/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Controller = zbf.Controller or {}
zbf.Controller.List = zbf.Controller.List or {}

/*
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	The controller is used to manage all the connected devices in radius

*/

function zbf.Controller.Initialize(Controller)
	zclib.Debug("zbf.Controller.Initialize")

	zbf.Controller.SetupIP(Controller)

	table.insert(zbf.Controller.List,Controller)

	zbf.Wallet.Setup(Controller)

	Controller:PrecacheGibs()

	if zbf.config.Damageable["zbf_controller"] >  0 then
		Controller:SetHealth(zbf.config.Damageable["zbf_controller"])
		Controller:SetMaxHealth(zbf.config.Damageable["zbf_controller"])
	end
end

function zbf.Controller.OnRemove(Controller)
	zbf.Controller.RemoveIP(Controller.BotNetIP)
end

function zbf.Controller.OnUse(Controller, ply)
	zclib.Debug("zbf.Controller.OnUse")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	/*
	if table.Count(zbf.Controller.GetAvailableJobs(ply)) <= 0 then
		zclib.Notify(ply, "There are no jobs available for you on this controller, so no touchy touchy.", 0)
		return
	end
	*/

	// Is the controller currently disabled?
	if zbf.Controller.IsDisabled(Controller,ply) then return end

	// Open interface to manage Controllers and devices
	zbf.Controller.Open(Controller, ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

util.AddNetworkString("zbf_Controller_Open")

function zbf.Controller.Open(Controller, ply)
	zclib.Debug("zbf.Controller.Open")

	//Send the player all the current scans on the controller
	zbf.Controller.IPCache_Update(Controller, ply)

	// Send the player any active cooldowns this controller has
	zbf.Controller.UpdateCooldowns(Controller, ply)

	// Update and possible send job offers
	zbf.Controller.UpdateJobOffers(Controller,ply)

	// Update the player about all the jobs he has currenly unlocked
	zbf.Controller.UpdateUnlockedJobs(ply)

	// Send the player all the currencies which are stored in the controller
	zbf.Wallet.UpdateCurrency(Controller,ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	// Send the player all the IP Hints this controller has
	zbf.Controller.UpdateHints(Controller,ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	timer.Simple(0.05, function()
		if not IsValid(Controller) or not IsValid(ply) then return end
		net.Start("zbf_Controller_Open")
		net.WriteEntity(Controller)
		net.Send(ply)
	end)
end

util.AddNetworkString("zbf_Controller_ConnectDevices")
net.Receive("zbf_Controller_ConnectDevices", function(len, ply)
	zclib.Debug_Net("zbf_Controller_ConnectDevices", len)
	if zclib.Player.Timeout(nil, ply) then return end
	local controller = net.ReadEntity()
	local listLength = net.ReadUInt(16)
	local devices = {}

	for i = 1, listLength do
		table.insert(devices, {
			device = net.ReadEntity(),
			connect = net.ReadBool()
		})
	end

	if not IsValid(controller) then return end
	if not IsValid(ply) then return end
	if zclib.util.InDistance(ply:GetPos(), controller:GetPos(), 500) == false then return end

	if not zclib.Player.IsOwner(ply, controller) then
		zclib.Notify(ply,zbf.language[ "Youdontown" ], 1)
		return
	end

	for k, v in pairs(devices) do
		if v and IsValid(v.device) then

			// Nobody can connected / reconnect bots which are highjacked
			if zbf.Bot.IsHighjacked(v.device) then continue end

			if v.connect then
				zbf.Bot.SetController(v.device, controller)
			else
				zbf.Bot.SetController(v.device, NULL)
			end
		end
	end

	timer.Simple(0.1, function()
		net.Start("zbf_Controller_ConnectDevices")
		net.WriteEntity(controller)
		net.Broadcast()
	end)
end)

function zbf.Controller.Destroy(Controller)
	if Controller.Destroyed then return end
	Controller.Destroyed = true
	zclib.Entity.SafeRemove(Controller)
	zclib.NetEvent.Create("zbf_Controller_destroy", {Controller})
end

function zbf.Controller.Damage(Controller, dmg)
	if zbf.config.Damageable["zbf_controller"] <= 0 then return end
	Controller:SetHealth(math.Clamp(Controller:Health() - (dmg or 5), 0, Controller:GetMaxHealth()))

	zclib.NetEvent.Create("zbf_bot_damage", {Controller})

	if Controller:Health() <= 0 then
		zbf.Controller.Destroy(Controller)
	end
end

function zbf.Controller.OnTakeDamage(Controller, dmginfo)
	zclib.Debug("zbf.Controller.OnTakeDamage")
	if not IsValid(Controller) then return end

	if (not Controller.m_bApplyingDamage) then
		Controller.m_bApplyingDamage = true
		Controller:TakeDamageInfo(dmginfo)
		zbf.Controller.Damage(Controller, dmginfo:GetDamage())
		Controller.m_bApplyingDamage = false
	end
end
