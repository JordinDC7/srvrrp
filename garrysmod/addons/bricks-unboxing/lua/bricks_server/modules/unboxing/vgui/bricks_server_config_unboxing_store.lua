local PANEL = {}

function PANEL:Init()
    self.margin = 0
end

function PANEL:FillPanel()
    if self.panelWide == nil or self.panelWide < 100 then self.panelWide = self:GetWide() end; if self.panelWide < 100 then self.panelWide = ScrW() * 0.72 + 200 - 220 end; if self.panelTall == nil or self.panelTall < 100 then self.panelTall = self:GetTall() end; if self.panelTall < 100 then self.panelTall = ScrH() * 0.75 - 130 end
    self.gridWide = self.panelWide-50-10-10

    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )
    end 

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local textX, textY = surface.GetTextSize( "Add Category" )
    local totalContentW = 16+5+textX

    local createNewCatButton = vgui.Create( "DButton", self.topBar )
    createNewCatButton:Dock( RIGHT )
    createNewCatButton:DockMargin( 10, 10, 25, 10 )
    createNewCatButton:SetWide( totalContentW+27 )
    createNewCatButton:SetText( "" )
    local alpha = 0
    local addMat = Material( "bricks_server/add_16.png" )
    createNewCatButton.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ) )
        surface.SetMaterial( addMat )
        local iconSize = 16
        surface.DrawTexturedRect( 12, (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( "Add Category", "BRICKS_SERVER_Font20", 12+iconSize+5, h/2, BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ), 0, TEXT_ALIGN_CENTER )
    end
    createNewCatButton.DoClick = function()
        local categoryKey = #BS_ConfigCopyTable.UNBOXING.Store.Categories+1
        BS_ConfigCopyTable.UNBOXING.Store.Categories[categoryKey] = {
            Name = "New Category"
        }

        self:CreateStoreCategoryCfg( categoryKey, true )
    end

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local textX, textY = surface.GetTextSize( "Add Store Item" )
    local totalContentW = 16+5+textX

    local createNewButton = vgui.Create( "DButton", self.topBar )
    createNewButton:Dock( RIGHT )
    createNewButton:DockMargin( 10, 10, 0, 10 )
    createNewButton:SetWide( totalContentW+27 )
    createNewButton:SetText( "" )
    local alpha = 0
    local addMat = Material( "bricks_server/add_16.png" )
    createNewButton.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ) )
        surface.SetMaterial( addMat )
        local iconSize = 16
        surface.DrawTexturedRect( 12, (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( "Add Store Item", "BRICKS_SERVER_Font20", 12+iconSize+5, h/2, BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ), 0, TEXT_ALIGN_CENTER )
    end
    createNewButton.DoClick = function()
        self.popoutWide, self.popoutTall = self.panelWide*0.9, self.panelTall*0.9

        self.popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall, self.popoutWide, self.popoutTall )

        self.popoutPanel.closeButton = vgui.Create( "DButton", self.popoutPanel )
        self.popoutPanel.closeButton:Dock( BOTTOM )
        self.popoutPanel.closeButton:SetTall( 40 )
        self.popoutPanel.closeButton:SetText( "" )
        self.popoutPanel.closeButton:DockMargin( 25, 0, 25, 25 )
        local changeAlpha = 0
        self.popoutPanel.closeButton.Paint = function( self2, w, h )
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
        self.popoutPanel.closeButton.DoClick = self.popoutPanel.ClosePopout

        local searchBar = vgui.Create( "bricks_server_searchbar", self.popoutPanel )
        searchBar:Dock( TOP )
        searchBar:DockMargin( 25, 25, 25, 0 )
        searchBar:SetTall( 40 )

        local scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.popoutPanel )
        scrollPanel:Dock( FILL )
        scrollPanel:DockMargin( 25, 10, 25, 25 )
        scrollPanel:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )

        local gridWide = self.popoutWide-50-10-10
        local slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 175 ) )
        local spacing = 10
        local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

        local grid = vgui.Create( "DIconLayout", scrollPanel )
        grid:Dock( TOP )
        grid:SetSpaceY( spacing )
        grid:SetSpaceX( spacing )

        function self.RefreshItems()
            grid:Clear()

            local showItems = {}
            for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Items ) do
                local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                
                local globalKey = "ITEM_" .. k
                table.insert( showItems, { rarityKey, globalKey, v } )
            end
    
            for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Cases ) do
                local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                
                local globalKey = "CASE_" .. k
                table.insert( showItems, { rarityKey, globalKey, v } )
            end
    
            for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Keys ) do
                local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                
                local globalKey = "KEY_" .. k
                table.insert( showItems, { rarityKey, globalKey, v } )
            end
    
            table.SortByMember( showItems, 1, true )
        
            for k, v in pairs( showItems ) do
                local globalKey, configItemTable  = v[2], v[3]
        
                if( not configItemTable ) then continue end

                if( searchBar:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( searchBar:GetValue() ) ) ) then
                    continue
                end

                local dontContinue
                for key, val in pairs( BS_ConfigCopyTable.UNBOXING.Store.Items ) do
                    if( globalKey == val.GlobalKey ) then
                        dontContinue = true
                        break
                    end
                end

                if( dontContinue ) then continue end

                local slotBack = grid:Add( "bricks_server_unboxingmenu_itemslot" )
                slotBack:SetSize( slotSize, slotSize*1.2 )
                slotBack:FillPanel( { globalKey, configItemTable }, 1, function()
                    local storeKey = #BS_ConfigCopyTable.UNBOXING.Store.Items+1
                    BS_ConfigCopyTable.UNBOXING.Store.Items[storeKey] = {
                        GlobalKey = globalKey,
                        Category = 1,
                        Price = 1000
                    }

                    self.popoutPanel.ClosePopout()
                    self:CreateStoreItemCfg( storeKey, true )
                end )
                slotBack.themeNum = 1
            end
        end
        self.RefreshItems()

        searchBar.OnChange = function()
            self.RefreshItems()
        end
    end

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( ScrW()*0.2 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:Refresh()
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self, w, h ) end 

    self:Refresh()
