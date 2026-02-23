function BRICKS_SERVER.UNBOXING.Func.OpenMenu()
    if( not IsValid( BRICKS_SERVER_UNBOXINGMENU ) ) then
		BRICKS_SERVER_UNBOXINGMENU = vgui.Create( "bricks_server_unboxingmenu" )
	elseif( not BRICKS_SERVER_UNBOXINGMENU:IsVisible() ) then
		BRICKS_SERVER_UNBOXINGMENU:SetVisible( true )
	end
	
	hook.Run( "BRS.Hooks.UnboxingMenuOpened" )
end

net.Receive( "BRS.Net.OpenUnboxingMenu", function()
	BRICKS_SERVER.UNBOXING.Func.OpenMenu()
end )

hook.Add( "PlayerButtonDown", "BricksServerHooks_PlayerButtonDown_OpenUnboxingMenu", function( ply, button )
	local bindText, bindButton = BRICKS_SERVER.Func.GetClientBind( "UnboxingMenuBind" )
	if( button == bindButton and CurTime() >= (BRS_UNBOXINGMENUCOOLDOWN or 0) ) then
		BRS_UNBOXINGMENUCOOLDOWN = CurTime()+1
		BRICKS_SERVER.UNBOXING.Func.OpenMenu()
	end
end )

net.Receive( "BRS.Net.UnboxCaseReturn", function()
	local globalKey = net.ReadString()

	if( not globalKey ) then return end

    hook.Run( "BRS.Hooks.UnboxingOpenCase", globalKey )
end )

