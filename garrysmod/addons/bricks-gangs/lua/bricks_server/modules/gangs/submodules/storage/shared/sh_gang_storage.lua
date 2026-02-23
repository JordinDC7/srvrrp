function BRICKS_SERVER.Func.GangIsStorageFull( gangID, amount, canStack )
    local gangStorage = ((BRICKS_SERVER_GANGS or {})[gangID] or {}).Storage or {}

    local storageCount = table.Count( gangStorage )
	if( not canStack ) then
		if( storageCount+amount > BRICKS_SERVER.Func.GangGetUpgradeInfo( gangID, "StorageSlots" )[1] ) then 
			return true
		end
	else
		local newStacks = amount/(BRICKS_SERVER.CONFIG.GANGS["Max Storage Item Stack"] or 10)
		if( storageCount+newStacks > BRICKS_SERVER.Func.GangGetUpgradeInfo( gangID, "StorageSlots" )[1] ) then 
			return true
		end
	end

	return false
end

function BRICKS_SERVER.Func.GangGetStorageCount( gangID )
    if( not BRICKS_SERVER_GANGS or not gangID ) then return 0 end

    local gangTable = BRICKS_SERVER_GANGS[gangID]

    if( not gangTable or not gangTable.Storage ) then return 0 end

    local itemCount = 0
    for k, v in pairs( gangTable.Storage ) do
        itemCount = itemCount+(v[1] or 0)
    end

    return itemCount
end