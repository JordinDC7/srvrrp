--[[

Author: tochnonement
Email: tochnonement@gmail.com

21/08/2024

--]]

onyx.hud.levelling = onyx.hud.levelling or {}

local function validateDataValue( data, key )
    assert( data[ key ], Format( '`onyx.hud.RegisterLevelSystem` bad data (missing value for \'%s\')', key ) )
    assert( isfunction( data[ key ] ), Format( '`onyx.hud.RegisterLevelSystem` bad data (the value should be function \'%s\')', type( data ), key ) )
end

function onyx.hud.RegisterLevelSystem( id, data )
    assert( isstring( id ), Format( '`onyx.hud.RegisterLevelSystem` bad argument #1 (expected string, got %s)', type( id ) ) )
    assert( istable( data ), Format( '`onyx.hud.RegisterLevelSystem` bad argument #2 (expected table, got %s)', type( data ) ) )
    validateDataValue( data, 'getLevel' )
    validateDataValue( data, 'getMaxXP' )
    validateDataValue( data, 'getXP' )
    validateDataValue( data, 'customCheck' )

    data.id = id
    onyx.hud.levelling[ id ] = data
end

function onyx.hud.IsLevellingEnabled()
    return ( onyx.hud.levelSystem ~= nil )
end

function onyx.hud.GetLevelData( client )
    local sysTable = onyx.hud.levelSystem
    if ( sysTable ) then
        local level = math.Round( sysTable.getLevel( client ) )
        local maxXP = math.Round( sysTable.getMaxXP( client ) )
        local xp = math.Round( sysTable.getXP( client ) )

        return level, xp, maxXP
    end
end

onyx.WaitForGamemode( 'onyx.hud.CheckLevelSystem', function()
    for sysID, sysTable in pairs( onyx.hud.levelling ) do
        if ( sysTable.customCheck() ) then
            if ( not sysTable.detected and sysTable.onDetected ) then
                sysTable.detected = true
                sysTable.onDetected()
            end

            onyx.hud.levelSystem = sysTable
        end
    end
end )