BRS_GANGSTORAGE_QUEUE = {}
function BRICKS_SERVER.Func.AddGangStorageItem( gangID, amount, itemData )
	if( not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

	if( not BRS_GANGSTORAGE_QUEUE ) then
		BRS_GANGSTORAGE_QUEUE = {}
	end

	if( not BRS_GANGSTORAGE_QUEUE[gangID] ) then
		BRS_GANGSTORAGE_QUEUE[gangID] = {}
	end

	table.insert( BRS_GANGSTORAGE_QUEUE[gangID], { amount, itemData } )
end

hook.Add( "Think", "BricksServerHooks_Think_GangStorage", function()
	if( not BRS_GANGSTORAGE_QUEUE ) then return end

	for gangID, items in pairs( BRS_GANGSTORAGE_QUEUE ) do 
		if( not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then
			BRS_GANGSTORAGE_QUEUE[gangID] = nil
			continue
		end

		for key, val in pairs( items ) do 
			local gangStorage = BRICKS_SERVER_GANGS[gangID].Storage or {}

			local maxSlots = BRICKS_SERVER.Func.GangGetUpgradeInfo( gangID, "StorageSlots" )[1]

			if( table.Count( gangStorage ) >= maxSlots ) then
				BRS_GANGSTORAGE_QUEUE[gangID] = nil
				break
			end

			local itemAmount, itemData = val[1], val[2]
	
			for i = 1, maxSlots do
				if( gangStorage[i] and (gangStorage[i][1] or 1) >= BRICKS_SERVER.CONFIG.GANGS["Max Storage Item Stack"] ) then continue end
	
				if( gangStorage[i] ) then
					local canCombine = false
					if( BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).CanCombine ) then
						canCombine = BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).CanCombine( itemData, (gangStorage[i][2] or {}) )
					else
						canCombine = BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs.CanCombine( itemData, (gangStorage[i][2] or {}) )
					end
		
					if( canCombine ) then
						local currentItemAmount = gangStorage[i][1] or 1

						gangStorage[i][1] = math.Clamp( currentItemAmount+itemAmount, 1, BRICKS_SERVER.CONFIG.GANGS["Max Storage Item Stack"] )
						BRICKS_SERVER.Func.UpdateGangTable( gangID, "Storage", gangStorage )
						hook.Run( "BRS.Hooks.GangStorageChanged", gangID, BRICKS_SERVER.Func.GangGetStorageCount( gangID ) )
	
						table.remove( BRS_GANGSTORAGE_QUEUE[gangID], key )

						if( currentItemAmount+itemAmount > BRICKS_SERVER.CONFIG.GANGS["Max Storage Item Stack"] ) then
							BRICKS_SERVER.Func.AddGangStorageItem( gangID, currentItemAmount+itemAmount-BRICKS_SERVER.CONFIG.GANGS["Max Storage Item Stack"], itemData )
						end
						break
					end
				else
					gangStorage[i] = { math.Clamp( (itemAmount or 1), 1, BRICKS_SERVER.CONFIG.GANGS["Max Storage Item Stack"] ), itemData }
					BRICKS_SERVER.Func.UpdateGangTable( gangID, "Storage", gangStorage )
					hook.Run( "BRS.Hooks.GangStorageChanged", gangID, BRICKS_SERVER.Func.GangGetStorageCount( gangID ) )
	
					table.remove( BRS_GANGSTORAGE_QUEUE[gangID], key )
	
					if( itemAmount > BRICKS_SERVER.CONFIG.GANGS["Max Storage Item Stack"] ) then
						BRICKS_SERVER.Func.AddGangStorageItem( gangID, itemAmount-BRICKS_SERVER.CONFIG.GANGS["Max Storage Item Stack"], itemData )
					end
					break
				end
			end
		end
	end
end )

