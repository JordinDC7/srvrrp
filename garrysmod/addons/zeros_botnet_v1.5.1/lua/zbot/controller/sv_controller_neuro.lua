/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*

    Neuro Tasks are aimed at players and requiere a special type of CPU
	Neuro task requiere a certain neuro level in order to reach players
	The Neuro Level of a controller is defined by the BotNets neurobots, aka you need a bunch of brain CPU in order to increase the overall neuro level to even execute those tasks
*/

/*
	Increases the targets movement speed / jump height
*/
function zbf.Controller.Neuro_Boost(Controller,ply,TargetID)
	if not IsValid(ply) then return end
	local Target = Player(TargetID)
	if not IsValid(Target) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	// If the player is not allowed to target this player then stop
	if not zbf.Controller.Neuro_CanTarget(ply,Target) then return end

	local str = zbf.language[ "notify_neuro_boost" ]
	str = string.Replace(str,"$PlayerName",ply:Nick())
	str = string.Replace(str,"$Duration",zbf.config.Neuro.Boost_duration)
	zclib.Notify(Target, str, 0)

	// Play speed up sound
	Target:EmitSound("zbf_speed_up")

	zbf.Neuro.MakeFaster(Target,zbf.config.Neuro.Boost_duration)

	// Call custom hook
	hook.Run("zbf_Neuro_Boost", ply, Target)
end

/*
	Increases the players health
*/
function zbf.Controller.Neuro_Vitality(Controller, ply, TargetID)
	if not IsValid(ply) then return end
	local Target = Player(TargetID)
	if not IsValid(Target) then return end

	// If the player is not allowed to target this player then stop
	if not zbf.Controller.Neuro_CanTarget(ply,Target) then return end

	local str = zbf.language[ "notify_neuro_health" ]
	str = string.Replace(str,"$PlayerName",ply:Nick())
	str = string.Replace(str,"$Amount",zbf.config.Neuro.Vitality_amount)
	zclib.Notify(Target, str, 0)

	Target:SetHealth(math.Clamp(Target:Health() + zbf.config.Neuro.Vitality_amount, 0, Target:GetMaxHealth()))
	Target:EmitSound("zbf_health_boost")


	// Call custom hook
	hook.Run("zbf_Neuro_Vitality", ply, Target)
end

/*
	Increases the players health
*/
function zbf.Controller.Neuro_Shield(Controller, ply, TargetID)
	if not IsValid(ply) then return end
	local Target = Player(TargetID)
	if not IsValid(Target) then return end

	// If the player is not allowed to target this player then stop
	if not zbf.Controller.Neuro_CanTarget(ply,Target) then return end

	local str = zbf.language[ "notify_neuro_shield" ]
	str = string.Replace(str,"$PlayerName",ply:Nick())
	str = string.Replace(str,"$Duration",zbf.config.Neuro.Shield_duration)
	zclib.Notify(Target, str, 0)

	// Play shield sound
	Target:EmitSound("zbf_shield")

	// This will define how much damage will be reducted
	// Lets say -0.25 damage per 250 NeuroLevel
	// So with this logic the player will have godmode if his neuro level reaches 1000
	local strength = math.Clamp((0.25 / 250) * zbf.Controller.GetNeuroLevel(Controller),0,1)

	zbf.Neuro.Protect(Target,zbf.config.Neuro.Shield_duration,strength)

	// Call custom hook
	hook.Run("zbf_Neuro_Shield", ply, Target)
end

local function CanAttack(Controller,ply,Target)

	// Depending on the rank of both players the attack might be a hit or miss
	if not zbf.Controller.Neuro_CanAttack(ply,Target) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

		// Should we crash the attacks botnet?
		if zbf.config.Neuro.CrashOnAttackFail then
			local defense_strength = zbf.Controller.Neuro_GetAttackValue(Target,ply)
			local BotCount = 50 * defense_strength
			zbf.Controller.MassError(Controller, BotCount, ZBF_ERRORTYPE_CRASH, 10, 3)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

		zclib.Notify(ply, string.Replace(zbf.language[ "NeuroAttackFailed" ], "$Player", Target:Nick()), 1)
		zclib.Notify(Target, string.Replace(zbf.language[ "NeuroAttackPrevented" ], "$Player", ply:Nick()), 0)
		return false
	end
	return true
