/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*

    The IP System can be used to target other players networks and attack them

*/

zbf.Controller.IPs = zbf.Controller.IPs or {}
// [IP] = ControllerEntity

/*
	Sets up the IPCache for the controller and assigns him a IP
*/
function zbf.Controller.SetupIP(Controller)
    zclib.Debug("zbf.Controller.SetupIP")

	// The IP we target via BotNet Attacks
	Controller.TargetIP = 0

    // This caches the scan result for the specified IP
	Controller.IPCache = {
		/*
		[IP] = {
			ControllerEntity = ent,
			ForeignConnections = 0,
			LastUpdate = CurTime()
		}
		*/
	}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

    zbf.Controller.AssignIP(Controller)
end

/*
	Trys to Assign the controller a new IP
*/
function zbf.Controller.AssignIP(Controller)
    zclib.Debug("zbf.Controller.AssignIP")

    if Controller.BotNetIP then zbf.Controller.IPs[Controller.BotNetIP] = nil end

	if zbf.config.Controller.ip_resetcache_onrefresh then
    	if Controller.BotNetIP then
			Controller.IPCache[Controller.BotNetIP] = nil
		end
	else
		if Controller.BotNetIP then
			Controller.IPCache[Controller.BotNetIP].ControllerEntity = NULL
		end
	end

	// Just so we dont do it for ever lets set a limit
	local Trys = 0
    local ValidIP = false
    while ValidIP == false and Trys < 50 do
        local ip = math.random(zbf.config.Controller.ip_size)
        if zbf.Controller.IPs[ip] == nil then
            ValidIP = ip
        end
		Trys = Trys + 1
    end

	// Stop if no IP was found in 50 trys
	if ValidIP == false then return end

    zbf.Controller.IPs[ValidIP] = Controller

    Controller.BotNetIP = ValidIP

    // The controller knows about his own ip
	Controller.IPCache[ValidIP] = {
		ControllerEntity = Controller,
		ForeignConnections = zbf.Controller.GetForeignConnections(Controller),
		LastUpdate = math.Round(CurTime())
	}

	// If ip_persistent is enabled then lets update any controller who scanned the field before
	if zbf.config.Controller.ip_ping_fadeout <= 0 then
		zbf.Controller.CheckIPPersistent(ValidIP)
	end

    zclib.Debug("New IP: " .. Controller.BotNetIP)
end

/*
	Clears the specified IP from the network
*/
function zbf.Controller.RemoveIP(IP)
	if IP == nil then return end
	zbf.Controller.IPs[ IP ] = nil

	// If ip_persistent is enabled then lets update any controller who scanned the field before
	if zbf.config.Controller.ip_ping_fadeout <= 0 then
		zbf.Controller.CheckIPPersistent(IP)
	end
end

/*
	Lets check which other controller on the server knows about this controllers IP
*/
function zbf.Controller.GetForeignConnections(Controller)
    local count = 0
    for _,ctrl in pairs(ents.FindByClass("zbf_controller")) do
        if not IsValid(ctrl) then continue end

		// We dont count our own connected controller as they are not forgein, counting them would just be confusing as fuck
		if zclib.Player.SharedOwner(ctrl,Controller) then continue end

        for _,data in pairs(ctrl.IPCache) do
            if not IsValid(data.ControllerEntity) then continue end
            if data.ControllerEntity == Controller then
                count = count + 1
                break
            end
        end
    end
    return count
end

/*
	Lets check which other controller on the server knows about this IP
*/
function zbf.Controller.GetForeignConnectionsForIP(IP,Controller)
    local count = 0
    for _,ctrl in pairs(ents.FindByClass("zbf_controller")) do
        if not IsValid(ctrl) then continue end

		// We dont count our own connected controller as they are not forgein, counting them would just be confusing as fuck
		if zclib.Player.SharedOwner(ctrl,Controller) then continue end

        for ip,data in pairs(ctrl.IPCache) do
            if ip == IP then
                count = count + 1
                break
            end
        end
    end
    return count
end

