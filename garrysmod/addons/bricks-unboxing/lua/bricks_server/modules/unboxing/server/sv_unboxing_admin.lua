concommand.Add( "unboxing_additem", function( ply, cmd, args )
	if( (not IsValid( ply ) or BRICKS_SERVER.Func.HasAdminAccess( ply )) and args[1] and args[2] and isstring( args[1] ) and isnumber( tonumber( args[2] ) ) ) then
		local victimSteamID64 = args[1]
		local itemKey = tonumber( args[2] )
		local itemAmount = tonumber( args[3] or 1 )

		local itemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey]
		if( not BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey] ) then return end
	
		local victimEntity = player.GetBySteamID64( victimSteamID64 )
	
		if( not IsValid( victimEntity ) or not victimEntity:IsPlayer() ) then return end
		victimEntity:AddUnboxingInventoryItem( "ITEM_" .. itemKey, itemAmount )
		
		BRICKS_SERVER.Func.SendNotification( victimEntity, 1, 5, BRICKS_SERVER.Func.L( "unboxingAdminAdded", (itemTable.Name or "ERROR") ) )

		if( IsValid( ply ) ) then
			BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingAdminAddedPly", (itemTable.Name or "ERROR") ) )
		end
	end
end )

concommand.Add( "unboxing_addcase", function( ply, cmd, args )
	if( (not IsValid( ply ) or BRICKS_SERVER.Func.HasAdminAccess( ply )) and args[1] and args[2] and isstring( args[1] ) and isnumber( tonumber( args[2] ) ) ) then
		local victimSteamID64 = args[1]
		local itemKey = tonumber( args[2] )
		local itemAmount = tonumber( args[3] or 1 )

		local itemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[itemKey]
		if( not BRICKS_SERVER.CONFIG.UNBOXING.Cases[itemKey] ) then return end
	
		local victimEntity = player.GetBySteamID64( victimSteamID64 )
	
		if( not IsValid( victimEntity ) or not victimEntity:IsPlayer() ) then return end
		victimEntity:AddUnboxingInventoryItem( "CASE_" .. itemKey, itemAmount )
		
		BRICKS_SERVER.Func.SendNotification( victimEntity, 1, 5, BRICKS_SERVER.Func.L( "unboxingAdminAdded", (itemTable.Name or "ERROR") ) )

		if( IsValid( ply ) ) then
			BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingAdminAddedPly", (itemTable.Name or "ERROR") ) )
		end
	end
end )

concommand.Add( "unboxing_addkey", function( ply, cmd, args )
	if( (not IsValid( ply ) or BRICKS_SERVER.Func.HasAdminAccess( ply )) and args[1] and args[2] and isstring( args[1] ) and isnumber( tonumber( args[2] ) ) ) then
		local victimSteamID64 = args[1]
		local itemKey = tonumber( args[2] )
		local itemAmount = tonumber( args[3] or 1 )

		local itemTable = BRICKS_SERVER.CONFIG.UNBOXING.Keys[itemKey]
		if( not BRICKS_SERVER.CONFIG.UNBOXING.Keys[itemKey] ) then return end
	
		local victimEntity = player.GetBySteamID64( victimSteamID64 )
	
		if( not IsValid( victimEntity ) or not victimEntity:IsPlayer() ) then return end
		victimEntity:AddUnboxingInventoryItem( "KEY_" .. itemKey, itemAmount )
		
		BRICKS_SERVER.Func.SendNotification( victimEntity, 1, 5, BRICKS_SERVER.Func.L( "unboxingAdminAdded", (itemTable.Name or "ERROR") ) )

		if( IsValid( ply ) ) then
			BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingAdminAddedPly", (itemTable.Name or "ERROR") ) )
		end
	end
end )

local function SendPlayerData( steamID64, ply )
    local player = player.GetBySteamID64( steamID64 )

    if( not IsValid( player ) ) then
        local playerData = {}
        BRICKS_SERVER.UNBOXING.Func.FetchInventoryDB( steamID64, function( data )
            playerData.inventory = util.JSONToTable( (data or {}).inventory or "" )

            BRICKS_SERVER.UNBOXING.Func.FetchStatsDB( steamID64, function( data )
                playerData.stats = data

                net.Start( "BRS.Net.SendUnboxingAdminPlayerData" )
                    net.WriteString( steamID64 )
                    net.WriteTable( playerData )
                net.Send( ply )
            end )
        end )
    else
        local playerData = {}
        playerData.inventory = player:GetUnboxingInventory()
        playerData.stats = player:GetUnboxingStats()

        net.Start( "BRS.Net.SendUnboxingAdminPlayerData" )
            net.WriteString( steamID64 )
            net.WriteTable( playerData )
        net.Send( ply )
    end
