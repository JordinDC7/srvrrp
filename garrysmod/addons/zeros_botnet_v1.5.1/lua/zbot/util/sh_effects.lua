/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zclib.NetEvent.AddDefinition("zbf_bot_damage", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	ent:EmitSound("zbf_bot_damage")
	zclib.Effect.ParticleEffect("zbf_bot_damage", ent:GetPos(), ent:GetAngles())
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

zclib.NetEvent.AddDefinition("zbf_bot_explode", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	if zclib.Convar.GetBool("zbf_cl_bot_gibs") then
		ent:GibBreakClient(VectorRand(-125, 125) + Vector(0, 0, 125), zbf.Bot.GetColor(ent))
	end
	ent:EmitSound("zbf_bot_explode")
	zclib.Effect.ParticleEffect("zbf_bot_destroy", ent:GetPos(), ent:GetAngles())
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

zclib.NetEvent.AddDefinition("zbf_bot_fix", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	ent:EmitSound("zbf_fix")
	zclib.Effect.ParticleEffect("zbf_bot_repair", ent:LocalToWorld(Vector(10, 0, 0)), ent:GetAngles())
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

zclib.NetEvent.AddDefinition("zbf_bot_repair", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	zclib.Sound.EmitFromPosition(ent:GetPos(),"cash")
	zclib.Effect.ParticleEffect("zbf_bot_repair", ent:LocalToWorld(Vector(10, 0, 0)), ent:GetAngles())
end)

zclib.NetEvent.AddDefinition("zbf_bot_buy", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
	zclib.Effect.ParticleEffect("zbf_bot_buy", pos, angle_zero)
	zclib.Sound.EmitFromPosition(pos, "cash")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

zclib.NetEvent.AddDefinition("zbf_rack_destroy", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	ent:GibBreakClient(VectorRand(-125, 125) + Vector(0, 0, 125))
end)

zclib.NetEvent.AddDefinition("zbf_Controller_destroy", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	ent:GibBreakClient(VectorRand(-125, 125) + Vector(0, 0, 125))
	ent:EmitSound("zbf_bot_explode")
	zclib.Effect.ParticleEffect("zbf_bot_destroy", ent:GetPos(), ent:GetAngles())
end)

zclib.NetEvent.AddDefinition("zbf_neuro_shield_reflect", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

	zclib.Effect.ParticleEffect("zbf_neuro_shield_reflect", pos, angle_zero)
	zclib.Sound.EmitFromPosition(pos, "zbf_neuro_shield_reflect")
end)
