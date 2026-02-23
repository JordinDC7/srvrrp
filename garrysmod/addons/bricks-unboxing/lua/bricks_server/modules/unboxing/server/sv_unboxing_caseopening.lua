
-- Builds one randomized StatTrak roll for eligible unboxed items.
local function brsUnboxingBuildStatTrakRoll( configItemTable )
	local statTrakConfig = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
	if( not BRICKS_SERVER.UNBOXING.Func.IsStatTrakEligibleItem( configItemTable ) ) then return nil end

	local stats = statTrakConfig.Stats or {}
	if( table.Count( stats ) <= 0 ) then return nil end

	local rollData = {
		Stats = {},
		Score = 0,
		TierName = "",
		TierTag = "STD",
		TierColor = Color( 164, 164, 164 ),
		IsGodRoll = false,
		Created = os.time()
	}

	local rarityRanges = statTrakConfig.RarityRollRanges or {}
	local rarityRange = rarityRanges[configItemTable.Rarity or ""] or {}

	local weightedScore, totalWeight = 0, 0
	for _, statInfo in ipairs( stats ) do
		local minValue = tonumber( statInfo.Min ) or 1
		local maxValue = tonumber( statInfo.Max ) or 100
		if( maxValue < minValue ) then
			minValue, maxValue = maxValue, minValue
		end

		if( isnumber( rarityRange.Min ) ) then
			minValue = math.max( minValue, rarityRange.Min )
		end

		if( isnumber( rarityRange.Max ) ) then
			maxValue = math.min( maxValue, rarityRange.Max )
		end

		if( minValue > maxValue ) then
			minValue, maxValue = maxValue, minValue
		end

		local statRoll = math.random( minValue, maxValue )
		rollData.Stats[statInfo.Key or "STAT"] = statRoll

		local weight = tonumber( statInfo.Weight ) or 1
		weightedScore = weightedScore + (statRoll*weight)
		totalWeight = totalWeight + weight
	end

	rollData.Score = math.Round( weightedScore/math.max( totalWeight, 1 ), 2 )

	for _, tierInfo in ipairs( statTrakConfig.TierBreakpoints or {} ) do
		if( rollData.Score >= (tonumber( tierInfo.MinScore ) or 0) ) then
			rollData.TierName = tierInfo.Name or rollData.TierName
			rollData.TierTag = tierInfo.Tag or rollData.TierTag
			rollData.TierColor = tierInfo.Color or rollData.TierColor
			break
		end
	end

	rollData.IsGodRoll = rollData.Score >= (tonumber( statTrakConfig.GodRollScore ) or 94)

	return rollData
end

-- Persists StatTrak roll metadata on the player's inventory data table.
local function brsUnboxingStoreStatTrakRoll( ply, globalKey, rollData )
	if( not IsValid( ply ) or not globalKey or not istable( rollData ) ) then return end

	local inventoryDataTable = ply:GetUnboxingInventoryData()
	inventoryDataTable[globalKey] = inventoryDataTable[globalKey] or {}
	local currentStatTrak = inventoryDataTable[globalKey].StatTrak or {}

	currentStatTrak.RollCount = (tonumber( currentStatTrak.RollCount ) or 0)+1
	currentStatTrak.LastRoll = rollData

	if( not currentStatTrak.BestRoll or (tonumber( rollData.Score ) or 0) > (tonumber( currentStatTrak.BestRoll.Score ) or 0) ) then
		currentStatTrak.BestRoll = rollData
	end

	inventoryDataTable[globalKey].StatTrak = currentStatTrak
	ply:SetUnboxingInventoryData( inventoryDataTable )
end

-- Public helper used by all case-open paths to apply StatTrak rolls.
function BRICKS_SERVER.UNBOXING.Func.TryRollAndStoreStatTrak( ply, globalKey )
	local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
	if( not BRICKS_SERVER.UNBOXING.Func.IsStatTrakEligibleItem( configItemTable ) ) then return nil end

	local rollData = brsUnboxingBuildStatTrakRoll( configItemTable )
	if( not rollData ) then return nil end

	brsUnboxingStoreStatTrakRoll( ply, globalKey, rollData )
	return rollData
