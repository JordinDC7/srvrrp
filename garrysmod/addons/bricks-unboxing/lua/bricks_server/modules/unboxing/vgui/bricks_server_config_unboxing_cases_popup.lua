local PANEL = {}

function PANEL:Init()
    if self.panelWide == nil or self.panelWide < 100 then self.panelWide = self:GetWide() end; if self.panelWide < 100 then self.panelWide = ScrW() * 0.72 + 200 - 220 end; if self.panelTall == nil or self.panelTall < 100 then self.panelTall = self:GetTall() end; if self.panelTall < 100 then self.panelTall = ScrH() * 0.75 - 130 end

    self.popoutWide, self.popoutTall = self.panelWide*0.9, self.panelTall*0.9

    self.popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall, self.popoutWide, self.popoutTall )
    self.popoutPanel.Paint = function( self2, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    end
    self.popoutPanel.OnRemove = function()
        self:Remove()
    end

    self.topPanel = vgui.Create( "DPanel", self.popoutPanel )
    self.topPanel:Dock( TOP )
    self.topPanel:SetTall( self.popoutTall*0.3 )
    self.topPanel.Paint = function( self2, w, h ) 
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), true, true, false, false )
    end

    local closeButton = vgui.Create( "DButton", self.popoutPanel )
    closeButton:Dock( BOTTOM )
    closeButton:SetTall( 40 )
    closeButton:SetText( "" )
    closeButton:DockMargin( 25, 25, 25, 25 )
    local changeAlpha = 0
    closeButton.Paint = function( self2, w, h )
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
        
        draw.SimpleText( BRICKS_SERVER.Func.L( "close" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    closeButton.DoClick = self.popoutPanel.ClosePopout

    self.navigationPanel = vgui.Create( "DPanel", self.popoutPanel )
    self.navigationPanel:Dock( TOP )
    self.navigationPanel:SetTall( 50 )
    self.navigationPanel.Paint = function( self2, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, 125 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    self.navigationContent = vgui.Create( "DPanel", self.popoutPanel )
    self.navigationContent:Dock( FILL )
    self.navigationContent.Paint = function( self2, w, h ) end

    self.pages = {}
end

function PANEL:AddPage( title, panel )
    local pageKey = #self.pages+1

    local pageButton = vgui.Create( "DButton", self.navigationPanel )
    pageButton:Dock( LEFT )
    pageButton:SetText( "" )
    local alpha = 0
    pageButton.Paint = function( self2, w, h )
        if( self.activePage == pageKey ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        elseif( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 150 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), 8 )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5, alpha ) )
        surface.DrawRect( 0, h-5, w, 5 )

        draw.SimpleText( title, "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 75+(180*(alpha/150)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    pageButton.DoClick = function()
        self.pages[self.activePage][1]:SetVisible( false )
        panel:SetVisible( true )
        self.activePage = pageKey
    end

    table.insert( self.pages, { panel, pageButton } )

    if( self.activePage ) then
        panel:SetVisible( false )
    else
        self.activePage = pageKey
    end

    for k, v in ipairs( self.pages ) do
        v[2]:SetWide( self.popoutWide/#self.pages )
    end
end

function PANEL:SetItemTable( itemKey, oldItemTable, closeFunc, removeFunc, duplicateFunc )
    local valueChanged = false
    local itemTable = table.Copy( oldItemTable )

    self.popoutPanel.OnRemove = function()
        self:Remove()

        closeFunc( valueChanged, itemTable )
    end

    local buttonBack = vgui.Create( "DPanel", self.topPanel )
    buttonBack:SetSize( 0, 40 )
    buttonBack:SetPos( self.popoutWide-10-buttonBack:GetWide(), 10 )
    buttonBack.Paint = function( self2, w, h ) end
    buttonBack.AddButton = function( iconMat, func, color, downColor )
        local button = vgui.Create( "DButton", buttonBack )
        button:Dock( RIGHT )
        button:DockMargin( 5, 0, 0, 0 )
        button:SetWide( buttonBack:GetTall() )
        button:SetText( "" )
        local alpha = 0
        button.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 150 )
            else
                alpha = math.Clamp( alpha-10, 0, 150 )
            end
    
            draw.RoundedBox( 8, 0, 0, w, h, color or BRICKS_SERVER.Func.GetTheme( 3, 125 ) )
    
            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBox( 8, 0, 0, w, h, downColor or BRICKS_SERVER.Func.GetTheme( 3 ) )
            surface.SetAlphaMultiplier( 1 )
    
            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, downColor or BRICKS_SERVER.Func.GetTheme( 3 ), 8 )
    
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, color and 255 or 75+(180*(alpha/150)) ) )
            surface.SetMaterial( iconMat )
            local iconSize = 24
            surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
        end
        button.DoClick = func

        buttonBack:SetWide( buttonBack:GetWide()+45 )
        buttonBack:SetPos( self.popoutWide-10-buttonBack:GetWide(), 10 )
    end

    buttonBack.AddButton( Material( "materials/bricks_server/delete.png" ), function()
        BRICKS_SERVER.Func.Query( "Deleting this case will remove it from players' inventories!", BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function()
            valueChanged = false
            self.popoutPanel.ClosePopout()
            removeFunc()
        end, function() end )
    end, BRICKS_SERVER.Func.GetTheme( 5 ), BRICKS_SERVER.Func.GetTheme( 4 ) )

    buttonBack.AddButton( Material( "materials/bricks_server/copy_command.png" ), function()
        BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "unboxingCopyCommandQuery" ), "unboxing_addcase [steamid64] " .. itemKey .. " [amount]", function( text ) 
        end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
    end )

    buttonBack.AddButton( Material( "materials/bricks_server/duplicate.png" ), function()
        BRICKS_SERVER.Func.Query( "Do you want to duplicate this case?", BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function()
            self.popoutPanel.ClosePopout()
            duplicateFunc()
        end, function() end )
    end )

    local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemTable.Rarity )

    self.itemName = vgui.Create( "DPanel", self.topPanel )
    self.itemName:Dock( BOTTOM )
    self.itemName:DockMargin( 0, 0, 0, 10 )
    self.itemName:SetTall( 60 )
    self.itemName.Paint = function( self2, w, h ) 
        draw.SimpleText( itemTable.Name or "NIL", "BRICKS_SERVER_Font23", w/2, (h/2)+2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        
        draw.SimpleText( (itemTable.Rarity or ""), "BRICKS_SERVER_Font20", w/2, (h/2)-2, BRICKS_SERVER.Func.GetRarityColor( rarityInfo ), TEXT_ALIGN_CENTER, 0 )
    end

    self.itemDisplay = vgui.Create( "bricks_server_unboxing_itemdisplay", self.topPanel )
    self.itemDisplay:SetSize( self.topPanel:GetTall()-20-self.itemName:GetTall(), self.topPanel:GetTall()-20-self.itemName:GetTall() )
    self.itemDisplay:SetPos( (self.popoutWide/2)-(self.itemDisplay:GetWide()/2), 10 )

    self.rarityBox = vgui.Create( "bricks_server_raritybox", self.topPanel )
    self.rarityBox:SetSize( self.popoutWide, 10 )
    self.rarityBox:SetPos( 0, self.topPanel:GetTall()-self.rarityBox:GetTall() )

    local function refreshInfo()
        self.itemDisplay:SetItemData( "CASE", itemTable )
        self.rarityBox:SetRarityName( itemTable.Rarity or "" )
        self.rarityBox:SetCornerRadius( 0 )

        rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemTable.Rarity )

        if( itemTable.Model ) then
            self.modelIconBack:SetTall( self.modelIconBack.originalH )
        else
            self.modelIconBack:SetTall( 0 )
        end
    end

    -- INFORMATION --
    local informationPage = vgui.Create( "DPanel", self.navigationContent )
    informationPage:Dock( FILL )
    informationPage.Paint = function( self2, w, h ) end
    self:AddPage( "1. INFORMATION", informationPage )

    informationPage.scroll = vgui.Create( "bricks_server_scrollpanel_bar", informationPage )
    informationPage.scroll:Dock( FILL )
    informationPage.scroll:DockMargin( 25, 25, 25, 0 )
    informationPage.scroll:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1, 200 ) )

    local function addValueEntry( text )
        surface.SetFont( "BRICKS_SERVER_Font20" )
        local textX, textY = surface.GetTextSize( text )

        local entryTitle = vgui.Create( "DPanel", informationPage.scroll )
        entryTitle:Dock( TOP )
        entryTitle:SetTall( textY-6 )
        entryTitle.Paint = function( self2, w, h )
            draw.SimpleText( text, "BRICKS_SERVER_Font20", 0, -4, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, 0 )
        end
    
        local entryBack = vgui.Create( "DPanel", informationPage.scroll )
        entryBack:Dock( TOP )
        entryBack:DockMargin( 0, 5, 10, 25 )
        entryBack:SetTall( 40 )
        local alpha = 0
        entryBack.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 150 ) )
    
            if( IsValid( self2.entry ) and self2.entry:IsEditing() ) then
                alpha = math.Clamp( alpha+5, 0, 100 )
            else
                alpha = math.Clamp( alpha-5, 0, 100 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, alpha ) )
        end

        return entryBack, entryTitle
    end

    local nameEntryBack = addValueEntry( "CASE NAME" )
    nameEntryBack.entry = vgui.Create( "bricks_server_textentry", nameEntryBack )
    nameEntryBack.entry:Dock( FILL )
    nameEntryBack.entry:SetValue( itemTable.Name or "NIL" )
    nameEntryBack.entry.OnChange = function()
        itemTable.Name = nameEntryBack.entry:GetValue()
        valueChanged = true
    end

    local rarityEntryBack = addValueEntry( "ITEM RARITY", informationPage.scroll )
    rarityEntryBack.Paint = function() end
    rarityEntryBack.totalRows = 0
    rarityEntryBack.AddEntry = function( self2, entry )
        if( not IsValid( self2.currentRow ) or (self2.currentRow.totalWide or 0)+entry:GetWide() > self2.currentRow.actualWide ) then
            self2.currentRow = vgui.Create( "DPanel", self2 )
            self2.currentRow:Dock( TOP )
            self2.currentRow:DockMargin( 0, 0, 0, 5 )
            self2.currentRow:SetTall( 40 )
            self2.currentRow.actualWide = self.popoutWide-50-20
            self2.currentRow.Paint = function() end

            self2.totalRows = self2.totalRows+1
        end

        self2.currentRow.totalWide = (self2.currentRow.totalWide or 0)+entry:GetWide()
        entry:SetParent( self2.currentRow )
    end

    for k, v in pairs( BS_ConfigCopyTable.GENERAL.Rarities ) do
        surface.SetFont( "BRICKS_SERVER_Font20" )
        local textX, textY = surface.GetTextSize( v[1] or "NIL" )
        
        local rarityEntry = vgui.Create( "DPanel" )
        rarityEntry:Dock( LEFT )
        rarityEntry:DockMargin( 0, 0, 5, 0 )
        rarityEntry:SetWide( textX+30 )
        local alpha = 0
        rarityEntry.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 150 ) )
    
            if( itemTable.Rarity == (v[1] or "") or (IsValid( self2.button ) and self2.button:IsHovered()) ) then
                alpha = math.Clamp( alpha+10, 0, 100 )
            else
                alpha = math.Clamp( alpha-10, 0, 100 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, alpha ) )

            draw.SimpleText( v[1] or "NIL", "BRICKS_SERVER_Font20", w/2, (h-5)/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        rarityEntry.rarityBox = vgui.Create( "bricks_server_raritybox", rarityEntry )
        rarityEntry.rarityBox:SetSize( rarityEntry:GetWide(), 5 )
        rarityEntry.rarityBox:SetPos( 0, rarityEntryBack:GetTall()-rarityEntry.rarityBox:GetTall() )
        rarityEntry.rarityBox:SetRarityName( v[1] or "" )
        rarityEntry.rarityBox:SetCornerRadius( 8 )
        rarityEntry.rarityBox:SetRoundedBoxDimensions( false, -11, false, 16 )

        rarityEntry.button = vgui.Create( "DButton", rarityEntry )
        rarityEntry.button:Dock( FILL )
        rarityEntry.button:SetText( "" )
        rarityEntry.button.Paint = function( self2, w, h ) end
        rarityEntry.button.DoClick = function()
            itemTable.Rarity = v[1] or ""
            valueChanged = true
            refreshInfo()
        end

        rarityEntryBack:AddEntry( rarityEntry )
    end

    rarityEntryBack:SetTall( (rarityEntryBack.totalRows*(40+5))-5 )

    local displayMiddleW = 50
    local displayEntryBack = addValueEntry( "CASE MODEL/ICON" )

    displayEntryBack.modelCombo = vgui.Create( "bricks_server_combo", displayEntryBack )
    displayEntryBack.modelCombo:Dock( LEFT )
    displayEntryBack.modelCombo:SetWide( (self.popoutWide-70-displayMiddleW)/2 )
    displayEntryBack.modelCombo.backColor = BRICKS_SERVER.Func.GetTheme( 1, 150 )
    displayEntryBack.modelCombo.highlightColor = BRICKS_SERVER.Func.GetTheme( 0 )
    displayEntryBack.modelCombo.cornerRadius = 8
    displayEntryBack.modelCombo:SetRoundedBoxDimensions( false, false, displayEntryBack.modelCombo:GetWide()+8, false )
    displayEntryBack.modelCombo:SetValue( (BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels[itemTable.Model or 0] or {}).Name or "None" )
    for k, v in pairs( BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels ) do
        displayEntryBack.modelCombo:AddChoice( v.Name, k )
    end
    displayEntryBack.modelCombo.OnSelect = function( self2, index, text, data )
        if( BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels[data] ) then
            itemTable.Model = data
        else
            return
        end

        if( itemTable.Icon ) then
            itemTable.Icon = nil
            displayEntryBack.iconEntryBack.entry:SetValue( "" )
        end

        valueChanged = true
        refreshInfo()
    end

    displayEntryBack.iconEntryBack = vgui.Create( "DPanel", displayEntryBack )
    displayEntryBack.iconEntryBack:Dock( RIGHT )
    displayEntryBack.iconEntryBack:SetWide( displayEntryBack.modelCombo:GetWide() )
    local alpha = 0
    displayEntryBack.iconEntryBack.Paint = function( self2, w, h ) 
        if( IsValid( self2.entry ) ) then
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 150 ), false, true, false, true )
        
            if( self2.entry:IsEditing() ) then
                alpha = math.Clamp( alpha+5, 0, 100 )
            else
                alpha = math.Clamp( alpha-5, 0, 100 )
            end
            
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, alpha ), false, true, false, true )
        end
    end

    displayEntryBack.iconEntryBack.entry = vgui.Create( "bricks_server_textentry", displayEntryBack.iconEntryBack )
    displayEntryBack.iconEntryBack.entry:Dock( FILL )
    displayEntryBack.iconEntryBack.entry:SetValue( itemTable.Icon or "" )
    displayEntryBack.iconEntryBack.entry.OnChange = function()
        if( itemTable.Model ) then
            itemTable.Model = nil
            displayEntryBack.modelCombo:SetValue( "None" )
        end

        local iconString = displayEntryBack.iconEntryBack.entry:GetValue()
        if( iconString != "" ) then
            itemTable.Icon = iconString
        else
            itemTable.Model = 1
            itemTable.Icon = nil
        end

        valueChanged = true
        refreshInfo()
    end

    displayEntryBack.center = vgui.Create( "DPanel", displayEntryBack )
    displayEntryBack.center:Dock( FILL )
    displayEntryBack.center.Paint = function( self2, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 0, 100 ) )
        surface.DrawRect( 0, 0, w, h )

        draw.SimpleText( "OR", "BRICKS_SERVER_Font23B", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    self.modelIconBack = vgui.Create( "DPanel", informationPage.scroll )
    self.modelIconBack:Dock( TOP )
    self.modelIconBack:DockMargin( 0, 0, 10, 25 )
    self.modelIconBack.originalH = 125
    self.modelIconBack:SetTall( self.modelIconBack.originalH )
    self.modelIconBack.headerY = 19
    self.modelIconBack.iconBackSize = self.modelIconBack.originalH-self.modelIconBack.headerY
    local loadingIcon = Material( "materials/bricks_server/loading.png" )
    self.modelIconBack.Paint = function( self2, w, h ) 
        draw.RoundedBoxEx( 8, 0, self2.headerY, self2.iconBackSize, self2.iconBackSize, BRICKS_SERVER.Func.GetTheme( 1 ), true, false, true, false )

        if( self2.iconMat ) then
            local iconSize = self2.iconBackSize*0.7
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
            surface.SetMaterial( self2.iconMat )
            surface.DrawTexturedRect( (self2.iconBackSize/2)-(iconSize/2), self.modelIconBack.headerY+(self2.iconBackSize/2)-(iconSize/2), iconSize, iconSize )
        else
            local iconSize = 32
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( loadingIcon )
            surface.DrawTexturedRectRotated( self2.iconBackSize/2, self.modelIconBack.headerY+(self2.iconBackSize/2), iconSize, iconSize, -(CurTime() % 360 * 250) )
        end

        draw.SimpleText( "MODEL ICON", "BRICKS_SERVER_Font20", 0, -4, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, 0 )
    end
    self.modelIconBack.RefreshIcon = function()
        if( itemTable.ModelIcon ) then
            BRICKS_SERVER.Func.GetImage( itemTable.ModelIcon, function( mat ) self.modelIconBack.iconMat = mat end )
        else
            self.modelIconBack.iconMat = nil
        end

        refreshInfo()
    end
    self.modelIconBack.RefreshIcon()

    self.modelIconBack.entryBack = vgui.Create( "DPanel", self.modelIconBack )
    self.modelIconBack.entryBack:Dock( FILL )
    self.modelIconBack.entryBack:DockMargin( self.modelIconBack.iconBackSize, self.modelIconBack.headerY, 0, 0 )
    local alpha = 0
    self.modelIconBack.entryBack.Paint = function( self2, w, h ) 
        if( IsValid( self2.entry ) ) then
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 150 ), false, true, false, true )
        
            if( self2.entry:IsEditing() ) then
                alpha = math.Clamp( alpha+5, 0, 100 )
            else
                alpha = math.Clamp( alpha-5, 0, 100 )
            end
            
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, alpha ), false, true, false, true )
        end
    end

    self.modelIconBack.entryBack.entry = vgui.Create( "bricks_server_textentry", self.modelIconBack.entryBack )
    self.modelIconBack.entryBack.entry:Dock( FILL )
    self.modelIconBack.entryBack.entry:SetValue( itemTable.ModelIcon or "" )
    self.modelIconBack.entryBack.entry.OnChange = function()
        local iconString = self.modelIconBack.entryBack.entry:GetValue()
        if( iconString != "" ) then
            itemTable.ModelIcon = iconString
        else
            itemTable.ModelIcon = nil
        end

        valueChanged = true
        self.modelIconBack.RefreshIcon()
    end

    local colorEntryBack = addValueEntry( "CASE COLOR" )
    colorEntryBack:SetTall( ScrH()*0.1 )

    colorEntryBack.colorEntry = vgui.Create( "DColorMixer", colorEntryBack )
	colorEntryBack.colorEntry:Dock( FILL )
	colorEntryBack.colorEntry:DockMargin( 10, 10, 10, 10 )
	colorEntryBack.colorEntry:SetPalette( false )
	colorEntryBack.colorEntry:SetAlphaBar( false) 
	colorEntryBack.colorEntry:SetWangs( true )
	colorEntryBack.colorEntry:SetColor( itemTable.Color or Color( 255, 255, 255 ) )
	colorEntryBack.colorEntry.ValueChanged = function()
        itemTable.Color = colorEntryBack.colorEntry:GetColor()
        valueChanged = true
        refreshInfo()
    end
    
    refreshInfo()

    -- ITEMS --
    local itemsPage = vgui.Create( "DPanel", self.navigationContent )
    itemsPage:Dock( FILL )
    itemsPage.Paint = function( self2, w, h ) end
    self:AddPage( "2. ITEMS", itemsPage )

    itemsPage.availableItems = vgui.Create( "DPanel", itemsPage )
    itemsPage.availableItems:Dock( LEFT )
    itemsPage.availableItems:SetWide( (self.popoutWide-50-25)/2 )
    itemsPage.availableItems:DockMargin( 25, 25, 0, 0 )
    itemsPage.availableItems:DockPadding( 0, 40, 0, 0 )
    itemsPage.availableItems.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 150 ) )

        draw.RoundedBoxEx( 8, 0, 0, w, 40, BRICKS_SERVER.Func.GetTheme( 3, 125 ), true, true, false, false )
        draw.SimpleText( "AVAILABLE ITEMS", "BRICKS_SERVER_Font20", w/2, 40/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    itemsPage.availableItems.search = vgui.Create( "bricks_server_searchbar", itemsPage.availableItems )
    itemsPage.availableItems.search:Dock( TOP )
    itemsPage.availableItems.search:SetTall( 40 )
    itemsPage.availableItems.search:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    itemsPage.availableItems.search:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    itemsPage.availableItems.search:SetCornerRadius( 0 )
    itemsPage.availableItems.search.OnChange = function()
        itemsPage.availableItems.RefreshItems()
    end

    itemsPage.availableItems.scroll = vgui.Create( "bricks_server_scrollpanel_bar", itemsPage.availableItems )
    itemsPage.availableItems.scroll:Dock( FILL )
    itemsPage.availableItems.scroll:DockMargin( 10, 10, 10, 10 )
    itemsPage.availableItems.scroll:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 2 ) )

    local gridWide = itemsPage.availableItems:GetWide()-20-20
    local slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 150 ) )
    local spacing = 10
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    itemsPage.availableItems.grid = vgui.Create( "DIconLayout", itemsPage.availableItems.scroll )
    itemsPage.availableItems.grid:Dock( FILL )
    itemsPage.availableItems.grid:SetSpaceY( spacing )
    itemsPage.availableItems.grid:SetSpaceX( spacing )

    function itemsPage.availableItems.RefreshItems()
        itemsPage.availableItems.grid:Clear()
    
        local sortedItems = {}
        for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Items ) do
            local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                    
            local globalKey = "ITEM_" .. k
            table.insert( sortedItems, { rarityKey, globalKey, v } )
        end

        for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Cases ) do
            local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                    
            local globalKey = "CASE_" .. k
            table.insert( sortedItems, { rarityKey, globalKey, v } )
        end

        for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Keys ) do
            local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                    
            local globalKey = "KEY_" .. k
            table.insert( sortedItems, { rarityKey, globalKey, v } )
        end
    
        table.SortByMember( sortedItems, 1 )

        for k, v in pairs( sortedItems ) do
            local globalKey, configItemTable  = v[2], v[3]

            if( itemTable.Items[globalKey] or ((itemsPage.availableItems.search:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( itemsPage.availableItems.search:GetValue() ) ))) ) then
                continue
            end
    
            local slotBack = itemsPage.availableItems.grid:Add( "bricks_server_unboxingmenu_itemslot" )
            slotBack:SetSize( slotSize, slotSize*1.2 )
            slotBack:FillPanel( { globalKey, configItemTable }, 1, function()
                BRICKS_SERVER.Func.StringRequest( "Admin", "What should the chance to unbox this item be?", 0, function( text ) 
                    local chance = tonumber( text )

                    if( chance <= 0 ) then return end

                    itemTable.Items[globalKey] = { chance }

                    valueChanged = true
                    itemsPage.availableItems.RefreshItems()
                    itemsPage.selectedItems.RefreshItems()
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            end )
            slotBack:AddTopInfo( 0 .. "%" )
            slotBack.themeNum = 1
        end
    end
    itemsPage.availableItems.RefreshItems()

    itemsPage.selectedItems = vgui.Create( "DPanel", itemsPage )
    itemsPage.selectedItems:Dock( RIGHT )
    itemsPage.selectedItems:SetWide( itemsPage.availableItems:GetWide() )
    itemsPage.selectedItems:DockMargin( 0, 25, 25, 0 )
    itemsPage.selectedItems:DockPadding( 0, 40, 0, 0 )
    itemsPage.selectedItems.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 150 ) )

        draw.RoundedBoxEx( 8, 0, 0, w, 40, BRICKS_SERVER.Func.GetTheme( 3, 125 ), true, true, false, false )
        draw.SimpleText( "SELECTED ITEMS", "BRICKS_SERVER_Font20", w/2, 40/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    itemsPage.selectedItems.search = vgui.Create( "bricks_server_searchbar", itemsPage.selectedItems )
    itemsPage.selectedItems.search:Dock( TOP )
    itemsPage.selectedItems.search:SetTall( 40 )
    itemsPage.selectedItems.search:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    itemsPage.selectedItems.search:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    itemsPage.selectedItems.search:SetCornerRadius( 0 )
    itemsPage.selectedItems.search.OnChange = function()
        itemsPage.selectedItems.RefreshItems()
    end

    itemsPage.selectedItems.scroll = vgui.Create( "bricks_server_scrollpanel_bar", itemsPage.selectedItems )
    itemsPage.selectedItems.scroll:Dock( FILL )
    itemsPage.selectedItems.scroll:DockMargin( 10, 10, 10, 10 )
    itemsPage.selectedItems.scroll:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 2 ) )

    local gridWide = itemsPage.selectedItems:GetWide()-20-20
    local slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 150 ) )
    local spacing = 10
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    itemsPage.selectedItems.grid = vgui.Create( "DIconLayout", itemsPage.selectedItems.scroll )
    itemsPage.selectedItems.grid:Dock( FILL )
    itemsPage.selectedItems.grid:SetSpaceY( spacing )
    itemsPage.selectedItems.grid:SetSpaceX( spacing )

    function itemsPage.selectedItems.RefreshItems()
        itemsPage.selectedItems.grid:Clear()
    
        local sortedItems = {}
        for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Items ) do
            local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                    
            local globalKey = "ITEM_" .. k
            table.insert( sortedItems, { rarityKey, globalKey, v } )
        end

        for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Cases ) do
            local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                    
            local globalKey = "CASE_" .. k
            table.insert( sortedItems, { rarityKey, globalKey, v } )
        end

        for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Keys ) do
            local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                    
            local globalKey = "KEY_" .. k
            table.insert( sortedItems, { rarityKey, globalKey, v } )
        end
    
        table.SortByMember( sortedItems, 1 )

        for k, v in pairs( sortedItems ) do
            local globalKey, configItemTable  = v[2], v[3]

            if( not itemTable.Items[globalKey] or ((itemsPage.selectedItems.search:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( itemsPage.selectedItems.search:GetValue() ) ))) ) then
                continue
            end

            local actions = {
                { "Edit Chance", function()
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What should the chance to unbox this item be?", itemTable.Items[globalKey][1], function( text ) 
                        local chance = tonumber( text )
    
                        if( chance > 0 ) then
                            itemTable.Items[globalKey][1] = chance
                        else
                            itemTable.Items[globalKey] = nil
                        end
    
                        valueChanged = true
                        itemsPage.selectedItems.RefreshItems()
                        itemsPage.availableItems.RefreshItems()
                    end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
                end },
                { itemTable.Items[globalKey][2] and "Unhide Item" or "Hide Item", function()
                    itemTable.Items[globalKey][2] = not itemTable.Items[globalKey][2]
                    valueChanged = true
                    itemsPage.selectedItems.RefreshItems()
                end }
            }
    
            local slotBack = itemsPage.selectedItems.grid:Add( "bricks_server_unboxingmenu_itemslot" )
            slotBack:SetSize( slotSize, slotSize*1.2 )
            slotBack:FillPanel( { globalKey, configItemTable }, 1, actions )
            slotBack:AddTopInfo( itemTable.Items[globalKey][1] .. "%" )
            slotBack.themeNum = 1

            if( itemTable.Items[globalKey][2] ) then
                slotBack:AddTopInfo( Material( "bricks_server/unboxing_hidden.png" ) )
            end
        end
    end
    itemsPage.selectedItems.RefreshItems()

    -- KEYS --
    local keysPage = vgui.Create( "DPanel", self.navigationContent )
    keysPage:Dock( FILL )
    keysPage.Paint = function( self2, w, h ) end
    self:AddPage( "3. KEYS", keysPage )

    keysPage.searchBar = vgui.Create( "bricks_server_searchbar", keysPage )
    keysPage.searchBar:Dock( TOP )
    keysPage.searchBar:SetTall( 40 )
    keysPage.searchBar:DockMargin( 25, 25, 25, 0 )
    keysPage.searchBar.OnChange = function()
        keysPage.RefreshItems()
    end

    keysPage.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", keysPage )
    keysPage.scrollPanel:Dock( FILL )
    keysPage.scrollPanel:DockMargin( 25, 10, 25, 25 )
    keysPage.scrollPanel:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )

    local gridWide = self.popoutWide-50-20
    local slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 150 ) )
    local spacing = 10
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    keysPage.grid = vgui.Create( "DIconLayout", keysPage.scrollPanel )
    keysPage.grid:Dock( FILL )
    keysPage.grid:SetSpaceY( spacing )
    keysPage.grid:SetSpaceX( spacing )

    function keysPage.RefreshItems()
        keysPage.grid:Clear()
    
        local sortedItems = {}
        for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Keys ) do
            local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                    
            table.insert( sortedItems, { rarityKey, k, v } )
        end
    
        table.SortByMember( sortedItems, 1, true )

        for k, v in pairs( sortedItems ) do
            local itemKey, configItemTable  = v[2], v[3]

            if( (keysPage.searchBar:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( keysPage.searchBar:GetValue() ) )) ) then
                continue
            end
    
            local slotBack = keysPage.grid:Add( "bricks_server_unboxingmenu_itemslot" )
            slotBack:SetSize( slotSize, slotSize*1.2 )
            slotBack:FillPanel( { "KEY_" .. itemKey, configItemTable }, 1, function()
                itemTable.Keys = itemTable.Keys or {}
                if( itemTable.Keys[itemKey] ) then
                    itemTable.Keys[itemKey] = nil
                else
                    itemTable.Keys[itemKey] = true
                end

                valueChanged = true
                keysPage.RefreshItems()
            end )
            slotBack.themeNum = 1
            
            if( (itemTable.Keys or {})[itemKey] ) then
                slotBack:AddTopInfo( Material( "bricks_server/unboxing_tick.png" ) )
            end
        end
    end
    keysPage.RefreshItems()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_unboxing_cases_popup", PANEL, "DPanel" )