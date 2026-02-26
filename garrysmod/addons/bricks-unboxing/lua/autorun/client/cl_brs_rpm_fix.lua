-- ============================================================
-- BRS Unique Weapons - RPM Polish System (OPTIMIZED)
-- Key optimization: NW2 values cached per weapon, not read per frame
-- ============================================================

-- ============================================================
-- CACHED MULTIPLIER: Read NW2 once on equip, cache on weapon
-- ============================================================
local _cachedWep = nil
local _cachedMult = 0
local _cachedOrigRPM = 0
local _cachedOrigDelay = 0
local _lastCacheCheck = 0

local function GetCachedMult(wep)
    if not IsValid(wep) then
        _cachedMult = 0
        return 0
    end

    -- Recheck NW2 every 0.2s or on weapon change (not every frame)
    local ct = CurTime()
    if wep ~= _cachedWep or ct - _lastCacheCheck > 0.2 then
        _cachedWep = wep
        _lastCacheCheck = ct
        _cachedMult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
        _cachedOrigRPM = wep:GetNW2Float("BRS_UW_OrigRPM", 0)
        _cachedOrigDelay = wep:GetNW2Float("BRS_UW_OrigDelay", 0.1)
    end

    return _cachedMult
end

-- ============================================================
-- 1. CORE: Continuous Primary.Delay/RPM sync (cached NW2)
-- ============================================================
hook.Add("Think", "BRS_UW_ClientSync", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.Primary then return end

    local mult = GetCachedMult(wep)

    if mult <= 1.0 then
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

    if _cachedOrigRPM <= 0 then return end

    -- Save originals once
    if not wep.BRS_UW_CL_Orig then
        wep.BRS_UW_CL_Orig = {
            Delay = 60 / _cachedOrigRPM,
            RPM = _cachedOrigRPM,
            Recoil = wep.Primary.Recoil,
            KickUp = wep.Primary.KickUp,
            KickDown = wep.Primary.KickDown,
            KickHorizontal = wep.Primary.KickHorizontal,
        }
    end

    -- Enforce boosted values
    local targetRPM = math.Round(_cachedOrigRPM * mult)
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
-- 2. SOUND: Natural pitch variation (cached mult check)
-- ============================================================
hook.Add("EntityEmitSound", "BRS_UW_RPMSoundFix", function(data)
    -- Fast reject: if no cached boosted weapon, skip entirely
    if _cachedMult <= 1.0 then return end

    local ent = data.Entity
    if not IsValid(ent) then return end

    local wep
    if ent:IsWeapon() then
        wep = ent
    elseif ent:IsPlayer() then
        wep = ent:GetActiveWeapon()
    end
    if not IsValid(wep) or wep ~= _cachedWep then return end

    -- Only touch fire sound
    local fireSound = wep.Primary and wep.Primary.Sound
    if not fireSound or data.SoundName ~= fireSound then return end

    data.Pitch = math.Clamp((data.Pitch or 100) + math.Rand(-4, 4), 85, 115)
    data.Volume = math.Clamp((data.Volume or 1) + math.Rand(-0.05, 0.05), 0.85, 1.0)
    return true
end)

-- ============================================================
-- 3. RECOIL: Smooth dampening (cached mult)
-- ============================================================
local playerMeta = FindMetaTable("Player")
if playerMeta and playerMeta.ViewPunch then
    local origViewPunch = playerMeta.ViewPunch

    playerMeta.ViewPunch = function(self, ang)
        if not ang or _cachedMult <= 1.0 then
            return origViewPunch(self, ang)
        end

        local s = 1 / math.sqrt(_cachedMult)
        local horizJitter = math.Rand(-0.15, 0.15) * math.abs(ang.p)

        return origViewPunch(self, Angle(
            ang.p * s,
            ang.y * s + horizJitter,
            ang.r * s * 0.5
        ))
    end
end

-- ============================================================
-- 4. ANIMATION: Fire anim speed scaling (cached mult)
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
    if not IsValid(vm) or _cachedMult <= 1.0 then return end
    if wep ~= _cachedWep then return end

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

    vm:SetPlaybackRate(isFiring and _cachedMult or 1.0)
end)

-- ============================================================
-- 5. CAMERA: Subtle sustained fire sway (cached mult)
-- ============================================================
local sustainedFireTime = 0
local lastShotTime = 0
local smoothP, smoothY, smoothR = 0, 0, 0  -- avoid Angle allocation

hook.Add("CalcView", "BRS_UW_CameraSmooth", function(ply, pos, ang, fov)
    if _cachedMult <= 1.0 then
        smoothP, smoothY, smoothR = 0, 0, 0
        return
    end
    if not IsValid(ply) then return end

    local now = CurTime()
    local dt = FrameTime()
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then
        smoothP, smoothY, smoothR = 0, 0, 0
        return
    end

    local shooting = ply:KeyDown(IN_ATTACK) and wep:Clip1() > 0

    if shooting then
        if now - lastShotTime > 0.3 then
            sustainedFireTime = 0
        end
        sustainedFireTime = sustainedFireTime + dt
        lastShotTime = now

        local intensity = math.Clamp(sustainedFireTime / 0.5, 0, 1) * (_cachedMult - 1) * 0.3
        local t = now * 8

        local tp = math.sin(t * 1.1) * intensity * 0.15
        local ty = math.cos(t * 0.9) * intensity * 0.12
        local tr = math.sin(t * 1.3) * intensity * 0.05

        local lerp = dt * 12
        smoothP = smoothP + (tp - smoothP) * lerp
        smoothY = smoothY + (ty - smoothY) * lerp
        smoothR = smoothR + (tr - smoothR) * lerp
    else
        local lerp = dt * 8
        smoothP = smoothP * (1 - lerp)
        smoothY = smoothY * (1 - lerp)
        smoothR = smoothR * (1 - lerp)

        if math.abs(smoothP) + math.abs(smoothY) + math.abs(smoothR) < 0.005 then
            smoothP, smoothY, smoothR = 0, 0, 0
            return
        end
    end

    if math.abs(smoothP) + math.abs(smoothY) + math.abs(smoothR) > 0.005 then
        return {
            origin = pos,
            angles = ang + Angle(smoothP, smoothY, smoothR),
            fov = fov,
        }
    end
end)

-- ============================================================
-- 6. SHELLS: Throttle at high RPM (no NW2 reads, no regex)
-- ============================================================
local lastShellTime = 0
local shellNames = {}  -- cache checked names

if util and util.Effect then
    local origEffect = util.Effect
    util.Effect = function(name, effectData, ...)
        if _cachedMult > 1.3 and name then
            -- Cache whether this effect name is a shell type
            local isShell = shellNames[name]
            if isShell == nil then
                local lower = string.lower(name)
                isShell = string.find(lower, "shell", 1, true) ~= nil
                    or string.find(lower, "brass", 1, true) ~= nil
                    or string.find(lower, "eject", 1, true) ~= nil
                shellNames[name] = isShell
            end

            if isShell then
                local now = CurTime()
                if now - lastShellTime < _cachedOrigDelay * 0.7 then return end
                lastShellTime = now
            end
        end
        return origEffect(name, effectData, ...)
    end
end

print("[BRS UW] RPM polish system (optimized) loaded")
