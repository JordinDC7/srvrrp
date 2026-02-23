/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*

	Handels the Buying  / selling of Bots

*/

util.AddNetworkString("zbf_Controller_Purchase")
net.Receive("zbf_Controller_Purchase", function(len, ply)
	zclib.Debug_Net("zbf_Controller_Purchase", len)
	if zclib.Player.Timeout(nil, ply) then return end

	local controller = net.ReadEntity()
	local botID = net.ReadUInt(8)

	if zbf.config.Controller.disable_shop then return end

	local tr = ply:GetEyeTrace()

	if tr == nil or not tr.Hit then return end
	if tr.HitPos == nil then return end
	if zclib.util.InDistance(controller:GetPos(), tr.HitPos, 500) == false then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	if not zclib.Player.IsOwner(ply, controller) then
		zclib.Notify(ply,zbf.language[ "Youdontown" ], 1)
		return
	end

	local BotLimit = zbf.Controller.GetBotLimit(controller, ply)
	local BotCount = zbf.Controller.GetBotCount(ply)

	// Can the player spawn more bots?
	if BotCount >= BotLimit then
		zclib.Notify(ply, zbf.language[ "BotLimit" ], 1)
		zclib.Notify(ply, "[ " .. BotCount .. " / " .. BotLimit .. " ]", 1)
		return
	end

	local target = tr.Entity
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	if not zbf.Bot.CanBuy(ply, botID) then return end

	local price = zbf.Bot.GetPrice(botID)

	// Check if the player has enough money
	if not zclib.Money.Has(ply, price) then
		zclib.Notify(ply, zbf.language[ "Not enough money!" ], 1)

		return
	end

	// We didnt hit a target
	if not IsValid(target) then
		zclib.Money.Take(ply, price)
		zclib.Notify(ply, "-" .. zclib.Money.Display(price), 3)
		// Spawn the bot
		local bot = ents.Create("zbf_bot")
		bot:SetPos(tr.HitPos + tr.Normal:Angle():Up() * 25)
		bot:SetBotID(botID)
		bot:Spawn()
		bot:Activate()
		zclib.Player.SetOwner(bot, ply)
		zclib.NetEvent.Create("zbf_bot_buy", { bot:LocalToWorld(Vector(5, 0, 0)) })
		zbf.Bot.SetController(bot, controller)
		return
	end

	// We hit a rack so lets add a bot if it has a free spot
	local class = target:GetClass()

	if class == "zbf_rack" then

		if not zclib.Player.IsOwner(ply, target) then
			zclib.Notify(ply,zbf.language[ "Youdontown" ], 1)
			return
		end

		// Check if we got a free spot for a bot on the rack
		local key = zbf.Rack.GetFreeSpot(target)

		if key == nil then
			zclib.Notify(ply, zbf.language[ "RackFull" ], 1)
			return
		end

		zclib.Money.Take(ply, price)
		zclib.Notify(ply, "-" .. zclib.Money.Display(price), 3)

		// Spawn the bot and add it on the rack
		local bot = ents.Create("zbf_bot")
		bot:SetNoDraw(true)
		bot:SetPos(tr.HitPos)
		bot:SetBotID(botID)
		bot:Spawn()
		bot:Activate()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

		zbf.Rack.AddBot(target, bot)
		zclib.Player.SetOwner(bot, ply)

		timer.Simple(0.1, function()
			if IsValid(bot) then
				zclib.NetEvent.Create("zbf_bot_buy", { bot:LocalToWorld(Vector(5, 0, 0)) })
				bot:SetNoDraw(false)
			end
		end)

		zbf.Bot.SetController(bot, controller)

		return
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	// We hit a bot so lets upgrade it
	if class == "zbf_bot" then
		// 224293224
		local bData = zbf.Bot.GetData(botID)

		// Check if the bot doesent have allready the specified ID
		if target:GetBotID() == botID then
			if target:Health() ~= bData.health then
				target:SetHealth(bData.health)
				zclib.NetEvent.Create("zbf_bot_fix",{target})
			end
			return
		end


		zclib.Money.Take(ply, price)
		zclib.Notify(ply, "-" .. zclib.Money.Display(price), 3)

		zclib.NetEvent.Create("zbf_bot_buy", { target:LocalToWorld(Vector(5, 0, 0)) })

		local rack = target:GetParent()
		target:SetParent(nil)
		zbf.Rack.AddBotAtID(rack, target, target.RackID)
		zbf.Bot.Update(target, botID)
	end
end)

util.AddNetworkString("zbf_Controller_Sell")
net.Receive("zbf_Controller_Sell", function(len, ply)
	zclib.Debug_Net("zbf_Controller_Sell", len)
	if zclib.Player.Timeout(nil, ply) then return end
	local bot = net.ReadEntity()
	if not IsValid(bot) then return end
	if bot:GetClass() ~= "zbf_bot" then return end
	if zclib.util.InDistance(ply:GetPos(), bot:GetPos(), 300) == false then return end

	if zbf.config.Controller.sell_refund <= 0 then return end

	// Check if the player owns this bot
	if not zclib.Player.IsOwner(ply, bot) then
		zclib.Notify(ply,zbf.language[ "Youdontown" ], 1)

		return
	end

	if zbf.Bot.IsHighjacked(bot) then
		zclib.Notify(ply, zbf.language[ "CantSellHighjack" ], 1)
		return
	end

	if zbf.Bot.HasError(bot) then
		zclib.Notify(ply,zbf.language[ "CantSellError" ], 1)
		return
	end

	// Give player the money according to bot id
	local money = zbf.Bot.GetPrice(bot:GetBotID()) * zbf.config.Controller.sell_refund
	zclib.Money.Give(ply, money)
	zclib.Notify(ply, "+" .. zclib.Money.Display(money), 0)
	zclib.NetEvent.Create("zbf_bot_buy", { bot:LocalToWorld(Vector(5, 0, 0)) })
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	SafeRemoveEntity(bot)
end)

util.AddNetworkString("zbf_Controller_Repair")
net.Receive("zbf_Controller_Repair", function(len, ply)
	zclib.Debug_Net("zbf_Controller_Repair", len)
	if zclib.Player.Timeout(nil, ply) then return end

	local bot = net.ReadEntity()
	if not IsValid(bot) then return end
	if not IsValid(ply) then return end

	if zbf.config.Controller.disable_repair then return end

	if zclib.util.InDistance(bot:GetPos(),ply:GetPos(), 500) == false then return end

	// Get the repair cost
	local price = zbf.config.WearSystem.repair_cost * zbf.Bot.GetRepairCost(bot:GetBotID())

	// Check if the player has enough money
	if not zclib.Money.Has(ply, price) then
		zclib.Notify(ply, zbf.language[ "Not enough money!" ], 1)

		return
	end
	if bot:Health() >= bot:GetMaxHealth() then return end

	zclib.Money.Take(ply, price)
	zclib.Notify(ply,"+"..zbf.config.WearSystem.repair_health.." " .. zbf.language[ "Repair" ] .. " / -" .. zclib.Money.Display(price), 3)
	bot:SetHealth(bot:Health() + zbf.config.WearSystem.repair_health)
	zclib.NetEvent.Create("zbf_bot_repair", {bot})
end)
