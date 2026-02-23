/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end

hook.Add("AddToolMenuCategories", "zbf_CreateCategories", function()
	spawnmenu.AddToolCategory("Options", "zbf_options", "BotNet")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

hook.Add("PopulateToolMenu", "zbf_PopulateMenus", function()
	spawnmenu.AddToolMenuOption("Options", "zbf_options", "zbf_Admin_Settings", "Admin Settings", "", "", function(CPanel)
		zclib.Settings.OptionPanel("Bot", nil, Color(86, 114, 194), zclib.colors[ "ui02" ], CPanel, {
			[ 1 ] = {
				name = "Open Editor",
				class = "DButton",
				cmd = "zbf_bot_editor",
				desc = "Open the Bot Editor."
			},
			[ 2 ] = {
				name = "Add Level",
				class = "DButton",
				cmd = "zbf.Bot.AddLevel",
				desc = "Increases the bots level by 1."
			},
			[ 3 ] = {
				name = "Factory Reset Config",
				class = "DButton",
				cmd = "zbf_bot_factory_reset",
				desc = "Resets the bot config back to default"
			},
		})
		zclib.Settings.OptionPanel("Vault", nil, Color(86, 114, 194), zclib.colors[ "ui02" ], CPanel, {
			[ 1 ] = {
				name = "Savefile Editor",
				class = "DButton",
				cmd = "zbf_vault_admin",
				desc = "Lets you edit another players vault."
			},
		})
		zclib.Settings.OptionPanel("ATM", nil, Color(86, 114, 194), zclib.colors[ "ui02" ], CPanel, {
			[ 1 ] = {
				name = "Save",
				class = "DButton",
				cmd = "zbf_atm_save",
			},
			[ 2 ] = {
				name = "Remove",
				class = "DButton",
				cmd = "zbf_atm_remove",
			},
		})
		zclib.Settings.OptionPanel("BotNet", nil, Color(86, 114, 194), zclib.colors[ "ui02" ], CPanel, {
			[ 1 ] = {
				name = "Reveal all IPs to Target",
				class = "DButton",
				cmd = "zbf.Controller.RevealAll",
			}
		})
		zclib.Settings.OptionPanel("Sign", nil, Color(86, 114, 194), zclib.colors[ "ui02" ], CPanel, {
			[ 1 ] = {
				name = "Save",
				class = "DButton",
				cmd = "zbf_infosign_save",
			},
			[ 2 ] = {
				name = "Remove",
				class = "DButton",
				cmd = "zbf_infosign_remove",
			},
		})
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

	spawnmenu.AddToolMenuOption("Options", "zbf_options", "zbf_Client_Settings", "Client Settings", "", "", function(CPanel)
		zclib.Settings.OptionPanel("Bot", "", Color(88, 152, 65), zclib.colors[ "ui02" ], CPanel, {
			[ 1 ] = {
				name = "World Effects",
				class = "DCheckBoxLabel",
				cmd = "zbf_cl_bot_effects"
			},
			[ 2 ] = {
				name = "Simple Screen",
				class = "DCheckBoxLabel",
				cmd = "zbf_cl_bot_simplescreen"
			},
			[ 3 ] = {
				name = "Break Gibs",
				class = "DCheckBoxLabel",
				cmd = "zbf_cl_bot_gibs"
			},
			[ 4 ] = {
				name = "Draw Connection",
				class = "DCheckBoxLabel",
				cmd = "zbf_cl_bot_connection"
			},
		})
	end)
end)
