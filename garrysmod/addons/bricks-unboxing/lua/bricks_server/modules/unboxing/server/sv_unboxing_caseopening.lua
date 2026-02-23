
local function brsUnboxingRollBiasedStat( minValue, maxValue, curve )
	local span = math.max( 0, maxValue-minValue )
	if( span <= 0 ) then return minValue end

	local sample = math.pow( math.Rand( 0, 1 ), tonumber( curve ) or 1 )
	return math.Round( minValue+(span*sample) )
end

local function brsUnboxingGetTierFloorConfig( statTrakConfig, configItemTable )
	if( not istable( statTrakConfig ) or not istable( configItemTable ) ) then return nil end

	local rarity = tostring( configItemTable.Rarity or "" )
	for _, tierFloor in ipairs( statTrakConfig.HighTierMinimums or {} ) do
		local rarities = tierFloor.Rarities or {}
		if( rarities[rarity] ) then
			return tierFloor
		end
	end

	return nil
end


local function brsUnboxingResolveConditionTier( wearValue )
	local conditionTiers = (BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig().ConditionTiers or {})
	for _, tierInfo in ipairs( conditionTiers ) do
		if( wearValue <= (tonumber( tierInfo.MaxWear ) or 1) ) then
			return tierInfo.Name or "Battle-Scarred", tierInfo.Tag or "BS"
		end
	end

	return "Battle-Scarred", "BS"
end

local function brsUnboxingBuildConditionData( caseKey, caseConfig )
	local statCfg = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
	local caseFamily = string.lower( tostring( BRICKS_SERVER.UNBOXING.Func.GetCaseFamily( caseKey, caseConfig ) ) )
	local bandCfg = statCfg.ConditionBandsByCaseFamily or {}
	local selectedBand = bandCfg[caseFamily] or bandCfg.default or { MinWear = 0.08, MaxWear = 0.8 }

	local minWear = math.Clamp( tonumber( selectedBand.MinWear ) or 0.08, 0, 1 )
	local maxWear = math.Clamp( tonumber( selectedBand.MaxWear ) or 0.80, 0, 1 )
	if( maxWear < minWear ) then minWear, maxWear = maxWear, minWear end

	local wearValue = math.Round( math.Rand( minWear, maxWear ), 4 )
	local tierName, tierTag = brsUnboxingResolveConditionTier( wearValue )

	return {
		Wear = wearValue,
		TierName = tierName,
		TierTag = tierTag,
		CaseFamily = caseFamily
	}
end

local function brsUnboxingApplyTier( statTrakConfig, rollData )
	for _, tierInfo in ipairs( statTrakConfig.TierBreakpoints or {} ) do
		if( rollData.Score >= (tonumber( tierInfo.MinScore ) or 0) ) then
			rollData.TierName = tierInfo.Name or rollData.TierName
			rollData.TierTag = tierInfo.Tag or rollData.TierTag
			rollData.TierColor = tierInfo.Color or rollData.TierColor
			break
		end
	end
end

