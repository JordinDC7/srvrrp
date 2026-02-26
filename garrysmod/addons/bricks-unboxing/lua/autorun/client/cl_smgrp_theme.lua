-- ============================================================
-- SmG RP - Custom Unboxing UI Theme
-- Tactical dark aesthetic with teal/amber accents
-- PERF: All colors pre-allocated. No per-call table/Color allocs.
-- ============================================================

SMGRP = SMGRP or {}
SMGRP.UI = SMGRP.UI or {}

-- ============================================================
-- COLOR PALETTE (all pre-allocated once)
-- ============================================================
SMGRP.UI.Colors = {
    bg_darkest   = Color(12, 12, 18),
    bg_dark      = Color(18, 18, 26),
    bg_mid       = Color(26, 27, 35),
    bg_light     = Color(34, 36, 46),
    bg_lighter   = Color(44, 46, 58),
    bg_input     = Color(22, 23, 30),

    border       = Color(50, 52, 65),
    border_light = Color(65, 68, 82),
    divider      = Color(38, 40, 50),

    text_primary   = Color(220, 222, 230),
    text_secondary = Color(140, 144, 160),
    text_muted     = Color(90, 94, 110),
    text_white     = Color(255, 255, 255),

    accent         = Color(0, 212, 170),
    accent_dim     = Color(0, 160, 128),
    accent_bg      = Color(0, 212, 170, 15),
    accent_hover   = Color(0, 235, 190),

    amber          = Color(255, 185, 50),
    amber_dim      = Color(200, 145, 35),

    red            = Color(220, 60, 60),
    red_dim        = Color(160, 40, 40),
    red_bg         = Color(220, 60, 60, 20),
    green          = Color(60, 200, 120),
    green_dim      = Color(40, 150, 90),
    blue           = Color(70, 140, 255),

    rarity_common    = Color(160, 165, 175),
    rarity_uncommon  = Color(100, 200, 75),
    rarity_rare      = Color(50, 140, 230),
    rarity_epic      = Color(155, 70, 255),
    rarity_legendary = Color(255, 170, 20),
    rarity_glitched  = Color(32, 255, 32),
    rarity_mythical  = Color(255, 50, 50),
}

local C = SMGRP.UI.Colors

-- ============================================================
-- FONTS
-- ============================================================
local function CreateFonts()
    local fonts = {
        { name = "SMGRP_Title",     size = 30, weight = 700 },
        { name = "SMGRP_Header",    size = 24, weight = 700 },
        { name = "SMGRP_SubHeader", size = 20, weight = 600 },
        { name = "SMGRP_Body16",    size = 18, weight = 500 },
        { name = "SMGRP_Body14",    size = 16, weight = 500 },
        { name = "SMGRP_Body13",    size = 15, weight = 500 },
        { name = "SMGRP_Body12",    size = 14, weight = 500 },
        { name = "SMGRP_Bold16",    size = 18, weight = 700 },
        { name = "SMGRP_Bold14",    size = 16, weight = 700 },
        { name = "SMGRP_Bold13",    size = 15, weight = 700 },
        { name = "SMGRP_Bold12",    size = 14, weight = 700 },
        { name = "SMGRP_Bold11",    size = 13, weight = 700 },
        { name = "SMGRP_Bold10",    size = 12, weight = 700 },
        { name = "SMGRP_Stat48",    size = 50, weight = 800 },
        { name = "SMGRP_Stat32",    size = 34, weight = 800 },
        { name = "SMGRP_Stat20",    size = 22, weight = 700 },
        { name = "SMGRP_Tiny9",     size = 11, weight = 600 },
        { name = "SMGRP_Tiny8",     size = 10, weight = 600 },
    }

    for _, f in ipairs(fonts) do
        surface.CreateFont(f.name, {
            font = "Montserrat", size = f.size, weight = f.weight, antialias = true,
        })
        surface.CreateFont(f.name .. "_FB", {
            font = "Segoe UI", size = f.size, weight = f.weight, antialias = true,
        })
    end
end
CreateFonts()

-- ============================================================
-- DRAWING HELPERS
-- ============================================================

