--[[

Author: tochnonement
Email: tochnonement@gmail.com

21/08/2024

--]]

--[[
    ***************
      WARNING
      This configuration is intended for advanced users familiar with Lua scripting. 
      Modifying this file without proper knowledge may result in unintended behavior or instability.
    ***************
]]

onyx.hud:CreateTheme( 'default', {
    colors = {
        primary = onyx:Config( 'colors.primary' ),
        secondary = onyx:Config( 'colors.secondary' ),
        tertiary = onyx:Config( 'colors.tertiary' ),
        accent = onyx:Config( 'colors.accent' ),
    }
} )

onyx.hud:CreateTheme( 'gray', {
    colors = {
        primary = Color( 172, 172, 172),
        secondary = Color( 197, 197, 197),
        tertiary = Color( 225, 225, 225),
        accent = Color( 101, 40, 206),
    }
} )

onyx.hud:CreateTheme( 'golden_dawn', {
    colors = {
        primary = Color( 195, 189, 154),
        secondary = Color( 224, 207, 143),
        tertiary = Color( 230, 205, 129),
        accent = Color( 44, 44, 255),
        textPrimary = Color( 40, 35, 19),
        textSecondary = Color( 59, 50, 14),
        textTertiary = Color( 90, 83, 53),
    }
} )

onyx.hud:CreateTheme( 'sky_blue', {
    colors = {
        primary = Color(186, 227, 252),
        secondary = Color(210, 235, 255),
        tertiary = Color(232, 243, 255),
        accent = Color(0, 89, 255),
        textPrimary = Color(25, 45, 60),
        textSecondary = Color(50, 75, 100),
        textTertiary = Color(80, 110, 140),
    }
} )

onyx.hud:CreateTheme( 'mint_light', {
    colors = {
        primary = Color(202, 230, 217),
        secondary = Color(223, 241, 232),
        tertiary = Color(240, 250, 244),
        accent = Color(0, 162, 78),
        textPrimary = Color(34, 52, 42),
        textSecondary = Color(57, 82, 69),
        textTertiary = Color(92, 118, 104),
    }
} )

onyx.hud:CreateTheme( 'lavender', {
    colors = {
        primary = Color(230, 230, 250),
        secondary = Color(245, 245, 255),
        tertiary = Color(255, 250, 255),
        accent = Color(138, 43, 226),
        textPrimary = Color(50, 50, 80),
        textSecondary = Color(70, 70, 100),
        textTertiary = Color(100, 100, 130),
    }
} )

onyx.hud:CreateTheme( 'green_apple', {
    colors = {
        primary = Color(144, 238, 144),
        secondary = Color(168, 255, 168),
        tertiary = Color(192, 255, 192),
        accent = Color(218, 24, 24),  -- Насыщенный зеленый
        textPrimary = Color(40, 70, 40),
        textSecondary = Color(60, 90, 60),
        textTertiary = Color(90, 120, 90),
    }
} )

onyx.hud:CreateTheme( 'elegance', {
    colors = {
        primary = Color(34, 40, 48),
        secondary = Color(32, 36, 42),
        tertiary = Color(40, 45, 53),
        accent = Color(60, 179, 113),
    }
} )

onyx.hud:CreateTheme( 'ocean_wave', {
    colors = {
        primary = Color(24, 32, 44),
        secondary = Color(30, 40, 52),
        tertiary = Color(37, 50, 61),
        quaternary = Color(24, 32, 44),
        accent = Color(70, 130, 180),
    }
} )

onyx.hud:CreateTheme( 'violet_night', {
    colors = {
        primary = Color(48, 25, 52),
        secondary = Color(58, 31, 63),
        tertiary = Color(72, 40, 78),
        quaternary = Color(48, 25, 52),
        accent = Color(186, 85, 211),
    }
} )

onyx.hud:CreateTheme( 'forest', {
    colors = {
        primary = Color(34, 44, 34),
        secondary = Color(42, 54, 42),
        tertiary = Color(50, 64, 50),
        quaternary = Color(34, 44, 34),
        accent = Color(152, 251, 152),
    }
} )

onyx.hud:CreateTheme( 'rose_garden', {
    colors = {
        primary = Color(44, 24, 34),
        secondary = Color(52, 28, 42),
        tertiary = Color(61, 33, 50),
        quaternary = Color(44, 24, 34),
        accent = Color(255, 105, 180),
    }
} )

onyx.hud:CreateTheme( 'rustic_ember', {
    colors = {
        primary = Color(44, 29, 24),
        secondary = Color(52, 34, 29),
        tertiary = Color(61, 40, 34),
        quaternary = Color(44, 29, 24),
        accent = Color(255, 99, 71),
    }
} )