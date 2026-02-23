BRICKS_SERVER.TEMP.UnboxingMarketplace = BRICKS_SERVER.TEMP.UnboxingMarketplace or {}

local function brsMarketplaceDiagnostics()
    local prices = {}
    local now = BRICKS_SERVER.Func.UTCTime()

    for _, marketItem in pairs( BRICKS_SERVER.TEMP.UnboxingMarketplace ) do
        if( now >= (marketItem.StartTime+marketItem.Duration) ) then continue end
        table.insert( prices, tonumber( marketItem.CurrentBid ) or 0 )
    end

    table.sort( prices, function( a, b ) return a < b end )

    local count = #prices
    local median = 0
    if( count > 0 ) then
        if( count % 2 == 0 ) then
            median = (prices[count/2]+prices[(count/2)+1])/2
        else
            median = prices[math.ceil( count/2 )]
        end
    end

    return {
        ActiveAuctions = count,
        Median = math.floor( median ),
        Floor = prices[1] or 0,
        Ceiling = prices[count] or 0,
        Velocity = count
    }
end

util.AddNetworkString( "BRS.Net.RequestUnboxingMarketplaceHealth" )
util.AddNetworkString( "BRS.Net.SendUnboxingMarketplaceHealth" )
net.Receive( "BRS.Net.RequestUnboxingMarketplaceHealth", function( len, ply )
    if( CurTime() < (ply.BRS_REQUEST_UNBOXING_MARKETHEALTH_COOLDOWN or 0) ) then return end
    ply.BRS_REQUEST_UNBOXING_MARKETHEALTH_COOLDOWN = CurTime()+5

    net.Start( "BRS.Net.SendUnboxingMarketplaceHealth" )
        net.WriteTable( brsMarketplaceDiagnostics() )
    net.Send( ply )
end )
hook.Add( "Initialize", "BricksServerHooks_Initialize_Marketplace", function()	
    BRICKS_SERVER.TEMP.UnboxingMarketplace = {}

    BRICKS_SERVER.UNBOXING.Func.FetchMarketplaceDB( function( data )
        for k, v in ipairs( data ) do
            BRICKS_SERVER.TEMP.UnboxingMarketplace[tonumber( v.marketKey )] = {
                OwnerSteamID64 = v.ownerSteamID64 or "",
                ItemGlobalKey = v.itemGlobalKey or "",
                ItemAmount = tonumber( v.itemAmount or 0 ),
                Duration = tonumber( v.duration or 0 ),
                StartTime = tonumber( v.startTime or 0 ),
                CurrentBid = tonumber( v.currentBid or 0 ),
                Bidders = util.JSONToTable( v.bidders or "" ) or {},
                OwnerCollected = tobool( v.ownerCollected )
            }
        end

        for k, v in pairs( BRICKS_SERVER.TEMP.UnboxingMarketplace ) do
            BRICKS_SERVER.UNBOXING.Func.CheckMarketplaceItemRemove( k )
        end
    end )
end )

local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.SetUnboxingMarketplaceSlots" )
function playerMeta:SetUnboxingMarketplaceSlots( marketSlotsTable )
	if( not marketSlotsTable ) then return end

	net.Start( "BRS.Net.SetUnboxingMarketplaceSlots" )
		net.WriteTable( marketSlotsTable )
	net.Send( self )

	self.BRS_UNBOXING_MARKETPLACESLOTS = marketSlotsTable
end

BRICKS_SERVER.TEMP.UnboxingMarketplacePlys = BRICKS_SERVER.TEMP.UnboxingMarketplacePlys or {}

util.AddNetworkString( "BRS.Net.SendUnboxingMarketplaceItems" )
function playerMeta:SendUnboxingMarketplaceItems( ... )
    local marketKeysTable = {...}

    if( not marketKeysTable ) then return end
    
    local marketData = {}
    for k, v in ipairs( marketKeysTable ) do
        marketData[v] = BRICKS_SERVER.TEMP.UnboxingMarketplace[v] or false
    end

	net.Start( "BRS.Net.SendUnboxingMarketplaceItems" )
		net.WriteTable( marketData )
	net.Send( self )
