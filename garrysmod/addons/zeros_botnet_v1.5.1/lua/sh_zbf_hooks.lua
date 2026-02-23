/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

/*

	A bunch of hooks to modify certain aspects

*/

// Can be used to prevent the player from doing certain jobs for any other reason thats not rank or job releated
hook.Add("zbf_Job_Block","zbf_Job_Block_test",function(ply,JobID)
	/*
	if JobID == ZBF_JOB_BOTNET_STEAL and and ply:GetLevel() < 15 then
		return true
	end
	*/
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

// Can be used to block the finish function of a job to execute
hook.Add("zbf_Job_BlockFinish","zbf_Job_PreventFinish_test",function(Controller,JobID)

end)

// Can be used to overwrite the Wallet size for any other reason then > zbf.config.Controller.wallet_size
hook.Add("zbf_Controller_GetWalletSize","zbf_Controller_GetWalletSize_test",function(Controller,ply,walletsize)

end)

// Can be used to overwrite how many bots the player can buy / spawn
hook.Add("zbf_Controller_GetBotLimit","zbf_Controller_GetBotLimit_test",function(Controller,ply,limit)

end)

// Can be used to overwrite which bots the player can buy for any other reason thats not rank or job releated
hook.Add("zbf_Bot_CanBuy","zbf_Bot_CanBuy_test",function(ply,BotID)		
	/*
	// In this examble if the player is a scammer then we only allow him to use the scam bot defined in the bot config file.
	if IsValid(ply) and ply:Team() == TEAM_ZBF_SCAMMER then
		if BotID == ZBF_BOT_SCAM then
			return true
		else
			// return CanBuy, Hide
			return false, true
		end
	end
	*/
end)

// Can be used to change what currency type and how much off it the player would get for the specified job
hook.Add("zbf_Modify_JobPayment","zbf_Modify_JobPayment_test",function(ply,Controller,JobID,CurrencyType,CurrencyAmount)

	if IsValid(ply) and not ply:Alive() then CurrencyAmount = 0 end

	/*
	// Double the payment if the player is a admin
	if ply:IsSuperAdmin() then
		return CurrencyAmount * 2
	end
	*/
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c



/*

	CRYPTO

*/
// Can be used to prevent certain players to mine this crypto currency
hook.Add("zbf_Crypto_CanMine","zbf_Crypto_CanMine_test",function(ply,CryptoShort)
	/*
	ply = The player entity
	CryptoShort = The Crypto Currencys Short ID, Examble: "BTC" or "DOGE"

	If you need the list id you can use > zbf.Currency.GetID(CryptoShort)

	if ply:Nick() == "DOGE Hater" and CryptoShort == "DOGE" then return false end
	*/
end)

// Can be used to prevent certain players to buy this crypto currency from the ATM
hook.Add("zbf_Crypto_CanBuy","zbf_Crypto_CanBuy_test",function(ply,CryptoShort)
	/*
	ply = The player entity
	CryptoShort = The Crypto Currencys Short ID, Examble: "BTC" or "DOGE"

	If you need the list id you can use > zbf.Currency.GetID(CryptoShort)

	if ply:Nick() == "DOGE Hater" and CryptoShort == "DOGE" then return false end
	*/
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

// Gets called when a player buys crypto from a ATM
hook.Add("zbf_Crypto_OnBuy","zbf_Crypto_OnBuy_test",function(ply,CryptoShort,CryptoAmount,PurchaseCost)

end)

// Can be used to prevent certain players to sell this crypto currency from the ATM
hook.Add("zbf_Crypto_CanSell","zbf_Crypto_CanSell_test",function(ply,CryptoShort)
	/*
	ply = The player entity
	CryptoShort = The Crypto Currencys Short ID, Examble: "BTC" or "DOGE"

	If you need the list id you can use > zbf.Currency.GetID(CryptoShort)

	if ply:Nick() == "DOGE Hater" and CryptoShort == "DOGE" then return false end
	*/
end)

// Gets called when a player sells crypto from a ATM
hook.Add("zbf_Crypto_OnSell","zbf_Crypto_OnSell_test",function(ply,CryptoShort,CryptoAmount,SellPrice,ProfitAmount,IsGain)
	// TODO
	/*
	ProfitAmount = the difference between buy and sell value
	IsGain = simply check profitAmount, if neg = false, else true
	*/
end)

// Can be used to prevent certain players to send this crypto currency from the ATM
hook.Add("zbf_Crypto_CanSend","zbf_Crypto_CanSend_test",function(ply,CryptoShort)
	/*
	ply = The player entity
	CryptoShort = The Crypto Currencys Short ID, Examble: "BTC" or "DOGE"

	If you need the list id you can use > zbf.Currency.GetID(CryptoShort)

	if ply:Nick() == "DOGE Hater" and CryptoShort == "DOGE" then return false end
	*/
end)

// Gets called when a player sends crypto from a ATM
hook.Add("zbf_Crypto_OnSend","zbf_Crypto_OnSend_test",function(ply,CryptoShort,CryptoAmount,Target)

end)



/*

	BOTNET
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

*/
// Gets called when one botnet pings another BotNet
hook.Add("zbf_BotNet_Ping","zbf_BotNet_Ping_test",function(Attacker_Ctrl,Attacker_Ply,Target_Ctrl,Target_Ply)

end)

// Gets called when one botnet steals money from another BotNet
hook.Add("zbf_BotNet_Steal","zbf_BotNet_Steal_test",function(Attacker_Ctrl,Attacker_Ply,Target_Ctrl,Target_Ply,CurrencyList)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

end)

// Gets called when one botnet performs a reboot attack on another BotNet
hook.Add("zbf_BotNet_Reboot","zbf_BotNet_Reboot_test",function(Attacker_Ctrl,Attacker_Ply,Target_Ctrl,Target_Ply,AttackBotCount)

end)

// Gets called when one botnet performs a crash attack on another BotNet
hook.Add("zbf_BotNet_Crash","zbf_BotNet_Crash_test",function(Attacker_Ctrl,Attacker_Ply,Target_Ctrl,Target_Ply,AttackBotCount,AttackDamagePerBot)

end)

// Gets called when one botnet performs a highjack attack on another BotNet
hook.Add("zbf_BotNet_Highjack","zbf_BotNet_Highjack_test",function(Attacker_Ctrl,Attacker_Ply,Target_Ctrl,Target_Ply,AttackBotCount,HighjackTimePerBot)

end)



/*

	NEURO

*/
// Can be used to not even allow the player to target this specific player for neuro attacks
hook.Add("zbf_Neuro_CanTarget","zbf_Neuro_CanTarget_test",function(Attacker_Ply,Target_Ply)
	/*
	// You cant target superadmins, except if you are a superadmin
	if not Attacker_Ply:IsSuperAdmin() and Target_Ply:IsSuperAdmin() then return false end
	*/
end)

// Can be used to prevent a neuro attack on another player
hook.Add("zbf_Neuro_PreventAttack","zbf_Neuro_PreventAttack_test",function(Attacker_Ply,Target_Ply)

end)

// Gets called when one botnet performs a neuro boost attack on another player
hook.Add("zbf_Neuro_Boost","zbf_Neuro_Boost_test",function(Attacker_Ply,Target_Ply)

end)

// Gets called when one botnet performs a neuro vitality attack on another player
hook.Add("zbf_Neuro_Vitality","zbf_Neuro_Vitality_test",function(Attacker_Ply,Target_Ply)

end)

// Gets called when one botnet performs a neuro Shield attack on another player
hook.Add("zbf_Neuro_Shield","zbf_Neuro_Shield_test",function(Attacker_Ply,Target_Ply)

end)

// Gets called when one botnet performs a neuro Cripple attack on another player
hook.Add("zbf_Neuro_Cripple","zbf_Neuro_Cripple_test",function(Attacker_Ply,Target_Ply)

end)

// Gets called when one botnet performs a neuro Overheat attack on another player
hook.Add("zbf_Neuro_Overheat","zbf_Neuro_Overheat_test",function(Attacker_Ply,Target_Ply)

end)



/*

	DATA

*/
// Called when a data file got updated / created on the server at garrysmod\data\zbf\vault
// NOTE Returning true in this hook will prevent the data to be saved as a file on the SERVER
hook.Add("zbf_Vault_save","zbf_Vault_save_test",function(ply,Data,steamID64)
	/*
		Save the Data to a mysql database?
	*/
end)

// Called when a data file gets loaded on the server at garrysmod\data\zbf\vault
// NOTE Returning anything in this hook will use the returned data instead of loading from a file
hook.Add("zbf_Vault_load","zbf_Vault_load_test",function(ply)
	/*
		Load the Data from a mysql database?
		return Data
	*/
end)

// Called when a data file got removed from the server at garrysmod\data\zbf\vault
// NOTE Returning true in this hook will prevent the data file to be removed from the SERVER
hook.Add("zbf_Vault_remove","zbf_Vault_remove_test",function(ply)
	/*
		Remove the players data entry from a mysql database?
	*/
end)





// Return true to prevent any interactions going in and from this controller (No Power)
local w, h = 270, 180
local vec = Vector(12.6, 0, 51.4)
local ang = Angle(0, 90, 85)
hook.Add("zbf_Controller_DisableInteraction", "zbf_Controller_DisableInteraction_test", function(Controller, ply)
	if not IsValid(Controller) then return end
	/*
	if Controller.Power <= 0 then
		if SERVER then
			zclib.Notify(ply, "No power!", 1)

			return true
		else
			cam.Start3D2D(Controller:LocalToWorld(vec), Controller:LocalToWorldAngles(ang), 0.05)
				draw.RoundedBox(5, -w / 2, -h / 2, w, h, zclib.colors[ "ui00" ])
				surface.SetDrawColor(zclib.colors[ "red01" ])
				surface.SetMaterial(zclib.Materials.Get("close"))
				surface.DrawTexturedRectRotated(0, 0, 160, 160, 0)
			cam.End3D2D()

			return true
		end
	end
	*/
end)
