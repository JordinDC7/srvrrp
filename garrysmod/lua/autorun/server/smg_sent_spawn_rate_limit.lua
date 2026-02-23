if not SERVER then return end

local SENT_SPAWN_WINDOW = 2
local SENT_SPAWN_LIMIT = 12
local SENT_BURST_COOLDOWN = 5

local sentSpawnTracker = {}

local function cleanupTracker()
  local now = CurTime()

  for steamID64, data in pairs(sentSpawnTracker) do
    if not data.lastAttempt or (now - data.lastAttempt) > 60 then
      sentSpawnTracker[steamID64] = nil
    end
  end
end

timer.Create("SmG_SentSpawnRateLimit_Cleanup", 60, 0, cleanupTracker)

hook.Add("PlayerSpawnSENT", "SmG_SentSpawnRateLimit", function(ply)
  if not IsValid(ply) then return end

  local steamID64 = ply:SteamID64()
  if not steamID64 then return end

  local now = CurTime()
  local data = sentSpawnTracker[steamID64]

  if not data then
    sentSpawnTracker[steamID64] = {
      windowStart = now,
      count = 1,
      lastAttempt = now
    }

    return
  end

  data.lastAttempt = now

  if data.blockedUntil and data.blockedUntil > now then
    return false
  end

  if (now - data.windowStart) > SENT_SPAWN_WINDOW then
    data.windowStart = now
    data.count = 1
    return
  end

  data.count = data.count + 1

  if data.count <= SENT_SPAWN_LIMIT then return end

  data.blockedUntil = now + SENT_BURST_COOLDOWN
  data.windowStart = now
  data.count = 0

  if DarkRP and DarkRP.notify then
    DarkRP.notify(ply, 1, 4, "You're spawning entities too quickly. Please slow down.")
  end

  return false
end)
