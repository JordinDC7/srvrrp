--[[

Author: tochnonement
Email: tochnonement@gmail.com

14/08/2024

--]]

local SPOLY_ID = 'onyx_hud_wheel_background_3'

do
    onyx.spoly.Generate( SPOLY_ID, function(w, h)
        local scaledThickness = h * .25

        local x = w * .5
        local y = h * .5
        local r = h * .5
        local vertices = 64

        local circleInner = onyx.CalculateCircle(x, y, r - scaledThickness, vertices)
        local circleOuter = onyx.CalculateCircle(x, y, r, vertices)

        onyx.InverseMaskFn(function()
            surface.DrawPoly(circleInner)
        end, function()
            surface.DrawPoly(circleOuter)
        end)
    end )
end

local PANEL = {}

AccessorFunc( PANEL, 'm_bShowLabel', 'ShowLabel' )

function PANEL:Init()
    local colors = onyx.hud:GetCurrentTheme().colors

    self.m_bShowLabel = false
    self.choices = {}
    self.fraction = 0
    self.colors = {
        primary = colors.primary,
        secondary = colors.secondary,
        tertiary = colors.tertiary,
        accent = colors.accent,
        textPrimary = colors.textPrimary,
        textSecondary = colors.textSecondary
    }

    self:Open()

    -- A new hook added in July patch
    -- It is going to replace gui.HideGameUI, so let's prepare to that moment
    -- https://wiki.facepunch.com/gmod/GM:OnPauseMenuShow
    hook.Add( 'OnPauseMenuShow', self, function( this )
        self:Close()
        return false
    end )
end

function PANEL:PerformLayout( w, h )
    self:UpdateSegments()
end

local choiceFont = onyx.Font( 'Comfortaa Bold@16' )
function PANEL:Paint( w, h )
    local colors = self.colors
    local x0, y0 = math.Round( w * .5 ), math.Round( h * .5 )
    local r = h * .5

    local animSpeed = FrameTime() * 8

    -- Draw segments
    for _, choice in ipairs( self.choices ) do
        if ( choice.valid ) then
            local isHovered = choice.isHovered
            local bgColor = isHovered and colors.secondary or colors.primary
            local textColor = isHovered and colors.accent or colors.textSecondary
            local outlineColor = not isHovered and colors.tertiary or colors.accent

            choice.outlineColor = onyx.LerpColor( animSpeed, choice.outlineColor or outlineColor, outlineColor )                                                                                                                                -- a0e762ff-7eea-45b0-9009-1be3e92f9b18
            choice.bgColor = onyx.LerpColor( animSpeed, choice.bgColor or bgColor, bgColor )

            local cos, sin = choice.cos, choice.sin
            local choiceX0 = x0 + cos * r * .75
            local choiceY0 = y0 + sin * r * .75
            local name = choice.name
            local iconSize = math.Round( r * .125 )

            -- Calculate text height
            surface.SetFont( choiceFont )
            local _, textH = surface.GetTextSize( name )

            -- Draw background
            onyx.DrawWithPolyMask( choice.mask, function()
                onyx.spoly.Draw( SPOLY_ID, 0, 0, w, h, choice.bgColor )
                onyx.DrawOutlinedCircle( x0, y0, r, 1, choice.outlineColor )
            end )

            -- Draw content
            if ( choice.mat ) then
                surface.SetDrawColor( textColor )
                surface.SetMaterial( choice.mat )
                surface.DrawTexturedRectRotated( choiceX0, choiceY0, iconSize, iconSize, 0 )
            else 
                draw.DrawText( name, choiceFont, choiceX0, choiceY0 - textH * .5, textColor, 1 )
            end
        end
    end

    -- Draw lines
    for _, choice in ipairs( self.choices ) do
        if ( choice.valid ) then
            local lineRad = math.rad( choice.startAng - 90 )
            local lineCos, lineSin = math.cos( lineRad ), math.sin( lineRad )

            surface.SetDrawColor( colors.tertiary )
            surface.DrawLine( 
                x0 + lineCos * r * .5,
                y0 + lineSin * r * .5,
                x0 + lineCos * r * 1,
                y0 + lineSin * r * 1
             )
        end
    end

    -- Draw label
    local hoveredChoice = self.hoveredChoice
    if ( hoveredChoice and self:GetShowLabel() ) then
        local name = hoveredChoice.name
        
        surface.SetFont( choiceFont )
        local textW, textH = surface.GetTextSize( name )
        local labelPadding = r * .05
        local labelW = textW + labelPadding * 2
        local labelH = textH + labelPadding * 2
        local labelX = x0 - labelW * .5
        local labelY = y0 - labelH * .5

        draw.RoundedBox( 8, labelX, labelY, labelW, labelH, colors.primary )
        draw.DrawText( name, choiceFont, x0, labelY + labelPadding, colors.textPrimary, 1 )
    end
