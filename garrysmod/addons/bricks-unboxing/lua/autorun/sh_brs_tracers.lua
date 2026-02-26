-- ============================================================
-- BRS Unique Weapons - Tracer System (Shared Definitions)
-- Visual projectile tracers + impact effects per rarity tier
-- ============================================================

BRS_UW = BRS_UW or {}
BRS_UW.Tracers = BRS_UW.Tracers or {}

-- ============================================================
-- TRACER TIERS (tied to rarity)
-- Higher rarity = more impressive visual effects
-- ============================================================
BRS_UW.Tracers.Tiers = {
    Common = {
        color = Color(220, 220, 180, 255),       -- warm white
        glowColor = Color(255, 250, 200, 80),
        trailWidth = 2,
        glowWidth = 6,
        speed = 8000,                              -- units/sec travel speed
        lifetime = 0.15,                           -- trail fade time
        hasParticles = false,
        hasImpact = false,
        hasSpiral = false,
        description = "Standard tracer",
    },
    Uncommon = {
        color = Color(120, 220, 80, 255),          -- green
        glowColor = Color(80, 255, 60, 100),
        trailWidth = 2.5,
        glowWidth = 8,
        speed = 9000,
        lifetime = 0.2,
        hasParticles = false,
        hasImpact = true,
        impactColor = Color(100, 255, 80, 200),
        hasSpiral = false,
        description = "Green tracer with impact flash",
    },
    Rare = {
        color = Color(42, 160, 255, 255),          -- blue
        glowColor = Color(30, 120, 255, 120),
        trailWidth = 3,
        glowWidth = 10,
        speed = 10000,
        lifetime = 0.25,
        hasParticles = true,
        particleColor = Color(80, 180, 255, 200),
        particleType = "sparks",                    -- small spark particles
        hasImpact = true,
        impactColor = Color(40, 140, 255, 220),
        hasSpiral = false,
        description = "Blue tracer with sparks",
    },
    Epic = {
        color = Color(180, 80, 255, 255),          -- purple
        glowColor = Color(152, 68, 255, 140),
        trailWidth = 3.5,
        glowWidth = 12,
        speed = 11000,
        lifetime = 0.3,
        hasParticles = true,
        particleColor = Color(200, 120, 255, 220),
        particleType = "energy",                    -- energy wisps
        hasImpact = true,
        impactColor = Color(170, 80, 255, 240),
        impactSize = 1.2,
        hasSpiral = false,
        description = "Purple energy tracer",
    },
    Legendary = {
        color = Color(255, 180, 20, 255),          -- gold/orange
        glowColor = Color(255, 160, 0, 160),
        trailWidth = 4,
        glowWidth = 14,
        speed = 12000,
        lifetime = 0.35,
        hasParticles = true,
        particleColor = Color(255, 200, 40, 240),
        particleType = "fire",                      -- fire embers
        hasImpact = true,
        impactColor = Color(255, 170, 20, 255),
        impactSize = 1.5,
        hasSpiral = true,
        spiralRadius = 3,
        spiralSpeed = 8,
        description = "Golden fire tracer with spiral",
    },
    Glitched = {
        color = Color(0, 255, 200, 255),           -- cyan/teal
        glowColor = Color(0, 255, 180, 180),
        trailWidth = 4.5,
        glowWidth = 16,
        speed = 13000,
        lifetime = 0.4,
        hasParticles = true,
        particleColor = Color(0, 255, 220, 240),
        particleType = "glitch",                    -- rainbow shifting sparks
        hasImpact = true,
        impactColor = Color(0, 255, 200, 255),
        impactSize = 1.8,
        hasSpiral = true,
        spiralRadius = 4,
        spiralSpeed = 12,
        chromatic = true,                           -- color shifts over time
        description = "Chromatic glitch tracer",
    },
    Mythical = {
        color = Color(255, 50, 50, 255),           -- red/crimson
        glowColor = Color(255, 30, 30, 200),
        trailWidth = 5,
        glowWidth = 20,
        speed = 14000,
        lifetime = 0.5,
        hasParticles = true,
        particleColor = Color(255, 80, 20, 255),
        particleType = "inferno",                   -- intense fire + smoke
        hasImpact = true,
        impactColor = Color(255, 40, 20, 255),
        impactSize = 2.2,
        hasSpiral = true,
        spiralRadius = 5,
        spiralSpeed = 15,
        hasAfterimage = true,                       -- secondary fading trail
        description = "Inferno tracer with afterimage",
    },
}

-- Get tracer tier for a rarity
function BRS_UW.Tracers.GetTier(rarityKey)
    return BRS_UW.Tracers.Tiers[rarityKey] or BRS_UW.Tracers.Tiers["Common"]
end

print("[BRS UW] Tracer definitions loaded")
