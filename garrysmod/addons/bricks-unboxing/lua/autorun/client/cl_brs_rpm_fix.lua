-- ============================================================
-- BRS Unique Weapons - High RPM Smoothing (Client)
--
-- Fixes for boosted RPM weapons:
--   1. Viewmodel: speed up FIRE animations only (not idle/reload)
--   2. ViewPunch: scale down per-shot recoil (sqrt curve)
--   3. Shells: throttle ejection effects to base rate
--   4. Sound: rotate channels to prevent Source dropping sounds
-- ============================================================

-- ============================================================
-- 1. VIEWMODEL ANIMATION - FIRE SEQUENCES ONLY
-- Only speed up fire/shoot activities, leave idle/reload/draw
-- at normal speed. This prevents weird fast-idle jitter.
-- ============================================================
local fireActivities = {
    [ACT_VM_PRIMARYATTACK] = true,
    [ACT_VM_SECONDARYATTACK] = true,
    [ACT_SHOTGUN_PUMP] = true,
}
-- Some M9K weapons use raw sequence names, so also check by name
local fireSequenceNames = {
    ["fire"] = true, ["shoot"] = true, ["shoot1"] = true, ["shoot2"] = true,
    ["shoot3"] = true, ["fire1"] = true, ["fire2"] = true, ["fire3"] = true,
    ["primaryattack"] = true,
}

hook.Add("PostDrawViewModel", "BRS_UW_RPMAnimFix", function(vm, ply, wep)
    if not IsValid(wep) or not IsValid(vm) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.0 then return end

    -- Check if current activity is a fire animation
    local act = vm:GetActivity()
    local isFiring = fireActivities[act]

    if not isFiring then
        -- Also check sequence name as fallback
        local seq = vm:GetSequence()
        if seq and seq >= 0 then
            local seqName = vm:GetSequenceName(seq)
            if seqName then
                isFiring = fireSequenceNames[string.lower(seqName)]
            end
        end
    end

    if isFiring then
        vm:SetPlaybackRate(mult)
    else
        vm:SetPlaybackRate(1.0)
    end
end)

-- ============================================================
-- 2. VIEWPUNCH REDUCTION (per-shot recoil)
-- Scale each kick down using sqrt so total recoil/sec is:
--   1.5x RPM -> 82% per-shot (1.22x total/sec)
--   2.0x RPM -> 71% per-shot (1.41x total/sec)
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
-- 3. SHELL EJECTION THROTTLE
-- Cap shell spawns at base weapon rate to prevent entity flood
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
-- 4. CLIENT-SIDE SOUND CHANNEL ROTATION
-- Source engine only allows ONE sound per channel per entity.
-- M9K fires on CHAN_WEAPON. At high RPM, Source silently drops
-- repeat EmitSound calls on a busy channel.
-- Fix: hook EntityEmitSound to rotate fire sounds across channels.
-- ============================================================
local fireSoundChannels = {CHAN_WEAPON, CHAN_BODY, CHAN_VOICE, CHAN_VOICE2}
local clientChanIdx = 0
local trackedFireSounds = {} -- [entIndex] = fire sound name

hook.Add("EntityEmitSound", "BRS_UW_RPMSoundChannelFix", function(data)
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

    -- Detect if this is the weapon's fire sound
    local fireSound = wep.Primary and wep.Primary.Sound
    if not fireSound then return end

    -- Match by sound name (M9K fire sounds)
    if data.SoundName == fireSound then
        clientChanIdx = clientChanIdx + 1
        if clientChanIdx > #fireSoundChannels then clientChanIdx = 1 end
        data.Channel = fireSoundChannels[clientChanIdx]
        return true
    end
end)

print("[BRS UW] RPM smoothing loaded (anim + recoil + shells + sound channels)")
