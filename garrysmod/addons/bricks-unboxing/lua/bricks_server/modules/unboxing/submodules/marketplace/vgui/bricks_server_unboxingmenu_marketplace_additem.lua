local PANEL = {}

function PANEL:Init()

end

function PANEL:CreatePopout()
    self.panelWide, self.panelTall = self:GetSize()
    self.popoutWide, self.popoutTall = self.panelWide*0.9, self.panelTall*0.9

    self.popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall, self.popoutWide, self.popoutTall )
    self.popoutPanel.OnRemove = function()
        self:Remove()
    end

    self.stepPanels = {}

    self.closeButton = vgui.Create( "DButton", self.popoutPanel )
    self.closeButton:Dock( BOTTOM )
    self.closeButton:SetTall( 40 )
    self.closeButton:SetText( "" )
    self.closeButton:DockMargin( 25, 0, 25, 25 )
    local changeAlpha = 0
    self.closeButton.Paint = function( self2, w, h )
        if( not self2:IsDown() and self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
        end
        
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )

        surface.SetAlphaMultiplier( changeAlpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        
        draw.SimpleText( BRICKS_SERVER.Func.L( "cancel" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    self.closeButton.DoClick = self.popoutPanel.ClosePopout

    self.topBar = vgui.Create( "DPanel", self.popoutPanel )
    self.topBar:Dock( TOP )
    self.topBar:DockMargin( 25, 25, 25, 25 )
    self.topBar:SetTall( 32 )
    local progressPercentW = 0
    self.topBar.Paint = function( self2, w, h ) 
        local stepPanel = self.stepPanels[self.currentStep] or {}

        progressPercentW = Lerp( FrameTime()*20, progressPercentW, ((self.currentStep-1)/#self.stepPanels)*w )

        draw.RoundedBox( h/2, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
        renderStartX, renderStartY, renderEndX, renderEndY = toScreenX, toScreenY, toScreenX+progressPercentW, toScreenY+h

        local text = BRICKS_SERVER.Func.L( "unboxingAuctionListing", math.floor( ((self.currentStep-1)/#self.stepPanels)*100 ) )
        draw.SimpleText( text, "BRICKS_SERVER_Font23", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        render.SetScissorRect( renderStartX, renderStartY, renderEndX, renderEndY, true )
            draw.RoundedBox( h/2, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
            draw.SimpleText( text, "BRICKS_SERVER_Font23", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        render.SetScissorRect( 0, 0, 0, 0, false )
    end

    self.inventoryPanel = self:CreateStep( 1, BRICKS_SERVER.Func.L( "unboxingItemSelection" ) )

    local searchBar = vgui.Create( "bricks_server_searchbar", self.inventoryPanel )
    searchBar:Dock( TOP )
    searchBar:DockMargin( 10, 10, 10, 0 )
    searchBar:SetTall( 40 )
    searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
    searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 1 ) )

    local scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.inventoryPanel )
    scrollPanel:Dock( FILL )
    scrollPanel:DockMargin( 10, 10, 10, 10 )
    scrollPanel:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 2 ) )

    local gridWide = self.popoutWide-50-20-10-5
    local slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 175 ) )
    local spacing = 5
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    local grid = vgui.Create( "DIconLayout", scrollPanel )
    grid:Dock( TOP )
    grid:SetSpaceY( spacing )
    grid:SetSpaceX( spacing )

    local sortChoice = "rarity_high_to_low"
    function self.RefreshInventory()
        grid:Clear()

        local sortedItems = {}
        for k, v in pairs( LocalPlayer():GetUnboxingInventory() ) do
            local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )

            if( not configItemTable ) then continue end
    
            if( searchBar:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( searchBar:GetValue() ) ) ) then
                continue
            end
            
            local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( configItemTable.Rarity or "" )
            
            table.insert( sortedItems, { rarityKey, k, v } )
        end
    
        if( sortChoice == "rarity_high_to_low" ) then
            table.SortByMember( sortedItems, 1, false )
        elseif( sortChoice == "rarity_low_to_high" ) then
            table.SortByMember( sortedItems, 1, true )
        end
    
        grid:SetTall( (math.ceil(#sortedItems/slotsWide)*(slotSize+spacing))-spacing )
    
        for k, v in pairs( sortedItems ) do
            local globalKey, itemAmount  = v[2], v[3]
            local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
    
            if( not configItemTable ) then continue end

            local slotBack = grid:Add( "bricks_server_unboxingmenu_itemslot" )
            slotBack:SetSize( slotSize, slotSize*1.2 )
            slotBack:FillPanel( globalKey, (itemAmount or 1), function()
                self.selectedItem = globalKey
                self:SetCurrentStep( 2 )
            end )
            slotBack.themeNum = 2
        end
    end
    self.RefreshInventory()

    searchBar.OnChange = function()
        self.RefreshInventory()
    end

    self.infoPanel = self:CreateStep( 2, BRICKS_SERVER.Func.L( "unboxingItemDetails" ) )
    self.infoPanel.titleW = 0
    self.infoPanel.createEntry = function( title )
        surface.SetFont( "BRICKS_SERVER_Font20" )
        local textX = surface.GetTextSize( title )

        self.infoPanel.titleW = math.max( self.infoPanel.titleW, textX+20 )

        local entryPanel = vgui.Create( "DPanel", self.infoPanel )
        entryPanel:Dock( TOP )
        entryPanel:DockMargin( 10, 10, 10, 0 )
        entryPanel:SetTall( 40 )
        entryPanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

            draw.RoundedBoxEx( 8, 0, 0, self.infoPanel.titleW, h, BRICKS_SERVER.Func.GetTheme( 0, 175 ), true, false, true, false )

            draw.SimpleText( title, "BRICKS_SERVER_Font20", self.infoPanel.titleW/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        return entryPanel
    end

    local amountSelector = self.infoPanel.createEntry( BRICKS_SERVER.Func.L( "unboxingItemAmount" ) )
    local priceSelector = self.infoPanel.createEntry( BRICKS_SERVER.Func.L( "unboxingStartingPrice" ) )
    local durationSelector = self.infoPanel.createEntry( BRICKS_SERVER.Func.L( "unboxingDuration" ) )

    local innerPanelW = (self.popoutWide-50-20)-self.infoPanel.titleW

    self.itemAmount = 1
    local amountSlider = vgui.Create( "bricks_server_dnumslider", amountSelector )
    amountSlider:SetSize( innerPanelW*0.5, amountSelector:GetTall() )
    amountSlider:SetPos( self.infoPanel.titleW+(innerPanelW/2)-(amountSlider:GetWide()/2), (amountSelector:GetTall()/2)-(amountSlider:GetTall()/2) )
    amountSlider:SetMin( 1 )
    amountSlider:SetMax( 1 )
    amountSlider:SetValue( 1 )
    amountSlider.OnValueChanged = function( self2, value )
        self.itemAmount = math.floor( value )
    end

    local priceEntryBack = vgui.Create( "DPanel", priceSelector )
    priceEntryBack:Dock( FILL )
    priceEntryBack:DockMargin( self.infoPanel.titleW, 0, 0, 0 )
    local alpha = 0
    priceEntryBack.Paint = function( self2, w, h )
        if( IsValid( self2.entry ) and self2.entry:IsEditing() ) then
            alpha = math.Clamp( alpha+5, 0, 100 )
        else
            alpha = math.Clamp( alpha-5, 0, 100 )
        end
        
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, alpha ), false, true, false, true )
    end

    self.itemPrice = BRICKS_SERVER.CONFIG.UNBOXING["Auction Minimum Starting Price"]
    priceEntryBack.entry = vgui.Create( "bricks_server_numberwang", priceEntryBack )
    priceEntryBack.entry:Dock( FILL )
    priceEntryBack.entry:SetMinMax( BRICKS_SERVER.CONFIG.UNBOXING["Auction Minimum Starting Price"], BRICKS_SERVER.CONFIG.UNBOXING["Auction Maximum Starting Price"] )
    priceEntryBack.entry:SetValue( BRICKS_SERVER.CONFIG.UNBOXING["Auction Minimum Starting Price"] )
    priceEntryBack.entry.OnValueChanged = function( self2, value )
        self.itemPrice = tonumber( value )
    end

    local durationEntryBack = vgui.Create( "DPanel", durationSelector )
    durationEntryBack:Dock( FILL )
    durationEntryBack:DockMargin( self.infoPanel.titleW, 0, 0, 0 )
    local alpha = 0
    durationEntryBack.Paint = function( self2, w, h )
        if( IsValid( self2.entry ) and self2.entry:IsEditing() ) then
            alpha = math.Clamp( alpha+5, 0, 100 )
        else
            alpha = math.Clamp( alpha-5, 0, 100 )
        end
        
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, alpha ), false, true, false, true )
    end

    self.auctionDuration = BRICKS_SERVER.CONFIG.UNBOXING["Auction Minimum Duration"]
    durationEntryBack.entry = vgui.Create( "bricks_server_numberwang", durationEntryBack )
    durationEntryBack.entry:Dock( FILL )
    durationEntryBack.entry:SetMinMax( BRICKS_SERVER.CONFIG.UNBOXING["Auction Minimum Duration"], BRICKS_SERVER.CONFIG.UNBOXING["Auction Maximum Duration"] )
    durationEntryBack.entry:SetValue( BRICKS_SERVER.CONFIG.UNBOXING["Auction Minimum Duration"] )
    durationEntryBack.entry.OnValueChanged = function( self2, value )
        self.auctionDuration = tonumber( value )
    end

    self.infoPanel.refresh = function()
        amountSlider:SetMax( LocalPlayer():GetUnboxingInventory()[self.selectedItem] or 1 )
        amountSlider:SetValue( 1 )
    end

    local nextStepButton = vgui.Create( "DButton", self.infoPanel )
    nextStepButton:Dock( TOP )
    nextStepButton:DockMargin( 10, 10, 10, 10 )
    nextStepButton:SetTall( 40 )
    nextStepButton:SetText( "" )
    local alpha = 0
    nextStepButton.Paint = function( self2, w, h )
        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+5, 0, 150 )
        else
            alpha = math.Clamp( alpha-5, 0, 150 )
        end

        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, 75 ), true, true, not expanded, not expanded )

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, not expanded, not expanded )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ), 8 )

        draw.SimpleText( BRICKS_SERVER.Func.L( "nextStep" ), "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    nextStepButton.DoClick = function()
        local isValid, errMessage = self:IsInfoValid()

        if( isValid ) then
            self:SetCurrentStep( 3 )
        else
            BRICKS_SERVER.Func.CreateTopNotification( errMessage, 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
        end
    end

    self.confirmPanel = self:CreateStep( 3, BRICKS_SERVER.Func.L( "unboxingConfirmation" ) )

    local slotTall = self.popoutTall-self.closeButton:GetTall()-25-self.topBar:GetTall()-50-25-((#self.stepPanels-1)*40)-((#self.stepPanels-1)*5)-40-50

    local confirmSlot = vgui.Create( "bricks_server_unboxingmenu_itemslot", self.confirmPanel )
    confirmSlot:SetSize( slotTall/1.2, slotTall )
    confirmSlot:SetPos( 25, 40+25 )
    confirmSlot.themeNum = 2

    local confirmRightPanel = vgui.Create( "DPanel", self.confirmPanel )
    confirmRightPanel:Dock( FILL )
    confirmRightPanel:DockMargin( confirmSlot:GetWide()+50, 25, 25, 25 )
    confirmRightPanel:DockPadding( 0, 25, 0, 0 )
    confirmRightPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, 75 ) )
    end

    local rightPanelW = self.popoutWide-50-75-confirmSlot:GetWide()

    local confirmRightInfoBack = vgui.Create( "DPanel", confirmRightPanel )
    confirmRightInfoBack:SetSize( rightPanelW, 0 )
    confirmRightInfoBack:SetPos( (rightPanelW/2)-(confirmRightInfoBack:GetWide()/2), ((slotTall-40)/2)-(confirmRightInfoBack:GetTall()/2) )
    confirmRightInfoBack.Paint = function( self2, w, h ) end
    confirmRightInfoBack.AddInfo = function( header, text )
        surface.SetFont( "BRICKS_SERVER_Font20" )
        local textX, textY = surface.GetTextSize( text )

        surface.SetFont( "BRICKS_SERVER_Font17" )
        local headerX, headerY = surface.GetTextSize( header )

        local boxW = math.max( headerX, textX )+25
        local bottomH = 20

        local confirmRightInfo = vgui.Create( "DPanel", confirmRightInfoBack )
        confirmRightInfo:Dock( TOP )
        confirmRightInfo:SetTall( 35+bottomH )
        confirmRightInfo:DockMargin( 25, 0, 25, 10 )
        confirmRightInfo.Paint = function( self2, w, h )
            draw.RoundedBox( 8, (w/2)-(boxW/2), 0, boxW, h, BRICKS_SERVER.Func.GetTheme( 2, 200 ) )
    
            draw.SimpleText( text, "BRICKS_SERVER_Font20", w/2, (h-bottomH)/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            draw.RoundedBoxEx( 8, (w/2)-(boxW/2), h-bottomH, boxW, bottomH, BRICKS_SERVER.Func.GetTheme( 1, 200 ), false, false, true, true )
            draw.SimpleText( header, "BRICKS_SERVER_Font17", w/2, h-(bottomH/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        confirmRightInfoBack:SetTall( confirmRightInfoBack:GetTall()+((confirmRightInfoBack:GetTall() > 0 and 10) or 0)+confirmRightInfo:GetTall() )
        confirmRightInfoBack:SetPos( (rightPanelW/2)-(confirmRightInfoBack:GetWide()/2), ((slotTall-40)/2)-(confirmRightInfoBack:GetTall()/2) )
    end

    confirmRightInfoBack.AddInfo( BRICKS_SERVER.Func.L( "unboxingStartingPrice" ), BRICKS_SERVER.UNBOXING.Func.FormatCurrency( self.itemPrice or 0 ) )
    confirmRightInfoBack.AddInfo( BRICKS_SERVER.Func.L( "unboxingAuctionDuration" ), BRICKS_SERVER.Func.FormatTime( self.auctionDuration or 0 ) )

    local submitButton = vgui.Create( "DButton", confirmRightPanel )
    submitButton:Dock( BOTTOM )
    submitButton:SetTall( 40 )
    submitButton:SetText( "" )
    local alpha = 0
    submitButton.Paint = function( self2, w, h )
        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green, false, false, true, true )

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen, false, false, true, true )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen, 8 )

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingSubmitAuction" ), "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    submitButton.DoClick = function()
        if( not self.slot ) then return end

        local isValid, errMessage = self:IsInfoValid()

        if( isValid ) then
            net.Start( "BRS.Net.SellUnboxingMarketplaceItem" )
                net.WriteUInt( self.slot, 8 )
                net.WriteString( self.selectedItem )
                net.WriteUInt( self.itemAmount, 16 )
                net.WriteUInt( self.itemPrice, 32 )
                net.WriteUInt( self.auctionDuration, 32 )
            net.SendToServer()

            self.popoutPanel.ClosePopout()
        else
            BRICKS_SERVER.Func.CreateTopNotification( errMessage, 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
        end
    end

    self.confirmPanel.refresh = function()
        confirmSlot:FillPanel( self.selectedItem, (self.itemAmount or 1) )

        confirmRightInfoBack:SetTall( 0 )
        confirmRightInfoBack:Clear()
        confirmRightInfoBack.AddInfo( BRICKS_SERVER.Func.L( "unboxingStartingPrice" ), BRICKS_SERVER.UNBOXING.Func.FormatCurrency( self.itemPrice or 0 ) )
        confirmRightInfoBack.AddInfo( BRICKS_SERVER.Func.L( "unboxingAuctionDuration" ), BRICKS_SERVER.Func.FormatTime( self.auctionDuration or 0 ) )
    end

    self:SetCurrentStep( 1 )
end

function PANEL:IsInfoValid()
    if( not self.selectedItem ) then return false, BRICKS_SERVER.Func.L( "unboxingNoItemSelected" ) end

    if( self.itemAmount > (LocalPlayer():GetUnboxingInventory()[self.selectedItem] or 1) ) then
        return false, BRICKS_SERVER.Func.L( "unboxingNotEnoughItem" )
    end

    if( self.itemPrice < BRICKS_SERVER.CONFIG.UNBOXING["Auction Minimum Starting Price"] or self.itemPrice > BRICKS_SERVER.CONFIG.UNBOXING["Auction Maximum Starting Price"] ) then
        return false, BRICKS_SERVER.Func.L( "unboxingStartingPriceTooLowHigh" )
    end

    if( self.auctionDuration < BRICKS_SERVER.CONFIG.UNBOXING["Auction Minimum Duration"] or self.auctionDuration > BRICKS_SERVER.CONFIG.UNBOXING["Auction Maximum Duration"] ) then
        return false, BRICKS_SERVER.Func.L( "unboxingDurationTooShortLong" )
    end

    return true
end

function PANEL:SetCurrentStep( num )
    if( self.currentStep ) then
        self.stepPanels[self.currentStep]:SizeTo( self.popoutWide-50, 40, 0.2 )
        self.stepPanels[self.currentStep].header.DoAnim( false )
    end

    self.currentStep = num

    local stepTall = self.popoutTall-self.closeButton:GetTall()-25-self.topBar:GetTall()-50-25-((#self.stepPanels-1)*40)-((#self.stepPanels-1)*5)
    self.stepPanels[num]:SizeTo( self.popoutWide-50, stepTall, 0.2 )
    self.stepPanels[num].header.DoAnim( true )

    if( self.stepPanels[num].refresh ) then
        self.stepPanels[num].refresh()
    end
end

function PANEL:CreateStep( num, title )
    self.stepPanels[num] = vgui.Create( "DPanel", self.popoutPanel )
    self.stepPanels[num]:Dock( TOP )
    self.stepPanels[num]:DockMargin( 25, 0, 25, 5 )
    self.stepPanels[num]:SetTall( 40 )
    self.stepPanels[num].Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 200 ) )
    end

    self.stepPanels[num].title = title

    self.stepPanels[num].header = vgui.Create( "DButton", self.stepPanels[num] )
    self.stepPanels[num].header:Dock( TOP )
    self.stepPanels[num].header:SetTall( self.stepPanels[num]:GetTall() )
    self.stepPanels[num].header:SetText( "" )
    local alpha = 0
    local arrow = Material( "bricks_server/down_16.png" )
    self.stepPanels[num].header.textureRotation = -90
    self.stepPanels[num].header.Paint = function( self2, w, h )
        local expanded = self.stepPanels[num]:GetTall() > 40

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+5, 0, 150 )
        else
            alpha = math.Clamp( alpha-5, 0, 150 )
        end

        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, 75 ), true, true, not expanded, not expanded )

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, not expanded, not expanded )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ), 8 )

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingStepXTitle", num, title ), "BRICKS_SERVER_Font20", 15, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        surface.SetMaterial( arrow )
        local iconSize = 16
        surface.DrawTexturedRectRotated( w-((h-iconSize)/2)-(iconSize/2), h/2, iconSize, iconSize, math.Clamp( (self2.textureRotation or 0), -90, 0 ) )
    end
    self.stepPanels[num].header.DoAnim = function( expanding )
        local anim = self.stepPanels[num].header:NewAnimation( 0.2, 0, -1 )
    
        anim.Think = function( anim, pnl, fraction )
            if( expanding ) then
                self.stepPanels[num].header.textureRotation = (1-fraction)*-90
            else
                self.stepPanels[num].header.textureRotation = fraction*-90
            end
        end
    end
    self.stepPanels[num].header.DoClick = function()
        if( self.currentStep <= num ) then return end

        self:SetCurrentStep( num )
    end

    return self.stepPanels[num]
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_marketplace_additem", PANEL, "DPanel" )