local PANEL = {}

function PANEL:Init()

end

function PANEL:CreatePopout()
    self.panelTall = self.panelTall or (ScrH()*0.75-90); self.panelWide = self.panelWide or self:GetWide()

    self.popoutWide, self.popoutTall = self.panelWide*0.4, self.panelTall*0.9

    self.popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall, self.popoutWide, self.popoutTall )
    self.popoutPanel.Paint = function( self2, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end
    self.popoutPanel.OnRemove = function()
        self:Remove()
    end

    self.mainPanel = vgui.Create( "DPanel", self.popoutPanel )
    self.mainPanel:Dock( FILL )
    self.mainPanel.Paint = function( self2, w, h ) end

    self.closeButton = vgui.Create( "DButton", self.mainPanel )
    self.closeButton:Dock( BOTTOM )
    self.closeButton:SetTall( 40 )
    self.closeButton:SetText( "" )
    self.closeButton:DockMargin( 25, 0, 25, 25 )
    local changeAlpha = 0
    self.closeButton.Paint = function( self2, w, h )
        if( not self2:IsDown() and self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
        end
        
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )

        surface.SetAlphaMultiplier( changeAlpha/255 )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ), 8 )
        
        draw.SimpleText( BRICKS_SERVER.Func.L( "close" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    self.closeButton.DoClick = self.popoutPanel.ClosePopout

    self.topPanel = vgui.Create( "DPanel", self.mainPanel )
    self.topPanel:Dock( TOP )
    self.topPanel:SetTall( self.popoutTall*0.3 )
    self.topPanel.Paint = function( self2, w, h ) 
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), true, true, false, false )
    end

    self.centerBack = vgui.Create( "DPanel", self.mainPanel )
    self.centerBack:Dock( FILL )
    self.centerBack:DockMargin( 25, 25, 25, 25 )
    self.centerBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        draw.RoundedBoxEx( 8, 0, 40, w, h-40, BRICKS_SERVER.Func.GetTheme( 3, 125 ), false, false, true, true )

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingUnlocks" ), "BRICKS_SERVER_Font21", w/2, 40/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local gridWide = self.popoutWide-50-20-20
    local slotsWide = math.floor( gridWide/125 )
    local spacing = 10
    self.slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    local itemsScroll = vgui.Create( "bricks_server_scrollpanel_bar", self.centerBack )
    itemsScroll:Dock( FILL )
    itemsScroll:DockMargin( 10, 50, 10, 10 )
    itemsScroll:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    itemsScroll.Paint = function( self, w, h ) end 

    self.itemsGrid = vgui.Create( "DIconLayout", itemsScroll )
    self.itemsGrid:Dock( FILL )
    self.itemsGrid:SetSpaceY( spacing )
    self.itemsGrid:SetSpaceX( spacing )
end

function PANEL:FillPanel( itemKey, buttonFunc, inventoryView )
    self.itemsGrid:Clear()

    local keyTable = BRICKS_SERVER.CONFIG.UNBOXING.Keys[itemKey]
    if( not keyTable ) then return end

    self.buttonFunc = buttonFunc
    self.inventoryView = inventoryView

    if( not self.inventoryView ) then
        surface.SetFont( "BRICKS_SERVER_Font21" )
        local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingAddToCart" ) )
        local totalContentW = 16+5+textX

        local addToCart = vgui.Create( "DButton", self.mainPanel )
        addToCart:Dock( BOTTOM )
        addToCart:DockMargin( 25, 0, 25, 10 )
        addToCart:SetTall( 40 )
        addToCart:SetText( "" )
        local alpha = 0
        local addToCartMat = Material( "bricks_server/unboxing_cart_16.png" )
        addToCart.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 125 )
            else
                alpha = math.Clamp( alpha-10, 0, 125 )
            end

            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ), 8 )

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
            surface.SetMaterial( addToCartMat )
            local iconSize = 16
            surface.DrawTexturedRect( (w/2)-(totalContentW/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingAddToCart" ), "BRICKS_SERVER_Font21", (w/2)-(totalContentW/2)+iconSize+5, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        end
        addToCart.DoClick = function()
            self.buttonFunc()
        end
    end

    local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( keyTable.Rarity )

    local keyName = vgui.Create( "DPanel", self.topPanel )
    keyName:Dock( BOTTOM )
    keyName:DockMargin( 0, 0, 0, 10 )
    keyName:SetTall( 60 )
    keyName.Paint = function( self2, w, h ) 
        draw.SimpleText( keyTable.Name, "BRICKS_SERVER_Font23", w/2, (h/2)+2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        
        draw.SimpleText( (keyTable.Rarity or ""), "BRICKS_SERVER_Font20", w/2, (h/2)-2, BRICKS_SERVER.Func.GetRarityColor( rarityInfo ), TEXT_ALIGN_CENTER, 0 )
    end

    local keyModel = vgui.Create( "bricks_server_unboxing_itemdisplay", self.topPanel )
    keyModel:SetSize( self.topPanel:GetTall()-10, self.topPanel:GetTall()-10-keyName:GetTall() )
    keyModel:SetPos( (self.popoutWide/2)-(keyModel:GetWide()/2), 0 )
    keyModel:SetItemData( "KEY", keyTable )
    keyModel:SetIconSizeAdjust( 0.8 )

    local rarityBox = vgui.Create( "bricks_server_raritybox", self.topPanel )
    rarityBox:SetSize( self.popoutWide, 10 )
    rarityBox:SetPos( 0, self.topPanel:GetTall()-rarityBox:GetTall() )
    rarityBox:SetRarityName( keyTable.Rarity or "" )
    rarityBox:SetCornerRadius( 0 )

    local sortedItems = {}
    for k, v in pairs( BRICKS_SERVER.CONFIG.UNBOXING.Cases ) do
        if( not v.Keys or not v.Keys[itemKey] ) then continue end

        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
        
        table.insert( sortedItems, { rarityKey, "CASE_" .. k } )
    end

    table.SortByMember( sortedItems, 1, false )

    for k, v in pairs( sortedItems ) do
        local slotBack = self.itemsGrid:Add( "bricks_server_unboxingmenu_itemslot" )
        slotBack:SetSize( self.slotSize, self.slotSize*1.2 )
        slotBack:FillPanel( v[2], 1, {} )
        slotBack.themeNum = 1
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_keyview_popup", PANEL, "DPanel" )