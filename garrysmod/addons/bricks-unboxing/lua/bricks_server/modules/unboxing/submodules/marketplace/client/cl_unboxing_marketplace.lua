BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "unboxingSlots" ), "bricks_server_config_unboxing_slots", "unboxing" )

BRICKS_SERVER.TEMP.UnboxingMarketplace = BRICKS_SERVER.TEMP.UnboxingMarketplace or {}

BRS_UNBOXING_MARKETPLACESLOTS = BRS_UNBOXING_MARKETPLACESLOTS or {}
net.Receive( "BRS.Net.SetUnboxingMarketplaceSlots", function()
	local marketSlotsTable = net.ReadTable()

	BRS_UNBOXING_MARKETPLACESLOTS = marketSlotsTable or {}

	hook.Run( "BRS.Hooks.FillUnboxingMarketslots" )
end )

net.Receive( "BRS.Net.SendUnboxingMarketplaceItems", function()
	local marketData = net.ReadTable()

	if( not marketData ) then return end

	for k, v in pairs( marketData ) do
		if( v != false ) then
			BRICKS_SERVER.TEMP.UnboxingMarketplace[k] = v
		else
			BRICKS_SERVER.TEMP.UnboxingMarketplace[k] = nil
		end
	end

	hook.Run( "BRS.Hooks.UpdateUnboxingMarketData" )
end )

function BRICKS_SERVER.UNBOXING.Func.RequestSlotMarketData()
    if( CurTime() < (BRS_REQUEST_UNBOXING_SLOTDATA_COOLDOWN or 0) ) then return end

    BRS_REQUEST_UNBOXING_SLOTDATA_COOLDOWN = CurTime()+3

    net.Start( "BRS.Net.RequestUnboxingSlotMarketData" )
    net.SendToServer()
end

function BRICKS_SERVER.UNBOXING.Func.RequestBidMarketData()
    if( CurTime() < (BRS_REQUEST_UNBOXING_BIDDATA_COOLDOWN or 0) ) then return end

    BRS_REQUEST_UNBOXING_BIDDATA_COOLDOWN = CurTime()+3

    net.Start( "BRS.Net.RequestUnboxingBidMarketData" )
    net.SendToServer()
end

function BRICKS_SERVER.UNBOXING.Func.RequestMarketData( searchString, filter, page )
    if( CurTime() < (BRS_REQUEST_UNBOXING_MARKETDATA_COOLDOWN or 0) ) then return false, BRICKS_SERVER.Func.L( "unboxingMarketReqCooldown" ), ((BRS_REQUEST_UNBOXING_MARKETDATA_COOLDOWN or 0)-CurTime()) end

    BRS_REQUEST_UNBOXING_MARKETDATA_COOLDOWN = CurTime()+3

	net.Start( "BRS.Net.RequestUnboxingMarketData" )
		net.WriteString( searchString )
		net.WriteString( filter )
		net.WriteUInt( page, 8 )
	net.SendToServer()
	
	return true
end

net.Receive( "BRS.Net.SendUnboxingMarketplaceRequestData", function()
	local marketData = net.ReadTable()
	local totalCount = net.ReadUInt( 16 )
	local page = net.ReadUInt( 8 )

	if( marketData ) then
		table.Merge( BRICKS_SERVER.TEMP.UnboxingMarketplace, marketData )
	end

	hook.Run( "BRS.Hooks.FillUnboxingMarket", table.GetKeys( marketData or {} ), totalCount, page )
end )