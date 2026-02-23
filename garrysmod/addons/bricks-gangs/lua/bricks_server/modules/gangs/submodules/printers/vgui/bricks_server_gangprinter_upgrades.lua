local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( ent )
    if( not IsValid( ent ) ) then return end
    
    local scrollPanel = vgui.Create( "bricks_server_scrollpanel", self )
    scrollPanel:Dock( FILL )
    scrollPanel:DockMargin( 15, 12, 15, 15 )
    scrollPanel.Paint = function( self, w, h ) end 

    local spacing = 12
    local gridWide = BRICKS_SERVER.DEVCONFIG.GangPrinterW-30
    local slotsWide = 3
    local slotW, slotH = (gridWide-((slotsWide-1)*spacing))/slotsWide, 250

    local grid = vgui.Create( "DIconLayout", scrollPanel )
    grid:Dock( FILL )
    grid:SetSpaceY( spacing )
    grid:SetSpaceX( spacing )

    local upgradeMat = Material( "bricks_server/gangprinter_upgrade.png" )
    local headerColor = Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 50 )
    for i = 1, BRICKS_SERVER.DEVCONFIG.GangPrinterSlots do
        local price = ((BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[ent:GetPrinterID()] or {}).ServerPrices or {})[i] or 0

        local slotBack = vgui.Create( "DPanel", grid )
        slotBack:SetSize( slotW, slotH )
        slotBack:DockPadding( 12, 60, 12, 12 )
        slotBack.Paint = function( self2, w, h ) 
            if( (ent:GetServers() or 0) < i ) then
                surface.SetAlphaMultiplier( 0.65 )
            end

            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

            draw.SimpleText( "SERVER SLOT " .. i, "BRICKS_SERVER_Font25", w/2, 60/2, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            surface.SetAlphaMultiplier( 1 )
        end

        for k, v in pairs( BRICKS_SERVER.CONFIG.GANGPRINTERS.ServerUpgrades ) do
            local devConfigUpgrade = BRICKS_SERVER.DEVCONFIG.GangServerUpgradeTypes[k] or {}

            local upgradeBack = vgui.Create( "DPanel", slotBack )
            upgradeBack:Dock( TOP )
            upgradeBack:DockMargin( 0, 0, 0, 8 )
            upgradeBack:SetTall( 40 )
            upgradeBack.Paint = function( self2, w, h ) 
                if( (ent:GetServers() or 0) < i ) then
                    surface.SetAlphaMultiplier( 0.5 )
                end

                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    
                local iconSize = 32
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( devConfigUpgrade.Icon )
                surface.DrawTexturedRect( 15, (h/2)-(iconSize/2), iconSize, iconSize )

                draw.SimpleText( string.upper( v.Name ), "BRICKS_SERVER_Font13", 15+iconSize+15, 11, headerColor, 0, 0 )

                local barWidth = w-15-iconSize-15-60
                draw.RoundedBox( 4, 15+iconSize+15, 25, barWidth, 8, BRICKS_SERVER.Func.GetTheme( 3 ) )

                local maxTiers = #(v.Tiers or {})
                local currentTier = devConfigUpgrade.GetFunc( ent, i )

                draw.RoundedBoxEx( 4, 15+iconSize+15, 25, (currentTier/maxTiers)*barWidth, 8, BRICKS_SERVER.Func.GetTheme( 5 ), true, (currentTier >= maxTiers), true, (currentTier >= maxTiers) )

                for barI = 1, maxTiers-1 do
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
                    surface.DrawRect( 15+iconSize+15+(barI*(barWidth/maxTiers))-0.5, 25, 1, 8 )
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
                if( (ent:GetServers() or 0) < i ) then
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

                local currentTier = devConfigUpgrade.GetFunc( ent, i )

                local iconSize = 10
                surface.SetFont( "BRICKS_SERVER_Font11" )
                
                local text = DarkRP.formatMoney( ((v.Tiers)[currentTier+1] or {}).Price or 0 )
                local textX, textY = surface.GetTextSize( text )

                local totalH = iconSize+1+textY

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( upgradeMat )
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(totalH/2), iconSize, iconSize )

                draw.SimpleText( text, "BRICKS_SERVER_Font11", w/2, (h/2)-(totalH/2)+iconSize+1, BRICKS_SERVER.Func.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )

                surface.SetAlphaMultiplier( 1 )
            end
            upgradeButton.DoClick = function()
                if( devConfigUpgrade.GetFunc( ent, i ) >= #(v.Tiers or {}) ) then return end

                net.Start( "BRS.Net.GangPrinterBuyServerUpgrade" )
                    net.WriteUInt( ent:GetPrinterID(), 8 )
                    net.WriteUInt( i, 3 )
                    net.WriteString( k )
                net.SendToServer()
            end
        end

        local slotButton = vgui.Create( "DButton", slotBack )
        slotButton:Dock( BOTTOM )
        slotButton:DockMargin( 0, 4, 0, 0 )
        slotButton:SetTall( 30 )
        slotButton:SetText( "" )
        local Alpha = 0
        slotButton.Paint = function( self2, w, h ) 
            local purchased = (ent:GetServers() or 0) >= i

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
            if( (ent:GetServers() or 0) >= i ) then return end

            net.Start( "BRS.Net.GangPrinterBuyServer" )
                net.WriteUInt( ent:GetPrinterID(), 8 )
                net.WriteUInt( i, 4 )
            net.SendToServer()
        end
    end

    for k, v in pairs( BRICKS_SERVER.CONFIG.GANGPRINTERS.Upgrades ) do
        local devConfigUpgrade = BRICKS_SERVER.DEVCONFIG.GangPrinterUpgradeTypes[k]

        if( not devConfigUpgrade ) then return end

        local slotBack = vgui.Create( "DPanel", grid )
        slotBack:SetSize( slotW, 110 )
        slotBack:DockPadding( 12, 60, 12, 12 )
        slotBack.Paint = function( self2, w, h ) 
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

            draw.SimpleText( v.Name, "BRICKS_SERVER_Font25", w/2, 60/2, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            if( v.Price ) then
                draw.SimpleText( DarkRP.formatMoney( v.Price ), "BRICKS_SERVER_Font13", w/2, h/2-3, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end

        if( v.Tiers ) then
            local upgradeBack = vgui.Create( "DPanel", slotBack )
            upgradeBack:Dock( TOP )
            upgradeBack:SetTall( 40 )
            upgradeBack.Paint = function( self2, w, h ) 
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    
                local iconSize = 32
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( devConfigUpgrade.Icon )
                surface.DrawTexturedRect( 15, (h/2)-(iconSize/2), iconSize, iconSize )

                draw.SimpleText( string.upper( devConfigUpgrade.Name ), "BRICKS_SERVER_Font13", 15+iconSize+15, 11, headerColor, 0, 0 )

                local barWidth = w-15-iconSize-15-60
                draw.RoundedBox( 4, 15+iconSize+15, 25, barWidth, 8, BRICKS_SERVER.Func.GetTheme( 3 ) )

                local maxTiers = #(v.Tiers or {})
                local currentTier = devConfigUpgrade.GetFunc( ent )

                draw.RoundedBoxEx( 4, 15+iconSize+15, 25, (currentTier/maxTiers)*barWidth, 8, BRICKS_SERVER.Func.GetTheme( 5 ), true, (currentTier >= maxTiers), true, (currentTier >= maxTiers) )

                for barI = 1, maxTiers-1 do
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
                    surface.DrawRect( 15+iconSize+15+(barI*(barWidth/maxTiers))-0.5, 25, 1, 8 )
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

                local currentTier = devConfigUpgrade.GetFunc( ent, i )

                local iconSize = 10
                surface.SetFont( "BRICKS_SERVER_Font11" )
                
                local text = DarkRP.formatMoney( ((v.Tiers)[currentTier+1] or {}).Price or 0 )
                local textX, textY = surface.GetTextSize( text )

                local totalH = iconSize+1+textY

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( upgradeMat )
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(totalH/2), iconSize, iconSize )

                draw.SimpleText( text, "BRICKS_SERVER_Font11", w/2, (h/2)-(totalH/2)+iconSize+1, BRICKS_SERVER.Func.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )
            end
            upgradeButton.DoClick = function()
                if( devConfigUpgrade.GetFunc( ent ) >= #(v.Tiers or {}) ) then return end

                net.Start( "BRS.Net.GangPrinterBuyUpgrade" )
                    net.WriteUInt( ent:GetPrinterID(), 8 )
                    net.WriteString( k )
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
                local purchased = devConfigUpgrade.GetFunc( ent )
    
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
                if( devConfigUpgrade.GetFunc( ent ) ) then return end
    
                net.Start( "BRS.Net.GangPrinterBuyUpgrade" )
                    net.WriteUInt( ent:GetPrinterID(), 8 )
                    net.WriteString( k )
                net.SendToServer()
            end
        end
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangprinter_upgrades", PANEL, "DPanel" )