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
util.AddNetworkString( "BRS.Net.UnboxingStatTrakReroll" )
util.AddNetworkString( "BRS.Net.UnboxingStatTrakRerollReturn" )

local function brsGetTopTierConfig()
	return BRICKS_SERVER.UNBOXING.LUACFG.TopTier or {}
end

local function brsGetLiveOpsRuntime()
	BRICKS_SERVER.UNBOXING.RUNTIME = BRICKS_SERVER.UNBOXING.RUNTIME or {}
	BRICKS_SERVER.UNBOXING.RUNTIME.LiveOps = BRICKS_SERVER.UNBOXING.RUNTIME.LiveOps or { DropWeightHotfixes = {} }
	BRICKS_SERVER.UNBOXING.RUNTIME.LiveOps.DropWeightHotfixes = BRICKS_SERVER.UNBOXING.RUNTIME.LiveOps.DropWeightHotfixes or {}

	return BRICKS_SERVER.UNBOXING.RUNTIME.LiveOps
end

function BRICKS_SERVER.UNBOXING.Func.LogLiveOpsAudit( actorPly, action, payload )
	local actor = IsValid( actorPly ) and actorPly:SteamID64() or "console"
	local entry = {
		Time = os.time(),
		Actor = actor,
		Action = tostring( action or "unknown" ),
		Payload = payload or {}
	}

	file.Append( "bricks_server/unboxing_liveops_audit.jsonl", util.TableToJSON( entry ) .. "\n" )
end

function BRICKS_SERVER.UNBOXING.Func.GetDropWeightMultiplier( caseKey, itemGlobalKey )
	local runtime = brsGetLiveOpsRuntime()
	local caseHotfixes = runtime.DropWeightHotfixes[tostring( caseKey or "" )] or {}
	local multiplier = tonumber( caseHotfixes[itemGlobalKey] ) or 1

	local limits = (brsGetTopTierConfig().LiveOps or {}).HotfixWeightLimits or {}
	local minM = tonumber( limits.Min ) or 0.1
	local maxM = tonumber( limits.Max ) or 5

	return math.Clamp( multiplier, minM, maxM )
end

function BRICKS_SERVER.UNBOXING.Func.ResolveDropWeight( caseKey, itemGlobalKey, baseWeight, caseFamily )
	local resolved = math.max( 0, tonumber( baseWeight ) or 0 )
	local liveOpsMultiplier = BRICKS_SERVER.UNBOXING.Func.GetDropWeightMultiplier( caseKey, itemGlobalKey )
	local supplyMultiplier = BRICKS_SERVER.UNBOXING.Func.GetSupplyBalancingMultiplier( caseKey, caseFamily, itemGlobalKey )
	return resolved * liveOpsMultiplier * supplyMultiplier
end


local function brsGetSupplyRuntime()
	local runtime = brsGetLiveOpsRuntime()
	runtime.SupplyWindows = runtime.SupplyWindows or {}

	return runtime.SupplyWindows
end

local function brsBuildSupplyWindowKey( caseKey, caseFamily, itemGlobalKey )
	local cfg = ((brsGetTopTierConfig().DynamicDropNudges or {}).SupplyBalancing or {})
	if( cfg.CaseFamilyIsolation ) then
		return tostring( caseFamily or "unknown" ) .. "|" .. tostring( itemGlobalKey or "" )
	end

	return tostring( caseKey or "" ) .. "|" .. tostring( itemGlobalKey or "" )
end

local function brsTrimSupplyRuntimeWindow( windowData, now, windowSeconds )
	if( not istable( windowData ) ) then return 0 end

	windowData.Drops = windowData.Drops or {}
	local kept = {}
	local total = 0
	for _, ts in ipairs( windowData.Drops ) do
		if( (now-ts) <= windowSeconds ) then
			table.insert( kept, ts )
			total = total + 1
		end
	end

	windowData.Drops = kept
	return total
end

