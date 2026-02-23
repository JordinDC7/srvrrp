util.AddNetworkString( "BRS.Net.OpenGangMenu" )
function BRICKS_SERVER.Func.OpenGangMenu( ply )
	net.Start( "BRS.Net.OpenGangMenu" )
	net.Send( ply )

	if( BRICKS_SERVER.Func.GangSendCommandData and ply:HasGang() ) then
		BRICKS_SERVER.Func.GangSendCommandData( ply:GetGangID(), ply )
	end
end

hook.Add( "PlayerSay", "BricksServerHooks_PlayerSay_OpenGangMenu", function( ply, text )
	local commandText = string.Trim( string.lower( text or "" ) )

	if( BRICKS_SERVER.GANGS.LUACFG.MenuCommands[commandText] ) then
		BRICKS_SERVER.Func.OpenGangMenu( ply )
		return ""
	end
end )

concommand.Add( "gang", function( ply, cmd, args )
	if( IsValid( ply ) and ply:IsPlayer() ) then
		BRICKS_SERVER.Func.OpenGangMenu( ply )
	end
end )

function BRICKS_SERVER.Func.SetGangBalance( gangID, amount )
	if( not gangID or not amount or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

	local maxBalance = BRICKS_SERVER.Func.GangGetUpgradeInfo( gangID, "MaxBalance" )[1]

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Money", math.Clamp( amount, 0, maxBalance ) )
end

function BRICKS_SERVER.Func.AddGangBalance( gangID, amount )
	local gangBalance = BRICKS_SERVER_GANGS[gangID or 0].Money or 0

	BRICKS_SERVER.Func.SetGangBalance( gangID, gangBalance+amount )
end

function BRICKS_SERVER.Func.TakeGangBalance( gangID, amount )
	local gangBalance = BRICKS_SERVER_GANGS[gangID or 0].Money or 0

	BRICKS_SERVER.Func.SetGangBalance( gangID, gangBalance-amount )
end

function BRICKS_SERVER.Func.CheckGangLevelUp( gangID )
	local gangLevel = BRICKS_SERVER.Func.GetGangLevel( gangID )

	if( gangLevel >= BRICKS_SERVER.CONFIG.GANGS["Max Level"] ) then return end

	local currentXP = BRICKS_SERVER_GANGS[gangID or 0].Experience or 0
	if( currentXP >= BRICKS_SERVER.Func.GetGangExpToLevel( 0, gangLevel+1 ) ) then
		local newLevel = gangLevel
		for i = gangLevel+1, BRICKS_SERVER.CONFIG.GANGS["Max Level"] do
			if( currentXP >= BRICKS_SERVER.Func.GetGangExpToLevel( 0, i ) ) then
				newLevel = i
			else
				break
			end
		end

		if( newLevel > gangLevel ) then
			BRICKS_SERVER.Func.SetGangLevel( gangID, newLevel )
		end
	end
end

function BRICKS_SERVER.Func.SetGangExperience( gangID, amount )
	if( not gangID or not amount or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Experience", math.max( amount, 0 ) )
end

function BRICKS_SERVER.Func.AddGangExperience( gangID, amount, optionalPly )
	if( not gangID or not amount or amount <= 0 or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

	amount = hook.Run( "BRS.Hooks.GangExpAddModify", gangID, amount, optionalPly ) or amount

	BRICKS_SERVER.Func.SetGangExperience( gangID, (BRICKS_SERVER_GANGS[gangID].Experience or 0)+amount )

	BRICKS_SERVER.Func.CheckGangLevelUp( gangID )

	hook.Run( "BRS.Hooks.GangExperienceEarned", gangID, amount )
end

function BRICKS_SERVER.Func.SetGangLevel( gangID, newLevel )
	if( not gangID or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

	local finalLevel = math.Clamp( (newLevel or 0), 0, BRICKS_SERVER.CONFIG.GANGS["Max Level"] )

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Level", finalLevel )

	hook.Run( "BRS.Hooks.GangLevelChanged", gangID, finalLevel )
end

function BRICKS_SERVER.Func.AddGangLevel( gangID, levels )
	if( not gangID or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

	BRICKS_SERVER.Func.SetGangLevel( gangID, ((BRICKS_SERVER_GANGS[gangID].Level or 0)+levels) )
end

function BRICKS_SERVER.Func.GetGangLevel( gangID )
	if( not gangID or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return 0 end

	return BRICKS_SERVER_GANGS[gangID].Level or 0
end

function BRICKS_SERVER.Func.GangKickMember( gangID, memberSteamID )
	if( not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return false end

	local gangMembers = BRICKS_SERVER_GANGS[gangID].Members or {}
	
	gangMembers[memberSteamID] = nil

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Members", gangMembers )

	local memberPly = player.GetBySteamID( memberSteamID )

	if( IsValid( memberPly ) ) then
		DarkRP.notify( memberPly, 1, 5, BRICKS_SERVER.Func.L( "gangKicked", BRICKS_SERVER_GANGS[gangID].Name )  )

		memberPly:SetGangID( 0 )
	end

	return true
end

function BRICKS_SERVER.Func.GangMemberSetRank( gangID, memberSteamID, newRank )
	if( not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return false end

	if( not BRICKS_SERVER_GANGS[gangID].Roles or not BRICKS_SERVER_GANGS[gangID].Roles[newRank] ) then return false end

	local gangMembers = BRICKS_SERVER_GANGS[gangID].Members or {}

	if( not gangMembers[memberSteamID] ) then return false end

	gangMembers[memberSteamID][2] = newRank

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Members", gangMembers )

	return true
end

util.AddNetworkString( "BRS.Net.CreateGang" )
net.Receive( "BRS.Net.CreateGang", function( len, ply ) 
	local gangIcon = string.Trim( net.ReadString() )
	local gangName = string.Trim( net.ReadString() )

	if( not gangIcon or not gangName ) then return end

	if( ply:HasGang() ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangAlreadyIn" ) )
		return
	end

	if( not BRICKS_SERVER.Func.CheckGangName( gangName ) ) then return end
	if( not BRICKS_SERVER.Func.CheckGangIconURL( gangIcon ) ) then return end

	local price = (BRICKS_SERVER.CONFIG.GANGS["Creation Fee"] or 0)
	if( ply:getDarkRPVar( "money" ) >= price ) then
		if( price > 0 ) then
			ply:addMoney( -price )
			DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangCreatedFor", DarkRP.formatMoney( price ) ) )
		else
			DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangCreated" ) )
		end

		BRICKS_SERVER.Func.CreateGangTable( ply, gangName, gangIcon )

		if( BRICKS_SERVER.Func.GangAddActivity ) then
			BRICKS_SERVER.Func.GangAddActivity( ply:GetGangID(), ply:Nick() .. " founded the gang.", Color( 104, 220, 145 ), ply:SteamID() )
		end
	else
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangCreationNoMoney", DarkRP.formatMoney( price ) ) )
	end
end )

util.AddNetworkString( "BRS.Net.SaveGangRoles" )
net.Receive( "BRS.Net.SaveGangRoles", function( len, ply ) 
	local compressedGangRoles = net.ReadData( len )

	if( not compressedGangRoles ) then return end

	if( not ply:GangHasPermission( "EditRoles" ) ) then return end

	if( not ply:HasGang() ) then return end

	if( (ply.BRS_NEXTGANGEDIT or 0) > CurTime() ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangWaitBeforeSaving", BRICKS_SERVER.DEVCONFIG.GangNextEditTime ) )
		return
	end

	ply.BRS_NEXTGANGEDIT = CurTime()+BRICKS_SERVER.DEVCONFIG.GangNextEditTime

	local unCompressedGangRoles = util.Decompress( compressedGangRoles )
	local newGangRoles = util.JSONToTable( unCompressedGangRoles )

	if( not newGangRoles or table.Count( newGangRoles ) <= 0 or table.Count( newGangRoles ) > BRICKS_SERVER.DEVCONFIG.GangRankLimit ) then return end

	local oldRoles = BRICKS_SERVER_GANGS[ply:GetGangID()].Roles or {}

	local newRolesNameID = {}
	for k, v in pairs( newGangRoles ) do
		newRolesNameID[v[1]] = k
	end

	local gangMembers = BRICKS_SERVER_GANGS[ply:GetGangID()].Members or {}
	for k, v in pairs( gangMembers ) do
		local oldRoleName = (oldRoles[v[2]] or {})[1] or ""
		if( newRolesNameID[oldRoleName] ) then
			v[2] = newRolesNameID[oldRoleName]
		else
			v[2] = #newGangRoles
		end
	end

	BRICKS_SERVER.Func.UpdateGangTable( ply:GetGangID(), "Roles", newGangRoles, "Members", gangMembers )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangRolesUpdated" ) )
end )

util.AddNetworkString( "BRS.Net.GangSetRank" )
net.Receive( "BRS.Net.GangSetRank", function( len, ply ) 
	local memberSteamID = net.ReadString()
	local newRank = net.ReadUInt( 16 )

	if( not memberSteamID or not newRank ) then return end

	if( not ply:GangHasPermission( "ChangePlayerRoles" ) ) then return end

	if( not ply:GangCanTargetMember( memberSteamID ) ) then 
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangCannotTarget" ) )
		return
	end

	if( not ply:HasGang() ) then return end

	if( not BRICKS_SERVER_GANGS[ply:GetGangID()].Roles or not BRICKS_SERVER_GANGS[ply:GetGangID()].Roles[newRank] ) then 
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangRankNotExists" ) )
		return
	end

	local gangMembers = BRICKS_SERVER_GANGS[ply:GetGangID()].Members or {}

	if( gangMembers[memberSteamID][2] == newRank ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangPlayerAlreadyRank" ) )
		return
	end

	if( BRICKS_SERVER_GANGS[ply:GetGangID()].Owner != ply:SteamID() and newRank <= gangMembers[ply:SteamID()][2] ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangCantPromote" ) )
		return
	end

	local success = BRICKS_SERVER.Func.GangMemberSetRank( ply:GetGangID(), memberSteamID, newRank )

	if( success ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangRankSet" ) )
	else
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangRankSetFail" ) )
	end
end )

util.AddNetworkString( "BRS.Net.SaveGangSettings" )
net.Receive( "BRS.Net.SaveGangSettings", function( len, ply ) 
	if( (ply.BRS_NEXTGANGEDIT or 0) > CurTime() ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangWaitBeforeSaving", BRICKS_SERVER.DEVCONFIG.GangNextEditTime ) )
		return
	end

	ply.BRS_NEXTGANGEDIT = CurTime()+BRICKS_SERVER.DEVCONFIG.GangNextEditTime

	if( not ply:GangHasPermission( "EditSettings" ) or not ply:HasGang() ) then return end

	local gangName, gangIcon = net.ReadString(), net.ReadString()
	if( not gangName or not gangIcon ) then return end

	-- local gangName, gangIcon, gangColour = net.ReadString(), net.ReadString(), net.ReadColor()
	-- if( not gangName or not gangIcon or not gangColour ) then return end

	local gangTable = BRICKS_SERVER_GANGS[ply:GetGangID()]
	if( not gangTable ) then return end

	local nameChanged
	if( gangName != gangTable.Name ) then
		nameChanged = true

		gangName = string.Trim( gangName )
		if( not BRICKS_SERVER.Func.CheckGangName( gangName ) ) then return end
	end

	local iconChanged
	if( gangIcon != gangTable.Icon ) then
		iconChanged = true

		gangIcon = string.Trim( gangIcon )
		if( not BRICKS_SERVER.Func.CheckGangIconURL( gangIcon ) ) then return end
	end

	if( nameChanged and iconChanged ) then
		BRICKS_SERVER.Func.UpdateGangTable( ply:GetGangID(), "Name", gangName, "Icon", gangIcon )
	elseif( nameChanged ) then
		BRICKS_SERVER.Func.UpdateGangTable( ply:GetGangID(), "Name", gangName )
	elseif( iconChanged ) then
		BRICKS_SERVER.Func.UpdateGangTable( ply:GetGangID(), "Icon", gangIcon )
	end

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangSettingsUpdated" ) )
end )

util.AddNetworkString( "BRS.Net.GangKick" )
net.Receive( "BRS.Net.GangKick", function( len, ply ) 
	local memberSteamID = net.ReadString()

	if( not memberSteamID ) then return end

	if( not ply:GangHasPermission( "KickPlayers" ) ) then return end

	if( ply:SteamID() == memberSteamID or not ply:GangCanTargetMember( memberSteamID ) ) then 
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangCannotTarget" ) )
		return
	end

	if( not ply:HasGang() ) then return end

	local gangMembers = BRICKS_SERVER_GANGS[ply:GetGangID()].Members or {}
	local memberName = gangMembers[memberSteamID][1] or BRICKS_SERVER.Func.L( "nil" )

	local success = BRICKS_SERVER.Func.GangKickMember( ply:GetGangID(), memberSteamID )

	if( success ) then
		if( BRICKS_SERVER.Func.GangAddActivity ) then
			BRICKS_SERVER.Func.GangAddActivity( ply:GetGangID(), ply:Nick() .. " removed " .. memberName .. " from the gang.", Color( 255, 120, 120 ), ply:SteamID() )
		end

		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangPlayerKicked", memberName ) )
	else
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangPlayerKickError" ) )
	end
end )

util.AddNetworkString( "BRS.Net.GangInvite" )
util.AddNetworkString( "BRS.Net.GangInviteSend" )
net.Receive( "BRS.Net.GangInvite", function( len, ply ) 
	local victimSteamID = net.ReadString()

	if( not victimSteamID or ply:SteamID() == victimSteamID ) then return end

	if( not ply:GangHasPermission( "InvitePlayers" ) ) then return end

	if( not ply:HasGang() ) then return end

	if( (ply.lastGangInvite or 0) > CurTime() ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangWaitBeforeInvite" ) )
		return
	end

	local victimPly = player.GetBySteamID( victimSteamID )

	if( not IsValid( victimPly ) ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangPlayerOffline" ) )
		return
	end

	if( victimPly:HasGangInvite( ply:GetGangID() ) ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangPlayerAlreadyInvited" ) )
		return
	end

	ply.lastGangInvite = CurTime()+5

	local gangName = BRICKS_SERVER_GANGS[ply:GetGangID()].Name or BRICKS_SERVER.Func.L( "gangNew" )

	BRICKS_SERVER.Func.AddGangInboxEntry( victimSteamID, false, "GangInvite", { ply:GetGangID(), gangName } )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangPlayerInvited", victimPly:Nick() ) )
	DarkRP.notify( victimPly, 1, 5, BRICKS_SERVER.Func.L( "gangInviteReceived", gangName ) )
end )

util.AddNetworkString( "BRS.Net.GangInviteAccept" )
net.Receive( "BRS.Net.GangInviteAccept", function( len, ply ) 
	local gangID = net.ReadUInt( 16 )

	if( not gangID or not BRICKS_SERVER_GANGS[gangID] ) then return end

	if( ply:HasGang() ) then 
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangLeaveCurrent" ) )
		return 
	end

	local inboxKey = ply:HasGangInvite( gangID )

	if( not inboxKey ) then return end

	BRICKS_SERVER.Func.DeleteGangInboxEntry( ply:SteamID(), inboxKey )

	local maxMembers = BRICKS_SERVER.Func.GangGetUpgradeInfo( gangID, "MaxMembers" )[1] or 0
	local gangMembers = BRICKS_SERVER_GANGS[gangID].Members or {}

	if( table.Count( gangMembers ) >= maxMembers ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangReachedMemberLimit" ) )
		return
	end

	BRICKS_SERVER.Func.SendGangTable( ply, gangID )

	gangMembers[ply:SteamID()] = { ply:Nick(), #(BRICKS_SERVER_GANGS[gangID].Roles or {}) }

	ply:SetGangID( gangID )

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Members", gangMembers )

	if( BRICKS_SERVER.Func.GangAddActivity ) then
		BRICKS_SERVER.Func.GangAddActivity( gangID, ply:Nick() .. " joined the gang.", Color( 110, 190, 255 ), ply:SteamID() )
	end

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangJoined", (BRICKS_SERVER_GANGS[gangID].Name or BRICKS_SERVER.Func.L( "nil" )) ) )

	hook.Run( "BRS.Hooks.GangMembersChanged", gangID, table.Count( gangMembers ) )

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "associations" ) ) then
		BRICKS_SERVER.Func.SendGangAssociations( ply )
	end
	
	BRICKS_SERVER.Func.SendGangInbox( ply )

	hook.Run( "BRS.Hooks.GangInviteAccepted", ply )
end )

util.AddNetworkString( "BRS.Net.GangDepositMoney" )
net.Receive( "BRS.Net.GangDepositMoney", function( len, ply ) 
	local depositAmount = net.ReadUInt( 32 )

	if( not depositAmount or depositAmount < (BRICKS_SERVER.CONFIG.GANGS["Minimum Deposit"] or 1000) ) then return end

	if( not ply:GangHasPermission( "DepositMoney" ) ) then return end

	if( not ply:HasGang() ) then return end

	if( ply:getDarkRPVar( "money" ) < depositAmount ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangNotEnoughMoney" ) )
		return
	end

	local gangBalance = BRICKS_SERVER_GANGS[ply:GetGangID()].Money or 0

	local maxBalance = BRICKS_SERVER.Func.GangGetUpgradeInfo( (ply:GetGangID()), "MaxBalance" )[1]

	if( gangBalance+depositAmount > maxBalance ) then return end

	ply:addMoney( -depositAmount )

	BRICKS_SERVER.Func.AddGangBalance( ply:GetGangID(), depositAmount )

	if( BRICKS_SERVER.Func.GangAddContribution ) then
		BRICKS_SERVER.Func.GangAddContribution( ply:GetGangID(), ply, "Deposited", depositAmount )
	end

	if( BRICKS_SERVER.Func.GangAddActivity ) then
		BRICKS_SERVER.Func.GangAddActivity( ply:GetGangID(), ply:Nick() .. " deposited " .. DarkRP.formatMoney( depositAmount ) .. ".", Color( 82, 217, 124 ), ply:SteamID() )
	end

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangDepositedMoney", DarkRP.formatMoney( depositAmount ) ) )

	hook.Run( "BRS.Hooks.GangBalanceChanged", ply:GetGangID(), math.Clamp( gangBalance+depositAmount, 0, maxBalance ) )
end )

util.AddNetworkString( "BRS.Net.GangWithdrawMoney" )
net.Receive( "BRS.Net.GangWithdrawMoney", function( len, ply ) 
	local withdrawAmount = net.ReadUInt( 32 )

	if( not withdrawAmount or withdrawAmount < (BRICKS_SERVER.CONFIG.GANGS["Minimum Withdraw"] or 1000) ) then return end

	if( not ply:GangHasPermission( "WithdrawMoney" ) ) then return end

	if( not ply:HasGang() ) then return end

	local gangBalance = BRICKS_SERVER_GANGS[ply:GetGangID()].Money or 0

	if( withdrawAmount > gangBalance ) then return end

	local maxBalance = BRICKS_SERVER.Func.GangGetUpgradeInfo( ply:GetGangID(), "MaxBalance" )[1]

	BRICKS_SERVER.Func.TakeGangBalance( ply:GetGangID(), withdrawAmount )

	if( BRICKS_SERVER.Func.GangAddContribution ) then
		BRICKS_SERVER.Func.GangAddContribution( ply:GetGangID(), ply, "Withdrawn", withdrawAmount )
	end

	if( BRICKS_SERVER.Func.GangAddActivity ) then
		BRICKS_SERVER.Func.GangAddActivity( ply:GetGangID(), ply:Nick() .. " withdrew " .. DarkRP.formatMoney( withdrawAmount ) .. ".", Color( 238, 133, 93 ), ply:SteamID() )
	end

	ply:addMoney( withdrawAmount )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangWithdrewMoney", DarkRP.formatMoney( withdrawAmount ) ) )
end )

util.AddNetworkString( "BRS.Net.GangDisband" )
net.Receive( "BRS.Net.GangDisband", function( len, ply ) 
	if( not ply:HasGang() ) then return end

	local gangTable = BRICKS_SERVER_GANGS[ply:GetGangID()]

	if( (gangTable.Owner or "") != ply:SteamID() ) then return end

	BRICKS_SERVER.Func.DeleteGangTable( ply:GetGangID() )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangDisbanded", (gangTable.Name or BRICKS_SERVER.Func.L( "nil" )) ) )
end )

util.AddNetworkString( "BRS.Net.GangTransfer" )
net.Receive( "BRS.Net.GangTransfer", function( len, ply ) 
	local memberSteamID = net.ReadString()

	if( not memberSteamID or not ply:HasGang() ) then return end

	local gangTable = BRICKS_SERVER_GANGS[ply:GetGangID()]

	if( (gangTable.Owner or "") != ply:SteamID() or memberSteamID == (gangTable.Owner or "") or not gangTable.Members or not gangTable.Members[memberSteamID] ) then return end

	BRICKS_SERVER.Func.UpdateGangTable( ply:GetGangID(), "Owner", memberSteamID )

	if( BRICKS_SERVER.Func.GangAddActivity ) then
		BRICKS_SERVER.Func.GangAddActivity( ply:GetGangID(), ply:Nick() .. " transferred ownership to " .. (gangTable.Members[memberSteamID][1] or "Unknown") .. ".", Color( 155, 128, 255 ), ply:SteamID() )
	end

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangOwnershipTransfered", (gangTable.Name or BRICKS_SERVER.Func.L( "nil" )), (gangTable.Members[memberSteamID][1] or BRICKS_SERVER.Func.L( "nil" )) ) )
end )

util.AddNetworkString( "BRS.Net.GangLeave" )
net.Receive( "BRS.Net.GangLeave", function( len, ply ) 
	if( not ply:HasGang() ) then return end

	local gangMembers = BRICKS_SERVER_GANGS[ply:GetGangID()].Members

	if( (BRICKS_SERVER_GANGS[ply:GetGangID()].Owner or "") == ply:SteamID() or not gangMembers or not gangMembers[ply:SteamID()] ) then return end

	gangMembers[ply:SteamID()] = nil

	BRICKS_SERVER.Func.UpdateGangTable( ply:GetGangID(), "Members", gangMembers )

	DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangLeft", (BRICKS_SERVER_GANGS[ply:GetGangID()].Name or BRICKS_SERVER.Func.L( "nil" )) .. "!" ) )

	if( BRICKS_SERVER.Func.GangAddActivity ) then
		BRICKS_SERVER.Func.GangAddActivity( ply:GetGangID(), ply:Nick() .. " left the gang.", Color( 255, 140, 102 ), ply:SteamID() )
	end

	ply:SetGangID( 0 )
end )

util.AddNetworkString( "BRS.Net.GangNetworkMessage" )
function BRICKS_SERVER.Func.AddGangChatMessage( gangID, message, memberSteamID )
	if( not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] or not message ) then return end

	if( not BRS_GANG_CHATS ) then
		BRS_GANG_CHATS = {}
	end

	if( not BRS_GANG_CHATS[gangID] ) then
		BRS_GANG_CHATS[gangID] = {}
	end

	local messageTable = { os.time(), message, memberSteamID }
	table.insert( BRS_GANG_CHATS[gangID], messageTable )

	local onlineMembers = {}
	for k, v in pairs( BRICKS_SERVER_GANGS[gangID].Members ) do
		local ply = player.GetBySteamID( k )

		if( IsValid( ply ) ) then
			table.insert( onlineMembers, ply )
		end
	end

	net.Start( "BRS.Net.GangNetworkMessage" )
		net.WriteInt( messageTable[1], 32 )
		net.WriteString( messageTable[2] )
		net.WriteString( messageTable[3] )
	net.Send( onlineMembers )
end

util.AddNetworkString( "BRS.Net.GangSendMessage" )
net.Receive( "BRS.Net.GangSendMessage", function( len, ply ) 
	if( BRICKS_SERVER.CONFIG.GANGS["Disable Gang Chat"] ) then return end

	if( not ply:HasGang() ) then return end

	if( not ply:GangHasPermission( "SendMessages" ) ) then return end

	local message = net.ReadString()

	if( not message or string.len( message ) > 500 ) then return end

	BRICKS_SERVER.Func.AddGangChatMessage( ply:GetGangID(), message, ply:SteamID() )
end )

hook.Add( "EntityTakeDamage", "BricksServerHooks_EntityTakeDamage_GangFF", function( target, dmginfo )
	if( not BRICKS_SERVER.CONFIG.GANGS["Gang Friendly Fire"] and target:IsPlayer() and IsValid( dmginfo:GetAttacker() ) and dmginfo:GetAttacker():IsPlayer() and target:HasGang() and target:GetGangID() == dmginfo:GetAttacker():GetGangID() ) then
		local shouldTakeDamage = hook.Run( "BRS.Hooks.CanTakeDamageFF", target, dmginfo:GetAttacker() )
		if( not shouldTakeDamage ) then
			return true
		end
	end
end )

util.AddNetworkString( "BRS.Net.RequestPlyGangInfo" )
util.AddNetworkString( "BRS.Net.SendPlyGangInfo" )
net.Receive( "BRS.Net.RequestPlyGangInfo", function( len, ply )
    if( CurTime() < (ply.BRS_REQUEST_PLYGANGINFO_COOLDOWN or 0) ) then return end

    ply.BRS_REQUEST_PLYGANGINFO_COOLDOWN = CurTime()+1

	local requestSteamID = net.ReadString()
	
	if( not requestSteamID ) then return end

	local requestPly = player.GetBySteamID( requestSteamID )

	if( not IsValid( requestPly ) ) then return end

	local gangID = requestPly:GetGangID()
	local gangTable = BRICKS_SERVER_GANGS[gangID or 0]
	if( gangTable ) then
		local groupData = requestPly:GangGetGroupData()
		local groupColor = (groupData or {})[2] or Color( 255, 255, 255 )
		net.Start( "BRS.Net.SendPlyGangInfo" )
			net.WriteString( requestSteamID )
			net.WriteBool( true )
			net.WriteString( gangTable.Name or "NIL" )
			net.WriteString( gangTable.Icon or "" )
			net.WriteString( (groupData or {})[1] or "NIL" )
			net.WriteColor( Color( groupColor.r, groupColor.g, groupColor.b ) )
		net.Send( ply )
	else
		net.Start( "BRS.Net.SendPlyGangInfo" )
			net.WriteString( requestSteamID )
		net.Send( ply )
	end
end )
