/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

zgo2 = zgo2 or {}
zgo2.config = zgo2.config or {}
zgo2.config.Watertanks = {}
zgo2.config.Watertanks_ListID = zgo2.config.Watertanks_ListID or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

local function AddWatertank(data)
	local PlantID = table.insert(zgo2.config.Watertanks,data)
	zgo2.config.Watertanks_ListID[data.uniqueid] = PlantID
	return PlantID
end

AddWatertank({
	uniqueid = "4z24zhdafdasf",
	class = "zgo2_watertank",
	name = zgo2.language[ "Watertank - Small" ],
	mdl = "models/zerochain/props_growop2/zgo2_watertank_small.mdl",
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

	price = 1000,

	// How much water can it hold
	Capacity = 2000,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	// How fast does it refill
	RefillRate = 25,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d95ede022471e32e4a4b21a5ceaeb1f2c170bb22540bb623b92f31411b4103f1

	UIPos = {
		vec = Vector(0, 17, 34),
		ang = Angle(0, 180, 90),
		scale = 0.02,
	}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d95ede022471e32e4a4b21a5ceaeb1f2c170bb22540bb623b92f31411b4103f1

AddWatertank({
	uniqueid = "fkljfi4i4i33i",
	class = "zgo2_watertank",
	name = zgo2.language[ "Watertank - Big" ],
	mdl = "models/zerochain/props_growop2/zgo2_watertank.mdl",
	price = 2000,
	Capacity = 10000,
	RefillRate = 50,
	jobs = zgo2.config.Jobs.Pro,
	UIPos = {
		vec = Vector(0, 54, 50),
		ang = Angle(0, 180, 90),
		scale = 0.05,
	}
})
