--[[

Author: tochnonement
Email: tochnonement@gmail.com

11/08/2024

--]]

local hud = onyx.hud
local nearest = {}
local statuses = {}

local MAX_DISTANCE = 400 ^ 2
local MAX_GLOBAL_DRAWS = 12

local CONVAR_MAX_DETAILED = CreateClientConVar( 'cl_onyx_hud_3d2d_max_details', '3', true, false, '', 1, 5 )

local COLOR_LOW_HP = Color( 255, 59, 59)
local COLOR_MAX_HP = Color( 115, 255, 49)
local COLOR_ARMOR = Color( 52, 130, 255)
local COLOR_RED = Color( 255, 52, 52)
local COLOR_BLUE = Color( 55, 52, 255)
local COLOR_SLIGHT_SHADOW = Color( 0, 0, 0, 150 )
local ICON_SIZE = 64
local MAT_LICENSE = Material( 'onyx_hud/license.png', 'smooth mips' )

local FONT_NAME = onyx.hud.CreateFont3D2D( 'OverheadName', 'Comfortaa Bold', 72 )
local FONT_JOB = onyx.hud.CreateFont3D2D( 'OverheadJob', 'Comfortaa SemiBold', 40 )
local FONT_STATUS = onyx.hud.CreateFont3D2D( 'OverheadStatus', 'Comfortaa Bold', 64 )

local drawShadowText = onyx.hud.DrawShadowText

local getStatuses, hasStatus do
    local function createStatus( data )
        table.insert( statuses, data )
    end

    function getStatuses( ply )
        local result = {}
        for _, status in ipairs( statuses ) do
            if ( status.func( ply ) ) then
                table.insert( result, status )
            end
        end
        return result
    end

    -- Quicker than checking by amount
    function hasStatus( ply )
        for _, status in ipairs( statuses ) do
            if ( status.func( ply ) ) then
                return true
            end
        end
        return false
    end

    createStatus( {
        id = 'wanted',
        mat = Material( 'onyx_hud/wanted.png', 'smooth mips' ),
        big = true,
        func = function( ply )
            return ply:getDarkRPVar( 'wanted' )
        end,
        getColor = function()
            local fraction = math.abs( math.sin( CurTime() ) )
            local color = onyx.LerpColor( fraction, COLOR_RED, COLOR_BLUE )
            return color
        end
    } )

    createStatus( {
        id = 'speaking',
        mat = Material( 'onyx_hud/microphone.png', 'smooth mips' ),
        func = function( ply )
            return ply:IsSpeaking()
        end
    } )

    createStatus( {
        id = 'typing',
        mat = Material( 'onyx_hud/chat.png', 'smooth mips' ),
        func = function( ply )
            return ply:IsTyping()
        end
    } )
end

local function drawStatus( ply, y )
    local halfIconSize = ICON_SIZE * .5
    local iconSpace = 10
    local statuses = getStatuses( ply )
    local amount = #statuses
    local totalW = amount * ICON_SIZE + ( amount - 1 ) * iconSpace
    local iconX = -totalW * .5
    local isSingle = amount == 1

    -- Draw microphone
    for i = 1, amount do
        local status = statuses[ i ]
        local color = status.getColor and status.getColor() or ( status.color or hud:GetColor( 'accent' ) )

        if ( isSingle and status.big ) then
            status.text = status.text or onyx.lang:Get( 'hud_status_' .. status.id )
            local text = status.text

            if ( status.dots ) then
                text = text .. string.rep( '.', CurTime() % 4 )
            end
        
            surface.SetFont( FONT_STATUS )
            local textW, textH = surface.GetTextSize( text )
            
            iconX = iconX - ( textW + iconSpace ) * .5

            drawShadowText( text, FONT_STATUS, iconX + ICON_SIZE + iconSpace, y + ICON_SIZE * .5 - textH * .5, color )
        end

        surface.SetDrawColor( COLOR_SLIGHT_SHADOW )
        surface.SetMaterial( statuses[ i ].mat )
        surface.DrawTexturedRect( iconX + 2, y + 2, ICON_SIZE, ICON_SIZE )

        surface.SetDrawColor( color )
        surface.SetMaterial( statuses[ i ].mat )
        surface.DrawTexturedRect( iconX, y, ICON_SIZE, ICON_SIZE )

        iconX = iconX + ICON_SIZE + iconSpace
    end
end

local function drawQuickInfo( ply, client )
    drawStatus( ply, 0 )
end

