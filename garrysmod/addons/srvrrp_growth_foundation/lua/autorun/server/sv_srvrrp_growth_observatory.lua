if CLIENT then return end

if not SRVRRP_GROWTH then return end

SRVRRP_GROWTH.Observatory = SRVRRP_GROWTH.Observatory or {}
local OBS = SRVRRP_GROWTH.Observatory

OBS.NetStats = OBS.NetStats or {}
OBS.InboundByPlayer = OBS.InboundByPlayer or {}
OBS.Samples = OBS.Samples or {
    tickMs = {},
    entityCount = {}
}

local function minuteBucket()
    return math.floor(os.time() / 60)
end

local function addNetStat(name, bytes, direction)
    if not name then return end

    local record = OBS.NetStats[name]
    if not record then
        record = {
            inboundCount = 0,
            outboundCount = 0,
            inboundBytes = 0,
            outboundBytes = 0,
            blocked = 0,
            lastSeen = 0
        }
        OBS.NetStats[name] = record
    end

    if direction == "in" then
        record.inboundCount = record.inboundCount + 1
        record.inboundBytes = record.inboundBytes + (bytes or 0)
    else
        record.outboundCount = record.outboundCount + 1
        record.outboundBytes = record.outboundBytes + (bytes or 0)
    end

    record.lastSeen = os.time()
end

