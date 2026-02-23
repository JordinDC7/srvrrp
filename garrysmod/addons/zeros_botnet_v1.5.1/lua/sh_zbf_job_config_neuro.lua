/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.config = zbf.config or {}

zbf.config.Jobs = zbf.config.Jobs or {}
local function AddJob(data) return table.insert(zbf.config.Jobs,data) end

/*
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

	Neuro Hacks

*/
AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "neuro_job01_name" ],
	desc = zbf.language[ "neuro_job01_desc" ],
	img = Material("materials/zerochain/zbot/jobs/neuro.png"),
	cooldown = 60,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	// What neuro level is requiered on the botnet to perform this hack
	neuro_reg = 100,

	// Depending on the neuro hacks type, this value defines either the hacks duration or amount
	// NOTE I wrote those values in the main config to make it easier for the end user.
	boost_val = zbf.config.Neuro.Boost_duration,

	ticks = 1000,
	jobs = {
		["Neuro Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		zbf.Controller.Neuro_Boost(Controller,ply,UserID)
	end,
})

AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "neuro_job02_name" ],
	desc = zbf.language[ "neuro_job02_desc" ],
	img = Material("materials/zerochain/zbot/jobs/neuro.png"),
	ticks = 1000,
	neuro_reg = 50,
	boost_val = zbf.config.Neuro.Vitality_amount,
	jobs = {
		["Neuro Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		zbf.Controller.Neuro_Vitality(Controller,ply,UserID)
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

ZBF_JOB_NEURO_SHIELD = AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "neuro_job03_name" ],
	desc = zbf.language[ "neuro_job03_desc" ],
	img = Material("materials/zerochain/zbot/jobs/neuro.png"),
	cooldown = 60,
	ticks = 1000,
	neuro_reg = 250,
	boost_val = zbf.config.Neuro.Shield_duration,
	jobs = {
		["Neuro Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		zbf.Controller.Neuro_Shield(Controller,ply,UserID)
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

ZBF_JOB_NEURO_CRIPPLE = AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "neuro_job04_name" ],
	desc = zbf.language[ "neuro_job04_desc" ],
	img = Material("materials/zerochain/zbot/jobs/neuro.png"),
	cooldown = 60,
	ticks = 1000,
	neuro_reg = 300,
	boost_val = zbf.config.Neuro.Cripple_duration,
	jobs = {
		["Neuro Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		zbf.Controller.Neuro_Cripple(Controller,ply,UserID)
	end,
})

ZBF_JOB_NEURO_OVERHEAT = AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "neuro_job05_name" ],
	desc = zbf.language[ "neuro_job05_desc" ],
	img = Material("materials/zerochain/zbot/jobs/neuro.png"),
	cooldown = 60,
	ticks = 1000,
	neuro_reg = 500,
	boost_val = zbf.config.Neuro.Overheat_duration,
	jobs = {
		["Neuro Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		zbf.Controller.Neuro_Overheat(Controller,ply,UserID)
	end,
})

ZBF_JOB_NEURO_ANEURYSM = AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "neuro_job06_name" ],
	desc = zbf.language[ "neuro_job06_desc" ],
	img = Material("materials/zerochain/zbot/jobs/neuro.png"),
	cooldown = 60,
	ticks = 1000,
	neuro_reg = 250,
	boost_val = zbf.config.Neuro.Aneurysm_duration,
	jobs = {
		["Neuro Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		zbf.Controller.Neuro_Aneurysm(Controller,ply,UserID)
	end,
})

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

ZBF_JOB_NEURO_GROWTH = AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "neuro_job07_name" ],
	desc = zbf.language[ "neuro_job07_desc" ],
	img = Material("materials/zerochain/zbot/jobs/neuro.png"),
	cooldown = 60,
	ticks = 1000,
	neuro_reg = 250,
	boost_val = zbf.config.Neuro.Growth_duration,
	jobs = {
		["Neuro Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		zbf.Controller.Neuro_Growth(Controller,ply,UserID)
	end,
})