end

/*
	Decreases the targets movement speed / jump height
*/
function zbf.Controller.Neuro_Cripple(Controller,ply,TargetID)
	if not IsValid(ply) then return end
	local Target = Player(TargetID)
	if not IsValid(Target) then return end

	// If the player is not allowed to target this player then stop
	if not zbf.Controller.Neuro_CanTarget(ply,Target) then return end

	// We cant use negative neuro hacks on players who got a protection shield
	if zbf.Neuro.IsProtected(Target) then return end

	if not CanAttack(Controller,ply,Target) then return end

	local str = zbf.language[ "notify_neuro_cripple" ]
	str = string.Replace(str,"$PlayerName",ply:Nick())
	str = string.Replace(str,"$Duration",zbf.config.Neuro.Cripple_duration)
	zclib.Notify(Target, str, 1)

	// Play slow down sound
	Target:EmitSound("zbf_speed_down")

	zbf.Neuro.MakeSlower(Target,zbf.config.Neuro.Cripple_duration)

	// Call custom hook
	hook.Run("zbf_Neuro_Cripple", ply, Target)
end

/*
	Causes the targets implants to overheat
*/
function zbf.Controller.Neuro_Overheat(Controller,ply,TargetID)
	if not IsValid(ply) then return end
	local Target = Player(TargetID)
	if not IsValid(Target) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	// If the player is not allowed to target this player then stop
	if not zbf.Controller.Neuro_CanTarget(ply,Target) then return end

	// We cant use negative neuro hacks on players who got a protection shield
	if zbf.Neuro.IsProtected(Target) then return end

	if not CanAttack(Controller,ply,Target) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

	local str = zbf.language[ "notify_neuro_overheat" ]
	str = string.Replace(str,"$PlayerName",ply:Nick())
	str = string.Replace(str,"$Duration",zbf.config.Neuro.Overheat_duration)
	zclib.Notify(Target, str, 1)

	Target:Ignite(zbf.config.Neuro.Overheat_duration,10)

	// Call custom hook
	hook.Run("zbf_Neuro_Overheat", ply, Target)
end

/*
	Impacts the targets health and sight
*/
function zbf.Controller.Neuro_Aneurysm(Controller,ply,TargetID)
	if not IsValid(ply) then return end
	local Target = Player(TargetID)
	if not IsValid(Target) then return end

	// If the player is not allowed to target this player then stop
	if not zbf.Controller.Neuro_CanTarget(ply,Target) then return end

	// We cant use negative neuro hacks on players who got a protection shield
	if zbf.Neuro.IsProtected(Target) then return end

	if not CanAttack(Controller,ply,Target) then return end

	local str = zbf.language[ "notify_neuro_aneurysm" ]
	str = string.Replace(str,"$PlayerName",ply:Nick())
	str = string.Replace(str,"$Duration",zbf.config.Neuro.Aneurysm_duration)
	zclib.Notify(Target, str, 1)

	zbf.Neuro.Aneurysm(Target,zbf.config.Neuro.Aneurysm_duration)

	// Call custom hook
	hook.Run("zbf_Neuro_Aneurysm", ply, Target)
end

/*
	Boosts the targets health and size
*/
function zbf.Controller.Neuro_Growth(Controller,ply,TargetID)
	if not IsValid(ply) then return end
	local Target = Player(TargetID)
	if not IsValid(Target) then return end

	// If the player is not allowed to target this player then stop
	if not zbf.Controller.Neuro_CanTarget(ply,Target) then return end

	local str = zbf.language[ "notify_neuro_growth" ]
	str = string.Replace(str,"$PlayerName",ply:Nick())
	str = string.Replace(str,"$Duration",zbf.config.Neuro.Growth_duration)
	zclib.Notify(Target, str, 0)

	zbf.Neuro.GrowthHormones(Target,zbf.config.Neuro.Growth_duration)

	// Call custom hook
	hook.Run("zbf_Neuro_Growth", ply, Target)
end
