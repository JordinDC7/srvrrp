local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.SetUnboxingInventory" )
function playerMeta:SetUnboxingInventory( inventoryTable, nosave )
	if( not inventoryTable ) then return end

	net.Start( "BRS.Net.SetUnboxingInventory" )
		net.WriteTable( inventoryTable )
	net.Send( self )

	self.BRS_UNBOXING_INVENTORY = inventoryTable

	if( not nosave ) then
		BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB( self:SteamID64(), inventoryTable )
	end
end

util.AddNetworkString( "BRS.Net.SetUnboxingInventoryData" )
function playerMeta:SetUnboxingInventoryData( inventoryDataTable, nosave )
	if( not inventoryDataTable ) then return end

	net.Start( "BRS.Net.SetUnboxingInventoryData" )
		net.WriteTable( inventoryDataTable )
	net.Send( self )

	self.BRS_UNBOXING_INVENTORYDATA = inventoryDataTable

	if( not nosave ) then
		BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDataDB( self:SteamID64(), inventoryDataTable )
	end
end

util.AddNetworkString( "BRS.Net.UpdateUnboxingStat" )
function playerMeta:UpdateUnboxingStat( key, value, add )
	if( not key or not value or not BRICKS_SERVER.DEVCONFIG.UnboxingStatTypes[key] ) then return end

	if( not self.BRS_UNBOXING_STATS ) then
		self.BRS_UNBOXING_STATS = {}
	end

	if( not add ) then
		self.BRS_UNBOXING_STATS[key] = value
	else
		self.BRS_UNBOXING_STATS[key] = (self:GetUnboxingStat( key ) or 0)+value
	end

	BRICKS_SERVER.UNBOXING.Func.FetchStatsDB( self:SteamID64(), function( data )
		if( data ) then
			BRICKS_SERVER.UNBOXING.Func.UpdateStatsDB( self:SteamID64(), key, self.BRS_UNBOXING_STATS[key] )
		else
			BRICKS_SERVER.UNBOXING.Func.InsertStatsDB( self:SteamID64(), key, self.BRS_UNBOXING_STATS[key] )
		end
	end )

	net.Start( "BRS.Net.UpdateUnboxingStat" )
		net.WriteString( key )
		net.WriteUInt( self.BRS_UNBOXING_STATS[key], 32 )
	net.Send( self )
end

util.AddNetworkString( "BRS.Net.SetUnboxingStats" )
hook.Add( "PlayerInitialSpawn", "BricksServerHooks_PlayerInitialSpawn_UnboxingLoadData", function( ply ) 
	BRICKS_SERVER.UNBOXING.Func.FetchInventoryDB( ply:SteamID64(), function( data )
		local inventoryTable = util.JSONToTable( data.inventory or "" ) or {}

		ply:SetUnboxingInventory( inventoryTable, true )
	end )

	BRICKS_SERVER.UNBOXING.Func.FetchInventoryDataDB( ply:SteamID64(), function( data )
		local inventoryDataTable = util.JSONToTable( data.inventorydata or "" ) or {}

		ply:SetUnboxingInventoryData( inventoryDataTable, true )
	end )

	BRICKS_SERVER.UNBOXING.Func.FetchStatsDB( ply:SteamID64(), function( data )
		if( not data ) then return end
		
		local statsTable = {
			cases = tonumber( data.cases or 0 ),
			trades = tonumber( data.trades or 0 ),
			items = tonumber( data.items or 0 )
		}

		net.Start( "BRS.Net.SetUnboxingStats" )
			net.WriteTable( statsTable )
		net.Send( ply )

		ply.BRS_UNBOXING_STATS = statsTable
	end )
end )

function playerMeta:AddUnboxingInventoryItem( ... )
	local itemsToAdd = { ... }

	local inventoryTable = self:GetUnboxingInventory()

	for k, v in ipairs( itemsToAdd ) do
		if( k % 2 == 0 ) then continue end

		local itemKey, amount = v, (itemsToAdd[k+1] or 1)

		if( not isstring( itemKey ) or not isnumber( amount ) ) then continue end

		local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( itemKey )

		if( not configItemTable ) then return end

		inventoryTable[itemKey] = (inventoryTable[itemKey] or 0)+(amount or 1)
	end

	self:SetUnboxingInventory( inventoryTable )
