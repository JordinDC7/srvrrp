util.AddNetworkString( "BRS.Net.OpenUnboxingMenu" )
function BRICKS_SERVER.UNBOXING.Func.OpenMenu( ply )
	net.Start( "BRS.Net.OpenUnboxingMenu" )
	net.Send( ply )
end

hook.Add( "PlayerSay", "BricksServerHooks_PlayerSay_OpenUnboxingMenu", function( ply, text )
	if( BRICKS_SERVER.UNBOXING.LUACFG.MenuCommands[string.lower( text )] ) then
		BRICKS_SERVER.UNBOXING.Func.OpenMenu( ply )
		return ""
	end
end )

concommand.Add( "unboxing", function( ply, cmd, args )
	if( IsValid( ply ) and ply:IsPlayer() ) then
		BRICKS_SERVER.UNBOXING.Func.OpenMenu( ply )
	end
end )

util.AddNetworkString( "BRS.Net.UseUnboxingItem" )
net.Receive( "BRS.Net.UseUnboxingItem", function( len, ply )
	local itemKey = net.ReadUInt( 16 )
	local amount = net.ReadUInt( 16 )

	local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey or 0]
	if( not itemKey or not amount or not configItemTable ) then return end

	local globalKey = "ITEM_" .. itemKey

	local inventoryTable = ply:GetUnboxingInventory()
	if( not inventoryTable or not inventoryTable[globalKey] or inventoryTable[globalKey] < amount ) then return end

	local devConfigItemTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type] or {}
	if( not devConfigItemTable or not devConfigItemTable.UseFunction or (amount > 1 and not devConfigItemTable.UseMultiple) ) then return end

	local message, dontRemove = devConfigItemTable.UseFunction( ply, configItemTable.ReqInfo, amount )

	if( message ) then
		BRICKS_SERVER.Func.SendTopNotification( ply, message )
	end

	if( not dontRemove ) then
		ply:RemoveUnboxingInventoryItem( globalKey, amount )
	end
end )

util.AddNetworkString( "BRS.Net.EquipUnboxingItem" )
net.Receive( "BRS.Net.EquipUnboxingItem", function( len, ply )
	local globalKey = net.ReadString()

	if( not globalKey or not string.StartWith( globalKey, "ITEM_" ) ) then return end

	local inventoryTable = ply:GetUnboxingInventory()

	if( not inventoryTable or not inventoryTable[globalKey] ) then return end

	local itemKey = tonumber( string.Replace( globalKey, "ITEM_", "" ) )
	local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey]

	if( not configItemTable ) then return end

	local devConfigItemTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type] or {}

	if( not devConfigItemTable or not devConfigItemTable.EquipFunction or ply:UnboxingIsItemEquipped( globalKey ) ) then return end

	local inventoryDataTable = ply:GetUnboxingInventoryData()
	inventoryDataTable[globalKey] = inventoryDataTable[globalKey] or {}
	inventoryDataTable[globalKey].Equipped = true

	ply:SetUnboxingInventoryData( inventoryDataTable )

	local message = devConfigItemTable.EquipFunction( ply, configItemTable.ReqInfo )

	if( message ) then
		BRICKS_SERVER.Func.SendTopNotification( ply, message )
	end
end )

util.AddNetworkString( "BRS.Net.UnEquipUnboxingItem" )
net.Receive( "BRS.Net.UnEquipUnboxingItem", function( len, ply )
	local globalKey = net.ReadString()

	if( not globalKey or not string.StartWith( globalKey, "ITEM_" ) ) then return end

	local inventoryTable = ply:GetUnboxingInventory()

	if( not inventoryTable or not inventoryTable[globalKey] ) then return end

	local itemKey = tonumber( string.Replace( globalKey, "ITEM_", "" ) )
	local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey]

	if( not configItemTable ) then return end

	local devConfigItemTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type] or {}

	if( not devConfigItemTable or not devConfigItemTable.UnEquipFunction or not ply:UnboxingIsItemEquipped( globalKey ) ) then return end

	local inventoryDataTable = ply:GetUnboxingInventoryData()
	inventoryDataTable[globalKey] = inventoryDataTable[globalKey] or {}
	inventoryDataTable[globalKey].Equipped = false

	ply:SetUnboxingInventoryData( inventoryDataTable )

	local message = devConfigItemTable.UnEquipFunction( ply, configItemTable.ReqInfo )

	if( message ) then
		BRICKS_SERVER.Func.SendTopNotification( ply, message )
	end
