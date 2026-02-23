/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.config = zbf.config or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

zbf.config.Jobs = zbf.config.Jobs or {}
local function AddJob(data) return table.insert(zbf.config.Jobs,data) end

/*

	Here we setup all the computing jobs that the BotNets can do

*/


/*

	Generic - Illegal Jobs

*/
AddJob({
	type = ZBF_JOBTYPE_GENERIC,
	name = zbf.language[ "illegal_job01_name" ],
	desc = zbf.language[ "illegal_job01_desc" ],
	img = Material("materials/zerochain/zbot/jobs/amazon.png"),

	// Can be used to overwrite the jobs icon
	//icon = Material("path","param")

	// This defines in which currency and how much the player gets paid
	GetPayment = function() return ZBF_CURRENCY_MONEY , 1500 end,

	// This means the job offer will stay availble once it got completed
	// NOTE This only will only be saved localy and wont stay after server restart
	//unlockable = true,

	// How many ticks are needed to Receive one pay
	ticks = 1000,

	// Jobs which have a cooldown dont repeat after completion
	cooldown = 60,

	// If set then this job will only be available sometimes and once it does , its gonna expire after the specified amount of seconds
	// This would be defined as a one time contract
	expire = 300,

	// Can be used to change the type of error this job can cause
	// If not defined then the jobs will cause a bot to reboot for 30 seconds
	error = {
		 // Causes a error every 50 seconds
		interval = 50,

		// Can also be writen like this which causes a error every random 10-60 seconds
		//interval = {min = 10,max = 60},

		types = {
			// [Time/Duration] = ErrorType,

			// Can also look like this to define how many bots will get this error and one ExtraValue which in case of ZBF_ERRORTYPE_CRASH will define how much damage will be applied
			// [Time/Duration] = {ErrorType,ImpactedBotCount,ExtraValue},

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

			// This would disable the bot for the next 30 seconds
			// [30] = ZBF_ERRORTYPE_REBOOT,

			// This would causes the bot to be damaged in 10 seconds if not fixed in time
			// [10] = ZBF_ERRORTYPE_CRASH,

			[30] = ZBF_ERRORTYPE_REBOOT,
			[15] = ZBF_ERRORTYPE_REBOOT,
			[60] = ZBF_ERRORTYPE_CRASH,
		}
	},

	// How high does the BotNets Neuro level need to be in order to perform this task / job
	// neuro_reg = 200,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	/*
	// Can be used to restrict this job to a certain rank
	ranks = {
		["vip"] = true,
	},
	*/

	// Who can do this job? Leave empty to allow everyone.
	jobs = {
		["Hacker"] = true,
		["Neuro Hacker"] = true,
	},

	// Can be used to run some custom code once a cycle is completed
	OnFinish = function(Controller,ply,IP)
		/*
			Controller = The controller entity that performed the job
			ply = The player who started the job
			IP = If the job is of type ZBF_JOBTYPE_BOTNET then this is the IP we targeted
		*/
	end,
})

AddJob({
	type = ZBF_JOBTYPE_GENERIC,
	name = zbf.language[ "illegal_job02_name" ],
	desc = zbf.language[ "illegal_job02_desc" ],
	img = Material("materials/zerochain/zbot/jobs/gmodrage.png"),
	cooldown = 300,
	expire = 60,
	GetPayment = function() return ZBF_CURRENCY_MONEY , 2000 end,
	ticks = 500,
	error = {
		interval = 30,
		types = {
			[5] = ZBF_ERRORTYPE_REBOOT,
		}
	},
	jobs = {
		["Hacker"] = true,
		["Neuro Hacker"] = true,
	}
})

AddJob({
	type = ZBF_JOBTYPE_GENERIC,
	name = zbf.language[ "illegal_job03_name" ],
	desc = zbf.language[ "illegal_job03_desc" ],
	img = Material("materials/zerochain/zbot/jobs/hacker.png"),
	cooldown = 600,
	expire = 60,
	GetPayment = function() return ZBF_CURRENCY_MONEY , 15000 end,
	ticks = 15000,
	error = {
		interval = 5,
		types = {
			[10] = ZBF_ERRORTYPE_CRASH,
		}
	},
	jobs = {
		["Hacker"] = true,
		["Neuro Hacker"] = true,
	}
})

