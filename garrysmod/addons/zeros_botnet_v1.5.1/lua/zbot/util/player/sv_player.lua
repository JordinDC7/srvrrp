/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zclib.Player.CleanUp_Add("zbf_bot")
zclib.Player.CleanUp_Add("zbf_controller")
zclib.Player.CleanUp_Add("zbf_rack")

zclib.Gamemode.AssignOwnerOnBuy("zbf_bot")
zclib.Gamemode.AssignOwnerOnBuy("zbf_controller")
zclib.Gamemode.AssignOwnerOnBuy("zbf_rack")

zclib.Hook.Add("zclib_PlayerJoined", "zbf_PlayerJoined", function(ply)

	if not zbf.Coinbase.FirstTimeLoaded then
		zbf.Print("Coinbase not yet initialized, Delay setup for " .. ply:Nick())
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

	local time = zbf.Coinbase.FirstTimeLoaded and 0.5 or 10

	timer.Simple(time, function()
		if not IsValid(ply) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

		// Send the player the bot config
		zclib.Data.Send("zbf_bot_config", ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

		// Send the player the current coinbase values
		zbf.Coinbase.OnJoin(ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		// Send the player his vault
		zbf.Vault.Load(ply)

		timer.Simple(1, function()
			if not IsValid(ply) then return end

			// Send the player all the currencies which he currently has
			zbf.Wallet.UpdateCurrency(ply,ply)

			ply.zbf_FullyInitialized = true
		end)
	end)
end)
