local PANEL = {}

function PANEL:Init()
    if self.panelWide == nil or self.panelWide < 100 then self.panelWide = self:GetWide() end; if self.panelWide < 100 then self.panelWide = math.min(ScrW() * 0.72, 1280) - 220 end; if self.panelTall == nil or self.panelTall < 100 then self.panelTall = self:GetTall() end; if self.panelTall < 100 then self.panelTall = math.min(ScrH() * 0.75, 820) - 90 end

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
        BRICKS_SERVER.Func.Query( "Deleting this key will remove it from players' inventories!", BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function()
            valueChanged = false
            self.popoutPanel.ClosePopout()
            removeFunc()
        end, function() end )
    end, BRICKS_SERVER.Func.GetTheme( 5 ), BRICKS_SERVER.Func.GetTheme( 4 ) )

    buttonBack.AddButton( Material( "materials/bricks_server/copy_command.png" ), function()
        BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "unboxingCopyCommandQuery" ), "unboxing_addkey [steamid64] " .. itemKey .. " [amount]", function( text ) 
        end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
    end )

    buttonBack.AddButton( Material( "materials/bricks_server/duplicate.png" ), function()
        BRICKS_SERVER.Func.Query( "Do you want to duplicate this key?", BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function()
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
        self.itemDisplay:SetItemData( "KEY", itemTable )
        self.rarityBox:SetRarityName( itemTable.Rarity or "" )
        self.rarityBox:SetCornerRadius( 0 )

        rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemTable.Rarity )
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

    local nameEntryBack = addValueEntry( "KEY NAME" )
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
    local displayEntryBack = addValueEntry( "KEY MODEL/ICON" )

    displayEntryBack.modelCombo = vgui.Create( "bricks_server_combo", displayEntryBack )
    displayEntryBack.modelCombo:Dock( LEFT )
    displayEntryBack.modelCombo:SetWide( (self.popoutWide-70-displayMiddleW)/2 )
    displayEntryBack.modelCombo.backColor = BRICKS_SERVER.Func.GetTheme( 1, 150 )
    displayEntryBack.modelCombo.highlightColor = BRICKS_SERVER.Func.GetTheme( 0 )
    displayEntryBack.modelCombo.cornerRadius = 8
    displayEntryBack.modelCombo:SetRoundedBoxDimensions( false, false, displayEntryBack.modelCombo:GetWide()+8, false )
    displayEntryBack.modelCombo:SetValue( (BRICKS_SERVER.DEVCONFIG.UnboxingKeyModels[itemTable.Model or 0] or {}).Name or "None" )
    for k, v in pairs( BRICKS_SERVER.DEVCONFIG.UnboxingKeyModels ) do
        displayEntryBack.modelCombo:AddChoice( v.Name, k )
    end
    displayEntryBack.modelCombo.OnSelect = function( self2, index, text, data )
        if( BRICKS_SERVER.DEVCONFIG.UnboxingKeyModels[data] ) then
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

    local colorEntryBack = addValueEntry( "KEY COLOR" )
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
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_unboxing_keys_popup", PANEL, "DPanel" )