local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW()*0.1, 30+10+50 )
    self:MakePopup()

    self.panelInfo = vgui.Create( "DPanel", self )
    self.panelInfo:Dock( FILL )
    self.panelInfo:SetSize( self:GetWide(), self:GetTall() )
    self.panelInfo.Paint = function( self2, w, h ) end

    self.buttonPanel = vgui.Create( "DPanel", self.panelInfo )
    self.buttonPanel:Dock( TOP )
    self.buttonPanel:SetTall( 30 )
    self.buttonPanel.Paint = function( self2, w, h ) end
    local buttons = {}
    local activePanel
    self.buttonPanel.AddButton = function( text, panel )
        if( activePanel ) then
            panel:SetVisible( false )
        else
            activePanel = panel
        end

        local button = vgui.Create( "DButton", self.buttonPanel )
        button:Dock( LEFT )
        button:SetText( "" )
        button.buttonPos = #buttons+1
        button.panel = panel
        local alpha = 0
        button.Paint = function( self2, w, h )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), button.buttonPos == 1, button.buttonPos == #buttons, false, false )
    
            if( activePanel == panel ) then
                alpha = math.Clamp( alpha+10, 0, 255 )
            elseif( self2:IsHovered() and alpha <= 100 ) then
                if( alpha < 100 ) then
                    alpha = math.Clamp( alpha+10, 0, 255 )
                end
            else
                alpha = math.Clamp( alpha-10, 0, 255 )
            end
    
            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), button.buttonPos == 1, button.buttonPos == #buttons, false, false )
            surface.SetAlphaMultiplier( 1 )
    
            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), 8 )

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5, alpha ) )
            surface.DrawRect( 0, h-3, w, 3 )
    
            draw.SimpleText( text, "BRICKS_SERVER_Font20", w/2, (h-3)/2, BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        button.DoClick = function()
            if( activePanel == panel ) then return end

            activePanel:SetVisible( false )

            activePanel = panel
            panel:SetVisible( true )
        end
        
        table.insert( buttons, button )
    end

    self.itemPanel = vgui.Create( "DPanel", self.panelInfo )
    self.itemPanel:Dock( FILL )
    self.itemPanel.Paint = function( self2, w, h ) end

    self.buttonPanel.AddButton( BRICKS_SERVER.Func.L( "unboxingITEM" ), self.itemPanel )

    self.biddersPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.panelInfo )
    self.biddersPanel:Dock( FILL )
    self.biddersPanel:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.biddersPanel:SetBarColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
    self.biddersPanel:SetBarDownColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
    self.biddersPanel:GetVBar():SetRounded( 0 )
    self.biddersPanel.Paint = function( self2, w, h ) 
        if( (self2.entries or 0) <= 0 ) then
            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingNoBids" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    self.buttonPanel.AddButton( BRICKS_SERVER.Func.L( "unboxingBIDS" ), self.biddersPanel )

    for k, v in pairs( buttons ) do
        v:SetWide( self.panelInfo:GetWide()/#buttons )
    end
end

function PANEL:FillPanel( globalKey, amount, actions, marketItemTable )
    local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )

    local ownerName = BRICKS_SERVER.Func.L( "unknown" )
    steamworks.RequestPlayerInfo( marketItemTable.OwnerSteamID64, function( steamName )
        ownerName = steamName
    end )

    local ownerEntry = vgui.Create( "DPanel", self.itemPanel )
    ownerEntry:Dock( TOP )
    ownerEntry:SetTall( 50 )
    ownerEntry.Paint = function( self2, w, h )
        draw.SimpleText( ownerName, "BRICKS_SERVER_Font20", h+5, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( BRICKS_SERVER.Func.L( "seller" ), "BRICKS_SERVER_Font17", h+6, h/2-2, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )
    end

    local ownerAvatar = vgui.Create( "bricks_server_circle_avatar", ownerEntry )
    ownerAvatar:Dock( LEFT )
    ownerAvatar:DockMargin( 5, 5, 5, 5 )
    ownerAvatar:SetWide( ownerEntry:GetTall()-10 )
    ownerAvatar:SetSteamID( marketItemTable.OwnerSteamID64, 32 )

    local info = {}
    if( configItemTable ) then
        local rarityBox = vgui.Create( "bricks_server_raritybox", self.panelInfo )
        rarityBox:Dock( BOTTOM )
        rarityBox:SetSize( self.panelInfo:GetWide(), 10 )
        rarityBox:SetRarityName( configItemTable.Rarity or "" )
        rarityBox:SetCornerRadius( 8 )
        rarityBox:SetRoundedBoxDimensions( false, -10, false, 20 )

        info = {
            { BRICKS_SERVER.Func.L( "name" ), configItemTable.Name },
            { BRICKS_SERVER.Func.L( "unboxingRarity" ), configItemTable.Rarity },
            { BRICKS_SERVER.Func.L( "unboxingAmount" ), amount },
            { BRICKS_SERVER.Func.L( "unboxingDuration" ), BRICKS_SERVER.Func.FormatTime( math.max( 0, (marketItemTable.StartTime+marketItemTable.Duration)-BRICKS_SERVER.Func.UTCTime() ) ) },
            { BRICKS_SERVER.Func.L( "unboxingHighestBid" ), BRICKS_SERVER.UNBOXING.Func.FormatCurrency( marketItemTable.CurrentBid or 0 ) }
        }

        for k, v in ipairs( info ) do
            local infoEntry = vgui.Create( "DPanel", self.itemPanel )
            infoEntry:Dock( TOP )
            infoEntry:SetTall( 30 )
            infoEntry.Paint = function( self2, w, h )
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( (k % 2 != 0) and 2 or 3 ) )
                surface.DrawRect( 0, 0, w, h )

                draw.SimpleText( v[1] .. ": " .. v[2], "BRICKS_SERVER_Font20", 10, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
            end
        end
    end

    for k, v in ipairs( actions ) do
        local actionButton = vgui.Create( "DButton", self.itemPanel )
        actionButton:Dock( BOTTOM )
        actionButton:DockMargin( 10, 0, 10, 10 )
        actionButton:SetTall( 35 )
        actionButton:SetText( "" )
        local alpha = 0
        actionButton.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 200 )
            else
                alpha = math.Clamp( alpha-10, 0, 200 )
            end

            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

            draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        actionButton.DoClick = function()
            v[2]()
        end
    end

    self:SetTall( self:GetTall()+(#info*30)+(#actions*45)+10 )

    local sortedBidders = {}
    for k, v in pairs( marketItemTable.Bidders ) do
        table.insert( sortedBidders, { k, v[1] } )
    end

    table.SortByMember( sortedBidders, 2 )

    self.biddersPanel.entries = 0
    for k, v in ipairs( sortedBidders ) do
        self.biddersPanel.entries = self.biddersPanel.entries+1

        local steamID = util.SteamIDTo64( v[1] )

        local bidderName = BRICKS_SERVER.Func.L( "unknown" )
        steamworks.RequestPlayerInfo( steamID, function( steamName )
            bidderName = steamName
        end )

        local bidderEntry = vgui.Create( "DPanel", self.biddersPanel )
        bidderEntry:Dock( TOP )
        bidderEntry:SetTall( 50 )
        bidderEntry.Paint = function( self2, w, h )
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( (k % 2 == 0) and 2 or 3 ) )
            surface.DrawRect( 0, 0, w, h )

            draw.SimpleText( bidderName, "BRICKS_SERVER_Font20", h+5, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
            draw.SimpleText( BRICKS_SERVER.UNBOXING.Func.FormatCurrency( v[2] ), "BRICKS_SERVER_Font17", h+6, h/2-2, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )
        end

        local bidderAvatar = vgui.Create( "bricks_server_circle_avatar", bidderEntry )
        bidderAvatar:Dock( LEFT )
        bidderAvatar:DockMargin( 5, 5, 5, 5 )
        bidderAvatar:SetWide( bidderEntry:GetTall()-10 )
        bidderAvatar:SetSteamID( steamID, 64 )
    end
end

function PANEL:Paint( w, h )
    local x, y = self:LocalToScreen( 0, 0 )

    BRICKS_SERVER.BSHADOWS.BeginShadow()
    draw.RoundedBox( 8, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )	
    BRICKS_SERVER.BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )
end

vgui.Register( "bricks_server_unboxingmenu_marketplace_view", PANEL, "DPanel" )