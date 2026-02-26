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
local MAX_TRAIL = 40
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

    -- Detect own bullets: entity check OR distance from eye (<80 units)
    -- net.ReadEntity can fail on unreliable messages, so distance is backup
    local lp = LocalPlayer()
    local isLocal = (IsValid(shooter) and shooter == lp)
        or (IsValid(lp) and src:DistToSqr(lp:EyePos()) < 6400)

    -- For own bullets, snap to client EyePos to prevent any server/client
    -- position mismatch that creates sideways flash streaks
    if isLocal and IsValid(lp) then
        src = lp:EyePos()
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
        isLocal = isLocal,
        dir = dir,
        right = ang:Right(),
        up = ang:Up(),
        trail = RingNew(),
        lastTrail = CurTime() + 0.03,  -- 30ms grace before first trail point
        lastPart = CurTime(),
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
        local iSize = (tier.impactSize or 1)
        impacts[#impacts + 1] = {
            pos = hitPos, normal = hitNormal,
            tier = tier, isAscended = isAsc,
            spawn = CurTime(),
            life = 0.35 + iSize * 0.25,
            size = iSize * 40,  -- bigger base (was 30)
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
            if dSq < LOD_PARTICLE and ct - p.lastPart > 0.04 then
                p.lastPart = ct
                local em = GetEmitter(p.pos)
                if em then
                    local tier = p.tier
                    local behindPos = p.pos - p.dir * Rand(2, 6) + VectorRand() * 1.5
                    local pt = em:Add("sprites/light_glow02_add", behindPos)
                    if pt then
                        pt:SetStartAlpha(180) pt:SetEndAlpha(0)
                        local pType = tier.particleType or "sparks"
                        if pType == "glitch" then
                            -- Cyber teal
                            local g = 200 + random(0, 55)
                            pt:SetColor(0, g, math.floor(g * 0.75 + random(0, 20)))
                            pt:SetDieTime(Rand(0.06, 0.15)) pt:SetStartSize(Rand(1.5, 2.5)) pt:SetEndSize(0)
                            pt:SetVelocity(VectorRand() * 50)
                        elseif pType == "divine" then
                            -- Heavenly: icy blue motes drifting upward
                            pt:SetColor(160 + random(0, 40), 210 + random(0, 25), 255)
                            pt:SetDieTime(Rand(0.3, 0.55)) pt:SetStartSize(Rand(3, 5)) pt:SetEndSize(0.5)
                            pt:SetVelocity(-p.dir * 15 + VectorRand() * 10 + Vector(0, 0, 35))
                            pt:SetGravity(Vector(0, 0, 45))
                        elseif pType == "comet" then
                            pt:SetColor(255, 140 + random(0, 80), random(20, 60))
                            pt:SetDieTime(Rand(0.2, 0.4)) pt:SetStartSize(Rand(2, 4)) pt:SetEndSize(0)
                            pt:SetVelocity(-p.dir * 50 + VectorRand() * 20) pt:SetGravity(Vector(0, 0, -120))
                        elseif pType == "energy" then
                            pt:SetColor(200, 120, 255)
                            pt:SetDieTime(Rand(0.12, 0.25)) pt:SetStartSize(Rand(1.5, 2.5)) pt:SetEndSize(0.5)
                            pt:SetVelocity(VectorRand() * 18) pt:SetGravity(Vector(0, 0, 50))
                        else
                            local pc = tier.particleColor or tier.color
                            pt:SetColor(pc.r, pc.g, pc.b)
                            pt:SetDieTime(Rand(0.1, 0.22)) pt:SetStartSize(Rand(1, 2)) pt:SetEndSize(0)
                            pt:SetVelocity(VectorRand() * 35) pt:SetGravity(Vector(0, 0, -200))
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
            if GlitchIsBright(elapsed + proj.seed) then
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

            -- Core beam only
            render.SetMaterial(matBeam)
            for j = 2, trailN do
                local p1 = RingGet(proj.trail, j - 1)
                local p2 = RingGet(proj.trail, j)
                if not p1 or not p2 then continue end
                -- Skip overly long segments (streak prevention, 180 units max)
                if p1.pos:DistToSqr(p2.pos) > 32400 then continue end
                local age = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                if age < 0.02 then continue end
                -- Core trail
                render.DrawBeam(p1.pos, p2.pos, tier.trailWidth, 0, 1, C(br, bg, bb, ba * age))
                -- Outer glow
                render.DrawBeam(p1.pos, p2.pos, tier.glowWidth, 0, 1, C(gr, gg, gb, ga * age * 0.45))
            end

            -- DETAIL EFFECTS (close only, one effect per tier max)
            if isClose then
                -- Glitched: offset data fragments
                if tier.glitchTrail then
                    local right = proj.right
                    for j = 2, trailN, 2 do
                        local p1 = RingGet(proj.trail, j - 1)
                        local p2 = RingGet(proj.trail, j)
                        if not p1 or not p2 then continue end
                        local age = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                        if age < 0.1 then continue end
                        local segHash = j + floor(elapsed * 15)
                        if segHash % 3 == 0 then
                            local off = sin(segHash * 97.3) * 6
                            render.DrawBeam(p1.pos + right * off, p2.pos + right * off, 1.5, 0, 1, C(0, 240, 190, 150 * age))
                        end
                    end
                end
            end
        end

        -- =====================
        -- PROJECTILE HEAD
        -- =====================
        if proj.alive then
            -- Skip rendering own bullets for first 40ms (inside player's face)
            if not proj.isLocal or elapsed > 0.04 then
                -- Head glow
                render.SetMaterial(matGlow)
                render.DrawSprite(curPos, tier.trailWidth * 2.5, tier.trailWidth * 2.5, C(br, bg, bb, 210))

                -- Divine aura (Mythical) - ethereal icy halo
                if tier.divineTrail then
                    render.SetMaterial(matSoft)
                    local pulse = 0.7 + sin(elapsed * 2.5) * 0.2
                    render.DrawSprite(curPos, tier.trailWidth * 5, tier.trailWidth * 5, C(160, 210, 255, 60 * pulse))
                end

                -- Spiral flares (Legendary only, close)
                if tier.hasSpiral and isClose then
                    render.SetMaterial(matFlare)
                    local sR = tier.spiralRadius or 3
                    for s = 0, 1 do
                        local a = elapsed * (tier.spiralSpeed or 5) * 6.283 + s * 3.14
                        local off = proj.right * cos(a) * sR + proj.up * sin(a) * sR
                        render.DrawSprite(curPos + off, tier.trailWidth * 1.2, tier.trailWidth * 1.2, C(br, bg, bb, 140))
                    end
                end
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
        local ringSize = imp.size * (0.4 + frac * 1.5)

        -- Main impact ring
        render.SetMaterial(matSoft)
        if tier.divineTrail then
            -- Heavenly: icy blue expanding burst
            render.DrawSprite(imp.pos + imp.normal, ringSize * 1.3, ringSize * 1.3, C(160, 210, 255, fade * 200))
            -- Inner bright core
            render.DrawSprite(imp.pos + imp.normal, ringSize * 0.5, ringSize * 0.5, C(210, 235, 255, fade * 240))
        else
            render.DrawSprite(imp.pos + imp.normal, ringSize, ringSize, C(ic.r, ic.g, ic.b, fade * 180))
        end

        -- Bright initial flash (all tiers)
        if frac < 0.2 then
            local ff = 1 - frac / 0.2
            render.SetMaterial(matGlow)
            local flashSize = imp.size * 0.8 * ff
            render.DrawSprite(imp.pos + imp.normal, flashSize, flashSize, C(255, 255, 255, 160 * ff))
        end

    end
end)

print("[BRS UW] Projectile client loaded")
