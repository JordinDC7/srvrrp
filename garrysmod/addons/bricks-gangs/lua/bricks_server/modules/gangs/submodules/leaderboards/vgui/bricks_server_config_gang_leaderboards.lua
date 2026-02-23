local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( configPanel )
    function self.RefreshPanel()
        self:Clear()

        for k, v in pairs( BS_ConfigCopyTable.GANGS.Leaderboards or {} ) do
            local itemActions = {
                [1] = { BRICKS_SERVER.Func.L( "edit" ), function()
                    BRICKS_SERVER.Func.CreateLeaderboardEditor( v, function( leaderboardTable ) 
                        BS_ConfigCopyTable.GANGS.Leaderboards[k] = leaderboardTable
                        BRICKS_SERVER.Func.ConfigChange( "GANGS" )
                        self.RefreshPanel()
                    end, function() end )
                end },
                [2] = { BRICKS_SERVER.Func.L( "remove" ), function()
                    BS_ConfigCopyTable.GANGS.Leaderboards[k] = nil
                    BRICKS_SERVER.Func.ConfigChange( "GANGS" )
                    self.RefreshPanel()
                end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed }
            }

            local devConfigTable = BRICKS_SERVER.DEVCONFIG.GangLeaderboards[(v.Type or "")] or {}

            local itemBack = vgui.Create( "DPanel", self )
            itemBack:Dock( TOP )
            itemBack:DockMargin( 0, 0, 0, 5 )
            itemBack:SetTall( 100 )
            itemBack:DockPadding( 0, 0, 25, 0 )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBoxEx( 5, 0, 0, 25, h, (v.Color or BRICKS_SERVER.Func.GetTheme( 5 )), true, false, true, false )

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                surface.DrawRect( 5, 0, 20, h )

                draw.SimpleText( v.Name, "BRICKS_SERVER_Font33", 20, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( BRICKS_SERVER.Func.L( "type" ) .. ": " .. (devConfigTable.Name or BRICKS_SERVER.Func.L( "nil" )), "BRICKS_SERVER_Font20", 20, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            for key2, val2 in ipairs( itemActions ) do
                local itemAction = vgui.Create( "DButton", itemBack )
                itemAction:Dock( RIGHT )
                itemAction:SetText( "" )
                itemAction:DockMargin( 5, 25, 0, 25 )
                surface.SetFont( "BRICKS_SERVER_Font25" )
                local textX, textY = surface.GetTextSize( val2[1] )
                textX = textX+20
                itemAction:SetWide( math.max( (ScrW()/2560)*150, textX ) )
                local changeAlpha = 0
                itemAction.Paint = function( self2, w, h )
                    if( self2:IsHovered() and not self2:IsDown() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                    else
                        changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                    end
                    
                    draw.RoundedBox( 5, 0, 0, w, h, val2[3] or BRICKS_SERVER.Func.GetTheme( 2 ) )
            
                    surface.SetAlphaMultiplier( changeAlpha/255 )
                        draw.RoundedBox( 5, 0, 0, w, h, val2[4] or BRICKS_SERVER.Func.GetTheme( 3 ) )
                    surface.SetAlphaMultiplier( 1 )

                    BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, val2[4] or BRICKS_SERVER.Func.GetTheme( 3 ) )
            
                    draw.SimpleText( val2[1], "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                itemAction.DoClick = function()
                    val2[2]()
                end
            end
        end

        local addNewButton = vgui.Create( "DButton", self )
        addNewButton:Dock( TOP )
        addNewButton:SetText( "" )
        addNewButton:DockMargin( 0, 0, 0, 5 )
        addNewButton:SetTall( 40 )
        local changeAlpha = 0
        addNewButton.Paint = function( self2, w, h )
            if( self2:IsDown() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
            elseif( self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
    
            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )
    
            draw.SimpleText( BRICKS_SERVER.Func.L( "gangAddLeaderboard" ), "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewButton.DoClick = function()
            local options = {}
			for k, v in pairs( BRICKS_SERVER.DEVCONFIG.GangLeaderboards ) do
				options[k] = v.Name
			end

			BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "gangNewLeaderboardType" ), "", options, function( value, data ) 
				if( options[data] and BRICKS_SERVER.DEVCONFIG.GangLeaderboards[data] ) then
                    table.insert( BS_ConfigCopyTable.GANGS.Leaderboards, {
                        Name = BRICKS_SERVER.Func.L( "gangNewLeaderboard" ), 
                        Type = data
                    } )

                    BRICKS_SERVER.Func.ConfigChange( "GANGS" )
                    self.RefreshPanel()
				else
					notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidType" ), 1, 3 )
				end
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_gang_leaderboards", PANEL, "bricks_server_scrollpanel" )