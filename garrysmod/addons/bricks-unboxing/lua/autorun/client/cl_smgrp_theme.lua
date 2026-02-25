-- ============================================================
-- SmG RP - Custom Unboxing UI Theme
-- Tactical dark aesthetic with teal/amber accents
-- ============================================================

SMGRP = SMGRP or {}
SMGRP.UI = SMGRP.UI or {}

-- ============================================================
-- COLOR PALETTE
-- ============================================================
SMGRP.UI.Colors = {
    -- Backgrounds (darkest to lightest)
    bg_darkest   = Color(12, 12, 18),        -- near-black for deepest bg
    bg_dark      = Color(18, 18, 26),        -- main panel background
    bg_mid       = Color(26, 27, 35),        -- card backgrounds
    bg_light     = Color(34, 36, 46),        -- elevated surfaces
    bg_lighter   = Color(44, 46, 58),        -- hover states / active items
    bg_input     = Color(22, 23, 30),        -- input field background

    -- Borders / Dividers
    border       = Color(50, 52, 65),        -- subtle borders
    border_light = Color(65, 68, 82),        -- lighter borders for emphasis
    divider      = Color(38, 40, 50),        -- section dividers

    -- Text
    text_primary   = Color(220, 222, 230),   -- main text
    text_secondary = Color(140, 144, 160),   -- secondary / muted text
    text_muted     = Color(90, 94, 110),     -- very muted / disabled text
    text_white     = Color(255, 255, 255),   -- pure white for emphasis

    -- Primary accent (teal/cyan)
    accent         = Color(0, 212, 170),     -- main accent
    accent_dim     = Color(0, 160, 128),     -- dimmed accent
    accent_bg      = Color(0, 212, 170, 15), -- very subtle accent for backgrounds
    accent_hover   = Color(0, 235, 190),     -- bright hover

    -- Secondary accent (warm amber)
    amber          = Color(255, 185, 50),
    amber_dim      = Color(200, 145, 35),

    -- Feedback colors
    red            = Color(220, 60, 60),
    red_dim        = Color(160, 40, 40),
    red_bg         = Color(220, 60, 60, 20),
    green          = Color(60, 200, 120),
    green_dim      = Color(40, 150, 90),
    blue           = Color(70, 140, 255),

    -- Rarity-specific (for unique weapon borders)
    rarity_common    = Color(160, 165, 175),
    rarity_uncommon  = Color(100, 200, 75),
    rarity_rare      = Color(50, 140, 230),
    rarity_epic      = Color(155, 70, 255),
    rarity_legendary = Color(255, 170, 20),
    rarity_glitched  = Color(0, 255, 210),
    rarity_mythical  = Color(255, 50, 50),
}

local C = SMGRP.UI.Colors -- shorthand

-- ============================================================
-- FONTS
-- ============================================================
local function CreateFonts()
    local fonts = {
        -- Headers
        { name = "SMGRP_Title",     size = 28, weight = 700 },
        { name = "SMGRP_Header",    size = 22, weight = 700 },
        { name = "SMGRP_SubHeader", size = 18, weight = 600 },

        -- Body text
        { name = "SMGRP_Body16",    size = 16, weight = 500 },
        { name = "SMGRP_Body14",    size = 14, weight = 500 },
        { name = "SMGRP_Body13",    size = 13, weight = 500 },
        { name = "SMGRP_Body12",    size = 12, weight = 500 },

        -- Bold variants
        { name = "SMGRP_Bold16",    size = 16, weight = 700 },
        { name = "SMGRP_Bold14",    size = 14, weight = 700 },
        { name = "SMGRP_Bold13",    size = 13, weight = 700 },
        { name = "SMGRP_Bold12",    size = 12, weight = 700 },
        { name = "SMGRP_Bold11",    size = 11, weight = 700 },
        { name = "SMGRP_Bold10",    size = 10, weight = 700 },

        -- Numbers / Stats
        { name = "SMGRP_Stat48",    size = 48, weight = 800 },
        { name = "SMGRP_Stat32",    size = 32, weight = 800 },
        { name = "SMGRP_Stat20",    size = 20, weight = 700 },

        -- Tiny
        { name = "SMGRP_Tiny9",     size = 9,  weight = 600 },
        { name = "SMGRP_Tiny8",     size = 8,  weight = 600 },
    }

    for _, f in ipairs(fonts) do
        surface.CreateFont(f.name, {
            font = "Montserrat",
            size = f.size,
            weight = f.weight,
            antialias = true,
        })
        -- Fallback if Montserrat not installed
        surface.CreateFont(f.name .. "_FB", {
            font = "Segoe UI",
            size = f.size,
            weight = f.weight,
            antialias = true,
        })
    end