function SMGRP.UI.DrawPanel(x, y, w, h, bgColor, borderColor, radius)
    radius = radius or 6
    draw.RoundedBox(radius, x, y, w, h, bgColor or C.bg_mid)
    if borderColor then
        surface.SetDrawColor(borderColor)
        surface.DrawRect(x + radius, y, w - radius * 2, 1)
        surface.DrawRect(x + radius, y + h - 1, w - radius * 2, 1)
        surface.DrawRect(x, y + radius, 1, h - radius * 2)
        surface.DrawRect(x + w - 1, y + radius, 1, h - radius * 2)
    end
end

-- Horizontal gradient (capped at 32 steps)
function SMGRP.UI.DrawGradientH(x, y, w, h, colLeft, colRight)
    surface.SetDrawColor(colLeft)
    surface.DrawRect(x, y, w, h)
    local steps = math.min(w, 32)
    local stepW = w / steps
    for i = 0, steps - 1 do
        local frac = i / steps
        surface.SetDrawColor(
            Lerp(frac, colLeft.r, colRight.r),
            Lerp(frac, colLeft.g, colRight.g),
            Lerp(frac, colLeft.b, colRight.b),
            Lerp(frac, colLeft.a or 255, colRight.a or 255)
        )
        surface.DrawRect(x + i * stepW, y, stepW + 1, h)
    end
end

function SMGRP.UI.DrawGradientV(x, y, w, h, colTop, colBottom)
    local steps = math.min(h, 32)
    local stepH = h / steps
    for i = 0, steps - 1 do
        local frac = i / steps
        surface.SetDrawColor(
            Lerp(frac, colTop.r, colBottom.r),
            Lerp(frac, colTop.g, colBottom.g),
            Lerp(frac, colTop.b, colBottom.b),
            Lerp(frac, colTop.a or 255, colBottom.a or 255)
        )
        surface.DrawRect(x, y + i * stepH, w, stepH + 1)
    end
end

-- Pre-alloc stat bar background color (was creating Color() every call)
local _statBarBg = Color(10, 10, 15, 200)
local _statBarHighlight = Color(255, 255, 255, 30)

function SMGRP.UI.DrawStatBar(x, y, w, h, fraction, color, showGlow)
    draw.RoundedBox(2, x, y, w, h, _statBarBg)
    local fillW = math.Clamp(fraction, 0, 1) * w
    if fillW > 2 then
        draw.RoundedBox(2, x, y, fillW, h, color)
        if h >= 4 then
            surface.SetDrawColor(_statBarHighlight)
            surface.DrawRect(x + 1, y, fillW - 2, math.floor(h / 2))
        end
    end
end

-- Pre-built rarity color map (was creating a new table EVERY call)
local _rarityColorMap = {
    Common = C.rarity_common,
    Uncommon = C.rarity_uncommon,
    Rare = C.rarity_rare,
    Epic = C.rarity_epic,
    Legendary = C.rarity_legendary,
    Glitched = C.rarity_glitched,
    Mythical = C.rarity_mythical,
}

function SMGRP.UI.GetRarityColor(rarityKey)
    return _rarityColorMap[rarityKey] or C.rarity_common
end

-- Animated glow (no Think hook, uses CurTime directly)
function SMGRP.UI.GetGlowAlpha()
    return 160 + math.sin(CurTime() * 2) * 60
end

-- Reuses pre-allocated color objects
local _glitchCol = Color(32, 255, 32, 255)
function SMGRP.UI.GetGlitchedColor()
    local t = CurTime() * 1.5
    _glitchCol.r = 20 + math.abs(math.sin(t * 0.7)) * 20
    _glitchCol.g = 200 + math.sin(t) * 55
    _glitchCol.b = 20 + math.abs(math.sin(t * 0.5)) * 20
    return _glitchCol
end

local _mythCol = Color(200, 30, 30, 255)
function SMGRP.UI.GetMythicalColor()
    local t = CurTime() * 1.2
    _mythCol.r = 200 + math.sin(t) * 55
    _mythCol.g = 30 + math.abs(math.sin(t * 0.7)) * 50
    return _mythCol
end

print("[SmG RP] Custom UI theme loaded")