end

util.AddNetworkString( "BRS.Net.RequestUnboxingSlotMarketData" )
net.Receive( "BRS.Net.RequestUnboxingSlotMarketData", function( len, ply )
    if( CurTime() < (ply.BRS_REQUEST_UNBOXING_SLOTDATA_COOLDOWN or 0) ) then return end

    ply.BRS_REQUEST_UNBOXING_SLOTDATA_COOLDOWN = CurTime()+2

    local marketKeysTable = {}
    for k, v in pairs( ply:GetUnboxingMarketplaceSlots() or {} ) do
        if( v[1] ) then
            table.insert( marketKeysTable, v[1] )
        end
    end

    ply:SendUnboxingMarketplaceItems( unpack( marketKeysTable ) )

    BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply] = BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply] or {}
    for k, v in pairs( marketKeysTable ) do
        if( BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply][v] ) then continue end

        BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply][v] = true
    end
end )

hook.Add( "PlayerInitialSpawn", "BricksServerHooks_PlayerInitialSpawn_UnboxingLoadMarketplaceData", function( ply ) 
    BRICKS_SERVER.UNBOXING.Func.FetchMarketplaceSlotsDB( ply:SteamID64(), function( data )
        local marketSlotsTable = {}
        for k, v in ipairs( data ) do
            marketSlotsTable[tonumber(v.slotKey)] = { tonumber(v.marketKey) }
        end

		ply:SetUnboxingMarketplaceSlots( marketSlotsTable )
	end )
end )

util.AddNetworkString( "BRS.Net.UnlockUnboxingMarketplaceSlot" )
net.Receive( "BRS.Net.UnlockUnboxingMarketplaceSlot", function( len, ply )
	local slotKey = net.ReadUInt( 8 )

	if( not slotKey ) then return end

    local slotConfigTable = BRICKS_SERVER.CONFIG.UNBOXING.Marketplace.Slots[slotKey]
    local plySlotsTable = ply:GetUnboxingMarketplaceSlots()

    if( not slotConfigTable or plySlotsTable[slotKey] ) then return end

    if( slotConfigTable.Price and not BRICKS_SERVER.UNBOXING.Func.CanAffordCurrency( ply, slotConfigTable.Price ) ) then return end

    if( slotConfigTable.Group and not BRICKS_SERVER.Func.IsInGroup( ply, slotConfigTable.Group ) ) then return end

    if( slotConfigTable.Price ) then
        BRICKS_SERVER.UNBOXING.Func.TakeCurrency( ply, slotConfigTable.Price )
    end

    plySlotsTable[slotKey] = {}

    ply:SetUnboxingMarketplaceSlots( plySlotsTable )

    BRICKS_SERVER.UNBOXING.Func.InsertMarketplaceSlotsDB( ply:SteamID64(), slotKey )

    BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingMarketSlotUnlock", slotKey ) )
end )

