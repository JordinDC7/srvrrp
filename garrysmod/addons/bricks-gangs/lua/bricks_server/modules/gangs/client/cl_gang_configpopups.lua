function BRICKS_SERVER.Func.CreateConfigPopup( onSave, onCancel, lastActionFunc )
	BRS_CONFIG_POPUP = vgui.Create( "DFrame" )
	BRS_CONFIG_POPUP:SetSize( ScrW(), ScrH() )
	BRS_CONFIG_POPUP:Center()
	BRS_CONFIG_POPUP:SetTitle( "" )
	BRS_CONFIG_POPUP:ShowCloseButton( false )
	BRS_CONFIG_POPUP:SetDraggable( false )
	BRS_CONFIG_POPUP:MakePopup()
	BRS_CONFIG_POPUP:SetAlpha( 0 )
	BRS_CONFIG_POPUP:AlphaTo( 255, 0.1, 0 )
	BRS_CONFIG_POPUP.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backgroundPanel = vgui.Create( "DPanel", BRS_CONFIG_POPUP )
	backgroundPanel.Paint = function( self2, w, h ) 
		local x, y = self2:LocalToScreen( 0, 0 )

		BRICKS_SERVER.BSHADOWS.BeginShadow()
		draw.RoundedBox( 5, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )			
		BRICKS_SERVER.BSHADOWS.EndShadow( 1, 2, 2, 255, 0, 0, false )
	end

	local backRightPanel = vgui.Create( "DPanel", backgroundPanel )
	backRightPanel:Dock( RIGHT )
	backRightPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
	end

	local backLeftPanel = vgui.Create( "DPanel", backgroundPanel )
	backLeftPanel:Dock( LEFT )
	backLeftPanel.Paint = function( self2, w, h ) 
		if( self2.iconMat ) then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( self2.iconMat )
			local iconSize = 64
			surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
		end
	end

	backgroundPanel.OnSizeChanged = function( self2, w, h )
		backRightPanel:SetWide( w/2 )
		backLeftPanel:SetWide( w/2 )
	end
	
	backgroundPanel:SetWide( 800 )
	backgroundPanel:Center()

	function backRightPanel.FillOptions( configTable, actions, extraActionsCount )
		backRightPanel:Clear()

		function backRightPanel.AddAction( v, k )
			local actionButton
			if( v[3] ) then
				actionButton = vgui.Create( "DButton", backRightPanel )
				actionButton:SetText( "" )
			else
				actionButton = vgui.Create( "DPanel", backRightPanel )
			end
			actionButton:Dock( TOP )
			local margin = (v[2] and 10) or 15
			actionButton:DockMargin( margin, 10, margin, 0 )
			actionButton:SetTall( 40 )
			local changeAlpha = 0
			actionButton.Paint = function( self2, w, h )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
				
				if( v[3] ) then
					if( self2:IsHovered() and not self2:IsDown() ) then
						changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
					else
						changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
					end

					surface.SetAlphaMultiplier( changeAlpha/255 )
						draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
					surface.SetAlphaMultiplier( 1 )

					BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
				end

				if( v[2] ) then
					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
					surface.SetMaterial( v[2] )
					local iconSize = 24
					surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
				end

				if( v[4] and configTable[v[4]] and not v[5] ) then
					draw.SimpleText( v[1] .. " - " .. string.sub( configTable[v[4]], 1, 15 ) .. ((string.len( configTable[v[4]] ) > 15 and "...") or ""), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( v[5] and isfunction( v[5] ) ) then
					draw.SimpleText( v[1] .. " - " .. v[5](), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			if( v[3] ) then
				actionButton.DoClick = v[3]
			end

			if( (k or 0) == #actions and backRightPanel.lastActionFunc ) then
				local extraToAdd = backRightPanel.lastActionFunc( extraActionsCount )
				extraActionsCount = (extraActionsCount or 0)+(extraToAdd or 0)
			end
		end

		for k, v in ipairs( actions or {} ) do
			backRightPanel.AddAction( v, k )
		end

		local buttonPanel = vgui.Create( "DPanel", backRightPanel )
		buttonPanel:Dock( BOTTOM )
		buttonPanel:DockMargin( 10, 10, 10, 10 )
		buttonPanel:SetTall( 40 )
		buttonPanel.Paint = function( self2, w, h ) end

		local leftButton = vgui.Create( "DButton", buttonPanel )
		leftButton:Dock( LEFT )
		leftButton:SetText( "" )
		leftButton:DockMargin( 0, 0, 0, 0 )
		local changeAlpha = 0
		leftButton.Paint = function( self2, w, h )
			if( self2:IsHovered() and not self2:IsDown() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
			else
				changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
			end
			
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
	
			surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )
			surface.SetAlphaMultiplier( 1 )

			BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )
	
			draw.SimpleText( BRICKS_SERVER.Func.L( "save" ), "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		leftButton.DoClick = function()
			onSave( configTable )

			BRS_CONFIG_POPUP:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BRS_CONFIG_POPUP ) ) then
					BRS_CONFIG_POPUP:Remove()
				end
			end )
		end

		local rightButton = vgui.Create( "DButton", buttonPanel )
		rightButton:Dock( RIGHT )
		rightButton:SetText( "" )
		rightButton:DockMargin( 0, 0, 0, 0 )
		local changeAlpha = 0
		rightButton.Paint = function( self2, w, h )
			if( self2:IsHovered() and not self2:IsDown() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
			else
				changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
			end
			
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
	
			surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
			surface.SetAlphaMultiplier( 1 )

			BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
	
			draw.SimpleText( BRICKS_SERVER.Func.L( "cancel" ), "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		rightButton.DoClick = function()
			onCancel()

			BRS_CONFIG_POPUP:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BRS_CONFIG_POPUP ) ) then
					BRS_CONFIG_POPUP:Remove()
				end
			end )
		end

		backgroundPanel:SetTall( math.max( ScrH()*0.45, buttonPanel:GetTall()+(2*10)+((#actions+(extraActionsCount or 0))*50) ) )
		backgroundPanel:Center()

		leftButton:SetWide( (backRightPanel:GetWide()-30)/2 )
		rightButton:SetWide( (backRightPanel:GetWide()-30)/2 )
	end

	function backLeftPanel.Refresh()
		backLeftPanel:Clear()

		local topMargin, bottomMargin = backgroundPanel:GetTall()*0.075, 145

		local itemInfoDisplay = vgui.Create( "DPanel", backLeftPanel )
		itemInfoDisplay:SetSize( backLeftPanel:GetWide(), backgroundPanel:GetTall()-topMargin-bottomMargin )
		itemInfoDisplay:SetPos( backLeftPanel:GetWide()-itemInfoDisplay:GetWide(), topMargin )
		itemInfoDisplay.Paint = function( self2, w, h ) 
			draw.SimpleText( (backLeftPanel.Name or BRICKS_SERVER.Func.L( "nil" )), "BRICKS_SERVER_Font25", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
		end

		local itemInfoNoticeBack = vgui.Create( "DPanel", itemInfoDisplay )
		itemInfoNoticeBack:SetSize( 0, 35 )
		itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
		itemInfoNoticeBack.Paint = function( self2, w, h ) end

		for k, v in pairs( backLeftPanel.Notices or {} ) do
			surface.SetFont( "BRICKS_SERVER_Font20" )
			local textX, textY = surface.GetTextSize( v[1] )
			local boxW, boxH = textX+10, textY

			local itemInfoNotice = vgui.Create( "DPanel", itemInfoNoticeBack )
			itemInfoNotice:Dock( LEFT )
			itemInfoNotice:DockMargin( 0, 0, 5, 0 )
			itemInfoNotice:SetWide( boxW )
			itemInfoNotice.Paint = function( self2, w, h ) 
				draw.RoundedBox( 5, 0, 0, w, h, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
				draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end

			if( itemInfoNoticeBack:GetWide() <= 5 ) then
				itemInfoNoticeBack:SetSize( itemInfoNoticeBack:GetWide()+boxW, boxH )
			else
				itemInfoNoticeBack:SetSize( itemInfoNoticeBack:GetWide()+5+boxW, boxH )
			end
			itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
		end
	end

	return backgroundPanel, backRightPanel, backLeftPanel
end

function BRICKS_SERVER.Func.CreateUpgradeEditor( oldUpgradeTable, upgradeKey, onSave, onCancel )
	local upgradeTable = table.Copy( oldUpgradeTable )

	local backgroundPanel, backRightPanel, backLeftPanel = BRICKS_SERVER.Func.CreateConfigPopup( onSave, onCancel )

	backRightPanel.lastActionFunc = function()
		local reqInfoTable = upgradeTable.Default or {}
		if( (BRICKS_SERVER.DEVCONFIG.GangUpgrades[upgradeTable.Type or upgradeKey] or {}).Unlimited ) then
			reqInfoTable = upgradeTable.ReqInfo or {}
		end

		for k, v in pairs( BRICKS_SERVER.DEVCONFIG.GangUpgrades[upgradeTable.Type or upgradeKey].ReqInfo ) do
			local actionButton = vgui.Create( "DButton", backRightPanel )
			actionButton:SetText( "" )
			actionButton:Dock( TOP )
			actionButton:DockMargin( 15, 10, 15, 0 )
			actionButton:SetTall( 40 )
			local changeAlpha = 0
			actionButton.Paint = function( self2, w, h )
				if( self2:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				elseif( self2:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
				end
				
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
		
				surface.SetAlphaMultiplier( changeAlpha/255 )
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
				surface.SetAlphaMultiplier( 1 )

				if( v[2] == "bool" ) then
					draw.SimpleText( v[1] .. " - " .. ((reqInfoTable[k] and "TRUE") or "FALSE"), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( reqInfoTable[k] ) then
					draw.SimpleText( v[1] .. " - " .. reqInfoTable[k], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			actionButton.DoClick = function()
				if( v[2] == "string" or v[2] == "integer" ) then 
					BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "valueQuery", v[1] ), (reqInfoTable[k] or 0), function( text ) 
						reqInfoTable[k] = text
						backLeftPanel.RefreshInfo()
					end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), (v[2] == "integer") )
				elseif( v[2] == "bool" ) then 
					reqInfoTable[k] = not reqInfoTable[k]
					backLeftPanel.RefreshInfo()
				elseif( v[2] == "table" and v[3] and BRICKS_SERVER.Func.GetList( v[3] ) ) then 
					BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "dataValueQuery" ), (reqInfoTable[k] or ""), BRICKS_SERVER.Func.GetList( v[3] ), function( value, data ) 
						if( BRICKS_SERVER.Func.GetList( v[3] )[data] ) then
							reqInfoTable[k] = data

							if( v[4] ) then
								local newupgradeTable = v[4]( upgradeTable ) 
								if( newupgradeTable ) then
									upgradeTable = newupgradeTable
								end
							end
							backLeftPanel.RefreshInfo()
						else
							notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidChoice" ), 1, 3 )
						end
					end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
				end
			end
		end
	end

	local devConfigTable = BRICKS_SERVER.DEVCONFIG.GangUpgrades[upgradeTable.Type or upgradeKey]
	function backLeftPanel.RefreshInfo()
		backLeftPanel:Clear()

		devConfigTable = BRICKS_SERVER.DEVCONFIG.GangUpgrades[upgradeTable.Type or upgradeKey]
        
        if( upgradeTable.Icon ) then
            BRICKS_SERVER.Func.GetImage( upgradeTable.Icon, function( mat ) 
                backLeftPanel.iconMat = mat 
            end )
        end

		backLeftPanel.Name = upgradeTable.Name or BRICKS_SERVER.Func.L( "gangNewUpgrade" )

		backLeftPanel.Notices = {}

		if( devConfigTable.Unlimited ) then
			table.insert( backLeftPanel.Notices, { DarkRP.formatMoney( upgradeTable.Price ), BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen } )
		end

		if( upgradeTable.Level ) then
			table.insert( backLeftPanel.Notices, { BRICKS_SERVER.Func.L( "levelX", upgradeTable.Level ) } )
		end

		if( upgradeTable.Group ) then
			local groupTable
			for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
				if( v[1] == upgradeTable.Group ) then
					groupTable = v
				end
			end

			if( groupTable ) then
				table.insert( backLeftPanel.Notices, { (groupTable[1] or BRICKS_SERVER.Func.L( "none" )), groupTable[3] } )
			end
		end

		backLeftPanel.Refresh()
    end

	local actions = {
		[1] = { BRICKS_SERVER.Func.L( "name" ), Material( "materials/bricks_server/name.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newNameQuery" ), upgradeTable.Name, function( text ) 
				upgradeTable.Name = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
		end, "Name" },
		[2] = { BRICKS_SERVER.Func.L( "description" ), Material( "materials/bricks_server/info.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newDescriptionQuery" ), upgradeTable.Description, function( text ) 
				upgradeTable.Description = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
		end, "Description" },
		[3] = { BRICKS_SERVER.Func.L( "icon" ), Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.MaterialRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newIconQuery" ), (upgradeTable.Icon or ""), function( icon ) 
				upgradeTable.Icon = icon
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ) )
		end, "Icon" }
	}

    if( devConfigTable.Unlimited ) then
        table.insert( actions, { BRICKS_SERVER.Func.L( "group" ), Material( "materials/bricks_server/group.png" ), function()
			local options = {}
			options["None"] = BRICKS_SERVER.Func.L( "none" )
			for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
				options[k] = v[1]
			end
			BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "groupRequirementQuery" ), (upgradeTable.Group or ""), options, function( value, data ) 
				if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups[data] ) then
					upgradeTable.Group = value
					backLeftPanel.RefreshInfo()
				elseif( data == "None" ) then
					upgradeTable.Group = nil
					backLeftPanel.RefreshInfo()
				else
					notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidGroup" ), 1, 3 )
				end
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
        end, "Group" } )
        
		table.insert( actions, { BRICKS_SERVER.Func.L( "level" ), Material( "materials/bricks_server/level.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "levelRequirementQuery" ), upgradeTable.Level, function( number ) 
				if( number > 0 ) then
					upgradeTable.Level = number
				else
					upgradeTable.Level = nil
				end
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
		end, "Level" } )

		table.insert( actions, { BRICKS_SERVER.Func.L( "price" ), Material( "materials/bricks_server/currency.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newPriceQuery" ), upgradeTable.Price, function( text ) 
				upgradeTable.Price = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
		end, "Price" } )
		
		table.insert( actions, { BRICKS_SERVER.Func.L( "type" ), Material( "materials/bricks_server/amount.png" ), function()
			local options = {}
			for k, v in pairs( BRICKS_SERVER.DEVCONFIG.GangUpgrades ) do
				if( not v.Unlimited ) then continue end

				options[k] = v.Name
			end

			BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newTypeQuery" ), (upgradeTable.Type or ""), options, function( value, data ) 
				if( options[data] ) then
					upgradeTable.Type = data
					backLeftPanel.RefreshInfo()
					backRightPanel.FillOptions( upgradeTable, actions )
				else
					notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidType" ), 1, 3 )
				end
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
        end, "Type" } )
	end
	
	backRightPanel.FillOptions( upgradeTable, actions )
	backLeftPanel.RefreshInfo()
end

function BRICKS_SERVER.Func.CreateUpgradeTierEditor( oldTierTable, tierKey, upgradeTable, upgradeKey, onSave, onCancel )
	local tierTable = table.Copy( oldTierTable )
	
	local backgroundPanel, backRightPanel, backLeftPanel = BRICKS_SERVER.Func.CreateConfigPopup( onSave, onCancel )

	local reqInfoIcon = Material( "bricks_server/more_24.png" )
	backRightPanel.lastActionFunc = function()
		for k, v in pairs( BRICKS_SERVER.DEVCONFIG.GangUpgrades[upgradeKey or ""].ReqInfo or {} ) do
			local actionButton = vgui.Create( "DButton", backRightPanel )
			actionButton:SetText( "" )
			actionButton:Dock( TOP )
			actionButton:DockMargin( 10, 10, 10, 0 )
			actionButton:SetTall( 40 )
			local changeAlpha = 0
			actionButton.Paint = function( self2, w, h )
				if( self2:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				elseif( self2:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
				end
				
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
		
				surface.SetAlphaMultiplier( changeAlpha/255 )
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
				surface.SetAlphaMultiplier( 1 )

				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
				surface.SetMaterial( reqInfoIcon )
				local iconSize = 24
				surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )

				if( v[2] == "bool" ) then
					draw.SimpleText( v[1] .. " - " .. (((tierTable.ReqInfo or {})[k] and BRICKS_SERVER.Func.L( "true" )) or BRICKS_SERVER.Func.L( "false" )), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( (tierTable.ReqInfo or {})[k] ) then
					draw.SimpleText( v[1] .. " - " .. (tierTable.ReqInfo or {})[k], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			actionButton.DoClick = function()
				if( v[2] == "string" or v[2] == "integer" ) then 
					BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "valueQuery", v[1] ), ((tierTable.ReqInfo or {})[k] or 0), function( text ) 
						tierTable.ReqInfo = tierTable.ReqInfo or {}
						tierTable.ReqInfo[k] = text
						backLeftPanel.RefreshInfo()
					end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), (v[2] == "integer") )
				elseif( v[2] == "bool" ) then 
					tierTable.ReqInfo = tierTable.ReqInfo or {}
					tierTable.ReqInfo[k] = not tierTable.ReqInfo[k]
					backLeftPanel.RefreshInfo()
				elseif( v[2] == "table" and v[3] and BRICKS_SERVER.Func.GetList( v[3] ) ) then 
					BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "dataValueQuery" ), ((tierTable.ReqInfo or {})[k] or ""), BRICKS_SERVER.Func.GetList( v[3] ), function( value, data ) 
						if( BRICKS_SERVER.Func.GetList( v[3] )[data] ) then
							tierTable.ReqInfo[k] = data

							if( v[4] ) then
								local newtierTable = v[4]( tierTable ) 
								if( newtierTable ) then
									tierTable = newtierTable
								end
							end
							backLeftPanel.RefreshInfo()
						else
							notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidChoice" ), 1, 3 )
						end
					end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
				end
			end
		end
	end

	if( upgradeTable.Icon ) then
		BRICKS_SERVER.Func.GetImage( upgradeTable.Icon, function( mat ) 
			backLeftPanel.iconMat = mat 
		end )
	end

	function backLeftPanel.RefreshInfo()
		backLeftPanel.Name = BRICKS_SERVER.Func.L( "gangUpgradeTierEdit", (upgradeTable.Name or BRICKS_SERVER.Func.L( "gangNewUpgrade" )), tierKey )

		backLeftPanel.Notices = {}

		table.insert( backLeftPanel.Notices, { DarkRP.formatMoney( tierTable.Price or 0 ), BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen } )

		if( tierTable.Level ) then
			table.insert( backLeftPanel.Notices, { BRICKS_SERVER.Func.L( "levelX", tierTable.Level ) } )
		end

		if( tierTable.Group ) then
			local groupTable
			for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
				if( v[1] == tierTable.Group ) then
					groupTable = v
				end
			end

			if( groupTable ) then
				table.insert( backLeftPanel.Notices, { (groupTable[1] or BRICKS_SERVER.Func.L( "none" )), groupTable[3] } )
			end
		end

		backLeftPanel.Refresh()
    end
    
    local devConfigTable = BRICKS_SERVER.DEVCONFIG.GangUpgrades[upgradeKey or ""]

	local actions = {
		[1] = { BRICKS_SERVER.Func.L( "price" ), Material( "materials/bricks_server/currency.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newPriceQuery" ), tierTable.Price, function( text ) 
				tierTable.Price = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
		end, "Price" },
		[2] = { BRICKS_SERVER.Func.L( "group" ), Material( "materials/bricks_server/group.png" ), function()
			local options = {}
			options["None"] = BRICKS_SERVER.Func.L( "none" )
			for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
				options[k] = v[1]
			end
			BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "groupRequirementQuery" ), (tierTable.Group or ""), options, function( value, data ) 
				if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups[data] ) then
					tierTable.Group = value
					backLeftPanel.RefreshInfo()
				elseif( data == "None" ) then
					tierTable.Group = nil
					backLeftPanel.RefreshInfo()
				else
					notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidGroup" ), 1, 3 )
				end
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
        end, "Group" },

	}

	table.insert( actions, { BRICKS_SERVER.Func.L( "level" ), Material( "materials/bricks_server/level.png" ), function()
		BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "levelRequirementQuery" ), tierTable.Level, function( text ) 
			tierTable.Level = text
			backLeftPanel.RefreshInfo()
		end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
	end, "Level" } )
	
	backRightPanel.FillOptions( tierTable, actions )
	backLeftPanel.RefreshInfo()
