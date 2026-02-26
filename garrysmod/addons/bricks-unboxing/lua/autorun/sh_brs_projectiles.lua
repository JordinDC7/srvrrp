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
        color = Color(220, 220, 180, 255), glowColor = Color(255, 250, 200, 80),
        trailWidth = 2, glowWidth = 6, lifetime = 0.15,
        hasParticles = false, hasImpact = false,
        description = "Standard tracer",
    },
    Uncommon = {
        color = Color(120, 220, 80, 255), glowColor = Color(80, 255, 60, 100),
        trailWidth = 2.5, glowWidth = 8, lifetime = 0.2,
        hasParticles = false,
        hasImpact = true, impactColor = Color(100, 255, 80, 200),
        description = "Green tracer",
    },
    Rare = {
        color = Color(42, 160, 255, 255), glowColor = Color(30, 120, 255, 120),
        trailWidth = 3, glowWidth = 10, lifetime = 0.25,
        hasParticles = true, particleColor = Color(80, 180, 255, 200), particleType = "sparks",
        hasImpact = true, impactColor = Color(40, 140, 255, 220),
        description = "Electric blue tracer",
    },
    Epic = {
        color = Color(180, 80, 255, 255), glowColor = Color(152, 68, 255, 140),
        trailWidth = 3.5, glowWidth = 12, lifetime = 0.3,
        hasParticles = true, particleColor = Color(200, 120, 255, 220), particleType = "energy",
        hasImpact = true, impactColor = Color(170, 80, 255, 240), impactSize = 1.2,
        description = "Arcane energy tracer",
    },
    Legendary = {
        color = Color(255, 200, 40, 255), glowColor = Color(255, 140, 0, 180),
        trailWidth = 4, glowWidth = 16, lifetime = 0.4,
        hasParticles = true, particleColor = Color(255, 180, 30, 240), particleType = "comet",
        hasImpact = true, impactColor = Color(255, 170, 20, 255), impactSize = 1.8,
        hasSpiral = true, spiralRadius = 3, spiralSpeed = 6,
        hasAfterimage = true, afterimageColor = Color(255, 100, 0, 50),
        description = "Golden comet",
    },
    Glitched = {
        color = Color(0, 255, 220, 255), color2 = Color(255, 0, 200, 255),
        glowColor = Color(0, 255, 180, 160),
        trailWidth = 3, glowWidth = 14, lifetime = 0.3,
        hasParticles = true, particleColor = Color(0, 255, 220, 240), particleType = "glitch",
        hasImpact = true, impactColor = Color(0, 255, 200, 255), impactSize = 1.6,
        glitchTrail = true, chromatic = true,
        description = "Digital corruption",
    },
    Mythical = {
        color = Color(200, 0, 0, 255), color2 = Color(40, 0, 40, 255),
        glowColor = Color(150, 0, 0, 200),
        trailWidth = 5, glowWidth = 22, lifetime = 0.55,
        hasParticles = true, particleColor = Color(180, 20, 20, 255), particleType = "void",
        hasImpact = true, impactColor = Color(200, 0, 0, 255), impactSize = 2.5,
        voidTrail = true, voidCore = true,
        hasAfterimage = true, afterimageColor = Color(60, 0, 0, 80),
        description = "Void reaper",
    },
}

BRS_UW.Tracers.AscendedOverlay = {
    hasLightning = true, lightningColor = Color(255, 230, 100, 220), lightningRange = 12,
    hasHalo = true, haloColor = Color(255, 215, 0, 180), haloRadius = 8,
    hasDivineRays = true, rayColor = Color(255, 240, 150, 120), rayCount = 6,
    hasGoldenShower = true, showerColor = Color(255, 220, 80, 200),
    impactPillar = true, pillarColor = Color(255, 230, 100, 200), pillarHeight = 120,
    description = "Divine wrath",
}

function BRS_UW.Tracers.GetTier(rarityKey)
    return BRS_UW.Tracers.Tiers[rarityKey] or BRS_UW.Tracers.Tiers["Common"]
end

print("[BRS UW] Projectile + tracer definitions loaded")
