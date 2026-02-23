/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Bot = zbf.Bot or {}

/*

    Here we load the Bots config from file if it exist

*/
zbf.config.Bots = zbf.config.Bots or {}
zbf.config.Bots_ListID = zbf.config.Bots_ListID or {}
file.CreateDir( "zbf" )
timer.Simple(0, function()
	zclib.Data.Setup("zbf_bot_config", "[Zero´s BotNet]", "zbf/bot_config.txt", function() return zbf.config.Bots end, function(data)
		// OnLoaded
		zbf.config.Bots = table.Copy(data)
		zbf.Bot.CalculateTickLimits()
		zbf.Bot.PrecacheModels()
	end, function() end, function(data)
		// OnSend
		// OnReceived
		zbf.config.Bots = table.Copy(data)
		zbf.Bot.CalculateTickLimits()
		zbf.Bot.PrecacheModels()

		if CLIENT then
			// Download the used imgur images and cache them in materials
			for k, v in pairs(zbf.config.Bots) do
				if v == nil then continue end
				if v.material == nil then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

				zclib.Imgur.GetMaterial(tostring(v.material.imgur_url), function(result)

					zclib.Imgur.GetMaterial(tostring(v.material.logo_url), function(result)

						zclib.Imgur.GetMaterial(tostring(v.material.em_url), function(result)

							zbf.Bot.GetMaterial("zbf_bot_paint_mat_" .. v.uniqueid, v)
						end)
					end)
				end)
			end
		end
	end, function(list)
		//OnIDListRebuild
		zbf.config.Bots_ListID = table.Copy(list)
	end)
end)

function zbf.Bot.GetListID(UniqueID)
    return zbf.config.Bots_ListID[UniqueID]
end

function zbf.Bot.GetData(UniqueID)
    if UniqueID == nil then return end

    // If its a list id then lets return its data
    if zbf.config.Bots[UniqueID] then return zbf.config.Bots[UniqueID] end

    // If its a uniqueid then lets get its list id and return the data
    local id = zbf.Bot.GetListID(UniqueID)
    if UniqueID and id and zbf.config.Bots[id] then
        return zbf.config.Bots[id]
    end
end

function zbf.Bot.GetID(ListID)
    return zbf.Bot.GetData(ListID).uniqueid
end

/*
	Returns true if the bot data has been loaded
*/
function zbf.Bot.IsLoaded(Bot)
	local dat = zbf.Bot.GetData(Bot:GetBotID())
	return dat ~= nil
end

/*
	Takes in a set of style data and adds any value thats missing from it
*/
function zbf.Bot.VerifyData(Data)
	local BotData = table.Copy(Data)

	if BotData.uniqueid then BotData.uniqueid = tostring(BotData.uniqueid) end

	BotData.name = BotData.name or "Bot Name"

	BotData.mdl = BotData.mdl or "models/zerochain/props_clickfarm/zcf_bot_lvl01.mdl"
	BotData.health = BotData.health or 25
	BotData.price = BotData.price or 100

	BotData.tps = BotData.tps or 1
	BotData.attack = BotData.attack or 0
	BotData.defense = BotData.defense or 0
	BotData.neuro = BotData.neuro or 0

	// The repair cost multipliactor changes the cost of repairing this bot
	BotData.repaircost = BotData.repaircost or 1

	BotData.ranks = BotData.ranks or {}
	BotData.jobs = BotData.jobs or {}

	if BotData.material == nil then BotData.material = {} end

	BotData.material.id = BotData.material.id or 0

	BotData.material.diff = BotData.material.diff or "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff"
	BotData.material.nrm = BotData.material.nrm or "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm"

	BotData.material.color = BotData.material.color or color_white
	BotData.material.spec_color = BotData.material.spec_color or color_black
	BotData.material.reflection = BotData.material.reflection or 0
	BotData.material.fresnel = BotData.material.fresnel or 0


	BotData.material.imgur_color = BotData.material.imgur_color or color_white
	BotData.material.imgur_blendmode = BotData.material.imgur_blendmode or 0
	BotData.material.imgur_url = BotData.material.imgur_url or ""
	BotData.material.imgur_x = BotData.material.imgur_x or 0
	BotData.material.imgur_y = BotData.material.imgur_y or 0
	BotData.material.imgur_scale = BotData.material.imgur_scale or 1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	BotData.material.logo_color = BotData.material.logo_color or color_white
	BotData.material.logo_blendmode = BotData.material.logo_blendmode or 0
	BotData.material.logo_url = BotData.material.logo_url or ""
	BotData.material.logo_x = BotData.material.logo_x or 0.77
	BotData.material.logo_y = BotData.material.logo_y or 0.59
	BotData.material.logo_scale = BotData.material.logo_scale or 0.11
	BotData.material.logo_rotation = BotData.material.logo_rotation or 90

	BotData.material.em_strength = BotData.material.em_strength or 0
	BotData.material.em_color = BotData.material.em_color or color_black
	BotData.material.em_url = BotData.material.em_url or ""
	BotData.material.em_x = BotData.material.em_x or 0
	BotData.material.em_y = BotData.material.em_y or 0
	BotData.material.em_scale = BotData.material.em_scale or 1

	return BotData
end


/*
	Goes throug all the bot configs and gets the lowest / highest TicksPerSecond
*/
local tick_min
local tick_max
function zbf.Bot.CalculateTickLimits()
    for k,v in pairs(zbf.config.Bots) do
        if tick_min == nil then tick_min = v.tps end
        if v.tps < tick_min then tick_min = v.tps end

        if tick_max == nil then tick_max = v.tps end
        if v.tps > tick_max then tick_max = v.tps end
    end