util.AddNetworkString( "BRS.Net.SellUnboxingMarketplaceItem" )
net.Receive( "BRS.Net.SellUnboxingMarketplaceItem", function( len, ply )
	local slotKey = net.ReadUInt( 8 )
    local globalKey = net.ReadString()
    local amount = net.ReadUInt( 16 )
    local price = net.ReadUInt( 32 )
    local duration = net.ReadUInt( 32 )

	if( not slotKey or not globalKey or not amount or not price or not duration ) then return end

    local slotConfigTable = BRICKS_SERVER.CONFIG.UNBOXING.Marketplace.Slots[slotKey]
    local plySlotsTable = ply:GetUnboxingMarketplaceSlots()

    if( not slotConfigTable or not plySlotsTable[slotKey] or plySlotsTable[slotKey][1] ) then return end

    local plyInventory = ply:GetUnboxingInventory()
    if( not plyInventory[globalKey] or amount > plyInventory[globalKey] ) then return end

    if( price < BRICKS_SERVER.CONFIG.UNBOXING["Auction Minimum Starting Price"] or price > BRICKS_SERVER.CONFIG.UNBOXING["Auction Maximum Starting Price"] ) then return end

    if( duration < BRICKS_SERVER.CONFIG.UNBOXING["Auction Minimum Duration"] or duration > BRICKS_SERVER.CONFIG.UNBOXING["Auction Maximum Duration"] ) then return end

    ply:RemoveUnboxingInventoryItem( globalKey, amount )

    local marketTable = { 
        OwnerSteamID64 = ply:SteamID64(),
        ItemGlobalKey = globalKey,
        ItemAmount = amount,
        Duration = duration,
        StartTime = BRICKS_SERVER.Func.UTCTime(),
        CurrentBid = price,
        Bidders = {},
        OwnerCollected = false
    }

    local marketKey = table.insert( BRICKS_SERVER.TEMP.UnboxingMarketplace, marketTable )

    BRICKS_SERVER.UNBOXING.Func.InsertMarketplaceDB( marketKey, marketTable.OwnerSteamID64, marketTable.ItemGlobalKey, marketTable.ItemAmount, marketTable.Duration, marketTable.StartTime, marketTable.CurrentBid )

    BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "unbox_market_listed", {
        SteamID64 = ply:SteamID64(),
        MarketKey = marketKey,
        Item = globalKey,
        Price = price,
        Duration = duration
    } )

    plySlotsTable[slotKey] = { marketKey }
    ply:SetUnboxingMarketplaceSlots( plySlotsTable )

    BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceSlotsDB( ply:SteamID64(), slotKey, marketKey )

    ply:SendUnboxingMarketplaceItems( marketKey )

    ply:SendUnboxingItemNotification( BRICKS_SERVER.Func.L( "unboxingAuctionCreated" ), marketTable.ItemGlobalKey, -marketTable.ItemAmount )
end )

local keysToSQL = {
    ["OwnerSteamID64"] = "ownerSteamID64",
    ["ItemGlobalKey"] = "itemGlobalKey",
    ["ItemAmount"] = "itemAmount",
    ["Duration"] = "duration",
    ["StartTime"] = "startTime",
    ["CurrentBid"] = "currentBid",
    ["Bidders"] = "bidders",
    ["OwnerCollected"] = "ownerCollected"
}

function BRICKS_SERVER.UNBOXING.Func.UpdateMarketDataPlys( marketKey )
    for k, v in pairs( BRICKS_SERVER.TEMP.UnboxingMarketplacePlys ) do
        if( not IsValid( k ) ) then
            BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[k] = nil
        end

        if( v[marketKey] ) then
            k:SendUnboxingMarketplaceItems( marketKey )
        end
    end
end

util.AddNetworkString( "BRS.Net.SendUnboxingMarketplaceClose" )
net.Receive( "BRS.Net.SendUnboxingMarketplaceClose", function( len, ply )
    if( not IsValid( ply ) ) then return end

    BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply] = nil
end )

function BRICKS_SERVER.UNBOXING.Func.RemoveMarketplaceItem( marketKey )
    local marketItemTable = BRICKS_SERVER.TEMP.UnboxingMarketplace[marketKey]
    BRICKS_SERVER.TEMP.UnboxingMarketplace[marketKey] = nil

    BRICKS_SERVER.UNBOXING.Func.RemoveMarketplaceDB( marketKey )

    BRICKS_SERVER.UNBOXING.Func.UpdateMarketDataPlys( marketKey )

    if( marketItemTable ) then
        local steamID64 = marketItemTable.OwnerSteamID64
        local ply = player.GetBySteamID64( steamID64 )

        if( IsValid( ply ) ) then
            local plySlotsTable = ply:GetUnboxingMarketplaceSlots()
            for k, v in pairs( plySlotsTable ) do
                if( v[1] == marketKey ) then
                    plySlotsTable[k] = {}
                    ply:SetUnboxingMarketplaceSlots( plySlotsTable )
                    BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceSlotsDB( steamID64, k )
                    break
                end
            end
        else
            BRICKS_SERVER.UNBOXING.Func.FetchMarketplaceSlotsDB( steamID64, function( data )
                local marketSlotsTable = {}
                for k, v in ipairs( data ) do
                    marketSlotsTable[tonumber(v.slotKey)] = { tonumber(v.marketKey) }
                end
        
                for k, v in pairs( marketSlotsTable ) do
                    if( v[1] == marketKey ) then
                        BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceSlotsDB( steamID64, k )
                        break
                    end
                end
            end )
        end
    end
