-- ============================================================
-- BRS Unique Weapons - High RPM Smoothing (Client)
--
-- Fixes for boosted RPM weapons:
--   1. Viewmodel: speed up FIRE animations only
--   2. ViewPunch: scale down per-shot recoil
--   3. Shells: throttle ejection effects
--   4. Sound: rotate ALL weapon sounds across channels
-- ============================================================

-- ============================================================
-- 1. VIEWMODEL ANIMATION - FIRE SEQUENCES ONLY
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

    -- Use GetSequenceActivity (GetActivity doesn't exist on viewmodels)
    local seq = vm:GetSequence()
    if not seq or seq < 0 then return end

    local isFiring = false

    -- Check activity
    local act = vm:GetSequenceActivity(seq)
    if act and fireActivities[act] then
        isFiring = true
    end

    -- Also check sequence name as fallback
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
-- 2. VIEWPUNCH REDUCTION
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
-- 4. SOUND CHANNEL ROTATION (catch-all)
-- Source only allows ONE sound per channel per entity.
-- M9K weapons emit fire sounds in many different ways:
--   self:EmitSound(), self.Weapon:EmitSound(), sound.Play(), etc.
-- EntityEmitSound catches ALL of them regardless of how they
-- were triggered. We rotate channels on ANY sound coming from
-- a boosted weapon entity to ensure nothing gets dropped.
-- ============================================================
local channels = {CHAN_WEAPON, CHAN_WEAPON2, CHAN_BODY, CHAN_VOICE}
local chanState = {} -- [entIndex] = { idx = N, lastTime = T }

hook.Add("EntityEmitSound", "BRS_UW_RPMSoundFix", function(data)
    local ent = data.Entity
    if not IsValid(ent) then return end

    -- Find the weapon - sound can come from weapon entity or the player
    local wep
    if ent:IsWeapon() then
        wep = ent
    elseif ent:IsPlayer() then
        wep = ent:GetActiveWeapon()
    end
    if not IsValid(wep) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.0 then return end

    -- Skip clearly non-weapon sounds (footsteps, physics, UI)
    local snd = data.SoundName
    if not snd then return end
    local sndLower = string.lower(snd)

    -- Skip sounds that are definitely not weapon fire
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

    -- For everything else from this weapon entity, rotate channels
    local idx = ent:EntIndex()
    local state = chanState[idx]
    if not state then
        state = { idx = 0, lastTime = 0 }
        chanState[idx] = state
    end

    local now = CurTime()
    state.idx = state.idx + 1
    if state.idx > #channels then state.idx = 1 end
    state.lastTime = now

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

print("[BRS UW] RPM smoothing loaded (anim + recoil + shells + sound channels)")
