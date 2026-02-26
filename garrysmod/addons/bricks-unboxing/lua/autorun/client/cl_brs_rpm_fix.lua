-- ============================================================
-- BRS Unique Weapons - High RPM Smoothing (Client)
--
-- Makes boosted RPM weapons feel smooth:
--   1. Viewmodel animation speed scaled to match RPM
--   2. ViewPunch per-shot recoil scaled down (sqrt curve)
--   3. Shell ejection throttled to base weapon rate
--
-- Does NOT block any sounds or bullets. Ever.
-- ============================================================

-- ============================================================
-- 1. VIEWMODEL ANIMATION SPEED
-- Scale playback rate so fire animation completes naturally
-- before the next shot restarts it. This is the #1 fix for
-- jittery viewmodels at high RPM.
-- ============================================================
hook.Add("PostDrawViewModel", "BRS_UW_RPMAnimFix", function(vm, ply, wep)
    if not IsValid(wep) or not IsValid(vm) then return end

    local mult = wep:GetNW2Float("BRS_UW_RPMMultiplier", 0)
    if mult <= 1.0 then return end

    vm:SetPlaybackRate(mult)
end)

-- ============================================================
-- 2. VIEWPUNCH REDUCTION (per-shot recoil)
-- M9K calls ply:ViewPunch() each shot for screen kick.
-- At 2x RPM = 2x kicks per second = screen shakes violently.
-- We scale each kick down using sqrt so:
--   1.5x RPM -> 82% per-shot kick (1.22x total recoil/sec)
--   2.0x RPM -> 71% per-shot kick (1.41x total recoil/sec)
--   2.5x RPM -> 63% per-shot kick (1.58x total recoil/sec)
-- Feels faster but stays controllable.
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
-- M9K spawns shell/brass effects per shot. At high RPM this
-- creates hundreds of entities causing lag. We throttle shell
-- spawning to roughly the base weapon fire rate.
-- ============================================================
local lastShellTime = 0

if util and util.Effect then
    local origEffect = util.Effect

    util.Effect = function(name, effectData, ...)
        -- Only intercept shell/brass effects
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
                        -- Spawn shells at base rate, not boosted rate
                        if now - lastShellTime < baseDelay * 0.7 then
                            return -- skip this shell, too soon
                        end
                        lastShellTime = now
                    end
                end
            end
        end

        return origEffect(name, effectData, ...)
    end
end

print("[BRS UW] RPM smoothing loaded (anim speed + recoil scale + shell throttle)")
