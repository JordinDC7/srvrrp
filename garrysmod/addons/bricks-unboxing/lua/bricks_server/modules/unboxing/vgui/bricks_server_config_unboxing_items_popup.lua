local PANEL = {}

function PANEL:Init()
    self.panelWide, self.panelTall = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth, ScrH()*0.65-40

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
        BRICKS_SERVER.Func.Query( "Deleting this item will remove it from players' inventories!", BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function()
            valueChanged = false
            self.popoutPanel.ClosePopout()
            removeFunc()
        end, function() end )
    end, BRICKS_SERVER.Func.GetTheme( 5 ), BRICKS_SERVER.Func.GetTheme( 4 ) )

    buttonBack.AddButton( Material( "materials/bricks_server/copy_command.png" ), function()
        BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "unboxingCopyCommandQuery" ), "unboxing_additem [steamid64] " .. itemKey .. " [amount]", function( text ) 
        end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
    end )

    buttonBack.AddButton( Material( "materials/bricks_server/duplicate.png" ), function()
        BRICKS_SERVER.Func.Query( "Do you want to duplicate this item?", BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function()
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
        self.itemDisplay:SetItemData( "ITEM", itemTable )
        self.rarityBox:SetRarityName( itemTable.Rarity or "" )
        self.rarityBox:SetCornerRadius( 0 )

        rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemTable.Rarity )
    end

    local function addValueEntry( text, parent )
        surface.SetFont( "BRICKS_SERVER_Font20" )
        local textX, textY = surface.GetTextSize( text )

        local entryTitle = vgui.Create( "DPanel", parent )
        entryTitle:Dock( TOP )
        entryTitle:SetTall( textY-4 )
        entryTitle.Paint = function( self2, w, h )
            draw.SimpleText( text, "BRICKS_SERVER_Font20", 0, -4, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, 0 )
        end
    
        local entryBack = vgui.Create( "DPanel", parent )
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

    -- INFORMATION --
    local informationPage = vgui.Create( "DPanel", self.navigationContent )
    informationPage:Dock( FILL )
    informationPage.Paint = function( self2, w, h ) end
    self:AddPage( "1. INFORMATION", informationPage )

    informationPage.scroll = vgui.Create( "bricks_server_scrollpanel_bar", informationPage )
    informationPage.scroll:Dock( FILL )
    informationPage.scroll:DockMargin( 25, 25, 25, 0 )
    informationPage.scroll:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1, 200 ) )

    local nameEntryBack = addValueEntry( "ITEM NAME", informationPage.scroll )
    nameEntryBack.entry = vgui.Create( "bricks_server_textentry", nameEntryBack )
    nameEntryBack.entry:Dock( FILL )
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
    local displayEntryBack = addValueEntry( "ITEM MODEL/ICON", informationPage.scroll )

    displayEntryBack.modelEntryBack = vgui.Create( "DPanel", displayEntryBack )
    displayEntryBack.modelEntryBack:Dock( LEFT )
    displayEntryBack.modelEntryBack:SetWide( (self.popoutWide-70-displayMiddleW)/2 )
    local alpha = 0
    displayEntryBack.modelEntryBack.Paint = function( self2, w, h ) 
        if( IsValid( self2.entry ) ) then
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 150 ), true, false, true, false )
        
            if( self2.entry:IsEditing() ) then
                alpha = math.Clamp( alpha+5, 0, 100 )
            else
                alpha = math.Clamp( alpha-5, 0, 100 )
            end
            
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, alpha ), true, false, true, false )
        end
    end

    displayEntryBack.modelEntryBack.entry = vgui.Create( "bricks_server_textentry", displayEntryBack.modelEntryBack )
    displayEntryBack.modelEntryBack.entry:Dock( FILL )
    displayEntryBack.modelEntryBack.entry.OnChange = function()
        if( itemTable.Icon ) then
            itemTable.Icon = nil
            displayEntryBack.iconEntryBack.entry:SetValue( "" )
        end

        itemTable.Model = displayEntryBack.modelEntryBack.entry:GetValue()

        valueChanged = true
        refreshInfo()
    end

    displayEntryBack.iconEntryBack = vgui.Create( "DPanel", displayEntryBack )
    displayEntryBack.iconEntryBack:Dock( RIGHT )
    displayEntryBack.iconEntryBack:SetWide( displayEntryBack.modelEntryBack:GetWide() )
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
    displayEntryBack.iconEntryBack.entry.OnChange = function()
        if( itemTable.Model ) then
            itemTable.Model = nil
            displayEntryBack.modelEntryBack.entry:SetValue( "" )
        end

        itemTable.Icon = displayEntryBack.iconEntryBack.entry:GetValue()

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
    
    refreshInfo()

    function informationPage.refreshEntryValues()
        nameEntryBack.entry:SetValue( itemTable.Name or "NIL" )
        displayEntryBack.modelEntryBack.entry:SetValue( itemTable.Model or "" )
        displayEntryBack.iconEntryBack.entry:SetValue( itemTable.Icon or "" )
    end
    informationPage.refreshEntryValues()

    -- TYPE INFO --
    local typeInfoPage = vgui.Create( "DPanel", self.navigationContent )
    typeInfoPage:Dock( FILL )
    typeInfoPage.Paint = function( self2, w, h ) end
    self:AddPage( "2. TYPE INFO", typeInfoPage )

    typeInfoPage.scroll = vgui.Create( "bricks_server_scrollpanel_bar", typeInfoPage )
    typeInfoPage.scroll:Dock( FILL )
    typeInfoPage.scroll:DockMargin( 25, 25, 25, 0 )
    typeInfoPage.scroll:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1, 200 ) )

    function typeInfoPage.RefreshTypeInfo()
        typeInfoPage.scroll:Clear()

        local typeEntryBack = addValueEntry( "ITEM TYPE", typeInfoPage.scroll )
        typeEntryBack.Paint = function( self2, w, h ) end
    
        typeEntryBack.modelCombo = vgui.Create( "bricks_server_combo", typeEntryBack )
        typeEntryBack.modelCombo:Dock( FILL )
        typeEntryBack.modelCombo.backColor = BRICKS_SERVER.Func.GetTheme( 1, 150 )
        typeEntryBack.modelCombo.highlightColor = BRICKS_SERVER.Func.GetTheme( 0 )
        typeEntryBack.modelCombo.cornerRadius = 8
        typeEntryBack.modelCombo:SetValue( (BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[itemTable.Type or ""] or {}).Name or "None" )
        for k, v in pairs( BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes ) do
            typeEntryBack.modelCombo:AddChoice( v.Name, k )
        end
        typeEntryBack.modelCombo.OnSelect = function( self2, index, text, data )
            if( BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[data] ) then
                itemTable.ReqInfo = {}
                itemTable.Type = data
                typeInfoPage.RefreshTypeInfo()
    
                valueChanged = true
            else
                notification.AddLegacy( "Invalid type.", 1, 3 )
            end
        end

        local itemReqInfo = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[itemTable.Type or ""].ReqInfo or {}

        for key, val in ipairs( itemReqInfo ) do
            if( val[2] == "integer" ) then
                local typeFieldEntryBack = addValueEntry( val[1], typeInfoPage.scroll )
                typeFieldEntryBack.entry = vgui.Create( "bricks_server_numberwang", typeFieldEntryBack )
                typeFieldEntryBack.entry:Dock( FILL )
                typeFieldEntryBack.entry:SetMinMax( 0, 9999999999999 )
                typeFieldEntryBack.entry:SetValue( (itemTable.ReqInfo or {})[key] or 0 )
                typeFieldEntryBack.entry.OnValueChanged = function( self2, value )
                    itemTable.ReqInfo = itemTable.ReqInfo or {}
                    itemTable.ReqInfo[key] = tonumber( value )
                    valueChanged = true
                end
            elseif( val[2] == "string" ) then
                local typeFieldEntryBack = addValueEntry( val[1], typeInfoPage.scroll )
                typeFieldEntryBack.entry = vgui.Create( "bricks_server_textentry", typeFieldEntryBack )
                typeFieldEntryBack.entry:Dock( FILL )
                typeFieldEntryBack.entry:SetValue( (itemTable.ReqInfo or {})[key] or "" )
                typeFieldEntryBack.entry.OnChange = function( self2, value )
                    itemTable.ReqInfo = itemTable.ReqInfo or {}
                    itemTable.ReqInfo[key] = typeFieldEntryBack.entry:GetValue()
                    valueChanged = true
                end
            elseif( val[2] == "table" ) then
                if( val[3] ) then
                    local typeFieldEntryBack = addValueEntry( val[1], typeInfoPage.scroll )
                    typeFieldEntryBack.Paint = function( self2, w, h ) end
    
                    local choicesTable = isfunction( val[3] ) and val[3]( table.Copy( itemTable ) ) or BRICKS_SERVER.Func.GetList( val[3] )

                    local valueEntry = vgui.Create( "bricks_server_combo_search", typeFieldEntryBack )
                    valueEntry:Dock( FILL )
                    valueEntry.backColor = BRICKS_SERVER.Func.GetTheme( 1, 150 )
                    valueEntry.highlightColor = BRICKS_SERVER.Func.GetTheme( 0 )
                    valueEntry.cornerRadius = 8
                    valueEntry:SetValue( choicesTable[(itemTable.ReqInfo or {})[key] or ""] or "" )
                    for k, v in pairs( choicesTable ) do
                        valueEntry:AddChoice( v, k )
                    end
                    valueEntry.OnSelect = function( self2, index, text, data )
                        itemTable.ReqInfo[key] = itemTable.ReqInfo[key] or {}
                        itemTable.ReqInfo[key] = data

                        if( val[4] ) then
                            itemTable = val[4]( table.Copy( itemTable ) ) or itemTable
                        end

                        refreshInfo()
                        valueChanged = true
                        typeInfoPage.RefreshTypeInfo()
                        informationPage.refreshEntryValues()
                    end
                else
                    for key2, val2 in ipairs( (itemTable.ReqInfo or {})[key] or {} ) do
                        local typeFieldEntryBack = addValueEntry( val[1], typeInfoPage.scroll )
                        typeFieldEntryBack.Paint = function( self2, w, h ) end

                        local removeButton = vgui.Create( "DButton", typeFieldEntryBack )
                        removeButton:Dock( RIGHT )
                        removeButton:SetWide( typeFieldEntryBack:GetTall() )
                        removeButton:SetText( "" )
                        local alpha = 0
                        local deleteMat = Material( "materials/bricks_server/delete.png" )
                        removeButton.Paint = function( self2, w, h )
                            if( not self2:IsDown() and self2:IsHovered() ) then
                                alpha = math.Clamp( alpha+5, 0, 200 )
                            else
                                alpha = math.Clamp( alpha-5, 0, 255 )
                            end
                    
                            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, false, true, false, true )

                            surface.SetAlphaMultiplier( alpha/255 )
                            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed, false, true, false, true )
                            surface.SetAlphaMultiplier( 1 )
                    
                            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
                
                            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                            surface.SetMaterial( deleteMat )
                            local iconSize = 24
                            surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
                        end
                        removeButton.DoClick = function()
                            table.remove( itemTable.ReqInfo[key], key2 )
                            valueChanged = true
                            typeInfoPage.RefreshTypeInfo()
                        end

                        local entryBack = vgui.Create( "DPanel", typeFieldEntryBack )
                        entryBack:Dock( FILL )
                        local alpha = 0
                        entryBack.Paint = function( self2, w, h )
                            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 150 ), true, false, true, false )
                    
                            if( IsValid( self2.entry ) and self2.entry:IsEditing() ) then
                                alpha = math.Clamp( alpha+5, 0, 100 )
                            else
                                alpha = math.Clamp( alpha-5, 0, 100 )
                            end
                            
                            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, alpha ), true, false, true, false )
                        end
            
                        entryBack.entry = vgui.Create( "bricks_server_textentry", entryBack )
                        entryBack.entry:Dock( FILL )
                        entryBack.entry:SetValue( val2 )
                        entryBack.entry.OnChange = function( self2, value )
                            itemTable.ReqInfo[key][key2] = entryBack.entry:GetValue()
                            valueChanged = true
                        end
                    end

                    local addReqInfoButton = vgui.Create( "DButton", typeInfoPage.scroll )
                    addReqInfoButton:Dock( TOP )
                    addReqInfoButton:DockMargin( 0, 0, 10, 0 )
                    addReqInfoButton:SetTall( 40 )
                    addReqInfoButton:SetText( "" )
                    local changeAlpha = 0
                    addReqInfoButton.Paint = function( self2, w, h )
                        if( not self2:IsDown() and self2:IsHovered() ) then
                            changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                        else
                            changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                        end
                        
                        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
                
                        surface.SetAlphaMultiplier( changeAlpha/255 )
                        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
                        surface.SetAlphaMultiplier( 1 )
                
                        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ), 8 )
                        
                        draw.SimpleText( val[4], "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                    addReqInfoButton.DoClick = function()
                        itemTable.ReqInfo = itemTable.ReqInfo or {}
                        itemTable.ReqInfo[key] = itemTable.ReqInfo[key] or {}
                        table.insert( itemTable.ReqInfo[key], "" )
                        valueChanged = true
                        typeInfoPage.RefreshTypeInfo()
                    end
                end
            end
        end
    end
    typeInfoPage.RefreshTypeInfo()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_unboxing_items_popup", PANEL, "DPanel" )