local function drawInfo( ply, client )
    local playerName = ply:Name()
    local teamID = ply:Team()
    local teamName = team.GetName( teamID )
    local teamColor = team.GetColor( teamID )
    local hasLicense = ply:getDarkRPVar( 'HasGunLicense' )
    local shouldDrawHealth = hud.IsElementEnabled( 'overhead_health' )

    local currentY = 0

    drawStatus( ply, -ICON_SIZE )

    -- Draw name
    if ( hasLicense ) then
        local iconSize = 32
        local iconSpace = 15

        surface.SetFont( FONT_NAME )
        local nameTextW, nameTextH = surface.GetTextSize( playerName )
        
        local nameX = ( nameTextW + iconSize + iconSpace ) * -.5
        local iconY = currentY + nameTextH * .5 - iconSize * .5
        
        surface.SetDrawColor( COLOR_SLIGHT_SHADOW )
        surface.SetMaterial( MAT_LICENSE )
        surface.DrawTexturedRect( nameX + nameTextW + iconSpace + 2, iconY + 2, iconSize, iconSize, MAT_LICENSE )

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( MAT_LICENSE )
        surface.DrawTexturedRect( nameX + nameTextW + iconSpace, iconY, iconSize, iconSize, MAT_LICENSE )

        drawShadowText( playerName, FONT_NAME, nameX, currentY, color_white )
        currentY = currentY + 65
    else
        drawShadowText( playerName, FONT_NAME, 0, currentY, color_white, 1, 0 )
        currentY = currentY + 65
    end

    -- Draw team
    drawShadowText( teamName, FONT_JOB, 0, currentY, teamColor, 1, 0 )
    currentY = currentY + 40

    -- Draw health & armor
    if ( shouldDrawHealth ) then
        local healthInt = ply:Health()
        local healthFraction = math.Clamp( healthInt / ply:GetMaxHealth(), 0, 1 )
        local healthColor = onyx.LerpColor( healthFraction, COLOR_LOW_HP, COLOR_MAX_HP )
        
        local armorInt = ply:Armor()
        local shouldDrawArmor = armorInt > 0 and hud.IsElementEnabled( 'overhead_armor' )

        local healthText = healthInt .. ' HP'
        
        if ( shouldDrawArmor ) then
            healthText = healthText .. '  '
            local armorText = armorInt .. ' AP'

            surface.SetFont( FONT_JOB )
            local healthTextWidth = surface.GetTextSize( healthText )
            local armorTextWidth = surface.GetTextSize( armorText )
            local totalTextWidth = healthTextWidth + armorTextWidth
            local textX = -totalTextWidth * .5
        
            drawShadowText( healthText, FONT_JOB, textX, currentY, healthColor )
            drawShadowText( armorText, FONT_JOB, textX + healthTextWidth, currentY, COLOR_ARMOR )
        else
            drawShadowText( healthText, FONT_JOB, 0, currentY, healthColor, 1, 0 )
        end

        currentY = currentY + 30
    end
end

timer.Create( 'onyx.hud.CollectNearestPlayers', 1 / 10, 0, function()
    local client = LocalPlayer()
    if ( IsValid( client ) ) then
        nearest = {}

        -- Make sure that any random error (if there is any) won't break the timer
        ProtectedCall( function()
            local origin = client:GetPos()
            local aimVector = client:GetAimVector()
        
            for _, ply in ipairs( player.GetAll() ) do
                local playerPos = ply:GetPos()
                
                if (ply ~= client and ply:Alive() and ply:GetColor().a > 50 and ply:Health() > 0 and not ply:GetNoDraw() and ply:GetRenderMode() ~= RENDERMODE_NONE and playerPos:DistToSqr( origin ) <= MAX_DISTANCE ) then
                    local dotProduct = aimVector:Dot( ( playerPos - origin ):GetNormalized() )
                    if ( dotProduct > .6 ) then
                        
                    table.insert( nearest, {
                        ply = ply,
                        dot = dotProduct
                    } )
                    end
                end
            end

            table.sort( nearest, function( a, b )
                return a.dot > b.dot
            end )
        end )
    end
end )

hook.Add( 'PostDrawTranslucentRenderables', 'onyx.hud.DrawOverheadInfo', function()
    local client = LocalPlayer()
    local index = 0

    for _, object in ipairs( nearest ) do
        local ply = object.ply
        if ( IsValid( ply ) ) then
            index = index + 1
            if ( index > MAX_GLOBAL_DRAWS ) then break end

            local detailed = index <= CONVAR_MAX_DETAILED:GetInt()
            local shouldDraw = detailed or hasStatus( ply )

            if ( shouldDraw ) then
                local _, maxs = ply:GetRenderBounds()
                local jobTable = ply:getJobTable() or {}
                local heightOffset = jobTable.onyxOverheadOffset or ( maxs.z + 10 )
                local pos = ply:GetPos() + Vector( 0, 0, heightOffset )
                local ang = Angle( 0, client:EyeAngles().y - 90, 90 )
                
                cam.Start3D2D( pos, ang, 0.075 )
                    if ( detailed ) then
                        drawInfo( ply, client )
                    else
                        print(client)
                        drawQuickInfo( ply, client )
                    end
                cam.End3D2D()
            end
        end
    end
end )