local PANEL = {}

function PANEL:Init()
    self.margin = 0
end

function PANEL:FillPanel()
    if self.panelWide == nil or self.panelWide < 100 then self.panelWide = self:GetWide() end; if self.panelWide < 100 then self.panelWide = math.min(ScrW() * 0.72, 1280) - 220 end; if self.panelTall == nil or self.panelTall < 100 then self.panelTall = self:GetTall() end; if self.panelTall < 100 then self.panelTall = ScrH() * 0.75 - 130 end

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
end

function PANEL:Refresh()
    self.scrollPanel:Clear()

    local slotWidth = self.backWidth-20
    local slotTall = slotWidth*1.2

    local mostItems = 0
    for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Rewards ) do
        mostItems = math.max( mostItems, table.Count( v ) )
    end

    local contentPanel = vgui.Create( "DPanel", self.scrollPanel )
    contentPanel:Dock( TOP )
    contentPanel:SetTall( math.max( self.panelTall-50-self.topHeaderH, ((mostItems+1)*(slotTall+10))+10 ) )
    contentPanel.Paint = function( self, w, h ) end 

    for i = 1, 7 do
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
                draw.RoundedBoxEx( 8, 0, 0, w, h, backColor, true, false, true, false )
            else
                surface.SetDrawColor( backColor )
                surface.DrawRect( 0, 0, w, h )
            end
        end 

        for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Rewards[i] or {} ) do
            local slotBack = vgui.Create( "bricks_server_unboxingmenu_itemslot", rewardEntry )
            slotBack:Dock( TOP )
            slotBack:DockMargin( 10, 10, 10, 0 )
            slotBack:SetSize( slotWidth, slotTall )
            slotBack:FillPanel( k, v, function()
                local itemAmount = v
                local popoutWide = self.panelWide*0.4
    
                local popoutPanel
    
                local actions = {
                    {
                        Name = function()
                            return "Edit Amount - " .. itemAmount .. "X"
                        end,
                        DoClick = function()
                            BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), "How many of this item should be rewarded?", (itemAmount or 1), function( text ) 
                                itemAmount = tonumber( text )
                            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
                        end
                    }
                }
    
                popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall, popoutWide, 50+40+25+(#actions*50)-10 )
                popoutPanel:SetColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
                popoutPanel:DockPadding( 25, 25, 25, 25 )
                popoutPanel.OnRemove = function()
                    if( itemAmount != v ) then
                        BS_ConfigCopyTable.UNBOXING.Rewards[i][k] = itemAmount
                        BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
    
                        if( IsValid( self ) ) then
                            self:Refresh()
                        end
    
                        BRICKS_SERVER.Func.CreateTopNotification( "Reward successfully edited!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
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
                    BS_ConfigCopyTable.UNBOXING.Rewards[i][k] = nil

                    BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
                    self:Refresh()
            
                    BRICKS_SERVER.Func.CreateTopNotification( "Reward successfully removed!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                end
    
                local closeButton = vgui.Create( "DButton", buttonBack )
                closeButton:Dock( BOTTOM )
                closeButton:SetTall( 40 )
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
            end )
        end

        local addButton = vgui.Create( "DButton", rewardEntry )
        addButton:Dock( TOP )
        addButton:DockMargin( 10, 10, 10, 0 )
        addButton:SetSize( slotWidth, slotTall )
        addButton:SetText( "" )
        local alpha = 0
        local addMat = Material( "bricks_server/unboxing_add_64.png" )
        addButton.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 75 )
            else
                alpha = math.Clamp( alpha-10, 0, 75 )
            end
    
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, alpha ) )
    
            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), 8 )
    
            local iconSize = 64
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
            surface.SetMaterial( addMat )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
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

            function self.RefreshInventory()
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
            
                    if( not configItemTable or BS_ConfigCopyTable.UNBOXING.Rewards[i][globalKey] ) then continue end

                    if( searchBar:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( searchBar:GetValue() ) ) ) then
                        continue
                    end

                    local slotBack = grid:Add( "bricks_server_unboxingmenu_itemslot" )
                    slotBack:SetSize( slotSize, slotSize*1.2 )
                    slotBack:FillPanel( { globalKey, configItemTable }, 1, function()
                        BS_ConfigCopyTable.UNBOXING.Rewards[i][globalKey] = 1
                
                        BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
                        self:Refresh()
                
                        BRICKS_SERVER.Func.CreateTopNotification( "New reward added!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )

                        self.popoutPanel.ClosePopout()
                    end )
                    slotBack.themeNum = 1
                end
            end
            self.RefreshInventory()

            searchBar.OnChange = function()
                self.RefreshInventory()
            end
        end
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_unboxing_rewards", PANEL, "DPanel" )