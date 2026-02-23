hook.Add( "Initialize", "BricksServerHooks_Initialize_GangInbox", function()	
    BRS_GANG_INBOXES = {}
    BRICKS_SERVER.Func.FetchInboxDB( function( data )
		for k, v in pairs( data ) do
			if( not v.inboxKey ) then continue end

			local key
			if( v.receiverSteamID and v.receiverSteamID != "NULL" ) then
				key = v.receiverSteamID
			elseif( v.receiverGangID and v.receiverGangID != "NULL" ) then
				key = tonumber( v.receiverGangID )
			else
				continue
			end
			
			if( not BRS_GANG_INBOXES[key] ) then
				BRS_GANG_INBOXES[key] = {}
			end

			BRS_GANG_INBOXES[key][tonumber( v.inboxKey or 0 )] = {
				Time = tonumber( v.time or 0 ),
				Type = (v.type or ""),
				ReqInfo = util.JSONToTable( v.reqInfo or "" )
			}
        end
    end )
end )

util.AddNetworkString( "BRS.Net.SendGangInbox" )
function BRICKS_SERVER.Func.SendGangInbox( ply )
	if( not BRS_GANG_INBOXES ) then return end

	local inboxTable = {}
	if( BRS_GANG_INBOXES and BRS_GANG_INBOXES[ply:SteamID()] ) then
		inboxTable[ply:SteamID()] = BRS_GANG_INBOXES[ply:SteamID()]
	end

	local gangID = ply:HasGang()
	if( gangID and BRS_GANG_INBOXES[gangID] ) then
		inboxTable[gangID] = BRS_GANG_INBOXES[gangID]
	end

	net.Start( "BRS.Net.SendGangInbox" )
		net.WriteTable( inboxTable )
	net.Send( ply )
end

hook.Add( "BRS.Hooks.PlayerGangInitialize", "BricksServerHooks_BRS_PlayerGangInitialize_GangInbox", function( ply )
	BRICKS_SERVER.Func.SendGangInbox( ply )
end )

util.AddNetworkString( "BRS.Net.SendGangInboxEntry" )
function BRICKS_SERVER.Func.AddGangInboxEntry( ReceiverSteamID, ReceiverGangID, Type, ReqInfo )
	if( not BRS_GANG_INBOXES ) then
		BRS_GANG_INBOXES = {}
	end

	local key
	if( ReceiverSteamID ) then
		key = ReceiverSteamID
	elseif( ReceiverGangID ) then
		key = ReceiverGangID
	end

	if( not key ) then return end

	if( not BRS_GANG_INBOXES[key] ) then
		BRS_GANG_INBOXES[key] = {}
	end

	local inboxEntry = {
		Time = os.time(),
		Type = Type,
		ReqInfo = ReqInfo
	}

	local inboxKey = table.insert( BRS_GANG_INBOXES[key], inboxEntry )

	if( ReceiverSteamID ) then
		local ply = player.GetBySteamID( ReceiverSteamID )

		if( IsValid( ply ) ) then
			net.Start( "BRS.Net.SendGangInboxEntry" )
				net.WriteString( key )
				net.WriteUInt( inboxKey, 16 )
				net.WriteTable( inboxEntry )
			net.Send( ply )
		end
	elseif( ReceiverGangID and BRICKS_SERVER_GANGS[ReceiverGangID] ) then
        local onlineMembers = {}
        for k, v in pairs( BRICKS_SERVER_GANGS[ReceiverGangID].Members or {} ) do
            local ply = player.GetBySteamID( k )

            if( IsValid( ply ) ) then
                table.insert( onlineMembers, ply )
            end
		end
		
		if( #onlineMembers > 0 ) then
			net.Start( "BRS.Net.SendGangInboxEntry" )
				net.WriteString( key )
				net.WriteUInt( inboxKey, 16 )
				net.WriteTable( inboxEntry )
			net.Send( onlineMembers )
		end
	end

	BRICKS_SERVER.Func.InsertInboxDB( ReceiverSteamID, ReceiverGangID, inboxKey, inboxEntry.Time, inboxEntry.Type, inboxEntry.ReqInfo )
end

util.AddNetworkString( "BRS.Net.RemoveGangInboxEntry" )
function BRICKS_SERVER.Func.DeleteGangInboxEntry( receiverKey, inboxKey )
	if( not BRS_GANG_INBOXES or not BRS_GANG_INBOXES[receiverKey] or not BRS_GANG_INBOXES[receiverKey][inboxKey] ) then return end

	BRS_GANG_INBOXES[receiverKey][inboxKey] = nil

	if( BRICKS_SERVER_GANGS[receiverKey] ) then
        local onlineMembers = {}
        for k, v in pairs( BRICKS_SERVER_GANGS[receiverKey].Members or {} ) do
            local ply = player.GetBySteamID( k )

            if( IsValid( ply ) ) then
                table.insert( onlineMembers, ply )
            end
		end
		
		if( #onlineMembers > 0 ) then
			net.Start( "BRS.Net.RemoveGangInboxEntry" )
				net.WriteString( receiverKey )
				net.WriteUInt( inboxKey, 16 )
			net.Send( onlineMembers )
		end
	else
		local ply = player.GetBySteamID( receiverKey )

		if( IsValid( ply ) ) then
			net.Start( "BRS.Net.RemoveGangInboxEntry" )
				net.WriteString( receiverKey )
				net.WriteUInt( inboxKey, 16 )
			net.Send( ply )
		end
	end

	local isGangID = BRICKS_SERVER_GANGS[receiverKey]

	BRICKS_SERVER.Func.DeleteInboxDB( (not isGangID and receiverKey), (isGangID and receiverKey), inboxKey )
end

util.AddNetworkString( "BRS.Net.DeleteGangInboxEntry" )
net.Receive( "BRS.Net.DeleteGangInboxEntry", function( len, ply ) 
	local receiverKey = net.ReadString()
	local inboxKey = net.ReadUInt( 16 )

	if( not receiverKey or not inboxKey ) then return end

	if( isnumber( tonumber( receiverKey ) ) ) then
		receiverKey = tonumber( receiverKey )
	end

	if( not BRS_GANG_INBOXES or not BRS_GANG_INBOXES[receiverKey] ) then return end

	if( receiverKey != ply:SteamID() and not ply:GangHasPermission( "EditInbox" ) ) then return end

	BRICKS_SERVER.Func.DeleteGangInboxEntry( receiverKey, inboxKey )
end )