end

function playerMeta:RemoveUnboxingInventoryItem( ... )
	local itemsToTake = { ... }

	local inventoryTable = self:GetUnboxingInventory()
	local plyInventoryData = self:GetUnboxingInventoryData()
	local plyInventoryDataChanged = false

	for k, v in ipairs( itemsToTake ) do
		if( k % 2 == 0 ) then continue end

		local itemKey, amount = v, (itemsToTake[k+1] or 1)

		if( not isstring( itemKey ) or not isnumber( amount ) ) then continue end

		if( not inventoryTable[itemKey] or (inventoryTable[itemKey] or 0) < (amount or 1) ) then continue end

		inventoryTable[itemKey] = (inventoryTable[itemKey] or 0)-(amount or 1)

		if( inventoryTable[itemKey] <= 0 ) then
			inventoryTable[itemKey] = nil

			if( string.StartWith( itemKey, "ITEM_" ) ) then 
				local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[(BRS_UW and BRS_UW.ParseUniqueKey(itemKey)) or tonumber( string.Replace( itemKey, "ITEM_", "" ) )]
				local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type]

				if( devConfigTable and devConfigTable.UnEquipFunction ) then
					if( plyInventoryData[itemKey] and plyInventoryData[itemKey].Equipped ) then
						devConfigTable.UnEquipFunction( self, configItemTable.ReqInfo )
						plyInventoryData[itemKey] = nil
						plyInventoryDataChanged = true
					end
				end
			end
		end
	end

	self:SetUnboxingInventory( inventoryTable )

	if( plyInventoryDataChanged ) then
		self:SetUnboxingInventoryData( plyInventoryData )
	end

	return true
end

util.AddNetworkString( "BRS.Net.SendUnboxingItemNotification" )
function playerMeta:SendUnboxingItemNotification( reason, ... )
	net.Start( "BRS.Net.SendUnboxingItemNotification" )
		net.WriteString( reason )
		net.WriteTable( { ... } )
	net.Send( self )
end

hook.Add( "canDropWeapon", "BricksServerHooks_canDropWeapon_UnboxingPerm", function( ply, wep )
	if( not IsValid( wep ) ) then return end

	local plyInventory = ply:GetUnboxingInventory()
	for k, v in pairs( ply:GetUnboxingInventoryData() ) do
		if( not plyInventory[k] or not v.Equipped or not string.StartWith( k, "ITEM_" ) ) then continue end

		local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[(BRS_UW and BRS_UW.ParseUniqueKey(k)) or tonumber( string.Replace( k, "ITEM_", "" ) )]

		if( not configItemTable or configItemTable.Type != "PermWeapon" or (configItemTable.ReqInfo[1] or "") != wep:GetClass() ) then continue end

		return false
	end
end )

local function checkPermModel( ply, delay )
	timer.Simple( delay or 0, function()
		local plyInventory = ply:GetUnboxingInventory()
		for k, v in pairs( ply:GetUnboxingInventoryData() ) do
			if( not plyInventory[k] or not v.Equipped or not string.StartWith( k, "ITEM_" ) ) then continue end

			local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[(BRS_UW and BRS_UW.ParseUniqueKey(k)) or tonumber( string.Replace( k, "ITEM_", "" ) )]

			if( not configItemTable or configItemTable.Type != "PermPlayermodel" ) then continue end

			ply:SetModel( configItemTable.ReqInfo[1] or "" )
			ply:SetupHands()
		end
	end )
end

hook.Add( "PlayerSpawn", "BricksServerHooks_PlayerSpawn_UnboxingEquip", checkPermModel )
hook.Add( "PlayerInitialSpawn", "BricksServerHooks_PlayerSpawn_UnboxingEquip", function( ply )
	checkPermModel( ply, 5 )
end )
hook.Add( "PlayerChangedTeam", "BricksServerHooks_PlayerChangedTeam_UnboxingEquip", checkPermModel )