end

function PANEL:Think()
    if ( not self._CLOSED ) then
        self:HandleEscape()
        self:HandleControls()
        if ( self.PostThink ) then
            self:PostThink()
        end
    end
end

function PANEL:HandleEscape()
    if ( input.IsKeyDown( KEY_ESCAPE ) ) then
        if ( gui.HideGameUI ) then gui.HideGameUI() end
        self:Close()
    end
end

function PANEL:HandleControls()
    local w, h = self:GetSize()
    local x, y = input.GetCursorPos()
    local curPos = Vector( x, y )
    local centerPos = Vector( ScrW() * .5, ScrH() * .5 )
    local relX, relY = self:ScreenToLocal( x, y )
    
    relX = relX - ( w * .5 )
    relY = relY - ( h * .5 )

    local ang = ( math.deg( math.atan2( relY, relX ) ) + 90 ) % 360
    local distance = curPos:Distance( centerPos )
    local hoveredChoice

    for _, choice in ipairs( self.choices ) do
        if ( choice.valid ) then
            local startAngle = choice.startAng
            local endAngle = choice.endAng
            local isHovered = ( 
                self:IsHovered()
                and ang > startAngle 
                and ang < endAngle
                and distance > h * .25
                and distance < h * .5
            )
    
            choice.isHovered = isHovered

            if ( isHovered ) then
                hoveredChoice = choice
            end
        end
    end

    self.hoveredChoice = hoveredChoice
end

function PANEL:OnMouseReleased( mouseCode )
    local hoveredChoice = self.hoveredChoice
    if ( mouseCode == MOUSE_LEFT and hoveredChoice ) then
        self:HandleClick( hoveredChoice )
    end
end

function PANEL:HandleClick( choice )
    local clickFn = choice.clickFn or choice.callback
    
    if ( not choice.ignoreClose ) then
        self:Close()
    end

    if ( clickFn ) then
        clickFn( self )
    end
end

function PANEL:UpdateSegments()
    local w, h = self:GetSize()
    if ( w < 1 or h < 1 ) then return end

    local x0, y0 = w * .5, h * .5
    local choices = self.choices
    local amount = #choices

    local segmentAng = ( 360 / amount )

    for index = 1, amount do
        local choice = choices[ index ]
        if ( choice ) then
            local startAng = ( index - 1 ) * segmentAng
            local endAng = startAng + segmentAng
            local betweenAng = startAng + segmentAng * .5
            local rad = math.rad( betweenAng - 90 )
    
            choice.startAng = startAng
            choice.endAng = endAng
            choice.segmentAng = segmentAng
        
            choice.cos = math.cos( rad )
            choice.sin = math.sin( rad )
            choice.mask = onyx.CalculateArc( x0, y0, startAng, segmentAng - 0, math.ceil( h * .5 ) + 1, 24, true )

            choice.valid = true
        end
    end
end

function PANEL:AddChoice( data )
    table.insert( self.choices, data )

    self:UpdateSegments()
end

function PANEL:Close()
    self._CLOSED = true
    self:SetMouseInputEnabled( false )
    self:SetKeyBoardInputEnabled( false )

    onyx.anim.Create( self, .2, {
        index = 1,
        easing = 'inOutQuad',
        target = { fraction = 0 },
        think = function( _, this )
            this:SetAlpha( this.fraction * 255 )
        end,
        onFinished = function( _, this )
            this:Remove()
        end
    } )
end

function PANEL:Open()
    self:SetAlpha( 0 )

    onyx.anim.Create( self, .2, {
        index = 1,
        easing = 'inOutQuad',
        target = { fraction = 1 },
        think = function( _, this )
            this:SetAlpha( this.fraction * 255 )
        end
    } )
end

onyx.gui.Register( 'onyx.hud.ChoiceWheel', PANEL )