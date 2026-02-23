if not SERVER then return end

local addonTag = "srvrrp_perf"

local monitorEnabled = CreateConVar("srvrrp_perf_monitor_enabled", "1", FCVAR_ARCHIVE, "Enable lightweight server performance heartbeat.")
local monitorInterval = CreateConVar("srvrrp_perf_monitor_interval", "30", FCVAR_ARCHIVE, "Seconds between heartbeat snapshots.", 5, 300)
local warningFrameTimeMs = CreateConVar("srvrrp_perf_warn_frametime_ms", "35", FCVAR_ARCHIVE, "Warn when average frame time exceeds this value in ms.", 5, 200)
local warningEntityCount = CreateConVar("srvrrp_perf_warn_entity_count", "2200", FCVAR_ARCHIVE, "Warn when entity count exceeds this value.", 100, 10000)
local persistSnapshots = CreateConVar("srvrrp_perf_persist_snapshots", "1", FCVAR_ARCHIVE, "Persist heartbeat snapshots to data/srvrrp/perf_snapshots.json.")
local maxStoredSnapshots = CreateConVar("srvrrp_perf_max_snapshots", "240", FCVAR_ARCHIVE, "Maximum heartbeat snapshots kept on disk.", 10, 2000)

local netMonitorEnabled = CreateConVar("srvrrp_perf_net_monitor_enabled", "1", FCVAR_ARCHIVE, "Track net.Receive handler pressure and runtime.")
local timerMonitorEnabled = CreateConVar("srvrrp_perf_timer_monitor_enabled", "1", FCVAR_ARCHIVE, "Track timer callback runtime for hotspots.")

local propGuardEnabled = CreateConVar("srvrrp_prop_guard_enabled", "1", FCVAR_ARCHIVE, "Limit prop spawn bursts per player.")
local propGuardWindow = CreateConVar("srvrrp_prop_guard_window", "2", FCVAR_ARCHIVE, "Seconds in rate-limit window.", 1, 30)
local propGuardLimit = CreateConVar("srvrrp_prop_guard_limit", "12", FCVAR_ARCHIVE, "Max props in the guard window.", 1, 100)

local ragdollCleanupEnabled = CreateConVar("srvrrp_ragdoll_cleanup_enabled", "0", FCVAR_ARCHIVE, "Enable automatic cleanup of old ragdolls.")
local ragdollCleanupAge = CreateConVar("srvrrp_ragdoll_cleanup_age", "180", FCVAR_ARCHIVE, "Ragdoll max age in seconds before cleanup.", 30, 3600)
local ragdollCleanupInterval = CreateConVar("srvrrp_ragdoll_cleanup_interval", "30", FCVAR_ARCHIVE, "Seconds between ragdoll cleanup passes.", 5, 300)

local sample = {
    frameTime = {},
    frameIdx = 1,
    frameSamples = 0,
    peakFrameMs = 0,
    snapshots = 0,
}

local propSpawnState = {}

local trackedRagdolls = {}
local perfHistoryPath = "srvrrp/perf_snapshots.json"

local netStats = {
    totalCalls = 0,
    totalBits = 0,
    handlers = {},
}

local timerStats = {
    callbacks = 0,
    timers = {},
}

local function recordNetStat(channelName, len, runMs, ply)
    netStats.totalCalls = netStats.totalCalls + 1
    netStats.totalBits = netStats.totalBits + (len or 0)

    local row = netStats.handlers[channelName]
    if not row then
        row = {
            calls = 0,
            bits = 0,
            maxMs = 0,
            totalMs = 0,
            players = {},
        }
        netStats.handlers[channelName] = row
    end

    row.calls = row.calls + 1
    row.bits = row.bits + (len or 0)
    row.totalMs = row.totalMs + runMs
    if runMs > row.maxMs then
        row.maxMs = runMs
    end

    if IsValid(ply) then
        row.players[ply] = (row.players[ply] or 0) + 1
    end
end

do
    local originalNetReceive = net.Receive

    net.Receive = function(name, callback)
        if not isfunction(callback) then
            return originalNetReceive(name, callback)
        end

        local wrapped = function(len, ply, ...)
            if not netMonitorEnabled:GetBool() then
                return callback(len, ply, ...)
            end

            local started = SysTime()
            local result = callback(len, ply, ...)
            local runMs = (SysTime() - started) * 1000

            recordNetStat(name, len, runMs, ply)

            return result
        end

        return originalNetReceive(name, wrapped)
    end
end

local function recordTimerStat(timerId, runMs)
    timerStats.callbacks = timerStats.callbacks + 1

    local row = timerStats.timers[timerId]
    if not row then
        row = {
            calls = 0,
            totalMs = 0,
            maxMs = 0,
        }
        timerStats.timers[timerId] = row
    end

    row.calls = row.calls + 1
    row.totalMs = row.totalMs + runMs
    if runMs > row.maxMs then
        row.maxMs = runMs
    end