local function pushSample(key, value)
    local list = OBS.Samples[key]
    if not list then return end

    list[#list + 1] = value
    local maxFrames = SRVRRP_GROWTH.Config.MaxHistoryFrames or 300
    if #list > maxFrames then
        table.remove(list, 1)
    end
end

local function avg(list)
    if not list or #list == 0 then return 0 end

    local sum = 0
    for i = 1, #list do
        sum = sum + list[i]
    end

    return math.Round(sum / #list, 2)
end

local function enforceInboundBudget(player, msgName)
    if not IsValid(player) then return true end
    if not SRVRRP_GROWTH:IsEnabled("net_budget_enforcement") then return true end

    local budget = SRVRRP_GROWTH.Config.NetBudgets[msgName]
    if not budget then return true end

    local sid = player:SteamID64() or player:SteamID() or "unknown"
    local bucket = minuteBucket()

    OBS.InboundByPlayer[sid] = OBS.InboundByPlayer[sid] or {}
    local playerStats = OBS.InboundByPlayer[sid][msgName]

    if not playerStats or playerStats.bucket ~= bucket then
        playerStats = { bucket = bucket, count = 0 }
        OBS.InboundByPlayer[sid][msgName] = playerStats
    end

    playerStats.count = playerStats.count + 1
    if playerStats.count <= budget then return true end

    local global = OBS.NetStats[msgName]
    if global then
        global.blocked = global.blocked + 1
    end

    if SRVRRP_GROWTH:IsEnabled("telemetry_console_reports") then
        print(string.format(
            "[SRVRRP][OBS] blocked net '%s' from %s (%d/%d this minute)",
            msgName,
            player:Nick(),
            playerStats.count,
            budget
        ))
    end

    return false
end

local originalReceive = net.Receive
net.Receive = function(msgName, callback)
    if type(callback) ~= "function" then
        return originalReceive(msgName, callback)
    end

    local wrapped = function(length, player)
        addNetStat(msgName, math.floor((length or 0) / 8), "in")

        if not enforceInboundBudget(player, msgName) then
            return
        end

        callback(length, player)
    end

    return originalReceive(msgName, wrapped)
end

local originalStart = net.Start
local originalSend = net.Send
local originalBroadcast = net.Broadcast
local originalSendPVS = net.SendPVS
local originalSendPAS = net.SendPAS

local activeNetMessage

net.Start = function(msgName, unreliable)
    activeNetMessage = msgName
    return originalStart(msgName, unreliable)
end

local function recordOutboundAndCall(sendFn, target)
    local msgName = activeNetMessage
    local bytes = net.BytesWritten and net.BytesWritten() or 0

    local result = sendFn(target)

    addNetStat(msgName, bytes, "out")
    activeNetMessage = nil

    return result
end

net.Send = function(target)
    return recordOutboundAndCall(originalSend, target)
end

net.Broadcast = function()
    return recordOutboundAndCall(originalBroadcast)
end

net.SendPVS = function(pos)
    return recordOutboundAndCall(originalSendPVS, pos)
end

net.SendPAS = function(pos)
    return recordOutboundAndCall(originalSendPAS, pos)
end

hook.Add("Tick", "SRVRRP.Growth.ObservatoryTick", function()
    if not SRVRRP_GROWTH:IsEnabled("observatory_enabled") then return end

    local frameTimeMs = FrameTime() * 1000
    pushSample("tickMs", frameTimeMs)
    pushSample("entityCount", #ents.GetAll())
end)

local function printSnapshot(requester)
    local avgTick = avg(OBS.Samples.tickMs)
    local avgEntities = avg(OBS.Samples.entityCount)
    local slowThreshold = SRVRRP_GROWTH.Config.SlowTickMsThreshold or 30

    local line = string.format(
        "[SRVRRP][OBS] avgTickMs=%.2f avgEntities=%.2f threshold=%.2f",
        avgTick,
        avgEntities,
        slowThreshold
    )

    print(line)

    if IsValid(requester) then
        requester:PrintMessage(HUD_PRINTCONSOLE, line)
    end
end

concommand.Add("srvrrp_obs_snapshot", function(player)
    if IsValid(player) and not player:IsAdmin() then return end
    printSnapshot(player)
end)

concommand.Add("srvrrp_obs_topnets", function(player)
    if IsValid(player) and not player:IsAdmin() then return end

    local rows = {}
    for name, data in pairs(OBS.NetStats) do
        rows[#rows + 1] = {
            name = name,
            score = data.inboundBytes + data.outboundBytes,
            row = string.format(
                "[SRVRRP][OBS] %s in=%d/%dB out=%d/%dB blocked=%d",
                name,
                data.inboundCount,
                data.inboundBytes,
                data.outboundCount,
                data.outboundBytes,
                data.blocked
            )
        }
    end

    table.sort(rows, function(a, b) return a.score > b.score end)

    local limit = math.min(#rows, 15)
    print(string.format("[SRVRRP][OBS] top net messages (%d)", limit))
    for i = 1, limit do
        print(rows[i].row)
        if IsValid(player) then
            player:PrintMessage(HUD_PRINTCONSOLE, rows[i].row)
        end
    end
end)

concommand.Add("srvrrp_obs_reset", function(player)
    if IsValid(player) and not player:IsSuperAdmin() then return end

    OBS.NetStats = {}
    OBS.InboundByPlayer = {}
    OBS.Samples.tickMs = {}
    OBS.Samples.entityCount = {}

    print("[SRVRRP][OBS] observatory stats reset")
end)

concommand.Add("srvrrp_ff_list", function(player)
    if IsValid(player) and not player:IsAdmin() then return end

    print("[SRVRRP][FF] feature flags")
    for name, enabled in pairs(SRVRRP_GROWTH.Config.FeatureFlags) do
        local line = string.format("[SRVRRP][FF] %s = %s", name, tostring(enabled))
        print(line)
        if IsValid(player) then
            player:PrintMessage(HUD_PRINTCONSOLE, line)
        end
    end
end)

concommand.Add("srvrrp_ff_set", function(player, _, args)
    if IsValid(player) and not player:IsSuperAdmin() then return end

    local flagName = args[1]
    local value = args[2]

    if not flagName or not value then
        print("[SRVRRP][FF] usage: srvrrp_ff_set <flag_name> <0|1>")
        return
    end

    local enabled = value == "1" or string.lower(value) == "true"
    local ok = SRVRRP_GROWTH:SetFeatureFlag(flagName, enabled)

    if not ok then
        print(string.format("[SRVRRP][FF] unknown flag: %s", flagName))
        return
    end

    print(string.format("[SRVRRP][FF] %s set to %s", flagName, tostring(enabled)))
end)
