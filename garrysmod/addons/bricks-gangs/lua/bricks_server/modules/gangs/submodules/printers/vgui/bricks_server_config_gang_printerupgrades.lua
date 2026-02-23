local PANEL = {}

function PANEL:Init()
    self.margin = 0
    self.panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 10, 10, 10, 10 )
end

function PANEL:FillPanel( configPanel )
    local spacing = 5
    local gridWide = self.panelWide-20
    local slotsWide = 3
    local slotW = (gridWide-((slotsWide-1)*spacing))/slotsWide

    local grid = vgui.Create( "DIconLayout", self.scrollPanel )
    grid:Dock( FILL )
    grid:SetSpaceY( spacing )
    grid:SetSpaceX( spacing )

    local panelTall = (ScrH()*0.65)-40

    local upgradeMat = Material( "bricks_server/gangprinter_upgrade.png" )

    local function addUpgradeSlot( k, v, isServerUpgrade )
        local devConfigUpgrade = ((isServerUpgrade and BRICKS_SERVER.DEVCONFIG.GangServerUpgradeTypes) or BRICKS_SERVER.DEVCONFIG.GangPrinterUpgradeTypes)[k]

        if( not devConfigUpgrade ) then return end

        local function changeConfigVariable( configKey, newConfigValue )
            local currentConfigTable = isServerUpgrade and BS_ConfigCopyTable.GANGPRINTERS.ServerUpgrades[k] or BS_ConfigCopyTable.GANGPRINTERS.Upgrades[k]
            currentConfigTable[configKey] = newConfigValue

            BRICKS_SERVER.Func.ConfigChange( "GANGPRINTERS" )
        end

        local configVariables = {
            { "Name", "Name", "" }
        }

        if( not devConfigUpgrade.Tiered ) then
            table.insert( configVariables, { "Price", "Price", 0 } )
        else
            table.insert( configVariables, { "Tiers", "Tiers", {}, function()
                if( IsValid( self.popout ) ) then
                    self.popout:Remove()
                end
        
                local popoutClose = vgui.Create( "DPanel", self )
                popoutClose:SetSize( self.panelWide, panelTall )
                popoutClose:SetAlpha( 0 )
                popoutClose:AlphaTo( 255, 0.2 )
                popoutClose.Paint = function( self2, w, h )
                    surface.SetDrawColor( 0, 0, 0, 150 )
                    surface.DrawRect( 0, 0, w, h )
                    BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
                end
        
                local popoutWide, popoutTall = self.panelWide*0.5, panelTall-self.panelWide*0.1
        
                self.popout = vgui.Create( "DPanel", self )
                self.popout:SetSize( 0, 0 )
                self.popout:SizeTo( popoutWide, popoutTall, 0.2 )
                self.popout:DockPadding( 0, 25, 0, 0 )
                self.popout.Paint = function( self2, w, h )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                end
                self.popout.OnSizeChanged = function( self2 )
                    self2:SetPos( (self.panelWide/2)-(self2:GetWide()/2), (panelTall/2)-(self2:GetTall()/2) )
                end
                self.popout.ClosePopout = function()
                    if( IsValid( self.popout ) ) then
                        self.popout:SizeTo( 0, 0, 0.2, 0, -1, function()
                            if( IsValid( self.popout ) ) then
                                self.popout:Remove()
                            end
                        end )
                    end
        
                    popoutClose:AlphaTo( 0, 0.2, 0, function()
                        if( IsValid( popoutClose ) ) then
                            popoutClose:Remove()
                        end
                    end )
                end
        
                local popoutCloseButton = vgui.Create( "DButton", self.popout )
                popoutCloseButton:Dock( BOTTOM )
                popoutCloseButton:SetTall( 40 )
                popoutCloseButton:SetText( "" )
                popoutCloseButton:DockMargin( 25, 0, 25, 25 )
                local changeAlpha = 0
                popoutCloseButton.Paint = function( self2, w, h )
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
                popoutCloseButton.DoClick = self.popout.ClosePopout

                local scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.popout )
                scrollPanel:Dock( FILL )
                scrollPanel:DockMargin( 25, 25, 25, 25 )

                local tierConfigVariables = {
                    { "Price", "Price", 0 },
                    { "Level", "Level", 0 },
                    { "Group", "Group", "", function( key )
                        local options = {}
                        options["None"] = BRICKS_SERVER.Func.L( "none" )
                        for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
                            options[k] = v[1]
                        end
                        BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "groupRequirementQuery" ), (v.Tiers[key].Group or ""), options, function( value, data ) 
                            if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups[data] ) then
                                v.Tiers[key].Group = value
                                changeConfigVariable( "Tiers", v.Tiers )
                            elseif( data == "None" ) then
                                v.Tiers[key].Group = nil
                                changeConfigVariable( "Tiers", v.Tiers )
                            else
                                notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidGroup" ), 1, 3 )
                            end
                        end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
                    end }
                }

                for key, val in pairs( devConfigUpgrade.ReqInfo ) do
                    table.insert( tierConfigVariables, { val[1], function( tierKey, value )
                        v.Tiers[tierKey].ReqInfo = v.Tiers[tierKey].ReqInfo or {}
                        v.Tiers[tierKey].ReqInfo[key] = value
                        changeConfigVariable( "Tiers", v.Tiers )
                    end, function( tierKey )
                        return (v.Tiers[tierKey].ReqInfo or {})[key] or 0
                    end } )
                end

                for key, val in ipairs( v.Tiers or {} ) do
                    local tierBack = vgui.Create( "DPanel", scrollPanel )
                    tierBack:Dock( TOP )
                    tierBack:DockMargin( 0, 0, 10, 5 )
                    tierBack:DockPadding( 5, 30, 5, 5 )
                    tierBack:SetTall( 30+(#tierConfigVariables*45) )
                    tierBack.Paint = function( self2, w, h )
                        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
            
                        draw.SimpleText( "TIER " .. key, "BRICKS_SERVER_Font20", 10, 5, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )
                    end

                    for key2, val2 in ipairs( tierConfigVariables ) do
                        surface.SetFont( "BRICKS_SERVER_Font23" )
                        local textX, textY = surface.GetTextSize( val2[1] )
            
                        local variableBack = vgui.Create( "DPanel", tierBack )
                        variableBack:Dock( TOP )
                        variableBack:DockMargin( 0, 0, 0, 5 )
                        variableBack:SetTall( 40 )
                        variableBack.Paint = function( self2, w, h ) 
                            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            
                            draw.RoundedBoxEx( 8, 0, 0, textX+15, h, BRICKS_SERVER.Func.GetTheme( 0 ), true, false, true, false )
                            draw.SimpleText( val2[1], "BRICKS_SERVER_Font20", (textX+15)/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        end
            
                        local defaultValue = (isfunction( val2[3] ) and val2[3]( key )) or val2[3]
                        if( (not val2[4] or not isfunction( val2[4] )) and (isstring( defaultValue ) or isnumber( defaultValue )) ) then
                            local valueEntryBack = vgui.Create( "DPanel", variableBack )
                            valueEntryBack:Dock( FILL )
                            valueEntryBack:DockMargin( textX+15, 0, 0, 0 )
                            local Alpha = 0
                            local valueEntry
                            local color1 = BRICKS_SERVER.Func.GetTheme( 1 )
                            valueEntryBack.Paint = function( self2, w, h )
                                if( valueEntry:IsEditing() ) then
                                    Alpha = math.Clamp( Alpha+5, 0, 100 )
                                else
                                    Alpha = math.Clamp( Alpha-5, 0, 100 )
                                end
                                
                                draw.RoundedBoxEx( 8, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ), false, true, false, true )
                            end
                
                            if( isnumber( defaultValue ) ) then
                                valueEntry = vgui.Create( "bricks_server_numberwang", valueEntryBack )
                                valueEntry:Dock( FILL )
                                valueEntry:SetMinMax( 0, 9999999999999 )
                                valueEntry:SetValue( v.Tiers[key][val2[2]] or defaultValue )
                                valueEntry.OnValueChanged = function( self2, value )
                                    if( isfunction( val2[2] ) ) then
                                        val2[2]( key, value )
                                    else
                                        v.Tiers[key][val2[2]] = value
                                    end

                                    changeConfigVariable( "Tiers", v.Tiers )
                                end
                            else
                                valueEntry = vgui.Create( "bricks_server_textentry", valueEntryBack )
                                valueEntry:Dock( FILL )
                                valueEntry:SetValue( v.Tiers[key][val2[2]] or defaultValue )
                                valueEntry.OnChange = function( self2, value )
                                    if( isfunction( val2[2] ) ) then
                                        val2[2]( key, valueEntry:GetValue() )
                                    else
                                        v.Tiers[key][val2[2]] = valueEntry:GetValue()
                                    end

                                    changeConfigVariable( "Tiers", v.Tiers )
                                end
                            end
                        elseif( val2[4] and isfunction( val2[4] ) ) then
                            local valueEntryButton = vgui.Create( "DButton", variableBack )
                            valueEntryButton:Dock( FILL )
                            valueEntryButton:DockMargin( textX+15, 0, 0, 0 )
                            valueEntryButton:SetText( "" )
                            local alpha = 0
                            valueEntryButton.Paint = function( self2, w, h )
                                if( not self2:IsDown() and self2:IsHovered() ) then
                                    alpha = math.Clamp( alpha+5, 0, 125 )
                                else
                                    alpha = math.Clamp( alpha-5, 0, 125 )
                                end
                    
                                surface.SetAlphaMultiplier( alpha/255 )
                                draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), false, true, false, true )
                                surface.SetAlphaMultiplier( 1 )
                    
                                BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
                    
                                draw.SimpleText( "Edit", "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            end
                            valueEntryButton.DoClick = function()
                                val2[4]( key )
                            end
                        end
                    end
                end
            end } )
        end

        local iconSize = 64
        
        local slotBack = vgui.Create( "DPanel", grid )
        slotBack:SetSize( slotW, 60+20+iconSize+(#configVariables*45)-5+10 )
        slotBack:DockPadding( 10, 60+20+iconSize, 10, 10 )
        slotBack.Paint = function( self2, w, h ) 
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

            draw.SimpleText( ((isServerUpgrade and "Server - ") or "") .. (v.Name or ""), "BRICKS_SERVER_Font25", w/2, 60/2, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
            surface.SetMaterial( devConfigUpgrade.Icon or upgradeMat )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), 60, iconSize, iconSize )
        end

        for key, val in ipairs( configVariables ) do
            surface.SetFont( "BRICKS_SERVER_Font23" )
            local textX, textY = surface.GetTextSize( val[1] )

            local variableBack = vgui.Create( "DPanel", slotBack )
            variableBack:Dock( TOP )
            variableBack:DockMargin( 0, 0, 5, 5 )
            variableBack:SetTall( 40 )
            variableBack.Paint = function( self2, w, h ) 
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                draw.RoundedBoxEx( 8, 0, 0, textX+15, h, BRICKS_SERVER.Func.GetTheme( 1 ), true, false, true, false )
                draw.SimpleText( val[1], "BRICKS_SERVER_Font20", (textX+15)/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end

            if( isstring( val[3] ) or isnumber( val[3] ) ) then
                local valueEntryBack = vgui.Create( "DPanel", variableBack )
                valueEntryBack:Dock( FILL )
                valueEntryBack:DockMargin( textX+15, 0, 0, 0 )
                local Alpha = 0
                local valueEntry
                local color1 = BRICKS_SERVER.Func.GetTheme( 1 )
                valueEntryBack.Paint = function( self2, w, h )
                    if( valueEntry:IsEditing() ) then
                        Alpha = math.Clamp( Alpha+5, 0, 100 )
                    else
                        Alpha = math.Clamp( Alpha-5, 0, 100 )
                    end
                    
                    draw.RoundedBoxEx( 8, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ), false, true, false, true )
                end
    
                if( isnumber( val[3] ) ) then
                    valueEntry = vgui.Create( "bricks_server_numberwang", valueEntryBack )
                    valueEntry:Dock( FILL )
                    valueEntry:SetMinMax( 0, 9999999999999 )
                    valueEntry:SetValue( v[val[2]] or val[3] )
                    valueEntry.OnValueChanged = function( self2, value )
                        changeConfigVariable( val[2], value )
                    end
                else
                    valueEntry = vgui.Create( "bricks_server_textentry", valueEntryBack )
                    valueEntry:Dock( FILL )
                    valueEntry:SetValue( v[val[2]] or val[3] )
                    valueEntry.OnChange = function( self2, value )
                        changeConfigVariable( val[2], valueEntry:GetValue() )
                    end
                end
            elseif( val[4] and isfunction( val[4] ) ) then
                local valueEntryButton = vgui.Create( "DButton", variableBack )
                valueEntryButton:Dock( FILL )
                valueEntryButton:DockMargin( textX+15, 0, 0, 0 )
                valueEntryButton:SetText( "" )
                local alpha = 0
                valueEntryButton.Paint = function( self2, w, h )
                    if( not self2:IsDown() and self2:IsHovered() ) then
                        alpha = math.Clamp( alpha+5, 0, 125 )
                    else
                        alpha = math.Clamp( alpha-5, 0, 125 )
                    end
        
                    surface.SetAlphaMultiplier( alpha/255 )
                    draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), false, true, false, true )
                    surface.SetAlphaMultiplier( 1 )
        
                    BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        
                    draw.SimpleText( "Edit", "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                valueEntryButton.DoClick = function()
                    val[4]( k )
                end
            end
        end
    end

    for k, v in pairs( BS_ConfigCopyTable.GANGPRINTERS.Upgrades ) do
        addUpgradeSlot( k, v )
    end

    for k, v in pairs( BS_ConfigCopyTable.GANGPRINTERS.ServerUpgrades ) do
        addUpgradeSlot( k, v, true )
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_gang_printerupgrades", PANEL, "DPanel" )