end

function BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceItem( marketKey, key, value )
    BRICKS_SERVER.TEMP.UnboxingMarketplace[marketKey][key] = value

    BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceDB( marketKey, keysToSQL[key], value )

    BRICKS_SERVER.UNBOXING.Func.UpdateMarketDataPlys( marketKey )
end

function BRICKS_SERVER.UNBOXING.Func.CheckMarketplaceItemRemove( marketKey, notRemovedFunc, removedFunc )
    local marketItemTable = BRICKS_SERVER.TEMP.UnboxingMarketplace[marketKey]

    if( not marketItemTable ) then return end

    local shouldRemove = true

    if( BRICKS_SERVER.Func.UTCTime() < marketItemTable.StartTime+marketItemTable.Duration+BRICKS_SERVER.CONFIG.UNBOXING["Dead Auction Remove Time"] ) then
        shouldRemove = marketItemTable.OwnerCollected

        if( shouldRemove ) then
            for k, v in pairs( marketItemTable.Bidders ) do
                if( not v[2] ) then
                    shouldRemove = false
                    break
                end
            end
        end
    end

    if( not shouldRemove ) then
        if( notRemovedFunc ) then
            notRemovedFunc()
        end
    else
        BRICKS_SERVER.UNBOXING.Func.RemoveMarketplaceItem( marketKey )
    end
end

util.AddNetworkString( "BRS.Net.CancelUnboxingAuction" )
net.Receive( "BRS.Net.CancelUnboxingAuction", function( len, ply )
	local marketKey = net.ReadUInt( 8 )

	if( not marketKey ) then return end

    local marketItemTable = BRICKS_SERVER.TEMP.UnboxingMarketplace[marketKey]

    if( not marketItemTable ) then return end

    if( marketItemTable.OwnerSteamID64 != ply:SteamID64() ) then return end

    if( BRICKS_SERVER.Func.UTCTime() >= marketItemTable.StartTime+marketItemTable.Duration ) then return end

    ply:AddUnboxingInventoryItem( marketItemTable.ItemGlobalKey, marketItemTable.ItemAmount )
    ply:SendUnboxingItemNotification( BRICKS_SERVER.Func.L( "unboxingAuctionCancelled" ), marketItemTable.ItemGlobalKey, marketItemTable.ItemAmount )

    BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceItem( marketKey, "Duration", 0 )
    BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceItem( marketKey, "OwnerCollected", true )

    BRICKS_SERVER.UNBOXING.Func.CheckMarketplaceItemRemove( marketKey, function()
        local plySlotsTable = ply:GetUnboxingMarketplaceSlots()
        for k, v in pairs( plySlotsTable ) do
            if( v[1] == marketKey ) then
                plySlotsTable[k] = {}
                ply:SetUnboxingMarketplaceSlots( plySlotsTable )
                BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceSlotsDB( ply:SteamID64(), k )
                break
            end
        end
    end )
end )

