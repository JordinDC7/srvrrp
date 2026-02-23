local PANEL = {}

function PANEL:Init()
    
end

function PANEL:FillPanel()
    self.panelTall = ScrH()*0.65-40

    self.bottomBar = vgui.Create( "DPanel", self )
    self.bottomBar:Dock( BOTTOM )
    self.bottomBar:SetTall( 100 )
    self.bottomBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )

        if( LocalPlayer():GetUnboxingRewardsTodayClaimed() ) then
            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingRewardsClaimedMsg" ), "BRICKS_SERVER_Font23", 25, h/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, TEXT_ALIGN_CENTER )
        else
            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingRewardsUnClaimed" ), "BRICKS_SERVER_Font23", 25, h/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, TEXT_ALIGN_CENTER )
        end
    end 

    self.topHeaderH = 35
    self.spacing = 2
    self.backWidth = (self.panelWide-50-10-(6*self.spacing))/7
    
    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:DockMargin( 25, 25, 25, 0 )
    self.topBar:SetTall( self.topHeaderH )
    self.topBar.Paint = function( self, w, h ) end 

    local dayNames = { BRICKS_SERVER.Func.L( "monday" ), BRICKS_SERVER.Func.L( "tuesday" ), BRICKS_SERVER.Func.L( "wednesday" ), BRICKS_SERVER.Func.L( "thursday" ), BRICKS_SERVER.Func.L( "friday" ), BRICKS_SERVER.Func.L( "saturday" ), BRICKS_SERVER.Func.L( "sunday" ) }
    
    for i = 1, 7 do
        local headerPanel = vgui.Create( "DPanel", self.topBar )
        headerPanel:Dock( LEFT )
        headerPanel:DockMargin( 0, 0, (i != 7 and self.spacing or 0), 0 )
        headerPanel:SetWide( self.backWidth )
        headerPanel.Paint = function( self, w, h ) 
            if( i == 1 ) then
                draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), true, false, false, false )
            elseif( i == 7 ) then
                draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, true, false, false )
            else
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                surface.DrawRect( 0, 0, w, h )
            end

            draw.SimpleText( string.upper( dayNames[i] ), "BRICKS_SERVER_Font23", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end 
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 0, 25, 25 )
    self.scrollPanel.VBar:SetRoundedCorners( false, true, false, true )
    self.scrollPanel.Paint = function( self, w, h ) end 

    self:Refresh()

    hook.Add( "BRS.Hooks.FillUnboxingRewardsClaimed", self, function()
        self:Refresh()
    end )

    hook.Add( "BRS.Hooks.ConfigReceived", self, function()
        self:Refresh()
    end )
end

function PANEL:Refresh()
    self.scrollPanel:Clear()

    local slotWidth = self.backWidth-20
    local slotTall = slotWidth*1.2

    local mostItems = 0
    for k, v in pairs( BRICKS_SERVER.CONFIG.UNBOXING.Rewards ) do
        mostItems = math.max( mostItems, table.Count( v ) )
    end

    local contentPanel = vgui.Create( "DPanel", self.scrollPanel )
    contentPanel:Dock( TOP )
    contentPanel:SetTall( math.max( self.panelTall-50-self.topHeaderH-self.bottomBar:GetTall(), (mostItems*(slotTall+10))+10 ) )
    contentPanel.Paint = function( self, w, h ) end 

    local dateTable = os.date( "*t" )
    local weekDay =  (dateTable.wday-1 >= 1 and dateTable.wday-1) or 7

    local todayClaimed = LocalPlayer():GetUnboxingRewardsTodayClaimed()
    local claimedTable = LocalPlayer():GetUnboxingRewardsClaimed()

    for i = 1, 7 do
        local isClaimed = false
        if( i == weekDay ) then
            isClaimed = todayClaimed
        elseif( i < weekDay ) then
            local checkTime = os.time( {
                year = dateTable.year,
                month = dateTable.month,
                day = dateTable.day-(weekDay-i),
                hour = 12,
                min = 0,
                sec = 0
            } )
            local checkDate = os.date( "*t", checkTime )
            local monthTable = ((claimedTable[checkDate.year] or {})[checkDate.month] or {})

            isClaimed = monthTable[checkDate.day] == true
        end

        local rewardEntry = vgui.Create( "DPanel", contentPanel )
        rewardEntry:Dock( LEFT )
        rewardEntry:DockMargin( 0, 0, (i != 7 and self.spacing or 0), 0 )
        rewardEntry:SetWide( self.backWidth )
        rewardEntry.Paint = function( self, w, h ) 
            local backColor = BRICKS_SERVER.Func.GetTheme( 2, 100 )
            if( i == weekDay ) then
                backColor = BRICKS_SERVER.Func.GetTheme( 3, 125 )
            end

            if( i == 1 ) then
                draw.RoundedBoxEx( 8, 0, 0, w, h, backColor, false, false, true, false )
            else
                surface.SetDrawColor( backColor )
                surface.DrawRect( 0, 0, w, h )
            end
        end 

        local tickMat = Material( "bricks_server/unboxing_tick_64.png" )
        for k, v in pairs( BRICKS_SERVER.CONFIG.UNBOXING.Rewards[i] or {} ) do
            local slotBack = vgui.Create( "bricks_server_unboxingmenu_itemslot", rewardEntry )
            slotBack:Dock( TOP )
            slotBack:DockMargin( 10, 10, 10, 0 )
            slotBack:SetSize( slotWidth, slotWidth*1.2 )
            slotBack:FillPanel( k, v, function()

            end )
            local paintTarget = (IsValid(slotBack.button) and slotBack.button) or slotBack
            paintTarget.PaintOver = function( self2, w, h ) 
                if( isClaimed ) then
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 10 ) )

                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                    surface.SetMaterial( tickMat )
                    local iconSize = 64
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end
            end
        end
    end

    self.bottomBar:Clear()

    surface.SetFont( "BRICKS_SERVER_Font22" )
    local text = not todayClaimed and BRICKS_SERVER.Func.L( "unboxingClaim" ) or BRICKS_SERVER.Func.L( "unboxingClaimed" )
    local textX, textY = surface.GetTextSize( text )
    local totalContentW = 16+5+textX

    local claimButton = vgui.Create( "DButton", self.bottomBar )
    claimButton:SetSize( totalContentW+65, 45 )
    claimButton:SetPos( self.panelWide-25-claimButton:GetWide(), (self.bottomBar:GetTall()/2)-(claimButton:GetTall()/2) )
    claimButton:SetText( "" )
    local alpha = 0
    local tickMat = Material( "bricks_server/unboxing_tick.png" )
    claimButton.Paint = function( self2, w, h )
        local buttonColor, downColor = BRICKS_SERVER.DEVCONFIG.BaseThemes.Green, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen
        if( todayClaimed ) then
            buttonColor, downColor = BRICKS_SERVER.Func.GetTheme( 1 ), BRICKS_SERVER.Func.GetTheme( 0 )
        end

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        draw.RoundedBox( 8, 0, 0, w, h, buttonColor )

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBox( 8, 0, 0, w, h, downColor )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, downColor, 8 )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        surface.SetMaterial( tickMat )
        local iconSize = 16
        surface.DrawTexturedRect( (w/2)-(totalContentW/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( text, "BRICKS_SERVER_Font22", (w/2)-(totalContentW/2)+iconSize+5, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    end
    claimButton.DoClick = function()
        if( LocalPlayer():GetUnboxingRewardsTodayClaimed() ) then return end

        net.Start( "BRS.Net.ClaimUnboxingRewards" )
        net.SendToServer()
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_rewards", PANEL, "DPanel" )