function BRICKS_SERVER.UNBOXING.Func.GetSupplyBalancingMultiplier( caseKey, caseFamily, itemGlobalKey )
	local cfg = ((brsGetTopTierConfig().DynamicDropNudges or {}).SupplyBalancing or {})
	if( not cfg.Enabled ) then return 1, 0, 0 end

	local key = brsBuildSupplyWindowKey( caseKey, caseFamily, itemGlobalKey )
	local runtime = brsGetSupplyRuntime()
	local now = os.time()
	local windowSeconds = math.max( 60, tonumber( cfg.WindowSeconds ) or 900 )
	local softCap = math.max( 1, tonumber( cfg.SoftCapPerItem ) or 12 )
	local maxPenalty = math.Clamp( tonumber( cfg.MaxPenalty ) or 0.35, 0, 0.95 )
	local exponent = math.max( 0.1, tonumber( cfg.PenaltyExponent ) or 0.7 )

	runtime[key] = runtime[key] or { Drops = {} }
	local inWindow = brsTrimSupplyRuntimeWindow( runtime[key], now, windowSeconds )
	if( inWindow <= softCap ) then
		return 1, inWindow, softCap
	end

	local overflowRatio = (inWindow-softCap)/softCap
	local penalty = math.Clamp( math.pow( overflowRatio, exponent ), 0, maxPenalty )
	return 1-penalty, inWindow, softCap
end

function BRICKS_SERVER.UNBOXING.Func.RecordSupplyDrop( caseKey, caseFamily, itemGlobalKey )
	local cfg = ((brsGetTopTierConfig().DynamicDropNudges or {}).SupplyBalancing or {})
	if( not cfg.Enabled ) then return end

	local key = brsBuildSupplyWindowKey( caseKey, caseFamily, itemGlobalKey )
	local runtime = brsGetSupplyRuntime()
	local now = os.time()
	local windowSeconds = math.max( 60, tonumber( cfg.WindowSeconds ) or 900 )

	runtime[key] = runtime[key] or { Drops = {} }
	brsTrimSupplyRuntimeWindow( runtime[key], now, windowSeconds )
	table.insert( runtime[key].Drops, now )
end


function BRICKS_SERVER.UNBOXING.Func.SetDropWeightHotfix( actorPly, caseKey, itemGlobalKey, multiplier, reason )
	local runtime = brsGetLiveOpsRuntime()
	local caseKeyStr = tostring( tonumber( caseKey ) or "" )
	if( caseKeyStr == "" or not itemGlobalKey or itemGlobalKey == "" ) then return false end

	runtime.DropWeightHotfixes[caseKeyStr] = runtime.DropWeightHotfixes[caseKeyStr] or {}
	local oldValue = runtime.DropWeightHotfixes[caseKeyStr][itemGlobalKey]

	if( not multiplier ) then
		runtime.DropWeightHotfixes[caseKeyStr][itemGlobalKey] = nil
		if( table.Count( runtime.DropWeightHotfixes[caseKeyStr] ) <= 0 ) then
			runtime.DropWeightHotfixes[caseKeyStr] = nil
		end
	else
		runtime.DropWeightHotfixes[caseKeyStr][itemGlobalKey] = tonumber( multiplier ) or 1
	end

	BRICKS_SERVER.UNBOXING.Func.LogLiveOpsAudit( actorPly, "drop_weight_hotfix", {
		CaseKey = caseKeyStr,
		Item = itemGlobalKey,
		Before = oldValue,
		After = runtime.DropWeightHotfixes[caseKeyStr] and runtime.DropWeightHotfixes[caseKeyStr][itemGlobalKey] or nil,
		Reason = reason or "manual"
	} )

	return true
end

function BRICKS_SERVER.UNBOXING.Func.GetDropWeightHotfixes()
	return brsGetLiveOpsRuntime().DropWeightHotfixes
end

function BRICKS_SERVER.UNBOXING.Func.GetSeasonState()
	local topTier = brsGetTopTierConfig()
	local liveOps = topTier.LiveOps or {}
	local now = os.time()
	local activeKey, activeSeason

	for key, season in pairs( liveOps.Seasons or {} ) do
		local startUnix = tonumber( season.StartUnix ) or 0
		local endUnix = tonumber( season.EndUnix ) or 0
		if( now >= startUnix and (endUnix <= 0 or now <= endUnix) ) then
			activeKey = tostring( key )
			activeSeason = season
			break
		end
	end

	if( not activeSeason and istable( liveOps.ActiveSeason ) ) then
		local startUnix = tonumber( liveOps.ActiveSeason.StartUnix ) or 0
		local endUnix = tonumber( liveOps.ActiveSeason.EndUnix ) or 0
		if( now >= startUnix and (endUnix <= 0 or now <= endUnix) ) then
			activeKey = "legacy_active"
			activeSeason = liveOps.ActiveSeason
		end
	end

	return {
		Now = now,
		SeasonKey = activeKey,
		ActiveSeason = activeSeason,
		LegacyVaultFamilies = liveOps.LegacyVaultFamilies or {},
		Seasons = liveOps.Seasons or {}
	}
