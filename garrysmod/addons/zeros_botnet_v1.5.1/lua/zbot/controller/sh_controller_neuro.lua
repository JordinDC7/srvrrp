/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*
	Returns the controllers neuro level
*/
function zbf.Controller.GetNeuroLevel(Controller)
	return zbf.Controller.GetStatValue(Controller,"neuro")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d


/*
	Checks if the controller has the requiered neuro level
*/
function zbf.Controller.HasNeuroRequierement(Controller, JobID)
	local JobData = zbf.Jobs.GetData(JobID)
	local level = 0
	if JobData and JobData.neuro_reg then level = JobData.neuro_reg end
	return zbf.Controller.GetNeuroLevel(Controller) >= level
end

/*
	Returns how strong the neuro attack will be (Only used for the Shield)
*/
function zbf.Controller.GetNeuroStrength(Controller)
	return math.Clamp(0.25 / 250 * zbf.Controller.GetNeuroLevel(Controller), 0, 1)
end

/*
	Returns the attack / defnese value depending on rank
*/
function zbf.Controller.GetNeuroAttackSuccess(ply)
	local result = zbf.config.Neuro.AttackSuccess[zclib.Player.GetRank(ply)]
	if result == nil then result = zbf.config.Neuro.AttackSuccess["default"] end
	if result == nil then result = 100 end
	return result
end

/*
	Returns a value from 0-1 on how strong the attack value is
*/
function zbf.Controller.Neuro_GetAttackValue(Attacker,Target)
	local Attack = zbf.Controller.GetNeuroAttackSuccess(Attacker)
	local Defense = zbf.Controller.GetNeuroAttackSuccess(Target)
	return math.Clamp(Attack / Defense, 0, 1)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

/*
	Returns if the Neuro Attack is successfull
*/
function zbf.Controller.Neuro_CanAttack(Attacker,Target)
	local Attack = zbf.Controller.GetNeuroAttackSuccess(Attacker)
	local Defense = zbf.Controller.GetNeuroAttackSuccess(Target)

	/*
		Attack = 100
		Defense = 250
	*/

	local prevent = hook.Run("zbf_Neuro_PreventAttack",Attacker,Target)
	if prevent then return false end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	// Ok lets calcuate the % diffrence between those two, or even better lets call it aspect
	local attacker_strength = math.Clamp(Attack / Defense, 0, 1)
	local defense_strength = math.Clamp(Defense / Attack, 0, 1)

	if attacker_strength >= defense_strength then
		// The Attacker won
		if zclib.util.RandomChance(95 * attacker_strength) then
			return true
		else
			return false
		end
	else
		// The defense won
		if zclib.util.RandomChance(95 * defense_strength) then
			return false
		else
			return true
		end
	end
end

/*
	Returns if the player can target this player for a neuro attack
*/
function zbf.Controller.Neuro_CanTarget(Attacker,Target)
	local cantarget = hook.Run("zbf_Neuro_CanTarget",Attacker,Target)
	if cantarget == false then return false end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	return true
end