/*
	Called from CLIENT to change this controller IP
*/
util.AddNetworkString("zbf_Controller_RefreshIP")
net.Receive("zbf_Controller_RefreshIP", function(len,ply)
    zclib.Debug_Net("zbf_Controller_RefreshIP", len)
    if zclib.Player.Timeout(nil,ply) then return end

    local Controller = net.ReadEntity()
    if not IsValid(Controller) then return end
    if not IsValid(ply) then return end

    if zclib.util.InDistance(ply:GetPos(), Controller:GetPos(), 500) == false then return end

	if not zclib.Player.IsOwner(ply, Controller) then
		zclib.Notify(ply,zbf.language[ "Youdontown" ], 1)
		return
	end

	if Controller.NextIPRefresh and Controller.NextIPRefresh > CurTime() then return end
	Controller.NextIPRefresh = CurTime() + zbf.config.Controller.ip_refresh

	// Find every controller who knows the current IP of this controller and remove it from its cache
	local CurrentIP = Controller.BotNetIP
	for _,ctrl in pairs(zbf.Controller.List) do
		if not IsValid(ctrl) then continue end

		// Does this controller who know the currentIP
		if ctrl.IPCache[CurrentIP] then

			local LastUpdate = ctrl.IPCache[CurrentIP].LastUpdate
			ctrl.IPCache[CurrentIP] = {}
			ctrl.IPCache[CurrentIP].LastUpdate = LastUpdate
			ctrl.IPCache[CurrentIP].ControllerEntity = NULL
			ctrl.IPCache[CurrentIP].ForeignConnections = 0

			zbf.Controller.IPCache_Update(ctrl, zclib.Player.GetOwner(ctrl))
		end
	end

    // Lets generate a new IP which is not yet used
    zbf.Controller.AssignIP(Controller)

	// Lets reset the IP Cache too, as a con for changing the IP
	if zbf.config.Controller.ip_resetcache_onrefresh then
		Controller.IPCache = {}
	end

	timer.Simple(0.1, function()
		if not IsValid(Controller) or not IsValid(ply) then return end
		zbf.Controller.IPCache_Update(Controller, ply)
	end)

	timer.Simple(0.15, function()
		if not IsValid(Controller) or not IsValid(ply) then return end
		net.Start("zbf_Controller_RefreshIP")
		net.Send(ply)
	end)
end)

/*
	Return if this IP has a controller on it
*/
function zbf.Controller.GetFromIP(BotNetIP)
	return zbf.Controller.IPs[ BotNetIP ]
end

/*
	Check if this IP has a controller
*/
function zbf.Controller.CheckIP(Controller, BotNetIP)
	local FieldController = zbf.Controller.IPs[BotNetIP]

	if IsValid(FieldController) then
		Controller.IPCache[BotNetIP] = {
			ControllerEntity = FieldController,
			CreationTime = FieldController:GetCreationTime(),
			ForeignConnections = zbf.Controller.GetForeignConnections(FieldController),
			LastUpdate = math.Round(CurTime())
		}
	else
		Controller.IPCache[BotNetIP] = {
			ControllerEntity = NULL,
			ForeignConnections = zbf.Controller.GetForeignConnectionsForIP(BotNetIP,Controller),
			LastUpdate = math.Round(CurTime())
		}
	end
end

/*
	Forces any Controller who previously pinged the provided IP to Update its IPCache about it
*/
function zbf.Controller.CheckIPPersistent(IP)
	if IP == nil then return end
	for k,v in pairs(zbf.Controller.List) do
		if not IsValid(v) then continue end

		// Has this controller previously pinged this IP?
		if v.IPCache[IP] then
			// If so then lets update him again that someone just got this IP assigned
			zbf.Controller.CheckIP(v, IP)

			zbf.Controller.IPCache_Update(v, zclib.Player.GetOwner(v))
		end
	end
end

/*
	Reveals the IPs for both the controller and the TargetIP
*/
function zbf.Controller.IPHandshake(Attacker_IP,Target_IP)
	local Attacker = zbf.Controller.GetFromIP(Attacker_IP)
	local Target = zbf.Controller.GetFromIP(Target_IP)

	if IsValid(Attacker) then
		zbf.Controller.CheckIP(Attacker, Target_IP)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

	if IsValid(Target) then
		zbf.Controller.CheckIP(Target, Attacker_IP)
	end

	// If ip_persistent is enabled then lets update any controller who scanned the field before
	if zbf.config.Controller.ip_ping_fadeout <= 0 then
		zbf.Controller.CheckIPPersistent(Target_IP)
		zbf.Controller.CheckIPPersistent(Attacker_IP)
	end
end