end

util.AddNetworkString( "BRS.Net.RequestUnboxingAdminPlayerData" )
util.AddNetworkString( "BRS.Net.SendUnboxingAdminPlayerData" )
net.Receive( "BRS.Net.RequestUnboxingAdminPlayerData", function( len, ply ) 
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

    local steamID64 = net.ReadString()
    if( not steamID64 ) then return end

    SendPlayerData( steamID64, ply )
end )

util.AddNetworkString( "BRS.Net.AdminUnboxingPlayerInventoryChange" )
net.Receive( "BRS.Net.AdminUnboxingPlayerInventoryChange", function( len, ply ) 
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local steamID64 = net.ReadString()
	local globalKey = net.ReadString()
	local amount = net.ReadInt( 32 )

    local player = player.GetBySteamID64( steamID64 )

    if( not IsValid( player ) ) then
        BRICKS_SERVER.UNBOXING.Func.FetchInventoryDB( steamID64, function( data )
            local inventoryTable = util.JSONToTable( (data or {}).inventory or "" ) or {}

            inventoryTable[globalKey] = (inventoryTable[globalKey] or 0)+amount

            if( inventoryTable[globalKey] < 1 ) then
                inventoryTable[globalKey] = nil
            end

            BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB( steamID64, inventoryTable )

            BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingAdminEdited" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )

            SendPlayerData( steamID64, ply )
        end )
    else
        if( amount > 0 ) then
            player:AddUnboxingInventoryItem( globalKey, amount )
        else
            player:RemoveUnboxingInventoryItem( globalKey, math.abs( amount ) )
        end

        BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingAdminEdited" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
        SendPlayerData( steamID64, ply )
    end
end )

concommand.Add( "unboxing_toptier_killswitch", function( ply, _, args )
	if( IsValid( ply ) and not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local enabled = tobool( tonumber( args[1] or 0 ) )
	BRICKS_SERVER.UNBOXING.LUACFG.TopTier = BRICKS_SERVER.UNBOXING.LUACFG.TopTier or {}
	BRICKS_SERVER.UNBOXING.LUACFG.TopTier.LiveOps = BRICKS_SERVER.UNBOXING.LUACFG.TopTier.LiveOps or {}
	BRICKS_SERVER.UNBOXING.LUACFG.TopTier.LiveOps.KillSwitchEnabled = enabled

	BRICKS_SERVER.Func.BRS_MSGN( "unboxing", "Top-tier kill switch set to " .. tostring( enabled ) .. " by " .. (IsValid( ply ) and ply:SteamID64() or "console") )
end )

concommand.Add( "unboxing_toptier_disable_family", function( ply, _, args )
	if( IsValid( ply ) and not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local caseFamily = tostring( args[1] or "" )
	local disabled = tobool( tonumber( args[2] or 1 ) )
	if( caseFamily == "" ) then return end

	BRICKS_SERVER.UNBOXING.LUACFG.TopTier = BRICKS_SERVER.UNBOXING.LUACFG.TopTier or {}
	BRICKS_SERVER.UNBOXING.LUACFG.TopTier.LiveOps = BRICKS_SERVER.UNBOXING.LUACFG.TopTier.LiveOps or {}
	BRICKS_SERVER.UNBOXING.LUACFG.TopTier.LiveOps.DisabledCaseFamilies = BRICKS_SERVER.UNBOXING.LUACFG.TopTier.LiveOps.DisabledCaseFamilies or {}
	BRICKS_SERVER.UNBOXING.LUACFG.TopTier.LiveOps.DisabledCaseFamilies[caseFamily] = disabled and true or nil

	BRICKS_SERVER.Func.BRS_MSGN( "unboxing", "Case family '" .. caseFamily .. "' disabled=" .. tostring( disabled ) .. " by " .. (IsValid( ply ) and ply:SteamID64() or "console") )
end )