AddJob({
	type = ZBF_JOBTYPE_GENERIC,
	name = zbf.language[ "illegal_job04_name" ],
	desc = zbf.language[ "illegal_job04_desc" ],
	img = Material("materials/zerochain/zbot/jobs/datacenter.png"),
	cooldown = 600,
	expire = 20,
	GetPayment = function() return ZBF_CURRENCY_MONEY , 25000 end,
	ticks = 15000,

	// The way this error is defined is that while we are computing this job every 25-40 seconds a error wave will occur
	// that impacts 10 Bots, which need to get fixed in 5 seconds or they gonna get 50 Damage
	error = {
		interval = {min = 25,max = 40},
		types = {
			[5] = {ZBF_ERRORTYPE_CRASH,10,50},
			[3] = ZBF_ERRORTYPE_CRASH,
			[4] = ZBF_ERRORTYPE_CRASH,
			[5] = {ZBF_ERRORTYPE_CRASH,15,25},
		}
	},

	jobs = {
		["Hacker"] = true,
		["Neuro Hacker"] = true,
	}
})

/*
	Scams
*/
AddJob({
	type = ZBF_JOBTYPE_SCAM,
	name = zbf.language[ "scam_job01_name" ],
	desc = zbf.language[ "scam_job01_desc" ],
	img = Material("materials/zerochain/zbot/jobs/scam_delivery.png"),
	GetPayment = function() return ZBF_CURRENCY_MONEY , 100 end,
	ticks = 1000,
	error = {
		interval = 100,
		types = {
			[10] = ZBF_ERRORTYPE_CRASH,
		}
	},
	jobs = {
		["Scammer"] = true,
	}
})

AddJob({
	type = ZBF_JOBTYPE_SCAM,
	name = zbf.language[ "scam_job02_name" ],
	desc = zbf.language[ "scam_job02_desc" ],
	img = Material("materials/zerochain/zbot/jobs/scam_romance.png"),
	GetPayment = function() return ZBF_CURRENCY_MONEY , 2000 end,
	ticks = 2500,
	error = {
		interval = 35,
		types = {
			[10] = ZBF_ERRORTYPE_CRASH,
		}
	},
	jobs = {
		["Scammer"] = true,
	}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

AddJob({
	type = ZBF_JOBTYPE_SCAM,
	name = zbf.language[ "scam_job03_name" ],
	desc = zbf.language[ "scam_job03_desc" ],
	img = Material("materials/zerochain/zbot/jobs/scam_award.png"),
	GetPayment = function() return ZBF_CURRENCY_MONEY , 120 end,
	ticks = 1300,
	error = {
		interval = 200,
		types = {
			[10] = ZBF_ERRORTYPE_CRASH,
		}
	},
	jobs = {
		["Scammer"] = true,
	}
})

AddJob({
	type = ZBF_JOBTYPE_SCAM,
	name = zbf.language[ "scam_job04_name" ],
	desc = zbf.language[ "scam_job04_desc" ],
	img = Material("materials/zerochain/zbot/jobs/scam_religion.png"),
	GetPayment = function() return ZBF_CURRENCY_MONEY , 200 end,
	ticks = 1000,
	error = {
		interval = 600,
		types = {
			[10] = ZBF_ERRORTYPE_CRASH,
		}
	},
	jobs = {
		["Scammer"] = true,
	}
})

AddJob({
	type = ZBF_JOBTYPE_SCAM,
	name = zbf.language[ "scam_job05_name" ],
	desc = zbf.language[ "scam_job05_desc" ],
	img = Material("materials/zerochain/zbot/jobs/scam_bank.png"),
	GetPayment = function() return ZBF_CURRENCY_MONEY , 600 end,
	ticks = 1000,
	error = {
		interval = 25,
		types = {
			[6] = ZBF_ERRORTYPE_CRASH,
		}
	},
	jobs = {
		["Scammer"] = true,
	}
})

AddJob({
	type = ZBF_JOBTYPE_SCAM,
	name = zbf.language[ "scam_job06_name" ],
	desc = zbf.language[ "scam_job06_desc" ],
	img = Material("materials/zerochain/zbot/jobs/scam_refund.png"),
	GetPayment = function() return ZBF_CURRENCY_MONEY , 1000 end,
	ticks = 3000,
	error = {
		interval = 100,
		types = {
			[10] = ZBF_ERRORTYPE_CRASH,
		}
	},
	jobs = {
		["Scammer"] = true,
	}
})

AddJob({
	type = ZBF_JOBTYPE_SCAM,
	name = zbf.language[ "scam_job07_name" ],
	desc = zbf.language[ "scam_job07_desc" ],
	img = Material("materials/zerochain/zbot/jobs/scam_ransome.png"),
	GetPayment = function()
		// This makes sure we always get 1000$ worth of that Crypto currency
		local amount = 1000 / zbf.Currency.List[ZBF_CURRENCY_BTC].value
		return ZBF_CURRENCY_BTC , amount
	end,
	ticks = 3000,
	error = {
		interval = 100,
		types = {
			[10] = ZBF_ERRORTYPE_CRASH,
		}
	},
	jobs = {
		["Scammer"] = true,
		["Hacker"] = true,
	}
})

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d


/*

	DarkRP Releated Hacks

*/
if not DarkRP then return end

AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "darkrp_hack01_title" ],
	desc = zbf.language[ "darkrp_hack01_desc" ],
	img = Material("materials/zerochain/zbot/jobs/hacker.png"),
	cooldown = 60,
	ticks = 15000,
	neuro_reg = 500,
	jobs = {
		["Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		local Target = Player(UserID)
		if not IsValid(Target) then return end
		Target:wanted(ply, zbf.language[ "darkrp_hack01_reason" ])
	end,
})

AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "darkrp_hack02_title" ],
	desc = zbf.language[ "darkrp_hack02_desc" ],
	img = Material("materials/zerochain/zbot/jobs/hacker.png"),
	cooldown = 60,
	ticks = 15000,
	neuro_reg = 500,
	jobs = {
		["Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		local Target = Player(UserID)
		if not IsValid(Target) then return end
		Target:unWanted(ply)
	end,
})

AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "darkrp_hack03_title" ],
	desc = zbf.language[ "darkrp_hack03_desc" ],
	img = Material("materials/zerochain/zbot/jobs/hacker.png"),
	cooldown = 60,
	ticks = 30000,
	neuro_reg = 500,
	jobs = {
		["Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		local Target = Player(UserID)
		if not IsValid(Target) then return end
		Target:arrest(300,ply)
	end,
})

AddJob({
	type = ZBF_JOBTYPE_NEURO,
	name = zbf.language[ "darkrp_hack04_title" ],
	desc = zbf.language[ "darkrp_hack04_desc" ],
	img = Material("materials/zerochain/zbot/jobs/hacker.png"),
	cooldown = 60,
	ticks = 15000,
	neuro_reg = 500,
	jobs = {
		["Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)
		local Target = Player(UserID)
		if not IsValid(Target) then return end
		Target:unArrest(ply)
	end,
})

AddJob({
	type = ZBF_JOBTYPE_GENERIC,
	name = zbf.language[ "darkrp_hack05_title" ],
	desc = zbf.language[ "darkrp_hack05_desc" ],
	img = Material("materials/zerochain/zbot/jobs/hacker.png"),
	cooldown = 600,
	ticks = 15000,
	error = {
		interval = 5,
		types = {
			[10] = ZBF_ERRORTYPE_CRASH,
		}
	},
	jobs = {
		["Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)

		if GetGlobalBool("DarkRP_LockDown") then return end

		for _, v in ipairs(player.GetAll()) do
			v:ConCommand("play " .. GAMEMODE.Config.lockdownsound .. "\n")
		end

		DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_started"))
		SetGlobalBool("DarkRP_LockDown", true)
		DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_started"))

		hook.Run("lockdownStarted", ply)
	end,
})

AddJob({
	type = ZBF_JOBTYPE_GENERIC,
	name = zbf.language[ "darkrp_hack06_title" ],
	desc = zbf.language[ "darkrp_hack06_desc" ],
	img = Material("materials/zerochain/zbot/jobs/hacker.png"),
	cooldown = 600,
	ticks = 15000,
	error = {
		interval = 5,
		types = {
			[10] = ZBF_ERRORTYPE_CRASH,
		}
	},
	jobs = {
		["Hacker"] = true,
	},
	OnFinish = function(Controller,ply,UserID)

		if not GetGlobalBool("DarkRP_LockDown") then return end

		DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_ended"))
	    DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_ended"))
	    SetGlobalBool("DarkRP_LockDown", false)

	    hook.Run("lockdownEnded", ply)
	end,
})
