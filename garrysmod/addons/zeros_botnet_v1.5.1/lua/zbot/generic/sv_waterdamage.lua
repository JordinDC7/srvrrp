/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end

/*
	If a bot is fully in water then it gets destroyed
*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

if not zbf.config.Waterdamage then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

zclib.Timer.Remove("zbf_WaterDamage_handler")
zclib.Timer.Create("zbf_WaterDamage_handler", 5, 0, function()
	for ent, _ in pairs(zbf.Bot.List) do
		if not IsValid(ent) then continue end

		if ent:WaterLevel() >= 2 then
			zbf.Bot.Destroy(ent)
		end
	end

	for _, ent in pairs(zbf.Controller.List) do
		if not IsValid(ent) then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		if ent:WaterLevel() >= 2 then
			zbf.Controller.Destroy(ent)
		end
	end

	for _, ent in pairs(zbf.USB.List) do
		if not IsValid(ent) then continue end

		if ent:WaterLevel() >= 2 then
			zbf.USB.Destroy(ent)
		end
	end

	for _, ent in pairs(zbf.Rack.List) do
		if not IsValid(ent) then continue end

		if ent:WaterLevel() >= 2 then
			zbf.Rack.Destroy(ent)
		end
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e
