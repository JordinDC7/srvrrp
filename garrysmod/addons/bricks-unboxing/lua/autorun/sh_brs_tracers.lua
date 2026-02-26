-- ============================================================
-- BRS Unique Weapons - Tracer System (Shared Definitions)
-- Visual projectile tracers + impact effects per rarity tier
-- ============================================================

BRS_UW = BRS_UW or {}
BRS_UW.Tracers = BRS_UW.Tracers or {}

-- ============================================================
-- TRACER TIERS (tied to rarity)
-- Each tier has a DISTINCT visual identity
-- ============================================================
BRS_UW.Tracers.Tiers = {
    -- ==========================================
    -- COMMON: Plain warm tracer, nothing fancy
    -- ==========================================
    Common = {
        color = Color(220, 220, 180, 255),
        glowColor = Color(255, 250, 200, 80),
        trailWidth = 2,
        glowWidth = 6,
        speed = 8000,
        lifetime = 0.15,
        hasParticles = false,
        hasImpact = false,
        hasSpiral = false,
        description = "Standard tracer",
    },

    -- ==========================================
    -- UNCOMMON: Green tracer with small impact
    -- ==========================================
    Uncommon = {
        color = Color(120, 220, 80, 255),
        glowColor = Color(80, 255, 60, 100),
        trailWidth = 2.5,
        glowWidth = 8,
        speed = 9000,
        lifetime = 0.2,
        hasParticles = false,
        hasImpact = true,
        impactColor = Color(100, 255, 80, 200),
        hasSpiral = false,
        description = "Green tracer",
    },

    -- ==========================================
    -- RARE: Blue electric with spark particles
    -- ==========================================
    Rare = {
        color = Color(42, 160, 255, 255),
        glowColor = Color(30, 120, 255, 120),
        trailWidth = 3,
        glowWidth = 10,
        speed = 10000,
        lifetime = 0.25,
        hasParticles = true,
        particleColor = Color(80, 180, 255, 200),
        particleType = "sparks",
        hasImpact = true,
        impactColor = Color(40, 140, 255, 220),
        hasSpiral = false,
        description = "Electric blue tracer",
    },

    -- ==========================================
    -- EPIC: Purple energy with wisp particles
    -- ==========================================
    Epic = {
        color = Color(180, 80, 255, 255),
        glowColor = Color(152, 68, 255, 140),
        trailWidth = 3.5,
        glowWidth = 12,
        speed = 11000,
        lifetime = 0.3,
        hasParticles = true,
        particleColor = Color(200, 120, 255, 220),
        particleType = "energy",
        hasImpact = true,
        impactColor = Color(170, 80, 255, 240),
        impactSize = 1.2,
        hasSpiral = false,
        description = "Arcane energy tracer",
    },

    -- ==========================================
    -- LEGENDARY: Golden comet / meteor
    -- Warm gold trail with fire ember shower
    -- Feels like a shooting star blazing through
    -- ==========================================
    Legendary = {
        color = Color(255, 200, 40, 255),
        glowColor = Color(255, 140, 0, 180),
        trailWidth = 4,
        glowWidth = 16,
        speed = 12000,
        lifetime = 0.4,
        hasParticles = true,
        particleColor = Color(255, 180, 30, 240),
        particleType = "comet",
        hasImpact = true,
        impactColor = Color(255, 170, 20, 255),
        impactSize = 1.8,
        hasSpiral = true,
        spiralRadius = 3,
        spiralSpeed = 6,
        hasAfterimage = true,
        afterimageColor = Color(255, 100, 0, 50),
        description = "Golden comet",
    },

    -- ==========================================
    -- GLITCHED: Digital corruption / matrix
    -- Trail flickers and teleports, scan-lines
    -- Cyan<->Magenta rapid shift, pixelated
    -- Completely different visual language
    -- ==========================================
    Glitched = {
        color = Color(0, 255, 220, 255),
        color2 = Color(255, 0, 200, 255),
        glowColor = Color(0, 255, 180, 160),
        trailWidth = 3,
        glowWidth = 14,
        speed = 15000,
        lifetime = 0.3,
        hasParticles = true,
        particleColor = Color(0, 255, 220, 240),
        particleType = "glitch",
        hasImpact = true,
        impactColor = Color(0, 255, 200, 255),
        impactSize = 1.6,
        hasSpiral = false,
        glitchTrail = true,
        scanLines = true,
        chromatic = true,
        description = "Digital corruption",
    },

    -- ==========================================
    -- MYTHICAL: Void reaper / dark energy
    -- Dark crimson core with black void aura
    -- Trail tears through reality, ominous + heavy
    -- Completely different from Legendary
    -- ==========================================
    Mythical = {
        color = Color(200, 0, 0, 255),
        color2 = Color(40, 0, 40, 255),
        glowColor = Color(150, 0, 0, 200),
        trailWidth = 5,
        glowWidth = 22,
        speed = 10000,
        lifetime = 0.6,
        hasParticles = true,
        particleColor = Color(180, 20, 20, 255),
        particleType = "void",
        hasImpact = true,
        impactColor = Color(200, 0, 0, 255),
        impactSize = 2.5,
        hasSpiral = false,
        voidTrail = true,
        voidCore = true,
        hasAfterimage = true,
        afterimageColor = Color(60, 0, 0, 80),
        description = "Void reaper",
    },
}

-- ============================================================
-- ASCENDED OVERLAY (applied ON TOP of rarity tier)
-- Only on Ascended quality weapons (Glitched/Mythical rarity)
-- Makes the weapon unmistakably divine
-- ============================================================
BRS_UW.Tracers.AscendedOverlay = {
    hasLightning = true,
    lightningColor = Color(255, 230, 100, 220),
    lightningArcCount = 3,
    lightningRange = 12,

    hasHalo = true,
    haloColor = Color(255, 215, 0, 180),
    haloRadius = 8,

    hasDivineRays = true,
    rayColor = Color(255, 240, 150, 120),
    rayCount = 6,

    hasGoldenShower = true,
    showerColor = Color(255, 220, 80, 200),

    impactPillar = true,
    pillarColor = Color(255, 230, 100, 200),
    pillarHeight = 120,

    description = "Divine wrath",
}

-- Get tracer tier for a rarity
function BRS_UW.Tracers.GetTier(rarityKey)
    return BRS_UW.Tracers.Tiers[rarityKey] or BRS_UW.Tracers.Tiers["Common"]
end

-- Check if weapon is ascended
function BRS_UW.Tracers.IsAscended(quality)
    return quality == "Ascended"
end

print("[BRS UW] Tracer definitions loaded")