end

function BRICKS_SERVER.Func.CreateAchievementEditor( oldAchievementTable, onSave, onCancel )
	local achievementTable = table.Copy( oldAchievementTable )

	local backgroundPanel, backRightPanel, backLeftPanel = BRICKS_SERVER.Func.CreateConfigPopup( onSave, onCancel )

	local function GetNextQuery( currentQuery, k, v )
		local reqInfo = BRICKS_SERVER.DEVCONFIG.GangRewards[k].ReqInfo

		currentQuery = currentQuery+1

		if( currentQuery > #reqInfo ) then return end

		local reqInfoEntry = reqInfo[currentQuery]

		if( reqInfoEntry[2] == "string" or reqInfoEntry[2] == "integer" ) then 
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "valueQuery", reqInfoEntry[1] ), ((achievementTable.Rewards[k] or {})[currentQuery] or 0), function( text ) 
				achievementTable.Rewards[k] = achievementTable.Rewards[k] or {}
				achievementTable.Rewards[k][currentQuery] = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), (reqInfoEntry[2] == "integer") )
		elseif( reqInfoEntry[2] == "bool" ) then 
			achievementTable.Rewards[k] = achievementTable.Rewards[k] or {}
			achievementTable.Rewards[k][currentQuery] = not achievementTable.Rewards[k][currentQuery]
			backLeftPanel.RefreshInfo()
		elseif( reqInfoEntry[2] == "table" and reqInfoEntry[3] and BRICKS_SERVER.Func.GetList( reqInfoEntry[3] ) ) then 
			BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "dataValueQuery" ), ((achievementTable.Rewards[k] or {})[currentQuery] or ""), BRICKS_SERVER.Func.GetList( reqInfoEntry[3] ), function( value, data ) 
				if( BRICKS_SERVER.Func.GetList( reqInfoEntry[3] )[data] ) then
					achievementTable.Rewards[k][currentQuery] = data

					if( reqInfoEntry[4] ) then
						local newupgradeTable = reqInfoEntry[4]( upgradeTable ) 
						if( newupgradeTable ) then
							upgradeTable = newupgradeTable
						end
					end
					backLeftPanel.RefreshInfo()
				else
					notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidChoice" ), 1, 3 )
				end
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
		end

		GetNextQuery( currentQuery, k, v )
	end

	backRightPanel.lastActionFunc = function( extraActionsCount )
		for k, v in pairs( BRICKS_SERVER.DEVCONFIG.GangAchievements[(achievementTable.Type or "")].ReqInfo or {} ) do
			local actionButton = vgui.Create( "DButton", backRightPanel )
			actionButton:SetText( "" )
			actionButton:Dock( TOP )
			actionButton:DockMargin( 15, 10, 15, 0 )
			actionButton:SetTall( 40 )
			local changeAlpha = 0
			actionButton.Paint = function( self2, w, h )
				if( self2:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				elseif( self2:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
				end
				
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
		
				surface.SetAlphaMultiplier( changeAlpha/255 )
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
				surface.SetAlphaMultiplier( 1 )

				if( v[2] == "bool" ) then
					draw.SimpleText( v[1] .. " - " .. (((achievementTable.ReqInfo or {})[k] and "TRUE") or "FALSE"), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( (achievementTable.ReqInfo or {})[k] ) then
					draw.SimpleText( v[1] .. " - " .. (achievementTable.ReqInfo or {})[k], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			actionButton.DoClick = function()
				if( v[2] == "string" or v[2] == "integer" ) then 
					BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "valueQuery", v[1] ), ((achievementTable.ReqInfo or {})[k] or 0), function( text ) 
						achievementTable.ReqInfo = achievementTable.ReqInfo or {}
						achievementTable.ReqInfo[k] = text
						backLeftPanel.RefreshInfo()
					end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), (v[2] == "integer") )
				elseif( v[2] == "bool" ) then 
					achievementTable.ReqInfo = achievementTable.ReqInfo or {}
					achievementTable.ReqInfo[k] = not achievementTable.ReqInfo[k]
					backLeftPanel.RefreshInfo()
				elseif( v[2] == "table" and v[3] and BRICKS_SERVER.Func.GetList( v[3] ) ) then 
					BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "dataValueQuery" ), ((achievementTable.ReqInfo or {})[k] or ""), BRICKS_SERVER.Func.GetList( v[3] ), function( value, data ) 
						if( BRICKS_SERVER.Func.GetList( v[3] )[data] ) then
							achievementTable.ReqInfo[k] = data

							if( v[4] ) then
								local newachievementTable = v[4]( achievementTable ) 
								if( newachievementTable ) then
									achievementTable = newachievementTable
								end
							end
							backLeftPanel.RefreshInfo()
						else
							notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidChoice" ), 1, 3 )
						end
					end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
				end
			end
		end

		backRightPanel.AddAction( { "Rewards", Material( "materials/bricks_server/more_24.png" ), false } )
	
		achievementTable.Rewards = achievementTable.Rewards or {}
		for key, val in pairs( BRICKS_SERVER.DEVCONFIG.GangRewards ) do
			backRightPanel.AddAction( { val.Name, false, function()
				GetNextQuery( 0, key, val )
			end, false, function() return val.FormatDescription( achievementTable.Rewards[key] or {} ) end } )
		end

		return table.Count( BRICKS_SERVER.DEVCONFIG.GangAchievements[(achievementTable.Type or "")].ReqInfo or {} )+1
	end

	local devConfigTable = BRICKS_SERVER.DEVCONFIG.GangAchievements[achievementTable.Type or ""]
	function backLeftPanel.RefreshInfo()
		backLeftPanel:Clear()

		devConfigTable = BRICKS_SERVER.DEVCONFIG.GangAchievements[achievementTable.Type or ""]
        
        if( achievementTable.Icon ) then
            BRICKS_SERVER.Func.GetImage( achievementTable.Icon, function( mat ) 
                backLeftPanel.iconMat = mat 
            end )
        end

		backLeftPanel.Name = achievementTable.Name or BRICKS_SERVER.Func.L( "gangNewAchievement" )

		backLeftPanel.Refresh()
    end

	local actions = {
		[1] = { BRICKS_SERVER.Func.L( "name" ), Material( "materials/bricks_server/name.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newNameQuery" ), achievementTable.Name, function( text ) 
				achievementTable.Name = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
		end, "Name" },
		[2] = { BRICKS_SERVER.Func.L( "description" ), Material( "materials/bricks_server/info.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newDescriptionQuery" ), achievementTable.Description, function( text ) 
				achievementTable.Description = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
		end, "Description" },
		[3] = { BRICKS_SERVER.Func.L( "icon" ), Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.MaterialRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newIconQuery" ), (achievementTable.Icon or ""), function( icon ) 
				achievementTable.Icon = icon
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ) )
		end, "Icon" },
		[4] = { BRICKS_SERVER.Func.L( "category" ), Material( "materials/bricks_server/more_24.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newCategoryQuery" ), achievementTable.Category, function( text ) 
				achievementTable.Category = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
		end, "Category" },
	}

	table.insert( actions, { BRICKS_SERVER.Func.L( "type" ), Material( "materials/bricks_server/amount.png" ), function()
		local options = {}
		for k, v in pairs( BRICKS_SERVER.DEVCONFIG.GangAchievements ) do
			options[k] = v.Name
		end

		BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newTypeQuery" ), (achievementTable.Type or ""), options, function( value, data ) 
			if( options[data] ) then
				achievementTable.Type = data
				backLeftPanel.RefreshInfo()
				backRightPanel.FillOptions( achievementTable, actions, table.Count( BRICKS_SERVER.DEVCONFIG.GangRewards ) )
			else
				notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidType" ), 1, 3 )
			end
		end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
	end, "Type" } )
	
	backRightPanel.FillOptions( achievementTable, actions, table.Count( BRICKS_SERVER.DEVCONFIG.GangRewards ) )
	backLeftPanel.RefreshInfo()
