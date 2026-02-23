/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Bot = zbf.Bot or {}

/*

    Here we add possible bot models and their default submaterial id of the material we gonna replace with a lua material later
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

*/
zbf.Bot.Models = {}
local function AddBotModel(mdl,id) table.insert(zbf.Bot.Models,{mdl = mdl,id = id}) end
AddBotModel("models/zerochain/props_clickfarm/zcf_bot_lvl01.mdl",1)
AddBotModel("models/zerochain/props_clickfarm/zcf_bot_lvl02.mdl",1)
AddBotModel("models/zerochain/props_clickfarm/zcf_bot_lvl03.mdl",1)
AddBotModel("models/zerochain/props_clickfarm/zcf_bot_lvl04.mdl",1)
AddBotModel("models/zerochain/props_clickfarm/zcf_bot_lvl05.mdl",2)

AddBotModel("models/zerochain/props_clickfarm/zcf_bot_neuro_lvl01.mdl",1)
AddBotModel("models/zerochain/props_clickfarm/zcf_bot_neuro_lvl02.mdl",1)
AddBotModel("models/zerochain/props_clickfarm/zcf_bot_neuro_lvl03.mdl",1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

/*
	Here we add all the normal maps the player can choose from
*/
zbf.Bot.NormalMaps = {}
local function AddNormalMap(path,name) table.insert(zbf.Bot.NormalMaps,{path = path,name = name}) end
AddNormalMap("zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm", zbf.language[ "Paint" ])
AddNormalMap("zerochain/props_clickfarm/bot/zcf_bot_mat01_metal_nrm", zbf.language[ "Metal" ])
AddNormalMap("zerochain/props_clickfarm/bot/zcf_bot_mat01_carbon_nrm", zbf.language[ "Carbon Fiber" ])
AddNormalMap("zerochain/props_clickfarm/bot/zcf_bot_mat01_plastic_nrm", zbf.language[ "Plastic" ])
AddNormalMap("zerochain/props_clickfarm/bot/zcf_bot_mat01_plate_nrm", zbf.language[ "Diamond Plate" ])
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
