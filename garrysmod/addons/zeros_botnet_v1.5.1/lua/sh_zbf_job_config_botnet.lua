/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.config = zbf.config or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

zbf.config.Jobs = zbf.config.Jobs or {}
local function AddJob(data) return table.insert(zbf.config.Jobs,data) end

/*
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	BotNet Jobs

*/
ZBF_JOB_BOTNET_PING = AddJob({
	type = ZBF_JOBTYPE_BOTNET,
	name = zbf.language[ "botnet_job01_name" ],
	desc = zbf.language[ "botnet_job01_desc" ],
	img = Material("materials/zerochain/zbot/jobs/botnet.png"),
	cooldown = 60,
	ticks = 5000,
	jobs = {
		["Hacker"] = true,
		["Neuro Hacker"] = true,
	},
	OnFinish = function(Controller,ply,IP) zbf.Controller.Attack_Ping(Controller,ply,IP) end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

ZBF_JOB_BOTNET_STEAL = AddJob({
	type = ZBF_JOBTYPE_BOTNET,
	name = zbf.language[ "botnet_job02_name" ],
	desc = zbf.language[ "botnet_job02_desc" ],
	img = Material("materials/zerochain/zbot/jobs/botnet.png"),
	cooldown = 60,
	ticks = 10000,
	jobs = {
		["Hacker"] = true,
		["Neuro Hacker"] = true,
	},
	OnFinish = function(Controller,ply,IP) zbf.Controller.Attack_Steal(Controller,ply,IP) end,
})

ZBF_JOB_BOTNET_REBOOT = AddJob({
	type = ZBF_JOBTYPE_BOTNET,
	name = zbf.language[ "botnet_job03_name" ],
	desc = zbf.language[ "botnet_job03_desc" ],
	img = Material("materials/zerochain/zbot/jobs/botnet.png"),
	cooldown = 60,
	ticks = 10000,
	jobs = {
		["Hacker"] = true,
		["Neuro Hacker"] = true,
	},
	OnFinish = function(Controller,ply,IP) zbf.Controller.Attack_Reboot(Controller,ply,IP) end,
})

ZBF_JOB_BOTNET_CRASH = AddJob({
	type = ZBF_JOBTYPE_BOTNET,
	name = zbf.language[ "botnet_job04_name" ],
	desc = zbf.language[ "botnet_job04_desc" ],
	img = Material("materials/zerochain/zbot/jobs/botnet.png"),
	cooldown = 60,
	ticks = 10000,
	jobs = {
		[ "Hacker" ] = true,
		[ "Neuro Hacker" ] = true,
	},
	OnFinish = function(Controller, ply, IP) zbf.Controller.Attack_Crash(Controller, ply, IP) end,
})

ZBF_JOB_BOTNET_HIGHJACK = AddJob({
	type = ZBF_JOBTYPE_BOTNET,
	name = zbf.language[ "botnet_job05_name" ],
	desc = zbf.language[ "botnet_job05_desc" ],
	img = Material("materials/zerochain/zbot/jobs/botnet.png"),
	cooldown = 5,
	ticks = 2500,
	jobs = {
		[ "Hacker" ] = true,
		[ "Neuro Hacker" ] = true,
	},
	OnFinish = function(Controller, ply, IP) zbf.Controller.Attack_Highjack(Controller, ply, IP) end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401
