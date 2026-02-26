-- ============================================================
-- BRS Unique Weapons - High RPM Fix (Client)
-- 
-- Fixes for boosted RPM weapons:
--   1. Viewmodel animation playback rate scaled to match RPM
--   2. Stop previous firing sound before new one plays
--      (prevents stacking/buzzing without blocking any sound)
-- ============================================================

-- ============================================================
-- VIEWMODEL ANIMATION SPEED
-- Scales playback rate so fire animation completes before the
-- next shot resets it, preventing jitter/stuttering
-- ============================================================
hook.Add("PostDrawViewModel", "BRS_UW_RPMAnimFix", function(vm, ply, wep)
    if not IsValid(wep) or not IsValid(vm) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.0 then return end

    vm:SetPlaybackRate(mult)
end)

-- ============================================================
-- SOUND DE-OVERLAP
-- Before each new firing sound plays, stop the previous instance
-- of that same sound on the entity. This prevents overlapping
-- sounds that create buzzing/distortion at high RPM.
-- 
-- NEVER returns false - NEVER blocks any sound from playing.
-- Every shot still gets its full sound, just not stacked.
-- ============================================================
local trackedSounds = {} -- [entIndex] = last sound name

hook.Add("EntityEmitSound", "BRS_UW_RPMSoundFix", function(data)
    local ent = data.Entity
    if not IsValid(ent) then return end

    -- Find the weapon entity
    local wep
    if ent:IsWeapon() then
        wep = ent
    elseif ent:IsPlayer() then
        wep = ent:GetActiveWeapon()
    end
    if not IsValid(wep) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.0 then return end

    -- Stop the previous instance of this sound to prevent overlap
    local idx = ent:EntIndex()
    local sndName = data.SoundName
    if trackedSounds[idx] and trackedSounds[idx] == sndName then
        ent:StopSound(sndName)
    end
    trackedSounds[idx] = sndName

    -- Let the new sound play normally (never block)
end)

print("[BRS UW] High RPM client fix loaded")
