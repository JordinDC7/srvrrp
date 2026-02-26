-- UNBOXING INVENTORY --
if( not sql.TableExists( "bricks_server_unboxing_inventory" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_unboxing_inventory ( 
		steamID64 varchar(20) NOT NULL UNIQUE, 
		inventory TEXT
	); ]] )
end

print( "[BricksUnboxing SQLLite] bricks_server_unboxing_inventory table validated!" )

function BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB( steamID64, inventory )
	local inventoryJSON = sql.SQLStr( util.TableToJSON( inventory ) )

	local query = sql.Query( "INSERT OR REPLACE INTO bricks_server_unboxing_inventory( steamID64, inventory ) VALUES(" .. steamID64 .. ", " .. inventoryJSON .. ");" )
	
	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.UNBOXING.Func.FetchInventoryDB( steamID64, func )
	local query = sql.QueryRow( "SELECT * FROM bricks_server_unboxing_inventory WHERE steamID64 = '" .. steamID64 .. "';", 1 )

	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end

-- UNBOXING INVENTORY DATA --
if( not sql.TableExists( "bricks_server_unboxing_inventorydata" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_unboxing_inventorydata ( 
		steamID64 varchar(20) NOT NULL UNIQUE, 
		inventorydata TEXT
	); ]] )
end

print( "[BricksUnboxing SQLLite] bricks_server_unboxing_inventorydata table validated!" )

function BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDataDB( steamID64, inventoryData )
	local inventoryDataJSON = sql.SQLStr( util.TableToJSON( inventoryData ) )

	local query = sql.Query( "INSERT OR REPLACE INTO bricks_server_unboxing_inventorydata( steamID64, inventorydata ) VALUES(" .. steamID64 .. ", " .. inventoryDataJSON .. ");" )
	
	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.UNBOXING.Func.FetchInventoryDataDB( steamID64, func )
	local query = sql.QueryRow( "SELECT * FROM bricks_server_unboxing_inventorydata WHERE steamID64 = '" .. steamID64 .. "';", 1 )

	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end

-- UNBOXING STATS --
if( not sql.TableExists( "bricks_server_unboxing_stats" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_unboxing_stats ( 
		steamID64 varchar(20) NOT NULL UNIQUE, 
		cases int,
		trades int,
		items int
	); ]] )
end

print( "[BricksUnboxing SQLLite] bricks_server_unboxing_stats table validated!" )

function BRICKS_SERVER.UNBOXING.Func.InsertStatsDB( steamID64, key, value )
	local query = sql.Query( "INSERT INTO bricks_server_unboxing_stats( steamID64, " .. key .. " ) VALUES(" .. steamID64 .. ", " .. value .. ");" )
	
	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.UNBOXING.Func.UpdateStatsDB( steamID64, key, value )
	local query = sql.Query( "UPDATE bricks_server_unboxing_stats SET " .. key .. " = " .. value .. " WHERE steamID64 = '" .. steamID64 .. "';" )

	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.UNBOXING.Func.FetchStatsDB( steamID64, func )
	local query = sql.QueryRow( "SELECT * FROM bricks_server_unboxing_stats WHERE steamID64 = '" .. steamID64 .. "';", 1 )

	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	else
		func( query )
	end
end

function BRICKS_SERVER.UNBOXING.Func.FetchStatsSortedDB( key, amount, func )
	local query = sql.Query( "SELECT steamID64, " .. key .. " FROM bricks_server_unboxing_stats WHERE " .. key .. " IS NOT NULL ORDER BY " .. key .. " DESC LIMIT " .. amount .. ";" )

	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end

-- UNBOXING MARKETPLACE --
if( not sql.TableExists( "bricks_server_unboxing_marketplace" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_unboxing_marketplace ( 
		marketKey int NOT NULL UNIQUE, 
		ownerSteamID64 varchar(20),
		itemGlobalKey varchar(10),
		itemAmount int,
		duration int,
		startTime int,
		currentBid int,
		bidders TEXT,
		ownerCollected boolean
	); ]] )
end

print( "[BricksUnboxing SQLLite] bricks_server_unboxing_marketplace table validated!" )

