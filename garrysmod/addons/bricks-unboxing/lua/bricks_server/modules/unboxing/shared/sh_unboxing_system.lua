local playerMeta = FindMetaTable("Player")
function playerMeta:GetUnboxingInventory()
	if( SERVER ) then
		return self.BRS_UNBOXING_INVENTORY or {}
	elseif( CLIENT ) then
		if( self == LocalPlayer() ) then
			return BRS_UNBOXING_INVENTORY or {}
		else
			return self.BRS_UNBOXING_INVENTORY or {}
		end
	end
end

function playerMeta:GetUnboxingInventoryData()
	if( SERVER ) then
		return self.BRS_UNBOXING_INVENTORYDATA or {}
	elseif( CLIENT ) then
		if( self == LocalPlayer() ) then
			return BRS_UNBOXING_INVENTORYDATA or {}
		else
			return self.BRS_UNBOXING_INVENTORYDATA or {}
		end
	end
end

function playerMeta:GetUnboxingStats()
	if( SERVER ) then
		return self.BRS_UNBOXING_STATS or {}
	elseif( CLIENT ) then
		if( self == LocalPlayer() ) then
			return BRS_UNBOXING_STATS or {}
		else
			return self.BRS_UNBOXING_STATS or {}
		end
	end
end

function playerMeta:UnboxingCanOpenCase( caseKey )
	local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey]

	if( not configItemTable ) then return false, BRICKS_SERVER.Func.L( "unboxingCaseNotExists" ) end

	local keysTable = configItemTable.Keys
	if( keysTable ) then
		local inventoryTable = self:GetUnboxingInventory()
		local hasKey = false
		for k, v in pairs( keysTable ) do
			if( (inventoryTable["KEY_" .. k] or 0) >= 1 ) then
				hasKey = true
				break
			end
		end

		if( not hasKey ) then return false, BRICKS_SERVER.Func.L( "unboxingNeedKey" ) end
	end

	return true
end

function playerMeta:UnboxingIsItemEquipped( globalKey )
	local plyInventoryData = self:GetUnboxingInventoryData()

	if( plyInventoryData[globalKey] and plyInventoryData[globalKey].Equipped == true ) then
		return true
	end

	return false
end

function playerMeta:GetUnboxingStat( stat )
	return self:GetUnboxingStats()[stat] or 0
end

function BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
    if( istable( globalKey ) ) then
        globalKey = globalKey[1]
    end

    if( not isstring( globalKey ) ) then return nil, nil, false, false, false end

	local isItem, isCase, isKey = string.StartWith( globalKey, "ITEM_" ), string.StartWith( globalKey, "CASE_" ), string.StartWith( globalKey, "KEY_" )
	local configItemTable, itemKey

	if( isItem ) then
		itemKey = tonumber( string.Replace( globalKey, "ITEM_", "" ) )
		configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey]
	elseif( isCase ) then
		itemKey = tonumber( string.Replace( globalKey, "CASE_", "" ) )
		configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[itemKey]
	elseif( isKey ) then
		itemKey = tonumber( string.Replace( globalKey, "KEY_", "" ) )
		configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Keys[itemKey]
	end

	return configItemTable, itemKey, isItem, isCase, isKey
end



-- Returns the data blob stored for a specific unboxing inventory key.
function playerMeta:GetUnboxingItemData( globalKey )
    if( not globalKey ) then return nil end

    return (self:GetUnboxingInventoryData() or {})[globalKey]
end

-- Returns StatTrak config with safe fallback.
function BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
    return BRICKS_SERVER.UNBOXING.LUACFG.StatTrak or {}
end

-- Checks whether an unboxed item type should receive StatTrak rolls.
function BRICKS_SERVER.UNBOXING.Func.IsStatTrakEligibleItem( configItemTable )
    local statTrakConfig = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
    if( not statTrakConfig.Enabled or not configItemTable ) then return false end

    return (statTrakConfig.EligibleItemTypes or {})[configItemTable.Type or ""] == true
end

-- Returns the best available StatTrak roll for UI display.
function BRICKS_SERVER.UNBOXING.Func.GetStatTrakSummary( ply, globalKey )
    if( not IsValid( ply ) or not globalKey ) then return nil end

    local itemData = ply:GetUnboxingItemData( globalKey ) or {}
    local statTrakData = itemData.StatTrak

    if( not istable( statTrakData ) ) then return nil end

    return statTrakData.BestRoll or statTrakData.LastRoll
