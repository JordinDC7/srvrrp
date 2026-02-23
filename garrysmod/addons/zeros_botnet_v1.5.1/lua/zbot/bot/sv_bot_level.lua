/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Bot = zbf.Bot or {}

/*

    Bots will increase their level overtime, the longer they work and stay alive the higher their level will be
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

*/

concommand.Add("zbf.Bot.AddLevel", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()
		if tr and IsValid(tr.Entity) and tr.Entity:GetClass() == "zbf_bot" then
			zbf.Bot.IncreaseLevel(tr.Entity)
		end
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

/*
	This will be called every second the bot is doing work
*/
function zbf.Bot.AddXP(Bot)
	if not zbf.config.LevelSystem.enabled then return end
	zclib.Debug("zbf.Bot.AddXP")
	Bot.XP = (Bot.XP or 0) + 1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	if Bot.XP >= (zbf.config.LevelSystem.time_max_level / zbf.config.LevelSystem.max_level) then
		Bot.XP = 0
		zbf.Bot.IncreaseLevel(Bot)
	end
end

/*
	Increase the level of the bot
*/
function zbf.Bot.IncreaseLevel(Bot)
	zclib.Debug("zbf.Bot.IncreaseLevel")
	local level = Bot:GetLevel()
	if level >= zbf.config.LevelSystem.max_level then return end
	zbf.Bot.SetLevel(Bot,level + 1)
end

/*
	Sets the level of the bot
*/
function zbf.Bot.SetLevel(Bot,lvl)
	zclib.Debug("zbf.Bot.SetLevel")
	Bot:SetLevel(lvl)
end
