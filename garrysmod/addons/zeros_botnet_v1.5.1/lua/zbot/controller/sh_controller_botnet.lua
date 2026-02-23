/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*
	Returns if the attacked BotNet will stay hidden
*/
function zbf.Controller.GetAttackValue_Stealth(Controller, Defense)
	local diff = zbf.Controller.GetStatValue(Controller, "attack")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	if IsValid(Defense) then
		diff = diff - zbf.Controller.GetStatValue(Defense, "defense")
	end

	return diff <= 0
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a


/*
	Returns how much money this botnet can / will steal , Attack Diffrence * 10
*/
function zbf.Controller.GetAttackValue_Money(Controller, Defense)
	local diff = zbf.Controller.GetStatValue(Controller, "attack")

	if IsValid(Defense) then
		diff = math.Clamp(diff - zbf.Controller.GetStatValue(Defense, "defense"), 0, 99999999999)
	end

	return diff * 10
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

/*
	Returns how many bots can / will be attacked
*/
function zbf.Controller.GetAttackValue_Bots(Controller, Defense)
	local diff = zbf.Controller.GetStatValue(Controller, "attack")

	if IsValid(Defense) then
		diff = math.Clamp(diff - zbf.Controller.GetStatValue(Defense, "defense"), 0, 99999999999)
	end

	return math.Round(math.Clamp(diff / 50,0,200))
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

/*
	Returns the total amount of damaged that will be caused
*/
function zbf.Controller.GetAttackValue_Health(Controller, Defense)
	local diff = zbf.Controller.GetStatValue(Controller, "attack")

	if IsValid(Defense) then
		diff = math.Clamp(diff - zbf.Controller.GetStatValue(Defense, "defense"), 0, 99999999999)
	end

	return math.Round(diff / 2)
end

/*
	Returns the total amount of time the bots will be assigned to the attackers network
*/
function zbf.Controller.GetAttackValue_Highjack(Controller, Defense)
	local diff = zbf.Controller.GetStatValue(Controller, "attack")

	if IsValid(Defense) then
		diff = math.Clamp(diff - zbf.Controller.GetStatValue(Defense, "defense"), 0, 99999999999)
	end

	return math.Round(diff / 2)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
