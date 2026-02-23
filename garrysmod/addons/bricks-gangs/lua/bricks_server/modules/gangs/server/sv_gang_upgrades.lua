util.AddNetworkString( "BRS.Net.GangUpgrade" )
net.Receive( "BRS.Net.GangUpgrade", function( len, ply ) 
	local upgradeKey = net.ReadString()

	if( not upgradeKey or not ply:HasGang() ) then return end

	if( not ply:GangHasPermission( "PurchaseUpgrades" ) ) then return end

	local upgradeConfig = (BRICKS_SERVER.CONFIG.GANGS.Upgrades or {})[upgradeKey]
	local upgradeDevConfig = BRICKS_SERVER.DEVCONFIG.GangUpgrades[upgradeConfig.Type or upgradeKey]
	local upgradeConfigTiers = upgradeConfig.Tiers or {}

	local upgradeUnlimited = upgradeDevConfig.Unlimited or false

	if( not upgradeConfigTiers and not upgradeUnlimited ) then return end

	local gangUpgrades = BRICKS_SERVER_GANGS[ply:GetGangID()].Upgrades or {}

	local nextUpgradeTier = (gangUpgrades[upgradeKey] or 0)+1
	local nextUpgrade = upgradeConfigTiers[nextUpgradeTier]

	if( (not upgradeUnlimited and not nextUpgrade) or (upgradeUnlimited and BRICKS_SERVER.Func.GangGetUpgradeBought( ply:GetGangID(), upgradeKey )) ) then return end

	if( (upgradeUnlimited and upgradeConfig.Level) or (not upgradeUnlimited and nextUpgrade.Level) ) then
		local levelRequired
		if( upgradeUnlimited ) then
			levelRequired = upgradeConfig.Level
		else
			levelRequired = nextUpgrade.Level
		end

		if( levelRequired and BRICKS_SERVER.Func.GangGetLevel( ply:GetGangID() ) < levelRequired ) then
			DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangIncorrectLevel" ) )
			return
		end
	end

	if( (upgradeUnlimited and upgradeConfig.Group) or (not upgradeUnlimited and nextUpgrade.Group) ) then
		local groupRequired
		if( upgradeUnlimited ) then
			groupRequired = upgradeConfig.Group
		else
			groupRequired = nextUpgrade.Group
		end

		if( not BRICKS_SERVER.Func.IsInGroup( ply, groupRequired ) ) then
			DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangIncorrectGroup" ) )
			return
		end
	end

	local gangBalance, price = BRICKS_SERVER_GANGS[ply:GetGangID()].Money or 0, upgradeConfig.Price or (nextUpgrade.Price or 0)

	if( gangBalance >= price ) then
		if( upgradeConfigTiers ) then
			gangUpgrades[upgradeKey] = nextUpgradeTier
		else
			gangUpgrades[upgradeKey] = 1
		end

		local newBalance = math.Clamp( gangBalance-price, 0, BRICKS_SERVER.Func.GangGetUpgradeInfo( ply:GetGangID(), "MaxBalance" )[1] )
		BRICKS_SERVER.Func.UpdateGangTable( ply:GetGangID(), "Money", newBalance, "Upgrades", gangUpgrades )

		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangUpgradeBought", DarkRP.formatMoney( price ) ) )
	else
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangNotEnoughFunds" ) )
	end
end )

hook.Add( "PlayerLoadout", "BricksServerHooks_PlayerLoadout_GangWeapons", function( ply )
	if( ply:HasGang() ) then
		for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Upgrades or {} ) do
			if( not v.Type or v.Type != "Weapon" or not BRICKS_SERVER.Func.GangGetUpgradeBought( ply:GetGangID(), k ) or not v.ReqInfo or not v.ReqInfo[1] ) then continue end

			ply:Give( v.ReqInfo[1] )
		end
	end
end )

hook.Add( "canDropWeapon", "BricksServerHooks_canDropWeapon_GangWeapons", function( ply, wep )
	if( ply:HasGang() ) then
		for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Upgrades or {} ) do
			if( not v.Type or v.Type != "Weapon" or not BRICKS_SERVER.Func.GangGetUpgradeBought( ply:GetGangID(), k ) or not v.ReqInfo or not v.ReqInfo[1] or v.ReqInfo[1] != wep:GetClass() ) then continue end

			return false
		end
	end
end )

local function OnSpawn( ply )
	if( ply:HasGang() ) then
		timer.Create( "BRS_TIMER_GANGUPGRADE_" .. (ply:SteamID() or "BOT"), 0, 1, function()
			for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Upgrades or {} ) do
				if( (k != "Health" and k != "Armor") or not BRICKS_SERVER.Func.GangGetUpgradeBought( ply:GetGangID(), k ) ) then continue end

				local reqInfo = BRICKS_SERVER.Func.GangGetUpgradeInfo( ply:GetGangID(), k )

				if( reqInfo[1] and reqInfo[1] > 0 ) then
					if( k == "Health" ) then
						ply:SetHealth( ply:Health()+reqInfo[1] )
					elseif( k == "Armor" ) then
						ply:SetArmor( ply:Armor()+reqInfo[1] )
					end
				end
			end
		end )
	end
end

hook.Add( "PlayerSpawn", "BricksServerHooks_PlayerSpawn_GangUpgrades", OnSpawn )
--hook.Add( "PlayerChangedTeam", "BricksServerHooks_PlayerChangedTeam_GangUpgrades", OnSpawn )

hook.Add( "playerGetSalary", "BricksServerHooks_playerGetSalary_GangUpgrades", function( ply, defaultSalary )
	if( ply:HasGang() ) then
		for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Upgrades or {} ) do
			if( k != "Salary" or not BRICKS_SERVER.Func.GangGetUpgradeBought( ply:GetGangID(), k ) ) then continue end

			local reqInfo = BRICKS_SERVER.Func.GangGetUpgradeInfo( ply:GetGangID(), k )
			
			if( reqInfo[1] and reqInfo[1] > 0 ) then
				return false, false, defaultSalary+reqInfo[1]
			end
		end
	end
end )