end

function BRICKS_SERVER.Func.CreateTerritoryEditor( oldTerritoryTable, onSave, onCancel )
	local territoryTable = table.Copy( oldTerritoryTable )

	local backgroundPanel, backRightPanel, backLeftPanel = BRICKS_SERVER.Func.CreateConfigPopup( onSave, onCancel )

	function backLeftPanel.RefreshInfo()
		backLeftPanel:Clear()

		backLeftPanel.Name = territoryTable.Name or BRICKS_SERVER.Func.L( "gangNewTerritory" )

		backLeftPanel.Refresh()
    end

	local actions = {
		[1] = { BRICKS_SERVER.Func.L( "name" ), Material( "materials/bricks_server/name.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newNameQuery" ), territoryTable.Name, function( text ) 
				territoryTable.Name = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
		end, "Name" },
		[2] = { BRICKS_SERVER.Func.L( "color" ), Material( "materials/bricks_server/color.png" ), function()
			BRICKS_SERVER.Func.ColorRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newColorQuery" ), territoryTable.Color, function( color ) 
				territoryTable.Color = color
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
		end },
		[3] = { BRICKS_SERVER.Func.L( "gangRewardTime" ), Material( "materials/bricks_server/chance.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "gangRewardTimeQuery" ), territoryTable.RewardTime, function( text ) 
				territoryTable.RewardTime = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
		end, "RewardTime" },
		[4] = { BRICKS_SERVER.Func.L( "gangRewards" ), Material( "materials/bricks_server/more_24.png" ), false }
	}

	local function GetNextQuery( currentQuery, k, v )
		local reqInfo = BRICKS_SERVER.DEVCONFIG.GangRewards[k].ReqInfo

		currentQuery = currentQuery+1

		if( currentQuery > #reqInfo ) then return end

		local reqInfoEntry = reqInfo[currentQuery]

		if( reqInfoEntry[2] == "string" or reqInfoEntry[2] == "integer" ) then 
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "valueQuery", reqInfoEntry[1] ), ((territoryTable.Rewards[k] or {})[currentQuery] or 0), function( text ) 
				territoryTable.Rewards[k] = territoryTable.Rewards[k] or {}
				territoryTable.Rewards[k][currentQuery] = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), (reqInfoEntry[2] == "integer") )
		elseif( reqInfoEntry[2] == "bool" ) then 
			territoryTable.Rewards[k] = territoryTable.Rewards[k] or {}
			territoryTable.Rewards[k][currentQuery] = not territoryTable.Rewards[k][currentQuery]
			backLeftPanel.RefreshInfo()
		elseif( reqInfoEntry[2] == "table" and reqInfoEntry[3] and BRICKS_SERVER.Func.GetList( reqInfoEntry[3] ) ) then 
			BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "dataValueQuery" ), ((territoryTable.Rewards[k] or {})[currentQuery] or ""), BRICKS_SERVER.Func.GetList( reqInfoEntry[3] ), function( value, data ) 
				if( BRICKS_SERVER.Func.GetList( reqInfoEntry[3] )[data] ) then
					territoryTable.Rewards[k][currentQuery] = data

					if( reqInfoEntry[4] ) then
						local newupgradeTable = reqInfoEntry[4]( upgradeTable ) 
						if( newupgradeTable ) then
							upgradeTable = newupgradeTable
						end
					end
					backLeftPanel.RefreshInfo()
				else
					notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidChoice" ), 1, 3 )
				end
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
		elseif( reqInfoEntry[2] == "custom" and reqInfoEntry[3] ) then 
			territoryTable.Rewards[k] = territoryTable.Rewards[k] or {}
			reqInfoEntry[3]( territoryTable.Rewards, k, currentQuery, (territoryTable.Rewards[k] or {})[currentQuery] or {} )
		end

		GetNextQuery( currentQuery, k, v )
	end

	territoryTable.Rewards = territoryTable.Rewards or {}
	for k, v in pairs( BRICKS_SERVER.DEVCONFIG.GangRewards ) do
		table.insert( actions, { v.Name, false, function()
			GetNextQuery( 0, k, v )
		end, false, function() return v.FormatDescription( territoryTable.Rewards[k] or {} ) end } )
	end
	
	backRightPanel.FillOptions( territoryTable, actions )
	backLeftPanel.RefreshInfo()
