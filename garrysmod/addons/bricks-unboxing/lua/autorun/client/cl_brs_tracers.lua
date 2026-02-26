-- ============================================================
-- BRS Unique Weapons - Tracer System (Client)
-- Renders visual projectile tracers with rarity-based effects
-- Each rarity has a DISTINCT visual identity
-- Ascended quality adds divine overlay effects
-- ============================================================

local tracers = {}
local impacts = {}
local MAX_TRACERS = 64
local MAX_IMPACTS = 32

local orderToRarity = {
    [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic",
    [5] = "Legendary", [6] = "Glitched", [7] = "Mythical",
}

-- ============================================================
-- MATERIALS
-- ============================================================
local matGlow = Material("sprites/light_glow02_add")
local matBeam = Material("trails/laser")
local matSoftGlow = Material("sprites/glow04_noz")
local matFlare = Material("effects/blueflare1")
local matRing = Material("effects/select_ring")
local matLight = Material("sprites/light_ignorez")

-- ============================================================
-- UTILITY: Chromatic color shift (Glitched)
-- ============================================================
local function ChromaticColor(t, alpha)
    local r = math.sin(t * 6) * 127 + 128
    local g = math.sin(t * 6 + 2.094) * 127 + 128
    local b = math.sin(t * 6 + 4.189) * 127 + 128
    return Color(r, g, b, alpha or 255)
end

-- Rapid cyan<->magenta flicker (Glitched)
local function GlitchColor(t, base, alt)
    -- Fast random flicker between two colors
    local flicker = math.sin(t * 40) + math.sin(t * 67) + math.sin(t * 97)
    if flicker > 0.5 then
        return alt or Color(255, 0, 200, 255)
    end
    return base or Color(0, 255, 220, 255)
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

    -- Adjust start to viewmodel muzzle for local player
    if IsValid(shooter) and shooter == LocalPlayer() then
        local vm = shooter:GetViewModel()
        if IsValid(vm) then
            local att = vm:GetAttachment(vm:LookupAttachment("muzzle") or 1)
            if att then startPos = att.Pos or startPos end
        end
    end

    local dist = startPos:Distance(endPos)
    local travelTime = math.max(dist / tier.speed, 0.02)
    local dir = (endPos - startPos):GetNormalized()

    if #tracers >= MAX_TRACERS then table.remove(tracers, 1) end

    table.insert(tracers, {
        startPos = startPos,
        endPos = endPos,
        dir = dir,
        dist = dist,
        hitNormal = hitNormal,
        didHit = didHit,
        tier = tier,
        rarityKey = rarityKey,
        isAscended = isAscended,
        spawnTime = CurTime(),
        travelTime = travelTime,
        trailPoints = {},
        lastTrailTime = 0,
        impactSpawned = false,
        -- Glitch-specific: pre-generate glitch offsets
        glitchSeed = math.random(1000),
    })
end)

-- ============================================================
-- SPAWN IMPACT EFFECT
-- ============================================================
local function SpawnImpact(pos, normal, tier, rarityKey, isAscended)
    if #impacts >= MAX_IMPACTS then table.remove(impacts, 1) end

    local size = (tier.impactSize or 1.0) * 30
    table.insert(impacts, {
        pos = pos,
        normal = normal,
        color = tier.impactColor or tier.color,
        tier = tier,
        rarityKey = rarityKey,
        isAscended = isAscended,
        spawnTime = CurTime(),
        lifetime = 0.5 + (tier.impactSize or 1.0) * 0.3,
        size = size,
    })

    -- Source engine impact for heavy tiers
    if tier.impactSize and tier.impactSize >= 1.5 then
        local ed = EffectData()
        ed:SetOrigin(pos)
        ed:SetNormal(normal)
        ed:SetScale(tier.impactSize)
        util.Effect("StunstickImpact", ed)
    end
end

