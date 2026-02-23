BRS_UNBOXING_INVENTORY = BRS_UNBOXING_INVENTORY or {}
net.Receive( "BRS.Net.SetUnboxingInventory", function()
	BRS_UNBOXING_INVENTORY = net.ReadTable() or {}

	hook.Run( "BRS.Hooks.FillUnboxingInventory" )
end )

BRS_UNBOXING_INVENTORYDATA = BRS_UNBOXING_INVENTORYDATA or {}
net.Receive( "BRS.Net.SetUnboxingInventoryData", function()
	BRS_UNBOXING_INVENTORYDATA = net.ReadTable() or {}

	hook.Run( "BRS.Hooks.FillUnboxingInventory" )
end )

BRS_UNBOXING_STATS = BRS_UNBOXING_STATS or {}
BRS_UNBOXING_PROGRESS = BRS_UNBOXING_PROGRESS or {}
net.Receive( "BRS.Net.SetUnboxingStats", function()
	BRS_UNBOXING_STATS = net.ReadTable() or {}
end )

net.Receive( "BRS.Net.UpdateUnboxingStat", function()
	local key, value = net.ReadString(), net.ReadUInt( 32 )

	if( not key ) then return end

	BRS_UNBOXING_STATS[key] = value
end )

net.Receive( "BRS.Net.SendUnboxingItemNotification", function()
	local reason = net.ReadString()
	local items = net.ReadTable()

	BRICKS_SERVER.Func.CreateUnboxingItemNotification( reason, unpack( items ) )
end )

net.Receive( "BRS.Net.UnboxingProgressState", function()
	BRS_UNBOXING_PROGRESS = net.ReadTable() or {}
	hook.Run( "BRS.Hooks.UnboxingProgressStateUpdated", BRS_UNBOXING_PROGRESS )
end )


BRS_UNBOXING_MARKET_HEALTH = BRS_UNBOXING_MARKET_HEALTH or {}
net.Receive( "BRS.Net.SendUnboxingMarketHealth", function()
	BRS_UNBOXING_MARKET_HEALTH = net.ReadTable() or {}
	hook.Run( "BRS.Hooks.UnboxingMarketHealthUpdated", BRS_UNBOXING_MARKET_HEALTH )
end )

BRS_UNBOXING_ODDS_HISTORY = BRS_UNBOXING_ODDS_HISTORY or {}
net.Receive( "BRS.Net.SendUnboxingOddsHistory", function()
	BRS_UNBOXING_ODDS_HISTORY = net.ReadTable() or {}
	hook.Run( "BRS.Hooks.UnboxingOddsHistoryUpdated", BRS_UNBOXING_ODDS_HISTORY )
end )

BRS_UNBOXING_MISSION_STATE = BRS_UNBOXING_MISSION_STATE or {}
net.Receive( "BRS.Net.SendUnboxingMissionState", function()
	BRS_UNBOXING_MISSION_STATE = net.ReadTable() or {}
	hook.Run( "BRS.Hooks.UnboxingMissionStateUpdated", BRS_UNBOXING_MISSION_STATE )
end )