-- Builds one randomized StatTrak roll for eligible unboxed items.
local function brsUnboxingBuildStatTrakRoll( caseKey, caseConfig, configItemTable )
	local statTrakConfig = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
	if( not BRICKS_SERVER.UNBOXING.Func.IsStatTrakEligibleItem( configItemTable ) ) then return nil end

	local stats = statTrakConfig.Stats or {}
	if( table.Count( stats ) <= 0 ) then return nil end

	local conditionData = brsUnboxingBuildConditionData( caseKey, caseConfig )
	local rollData = {
		Stats = {},
		Score = 0,
		TierName = "",
		TierTag = "RAW",
		TierColor = Color( 164, 164, 164 ),
		IsGodRoll = false,
		IsJackpot = false,
		RollFlavor = "",
		Condition = conditionData,
		Created = os.time()
	}

	local rarityRange = (statTrakConfig.RarityRollRanges or {})[configItemTable.Rarity or ""] or {}
	rollData.RollFlavor = tostring( rarityRange.Flavor or "Field" )
	local tierFloorConfig = brsUnboxingGetTierFloorConfig( statTrakConfig, configItemTable )

	local weightedScore, totalWeight = 0, 0
	for _, statInfo in ipairs( stats ) do
		local minValue = tonumber( statInfo.Min ) or 1
		local maxValue = tonumber( statInfo.Max ) or 100
		if( maxValue < minValue ) then
			minValue, maxValue = maxValue, minValue
		end

		if( isnumber( rarityRange.Min ) ) then minValue = math.max( minValue, rarityRange.Min ) end
		if( isnumber( rarityRange.Max ) ) then maxValue = math.min( maxValue, rarityRange.Max ) end
		if( minValue > maxValue ) then minValue, maxValue = maxValue, minValue end

		local statRoll = brsUnboxingRollBiasedStat( minValue, maxValue, rarityRange.BiasCurve )
		rollData.Stats[statInfo.Key or "STAT"] = statRoll

		local weight = tonumber( statInfo.Weight ) or 1
		weightedScore = weightedScore + (statRoll*weight)
		totalWeight = totalWeight + weight
	end

	local hardCap = tonumber( rarityRange.HardCap )
	if( hardCap and hardCap > 0 ) then
		for statKey, statValue in pairs( rollData.Stats ) do
			rollData.Stats[statKey] = math.min( statValue, hardCap )
		end
	end

	local absoluteStatFloor = tierFloorConfig and tonumber( tierFloorConfig.MinStat ) or nil
	if( absoluteStatFloor and absoluteStatFloor > 0 ) then
		for statKey, statValue in pairs( rollData.Stats ) do
			rollData.Stats[statKey] = math.max( tonumber( statValue ) or 0, absoluteStatFloor )
		end

		rollData.RollFlavor = tostring( tierFloorConfig.Flavor or "Masterwork" )
	end

	local jackpotChance = tonumber( rarityRange.JackpotChance ) or 0
	if( jackpotChance > 0 and math.Rand( 0, 1 ) <= jackpotChance ) then
		rollData.IsJackpot = true
		local jackpotBoostCfg = statTrakConfig.JackpotBoost or {}
		local boostMin = tonumber( jackpotBoostCfg.Min ) or 8
		local boostMax = tonumber( jackpotBoostCfg.Max ) or 24
		if( boostMax < boostMin ) then boostMin, boostMax = boostMax, boostMin end

		for statKey, statValue in pairs( rollData.Stats ) do
			rollData.Stats[statKey] = math.Clamp( statValue+math.random( boostMin, boostMax ), 1, 100 )
		end

		rollData.RollFlavor = "Ascendant " .. rollData.RollFlavor
	end

	weightedScore, totalWeight = 0, 0
	for _, statInfo in ipairs( stats ) do
		local statRoll = tonumber( rollData.Stats[statInfo.Key or "STAT"] ) or 0
		local weight = tonumber( statInfo.Weight ) or 1
		weightedScore = weightedScore + (statRoll*weight)
		totalWeight = totalWeight + weight
	end

	rollData.Score = math.Round( weightedScore/math.max( totalWeight, 1 ), 2 )
	brsUnboxingApplyTier( statTrakConfig, rollData )

	rollData.IsGodRoll = rollData.Score >= (tonumber( statTrakConfig.GodRollScore ) or 97)
	if( rollData.IsJackpot and rollData.Score < (tonumber( statTrakConfig.GodRollScore ) or 97) ) then
		rollData.Score = math.min( 99.99, rollData.Score+5 )
		brsUnboxingApplyTier( statTrakConfig, rollData )
	end

	return rollData
end

