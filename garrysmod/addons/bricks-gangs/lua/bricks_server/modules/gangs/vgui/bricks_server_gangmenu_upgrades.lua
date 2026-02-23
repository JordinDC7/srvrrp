local PANEL = {}

function PANEL:Init()
    self:DockMargin( 10, 10, 10, 10 )
end

function PANEL:FillPanel( gangTable )
    local summaryBack = vgui.Create( "DPanel", self )
    summaryBack:Dock( TOP )
    summaryBack:DockMargin( 0, 0, 0, 8 )
    summaryBack:SetTall( 70 )
    summaryBack.Paint = function( self2, w, h )
        local totalUpgrades, purchasedUpgrades = 0, 0

        for upgradeKey, upgradeData in pairs( BRICKS_SERVER.CONFIG.GANGS.Upgrades or {} ) do
            local upgradeDevConfig = BRICKS_SERVER.DEVCONFIG.GangUpgrades[upgradeData.Type or upgradeKey] or {}
            local maxTiers = #(upgradeData.Tiers or {})

            if( maxTiers <= 0 ) then continue end

            totalUpgrades = totalUpgrades+maxTiers

            if( not upgradeDevConfig.Unlimited ) then
                purchasedUpgrades = purchasedUpgrades+math.min( (gangTable.Upgrades or {})[upgradeKey] or 0, maxTiers )
            elseif( BRICKS_SERVER.Func.GangGetUpgradeBought( LocalPlayer():GetGangID(), upgradeKey ) ) then
                purchasedUpgrades = purchasedUpgrades+1
            end
        end

        local completionDecimal = 0
        if( totalUpgrades > 0 ) then
            completionDecimal = math.Clamp( purchasedUpgrades/totalUpgrades, 0, 1 )
        end

        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        BRICKS_SERVER.Func.DrawGradientRoundedBox( 8, 0, 0, w, h, 1, Color( 39, 128, 100, 75 ), Color( 208, 145, 41, 75 ) )

        draw.SimpleText( "SRVRRP GANG UPGRADE TRACKER", "BRICKS_SERVER_Font20B", 18, 14, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
        draw.SimpleText( purchasedUpgrades .. "/" .. totalUpgrades .. " tiers unlocked", "BRICKS_SERVER_Font17", 18, 37, Color( 255, 255, 255, 175 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

        local progressX, progressY, progressW, progressH = w*0.48, 23, w*0.48, 22
        draw.RoundedBox( 6, progressX, progressY, progressW, progressH, BRICKS_SERVER.Func.GetTheme( 3 ) )
        draw.RoundedBox( 6, progressX, progressY, progressW*completionDecimal, progressH, Color( 89, 184, 113 ) )
        draw.SimpleText( math.Round( completionDecimal*100 ) .. "%", "BRICKS_SERVER_Font17", progressX+(progressW/2), progressY+(progressH/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local upgradesScroll = vgui.Create( "bricks_server_scrollpanel", self )
    upgradesScroll:Dock( FILL )

    function self.RefreshPanel()
        upgradesScroll:Clear()

        local sortedUpgrades = {}
        for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Upgrades or {} ) do
            local upgradeTable = v
            upgradeTable.Key = k
            upgradeTable.SortValue = 1+((not v.Tiers and 100) or 0)

            table.insert( sortedUpgrades, upgradeTable )
        end

        table.SortByMember( sortedUpgrades, "SortValue", true )

        for k, v in pairs( sortedUpgrades ) do
            local k = v.Key
            local upgradeDevConfig = BRICKS_SERVER.DEVCONFIG.GangUpgrades[v.Type or k] or {}
            local upgradeTiers = v.Tiers

            if( #(upgradeTiers or {}) <= 0 ) then continue end

            local upgrade
            if( not upgradeDevConfig.Unlimited ) then
                upgrade = 0
                if( gangTable and gangTable.Upgrades and gangTable.Upgrades[k] ) then
                    upgrade = gangTable.Upgrades[k] or 0
                end
            else
                upgrade = (BRICKS_SERVER.Func.GangGetUpgradeBought( LocalPlayer():GetGangID(), k ) and 1) or 0
            end

            local upgradeBack = vgui.Create( "DPanel", upgradesScroll )
            upgradeBack:Dock( TOP )
            upgradeBack:DockMargin( 0, 0, 0, 5 )
            upgradeBack:SetTall( 80 )
            upgradeBack.Paint = function( self2, w, h ) 
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            end

            local upgradeIcon = vgui.Create( "DPanel", upgradeBack )
            upgradeIcon:Dock( LEFT )
            upgradeIcon:DockMargin( 0, 0, 0, 0 )
            upgradeIcon:SetWide( upgradeBack:GetTall() )
            local iconMat = Material( "bricks_server/upgrades.png" )
            if( v.Icon ) then
                BRICKS_SERVER.Func.GetImage( v.Icon, function( mat ) 
                    iconMat = mat 
                end )
            end
            upgradeIcon.Paint = function( self2, w, h ) 
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( iconMat )
                local iconSize = 64
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end

            local upgradeInfo = vgui.Create( "DPanel", upgradeBack )
            upgradeInfo:Dock( LEFT )
            upgradeInfo:DockMargin( 0, 10, 0, 10 )
            upgradeInfo:SetWide( 125 )
            upgradeInfo.Paint = function( self2, w, h ) 
                draw.SimpleText( (v.Name or BRICKS_SERVER.Func.L( "gangNewUpgrade" )), "BRICKS_SERVER_Font17", 0, 5, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )
            end

            local upgradeDescription = vgui.Create( "DPanel", upgradeInfo )
            upgradeDescription:Dock( FILL )
            upgradeDescription:DockMargin( 0, 22, 0, 0 )
            upgradeDescription.Paint = function( self2, w, h )
                local description = BRICKS_SERVER.Func.TextWrap( (v.Description or BRICKS_SERVER.Func.L( "noDescription" )), "BRICKS_SERVER_Font17", w )

                BRICKS_SERVER.Func.DrawNonParsedText( description, "BRICKS_SERVER_Font17", 0, 0, BRICKS_SERVER.Func.GetTheme( 6 ), 0 )
            end

            local completed = (not upgradeDevConfig.Unlimited and upgrade >= #upgradeTiers) or (upgradeDevConfig.Unlimited and upgrade == 1)
            if( LocalPlayer():GangHasPermission( "PurchaseUpgrades" ) and not completed ) then
                local price = v.Price or (upgradeTiers[upgrade+1].Price or 0)

                local upgradeButton = vgui.Create( "DButton", upgradeBack )
                upgradeButton:Dock( RIGHT )
                upgradeButton:DockMargin( 0, 10, 10, 10 )
                upgradeButton:SetWide( upgradeBack:GetTall()-20 )
                upgradeButton:SetText( "" )
                local Alpha = 0
                local upgradeMat = Material( "bricks_server/gang_upgrade.png" )
                upgradeButton.Paint = function( self2, w, h )
                    if( self2:IsDown() ) then
                        Alpha = 0
                    elseif( self2:IsHovered() ) then
                        Alpha = math.Clamp( Alpha+5, 0, 75 )
                    else
                        Alpha = math.Clamp( Alpha-5, 0, 75 )
                    end

                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                    surface.SetAlphaMultiplier( Alpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                    surface.SetAlphaMultiplier( 1 )

                    surface.SetDrawColor( 255, 255, 255, 20+(235*(Alpha/75)) )
                    surface.SetMaterial( upgradeMat )
                    local iconSize = 32
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end
                upgradeButton.DoClick = function()
                    if( (upgradeTiers and not upgradeTiers[upgrade+1]) or (upgradeDevConfig.Unlimited and upgrade == 1) ) then return end

                    BRICKS_SERVER.Func.Query( BRICKS_SERVER.Func.L( "gangBuyUpgrade", DarkRP.formatMoney( price ) ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function() 
                        net.Start( "BRS.Net.GangUpgrade" )
                            net.WriteString( k )
                        net.SendToServer()
                    end )
                end
            elseif( completed ) then
                local completedBack = vgui.Create( "DPanel", upgradeBack )
                completedBack:Dock( RIGHT )
                completedBack:DockMargin( 0, 10, 10, 10 )
                completedBack:SetWide( upgradeBack:GetTall()-20 )
                local completedMat = Material( "bricks_server/gang_upgrade_bought.png" )
                completedBack.Paint = function( self2, w, h )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

                    surface.SetDrawColor( 255, 255, 255, 20 )
                    surface.SetMaterial( completedMat )
                    local iconSize = 32
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end 
            end

            if( not upgradeDevConfig.Unlimited and upgradeTiers ) then
                local upgradeProgress = vgui.Create( "DPanel", upgradeBack )
                upgradeProgress:Dock( BOTTOM )
                upgradeProgress:DockMargin( 5, 0, 5, 10 )
                upgradeProgress:SetTall( 32 )
                local themeColor = BRICKS_SERVER.Func.GetTheme( 0 )
                local overlayColor = Color( themeColor.r, themeColor.g, themeColor.b, 125 )
                upgradeProgress.Paint = function( self2, w, h ) 
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

                    local decimal = math.Clamp( upgrade/#upgradeTiers, 0, 1 )

                    draw.RoundedBox( 5, 0, 0, w*decimal, h, overlayColor )

                    draw.SimpleText( BRICKS_SERVER.Func.L( "gangUpgradeTier", math.min( upgrade, #upgradeTiers ), #upgradeTiers ), "BRICKS_SERVER_Font17", 10, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
                    
                    draw.SimpleText( math.floor( decimal*100 ) .. "%", "BRICKS_SERVER_Font17", w-10, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                end

                local upgradeReqInfoBack = vgui.Create( "DPanel", upgradeBack )
                upgradeReqInfoBack:Dock( FILL )
                upgradeReqInfoBack:DockMargin( 5, 10, 5, 5 )
                upgradeReqInfoBack.Paint = function( self2, w, h ) end
                upgradeReqInfoBack.AddInfo = function( text, dockRight, color )
                    surface.SetFont( "BRICKS_SERVER_Font17" )
                    local textX, textY = surface.GetTextSize( text )

                    local upgradeReqInfo = vgui.Create( "DPanel", upgradeReqInfoBack )
                    upgradeReqInfo:Dock( (dockRight and RIGHT) or LEFT )
                    upgradeReqInfo:DockMargin( (dockRight and 5) or 0, 0, (not dockRight and 5) or 0, 0 )
                    upgradeReqInfo:SetWide( textX+15 )
                    upgradeReqInfo.Paint = function( self2, w, h ) 
                        draw.RoundedBox( 5, 0, 0, w, h, (color or BRICKS_SERVER.Func.GetTheme( 4 )) )

                        draw.SimpleText( text, "BRICKS_SERVER_Font17", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                end

                local currentText = BRICKS_SERVER.Func.L( "gangCurrent", 0 )
                local currentReqInfo = v.Default or {}
                if( upgradeTiers[upgrade] and upgradeTiers[upgrade].ReqInfo ) then
                    currentReqInfo = upgradeTiers[upgrade].ReqInfo
                end

                if( upgradeDevConfig.Format ) then
                    currentText = BRICKS_SERVER.Func.L( "gangCurrent", upgradeDevConfig.Format( currentReqInfo ) )
                else
                    currentText = BRICKS_SERVER.Func.L( "gangCurrent", currentReqInfo[1] or 0 )
                end

                upgradeReqInfoBack.AddInfo( currentText, false )

                local nextTierTable = upgradeTiers[upgrade+1]
                if( nextTierTable ) then
                    local nextText = BRICKS_SERVER.Func.L( "gangNext", 0 )
                    local nextReqInfo = {}
                    if( nextTierTable and nextTierTable.ReqInfo and nextTierTable.ReqInfo ) then
                        nextReqInfo = nextTierTable.ReqInfo
                    end

                    if( upgradeDevConfig.Format ) then
                        nextText = BRICKS_SERVER.Func.L( "gangNext", upgradeDevConfig.Format( nextReqInfo ) )
                    else
                        nextText = BRICKS_SERVER.Func.L( "gangNext", nextReqInfo[1] or 0 )
                    end

                    upgradeReqInfoBack.AddInfo( nextText, true, Color(39, 174, 96) )

                    if( nextTierTable.Level ) then
                        upgradeReqInfoBack.AddInfo( BRICKS_SERVER.Func.L( "levelX", nextTierTable.Level ), true )
                    end

                    if( nextTierTable.Group ) then
                        local groupTable
                        for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                            if( v[1] == nextTierTable.Group ) then
                                groupTable = v
                            end
                        end

                        if( groupTable ) then
                            upgradeReqInfoBack.AddInfo( (groupTable[1] or BRICKS_SERVER.Func.L( "none" )), true, groupTable[3] )
                        end
                    end
                end
            else
                local upgradeReqInfoBack = vgui.Create( "DPanel", upgradeBack )
                upgradeReqInfoBack:Dock( TOP )
                upgradeReqInfoBack:SetTall( 23 )
                upgradeReqInfoBack:DockMargin( 5, 10, 5, 5 )
                upgradeReqInfoBack.Paint = function( self2, w, h ) end
                upgradeReqInfoBack.AddInfo = function( text, dockRight, color )
                    surface.SetFont( "BRICKS_SERVER_Font17" )
                    local textX, textY = surface.GetTextSize( text )

                    local upgradeReqInfo = vgui.Create( "DPanel", upgradeReqInfoBack )
                    upgradeReqInfo:Dock( (dockRight and RIGHT) or LEFT )
                    upgradeReqInfo:DockMargin( (dockRight and 5) or 0, 0, (not dockRight and 5) or 0, 0 )
                    upgradeReqInfo:SetWide( textX+15 )
                    upgradeReqInfo.Paint = function( self2, w, h ) 
                        draw.RoundedBox( 5, 0, 0, w, h, (color or BRICKS_SERVER.Func.GetTheme( 4 )) )

                        draw.SimpleText( text, "BRICKS_SERVER_Font17", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                end

                if( v.Level ) then
                    upgradeReqInfoBack.AddInfo( BRICKS_SERVER.Func.L( "levelX", v.Level ), true )
                end

                if( v.Group ) then
                    local groupTable
                    for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                        if( val[1] == v.Group ) then
                            groupTable = val
                        end
                    end

                    if( groupTable ) then
                        upgradeReqInfoBack.AddInfo( (groupTable[1] or BRICKS_SERVER.Func.L( "none" )), true, groupTable[3] )
                    end
                end
            end
        end
    end
    self.RefreshPanel()

    hook.Add( "BRS.Hooks.RefreshGang", self, function( self, valuesChanged )
        if( IsValid( self ) ) then
            if( valuesChanged and valuesChanged["Upgrades"] ) then
                self.RefreshPanel()
            end
        else
            hook.Remove( "BRS.Hooks.RefreshGang", self )
        end
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_upgrades", PANEL, "bricks_server_scrollpanel" )