util.AddNetworkString( "BRS.Net.GangDepositLoadout" )
net.Receive( "BRS.Net.GangDepositLoadout", function( len, ply ) 
	local weaponClass = net.ReadString()

	if( not weaponClass or not ply:HasWeapon( weaponClass ) ) then return end

	local weapon = ply:GetWeapon( weaponClass )

	if( not IsValid( weapon ) ) then return end

	local canDrop = hook.Run( "canDropWeapon", ply, weapon )

	if( not canDrop or weapon:GetClass() == "bricks_server_invpickup" ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangCannotDeposit" ) )
		return
	end

	if( not ply:GangHasPermission( "DepositItem" ) ) then return end

	if( not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[ply:GetGangID() or 0] ) then return end

	local weapon = ply:GetWeapon( weaponClass )
	
	if( not IsValid( weapon ) ) then return end

	local storageFull = BRICKS_SERVER.Func.GangIsStorageFull( ply:GetGangID(), 1, true )
	if( storageFull ) then 
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangStorageFullError" ) )
		return
	end

	BRICKS_SERVER.Func.AddGangStorageItem( ply:GetGangID(), 1, { "spawned_weapon", weapon:GetModel(), weaponClass } )

	ply:StripWeapon( weaponClass )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangDepositedItem" ) )
end )

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) ) then
	util.AddNetworkString( "BRS.Net.GangDepositInventory" )
	net.Receive( "BRS.Net.GangDepositInventory", function( len, ply ) 
		local itemKey = net.ReadUInt( 10 )
		
		if( not itemKey ) then return end

		if( not ply:GangHasPermission( "DepositItem" ) ) then return end

		if( not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[ply:GetGangID()] ) then return end

		local inventoryTable = ply:BRS():GetInventory()
		
		if( inventoryTable[itemKey] ) then
			local itemTable = inventoryTable[itemKey]

			if( BRICKS_SERVER.Func.GangIsStorageFull( ply:GetGangID(), (itemTable[1] or 1), true ) ) then 
				DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangStorageFull" ) )
				return
			end

			inventoryTable[itemKey] = nil

			ply:BRS():SetInventory( inventoryTable )

			BRICKS_SERVER.Func.AddGangStorageItem( ply:GetGangID(), (itemTable[1] or 1), (itemTable[2] or {}) )

			DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangDepositedItem" ) )
		end
	end )
end

util.AddNetworkString( "BRS.Net.GangStorageDrop" )
net.Receive( "BRS.Net.GangStorageDrop", function( len, ply ) 
	local amount = net.ReadUInt( 8 )
	local itemKey = net.ReadUInt( 10 )
	
	if( not amount or not itemKey ) then return end

	if( not ply:GangHasPermission( "WithdrawItem" ) ) then return end

	if( not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[ply:GetGangID()] ) then return end

	local gangStorage = BRICKS_SERVER_GANGS[ply:GetGangID()].Storage or {}
	
	if( not gangStorage[itemKey] ) then return end

	local itemTable = gangStorage[itemKey]
	local itemData = itemTable[2] or {}
	local placePos = ply:GetPos()+( ply:GetForward()*30 )+Vector( 0, 0, 20 )

	if( not BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).CanDropMultiple ) then
		if( amount > 1 ) then return end
	else
		if( amount > (itemTable[1] or 1) ) then return end
	end

	if( BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).OnSpawn ) then
		BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).OnSpawn( ply, placePos, itemData, amount )
	else
		BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs.OnSpawn( ply, placePos, itemData, amount )
	end

	if( (itemTable[1] or 1) > amount ) then
		itemTable[1] = math.Clamp( itemTable[1]-amount, 1, (BRICKS_SERVER.CONFIG.GANGS["Max Storage Item Stack"] or 10) )
	else
		gangStorage[itemKey] = nil
	end

	BRICKS_SERVER.Func.UpdateGangTable( ply:GetGangID(), "Storage", gangStorage )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangDroppedItem" ) )
end )

util.AddNetworkString( "BRS.Net.GangStorageUse" )
net.Receive( "BRS.Net.GangStorageUse", function( len, ply ) 
	local itemKey = net.ReadUInt( 10 )
	
	if( not itemKey ) then return end

	if( not ply:GangHasPermission( "WithdrawItem" ) ) then return end

	if( not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[ply:GetGangID()] ) then return end

	local gangStorage = BRICKS_SERVER_GANGS[ply:GetGangID()].Storage or {}
	
	if( not gangStorage[itemKey] ) then return end

	local preventUse, errorMessage = hook.Run( "BRS.Hooks.GangStorageCanUse", ply, itemKey )

	if( not preventUse ) then
		local itemTable = gangStorage[itemKey]
		local itemData = itemTable[2] or {}

		if( BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).OnUse ) then
			BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).OnUse( ply, itemData )
		end

		if( (itemTable[1] or 1) > 1 ) then
			itemTable[1] = math.Clamp( itemTable[1]-1, 1, (BRICKS_SERVER.CONFIG.GANGS["Max Storage Item Stack"] or 10) )
		else
			gangStorage[itemKey] = nil
		end

		BRICKS_SERVER.Func.UpdateGangTable( ply:GetGangID(), "Storage", gangStorage )

		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangUsedItem" ) )
	else
		DarkRP.notify( ply, 1, 5, errorMessage or BRICKS_SERVER.Func.L( "gangCantUse" ) )
	end
end )