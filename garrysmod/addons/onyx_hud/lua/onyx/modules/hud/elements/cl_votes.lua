--[[

Author: tochnonement
Email: tochnonement@gmail.com

18/08/2024

--]]

onyx.hud.popups = onyx.hud.popups or {}

local L = function( ... ) return onyx.lang:Get( ... ) end
local hud = onyx.hud

local function startFadeAnimation( panel, target, callback )
    panel.animAlpha = panel:GetAlpha() / 255
    
    onyx.anim.Create( panel, .2, {
        index = 1,
        target = { animAlpha = target },
        easing = 'inOutSine',
        think = function( _, panel )
            panel:SetAlpha( panel.animAlpha * 255 )
        end,
        onFinished = function( _, panel )
            if ( callback ) then
                callback( panel )
            end
        end
    } )
end

local function movePopups()
    local padding = hud.GetScreenPadding()
    local space = hud.ScaleTall( 5 )
    local baseX = padding
    local baseY = padding
    local posY = baseY
    
    for _, popup in ipairs( onyx.hud.popups ) do
        popup.animY = popup.animY or posY

        popup:SetVisible( true )

        onyx.anim.Create( popup, .2, {
            index = 2,
            target = { animY = posY },
            easing = 'inOutSine',
            think = function( _, panel )
                panel:SetPos( baseX, panel.animY )
            end
        } )

        posY = posY + popup:GetTall() + space
    end
end

local function createPopup( title, desc, duration, acceptCallback, denyCallback, onRemove )
    local padding = hud.ScaleTall( 10 )
    local w = hud.ScaleWide( 200 )
    local titleFont = hud.fonts.TinyBold
    local descFont = hud.fonts.Tiny
    local isDark = onyx.hud:IsDark()

    desc = DarkRP.textWrap( desc, descFont, w - padding * 2 )

    local duration = duration or 5
    local endtime = CurTime() + duration

    surface.SetFont( titleFont )
    local _, titleH = surface.GetTextSize( title )

    surface.SetFont( descFont )
    local _, descH = surface.GetTextSize( desc )

    local buttonHeight = hud.ScaleTall( 20 )
    local elementSpace = hud.ScaleTall( 10 )
    local titleSpace = hud.ScaleTall( 5 )
    local totalHeight = padding * 2 + buttonHeight + descH + titleH + elementSpace + titleSpace

    local screenPadding = hud.GetScreenPadding()
    local h = totalHeight
    
    local popup = vgui.Create( 'Panel' )
    popup:SetSize( w, h )
    popup:SetAlpha( 0 )
    popup:SetVisible( false )
    popup:DockPadding( padding, padding, padding, padding )
    popup.Paint = function( panel, w, h )
        hud.DrawRoundedBox( 0, 0, w, h, hud:GetColor( 'primary' ) )
    end
    popup.Close = function( panel )
        startFadeAnimation( panel, 0, function( this )
            this:Remove()
        end )
    end
    popup.OnRemove = function( panel )
        for index, popup2 in ipairs( onyx.hud.popups ) do
            if ( panel == popup2 ) then
                table.remove( onyx.hud.popups, index )
                break
            end
        end
    
        movePopups()

        if ( onRemove ) then
            onRemove( panel )
        end
    end
    popup.Think = function( panel )
        if ( CurTime() > endtime and not panel.closed ) then
            panel.closed = true
            panel:Close()
        end
    end

    table.insert( onyx.hud.popups, popup )
    movePopups()

    startFadeAnimation( popup, 1 )

    local lblTitle = popup:Add( 'DLabel' )
    lblTitle:SetText( onyx.utf8.upper( title ) )
    lblTitle:SetFont( titleFont )
    lblTitle:SetTall( titleH )
    lblTitle:SetTextColor( hud:GetColor( 'textSecondary' ) )
    lblTitle:Dock( TOP )
    lblTitle:DockMargin( 0, 0, 0, titleSpace )
    lblTitle.Paint = function( panel, w, h )
        local timeLeft = math.max( 0, endtime - CurTime() )

        draw.SimpleText( math.Round( timeLeft ), panel:GetFont(), w, h * .5, panel:GetTextColor(), 2, 1 )
    end
    popup.lblTitle = lblTitle

    local lblDesc = popup:Add( 'DLabel' ) 
    lblDesc:SetText( desc )
    lblDesc:SetFont( descFont )
    lblDesc:SetTextColor( hud:GetColor( 'textPrimary' ) )
    lblDesc:SetContentAlignment( 7 )
    lblDesc:Dock( FILL )
    lblDesc:DockMargin( 0, 0, 0, elementSpace )
    popup.lblDesc = lblDesc

    local conButtons = popup:Add( 'Panel' )
    conButtons:SetTall( buttonHeight )
    conButtons:Dock( BOTTOM )
    conButtons.PerformLayout = function( panel, w, h )
        local space = hud.ScaleTall( 5 )
        local wide = math.Round( ( w - space ) / 2 )
        for _, child in ipairs( panel:GetChildren() ) do
            child:SetWide( wide )
            child:DockMargin( 0, 0, space, 0 )
            child:Dock( LEFT )
        end
    end

    local btnAccept = conButtons:Add( 'onyx.Button' )
    btnAccept:SetText( L( 'accept' ) )
    btnAccept:SetFont( hud.fonts.TinyBold )
    btnAccept:SetMasking( true )
    btnAccept:SetColorIdle( hud:GetColor( not isDark and 'tertiary' or 'accent' ) )
    btnAccept:SetColorHover( onyx.OffsetColor( btnAccept:GetColorIdle(), -20 ) )
    btnAccept:SetGradientColor( onyx.OffsetColor( btnAccept:GetColorIdle(), -20 ) )
    btnAccept:SetGradientDirection( TOP )
    btnAccept.DoClick = function()
        popup:Close()
        if ( acceptCallback ) then
            acceptCallback()
        end
    end
    popup.btnAccept = btnAccept

    local btnDeny = conButtons:Add( 'onyx.Button' )
    btnDeny:SetText( L( 'deny' ) )
    btnDeny:SetFont( hud.fonts.TinyBold )
    btnDeny:SetMasking( true )
    btnDeny:SetColorIdle( hud:GetColor( 'tertiary' ) )
    btnDeny:SetColorHover( onyx.OffsetColor( hud:GetColor( 'tertiary' ), -10 ) )
    btnDeny:SetGradientColor( onyx.OffsetColor( btnDeny:GetColorIdle(), -20 ) )
    btnDeny:SetGradientDirection( TOP )
    btnDeny.DoClick = function()
        popup:Close()
        if ( denyCallback ) then
            denyCallback()
        end
    end
    popup.btnDeny = btnDeny

    hook.Add( 'onyx.hud.OnChangedTheme', popup, function( this )
        this.lblTitle:SetTextColor( hud:GetColor( 'textSecondary' ) )
        this.lblDesc:SetTextColor( hud:GetColor( 'textPrimary' ) )

        this.btnAccept:SetColorIdle( hud:GetColor( not isDark and 'tertiary' or 'accent' ) )
        this.btnAccept:SetColorHover( onyx.OffsetColor( this.btnAccept:GetColorIdle(), -20 ) )
        this.btnAccept:SetGradientColor( onyx.OffsetColor( this.btnAccept:GetColorIdle(), -20 ) )

        this.btnDeny:SetColorIdle( hud:GetColor( 'tertiary' ) )
        this.btnDeny:SetColorHover( onyx.OffsetColor( hud:GetColor( 'negative' ), -20 ) )
        this.btnDeny:SetGradientColor( onyx.OffsetColor( this.btnDeny:GetColorIdle(), -20 ) )
    end )

    return popup
