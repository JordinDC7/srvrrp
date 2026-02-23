/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

zgo2 = zgo2 or {}
zgo2.config = zgo2.config or {}
zgo2.config.Mules = {}

local function AddMule(data) return table.insert(zgo2.config.Mules,data) end

AddMule({
	// Name of the transfer service
	name = "Fernando",

	// How much does the transfer of weed cost per g
	cost = 3,

	// How much weed will be lost on the way (This value scales by distance, the further the destination is away the more weed will be lost but never more then this defined value)
	spillage = 10, // 10%

	// How fast is this transfer server
	speed = 1,

	// Thumbnail image of the mule
	img = Material("materials/zerochain/zgo2/mules/Fernando.png", "noclamp smooth"),
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	/*
	What job can use this mule
	jobs = {
		[TEAM_OTHER] = true,
	},

	// What rank can use this mule
	ranks = {
		["superadmin"] = true,
	},
	*/
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

AddMule({
	name = "Emilia",
	cost = 5,
	spillage = 5,
	speed = 1.25,
	img = Material("materials/zerochain/zgo2/mules/Emilia.png", "noclamp smooth")
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

// The transporter movie reference
AddMule({
	name = "Frank",
	cost = 15,
	spillage = 1,
	speed = 5,
	img = Material("materials/zerochain/zgo2/mules/Frank.png", "noclamp smooth"),
	jobs = zgo2.config.Jobs.Pro,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c98d49b320af02372d954ba403147b52446efe45185e82d35620a577545ff88

AddMule({
	name = "High Tony",
	cost = 1,
	spillage = 25,
	speed = 1.25,
	img = Material("materials/zerochain/zgo2/mules/Tony.png", "noclamp smooth")
})


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d95ede022471e32e4a4b21a5ceaeb1f2c170bb22540bb623b92f31411b4103f1


// NOTE This Mule will be used if mules are disabled, since we need some travel informations
if zgo2.config.Marketplace.DisableMules then
	zgo2.config.Mules[ 6666 ] = {
		name = "Generic",
		cost = 0,
		spillage = 0,
		speed = 15,
	}
end
