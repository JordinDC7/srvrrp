hook.Add( "Initialize", "BricksServerHooks_Initialize_GangAssociations", function()	
    BRICKS_SERVER_ASSOCIATIONS = {}
    BRICKS_SERVER.Func.FetchAssociationsDB( function( data )
		for k, v in pairs( data ) do
			local gang1ID = tonumber( v.gang1ID )
			local gang2ID = tonumber( v.gang2ID )
			
			if( not BRICKS_SERVER_ASSOCIATIONS[gang1ID] ) then
				BRICKS_SERVER_ASSOCIATIONS[gang1ID] = {}
			end

            BRICKS_SERVER_ASSOCIATIONS[gang1ID][gang2ID] = v.associationType
        end
    end )
end )

util.AddNetworkString( "BRS.Net.SendGangAssociations" )
function BRICKS_SERVER.Func.SendGangAssociations( ply )
	local gangID = ply:HasGang()

	if( not gangID or not BRS_GANG_ASSOCIATIONS ) then return end

    local associationsTable = {}
   
	if( BRS_GANG_ASSOCIATIONS[gangID] ) then
		associationsTable[gangID] = BRS_GANG_ASSOCIATIONS[gangID]
	end

	for k, v in pairs( BRS_GANG_ASSOCIATIONS ) do
		if( v[gangID] ) then
			associationsTable[k] = {}
			associationsTable[k][gangID] = v[gangID]
		end
	end

	net.Start( "BRS.Net.SendGangAssociations" )
		net.WriteTable( associationsTable )
	net.Send( ply )
end

hook.Add( "BRS.Hooks.PlayerGangInitialize", "BricksServerHooks_BRS_PlayerGangInitialize_GangAssociations", BRICKS_SERVER.Func.SendGangAssociations )

