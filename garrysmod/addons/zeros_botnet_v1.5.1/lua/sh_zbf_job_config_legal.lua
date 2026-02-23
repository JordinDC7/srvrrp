/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.config = zbf.config or {}

zbf.config.Jobs = zbf.config.Jobs or {}
local function AddJob(data) return table.insert(zbf.config.Jobs,data) end

/*

	Generic - Legal

*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

/*
	Quick way to add all the diffrent movies as a render job
*/
local MovieList = {
	[1] = {
		name = zbf.language[ "legal_job01_name" ],
		desc = zbf.language[ "legal_job01_desc" ],
		img = Material("materials/zerochain/zbot/jobs/waifucatgirl.png"),
	},
	[2] = {
		name = zbf.language[ "legal_job02_name" ],
		desc = zbf.language[ "legal_job02_desc" ],
		img = Material("materials/zerochain/zbot/jobs/nofreedom.png"),
	},
	[3] = {
		name = zbf.language[ "legal_job03_name" ],
		desc = zbf.language[ "legal_job03_desc" ],
		img = Material("materials/zerochain/zbot/jobs/summer.png"),
	},
	[4] = {
		name = zbf.language[ "legal_job04_name" ],
		desc = zbf.language[ "legal_job04_desc" ],
		img = Material("materials/zerochain/zbot/jobs/daterunner.png"),
	},
	[5] = {
		name = zbf.language[ "legal_job05_name" ],
		desc = zbf.language[ "legal_job05_desc" ],
		img = Material("materials/zerochain/zbot/jobs/snailhunter.png"),
	},
	[6] = {
		name = zbf.language[ "legal_job06_name" ],
		desc = zbf.language[ "legal_job06_desc" ],
		img = Material("materials/zerochain/zbot/jobs/nolife.png"),
	},
	[7] = {
		name = zbf.language[ "legal_job07_name" ],
		desc = zbf.language[ "legal_job07_desc" ],
		img = Material("materials/zerochain/zbot/jobs/gallam.png"),
	},
	[8] = {
		name = zbf.language[ "legal_job08_name" ],
		desc = zbf.language[ "legal_job08_desc" ],
		img = Material("materials/zerochain/zbot/jobs/collector.png"),
	},
	[9] = {
		name = zbf.language[ "legal_job09_name" ],
		desc = zbf.language[ "legal_job09_desc" ],
		img = Material("materials/zerochain/zbot/jobs/enchant.png"),
	},
	[10] = {
		name = zbf.language[ "legal_job10_name" ],
		desc = zbf.language[ "legal_job10_desc" ],
		img = Material("materials/zerochain/zbot/jobs/candy.png"),
	},
	[11] = {
		name = zbf.language[ "legal_job11_name" ],
		desc = zbf.language[ "legal_job11_desc" ],
		img = Material("materials/zerochain/zbot/jobs/tomb.png"),
	},
	[12] = {
		name = zbf.language[ "legal_job12_name" ],
		desc = zbf.language[ "legal_job12_desc" ],
		img = Material("materials/zerochain/zbot/jobs/train.png"),
	},
	[13] = {
		name = zbf.language[ "legal_job13_name" ],
		desc = zbf.language[ "legal_job13_desc" ],
		img = Material("materials/zerochain/zbot/jobs/ody.png"),
	},
	[14] = {
		name = zbf.language[ "legal_job14_name" ],
		desc = zbf.language[ "legal_job14_desc" ],
		img = Material("materials/zerochain/zbot/jobs/memory.png"),
	},
	[15] = {
		name = zbf.language[ "legal_job15_name" ],
		desc = zbf.language[ "legal_job15_desc" ],
		img = Material("materials/zerochain/zbot/jobs/country.png"),
	},
	[16] = {
		name = zbf.language[ "legal_job16_name" ],
		desc = zbf.language[ "legal_job16_desc" ],
		img = Material("materials/zerochain/zbot/jobs/crowbar.png"),
	},
	[17] = {
		name = zbf.language[ "legal_job17_name" ],
		desc = zbf.language[ "legal_job17_desc" ],
		img = Material("materials/zerochain/zbot/jobs/spot.png"),
	},
	[18] = {
		name = zbf.language[ "legal_job18_name" ],
		desc = zbf.language[ "legal_job18_desc" ],
		img = Material("materials/zerochain/zbot/jobs/conse.png"),
	},
}
for k,v in pairs(MovieList) do
	AddJob({
		type = ZBF_JOBTYPE_GENERIC,

		name = v.name,
		desc = v.desc,
		img = v.img,

		// This means the job offer will stay availble once it got completed
		// NOTE This only will only be saved localy and wont stay after server restart
		unlockable = true,

		// This means the player has 10 minutes to start the job offer or its gonna disappear again
		expire = 600,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

		// This means the job will be on a 10 minute cooldown after it got completed
		cooldown = 600,

		GetPayment = function() return ZBF_CURRENCY_MONEY , 5000 end,
		ticks = 6500,
		jobs = {
			["Render Farm Manager"] = true,
		}
	})
end


/*

	Crypto Mining Jobs
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

*/
// NOTE You can find all available crypto currencies at lua/zbot/generic/sh_currency.lua
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

// Lets quick sort them alphapetically
local t_list = table.Copy(zbf.Currency.List)
for k,v in pairs(t_list) do v.id = k end
table.sort( t_list, function(a, b) return a.name < b.name end)

for k,v in pairs(t_list) do
	// You cant mine normal money, thats called money printing Duuuuuh
	if v.id == ZBF_CURRENCY_MONEY then continue end

	AddJob({
		type = ZBF_JOBTYPE_CRYPTO,
		name = zbf.Currency.GetName(v.id),
		desc = zbf.language[ "crypto_job_desc" ],

		// Lets replace the job icon with the Crypto icon
		icon = zbf.Currency.GetIcon(v.id),
		icon_size = 0.8,
		icon_color = color_white,
		img = Material("materials/zerochain/zbot/jobs/crypto.png"),

		ticks = 1200,

		// Lets keep track on which Crypto ID this job is linked to
		crypto_id = v.id,

		// This defines in which currency and how much the player gets paid
		GetPayment = function(Controller, ply, TargetIP)
			local amount = zbf.config.Crypto.MoneyPerCycle / zbf.Currency.GetValue(v.id)

			return v.id , amount
		end,

		error = {
			interval = {min = 60,max = 120},
			types = {
				[30] = {ZBF_ERRORTYPE_CRASH,1,150},
				[3] = ZBF_ERRORTYPE_REBOOT,
				[6] = ZBF_ERRORTYPE_REBOOT,
				[9] = ZBF_ERRORTYPE_REBOOT,
				[12] = ZBF_ERRORTYPE_REBOOT,
			}
		},

		// Those jobs can mine crypto
		jobs = {
			["Crypto Miner"] = true,
			//["Hacker"] = true,
			//["Neuro Hacker"] = true,
		},
	})
end
