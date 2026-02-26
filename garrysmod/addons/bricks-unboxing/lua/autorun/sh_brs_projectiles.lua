-- ============================================================
-- BRS Unique Weapons - Projectile System (Shared)
-- Bullet physics + tracer visuals
-- Hitscan FULLY suppressed. Projectile = only damage source.
-- ============================================================

BRS_UW = BRS_UW or {}
BRS_UW.Projectiles = BRS_UW.Projectiles or {}
BRS_UW.Tracers = BRS_UW.Tracers or {}

-- ============================================================
-- BULLET PHYSICS - tuned for VISIBLE trajectory + bullet drop
--
-- GRAVITY ~20% below original (was 40% reduced, added 20% back).
-- STAB stat can further reduce gravity for boosted weapons.
-- ============================================================
BRS_UW.Projectiles.Physics = {
    Pistol  = { velocity = 3000,  gravity = 640  },
    SMG     = { velocity = 4000,  gravity = 560  },
    Rifle   = { velocity = 6000,  gravity = 480  },
    Shotgun = { velocity = 2500,  gravity = 800  },
    Sniper  = { velocity = 10000, gravity = 320  },
    Heavy   = { velocity = 5000,  gravity = 560  },
}

BRS_UW.Projectiles.MAX_LIFETIME = 3.0
BRS_UW.Projectiles.MAX_DISTANCE = 25000

function BRS_UW.Projectiles.GetPhysics(category)
    return BRS_UW.Projectiles.Physics[category] or { velocity = 5000, gravity = 560 }
end

-- ============================================================
-- SHARED SIMULATION STEP (server + client identical)
-- Semi-implicit Euler: apply gravity to vel first, then move
-- ============================================================
function BRS_UW.Projectiles.Step(pos, vel, gravity, dt)
    local nz = vel.z - gravity * dt
    return Vector(pos.x + vel.x * dt, pos.y + vel.y * dt, pos.z + nz * dt),
           Vector(vel.x, vel.y, nz)
end

-- ============================================================
-- TRACER VISUAL TIERS
-- ============================================================
BRS_UW.Tracers.Tiers = {
    Common = {
        color = Color(220, 220, 180, 255), glowColor = Color(255, 250, 200, 70),
        trailWidth = 2, glowWidth = 6, lifetime = 0.14,
        hasParticles = false, hasImpact = false,
        description = "Standard tracer",
    },
    Uncommon = {
        color = Color(120, 220, 80, 255), glowColor = Color(80, 255, 60, 80),
        trailWidth = 2.5, glowWidth = 8, lifetime = 0.18,
        hasParticles = false,
        hasImpact = true, impactColor = Color(100, 255, 80, 190),
        description = "Green tracer",
    },
    Rare = {
        color = Color(42, 160, 255, 255), glowColor = Color(30, 120, 255, 90),
        trailWidth = 2.5, glowWidth = 9, lifetime = 0.22,
        hasParticles = true, particleColor = Color(80, 180, 255, 200), particleType = "sparks",
        hasImpact = true, impactColor = Color(40, 140, 255, 210),
        description = "Electric blue tracer",
    },
    Epic = {
        color = Color(180, 80, 255, 255), glowColor = Color(152, 68, 255, 100),
        trailWidth = 3, glowWidth = 10, lifetime = 0.26,
        hasParticles = true, particleColor = Color(200, 120, 255, 220), particleType = "energy",
        hasImpact = true, impactColor = Color(170, 80, 255, 230), impactSize = 1.1,
        description = "Arcane energy tracer",
    },
    Legendary = {
        color = Color(255, 200, 40, 255), glowColor = Color(255, 140, 0, 110),
        trailWidth = 3.5, glowWidth = 12, lifetime = 0.32,
        hasParticles = true, particleColor = Color(255, 180, 30, 240), particleType = "comet",
        hasImpact = true, impactColor = Color(255, 170, 20, 240), impactSize = 1.4,
        hasSpiral = true, spiralRadius = 2.5, spiralSpeed = 5,
        description = "Golden comet",
    },
    Glitched = {
        color = Color(0, 255, 200, 255), color2 = Color(0, 200, 160, 255),
        glowColor = Color(0, 220, 180, 90),
        trailWidth = 3, glowWidth = 10, lifetime = 0.28,
        hasParticles = true, particleColor = Color(0, 255, 200, 220), particleType = "glitch",
        hasImpact = true, impactColor = Color(0, 255, 200, 230), impactSize = 1.2,
        glitchTrail = true, chromatic = false,
        description = "Cyber data stream",
    },
    Mythical = {
        color = Color(190, 225, 255, 255), color2 = Color(140, 190, 255, 255),
        glowColor = Color(160, 210, 255, 130),
        trailWidth = 4, glowWidth = 16, lifetime = 0.4,
        hasParticles = true, particleColor = Color(180, 220, 255, 240), particleType = "divine",
        hasImpact = true, impactColor = Color(180, 220, 255, 250), impactSize = 2.0,
        divineTrail = true,
        description = "Heavenly radiance",
    },
}

-- Ascended adds nothing extra visually to tracers
-- The card UI handles Ascended identity (gold inner border + corner diamonds)
BRS_UW.Tracers.AscendedOverlay = {
    description = "Ascended (no tracer overlay)",
}

function BRS_UW.Tracers.GetTier(rarityKey)
    return BRS_UW.Tracers.Tiers[rarityKey] or BRS_UW.Tracers.Tiers["Common"]
end

print("[BRS UW] Projectile + tracer definitions loaded")
