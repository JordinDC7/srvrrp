local Host = "localhost"
local Username = "u14547_rEOEMLMVTj"
local Password = "lm=uJs8+ln^!vnBZR30dWtH4"
local DatabaseName = "s14547_unboxing"
local DatabasePort = 3306

--[[

	DONT TOUCH ANYTHING BELOW THIS LINE!
	
]]--

require( "mysqloo" )

local tablesToCreate = {
	["bricks_server_unboxing_inventory"] = [[ CREATE TABLE IF NOT EXISTS bricks_server_unboxing_inventory ( 
		steamID64 varchar(20) NOT NULL UNIQUE, 
		inventory TEXT
	); ]],
	["bricks_server_unboxing_inventorydata"] = [[ CREATE TABLE IF NOT EXISTS bricks_server_unboxing_inventorydata ( 
		steamID64 varchar(20) NOT NULL UNIQUE, 
		inventorydata TEXT
	); ]],
	["bricks_server_unboxing_stats"] = [[ CREATE TABLE IF NOT EXISTS bricks_server_unboxing_stats ( 
		steamID64 varchar(20) NOT NULL UNIQUE, 
		cases int,
		trades int,
		items int
	); ]],
	["bricks_server_unboxing_marketplace"] = [[ CREATE TABLE IF NOT EXISTS bricks_server_unboxing_marketplace ( 
		marketKey int NOT NULL UNIQUE, 
		ownerSteamID64 varchar(20),
		itemGlobalKey varchar(10),
		itemAmount int,
		duration int,
		startTime int,
		currentBid int,
		bidders TEXT,
		ownerCollected boolean
	); ]],
	["bricks_server_unboxing_marketplaceslots"] = [[ CREATE TABLE IF NOT EXISTS bricks_server_unboxing_marketplaceslots ( 
		steamID64 varchar(20),
		slotKey int NOT NULL,
		marketKey int
	); ]],
	["bricks_server_unboxing_rewards"] = [[ CREATE TABLE IF NOT EXISTS bricks_server_unboxing_rewards ( 
		steamID64 varchar(20) NOT NULL UNIQUE, 
		claimed TEXT
	); ]],
}

local function ConnectToDatabase()
	BRS_UNBOXING_DB = mysqloo.connect( Host, Username, Password, DatabaseName, DatabasePort )
	BRS_UNBOXING_DB.onConnected = function() print( "[BricksUnboxing SQL] Database has connected!" ) end
	BRS_UNBOXING_DB.onConnectionFailed = function( db, err ) print( "[BricksUnboxing SQL] Connection to database failed! Error: " .. err ) end
	BRS_UNBOXING_DB:connect()
	
	for k, v in pairs( tablesToCreate ) do
		local tableQuery = BRS_UNBOXING_DB:query( v )
		function tableQuery:onSuccess(data) print( "[BricksUnboxing SQL] " .. k .. " table validated!" ) end
		function tableQuery:onError(err) print("[BricksUnboxing SQL] An error occured while executing the query: " .. err) end
		tableQuery:start()
	end
end
ConnectToDatabase()

function BRICKS_SERVER.UNBOXING.Func.QueryDB( query, func, singleRow )
	local query = BRS_UNBOXING_DB:query( query )
	if( func ) then
		function query:onSuccess( data ) 
			data = data or {}
			
			if( singleRow ) then
				data = data[1] or {}
			end

			func( data ) 
		end
	end
	function query:onError( err ) print( "[BricksUnboxing SQL] An error occured while executing the query: " .. err ) end
	query:start()
end

-- UNBOXING INVENTORY --
function BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB( steamID64, inventory )
	local inventoryJSON = util.TableToJSON( inventory )

	BRICKS_SERVER.UNBOXING.Func.QueryDB( "REPLACE INTO bricks_server_unboxing_inventory( steamID64, inventory ) VALUES('" .. steamID64 .. "', '" .. inventoryJSON .. "');" )
end

function BRICKS_SERVER.UNBOXING.Func.FetchInventoryDB( steamID64, func )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "SELECT * FROM bricks_server_unboxing_inventory WHERE steamID64 = '" .. steamID64 .. "';", func, true )
end

-- UNBOXING INVENTORY DATA --
function BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDataDB( steamID64, inventoryData )
	local inventoryDataJSON = util.TableToJSON( inventoryData )

	BRICKS_SERVER.UNBOXING.Func.QueryDB( "REPLACE INTO bricks_server_unboxing_inventorydata( steamID64, inventorydata ) VALUES('" .. steamID64 .. "', '" .. inventoryDataJSON .. "');" )
end

function BRICKS_SERVER.UNBOXING.Func.FetchInventoryDataDB( steamID64, func )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "SELECT * FROM bricks_server_unboxing_inventorydata WHERE steamID64 = '" .. steamID64 .. "';", func, true )
end