util.AddNetworkString( "BRS.Net.CollectUnboxingAuction" )
net.Receive( "BRS.Net.CollectUnboxingAuction", function( len, ply )
	local marketKey = net.ReadUInt( 8 )

	if( not marketKey ) then return end

    local marketItemTable = BRICKS_SERVER.TEMP.UnboxingMarketplace[marketKey]

    if( not marketItemTable ) then return end

    if( BRICKS_SERVER.Func.UTCTime() < marketItemTable.StartTime+marketItemTable.Duration ) then return end

    if( marketItemTable.OwnerSteamID64 == ply:SteamID64() ) then
        if( marketItemTable.OwnerCollected ) then return end

        if( table.Count( marketItemTable.Bidders or {} ) > 0 ) then
            BRICKS_SERVER.UNBOXING.Func.AddCurrency( ply, marketItemTable.CurrentBid )
            BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingAuctionCurrencyCollected", BRICKS_SERVER.UNBOXING.Func.FormatCurrency( marketItemTable.CurrentBid ) ) )

            BRICKS_SERVER.UNBOXING.Func.LogTelemetry( "unbox_market_sold", {
                SteamID64 = ply:SteamID64(),
                MarketKey = marketKey,
                Item = marketItemTable.ItemGlobalKey,
                Price = marketItemTable.CurrentBid
            } )
        else
            ply:AddUnboxingInventoryItem( marketItemTable.ItemGlobalKey, marketItemTable.ItemAmount )
            ply:SendUnboxingItemNotification( BRICKS_SERVER.Func.L( "unboxingAuctionCollected" ), marketItemTable.ItemGlobalKey, marketItemTable.ItemAmount )
        end

        BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceItem( marketKey, "OwnerCollected", true )

        BRICKS_SERVER.UNBOXING.Func.CheckMarketplaceItemRemove( marketKey, function()
            local plySlotsTable = ply:GetUnboxingMarketplaceSlots()
            for k, v in pairs( plySlotsTable ) do
                if( v[1] == marketKey ) then
                    plySlotsTable[k] = {}
                    ply:SetUnboxingMarketplaceSlots( plySlotsTable )
                    BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceSlotsDB( ply:SteamID64(), k )
                    break
                end
            end
        end )
    else
        if( not marketItemTable.Bidders or not marketItemTable.Bidders[ply:SteamID()] or marketItemTable.Bidders[ply:SteamID()][2] == true ) then return end

        if( marketItemTable.Bidders[ply:SteamID()][1] == marketItemTable.CurrentBid and marketItemTable.Duration > 0 ) then
            ply:AddUnboxingInventoryItem( marketItemTable.ItemGlobalKey, marketItemTable.ItemAmount )
            ply:SendUnboxingItemNotification( BRICKS_SERVER.Func.L( "unboxingAuctionCollected" ), marketItemTable.ItemGlobalKey, marketItemTable.ItemAmount )
        else
            BRICKS_SERVER.UNBOXING.Func.AddCurrency( ply, marketItemTable.Bidders[ply:SteamID()][1] )
            BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingAuctionCurrencyCollected", BRICKS_SERVER.UNBOXING.Func.FormatCurrency( marketItemTable.Bidders[ply:SteamID()][1] ) ) )
        end

        marketItemTable.Bidders[ply:SteamID()][2] = true

        BRICKS_SERVER.UNBOXING.Func.CheckMarketplaceItemRemove( marketKey, function()
            BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceItem( marketKey, "Bidders", marketItemTable.Bidders )
        end )
    end
end )

