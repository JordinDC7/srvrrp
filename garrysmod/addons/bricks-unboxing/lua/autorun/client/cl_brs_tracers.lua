-- ============================================================
-- BRS Unique Weapons - Tracer System (Client)
-- Renders visual projectile tracers with rarity-based effects
-- Glow trails, particles, spirals, impact splashes, afterimages
-- ============================================================

local tracers = {}              -- active tracer projectiles
local impacts = {}              -- active impact effects
local MAX_TRACERS = 64          -- pool limit
local MAX_IMPACTS = 32

-- Rarity order -> key lookup
local orderToRarity = {
    [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic",
    [5] = "Legendary", [6] = "Glitched", [7] = "Mythical",
}

-- ============================================================
-- TRACER MATERIALS (created once)
-- ============================================================
local matGlow = Material("sprites/light_glow02_add")
local matBeam = Material("trails/laser")
local matSoftGlow = Material("sprites/glow04_noz")
local matFlare = Material("effects/blueflare1")
local matSmoke = Material("particle/particle_smokegrenade")
local matSpark = Material("effects/spark")
local matRing = Material("effects/select_ring")

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

    local rarityKey = orderToRarity[rarityOrder] or "Common"
    local tier = BRS_UW.Tracers and BRS_UW.Tracers.GetTier(rarityKey)
    if not tier then return end

    -- Don't render our own tracers in first person (we see muzzle flash instead)
    -- Actually DO render them - they look cool
    -- But offset start to muzzle attachment if it's us
    if IsValid(shooter) and shooter == LocalPlayer() then
        local vm = shooter:GetViewModel()
        if IsValid(vm) then
            local att = vm:GetAttachment(vm:LookupAttachment("muzzle") or 1)
            if att then
                -- Keep server hitPos, just adjust visual start
                startPos = att.Pos or startPos
            end
        end
    end

    -- Calculate travel
    local dist = startPos:Distance(endPos)
    local travelTime = dist / tier.speed
    local dir = (endPos - startPos):GetNormalized()

    -- Trim oldest if pool full
    if #tracers >= MAX_TRACERS then
        table.remove(tracers, 1)
    end

    -- Spawn tracer
    table.insert(tracers, {
        startPos = startPos,
        endPos = endPos,
        dir = dir,
        dist = dist,
        hitNormal = hitNormal,
        didHit = didHit,
        tier = tier,
        rarityKey = rarityKey,
        spawnTime = CurTime(),
        travelTime = math.max(travelTime, 0.02),
        trailPoints = {},           -- breadcrumb trail positions
        lastTrailTime = 0,
        alive = true,
        impactSpawned = false,
    })
end)

-- ============================================================
-- CHROMATIC COLOR SHIFT (for Glitched rarity)
-- ============================================================
local function ChromaticColor(baseColor, t)
    local hueShift = (t * 200) % 360
    -- Simple HSV-ish cycle
    local r = math.sin(math.rad(hueShift)) * 127 + 128
    local g = math.sin(math.rad(hueShift + 120)) * 127 + 128
    local b = math.sin(math.rad(hueShift + 240)) * 127 + 128
    return Color(r, g, b, baseColor.a)
end

-- ============================================================
-- SPAWN IMPACT EFFECT
-- ============================================================
local function SpawnImpact(pos, normal, tier, rarityKey)
    if #impacts >= MAX_IMPACTS then
        table.remove(impacts, 1)
    end

    local size = (tier.impactSize or 1.0) * 30
    local impactCol = tier.impactColor or tier.color

    table.insert(impacts, {
        pos = pos,
        normal = normal,
        color = impactCol,
        tier = tier,
        rarityKey = rarityKey,
        spawnTime = CurTime(),
        lifetime = 0.5 + (tier.impactSize or 1.0) * 0.3,
        size = size,
        alive = true,
    })

    -- Spawn Source engine particles for extra oomph on high tiers
    if tier.impactSize and tier.impactSize >= 1.5 then
        local ed = EffectData()
        ed:SetOrigin(pos)
        ed:SetNormal(normal)
        ed:SetScale(tier.impactSize)
        util.Effect("StunstickImpact", ed)
    end
end