end

function BRICKS_SERVER.Func.CreateLeaderboardEditor( oldLeaderboardTable, onSave, onCancel )
	local leaderboardTable = table.Copy( oldLeaderboardTable )

	local backgroundPanel, backRightPanel, backLeftPanel = BRICKS_SERVER.Func.CreateConfigPopup( onSave, onCancel )

	function backLeftPanel.RefreshInfo()
		backLeftPanel:Clear()

		backLeftPanel.Name = leaderboardTable.Name or BRICKS_SERVER.Func.L( "gangNewLeaderboard" )

		backLeftPanel.Refresh()
    end

	local actions = {
		[1] = { BRICKS_SERVER.Func.L( "name" ), Material( "materials/bricks_server/name.png" ), function()
			BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newNameQuery" ), leaderboardTable.Name, function( text ) 
				leaderboardTable.Name = text
				backLeftPanel.RefreshInfo()
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
		end, "Name" },
		[2] = { BRICKS_SERVER.Func.L( "type" ), Material( "materials/bricks_server/amount.png" ), function()
			local options = {}
			for k, v in pairs( BRICKS_SERVER.DEVCONFIG.GangLeaderboards ) do
				options[k] = v.Name
			end
	
			BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "newTypeQuery" ), (leaderboardTable.Type or ""), options, function( value, data ) 
				if( options[data] ) then
					leaderboardTable.Type = data
					backLeftPanel.RefreshInfo()
					backRightPanel.FillOptions( leaderboardTable, actions )
				else
					notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidType" ), 1, 3 )
				end
			end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
		end, "Type" }
	}
	
	backRightPanel.FillOptions( leaderboardTable, actions )
	backLeftPanel.RefreshInfo()
end