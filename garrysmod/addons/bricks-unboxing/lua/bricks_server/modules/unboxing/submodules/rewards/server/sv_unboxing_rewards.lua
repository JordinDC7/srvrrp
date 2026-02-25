local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.SetUnboxingRewardsClaimed" )
function playerMeta:SetUnboxingRewardsClaimed( claimedTable, nosave )
	if( not claimedTable ) then return end

	net.Start( "BRS.Net.SetUnboxingRewardsClaimed" )
		net.WriteTable( claimedTable )
	net.Send( self )

	self.BRS_UNBOXING_REWARDSCLAIMED = claimedTable

	if( not nosave ) then
		BRICKS_SERVER.UNBOXING.Func.UpdateRewardsClaimedDB( self:SteamID64(), claimedTable )
	end
end

hook.Add( "PlayerInitialSpawn", "BricksServerHooks_PlayerInitialSpawn_UnboxingRewardsLoadData", function( ply ) 
	BRICKS_SERVER.UNBOXING.Func.FetchRewardsClaimedDB( ply:SteamID64(), function( data )
		local claimedTable = util.JSONToTable( data.claimed or "" ) or {}

		ply:SetUnboxingRewardsClaimed( claimedTable, true )
	end )
end )

util.AddNetworkString( "BRS.Net.ClaimUnboxingRewards" )
net.Receive( "BRS.Net.ClaimUnboxingRewards", function( len, ply )
    if( ply:GetUnboxingRewardsTodayClaimed() ) then return end
    
    local claimedTable = ply:GetUnboxingRewardsClaimed()

    local dateTable = os.date( "*t" )
    
    claimedTable[dateTable.year] = claimedTable[dateTable.year] or {}
    claimedTable[dateTable.year][dateTable.month] = claimedTable[dateTable.year][dateTable.month] or {}
    claimedTable[dateTable.year][dateTable.month][dateTable.day] = true

    ply:SetUnboxingRewardsClaimed( claimedTable )

    local rewards = BRICKS_SERVER.CONFIG.UNBOXING.Rewards[(dateTable.wday-1 >= 1 and dateTable.wday-1) or 7]
    if( rewards and table.Count( rewards ) > 0 ) then
        local itemAddList = {}
        for k, v in pairs( rewards ) do
            table.insert( itemAddList, k )
            table.insert( itemAddList, v )
        end

        ply:AddUnboxingInventoryItem( unpack( itemAddList ) )
        ply:SendUnboxingItemNotification( BRICKS_SERVER.Func.L( "unboxingRewardsClaimed" ), unpack( itemAddList ) )
    end
end )