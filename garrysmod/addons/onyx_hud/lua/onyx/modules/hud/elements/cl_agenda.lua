--[[

Author: tochnonement
Email: tochnonement@gmail.com

18/08/2024

--]]

local hud = onyx.hud
local agendaWrapped = ''
local lastTitle = ''
local titleFormatted = ''

local function drawAgenda( element, client, scrW, scrH )
    local agendaTable = client:getAgendaTable()
    local agendaText = client:getDarkRPVar( 'agenda' ) or ''
    
    element.active = agendaTable and agendaText ~= ''
    if ( not element.active ) then return end

    local screenPadding = hud.GetScreenPadding()
    local padding = hud.ScaleTall( element.padding )
    local w = hud.ScaleWide( element.width )
    local h = hud.ScaleTall( element.height )
    local fontTitle = hud.fonts.TinyBold
    local fontDesc = hud.fonts.Tiny

    local title = agendaTable.Title
    local titleH = hud.ScaleTall( 25 )

    if ( agendaText ~= agendaWrapped ) then
        agendaWrapped = DarkRP.textWrap( agendaText, fontDesc, w - padding * 2 )
    end

    if ( lastTitle ~= title ) then
        lastTitle = title
        titleFormatted = onyx.utf8.upper( title )
    end

    local x, y = scrW - w - screenPadding, screenPadding
    
    hud.DrawRoundedBox( x, y, w, h, hud:GetColor( 'primary' ) )
    hud.DrawRoundedBoxEx( x, y, w, titleH, hud:GetColor( 'secondary' ), true, true )
    draw.SimpleText( titleFormatted, fontTitle, x + w * .5, y + titleH * .5, hud:GetColor( 'textSecondary' ), 1, 1 )
    draw.DrawText( agendaWrapped, fontDesc, x + padding, y + titleH + padding, hud:GetColor( 'textPrimary' ), 0, 1 )
end

onyx.hud:RegisterElement( 'agenda', { drawFn = drawAgenda, height = 120, width = 250, padding = 10 } )