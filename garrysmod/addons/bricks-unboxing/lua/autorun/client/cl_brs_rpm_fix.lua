-- ============================================================
-- BRS Unique Weapons - High RPM Smoothing (Client)
--
-- ROOT CAUSE FIX: The server changes wep.Primary.Delay and
-- wep.Primary.RPM, but these are Lua table values that do NOT
-- network to the client. GMod weapons are PREDICTED - 
-- PrimaryAttack() runs on both client and server. The client
-- still has the ORIGINAL delay, so it only predicts shots at
-- the original fire rate. Sound/animation only play when the
-- CLIENT thinks a shot happened.
--
-- FIX: Apply the same RPM/Delay changes on the client weapon
-- when we detect the networked RPM multiplier.
-- ============================================================

-- ============================================================
-- CORE FIX: Sync RPM/Delay to client weapon's Primary table
-- This is the #1 fix. Without this, nothing else matters.
-- ============================================================
hook.Add("Think", "BRS_UW_RPMClientSync", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    for _, wep in ipairs(ply:GetWeapons()) do
        if not IsValid(wep) then continue end

        local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
        if mult <= 1.0 then
            -- Clean up if weapon was un-boosted
            if wep.BRS_UW_ClientPatched then
                if wep.BRS_UW_ClientOrigDelay then
                    wep.Primary.Delay = wep.BRS_UW_ClientOrigDelay
                end
                if wep.BRS_UW_ClientOrigRPM then
                    wep.Primary.RPM = wep.BRS_UW_ClientOrigRPM
                end
                if wep.BRS_UW_ClientOrigRecoil then
                    wep.Primary.Recoil = wep.BRS_UW_ClientOrigRecoil
                end
                if wep.BRS_UW_ClientOrigKickUp then
                    wep.Primary.KickUp = wep.BRS_UW_ClientOrigKickUp
                end
                if wep.BRS_UW_ClientOrigKickDown then
                    wep.Primary.KickDown = wep.BRS_UW_ClientOrigKickDown
                end
                if wep.BRS_UW_ClientOrigKickH then
                    wep.Primary.KickHorizontal = wep.BRS_UW_ClientOrigKickH
                end
                wep.BRS_UW_ClientPatched = nil
            end
            continue
        end

        -- Already patched this weapon
        if wep.BRS_UW_ClientPatched then continue end
        if not wep.Primary then continue end

        -- Save originals
        wep.BRS_UW_ClientOrigDelay = wep.Primary.Delay
        wep.BRS_UW_ClientOrigRPM = wep.Primary.RPM

        -- Apply boosted RPM and Delay to CLIENT's Primary table
        if wep.Primary.RPM then
            wep.Primary.RPM = math.Round(wep.Primary.RPM * mult)
        end
        if wep.Primary.Delay then
            wep.Primary.Delay = wep.Primary.Delay / mult
        elseif wep.Primary.RPM and wep.Primary.RPM > 0 then
            wep.Primary.Delay = 60 / wep.Primary.RPM
        end

        -- Scale down recoil on client too (same sqrt curve as server)
        local recoilScale = 1 / math.sqrt(mult)
        if wep.Primary.Recoil then
            wep.BRS_UW_ClientOrigRecoil = wep.Primary.Recoil
            wep.Primary.Recoil = wep.Primary.Recoil * recoilScale
        end
        if wep.Primary.KickUp then
            wep.BRS_UW_ClientOrigKickUp = wep.Primary.KickUp
            wep.Primary.KickUp = wep.Primary.KickUp * recoilScale
        end
        if wep.Primary.KickDown then
            wep.BRS_UW_ClientOrigKickDown = wep.Primary.KickDown
            wep.Primary.KickDown = wep.Primary.KickDown * recoilScale
        end
        if wep.Primary.KickHorizontal then
            wep.BRS_UW_ClientOrigKickH = wep.Primary.KickHorizontal
            wep.Primary.KickHorizontal = wep.Primary.KickHorizontal * recoilScale
        end

        wep.BRS_UW_ClientPatched = true
        -- print("[BRS UW Client] Patched " .. wep:GetClass() .. " RPM mult=" .. mult .. " delay=" .. (wep.Primary.Delay or "nil"))
    end
end)

-- ============================================================
-- VIEWMODEL ANIMATION - FIRE SEQUENCES ONLY
-- Speed up fire animations so they complete before next shot
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
-- VIEWPUNCH REDUCTION
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
                local scale = 1 / math.sqrt(mult)
                return origViewPunch(self, Angle(
                    (ang.p or 0) * scale,
                    (ang.y or 0) * scale,
                    (ang.r or 0) * scale
                ))
            end
        end

        return origViewPunch(self, ang)
    end
end

-- ============================================================
-- SHELL EJECTION THROTTLE
-- ============================================================
local lastShellTime = 0

if util and util.Effect then
    local origEffect = util.Effect

    util.Effect = function(name, effectData, ...)
        if name and (
            string.find(name, "[Ss]hell") or
            string.find(name, "[Bb]rass") or
            string.find(name, "[Ee]ject")
        ) then
            local ply = LocalPlayer()
            if IsValid(ply) then
                local wep = ply:GetActiveWeapon()
                if IsValid(wep) then
                    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
                    if mult > 1.3 then
                        local now = CurTime()
                        local baseDelay = wep:GetNW2Float("BRS_UW_BaseDelay", 0.1)
                        if now - lastShellTime < baseDelay * 0.7 then
                            return
                        end
                        lastShellTime = now
                    end
                end
            end
        end

        return origEffect(name, effectData, ...)
    end
end

-- ============================================================
-- SOUND CHANNEL ROTATION
-- Even with correct client-side fire rate, Source can still
-- drop sounds if they play too fast on the same channel.
-- Rotate fire sounds across channels as safety net.
-- ============================================================
local channels = {CHAN_WEAPON, CHAN_WEAPON2, CHAN_BODY, CHAN_VOICE}
local chanState = {}

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

    -- Skip non-weapon sounds
    local snd = data.SoundName
    if not snd then return end
    local sndLower = string.lower(snd)
    if string.find(sndLower, "step") or
       string.find(sndLower, "foot") or
       string.find(sndLower, "phys") or
       string.find(sndLower, "button") or
       string.find(sndLower, "door") or
       string.find(sndLower, "ui/") or
       string.find(sndLower, "ambient") or
       string.find(sndLower, "player/") then
        return
    end

    local idx = ent:EntIndex()
    local state = chanState[idx]
    if not state then
        state = { idx = 0, lastTime = 0 }
        chanState[idx] = state
    end

    state.idx = state.idx + 1
    if state.idx > #channels then state.idx = 1 end
    state.lastTime = CurTime()

    data.Channel = channels[state.idx]
    return true
end)

-- Cleanup stale channel state
timer.Create("BRS_UW_ChanCleanup", 5, 0, function()
    local now = CurTime()
    for idx, state in pairs(chanState) do
        if now - state.lastTime > 3 then
            chanState[idx] = nil
        end
    end
end)

print("[BRS UW] RPM client fix loaded (Primary.Delay sync + anim + recoil + shells + sound)")
