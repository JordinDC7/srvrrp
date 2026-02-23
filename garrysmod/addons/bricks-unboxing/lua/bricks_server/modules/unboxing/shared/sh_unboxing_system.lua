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