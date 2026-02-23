if not SERVER then return end

local addonTag = "srvrrp_perf"

local monitorEnabled = CreateConVar("srvrrp_perf_monitor_enabled", "1", FCVAR_ARCHIVE, "Enable lightweight server performance heartbeat.")
local monitorInterval = CreateConVar("srvrrp_perf_monitor_interval", "30", FCVAR_ARCHIVE, "Seconds between heartbeat snapshots.", 5, 300)
local warningFrameTimeMs = CreateConVar("srvrrp_perf_warn_frametime_ms", "35", FCVAR_ARCHIVE, "Warn when average frame time exceeds this value in ms.", 5, 200)
local warningEntityCount = CreateConVar("srvrrp_perf_warn_entity_count", "2200", FCVAR_ARCHIVE, "Warn when entity count exceeds this value.", 100, 10000)
local persistSnapshots = CreateConVar("srvrrp_perf_persist_snapshots", "1", FCVAR_ARCHIVE, "Persist recent performance snapshots to data/srvrrp/perf_snapshots.json.")
local maxSnapshots = CreateConVar("srvrrp_perf_max_snapshots", "120", FCVAR_ARCHIVE, "Maximum persisted snapshots.", 20, 2000)
local netMonitorEnabled = CreateConVar("srvrrp_perf_net_monitor_enabled", "1", FCVAR_ARCHIVE, "Track net.Receive handler runtime stats.")
local timerMonitorEnabled = CreateConVar("srvrrp_perf_timer_monitor_enabled", "1", FCVAR_ARCHIVE, "Track timer callback runtime stats.")

local propGuardEnabled = CreateConVar("srvrrp_prop_guard_enabled", "1", FCVAR_ARCHIVE, "Limit prop spawn bursts per player.")
local propGuardWindow = CreateConVar("srvrrp_prop_guard_window", "2", FCVAR_ARCHIVE, "Seconds in rate-limit window.", 1, 30)
local propGuardLimit = CreateConVar("srvrrp_prop_guard_limit", "12", FCVAR_ARCHIVE, "Max props in the guard window.", 1, 100)

local ragdollCleanupEnabled = CreateConVar("srvrrp_ragdoll_cleanup_enabled", "0", FCVAR_ARCHIVE, "Enable automatic cleanup of old ragdolls.")
local ragdollCleanupAge = CreateConVar("srvrrp_ragdoll_cleanup_age", "180", FCVAR_ARCHIVE, "Ragdoll max age in seconds before cleanup.", 30, 3600)
local ragdollCleanupInterval = CreateConVar("srvrrp_ragdoll_cleanup_interval", "30", FCVAR_ARCHIVE, "Seconds between ragdoll cleanup passes.", 5, 300)

local netBudgetEnabled = CreateConVar("srvrrp_net_budget_enabled", "1", FCVAR_ARCHIVE, "Enable net message budgeting diagnostics.")
local netBudgetWarnRatio = CreateConVar("srvrrp_net_budget_warn_ratio", "0.85", FCVAR_ARCHIVE, "Warn when a message reaches this ratio of its budget.", 0.5, 1)
local telemetryEnabled = CreateConVar("srvrrp_ui_telemetry_enabled", "1", FCVAR_ARCHIVE, "Enable SRVRRP UI telemetry aggregation.")

local sample = {
    frameTime = {},
    frameIdx = 1,
    frameSamples = 0,
    peakFrameMs = 0,
    snapshots = 0,
}

local propSpawnState = {}

local trackedRagdolls = {}
local netBudgets = {}
local netUsage = {}
local netWindow = {}
local timerWindow = {}
local snapshotHistory = {}
local snapshotPath = "srvrrp/perf_snapshots.json"
local uiTelemetry = {
    startedAt = CurTime(),
    totals = {},
    byPlayer = {},
}

local originalNetReceive = net.Receive
local originalTimerCreate = timer.Create

local function loadSnapshotHistory()
    if not file.Exists(snapshotPath, "DATA") then
        return
    end

    local raw = file.Read(snapshotPath, "DATA")
    if raw == nil or raw == "" then
        return
    end

    local decoded = util.JSONToTable(raw)
    if istable(decoded) then
        snapshotHistory = decoded
    end
end

local function persistSnapshotHistory()
    if not persistSnapshots:GetBool() then
        return
    end

    file.CreateDir("srvrrp")
    file.Write(snapshotPath, util.TableToJSON(snapshotHistory, false) or "[]")
end

local function resetMonitoringWindows()
    netWindow = {}
    timerWindow = {}
end