end

function BRICKS_SERVER.UNBOXING.Func.GetCaseSeasonAvailability( caseKey, caseConfig )
	local liveOps = (brsGetTopTierConfig().LiveOps or {})
	if( not liveOps.SeasonModelEnabled ) then
		return true, "always_on", nil
	end

	local resolvedCase = caseConfig or BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey or 0] or {}
	local caseFamily = BRICKS_SERVER.UNBOXING.Func.GetCaseFamily( caseKey, resolvedCase )
	local seasonState = BRICKS_SERVER.UNBOXING.Func.GetSeasonState()
	local activeSeason = seasonState.ActiveSeason
	if( not activeSeason ) then
		return true, "no_active_season", nil
	end

	local featuredFamilies = activeSeason.FeaturedFamilies or {}
	if( featuredFamilies[caseFamily] ) then
		return true, "featured", activeSeason
	end

	local legacyVault = seasonState.LegacyVaultFamilies or {}
	if( legacyVault[caseFamily] ) then
		return true, "legacy_vault", activeSeason
	end

	return true, "out_of_rotation", activeSeason
end

function BRICKS_SERVER.UNBOXING.Func.GetCaseFamily( caseKey, caseConfig )
	local resolvedConfig = caseConfig or BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey or 0] or {}

	return tostring( resolvedConfig.CaseFamily or resolvedConfig.Rarity or ("case_" .. tostring( caseKey or "unknown" )) )
end


function BRICKS_SERVER.UNBOXING.Func.GetWeaponProgressionState( ply, globalKey )
	if( not IsValid( ply ) or not globalKey ) then return nil end

	local inventoryData = ply:GetUnboxingInventoryData()
	inventoryData[globalKey] = inventoryData[globalKey] or {}
	inventoryData[globalKey].StatTrak = inventoryData[globalKey].StatTrak or {}

	local statTrak = inventoryData[globalKey].StatTrak
	statTrak.Progression = statTrak.Progression or {
		XP = 0,
		Shots = 0,
		Hits = 0,
		Kills = 0,
		Unlocks = {}
	}

	statTrak.Progression.XP = tonumber( statTrak.Progression.XP ) or 0
	statTrak.Progression.Shots = tonumber( statTrak.Progression.Shots ) or 0
	statTrak.Progression.Hits = tonumber( statTrak.Progression.Hits ) or 0
	statTrak.Progression.Kills = tonumber( statTrak.Progression.Kills ) or 0
	statTrak.Progression.Unlocks = statTrak.Progression.Unlocks or {}

	return statTrak.Progression
end

function BRICKS_SERVER.UNBOXING.Func.AddWeaponProgressionXP( ply, globalKey, amount, progressType )
	if( not IsValid( ply ) or not globalKey ) then return end

	local statCfg = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
	local progressionCfg = statCfg.Progression or {}
	if( not progressionCfg.Enabled ) then return end

	local addAmount = math.max( 0, math.floor( tonumber( amount ) or 0 ) )
	if( addAmount <= 0 ) then return end

	local progression = BRICKS_SERVER.UNBOXING.Func.GetWeaponProgressionState( ply, globalKey )
	if( not progression ) then return end

	progression.XP = progression.XP + addAmount
	if( progressType == "shot" ) then
		progression.Shots = progression.Shots + 1
	elseif( progressType == "hit" ) then
		progression.Hits = progression.Hits + 1
	elseif( progressType == "kill" ) then
		progression.Kills = progression.Kills + 1
	end

	local unlocked = {}
	for _, milestone in ipairs( progressionCfg.Milestones or {} ) do
		local key = tostring( milestone.Unlock or "" )
		if( key != "" and progression.XP >= (tonumber( milestone.XP ) or 0) and not progression.Unlocks[key] ) then
			progression.Unlocks[key] = true
			table.insert( unlocked, key )
		end
	end

	local inventoryData = ply:GetUnboxingInventoryData()
	inventoryData[globalKey].StatTrak.Progression = progression
	ply:SetUnboxingInventoryData( inventoryData )

	if( #unlocked > 0 ) then
		BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "unbox_weapon_progression_unlock", {
			SteamID64 = ply:SteamID64(),
			Item = globalKey,
			XP = progression.XP,
			Unlocks = unlocked
		} )
	end
