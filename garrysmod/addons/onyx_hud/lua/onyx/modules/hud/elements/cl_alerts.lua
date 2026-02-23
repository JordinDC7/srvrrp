--[[

Author: tochnonement
Email: tochnonement@gmail.com

17/08/2024

--]]

local DURATION = 5

local hud = onyx.hud
local alerts = {}

local function addAlert( text )
    local useQueue = hud:GetOptionValue( 'alert_queue' )
    local data = {
        title = onyx.utf8.upper( onyx.lang:Get( 'message' ) ),
        text = text,
        duration = DURATION
    }

    if ( useQueue ) then
        table.insert( alerts, data )
    else
        alerts[ 1 ] = data
    end
end

local function drawAlerts( element, client, scrW, scrH )
    local alert = alerts[ 1 ]

    if ( not alert ) then return end
    if ( not alert.endtime ) then alert.endtime = CurTime() + alert.duration end

    local maxW = hud.ScaleWide( 500 )
    local font = hud.fonts.Small
    local roundness = hud.GetRoundness()
    local colorPrimary = hud:GetColor( 'primary' )
    local colorText = hud:GetColor( 'textPrimary' )
    local colorTitle = hud:GetColor( 'textSecondary' )
    local colorAccent = hud:GetColor( 'accent' )
    local alertSpace = hud.ScaleTall( 5 )
    local baseY = ScrH() * .25
    local posY = baseY

    if ( not alert.wrapText ) then
        alert.wrapText = DarkRP.textWrap( alert.text, font, maxW )
    end
    
    local text = alert.wrapText
    local title = alert.title

    surface.SetFont( font )
    local textW, textH = surface.GetTextSize( text )
    local titleH = hud.ScaleTall( 20 )

    local padding = hud.ScaleTall( 10 )
    local x0, y0 = scrW * .5, scrH * .5
    local w = textW + padding * 2
    local h = textH + titleH + padding * 2
    local x = x0 - w * .5
    local y = posY
    local lineH = hud.ScaleTall( 3 )
    local timeLeft = math.max( 0, ( alert.endtime - CurTime() ) )
    local lifeFraction = timeLeft / alert.duration
    local isExpired = lifeFraction <= 0
    
    alert.alpha = Lerp( FrameTime() * 8, alert.alpha or 0, isExpired and 0 or 1 )

    surface.SetAlphaMultiplier( alert.alpha )

        hud.DrawRoundedBox( x, y, w, h, colorPrimary )

        render.SetScissorRect( x, y + h - lineH, x + w, y + h, true )
            hud.DrawRoundedBox( x, y, w, h, onyx.LerpColor( .75, colorAccent, colorPrimary ) )
        render.SetScissorRect( x, y + h - lineH, x + w * lifeFraction, y + h, true )
            hud.DrawRoundedBox( x, y, w, h, colorAccent )
        render.SetScissorRect( 0, 0, 0, 0, false )

        draw.SimpleText( title, hud.fonts.TinyBold, x0, y + padding, colorTitle, 1 )

        draw.DrawText( text, font, x0, y + padding + titleH, colorText, 1 )

    surface.SetAlphaMultiplier( 1 )
    
    if ( isExpired and math.Round( alert.alpha, 1 ) == 0 ) then
        table.remove( alerts, 1 )
    end
end

net.Receive( 'onyx.hud::SendAlert', function()
    if ( onyx.hud.IsElementEnabled( 'alerts' ) ) then
        addAlert( net.ReadString() )
    end
end )

hook.Add( 'onyx.inconfig.Updated', 'onyx.hud.ClearAlerts', function( id, old, new )
    if ( id and id == 'hud_display_alerts' ) then
        alerts = {}
    end
end )

onyx.hud:RegisterElement( 'alerts', { drawFn = drawAlerts } )