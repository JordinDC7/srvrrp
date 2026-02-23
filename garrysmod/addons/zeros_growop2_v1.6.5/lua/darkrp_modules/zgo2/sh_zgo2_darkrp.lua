/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/


/*

	Here we setup all the DarkRP Jobs

*/
TEAM_ZGO2_AMATEUR = DarkRP.createJob("Amateur Grower", {
	color = Color(111, 150, 97, 255),
	model = {"models/player/group03/male_06.mdl"},
	description = [[You grow and sell weed.]],
	weapons = {"zgo2_multitool","zgo2_backpack"},
	command = "zgo2_amateur",
	max = 4,
	salary = 0,
	admin = 0,
	vote = false,
	category = "Gangsters",
	hasLicense = false
})

TEAM_ZGO2_BASIC = DarkRP.createJob("Basic Grower", {
	color = Color(111, 150, 97, 255),
	model = {"models/player/group03/male_03.mdl"},
	description = [[You grow and sell weed.]],
	weapons = {"zgo2_multitool","zgo2_backpack"},
	command = "zgo2_basic",
	max = 4,
	salary = 0,
	admin = 0,
	vote = false,
	category = "Gangsters",
	hasLicense = false
})

TEAM_ZGO2_PRO = DarkRP.createJob("Professional Grower", {
	color = Color(111, 150, 97, 255),
	model = {"models/player/group03/male_02.mdl"},
	description = [[You grow and sell weed.]],
	weapons = {"zgo2_multitool","zgo2_backpack"},
	command = "zgo2_pro",
	max = 4,
	salary = 0,
	admin = 0,
	vote = false,
	category = "Gangsters",
	hasLicense = false
})


