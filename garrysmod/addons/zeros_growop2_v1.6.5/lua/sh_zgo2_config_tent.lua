/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

zgo2 = zgo2 or {}
zgo2.config = zgo2.config or {}
zgo2.config.Tents = {}
zgo2.config.Tents_ListID = zgo2.config.Tents_ListID or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c5b22d0c464981a2a2cb55407ea8523b955c581541c9aaa45b7d50e2253186c

local function AddTent(data)
	local PlantID = table.insert(zgo2.config.Tents,data)
	zgo2.config.Tents_ListID[data.uniqueid] = PlantID
	return PlantID
end

AddTent({
	uniqueid = "4624vcsvfhfgv",
	class = "zgo2_tent",
	name = zgo2.language[ "Tent - Small" ],
	mdl = "models/zerochain/props_growop2/zgo2_tent01.mdl",
	price = 1000,
	lamps = {
		{Vector(0,0,69),Angle(0,0,0)}
	},

	pots = {
		{Vector(0,0,1),Angle(0,-90,0)}
	},
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c5b22d0c464981a2a2cb55407ea8523b955c581541c9aaa45b7d50e2253186c

	battery_bg = {
		[1] = 0
	}
})

AddTent({
	uniqueid = "4621zhfhss",
	class = "zgo2_tent",
	name = zgo2.language[ "Tent - Big" ],
	mdl = "models/zerochain/props_growop2/zgo2_tent02.mdl",
	price = 2500,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c98d49b320af02372d954ba403147b52446efe45185e82d35620a577545ff88

	lamps = {
		{Vector(30,0,69),Angle(0,0,0)},
		{Vector(-29,0,69),Angle(0,0,0)},
	},

	pots = {
		{Vector(30,0,1),Angle(0,-90,0)},
		{Vector(-30,0,1),Angle(0,-90,0)},
	},
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

	battery_bg = {
		[1] = 1,
		[2] = 0,
	}
})
