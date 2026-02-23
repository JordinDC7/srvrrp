local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( configPanel )
    function self.RefreshPanel()
        self:Clear()

        local sortedUpgrades = {}
        for k, v in pairs( BS_ConfigCopyTable.GANGS.Upgrades or {} ) do
            local upgradeTable = v
            upgradeTable.Key = k
            upgradeTable.SortValue = 1+((not v.Tiers and 100) or 0)

            table.insert( sortedUpgrades, upgradeTable )
        end

        table.SortByMember( sortedUpgrades, "SortValue", true )

        for k, v in pairs( sortedUpgrades ) do
            local devConfigTable = BRICKS_SERVER.DEVCONFIG.GangUpgrades[v.Type or v.Key]

            local itemActions = {
                [1] = { BRICKS_SERVER.Func.L( "edit" ), function()
                    BRICKS_SERVER.Func.CreateUpgradeEditor( v, v.Key, function( upgradeTable ) 
                        BS_ConfigCopyTable.GANGS.Upgrades[v.Key] = upgradeTable
                        BRICKS_SERVER.Func.ConfigChange( "GANGS" )
                        self.RefreshPanel()
                    end, function() end )
                end }
            }

            if( devConfigTable ) then
                if( devConfigTable.Unlimited ) then
                    table.insert( itemActions, { BRICKS_SERVER.Func.L( "remove" ), function()
                        BS_ConfigCopyTable.GANGS.Upgrades[v.Key] = nil
                        BRICKS_SERVER.Func.ConfigChange( "GANGS" )
                        self.RefreshPanel()
                    end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed } )
                else
                    table.insert( itemActions, { BRICKS_SERVER.Func.L( "gangAddTier" ), function()
                        if( not BS_ConfigCopyTable.GANGS.Upgrades[v.Key].Tiers ) then
                            BS_ConfigCopyTable.GANGS.Upgrades[v.Key].Tiers = {}
                        end

                        table.insert( BS_ConfigCopyTable.GANGS.Upgrades[v.Key].Tiers, {
                            Price = 1500,
                            ReqInfo = {}
                        } )

                        BRICKS_SERVER.Func.ConfigChange( "GANGS" )
                        self.RefreshPanel()
                    end, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green } ) 
                end
            end


            local itemBackPanel = vgui.Create( "DPanel", self )
            itemBackPanel:Dock( TOP )
            itemBackPanel:DockMargin( 0, 0, 0, 5 )
            itemBackPanel:SetTall( 100 )
            itemBackPanel.Paint = function( self2, w, h )
                surface.SetAlphaMultiplier( 50/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                surface.SetAlphaMultiplier( 1 )
            end

            local itemBack = vgui.Create( "DPanel", itemBackPanel )
            itemBack:Dock( TOP )
            itemBack:SetTall( 100 )
            itemBack:DockPadding( 0, 0, 25, 0 )
            local iconMat
            BRICKS_SERVER.Func.GetImage( v.Icon or "", function( mat ) iconMat = mat end )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                if( iconMat ) then
                    surface.SetDrawColor( 255, 255, 255, 255 )
                    surface.SetMaterial( iconMat )
                    local size = 64
                    surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
                end

                draw.SimpleText( v.Name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( (v.Description or BRICKS_SERVER.Func.L( "noDescription" )), "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
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

            if( devConfigTable ) then
                if( not devConfigTable.Unlimited ) then
                    local tierCount = #v.Tiers
                    local tierTall = 40

                    itemBackPanel:SetTall( 100+(tierCount*(tierTall+5))+5 )

                    for key, val in pairs( v.Tiers ) do
                        local currentText = 0
                        local currentReqInfo = v.Default or {}
                        if( val.ReqInfo ) then
                            currentReqInfo = val.ReqInfo
                        end
        
                        if( devConfigTable.Format ) then
                            currentText = devConfigTable.Format( currentReqInfo )
                        else
                            currentText = currentReqInfo[1] or 0
                        end

                        local tierBack = vgui.Create( "DPanel", itemBackPanel )
                        tierBack:Dock( TOP )
                        tierBack:DockMargin( 5, 5, 5, 0 )
                        tierBack:SetTall( tierTall )
                        local width = 75
                        tierBack.Paint = function( self2, w, h )
                            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                            draw.RoundedBoxEx( 5, 0, 0, width, h, BRICKS_SERVER.Func.GetTheme( 2 ), true, false, true, false )

                            draw.SimpleText( BRICKS_SERVER.Func.L( "gangTierX", key ), "BRICKS_SERVER_Font23", width/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                            draw.SimpleText( currentText, "BRICKS_SERVER_Font20", width+10, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
                        end

                        surface.SetFont( "BRICKS_SERVER_Font20" )
                        local reqInfoX, reqInfoY = surface.GetTextSize( currentText )

                        local tierNoticeBack = vgui.Create( "DPanel", tierBack )
                        tierNoticeBack:SetSize( 0, 35 )
                        tierNoticeBack:SetPos( width+10+reqInfoX+10, (tierBack:GetTall()/2)-(tierNoticeBack:GetTall()/2) )
                        tierNoticeBack.Paint = function( self2, w, h ) end

                        local itemNotices = {}

                        table.insert( itemNotices, { DarkRP.formatMoney( val.Price or 0 ), BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen } )

                        if( val.Level ) then
                            table.insert( itemNotices, { BRICKS_SERVER.Func.L( "levelX", val.Level ) } )
                        end

                        if( val.Group ) then
                            local groupTable
                            for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                                if( v[1] == val.Group ) then
                                    groupTable = v
                                end
                            end

                            if( groupTable ) then
                                table.insert( itemNotices, { (groupTable[1] or BRICKS_SERVER.Func.L( "none" )), groupTable[3] } )
                            end
                        end

                        for k, v in pairs( itemNotices ) do
                            surface.SetFont( "BRICKS_SERVER_Font20" )
                            local textX, textY = surface.GetTextSize( v[1] )
                            local boxW, boxH = textX+10, textY

                            local itemInfoNotice = vgui.Create( "DPanel", tierNoticeBack )
                            itemInfoNotice:Dock( LEFT )
                            itemInfoNotice:DockMargin( 0, 0, 5, 0 )
                            itemInfoNotice:SetWide( boxW )
                            itemInfoNotice.Paint = function( self2, w, h ) 
                                draw.RoundedBox( 5, 0, 0, w, h, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                                draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            end

                            if( tierNoticeBack:GetWide() <= 5 ) then
                                tierNoticeBack:SetSize( tierNoticeBack:GetWide()+boxW, boxH )
                            else
                                tierNoticeBack:SetSize( tierNoticeBack:GetWide()+5+boxW, boxH )
                            end
                            tierNoticeBack:SetPos( width+10+reqInfoX+10, (tierBack:GetTall()/2)-(tierNoticeBack:GetTall()/2) )
                        end

                        local tierEdit = vgui.Create( "DButton", tierBack )
                        tierEdit:Dock( RIGHT )
                        tierEdit:SetWide( tierBack:GetTall() )
                        tierEdit:SetText( "" )
                        local Alpha = 0
                        local editMat = Material( "bricks_server/edit.png" )
                        tierEdit.Paint = function( self2, w, h ) 
                            if( not self2:IsDown() and self2:IsHovered() ) then
                                Alpha = math.Clamp( Alpha+5, 0, 100 )
                            else
                                Alpha = math.Clamp( Alpha-5, 0, 100 )
                            end
                        
                            draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), false, true, false, true )
                
                            surface.SetAlphaMultiplier( Alpha/255 )
                            draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, true, false, true )
                            surface.SetAlphaMultiplier( 1 )
                
                            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                
                            surface.SetDrawColor( 255, 255, 255, 20+(235*(Alpha/100)) )
                            surface.SetMaterial( editMat )
                            local iconSize = 24
                            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                        end
                        tierEdit.DoClick = function()
                            BRICKS_SERVER.Func.CreateUpgradeTierEditor( val, key, v, v.Key, function( tierTable ) 
                                BS_ConfigCopyTable.GANGS.Upgrades[v.Key].Tiers[key] = tierTable
                                BRICKS_SERVER.Func.ConfigChange( "GANGS" )
                                self.RefreshPanel()
                            end, function() end )
                        end

                        local tierRemove = vgui.Create( "DButton", tierBack )
                        tierRemove:Dock( RIGHT )
                        tierRemove:SetWide( tierBack:GetTall() )
                        tierRemove:SetText( "" )
                        local Alpha = 0
                        local deleteMat = Material( "bricks_server/delete.png" )
                        tierRemove.Paint = function( self2, w, h ) 
                            if( not self2:IsDown() and self2:IsHovered() ) then
                                Alpha = math.Clamp( Alpha+5, 0, 100 )
                            else
                                Alpha = math.Clamp( Alpha-5, 0, 100 )
                            end
                        
                            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                            surface.DrawRect( 0, 0, w, h )
                
                            surface.SetAlphaMultiplier( Alpha/255 )
                            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                            surface.DrawRect( 0, 0, w, h )
                            surface.SetAlphaMultiplier( 1 )
                
                            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                
                            surface.SetDrawColor( 255, 255, 255, 20+(235*(Alpha/100)) )
                            surface.SetMaterial( deleteMat )
                            local iconSize = 24
                            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                        end
                        tierRemove.DoClick = function()
                            table.remove( BS_ConfigCopyTable.GANGS.Upgrades[v.Key].Tiers, key )
                            BRICKS_SERVER.Func.ConfigChange( "GANGS" )
                            self.RefreshPanel()
                        end
                    end
                else
                    surface.SetFont( "BRICKS_SERVER_Font33" )
                    local nameX, nameY = surface.GetTextSize( v.Name )
        
                    local noticeBack = vgui.Create( "DPanel", itemBack )
                    noticeBack:SetSize( 0, 35 )
                    noticeBack:SetPos( itemBack:GetTall()+15+nameX+10, 5+(nameY/2)-(noticeBack:GetTall()/2) )
                    noticeBack.Paint = function( self2, w, h ) end
        
                    local itemNotices = {}
        
                    table.insert( itemNotices, { DarkRP.formatMoney( v.Price or 0 ), BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen } )
        
                    if( v.Level ) then
                        table.insert( itemNotices, { BRICKS_SERVER.Func.L( "levelX", v.Level ) } )
                    end
        
                    if( v.Group ) then
                        local groupTable
                        for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                            if( val[1] == v.Group ) then
                                groupTable = val
                            end
                        end
        
                        if( groupTable ) then
                            table.insert( itemNotices, { (groupTable[1] or BRICKS_SERVER.Func.L( "none" )), groupTable[3] } )
                        end
                    end
        
                    for k, v in pairs( itemNotices ) do
                        surface.SetFont( "BRICKS_SERVER_Font23" )
                        local textX, textY = surface.GetTextSize( v[1] )
                        local boxW, boxH = textX+10, textY
        
                        local itemInfoNotice = vgui.Create( "DPanel", noticeBack )
                        itemInfoNotice:Dock( LEFT )
                        itemInfoNotice:DockMargin( 0, 0, 5, 0 )
                        itemInfoNotice:SetWide( boxW )
                        itemInfoNotice.Paint = function( self2, w, h ) 
                            draw.RoundedBox( 5, 0, 0, w, h, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                            draw.SimpleText( v[1], "BRICKS_SERVER_Font23", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        end
        
                        if( noticeBack:GetWide() <= 5 ) then
                            noticeBack:SetSize( noticeBack:GetWide()+boxW, boxH )
                        else
                            noticeBack:SetSize( noticeBack:GetWide()+5+boxW, boxH )
                        end
                        noticeBack:SetPos( itemBack:GetTall()+15+nameX+10, 5+(nameY/2)-(noticeBack:GetTall()/2)+1 )
                    end
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
    
            draw.SimpleText( "Add Upgrade", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewButton.DoClick = function()
            local options = {}
			for k, v in pairs( BRICKS_SERVER.DEVCONFIG.GangUpgrades ) do
				if( not v.Unlimited and BS_ConfigCopyTable.GANGS.Upgrades[k] ) then continue end

				options[k] = v.Name
			end

			BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "gangNewUpgradeType" ), "", options, function( value, data ) 
				if( options[data] and BRICKS_SERVER.DEVCONFIG.GangUpgrades[data] ) then
                    local newUpgrade = {
                        Name = BRICKS_SERVER.Func.L( "gangNewUpgrade" ), 
                        Description = BRICKS_SERVER.Func.L( "gangNewUpgradeDesc" ),
                        Icon = "upgrade.png",
                    }

                    local key = data
                    if( BRICKS_SERVER.DEVCONFIG.GangUpgrades[data].Unlimited ) then
                        newUpgrade.Type = data
                        newUpgrade.ReqInfo = {}
                        newUpgrade.Price = 1500

                        local currentNum = 1
                        key = data .. "_1"

                        while BS_ConfigCopyTable.GANGS.Upgrades[key] do
                            currentNum = currentNum+1

                            key = data .. "_" .. currentNum
                        end
                    else
                        newUpgrade.Default = {}
                        newUpgrade.Tiers = {}
                    end
        
                    BS_ConfigCopyTable.GANGS.Upgrades[key] = newUpgrade
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

vgui.Register( "bricks_server_config_gang_upgrades", PANEL, "bricks_server_scrollpanel" )