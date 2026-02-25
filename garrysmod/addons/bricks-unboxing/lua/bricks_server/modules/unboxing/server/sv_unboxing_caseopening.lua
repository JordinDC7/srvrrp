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