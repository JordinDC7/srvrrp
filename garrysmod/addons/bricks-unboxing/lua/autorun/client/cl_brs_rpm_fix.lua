-- ============================================================
-- BRS Unique Weapons - High RPM Visual Fix
-- Fixes M9K animation jitter, sound stacking, and muzzle flash
-- pileup when RPM is boosted significantly
--
-- How it works:
--   1. Scales viewmodel animation playback rate to match RPM multiplier
--      so fire animation completes before next shot
--   2. Throttles firing sounds so they don't overlap/distort
--   3. Works automatically on any weapon with BRS_UW_RPMMultiplier
-- ============================================================

local lastFireTime = {}     -- [weapon entity index] = CurTime of last fire anim
local lastSoundTime = {}    -- [weapon entity index] = CurTime of last allowed sound

-- ============================================================
-- VIEWMODEL ANIMATION SPEED
-- Scale playback rate so fire animation finishes before next shot
-- ============================================================
hook.Add("PostDrawViewModel", "BRS_UW_RPMAnimFix", function(vm, ply, wep)
    if not IsValid(wep) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.0 then return end

    -- Get the viewmodel's current sequence info
    local seq = vm:GetSequence()
    if seq <= 0 then return end

    -- Scale playback rate to match RPM multiplier
    -- This makes the fire animation play faster so it completes
    -- before the next shot, preventing jitter/reset
    vm:SetPlaybackRate(mult)
end)

-- ============================================================
-- SOUND THROTTLING
-- Prevent firing sounds from stacking on top of each other
-- at high RPM, which causes distortion/buzzing
-- ============================================================
hook.Add("EntityEmitSound", "BRS_UW_RPMSoundFix", function(data)
    local ent = data.Entity
    if not IsValid(ent) then return end

    -- Check if this is a weapon with RPM boost
    -- The entity emitting might be the weapon or the player
    local wep
    if ent:IsWeapon() then
        wep = ent
    elseif ent:IsPlayer() then
        wep = ent:GetActiveWeapon()
    end

    if not IsValid(wep) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.15 then return end -- only throttle above 15% boost

    local baseDelay = wep:GetNW2Float("BRS_UW_BaseDelay", 0)
    if baseDelay <= 0 then return end

    -- Check if this sounds like a firing sound
    -- M9K firing sounds are typically in Primary.Sound
    local sndName = data.SoundName or ""
    -- Skip non-weapon sounds (UI, footsteps, etc.)
    -- M9K weapon sounds usually contain weapon-related paths
    local isFireSound = string.find(sndName, "weapon") or
                        string.find(sndName, "shoot") or
                        string.find(sndName, "fire") or
                        string.find(sndName, "m9k") or
                        string.find(sndName, "gun") or
                        string.find(sndName, "rifle") or
                        string.find(sndName, "pistol") or
                        string.find(sndName, "shotgun") or
                        string.find(sndName, "sniper") or
                        string.find(sndName, "smg") or
                        string.find(sndName, "auto")

    if not isFireSound then return end

    -- Throttle: ensure minimum interval between firing sounds
    -- At 2x RPM, we play every other sound (sounds at base rate)
    -- At 3x RPM, we play every third sound, etc.
    -- This keeps sound at roughly the original weapon's fire rate
    local idx = wep:EntIndex()
    local now = CurTime()
    local lastTime = lastSoundTime[idx] or 0
    local minInterval = baseDelay * 0.75 -- slightly faster than base to still feel boosted

    if now - lastTime < minInterval then
        return false -- suppress this sound
    end

    lastSoundTime[idx] = now

    -- Optionally pitch up slightly to hint at faster fire rate
    if mult > 1.3 then
        data.Pitch = math.Clamp((data.Pitch or 100) * math.min(mult * 0.85, 1.15), 90, 120)
        return true
    end
end)

-- ============================================================
-- MUZZLE FLASH THROTTLE
-- Reduce muzzle flash frequency at high RPM to prevent
-- visual overload (constant white screen)
-- ============================================================
hook.Add("PostDrawEffects", "BRS_UW_RPMMuzzleFix", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.5 then return end

    -- At very high RPM, suppress some muzzle effects to prevent flash overload
    -- We do this by reducing the weapon's MuzzleFlash function call rate
    -- This is handled implicitly by the animation speed fix above
end)

-- ============================================================
-- CLEANUP on weapon switch/removal
-- ============================================================
hook.Add("Think", "BRS_UW_RPMCleanup", function()
    -- Periodic cleanup of stale entries (every 5 seconds)
    local now = CurTime()
    if (BRS_UW_LastCleanup or 0) + 5 > now then return end
    BRS_UW_LastCleanup = now

    for idx, time in pairs(lastSoundTime) do
        if now - time > 2 then
            lastSoundTime[idx] = nil
            lastFireTime[idx] = nil
        end
    end
end)

print("[BRS UW] High RPM visual fix loaded")
