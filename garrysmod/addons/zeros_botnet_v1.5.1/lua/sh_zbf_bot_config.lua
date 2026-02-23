/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.config = zbf.config or {}
zbf.config.Bots = {}
zbf.config.Bots_ListID = zbf.config.Bots_ListID or {}
local function AddBot(data) util.PrecacheModel( data.mdl ) local BotID = table.insert(zbf.config.Bots,data) zbf.config.Bots_ListID[data.uniqueid] = BotID return BotID end

/*
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

	This Bot config can be edited ingame using the Bot Editor

*/


AddBot({
	uniqueid = 24624626,
	name = zbf.language[ "bot_name_lvl01" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl01.mdl",

	// How much damage can it withstand before it explodes
	health = 5,

	// How much does the bot cost
	price = 300,

	// Ticks per second
	tps = 0.1,

	// Strength of the attack
	attack = 1,

	// Defense against Attacks
	defense = 1,

	/*
	// Restricts which rank can use this bot
	ranks = {
		["superadmin"] = true,
	},
	*/

	/*
	// Restricts which job can use this bot
	jobs = {
		["Hacker"] = true,
	},
	*/

	// Changes the material of the bot
	material = {
		// Which sub material id should we replace
		id = 1,

		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",

		// Defines which skin base to use
		//skin = 1,

		// The color of the material / reflect
		color = Color(222, 222, 222),

		fresnel = 0.5,
		reflection = 4,
		spec_color = color_white,
	}
})

AddBot({
	uniqueid = 246224726,
	name = zbf.language[ "bot_name_lvl02" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl02.mdl",
	health = 5,
	price = 600,
	tps = 0.5,
	attack = 1,
	defense = 1,
	material = {
		id = 1,

		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",

		color = Color(255, 225, 96),
		fresnel = 0.5,
		reflection = 4,
		spec_color = Color(255, 225, 96),
		imgur_url = "DcWyj7Q",
		imgur_color = Color(255,255,255,125),
		imgur_blendmode = 2,
		imgur_scale = 1,
		imgur_x = 0,
		imgur_y = 0
	}
})

AddBot({
	uniqueid = 90943586,
	name = zbf.language[ "bot_name_lvl03" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl03.mdl",
	health = 5,
	price = 1000,
	tps = 1,
	attack = 1,
	defense = 1,
	material = {
		id = 1,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",

		color = Color(50, 131, 232),
		fresnel = 0.5,
		reflection = 4,
		spec_color = Color(50, 131, 232),
		imgur_url = "DcWyj7Q",
		imgur_color = Color(255,255,255,125),
		imgur_blendmode = 2,
		imgur_scale = 1,
		imgur_x = 0,
		imgur_y = 0
	}
})

AddBot({
	uniqueid = "f820c765c9",
	name = zbf.language[ "bot_name_lvl03_5" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl04.mdl",
	health = 5,
	price = 1000,
	tps = 1.5,
	attack = 1,
	defense = 1,
	neuro = 0,
	ranks = {},
	jobs = {},
	material = {
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		id = 1,
		imgur_blendmode = 2,
		logo_scale = 0.11,
		em_x = 0,
		logo_y = 0.59,
		logo_color = Color(255, 255, 255, 255),
		em_y = 0,
		spec_color = Color(110, 110, 110, 255),
		logo_x = 0.77,
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",
		imgur_scale = 1,
		reflection = 1,
		imgur_color = Color(255, 255, 255, 125),
		em_strength = 0,
		logo_rotation = 90,
		imgur_y = 0,
		color = Color(170, 187, 220, 255),
		imgur_x = 0,
		logo_blendmode = 0,
		em_color = Color(0, 0, 0, 255),
		fresnel = 1,
		em_scale = 1,
	},
})

AddBot({
	uniqueid = 3561655,
	name = zbf.language[ "bot_name_lvl04" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl04.mdl",
	health = 5,
	price = 2000,
	tps = 2,
	attack = 1,
	defense = 1,
	material = {
		id = 1,

		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",

		color = Color(178, 50, 232),
		fresnel = 0.5,
		reflection = 4,
		spec_color = Color(178, 50, 232),

		imgur_url = "DcWyj7Q",
		imgur_color = Color(255,255,255,125),
		imgur_blendmode = 2,
		imgur_scale = 1,
		imgur_x = 0,
		imgur_y = 0
	}
})

AddBot({
	uniqueid = 5587832,
	name = zbf.language[ "bot_name_lvl05" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl05.mdl",
	health = 5,
	price = 3000,
	tps = 3,
	attack = 1,
	defense = 1,
	ranks = {
		["superadmin"] = true,
		["vip"] = true,
	},
	material = {
		id = 2,

		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",

		color = Color(232, 50, 71),
		fresnel = 0.5,
		reflection = 4,
		spec_color = Color(232, 50, 71),

		imgur_url = "DcWyj7Q",
		imgur_color = Color(255,255,255,125),
		imgur_blendmode = 2,
		imgur_scale = 1,
		imgur_x = 0,
		imgur_y = 0
	}
})

AddBot({
	uniqueid = 5111159,
	name = zbf.language[ "bot_name_attacker" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl05.mdl",
	health = 25,
	attack = 45,
	defense = 10,
	price = 3000,
	tps = 1,
	ranks = {},
	jobs = {
		["Hacker"] = true,
		["Neuro Hacker"] = true,
	},
	material = {
		id = 2,
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",
		color = Color(255, 255, 255),
		fresnel = 0.5,
		reflection = 1,
		spec_color = Color(255, 255, 255),
		imgur_url = "cXyfd4l",
		imgur_color = color_white,
		imgur_blendmode = 2,
		imgur_scale = 1,
		imgur_x = 0.09,
		imgur_y = 0.15
	}
})

AddBot({
	uniqueid = "df02694fa2",
	name = zbf.language[ "bot_name_nextgen" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl04.mdl",
	health = 25,
	attack = 10,
	defense = 10,
	price = 6000,
	tps = 5,
	ranks = {},
	material = {
		id = 1,
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",
		color = Color(255, 225, 0),
		fresnel = 1,
		reflection = 0.1,
		spec_color = Color(255, 255, 255),
		imgur_url = "DcWyj7Q",
		imgur_color = color_white,
		imgur_blendmode = 2,
		imgur_scale = 1,
		imgur_x = 0,
		imgur_y = 0
	}
})

AddBot({
	uniqueid = "5590832",
	name = zbf.language[ "bot_name_god" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl05.mdl",
	health = 100,
	price = 50000,
	tps = 5,
	attack = 100,
	defense = 100,
	neuro = 0,
	ranks = {
		[ "superadmin" ] = true,
	},
	jobs = {},
	material = {
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		imgur_x = 0,
		imgur_blendmode = 0,
		logo_scale = 0.11,
		em_x = 0,
		fresnel = 1.5,
		logo_color = Color(255, 255, 255, 255),
		em_y = 0,
		spec_color = Color(255, 189, 59, 255),
		logo_x = 0.77,
		logo_blendmode = 0,
		imgur_scale = 1,
		reflection = 1.5,
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_carbon_nrm",
		em_strength = 0,
		logo_rotation = 90,
		imgur_y = 0,
		color = Color(98, 70, 12, 255),
		imgur_color = Color(255, 255, 255, 255),
		logo_y = 0.59,
		em_color = Color(0, 0, 0, 255),
		id = 2,
		em_scale = 1,
	},
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

ZBF_BOT_SCAM = AddBot({
	uniqueid = "244524726",
	name = zbf.language[ "bot_name_scam" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl02.mdl",
	health = 10,
	price = 100,
	tps = 0.5,
	attack = 3,
	defense = 0,
	neuro = 0,
	ranks = {},
	jobs = {
		[ "Scammer" ] = true,
	},
	material = {
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		imgur_x = 0,
		imgur_blendmode = 0,
		logo_scale = 0.11,
		em_x = 0,
		fresnel = 1,
		logo_color = Color(255, 255, 255, 255),
		em_y = 0,
		spec_color = Color(255, 255, 255, 255),
		logo_x = 0.77,
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_plastic_nrm",
		imgur_scale = 1,
		em_scale = 1,
		id = 1,
		em_color = Color(0, 0, 0, 255),
		logo_rotation = 90,
		imgur_y = 0,
		logo_y = 0.59,
		imgur_color = Color(255, 255, 255, 255),
		color = Color(200, 201, 186, 255),
		em_strength = 0,
		logo_blendmode = 0,
		reflection = 2,
	},
})



/*
	A bot which can hack players brains
*/
AddBot({
	uniqueid = 5111449,
	name = zbf.language[ "bot_name_neuro01" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_neuro_lvl01.mdl",
	health = 10,
	attack = 0,
	defense = 0,
	neuro = 10,
	price = 1000,
	tps = 1,
	jobs = {
		["Neuro Hacker"] = true,
	},
	material = {
		id = 5,
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",
		color = Color(255, 255, 255),
		fresnel = 0.5,
		reflection = 1,
		spec_color = Color(255, 255, 255),
	}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

AddBot({
	uniqueid = 5144449,
	name = zbf.language[ "bot_name_neuro02" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_neuro_lvl02.mdl",
	health = 10,
	attack = 0,
	defense = 0,
	neuro = 25,
	price = 2000,
	tps = 2,
	jobs = {
		["Neuro Hacker"] = true,
	},
	material = {
		id = 5,
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",
		color = Color(255, 255, 255),
		fresnel = 0.5,
		reflection = 1,
		spec_color = Color(255, 255, 255),
	}
})

AddBot({
	uniqueid = 5551449,
	name = zbf.language[ "bot_name_neuro03" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_neuro_lvl03.mdl",
	health = 10,
	attack = 0,
	defense = 0,
	neuro = 50,
	price = 3000,
	tps = 3,
	jobs = {
		["Neuro Hacker"] = true,
	},
	ranks = {
		["superadmin"] = true,
		["vip"] = true,
	},
	material = {
		id = 5,
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",
		color = Color(255, 255, 255),
		fresnel = 0.5,
		reflection = 1,
		spec_color = Color(255, 255, 255),
	}
})

AddBot({
	uniqueid = "180ad488fd",
	name = zbf.language[ "bot_name_neuro04" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_neuro_lvl03.mdl",
	health = 25,
	attack = 5,
	defense = 5,
	neuro = 100,
	price = 5000,
	tps = 5,
	jobs = {
		["Neuro Hacker"] = true,
	},
	ranks = {
		["superadmin"] = true,
		["vip"] = true,
	},
	material = {
		id = 1,
		diff = "zerochain/props_clickfarm/neurobot/zcf_neurobot_brain_diff",
		nrm = "zerochain/props_clickfarm/neurobot/zcf_neurobot_brain_nrm",
		color = Color(255, 114, 0),
		fresnel = 5.5,
		reflection = 3,
		spec_color = Color(255, 31, 31),
		em_color = Color(113, 220, 94),
		em_url = "Egii0ey",
		em_strength = 1,
		em_scale = 0.8,
	}
})



AddBot({
	uniqueid = "f476d5b02b",
	name = zbf.language[ "bot_name_01" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl05.mdl",
	health = 25,
	price = 3000,
	tps = 2.5,
	attack = 1,
	defense = 25,
	neuro = 0,
	ranks = {},
	jobs = {},
	material = {
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		color = Color(255, 133, 133, 255),
		imgur_url = "2YbMZZB",
		logo_scale = 0.11,
		em_x = 0,
		logo_y = 0.59,
		logo_color = Color(255, 255, 255, 255),
		em_y = 0,
		spec_color = Color(255, 169, 169, 255),
		logo_x = 0.77,
		reflection = 3.4443459858089,
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",
		imgur_scale = 1,
		imgur_blendmode = 2,
		em_strength = 0,
		id = 2,
		logo_rotation = 90,
		imgur_y = 0,
		imgur_x = 0,
		imgur_color = Color(255, 255, 255, 255),
		logo_blendmode = 0,
		em_color = Color(0, 0, 0, 255),
		fresnel = 0.65372393909323,
		em_scale = 1,
	},
})

AddBot({
	uniqueid = "04073f21a6",
	name = zbf.language[ "bot_name_02" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl05.mdl",
	health = 25,
	price = 3000,
	tps = 2.5,
	attack = 1,
	defense = 25,
	neuro = 0,
	ranks = {},
	jobs = {},
	material = {
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		color = Color(201, 201, 201, 255),
		imgur_url = "yVgRCRw",
		logo_scale = 0.11,
		em_x = 0,
		logo_y = 0.59,
		logo_color = Color(255, 255, 255, 255),
		reflection = 3.4443459858089,
		em_y = 0,
		em_url = "0k2Efa2",
		logo_x = 0.77,
		imgur_blendmode = 2,
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm",
		imgur_scale = 1,
		em_strength = 1,
		id = 2,
		imgur_x = 0,
		logo_rotation = 90,
		imgur_y = 0,
		imgur_color = Color(255, 255, 255, 255),
		logo_blendmode = 0,
		fresnel = 0.65372393909323,
		em_color = Color(0, 199, 255, 255),
		spec_color = Color(255, 255, 255, 255),
		em_scale = 1,
	},
})

AddBot({
	uniqueid = "c479bee58f",
	name = zbf.language[ "bot_name_03" ],
	mdl = "models/zerochain/props_clickfarm/zcf_bot_lvl03.mdl",
	health = 5,
	price = 1500,
	tps = 1,
	attack = 10,
	defense = 0,
	neuro = 0,
	ranks = {},
	jobs = {},
	material = {
		diff = "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff",
		id = 1,
		imgur_blendmode = 2,
		logo_scale = 0.11,
		em_x = 0,
		logo_y = 0.59,
		logo_color = Color(255, 255, 255, 255),
		em_y = 0,
		spec_color = Color(0, 64, 194, 255),
		logo_x = 0.77,
		nrm = "zerochain/props_clickfarm/bot/zcf_bot_mat01_plate_nrm",
		imgur_scale = 1,
		reflection = 3,
		color = Color(130, 130, 130, 255),
		em_strength = 0,
		logo_rotation = 90,
		imgur_y = 0,
		imgur_x = 0,
		imgur_color = Color(255, 255, 255, 125),
		logo_blendmode = 0,
		em_color = Color(0, 0, 0, 255),
		fresnel = 1,
		em_scale = 1,
	},
})
