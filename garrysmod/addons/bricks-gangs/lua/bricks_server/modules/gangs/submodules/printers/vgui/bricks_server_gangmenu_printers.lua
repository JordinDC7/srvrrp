local PANEL = {}

function PANEL:Init()
    self.showingSlot = 1

    self.slidePanel = vgui.Create( "DPanel", self )
    self.slidePanel:SetSize( 0, ScrH()*0.65-40 )
    self.slidePanel.Paint = function( self2, w, h ) end
    self.slidePanel.DisplaySlot = function( slot )
        self.showingSlot = slot
        self.slidePanel:MoveTo( -((slot-1)*self.panelWide), 0, 0.5 )
    end
end

function PANEL:RefreshButtons()
    local panelTall = ScrH()*0.65-40

    if( IsValid( self.rightButton ) ) then
        self.rightButton:Remove()
    end

    if( IsValid( self.leftButton ) ) then
        self.leftButton:Remove()
    end

    local printerCount = #BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers

    if( self.showingSlot < printerCount ) then
        self.rightButton = vgui.Create( "DButton", self )
        self.rightButton:SetSize( BRICKS_SERVER.Func.ScreenScale( 45 ), BRICKS_SERVER.Func.ScreenScale( 75 ) )
        self.rightButton:SetPos( self.panelWide-self.rightButton:GetWide(), (panelTall/3.3)-(self.rightButton:GetTall()/2) )
        self.rightButton:SetText( "" )
        local Alpha = 0
        local rightMat = Material( "bricks_server/next_32.png")
        self.rightButton.Paint = function( self2, w, h ) 
            if( not self2:IsDown() and self2:IsHovered() ) then
                Alpha = math.Clamp( Alpha+5, 0, 150 )
            else
                Alpha = math.Clamp( Alpha-5, 0, 150 )
            end
        
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), true, false, true, false )

            surface.SetAlphaMultiplier( Alpha/255 )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), true, false, true, false )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

            local iconSize = BRICKS_SERVER.Func.ScreenScale( 32 )
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
            surface.SetMaterial( rightMat )
            surface.DrawTexturedRect( (w/2)-(iconSize/2)+2, (h/2)-(iconSize/2), iconSize, iconSize )
        end
        self.rightButton.DoClick = function()
            self.slidePanel.DisplaySlot( self.showingSlot+1 )

            self:RefreshButtons()
        end
    end

    if( self.showingSlot > 1 ) then
        self.leftButton = vgui.Create( "DButton", self )
        self.leftButton:SetSize( BRICKS_SERVER.Func.ScreenScale( 45 ), BRICKS_SERVER.Func.ScreenScale( 75 ) )
        self.leftButton:SetPos( 0, (panelTall/3.3)-(self.leftButton:GetTall()/2) )
        self.leftButton:SetText( "" )
        local Alpha = 0
        local leftMat = Material( "bricks_server/previous_32.png")
        self.leftButton.Paint = function( self2, w, h ) 
            if( not self2:IsDown() and self2:IsHovered() ) then
                Alpha = math.Clamp( Alpha+5, 0, 150 )
            else
                Alpha = math.Clamp( Alpha-5, 0, 150 )
            end
        
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, true, false, true )

            surface.SetAlphaMultiplier( Alpha/255 )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), false, true, false, true )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

            local iconSize = BRICKS_SERVER.Func.ScreenScale( 32 )
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
            surface.SetMaterial( leftMat )
            surface.DrawTexturedRect( (w/2)-(iconSize/2)-2, (h/2)-(iconSize/2), iconSize, iconSize )
        end
        self.leftButton.DoClick = function()
            self.slidePanel.DisplaySlot( self.showingSlot-1 )

            self:RefreshButtons()
        end
    end
end

