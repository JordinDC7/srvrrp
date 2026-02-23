--[[

Author: tochnonement
Email: tochnonement@gmail.com

14/08/2024

--]]

-- I made this to cache calculated values for UI scaling
-- It is working cheaper than using raw functions ;P

local CONVAR = CreateClientConVar( 'cl_onyx_hud_scale', '100', true, false, 'Scale', 50, 150 )

local currentContextID
local cache = {
    [ 1 ] = {}, -- ScaleWide
    [ 2 ] = {} -- ScaleTall
}

local scale do
    local Round = math.Round
    function scale( int, method, storageIndex )
        local scaleFunc = onyx[ method ]
        local scaleInt = onyx.hud.GetScale() -- from outside

        if ( currentContextID ) then
            local cacheTable = cache[ storageIndex ]
            local cached = cacheTable[ int ]

            if ( cached ) then
                return cached
            else
                local result = Round( scaleFunc( int ) * scaleInt )
    
                cache[ storageIndex ][ int ] = result
    
                return result
            end
        else
            return Round( scaleFunc( int ) * scaleInt )
        end
    end
end

function onyx.hud.GetScale()
    return ( CONVAR:GetInt() / 100 )
end

function onyx.hud.StartScaling( contextID )
    currentContextID = contextID
end

function onyx.hud.EndScaling()
    if ( currentContextID ) then
        currentContextID = nil
    end
end

function onyx.hud.ScaleWide( int )
    return scale( int, 'ScaleWide', 1 )
end

function onyx.hud.ScaleTall( int )
    return scale( int, 'ScaleTall', 2 )
end

function onyx.hud.ResetScaleCache()
    local client = LocalPlayer()

    for index = 1, 2 do
        cache[ index ] = {}
    end

    for id, element in pairs( onyx.hud.elements ) do
        if ( element.onSizeChanged ) then
            element:onSizeChanged( client )
        end
    end
end

cvars.AddChangeCallback( 'cl_onyx_hud_scale', function( _, _, new )
    onyx.hud.ResetScaleCache()
    onyx.hud.BuildFonts()
end, 'onyx.hud.Update' )

hook.Add( 'OnScreenSizeChanged', 'onyx.hud.ResetScaleCache', function()
    onyx.hud.ResetScaleCache()
    onyx.hud.BuildFonts()
end )