--[[

Author: tochnonement
Email: tochnonement@gmail.com

14/08/2024

--]]

onyx.hud.themes = onyx.hud.themes or {}

local CONVAR_THEME = CreateClientConVar( 'cl_onyx_hud_theme_id', 'default', true, false )

cvars.AddChangeCallback( 'cl_onyx_hud_theme_id', function( _, _, new )
    hook.Run( 'onyx.hud.OnChangedTheme', onyx.hud:GetCurrentTheme() )
end, 'onyx.hud.internal' )

-- predefined colors
local COLORS = {
    [ 'light' ] = {
        textPrimary = color_black,
        textSecondary = Color( 45, 45, 45 ),
        textTertiary = Color( 70, 70, 70),
        negative = Color( 210, 35, 35),
        lockdown = Color( 166, 44, 44)
    },
    [ 'dark' ] = {
        textPrimary = color_white,
        textSecondary = Color( 171, 171, 171),
        textTertiary = Color( 97, 97, 97),
        negative = Color( 255, 76, 76),
        lockdown = Color( 255, 76, 76)
    }
}

function onyx.hud:GetColor( id )
    local themeTable = self:GetCurrentTheme()
    local colorsTable = themeTable.colors
    
    return ( colorsTable[ id ] )
end

function onyx.hud:GetCurrentTheme()
    if ( self:GetOptionValue( 'restrict_themes' ) ) then
        return self.themes[ 'default' ]
    else
        local themeID = CONVAR_THEME:GetString()
        return ( self.themes[ themeID ] or self.themes[ 'default' ] )
    end
end

function onyx.hud:IsDark()
    return self:GetCurrentTheme().dark
end

function onyx.hud:CreateTheme( id, data )
    local colors = data.colors
    local _, _, lightness = ColorToHSL( colors.primary )
    local isDark = lightness < .5
    local predefinedColors = COLORS[ isDark and 'dark' or 'light' ]

    data.id = id
    data.dark = isDark
    data.isDark = isDark
    
    table.Inherit( colors, predefinedColors )
    
    self.themes[ id ] = data
end