end


function BRICKS_SERVER.UNBOXING.Func.GetStatTrakProfileState( ply, globalKey )
	if( not IsValid( ply ) or not globalKey ) then return nil end

	local inventoryData = ply:GetUnboxingInventoryData()
	inventoryData[globalKey] = inventoryData[globalKey] or {}
	inventoryData[globalKey].StatTrak = inventoryData[globalKey].StatTrak or {}

	local statTrak = inventoryData[globalKey].StatTrak
	statTrak.Profile = statTrak.Profile or {
		kills = 0,
		headshots = 0,
		longest_streak = 0,
		assists = 0,
		objective_score = 0,
		CurrentStreak = 0,
		Prestige = { LastMilestone = 0, LastAnnounce = 0 },
		LastKillAt = 0,
		LastDeathAt = 0,
		LastCombatByVictim = {},
		Anomalies = 0
	}

	local profile = statTrak.Profile
	profile.kills = tonumber( profile.kills ) or 0
	profile.headshots = tonumber( profile.headshots ) or 0
	profile.longest_streak = tonumber( profile.longest_streak ) or 0
	profile.assists = tonumber( profile.assists ) or 0
	profile.objective_score = tonumber( profile.objective_score ) or 0
	profile.CurrentStreak = tonumber( profile.CurrentStreak ) or 0
	profile.Prestige = profile.Prestige or { LastMilestone = 0, LastAnnounce = 0 }
	profile.LastCombatByVictim = profile.LastCombatByVictim or {}
	profile.Anomalies = tonumber( profile.Anomalies ) or 0

	statTrak.Provenance = statTrak.Provenance or {
		OriginalUnboxer = statTrak.UnboxedBySteamID64,
		Transfers = {},
		Milestones = {},
		CreatedAt = statTrak.Created or os.time()
	}

	return profile
end

function BRICKS_SERVER.UNBOXING.Func.GetStatTrakLadderState( ply, globalKey )
	if( not IsValid( ply ) or not globalKey ) then return nil end

	local seasonState = BRICKS_SERVER.UNBOXING.Func.GetSeasonState()
	local seasonKey = seasonState.SeasonKey or "offseason"
	local inventoryData = ply:GetUnboxingInventoryData()
	inventoryData[globalKey] = inventoryData[globalKey] or {}
	inventoryData[globalKey].StatTrak = inventoryData[globalKey].StatTrak or {}

	local ladders = inventoryData[globalKey].StatTrak.Ladders or {}
	ladders[seasonKey] = ladders[seasonKey] or {
		Season = seasonKey,
		Points = 0,
		Rewards = {}
	}

	inventoryData[globalKey].StatTrak.Ladders = ladders
	return ladders[seasonKey], seasonKey
end