-- ============================================================
-- THINK: Update tracers and impacts
-- ============================================================
hook.Add("Think", "BRS_UW_TracerThink", function()
    local ct = CurTime()

    -- Update tracers
    for i = #tracers, 1, -1 do
        local tr = tracers[i]
        local elapsed = ct - tr.spawnTime
        local progress = math.Clamp(elapsed / tr.travelTime, 0, 1)

        -- Current position along path
        tr.currentPos = LerpVector(progress, tr.startPos, tr.endPos)

        -- Add trail breadcrumbs
        if ct - tr.lastTrailTime > 0.005 then
            table.insert(tr.trailPoints, {
                pos = tr.currentPos,
                time = ct,
            })
            tr.lastTrailTime = ct
        end

        -- Trim old trail points
        local fadeTime = tr.tier.lifetime or 0.2
        for j = #tr.trailPoints, 1, -1 do
            if ct - tr.trailPoints[j].time > fadeTime then
                table.remove(tr.trailPoints, j)
            end
        end

        -- Projectile reached destination
        if progress >= 1 then
            if not tr.impactSpawned and tr.didHit and tr.tier.hasImpact then
                SpawnImpact(tr.endPos, tr.hitNormal, tr.tier, tr.rarityKey)
                tr.impactSpawned = true
            end

            -- Keep alive for trail fade
            if #tr.trailPoints == 0 then
                table.remove(tracers, i)
            end
        end
    end

    -- Update impacts
    for i = #impacts, 1, -1 do
        local imp = impacts[i]
        if ct - imp.spawnTime > imp.lifetime then
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
    local eyePos = EyePos()

    for _, tr in ipairs(tracers) do
        local tier = tr.tier
        local elapsed = ct - tr.spawnTime
        local progress = math.Clamp(elapsed / tr.travelTime, 0, 1)
        local curPos = tr.currentPos or tr.startPos

        -- Base color (may shift for chromatic)
        local baseColor = tier.color
        local glowColor = tier.glowColor
        if tier.chromatic then
            baseColor = ChromaticColor(tier.color, elapsed)
            glowColor = ChromaticColor(tier.glowColor, elapsed)
        end

        -- ========================================
        -- GLOW TRAIL (beam from trail points)
        -- ========================================
        if #tr.trailPoints > 1 then
            local fadeTime = tier.lifetime or 0.2

            render.SetMaterial(matBeam)
            for j = 2, #tr.trailPoints do
                local p1 = tr.trailPoints[j - 1]
                local p2 = tr.trailPoints[j]
                local age1 = 1 - math.Clamp((ct - p1.time) / fadeTime, 0, 1)
                local age2 = 1 - math.Clamp((ct - p2.time) / fadeTime, 0, 1)

                -- Core beam
                render.DrawBeam(p1.pos, p2.pos, tier.trailWidth, 0, 1,
                    Color(baseColor.r, baseColor.g, baseColor.b, baseColor.a * age1))

                -- Outer glow
                render.DrawBeam(p1.pos, p2.pos, tier.glowWidth, 0, 1,
                    Color(glowColor.r, glowColor.g, glowColor.b, glowColor.a * age1 * 0.6))
            end

            -- Afterimage trail (Mythical)
            if tier.hasAfterimage then
                render.SetMaterial(matBeam)
                for j = 2, #tr.trailPoints do
                    local p1 = tr.trailPoints[j - 1]
                    local p2 = tr.trailPoints[j]
                    local age1 = 1 - math.Clamp((ct - p1.time) / (fadeTime * 1.8), 0, 1)

                    render.DrawBeam(p1.pos, p2.pos, tier.glowWidth * 1.5, 0, 1,
                        Color(255, 150, 50, 60 * age1))
                end
            end
        end

        -- ========================================
        -- PROJECTILE HEAD (sprite at current pos)
        -- ========================================
        if progress < 1 then
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
            -- SPIRAL PATTERN (Legendary+)
            -- ========================================
            if tier.hasSpiral then
                local spiralR = tier.spiralRadius or 3
                local spiralSpd = tier.spiralSpeed or 8
                local right = tr.dir:Angle():Right()
                local up = tr.dir:Angle():Up()

                render.SetMaterial(matFlare)
                for s = 0, 2 do
                    local angle = elapsed * spiralSpd * math.pi * 2 + s * (math.pi * 2 / 3)
                    local offset = right * math.cos(angle) * spiralR + up * math.sin(angle) * spiralR
                    local spiralPos = curPos + offset
                    local spiralCol = tier.chromatic and ChromaticColor(baseColor, elapsed + s * 0.3) or baseColor
                    render.DrawSprite(spiralPos, tier.trailWidth * 1.5, tier.trailWidth * 1.5,
                        Color(spiralCol.r, spiralCol.g, spiralCol.b, 180))
                end
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

        local col = imp.color
        if imp.tier.chromatic then
            col = ChromaticColor(col, age)
        end

        -- Flash ring expanding outward
        local ringSize = imp.size * (0.3 + life * 2)

        render.SetMaterial(matSoftGlow)
        render.DrawSprite(imp.pos + imp.normal * 1, ringSize, ringSize,
            Color(col.r, col.g, col.b, fade * 200))

        -- Core flash (bright, fast fade)
        if life < 0.3 then
            local flashFade = 1 - (life / 0.3)
            render.SetMaterial(matGlow)
            render.DrawSprite(imp.pos + imp.normal * 2, imp.size * 1.5 * flashFade, imp.size * 1.5 * flashFade,
                Color(255, 255, 255, 200 * flashFade))
        end

        -- Secondary ring (Legendary+)
        if imp.tier.impactSize and imp.tier.impactSize >= 1.5 then
            local ring2Size = imp.size * (0.1 + life * 3)
            render.SetMaterial(matRing)
            render.DrawSprite(imp.pos + imp.normal * 0.5, ring2Size, ring2Size,
                Color(col.r, col.g, col.b, fade * 100))
        end
    end
end)

