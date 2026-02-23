function BRICKS_SERVER.Func.GangCompleteAchievement( gangID, achievementKey )
	local gangTable = (BRICKS_SERVER_GANGS or {})[gangID]

	if( not gangTable or not BRICKS_SERVER.CONFIG.GANGS.Achievements or not BRICKS_SERVER.CONFIG.GANGS.Achievements[achievementKey] ) then return end

	local gangAchievements = gangTable.Achievements or {}
	gangAchievements[achievementKey] = true

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Achievements", gangAchievements )

	local rewards = BRICKS_SERVER.CONFIG.GANGS.Achievements[achievementKey].Rewards
	if( not rewards or table.Count( rewards ) <= 0 ) then
		BRICKS_SERVER.Func.AddGangInboxEntry( false, gangID, "Achievement", { achievementKey } )
	else
		BRICKS_SERVER.Func.AddGangInboxEntry( false, gangID, "AchievementReward", { achievementKey, BRICKS_SERVER.CONFIG.GANGS.Achievements[achievementKey].Rewards } )
	end
end

hook.Add( "BRS.Hooks.GangBalanceChanged", "BricksServerHooks_BRS_GangBalanceChanged_Achievements", function( gangID, newBalance )
	for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Achievements or {} ) do
		if( v.Type != "Balance" or BRICKS_SERVER.Func.GangGetAchievementCompleted( gangID, k ) ) then continue end

		if( (newBalance or 0) >= ((v.ReqInfo or {})[1] or 0) ) then
			BRICKS_SERVER.Func.GangCompleteAchievement( gangID, k )
		end
	end
end )

hook.Add( "BRS.Hooks.GangMembersChanged", "BricksServerHooks_BRS_GangMembersChanged_Achievements", function( gangID, newMemberCount )
	for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Achievements or {} ) do
		if( v.Type != "Members" or BRICKS_SERVER.Func.GangGetAchievementCompleted( gangID, k ) ) then continue end

		if( (newMemberCount or 0) >= ((v.ReqInfo or {})[1] or 0) ) then
			BRICKS_SERVER.Func.GangCompleteAchievement( gangID, k )
		end
	end
end )

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "storage" ) ) then
	hook.Add( "BRS.Hooks.GangStorageChanged", "BricksServerHooks_BRS_GangStorageChanged_Achievements", function( gangID, newStorageCount )
		for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Achievements or {} ) do
			if( v.Type != "Storage" or BRICKS_SERVER.Func.GangGetAchievementCompleted( gangID, k ) ) then continue end

			if( (newStorageCount or 0) >= ((v.ReqInfo or {})[1] or 0) ) then
				BRICKS_SERVER.Func.GangCompleteAchievement( gangID, k )
			end
		end
	end )
end

hook.Add( "BRS.Hooks.GangLevelChanged", "BricksServerHooks_BRS_GangLevelChanged_Achievements", function( gangID, newLevel )
	for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Achievements or {} ) do
		if( v.Type != "Level" or BRICKS_SERVER.Func.GangGetAchievementCompleted( gangID, k ) ) then continue end

		if( (newLevel or 0) >= ((v.ReqInfo or {})[1] or 0) ) then
			BRICKS_SERVER.Func.GangCompleteAchievement( gangID, k )
		end
	end
end )

util.AddNetworkString( "BRS.Net.GangAchievementClaim" )
net.Receive( "BRS.Net.GangAchievementClaim", function( len, ply ) 
	local gangID = ply:HasGang()

	if( not gangID or not ply:GangHasPermission( "EditInbox" ) ) then return end

	local inboxKey = net.ReadUInt( 16 )

	if( not inboxKey or not BRS_GANG_INBOXES or not BRS_GANG_INBOXES[gangID] or not BRS_GANG_INBOXES[gangID][inboxKey] ) then return end

	local inboxEntry = BRS_GANG_INBOXES[gangID][inboxKey]

	if( inboxEntry.Type != "AchievementReward" ) then return end

	if( inboxEntry.ReqInfo and inboxEntry.ReqInfo[2] ) then
		local rewards = inboxEntry.ReqInfo[2]

		for k, v in pairs( rewards ) do
			local devConfigReward = BRICKS_SERVER.DEVCONFIG.GangRewards[k]

			if( not devConfigReward ) then continue end

			devConfigReward.RewardFunc( gangID, v )
		end
	end

	BRICKS_SERVER.Func.DeleteGangInboxEntry( gangID, inboxKey )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangClaimedAchievement" ) )
end )