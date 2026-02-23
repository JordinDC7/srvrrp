/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*
	Can this controller be used currently?
*/
function zbf.Controller.IsDisabled(Controller,ply)
	local result = hook.Run("zbf_Controller_DisableInteraction",Controller,ply)
	if result == nil then return false end
	return result
end

/*
	Returns a list of all the bots near the controller which share the same owner
*/
function zbf.Controller.GetNearDevices(Controller)
    if not IsValid(Controller) then return {} end
    local devices = {}
    for bot,_ in pairs(zbf.Bot.List) do
        if IsValid(bot) and zclib.Player.SharedOwner(Controller,bot) and zclib.util.InDistance(Controller:GetPos(), bot:GetPos(), 500) then
            table.insert(devices,bot)
        end
    end
    return devices
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

/*
	Returns all the bots which are currently connected to the provided controller
*/
function zbf.Controller.GetConnectedDevices(Controller)
	if not IsValid(Controller) then return {} end
	local devices = {}

	for bot, _ in pairs(zbf.Bot.List) do
		if IsValid(bot) and bot:GetController() == Controller then
			table.insert(devices, bot)
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	return devices
end

/*
	Returns how many ticks per second all working bots in the network produce
*/
function zbf.Controller.GetTicksPerSecond(Controller)
	local count = 0

	for k, v in pairs(zbf.Controller.GetConnectedDevices(Controller)) do
		if IsValid(v) and zbf.Bot.IsLoaded(v) and zbf.Bot.IsWorking(v) then
			count = count + zbf.Bot.GetTicksPerSecond(v)
		end
	end

	return math.Round(count, 1)
end

/*
	Returns the first random bot that is still working
*/
function zbf.Controller.GetRandomWorkingBot(Controller)
	local validBots = {}

	for k, v in pairs(zbf.Controller.GetConnectedDevices(Controller)) do
		if IsValid(v) and zbf.Bot.IsWorking(v) then
			table.insert(validBots, v)
		end
	end

	validBots = zclib.table.randomize(validBots)

	return validBots[math.random(#validBots)]
end

/*
	Returns the first random bot that is connected and has no error
*/
function zbf.Controller.GetRandomBot(Controller)
	local validBots = {}

	for k, v in pairs(zbf.Controller.GetConnectedDevices(Controller)) do
		if IsValid(v) and (zbf.Bot.IsHighjacked(v) or not zbf.Bot.HasError(v)) then
			table.insert(validBots, v)
		end
	end

	validBots = zclib.table.randomize(validBots)

	return validBots[math.random(#validBots)]
end

/*
	Returns how much money can be hold in the BotNets Wallet
*/
function zbf.Controller.GetWalletSize(Controller, ply)
	if not IsValid(ply) then return 5000 end
	local size = zbf.config.Controller.wallet_size[zclib.Player.GetRank(ply)]
	if size == nil then size = zbf.config.Controller.wallet_size["default"] end
	if size == nil then size = 5000 end

	local result = hook.Run("zbf_Controller_GetWalletSize",Controller, ply,size)
	if result ~= nil then return result end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	return size
end

/*
	Returns how much money can be hold in the BotNets Wallet
*/
function zbf.Controller.GetBotLimit(Controller, ply)
	if not IsValid(ply) then return 20 end
	local limit = zbf.config.Controller.BotLimit[zclib.Player.GetRank(ply)]
	if limit == nil then limit = zbf.config.Controller.BotLimit["default"] end
	if limit == nil then limit = 20 end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	local result = hook.Run("zbf_Controller_GetBotLimit",Controller, ply,limit)
	if result ~= nil then return result end

	return limit
end

/*
	Returns how many bots are owned by the player
*/
function zbf.Controller.GetBotCount(ply)
	local count = 0

	for bot, _ in pairs(zbf.Bot.List) do
		if IsValid(bot) and zclib.Player.IsOwner(ply, bot) then
			count = count + 1
		end
	end

	return count
end

/*
	Catches the specified value from all connect Bot Configs
*/
function zbf.Controller.GetStatValue(Controller, key)
	local val = 0

	for k, v in pairs(zbf.Controller.GetConnectedDevices(Controller)) do
		if not IsValid(v) then continue end

		if not zbf.Bot.IsHighjacked(v) and zbf.Bot.HasError(v) then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

		local dat = zbf.Bot.GetData(v:GetBotID())
		if dat == nil then continue end
		if dat[key] == nil then continue end
		local stat = dat[key] * zbf.Bot.GetLevelPerformance(v)
		val = val + stat
	end

	return val
end