-- ============================================================
-- PARTICLES: Emit from Think hook (not render hook)
-- Particles can't be created inside render contexts
-- ============================================================
hook.Add("Think", "BRS_UW_TracerParticles", function()
    local ct = CurTime()

    for _, tr in ipairs(tracers) do
        local tier = tr.tier
        if not tier.hasParticles then continue end

        local elapsed = ct - tr.spawnTime
        local progress = math.Clamp(elapsed / tr.travelTime, 0, 1)
        if progress >= 1 then continue end

        -- Throttle particle emission
        if ct - (tr.lastParticleTime or 0) < 0.02 then continue end
        tr.lastParticleTime = ct

        if math.random() > 0.6 then continue end

        local curPos = tr.currentPos or tr.startPos
        local pCol = tier.particleColor or tier.color
        if tier.chromatic then
            pCol = ChromaticColor(pCol, elapsed + math.random() * 2)
        end

        local behindPos = curPos - tr.dir * math.random(2, 8) + VectorRand() * 2
        local pType = tier.particleType or "sparks"

        local emitter = ParticleEmitter(behindPos, false)
        if not emitter then continue end

        local p = emitter:Add("sprites/light_glow02_add", behindPos)
        if p then
            p:SetDieTime(math.Rand(0.1, 0.3))
            p:SetStartAlpha(pCol.a)
            p:SetEndAlpha(0)
            p:SetColor(pCol.r, pCol.g, pCol.b)

            if pType == "sparks" then
                p:SetStartSize(math.Rand(1, 2))
                p:SetEndSize(0)
                p:SetVelocity(VectorRand() * 40)
                p:SetGravity(Vector(0, 0, -200))
            elseif pType == "energy" then
                p:SetStartSize(math.Rand(2, 4))
                p:SetEndSize(1)
                p:SetVelocity(VectorRand() * 20)
                p:SetGravity(Vector(0, 0, 50))
            elseif pType == "fire" then
                p:SetStartSize(math.Rand(2, 5))
                p:SetEndSize(0)
                p:SetVelocity(-tr.dir * 80 + VectorRand() * 30)
                p:SetGravity(Vector(0, 0, 100))
                p:SetDieTime(math.Rand(0.15, 0.4))
            elseif pType == "glitch" then
                p:SetStartSize(math.Rand(1, 3))
                p:SetEndSize(math.Rand(0, 4))
                p:SetVelocity(VectorRand() * 60)
                p:SetGravity(Vector(0, 0, 0))
                p:SetDieTime(math.Rand(0.1, 0.25))
            elseif pType == "inferno" then
                p:SetStartSize(math.Rand(3, 7))
                p:SetEndSize(0)
                p:SetVelocity(-tr.dir * 100 + VectorRand() * 50)
                p:SetGravity(Vector(0, 0, 150))
                p:SetDieTime(math.Rand(0.2, 0.5))

                -- Extra smoke particle
                local smoke = emitter:Add("particle/particle_smokegrenade", behindPos)
                if smoke then
                    smoke:SetDieTime(math.Rand(0.3, 0.6))
                    smoke:SetStartAlpha(40)
                    smoke:SetEndAlpha(0)
                    smoke:SetColor(80, 30, 10)
                    smoke:SetStartSize(math.Rand(2, 4))
                    smoke:SetEndSize(math.Rand(6, 10))
                    smoke:SetVelocity(-tr.dir * 40 + VectorRand() * 20)
                    smoke:SetGravity(Vector(0, 0, 80))
                    smoke:SetRoll(math.Rand(0, 360))
                    smoke:SetRollDelta(math.Rand(-2, 2))
                end
            end
        end
        emitter:Finish()
    end
end)

print("[BRS UW] Tracer client renderer loaded")
