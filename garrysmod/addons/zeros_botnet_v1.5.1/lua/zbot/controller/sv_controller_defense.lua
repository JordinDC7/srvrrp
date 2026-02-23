/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if not SERVER then return end
zbf = zbf or {}
zbf.Controller = zbf.Controller or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

/*
	The defense system gets powered by ticks and attacks unauthorized player near by.
	The perfect system to protect your base
	TODO I just dont believe this system would be any use in its current state, maybe in the future
*/

/*
	Everytime this function gets called every player who is not the owner or whitelisted gets a zap if he is near the controller
*/
function zbf.Controller.Defense_Attack(Controller)
	for v, _ in pairs(zclib.Player.GetInSphere(Controller:GetPos(), 500)) do
		if not IsValid(v) then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		if zclib.Player.IsOwner(v, Controller) then continue end

		local d = DamageInfo()
		d:SetDamage(5)
		d:SetAttacker(Controller)
		d:SetDamageType(DMG_SHOCK)
		v:TakeDamageInfo(d)

		zclib.NetEvent.Create("zbf_bot_damage",{v})

		local effectdata = EffectData()
        effectdata:SetOrigin(Controller:GetPos() + Vector(0, 0, 50))
        effectdata:SetMagnitude(100)
        effectdata:SetStart(v:GetPos() + Vector(0, 0, 50))
        effectdata:SetScale(25)
        effectdata:SetRadius(100)
        util.Effect("tooltracer", effectdata)
	end
end

function zbf.Controller.Defense_Heal(Controller)
	for v, _ in pairs(zclib.Player.GetInSphere(Controller:GetPos(), 500)) do
		if not IsValid(v) then continue end
		if v:Health() >= v:GetMaxHealth() then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

		v:SetHealth(math.Clamp(v:Health() + 5, 0, v:GetMaxHealth()))
		v:EmitSound("zbf_health_boost")

		local effectdata = EffectData()
        effectdata:SetOrigin(v:GetPos() + Vector(0, 0, 50))
        effectdata:SetMagnitude(100)
        effectdata:SetScale(5)
        effectdata:SetRadius(25)
        util.Effect("VortDispel", effectdata)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
