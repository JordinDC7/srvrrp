-- ============================================================
-- BRS Unique Weapons - RPM Client Sync
--
-- DESIGN: Minimal, surgical, continuous.
-- Server sets Primary.Delay/RPM on its copy of the weapon.
-- Client gets the multiplier via NW2 and continuously
-- enforces the correct values on its own copy.
--
-- "Continuously" because M9K weapons reset Primary table on
-- Deploy, Holster, Initialize, etc. A one-time patch breaks
-- on weapon switch. Checking one weapon per frame is free.
-- ============================================================

-- ============================================================
-- CORE: Keep client Primary.Delay in sync with server
-- Runs every frame but only touches the active weapon.
-- Compares actual delay to target delay - only writes if wrong.
-- ============================================================
hook.Add("Think", "BRS_UW_ClientSync", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.Primary then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)

    if mult <= 1.0 then
        -- Not boosted or multiplier not received yet
        -- Restore if we previously patched this weapon
        if wep.BRS_UW_CL_OrigDelay then
            wep.Primary.Delay = wep.BRS_UW_CL_OrigDelay
            wep.Primary.RPM = wep.BRS_UW_CL_OrigRPM
            if wep.BRS_UW_CL_OrigRecoil then wep.Primary.Recoil = wep.BRS_UW_CL_OrigRecoil end
            if wep.BRS_UW_CL_OrigKickUp then wep.Primary.KickUp = wep.BRS_UW_CL_OrigKickUp end
            if wep.BRS_UW_CL_OrigKickDown then wep.Primary.KickDown = wep.BRS_UW_CL_OrigKickDown end
            if wep.BRS_UW_CL_OrigKickH then wep.Primary.KickHorizontal = wep.BRS_UW_CL_OrigKickH end
            wep.BRS_UW_CL_OrigDelay = nil
            wep.BRS_UW_CL_OrigRPM = nil
            wep.BRS_UW_CL_OrigRecoil = nil
            wep.BRS_UW_CL_OrigKickUp = nil
            wep.BRS_UW_CL_OrigKickDown = nil
            wep.BRS_UW_CL_OrigKickH = nil
        end
        return
    end

    -- Calculate what the values SHOULD be
    local origRPM = wep:GetNW2Float("BRS_UW_OrigRPM", 0)
    if origRPM <= 0 then return end

    local targetRPM = math.Round(origRPM * mult)
    local targetDelay = 60 / targetRPM

    -- Save originals on first encounter (before any modification)
    if not wep.BRS_UW_CL_OrigDelay then
        wep.BRS_UW_CL_OrigDelay = 60 / origRPM
        wep.BRS_UW_CL_OrigRPM = origRPM
        -- Save recoil originals
        wep.BRS_UW_CL_OrigRecoil = wep.Primary.Recoil
        wep.BRS_UW_CL_OrigKickUp = wep.Primary.KickUp
        wep.BRS_UW_CL_OrigKickDown = wep.Primary.KickDown
        wep.BRS_UW_CL_OrigKickH = wep.Primary.KickHorizontal
    end

    -- Enforce correct values (M9K may have reset them)
    wep.Primary.RPM = targetRPM
    wep.Primary.Delay = targetDelay

    -- Enforce recoil scaling
    local recoilScale = 1 / math.sqrt(mult)
    if wep.BRS_UW_CL_OrigRecoil then
        wep.Primary.Recoil = wep.BRS_UW_CL_OrigRecoil * recoilScale
    end
    if wep.BRS_UW_CL_OrigKickUp then
        wep.Primary.KickUp = wep.BRS_UW_CL_OrigKickUp * recoilScale
    end
    if wep.BRS_UW_CL_OrigKickDown then
        wep.Primary.KickDown = wep.BRS_UW_CL_OrigKickDown * recoilScale
    end
    if wep.BRS_UW_CL_OrigKickH then
        wep.Primary.KickHorizontal = wep.BRS_UW_CL_OrigKickH * recoilScale
    end
end)

-- ============================================================
-- ANIMATION: Speed up fire sequences only
-- ============================================================
local fireActivities = {
    [ACT_VM_PRIMARYATTACK] = true,
    [ACT_VM_SECONDARYATTACK] = true,
    [ACT_SHOTGUN_PUMP] = true,
}

local fireSeqNames = {
    fire = true, fire1 = true, fire2 = true, fire3 = true, fire4 = true,
    shoot = true, shoot1 = true, shoot2 = true, shoot3 = true,
    primaryattack = true, attack = true, attack1 = true,
}

hook.Add("PostDrawViewModel", "BRS_UW_RPMAnimFix", function(vm, ply, wep)
    if not IsValid(wep) or not IsValid(vm) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.0 then return end

    local seq = vm:GetSequence()
    if not seq or seq < 0 then return end

    local isFiring = false
    local act = vm:GetSequenceActivity(seq)
    if act and fireActivities[act] then
        isFiring = true
    end
    if not isFiring then
        local seqName = vm:GetSequenceName(seq)
        if seqName then
            isFiring = fireSeqNames[string.lower(seqName)] or false
        end
    end

    vm:SetPlaybackRate(isFiring and mult or 1.0)
end)

-- ============================================================
-- VIEWPUNCH: Scale down per-shot screen kick
-- ============================================================
local playerMeta = FindMetaTable("Player")
if playerMeta and playerMeta.ViewPunch then
    local origViewPunch = playerMeta.ViewPunch

    playerMeta.ViewPunch = function(self, ang)
        if not IsValid(self) or not ang then
            return origViewPunch(self, ang)
        end
        local wep = self:GetActiveWeapon()
        if IsValid(wep) then
            local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
            if mult > 1.0 then
                local s = 1 / math.sqrt(mult)
                return origViewPunch(self, Angle(ang.p * s, ang.y * s, ang.r * s))
            end
        end
        return origViewPunch(self, ang)
    end
end

-- ============================================================
-- SHELLS: Throttle ejection at high RPM
-- ============================================================
local lastShellTime = 0

if util and util.Effect then
    local origEffect = util.Effect
    util.Effect = function(name, effectData, ...)
        if name and (string.find(name, "[Ss]hell") or string.find(name, "[Bb]rass") or string.find(name, "[Ee]ject")) then
            local ply = LocalPlayer()
            if IsValid(ply) then
                local wep = ply:GetActiveWeapon()
                if IsValid(wep) then
                    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
                    if mult > 1.3 then
                        local now = CurTime()
                        local origDelay = wep:GetNW2Float("BRS_UW_OrigDelay", 0.1)
                        if now - lastShellTime < origDelay * 0.7 then return end
                        lastShellTime = now
                    end
                end
            end
        end
        return origEffect(name, effectData, ...)
    end
end

-- ============================================================
-- SOUND: Rotate channels for fire sound ONLY
-- Matches the exact Primary.Sound string. Nothing else touched.
-- ============================================================
local channels = {CHAN_WEAPON, CHAN_WEAPON2, CHAN_BODY, CHAN_VOICE}
local chanIdx = 0

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
    if mult <= 1.0 then return end

    -- ONLY rotate channel for the weapon's fire sound
    local fireSound = wep.Primary and wep.Primary.Sound
    if not fireSound then return end
    if data.SoundName ~= fireSound then return end

    chanIdx = chanIdx + 1
    if chanIdx > #channels then chanIdx = 1 end
    data.Channel = channels[chanIdx]
    return true
end)

print("[BRS UW] RPM sync loaded")
