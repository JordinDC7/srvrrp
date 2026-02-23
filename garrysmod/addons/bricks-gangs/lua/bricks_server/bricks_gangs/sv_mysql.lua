local Host = "193.243.190.26"
local Username = "u14547_RCUeG4pFZn"
local Password = "!tMYP+jwxbheds0zmyMhNw1H"
local DatabaseName = "s14547_gangs"
local DatabasePort = 3306

--[[

	DONT TOUCH ANYTHING BELOW THIS LINE!
	
]]--

require( "mysqloo" )

local function ConnectToDatabase()
	bricks_gang_db = mysqloo.connect( Host, Username, Password, DatabaseName, DatabasePort )
	bricks_gang_db.onConnected = function()	print( "[BricksGang SQL] BricksGang database has connected!" )	end
	bricks_gang_db.onConnectionFailed = function( db, err )	print( "[BricksGang SQL] Connection to BricksGang Database failed! Error: " .. err )	end
	bricks_gang_db:connect()
	
	local gangTableQuery = bricks_gang_db:query( [[ CREATE TABLE IF NOT EXISTS bricks_server_gangs ( 
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
	function gangTableQuery:onSuccess(data) print( "[BricksGang SQL] bricks_server_gangs table validated!" ) end
	function gangTableQuery:onError(err) print("[BricksGang SQL] An error occured while executing the query: " .. err) end
	gangTableQuery:start()

	local inboxTableQuery = bricks_gang_db:query( [[ CREATE TABLE IF NOT EXISTS bricks_server_inboxes ( 
		receiverSteamID varchar(20), 
		receiverGangID int, 
		inboxKey int NOT NULL,
		time int, 
		type TEXT, 
		reqInfo TEXT
	); ]] )
	function inboxTableQuery:onSuccess(data) print( "[BricksGang SQL] bricks_server_inboxes table validated!" ) end
	function inboxTableQuery:onError(err) print("[BricksGang SQL] An error occured while executing the query: " .. err) end
	inboxTableQuery:start()

	local associationTableQuery = bricks_gang_db:query( [[ CREATE TABLE IF NOT EXISTS bricks_server_associations ( 
		gang1ID int NOT NULL, 
		gang2ID int NOT NULL, 
		associationType TEXT
	); ]] )
	function associationTableQuery:onSuccess(data) print( "[BricksGang SQL] bricks_server_associations table validated!" ) end
	function associationTableQuery:onError(err) print("[BricksGang SQL] An error occured while executing the query: " .. err) end
	associationTableQuery:start()

	local printerTableQuery = bricks_gang_db:query( [[ CREATE TABLE IF NOT EXISTS bricks_server_gangprinters ( 
		gangID int NOT NULL, 
		printerID int NOT NULL, 
		servers TEXT,
		upgrades TEXT
	); ]] )
	function printerTableQuery:onSuccess(data) print( "[BricksGang SQL] bricks_server_gangprinters table validated!" ) end
	function printerTableQuery:onError(err) print("[BricksGang SQL] An error occured while executing the query: " .. err) end
	printerTableQuery:start()
end
ConnectToDatabase()

-- GANGS --
function BRICKS_SERVER.Func.InsertGangDB( gangID, gangName, gangIcon, owner, members, roles, func )
	local query = bricks_gang_db:query( string.format( "INSERT INTO bricks_server_gangs( gangID, gangName, gangIcon, owner, members, roles ) VALUES(%d, '%s', '%s', '%s', '%s', '%s');", gangID, bricks_gang_db:escape( gangName ), bricks_gang_db:escape( gangIcon ), bricks_gang_db:escape( owner ), bricks_gang_db:escape( util.TableToJSON( members ) ), bricks_gang_db:escape( util.TableToJSON( roles ) ) ) )
	function query:onSuccess( err ) 
		if( func ) then func() end
	end
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

function BRICKS_SERVER.Func.UpdateGangDB( gangID, key, value )
	local query = bricks_gang_db:query( "UPDATE bricks_server_gangs SET " .. key .. " = '" .. ((isstring( value ) and bricks_gang_db:escape( value )) or value) .. "' WHERE gangID = '" .. gangID .. "';" )
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

function BRICKS_SERVER.Func.FetchGangsDB( func )
	local query = bricks_gang_db:query( "SELECT * FROM bricks_server_gangs" )
	function query:onSuccess( data ) func( data or {} ) end
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

-- INBOX --
function BRICKS_SERVER.Func.InsertInboxDB( receiverSteamID, receiverGangID, inboxKey, time, type, reqInfo )
	local query = bricks_gang_db:query( [[ INSERT INTO bricks_server_inboxes (]] .. ((receiverSteamID and "receiverSteamID") or "receiverGangID") .. [[, inboxKey, time, type, reqInfo)
		VALUES( ']] .. ((receiverSteamID and bricks_gang_db:escape( receiverSteamID )) or receiverGangID) .. [[', ']] .. inboxKey .. [[', ']] .. time .. [[', ']] .. bricks_gang_db:escape( type ) .. [[', ']] .. bricks_gang_db:escape( util.TableToJSON( reqInfo ) ) .. [['
	); ]] )
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

function BRICKS_SERVER.Func.DeleteInboxDB( receiverSteamID, receiverGangID, inboxKey )
	local query = bricks_gang_db:query( "DELETE FROM bricks_server_inboxes WHERE " .. ((receiverSteamID and "receiverSteamID") or "receiverGangID") .. " = '" .. ((receiverSteamID and bricks_gang_db:escape( receiverSteamID )) or receiverGangID) .. "' AND inboxKey = '" .. inboxKey .. "';" )
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

function BRICKS_SERVER.Func.FetchInboxDB( func )
	local query = bricks_gang_db:query( "SELECT * FROM bricks_server_inboxes" )
	function query:onSuccess( data ) func( data or {} ) end
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

-- ASSOCIATIONS --
function BRICKS_SERVER.Func.InsertAssociationDB( gang1ID, gang2ID, associationType )
	local query = bricks_gang_db:query( [[ INSERT INTO bricks_server_associations (gang1ID, gang2ID, associationType)
		VALUES( ']] .. gang1ID .. [[', ']] .. gang2ID .. [[', ']] .. bricks_gang_db:escape( associationType ) .. [['
	); ]] )
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

function BRICKS_SERVER.Func.UpdateAssociationDB( gang1ID, gang2ID, associationType )
	local query = bricks_gang_db:query( "UPDATE bricks_server_associations SET associationType = '" .. bricks_gang_db:escape( associationType ) .. "' WHERE gang1ID = '" .. gang1ID .. "' AND gang2ID = '" .. gang2ID .. "';" )
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

function BRICKS_SERVER.Func.DeleteAssociationDB( gang1ID, gang2ID )
	local query = bricks_gang_db:query( "DELETE FROM bricks_server_associations WHERE gang1ID = '" .. gang1ID .. "' AND gang2ID = '" .. gang2ID .. "';" )
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

function BRICKS_SERVER.Func.FetchAssociationsDB( func )
	local query = bricks_gang_db:query( "SELECT * FROM bricks_server_associations" )
	function query:onSuccess( data ) func( data or {} ) end
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

-- PRINTERS --
function BRICKS_SERVER.Func.InsertGangPrinterDB( gangID, printerID, servers, upgrades )
	local query = bricks_gang_db:query( [[ INSERT INTO bricks_server_gangprinters (gangID, printerID, servers, upgrades)
		VALUES( ]] .. gangID .. [[, ]] .. printerID .. [[, ']] .. bricks_gang_db:escape( util.TableToJSON( servers or {} ) ) .. [[', ']] .. bricks_gang_db:escape( util.TableToJSON( upgrades or {} ) ) .. [['
	); ]])
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

function BRICKS_SERVER.Func.UpdateGangPrinterDB( gangID, printerID, servers, upgrades )
	local query = bricks_gang_db:query( "UPDATE bricks_server_gangprinters SET " .. ((servers and "servers") or "upgrades") .. " = '" .. bricks_gang_db:escape( util.TableToJSON( servers or upgrades ) ) .. "' WHERE gangID = '" .. gangID .. "' AND printerID = '" .. printerID .. "';" )
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

function BRICKS_SERVER.Func.DeleteGangPrinterDB( gangID, printerID )
	local query = bricks_gang_db:query( "DELETE FROM bricks_server_gangprinters WHERE gangID = '" .. gangID .. "' AND printerID = '" .. printerID .. "';" )
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

function BRICKS_SERVER.Func.FetchGangPrinterDB( func )
	local query = bricks_gang_db:query( "SELECT * FROM bricks_server_gangprinters" )
	function query:onSuccess( data ) func( data or {} ) end
	function query:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	query:start()
end


-- CLEAR GANG FROM DATABASE --
function BRICKS_SERVER.Func.ClearGangFromDB( gangID )
	local queryGang = bricks_gang_db:query( "DELETE FROM bricks_server_gangs WHERE gangID = '" .. gangID .. "';" )
	function queryGang:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	queryGang:start()
	
	local queryInbox = bricks_gang_db:query( "DELETE FROM bricks_server_inboxes WHERE receiverGangID = '" .. gangID .. "';" )
	function queryInbox:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	queryInbox:start()
	
	local queryAssociation = bricks_gang_db:query( "DELETE FROM bricks_server_associations WHERE gang1ID = '" .. gangID .. "' OR gang2ID = '" .. gangID .. "';" )
	function queryAssociation:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	queryAssociation:start()

	local queryPrinters = bricks_gang_db:query( "DELETE FROM bricks_server_gangprinters WHERE gangID = '" .. gangID .. "';" )
	function queryPrinters:onError( err ) print( "[BricksGang SQL] An error occured while executing the query: " .. err ) end
	queryPrinters:start()
end