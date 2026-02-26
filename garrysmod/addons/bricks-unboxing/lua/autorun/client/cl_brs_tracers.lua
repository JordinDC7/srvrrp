-- ============================================================
-- BRS Unique Weapons - Tracer System (Client) - OPTIMIZED
-- Key optimizations:
--   - Trail points capped at 30, interval 0.015s (was 0.005s)
--   - Direction vectors cached per tracer (not recomputed per frame)
--   - Color objects pre-allocated and reused
--   - Distance culling: no particles/detail past 2000 units
--   - Pool limits: 24 tracers, 16 impacts
--   - Single shared particle emitter
--   - Trail trim from front (no mid-table remove)
-- ============================================================

local tracers = {}
local impacts = {}
local MAX_TRACERS = 24
local MAX_IMPACTS = 16
local MAX_TRAIL_POINTS = 30
local TRAIL_INTERVAL = 0.015
local DETAIL_DIST_SQ = 2000 * 2000  -- no detail effects beyond 2000u
local PARTICLE_DIST_SQ = 3000 * 3000

local orderToRarity = {
    [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic",
    [5] = "Legendary", [6] = "Glitched", [7] = "Mythical",
}

-- ============================================================
-- MATERIALS (cached once)
-- ============================================================
local matGlow = Material("sprites/light_glow02_add")
local matBeam = Material("trails/laser")
local matSoftGlow = Material("sprites/glow04_noz")
local matFlare = Material("effects/blueflare1")
local matRing = Material("effects/select_ring")

-- ============================================================
-- PRE-ALLOCATED COLOR OBJECTS (reused to avoid GC)
-- ============================================================
local _col = Color(255, 255, 255, 255)
local function SetCol(r, g, b, a)
    _col.r = r  _col.g = g  _col.b = b  _col.a = a
    return _col
end

-- Second color for simultaneous use
local _col2 = Color(255, 255, 255, 255)
local function SetCol2(r, g, b, a)
    _col2.r = r  _col2.g = g  _col2.b = b  _col2.a = a
    return _col2
end

-- ============================================================
-- UTILITY
-- ============================================================
local sin, cos, Clamp, Rand = math.sin, math.cos, math.Clamp, math.Rand
local floor, random, abs = math.floor, math.random, math.abs

local function ChromaticRGB(t)
    return sin(t * 6) * 127 + 128, sin(t * 6 + 2.094) * 127 + 128, sin(t * 6 + 4.189) * 127 + 128
end

local function GlitchIsCyan(t)
    return (sin(t * 40) + sin(t * 67) + sin(t * 97)) <= 0.5
end

-- ============================================================
-- SHARED PARTICLE EMITTER (reused, not created per particle)
-- ============================================================
local sharedEmitter = nil
local emitterRefreshTime = 0

local function GetEmitter(pos)
    local ct = CurTime()
    if not sharedEmitter or ct - emitterRefreshTime > 5 then
        if sharedEmitter then sharedEmitter:Finish() end
        sharedEmitter = ParticleEmitter(pos, false)
        emitterRefreshTime = ct
    end
    return sharedEmitter
end

-- ============================================================
-- RECEIVE TRACER FROM SERVER
-- ============================================================
net.Receive("BRS_UW.Tracer", function()
    local startPos = net.ReadVector()
    local endPos = net.ReadVector()
    local hitNormal = net.ReadNormal()
    local rarityOrder = net.ReadUInt(4)
    local shooter = net.ReadEntity()
    local didHit = net.ReadBool()
    local isAscended = net.ReadBool()

    local rarityKey = orderToRarity[rarityOrder] or "Common"
    local tier = BRS_UW.Tracers and BRS_UW.Tracers.GetTier(rarityKey)
    if not tier then return end

    -- Muzzle offset for local player
    if IsValid(shooter) and shooter == LocalPlayer() then
        local vm = shooter:GetViewModel()
        if IsValid(vm) then
            local att = vm:GetAttachment(vm:LookupAttachment("muzzle") or 1)
            if att then startPos = att.Pos or startPos end
        end
    end

    local dist = startPos:Distance(endPos)
    local dir = (endPos - startPos):GetNormalized()
    local ang = dir:Angle()

    -- Trim pool
    while #tracers >= MAX_TRACERS do table.remove(tracers, 1) end

    table.insert(tracers, {
        startPos = startPos,
        endPos = endPos,
        dir = dir,
        -- CACHED direction vectors (expensive to compute)
        right = ang:Right(),
        up = ang:Up(),
        dist = dist,
        hitNormal = hitNormal,
        didHit = didHit,
        tier = tier,
        rarityKey = rarityKey,
        isAscended = isAscended,
        spawnTime = CurTime(),
        travelTime = math.max(dist / tier.speed, 0.02),
        -- Trail: simple array, trimmed from front
        trail = {},
        trailHead = 0,
        lastTrailTime = 0,
        lastParticleTime = 0,
        impactSpawned = false,
        glitchSeed = random(1000),
    })
end)

-- ============================================================
-- SPAWN IMPACT
-- ============================================================
local function SpawnImpact(pos, normal, tier, rarityKey, isAscended)
    while #impacts >= MAX_IMPACTS do table.remove(impacts, 1) end

    table.insert(impacts, {
        pos = pos,
        normal = normal,
        tier = tier,
        rarityKey = rarityKey,
        isAscended = isAscended,
        spawnTime = CurTime(),
        lifetime = 0.4 + (tier.impactSize or 1.0) * 0.2,
        size = (tier.impactSize or 1.0) * 30,
    })
end

-- ============================================================
-- THINK: Update tracers + emit particles
-- ============================================================
hook.Add("Think", "BRS_UW_TracerThink", function()
    local ct = CurTime()
    local eyePos = EyePos()

    -- Update tracers
    for i = #tracers, 1, -1 do
        local tr = tracers[i]
        local elapsed = ct - tr.spawnTime
        local progress = Clamp(elapsed / tr.travelTime, 0, 1)

        tr.currentPos = LerpVector(progress, tr.startPos, tr.endPos)

        -- Add trail breadcrumb (throttled)
        if ct - tr.lastTrailTime > TRAIL_INTERVAL then
            local trail = tr.trail
            trail[#trail + 1] = { pos = tr.currentPos, time = ct }
            tr.lastTrailTime = ct

            -- Trim from front if over cap
            while #trail > MAX_TRAIL_POINTS do
                table.remove(trail, 1)
            end
        end

        -- Trim expired trail points from front
        local fadeTime = tr.tier.lifetime or 0.2
        local trail = tr.trail
        while #trail > 0 and ct - trail[1].time > fadeTime do
            table.remove(trail, 1)
        end

        -- Reached destination
        if progress >= 1 then
            if not tr.impactSpawned and tr.didHit and tr.tier.hasImpact then
                SpawnImpact(tr.endPos, tr.hitNormal, tr.tier, tr.rarityKey, tr.isAscended)
                tr.impactSpawned = true
            end
            if #trail == 0 then
                table.remove(tracers, i)
                continue
            end
        end

        -- ========================================
        -- PARTICLES (emitted from Think, safe context)
        -- Distance culled
        -- ========================================
        if tr.tier.hasParticles and progress < 1 then
            local distSq = tr.currentPos:DistToSqr(eyePos)
            if distSq < PARTICLE_DIST_SQ and ct - tr.lastParticleTime > 0.03 then
                tr.lastParticleTime = ct
                if random() < 0.5 then
                    local tier2 = tr.tier
                    local curPos = tr.currentPos
                    local pType = tier2.particleType or "sparks"
                    local behindPos = curPos - tr.dir * random(2, 8) + VectorRand() * 2

                    local emitter = GetEmitter(behindPos)
                    if emitter then
                        local p = emitter:Add("sprites/light_glow02_add", behindPos)
                        if p then
                            -- Color based on type
                            if pType == "glitch" then
                                if random() > 0.5 then
                                    p:SetColor(255, 0, 200)
                                else
                                    p:SetColor(0, 255, 220)
                                end
                            elseif pType == "void" then
                                p:SetColor(40 + random(0, 160), 0, 0)
                            elseif pType == "comet" then
                                p:SetColor(255, 140 + random(0, 80), random(20, 60))
                            elseif tier2.chromatic then
                                local r, g, b = ChromaticRGB(elapsed + random() * 2)
                                p:SetColor(r, g, b)
                            else
                                local pc = tier2.particleColor or tier2.color
                                p:SetColor(pc.r, pc.g, pc.b)
                            end

                            p:SetStartAlpha(220)
                            p:SetEndAlpha(0)

                            if pType == "sparks" then
                                p:SetDieTime(Rand(0.1, 0.25))
                                p:SetStartSize(Rand(1, 2))
                                p:SetEndSize(0)
                                p:SetVelocity(VectorRand() * 40)
                                p:SetGravity(Vector(0, 0, -200))
                            elseif pType == "energy" then
                                p:SetDieTime(Rand(0.15, 0.3))
                                p:SetStartSize(Rand(2, 3))
                                p:SetEndSize(1)
                                p:SetVelocity(VectorRand() * 20)
                                p:SetGravity(Vector(0, 0, 50))
                            elseif pType == "comet" then
                                p:SetDieTime(Rand(0.2, 0.4))
                                p:SetStartSize(Rand(2, 4))
                                p:SetEndSize(0)
                                p:SetVelocity(-tr.dir * 60 + VectorRand() * 25)
                                p:SetGravity(Vector(0, 0, -120))
                            elseif pType == "glitch" then
                                p:SetDieTime(Rand(0.05, 0.12))
                                p:SetStartSize(Rand(1, 2))
                                p:SetEndSize(0)
                                p:SetVelocity(VectorRand() * 70)
                            elseif pType == "void" then
                                p:SetDieTime(Rand(0.3, 0.5))
                                p:SetStartSize(Rand(3, 5))
                                p:SetEndSize(1)
                                p:SetVelocity(-tr.dir * 25 + VectorRand() * 12)
                                p:SetGravity(Vector(0, 0, 20))
                            end
                        end

                        -- Ascended golden shower
                        if tr.isAscended and random() < 0.4 then
                            local gp = emitter:Add("sprites/light_glow02_add", curPos + VectorRand() * 3)
                            if gp then
                                gp:SetDieTime(Rand(0.15, 0.35))
                                gp:SetStartAlpha(200)
                                gp:SetEndAlpha(0)
                                gp:SetColor(255, 220, 80)
                                gp:SetStartSize(Rand(1, 2.5))
                                gp:SetEndSize(0)
                                gp:SetVelocity(VectorRand() * 30 + Vector(0, 0, 25))
                                gp:SetGravity(Vector(0, 0, -140))
                            end
                        end
                    end
                end
            end
        end
    end

    -- Update impacts
    for i = #impacts, 1, -1 do
        if ct - impacts[i].spawnTime > impacts[i].lifetime then
            table.remove(impacts, i)
        end
    end
end)

-- ============================================================
-- RENDER: Draw all effects (optimized)
-- ============================================================
hook.Add("PostDrawTranslucentRenderables", "BRS_UW_TracerRender", function(bDrawingDepth, bDrawingSkybox)
    if bDrawingSkybox then return end
    if #tracers == 0 and #impacts == 0 then return end

    local ct = CurTime()
    local eyePos = EyePos()
    local ascOverlay = BRS_UW.Tracers and BRS_UW.Tracers.AscendedOverlay

    for _, tr in ipairs(tracers) do
        local tier = tr.tier
        local trail = tr.trail
        local elapsed = ct - tr.spawnTime
        local progress = Clamp(elapsed / tr.travelTime, 0, 1)
        local curPos = tr.currentPos or tr.startPos
        local distSq = curPos:DistToSqr(eyePos)
        local isClose = distSq < DETAIL_DIST_SQ

        -- ========================================
        -- RESOLVE BASE COLOR (no Color() alloc)
        -- ========================================
        local br, bg, bb, ba  -- base color RGBA
        local gr, gg, gb, ga  -- glow color RGBA

        if tier.chromatic then
            if GlitchIsCyan(elapsed + tr.glitchSeed) then
                br, bg, bb, ba = tier.color.r, tier.color.g, tier.color.b, 255
            else
                local c2 = tier.color2 or tier.color
                br, bg, bb, ba = c2.r, c2.g, c2.b, 255
            end
            local cr, cg, cb = ChromaticRGB(elapsed)
            gr, gg, gb, ga = cr, cg, cb, tier.glowColor.a
        elseif tier.color2 then
            local pulse = sin(elapsed * 2) * 0.5 + 0.5
            local c1, c2 = tier.color, tier.color2
            br = c1.r + (c2.r - c1.r) * pulse
            bg = c1.g + (c2.g - c1.g) * pulse
            bb = c1.b + (c2.b - c1.b) * pulse
            ba = 255
            gr, gg, gb, ga = tier.glowColor.r, tier.glowColor.g, tier.glowColor.b, tier.glowColor.a
        else
            br, bg, bb, ba = tier.color.r, tier.color.g, tier.color.b, tier.color.a
            gr, gg, gb, ga = tier.glowColor.r, tier.glowColor.g, tier.glowColor.b, tier.glowColor.a
        end

        -- ========================================
        -- GLOW TRAIL (all tiers - core + glow beam)
        -- ========================================
        if #trail > 1 then
            local fadeTime = tier.lifetime or 0.2

            render.SetMaterial(matBeam)
            for j = 2, #trail do
                local p1 = trail[j - 1]
                local p2 = trail[j]
                local age1 = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                if age1 < 0.01 then continue end

                -- Core beam (reuse color)
                render.DrawBeam(p1.pos, p2.pos, tier.trailWidth, 0, 1,
                    SetCol(br, bg, bb, ba * age1))
                -- Outer glow
                render.DrawBeam(p1.pos, p2.pos, tier.glowWidth, 0, 1,
                    SetCol(gr, gg, gb, ga * age1 * 0.6))
            end

            -- ========================================
            -- AFTERIMAGE (Legendary + Mythical) - uses cached color
            -- ========================================
            if tier.hasAfterimage then
                local aic = tier.afterimageColor
                if aic then
                    for j = 2, #trail do
                        local p1 = trail[j - 1]
                        local age1 = 1 - Clamp((ct - p1.time) / (fadeTime * 2), 0, 1)
                        if age1 < 0.02 then continue end
                        render.DrawBeam(trail[j - 1].pos, trail[j].pos, tier.glowWidth * 1.5, 0, 1,
                            SetCol(aic.r, aic.g, aic.b, aic.a * age1))
                    end
                end
            end

            -- ========================================
            -- DETAIL EFFECTS (only when close)
            -- ========================================
            if isClose then
                -- GLITCH TRAIL: offset flickering segments
                if tier.glitchTrail then
                    local right, up = tr.right, tr.up
                    for j = 2, #trail, 2 do  -- skip every other for perf
                        local p1, p2 = trail[j - 1], trail[j]
                        local age1 = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                        local segHash = j + floor(elapsed * 30)
                        if segHash % 3 == 0 then
                            local offsetAmt = sin(segHash * 137.5 + elapsed * 50) * 8
                            local offset = right * offsetAmt + up * (offsetAmt * 0.5)
                            local isCyan = GlitchIsCyan(elapsed + j * 0.1)
                            local fc = isCyan and tier.color or (tier.color2 or tier.color)
                            render.DrawBeam(p1.pos + offset, p2.pos + offset, tier.trailWidth * 0.8, 0, 1,
                                SetCol(fc.r, fc.g, fc.b, 200 * age1))
                        end
                    end
                end

                -- VOID TRAIL: 2 tendrils (was 3)
                if tier.voidTrail then
                    local right, up = tr.right, tr.up
                    local c2 = tier.color2 or tier.color
                    for tendril = 0, 1 do
                        local phase = tendril * 3.14
                        for j = 2, #trail, 2 do  -- skip every other
                            local p1, p2 = trail[j - 1], trail[j]
                            local age1 = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                            if age1 < 0.05 then continue end
                            local segT = j / #trail
                            local wave1 = sin(elapsed * 4 + segT * 8 + phase) * (5 + segT * 3)
                            local wave2 = cos(elapsed * 3 + segT * 6 + phase) * (3 + segT * 2)
                            local offset = right * wave1 + up * wave2
                            render.DrawBeam(p1.pos + offset, p2.pos + offset, 1.5, 0, 1,
                                SetCol(c2.r, c2.g, c2.b, 130 * age1))
                        end
                    end
                end

                -- ASCENDED: Lightning arcs (2 arcs, skip every other point)
                if tr.isAscended and ascOverlay and ascOverlay.hasLightning then
                    local right, up = tr.right, tr.up
                    local lc = ascOverlay.lightningColor
                    for arc = 1, 2 do
                        local arcSeed = arc * 47.3 + tr.glitchSeed
                        for j = 2, #trail, 2 do
                            local p1, p2 = trail[j - 1], trail[j]
                            local age1 = 1 - Clamp((ct - p1.time) / fadeTime, 0, 1)
                            if age1 < 0.05 then continue end
                            local jag1 = sin((j + floor(elapsed * 60)) * arcSeed) * ascOverlay.lightningRange
                            local jag2 = cos((j + floor(elapsed * 60)) * arcSeed * 0.7) * ascOverlay.lightningRange * 0.6
                            render.DrawBeam(p1.pos + right * jag1 + up * jag2, p2.pos + right * jag1 + up * jag2,
                                1, 0, 1, SetCol(lc.r, lc.g, lc.b, lc.a * age1))
                        end
                    end
                end
            end -- isClose
        end -- trail

        -- ========================================
        -- PROJECTILE HEAD
        -- ========================================
        if progress < 1 then
            render.SetMaterial(matGlow)
            local headSize = tier.trailWidth * 3
            render.DrawSprite(curPos, headSize, headSize, SetCol(br, bg, bb, 255))

            render.SetMaterial(matSoftGlow)
            render.DrawSprite(curPos, tier.glowWidth * 2, tier.glowWidth * 2, SetCol(gr, gg, gb, 100))

            -- Void core (Mythical) - dark center
            if tier.voidCore then
                render.SetMaterial(matGlow)
                render.DrawSprite(curPos, headSize * 1.5, headSize * 1.5, SetCol(0, 0, 0, 200))
                render.SetMaterial(matSoftGlow)
                local aura = tier.glowWidth * 2 * (2.5 + sin(elapsed * 3) * 0.5)
                render.DrawSprite(curPos, aura, aura, SetCol(60, 0, 0, 40))
            end

            -- Spiral (Legendary comet)
            if tier.hasSpiral and isClose then
                render.SetMaterial(matFlare)
                local spiralR, spiralSpd = tier.spiralRadius or 3, tier.spiralSpeed or 6
                for s = 0, 2 do
                    local angle = elapsed * spiralSpd * 6.283 + s * 2.094
                    local offset = tr.right * cos(angle) * spiralR + tr.up * sin(angle) * spiralR
                    render.DrawSprite(curPos + offset, tier.trailWidth * 1.5, tier.trailWidth * 1.5,
                        SetCol(br, bg, bb, 180))
                end
            end

            -- ASCENDED: Halo + rays (close only)
            if tr.isAscended and ascOverlay and isClose then
                if ascOverlay.hasHalo then
                    local hc = ascOverlay.haloColor
                    local hR = ascOverlay.haloRadius
                    render.SetMaterial(matFlare)
                    for p = 0, 7 do
                        local angle = p * 0.785 + elapsed * 4
                        local offset = tr.right * cos(angle) * hR + tr.up * sin(angle) * hR
                        render.DrawSprite(curPos + offset, 3, 3, SetCol(hc.r, hc.g, hc.b, hc.a))
                    end
                end

                if ascOverlay.hasDivineRays then
                    local rc = ascOverlay.rayColor
                    render.SetMaterial(matBeam)
                    for r = 0, ascOverlay.rayCount - 1 do
                        local angle = r / ascOverlay.rayCount * 6.283 + elapsed * 2
                        local rayDir = tr.right * cos(angle) + tr.up * sin(angle)
                        local rayLen = 15 + sin(elapsed * 5 + r) * 5
                        render.DrawBeam(curPos, curPos + rayDir * rayLen, 1.5, 0, 1,
                            SetCol(rc.r, rc.g, rc.b, rc.a * (0.6 + sin(elapsed * 8 + r) * 0.4)))
                    end
                end

                -- Golden overlay glow
                render.SetMaterial(matGlow)
                render.DrawSprite(curPos, tier.trailWidth * 6, tier.trailWidth * 6,
                    SetCol(255, 230, 100, 60 + sin(elapsed * 6) * 25))
            end
        end
    end

    -- ========================================
    -- IMPACTS (simplified)
    -- ========================================
    for _, imp in ipairs(impacts) do
        local age = ct - imp.spawnTime
        local life = age / imp.lifetime
        local fade = 1 - life
        local tier = imp.tier
        local ic = tier.impactColor or tier.color

        -- Ring
        local ringSize = imp.size * (0.3 + life * 2)
        render.SetMaterial(matSoftGlow)

        if tier.chromatic then
            local cr, cg, cb = ChromaticRGB(age)
            render.DrawSprite(imp.pos + imp.normal, ringSize, ringSize, SetCol(cr, cg, cb, fade * 200))
        elseif tier.voidTrail then
            -- Dark void impact
            render.SetMaterial(matGlow)
            render.DrawSprite(imp.pos + imp.normal * 0.5, ringSize, ringSize, SetCol(0, 0, 0, fade * 180))
            render.SetMaterial(matRing)
            render.DrawSprite(imp.pos + imp.normal * 0.5, ringSize * 1.3, ringSize * 1.3, SetCol(200, 0, 0, fade * 120))
        else
            render.DrawSprite(imp.pos + imp.normal, ringSize, ringSize, SetCol(ic.r, ic.g, ic.b, fade * 200))
        end

        -- Core flash
        if life < 0.3 then
            local ff = 1 - life / 0.3
            render.SetMaterial(matGlow)
            render.DrawSprite(imp.pos + imp.normal * 2, imp.size * 1.5 * ff, imp.size * 1.5 * ff,
                SetCol(255, 255, 255, 200 * ff))
        end

        -- Ascended pillar
        if imp.isAscended and ascOverlay and ascOverlay.impactPillar then
            local pf = fade * fade
            local pc = ascOverlay.pillarColor
            local ph = ascOverlay.pillarHeight
            render.SetMaterial(matBeam)
            render.DrawBeam(imp.pos - Vector(0, 0, ph * 0.2 * pf), imp.pos + Vector(0, 0, ph * pf),
                6 * pf, 0, 1, SetCol(pc.r, pc.g, pc.b, pc.a * pf))
            render.DrawBeam(imp.pos - Vector(0, 0, ph * 0.15 * pf), imp.pos + Vector(0, 0, ph * 0.9 * pf),
                2 * pf, 0, 1, SetCol(255, 255, 230, 180 * pf))
        end
    end
end)

print("[BRS UW] Tracer client (optimized) loaded")