-- Persists StatTrak roll metadata on the player's inventory data table.
local function brsUnboxingStoreStatTrakRoll( ply, globalKey, rollData )
	if( not IsValid( ply ) or not globalKey or not istable( rollData ) ) then return end

	rollData.UUID = rollData.UUID or util.CRC( tostring( globalKey ) .. ":" .. tostring( rollData.Created or os.time() ) .. ":" .. tostring( math.random( 1, 999999 ) ) )
	rollData.BoosterID = rollData.BoosterID or BRICKS_SERVER.UNBOXING.Func.BuildStatTrakBoosterID( globalKey, rollData )
	rollData.UnboxedBy = rollData.UnboxedBy or ply:Nick()
	rollData.UnboxedBySteamID64 = rollData.UnboxedBySteamID64 or ply:SteamID64()

	local inventoryDataTable = ply:GetUnboxingInventoryData()
	inventoryDataTable[globalKey] = inventoryDataTable[globalKey] or {}
	local currentStatTrak = inventoryDataTable[globalKey].StatTrak or {}
	currentStatTrak.Rolls = currentStatTrak.Rolls or {}

	currentStatTrak.RollCount = (tonumber( currentStatTrak.RollCount ) or 0)+1
	currentStatTrak.LastRoll = rollData
	table.insert( currentStatTrak.Rolls, 1, rollData )
	currentStatTrak.UnboxedBySteamID64 = currentStatTrak.UnboxedBySteamID64 or ply:SteamID64()
	currentStatTrak.UnboxedByName = currentStatTrak.UnboxedByName or ply:Nick()
	currentStatTrak.Created = currentStatTrak.Created or os.time()
	currentStatTrak.Provenance = currentStatTrak.Provenance or {
		OriginalUnboxer = currentStatTrak.UnboxedBySteamID64,
		Transfers = {},
		Milestones = {},
		CreatedAt = currentStatTrak.Created
	}

	local maxSavedRolls = tonumber( BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig().MaxSavedRolls ) or 250
	if( maxSavedRolls < 1 ) then maxSavedRolls = 1 end
	if( #currentStatTrak.Rolls > maxSavedRolls ) then
		for i = #currentStatTrak.Rolls, maxSavedRolls+1, -1 do
			currentStatTrak.Rolls[i] = nil
		end
	end

	if( not currentStatTrak.BestRoll or (tonumber( rollData.Score ) or 0) > (tonumber( currentStatTrak.BestRoll.Score ) or 0) ) then
		currentStatTrak.BestRoll = rollData
	end

	inventoryDataTable[globalKey].StatTrak = currentStatTrak
	ply:SetUnboxingInventoryData( inventoryDataTable )
end

-- Public helper used by all case-open paths to apply StatTrak rolls.
function BRICKS_SERVER.UNBOXING.Func.TryRollAndStoreStatTrak( ply, globalKey, caseKey, caseConfig )
	local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
	if( not BRICKS_SERVER.UNBOXING.Func.IsStatTrakEligibleItem( configItemTable ) ) then return nil end

	local rollData = brsUnboxingBuildStatTrakRoll( caseKey, caseConfig, configItemTable )
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

	local seasonAllowed, seasonReason = BRICKS_SERVER.UNBOXING.Func.GetCaseSeasonAvailability( caseKey, configItemTable )
	if( not seasonAllowed ) then
		local denyMsg = "This case is currently vaulted for this season."
		if( seasonReason == "no_active_season" ) then
			denyMsg = "No active case season right now."
		end
		BRICKS_SERVER.Func.SendTopNotification( ply, denyMsg, 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
		return false
	end

	local liveOpsConfig = ((BRICKS_SERVER.UNBOXING.LUACFG.TopTier or {}).LiveOps or {})
	if( liveOpsConfig.KillSwitchEnabled ) then
		local caseFamily = BRICKS_SERVER.UNBOXING.Func.GetCaseFamily( caseKey, configItemTable )
		if( (liveOpsConfig.DisabledCaseFamilies or {})[caseFamily] ) then
			BRICKS_SERVER.Func.SendTopNotification( ply, "This case family is temporarily disabled.", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
			return false
		end
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

	local caseFamily = BRICKS_SERVER.UNBOXING.Func.GetCaseFamily( caseKey, configItemTable )
	local pityConfig = (BRICKS_SERVER.UNBOXING.LUACFG.TopTier or {}).Pity or {}
	local state = BRICKS_SERVER.UNBOXING.Func.GetTopTierState( ply )
	state.Pity[caseFamily] = tonumber( state.Pity[caseFamily] ) or 0

	local winningChance, currentChance = math.Rand( 0, 100 ), 0
	local winningItemKey
	local pityBefore = state.Pity[caseFamily]

	if( pityConfig.HardPityCap and pityConfig.HardPityCap > 0 and pityBefore >= pityConfig.HardPityCap ) then
		local apexPool = {}
		for itemGlobalKey, itemChance in pairs( configItemTable.Items ) do
			local itemConfig = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( itemGlobalKey )
			if( itemConfig and BRICKS_SERVER.UNBOXING.Func.IsApexRarity( itemConfig.Rarity ) ) then
				table.insert( apexPool, itemGlobalKey )
			end
		end

		if( #apexPool > 0 ) then
			winningItemKey = apexPool[math.random( 1, #apexPool )]
		end
	end

	local softPityThreshold = tonumber( pityConfig.SoftPityStart ) or 0
	local softPityBoost = tonumber( pityConfig.SoftPityBoostPerOpen ) or 0
	local pityMultiplier = 1
	if( softPityThreshold > 0 and pityBefore >= softPityThreshold ) then
		pityMultiplier = 1+((pityBefore-softPityThreshold+1)*softPityBoost)
	end

	local totalChanceWeighted = 0
	for itemGlobalKey, itemChanceTable in pairs( configItemTable.Items ) do
		local itemChance = BRICKS_SERVER.UNBOXING.Func.ResolveDropWeight( caseKey, itemGlobalKey, tonumber( (itemChanceTable or {})[1] ) or 0, caseFamily, ply )
		local itemConfig = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( itemGlobalKey )
		if( itemConfig and BRICKS_SERVER.UNBOXING.Func.IsApexRarity( itemConfig.Rarity ) ) then
			itemChance = itemChance * pityMultiplier
		end

		totalChanceWeighted = totalChanceWeighted + itemChance
	end

	if( not winningItemKey ) then
		winningChance = math.Rand( 0, 100 )
		currentChance = 0

		for k, v in pairs( configItemTable.Items ) do
			local itemChance = BRICKS_SERVER.UNBOXING.Func.ResolveDropWeight( caseKey, k, tonumber( v[1] ) or 0, caseFamily, ply )
			local itemConfig = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )
			if( itemConfig and BRICKS_SERVER.UNBOXING.Func.IsApexRarity( itemConfig.Rarity ) ) then
				itemChance = itemChance * pityMultiplier
			end

			local actualChance = (itemChance/math.max( totalChanceWeighted, 1))*100

			if( winningChance > currentChance and winningChance <= currentChance+actualChance ) then
				winningItemKey = k
				break
			end

			currentChance = currentChance+actualChance
		end
	end

	local duplicateProtection = ((BRICKS_SERVER.UNBOXING.LUACFG.TopTier or {}).DuplicateProtection or {})
	if( duplicateProtection.Enabled ) then
		local winningConfig = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( winningItemKey )
		if( winningConfig and BRICKS_SERVER.UNBOXING.Func.IsApexRarity( winningConfig.Rarity ) ) then
			state.RecentApexDrops = state.RecentApexDrops or {}
			local now = os.time()
			local window = math.max( 30, tonumber( duplicateProtection.WindowSeconds ) or 180 )
			local recent = state.RecentApexDrops[winningItemKey]
			local rerolls = math.max( 0, tonumber( duplicateProtection.MaxRerolls ) or 3 )
			if( recent and (now-(tonumber( recent.Time ) or 0)) <= window ) then
				for _ = 1, rerolls do
					local candidate = nil
					local roll = math.Rand( 0, 100 )
					local acc = 0
					for k, v in pairs( configItemTable.Items ) do
						local weight = BRICKS_SERVER.UNBOXING.Func.ResolveDropWeight( caseKey, k, tonumber( v[1] ) or 0, caseFamily, ply )
						local actualChance = (weight/math.max( totalChanceWeighted, 1))*100
						if( roll > acc and roll <= acc+actualChance ) then
							candidate = k
							break
						end
						acc = acc+actualChance
					end
					if( candidate and candidate != winningItemKey ) then
						winningItemKey = candidate
						break
					end
				end
			end
		end
	end

	if( not winningItemKey or not configItemTable.Items[winningItemKey] ) then
		BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoItemFound" ) )
		return false
	end

	local wonConfig = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( winningItemKey )
	if( wonConfig and BRICKS_SERVER.UNBOXING.Func.IsApexRarity( wonConfig.Rarity ) ) then
		state.Pity[caseFamily] = 0
		BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "unbox_pity_guaranteed", {
			SteamID64 = ply:SteamID64(),
			CaseFamily = caseFamily,
			PityBefore = pityBefore,
			Item = winningItemKey
		} )
	else
		state.Pity[caseFamily] = pityBefore + 1
		BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "unbox_pity_incremented", {
			SteamID64 = ply:SteamID64(),
			CaseFamily = caseFamily,
			PityBefore = pityBefore,
			PityAfter = state.Pity[caseFamily],
			Item = winningItemKey
		} )
	end

	state.Daily.Date = state.Daily.Date or os.date( "%Y-%m-%d" )
	if( state.Daily.Date != os.date( "%Y-%m-%d" ) ) then
		state.Daily.Date = os.date( "%Y-%m-%d" )
		state.Daily.Opened = 0
	end
	state.Daily.Opened = (tonumber( state.Daily.Opened ) or 0) + 1

	local wonCfgForRecent = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( winningItemKey )
	if( wonCfgForRecent and BRICKS_SERVER.UNBOXING.Func.IsApexRarity( wonCfgForRecent.Rarity ) ) then
		state.RecentApexDrops[winningItemKey] = { Time = os.time() }
	end
	BRICKS_SERVER.UNBOXING.Func.SetTopTierState( ply, state )
	BRICKS_SERVER.UNBOXING.Func.SendProgressState( ply, { PityFamily = caseFamily, PityDepth = state.Pity[caseFamily] } )

	BRICKS_SERVER.UNBOXING.Func.RecordSupplyDrop( caseKey, caseFamily, winningItemKey )
	local supplyMultiplier, supplyInWindow, supplySoftCap = BRICKS_SERVER.UNBOXING.Func.GetSupplyBalancingMultiplier( caseKey, caseFamily, winningItemKey )

	BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "unbox_open_resolved", {
		SteamID64 = ply:SteamID64(),
		CaseFamily = caseFamily,
		Drop = winningItemKey,
		PityBefore = pityBefore,
		PityAfter = state.Pity[caseFamily],
		Season = (BRICKS_SERVER.UNBOXING.Func.GetSeasonState() or {}).SeasonKey,
		DropWeightHotfix = BRICKS_SERVER.UNBOXING.Func.GetDropWeightMultiplier( caseKey, winningItemKey ),
		SupplyDropMultiplier = supplyMultiplier,
		SupplyDropsInWindow = supplyInWindow,
		SupplySoftCap = supplySoftCap,
		SessionLengthBucket = "0-15m",
		Gang = false
	} )
	
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
		
		local duplicate = (ply:GetUnboxingInventory()[winningItemKey] or 0) > 0
		ply:AddUnboxingInventoryItem( winningItemKey )
		BRICKS_SERVER.UNBOXING.Func.TryRollAndStoreStatTrak( ply, winningItemKey, caseKey, BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey] )

		if( duplicate and string.StartWith( winningItemKey, "ITEM_" ) ) then
			local fragmentGain = BRICKS_SERVER.UNBOXING.Func.GetDuplicateFragmentValue( winningItemKey )
			BRICKS_SERVER.UNBOXING.Func.AddFragments( ply, fragmentGain, "duplicate_conversion", { Item = winningItemKey } )
			BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "unbox_duplicate_converted", {
				SteamID64 = ply:SteamID64(),
				Item = winningItemKey,
				Fragments = fragmentGain
			} )
		end

		BRICKS_SERVER.UNBOXING.Func.AddMasteryXP( ply, ((BRICKS_SERVER.UNBOXING.LUACFG.TopTier or {}).MasteryXPPerOpen or 10), { Item = winningItemKey } )
		BRICKS_SERVER.UNBOXING.Func.AddCaseOpenHistory( ply, caseKey, winningItemKey )
		BRICKS_SERVER.UNBOXING.Func.ProgressRetentionMission( ply, "open_cases", 1 )
		BRICKS_SERVER.UNBOXING.Func.UpdateCollectionBooks( ply )

		local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( winningItemKey )
		if( configItemTable and configItemTable.Rarity and BRICKS_SERVER.UNBOXING.Func.IsApexRarity( configItemTable.Rarity ) ) then
			net.Start( "BRS.Net.UnboxCaseAlert" )
				net.WriteEntity( ply )
				net.WriteString( winningItemKey )
			net.Broadcast()
		elseif( configItemTable and configItemTable.Rarity and (BRICKS_SERVER.CONFIG.UNBOXING.NotificationRarities or {})[configItemTable.Rarity] ) then
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

	local seasonAllowed = BRICKS_SERVER.UNBOXING.Func.GetCaseSeasonAvailability( caseKey, configItemTable )
	if( not seasonAllowed ) then
		BRICKS_SERVER.Func.SendTopNotification( ply, "This case is currently vaulted for this season.", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
		return
	end

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

	local caseFamily = BRICKS_SERVER.UNBOXING.Func.GetCaseFamily( caseKey, configItemTable )
	local totalChance = 0
	for itemGlobalKey, chanceInfo in pairs( configItemTable.Items ) do
		totalChance = totalChance + BRICKS_SERVER.UNBOXING.Func.ResolveDropWeight( caseKey, itemGlobalKey, (chanceInfo or {})[1], caseFamily, ply )
	end

	local itemsToGive = {}
	for i = 1, openAmount do
		local winningChance, currentChance = math.Rand( 0, 100 ), 0
		for k, v in pairs( configItemTable.Items ) do
			local resolvedWeight = BRICKS_SERVER.UNBOXING.Func.ResolveDropWeight( caseKey, k, v[1], caseFamily, ply )
			local actualChance = (resolvedWeight/math.max( totalChance, 1))*100
	
			if( winningChance > currentChance and winningChance <= currentChance+actualChance ) then
				itemsToGive[k] = (itemsToGive[k] or 0)+1
				BRICKS_SERVER.UNBOXING.Func.RecordSupplyDrop( caseKey, caseFamily, k )
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
	BRICKS_SERVER.UNBOXING.Func.ProgressRetentionMission( ply, "open_cases", openAmount )
	BRICKS_SERVER.UNBOXING.Func.UpdateCollectionBooks( ply )

	for globalKey, amount in pairs( itemsToGive ) do
		for i = 1, amount do
			BRICKS_SERVER.UNBOXING.Func.TryRollAndStoreStatTrak( ply, globalKey, caseKey, configItemTable )
			BRICKS_SERVER.UNBOXING.Func.AddCaseOpenHistory( ply, caseKey, globalKey )
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