end

function PANEL:CreateStoreItemCfg( storeKey, justCreated )
    local valueChanged = justCreated
    local storeItem = table.Copy( BS_ConfigCopyTable.UNBOXING.Store.Items[storeKey] )

    if( not storeItem ) then return end

    local popoutWide = self.panelWide*0.4

    local popoutPanel

    local groupOptions = {}
    groupOptions["None"] = "None"
    for k, v in pairs( BS_ConfigCopyTable.GENERAL.Groups ) do
        groupOptions[k] = v[1]
    end

    local categoryOptions = {}
    for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Store.Categories ) do
        categoryOptions[k] = v.Name
    end
    
    local currencyOptions = {}
    currencyOptions["Default"] = "Default"
    for k, v in pairs( BRICKS_SERVER.DEVCONFIG.Currencies ) do
        currencyOptions[k] = v.Title
    end

    local actions = {
        {
            Name = function()
                return "Edit Price - " .. BRICKS_SERVER.UNBOXING.Func.FormatCurrency( storeItem.Price or 0, storeItem.Currency )
            end,
            DoClick = function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), "How much should this item cost?", (storeItem.Price or 0), function( text ) 
                    storeItem.Price = tonumber( text )
                    valueChanged = true
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            end
        },
        {
            Name = function()
                return "Edit Group - " .. (storeItem.Group or "None")
            end,
            DoClick = function()
                BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), "What should the group requirement be?", (storeItem.Group or "None"), groupOptions, function( value, data ) 
                    if( BS_ConfigCopyTable.GENERAL.Groups[data] ) then
                        storeItem.Group = value
                        valueChanged = true
                    elseif( value == "None" ) then
                        storeItem.Group = nil
                        valueChanged = true
                    else
                        notification.AddLegacy( "Invalid group.", 1, 3 )
                    end
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
            end
        },
        {
            Name = function()
                return "Edit Category - " .. categoryOptions[storeItem.Category]
            end,
            DoClick = function()
                BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), "What category should this item be in?", (storeItem.Group or "None"), categoryOptions, function( value, data ) 
                    if( categoryOptions[data] ) then
                        storeItem.Category = data
                        valueChanged = true
                    else
                        notification.AddLegacy( "Invalid category.", 1, 3 )
                    end
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
            end
        },
        {
            Name = function()
                return "Edit SortOrder - " .. (storeItem.SortOrder or "None")
            end,
            DoClick = function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), "How much should this item cost?", (storeItem.SortOrder or 0), function( text ) 
                    if( tonumber( text ) > 0 ) then
                        storeItem.SortOrder = tonumber( text )
                        valueChanged = true
                    else
                        storeItem.SortOrder = nil
                        valueChanged = true
                    end
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            end
        },
        {
            Name = function()
                return "Edit Currency - " .. ((BRICKS_SERVER.DEVCONFIG.Currencies[storeItem.Currency or ""] or {}).Title or "Default")
            end,
            DoClick = function()
                BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), "What currency should this item be?", (storeItem.Currency or "Default"), currencyOptions, function( value, data ) 
                    if( currencyOptions[data] ) then
                        storeItem.Currency = data
                        valueChanged = true
                    elseif( value == "Default" ) then
                        storeItem.Currency = nil
                        valueChanged = true
                    else
                        notification.AddLegacy( "Invalid currency.", 1, 3 )
                    end
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
            end
        }
    }

    popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall, popoutWide, 50+40+25+(#actions*50)-10 )
    popoutPanel:SetColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    popoutPanel:DockPadding( 25, 25, 25, 25 )
    popoutPanel.OnRemove = function()
        if( valueChanged ) then
            BS_ConfigCopyTable.UNBOXING.Store.Items[storeKey] = storeItem
            BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )

            if( IsValid( self ) ) then
                self:Refresh()
            end

            BRICKS_SERVER.Func.CreateTopNotification( not justCreated and "Store item successfully edited!" or "Store item successfully created!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
        end
    end

    for k, v in pairs( actions ) do
        local actionButton = vgui.Create( "DButton", popoutPanel )
        actionButton:Dock( TOP )
        actionButton:SetTall( 40 )
        actionButton:SetText( "" )
        actionButton:DockMargin( 0, 0, 0, 10 )
        local changeAlpha = 0
        actionButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, v.Color or BRICKS_SERVER.Func.GetTheme( 2 ) )
    
            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, v.DownColor or BRICKS_SERVER.Func.GetTheme( 1 ) )
            surface.SetAlphaMultiplier( 1 )
    
            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, v.DownColor or BRICKS_SERVER.Func.GetTheme( 1 ) )
            
            draw.SimpleText( (isfunction( v.Name ) and v.Name()) or v.Name, "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        actionButton.DoClick = v.DoClick
    end

    local buttonBack = vgui.Create( "DPanel", popoutPanel )
    buttonBack:Dock( BOTTOM )
    buttonBack:SetTall( 40 )
    buttonBack.Paint = function( self2, w, h ) end

    local removeButton = vgui.Create( "DButton", buttonBack )
    removeButton:Dock( RIGHT )
    removeButton:DockMargin( 5, 0, 0, 0 )
    removeButton:SetWide( buttonBack:GetTall() )
    removeButton:SetText( "" )
    local alpha = 0
    local deleteMat = Material( "materials/bricks_server/delete.png" )
    removeButton.Paint = function( self2, w, h )
        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+5, 0, 200 )
        else
            alpha = math.Clamp( alpha-5, 0, 255 )
        end

        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        surface.SetMaterial( deleteMat )
        local iconSize = 24
        surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
    end
    removeButton.DoClick = function()
        popoutPanel.ClosePopout()
        BS_ConfigCopyTable.UNBOXING.Store.Items[storeKey] = nil

        BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
        self:Refresh()

        BRICKS_SERVER.Func.CreateTopNotification( "Store item successfully removed!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
    end

    local closeButton = vgui.Create( "DButton", buttonBack )
    closeButton:Dock( FILL )
    closeButton:SetText( "" )
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
    closeButton.DoClick = popoutPanel.ClosePopout
end

function PANEL:CreateStoreCategoryCfg( categoryKey, justCreated )
    local valueChanged = justCreated
    local categoryTable = table.Copy( BS_ConfigCopyTable.UNBOXING.Store.Categories[categoryKey] )

    if( not categoryTable ) then return end

    local popoutWide = self.panelWide*0.4

    local popoutPanel

    local actions = {
        {
            Name = function()
                return "Edit Name - " .. categoryTable.Name
            end,
            DoClick = function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), "What should the category name be?", categoryTable.Name, function( text ) 
                    categoryTable.Name = text
                    valueChanged = true
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
            end
        },
        {
            Name = function()
                return "Edit SortOrder - " .. (categoryTable.SortOrder or "None")
            end,
            DoClick = function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), "How much should this item cost?", (categoryTable.SortOrder or 0), function( text ) 
                    if( tonumber( text ) > 0 ) then
                        categoryTable.SortOrder = tonumber( text )
                        valueChanged = true
                    else
                        categoryTable.SortOrder = nil
                        valueChanged = true
                    end
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            end
        }
    }

    popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall, popoutWide, 50+40+25+(#actions*50)-10 )
    popoutPanel:SetColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    popoutPanel:DockPadding( 25, 25, 25, 25 )
    popoutPanel.OnRemove = function()
        if( valueChanged ) then
            BS_ConfigCopyTable.UNBOXING.Store.Categories[categoryKey] = categoryTable
            BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )

            if( IsValid( self ) ) then
                self:Refresh()
            end

            BRICKS_SERVER.Func.CreateTopNotification( not justCreated and "Store category successfully edited!" or "Store category successfully created!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
        end
    end

    for k, v in pairs( actions ) do
        local actionButton = vgui.Create( "DButton", popoutPanel )
        actionButton:Dock( TOP )
        actionButton:SetTall( 40 )
        actionButton:SetText( "" )
        actionButton:DockMargin( 0, 0, 0, 10 )
        local changeAlpha = 0
        actionButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, v.Color or BRICKS_SERVER.Func.GetTheme( 2 ) )
    
            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, v.DownColor or BRICKS_SERVER.Func.GetTheme( 1 ) )
            surface.SetAlphaMultiplier( 1 )
    
            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, v.DownColor or BRICKS_SERVER.Func.GetTheme( 1 ) )
            
            draw.SimpleText( (isfunction( v.Name ) and v.Name()) or v.Name, "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        actionButton.DoClick = v.DoClick
    end

    local buttonBack = vgui.Create( "DPanel", popoutPanel )
    buttonBack:Dock( BOTTOM )
    buttonBack:SetTall( 40 )
    buttonBack.Paint = function( self2, w, h ) end

    local removeButton = vgui.Create( "DButton", buttonBack )
    removeButton:Dock( RIGHT )
    removeButton:DockMargin( 5, 0, 0, 0 )
    removeButton:SetWide( buttonBack:GetTall() )
    removeButton:SetText( "" )
    local alpha = 0
    local deleteMat = Material( "materials/bricks_server/delete.png" )
    removeButton.Paint = function( self2, w, h )
        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+5, 0, 200 )
        else
            alpha = math.Clamp( alpha-5, 0, 255 )
        end

        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        surface.SetMaterial( deleteMat )
        local iconSize = 24
        surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
    end
    removeButton.DoClick = function()
        popoutPanel.ClosePopout()
        BS_ConfigCopyTable.UNBOXING.Store.Categories[categoryKey] = nil

        BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
        self:Refresh()

        BRICKS_SERVER.Func.CreateTopNotification( "Store category successfully removed!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
    end

    local closeButton = vgui.Create( "DButton", buttonBack )
    closeButton:Dock( FILL )
    closeButton:SetText( "" )
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
    closeButton.DoClick = popoutPanel.ClosePopout
end

function PANEL:AddStoreItem( storeTable, itemKey, grid, itemWidth, itemHeight, func )
    if( not storeTable or not storeTable.GlobalKey ) then return end

    local configItemTable = {}
    if( string.StartWith( storeTable.GlobalKey, "CASE_" ) ) then
        configItemTable = BS_ConfigCopyTable.UNBOXING.Cases[tonumber( string.Replace( storeTable.GlobalKey, "CASE_", "" ) )]
    elseif( string.StartWith( storeTable.GlobalKey, "ITEM_" ) ) then
        configItemTable = BS_ConfigCopyTable.UNBOXING.Items[tonumber( string.Replace( storeTable.GlobalKey, "ITEM_", "" ) )]
    elseif( string.StartWith( storeTable.GlobalKey, "KEY_" ) ) then
        configItemTable = BS_ConfigCopyTable.UNBOXING.Keys[tonumber( string.Replace( storeTable.GlobalKey, "KEY_", "" ) )]
    end

    if( not configItemTable ) then return end

    local slotBack = grid:Add( "bricks_server_unboxingmenu_itemslot" )
    slotBack:SetSize( itemWidth, itemHeight )
    slotBack:FillPanel( { storeTable.GlobalKey, configItemTable }, 1, func )
    slotBack:AddTopInfo( BRICKS_SERVER.UNBOXING.Func.FormatCurrency( storeTable.Price or 0, storeTable.Currency ) )

    if( storeTable.Group ) then
        local groupTable = {}
        for key, val in pairs( BS_ConfigCopyTable.GENERAL.Groups ) do
            if( val[1] == storeTable.Group ) then
                groupTable = val
                break
            end
        end

        slotBack:AddTopInfo( storeTable.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme( 6 ) )
    end
end

function PANEL:Refresh()
    self.scrollPanel:Clear()

    local storeConfig = BS_ConfigCopyTable.UNBOXING.Store
    local storeItemsConfig = storeConfig.Items

    local function GetItemInfo( globalKey )
        local isItem, isCase, isKey = string.StartWith( globalKey, "ITEM_" ), string.StartWith( globalKey, "CASE_" ), string.StartWith( globalKey, "KEY_" )
        local configItemTable, itemKey

        if( isItem ) then
            itemKey = tonumber( string.Replace( globalKey, "ITEM_", "" ) )
            configItemTable = BS_ConfigCopyTable.UNBOXING.Items[itemKey]
        elseif( isCase ) then
            itemKey = tonumber( string.Replace( globalKey, "CASE_", "" ) )
            configItemTable = BS_ConfigCopyTable.UNBOXING.Cases[itemKey]
        elseif( isKey ) then
            itemKey = tonumber( string.Replace( globalKey, "KEY_", "" ) )
            configItemTable = BS_ConfigCopyTable.UNBOXING.Keys[itemKey]
        end

        return (configItemTable or {}), (itemKey or 0), isItem, isCase, isKey
    end

    surface.SetFont( "BRICKS_SERVER_Font33" )
    local featuredX, featuredY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingFeaturedHeader" ) )

    if( storeConfig.Featured ) then
        local featuredHeader = vgui.Create( "DPanel", self.scrollPanel )
        featuredHeader:Dock( TOP )
        featuredHeader:DockMargin( 0, 0, 10, 5 )
        featuredHeader:SetTall( featuredY )
        featuredHeader.Paint = function( self2, w, h )
            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingFeaturedHeader" ), "BRICKS_SERVER_Font33", 0, 0, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
        end

        local featuredBack = vgui.Create( "DPanel", self.scrollPanel )
        featuredBack:Dock( TOP )
        featuredBack:DockMargin( 0, 0, 10, 0 )
        featuredBack:SetTall( ScrH()*0.35 )
        featuredBack.Paint = function( self2, w, h ) end

        local featuredSpacing = 10
        local featuredWide = (self.gridWide-((BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount-1)*featuredSpacing))/BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount
        
        local featuredGrid = vgui.Create( "DIconLayout", featuredBack )
        featuredGrid:Dock( FILL )
        featuredGrid:SetSpaceY( featuredSpacing )
        featuredGrid:SetSpaceX( featuredSpacing )

        local function editFunction( i )
            local itemOptions = {}
            for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Store.Items ) do
                itemOptions[k] = GetItemInfo( v.GlobalKey ).Name or ""
            end

            BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), "What item should be featured here?", (BS_ConfigCopyTable.UNBOXING.Store.Featured[i] or 0), itemOptions, function( value, data ) 
                if( itemOptions[data] ) then
                    BS_ConfigCopyTable.UNBOXING.Store.Featured[i] = data
                    BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
                    self:Refresh()
                else
                    notification.AddLegacy( "Invalid item.", 1, 3 )
                end
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
        end

        for i = 1, BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount do
            local globalKey = (storeItemsConfig[storeConfig.Featured[i] or 0] or {}).GlobalKey
            local configItemTable
            if( globalKey ) then
                if( string.StartWith( globalKey, "CASE_" ) ) then
                    configItemTable = BS_ConfigCopyTable.UNBOXING.Cases[tonumber( string.Replace( globalKey, "CASE_", "" ) )]
                elseif( string.StartWith( globalKey, "ITEM_" ) ) then
                    configItemTable = BS_ConfigCopyTable.UNBOXING.Items[tonumber( string.Replace( globalKey, "ITEM_", "" ) )]
                elseif( string.StartWith( globalKey, "KEY_" ) ) then
                    configItemTable = BS_ConfigCopyTable.UNBOXING.Keys[tonumber( string.Replace( globalKey, "KEY_", "" ) )]
                end
            end

            if( configItemTable ) then
                self:AddStoreItem( (storeItemsConfig[storeConfig.Featured[i] or 0] or {}), storeConfig.Featured[i], featuredGrid, featuredWide, featuredBack:GetTall(), function()
                    editFunction( i )
                end )
            else
                local addMat = Material( "bricks_server/unboxing_add.png" )
                local iconSize = 128

                local addButton = featuredGrid:Add( "DButton" )
                addButton:SetSize( featuredWide, featuredBack:GetTall() )
                addButton:SetText( "" )
                local alpha = 0
                addButton.Paint = function( self2, w, h )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            
                    if( not self2:IsDown() and self2:IsHovered() ) then
                        alpha = math.Clamp( alpha+10, 0, 75 )
                    else
                        alpha = math.Clamp( alpha-10, 0, 75 )
                    end
            
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, alpha ) )
            
                    BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), 8 )
            
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                    surface.SetMaterial( addMat )
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            
                    draw.SimpleText( string.upper( BRICKS_SERVER.Func.L( "createNew" ) ), "BRICKS_SERVER_Font30B", w/2, (h/2)+(iconSize/2)+10, textColor or BRICKS_SERVER.Func.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
                end
                addButton.DoClick = function()
                    editFunction( i )
                end
            end
        end
    end

    local itemSpacing = 5
    local wantedItemSize = 200
    local itemSlotsWide = math.floor( self.gridWide/wantedItemSize )
    local itemSlotWidth = (self.gridWide-((itemSlotsWide-1)*itemSpacing))/itemSlotsWide
    local itemSlotTall = itemSlotWidth*1.25

    surface.SetFont( "BRICKS_SERVER_Font30" )
    local headerX, headerY = surface.GetTextSize( "CATEGORY" )

    local sortedCategories = {}
    for k, v in pairs( storeConfig.Categories ) do
        table.insert( sortedCategories, { k, v } )
    end

    table.sort( sortedCategories, function(a, b) return (((a or {})[2] or {}).SortOrder or 1000) < (((b or {})[2] or {}).SortOrder or 1000) end )

    local categories = {}
    local categoryHeaderTall, categoryHeaderSpacing = headerY, 5
    for _, val in pairs( sortedCategories ) do
        local k, v = val[1], val[2]

        categories[k] = vgui.Create( "DPanel", self.scrollPanel )
        categories[k]:Dock( TOP )
        categories[k]:DockMargin( 0, 25, 10, 0 )
        categories[k]:DockPadding( 0, categoryHeaderTall+categoryHeaderSpacing, 0, 0 )
        categories[k]:SetTall( categoryHeaderTall )
        categories[k].Paint = function( self2, w, h )
            draw.SimpleText( string.upper( v.Name ), "BRICKS_SERVER_Font30", 0, 0, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
        end

        surface.SetFont( "BRICKS_SERVER_Font30" )
        local headerX, headerY = surface.GetTextSize( string.upper( v.Name ) )

        local categoryEditName = vgui.Create( "DButton", categories[k] )
        categoryEditName:SetText( "" )
        categoryEditName:SetSize( 16, 16 )
        categoryEditName:SetPos( headerX+5, (categoryHeaderTall/2)-(categoryEditName:GetTall()/2)+2 )
        local alpha = 20
        local editMat = Material( "materials/bricks_server/edit_16.png" )
        categoryEditName.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 20, 255 )
            else
                alpha = math.Clamp( alpha-10, 20, 255 )
            end
    
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, alpha ) )
            surface.SetMaterial( editMat )
            local iconSize = 16
            surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
        end
        categoryEditName.DoClick = function()
            self:CreateStoreCategoryCfg( k )
        end

        categories[k].grid = vgui.Create( "DIconLayout", categories[k] )
        categories[k].grid:Dock( TOP )
        categories[k].grid:SetTall( 0 )
        categories[k].grid:SetSpaceY( itemSpacing )
        categories[k].grid:SetSpaceX( itemSpacing )
    end

    local sortedStoreItems = {}
    for k, v in pairs( storeItemsConfig ) do
        local configItemTable = GetItemInfo( v.GlobalKey )

        if( not configItemTable ) then continue end

        if( self.searchBar:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end

        table.insert( sortedStoreItems, { k, v } )
    end

    table.sort( sortedStoreItems, function(a, b) return (((a or {})[2] or {}).SortOrder or 1000) < (((b or {})[2] or {}).SortOrder or 1000) end )

    for k, v in pairs( sortedStoreItems ) do
        local categoryPanel = categories[v[2].Category or 0]

        if( not IsValid( categoryPanel ) ) then 
            print( "[Brick's Unboxing] ERROR MISSING ITEM CATEGORY!")
            continue 
        end

        local gridPanel = categoryPanel.grid
        if( not IsValid( gridPanel ) ) then continue end
        
        self:AddStoreItem( v[2], v[1], gridPanel, itemSlotWidth, itemSlotTall, function()
            self:CreateStoreItemCfg( v[1] )
        end )

        gridPanel.entries = (gridPanel.entries or 0)+1

        local newGridTall = (math.ceil(gridPanel.entries/itemSlotsWide)*(itemSlotTall+itemSpacing))-itemSpacing
        
        if( gridPanel:GetTall() != newGridTall ) then
            gridPanel:SetTall( newGridTall )
            categoryPanel:SetTall( categoryHeaderTall+categoryHeaderSpacing+newGridTall )
        end
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_unboxing_store", PANEL, "DPanel" )