if( not BRICKS_SERVER.UNBOXING.LUACFG.TTT ) then
	hook.Add( "PlayerLoadout", "BricksServerHooks_PlayerLoadout_UnboxingPerm", function( ply )
		local plyInventory = ply:GetUnboxingInventory()
		for k, v in pairs( ply:GetUnboxingInventoryData() ) do
			if( not plyInventory[k] or not v.Equipped or not string.StartWith( k, "ITEM_" ) ) then continue end
	
			local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[(BRS_UW and BRS_UW.ParseUniqueKey(k)) or tonumber( string.Replace( k, "ITEM_", "" ) )]
	
			if( not configItemTable or configItemTable.Type != "PermWeapon" ) then continue end
	
			ply:Give( configItemTable.ReqInfo[1] or "" )
		end
	end )
else
	local function ClearKind( ply, kind )
		if( not kind ) then return end
	
		for _, wep in ipairs( ply:GetWeapons() ) do
			if( wep.Kind and wep.Kind == kind ) then
				ply:StripWeapon( wep:GetClass() )
	
				break
			end
		end
	end

	hook.Add( "TTTBeginRound", "BricksServerHooks_TTTBeginRound_UnboxingPerm", function() 
		for k, ply in ipairs( player.GetAll() ) do
			local plyInventory = ply:GetUnboxingInventory()
			for k, v in pairs( ply:GetUnboxingInventoryData() ) do
				if( not plyInventory[k] or not v.Equipped or not string.StartWith( k, "ITEM_" ) ) then continue end
		
				local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[(BRS_UW and BRS_UW.ParseUniqueKey(k)) or tonumber( string.Replace( k, "ITEM_", "" ) )]
		
				if( not configItemTable ) then continue end

				if( configItemTable.Type == "PermWeapon" ) then
					ClearKind( ply, (weapons.Get( configItemTable.ReqInfo[1] ) or {}).Kind )

					ply:Give( configItemTable.ReqInfo[1] )
				elseif( configItemTable.Type == "PermPlayermodel" ) then
					timer.Simple( 0, function() 
						ply:SetModel( configItemTable.ReqInfo[1] ) 
						ply:SetupHands()
					end )
				end
			end
		end
	end )
end

-- Random drops
hook.Add( "PlayerInitialSpawn", "BricksServerHooks_PlayerSpawn_UnboxingDrops", function( ply )
	if( table.Count( BRICKS_SERVER.CONFIG.UNBOXING.Drops.Items ) <= 0 ) then return end

	local timerID = "BRS_TIMER_UNBOXINGDROPS_" .. ply:SteamID64()
	timer.Create( timerID, BRICKS_SERVER.CONFIG.UNBOXING.Drops.TimeInterval, 0, function()
		if( not IsValid( ply ) ) then 
			timer.Remove( timerID )
			return 
		end

		local totalChance = 0
		for k, v in pairs( BRICKS_SERVER.CONFIG.UNBOXING.Drops.Items ) do
			totalChance = totalChance+v[2]
		end
	
		local winningChance, currentChance = math.Rand( 0, 100 ), 0
		local winningItemTable
		for k, v in pairs( BRICKS_SERVER.CONFIG.UNBOXING.Drops.Items ) do
			local actualChance = (v[2]/totalChance)*100
	
			if( winningChance > currentChance and winningChance <= currentChance+actualChance ) then
				winningItemTable = v
				break
			end
	
			currentChance = currentChance+actualChance
		end

		if( winningItemTable ) then
			ply:AddUnboxingInventoryItem( winningItemTable[1], winningItemTable[3] or 1 )
			ply:SendUnboxingItemNotification( BRICKS_SERVER.Func.L( "unboxingRandomDrop" ), winningItemTable[1], winningItemTable[3] or 1 )
		end
	end )
end )