end
CreateFonts()

-- ============================================================
-- DRAWING HELPERS
-- ============================================================

-- Draw a panel with optional border
function SMGRP.UI.DrawPanel(x, y, w, h, bgColor, borderColor, radius)
    radius = radius or 6
    draw.RoundedBox(radius, x, y, w, h, bgColor or C.bg_mid)
    if borderColor then
        -- 1px border overlay
        surface.SetDrawColor(borderColor)
        -- Top
        surface.DrawRect(x + radius, y, w - radius*2, 1)
        -- Bottom
        surface.DrawRect(x + radius, y + h - 1, w - radius*2, 1)
        -- Left
        surface.DrawRect(x, y + radius, 1, h - radius*2)
        -- Right
        surface.DrawRect(x + w - 1, y + radius, 1, h - radius*2)
    end
end

-- Horizontal gradient fill
function SMGRP.UI.DrawGradientH(x, y, w, h, colLeft, colRight)
    surface.SetDrawColor(colLeft)
    surface.DrawRect(x, y, w, h)
    local steps = math.min(w, 32)
    local stepW = w / steps
    for i = 0, steps - 1 do
        local frac = i / steps
        local r = Lerp(frac, colLeft.r, colRight.r)
        local g = Lerp(frac, colLeft.g, colRight.g)
        local b = Lerp(frac, colLeft.b, colRight.b)
        local a = Lerp(frac, colLeft.a or 255, colRight.a or 255)
        surface.SetDrawColor(r, g, b, a)
        surface.DrawRect(x + i * stepW, y, stepW + 1, h)
    end
end

-- Vertical gradient fill
function SMGRP.UI.DrawGradientV(x, y, w, h, colTop, colBottom)
    local steps = math.min(h, 32)
    local stepH = h / steps
    for i = 0, steps - 1 do
        local frac = i / steps
        local r = Lerp(frac, colTop.r, colBottom.r)
        local g = Lerp(frac, colTop.g, colBottom.g)
        local b = Lerp(frac, colTop.b, colBottom.b)
        local a = Lerp(frac, colTop.a or 255, colBottom.a or 255)
        surface.SetDrawColor(r, g, b, a)
        surface.DrawRect(x, y + i * stepH, w, stepH + 1)
    end
end

-- Stat bar with glow effect
function SMGRP.UI.DrawStatBar(x, y, w, h, fraction, color, showGlow)
    -- Background track
    draw.RoundedBox(2, x, y, w, h, Color(10, 10, 15, 200))

    -- Fill
    local fillW = math.Clamp(fraction, 0, 1) * w
    if fillW > 2 then
        draw.RoundedBox(2, x, y, fillW, h, color)

        -- Subtle inner highlight on top half
        if h >= 4 then
            surface.SetDrawColor(255, 255, 255, 30)
            surface.DrawRect(x + 1, y, fillW - 2, math.floor(h / 2))
        end
    end
end

-- Get rarity color from our palette
function SMGRP.UI.GetRarityColor(rarityKey)
    local map = {
        Common = C.rarity_common,
        Uncommon = C.rarity_uncommon,
        Rare = C.rarity_rare,
        Epic = C.rarity_epic,
        Legendary = C.rarity_legendary,
        Glitched = C.rarity_glitched,
        Mythical = C.rarity_mythical,
    }
    return map[rarityKey] or C.rarity_common
end

-- Animated glowing border for high-tier items
SMGRP.UI._glowPhase = 0
hook.Add("Think", "SMGRP_UI_AnimPhase", function()
    SMGRP.UI._glowPhase = (SMGRP.UI._glowPhase + FrameTime() * 2) % (math.pi * 2)
end)

function SMGRP.UI.GetGlowAlpha()
    return 160 + math.sin(SMGRP.UI._glowPhase) * 60
end

-- Rainbow cycle for Glitched rarity
function SMGRP.UI.GetGlitchedColor()
    local t = CurTime() * 0.8
    return Color(
        128 + math.sin(t) * 127,
        128 + math.sin(t + 2.094) * 127,
        128 + math.sin(t + 4.189) * 127
    )
end

-- Hot cycle for Mythical rarity  
function SMGRP.UI.GetMythicalColor()
    local t = CurTime() * 1.2
    return Color(
        200 + math.sin(t) * 55,
        30 + math.abs(math.sin(t * 0.7)) * 50,
        30
    )
end

print("[SmG RP] Custom UI theme loaded")
