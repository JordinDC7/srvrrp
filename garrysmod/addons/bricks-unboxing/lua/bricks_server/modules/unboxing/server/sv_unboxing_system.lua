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
util.AddNetworkString( "BRS.Net.UnboxingPremiumRedirect" )
-- Handles optional premium-credit checkout redirects for insufficient funds.
local function brsHandlePremiumRedirect( ply, currency )
    local redirectConfig = BRICKS_SERVER.UNBOXING.LUACFG.PremiumCreditRedirect or {}

    if( not redirectConfig.Enabled or not isstring( redirectConfig.URL ) or redirectConfig.URL == "" ) then return false end
    if( currency ~= (redirectConfig.Currency or "ps2_premium_points") ) then return false end

    BRICKS_SERVER.Func.SendNotification( ply, 1, 7, BRICKS_SERVER.Func.L( "unboxingCantAffordItems" ) )

    net.Start( "BRS.Net.UnboxingPremiumRedirect" )
        net.WriteString( redirectConfig.URL )
    net.Send( ply )

    BRICKS_SERVER.Func.BRS_MSGN( "unboxing", "Premium redirect triggered for " .. (ply:SteamID64() or "unknown") )

    return true
end

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
			if( brsHandlePremiumRedirect( ply, k ) ) then return end

			BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingCantAffordItems" ) )
			BRICKS_SERVER.Func.BRS_MSGN( "unboxing", "Store purchase denied (insufficient currency) for " .. (ply:SteamID64() or "unknown") .. " on " .. tostring( k ) )
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

util.AddNetworkString( "BRS.Net.UnboxingProgressState" )
util.AddNetworkString( "BRS.Net.UnboxingCraftItem" )
util.AddNetworkString( "BRS.Net.UnboxingCraftItemReturn" )
util.AddNetworkString( "BRS.Net.UnboxingBatchConvertCommons" )
util.AddNetworkString( "BRS.Net.UnboxingSetHypeFeedMuted" )

local function brsGetTopTierConfig()
	return BRICKS_SERVER.UNBOXING.LUACFG.TopTier or {}
end

function BRICKS_SERVER.UNBOXING.Func.GetCaseFamily( caseKey, caseConfig )
	local resolvedConfig = caseConfig or BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey or 0] or {}

	return tostring( resolvedConfig.CaseFamily or resolvedConfig.Rarity or ("case_" .. tostring( caseKey or "unknown" )) )
end

function BRICKS_SERVER.UNBOXING.Func.IsApexRarity( rarity )
	return (brsGetTopTierConfig().ApexRarities or {})[tostring( rarity or "")] == true
end

function BRICKS_SERVER.UNBOXING.Func.GetTopTierState( ply )
	if( not IsValid( ply ) ) then return {} end

	local inventoryData = ply:GetUnboxingInventoryData()
	inventoryData.__TopTier = inventoryData.__TopTier or {}
	inventoryData.__TopTier.Pity = inventoryData.__TopTier.Pity or {}
	inventoryData.__TopTier.Fragments = tonumber( inventoryData.__TopTier.Fragments ) or 0
	inventoryData.__TopTier.MasteryXP = tonumber( inventoryData.__TopTier.MasteryXP ) or 0
	inventoryData.__TopTier.Collection = inventoryData.__TopTier.Collection or {}
	inventoryData.__TopTier.Daily = inventoryData.__TopTier.Daily or { Opened = 0, Date = os.date( "%Y-%m-%d" ) }
	inventoryData.__TopTier.HypeFeedMuted = inventoryData.__TopTier.HypeFeedMuted == true
	inventoryData.__TopTier.GangObjectives = inventoryData.__TopTier.GangObjectives or { Week = os.date( "%Y-%W" ), Progress = 0, Claimed = false }

	return inventoryData.__TopTier
end

function BRICKS_SERVER.UNBOXING.Func.SetTopTierState( ply, state )
	if( not IsValid( ply ) or not istable( state ) ) then return end

	local inventoryData = ply:GetUnboxingInventoryData()
	inventoryData.__TopTier = state
	ply:SetUnboxingInventoryData( inventoryData )
end

function BRICKS_SERVER.UNBOXING.Func.LogTelemetry( eventName, payload )
	local entry = {
		Time = os.time(),
		Event = tostring( eventName or "unbox_unknown" ),
		Payload = payload or {}
	}

	file.Append( "bricks_server/unboxing_telemetry.jsonl", util.TableToJSON( entry ) .. "\n" )
end

function BRICKS_SERVER.UNBOXING.Func.SendProgressState( ply, progressionDelta )
	if( not IsValid( ply ) ) then return end

	local state = BRICKS_SERVER.UNBOXING.Func.GetTopTierState( ply )
	net.Start( "BRS.Net.UnboxingProgressState" )
		net.WriteTable( {
			Fragments = state.Fragments,
			Pity = state.Pity,
			MasteryXP = state.MasteryXP,
			Collection = state.Collection,
			Daily = state.Daily,
			GangObjectives = state.GangObjectives,
			HypeFeedMuted = state.HypeFeedMuted,
			Delta = progressionDelta or {}
		} )
	net.Send( ply )
end