/*
	Just to be save lets make sure this BotNet does have a IP Cache where the same controller covers multiple IP fields
*/
function zbf.Controller.IPCache_Verify(Controller)
	zclib.Debug("zbf.Controller.IPCache_Verify " .. tostring(Controller))
	local FoundEnts = {}
	for k,v in pairs(Controller.IPCache) do
		if v == nil then
			Controller.IPCache[k] = nil
			zclib.Debug("IPCache data invalid!")
			continue
		end
		if not IsValid(v.ControllerEntity) then
			v.ControllerEntity = nil
			zclib.Debug("IPCache ControllerEntity invalid!")
			continue
		end

		// The controller was found in a diffrent IP field before, lets removed it
		if FoundEnts[v.ControllerEntity] then
			zclib.Debug("IPCache ControllerEntity already in list, Skip!")
			Controller.IPCache[k] = nil
			continue
		end

		// This check exists for the very small chance that the entity refrenced in the IP Cache is not the original entity but instead is one thats Reusing the original entities EntIndex
		if v.ControllerEntity:GetCreationTime() ~= v.CreationTime then
			Controller.IPCache[k] = nil
			zclib.Debug("IPCache ControllerEntity CreationTime differs from entity GetCreationTime!")
			continue
		end

		FoundEnts[v.ControllerEntity] = true
	end
end

/*
	Sends the client
		- The Controller Entity
		- His BotNet ID
		- The current Target IP
		- Every Cached / Scanned IP
*/
util.AddNetworkString("zbf_Controller_IPCache_Update")
function zbf.Controller.IPCache_Update(Controller, ply)
	if not IsValid(ply) then return end
	zclib.Debug("zbf.Controller.IPCache_Update")

	// Just to be save lets make sure this BotNet does have a IP Cache where the same controller covers multiple IP fields
	zbf.Controller.IPCache_Verify(Controller)

	// Only add all your other controllers if you own this controller
	if zclib.Player.IsOwner(ply, Controller) then
		// Lets get all the controller who we own in to our scan list
		for k, v in pairs(ents.FindByClass("zbf_controller")) do
			if IsValid(v) and zclib.Player.IsOwner(ply, v) then
				zbf.Controller.CheckIP(Controller, v.BotNetIP)
			end
		end
	end

	net.Start("zbf_Controller_IPCache_Update")
	net.WriteEntity(Controller)
	net.WriteUInt(Controller.BotNetIP, 15)
	net.WriteUInt(Controller.TargetIP,15)
	local count = table.Count(Controller.IPCache)
	net.WriteUInt(count, 15)
	for ip, data in pairs(Controller.IPCache) do
		net.WriteUInt(ip, 15)
		net.WriteEntity(data.ControllerEntity)
		net.WriteUInt(data.ForeignConnections,8)
		net.WriteUInt(data.LastUpdate,32)
	end
	net.Send(ply)
end

