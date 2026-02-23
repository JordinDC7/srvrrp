-- GANGS --
if( not sql.TableExists( "bricks_server_gangs" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_gangs ( 
		gangID int NOT NULL UNIQUE, 
		gangName varchar(30), 
		gangIcon varchar(200), 
		owner varchar(20), 
		members TEXT, 
		money int, 
		level int, 
		experience bigint,
		storage TEXT, 
		roles TEXT, 
		upgrades TEXT, 
		achievements TEXT
	); ]] )
end

print( "[BricksServer SQLLite] bricks_server_gangs table validated!" )

function BRICKS_SERVER.Func.InsertGangDB( gangID, gangName, gangIcon, owner, members, roles, func )
	local query = sql.Query( [[ INSERT INTO bricks_server_gangs (gangID, gangName, gangIcon, owner, members, roles)
		VALUES( ]] .. gangID .. [[, ]] .. sql.SQLStr( gangName ) .. [[, ]] .. sql.SQLStr( gangIcon ) .. [[, ]] .. sql.SQLStr( owner ) .. [[, ]] .. sql.SQLStr( util.TableToJSON( members ) ) .. [[, ]] .. sql.SQLStr( util.TableToJSON( roles ) ) .. [[
	); ]])
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	elseif( func ) then
		func()
	end
end

function BRICKS_SERVER.Func.UpdateGangDB( gangID, key, value )
	local query = sql.Query( "UPDATE bricks_server_gangs SET " .. key .. " = " .. sql.SQLStr( value ) .. " WHERE gangID = '" .. gangID .. "';" )
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.FetchGangsDB( func )
	local query = sql.Query( "SELECT * FROM bricks_server_gangs")
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end

-- INBOX --
if( not sql.TableExists( "bricks_server_inboxes" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_inboxes ( 
		receiverSteamID varchar(20), 
		receiverGangID int, 
		inboxKey int NOT NULL,
		time int, 
		type TEXT, 
		reqInfo TEXT
	); ]] )
end

print( "[BricksServer SQLLite] bricks_server_inboxes table validated!" )

function BRICKS_SERVER.Func.InsertInboxDB( receiverSteamID, receiverGangID, inboxKey, time, type, reqInfo )
	local query = sql.Query( [[ INSERT INTO bricks_server_inboxes (]] .. ((receiverSteamID and "receiverSteamID") or "receiverGangID") .. [[, inboxKey, time, type, reqInfo)
		VALUES( ]] .. sql.SQLStr( receiverSteamID or receiverGangID ) .. [[, ]] .. inboxKey .. [[, ]] .. time .. [[, ]] .. sql.SQLStr( type ) .. [[, ]] .. sql.SQLStr( util.TableToJSON( reqInfo ) ) .. [[
	); ]])
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.DeleteInboxDB( receiverSteamID, receiverGangID, inboxKey )
	local query = sql.Query( "DELETE FROM bricks_server_inboxes WHERE " .. ((receiverSteamID and "receiverSteamID") or "receiverGangID") .. " = " .. sql.SQLStr( receiverSteamID or receiverGangID ) .. " AND inboxKey = '" .. inboxKey .. "';" )
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.FetchInboxDB( func )
	local query = sql.Query( "SELECT * FROM bricks_server_inboxes")
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end

-- ASSOCIATIONS --
if( not sql.TableExists( "bricks_server_associations" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_associations ( 
		gang1ID int NOT NULL, 
		gang2ID int NOT NULL, 
		associationType TEXT
	); ]] )
end

print( "[BricksServer SQLLite] bricks_server_associations table validated!" )

function BRICKS_SERVER.Func.InsertAssociationDB( gang1ID, gang2ID, associationType )
	local query = sql.Query( [[ INSERT INTO bricks_server_associations (gang1ID, gang2ID, associationType)
		VALUES( ]] .. gang1ID .. [[, ]] .. gang2ID .. [[, ]] .. sql.SQLStr( associationType ) .. [[
	); ]])
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.UpdateAssociationDB( gang1ID, gang2ID, associationType )
	local query = sql.Query( "UPDATE bricks_server_associations SET associationType = " .. sql.SQLStr( associationType ) .. " WHERE gang1ID = '" .. gang1ID .. "' AND gang2ID = '" .. gang2ID .. "';" )
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.DeleteAssociationDB( gang1ID, gang2ID )
	local query = sql.Query( "DELETE FROM bricks_server_associations WHERE gang1ID = '" .. gang1ID .. "' AND gang2ID = '" .. gang2ID .. "';" )
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.FetchAssociationsDB( func )
	local query = sql.Query( "SELECT * FROM bricks_server_associations")
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end

-- PRINTERS --
if( not sql.TableExists( "bricks_server_gangprinters" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_gangprinters ( 
		gangID int NOT NULL, 
		printerID int NOT NULL, 
		servers TEXT,
		upgrades TEXT
	); ]] )
end

print( "[BricksServer SQLLite] bricks_server_gangprinters table validated!" )

function BRICKS_SERVER.Func.InsertGangPrinterDB( gangID, printerID, servers, upgrades )
	local query = sql.Query( [[ INSERT INTO bricks_server_gangprinters (gangID, printerID, servers, upgrades)
		VALUES( ]] .. gangID .. [[, ]] .. printerID .. [[, ]] .. sql.SQLStr( util.TableToJSON( servers or {} ) ) .. [[, ]] .. sql.SQLStr( util.TableToJSON( upgrades or {} ) ) .. [[
	); ]])
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.UpdateGangPrinterDB( gangID, printerID, servers, upgrades )
	local query = sql.Query( "UPDATE bricks_server_gangprinters SET " .. ((servers and "servers") or "upgrades") .. " = " .. sql.SQLStr( util.TableToJSON( servers or upgrades ) ) .. " WHERE gangID = '" .. gangID .. "' AND printerID = '" .. printerID .. "';" )
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.DeleteGangPrinterDB( gangID, printerID )
	local query = sql.Query( "DELETE FROM bricks_server_gangprinters WHERE gangID = '" .. gangID .. "' AND printerID = '" .. printerID .. "';" )
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.FetchGangPrinterDB( func )
	local query = sql.Query( "SELECT * FROM bricks_server_gangprinters" )
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end

-- CLEAR GANG FROM DATABASE --
function BRICKS_SERVER.Func.ClearGangFromDB( gangID )
	local queryGang = sql.Query( "DELETE FROM bricks_server_gangs WHERE gangID = '" .. gangID .. "';" )
	if( queryGang == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
	
	local queryInbox = sql.Query( "DELETE FROM bricks_server_inboxes WHERE receiverGangID = '" .. gangID .. "';" )
	if( queryInbox == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
	
	local queryAssociation = sql.Query( "DELETE FROM bricks_server_associations WHERE gang1ID = '" .. gangID .. "' OR gang2ID = '" .. gangID .. "';" )
	if( queryAssociation == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end

	local queryPrinters = sql.Query( "DELETE FROM bricks_server_gangprinters WHERE gangID = '" .. gangID .. "';" )
	if( queryPrinters == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end