end

local function overrideDarkRP()
    usermessage.Hook( 'DoVote', function( msg )
        local text = msg:ReadString()
        local voteID = msg:ReadShort()
        local duration = msg:ReadFloat()
    
        if ( duration == 0 ) then
            duration = 100
        end

        local popup = createPopup( L( 'vote' ), text, duration, function()
            LocalPlayer():ConCommand( 'vote ' .. voteID .. ' yea\n' )
        end, function()
            LocalPlayer():ConCommand( 'vote ' .. voteID .. ' nay\n' )
        end )

        popup.voteID = voteID
    end )

    usermessage.Hook( 'DoQuestion', function( msg )
        local text = msg:ReadString()
        local questionID = msg:ReadString()
        local duration = msg:ReadFloat()
    
        if ( duration == 0 ) then
            duration = 100
        end

        local popup = createPopup( L( 'question' ), text, duration, function()
            LocalPlayer():ConCommand( 'ans ' .. questionID .. ' 1\n' )
        end, function()
            LocalPlayer():ConCommand( 'ans ' .. questionID .. ' 2\n' )
        end )

        popup.questionID = questionID
    end )

    usermessage.Hook( 'KillVoteVGUI', function( msg )
        local id = msg:ReadShort()
        for _, popup in ipairs( hud.popups ) do
            if ( popup.voteID == id ) then
                popup:Close()
                break
            end
        end
    end )

    usermessage.Hook( 'KillQuestionVGUI', function( msg )
        local id = msg:ReadString()    
        for _, popup in ipairs( hud.popups ) do
            if ( popup.questionID == id ) then
                popup:Close()
                break
            end
        end
    end )

    concommand.Add( 'rp_vote', function( ply, cmd, args )
        local value = string.lower( args[ 1 ] or '' )
        local vote = 0
        if ( tonumber( value ) == 1 ) or ( value == 'yes' ) or ( value == 'true' ) then vote = 1 end
    
        for _, popup in ipairs( hud.popups ) do
            if ( popup.questionID ) then
                popup:Close()
                RunConsoleCommand( 'ans', popup.questionID, vote )
                break
            elseif ( popup.voteID ) then
                popup:Close()
                RunConsoleCommand( 'vote', popup.voteID, vote )
                break
            end
        end
    end )
end

onyx.hud.OverrideGamemode( 'onyx.hud.OverrideVoteMenus', overrideDarkRP )