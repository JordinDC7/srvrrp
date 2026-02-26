local PANEL = {}

function PANEL:Init()
    self.margin = 0
end

function PANEL:FillPanel()
    if self.panelWide == nil or self.panelWide < 100 then self.panelWide = self:GetWide() end; if self.panelWide < 100 then self.panelWide = math.min(ScrW() * 0.72, 1280) - 220 end; if self.panelTall == nil or self.panelTall < 100 then self.panelTall = self:GetTall() end; if self.panelTall < 100 then self.panelTall = math.min(ScrH() * 0.75, 820) - 220 end

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local headerX, headerY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingDropsConfigInfo" ) )
    local fullWidth = 60+headerX+35

    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    local noticeMat = Material( "bricks_server/unboxing_information.png" )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )

        -- Notice --
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
        surface.DrawRect( w-fullWidth, 0, fullWidth, h )
        
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
        surface.DrawRect( w-fullWidth, 0, h, h )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        surface.SetMaterial( noticeMat )
        local iconSize = 32
        surface.DrawTexturedRect( w-fullWidth+(h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingDropsConfigInfo" ), "BRICKS_SERVER_Font20", w-fullWidth+60+((fullWidth-60)/2), h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end 

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( math.min( ScrW()*0.2, self.panelWide-fullWidth-50 ) )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:Refresh()
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self, w, h ) end

    surface.SetFont( "BRICKS_SERVER_Font33" )
    local timeX, timeY = surface.GetTextSize( BRICKS_SERVER.Func.FormatTime( BS_ConfigCopyTable.UNBOXING.Drops.TimeInterval ) )

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local timeTextX, timeTextY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingDropsConfigInterval" ) )

    local totalTimeH = timeY+timeTextY-4

    local intervalConfigBack = vgui.Create( "DPanel", self.scrollPanel )
    intervalConfigBack:Dock( TOP )
    intervalConfigBack:DockMargin( 0, 0, 10, 10 )
    intervalConfigBack:DockPadding( 25, 0, 0, 0 )
    intervalConfigBack:SetTall( 100 )
    intervalConfigBack.Paint = function( self, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        draw.SimpleText( BRICKS_SERVER.Func.FormatTime( BS_ConfigCopyTable.UNBOXING.Drops.TimeInterval ), "BRICKS_SERVER_Font33", w-25, (h/2)-(totalTimeH/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, 0 )
        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingDropsConfigInterval" ), "BRICKS_SERVER_Font20", w-25, (h/2)+(totalTimeH/2), BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
    end 

    surface.SetFont( "BRICKS_SERVER_Font17" )
    local bottomW, bottomH = surface.GetTextSize( "HOURS" )

    local hours, minutes, seconds = 0, 0, 0
    local function calculateTimes()
        hours = math.floor( BS_ConfigCopyTable.UNBOXING.Drops.TimeInterval/3600 )
        minutes = math.floor( (BS_ConfigCopyTable.UNBOXING.Drops.TimeInterval-(hours*3600))/60 )
        seconds = math.floor( BS_ConfigCopyTable.UNBOXING.Drops.TimeInterval-(hours*3600)-(minutes*60) )
    end
    calculateTimes()

    local entryCount = 0
    local function createNumberEntry( title, default, maxValue, updateValue )
        entryCount = entryCount+1
        local entryPos = entryCount

        local numberEntryBack = vgui.Create( "DPanel", intervalConfigBack )
        numberEntryBack:Dock( LEFT )
        numberEntryBack:DockMargin( 0, 30, 1, 30-bottomH )
        numberEntryBack:SetWide( 50 )
        local alpha = 0
        numberEntryBack.Paint = function( self2, w, h ) 
            draw.RoundedBoxEx( 8, 0, 0, w, h-bottomH, BRICKS_SERVER.Func.GetTheme( 3, 100 ), entryPos == 1, entryPos == entryCount, entryPos == 1, entryPos == entryCount )

            if( IsValid( self2.entry ) ) then
                if( self2.entry:IsEditing() ) then
                    alpha = math.Clamp( alpha+5, 0, 150 )
                else
                    alpha = math.Clamp( alpha-5, 0, 150 )

                    local newValue = math.Clamp( self2.entry:GetValue(), 0, maxValue )
                    if( self2.entry:GetValue() != newValue ) then
                        self2.entry:SetValue( newValue )
                    end
                end
            end
            
            draw.RoundedBoxEx( 8, 0, 0, w, h-bottomH, BRICKS_SERVER.Func.GetTheme( 3, alpha ), entryPos == 1, entryPos == entryCount, entryPos == 1, entryPos == entryCount )
    
            draw.SimpleText( title, "BRICKS_SERVER_Font17", w/2, h, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end

        numberEntryBack.entry = vgui.Create( "bricks_server_numberwang", numberEntryBack )
        numberEntryBack.entry:Dock( FILL )
        numberEntryBack.entry:DockMargin( 10, 0, 0, bottomH )
        numberEntryBack.entry:SetValue( default )
        numberEntryBack.entry:SetMinMax( 0, maxValue )
        numberEntryBack.entry:HideWang()
        numberEntryBack.entry.OnValueChanged = function( self2, value )
            local newValue = math.Clamp( value, 0, maxValue )
            updateValue( newValue )

            BS_ConfigCopyTable.UNBOXING.Drops.TimeInterval = (hours*3600)+(minutes*60)+seconds
            BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
        end
    end

    createNumberEntry( "HOURS", hours, 24, function( newValue ) hours = newValue end )
    createNumberEntry( "MINS", minutes, 59, function( newValue ) minutes = newValue end )
    createNumberEntry( "SECS", seconds, 59, function( newValue ) seconds = newValue end )

    local gridWide = self.panelWide-50-10-10
    self.slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 200 ) )
    self.spacing = 10
    self.slotWide = (gridWide-((self.slotsWide-1)*self.spacing))/self.slotsWide

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( self.spacing )
    self.grid:SetSpaceX( self.spacing )

    self:Refresh()
end

function PANEL:Refresh()
    self.grid:Clear()

    local sortedItems = {}
    for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Drops.Items ) do
        local configItemTable
        if( string.StartWith( v[1], "ITEM_" ) ) then
            configItemTable = BS_ConfigCopyTable.UNBOXING.Items[tonumber(string.Replace( v[1], "ITEM_", "" ))]
        elseif( string.StartWith( v[1], "CASE_" ) ) then
            configItemTable = BS_ConfigCopyTable.UNBOXING.Cases[tonumber(string.Replace( v[1], "CASE_", "" ))]
        elseif( string.StartWith( v[1], "KEY_" ) ) then
            configItemTable = BS_ConfigCopyTable.UNBOXING.Keys[tonumber(string.Replace( v[1], "KEY_", "" ))]
        end

        if( not configItemTable ) then continue end

        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( configItemTable.Rarity or "" )
        
        table.insert( sortedItems, { rarityKey, configItemTable, v, k } )
    end

    table.SortByMember( sortedItems, 1, true )

    for k, v in pairs( sortedItems ) do
        local configItemTable, dropTable, dropKey = v[2], v[3], v[4]
        local globalKey = dropTable[1]

        if( (self.searchBar:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( self.searchBar:GetValue() ) )) ) then
            continue
        end

        local actions = {
            { "Edit Chance", function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), "What should the chance to get this item be?", dropTable[2], function( text ) 
                    BS_ConfigCopyTable.UNBOXING.Drops.Items[dropKey][2] = tonumber( text )
                    BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
                    self:Refresh()

                    BRICKS_SERVER.Func.CreateTopNotification( "Item drop chance edited!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            end },
            { "Edit Amount", function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), "How much of this item should be given?", (dropTable[3] or 1), function( text ) 
                    BS_ConfigCopyTable.UNBOXING.Drops.Items[dropKey][3] = tonumber( text )
                    BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
                    self:Refresh()

                    BRICKS_SERVER.Func.CreateTopNotification( "Item drop chance edited!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            end },
            { "Remove", function()
                BS_ConfigCopyTable.UNBOXING.Drops.Items[dropKey] = nil
                BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
                self:Refresh()

                BRICKS_SERVER.Func.CreateTopNotification( "Item removed from random drops!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
            end }
        }

        local slotBack = self.grid:Add( "bricks_server_unboxingmenu_itemslot" )
        slotBack:SetSize( self.slotWide, self.slotWide*1.2 )
        slotBack:FillPanel( { globalKey, configItemTable }, (dropTable[3] or 1), actions )
        slotBack:AddTopInfo( dropTable[2] .. "%" )
    end

    local addMat = Material( "bricks_server/unboxing_add_64.png" )
    local iconSize = 64

    local addButton = self.grid:Add( "DButton" )
    addButton:SetSize( self.slotWide, self.slotWide*1.2 )
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

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingDropsAddNew" ), "BRICKS_SERVER_Font30B", w/2, (h/2)+(iconSize/2)+10, textColor or BRICKS_SERVER.Func.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
    end
    addButton.DoClick = function()
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

                if( searchBar:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( searchBar:GetValue() ) ) ) then
                    continue
                end

                local slotBack = grid:Add( "bricks_server_unboxingmenu_itemslot" )
                slotBack:SetSize( slotSize, slotSize*1.2 )
                slotBack:FillPanel( { globalKey, configItemTable }, 1, function()
                    BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), "What should the chance to get this item be?", 0, function( text ) 
                        self.popoutPanel.ClosePopout()
                        
                        table.insert( BS_ConfigCopyTable.UNBOXING.Drops.Items, { globalKey, tonumber( text ) } ) 
                        BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
                        self:Refresh()

                        BRICKS_SERVER.Func.CreateTopNotification( "Item added to random drops!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
                    end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
                end )
                slotBack.themeNum = 1
            end
        end
        self.RefreshItems()

        searchBar.OnChange = function()
            self.RefreshItems()
        end
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_unboxing_drops", PANEL, "DPanel" )