end

-- Returns all persisted rolls for one inventory key (newest first in source order).
function BRICKS_SERVER.UNBOXING.Func.GetStatTrakRolls( ply, globalKey )
    if( not IsValid( ply ) or not globalKey ) then return {} end

    local itemData = ply:GetUnboxingItemData( globalKey ) or {}
    local statTrakData = itemData.StatTrak
    if( not istable( statTrakData ) ) then return {} end

    local rolls = statTrakData.Rolls
    if( not istable( rolls ) ) then
        local fallback = BRICKS_SERVER.UNBOXING.Func.GetStatTrakSummary( ply, globalKey )
        return fallback and { fallback } or {}
    end

    if( #rolls > 0 ) then
        return rolls
    end

    local normalized = {}
    for k, v in pairs( rolls ) do
        local idx = tonumber( k )
        if( idx and istable( v ) ) then
            normalized[idx] = v
        end
    end

    if( #normalized > 0 ) then
        return normalized
    end

    local fallback = BRICKS_SERVER.UNBOXING.Func.GetStatTrakSummary( ply, globalKey )
    return fallback and { fallback } or {}
end

-- Returns one roll instance by list index, with sane fallback to summary.
function BRICKS_SERVER.UNBOXING.Func.GetStatTrakRollByIndex( ply, globalKey, rollIndex )
    local rolls = BRICKS_SERVER.UNBOXING.Func.GetStatTrakRolls( ply, globalKey )

    if( istable( rolls[rollIndex] ) ) then
        return rolls[rollIndex]
    end

    local idx = math.max( 1, tonumber( rollIndex ) or 1 )

    return rolls[idx] or BRICKS_SERVER.UNBOXING.Func.GetStatTrakSummary( ply, globalKey )
end

-- Builds a deterministic metadata id for one specific rolled item instance.
function BRICKS_SERVER.UNBOXING.Func.BuildStatTrakBoosterID( globalKey, rollData )
    if( not globalKey or not istable( rollData ) ) then return "" end

    local seed = string.format(
        "%s|%s|%s|%s|%s|%s",
        tostring( globalKey ),
        tostring( (rollData.Stats or {}).DMG or 0 ),
        tostring( (rollData.Stats or {}).ACC or 0 ),
        tostring( (rollData.Stats or {}).CTRL or 0 ),
        tostring( (rollData.Stats or {}).HND or 0 ),
        tostring( (rollData.Stats or {}).MOV or 0 ),
        tostring( rollData.Created or os.time() )
    )

    return string.upper( util.CRC( seed ) or "" )
end

-- Calculates per-stat rank/percentile against the player's equipped inventory for a weapon class.
function BRICKS_SERVER.UNBOXING.Func.GetStatTrakRankings( ply, weaponClass, currentStats )
    if( not IsValid( ply ) or not weaponClass or not istable( currentStats ) ) then return {} end

    local statKeys = { "DMG", "ACC", "CTRL", "HND", "MOV" }
    local compared = {
        DMG = {},
        ACC = {},
        CTRL = {},
        HND = {},
        MOV = {}
    }

    local inventory = ply:GetUnboxingInventory()
    local inventoryData = ply:GetUnboxingInventoryData()

    for globalKey, itemData in pairs( inventoryData ) do
        if( not inventory[globalKey] or not string.StartWith( globalKey, "ITEM_" ) ) then continue end

        local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[tonumber( string.Replace( globalKey, "ITEM_", "" ) )]
        if( not configItemTable ) then continue end
        if( configItemTable.Type != "Weapon" and configItemTable.Type != "PermWeapon" ) then continue end
        if( (configItemTable.ReqInfo or {})[1] != weaponClass ) then continue end

        local summary = BRICKS_SERVER.UNBOXING.Func.GetStatTrakSummary( ply, globalKey )
        local stats = (summary and summary.Stats) or {}

        for _, statKey in ipairs( statKeys ) do
            table.insert( compared[statKey], tonumber( stats[statKey] ) or 0 )
        end
    end

    local output = {}
    for _, statKey in ipairs( statKeys ) do
        local values = compared[statKey]
        table.sort( values, function( a, b ) return a > b end )

        local rank = 1
        local currentValue = tonumber( currentStats[statKey] ) or 0
        for i, value in ipairs( values ) do
            if( value == currentValue ) then
                rank = i
                break
            end
        end

        local total = math.max( #values, 1 )
        local percentile = math.Round( (1-((rank-1)/total))*100, 2 )

        output[statKey] = {
            Rank = rank,
            Total = total,
            Percentile = percentile
        }
    end

    return output
end

local function brsClamp( value, minValue, maxValue )
    if( value < minValue ) then return minValue end
    if( value > maxValue ) then return maxValue end

    return value
end

-- Maps a 1-100 roll into a gameplay scalar range.
function BRICKS_SERVER.UNBOXING.Func.GetStatTrakStatScalar( statKey, statValue )
    local statTrakConfig = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
    local effectConfig = (statTrakConfig.StatEffects or {})[statKey or ""]
    if( not effectConfig ) then return 1 end

    local minScale = tonumber( effectConfig.MinScale ) or 1
    local maxScale = tonumber( effectConfig.MaxScale ) or 1
    local normalized = brsClamp( (tonumber( statValue ) or 0), 1, 100 )
    normalized = (normalized-1)/99

    return minScale+((maxScale-minScale)*normalized)
end

-- Reads equipped weapon stat metadata and returns effective gameplay scalars.
function BRICKS_SERVER.UNBOXING.Func.GetEquippedWeaponStatScalars( ply, weaponClass )
    if( not IsValid( ply ) or not weaponClass ) then return nil end

    local inventory = ply:GetUnboxingInventory()
    local inventoryData = ply:GetUnboxingInventoryData()

    for globalKey, itemData in pairs( inventoryData ) do
        if( not inventory[globalKey] or not itemData.Equipped or not string.StartWith( globalKey, "ITEM_" ) ) then continue end

        local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[tonumber( string.Replace( globalKey, "ITEM_", "" ) )]
        if( not configItemTable ) then continue end

        local itemType = configItemTable.Type or ""
        if( itemType != "Weapon" and itemType != "PermWeapon" ) then continue end
        if( (configItemTable.ReqInfo or {})[1] != weaponClass ) then continue end

        local roll = BRICKS_SERVER.UNBOXING.Func.GetStatTrakSummary( ply, globalKey )
        local stats = (roll and roll.Stats) or {}

        return {
            DamageScale = BRICKS_SERVER.UNBOXING.Func.GetStatTrakStatScalar( "DamageScale", stats.DMG ),
            AccuracySpreadScale = BRICKS_SERVER.UNBOXING.Func.GetStatTrakStatScalar( "AccuracySpreadScale", stats.ACC ),
            ControlMoveSpreadScale = BRICKS_SERVER.UNBOXING.Func.GetStatTrakStatScalar( "ControlMoveSpreadScale", stats.CTRL ),
            HandlingFireDelayScale = BRICKS_SERVER.UNBOXING.Func.GetStatTrakStatScalar( "HandlingFireDelayScale", stats.HND ),
            MobilitySpreadScale = BRICKS_SERVER.UNBOXING.Func.GetStatTrakStatScalar( "MobilitySpreadScale", stats.MOV ),
            Roll = roll,
            GlobalKey = globalKey
        }
    end

    return nil
end

function BRICKS_SERVER.UNBOXING.Func.UnpackItemsTable( itemsTable )
	local unpackTable = {}

	for k, v in pairs( itemsTable ) do
		table.insert( unpackTable, k )
		table.insert( unpackTable, v )
	end

	return unpack( unpackTable )
end

-- Currencies --
function BRICKS_SERVER.UNBOXING.Func.CanAffordCurrency( ply, amount, currency )
	if( currency and BRICKS_SERVER.DEVCONFIG.Currencies[currency] ) then
		return BRICKS_SERVER.DEVCONFIG.Currencies[currency].getFunction( ply ) >= amount
	else
		return BRICKS_SERVER.DEVCONFIG.Currencies[BRICKS_SERVER.UNBOXING.LUACFG.DefaultCurrency].getFunction( ply ) >= amount
	end
end

function BRICKS_SERVER.UNBOXING.Func.FormatCurrency( amount, currency )
	if( currency and BRICKS_SERVER.DEVCONFIG.Currencies[currency] ) then
		return BRICKS_SERVER.DEVCONFIG.Currencies[currency].formatFunction( amount )
	else
		return BRICKS_SERVER.DEVCONFIG.Currencies[BRICKS_SERVER.UNBOXING.LUACFG.DefaultCurrency].formatFunction( amount )
	end
end
