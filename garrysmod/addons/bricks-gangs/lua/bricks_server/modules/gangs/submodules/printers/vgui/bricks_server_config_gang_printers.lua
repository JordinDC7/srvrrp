local PANEL = {}

function PANEL:Init()
    self.margin = 0
    self.panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 10, 10, 10, 10 )
end

function PANEL:FillPanel( configPanel )
    BRICKS_SERVER.Func.FillVariableConfigs( self.scrollPanel, "GANGPRINTERS", "GANGPRINTERS" )

    local spacing = 5
    local gridWide = self.panelWide-20
    local slotsWide = (ScrW() >= 1920 and 3) or 2
    local slotW, slotH = (gridWide-((slotsWide-1)*spacing))/slotsWide, ScrH()*0.35

    local grid = vgui.Create( "DIconLayout", self.scrollPanel )
    grid:Dock( FILL )
    grid:SetSpaceY( spacing )
    grid:SetSpaceX( spacing )

    local panelTall = (ScrH()*0.65)-40

    local configVariables = {
        { "Name", "Name", "" },
        { "Price", "Price", 0 },
        { "Server Prices", "ServerPrices", {}, function( printerKey )
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

            for i = 1, BRICKS_SERVER.DEVCONFIG.GangPrinterSlots do
                surface.SetFont( "BRICKS_SERVER_Font23" )
                local textX, textY = surface.GetTextSize( "Server " .. i .. " Price" )
    
                local variableBack = vgui.Create( "DPanel", self.popout )
                variableBack:Dock( TOP )
                variableBack:DockMargin( 25, 0, 25, 5 )
                variableBack:SetTall( 40 )
                variableBack.Paint = function( self2, w, h ) 
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
    
                    draw.RoundedBoxEx( 8, 0, 0, textX+15, h, BRICKS_SERVER.Func.GetTheme( 1 ), true, false, true, false )
                    draw.SimpleText( "Server " .. i .. " Price", "BRICKS_SERVER_Font20", (textX+15)/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
    
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
    
                valueEntry = vgui.Create( "bricks_server_numberwang", valueEntryBack )
                valueEntry:Dock( FILL )
                valueEntry:SetMinMax( 0, 9999999999999 )
                valueEntry:SetValue( (BS_ConfigCopyTable.GANGPRINTERS.Printers[printerKey].ServerPrices or {})[i] or 0 )
                valueEntry.OnValueChanged = function( self2, value )
                    if( not BS_ConfigCopyTable.GANGPRINTERS.Printers[printerKey].ServerPrices ) then
                        BS_ConfigCopyTable.GANGPRINTERS.Printers[printerKey].ServerPrices = {}
                    end

                    BS_ConfigCopyTable.GANGPRINTERS.Printers[printerKey].ServerPrices[i] = value

                    BRICKS_SERVER.Func.ConfigChange( "GANGPRINTERS" )
                end
            end
        end },
        { "Server Print Amount", "ServerAmount", 0 },
        { "Server Heat Generated", "ServerHeat", 0 },
        { "Server Print Time", "ServerTime", 0 },
        { "Maximum Heat", "MaxHeat", 0 },
        { "Base Heat", "BaseHeat", 0 }
    }

    function self.RefreshPanel()
        grid:Clear()

        for k, v in pairs( BS_ConfigCopyTable.GANGPRINTERS.Printers ) do
            local slotBack = vgui.Create( "DPanel", grid )
            slotBack:SetSize( slotW, slotH )
            slotBack:DockPadding( 10, 40, 10, 10 )
            slotBack.Paint = function( self2, w, h ) 
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

                draw.SimpleText( (v.Name or ""), "BRICKS_SERVER_Font25", w/2, 60/2, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end

            local printerModel = vgui.Create( "DModelPanel" , slotBack )
            printerModel:Dock( TOP )
            printerModel:SetTall( slotH/2.75 )
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

                printerModel:SetFOV( 50 )
                printerModel:SetCamPos( Vector( size, size, size ) )
                printerModel:SetLookAt( (mn + mx) * 0.5 )

                printerModel.Entity:SetAngles( printerModel.Entity:GetAngles()+Angle( 25, 220, -2 ) )

                for i = 1, BRICKS_SERVER.DEVCONFIG.GangPrinterSlots do
                    printerModel.Entity:SetBodygroup( i, 1 )
                    printerModel.Entity:SetBodygroup( 8+((i-1)*2), 1 )
                    printerModel.Entity:SetBodygroup( 8+((i-1)*2)+1, 1 )
                end

                printerModel.Entity:SetBodygroup( 7, 1 )

                printerModel.Entity:SetSequence( "fanson" )
                printerModel.Entity:SetPlaybackRate( 5 )
            end

            local slotScrollpanel = vgui.Create( "bricks_server_scrollpanel_bar", slotBack )
            slotScrollpanel:Dock( FILL )
            slotScrollpanel.Paint = function( self, w, h ) end 

            for key, val in ipairs( configVariables ) do
                surface.SetFont( "BRICKS_SERVER_Font23" )
                local textX, textY = surface.GetTextSize( val[1] )

                local variableBack = vgui.Create( "DPanel", slotScrollpanel )
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
                            BS_ConfigCopyTable.GANGPRINTERS.Printers[k][val[2]] = value
                            BRICKS_SERVER.Func.ConfigChange( "GANGPRINTERS" )
                        end
                    else
                        valueEntry = vgui.Create( "bricks_server_textentry", valueEntryBack )
                        valueEntry:Dock( FILL )
                        valueEntry:SetValue( v[val[2]] or val[3] )
                        valueEntry.OnChange = function( self2, value )
                            BS_ConfigCopyTable.GANGPRINTERS.Printers[k][val[2]] = valueEntry:GetValue()
                            BRICKS_SERVER.Func.ConfigChange( "GANGPRINTERS" )
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

            
            local removeButton = vgui.Create( "DButton", slotScrollpanel )
            removeButton:Dock( TOP )
            removeButton:DockMargin( 0, 0, 5, 5 )
            removeButton:SetTall( 40 )
            removeButton:SetText( "" )
            local changeAlpha = 0
            removeButton.Paint = function( self2, w, h )
                if( self2:IsHovered() and not self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                end
                
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
                surface.SetAlphaMultiplier( 1 )

                BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
        
                draw.SimpleText( BRICKS_SERVER.Func.L( "remove" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            removeButton.DoClick = function()
                BS_ConfigCopyTable.GANGPRINTERS.Printers[k] = nil
                BRICKS_SERVER.Func.ConfigChange( "GANGPRINTERS" )
                self.RefreshPanel()
            end
        end

        local addNewButton = grid:Add( "DButton" )
        addNewButton:SetSize( slotW, slotH )
        addNewButton:SetText( "" )
        local alpha = 0
        local addMat = Material( "materials/bricks_server/add_64.png" )
        addNewButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 200 )
            else
                alpha = math.Clamp( alpha-5, 0, 255 )
            end
    
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    
            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
            surface.SetAlphaMultiplier( 1 )
    
            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
            surface.SetMaterial( addMat )
            local iconSize = 64
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        addNewButton.DoClick = function()
            table.insert( BS_ConfigCopyTable.GANGPRINTERS.Printers, {
                Name = "New Printer",
                Price = 5000,
                ServerPrices = { 1000, 1500, 2500, 4000, 6500, 8000 },
                ServerAmount = 100,
                ServerHeat = 8,
                MaxHeat = 60,
                BaseHeat = 20,
                ServerTime = 2
            } )
            BRICKS_SERVER.Func.ConfigChange( "GANGPRINTERS" )
            self.RefreshPanel()
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_gang_printers", PANEL, "DPanel" )