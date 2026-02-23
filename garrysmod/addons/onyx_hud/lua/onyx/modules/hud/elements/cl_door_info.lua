--[[

Author: tochnonement
Email: tochnonement@gmail.com

16/08/2024

--]]

local RANGE = 400
local FONT_NAME = onyx.hud.CreateFont3D2D( 'DoorName', 'Comfortaa SemiBold', 60 )
local FONT_SMALL_NAME = onyx.hud.CreateFont3D2D( 'DoorSmallName', 'Comfortaa SemiBold', 40 )
local FONT_HELP = onyx.hud.CreateFont3D2D( 'DoorHelp', 'Comfortaa', 32 )
local COLOR_GRAY = Color( 200, 200, 200 )
local COLOR_GREEN = Color( 147, 255, 108)
local COLOR_RED = Color( 255, 87, 87)
local L = function( ... ) return onyx.lang:Get( ... ) end

local nearest = {}
local traceOut = {}
local traceIn = { output = traceOut, mask = MASK_SHOT }

local bindKey = ''

-- To get a nice string containing players' name from DarkRP
local function getPlayersStr( players, maxNames )
    local maxNames = maxNames or 2
    local result = {}
    local added = 0
    local limitExceeded = false

    for playerIndex in pairs( players ) do
        local ply = Player( playerIndex )
        if ( IsValid( ply ) ) then
            added = added + 1
            if ( added > maxNames ) then
                limitExceeded = true
                break
            end

            result[ added ] = ply:Name()
        end
    end

    local finalStr = table.concat( result, ', ' )

    if ( limitExceeded ) then
        finalStr = finalStr .. ', ...'
    end

    return finalStr 
end

local function drawInfo( ent, client )
    local screenPos = ent:LocalToWorld( ent:OBBCenter() ) + Vector( 0, 0, 16 )
    
    -- I wish I could put this in a timer, but it would look bad when the door is moving
    traceIn.start = client:GetShootPos()
    traceIn.endpos = screenPos
    traceIn.filter = client
    util.TraceLine( traceIn )

    if ( traceOut.Entity ~= ent ) then return end

    local hitPos = traceOut.HitPos
    local hitNormal = traceOut.HitNormal
    local length = ( hitPos - screenPos ):Length2D()

    if ( length > 6 ) then return end

    local renderPos = hitPos + hitNormal
    local renderAng = hitNormal:Angle() + Angle( 0, 90, 90 )

    local doorTeams = ent:getKeysDoorTeams()
    local doorGroup = ent:getKeysDoorGroup()
    local doorCoowners = ent:getKeysCoOwners() or {}
    local doorPrice = GAMEMODE.Config.doorcost ~= 0 and GAMEMODE.Config.doorcost or 30
    local playerOwned = ent:isKeysOwned() or table.GetFirstValue( doorCoowners ) ~= nil
    local isOwned = playerOwned or doorGroup or doorTeams
    local allowedCoOwn = ent:getKeysAllowedToOwn()

    local title = ''
    local subtitle = ''
    local color = color_white
    local titleFont = FONT_NAME

    if ( isOwned ) then
        local doorOwner = ent:getDoorOwner()
        local ownedByClient = playerOwned and ( doorOwner == client or doorCoowners[ client:UserID() ] )
    
        title = ent:getKeysTitle()

        if ( not title ) then
            if ( playerOwned ) then
                title = L( 'door_owned' )
                color = ownedByClient and COLOR_GREEN or COLOR_RED
            else
                if ( doorGroup ) then
                    title = doorGroup
                    titleFont = FONT_SMALL_NAME
                else
                    title = L( 'door_owned' )
                end
    
                if ( doorTeams ) then
                    for teamIndex in pairs( doorTeams ) do
                        subtitle = subtitle .. team.GetName( teamIndex ) .. '\n'
                    end
                end
            end
        elseif ( not playerOwned ) then
            if ( doorGroup ) then
                subtitle = doorGroup
            elseif ( doorTeams ) then
                for teamIndex in pairs( doorTeams ) do
                    subtitle = subtitle .. team.GetName( teamIndex ) .. '\n'
                end
            end
        end

        if ( playerOwned ) then
            subtitle = L( 'hud_door_owner', { name = IsValid( doorOwner ) and doorOwner:Name() or '' } )

            if ( not table.IsEmpty( doorCoowners ) ) then
                subtitle = subtitle .. Format( '\n%s: %s', L( 'hud_door_coowners' ), getPlayersStr( doorCoowners ) )
            end

            if ( allowedCoOwn and not table.IsEmpty( allowedCoOwn ) ) then
                subtitle = subtitle .. Format( '\n%s: %s', L( 'hud_door_allowed' ), getPlayersStr( allowedCoOwn ) )
            end
        end
    else
        title = L( 'door_unowned' )
        subtitle = L( 'hud_door_help', { bind = bindKey, price = DarkRP.formatMoney( doorPrice ) } )
    end

    cam.Start3D2D( renderPos, renderAng, .085 )

        onyx.hud.DrawShadowText( title, titleFont, 0, 0, color, 1, 0 )
        draw.DrawText( subtitle, FONT_HELP .. '.Blur', 2, 60 + 2, color_black, 1 )
        draw.DrawText( subtitle, FONT_HELP, 0, 60, COLOR_GRAY, 1 )

    cam.End3D2D()
end

do
    local DOORS = {
        [ 'prop_door_rotating' ] = true,
        [ 'func_door_rotating' ] = true,
        [ 'func_door' ] = true,
    }
    timer.Create( 'onyx.hud.CatchNearestDoors', 1 / 5, 0, function()
        local client = LocalPlayer()
        if ( IsValid( client ) ) then
            local entities = ents.FindInCone( client:GetShootPos(), client:GetAimVector(), RANGE, math.cos( math.rad( 45 ) ) )
    
            nearest = {}
            bindKey = input.LookupBinding( 'gm_showteam' ) or ''
    
            for _, ent in ipairs( entities ) do
                if ( IsValid( ent ) and ent:isDoor() and not ent:getKeysNonOwnable() and DOORS[ ent:GetClass() ] and not ent:GetNoDraw() ) then
                    table.insert( nearest, ent )
                end
            end
        end
    end )
end

hook.Add( 'PostDrawTranslucentRenderables', 'onyx.hud.DrawDoors', function()
    local client = LocalPlayer()
    for _, ent in ipairs( nearest ) do
        if ( IsValid( ent ) ) then
            drawInfo( ent, client )
        end
    end
end )