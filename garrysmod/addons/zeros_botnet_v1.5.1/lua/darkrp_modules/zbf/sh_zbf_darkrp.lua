/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/


/*

	Here we setup all the DarkRP Jobs

*/
// NOTE If you change the TEAM_ names then you would need to adjust them here too > zeros_botnet/lua/sh_zbf_hooks.lua

TEAM_ZBF_MINER = DarkRP.createJob("Crypto Miner", {
	color = Color(111, 150, 97, 255),
	model = {"models/player/group03/male_06.mdl"},
	description = [[You mine crypto currencys.]],
	weapons = {},
	command = "zbl_cryptominer",
	max = 4,
	salary = 45,
	admin = 0,
	vote = false,
	category = "Citizens",
	hasLicense = false
})

TEAM_ZBF_HACKER = DarkRP.createJob("Hacker", {
	color = Color(111, 150, 97, 255),
	model = {"models/player/group03/male_02.mdl"},
	description = [[You perform illegal hack attacks for paying individuals.]],
	weapons = {},
	command = "zbl_hacker",
	max = 4,
	salary = 45,
	admin = 0,
	vote = false,
	category = "Gangsters",
	hasLicense = false
})

TEAM_ZBF_NEUROHACKER = DarkRP.createJob("Neuro Hacker", {
	color = Color(111, 150, 97, 255),
	model = {"models/player/group03/female_03.mdl"},
	description = [[You can hack everything!]],
	weapons = {},
	command = "zbl_netrunner",
	max = 4,
	salary = 45,
	admin = 0,
	vote = false,
	category = "Civil Protection",
	hasLicense = false
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

TEAM_ZBF_RENDERFARM = DarkRP.createJob("Render Farm Manager", {
	color = Color(111, 150, 97, 255),
	model = {"models/player/group03/male_07.mdl"},
	description = [[Movie Studios pay you to render out their latest films in 4k.]],
	weapons = {},
	command = "zbl_renderfarm",
	max = 4,
	salary = 45,
	admin = 0,
	vote = false,
	category = "Citizens",
	hasLicense = false
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

TEAM_ZBF_SCAMMER = DarkRP.createJob("Scammer", {
	color = Color(111, 150, 97, 255),
	model = {"models/player/group03/male_05.mdl"},
	description = [[You manage systems which flood the internet with spam emails.]],
	weapons = {},
	command = "zbl_scammer",
	max = 4,
	salary = 45,
	admin = 0,
	vote = false,
	category = "Gangsters",
	hasLicense = false
})

/*

	Here we setup all the DarkRP Entities
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

*/

DarkRP.createCategory{
	name = "Bot Equipment",
	categorises = "entities",
	startExpanded = true,
	color = Color(111, 150, 97, 255),
	canSee = function(ply) return true end,
	sortOrder = 103
}

DarkRP.createEntity("Controller", {
	ent = "zbf_controller",
	model = "models/zerochain/props_clickfarm/zcf_controller.mdl",
	price = 2000,
	max = 1,
	cmd = "buy_zbf_controller",
	allowed = {
		TEAM_ZBF_MINER,
		TEAM_ZBF_HACKER,
		TEAM_ZBF_NEUROHACKER,
		TEAM_ZBF_RENDERFARM,
		TEAM_ZBF_SCAMMER
	},
	category = "Bot Equipment",
})

DarkRP.createEntity("Bot Rack", {
	ent = "zbf_rack",
	model = "models/zerochain/props_clickfarm/zcf_rack.mdl",
	price = 2000,
	max = 3,
	cmd = "buy_zbf_rack",
	allowed = {
		TEAM_ZBF_MINER,
		TEAM_ZBF_HACKER,
		TEAM_ZBF_NEUROHACKER,
		TEAM_ZBF_RENDERFARM,
		TEAM_ZBF_SCAMMER
	},
	category = "Bot Equipment"
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a
