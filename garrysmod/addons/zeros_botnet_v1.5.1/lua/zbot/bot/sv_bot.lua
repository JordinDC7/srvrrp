/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Bot = zbf.Bot or {}
zbf.Bot.List = zbf.Bot.List or {}

/*

    The Bot device will be used to generate online interest

*/

concommand.Add("zbf_bot_factory_reset", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		zclib.Data.Remove(ply,"zbf_bot_config")
		include("sh_zbf_bot_config.lua")
		zclib.Data.UpdateConfig("zbf_bot_config")

		zclib.Notify(ply, "Bot config reset, restart server to have full effect.", 0)

		// Tell all clients to remove their bot thumbnails
		zclib.Snapshoter.Delete("zbf")
	end
end)

function zbf.Bot.Initialize(Bot)
	zclib.Debug("zbf.Bot.Initialize")
	zbf.Bot.Update(Bot, Bot:GetBotID())
	Bot:PhysicsInit(SOLID_VPHYSICS)
	Bot:SetSolid(SOLID_VPHYSICS)
	Bot:SetMoveType(MOVETYPE_VPHYSICS)
	Bot:SetUseType(SIMPLE_USE)
	Bot:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phy = Bot:GetPhysicsObject()
	if IsValid(phy) then
		phy:Wake()
		phy:EnableMotion(true)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

	Bot:DrawShadow(false)

	zclib.EntityTracker.Add(Bot)

	Bot:PrecacheGibs()

	// Give the bot a random starting value
	Bot.XP = math.random(30)

	// Give the bot a random starting value
	Bot.UseCount = math.random(30)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	if zbf.Bot.List[Bot] == nil then
		zbf.Bot.List[Bot] = true
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

function zbf.Bot.Update(Bot, BotID)
	zbf.Bot.UpdateVisuals(Bot, BotID)
	Bot:SetBotID(BotID)
	local dat = zbf.Bot.GetData(BotID)
	Bot:SetHealth(dat.health or 25)
	Bot:SetMaxHealth(dat.health or 25)

	// Reset the level
	Bot:SetLevel(1)
end

function zbf.Bot.UpdateVisuals(Bot, BotID)
	local dat = zbf.Bot.GetData(BotID)
	Bot:SetModel(dat.mdl)
end

function zbf.Bot.OnRemove(Bot)
	zclib.Timer.Remove("zbf_bot_error_" .. Bot:EntIndex())
	zbf.Bot.List[Bot] = nil
end

function zbf.Bot.OnUse(Bot, ply)
	zclib.Debug("zbf.Bot.OnUse")
	zbf.Bot.Fix(Bot)
end

function zbf.Bot.MassError(Bots, id, time, val)
	local delay = 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	for k, v in pairs(Bots) do
		if not IsValid(v) then continue end

		timer.Simple(delay, function()
			if IsValid(v) then
				zbf.Bot.Error(v, id, time, val)
			end
		end)
		delay = delay + 0.25
	end
end

function zbf.Bot.Error(Bot, id, time, val)
	local ErrorData = zbf.Bot.GetErrorData(id)

	Bot:EmitSound(ErrorData.sound)

	Bot:SetErrorType(id)
	Bot:SetErrorStart(math.Round(CurTime()))
	Bot:SetErrorTime(math.Round(time))
	local timerid = "zbf_bot_error_" .. Bot:EntIndex()
	zclib.Timer.Remove(timerid)

	zclib.Timer.Create(timerid, time, 1, function()
		if IsValid(Bot) then
			Bot:SetErrorType(-1)
			Bot:SetErrorStart(-1)
			Bot:SetErrorTime(-1)
			ErrorData.OnFinished(Bot, val)
		end
	end)
end

function zbf.Bot.Fix(Bot)
	// Does the bot even have a error
	if not zbf.Bot.HasError(Bot) then return end
	// Do we still have time to fix this error
	if CurTime() >= (Bot:GetErrorStart() + Bot:GetErrorTime()) then return end
	local ErrorData = zbf.Bot.GetErrorData(Bot:GetErrorType())
	// Can we even fix this error
	if not ErrorData.fixable then return end
	Bot:SetErrorType(-1)
	Bot:SetErrorStart(-1)
	Bot:SetErrorTime(-1)
	zclib.Timer.Remove("zbf_bot_error_" .. Bot:EntIndex())
	zclib.NetEvent.Create("zbf_bot_fix", {Bot})
end

function zbf.Bot.Destroy(Bot)
	if Bot.Destroyed then return end
	Bot.Destroyed = true
	zclib.Entity.SafeRemove(Bot)
	// Create explosion effect with metal debris
	zclib.NetEvent.Create("zbf_bot_explode", {Bot})
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function zbf.Bot.Damage(Bot, dmg)
	Bot:SetHealth(math.Clamp(Bot:Health() - (dmg or 5), 0, Bot:GetMaxHealth()))

	if Bot:Health() <= 0 then
		zbf.Bot.Destroy(Bot)
	else
		zclib.NetEvent.Create("zbf_bot_damage", {Bot})
	end
end

function zbf.Bot.OnTakeDamage(Bot, dmginfo)
	zclib.Debug("zbf.Bot.OnTakeDamage")
	if not IsValid(Bot) then return end

	if (not Bot.m_bApplyingDamage) then
		Bot.m_bApplyingDamage = true
		Bot:TakeDamageInfo(dmginfo)
		zbf.Bot.Damage(Bot, dmginfo:GetDamage())
		Bot.m_bApplyingDamage = false
	end
end

function zbf.Bot.SetController(Bot, controller)
	Bot:SetController(controller)
end
