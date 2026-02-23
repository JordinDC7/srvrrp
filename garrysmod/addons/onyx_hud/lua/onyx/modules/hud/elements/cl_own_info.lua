--[[

Author: tochnonement
Email: tochnonement@gmail.com

16/08/2024

--]]

local L = function( ... ) return onyx.lang:Get( ... ) end
local MAX_RANGE = 128 ^ 2

local hud = onyx.hud

local traceEntity = NULL
local showFraction = 0
local traceData

timer.Create( 'onyx.hud.CatchTraceVehicle', 1 / 6, 0, function()
    local client = LocalPlayer()
    if ( IsValid( client ) ) then
        local origin = client:GetPos()
        local trace = client:GetEyeTrace()
        local ent = trace.Entity

        if ( IsValid( ent ) and ent:IsVehicle() and not client:InVehicle() and ent:GetPos():DistToSqr( origin ) <= MAX_RANGE ) then
            local class = ent:GetVehicleClass()
            local vehTable = list.Get( 'Vehicles' )[ class ]
            if ( not vehTable and simfphys ) then
                vehTable = list.Get( "simfphys_vehicles" )[ class ]
            end

            local name = vehTable and ( vehTable.Name or class ) or class
        
            local owner = ent:getDoorOwner()
            local group = ent:getKeysDoorGroup()
            local info = L( 'hud_door_owner', { name = IsValid( owner ) and owner:Name() or L( 'unknown' ) } )

            if ( group ) then
                info = group
            end

            if ( traceEntity ~= ent ) then showFraction = 0 end
            
            traceEntity = ent

            -- it will be set to nil when the animation's fraction reaches 0
            traceData = {
                name = name,
                owner = owner,
                info = info
            }
        else
            traceEntity = NULL
        end
    end
end )

local function drawOwnInfo( element, client, scrW, scrH )
    local validTarget = IsValid( traceEntity )

    showFraction = math.Approach( showFraction, validTarget and 1 or 0, FrameTime() * 8 )
    
    if ( showFraction <= 0 or not traceData ) then 
        traceData = nil
        return 
    end

    local x0 = scrW * .5
    local y0 = scrH * .85

    local theme = hud:GetCurrentTheme()
    local colors = theme.colors
    local infoW = hud.ScaleWide( 200 )
    local infoH = hud.ScaleTall( 50 )    
    local infoX, infoY = x0 - infoW * .5, y0 - infoH * .5

    hud.OverrideAlpha( showFraction, function()

        hud.DrawRoundedBox( infoX, infoY, infoW, infoH, colors.primary )
        draw.SimpleText( traceData.name, hud.fonts.SmallBold, x0, y0, colors.textPrimary, 1, 4 )
        draw.SimpleText( traceData.info, hud.fonts.Tiny, x0, y0, colors.textSecondary, 1, 0 )

    end )
end

onyx.hud:RegisterElement( 'owner_info', { drawFn = drawOwnInfo } )