-- ============================================================
-- THINK: Update tracers
-- ============================================================
hook.Add("Think", "BRS_UW_TracerThink", function()
    local ct = CurTime()

    for i = #tracers, 1, -1 do
        local tr = tracers[i]
        local elapsed = ct - tr.spawnTime
        local progress = math.Clamp(elapsed / tr.travelTime, 0, 1)

        tr.currentPos = LerpVector(progress, tr.startPos, tr.endPos)

        -- Trail breadcrumbs
        if ct - tr.lastTrailTime > 0.005 then
            table.insert(tr.trailPoints, { pos = tr.currentPos, time = ct })
            tr.lastTrailTime = ct
        end

        -- Trim old trail
        local fadeTime = tr.tier.lifetime or 0.2
        for j = #tr.trailPoints, 1, -1 do
            if ct - tr.trailPoints[j].time > fadeTime then
                table.remove(tr.trailPoints, j)
            end
        end

        -- Hit destination
        if progress >= 1 then
            if not tr.impactSpawned and tr.didHit and tr.tier.hasImpact then
                SpawnImpact(tr.endPos, tr.hitNormal, tr.tier, tr.rarityKey, tr.isAscended)
                tr.impactSpawned = true
            end
            if #tr.trailPoints == 0 then
                table.remove(tracers, i)
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
-- RENDER: Draw all tracer effects
-- ============================================================
hook.Add("PostDrawTranslucentRenderables", "BRS_UW_TracerRender", function(bDrawingDepth, bDrawingSkybox)
    if bDrawingSkybox then return end

    local ct = CurTime()
    local ascOverlay = BRS_UW.Tracers and BRS_UW.Tracers.AscendedOverlay

    for _, tr in ipairs(tracers) do
        local tier = tr.tier
        local elapsed = ct - tr.spawnTime
        local progress = math.Clamp(elapsed / tr.travelTime, 0, 1)
        local curPos = tr.currentPos or tr.startPos

        -- ========================================
        -- RESOLVE COLORS (tier-specific logic)
        -- ========================================
        local baseColor, glowColor

        if tier.chromatic then
            -- GLITCHED: rapid cyan<->magenta flicker
            baseColor = GlitchColor(elapsed + tr.glitchSeed, tier.color, tier.color2)
            glowColor = ChromaticColor(elapsed, tier.glowColor.a)
        elseif tier.color2 then
            -- MYTHICAL: dark red core, void purple pulse
            local pulse = math.sin(elapsed * 2) * 0.5 + 0.5
            baseColor = Color(
                Lerp(pulse, tier.color.r, tier.color2.r),
                Lerp(pulse, tier.color.g, tier.color2.g),
                Lerp(pulse, tier.color.b, tier.color2.b),
                255
            )
            glowColor = tier.glowColor
        else
            baseColor = tier.color
            glowColor = tier.glowColor
        end

        -- ========================================
        -- GLOW TRAIL (all tiers)
        -- ========================================
        if #tr.trailPoints > 1 then
            local fadeTime = tier.lifetime or 0.2

            render.SetMaterial(matBeam)
            for j = 2, #tr.trailPoints do
                local p1 = tr.trailPoints[j - 1]
                local p2 = tr.trailPoints[j]
                local age1 = 1 - math.Clamp((ct - p1.time) / fadeTime, 0, 1)

                -- Core beam
                render.DrawBeam(p1.pos, p2.pos, tier.trailWidth, 0, 1,
                    Color(baseColor.r, baseColor.g, baseColor.b, baseColor.a * age1))

                -- Outer glow
                render.DrawBeam(p1.pos, p2.pos, tier.glowWidth, 0, 1,
                    Color(glowColor.r, glowColor.g, glowColor.b, glowColor.a * age1 * 0.6))
            end

            -- ========================================
            -- AFTERIMAGE (Legendary + Mythical)
            -- ========================================
            if tier.hasAfterimage then
                local aiColor = tier.afterimageColor or Color(255, 150, 50, 50)
                render.SetMaterial(matBeam)
                for j = 2, #tr.trailPoints do
                    local p1 = tr.trailPoints[j - 1]
                    local p2 = tr.trailPoints[j]
                    local age1 = 1 - math.Clamp((ct - p1.time) / (fadeTime * 2), 0, 1)
                    render.DrawBeam(p1.pos, p2.pos, tier.glowWidth * 1.5, 0, 1,
                        Color(aiColor.r, aiColor.g, aiColor.b, aiColor.a * age1))
                end
            end

            -- ========================================
            -- GLITCH TRAIL: flickering segments that offset randomly
            -- ========================================
            if tier.glitchTrail then
                render.SetMaterial(matBeam)
                for j = 2, #tr.trailPoints do
                    local p1 = tr.trailPoints[j - 1]
                    local p2 = tr.trailPoints[j]
                    local age1 = 1 - math.Clamp((ct - p1.time) / fadeTime, 0, 1)

                    -- Every few segments, offset the trail randomly (glitch teleport)
                    local segHash = j + math.floor(elapsed * 30)
                    if segHash % 3 == 0 then
                        local offsetAmt = math.sin(segHash * 137.5 + elapsed * 50) * 8
                        local right = tr.dir:Angle():Right()
                        local up = tr.dir:Angle():Up()
                        local offset = right * offsetAmt + up * (offsetAmt * 0.5)

                        local flickCol = GlitchColor(elapsed + j * 0.1, tier.color, tier.color2)
                        render.DrawBeam(p1.pos + offset, p2.pos + offset, tier.trailWidth * 0.8, 0, 1,
                            Color(flickCol.r, flickCol.g, flickCol.b, 200 * age1))
                    end
                end

                -- Scan line overlay: thin horizontal lines that scroll
                if tier.scanLines and #tr.trailPoints > 2 then
                    local first = tr.trailPoints[1].pos
                    local last = tr.trailPoints[#tr.trailPoints].pos
                    local scanOffset = (elapsed * 400) % 20

                    render.SetMaterial(matBeam)
                    for s = 0, 3 do
                        local t = (s * 0.25 + scanOffset / 20) % 1
                        local scanPos = LerpVector(t, first, last)
                        local scanDir = tr.dir:Angle():Right()
                        local scanW = 6
                        render.DrawBeam(
                            scanPos - scanDir * scanW,
                            scanPos + scanDir * scanW,
                            0.5, 0, 1,
                            ChromaticColor(elapsed + s, 120)
                        )
                    end
                end
            end

            -- ========================================
            -- VOID TRAIL: dark tendrils writhing behind projectile
            -- ========================================
            if tier.voidTrail then
                render.SetMaterial(matBeam)
                local right = tr.dir:Angle():Right()
                local up = tr.dir:Angle():Up()

                -- 3 writhing tendrils
                for tendril = 0, 2 do
                    local phase = tendril * 2.094 -- 120 degrees apart
                    for j = 2, #tr.trailPoints do
                        local p1 = tr.trailPoints[j - 1]
                        local p2 = tr.trailPoints[j]
                        local age1 = 1 - math.Clamp((ct - p1.time) / fadeTime, 0, 1)
                        local segT = (j / #tr.trailPoints)

                        -- Tendrils wave outward from center, grow wider over time
                        local waveAmt = math.sin(elapsed * 4 + segT * 8 + phase) * (6 + segT * 4)
                        local waveAmt2 = math.cos(elapsed * 3 + segT * 6 + phase) * (4 + segT * 3)
                        local offset = right * waveAmt + up * waveAmt2

                        render.DrawBeam(p1.pos + offset, p2.pos + offset, 1.5, 0, 1,
                            Color(tier.color2.r, tier.color2.g, tier.color2.b, 140 * age1))
                    end
                end
            end

            -- ========================================
            -- ASCENDED: Golden lightning arcs along trail
            -- ========================================
            if tr.isAscended and ascOverlay and ascOverlay.hasLightning then
                render.SetMaterial(matBeam)
                local lColor = ascOverlay.lightningColor
                local right = tr.dir:Angle():Right()
                local up = tr.dir:Angle():Up()

                for arc = 1, ascOverlay.lightningArcCount do
                    local arcSeed = arc * 47.3 + tr.glitchSeed
                    for j = 2, #tr.trailPoints do
                        local p1 = tr.trailPoints[j - 1]
                        local p2 = tr.trailPoints[j]
                        local age1 = 1 - math.Clamp((ct - p1.time) / fadeTime, 0, 1)

                        -- Jagged lightning offset
                        local jag1 = math.sin((j + math.floor(elapsed * 60)) * arcSeed) * ascOverlay.lightningRange
                        local jag2 = math.cos((j + math.floor(elapsed * 60)) * arcSeed * 0.7) * ascOverlay.lightningRange * 0.6
                        local offset = right * jag1 + up * jag2

                        render.DrawBeam(p1.pos + offset, p2.pos + offset, 1, 0, 1,
                            Color(lColor.r, lColor.g, lColor.b, lColor.a * age1))
                    end
                end
            end
        end

        -- ========================================
        -- PROJECTILE HEAD
        -- ========================================
        if progress < 1 then
            -- Core glow
            render.SetMaterial(matGlow)
            local headSize = tier.trailWidth * 3
            render.DrawSprite(curPos, headSize, headSize,
                Color(baseColor.r, baseColor.g, baseColor.b, 255))

            -- Outer flare
            render.SetMaterial(matSoftGlow)
            local flareSize = tier.glowWidth * 2
            render.DrawSprite(curPos, flareSize, flareSize,
                Color(glowColor.r, glowColor.g, glowColor.b, 100))

            -- ========================================
            -- VOID CORE: dark center with red corona (Mythical)
            -- ========================================
            if tier.voidCore then
                -- Dark black center
                render.SetMaterial(matGlow)
                render.DrawSprite(curPos, headSize * 1.5, headSize * 1.5,
                    Color(0, 0, 0, 200))
                -- Red corona around black
                render.SetMaterial(matSoftGlow)
                render.DrawSprite(curPos, flareSize * 1.8, flareSize * 1.8,
                    Color(200, 0, 0, 80 + math.sin(elapsed * 8) * 40))
                -- Pulsing dark aura
                local auraSize = flareSize * (2.5 + math.sin(elapsed * 3) * 0.5)
                render.DrawSprite(curPos, auraSize, auraSize,
                    Color(60, 0, 0, 40))
            end

            -- ========================================
            -- SPIRAL (Legendary comet orbiting embers)
            -- ========================================
            if tier.hasSpiral then
                local spiralR = tier.spiralRadius or 3
                local spiralSpd = tier.spiralSpeed or 6
                local right = tr.dir:Angle():Right()
                local up = tr.dir:Angle():Up()

                render.SetMaterial(matFlare)
                for s = 0, 2 do
                    local angle = elapsed * spiralSpd * math.pi * 2 + s * (math.pi * 2 / 3)
                    local offset = right * math.cos(angle) * spiralR + up * math.sin(angle) * spiralR
                    render.DrawSprite(curPos + offset, tier.trailWidth * 1.5, tier.trailWidth * 1.5,
                        Color(baseColor.r, baseColor.g, baseColor.b, 180))
                end
            end

            -- ========================================
            -- ASCENDED: Spinning halo ring + divine rays
            -- ========================================
            if tr.isAscended and ascOverlay then
                -- Golden halo ring (spinning)
                if ascOverlay.hasHalo then
                    local hColor = ascOverlay.haloColor
                    local hR = ascOverlay.haloRadius
                    local right = tr.dir:Angle():Right()
                    local up = tr.dir:Angle():Up()

                    render.SetMaterial(matFlare)
                    -- Draw ring as series of points
                    for p = 0, 11 do
                        local angle = (p / 12) * math.pi * 2 + elapsed * 4
                        local offset = right * math.cos(angle) * hR + up * math.sin(angle) * hR
                        render.DrawSprite(curPos + offset, 3, 3,
                            Color(hColor.r, hColor.g, hColor.b, hColor.a))
                    end
                end

                -- Divine light rays
                if ascOverlay.hasDivineRays then
                    local rColor = ascOverlay.rayColor
                    local right = tr.dir:Angle():Right()
                    local up = tr.dir:Angle():Up()

                    render.SetMaterial(matBeam)
                    for r = 0, ascOverlay.rayCount - 1 do
                        local angle = (r / ascOverlay.rayCount) * math.pi * 2 + elapsed * 2
                        local rayDir = right * math.cos(angle) + up * math.sin(angle)
                        local rayLen = 15 + math.sin(elapsed * 5 + r) * 5
                        local rayEnd = curPos + rayDir * rayLen
                        render.DrawBeam(curPos, rayEnd, 1.5, 0, 1,
                            Color(rColor.r, rColor.g, rColor.b, rColor.a * (0.6 + math.sin(elapsed * 8 + r) * 0.4)))
                    end
                end

                -- Golden core overlay
                render.SetMaterial(matGlow)
                local divineSize = headSize * 2
                render.DrawSprite(curPos, divineSize, divineSize,
                    Color(255, 230, 100, 80 + math.sin(elapsed * 6) * 30))
            end
        end
    end

    -- ========================================
    -- IMPACT EFFECTS
    -- ========================================
    for _, imp in ipairs(impacts) do
        local age = ct - imp.spawnTime
        local life = age / imp.lifetime
        local fade = 1 - life
        local tier = imp.tier
        local col = imp.color

        if tier.chromatic then
            col = ChromaticColor(age, 255)
        elseif tier.color2 then
            -- Void impact: dark red pulse
            local pulse = math.sin(age * 6) * 0.5 + 0.5
            col = Color(
                Lerp(pulse, tier.color.r, 40),
                0,
                Lerp(pulse, 0, 20),
                255
            )
        end

        -- Expanding ring
        local ringSize = imp.size * (0.3 + life * 2)
        render.SetMaterial(matSoftGlow)
        render.DrawSprite(imp.pos + imp.normal * 1, ringSize, ringSize,
            Color(col.r, col.g, col.b, fade * 200))

        -- Core flash
        if life < 0.3 then
            local flashFade = 1 - (life / 0.3)
            render.SetMaterial(matGlow)
            render.DrawSprite(imp.pos + imp.normal * 2,
                imp.size * 1.5 * flashFade, imp.size * 1.5 * flashFade,
                Color(255, 255, 255, 200 * flashFade))
        end

        -- Void impact: dark expanding void circle
        if tier.voidTrail then
            local voidSize = imp.size * (0.5 + life * 3)
            render.SetMaterial(matGlow)
            render.DrawSprite(imp.pos + imp.normal * 0.5, voidSize, voidSize,
                Color(0, 0, 0, 180 * fade))
            -- Red ring around void
            render.SetMaterial(matRing)
            render.DrawSprite(imp.pos + imp.normal * 0.5, voidSize * 1.3, voidSize * 1.3,
                Color(200, 0, 0, 120 * fade))
        end

        -- Glitch impact: multiple offset copies
        if tier.glitchTrail then
            for g = 1, 3 do
                local gOffset = Vector(
                    math.sin(age * 40 + g * 2.5) * 8 * fade,
                    math.cos(age * 35 + g * 3.7) * 8 * fade,
                    math.sin(age * 45 + g * 1.3) * 4 * fade
                )
                local gCol = GlitchColor(age + g, tier.color, tier.color2)
                render.SetMaterial(matSoftGlow)
                render.DrawSprite(imp.pos + gOffset, ringSize * 0.6, ringSize * 0.6,
                    Color(gCol.r, gCol.g, gCol.b, 100 * fade))
            end
        end

        -- Secondary ring (heavy tiers)
        if tier.impactSize and tier.impactSize >= 1.5 then
            local ring2Size = imp.size * (0.1 + life * 3)
            render.SetMaterial(matRing)
            render.DrawSprite(imp.pos + imp.normal * 0.5, ring2Size, ring2Size,
                Color(col.r, col.g, col.b, fade * 100))
        end

        -- ========================================
        -- ASCENDED IMPACT: Golden light pillar
        -- ========================================
        if imp.isAscended and ascOverlay and ascOverlay.impactPillar then
            local pColor = ascOverlay.pillarColor
            local pHeight = ascOverlay.pillarHeight

            -- Vertical beam of light
            render.SetMaterial(matBeam)
            local pillarFade = fade * fade -- faster falloff
            local pillarTop = imp.pos + Vector(0, 0, pHeight * pillarFade)
            local pillarBot = imp.pos - Vector(0, 0, pHeight * 0.3 * pillarFade)

            render.DrawBeam(pillarBot, pillarTop, 8 * pillarFade, 0, 1,
                Color(pColor.r, pColor.g, pColor.b, pColor.a * pillarFade))
            -- Inner bright core
            render.DrawBeam(pillarBot, pillarTop, 3 * pillarFade, 0, 1,
                Color(255, 255, 230, 200 * pillarFade))

            -- Ground ring
            local groundRing = imp.size * (1 + life * 4) * 1.5
            render.SetMaterial(matRing)
            render.DrawSprite(imp.pos, groundRing, groundRing,
                Color(pColor.r, pColor.g, pColor.b, 120 * pillarFade))
        end
    end
end)

-- ============================================================
-- PARTICLES: Emitted from Think hook (safe context)
-- ============================================================
hook.Add("Think", "BRS_UW_TracerParticles", function()
    local ct = CurTime()
    local ascOverlay = BRS_UW.Tracers and BRS_UW.Tracers.AscendedOverlay

    for _, tr in ipairs(tracers) do
        local tier = tr.tier
        local elapsed = ct - tr.spawnTime
        local progress = math.Clamp(elapsed / tr.travelTime, 0, 1)
        if progress >= 1 then continue end

        local curPos = tr.currentPos or tr.startPos

        -- Throttle
        if ct - (tr.lastParticleTime or 0) < 0.015 then continue end
        tr.lastParticleTime = ct

        -- ========================================
        -- RARITY PARTICLES
        -- ========================================
        if tier.hasParticles and math.random() < 0.7 then
            local pCol = tier.particleColor or tier.color
            if tier.chromatic then
                pCol = ChromaticColor(elapsed + math.random() * 2, 240)
            end

            local behindPos = curPos - tr.dir * math.random(2, 8) + VectorRand() * 2
            local pType = tier.particleType or "sparks"

            local emitter = ParticleEmitter(behindPos, false)
            if emitter then
                local p = emitter:Add("sprites/light_glow02_add", behindPos)
                if p then
                    p:SetStartAlpha(pCol.a)
                    p:SetEndAlpha(0)
                    p:SetColor(pCol.r, pCol.g, pCol.b)

                    if pType == "sparks" then
                        p:SetDieTime(math.Rand(0.1, 0.3))
                        p:SetStartSize(math.Rand(1, 2))
                        p:SetEndSize(0)
                        p:SetVelocity(VectorRand() * 40)
                        p:SetGravity(Vector(0, 0, -200))

                    elseif pType == "energy" then
                        p:SetDieTime(math.Rand(0.15, 0.3))
                        p:SetStartSize(math.Rand(2, 4))
                        p:SetEndSize(1)
                        p:SetVelocity(VectorRand() * 20)
                        p:SetGravity(Vector(0, 0, 50))

                    elseif pType == "comet" then
                        -- Ember shower: bright sparks falling behind like a comet tail
                        p:SetDieTime(math.Rand(0.2, 0.5))
                        p:SetStartSize(math.Rand(2, 4))
                        p:SetEndSize(0)
                        p:SetVelocity(-tr.dir * 60 + VectorRand() * 25)
                        p:SetGravity(Vector(0, 0, -120))
                        p:SetColor(255, math.random(140, 220), math.random(20, 60))

                        -- Extra bright ember
                        local ember = emitter:Add("sprites/light_glow02_add", behindPos + VectorRand() * 3)
                        if ember then
                            ember:SetDieTime(math.Rand(0.1, 0.25))
                            ember:SetStartAlpha(255)
                            ember:SetEndAlpha(0)
                            ember:SetColor(255, 255, 200)
                            ember:SetStartSize(math.Rand(1, 2))
                            ember:SetEndSize(0)
                            ember:SetVelocity(-tr.dir * 40 + VectorRand() * 40)
                            ember:SetGravity(Vector(0, 0, -300))
                        end

                    elseif pType == "glitch" then
                        -- Digital fragments: sharp, fast, random directions
                        p:SetDieTime(math.Rand(0.05, 0.15))
                        p:SetStartSize(math.Rand(1, 3))
                        p:SetEndSize(0)
                        p:SetVelocity(VectorRand() * 80)
                        p:SetGravity(Vector(0, 0, 0))
                        -- Alternate colors
                        if math.random() > 0.5 then
                            p:SetColor(255, 0, 200) -- magenta
                        else
                            p:SetColor(0, 255, 220) -- cyan
                        end

                        -- Extra: digital "square" particles (tiny, short-lived)
                        local sq = emitter:Add("sprites/light_glow02_add", curPos + VectorRand() * 6)
                        if sq then
                            sq:SetDieTime(0.05)
                            sq:SetStartAlpha(200)
                            sq:SetEndAlpha(0)
                            sq:SetColor(math.random(200, 255), math.random(200, 255), math.random(200, 255))
                            sq:SetStartSize(math.Rand(0.5, 1.5))
                            sq:SetEndSize(0)
                            sq:SetVelocity(Vector(0, 0, 0))
                        end

                    elseif pType == "void" then
                        -- Dark void wisps: slow, drifting, ominous
                        p:SetDieTime(math.Rand(0.3, 0.7))
                        p:SetStartSize(math.Rand(3, 6))
                        p:SetEndSize(math.Rand(1, 3))
                        p:SetVelocity(-tr.dir * 30 + VectorRand() * 15)
                        p:SetGravity(Vector(0, 0, 20))
                        p:SetColor(40, 0, 0)
                        p:SetStartAlpha(160)

                        -- Red ember in the void
                        local redEmber = emitter:Add("sprites/light_glow02_add", behindPos + VectorRand() * 4)
                        if redEmber then
                            redEmber:SetDieTime(math.Rand(0.2, 0.4))
                            redEmber:SetStartAlpha(200)
                            redEmber:SetEndAlpha(0)
                            redEmber:SetColor(200, 0, 0)
                            redEmber:SetStartSize(math.Rand(1, 2))
                            redEmber:SetEndSize(0)
                            redEmber:SetVelocity(VectorRand() * 20)
                            redEmber:SetGravity(Vector(0, 0, -50))
                        end

                        -- Dark smoke
                        local smoke = emitter:Add("particle/particle_smokegrenade", behindPos)
                        if smoke then
                            smoke:SetDieTime(math.Rand(0.4, 0.8))
                            smoke:SetStartAlpha(60)
                            smoke:SetEndAlpha(0)
                            smoke:SetColor(20, 0, 10)
                            smoke:SetStartSize(math.Rand(3, 5))
                            smoke:SetEndSize(math.Rand(8, 14))
                            smoke:SetVelocity(-tr.dir * 20 + VectorRand() * 10)
                            smoke:SetGravity(Vector(0, 0, 30))
                            smoke:SetRoll(math.Rand(0, 360))
                            smoke:SetRollDelta(math.Rand(-2, 2))
                        end
                    end
                end
                emitter:Finish()
            end
        end

        -- ========================================
        -- ASCENDED: Golden spark shower along trail
        -- ========================================
        if tr.isAscended and ascOverlay and ascOverlay.hasGoldenShower then
            if math.random() < 0.5 then
                local sColor = ascOverlay.showerColor
                local emitter = ParticleEmitter(curPos, false)
                if emitter then
                    local gp = emitter:Add("sprites/light_glow02_add", curPos + VectorRand() * 4)
                    if gp then
                        gp:SetDieTime(math.Rand(0.2, 0.5))
                        gp:SetStartAlpha(sColor.a)
                        gp:SetEndAlpha(0)
                        gp:SetColor(sColor.r, sColor.g, sColor.b)
                        gp:SetStartSize(math.Rand(1.5, 3))
                        gp:SetEndSize(0)
                        gp:SetVelocity(VectorRand() * 35 + Vector(0, 0, 30))
                        gp:SetGravity(Vector(0, 0, -150))
                    end
                    emitter:Finish()
                end
            end
        end
    end
end)

print("[BRS UW] Tracer client renderer loaded")
