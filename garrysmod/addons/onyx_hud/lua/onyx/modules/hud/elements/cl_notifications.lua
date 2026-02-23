--[[

Author: tochnonement
Email: tochnonement@gmail.com

11/08/2024

--]]

local hud = onyx.hud
local cache = {}

local COLOR_BAR = Color( 0, 0, 0, 200 ) -- Only for light themes
local FONT_TEXT = 'onyx.hud.Small'
local NOTIFICATION_TYPES = {
    [ NOTIFY_GENERIC ] = {
        color = Color( 255, 228, 52),
        mat = Material("onyx_hud/notify_generic.png", "smooth mips")
    },
    [ NOTIFY_ERROR ] = {
        color = Color( 235, 57, 57),
        mat = Material("onyx_hud/notify_error.png", "smooth mips")
    },
    [ NOTIFY_UNDO ] = {
        color = Color( 69, 78, 255),
        mat = Material("onyx_hud/notify_undo.png", "smooth mips")
    },
    [ NOTIFY_HINT ] = {
        color = Color( 37, 222, 225),
        mat = Material("onyx_hud/notify_hint.png", "smooth mips")
    },
    [ NOTIFY_CLEANUP ] = {
        color = Color( 235, 81, 255),
        mat = Material("onyx_hud/notify_cleanup.png", "smooth mips")
    },
}

local function addNotification( text, type, length )
    table.insert( cache, 1, {
        text = text,
        type = type,
        endtime = CurTime() + length,
        duration = length
    } )
end

local function overrideNotifications()
    hud.original_AddLegacy = hud.original_AddLegacy or notification.AddLegacy

    function notification.AddLegacy( text, type, length )
        local text = tostring( text )
        local type = type or NOTIFY_GENERIC
        local length = length or 3
        local isEnabled = onyx.hud.IsElementEnabled( 'notifications' )
        
        if ( isEnabled ) then
            addNotification( text:Trim():gsub('\n', ' '), type, length )
        else
            hud.original_AddLegacy( text, type, length )
        end
    end
end
onyx.hud.OverrideGamemode( 'onyx.hud.OverrideNotifications', overrideNotifications )

local function drawNotifications( self, client, scrW, scrH )
    local theme = hud:GetCurrentTheme()
    local colorPrimary = theme.colors.primary
    local colorSecondary = theme.colors.secondary
    local colorTertiary = theme.colors.tertiary
    local colorText = theme.colors.textPrimary
    local isDark = theme.dark

    local space = onyx.hud.GetScreenPadding()
    local horPadding = onyx.hud.ScaleTall( 10 )
    local notifH = onyx.hud.ScaleTall( 30 )
    local hudRoundness = onyx.hud.GetRoundness()
    local notifSpace = onyx.hud.ScaleTall( 5 )
    local iconSpace = onyx.hud.ScaleTall( 10 )
    local iconSize = onyx.hud.ScaleTall( 18 )
    local lineH = onyx.hud.ScaleTall( 2 )

    local amount = #cache
    local posY = scrH * .75
    local speed = FrameTime() * 8

    -- to avoid overlapping
    if ( #onyx.hud.VoicePanels > 0 ) then
        for _, data in ipairs( onyx.hud.VoicePanels ) do
            local panel = data.panel
            if ( IsValid( panel ) and panel:IsVisible() ) then
                posY = math.min( posY, select( 2, panel:GetPos() ) )
            end
        end
        posY = posY - notifSpace
    end
    
    posY = posY - notifH

    for index = 1, amount do
        local data = cache[ index ]
        if ( not data ) then continue end

        local notifText = data.text
        local notifType = data.type or 0
        local notifTypeData = NOTIFICATION_TYPES[ notifType ] or NOTIFICATION_TYPES[ NOTIFY_GENERIC ]
        local notifColor = notifTypeData.color
        local timeLeft = math.max( 0, data.endtime - CurTime() )
        local lifeFraction = timeLeft / data.duration
        local expired = lifeFraction == 0
        local targetFraction = expired and 0 or 1
        local matObject = notifTypeData.mat

        -- Get size
        surface.SetFont( FONT_TEXT )
        local textW, textH = surface.GetTextSize( notifText )
        local notifW = textW + horPadding * 2 + iconSize + iconSpace

        -- Calculate pos
        local posX = expired and scrW or ( scrW - notifW - space )

        data.x = Lerp( speed, data.x or scrW, posX )
        data.y = Lerp( speed, data.y or posY, posY )
        data.fraction = math.Approach( data.fraction or 0, targetFraction, speed )

        local x = data.x
        local y = math.ceil( data.y )

        -- Draw
        local prevAlpha = surface.GetAlphaMultiplier()
        local lineColor = isDark and ColorAlpha( notifColor, 20 ) or COLOR_BAR

        surface.SetAlphaMultiplier( data.fraction )

            onyx.hud.DrawRoundedBox( x, y, notifW, notifH, colorPrimary )

            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( matObject )
            surface.DrawTexturedRect( x + horPadding, y + notifH * .5 - iconSize * .5, iconSize, iconSize )

            render.SetScissorRect( x, y + notifH - lineH, x + notifW, y + notifH, true )
                onyx.hud.DrawRoundedBox( x, y, notifW, notifH, lineColor )
            render.SetScissorRect( x, y + notifH - lineH, x + notifW * lifeFraction, y + notifH, true )
                onyx.hud.DrawRoundedBox( x, y, notifW, notifH, notifColor )
            render.SetScissorRect( 0, 0, 0, 0, false )

            onyx.hud.DrawCheapText( notifText, FONT_TEXT, x + horPadding + iconSize + iconSpace, y + notifH * .5 - textH * .5, colorText )

        surface.SetAlphaMultiplier( prevAlpha )

        posY = posY - notifH - notifSpace

        if ( expired and data.fraction == 0 ) then
            table.remove( cache, index )
        end
    end
end

onyx.hud:RegisterElement( 'notifications', {
    priority = 90,
    drawFn = drawNotifications,
    hideElements = {}
} )

concommand.Add( 'onyx_hud_test_notifications', function( ply )
    if ( ply:IsAdmin() ) then
        local index = 0
        for type in pairs( NOTIFICATION_TYPES ) do
            index = index + 1
            notification.AddLegacy( 'Onyx HUD Notification', type, 10 - index )
        end
    end
end )