util.AddNetworkString( "BRS.Net.RequestUnboxingMarketData" )
util.AddNetworkString( "BRS.Net.SendUnboxingMarketplaceRequestData" )
net.Receive( "BRS.Net.RequestUnboxingMarketData", function( len, ply )
    if( (ply.BRS_REQUEST_UNBOXING_MARKETDATA_COOLDOWN or 0) > CurTime() ) then return end
    
    ply.BRS_REQUEST_UNBOXING_MARKETDATA_COOLDOWN = CurTime()+2

	local searchString = net.ReadString()
	local filter = net.ReadString()
	local page = net.ReadUInt( 8 )

	if( not searchString or not filter or not page ) then return end

    local marketData, valuesPassed, totalCount = {}, 0, 0
    for k, v in pairs( BRICKS_SERVER.TEMP.UnboxingMarketplace ) do
        local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( v.ItemGlobalKey )

        if( not configItemTable ) then continue end

        if( BRICKS_SERVER.Func.UTCTime() >= v.StartTime+v.Duration ) then continue end

        if( searchString != "" and not string.find( string.lower( configItemTable.Name ), string.lower( searchString ) ) ) then
            continue
        end

        totalCount = totalCount+1

        if( table.Count( marketData ) >= BRICKS_SERVER.CONFIG.UNBOXING["Auctions Per Page"] ) then continue end

        if( valuesPassed >= BRICKS_SERVER.CONFIG.UNBOXING["Auctions Per Page"]*(page-1) ) then
            marketData[k] = v
        else
            valuesPassed = valuesPassed+1
        end
    end

	net.Start( "BRS.Net.SendUnboxingMarketplaceRequestData" )
		net.WriteTable( marketData )
		net.WriteUInt( totalCount, 16 )
		net.WriteUInt( page, 8 )
    net.Send( ply )
    
    BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply] = BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply] or {}
    for k, v in pairs( marketData ) do
        if( BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply][k] ) then continue end

        BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply][k] = true
    end
end )

util.AddNetworkString( "BRS.Net.BidUnboxingAuction" )
net.Receive( "BRS.Net.BidUnboxingAuction", function( len, ply )
	local marketKey = net.ReadUInt( 8 )
	local bidAmount = net.ReadUInt( 32 )

	if( not marketKey or not bidAmount ) then return end

    local marketItemTable = BRICKS_SERVER.TEMP.UnboxingMarketplace[marketKey]

    if( not marketItemTable ) then return end

    if( BRICKS_SERVER.Func.UTCTime() >= marketItemTable.StartTime+marketItemTable.Duration or marketItemTable.OwnerSteamID64 == ply:SteamID64() ) then return end

    if( bidAmount < math.floor( marketItemTable.CurrentBid*BRICKS_SERVER.CONFIG.UNBOXING["Auctions Minimum Bid Increase"] ) ) then return end

    local biddersTable = marketItemTable.Bidders or {}

    local moneyToTake = bidAmount-((biddersTable[ply:SteamID()] or {})[1] or 0)
    if( not BRICKS_SERVER.UNBOXING.Func.CanAffordCurrency( ply, moneyToTake ) ) then 
        BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingCantAfford" ) )
        return 
    end

    BRICKS_SERVER.UNBOXING.Func.TakeCurrency( ply, moneyToTake )

    biddersTable[ply:SteamID()] = { bidAmount }
    BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceItem( marketKey, "Bidders", biddersTable )
    BRICKS_SERVER.UNBOXING.Func.UpdateMarketplaceItem( marketKey, "CurrentBid", bidAmount )

    BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingMarketBidPlaced" ) )
end )

util.AddNetworkString( "BRS.Net.RequestUnboxingBidMarketData" )
net.Receive( "BRS.Net.RequestUnboxingBidMarketData", function( len, ply )
    if( CurTime() < (ply.BRS_REQUEST_UNBOXING_BIDDATA_COOLDOWN or 0) ) then return end

    ply.BRS_REQUEST_UNBOXING_BIDDATA_COOLDOWN = CurTime()+2

    local marketKeysTable = {}
    for k, v in pairs( BRICKS_SERVER.TEMP.UnboxingMarketplace ) do
        if( v.Bidders and v.Bidders[ply:SteamID()] and not v.Bidders[ply:SteamID()][2] ) then
            table.insert( marketKeysTable, k )
        end
    end

    ply:SendUnboxingMarketplaceItems( unpack( marketKeysTable ) )

    BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply] = BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply] or {}
    for k, v in pairs( marketKeysTable ) do
        if( BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply][v] ) then continue end

        BRICKS_SERVER.TEMP.UnboxingMarketplacePlys[ply][v] = true
    end
end )