function BRICKS_SERVER.UNBOXING.Func.AddFragments( ply, amount, reason, metadata )
	local addAmount = math.max( 0, math.floor( tonumber( amount ) or 0 ) )
	if( addAmount <= 0 ) then return 0 end

	local state = BRICKS_SERVER.UNBOXING.Func.GetTopTierState( ply )
	state.Fragments = state.Fragments + addAmount
	BRICKS_SERVER.UNBOXING.Func.SetTopTierState( ply, state )

	BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "unbox_fragment_delta", {
		SteamID64 = ply:SteamID64(),
		Delta = addAmount,
		Reason = reason,
		Metadata = metadata
	} )

	BRICKS_SERVER.UNBOXING.Func.SendProgressState( ply, { Fragments = addAmount } )
	return addAmount
end

function BRICKS_SERVER.UNBOXING.Func.AddMasteryXP( ply, amount, metadata )
	local addAmount = math.max( 0, math.floor( tonumber( amount ) or 0 ) )
	if( addAmount <= 0 ) then return end

	local state = BRICKS_SERVER.UNBOXING.Func.GetTopTierState( ply )
	state.MasteryXP = state.MasteryXP + addAmount
	BRICKS_SERVER.UNBOXING.Func.SetTopTierState( ply, state )

	BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "unbox_mastery_xp", {
		SteamID64 = ply:SteamID64(),
		Delta = addAmount,
		Metadata = metadata
	} )

	BRICKS_SERVER.UNBOXING.Func.SendProgressState( ply, { MasteryXP = addAmount } )
end

function BRICKS_SERVER.UNBOXING.Func.GetDuplicateFragmentValue( globalKey )
	local rarity = (BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey ) or {}).Rarity
	return (brsGetTopTierConfig().DuplicateFragmentValues or {})[tostring( rarity or "")] or (brsGetTopTierConfig().DuplicateFragmentFallback or 1)
end

net.Receive( "BRS.Net.UnboxingCraftItem", function( len, ply )
	local recipeKey = net.ReadString()
	local recipe = (brsGetTopTierConfig().CraftingRecipes or {})[recipeKey or ""]
	if( not recipe or not recipe.GlobalKey ) then return end

	local cost = math.max( 1, math.floor( tonumber( recipe.FragmentCost ) or 0 ) )
	local state = BRICKS_SERVER.UNBOXING.Func.GetTopTierState( ply )
	if( state.Fragments < cost ) then
		net.Start( "BRS.Net.UnboxingCraftItemReturn" )
			net.WriteBool( false )
			net.WriteString( "Not enough fragments." )
		net.Send( ply )
		return
	end

	state.Fragments = state.Fragments - cost
	BRICKS_SERVER.UNBOXING.Func.SetTopTierState( ply, state )
	ply:AddUnboxingInventoryItem( recipe.GlobalKey, recipe.Amount or 1 )

	BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "unbox_fragment_crafted", {
		SteamID64 = ply:SteamID64(),
		Recipe = recipeKey,
		GlobalKey = recipe.GlobalKey,
		Cost = cost
	} )

	BRICKS_SERVER.UNBOXING.Func.SendProgressState( ply, { Fragments = -cost, Crafted = recipe.GlobalKey } )

	net.Start( "BRS.Net.UnboxingCraftItemReturn" )
		net.WriteBool( true )
		net.WriteString( recipe.GlobalKey )
	net.Send( ply )
end )

net.Receive( "BRS.Net.UnboxingBatchConvertCommons", function( len, ply )
	local inventory = ply:GetUnboxingInventory()
	local totalFragments, removeList = 0, {}

	for globalKey, amount in pairs( inventory ) do
		if( not string.StartWith( globalKey, "ITEM_" ) or amount <= 0 ) then continue end

		local itemConfig = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
		if( not itemConfig or itemConfig.Rarity != "Common" ) then continue end

		local fragmentValue = BRICKS_SERVER.UNBOXING.Func.GetDuplicateFragmentValue( globalKey )
		totalFragments = totalFragments + (fragmentValue * amount)
		table.insert( removeList, globalKey )
		table.insert( removeList, amount )
	end

	if( #removeList <= 0 or totalFragments <= 0 ) then return end

	ply:RemoveUnboxingInventoryItem( unpack( removeList ) )
	BRICKS_SERVER.UNBOXING.Func.AddFragments( ply, totalFragments, "batch_convert_commons" )
end )

net.Receive( "BRS.Net.UnboxingSetHypeFeedMuted", function( len, ply )
	local shouldMute = net.ReadBool()
	local state = BRICKS_SERVER.UNBOXING.Func.GetTopTierState( ply )
	state.HypeFeedMuted = shouldMute
	BRICKS_SERVER.UNBOXING.Func.SetTopTierState( ply, state )
	BRICKS_SERVER.UNBOXING.Func.SendProgressState( ply )
end )

hook.Add( "PlayerInitialSpawn", "BricksServerHooks_PlayerInitialSpawn_UnboxingProgressState", function( ply )
	timer.Simple( 6, function()
		if( not IsValid( ply ) ) then return end
		BRICKS_SERVER.UNBOXING.Func.SendProgressState( ply )
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