function BRICKS_SERVER.UNBOXING.Func.TrackStatTrakMilestone( ply, globalKey, statKey, value )
	if( not IsValid( ply ) or not globalKey ) then return end

	local profile = BRICKS_SERVER.UNBOXING.Func.GetStatTrakProfileState( ply, globalKey )
	if( not profile ) then return end

	local statCfg = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
	local milestones = statCfg.PrestigeMilestones or {}
	local prestige = profile.Prestige or { LastMilestone = 0, LastAnnounce = 0 }
	local newlyHit

	for _, milestone in ipairs( milestones ) do
		local milestoneVal = tonumber( milestone ) or 0
		if( milestoneVal > (tonumber( prestige.LastMilestone ) or 0) and value >= milestoneVal ) then
			newlyHit = milestoneVal
		end
	end

	if( not newlyHit ) then return end

	prestige.LastMilestone = newlyHit
	profile.Prestige = prestige

	local inventoryData = ply:GetUnboxingInventoryData()
	local statTrak = (inventoryData[globalKey] or {}).StatTrak or {}
	statTrak.Provenance = statTrak.Provenance or { Transfers = {}, Milestones = {} }
	statTrak.Provenance.Milestones = statTrak.Provenance.Milestones or {}
	table.insert( statTrak.Provenance.Milestones, {
		Time = os.time(),
		Stat = statKey,
		Value = value,
		Milestone = newlyHit
	} )

	local cooldown = math.max( 10, tonumber( statCfg.PrestigeCooldownSeconds ) or 90 )
	local now = CurTime()
	if( now >= ((prestige.LastAnnounce or 0)+cooldown) ) then
		prestige.LastAnnounce = now
		local itemName = (BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey ) or {}).Name or globalKey
		for _, target in ipairs( player.GetHumans() ) do
			BRICKS_SERVER.Func.SendChatNotification( target, Color( 255, 200, 85 ), "[StatTrak Prestige]", Color( 255, 255, 255 ), string.format( "%s reached %s %d on %s!", ply:Nick(), statKey, newlyHit, itemName ) )
		end
	end

	inventoryData[globalKey] = inventoryData[globalKey] or {}
	inventoryData[globalKey].StatTrak = statTrak
	inventoryData[globalKey].StatTrak.Profile = profile
	ply:SetUnboxingInventoryData( inventoryData )
end

function BRICKS_SERVER.UNBOXING.Func.RecordStatTrakTransfer( fromPly, toPly, globalKey, amount )
	if( not IsValid( fromPly ) or not IsValid( toPly ) ) then return end
	if( not globalKey or not string.StartWith( globalKey, "ITEM_" ) ) then return end
	if( (tonumber( amount ) or 0) <= 0 ) then return end

	local fromData = fromPly:GetUnboxingInventoryData()
	local statTrak = ((fromData[globalKey] or {}).StatTrak or nil)
	if( not istable( statTrak ) ) then return end

	statTrak.Provenance = statTrak.Provenance or { Transfers = {}, Milestones = {} }
	statTrak.Provenance.Transfers = statTrak.Provenance.Transfers or {}
	table.insert( statTrak.Provenance.Transfers, {
		Time = os.time(),
		From = fromPly:SteamID64(),
		To = toPly:SteamID64(),
		Amount = math.floor( tonumber( amount ) or 1 )
	} )

	fromData[globalKey] = fromData[globalKey] or {}
	fromData[globalKey].StatTrak = statTrak
	fromPly:SetUnboxingInventoryData( fromData )

	local toData = toPly:GetUnboxingInventoryData()
	toData[globalKey] = toData[globalKey] or {}
	toData[globalKey].StatTrak = table.Copy( statTrak )
	toPly:SetUnboxingInventoryData( toData )

	BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "stattrak_transfer", {
		Item = globalKey,
		From = fromPly:SteamID64(),
		To = toPly:SteamID64(),
		Amount = math.floor( tonumber( amount ) or 1 )
	} )
end

function BRICKS_SERVER.UNBOXING.Func.FlagStatTrakAnomaly( ply, reason, context )
	if( not IsValid( ply ) ) then return end

	local payload = {
		SteamID64 = ply:SteamID64(),
		Reason = tostring( reason or "unknown" ),
		Context = context or {}
	}

	BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "stattrak_anomaly", payload )
end

function BRICKS_SERVER.UNBOXING.Func.RecordStatTrakCombatAssist( attacker, victim )
	if( not IsValid( attacker ) or not IsValid( victim ) ) then return end

	local wep = attacker:GetActiveWeapon()
	if( not IsValid( wep ) ) then return end

	local statScalars = BRICKS_SERVER.UNBOXING.Func.GetEquippedWeaponStatScalars( attacker, wep:GetClass() )
	if( not statScalars or not statScalars.GlobalKey ) then return end

	local profile = BRICKS_SERVER.UNBOXING.Func.GetStatTrakProfileState( attacker, statScalars.GlobalKey )
	if( not profile ) then return end

	profile.LastCombatByVictim[victim:SteamID64()] = CurTime()

	local inventoryData = attacker:GetUnboxingInventoryData()
	inventoryData[statScalars.GlobalKey].StatTrak.Profile = profile
	attacker:SetUnboxingInventoryData( inventoryData )