local function topRuntimeSummary(window, keyLabel)
    local rows = {}
    for key, state in pairs(window) do
        rows[#rows + 1] = {
            key = key,
            calls = state.calls or 0,
            bits = state.bits or 0,
            totalRuntimeMs = state.totalRuntimeMs or 0,
            maxRuntimeMs = state.maxRuntimeMs or 0,
        }
    end

    table.sort(rows, function(a, b)
        if a.totalRuntimeMs == b.totalRuntimeMs then
            return a.calls > b.calls
        end

        return a.totalRuntimeMs > b.totalRuntimeMs
    end)

    local top = {}
    for i = 1, math.min(5, #rows) do
        local row = rows[i]
        top[#top + 1] = string.format(
            "%s=%s calls=%d bits=%d total=%.2fms max=%.2fms",
            keyLabel,
            row.key,
            row.calls,
            row.bits,
            row.totalRuntimeMs,
            row.maxRuntimeMs
        )
    end

    if #top == 0 then
        return "none"
    end

    return table.concat(top, " | ")
end

net.Receive = function(messageName, callback)
    if type(callback) ~= "function" then
        return originalNetReceive(messageName, callback)
    end

    return originalNetReceive(messageName, function(len, ply)
        if not netMonitorEnabled:GetBool() then
            return callback(len, ply)
        end

        local runtimeStart = SysTime()
        callback(len, ply)
        local elapsedMs = (SysTime() - runtimeStart) * 1000

        local state = netWindow[messageName]
        if not state then
            state = {
                calls = 0,
                bits = 0,
                totalRuntimeMs = 0,
                maxRuntimeMs = 0,
            }
            netWindow[messageName] = state
        end

        state.calls = state.calls + 1
        state.bits = state.bits + math.max(0, tonumber(len) or 0)
        state.totalRuntimeMs = state.totalRuntimeMs + elapsedMs
        if elapsedMs > state.maxRuntimeMs then
            state.maxRuntimeMs = elapsedMs
        end
    end)
end

timer.Create = function(name, delay, repetitions, callback)
    if type(callback) ~= "function" then
        return originalTimerCreate(name, delay, repetitions, callback)
    end

    local timerName = tostring(name or "anonymous")
    return originalTimerCreate(name, delay, repetitions, function(...)
        if not timerMonitorEnabled:GetBool() then
            return callback(...)
        end

        local runtimeStart = SysTime()
        callback(...)
        local elapsedMs = (SysTime() - runtimeStart) * 1000

        local state = timerWindow[timerName]
        if not state then
            state = {
                calls = 0,
                bits = 0,
                totalRuntimeMs = 0,
                maxRuntimeMs = 0,
            }
            timerWindow[timerName] = state
        end

        state.calls = state.calls + 1
        state.totalRuntimeMs = state.totalRuntimeMs + elapsedMs
        if elapsedMs > state.maxRuntimeMs then
            state.maxRuntimeMs = elapsedMs
        end
    end)
end

local function registerNetBudget(messageName, perMinute, description)
    if messageName == nil or messageName == "" then
        return
    end

    netBudgets[messageName] = {
        perMinute = math.max(1, tonumber(perMinute) or 1),
        description = description or "",
    }
end

function SRVRRP_RegisterNetBudget(messageName, perMinute, description)
    registerNetBudget(messageName, perMinute, description)
end

function SRVRRP_TrackNetMessage(messageName, recipientCount)
    if not netBudgetEnabled:GetBool() then
        return
    end

    local budget = netBudgets[messageName]
    if not budget then
        return
    end

    local now = CurTime()
    local state = netUsage[messageName]
    if not state then
        state = {
            windowStart = now,
            count = 0,
            warns = 0,
        }
        netUsage[messageName] = state
    end

    if now - state.windowStart >= 60 then
        state.windowStart = now
        state.count = 0
        state.warns = 0
    end

    state.count = state.count + math.max(1, tonumber(recipientCount) or 1)

    local warnThreshold = budget.perMinute * netBudgetWarnRatio:GetFloat()
    if state.count >= warnThreshold and state.warns < 2 then
        state.warns = state.warns + 1
        print(string.format("[%s][NET][WARN] %s reached %d/%d recipients per minute (%s)", addonTag, messageName, state.count, budget.perMinute, budget.description))
    end
end

registerNetBudget("srvrrp_mega_update_open_hub", 150, "Hub open signal")
registerNetBudget("srvrrp_mega_update_tip", 220, "Spawn and briefing hints")
registerNetBudget("srvrrp_mega_update_daily_brief", 160, "Daily brief payload")

local function addFrameSample()
    local frameMs = FrameTime() * 1000

    sample.frameTime[sample.frameIdx] = frameMs
    sample.frameIdx = sample.frameIdx + 1
    if sample.frameIdx > 128 then
        sample.frameIdx = 1
    end

    if sample.frameSamples < 128 then
        sample.frameSamples = sample.frameSamples + 1
    end

    if frameMs > sample.peakFrameMs then
        sample.peakFrameMs = frameMs
    end
end

local function averageFrameMs()
    if sample.frameSamples == 0 then
        return 0
    end

    local total = 0
    for i = 1, sample.frameSamples do
        total = total + (sample.frameTime[i] or 0)
    end

    return total / sample.frameSamples
end

hook.Add("Think", addonTag .. "_frametime_sample", addFrameSample)

local function buildSnapshot()
    local playerCount = #player.GetHumans()
    local entities = ents.GetAll()
    local entityCount = #entities
    local classCounts = {}

    for i = 1, entityCount do
        local className = entities[i]:GetClass()
        classCounts[className] = (classCounts[className] or 0) + 1
    end

    local topClasses = {}
    for className, count in pairs(classCounts) do
        topClasses[#topClasses + 1] = {
            className = className,
            count = count,
        }
    end

    table.sort(topClasses, function(a, b)
        return a.count > b.count
    end)

    local topSummary = {}
    for i = 1, math.min(5, #topClasses) do
        local row = topClasses[i]
        topSummary[#topSummary + 1] = string.format("%s=%d", row.className, row.count)
    end

    local averageMs = averageFrameMs()

    sample.snapshots = sample.snapshots + 1

    return {
        timestamp = os.time(),
        averageFrameMs = averageMs,
        peakFrameMs = sample.peakFrameMs,
        playerCount = playerCount,
        entityCount = entityCount,
        topClasses = table.concat(topSummary, ", "),
        topNet = topRuntimeSummary(netWindow, "channel"),
        topTimers = topRuntimeSummary(timerWindow, "timer"),
        snapshots = sample.snapshots,
    }
end

local function printSnapshot(prefix)
    local snapshot = buildSnapshot()

    print(string.format(
        "[%s] %s avg=%.2fms peak=%.2fms players=%d entities=%d top=[%s]",
        addonTag,
        prefix,
        snapshot.averageFrameMs,
        snapshot.peakFrameMs,
        snapshot.playerCount,
        snapshot.entityCount,
        snapshot.topClasses
    ))

    print(string.format("[%s] %s net=[%s]", addonTag, prefix, snapshot.topNet))
    print(string.format("[%s] %s timers=[%s]", addonTag, prefix, snapshot.topTimers))

    if snapshot.averageFrameMs >= warningFrameTimeMs:GetFloat() then
        print(string.format("[%s][WARN] Average frame time high: %.2fms", addonTag, snapshot.averageFrameMs))
    end

    if snapshot.entityCount >= warningEntityCount:GetInt() then
        print(string.format("[%s][WARN] Entity count high: %d", addonTag, snapshot.entityCount))
    end

    if netBudgetEnabled:GetBool() then
        for messageName, budget in pairs(netBudgets) do
            local state = netUsage[messageName]
            local count = state and state.count or 0
            print(string.format("[%s][NET] %s usage=%d/%d", addonTag, messageName, count, budget.perMinute))
        end
    end

    snapshot.reason = prefix
    snapshotHistory[#snapshotHistory + 1] = snapshot

    local keep = math.max(20, maxSnapshots:GetInt())
    while #snapshotHistory > keep do
        table.remove(snapshotHistory, 1)
    end

    persistSnapshotHistory()
    resetMonitoringWindows()
end

local function scheduleMonitorTimer()
    timer.Remove(addonTag .. "_heartbeat")

    if not monitorEnabled:GetBool() then
        return
    end

    timer.Create(addonTag .. "_heartbeat", monitorInterval:GetFloat(), 0, function()
        if not monitorEnabled:GetBool() then
            return
        end

        printSnapshot("heartbeat")
    end)
end

cvars.AddChangeCallback("srvrrp_perf_monitor_enabled", function()
    scheduleMonitorTimer()
end, addonTag .. "_monitor_enabled")

cvars.AddChangeCallback("srvrrp_perf_monitor_interval", function()
    scheduleMonitorTimer()
end, addonTag .. "_monitor_interval")

concommand.Add("srvrrp_perf_snapshot", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("Admin only.")
        return
    end

    printSnapshot("manual")
end, nil, "Prints a single lightweight performance snapshot.")

concommand.Add("srvrrp_net_budget_snapshot", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("Admin only.")
        return
    end

    print(string.format("[%s] Net budget snapshot", addonTag))
    for messageName, budget in pairs(netBudgets) do
        local state = netUsage[messageName]
        local count = state and state.count or 0
        print(string.format("[%s][NET] %s=%d/%d (%s)", addonTag, messageName, count, budget.perMinute, budget.description))
    end
end, nil, "Prints net message budget usage for tracked SRVRRP channels.")

concommand.Add("srvrrp_perf_dump_history", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("Admin only.")
        return
    end

    print(string.format("[%s] Snapshot history path=data/%s count=%d", addonTag, snapshotPath, #snapshotHistory))

    local startIdx = math.max(1, #snapshotHistory - 4)
    for i = startIdx, #snapshotHistory do
        local entry = snapshotHistory[i]
        print(string.format(
            "[%s] #%d reason=%s avg=%.2fms players=%d entities=%d",
            addonTag,
            i,
            entry.reason or "unknown",
            tonumber(entry.averageFrameMs) or 0,
            tonumber(entry.playerCount) or 0,
            tonumber(entry.entityCount) or 0
        ))
    end
end, nil, "Prints recent persisted performance snapshot metadata.")

hook.Add("PlayerSpawnProp", addonTag .. "_prop_guard", function(ply)
    if not propGuardEnabled:GetBool() then
        return
    end

    if not IsValid(ply) or ply:IsAdmin() then
        return
    end

    local now = CurTime()
    local state = propSpawnState[ply]

    if not state or now > state.windowEnd then
        state = {
            count = 0,
            windowEnd = now + propGuardWindow:GetFloat(),
        }
        propSpawnState[ply] = state
    end

    state.count = state.count + 1

    if state.count > propGuardLimit:GetInt() then
        if state.lastWarn == nil or now - state.lastWarn > 2 then
            state.lastWarn = now
            ply:ChatPrint("You are spawning props too quickly. Please slow down.")
        end

        return false
    end
end)

hook.Add("PlayerDisconnected", addonTag .. "_prop_guard_cleanup", function(ply)
    propSpawnState[ply] = nil
end)

hook.Add("OnEntityCreated", addonTag .. "_track_ragdolls", function(ent)
    if not IsValid(ent) then
        return
    end

    timer.Simple(0, function()
        if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" then
            return
        end

        trackedRagdolls[ent] = CurTime()
    end)
end)

local function cleanupRagdolls()
    if not ragdollCleanupEnabled:GetBool() then
        return
    end

    local now = CurTime()
    local ageLimit = ragdollCleanupAge:GetFloat()
    local removed = 0

    for ent, createdAt in pairs(trackedRagdolls) do
        if not IsValid(ent) then
            trackedRagdolls[ent] = nil
        elseif now - createdAt >= ageLimit then
            ent:Remove()
            trackedRagdolls[ent] = nil
            removed = removed + 1
        end
    end

    if removed > 0 then
        print(string.format("[%s] Removed %d ragdolls older than %.0fs", addonTag, removed, ageLimit))
    end
end

local function scheduleRagdollTimer()
    timer.Remove(addonTag .. "_ragdoll_cleanup")

    timer.Create(addonTag .. "_ragdoll_cleanup", ragdollCleanupInterval:GetFloat(), 0, cleanupRagdolls)
end

cvars.AddChangeCallback("srvrrp_ragdoll_cleanup_interval", function()
    scheduleRagdollTimer()
end, addonTag .. "_ragdoll_interval")

util.AddNetworkString("srvrrp_ui_telemetry_event")

net.Receive("srvrrp_ui_telemetry_event", function(_, ply)
    if not telemetryEnabled:GetBool() then
        return
    end

    if not IsValid(ply) then
        return
    end

    local eventKey = string.sub(string.lower(net.ReadString() or ""), 1, 48)
    if eventKey == "" then
        return
    end

    uiTelemetry.totals[eventKey] = (uiTelemetry.totals[eventKey] or 0) + 1

    local sid = ply:SteamID64() or ply:SteamID() or "unknown"
    local pState = uiTelemetry.byPlayer[sid]
    if not pState then
        pState = {}
        uiTelemetry.byPlayer[sid] = pState
    end

    pState[eventKey] = (pState[eventKey] or 0) + 1
end)

timer.Create(addonTag .. "_ui_telemetry_heartbeat", 120, 0, function()
    if not telemetryEnabled:GetBool() then
        return
    end

    local rows = {}
    for eventKey, count in pairs(uiTelemetry.totals) do
        rows[#rows + 1] = {
            eventKey = eventKey,
            count = count,
        }
    end

    table.sort(rows, function(a, b)
        return a.count > b.count
    end)

    local top = {}
    for i = 1, math.min(5, #rows) do
        top[#top + 1] = string.format("%s=%d", rows[i].eventKey, rows[i].count)
    end

    if #top > 0 then
        print(string.format("[%s][UI] top events since boot: %s", addonTag, table.concat(top, ", ")))
    end
end)

loadSnapshotHistory()
scheduleMonitorTimer()
scheduleRagdollTimer()

print("[srvrrp_perf] Performance monitor and guardrails initialized.")
