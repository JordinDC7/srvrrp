/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Bot = zbf.Bot or {}
zbf.Bot.ErrorTypes = {}
local function AddErrorType(data) return table.insert(zbf.Bot.ErrorTypes,data) end

/*
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	While a Bot has a error it cant be used and after the time runs out something might happen

*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

ZBF_ERRORTYPE_REBOOT = AddErrorType({
	// Name of the error
	name = zbf.language["Reboot"],

	// Can the player fix the error by pressing E on the bot
	fixable = false,

	// The color of the error
	color = zclib.colors["blue02"],

	// The sound of the error to make him easy to identify
	sound = "zbf_reboot",

	OnDraw = function(Bot,w,h,x,y)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

		local rot = CurTime() * -700
        rot = zclib.util.SnapValue(36, rot)

		surface.SetDrawColor(zclib.colors["black_a100"])
		surface.SetMaterial(zclib.Materials.Get("icon_loading"))
		surface.DrawTexturedRectRotated(0, -40, 100, 100,rot)
	end,

	// What should happen when the error time runs out
	OnFinished = function(Bot,val) end
})

ZBF_ERRORTYPE_CRASH = AddErrorType({
	name = zbf.language["Crash"],
	fixable = true,
	color = zclib.colors["red01"],
	sound = "zbf_crash",
	OnDraw = function(Bot,w,h,x,y)
		surface.SetDrawColor(zclib.colors["black_a100"])
		surface.SetMaterial(zclib.Materials.Get("close"))
		surface.DrawTexturedRectRotated(0, -40, 100, 100,0)
	end,
	OnFinished = function(Bot,val)
		// Damage the bot by the given value
		zbf.Bot.Damage(Bot,val)
	end
})

/*
	This type of error doesent really impact the functionality of the BOT but rather who its assigned too. It gets called when the bot is being highjacked
*/
ZBF_ERRORTYPE_HIGHJACK = AddErrorType({
	name = zbf.language["Hacked"],
	fixable = false,
	color = zbf.colors["violett01"],
	sound = "zbf_reboot",
	OnDraw = function(Bot,w,h,x,y)

		local rot = CurTime() * -700
        rot = zclib.util.SnapValue(36, rot)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

		surface.SetDrawColor(zclib.colors["black_a100"])
		surface.SetMaterial(zclib.Materials.Get("icon_loading"))
		surface.DrawTexturedRectRotated(0, -40, 100, 100,rot)
	end,
	OnFinished = function(Bot,val)
		// Disconnect the bot from any network
		zbf.Bot.SetController(Bot, NULL)
	end
})

function zbf.Bot.GetErrorData(id)
	return zbf.Bot.ErrorTypes[id]
end

function zbf.Bot.GetErrorColor(id)
	local dat = zbf.Bot.GetErrorData(id)
	if dat and dat.color then
		return dat.color
	else
		return color_white
	end
end
