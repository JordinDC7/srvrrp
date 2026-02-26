-- ============================================================
-- BRS Unique Weapons - Projectile System (Client)
-- Local trajectory prediction + tracer visuals
--
-- PERFORMANCE:
--   Ring buffer trails (no table.remove)
--   Single reusable Color object (zero alloc render)
--   Distance-based LOD (cull detail effects)
--   Shared particle emitter
--   Pool limits on projectiles + impacts
-- ============================================================

local projectiles = {}
local impacts = {}
local MAX_PROJ = 32
local MAX_IMPACTS = 16
local MAX_TRAIL = 28
local TRAIL_DT = 0.014  -- ~71 points/sec

local orderToRarity = {
    "Common", "Uncommon", "Rare", "Epic", "Legendary", "Glitched", "Mythical",
}

-- Materials (cached once)
local matGlow = Material("sprites/light_glow02_add")
local matBeam = Material("trails/laser")
local matSoft = Material("sprites/glow04_noz")
local matFlare = Material("effects/blueflare1")

-- Zero-alloc color: single reusable Color, set before each draw call
local _c = Color(255, 255, 255, 255)
local function C(r, g, b, a)
    _c.r = r  _c.g = g  _c.b = b  _c.a = a
    return _c
end

-- Fast math locals
local sin, cos, abs = math.sin, math.cos, math.abs
local Clamp, Rand, floor, random = math.Clamp, math.Rand, math.floor, math.random
local Vector = Vector

-- Distance LOD thresholds (squared)
local LOD_DETAIL = 2000 * 2000
local LOD_PARTICLE = 3000 * 3000
local LOD_VISIBLE = 8000 * 8000

-- Shared particle emitter (one for all tracers)
local _emitter, _emitterAge = nil, 0
local function GetEmitter(pos)
    local ct = CurTime()
    if not _emitter or ct - _emitterAge > 5 then
        if _emitter then _emitter:Finish() end
        _emitter = ParticleEmitter(pos, false)
        _emitterAge = ct
    end
    return _emitter
end

-- Color utils
local function ChromaticRGB(t)
    return sin(t * 6) * 127 + 128, sin(t * 6 + 2.094) * 127 + 128, sin(t * 6 + 4.189) * 127 + 128
end
local function GlitchIsBright(t)
    return (sin(t * 40) + sin(t * 67) + sin(t * 97)) <= 0.5
end

-- ============================================================
-- RING BUFFER: O(1) add, O(1) trim, no table.remove
-- ============================================================
local function RingNew()
    return { head = 0, tail = 0, buf = {} }
end

local function RingPush(ring, pos, time)
    ring.head = ring.head + 1
    ring.buf[ring.head] = { pos = pos, time = time }
    -- Enforce max size
    if ring.head - ring.tail > MAX_TRAIL then
        ring.tail = ring.head - MAX_TRAIL
    end
end

local function RingTrimBefore(ring, minTime)
    local buf = ring.buf
    while ring.tail < ring.head do
        local entry = buf[ring.tail + 1]
        if not entry or entry.time >= minTime then break end
        buf[ring.tail + 1] = nil  -- free memory
        ring.tail = ring.tail + 1
    end
end

local function RingCount(ring)
    return ring.head - ring.tail
end

local function RingGet(ring, i)
    return ring.buf[ring.tail + i]
end

