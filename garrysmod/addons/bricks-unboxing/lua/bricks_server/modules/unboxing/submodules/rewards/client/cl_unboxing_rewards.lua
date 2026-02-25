BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "unboxingRewardsFull" ), "bricks_server_config_unboxing_rewards", "unboxing" )

BRS_UNBOXING_REWARDSCLAIMED = BRS_UNBOXING_REWARDSCLAIMED or {}
net.Receive( "BRS.Net.SetUnboxingRewardsClaimed", function()
	local claimedTable = net.ReadTable()

	BRS_UNBOXING_REWARDSCLAIMED = claimedTable or {}

	hook.Run( "BRS.Hooks.FillUnboxingRewardsClaimed" )
end )