function PANEL:FillPanel( gangTable )
    local panelTall = ScrH()*0.65-40

    function self.RefreshPanel()
        self.slidePanel:Clear()
        self.slidePanel:SetWide( 0 )

        self:RefreshButtons()

        local printers = gangTable.Printers or {}
        local maxCoolingUpgrade = #BRICKS_SERVER.CONFIG.GANGPRINTERS.ServerUpgrades["Cooling"].Tiers

        for k, v in pairs( BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers ) do
            local printerTable = printers[k]

            local page = vgui.Create( "DPanel", self.slidePanel )
            page:Dock( LEFT )
            page:SetWide( self.panelWide )
            page.Paint = function( self2, w, h ) end

            self.slidePanel:SetWide( self.slidePanel:GetWide()+page:GetWide() )

            surface.SetFont( "BRICKS_SERVER_Font20" )
            local textX, textY = surface.GetTextSize( "UNPURCHASED" )

            local printerInfo = vgui.Create( "DPanel", page )
            printerInfo:Dock( BOTTOM )
            printerInfo:DockMargin( 10, 0, 10, 0 )
            printerInfo:SetTall( (printerTable and 300) or 0 )
            printerInfo.Paint = function( self2, w, h ) 
                draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), true, true, false, false )
            end

            if( not printerTable and LocalPlayer():GangHasPermission( "PurchasePrinters" ) ) then
                surface.SetFont( "BRICKS_SERVER_Font30" )
                local textX, textY = surface.GetTextSize( "Purchase" )

                surface.SetFont( "BRICKS_SERVER_Font17" )
                local subTextX, subTextY = surface.GetTextSize( DarkRP.formatMoney( v.Price or 0 ) )

                local sideMargin = math.min( ScrW()*0.2, (self.panelWide-(math.max( textX, subTextX )+75))/2 )

                local purchaseButton = vgui.Create( "DButton", page )
                purchaseButton:Dock( BOTTOM )
                purchaseButton:DockMargin( sideMargin, 0, sideMargin, 40 )
                purchaseButton:SetTall( BRICKS_SERVER.Func.ScreenScale( 55 ) )
                purchaseButton:SetText( "" )
                local Alpha = 0
                purchaseButton.Paint = function( self2, w, h ) 
                    if( not self2:IsDown() and self2:IsHovered() ) then
                        Alpha = math.Clamp( Alpha+5, 0, 150 )
                    else
                        Alpha = math.Clamp( Alpha-5, 0, 150 )
                    end
                
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
        
                    surface.SetAlphaMultiplier( Alpha/255 )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )
                    surface.SetAlphaMultiplier( 1 )
        
                    BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )
        
                    draw.SimpleText( "Purchase", "BRICKS_SERVER_Font30", w/2, h/2+4, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
                    draw.SimpleText( DarkRP.formatMoney( v.Price or 0 ), "BRICKS_SERVER_Font17", w/2, h/2-0, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                end
                purchaseButton.DoClick = function()
                    net.Start( "BRS.Net.GangPrinterPurchase" )
                        net.WriteUInt( k, 8 )
                    net.SendToServer()
                end
            elseif( printerTable and LocalPlayer():GangHasPermission( "PlacePrinters" ) ) then
                surface.SetFont( "BRICKS_SERVER_Font30" )
                local textX, textY = surface.GetTextSize( "Place" )

                surface.SetFont( "BRICKS_SERVER_Font17" )
                local subTextX, subTextY = surface.GetTextSize( v.Name )

                local sideMargin = math.min( ScrW()*0.2, (self.panelWide-(math.max( textX, subTextX )+75))/2 )

                local placeButton = vgui.Create( "DButton", page )
                placeButton:Dock( BOTTOM )
                placeButton:DockMargin( sideMargin, 0, sideMargin, 40 )
                placeButton:SetTall( BRICKS_SERVER.Func.ScreenScale( 55 ) )
                placeButton:SetText( "" )
                local Alpha = 0
                placeButton.Paint = function( self2, w, h ) 
                    if( not self2:IsDown() and self2:IsHovered() ) then
                        Alpha = math.Clamp( Alpha+5, 0, 150 )
                    else
                        Alpha = math.Clamp( Alpha-5, 0, 150 )
                    end
                
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
        
                    surface.SetAlphaMultiplier( Alpha/255 )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
                    surface.SetAlphaMultiplier( 1 )
        
                    BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        
                    draw.SimpleText( "Place", "BRICKS_SERVER_Font30", w/2, h/2+4, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
                    draw.SimpleText( v.Name, "BRICKS_SERVER_Font17", w/2, h/2-0, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                end
                placeButton.DoClick = function()
                    net.Start( "BRS.Net.GangPrinterPlace" )
                        net.WriteUInt( k, 8 )
                    net.SendToServer()
                end

                local scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", printerInfo )
                scrollPanel:Dock( FILL )
                scrollPanel:DockMargin( 10, 10, 10, 0 )
                scrollPanel.Paint = function( self, w, h ) end 

                local spacing = 10
                local gridWide = self.panelWide-40-20
                local slotsWide = 4
                local slotW = (gridWide-((slotsWide-1)*spacing))/slotsWide

                local grid = vgui.Create( "DIconLayout", scrollPanel )
                grid:Dock( FILL )
                grid:SetSpaceY( spacing )
                grid:SetSpaceX( spacing )

                local upgradeMat = Material( "bricks_server/gangprinter_upgrade.png" )
                local headerColor = Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 50 )
                for i = 1, BRICKS_SERVER.DEVCONFIG.GangPrinterSlots do
                    local price = ((BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[k] or {}).ServerPrices or {})[i] or 0

                    local slotBack = vgui.Create( "DPanel", grid )
                    slotBack:SetSize( slotW, 0 )
                    slotBack:DockPadding( 12, 60, 12, 12 )
                    slotBack.Paint = function( self2, w, h ) 
                        if( not printerTable.Servers or not printerTable.Servers[i] ) then
                            surface.SetAlphaMultiplier( 0.65 )
                        end

                        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

                        draw.SimpleText( "SERVER SLOT " .. i, "BRICKS_SERVER_Font25", w/2, 60/2, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                        surface.SetAlphaMultiplier( 1 )
                    end

                    for key, val in pairs( BRICKS_SERVER.CONFIG.GANGPRINTERS.ServerUpgrades ) do
                        local devConfigUpgrade = BRICKS_SERVER.DEVCONFIG.GangServerUpgradeTypes[key] or {}

                        local spacing = BRICKS_SERVER.Func.ScreenScale( 15 )
                        local barDistance = ScrW() == 2560 and 25 or BRICKS_SERVER.Func.ScreenScale( 5 )
                        local upgradeBack = vgui.Create( "DPanel", slotBack )
                        upgradeBack:Dock( TOP )
                        upgradeBack:DockMargin( 0, 0, 0, 8 )
                        upgradeBack:SetTall( BRICKS_SERVER.Func.ScreenScale( 40 ) )
                        upgradeBack.Paint = function( self2, w, h ) 
                            if( not printerTable.Servers or not printerTable.Servers[i] ) then
                                surface.SetAlphaMultiplier( 0.5 )
                            end

                            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                
                            local iconSize = BRICKS_SERVER.Func.ScreenScale( 32 )
                            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                            surface.SetMaterial( devConfigUpgrade.Icon )
                            surface.DrawTexturedRect( spacing, (h/2)-(iconSize/2), iconSize, iconSize )

                            draw.SimpleText( string.upper( val.Name ), "BRICKS_SERVER_Font13", spacing+iconSize+spacing, 11, headerColor, 0, 0 )

                            local barWidth = w-spacing-iconSize-spacing-60
                            draw.RoundedBox( 4, spacing+iconSize+spacing, barDistance, barWidth, 8, BRICKS_SERVER.Func.GetTheme( 3 ) )

                            local maxTiers = #(val.Tiers or {})
                            local currentTier = (printerTable.Servers[i] or {})[key] or 0

                            draw.RoundedBoxEx( 4, spacing+iconSize+spacing, barDistance, (currentTier/maxTiers)*barWidth, 8, BRICKS_SERVER.Func.GetTheme( 5 ), true, (currentTier >= maxTiers), true, (currentTier >= maxTiers) )

                            for barI = 1, maxTiers-1 do
                                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
                                surface.DrawRect( spacing+iconSize+spacing+(barI*(barWidth/maxTiers))-0.5, barDistance, 1, 8 )
                            end

                            surface.SetAlphaMultiplier( 1 )
                        end

                        local upgradeButton = vgui.Create( "DButton", upgradeBack )
                        upgradeButton:Dock( RIGHT )
                        upgradeButton:DockMargin( 0, 3, 5, 3 )
                        upgradeButton:SetWide( 46 )
                        upgradeButton:SetText( "" )
                        local Alpha = 0
                        upgradeButton.Paint = function( self2, w, h ) 
                            if( not printerTable.Servers or not printerTable.Servers[i] ) then
                                surface.SetAlphaMultiplier( 0.5 )
                            end

                            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
                
                            if( self2.Hovered ) then
                                Alpha = math.Clamp( Alpha+10, 0, 255 )
                            else
                                Alpha = math.Clamp( Alpha-10, 0, 255 )
                            end
                        
                            surface.SetAlphaMultiplier( Alpha/255 )
                            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
                            surface.SetAlphaMultiplier( 1 )

                            local currentTier = (printerTable.Servers[i] or {})[key] or 0

                            local iconSize = 10
                            surface.SetFont( "BRICKS_SERVER_Font11" )
                            
                            local text = DarkRP.formatMoney( ((val.Tiers)[currentTier+1] or {}).Price or 0 )
                            local textX, textY = surface.GetTextSize( text )

                            local totalH = iconSize+1+textY

                            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                            surface.SetMaterial( upgradeMat )
                            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(totalH/2), iconSize, iconSize )

                            draw.SimpleText( text, "BRICKS_SERVER_Font11", w/2, (h/2)-(totalH/2)+iconSize+1, BRICKS_SERVER.Func.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )

                            surface.SetAlphaMultiplier( 1 )
                        end
                        upgradeButton.DoClick = function()
                            if( not printerTable.Servers[i] or (printerTable.Servers[i][key] or 0) >= #(val.Tiers or {}) ) then return end

                            net.Start( "BRS.Net.GangPrinterBuyServerUpgrade" )
                                net.WriteUInt( k, 8 )
                                net.WriteUInt( i, 3 )
                                net.WriteString( key )
                            net.SendToServer()
                        end
                    end

                    local slotButton = vgui.Create( "DButton", slotBack )
                    slotButton:Dock( BOTTOM )
                    slotButton:DockMargin( 0, 4, 0, 0 )
                    slotButton:SetTall( BRICKS_SERVER.Func.ScreenScale( 30 ) )
                    slotButton:SetText( "" )
                    local Alpha = 0
                    slotButton.Paint = function( self2, w, h ) 
                        local purchased = printerTable.Servers and printerTable.Servers[i]

                        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( (purchased and 2) or 5 ) )

                        if( not purchased ) then
                            if( self2.Hovered ) then
                                Alpha = math.Clamp( Alpha+10, 0, 255 )
                            else
                                Alpha = math.Clamp( Alpha-10, 0, 255 )
                            end
                        
                            surface.SetAlphaMultiplier( Alpha/255 )
                            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
                            surface.SetAlphaMultiplier( 1 )

                            draw.SimpleText( "PURCHASE", "BRICKS_SERVER_Font13", w/2, h/2+1.5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
                            draw.SimpleText( DarkRP.formatMoney( price ), "BRICKS_SERVER_Font13", w/2, h/2-1.5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                        else
                            draw.SimpleText( "PURCHASED", "BRICKS_SERVER_Font13", w/2, h/2, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        end
                    end
                    slotButton.DoClick = function()
                        if( printerTable.Servers and printerTable.Servers[i] ) then return end

                        net.Start( "BRS.Net.GangPrinterBuyServer" )
                            net.WriteUInt( k, 8 )
                            net.WriteUInt( i, 4 )
                        net.SendToServer()
                    end

                    slotBack:SetTall( 72+(table.Count( BRICKS_SERVER.CONFIG.GANGPRINTERS.ServerUpgrades )*(BRICKS_SERVER.Func.ScreenScale( 40 )+8))+4+slotButton:GetTall() )
                end

                for key, val in pairs( BRICKS_SERVER.CONFIG.GANGPRINTERS.Upgrades ) do
                    local devConfigUpgrade = BRICKS_SERVER.DEVCONFIG.GangPrinterUpgradeTypes[key]
            
                    if( not devConfigUpgrade ) then return end
            
                    local slotBack = vgui.Create( "DPanel", grid )
                    slotBack:SetSize( slotW, 110 )
                    slotBack:DockPadding( 12, 60, 12, 12 )
                    slotBack.Paint = function( self2, w, h ) 
                        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
            
                        draw.SimpleText( val.Name, "BRICKS_SERVER_Font25", w/2, 60/2, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            
                        if( val.Price ) then
                            draw.SimpleText( DarkRP.formatMoney( val.Price ), "BRICKS_SERVER_Font13", w/2, h/2-3, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        end
                    end
            
                    if( val.Tiers ) then
                        local spacing = BRICKS_SERVER.Func.ScreenScale( 15 )
                        local barDistance = ScrW() == 2560 and 25 or BRICKS_SERVER.Func.ScreenScale( 5 )
                        local upgradeBack = vgui.Create( "DPanel", slotBack )
                        upgradeBack:Dock( TOP )
                        upgradeBack:DockMargin( 0, 0, 0, 8 )
                        upgradeBack:SetTall( BRICKS_SERVER.Func.ScreenScale( 40 ) )
                        upgradeBack.Paint = function( self2, w, h ) 
                            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                
                            local iconSize = BRICKS_SERVER.Func.ScreenScale( 32 )
                            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                            surface.SetMaterial( devConfigUpgrade.Icon )
                            surface.DrawTexturedRect( spacing, (h/2)-(iconSize/2), iconSize, iconSize )

                            draw.SimpleText( string.upper( val.Name ), "BRICKS_SERVER_Font13", spacing+iconSize+spacing, 11, headerColor, 0, 0 )

                            local barWidth = w-spacing-iconSize-spacing-60
                            draw.RoundedBox( 4, spacing+iconSize+spacing, barDistance, barWidth, 8, BRICKS_SERVER.Func.GetTheme( 3 ) )

                            local maxTiers = #(val.Tiers or {})
                            local currentTier = (printerTable.Upgrades or {})[key] or 0

                            draw.RoundedBoxEx( 4, spacing+iconSize+spacing, barDistance, (currentTier/maxTiers)*barWidth, 8, BRICKS_SERVER.Func.GetTheme( 5 ), true, (currentTier >= maxTiers), true, (currentTier >= maxTiers) )

                            for barI = 1, maxTiers-1 do
                                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
                                surface.DrawRect( spacing+iconSize+spacing+(barI*(barWidth/maxTiers))-0.5, barDistance, 1, 8 )
                            end
                        end
            
                        local upgradeButton = vgui.Create( "DButton", upgradeBack )
                        upgradeButton:Dock( RIGHT )
                        upgradeButton:DockMargin( 0, 3, 5, 3 )
                        upgradeButton:SetWide( 46 )
                        upgradeButton:SetText( "" )
                        local Alpha = 0
                        upgradeButton.Paint = function( self2, w, h ) 
                            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
                
                            if( self2.Hovered ) then
                                Alpha = math.Clamp( Alpha+10, 0, 255 )
                            else
                                Alpha = math.Clamp( Alpha-10, 0, 255 )
                            end
                        
                            surface.SetAlphaMultiplier( Alpha/255 )
                            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
                            surface.SetAlphaMultiplier( 1 )
            
                            local currentTier = (printerTable.Upgrades or {})[key] or 0
            
                            local iconSize = 10
                            surface.SetFont( "BRICKS_SERVER_Font11" )
                            
                            local text = DarkRP.formatMoney( ((val.Tiers)[currentTier+1] or {}).Price or 0 )
                            local textX, textY = surface.GetTextSize( text )
            
                            local totalH = iconSize+1+textY
            
                            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                            surface.SetMaterial( upgradeMat )
                            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(totalH/2), iconSize, iconSize )
            
                            draw.SimpleText( text, "BRICKS_SERVER_Font11", w/2, (h/2)-(totalH/2)+iconSize+1, BRICKS_SERVER.Func.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )
                        end
                        upgradeButton.DoClick = function()
                            if( ((printerTable.Upgrades or {})[key] or 0) >= #(val.Tiers or {}) ) then return end
            
                            net.Start( "BRS.Net.GangPrinterBuyUpgrade" )
                                net.WriteUInt( k, 8 )
                                net.WriteString( key )
                            net.SendToServer()
                        end
                    else
                        local slotButton = vgui.Create( "DButton", slotBack )
                        slotButton:Dock( BOTTOM )
                        slotButton:DockMargin( 0, 4, 0, 0 )
                        slotButton:SetTall( 30 )
                        slotButton:SetText( "" )
                        local Alpha = 0
                        slotButton.Paint = function( self2, w, h ) 
                            local purchased = (printerTable.Upgrades or {})[key]
                
                            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( (purchased and 2) or 5 ) )
                
                            if( not purchased ) then
                                if( self2.Hovered ) then
                                    Alpha = math.Clamp( Alpha+10, 0, 255 )
                                else
                                    Alpha = math.Clamp( Alpha-10, 0, 255 )
                                end
                            
                                surface.SetAlphaMultiplier( Alpha/255 )
                                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
                                surface.SetAlphaMultiplier( 1 )
                
                                draw.SimpleText( "PURCHASE", "BRICKS_SERVER_Font13", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            else
                                draw.SimpleText( "PURCHASED", "BRICKS_SERVER_Font13", w/2, h/2, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            end
                        end
                        slotButton.DoClick = function()
                            if( (printerTable.Upgrades or {})[key] ) then return end
                
                            net.Start( "BRS.Net.GangPrinterBuyUpgrade" )
                                net.WriteUInt( k, 8 )
                                net.WriteString( key )
                            net.SendToServer()
                        end
                    end
                end
            end

            local printerBack = vgui.Create( "DPanel", page )
            printerBack:Dock( FILL )
            printerBack:DockMargin( 10, 5, 10, 5 )
            printerBack.Paint = function( self2, w, h ) end

            local printerModel = vgui.Create( "DModelPanel" , printerBack )
            printerModel:Dock( FILL )
            printerModel:SetModel( "models/ogl/ogl_bricksprinterrack.mdl" )
            if( IsValid( printerModel.Entity ) ) then
                function printerModel:LayoutEntity(ent) 
                    printerModel:RunAnimation()
                end
                local mn, mx = printerModel.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

                printerModel:SetFOV( 60 )
                printerModel:SetCamPos( Vector( size, size, size ) )
                printerModel:SetLookAt( (mn + mx) * 0.5 )

                printerModel.Entity:SetAngles( printerModel.Entity:GetAngles()+Angle( 25, 220, -2 ) )

                if( printerTable ) then
                    if( printerTable.Servers ) then
                        for key, val in pairs( printerTable.Servers ) do
                            if( not val ) then continue end

                            printerModel.Entity:SetBodygroup( key, 1 )

                            local coolingBought = val.Cooling or 0
                            if( coolingBought >= maxCoolingUpgrade/2 ) then
                                printerModel.Entity:SetBodygroup( 8+((key-1)*2), 1 )

                                if( coolingBought >= maxCoolingUpgrade ) then
                                    printerModel.Entity:SetBodygroup( 8+((key-1)*2)+1, 1 )
                                end
                            end
                        end
                    end

                    if( printerTable.Upgrades and printerTable.Upgrades["RGB"] ) then
                        printerModel.Entity:SetBodygroup( 7, 1 )
                    end
                end

                printerModel.Entity:SetSequence( "fanson" )
                printerModel.Entity:SetPlaybackRate( 5 )
            end
        end


    end
    self.RefreshPanel()

    hook.Add( "BRS.Hooks.RefreshGang", self, function( self, valuesChanged )
        if( IsValid( self ) ) then
            if( valuesChanged and valuesChanged["Printers"] ) then
                self.RefreshPanel()
            end
        else
            hook.Remove( "BRS.Hooks.RefreshGang", self )
        end
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_printers", PANEL, "DPanel" )