end

local function caseOpen( ply, caseKey )
	local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey or 0]

	if( not configItemTable ) then return false end

	local inventoryTable = ply:GetUnboxingInventory()
	local globalKey = "CASE_" .. caseKey

	if( not inventoryTable or not inventoryTable[globalKey] ) then return false end

	local canOpen, message = ply:UnboxingCanOpenCase( caseKey )
	if( not canOpen ) then
		BRICKS_SERVER.Func.SendTopNotification( ply, message, 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
		return false
	end

	local keyUsed
	if( configItemTable.Keys and table.Count( configItemTable.Keys ) > 0 ) then
		local keyRemovedSuccess = false
		for k, v in pairs( configItemTable.Keys ) do
			if( (inventoryTable["KEY_" .. k] or 0) >= 1 ) then
				local removedKey = ply:RemoveUnboxingInventoryItem( "KEY_" .. k, 1 )

				if( removedKey ) then
					keyRemovedSuccess, keyUsed = true, k
					break
				end
			end
		end

		if( not keyRemovedSuccess ) then
			BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoKeyFound" ) )
		end
	end

	local removedItem = ply:RemoveUnboxingInventoryItem( globalKey, 1 )

	if( not removedItem ) then return false end

	local totalChance = 0
	for k, v in pairs( configItemTable.Items ) do
		totalChance = totalChance+v[1]
	end

	local winningChance, currentChance = math.Rand( 0, 100 ), 0
	local winningItemKey
	for k, v in pairs( configItemTable.Items ) do
		local actualChance = (v[1]/totalChance)*100

		if( winningChance > currentChance and winningChance <= currentChance+actualChance ) then
			winningItemKey = k
			break
		end

		currentChance = currentChance+actualChance
	end

	if( not winningItemKey or not configItemTable.Items[winningItemKey] ) then
		BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoItemFound" ) )
		return false
	end
	
	hook.Run( "BRS.Hooks.CaseUnboxed", ply )
    
    return true, winningItemKey, keyUsed
end

util.AddNetworkString( "BRS.Net.UnboxCase" )
util.AddNetworkString( "BRS.Net.UnboxCaseReturn" )
util.AddNetworkString( "BRS.Net.UnboxCaseAlert" )
net.Receive( "BRS.Net.UnboxCase", function( len, ply )
	local caseKey = net.ReadUInt( 16 )
    
    local success, winningItemKey = caseOpen( ply, caseKey )

    if( not success ) then return end

	net.Start( "BRS.Net.UnboxCaseReturn" )
		net.WriteString( winningItemKey )
	net.Send( ply )

	timer.Simple( BRICKS_SERVER.CONFIG.UNBOXING["Case UI Open Time"], function()
		if( not IsValid( ply ) ) then return end
		
		ply:AddUnboxingInventoryItem( winningItemKey )
		BRICKS_SERVER.UNBOXING.Func.TryRollAndStoreStatTrak( ply, winningItemKey )

		local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( winningItemKey )
		if( configItemTable and configItemTable.Rarity and (BRICKS_SERVER.CONFIG.UNBOXING.NotificationRarities or {})[configItemTable.Rarity] ) then
			net.Start( "BRS.Net.UnboxCaseAlert" )
				net.WriteEntity( ply )
				net.WriteString( winningItemKey )
			net.Broadcast()
		end

		ply:SendUnboxingItemNotification( BRICKS_SERVER.Func.L( "unboxingCaseOpened" ), winningItemKey, 1 )

		ply:UpdateUnboxingStat( "cases", 1, true )
	end )
end )

util.AddNetworkString( "BRS.Net.UnboxingOpenAll" )
net.Receive( "BRS.Net.UnboxingOpenAll", function( len, ply )
	local caseKey = net.ReadUInt( 16 )
	local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey or 0]

	if( not configItemTable ) then return end

	local inventoryTable = ply:GetUnboxingInventory()
	local globalKey = "CASE_" .. caseKey

	if( not inventoryTable or not inventoryTable[globalKey] ) then return end

	local openAmount = inventoryTable[globalKey]

	if( configItemTable.Keys and table.Count( configItemTable.Keys ) > 0 ) then
		local remainingAmount = openAmount
		local keysToTake = {}

		for k, v in pairs( configItemTable.Keys ) do
			local amount = inventoryTable["KEY_" .. k] or 0
			if( amount < 1 ) then continue end

			local toRemove = math.min( remainingAmount, amount )
			remainingAmount = remainingAmount - toRemove

			table.insert( keysToTake, "KEY_" .. k )
			table.insert( keysToTake, toRemove )

			if( remainingAmount <= 0 ) then break end
		end

		if( table.Count( keysToTake ) > 0 ) then
			ply:RemoveUnboxingInventoryItem( unpack( keysToTake ) )
		end

		openAmount = openAmount-remainingAmount
	end

	if( openAmount <= 0 ) then
		BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingNeedKey" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
		return
	end

	ply:RemoveUnboxingInventoryItem( globalKey, openAmount )

	local totalChance = 0
	for k, v in pairs( configItemTable.Items ) do
		totalChance = totalChance+v[1]
	end

	local itemsToGive = {}
	for i = 1, openAmount do
		local winningChance, currentChance = math.Rand( 0, 100 ), 0
		for k, v in pairs( configItemTable.Items ) do
			local actualChance = (v[1]/totalChance)*100
	
			if( winningChance > currentChance and winningChance <= currentChance+actualChance ) then
				itemsToGive[k] = (itemsToGive[k] or 0)+1
				break
			end
	
			currentChance = currentChance+actualChance
		end
	end

	local formattedItems = {}
	for k, v in pairs( itemsToGive ) do
		table.insert( formattedItems, k )
		table.insert( formattedItems, v )
	end

	ply:AddUnboxingInventoryItem( unpack( formattedItems ) )

	for globalKey, amount in pairs( itemsToGive ) do
		for i = 1, amount do
			BRICKS_SERVER.UNBOXING.Func.TryRollAndStoreStatTrak( ply, globalKey )
		end
	end

	BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingCasesUnboxed", openAmount ) )
	
	hook.Run( "BRS.Hooks.CaseUnboxed", ply, openAmount )

	ply:UpdateUnboxingStat( "cases", openAmount, true )
end )

util.AddNetworkString( "BRS.Net.PlaceUnboxingCase" )
net.Receive( "BRS.Net.PlaceUnboxingCase", function( len, ply )
    if( CurTime() < (ply.BRS_CASECOOLDOWN or 0) ) then return end

	ply.BRS_CASECOOLDOWN = CurTime()+0.3
	
	if( not ply:Alive() ) then return end

	local caseKey = net.ReadUInt( 16 )
	local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey]
	
	if( not configItemTable or not configItemTable.Model or not BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels[configItemTable.Model] ) then return end
    
    local spawnPos = ply:GetEyeTrace().HitPos
    if( ply:GetPos():DistToSqr( spawnPos ) > 10000 ) then
        return
    end

    local success, winningItemKey, keyUsed = caseOpen( ply, caseKey )

    if( not success ) then return end
    
	local caseEnt = ents.Create( "bricks_server_unboxingcase" )
	if( not IsValid( caseEnt ) ) then return end
    caseEnt:SetPos( spawnPos+Vector( 0, 0, 50 ) )
    caseEnt:OpenCase( caseKey, ply, winningItemKey, keyUsed )
    caseEnt:Spawn()
    caseEnt:DropToFloor()
end )