util.AddNetworkString( "BRS.Net.SendGangAssociationValue" )
function BRICKS_SERVER.Func.GangsSetAssociation( gang1ID, gang2ID, associationType )
	if( not BRICKS_SERVER_GANGS[gang1ID] or not BRICKS_SERVER_GANGS[gang2ID] ) then return end

	if( not BRS_GANG_ASSOCIATIONS ) then
		BRS_GANG_ASSOCIATIONS = {}
	end

	if( associationType ) then
		if( BRS_GANG_ASSOCIATIONS[gang2ID] and BRS_GANG_ASSOCIATIONS[gang2ID][gang1ID] ) then
			BRS_GANG_ASSOCIATIONS[gang2ID][gang1ID] = nil
			
			BRICKS_SERVER.Func.DeleteAssociationDB( gang2ID, gang1ID )
		end

		if( not BRS_GANG_ASSOCIATIONS[gang1ID] ) then
			BRS_GANG_ASSOCIATIONS[gang1ID] = {}
		end
	
		if( not BRS_GANG_ASSOCIATIONS[gang1ID][gang2ID] ) then
			BRICKS_SERVER.Func.InsertAssociationDB( gang1ID, gang2ID, associationType )
		else
			BRICKS_SERVER.Func.UpdateAssociationDB( gang1ID, gang2ID, associationType )
		end
	
		BRS_GANG_ASSOCIATIONS[gang1ID][gang2ID] = associationType

		BRICKS_SERVER.Func.AddGangInboxEntry( false, gang1ID, "AssociationCreated", { gang2ID, (BRICKS_SERVER_GANGS[gang2ID].Name or BRICKS_SERVER.Func.L( "nil" )), associationType } )
		BRICKS_SERVER.Func.AddGangInboxEntry( false, gang2ID, "AssociationCreated", { gang1ID, (BRICKS_SERVER_GANGS[gang1ID].Name or BRICKS_SERVER.Func.L( "nil" )), associationType } )
	else
		if( BRS_GANG_ASSOCIATIONS[gang2ID] and BRS_GANG_ASSOCIATIONS[gang2ID][gang1ID] ) then
			BRS_GANG_ASSOCIATIONS[gang2ID][gang1ID] = nil
			
			BRICKS_SERVER.Func.DeleteAssociationDB( gang2ID, gang1ID )
		end

		if( BRS_GANG_ASSOCIATIONS[gang1ID] and BRS_GANG_ASSOCIATIONS[gang1ID][gang2ID] ) then
			BRS_GANG_ASSOCIATIONS[gang1ID][gang2ID] = nil
			
			BRICKS_SERVER.Func.DeleteAssociationDB( gang1ID, gang2ID )
		end

		BRICKS_SERVER.Func.AddGangInboxEntry( false, gang1ID, "AssociationDissolved", { gang2ID, (BRICKS_SERVER_GANGS[gang2ID].Name or BRICKS_SERVER.Func.L( "nil" )) } )
		BRICKS_SERVER.Func.AddGangInboxEntry( false, gang2ID, "AssociationDissolved", { gang1ID, (BRICKS_SERVER_GANGS[gang1ID].Name or BRICKS_SERVER.Func.L( "nil" )) } )
	end

	local onlineMembers = {}
	local members = table.Merge( table.Copy( BRICKS_SERVER_GANGS[gang1ID].Members or {} ), BRICKS_SERVER_GANGS[gang2ID].Members or {} )
	for k, v in pairs( members ) do
		local ply = player.GetBySteamID( k )

		if( IsValid( ply ) ) then
			table.insert( onlineMembers, ply )
		end
	end
	
	if( #onlineMembers > 0 ) then
		net.Start( "BRS.Net.SendGangAssociationValue" )
			net.WriteUInt( gang1ID, 16 )
			net.WriteUInt( gang2ID, 16 )
			net.WriteString( associationType or "" )
		net.Send( onlineMembers )
	end
end

util.AddNetworkString( "BRS.Net.RequestAssociationGangs" )
util.AddNetworkString( "BRS.Net.SendAssociationGangTables" )
net.Receive( "BRS.Net.RequestAssociationGangs", function( len, ply ) 
    if( (ply.BRS_REQUEST_ASSOCIATIONGANG_COOLDOWN or 0) > CurTime() ) then return end
    
    ply.BRS_REQUEST_ASSOCIATIONGANG_COOLDOWN = CurTime()+3

	local searchString = net.ReadString()

	local sortedGangs = {}
    for k, v in pairs( BRICKS_SERVER_GANGS ) do
        if( #sortedGangs >= BRICKS_SERVER.CONFIG.GANGS["Gang Display Limit"] ) then break end
		
        if( ply:GetGangID() == k ) then continue end

		if( (searchString != "" and not string.find( string.lower( v.Name or "" ), string.lower( searchString ) )) ) then
			continue
		end

		sortedGangs[k] = {
			Name = v.Name,
			Icon = v.Icon
		}
	end

	net.Start( "BRS.Net.SendAssociationGangTables" )
		net.WriteTable( sortedGangs )
	net.Send( ply )
end )

util.AddNetworkString( "BRS.Net.RequestGangAssociation" )
net.Receive( "BRS.Net.RequestGangAssociation", function( len, ply ) 
	local firstGang = ply:HasGang()

	if( not firstGang or not ply:GangHasPermission( "RequestAssociations" ) ) then return end

	local associationType = net.ReadString()

	if( not associationType or not BRICKS_SERVER.DEVCONFIG.GangAssociationTypes[associationType or ""] ) then return end

	local secondGang = net.ReadUInt( 16 )

	if( not secondGang or not BRICKS_SERVER_GANGS[secondGang] ) then return end

	local currentAssociation = BRICKS_SERVER.Func.GangsGetAssociation( firstGang, secondGang )

	if( currentAssociation and currentAssociation == associationType ) then 
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangAlreadyAssociation" ) )
		return 
	end

	if( BRICKS_SERVER.Func.GangHasAssociationInvite( secondGang, firstGang ) ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangAlreadySentAssociation" ) )
		return 
	end

	local gangName = BRICKS_SERVER_GANGS[firstGang].Name or BRICKS_SERVER.Func.L( "gangNew" )

	BRICKS_SERVER.Func.AddGangInboxEntry( false, secondGang, "AssociationInvite", { ply:GetGangID(), gangName, associationType } )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangAssociationSent" ) )
end )

util.AddNetworkString( "BRS.Net.AcceptGangAssociation" )
net.Receive( "BRS.Net.AcceptGangAssociation", function( len, ply ) 
	local toGangID = ply:HasGang()

	if( not toGangID or not ply:GangHasPermission( "AcceptAssociations" ) ) then return end

	local gangID = net.ReadUInt( 16 )

	if( not gangID or not BRICKS_SERVER_GANGS[gangID] ) then return end

	local inboxKey = BRICKS_SERVER.Func.GangHasAssociationInvite( toGangID, gangID )

	if( not inboxKey ) then return end

	local inboxReqInfo = BRICKS_SERVER.Func.GangGetInboxReqInfo( toGangID, inboxKey )

	BRICKS_SERVER.Func.DeleteGangInboxEntry( toGangID, inboxKey )

	BRICKS_SERVER.Func.GangsSetAssociation( gangID, toGangID, inboxReqInfo[3] )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangAssociationAccepted" ) )
end )

util.AddNetworkString( "BRS.Net.DissolveGangAssociation" )
net.Receive( "BRS.Net.DissolveGangAssociation", function( len, ply ) 
	local gang1ID = ply:HasGang()

	if( not gang1ID or not ply:GangHasPermission( "RequestAssociations" ) ) then return end

	local gang2ID = net.ReadUInt( 16 )

	if( not gang2ID or not BRICKS_SERVER_GANGS[gang2ID] ) then return end

	local currentAssociation = BRICKS_SERVER.Func.GangsGetAssociation( gang1ID, gang2ID )

	if( not currentAssociation ) then 
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangNoAssociation" ) )
		return 
	end

	BRICKS_SERVER.Func.GangsSetAssociation( gang1ID, gang2ID )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangAssociationDissolved" ) )
end )