/*
	Performs a Ping attack which reveals any BotNet which might be hidden on this IP
*/
function zbf.Controller.Attack_Ping(Controller,ply,BotNetIP)
	local Target = zbf.Controller.IPs[BotNetIP]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	// If this IP has a BotNet and the BotNets defense is stronger then ours then it stays hidden
	/*
		NOTE The player will probably notice that his Ping didnt reveal anything, not even a Empty IP Field but thats fine,
		it doesent matter that thats a BotNet indicator, all that matters is that he does not get any more informations then that
	*/
	if IsValid(Target) and zbf.Controller.GetAttackValue_Stealth(Controller, Target) then return end

	// If no player is on this field then we could find random loot
	if Controller.FoundLoot == nil then Controller.FoundLoot = {} end
	if not IsValid(Target) and not Controller.FoundLoot[BotNetIP] and zclib.util.RandomChance(zbf.config.Controller.ip_loot.chance) then

		// Check if we already pinged this field before, if we did then check how much time has passed.
		// NOTE We dont want the player to get loot from the same field twice

		// How much money did we find
		local money = math.random(zbf.config.Controller.ip_loot.min_money,zbf.config.Controller.ip_loot.min_money)

		// What currency did we find
		local c_type = math.random(#zbf.Currency.List)

		// Calculate how much a faction of the full money amount of this type of currency is
		local c_amount = money / zbf.Currency.GetValue(c_type)

		// Give player the loot
		zbf.Wallet.AddCurrency(Controller,c_type,c_amount)

		Controller.FoundLoot[BotNetIP] = true
	end

	// Get all the info about the specified IP and cache it in the controller
	zbf.Controller.CheckIP(Controller, BotNetIP)

	// Update the player who started it
	zbf.Controller.IPCache_Update(Controller, ply)

	// If ip_persistent is enabled then lets update any controller who scanned the field before
	if zbf.config.Controller.ip_ping_fadeout <= 0 then
		zbf.Controller.CheckIPPersistent(BotNetIP)
	end

	// Add some ping hints to the controller which decay overtime
	// The hints show a potential BotNet with some wrong hints to throw the player of
	if zbf.config.Controller.ip_hints and zbf.config.Controller.ip_hints.enabled then
		zbf.Controller.AddHints(Controller)
	end

	// Call custom hook
	hook.Run("zbf_BotNet_Ping",Controller,ply,Target,zclib.Player.GetOwner(Target))
end

/*
	Steals a certain amount of Currency if the specified IP has a BotNet connected
*/
function zbf.Controller.Attack_Steal(Controller,ply,BotNetIP)

	local Target = zbf.Controller.IPs[BotNetIP]

	// Reveals the IP of both BotNets to each other
	if zbf.config.BotNet.RevealAttacker then
		zbf.Controller.IPHandshake(Controller.BotNetIP,BotNetIP)
	end

	// Is there even a BotNet at this IP?
	if not IsValid(Target) then return end

	// The max amount of $ that can be stolen according to the Controllers Attack value - Target Defense value
	local MaxSteal = zbf.Controller.GetAttackValue_Money(Controller,Target)

	// Get a list of all the crypto currencies inside the targets controller which money value combined is less or equal > MaxSteal
	local currencyList = zbf.Wallet.GetCurrencyMoneyAmount(Target,MaxSteal)

	// How much money does the target have?
	if table.Count(currencyList) > 0 then

		// Call custom hook
		hook.Run("zbf_BotNet_Steal",Controller,ply,Target,zclib.Player.GetOwner(Target),currencyList)

		for c_type,c_amount in pairs(currencyList) do

			// The new currency amount of the target
			local NewAmount = zbf.Wallet.GetCurrency(Target,c_type) - c_amount

			// Take the currency from the target
			zbf.Wallet.SetCurrency(Target,c_type,NewAmount)

			// Give the currency to the attacker
			zbf.Wallet.AddCurrency(Controller,c_type,c_amount)
		end
	end
end

/*
	Causes a certain amount of Bots from the Target BotNet to reboot
*/
function zbf.Controller.Attack_Reboot(Controller,ply,BotNetIP)

	local Target = zbf.Controller.IPs[BotNetIP]

	// Reveals the IP of both BotNets to each other
	if zbf.config.BotNet.RevealAttacker then
		zbf.Controller.IPHandshake(Controller.BotNetIP,BotNetIP)
	end

	// Is there even a BotNet at this IP?
	if not IsValid(Target) then return end

	local AttackBotCount = zbf.Controller.GetAttackValue_Bots(Controller,Target)
	if AttackBotCount <= 0 then return end

	// Call custom hook
	hook.Run("zbf_BotNet_Reboot",Controller,ply,Target,zclib.Player.GetOwner(Target),AttackBotCount)

	local Count = 0
	local timerid = "zbf_controller_attack_reboot_" .. Controller:EntIndex()
	zclib.Timer.Remove(timerid)
	zclib.Timer.Create(timerid,0.1,0,function()
		if not IsValid(Target) then zclib.Timer.Remove(timerid) return end

		local device = zbf.Controller.GetRandomBot(Target)
		if IsValid(device) then zbf.Bot.Error(device, ZBF_ERRORTYPE_REBOOT,30) end

		Count = Count + 1

		if Count >= AttackBotCount then zclib.Timer.Remove(timerid) end
	end)
end

/*
	Causes a certain amount of Bots from the Target BotNet to get damaged
*/
function zbf.Controller.Attack_Crash(Controller,ply,BotNetIP)

	local Target = zbf.Controller.IPs[BotNetIP]

	// Reveals the IP of both BotNets to each other
	if zbf.config.BotNet.RevealAttacker then
		zbf.Controller.IPHandshake(Controller.BotNetIP,BotNetIP)
	end

	// Is there even a BotNet at this IP?
	if not IsValid(Target) then return end

	// How many bots can we attack
	local AttackBotCount = zbf.Controller.GetAttackValue_Bots(Controller,Target)
	if AttackBotCount <= 0 then return end

	// Calculate how much damage gets applied per bot
	local TotalAttackDamage = zbf.Controller.GetAttackValue_Health(Controller, Target)

	// Get a list of all the bots we will attack on the Target network
	local AttackList = {}
	for i = 1,AttackBotCount do
		local device = zbf.Controller.GetRandomBot(Target)
		if IsValid(device) and not AttackList[device] then
			AttackList[device] = true
		end
	end
	local AttackDamagePerBot = TotalAttackDamage / AttackBotCount

	// Call custom hook
	hook.Run("zbf_BotNet_Crash",Controller,ply,Target,zclib.Player.GetOwner(Target),AttackBotCount,AttackDamagePerBot)

	local Count = 0
	local timerid = "zbf_controller_attack_crash_" .. Controller:EntIndex()
	zclib.Timer.Remove(timerid)
	zclib.Timer.Create(timerid,0.1,0,function()
		if not IsValid(Target) then zclib.Timer.Remove(timerid) return end

		local _,device = table.Random(AttackList)

		//local device = zbf.Controller.GetRandomBot(Target)
		if IsValid(device) then
			AttackList[device] = nil
			zbf.Bot.Error(device ,ZBF_ERRORTYPE_CRASH,5,AttackDamagePerBot)
		end

		Count = Count + 1

		//if Count >= AttackBotCount then zclib.Timer.Remove(timerid) end
		if table.Count(AttackList) <= 0 then zclib.Timer.Remove(timerid) end
	end)
end

/*
	Reassigns a certain amount of Bots from the Target BotNet to our own BotNet, aka make them zombies
*/
function zbf.Controller.Attack_Highjack(Controller,ply,BotNetIP)

	local Target = zbf.Controller.IPs[BotNetIP]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

	// Reveals the IP of both BotNets to each other
	if zbf.config.BotNet.RevealAttacker then
		zbf.Controller.IPHandshake(Controller.BotNetIP,BotNetIP)
	end

	// Is there even a BotNet at this IP?
	if not IsValid(Target) then return end

	local AttackBotCount = zbf.Controller.GetAttackValue_Bots(Controller,Target)
	if AttackBotCount <= 0 then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	// Calculate how much damage gets applied per bot
	local TotalHighjackTime = zbf.Controller.GetAttackValue_Highjack(Controller, Target)

	// Its better if cap the highjack time per bot to 120 seconds or so
	local HighjackTimePerBot = math.Clamp(TotalHighjackTime / AttackBotCount,1,180)

	// Call custom hook
	hook.Run("zbf_BotNet_Highjack",Controller,ply,Target,zclib.Player.GetOwner(Target),AttackBotCount,HighjackTimePerBot)

	local Count = 0
	local timerid = "zbf_controller_attack_highjack_" .. Controller:EntIndex()
	zclib.Timer.Remove(timerid)
	zclib.Timer.Create(timerid,0.1,0,function()
		if not IsValid(Target) then zclib.Timer.Remove(timerid) return end

		local device = zbf.Controller.GetRandomBot(Target)
		if IsValid(device) and device:GetController() ~= Controller then

			// Set the bot in highjack mode
			// NOTE In this error mode he will still work normaly but his controller cant be changed
			zbf.Bot.Error(device ,ZBF_ERRORTYPE_HIGHJACK,HighjackTimePerBot)

			// Connect the bot to another controller
			zbf.Bot.SetController(device, Controller)
		end

		Count = Count + 1

		if Count >= AttackBotCount then zclib.Timer.Remove(timerid) end
	end)
end

/*
	Reveals every single IP to the specified controller
*/
concommand.Add("zbf.Controller.CheckAllIP", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()

		if tr and IsValid(tr.Entity) and tr.Entity:GetClass() == "zbf_controller" then
			for i = 1, zbf.config.Controller.ip_size do
				zbf.Controller.CheckIP(tr.Entity, i)
			end
		end
	end
end)

/*
	Reveals any IP field wich is owned by a player
*/
concommand.Add("zbf.Controller.RevealAll", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()

		if tr and IsValid(tr.Entity) and tr.Entity:GetClass() == "zbf_controller" then
			for k, v in pairs(zbf.Controller.IPs) do
				if IsValid(v) then
					zbf.Controller.CheckIP(tr.Entity, k)
				end
			end
		end
	end
end)
