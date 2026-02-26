-- ============================================================
-- BRS Unique Weapons - High RPM Visual Fix
-- Fixes M9K animation jitter at boosted RPM
--
-- How it works:
--   1. Scales viewmodel animation playback rate to match RPM
--      so fire animation completes before next shot
--   2. Slight pitch increase on firing sounds to convey speed
--   3. Does NOT suppress any sounds or bullets
-- ============================================================

-- ============================================================
-- VIEWMODEL ANIMATION SPEED
-- Scale playback rate so fire animation finishes before next shot
-- ============================================================
hook.Add("PostDrawViewModel", "BRS_UW_RPMAnimFix", function(vm, ply, wep)
    if not IsValid(wep) or not IsValid(vm) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.0 then return end

    -- Scale playback rate to match RPM multiplier
    -- This makes the fire animation play faster so it completes
    -- before the next shot resets it, preventing jitter
    vm:SetPlaybackRate(mult)
end)

-- ============================================================
-- SOUND PITCH ADJUSTMENT (no suppression)
-- Slightly pitch up firing sounds to convey faster fire rate
-- Never returns false - never blocks any sound
-- ============================================================
hook.Add("EntityEmitSound", "BRS_UW_RPMSoundFix", function(data)
    local ent = data.Entity
    if not IsValid(ent) then return end

    local wep
    if ent:IsWeapon() then
        wep = ent
    elseif ent:IsPlayer() then
        wep = ent:GetActiveWeapon()
    end

    if not IsValid(wep) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.2 then return end -- only adjust above 20% boost

    -- Subtle pitch increase - caps at 115% pitch for 2x+ RPM
    -- Makes it sound faster without distortion
    local pitchMult = math.Clamp(1 + (mult - 1) * 0.15, 1.0, 1.15)
    data.Pitch = math.Clamp((data.Pitch or 100) * pitchMult, 80, 130)
    return true
end)

print("[BRS UW] High RPM visual fix loaded")