net.Receive( "BRS.Net.UnboxCaseAlert", function()
	local ply = net.ReadEntity()

	if( not IsValid( ply ) ) then return end

	local globalKey = net.ReadString()

	if( not globalKey ) then return end

	local plyName = ply:Nick() or BRICKS_SERVER.Func.L( "unknown" )

	local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
	
	if( not configItemTable ) then return end

	local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( configItemTable.Rarity or "" )
	local rarityColor = BRICKS_SERVER.Func.GetRarityColor( rarityInfo )
	
	chat.AddText( Color( 26, 188, 156 ), BRICKS_SERVER.Func.L( "unboxingChatTag" ) .. " ", ply, Color( 255, 255, 255 ), BRICKS_SERVER.Func.L( "unboxingUnboxedX" ), rarityColor, "'" .. configItemTable.Name .. "'" )

	if( not BRS_UNBOXING_ACTIVITY ) then
		BRS_UNBOXING_ACTIVITY = {}
	end

	if( #BRS_UNBOXING_ACTIVITY >= (BRICKS_SERVER.CONFIG.UNBOXING["Activity Entry Limit"] or 25) ) then
		table.remove( BRS_UNBOXING_ACTIVITY, 1 )
	end

	local activityKey = table.insert( BRS_UNBOXING_ACTIVITY, { plyName, (configItemTable.Rarity or ""), configItemTable.Name } )

	hook.Run( "BRS.Hooks.InsertUnboxingAlert", activityKey )
end )

function BRICKS_SERVER.UNBOXING.Func.RequestLeaderboardStats()
    if( CurTime() < (BRS_REQUEST_UNBOXINGSTATS_COOLDOWN or 0) ) then return false, ((BRS_REQUEST_UNBOXINGSTATS_COOLDOWN or 0)-CurTime()) end

    BRS_REQUEST_UNBOXINGSTATS_COOLDOWN = CurTime()+10

    net.Start( "BRS.Net.RequestUnboxingLeaderboardStats" )
    net.SendToServer()

    return true
end

net.Receive( "BRS.Net.SendUnboxingLeaderboardStats", function()
	local statsTable = net.ReadTable()

	if( not statsTable ) then return end

	BRICKS_SERVER.TEMP.UnboxingLeaderboard = statsTable

	hook.Run( "BRS.Hooks.RefreshUnboxingLeaderboard" )
end )

net.Receive( "BRS.Net.PurchaseShopUnboxingItemsReturn", function()
	BRS_UNBOXING_CART = nil
	hook.Run( "BRS.Hooks.RefreshUnboxingCart" )
end )

function BRICKS_SERVER.Func.CreateUnboxingItemNotification( reason, ... )
	local argItems = { ... }
	local items = {}
	for k, v in ipairs( argItems ) do
		if( k % 2 == 0 ) then continue end

		items[v] = argItems[k+1] or 1
	end
	
	if( IsValid( BRS_UNBOXING_ITEMNOTIFICATION ) ) then
		BRS_UNBOXING_ITEMNOTIFICATION:Remove()
	end

	if( IsValid( BRS_TOPNOTIFICATION ) ) then
		BRS_TOPNOTIFICATION:Remove()
	end

	if( timer.Exists( "brs_unboxing_itemnotification_remove" ) ) then
		timer.Remove( "brs_unboxing_itemnotification_remove" )
	end

	surface.PlaySound( "ui/buttonclick.wav" )

	local multipleItems = table.Count( items ) > 1
	local popoutWide, popoutTall = ScrW()*0.18, not multipleItems and 100 or 120

	local singleConfigItemTable
	local amount = 0
	for k, v in pairs( items ) do
		local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )

		if( not configItemTable ) then continue end

		if( not multipleItems ) then
			singleConfigItemTable = configItemTable
		end

		amount = amount+v
	end

	if( not multipleItems and not singleConfigItemTable ) then return end

	local highestRarityKey, highestRarity

	BRS_UNBOXING_ITEMNOTIFICATION = vgui.Create( "DPanel" )
	BRS_UNBOXING_ITEMNOTIFICATION:SetSize( 0, popoutTall )
	BRS_UNBOXING_ITEMNOTIFICATION:SizeTo( popoutWide, popoutTall, 0.2 )
	BRS_UNBOXING_ITEMNOTIFICATION:DockPadding( 10, 0, 0, 0 )
	BRS_UNBOXING_ITEMNOTIFICATION:SetDrawOnTop( true )
	BRS_UNBOXING_ITEMNOTIFICATION.Paint = function( self2, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

		draw.SimpleText( string.upper( reason or "" ), "BRICKS_SERVER_Font17", w/2, h-10-8, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

		if( not multipleItems ) then
			local iconBackSize = popoutTall-20-8
			draw.SimpleText( singleConfigItemTable.Name, "BRICKS_SERVER_Font23", 10+iconBackSize+20, (h-8)/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( (singleConfigItemTable.Rarity or ""), "BRICKS_SERVER_Font20", 10+iconBackSize+20, (h-8)/2-2, BRICKS_SERVER.Func.GetRarityColor( highestRarity ), 0, 0 )
		end

		draw.SimpleText( amount .. "X", "BRICKS_SERVER_Font30", w-((h-8)/2), (h-8)/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	BRS_UNBOXING_ITEMNOTIFICATION.OnSizeChanged = function( self2 )
		self2:SetPos( (ScrW()/2)-(self2:GetWide()/2), 100 )
	end
	BRS_UNBOXING_ITEMNOTIFICATION.ClosePopout = function()
		if( IsValid( BRS_UNBOXING_ITEMNOTIFICATION ) ) then
			BRS_UNBOXING_ITEMNOTIFICATION:SizeTo( 0, popoutTall, 0.2, 0, -1, function()
				if( IsValid( BRS_UNBOXING_ITEMNOTIFICATION ) ) then
					BRS_UNBOXING_ITEMNOTIFICATION:Remove()
				end
			end )
		end
	end

	for k, v in pairs( items ) do
		local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )

		if( not configItemTable ) then continue end

		local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( configItemTable.Rarity or "" )

		if( rarityKey > (highestRarityKey or 0) ) then
			highestRarityKey, highestRarity = rarityKey, rarityInfo
		end
	end

	local rarityBox = vgui.Create( "bricks_server_raritybox", BRS_UNBOXING_ITEMNOTIFICATION )
	rarityBox:SetSize( popoutWide, 8 )
	rarityBox:SetPos( 0, popoutTall-rarityBox:GetTall() )
	rarityBox:SetRarityName( highestRarity[1] )
	rarityBox:SetCornerRadius( 8 )
	rarityBox:SetRoundedBoxDimensions( false, -(16-rarityBox:GetTall()), false, 16 )

	for k, v in pairs( items ) do
		local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )

		if( not configItemTable ) then continue end

		local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( configItemTable.Rarity )

		local itemBack = vgui.Create( "DPanel", BRS_UNBOXING_ITEMNOTIFICATION )
		itemBack:Dock( LEFT )
		itemBack:DockMargin( 0, 10, (not multipleItems and 0 or 5), 8+(not multipleItems and 10 or 35) )
		itemBack:SetWide( popoutTall-8-10-(not multipleItems and 0 or 35) )
		itemBack.Paint = function( self2, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, 150 ) )
		end

		local itemModel = vgui.Create( "bricks_server_unboxing_itemdisplay", itemBack )
        itemModel:Dock( FILL )
        itemModel:SetItemData( (isItem and "ITEM") or (isCase and "CASE") or (isKey and "KEY") or "", configItemTable )
        itemModel:SetIconSizeAdjust( 0.8 )
	end

	timer.Create( "brs_unboxing_itemnotification_remove", 3, 1, function()
		if( IsValid( BRS_UNBOXING_ITEMNOTIFICATION ) ) then
			BRS_UNBOXING_ITEMNOTIFICATION.ClosePopout()
		end
	end )
end