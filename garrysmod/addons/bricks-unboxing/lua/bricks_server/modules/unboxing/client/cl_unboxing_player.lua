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