-- ============================================================
-- RECEIVE: Projectile spawn
-- ============================================================
net.Receive("BRS_UW.ProjSpawn", function()
    local src = net.ReadVector()
    local vel = net.ReadVector()
    local gravity = net.ReadFloat()
    local rarityIdx = net.ReadUInt(4)
    local shooter = net.ReadEntity()
    local isAscended = net.ReadBool()

    local rarityKey = orderToRarity[rarityIdx] or "Common"
    local tier = BRS_UW.Tracers and BRS_UW.Tracers.GetTier(rarityKey)
    if not tier then return end

    -- Adjust start pos to viewmodel muzzle for local player
    if IsValid(shooter) and shooter == LocalPlayer() then
        local vm = shooter:GetViewModel()
        if IsValid(vm) then
            local att = vm:GetAttachment(vm:LookupAttachment("muzzle") or 1)
            if att then src = att.Pos end
        end
    end

    -- Pool limit (swap-remove: O(1) instead of table.remove O(n))
    if #projectiles >= MAX_PROJ then
        projectiles[1] = projectiles[#projectiles]
        projectiles[#projectiles] = nil
    end

    local dir = vel:GetNormalized()
    local ang = dir:Angle()

    projectiles[#projectiles + 1] = {
        pos = Vector(src.x, src.y, src.z),
        vel = Vector(vel.x, vel.y, vel.z),
        gravity = gravity,
        spawn = CurTime(),
        tier = tier,
        rarityKey = rarityKey,
        isAscended = isAscended,
        dir = dir,
        right = ang:Right(),
        up = ang:Up(),
        trail = RingNew(),
        lastTrail = 0,
        lastPart = 0,
        seed = random(1000),
        alive = true,
        hitTime = 0,
    }
end)

-- ============================================================
-- RECEIVE: Hit event (spawn impact effect)
-- ============================================================
net.Receive("BRS_UW.ProjHit", function()
    local hitPos = net.ReadVector()
    local hitNormal = net.ReadNormal()

    -- Match to closest live projectile
    local bestIdx, bestDSq = nil, math.huge
    for i, p in ipairs(projectiles) do
        if p.alive then
            local d = p.pos:DistToSqr(hitPos)
            if d < bestDSq then bestDSq = d; bestIdx = i end
        end
    end

    local tier, isAsc
    if bestIdx then
        local p = projectiles[bestIdx]
        tier = p.tier
        isAsc = p.isAscended
        p.alive = false
        p.hitTime = CurTime()
    else
        tier = BRS_UW.Tracers.GetTier("Common")
        isAsc = false
    end

    if tier.hasImpact then
        while #impacts >= MAX_IMPACTS do
            impacts[1] = impacts[#impacts]
            impacts[#impacts] = nil
        end
        impacts[#impacts + 1] = {
            pos = hitPos, normal = hitNormal,
            tier = tier, isAscended = isAsc,
            spawn = CurTime(),
            life = 0.4 + (tier.impactSize or 1) * 0.2,
            size = (tier.impactSize or 1) * 30,
        }
    end
end)

-- ============================================================
-- THINK: Advance projectiles + emit particles
-- ============================================================
hook.Add("Think", "BRS_UW_ProjThink", function()
    if #projectiles == 0 and #impacts == 0 then return end

    local ct = CurTime()
    local dt = FrameTime()
    local Step = BRS_UW.Projectiles and BRS_UW.Projectiles.Step
    if not Step then return end
    local eyePos = EyePos()

    for i = #projectiles, 1, -1 do
        local p = projectiles[i]
        local elapsed = ct - p.spawn

        -- Remove expired
        if p.alive and elapsed > 3 then
            projectiles[i] = projectiles[#projectiles]
            projectiles[#projectiles] = nil
            continue
        end
        if not p.alive and ct - p.hitTime > (p.tier.lifetime or 0.2) + 0.05 then
            projectiles[i] = projectiles[#projectiles]
            projectiles[#projectiles] = nil
            continue
        end

        -- Advance physics
        if p.alive then
            local newPos, newVel = Step(p.pos, p.vel, p.gravity, dt)
            p.pos = newPos
            p.vel = newVel

            -- Update direction (gravity curves it)
            p.dir = newVel:GetNormalized()
        end

        -- Trail points (ring buffer)
        if p.alive and ct - p.lastTrail > TRAIL_DT then
            RingPush(p.trail, Vector(p.pos.x, p.pos.y, p.pos.z), ct)
            p.lastTrail = ct
        end

        -- Trim expired trail points
        RingTrimBefore(p.trail, ct - (p.tier.lifetime or 0.2))

        -- Particles (distance culled)
        if p.alive and p.tier.hasParticles then
            local dSq = p.pos:DistToSqr(eyePos)
            if dSq < LOD_PARTICLE and ct - p.lastPart > 0.035 then
                p.lastPart = ct
                local em = GetEmitter(p.pos)
                if em then
                    local tier = p.tier
                    local behindPos = p.pos - p.dir * Rand(2, 6) + VectorRand() * 2
                    local pt = em:Add("sprites/light_glow02_add", behindPos)
                    if pt then
                        pt:SetStartAlpha(200) pt:SetEndAlpha(0)
                        local pType = tier.particleType or "sparks"
                        if pType == "glitch" then
                            pt:SetColor(random() > 0.5 and 255 or 0, random() > 0.5 and 255 or 0, random() > 0.5 and 220 or 200)
                            pt:SetDieTime(Rand(0.05, 0.12)) pt:SetStartSize(Rand(1, 2)) pt:SetEndSize(0)
                            pt:SetVelocity(VectorRand() * 70)
                        elseif pType == "void" then
                            pt:SetColor(40 + random(0, 160), 0, 0)
                            pt:SetDieTime(Rand(0.3, 0.5)) pt:SetStartSize(Rand(3, 5)) pt:SetEndSize(1)
                            pt:SetVelocity(-p.dir * 25 + VectorRand() * 12) pt:SetGravity(Vector(0, 0, 20))
                        elseif pType == "comet" then
                            pt:SetColor(255, 140 + random(0, 80), random(20, 60))
                            pt:SetDieTime(Rand(0.2, 0.4)) pt:SetStartSize(Rand(2, 4)) pt:SetEndSize(0)
                            pt:SetVelocity(-p.dir * 60 + VectorRand() * 25) pt:SetGravity(Vector(0, 0, -120))
                        elseif pType == "energy" then
                            pt:SetColor(200, 120, 255)
                            pt:SetDieTime(Rand(0.15, 0.3)) pt:SetStartSize(Rand(2, 3)) pt:SetEndSize(1)
                            pt:SetVelocity(VectorRand() * 20) pt:SetGravity(Vector(0, 0, 50))
                        else
                            local pc = tier.particleColor or tier.color
                            pt:SetColor(pc.r, pc.g, pc.b)
                            pt:SetDieTime(Rand(0.1, 0.25)) pt:SetStartSize(Rand(1, 2)) pt:SetEndSize(0)
                            pt:SetVelocity(VectorRand() * 40) pt:SetGravity(Vector(0, 0, -200))
                        end
                    end

                    -- Ascended golden sparks
                    if p.isAscended and random() < 0.3 then
                        local gp = em:Add("sprites/light_glow02_add", p.pos + VectorRand() * 3)
                        if gp then
                            gp:SetDieTime(Rand(0.15, 0.3)) gp:SetStartAlpha(200) gp:SetEndAlpha(0)
                            gp:SetColor(255, 220, 80) gp:SetStartSize(Rand(1, 2.5)) gp:SetEndSize(0)
                            gp:SetVelocity(VectorRand() * 30 + Vector(0, 0, 25)) gp:SetGravity(Vector(0, 0, -140))
                        end
                    end
                end
            end
        end
    end

    -- Clean impacts
    for i = #impacts, 1, -1 do
        if ct - impacts[i].spawn > impacts[i].life then
            impacts[i] = impacts[#impacts]
            impacts[#impacts] = nil
        end
    end
end)

-- ============================================================
-- RENDER: Draw tracer beams + impacts
-- All draw calls use single reusable Color via C()
-- ============================================================
hook.Add("PostDrawTranslucentRenderables", "BRS_UW_ProjRender", function(_, bSky)
    if bSky then return end
    if #projectiles == 0 and #impacts == 0 then return end

    local ct = CurTime()
    local eyePos = EyePos()
    local ascOvr = BRS_UW.Tracers and BRS_UW.Tracers.AscendedOverlay

    for _, proj in ipairs(projectiles) do
        local tier = proj.tier
        local curPos = proj.pos
        local dSq = curPos:DistToSqr(eyePos)

        -- Skip if too far
        if dSq > LOD_VISIBLE then continue end

        local isClose = dSq < LOD_DETAIL
        local elapsed = ct - proj.spawn
        local trailN = RingCount(proj.trail)

        -- Resolve color (avoid allocations)
        local br, bg, bb, ba, gr, gg, gb, ga
        if tier.chromatic then
            if GlitchIsCyan(elapsed + proj.seed) then
                br, bg, bb = tier.color.r, tier.color.g, tier.color.b
            else
                local c2 = tier.color2 or tier.color
                br, bg, bb = c2.r, c2.g, c2.b
            end
            ba = 255
            gr, gg, gb = ChromaticRGB(elapsed)
            ga = tier.glowColor.a
        elseif tier.color2 then
            local t = sin(elapsed * 2) * 0.5 + 0.5
            local c1, c2 = tier.color, tier.color2
            br = c1.r + (c2.r - c1.r) * t
            bg = c1.g + (c2.g - c1.g) * t
            bb = c1.b + (c2.b - c1.b) * t
            ba = 255
            gr, gg, gb, ga = tier.glowColor.r, tier.glowColor.g, tier.glowColor.b, tier.glowColor.a
        else
            br, bg, bb, ba = tier.color.r, tier.color.g, tier.color.b, tier.color.a
            gr, gg, gb, ga = tier.glowColor.r, tier.glowColor.g, tier.glowColor.b, tier.glowColor.a
        end

        -- =====================
        -- TRAIL BEAMS
        -- =====================
        if trailN > 1 then
            local fadeTime = tier.lifetime or 0.2

            -- Core + glow beams
            render.SetMaterial(matBeam)
            for j = 2, trailN do
                local p1 = RingGet(proj.trail, j - 1)
                local p2 = RingGet(proj.trail, j)
                if not p1 or not p2 then continue end
                local age = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                if age < 0.02 then continue end
                render.DrawBeam(p1.pos, p2.pos, tier.trailWidth, 0, 1, C(br, bg, bb, ba * age))
                render.DrawBeam(p1.pos, p2.pos, tier.glowWidth, 0, 1, C(gr, gg, gb, ga * age * 0.6))
            end

            -- Afterimage (Legendary/Mythical)
            if tier.hasAfterimage then
                local aic = tier.afterimageColor
                if aic then
                    for j = 2, trailN do
                        local p1 = RingGet(proj.trail, j - 1)
                        local p2 = RingGet(proj.trail, j)
                        if not p1 or not p2 then continue end
                        local age = 1 - Clamp((ct - p1.time) / (fadeTime * 2), 0, 1)
                        if age < 0.03 then continue end
                        render.DrawBeam(p1.pos, p2.pos, tier.glowWidth * 1.5, 0, 1, C(aic.r, aic.g, aic.b, aic.a * age))
                    end
                end
            end

            -- ASCENDED: Wide golden outer trail glow (the "pop" - visible at distance)
            if proj.isAscended then
                local pulse = 0.7 + sin(elapsed * 4) * 0.3
                for j = 2, trailN do
                    local p1 = RingGet(proj.trail, j - 1)
                    local p2 = RingGet(proj.trail, j)
                    if not p1 or not p2 then continue end
                    local age = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                    if age < 0.02 then continue end
                    render.DrawBeam(p1.pos, p2.pos, tier.glowWidth * 2.5, 0, 1, C(255, 215, 60, 45 * age * pulse))
                end
            end

            -- DETAIL EFFECTS (close only)
            if isClose then
                -- Void tendrils (Mythical)
                if tier.voidTrail then
                    local right, up = proj.right, proj.up
                    local c2 = tier.color2 or tier.color
                    for tendril = 0, 1 do
                        local phase = tendril * 3.14
                        for j = 2, trailN, 2 do
                            local p1 = RingGet(proj.trail, j - 1)
                            local p2 = RingGet(proj.trail, j)
                            if not p1 or not p2 then continue end
                            local age = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                            if age < 0.05 then continue end
                            local segT = j / trailN
                            local w1 = sin(elapsed * 4 + segT * 8 + phase) * (5 + segT * 3)
                            local w2 = cos(elapsed * 3 + segT * 6 + phase) * (3 + segT * 2)
                            render.DrawBeam(p1.pos + right * w1 + up * w2, p2.pos + right * w1 + up * w2, 1.5, 0, 1, C(c2.r, c2.g, c2.b, 130 * age))
                        end
                    end
                end

                -- Glitch trail offset segments
                if tier.glitchTrail then
                    local right, up = proj.right, proj.up
                    for j = 2, trailN, 2 do
                        local p1 = RingGet(proj.trail, j - 1)
                        local p2 = RingGet(proj.trail, j)
                        if not p1 or not p2 then continue end
                        local age = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                        local segHash = j + floor(elapsed * 30)
                        if segHash % 3 == 0 then
                            local off = sin(segHash * 137.5 + elapsed * 50) * 8
                            local isBright = GlitchIsBright(elapsed + j * 0.1)
                            local fc = isBright and tier.color or (tier.color2 or tier.color)
                            render.DrawBeam(p1.pos + right * off + up * off * 0.5, p2.pos + right * off + up * off * 0.5, tier.trailWidth * 0.8, 0, 1, C(fc.r, fc.g, fc.b, 200 * age))
                        end
                    end
                end

                -- Ascended lightning arcs
                if proj.isAscended and ascOvr and ascOvr.hasLightning then
                    local right, up = proj.right, proj.up
                    local lc = ascOvr.lightningColor
                    for arc = 1, 2 do
                        local seed = arc * 47.3 + proj.seed
                        for j = 2, trailN, 2 do
                            local p1 = RingGet(proj.trail, j - 1)
                            local p2 = RingGet(proj.trail, j)
                            if not p1 or not p2 then continue end
                            local age = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                            if age < 0.05 then continue end
                            local jag = sin((j + floor(elapsed * 60)) * seed) * ascOvr.lightningRange
                            local jag2 = cos((j + floor(elapsed * 60)) * seed * 0.7) * ascOvr.lightningRange * 0.6
                            render.DrawBeam(p1.pos + right * jag + up * jag2, p2.pos + right * jag + up * jag2, 1, 0, 1, C(lc.r, lc.g, lc.b, lc.a * age))
                        end
                    end
                end
            end
        end

        -- =====================
        -- PROJECTILE HEAD
        -- =====================
        if proj.alive then
            render.SetMaterial(matGlow)
            render.DrawSprite(curPos, tier.trailWidth * 3, tier.trailWidth * 3, C(br, bg, bb, 255))
            render.SetMaterial(matSoft)
            render.DrawSprite(curPos, tier.glowWidth * 2, tier.glowWidth * 2, C(gr, gg, gb, 100))

            -- Void dark core (Mythical)
            if tier.voidCore then
                render.SetMaterial(matGlow)
                render.DrawSprite(curPos, tier.trailWidth * 4.5, tier.trailWidth * 4.5, C(0, 0, 0, 200))
                render.SetMaterial(matSoft)
                local aura = tier.glowWidth * 2 * (2.5 + sin(elapsed * 3) * 0.5)
                render.DrawSprite(curPos, aura, aura, C(60, 0, 0, 40))
            end

            -- Spiral flares (Legendary)
            if tier.hasSpiral and isClose then
                render.SetMaterial(matFlare)
                local sR = tier.spiralRadius or 3
                for s = 0, 2 do
                    local a = elapsed * (tier.spiralSpeed or 6) * 6.283 + s * 2.094
                    local off = proj.right * cos(a) * sR + proj.up * sin(a) * sR
                    render.DrawSprite(curPos + off, tier.trailWidth * 1.5, tier.trailWidth * 1.5, C(br, bg, bb, 180))
                end
            end

            -- Ascended head effects: clean golden aura (no clutter)
            if proj.isAscended and isClose then
                -- Subtle golden breathing core - NOT a ball of sparkles
                local pulse = 0.6 + sin(elapsed * 3) * 0.25
                render.SetMaterial(matSoft)
                render.DrawSprite(curPos, tier.trailWidth * 5, tier.trailWidth * 5, C(255, 215, 60, 35 * pulse))
            end
        end
    end

    -- =====================
    -- IMPACT EFFECTS
    -- =====================
    for _, imp in ipairs(impacts) do
        local age = ct - imp.spawn
        local frac = age / imp.life
        local fade = 1 - frac
        local tier = imp.tier
        local ic = tier.impactColor or tier.color
        local ringSize = imp.size * (0.3 + frac * 2)

        render.SetMaterial(matSoft)
        if tier.chromatic then
            local cr, cg, cb = ChromaticRGB(age)
            render.DrawSprite(imp.pos + imp.normal, ringSize, ringSize, C(cr, cg, cb, fade * 200))
        elseif tier.voidTrail then
            render.SetMaterial(matGlow)
            render.DrawSprite(imp.pos + imp.normal * 0.5, ringSize, ringSize, C(0, 0, 0, fade * 180))
            render.DrawSprite(imp.pos + imp.normal * 0.5, ringSize * 1.3, ringSize * 1.3, C(200, 0, 0, fade * 120))
        else
            render.DrawSprite(imp.pos + imp.normal, ringSize, ringSize, C(ic.r, ic.g, ic.b, fade * 200))
        end

        -- Initial flash
        if frac < 0.3 then
            local ff = 1 - frac / 0.3
            render.SetMaterial(matGlow)
            render.DrawSprite(imp.pos + imp.normal * 2, imp.size * 1.5 * ff, imp.size * 1.5 * ff, C(255, 255, 255, 200 * ff))
        end

        -- Ascended pillar
        if imp.isAscended and ascOvr and ascOvr.impactPillar then
            local pf = fade * fade
            local pc = ascOvr.pillarColor
            render.SetMaterial(matBeam)
            render.DrawBeam(imp.pos, imp.pos + Vector(0, 0, ascOvr.pillarHeight * pf), 6 * pf, 0, 1, C(pc.r, pc.g, pc.b, pc.a * pf))
            render.DrawBeam(imp.pos, imp.pos + Vector(0, 0, ascOvr.pillarHeight * 0.9 * pf), 2 * pf, 0, 1, C(255, 255, 230, 180 * pf))
        end
    end
end)

print("[BRS UW] Projectile client loaded")