end

function BRICKS_SERVER.UNBOXING.Func.RecordValidatedStatTrakKill( attacker, victim, statScalars, context )
	if( not IsValid( attacker ) or not statScalars or not statScalars.GlobalKey ) then return end

	local globalKey = statScalars.GlobalKey
	local profile = BRICKS_SERVER.UNBOXING.Func.GetStatTrakProfileState( attacker, globalKey )
	if( not profile ) then return end

	profile.kills = profile.kills+1
	profile.CurrentStreak = profile.CurrentStreak+1
	profile.longest_streak = math.max( profile.longest_streak, profile.CurrentStreak )
	profile.LastKillAt = CurTime()
	if( (context or {}).IsHeadshot ) then
		profile.headshots = profile.headshots+1
	end

	local statCfg = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
	local ladderCfg = statCfg.SeasonalLadders or {}
	if( ladderCfg.Enabled ) then
		local ladderState = BRICKS_SERVER.UNBOXING.Func.GetStatTrakLadderState( attacker, globalKey )
		if( ladderState ) then
			local pointsCfg = ladderCfg.LadderPoints or {}
			ladderState.Points = (tonumber( ladderState.Points ) or 0)+(tonumber( pointsCfg.Kill ) or 0)
			if( (context or {}).IsHeadshot ) then
				ladderState.Points = ladderState.Points+(tonumber( pointsCfg.Headshot ) or 0)
			end

			for _, reward in ipairs( ladderCfg.CosmeticRewards or {} ) do
				local rewardKey = tostring( reward.CosmeticID or "" )
				local threshold = tonumber( reward.Points ) or 0
				if( rewardKey != "" and ladderState.Points >= threshold and not ladderState.Rewards[rewardKey] ) then
					ladderState.Rewards[rewardKey] = os.time()
					BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "stattrak_ladder_reward", {
						SteamID64 = attacker:SteamID64(),
						Item = globalKey,
						Reward = rewardKey,
						Points = ladderState.Points
					} )
				end
			end
		end
	end

	BRICKS_SERVER.UNBOXING.Func.TrackStatTrakMilestone( attacker, globalKey, "kills", profile.kills )

	local inventoryData = attacker:GetUnboxingInventoryData()
	inventoryData[globalKey].StatTrak.Profile = profile
	attacker:SetUnboxingInventoryData( inventoryData )

	BRICKS_SERVER.UNBOXING.Func.TryAwardSocketModifier( attacker, globalKey, profile )

	if( IsValid( victim ) and victim:IsPlayer() ) then
		for _, helper in ipairs( player.GetHumans() ) do
			if( helper == attacker or helper == victim ) then continue end

			local helperWep = helper:GetActiveWeapon()
			if( not IsValid( helperWep ) ) then continue end

			local helperScalars = BRICKS_SERVER.UNBOXING.Func.GetEquippedWeaponStatScalars( helper, helperWep:GetClass() )
			if( not helperScalars or not helperScalars.GlobalKey ) then continue end

			local helperProfile = BRICKS_SERVER.UNBOXING.Func.GetStatTrakProfileState( helper, helperScalars.GlobalKey )
			if( not helperProfile ) then continue end

			local assistWindow = math.max( 1, tonumber( statCfg.AssistWindowSeconds ) or 10 )
			local lastHit = tonumber( (helperProfile.LastCombatByVictim or {})[victim:SteamID64()] ) or 0
			if( CurTime()-lastHit > assistWindow ) then continue end

			helperProfile.assists = helperProfile.assists+1
			local helperData = helper:GetUnboxingInventoryData()
			helperData[helperScalars.GlobalKey].StatTrak.Profile = helperProfile
			helper:SetUnboxingInventoryData( helperData )

			if( ladderCfg.Enabled ) then
				local helperLadder = BRICKS_SERVER.UNBOXING.Func.GetStatTrakLadderState( helper, helperScalars.GlobalKey )
				if( helperLadder ) then
					helperLadder.Points = (tonumber( helperLadder.Points ) or 0)+(tonumber( (ladderCfg.LadderPoints or {}).Assist ) or 0)
				end
			end
		end
	end

	BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "stattrak_validated_kill", {
		SteamID64 = attacker:SteamID64(),
		Item = globalKey,
		Victim = IsValid( victim ) and victim:SteamID64() or "npc",
		Headshot = (context or {}).IsHeadshot == true,
		Distance = tonumber( (context or {}).Distance ) or 0,
		Kills = profile.kills
	} )
