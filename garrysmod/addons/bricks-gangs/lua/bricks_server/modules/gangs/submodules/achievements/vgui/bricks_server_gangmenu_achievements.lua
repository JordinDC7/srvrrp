local PANEL = {}

function PANEL:Init()
    self:DockMargin( 10, 10, 10, 10 )
end

function PANEL:FillPanel( gangTable )
    local categoryList = vgui.Create( "bricks_server_dcategorylist", self )
    categoryList:Dock( FILL )

    function self.RefreshPanel()
        categoryList:Clear()

        local categories = {}
        local slotTall, spacing = 80, 5

        for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Achievements or {} ) do
            local categoryName = v.Category or BRICKS_SERVER.Func.L( "other" )
            if( not categories[categoryName] ) then
                local categoryColor = BRICKS_SERVER.Func.GetTheme( 5 )

                categories[categoryName] = categoryList:Add( categoryName, categoryColor )
                categories[categoryName]:SetTall( 40+spacing )

                local spacer = vgui.Create( "DPanel", categories[categoryName] )
                spacer:Dock( BOTTOM )
                spacer:SetTall( spacing )
                spacer.Paint = function( self2, w, h ) end
            end

            categories[categoryName]:SetTall( categories[categoryName]:GetTall()+slotTall+spacing )

            local upgradeDevConfig = BRICKS_SERVER.DEVCONFIG.GangAchievements[v.Type] or {}

            local achievementBack = vgui.Create( "DPanel", categories[categoryName] )
            achievementBack:Dock( TOP )
            achievementBack:DockMargin( spacing, spacing, spacing, 0 )
            achievementBack:SetTall( slotTall )
            achievementBack.Paint = function( self2, w, h ) 
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            end

            local achievementIcon = vgui.Create( "DPanel", achievementBack )
            achievementIcon:Dock( LEFT )
            achievementIcon:DockMargin( 0, 0, 0, 0 )
            achievementIcon:SetWide( achievementBack:GetTall() )
            local iconMat = Material( "bricks_server/upgrades.png" )
            if( v.Icon ) then
                BRICKS_SERVER.Func.GetImage( v.Icon, function( mat ) 
                    iconMat = mat 
                end )
            end
            achievementIcon.Paint = function( self2, w, h ) 
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( iconMat )
                local iconSize = 64
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end

            local achievementInfo = vgui.Create( "DPanel", achievementBack )
            achievementInfo:Dock( LEFT )
            achievementInfo:DockMargin( 0, 10, 0, 10 )
            achievementInfo:SetWide( 125 )
            achievementInfo.Paint = function( self2, w, h ) 
                draw.SimpleText( (v.Name or BRICKS_SERVER.Func.L( "nil" )), "BRICKS_SERVER_Font17", 0, 5, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )
            end
            
            local achievementDescription = vgui.Create( "DPanel", achievementInfo )
            achievementDescription:Dock( FILL )
            achievementDescription:DockMargin( 0, 22, 0, 0 )
            achievementDescription.Paint = function( self2, w, h )
                local description = BRICKS_SERVER.Func.TextWrap( (v.Description or BRICKS_SERVER.Func.L( "noDescription" )), "BRICKS_SERVER_Font17", w )

                BRICKS_SERVER.Func.DrawNonParsedText( description, "BRICKS_SERVER_Font17", 0, 0, BRICKS_SERVER.Func.GetTheme( 6 ), 0 )
            end

            local completed = BRICKS_SERVER.Func.GangGetAchievementCompleted( LocalPlayer():GetGangID(), k )
            if( completed ) then
                local completedBack = vgui.Create( "DPanel", achievementBack )
                completedBack:Dock( RIGHT )
                completedBack:DockMargin( 0, 10, 10, 10 )
                completedBack:SetWide( achievementBack:GetTall()-20 )
                local completedMat = Material( "bricks_server/gang_upgrade_bought.png" )
                completedBack.Paint = function( self2, w, h )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

                    surface.SetDrawColor( 255, 255, 255, 20 )
                    surface.SetMaterial( completedMat )
                    local iconSize = 32
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end 
            end

            local achievementProgress = vgui.Create( "DPanel", achievementBack )
            achievementProgress:Dock( BOTTOM )
            achievementProgress:DockMargin( 5, 0, 5, 10 )
            achievementProgress:SetTall( 32 )
            local themeColor = BRICKS_SERVER.Func.GetTheme( 0 )
            local overlayColor = Color( themeColor.r, themeColor.g, themeColor.b, 125 )
            local goal = upgradeDevConfig.GetGoal( v.ReqInfo ) or 0
            achievementProgress.Paint = function( self2, w, h ) 
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

                if( not completed ) then
                    local progress = upgradeDevConfig.GetProgress( gangTable ) or 0
                    local decimal = math.Clamp( progress/goal, 0, 1 )

                    draw.RoundedBox( 5, 0, 0, w*decimal, h, overlayColor )

                    draw.SimpleText( BRICKS_SERVER.Func.L( "gangProgress", upgradeDevConfig.Format( progress, goal ) ), "BRICKS_SERVER_Font17", 10, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
                    
                    draw.SimpleText( math.floor( decimal*100 ) .. "%", "BRICKS_SERVER_Font17", w-10, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                else
                    draw.RoundedBox( 5, 0, 0, w, h, overlayColor )

                    draw.SimpleText( BRICKS_SERVER.Func.L( "completed" ), "BRICKS_SERVER_Font17", 10, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
                end
            end

            local achievementNoticeBack = vgui.Create( "DPanel", achievementBack )
            achievementNoticeBack:Dock( FILL )
            achievementNoticeBack:DockMargin( 5, 10, 5, 5 )
            achievementNoticeBack.Paint = function( self2, w, h ) end
            achievementNoticeBack.AddInfo = function( text, dockRight, color )
                surface.SetFont( "BRICKS_SERVER_Font17" )
                local textX, textY = surface.GetTextSize( text )

                local upgradeReqInfo = vgui.Create( "DPanel", achievementNoticeBack )
                upgradeReqInfo:Dock( (dockRight and RIGHT) or LEFT )
                upgradeReqInfo:DockMargin( (dockRight and 5) or 0, 0, (not dockRight and 5) or 0, 0 )
                upgradeReqInfo:SetWide( textX+15 )
                upgradeReqInfo.Paint = function( self2, w, h ) 
                    draw.RoundedBox( 5, 0, 0, w, h, (color or BRICKS_SERVER.Func.GetTheme( 4 )) )

                    draw.SimpleText( text, "BRICKS_SERVER_Font17", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
            end

            for k, v in pairs( v.Rewards or {} ) do
                local devConfigReward = BRICKS_SERVER.DEVCONFIG.GangRewards[k]

                if( not devConfigReward ) then continue end

                achievementNoticeBack.AddInfo( devConfigReward.FormatDescription( v ), true, devConfigReward.Color )
            end
        end
    end
    self.RefreshPanel()

    hook.Add( "BRS.Hooks.RefreshGang", self, function( self, valuesChanged )
        if( IsValid( self ) ) then
            if( valuesChanged and valuesChanged["Achievements"] ) then
                self.RefreshPanel()
            end
        else
            hook.Remove( "BRS.Hooks.RefreshGang", self )
        end
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_achievements", PANEL, "DPanel" )