end
zbf.Bot.CalculateTickLimits()

/*
	Precache the current bot models on both server and client
*/
function zbf.Bot.PrecacheModels()
    for k,v in pairs(zbf.config.Bots) do
        if v and v.mdl then util.PrecacheModel(v.mdl) end
    end
end
zbf.Bot.PrecacheModels()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c


/*
	Returns the name of the Bot
*/
function zbf.Bot.GetName(Bot)
    local dat = zbf.Bot.GetData(Bot:GetBotID())
    return dat.name
end

/*
	Returns either color or spec_color of the Bot
*/
function zbf.Bot.GetColor(Bot)
    local dat = zbf.Bot.GetData(Bot:GetBotID())
    return dat.material.color or dat.material.spec_color
end

/*
	Returns how many TicksPerSecond this Bot can produce
*/
function zbf.Bot.GetTicksPerSecond(Bot)
    local dat = zbf.Bot.GetData(Bot:GetBotID())
    return dat.tps * zbf.Bot.GetLevelPerformance(Bot)
end

/*
	Returns the speed of the bot from a value 0 - 1
*/
function zbf.Bot.GetSpeed(Bot)
    return math.Clamp((1 / tick_max) * zbf.Bot.GetTicksPerSecond(Bot),0,1)
end

/*
	Returns if the Bot has currently a Error
*/
function zbf.Bot.HasError(Bot)
    return Bot:GetErrorType() > 0
end

/*
	Returns if the Bot has currently a Error
*/
function zbf.Bot.IsHighjacked(Bot)
    return Bot:GetErrorType() == ZBF_ERRORTYPE_HIGHJACK
end

/*
	Returns if the Bot is connected to a Controller
*/
function zbf.Bot.IsConnected(Bot)
    local controller = Bot:GetController()
    if not IsValid(controller) then return false end
    return true
end

/*
	Returns if the Bot is in IDLE mode
*/
function zbf.Bot.IsIdle(Bot)
    local controller = Bot:GetController()
    if not IsValid(controller) then return false end
    local JobID = controller:GetJobID()
    if JobID >= 0 then return false end
    if zbf.config.Jobs[JobID] then return false end
    return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

/*
	Returns if the Bot if currently Computing
*/
function zbf.Bot.IsWorking(Bot)
	// The Highjacked error type is still a error so we need to make sure it doesent prevent the bot working normaly
    if not zbf.Bot.IsHighjacked(Bot) and zbf.Bot.HasError(Bot) then return false end

    local controller = Bot:GetController()
    if not IsValid(controller) then return false end
    local JobID = controller:GetJobID()
    if JobID <= 0 then return false end
    if zbf.config.Jobs[JobID] == nil then return false end
	if not zbf.Bot.IsCompatible(Bot, JobID) then return false end
    return true
end


/*
	Checks if the Bot is compatible with the select job id
*/
function zbf.Bot.IsNeuroBot(Bot)
	local dat = zbf.Bot.GetData(Bot:GetBotID())
	if not dat then return end
	return dat.neuro and dat.neuro > 0
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

/*
	Checks if the Bot is compatible with the select job id
*/
function zbf.Bot.IsCompatible(Bot, JobID)
	if zbf.Jobs.IsNeuroJob(JobID) and not zbf.Bot.IsNeuroBot(Bot) then return false end
	if not zbf.Jobs.IsNeuroJob(JobID) and zbf.Bot.IsNeuroBot(Bot) then return false end
	return true
end

/*
	Returns the color of the Bots State
*/
function zbf.Bot.GetStateColor(Bot, JobID)
	if zbf.Bot.HasError(Bot) then return zbf.Bot.GetErrorColor(Bot:GetErrorType()) end
	if not zbf.Bot.IsCompatible(Bot, JobID) then return zclib.colors["white_a5"] end
	return zbf.colors["green01"] // zclib.colors["green01"]
end

/*
	Returns the price
*/
function zbf.Bot.GetPrice(BotID)
	local dat = zbf.Bot.GetData(BotID)
	return dat.price or 100
end

/*
	Returns if the player can purchase this bot
*/
function zbf.Bot.CanBuy_JobRestriction(ply,BotID)
	local dat = zbf.Bot.GetData(BotID)
	if dat.jobs and not zclib.Player.JobCheck(ply, dat.jobs) then return false end

	local _,shouldhide = hook.Run("zbf_Bot_CanBuy",ply,BotID)
	if shouldhide == true then return false end

	return true
end

/*
	Returns if the player can purchase this bot
*/
function zbf.Bot.CanBuy(ply,BotID)
	local dat = zbf.Bot.GetData(BotID)

	local overwrite = hook.Run("zbf_Bot_CanBuy",ply,BotID)
	if overwrite ~= nil then return overwrite end

	if dat.ranks and not zclib.Player.RankCheck(ply,dat.ranks) then return false end
	if dat.jobs and not zclib.Player.JobCheck(ply, dat.jobs) then return false end

	return true
end

// Lets just verify all the current bot data to make sure its not missing anything
for k,v in pairs(zbf.config.Bots) do zbf.config.Bots[k] = zbf.Bot.VerifyData(v) end


/*
	Returns the repair cost multipliactor
*/
function zbf.Bot.GetRepairCost(BotID)
	local dat = zbf.Bot.GetData(BotID)
	if not dat then return 1 end
	return dat.repaircost or 1
end
