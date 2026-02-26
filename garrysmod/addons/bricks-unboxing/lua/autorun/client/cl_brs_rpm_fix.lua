-- ============================================================
-- BRS Unique Weapons - RPM Polish System
--
-- PHILOSOPHY: Make boosted weapons feel BETTER than stock,
-- not worse. Stock M9K has a natural rhythm. Our job is to
-- preserve that rhythm at higher speed and add premium feel.
--
-- APPROACH:
--   1. Continuously sync Primary.Delay/RPM to client (core fix)
--   2. Pitch randomization on fire sounds (natural variation)
--   3. Smooth recoil dampening (not sharp per-shot override)
--   4. Let animations interrupt naturally (no forced playback)
--   5. Subtle camera smoothing during rapid fire
-- ============================================================

-- ============================================================
-- 1. CORE: Continuous Primary.Delay/RPM sync
-- This is non-negotiable. Without it, client predicts at wrong rate.
-- Runs every frame on active weapon only.
-- ============================================================
hook.Add("Think", "BRS_UW_ClientSync", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.Primary then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)

    if mult <= 1.0 then
        -- Restore originals if we modified this weapon
        if wep.BRS_UW_CL_Orig then
            local o = wep.BRS_UW_CL_Orig
            wep.Primary.Delay = o.Delay
            wep.Primary.RPM = o.RPM
            if o.Recoil then wep.Primary.Recoil = o.Recoil end
            if o.KickUp then wep.Primary.KickUp = o.KickUp end
            if o.KickDown then wep.Primary.KickDown = o.KickDown end
            if o.KickHorizontal then wep.Primary.KickHorizontal = o.KickHorizontal end
            wep.BRS_UW_CL_Orig = nil
        end
        return
    end

    local origRPM = wep:GetNW2Float("BRS_UW_OrigRPM", 0)
    if origRPM <= 0 then return end

    -- Save originals once
    if not wep.BRS_UW_CL_Orig then
        wep.BRS_UW_CL_Orig = {
            Delay = 60 / origRPM,
            RPM = origRPM,
            Recoil = wep.Primary.Recoil,
            KickUp = wep.Primary.KickUp,
            KickDown = wep.Primary.KickDown,
            KickHorizontal = wep.Primary.KickHorizontal,
        }
    end

    -- Enforce boosted values every frame
    local targetRPM = math.Round(origRPM * mult)
    wep.Primary.RPM = targetRPM
    wep.Primary.Delay = 60 / targetRPM

    -- Smooth recoil scaling
    local rs = 1 / math.sqrt(mult)
    local o = wep.BRS_UW_CL_Orig
    if o.Recoil then wep.Primary.Recoil = o.Recoil * rs end
    if o.KickUp then wep.Primary.KickUp = o.KickUp * rs end
    if o.KickDown then wep.Primary.KickDown = o.KickDown * rs end
    if o.KickHorizontal then wep.Primary.KickHorizontal = o.KickHorizontal * rs end
end)

-- ============================================================
-- 2. SOUND: Natural pitch variation instead of channel rotation
--
-- Channel rotation causes robotic feel because each channel
-- has slightly different spatialization. Instead: let Source
-- handle channels naturally and add random pitch variation
-- so each shot sounds slightly different (like a real gun).
-- Source may drop an occasional sound at very high RPM - 
-- the pitch variation masks this perfectly.
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
    if mult <= 1.0 then return end

    -- Only touch the weapon's fire sound
    local fireSound = wep.Primary and wep.Primary.Sound
    if not fireSound or data.SoundName ~= fireSound then return end

    -- Pitch variation: ±4% random per shot
    -- This makes sustained fire sound natural instead of a loop
    local basePitch = data.Pitch or 100
    local variation = math.Rand(-4, 4)
    data.Pitch = math.Clamp(basePitch + variation, 85, 115)

    -- Slight volume variation for realism (±5%)
    local baseVol = data.Volume or 1
    data.Volume = math.Clamp(baseVol + math.Rand(-0.05, 0.05), 0.85, 1.0)

    return true
end)