end )

util.AddNetworkString( "BRS.Net.PurchaseShopUnboxingItems" )
util.AddNetworkString( "BRS.Net.PurchaseShopUnboxingItemsReturn" )
net.Receive( "BRS.Net.PurchaseShopUnboxingItems", function( len, ply )
	local itemCount = net.ReadUInt( 8 )
	if( not itemCount or itemCount < 1 ) then return end

	local shopItems = {}
	for i = 1, itemCount do
		local key, amount = net.ReadUInt( 16 ), net.ReadUInt( 8 )
		if( not key or not amount ) then return end
		shopItems[key] = amount
	end

	local totalCosts, totalItems, itemAddList = {}, 0, {}
	for k, v in pairs( shopItems ) do
		local shopItemConfig = BRICKS_SERVER.CONFIG.UNBOXING.Store.Items[k]

		if( not shopItemConfig or v < 1 or not shopItemConfig.GlobalKey ) then 
			BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoItemFoundAmount" ) )
			return 
		end

		if( shopItemConfig.Group and not BRICKS_SERVER.Func.IsInGroup( ply, shopItemConfig.Group ) ) then 
			BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNotGroup" ) )
			return 
		end

		local currency = shopItemConfig.Currency or BRICKS_SERVER.UNBOXING.LUACFG.DefaultCurrency
		totalCosts[currency] = (totalCosts[currency] or 0)+((shopItemConfig.Price or 0)*v)

		totalItems = totalItems+v
		table.insert( itemAddList, shopItemConfig.GlobalKey )
		table.insert( itemAddList, v )
	end
	 
	for k, v in pairs( totalCosts ) do
		if( not BRICKS_SERVER.UNBOXING.Func.CanAffordCurrency( ply, v, k ) ) then
			BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingCantAffordItems" ) )
			return
		end
	end

	for k, v in pairs( totalCosts ) do
		BRICKS_SERVER.UNBOXING.Func.TakeCurrency( ply, v, k )
	end

	ply:AddUnboxingInventoryItem( unpack( itemAddList ) )

	ply:UpdateUnboxingStat( "items", totalItems, true )

	ply:SendUnboxingItemNotification( BRICKS_SERVER.Func.L( "unboxingItemsPurchased" ), unpack( itemAddList ) )

	net.Start( "BRS.Net.PurchaseShopUnboxingItemsReturn" )
	net.Send( ply )
end )

util.AddNetworkString( "BRS.Net.RequestUnboxingLeaderboardStats" )
util.AddNetworkString( "BRS.Net.SendUnboxingLeaderboardStats" )
net.Receive( "BRS.Net.RequestUnboxingLeaderboardStats", function( len, ply )
    if( CurTime() < (ply.BRS_REQUEST_UNBOXINGSTATS_COOLDOWN or 0) ) then return end

	ply.BRS_REQUEST_UNBOXINGSTATS_COOLDOWN = CurTime()+10

	BRICKS_SERVER.UNBOXING.Func.FetchStatsSortedDB( "cases", BRICKS_SERVER.CONFIG.UNBOXING["Cases Leaderboard Limit"], function( data )
		if( not data ) then return end

		net.Start( "BRS.Net.SendUnboxingLeaderboardStats" )
			net.WriteTable( data )
		net.Send( ply )
	end )
end )

-- Currencies --
function BRICKS_SERVER.UNBOXING.Func.AddCurrency( ply, amount, currency )
	if( currency and BRICKS_SERVER.DEVCONFIG.Currencies[currency] ) then
		BRICKS_SERVER.DEVCONFIG.Currencies[currency].addFunction( ply, amount )
	else
		BRICKS_SERVER.DEVCONFIG.Currencies[BRICKS_SERVER.UNBOXING.LUACFG.DefaultCurrency].addFunction( ply, amount )
	end
end

function BRICKS_SERVER.UNBOXING.Func.TakeCurrency( ply, amount, currency )
	if( currency and BRICKS_SERVER.DEVCONFIG.Currencies[currency] ) then
		BRICKS_SERVER.DEVCONFIG.Currencies[currency].addFunction( ply, -amount )
	else
		BRICKS_SERVER.DEVCONFIG.Currencies[BRICKS_SERVER.UNBOXING.LUACFG.DefaultCurrency].addFunction( ply, -amount )
	end
end