-- UNBOXING STATS --
function BRICKS_SERVER.UNBOXING.Func.InsertStatsDB( steamID64, key, value )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "INSERT INTO bricks_server_unboxing_stats( steamID64, " .. key .. " ) VALUES('" .. steamID64 .. "', " .. value .. ");" )
end

function BRICKS_SERVER.UNBOXING.Func.UpdateStatsDB( steamID64, key, value )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "UPDATE bricks_server_unboxing_stats SET " .. key .. " = " .. value .. " WHERE steamID64 = '" .. steamID64 .. "';" )
end

function BRICKS_SERVER.UNBOXING.Func.FetchStatsDB( steamID64, func )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "SELECT * FROM bricks_server_unboxing_stats WHERE steamID64 = '" .. steamID64 .. "';", function( data )
		if( table.Count( data ) < 1 ) then
			data = nil	
		end

		func( data )
	end, true )
end

function BRICKS_SERVER.UNBOXING.Func.FetchStatsSortedDB( key, amount, func )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "SELECT steamID64, " .. key .. " FROM bricks_server_unboxing_stats WHERE " .. key .. " IS NOT NULL ORDER BY " .. key .. " DESC LIMIT " .. amount .. ";", func )
end

-- UNBOXING MARKETPLACE --
function BRICKS_SERVER.UNBOXING.Func.InsertMarketplaceDB( marketKey, ownerSteamID64, itemGlobalKey, itemAmount, duration, startTime, currentBid )
	local queryStr = string.format( "INSERT INTO bricks_server_unboxing_marketplace( marketKey, ownerSteamID64, itemGlobalKey, itemAmount, duration, startTime, currentBid, ownerCollected ) VALUES(%d, '%s', '%s', %d, %d, %d, %d, %d);", marketKey, ownerSteamID64, itemGlobalKey, itemAmount, duration, startTime, currentBid, 0 )
	
	BRICKS_SERVER.UNBOXING.Func.QueryDB( queryStr )
end

local keyTable = {
	["startTime"] = "integer",
	["currentBid"] = "integer",
	["duration"] = "integer",
	["bidders"] = "table",
	["ownerCollected"] = "boolean"
}

function BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceDB( marketKey, key, value )
	if( not keyTable[key] ) then return end

	local finalValue = value
	if( keyTable[key] == "table" ) then
		finalValue = util.TableToJSON( finalValue )
	elseif( keyTable[key] == "boolean" ) then
		finalValue = ((finalValue or false) == true and 1) or 0
	end
	
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "UPDATE bricks_server_unboxing_marketplace SET " .. key .. " = '" .. finalValue .. "' WHERE marketKey = '" .. marketKey .. "';" )
end

function BRICKS_SERVER.UNBOXING.Func.RemoveMarketplaceDB( marketKey )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "DELETE FROM bricks_server_unboxing_marketplace WHERE marketKey = '" .. marketKey .. "';" )
end

function BRICKS_SERVER.UNBOXING.Func.FetchMarketplaceEntryDB( marketKey, func )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "SELECT * FROM bricks_server_unboxing_marketplace WHERE marketKey = '" .. marketKey .. "';", func, true )
end

function BRICKS_SERVER.UNBOXING.Func.FetchMarketplaceDB( func )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "SELECT * FROM bricks_server_unboxing_marketplace;", func )
end

-- UNBOXING MARKETPLACE SLOTS --
function BRICKS_SERVER.UNBOXING.Func.InsertMarketplaceSlotsDB( steamID64, slotKey )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "INSERT INTO bricks_server_unboxing_marketplaceslots( steamID64, slotKey ) VALUES('" .. steamID64 .. "', " .. slotKey .. ");" )
end

function BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceSlotsDB( steamID64, slotKey, marketKey )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "UPDATE bricks_server_unboxing_marketplaceslots SET marketKey = " .. (marketKey or "null") .. " WHERE steamID64 = '" .. steamID64 .. "' AND slotKey = " .. slotKey .. ";" )
end

function BRICKS_SERVER.UNBOXING.Func.FetchMarketplaceSlotsDB( steamID64, func )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "SELECT * FROM bricks_server_unboxing_marketplaceslots WHERE steamID64 = '" .. steamID64 .. "';", func )
end

-- UNBOXING REWARDS CLAIMED --
function BRICKS_SERVER.UNBOXING.Func.UpdateRewardsClaimedDB( steamID64, claimed )
	local claimedJSON = util.TableToJSON( claimed )

	BRICKS_SERVER.UNBOXING.Func.QueryDB( "REPLACE INTO bricks_server_unboxing_rewards( steamID64, claimed ) VALUES(" .. steamID64 .. ", '" .. claimedJSON .. "');" )
end

function BRICKS_SERVER.UNBOXING.Func.FetchRewardsClaimedDB( steamID64, func )
	BRICKS_SERVER.UNBOXING.Func.QueryDB( "SELECT * FROM bricks_server_unboxing_rewards WHERE steamID64 = '" .. steamID64 .. "';", func, true )
end