util.AddNetworkString( "BRS.Net.AddGangAdminMail" )
net.Receive( "BRS.Net.AddGangAdminMail", function( len, ply ) 
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local victimSteamID = net.ReadString()
	local header = net.ReadString()
	local body = net.ReadString()

	if( not victimSteamID or not header or not body ) then return end

	local victimEntity = player.GetBySteamID( victimSteamID )

	if( not IsValid( victimEntity ) or not victimEntity:IsPlayer() ) then return end

	BRICKS_SERVER.Func.AddGangInboxEntry( victimSteamID, false, "AdminMail", { header, body } )
	
	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangAdminNotificationSent", victimEntity:Nick() ) )
end )

util.AddNetworkString( "BRS.Net.RequestAdminGangs" )
util.AddNetworkString( "BRS.Net.SendAdminGangTables" )
net.Receive( "BRS.Net.RequestAdminGangs", function( len, ply ) 
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local searchString = net.ReadString()

	local sortedGangs = {}
	for k, v in pairs( BRICKS_SERVER_GANGS ) do
		if( #sortedGangs >= BRICKS_SERVER.CONFIG.GANGS["Gang Display Limit"] ) then break end

		if( (searchString != "" and not string.find( string.lower( v.Name or "" ), string.lower( searchString ) )) ) then
			continue
		end

		sortedGangs[k] = {
			Name = v.Name,
			Icon = v.Icon,
			MemberCount = table.Count( v.Members or {} ),
			MemberMax = BRICKS_SERVER.Func.GangGetUpgradeInfo( k, "MaxMembers" )[1]
		}
	end

	net.Start( "BRS.Net.SendAdminGangTables" )
		net.WriteTable( sortedGangs )
	net.Send( ply )
end )

util.AddNetworkString( "BRS.Net.RequestAdminGangData" )
util.AddNetworkString( "BRS.Net.SendAdminGangData" )
net.Receive( "BRS.Net.RequestAdminGangData", function( len, ply ) 
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local gangID = net.ReadUInt( 16 )

	net.Start( "BRS.Net.SendAdminGangData" )
		net.WriteUInt( gangID, 16 )
		net.WriteTable( BRICKS_SERVER_GANGS[gangID] or {} )
	net.Send( ply )
end )

util.AddNetworkString( "BRS.Net.AdminGangCMD" )
net.Receive( "BRS.Net.AdminGangCMD", function( len, ply ) 
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local cmdKey = net.ReadUInt( 8 )

	if( not cmdKey or not BRICKS_SERVER.DEVCONFIG.GangAdminCmds[cmdKey] ) then return end

	local gangID = net.ReadUInt( 16 )

	if( not gangID or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

	local reqInfo = net.ReadTable()

	if( not reqInfo ) then return end

	local devConfig = BRICKS_SERVER.DEVCONFIG.GangAdminCmds[cmdKey]

	local message = devConfig.ServerFunc( BRICKS_SERVER_GANGS[gangID], gangID, reqInfo )

	if( message ) then
		DarkRP.notify( ply, 1, 5, message )
	end

	net.Start( "BRS.Net.SendAdminGangData" )
		net.WriteUInt( gangID, 16 )
		net.WriteTable( BRICKS_SERVER_GANGS[gangID] or {} )
	net.Send( ply )
end )