/*

	Bellow are all the grow entities if you wanna spawn them with the f4 menu instead

*/
local function SetupDarkRPEntities()

	// If the shop config has not yet been loaded then wait 1 second
	if not zgo2.Shop or not zgo2.Shop.List then
		timer.Simple(1,SetupDarkRPEntities)
		return
	end

	DarkRP.createCategory{
		name = "Grow Equipment",
		categorises = "entities",
		startExpanded = true,
		color = Color(111, 150, 97, 255),
		canSee = function(ply) return true end,
		sortOrder = 100
	}

	DarkRP.createCategory{
		name = "Plant Seeds",
		categorises = "entities",
		startExpanded = false,
		color = Color(111, 150, 97, 255),
		canSee = function(ply) return true end,
		sortOrder = 99
	}

	DarkRP.createCategory{
		name = "Production",
		categorises = "entities",
		startExpanded = true,
		color = Color(111, 150, 97, 255),
		canSee = function(ply) return true end,
		sortOrder = 100
	}

	DarkRP.createEntity("Soil", {
		ent = "zgo2_soil",
		model = "models/zerochain/props_growop2/zgo2_soil.mdl",
		price = 100,
		max = 4,
		cmd = "buy_zgo2_soil",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Splicer", {
		ent = "zgo2_splicer",
		model = "models/zerochain/props_growop2/zgo2_lab.mdl",
		price = 1000,
		max = 1,
		cmd = "buy_zgo2_splicer",
		allowed = {
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Drying Line", {
		ent = "zgo2_dryline",
		model = "models/zerochain/props_growop2/zgo2_dryline.mdl",
		price = 1000,
		max = 1,
		cmd = "buy_zgo2_dryline",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Weed Clipper", {
		ent = "zgo2_clipper",
		model = "models/zerochain/props_growop2/zgo2_weedcruncher.mdl",
		price = 5000,
		max = 2,
		cmd = "buy_zgo2_clipper",
		allowed = {
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Weed Packer", {
		ent = "zgo2_packer",
		model = "models/zerochain/props_growop2/zgo2_weedpacker.mdl",
		price = 5000,
		max = 2,
		cmd = "buy_zgo2_packer",
		allowed = {
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Palette", {
		ent = "zgo2_palette",
		model = "models/zerochain/props_growop2/zgo2_palette.mdl",
		price = 100,
		max = 6,
		cmd = "buy_zgo2_palette",
		allowed = {
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Weed Clipper - Motor", {
		ent = "zgo2_motor",
		model = "models/zerochain/props_growop2/zgo2_motor.mdl",
		price = 1000,
		max = 2,
		cmd = "buy_zgo2_motor",
		allowed = {
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	DarkRP.createEntity("Jar", {
		ent = "zgo2_jar",
		model = "models/zerochain/props_growop2/zgo2_jar.mdl",
		price = 500,
		max = 12,
		cmd = "buy_zgo2_jar",
		allowed = {
			TEAM_ZGO2_PRO,
			TEAM_ZGO2_BASIC
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Transport Crate", {
		ent = "zgo2_crate",
		model = "models/zerochain/props_growop2/zgo2_crate.mdl",
		price = 1000,
		max = 6,
		cmd = "buy_zgo2_crate",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	DarkRP.createEntity("Jar Crate", {
		ent = "zgo2_jarcrate",
		model = "models/zerochain/props_growop2/zgo2_jarcrate.mdl",
		price = 1000,
		max = 6,
		cmd = "buy_zgo2_jarcrate",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})


	DarkRP.createEntity("Log Book", {
		ent = "zgo2_logbook",
		model = "models/props_lab/binderblue.mdl",
		price = 1000,
		max = 1,
		cmd = "buy_zgo2_logbook",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Water Pump", {
		ent = "zgo2_pump",
		model = "models/zerochain/props_growop2/zgo2_pump.mdl",
		price = 3000,
		max = 2,
		cmd = "buy_zgo2_pump",
		allowed = {
			TEAM_ZGO2_PRO,
			TEAM_ZGO2_BASIC
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Battery", {
		ent = "zgo2_battery",
		model = "models/zerochain/props_growop2/zgo2_battery.mdl",
		price = 500,
		max = 3,
		cmd = "buy_zgo2_battery",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Fuel", {
		ent = "zgo2_fuel",
		model = "models/zerochain/props_growop2/zgo2_fuel.mdl",
		price = 500,
		max = 3,
		cmd = "buy_zgo2_fuel",
		allowed = {
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Bulb", {
		ent = "zgo2_bulb",
		model = "models/zerochain/props_growop2/zgo2_bulb.mdl",
		price = 500,
		max = 3,
		cmd = "buy_zgo2_bulb",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Grow Equipment",
	})

	DarkRP.createEntity("Seed Libary", {
		ent = "zgo2_seedlibary",
		model = "models/zerochain/props_growop2/zgo2_seedlibary.mdl",
		price = 1000,
		max = 1,
		cmd = "buy_zgo2_seedlibary",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Plant Seeds",
	})
	for k, v in pairs(zgo2.config.Plants) do

		if zgo2.Plant.IsSplice(k) then continue end

		DarkRP.createEntity(v.name .. " [Seeds]", {
			ent = "zgo2_seed",
			model = "models/zerochain/props_growop2/zgo2_weedseeds.mdl",
			price = zgo2.Plant.GetTotalMoney(k) * ((1 / 100) * zgo2.config.Seedbox.Cost),
			max = 5,
			cmd = "buy_zgo2_seed" .. v.uniqueid,
			allowed = { TEAM_ZGO2_AMATEUR, TEAM_ZGO2_PRO , TEAM_ZGO2_BASIC },
			customCheck = function(ply) return zgo2.Player.CanUse(ply,v) end,
			CustomCheckFailMsg = function(ply, entTable) return "" end,
			category = "Plant Seeds",
			spawn = function(ply, tr, tblEnt)
				local ent = ents.Create("zgo2_seed")
				ent:SetPlantID(k)
				ent:Spawn()
				ent:SetPos(tr.HitPos)

				return ent
			end
		})
	end

	for k, v in pairs(zgo2.config.Pots) do
		DarkRP.createEntity(v.name, {
			ent = "zgo2_pot",
			model = zgo2.Pot.GetModel(k),
			price = v.price,
			max = 6,
			cmd = "buy_zgo2_pot" .. v.uniqueid,
			allowed = { TEAM_ZGO2_AMATEUR, TEAM_ZGO2_PRO , TEAM_ZGO2_BASIC },
			customCheck = function(ply) return zgo2.Player.CanUse(ply,v) end,
			CustomCheckFailMsg = function(ply, entTable) return "" end,
			category = "Grow Equipment",
			spawn = function(ply, tr, tblEnt)
				local ent = ents.Create("zgo2_pot")
				ent:SetPotID(k)
				ent:Spawn()
				ent:SetPos(tr.HitPos)

				return ent
			end
		})
	end

	for k,v in pairs(zgo2.config.Racks) do
		DarkRP.createEntity(v.name .. "0" .. k, {
			ent = "zgo2_rack",
			model = v.mdl,
			price = v.price,
			max = 6,
			cmd = "buy_zgo2_rack" .. v.uniqueid,
			allowed = { TEAM_ZGO2_AMATEUR, TEAM_ZGO2_PRO , TEAM_ZGO2_BASIC },
			customCheck = function(ply) return zgo2.Player.CanUse(ply,v) end,
			CustomCheckFailMsg = function(ply, entTable) return "" end,
			category = "Grow Equipment",
			spawn = function(ply, tr, tblEnt)
				local ent = ents.Create("zgo2_rack")
				ent:SetRackID(k)
				ent:Spawn()
				ent:SetPos(tr.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d95ede022471e32e4a4b21a5ceaeb1f2c170bb22540bb623b92f31411b4103f1

				return ent
			end
		})
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2

	for k, v in pairs(zgo2.config.Watertanks) do
		DarkRP.createEntity(v.name, {
			ent = "zgo2_watertank",
			model = v.mdl,
			price = v.price,
			max = 6,
			cmd = "buy_zgo2_watertank" .. v.uniqueid,
			allowed = { TEAM_ZGO2_AMATEUR, TEAM_ZGO2_PRO , TEAM_ZGO2_BASIC },
			customCheck = function(ply) return zgo2.Player.CanUse(ply,v) end,
			CustomCheckFailMsg = function(ply, entTable) return "" end,
			category = "Grow Equipment",
			spawn = function(ply, tr, tblEnt)
				local ent = ents.Create("zgo2_watertank")
				ent:SetWatertankID(k)
				ent:Spawn()
				ent:SetPos(tr.HitPos)

				return ent
			end
		})
	end

	for k, v in pairs(zgo2.config.Lamps) do

		if v.tent then
			DarkRP.createEntity(v.name, {
				ent = "zgo2_lamp",
				model = v.mdl,
				price = v.price,
				max = 8,
				cmd = "buy_zgo2_lamp" .. v.uniqueid,
				allowed = { TEAM_ZGO2_AMATEUR, TEAM_ZGO2_PRO , TEAM_ZGO2_BASIC },
				customCheck = function(ply) return zgo2.Player.CanUse(ply,v) end,
				CustomCheckFailMsg = function(ply, entTable) return "" end,
				category = "Grow Equipment",
				spawn = function(ply, tr, tblEnt)
					local ent = ents.Create("zgo2_lamp")
					ent:SetLampID(k)
					ent:Spawn()
					ent:SetPos(tr.HitPos)

					return ent
				end
			})
		else
			DarkRP.createEntity(v.name, {
				ent = "zgo2_lamp",
				model = v.mdl,
				price = v.price,
				max = 6,
				cmd = "buy_zgo2_lamp" .. v.uniqueid,
				allowed = { TEAM_ZGO2_AMATEUR, TEAM_ZGO2_PRO , TEAM_ZGO2_BASIC },
				customCheck = function(ply) return zgo2.Player.CanUse(ply,v) end,
				CustomCheckFailMsg = function(ply, entTable) return "" end,
				category = "Grow Equipment",
				spawn = function(ply, tr, tblEnt)
					local ent = ents.Create("zgo2_lamp")
					ent:SetLampID(k)
					ent:Spawn()
					ent:SetPos(tr.HitPos)

					return ent
				end
			})
		end
	end

	for k, v in pairs(zgo2.config.Tents) do
		DarkRP.createEntity(v.name, {
			ent = "zgo2_tent",
			model = v.mdl,
			price = v.price,
			max = 4,
			cmd = "buy_zgo2_tent" .. v.uniqueid,
			allowed = { TEAM_ZGO2_AMATEUR, TEAM_ZGO2_PRO , TEAM_ZGO2_BASIC },
			customCheck = function(ply) return zgo2.Player.CanUse(ply,v) end,
			CustomCheckFailMsg = function(ply, entTable) return "" end,
			category = "Grow Equipment",
			spawn = function(ply, tr, tblEnt)
				local ent = ents.Create("zgo2_tent")
				ent:SetTentID(k)
				ent:Spawn()
				ent:SetPos(tr.HitPos)

				return ent
			end
		})
	end

	for k, v in pairs(zgo2.config.Generators) do
		DarkRP.createEntity(v.name, {
			ent = "zgo2_generator",
			model = v.mdl,
			price = v.price,
			max = 1,
			cmd = "buy_zgo2_generator" .. v.uniqueid,
			allowed = { TEAM_ZGO2_AMATEUR, TEAM_ZGO2_PRO , TEAM_ZGO2_BASIC },
			customCheck = function(ply) return zgo2.Player.CanUse(ply,v) end,
			CustomCheckFailMsg = function(ply, entTable) return "" end,
			category = "Grow Equipment",
			spawn = function(ply, tr, tblEnt)
				local ent = ents.Create("zgo2_generator")
				ent:SetGeneratorID(k)
				ent:Spawn()
				ent:SetPos(tr.HitPos)

				return ent
			end
		})
	end

	DarkRP.createEntity("DoobyTable", {
		ent = "zgo2_doobytable",
		model = "models/zerochain/props_growop2/zgo2_doobytable.mdl",
		price = 1000,
		max = 1,
		cmd = "buy_zgo2_doobytable",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Production",
	})

	DarkRP.createEntity("Mixer", {
		ent = "zgo2_mixer",
		model = "models/zerochain/props_growop2/zgo2_mixer.mdl",
		price = 1000,
		max = 5,
		cmd = "buy_zgo2_mixer",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Production",
	})

	DarkRP.createEntity("Oven", {
		ent = "zgo2_oven",
		model = "models/zerochain/props_growop2/zgo2_oven.mdl",
		price = 1000,
		max = 5,
		cmd = "buy_zgo2_oven",
		allowed = {
			TEAM_ZGO2_AMATEUR,
			TEAM_ZGO2_BASIC,
			TEAM_ZGO2_PRO
		},
		category = "Production",
	})

	for k, v in pairs(zgo2.config.Edibles) do
		DarkRP.createEntity(v.name, {
			ent = "zgo2_backmix",
			model = v.backmix_model,
			price = 1000,
			max = 5,
			cmd = "buy_zgo2_backmix" .. k,
			allowed = { TEAM_ZGO2_AMATEUR, TEAM_ZGO2_BASIC, TEAM_ZGO2_PRO },
			category = "Production",
			spawn = function(ply, tr, tblEnt)
				local ent = ents.Create("zgo2_backmix")
				ent.EdibleID = k
				ent:Spawn()
				ent:SetPos(tr.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2

				return ent
			end
		})
	end
end

// Delayed by 5 second to make sure all the custom config files have been loaded
// NOTE If you change any of the configs Pot / Plant then you need to restart in order for them to appear in F4 Menu

// NOTE Remove // bellow to add all the weed entities to the f4 menu
// timer.Simple(5,SetupDarkRPEntities)
