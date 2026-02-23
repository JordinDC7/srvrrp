/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

function zbf.Print(msg)
	MsgC(Color(89, 55, 160), "[Zero´s BotNet] -> ", Color(255, 255, 255), msg .. "\n")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

/*
	Caches and returns a lerped color depending on a percentage 1-100%
*/
local CachedColor = {}
function zbf.GetPercentageColor(percent)
	percent = math.Round(percent)
	if CachedColor[percent] then
		return CachedColor[percent]
	else
		CachedColor[percent] = zclib.util.LerpColor((1 / 100) * percent, zclib.colors["red01"], zclib.colors["green01"])
		return CachedColor[percent]
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d
