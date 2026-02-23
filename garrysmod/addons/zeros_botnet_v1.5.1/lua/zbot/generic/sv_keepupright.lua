/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end

/*
	Makes the entity up right once dropped
*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

local list = {
	[ "zbf_bot" ] = true,
	[ "zbf_controller" ] = true,
	[ "zbf_rack" ] = true,
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

zclib.Hook.Add("GravGunOnDropped", "zbf_entityaligment", function(ply, ent)
	if IsValid(ent) and list[ ent:GetClass() ] then
		local ang = ply:GetAngles()
		ang:RotateAroundAxis(ply:GetUp(), 180)
		ent:SetAngles(Angle(0, ang.y, 0))
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a