end

do
    local originalTimerCreate = timer.Create

    timer.Create = function(identifier, delay, repetitions, func)
        if not isfunction(func) then
            return originalTimerCreate(identifier, delay, repetitions, func)
        end

        local wrapped = function(...)
            if not timerMonitorEnabled:GetBool() then
                return func(...)
            end

            local started = SysTime()
            local result = func(...)
            local runMs = (SysTime() - started) * 1000

            recordTimerStat(identifier, runMs)

            return result
        end

        return originalTimerCreate(identifier, delay, repetitions, wrapped)
    end
end

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

    local topNet = {}
    for channelName, row in pairs(netStats.handlers) do
        topNet[#topNet + 1] = {
            name = channelName,
            calls = row.calls,
        }
    end

    table.sort(topNet, function(a, b)
        return a.calls > b.calls
    end)

    local topNetSummary = {}
    for i = 1, math.min(5, #topNet) do
        local row = topNet[i]
        topNetSummary[#topNetSummary + 1] = string.format("%s=%d", row.name, row.calls)
    end

    local topTimers = {}
    for timerId, row in pairs(timerStats.timers) do
        topTimers[#topTimers + 1] = {
            timerId = timerId,
            totalMs = row.totalMs,
        }
    end

    table.sort(topTimers, function(a, b)
        return a.totalMs > b.totalMs
    end)

    local topTimerSummary = {}
    for i = 1, math.min(5, #topTimers) do
        local row = topTimers[i]
        topTimerSummary[#topTimerSummary + 1] = string.format("%s=%.2fms", row.timerId, row.totalMs)
    end

    sample.snapshots = sample.snapshots + 1

    return {
        timestamp = os.time(),
        averageFrameMs = averageMs,
        peakFrameMs = sample.peakFrameMs,
        playerCount = playerCount,
        entityCount = entityCount,
        topClasses = table.concat(topSummary, ", "),
        netCalls = netStats.totalCalls,
        netBits = netStats.totalBits,
        topNet = table.concat(topNetSummary, ", "),
        timerCallbacks = timerStats.callbacks,
        topTimers = table.concat(topTimerSummary, ", "),
        snapshots = sample.snapshots,
    }
end

local function persistSnapshot(snapshot)
    if not persistSnapshots:GetBool() then
        return
    end

    file.CreateDir("srvrrp")

    local existing = {}
    if file.Exists(perfHistoryPath, "DATA") then
        local raw = file.Read(perfHistoryPath, "DATA")
        local parsed = util.JSONToTable(raw or "", false, true)
        if istable(parsed) then
            existing = parsed
        end
    end

    existing[#existing + 1] = snapshot

    local maxSnapshots = maxStoredSnapshots:GetInt()
    while #existing > maxSnapshots do
        table.remove(existing, 1)
    end

    file.Write(perfHistoryPath, util.TableToJSON(existing, false))
end

local function clearWindowCounters()
    netStats.totalCalls = 0
    netStats.totalBits = 0
    netStats.handlers = {}

    timerStats.callbacks = 0
    timerStats.timers = {}
end

local function printSnapshot(prefix)
    local snapshot = buildSnapshot()

    print(string.format(
        "[%s] %s avg=%.2fms peak=%.2fms players=%d entities=%d top=[%s] net_calls=%d net_bits=%d top_net=[%s] timer_calls=%d top_timers=[%s]",
        addonTag,
        prefix,
        snapshot.averageFrameMs,
        snapshot.peakFrameMs,
        snapshot.playerCount,
        snapshot.entityCount,
        snapshot.topClasses,
        snapshot.netCalls,
        snapshot.netBits,
        snapshot.topNet,
        snapshot.timerCallbacks,
        snapshot.topTimers
    ))

    persistSnapshot(snapshot)
    clearWindowCounters()

    if snapshot.averageFrameMs >= warningFrameTimeMs:GetFloat() then
        print(string.format("[%s][WARN] Average frame time high: %.2fms", addonTag, snapshot.averageFrameMs))
    end

    if snapshot.entityCount >= warningEntityCount:GetInt() then
        print(string.format("[%s][WARN] Entity count high: %d", addonTag, snapshot.entityCount))
    end
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

concommand.Add("srvrrp_perf_dump_history", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("Admin only.")
        return
    end

    if not file.Exists(perfHistoryPath, "DATA") then
        print(string.format("[%s] No snapshot history found at data/%s", addonTag, perfHistoryPath))
        return
    end

    print(string.format("[%s] Snapshot history path: data/%s", addonTag, perfHistoryPath))
end, nil, "Prints the current snapshot history file path.")

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

scheduleMonitorTimer()
scheduleRagdollTimer()

print("[srvrrp_perf] Performance monitor and guardrails initialized.")
