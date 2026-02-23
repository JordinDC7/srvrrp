/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

// THIS MODULE REQUIRES bLOGS https://www.gmodstore.com/market/view/6016

/*
	Log any transaction from and to the players vault
*/
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "BotNet"
MODULE.Name = "ATM"
MODULE.Colour = Color(86, 114, 194)
MODULE:Setup(function()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	MODULE:Hook("zbf_Crypto_OnBuy", "zbf_Crypto_OnBuy_blogs", function(ply,CryptoShort,CryptoAmount,PurchaseCost)
		if IsValid(ply) and CryptoShort and CryptoAmount and PurchaseCost then
			MODULE:Log("{1} bought " .. math.Round(CryptoAmount,5) .. " " .. CryptoShort .. " for " .. zclib.Money.Display(PurchaseCost), GAS.Logging:FormatPlayer(ply))
		end
	end)

	MODULE:Hook("zbf_Crypto_OnSell", "zbf_Crypto_OnSell_blogs", function(ply,CryptoShort,CryptoAmount,SellPrice)
		if IsValid(ply) and CryptoShort and CryptoAmount and SellPrice then
			MODULE:Log("{1} sold " .. math.Round(CryptoAmount,5) .. " " .. CryptoShort .. " for " .. zclib.Money.Display(SellPrice), GAS.Logging:FormatPlayer(ply))
		end
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	MODULE:Hook("zbf_Crypto_OnSend", "zbf_Crypto_OnSend_blogs", function(ply,CryptoShort,CryptoAmount,Target)
		if IsValid(ply) and CryptoShort and CryptoAmount and IsValid(Target) then
			MODULE:Log("{1} send " .. math.Round(CryptoAmount,5) .. " " .. CryptoShort .. " to {2}", GAS.Logging:FormatPlayer(ply),GAS.Logging:FormatPlayer(Target))
		end
	end)

	MODULE:Hook("zbf_Crypto_OnSendToVault", "zbf_Crypto_OnSendToVault_blogs", function(ply,CryptoShort,CryptoAmount)
		if IsValid(ply) and CryptoShort and CryptoAmount then
			MODULE:Log("{1} send " .. math.Round(CryptoAmount,5) .. " " .. CryptoShort .. " to his Vault!", GAS.Logging:FormatPlayer(ply))
		end
	end)
end)
GAS.Logging:AddModule(MODULE)


/*
	Log any attacks between BotNets
*/
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "BotNet"
MODULE.Name = "BotNet - Attacks"
MODULE.Colour = Color(86, 114, 194)
MODULE:Setup(function()

	MODULE:Hook("zbf_BotNet_Ping", "zbf_BotNet_Ping_blogs", function(Attacker_Ctrl,Attacker_Ply,Target_Ctrl,Target_Ply)
		if IsValid(Attacker_Ply) and IsValid(Target_Ply) then
			MODULE:Log("{1} BotNet performed a ping attack on {2} BotNet", GAS.Logging:FormatPlayer(Attacker_Ply), GAS.Logging:FormatPlayer(Target_Ply))
		end
	end)

	MODULE:Hook("zbf_BotNet_Steal", "zbf_BotNet_Steal_blogs", function(Attacker_Ctrl,Attacker_Ply,Target_Ctrl,Target_Ply,CurrencyList)
		if IsValid(Attacker_Ply) and IsValid(Target_Ply) then
			MODULE:Log("{1} BotNet performed a steal attack on {2} BotNet", GAS.Logging:FormatPlayer(Attacker_Ply), GAS.Logging:FormatPlayer(Target_Ply))
		end
	end)

	MODULE:Hook("zbf_BotNet_Reboot", "zbf_BotNet_Reboot_blogs", function(Attacker_Ctrl,Attacker_Ply,Target_Ctrl,Target_Ply,AttackBotCount)
		if IsValid(Attacker_Ply) and IsValid(Target_Ply) then
			MODULE:Log("{1} BotNet performed a reboot attack on {2} BotNet", GAS.Logging:FormatPlayer(Attacker_Ply), GAS.Logging:FormatPlayer(Target_Ply))
		end
	end)

	MODULE:Hook("zbf_BotNet_Crash", "zbf_BotNet_Crash_blogs", function(Attacker_Ctrl,Attacker_Ply,Target_Ctrl,Target_Ply,AttackBotCount,AttackDamagePerBot)
		if IsValid(Attacker_Ply) and IsValid(Target_Ply) then
			MODULE:Log("{1} BotNet performed a crash attack on {2} BotNet", GAS.Logging:FormatPlayer(Attacker_Ply), GAS.Logging:FormatPlayer(Target_Ply))
		end
	end)

	MODULE:Hook("zbf_BotNet_Highjack", "zbf_BotNet_Highjack_blogs", function(Attacker_Ctrl,Attacker_Ply,Target_Ctrl,Target_Ply,AttackBotCount,HighjackTimePerBot)
		if IsValid(Attacker_Ply) and IsValid(Target_Ply) then
			MODULE:Log("{1} BotNet performed a highjack attack on {2} BotNet", GAS.Logging:FormatPlayer(Attacker_Ply), GAS.Logging:FormatPlayer(Target_Ply))
		end
	end)
end)
GAS.Logging:AddModule(MODULE)

/*
	Log any neuro attacks between BotNet and player
*/
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "BotNet"
MODULE.Name = "Neuro - Attacks"
MODULE.Colour = Color(86, 114, 194)
MODULE:Setup(function()

	MODULE:Hook("zbf_Neuro_Boost", "zbf_Neuro_Boost_blogs", function(Attacker_Ply,Target_Ply)
		if IsValid(Attacker_Ply) and IsValid(Target_Ply) then
			MODULE:Log("{1} BotNet performed a Neuro Boost attack on {2}", GAS.Logging:FormatPlayer(Attacker_Ply), GAS.Logging:FormatPlayer(Target_Ply))
		end
	end)

	MODULE:Hook("zbf_Neuro_Vitality", "zbf_Neuro_Vitality_blogs", function(Attacker_Ply,Target_Ply)
		if IsValid(Attacker_Ply) and IsValid(Target_Ply) then
			MODULE:Log("{1} BotNet performed a Neuro Vitality attack on {2}", GAS.Logging:FormatPlayer(Attacker_Ply), GAS.Logging:FormatPlayer(Target_Ply))
		end
	end)

	MODULE:Hook("zbf_Neuro_Shield", "zbf_Neuro_Shield_blogs", function(Attacker_Ply,Target_Ply)
		if IsValid(Attacker_Ply) and IsValid(Target_Ply) then
			MODULE:Log("{1} BotNet performed a Neuro Shield attack on {2}", GAS.Logging:FormatPlayer(Attacker_Ply), GAS.Logging:FormatPlayer(Target_Ply))
		end
	end)

	MODULE:Hook("zbf_Neuro_Cripple", "zbf_Neuro_Cripple_blogs", function(Attacker_Ply,Target_Ply)
		if IsValid(Attacker_Ply) and IsValid(Target_Ply) then
			MODULE:Log("{1} BotNet performed a Neuro Cripple attack on {2}", GAS.Logging:FormatPlayer(Attacker_Ply), GAS.Logging:FormatPlayer(Target_Ply))
		end
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

	MODULE:Hook("zbf_Neuro_Overheat", "zbf_Neuro_Overheat_blogs", function(Attacker_Ply,Target_Ply)
		if IsValid(Attacker_Ply) and IsValid(Target_Ply) then
			MODULE:Log("{1} BotNet performed a Neuro Overheat attack on {2}", GAS.Logging:FormatPlayer(Attacker_Ply), GAS.Logging:FormatPlayer(Target_Ply))
		end
	end)
end)
GAS.Logging:AddModule(MODULE)

/*
	Log any vault data being saved / load / removed from the server
*/
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "BotNet"
MODULE.Name = "Data"
MODULE.Colour = Color(86, 114, 194)
MODULE:Setup(function()

	MODULE:Hook("zbf_Vault_saved", "zbf_Vault_saved_blogs", function(ply)
		if IsValid(ply) then MODULE:Log("{1} vault data file has been saved on the server!", GAS.Logging:FormatPlayer(ply)) end
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

	MODULE:Hook("zbf_Vault_loaded", "zbf_Vault_loaded_blogs", function(ply)
		if IsValid(ply) then MODULE:Log("{1} vault data file has been loaded from the server!", GAS.Logging:FormatPlayer(ply)) end
	end)

	MODULE:Hook("zbf_Vault_removed", "zbf_Vault_removed_blogs", function(ply)
		if IsValid(ply) then MODULE:Log("{1} vault data file has been removed from the server!", GAS.Logging:FormatPlayer(ply)) end
	end)
end)
GAS.Logging:AddModule(MODULE)
