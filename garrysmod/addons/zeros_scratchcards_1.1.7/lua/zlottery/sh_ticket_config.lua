zlt = zlt or {}
zlt.config = zlt.config or {}

// Add default image switch depending on zclib.config.ActiveImageService
local DefaultImageID_Switch = {
	["imgur"] = {
		["blacklogo"] = "1XlfMZP",

		["golden_bg"] = "6lLkTrz",
		["golden_scratch"] = "3CchPAs",

		["factory_bg"] = "GmZHibG",
		["factory_scratch"] = "4H154Ky",

		["crystal_bg"] = "fXy8Ea0",
		["crystal_scratch"] = "czu8vJR",

		["og_bg"] = "41z20bv",
		["og_scratch"] = "Voh7Apg",
	},
	["imgpile"] = {
		["blacklogo"] = "NJlC9N",

		["golden_bg"] = "NJlT1r",
		["golden_scratch"] = "NJlMWx",

		["factory_bg"] = "NJlDzW",
		["factory_scratch"] = "NJlKsL",

		["crystal_bg"] = "NJlG3P",
		["crystal_scratch"] = "NJlP1j",

		["og_bg"] = "NJlx51",
		["og_scratch"] = "NJlYKo",
	}
}

local dat = DefaultImageID_Switch[zclib.config.ActiveImageService]

zlt.config.Tickets = {
	[1] = {
		["uniqueid"] = "a6bb3f1f82",
		["price"] = 100,
		["title_val"] = "Golden shower",
		["title_y"] = 1,
		["title_x"] = 1,
		["scratch_url"] = dat["golden_scratch"],
		["scratch_outline_col"] = Color(242, 116, 5, 255),
		["scratch_outline_type"] = "border01",
		["bg_url"] = dat["golden_bg"],
		["logo_url"] = dat["blacklogo"],
		["logo_x"] = 0.11,
		["logo_y"] = 0.92,
		["logo_scale_w"] = 0.2,
		["logo_scale_h"] = 0.2,
		["prizelist"] = {
			[1] = {
				type = 1,
				chance = 10,
				final_chance = 63,
			},
			[2] = {
				type = 2,
				money = 50,
				chance = 5,
				final_chance = 31,
			},
			[3] = {
				type = 2,
				money = 100,
				chance = 1,
				final_chance = 6,
			}
		}
	},
	[2] = {
		["uniqueid"] = "e29ffaabc7",
		["price"] = 100,
		["title_val"] = "Cash Factory",
		["title_y"] = 1,
		["title_x"] = 1,
		["scratch_url"] = dat["factory_scratch"],
		["scratch_outline_col"] = Color(255, 29, 37, 255),
		["scratch_outline_type"] = "border01",
		["bg_url"] = dat["factory_bg"],
		["logo_url"] = dat["blacklogo"],
		["logo_x"] = 0.11,
		["logo_y"] = 0.92,
		["logo_scale_w"] = 0.2,
		["logo_scale_h"] = 0.2,
		["prizelist"] = {
			[1] = {
				type = 1,
				chance = 10,
				final_chance = 63,
			},
			[2] = {
				type = 2,
				money = 50,
				chance = 5,
				final_chance = 31,
			},
			[3] = {
				type = 2,
				money = 100,
				chance = 1,
				final_chance = 6,
			}
		}
	},
	[3] = {
		["uniqueid"] = "360400a9cd",
		["price"] = 100,
		["title_val"] = "Crazy Crystalls",
		["title_y"] = 1,
		["title_x"] = 1,
		["scratch_url"] = dat["crystal_scratch"],
		["scratch_outline_type"] = "border04",
		["bg_url"] = dat["crystal_bg"],
		["logo_url"] = dat["blacklogo"],
		["logo_x"] = 0.11,
		["logo_y"] = 0.92,
		["logo_scale_w"] = 0.2,
		["logo_scale_h"] = 0.2,
		["prizelist"] = {
			[1] = {
				type = 1,
				chance = 10,
				final_chance = 63,
			},
			[2] = {
				type = 2,
				money = 50,
				chance = 5,
				final_chance = 31,
			},
			[3] = {
				type = 2,
				money = 100,
				chance = 1,
				final_chance = 6,
			}
		}
	},
	[4] = {
		["uniqueid"] = "361400a9cd",
		["price"] = 100,
		["title_val"] = "OG Cash",
		["title_y"] = 1,
		["title_x"] = 1,
		["scratch_url"] = dat["og_scratch"],
		["scratch_outline_col"] = Color(110, 133, 109, 255),
		["scratch_outline_type"] = "border01",
		["bg_url"] = dat["og_bg"],
		["logo_url"] = dat["blacklogo"],
		["logo_x"] = 0.11,
		["logo_y"] = 0.92,
		["logo_scale_w"] = 0.2,
		["logo_scale_h"] = 0.2,
		["prizelist"] = {
			[1] = {
				type = 1,
				chance = 10,
				final_chance = 63,
			},
			[2] = {
				type = 2,
				money = 50,
				chance = 5,
				final_chance = 31,
			},
			[3] = {
				type = 2,
				money = 100,
				chance = 1,
				final_chance = 6,
			}
		}
	}
}