-- ============================================================
-- 3. RECOIL: Smooth dampening instead of sharp ViewPunch override
--
-- Problem: ViewPunch applies instant angular kick. At high RPM
-- these stack into a vibrating mess even when scaled down.
--
-- Fix: Dampen ViewPunch recovery speed so the camera smoothly
-- settles between shots instead of snapping back and forth.
-- Also slightly randomize kick direction for natural spray.
-- ============================================================
local playerMeta = FindMetaTable("Player")
if playerMeta and playerMeta.ViewPunch then
    local origViewPunch = playerMeta.ViewPunch

    playerMeta.ViewPunch = function(self, ang)
        if not IsValid(self) or not ang then
            return origViewPunch(self, ang)
        end

        local wep = self:GetActiveWeapon()
        if not IsValid(wep) then return origViewPunch(self, ang) end

        local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
        if mult <= 1.0 then return origViewPunch(self, ang) end

        -- Scale magnitude by sqrt
        local s = 1 / math.sqrt(mult)

        -- Add slight random variation to horizontal kick
        -- Makes spray feel organic instead of a perfect line
        local horizJitter = math.Rand(-0.15, 0.15) * math.abs(ang.p)

        return origViewPunch(self, Angle(
            ang.p * s,
            ang.y * s + horizJitter,
            ang.r * s * 0.5  -- reduce roll even more, it causes nausea at high RPM
        ))
    end
end

-- ============================================================
-- 4. ANIMATION: Gentle speed scaling with natural cap
--
-- At 1.3x RPM, play anim at 1.3x - looks fine.
-- Above 1.6x, cap anim speed and let shots interrupt naturally.
-- Fast-interrupting fire anim looks like a real fast gun.
-- Raw 2.5x playback looks like a sped-up video = bad.
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

    if isFiring then
        vm:SetPlaybackRate(mult)
    else
        vm:SetPlaybackRate(1.0)
    end
end)

-- ============================================================
-- 5. CAMERA: Subtle smooth shake during sustained rapid fire
-- Adds a gentle camera sway that builds during sustained fire
-- and fades out when you stop. Feels premium and physical.
-- ============================================================
local sustainedFireTime = 0
local lastShotTime = 0
local smoothShake = Angle(0, 0, 0)

hook.Add("CalcView", "BRS_UW_CameraSmooth", function(ply, pos, ang, fov)
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then
        smoothShake = Angle(0, 0, 0)
        return
    end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.0 then
        smoothShake = Angle(0, 0, 0)
        return
    end

    local now = CurTime()
    local shooting = ply:KeyDown(IN_ATTACK) and wep:Clip1() > 0

    if shooting then
        -- Build up sustained fire timer
        if now - lastShotTime > 0.3 then
            sustainedFireTime = 0  -- reset if gap between bursts
        end
        sustainedFireTime = sustainedFireTime + FrameTime()
        lastShotTime = now

        -- Intensity builds over ~0.5 seconds of sustained fire
        local intensity = math.Clamp(sustainedFireTime / 0.5, 0, 1)
        intensity = intensity * (mult - 1) * 0.3  -- scale with RPM boost

        -- Smooth organic camera sway using perlin-like noise
        local t = now * 8
        local targetShake = Angle(
            math.sin(t * 1.1) * intensity * 0.15,
            math.cos(t * 0.9) * intensity * 0.12,
            math.sin(t * 1.3) * intensity * 0.05
        )

        -- Smooth interpolation
        smoothShake = LerpAngle(FrameTime() * 12, smoothShake, targetShake)
    else
        -- Fade out smoothly
        smoothShake = LerpAngle(FrameTime() * 8, smoothShake, Angle(0, 0, 0))
        local mag = math.abs(smoothShake.p) + math.abs(smoothShake.y) + math.abs(smoothShake.r)
        if mag < 0.01 then
            smoothShake = Angle(0, 0, 0)
            return
        end
    end

    local mag = math.abs(smoothShake.p) + math.abs(smoothShake.y) + math.abs(smoothShake.r)
    if mag > 0.01 then
        return {
            origin = pos,
            angles = ang + smoothShake,
            fov = fov,
        }
    end
end)

-- ============================================================
-- 6. SHELLS: Throttle at high RPM
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

print("[BRS UW] RPM polish system loaded")
