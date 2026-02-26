local PANEL = {}

function PANEL:Init()
    self.margin = 0
end

function PANEL:FillPanel()
    if self.panelWide == nil or self.panelWide < 100 then self.panelWide = self:GetWide() end; if self.panelWide < 100 then self.panelWide = math.min(ScrW() * 0.72, 1280) - 220 end; if self.panelTall == nil or self.panelTall < 100 then self.panelTall = self:GetTall() end; if self.panelTall < 100 then self.panelTall = ScrH() * 0.75 - 130 end

    self.spacing = 10
    local gridWide = self.panelWide-50-10-self.spacing
    self.slotsWide = 4
    self.slotWide = (gridWide-((self.slotsWide-1)*self.spacing))/self.slotsWide

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self, w, h ) end 

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( self.spacing )
    self.grid:SetSpaceX( self.spacing )

    self:Refresh()
end

function PANEL:Refresh()
    self.grid:Clear()

    local addMat = Material( "bricks_server/unboxing_add.png" )
    local editMat = Material( "bricks_server/unboxing_edit.png" )
    local iconSize = 128

    for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Marketplace.Slots ) do
        local slot = self.grid:Add( "DPanel" )
        slot:SetSize( self.slotWide, self.slotWide*1.2 )
        local alpha = 0
        slot.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    
            if( IsValid( self2.button ) ) then
                if( not self2.button:IsDown() and self2.button:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 75 )
                else
                    alpha = math.Clamp( alpha-10, 0, 75 )
                end
    
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, alpha ) )
    
                BRICKS_SERVER.Func.DrawClickCircle( self2.button, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), 8 )
            end
    
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
            surface.SetMaterial( editMat )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( string.upper( BRICKS_SERVER.Func.L( "edit" ) ), "BRICKS_SERVER_Font30B", w/2, (h/2)+(iconSize/2)+10, textColor or BRICKS_SERVER.Func.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
        end
        slot.addTopInfo = function( text, color, textColor )
            surface.SetFont( "BRICKS_SERVER_Font20B" )
            local topX, topY = surface.GetTextSize( text )
            
            local boxW, boxH = topX+15, topY+5

            slot.topBar:SetTall( math.max( slot.topBar:GetTall(), boxH ) )

            local infoEntry = vgui.Create( "DPanel", slot.topBar )
            infoEntry:Dock( RIGHT )
            infoEntry:DockMargin( 5, 0, 0, 0 )
            infoEntry:SetWide( boxW )
            infoEntry.Paint = function( self2, w, h ) 
                draw.RoundedBox( 8, 0, 0, w, h, color or BRICKS_SERVER.Func.GetTheme( 1 ) )
                draw.SimpleText( text, "BRICKS_SERVER_Font20B", w/2, (h/2)-1, textColor or BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end

        slot.topBar = vgui.Create( "DPanel", slot )
        slot.topBar:SetPos( 5, 5 )
        slot.topBar:SetWide( slot:GetWide()-10 )
        slot.topBar.Paint = function( self2, w, h ) end

        slot.addTopInfo( BRICKS_SERVER.Func.L( "unboxingAuctionSlot", k ) )
        
        if( v.Price ) then
            slot.addTopInfo( BRICKS_SERVER.UNBOXING.Func.FormatCurrency( v.Price ) )
        end

        if( v.Group ) then
            local groupTable = {}
            for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                if( val[1] == v.Group ) then
                    groupTable = val
                    break
                end
            end

            slot.addTopInfo( v.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme( 6 ) )
        end

        slot.button = vgui.Create( "DButton", slot )
        slot.button:Dock( FILL )
        slot.button:SetText( "" )
        slot.button.Paint = function( self2, w, h ) end
        slot.button.DoClick = function( self2 )
            local valueChanged = false
            local slotTable = table.Copy( v )
            local popoutWide = self.panelWide*0.4

            local options = {}
			options["None"] = "None"
			for k, v in pairs( BS_ConfigCopyTable.GENERAL.Groups ) do
				options[k] = v[1]
            end
            
            local popoutPanel

            local actions = {
                {
                    Name = function()
                        return "Edit Price - " .. BRICKS_SERVER.UNBOXING.Func.FormatCurrency( slotTable.Price or 0 )
                    end,
                    DoClick = function()
                        BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), "How much should it cost to purchase?", (slotTable.Price or 0), function( text ) 
                            local newPrice = tonumber( text )
                            if( slotTable.Price == newPrice ) then return end

                            if( newPrice > 0 ) then
                                slotTable.Price= newPrice
                            else
                                slotTable.Price = nil
                            end

                            valueChanged = true
                        end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
                    end
                },
                {
                    Name = function()
                        return "Edit Group - " .. (slotTable.Group or "None")
                    end,
                    DoClick = function()
                        BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), "What should the group requirement be?", (slotTable.Group or "None"), options, function( value, data ) 
                            if( BS_ConfigCopyTable.GENERAL.Groups[data] ) then
                                slotTable.Group = value
                                valueChanged = true
                            elseif( value == "None" ) then
                                slotTable.Group = nil
                                valueChanged = true
                            else
                                notification.AddLegacy( "Invalid group.", 1, 3 )
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
                    BS_ConfigCopyTable.UNBOXING.Marketplace.Slots[k] = slotTable
                    BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )

                    if( IsValid( self ) ) then
                        self:Refresh()
                    end

                    BRICKS_SERVER.Func.CreateTopNotification( "Slot successfully edited!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
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
                BRICKS_SERVER.Func.Query( "Are you sure you want to remove this slot?", BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function()
                    popoutPanel.ClosePopout()
                    BS_ConfigCopyTable.UNBOXING.Marketplace.Slots[k] = nil

                    BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
                    self:Refresh()
            
                    BRICKS_SERVER.Func.CreateTopNotification( "Slot successfully removed!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                end, function() end )
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
        end
    end

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

        draw.SimpleText( string.upper( BRICKS_SERVER.Func.L( "createNew" ) ), "BRICKS_SERVER_Font30B", w/2, (h/2)+(iconSize/2)+10, textColor or BRICKS_SERVER.Func.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
    end
    addButton.DoClick = function()
        table.insert( BS_ConfigCopyTable.UNBOXING.Marketplace.Slots, {} )

        BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
        self:Refresh()

        BRICKS_SERVER.Func.CreateTopNotification( "New slot successfully created!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_unboxing_slots", PANEL, "DPanel" )