end

function BRICKS_SERVER.UNBOXING.Func.TryAwardSocketModifier( ply, globalKey, profile )
	if( not IsValid( ply ) or not globalKey ) then return end

	local statCfg = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
	local socketCfg = statCfg.SocketedModifiers or {}
	if( not socketCfg.Enabled ) then return end

	local everyKills = math.max( 1, tonumber( socketCfg.EarnEveryKills ) or 40 )
	local kills = tonumber( (profile or {}).kills ) or 0
	if( kills <= 0 or (kills % everyKills) != 0 ) then return end

	local inventoryData = ply:GetUnboxingInventoryData()
	inventoryData[globalKey] = inventoryData[globalKey] or {}
	inventoryData[globalKey].StatTrak = inventoryData[globalKey].StatTrak or {}
	inventoryData[globalKey].StatTrak.SocketModifiers = inventoryData[globalKey].StatTrak.SocketModifiers or {}

	local socketList = inventoryData[globalKey].StatTrak.SocketModifiers
	local maxSockets = math.max( 1, tonumber( socketCfg.MaxSockets ) or 2 )
	if( #socketList >= maxSockets ) then return end

	local modifierPool = socketCfg.Modifiers or {}
	if( #modifierPool <= 0 ) then return end

	local statKey = tostring( modifierPool[math.random( 1, #modifierPool )] or "" )
	if( statKey == "" ) then return end

	local minBonus = tonumber( ((socketCfg.BonusRange or {}).Min) ) or 0.005
	local maxBonus = tonumber( ((socketCfg.BonusRange or {}).Max) ) or 0.025
	if( maxBonus < minBonus ) then minBonus, maxBonus = maxBonus, minBonus end

	table.insert( socketList, {
		StatKey = statKey,
		Bonus = math.Round( math.Rand( minBonus, maxBonus ), 4 ),
		EarnedAt = os.time(),
		Source = "gameplay"
	} )

	inventoryData[globalKey].StatTrak.SocketModifiers = socketList
	ply:SetUnboxingInventoryData( inventoryData )

	BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "stattrak_socket_awarded", {
		SteamID64 = ply:SteamID64(),
		Item = globalKey,
		StatKey = statKey,
		SocketCount = #socketList
	} )
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
	local seasonState = BRICKS_SERVER.UNBOXING.Func.GetSeasonState()
	local pityCfg = (brsGetTopTierConfig().Pity or {})

	net.Start( "BRS.Net.UnboxingProgressState" )
		net.WriteTable( {
			Fragments = state.Fragments,
			Pity = state.Pity,
			MasteryXP = state.MasteryXP,
			Collection = state.Collection,
			Daily = state.Daily,
			GangObjectives = state.GangObjectives,
			HypeFeedMuted = state.HypeFeedMuted,
			PityConfig = {
				SoftPityStart = pityCfg.SoftPityStart,
				HardPityCap = pityCfg.HardPityCap
			},
			Season = {
				Key = seasonState.SeasonKey,
				Data = seasonState.ActiveSeason,
				Now = seasonState.Now
			},
			LiveOps = {
				HotfixCaseCount = table.Count( BRICKS_SERVER.UNBOXING.Func.GetDropWeightHotfixes() ),
				SupplyWindowCount = table.Count( brsGetSupplyRuntime() )
			},
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

function BRICKS_SERVER.UNBOXING.Func.AddStatTrakObjectiveScore( ply, amount )
	if( not IsValid( ply ) ) then return end

	local addAmount = math.max( 0, math.floor( tonumber( amount ) or 0 ) )
	if( addAmount <= 0 ) then return end

	local wep = ply:GetActiveWeapon()
	if( not IsValid( wep ) ) then return end

	local statScalars = BRICKS_SERVER.UNBOXING.Func.GetEquippedWeaponStatScalars( ply, wep:GetClass() )
	if( not statScalars or not statScalars.GlobalKey ) then return end

	local profile = BRICKS_SERVER.UNBOXING.Func.GetStatTrakProfileState( ply, statScalars.GlobalKey )
	if( not profile ) then return end

	profile.objective_score = profile.objective_score+addAmount

	local inventoryData = ply:GetUnboxingInventoryData()
	inventoryData[statScalars.GlobalKey].StatTrak.Profile = profile
	ply:SetUnboxingInventoryData( inventoryData )

	local ladderCfg = (BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig().SeasonalLadders or {})
	if( ladderCfg.Enabled ) then
		local ladderState = BRICKS_SERVER.UNBOXING.Func.GetStatTrakLadderState( ply, statScalars.GlobalKey )
		if( ladderState ) then
			ladderState.Points = (tonumber( ladderState.Points ) or 0)+(addAmount*(tonumber( (ladderCfg.LadderPoints or {}).ObjectiveScore ) or 1))
		end
	end

	BRICKS_SERVER.UNBOXING.Func.TrackStatTrakMilestone( ply, statScalars.GlobalKey, "objective_score", profile.objective_score )
end

net.Receive( "BRS.Net.UnboxingStatTrakReroll", function( len, ply )
	local globalKey = net.ReadString()
	local targetStat = string.upper( net.ReadString() or "" )
	if( not globalKey or not string.StartWith( globalKey, "ITEM_" ) ) then return end

	local itemCfg = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
	if( not BRICKS_SERVER.UNBOXING.Func.IsStatTrakEligibleItem( itemCfg ) ) then return end

	local statCfg = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
	local craftCfg = statCfg.Crafting or {}
	if( not craftCfg.AllowTargetedReroll ) then return end

	local state = BRICKS_SERVER.UNBOXING.Func.GetTopTierState( ply )
	local cost = math.max( 1, math.floor( tonumber( craftCfg.RerollCostFragments ) or 35 ) )
	if( state.Fragments < cost ) then
		net.Start( "BRS.Net.UnboxingStatTrakRerollReturn" )
			net.WriteBool( false )
			net.WriteString( "Not enough fragments." )
		net.Send( ply )
		return
	end

	local inventoryData = ply:GetUnboxingInventoryData()
	inventoryData[globalKey] = inventoryData[globalKey] or {}
	inventoryData[globalKey].StatTrak = inventoryData[globalKey].StatTrak or {}

	local roll = inventoryData[globalKey].StatTrak.BestRoll or inventoryData[globalKey].StatTrak.LastRoll
	if( not istable( roll ) or not istable( roll.Stats ) or targetStat == "" or not roll.Stats[targetStat] ) then
		return
	end

	roll.Stats[targetStat] = math.random( 1, 100 )
	local scoreTotal, weightTotal = 0, 0
	for _, statInfo in ipairs( statCfg.Stats or {} ) do
		local key = tostring( statInfo.Key or "" )
		if( key == "" ) then continue end
		local weight = tonumber( statInfo.Weight ) or 1
		scoreTotal = scoreTotal+((tonumber( roll.Stats[key] ) or 0)*weight)
		weightTotal = weightTotal+weight
	end
	roll.Score = math.Round( scoreTotal/math.max( weightTotal, 1 ), 2 )
	roll.RerolledAt = os.time()

	inventoryData[globalKey].StatTrak.BestRoll = roll
	inventoryData[globalKey].StatTrak.LastRoll = roll
	state.Fragments = state.Fragments-cost
	inventoryData.__TopTier = state
	ply:SetUnboxingInventoryData( inventoryData )

	BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "stattrak_targeted_reroll", {
		SteamID64 = ply:SteamID64(),
		Item = globalKey,
		Stat = targetStat,
		Cost = cost,
		NewScore = roll.Score
	} )

	net.Start( "BRS.Net.UnboxingStatTrakRerollReturn" )
		net.WriteBool( true )
		net.WriteString( targetStat )
	net.Send( ply )

	BRICKS_SERVER.UNBOXING.Func.SendProgressState( ply, { Fragments = -cost, Reroll = targetStat } )
end )

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
