--[[

Author: tochnonement
Email: tochnonement@gmail.com

17/08/2024

--]]

onyx.hud.fonts = onyx.hud.fonts or {}

local function font2D( name, size, postfix )
    local family = 'Comfortaa'
    local finalFont = family
    local scaleInt = onyx.hud.GetScale()
    local updatedSize = math.ceil( ( size * scaleInt ) / 900 * ScrH() )
    local fontName = 'onyx.hud.' .. name

    if ( postfix ) then
        finalFont = finalFont .. ' ' .. postfix
    end

    surface.CreateFont( fontName, {
        font = finalFont,
        size = updatedSize,
        extended = true
    } )
    
    onyx.hud.fonts[ name ] = fontName
end

local function font3D2D( name, family, size )
    local realName = 'onyx.hud.' .. name

    surface.CreateFont( realName, {
        font = family,
        size = size,
        extended = true
    } )

    surface.CreateFont( realName .. '.Blur', {
        font = family,
        size = size,
        blursize = 2,
        extended = true
    } )

    return realName
end
onyx.hud.CreateFont3D2D = font3D2D

function onyx.hud.BuildFonts()
    onyx.hud.builtFonts = true

    font2D( 'ExtraTiny', 14 )
    font2D( 'ExtraTinyBold', 14, 'Bold' )

    font2D( 'Tiny', 16 )
    font2D( 'TinyBold', 16, 'Bold' )

    font2D( 'Small', 18 )
    font2D( 'SmallBold', 18, 'Bold' )

    font2D( 'Medium', 22 )
    font2D( 'MediumBold', 22, 'Bold' )

    font2D( 'Big', 28 )
    font2D( 'BigBold', 28, 'Bold' )

    font2D( 'Name', 20, 'Bold' )
    font2D( 'AmmoClip', 40, 'Bold' )
    font2D( 'AmmoRemaining', 28 )

    font2D( 'Speedometer', 80 )
end

onyx.WaitForGamemode( 'onyx.hud.BuildFonts', onyx.hud.BuildFonts )