function BRICKS_SERVER.UNBOXING.Func.InsertMarketplaceDB( marketKey, ownerSteamID64, itemGlobalKey, itemAmount, duration, startTime, currentBid )
	local queryStr = string.format( "INSERT INTO bricks_server_unboxing_marketplace( marketKey, ownerSteamID64, itemGlobalKey, itemAmount, duration, startTime, currentBid, ownerCollected ) VALUES(%d, '%s', '%s', %d, %d, %d, %d, %d);", marketKey, ownerSteamID64, itemGlobalKey, itemAmount, duration, startTime, currentBid, 0 )
	local query = sql.Query( queryStr )
	
	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	end
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
		finalValue = sql.SQLStr( util.TableToJSON( finalValue ) )
	elseif( keyTable[key] == "boolean" ) then
		finalValue = ((finalValue or false) == true and 1) or 0
	end

	local query = sql.Query( "UPDATE bricks_server_unboxing_marketplace SET " .. key .. " = " .. finalValue .. " WHERE marketKey = '" .. marketKey .. "';" )
	
	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.UNBOXING.Func.RemoveMarketplaceDB( marketKey )
	local query = sql.Query( "DELETE FROM bricks_server_unboxing_marketplace WHERE marketKey = '" .. marketKey .. "';" )
	
	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.UNBOXING.Func.FetchMarketplaceEntryDB( marketKey, func )
	local query = sql.QueryRow( "SELECT * FROM bricks_server_unboxing_marketplace WHERE marketKey = '" .. marketKey .. "';", 1 )

	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end

function BRICKS_SERVER.UNBOXING.Func.FetchMarketplaceDB( func )
	local query = sql.Query( "SELECT * FROM bricks_server_unboxing_marketplace;" )

	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end

-- UNBOXING MARKETPLACE SLOTS --
if( not sql.TableExists( "bricks_server_unboxing_marketplaceslots" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_unboxing_marketplaceslots ( 
		steamID64 varchar(20),
		slotKey int NOT NULL,
		marketKey int
	); ]] )
end

-- Remove unique index if it was previously added (it caused issues)
sql.Query( "DROP INDEX IF EXISTS idx_marketplaceslots_unique;" )

print( "[BricksUnboxing SQLLite] bricks_server_unboxing_marketplaceslots table validated!" )

function BRICKS_SERVER.UNBOXING.Func.InsertMarketplaceSlotsDB( steamID64, slotKey )
	-- Check if row already exists to prevent duplicates
	local existing = sql.Query( "SELECT 1 FROM bricks_server_unboxing_marketplaceslots WHERE steamID64 = '" .. steamID64 .. "' AND slotKey = " .. slotKey .. " LIMIT 1;" )
	if( existing and #existing > 0 ) then return end

	local query = sql.Query( "INSERT INTO bricks_server_unboxing_marketplaceslots( steamID64, slotKey ) VALUES('" .. steamID64 .. "', " .. slotKey .. ");" )
	
	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceSlotsDB( steamID64, slotKey, marketKey )
	local query = sql.Query( "UPDATE bricks_server_unboxing_marketplaceslots SET marketKey = " .. (marketKey or "null") .. " WHERE steamID64 = '" .. steamID64 .. "' AND slotKey = " .. slotKey .. ";" )
	
	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.UNBOXING.Func.FetchMarketplaceSlotsDB( steamID64, func )
	local query = sql.Query( "SELECT * FROM bricks_server_unboxing_marketplaceslots WHERE steamID64 = '" .. steamID64 .. "';" )

	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end

-- UNBOXING REWARDS CLAIMED --
if( not sql.TableExists( "bricks_server_unboxing_rewards" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_unboxing_rewards ( 
		steamID64 varchar(20) NOT NULL UNIQUE, 
		claimed TEXT
	); ]] )
end

print( "[BricksUnboxing SQLLite] bricks_server_unboxing_rewards table validated!" )

function BRICKS_SERVER.UNBOXING.Func.UpdateRewardsClaimedDB( steamID64, claimed )
	local claimedJSON = sql.SQLStr( util.TableToJSON( claimed ) )

	local query = sql.Query( "INSERT OR REPLACE INTO bricks_server_unboxing_rewards( steamID64, claimed ) VALUES(" .. steamID64 .. ", " .. claimedJSON .. ");" )
	
	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.UNBOXING.Func.FetchRewardsClaimedDB( steamID64, func )
	local query = sql.QueryRow( "SELECT * FROM bricks_server_unboxing_rewards WHERE steamID64 = '" .. steamID64 .. "';", 1 )

	if( query == false ) then
		print( "[BricksUnboxing SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end