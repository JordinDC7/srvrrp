XeninUI = XeninUI || {}
XeninUI.ORM = XeninUI.ORM || {}
XeninUI.Players = XeninUI.Players || {}

function XeninUI:CreateFont(name, size, weight, mergeTbl)
	local tbl = {
		font = "Montserrat Medium",

		size = size + 2,
		weight = weight or 500,
		extended = true
	}

	if mergeTbl then
		table.Merge(tbl, mergeTbl)
	end

	surface.CreateFont(name, tbl)
end

function XeninUI:IncludeClient(path)
	if CLIENT then
		include("xeninui/" .. path .. ".lua")
	end

	if SERVER then
		AddCSLuaFile("xeninui/" .. path .. ".lua")
	end
end

function XeninUI:IncludeServer(path)
	if SERVER then
		include("xeninui/" .. path .. ".lua")
	end
end

function XeninUI:IncludeShared(path)
	XeninUI:IncludeServer(path)
	XeninUI:IncludeClient(path)
end

XeninUI:IncludeShared("settings/settings")
hook.Run("XeninUI.PostLoadSettings")
XeninUI:IncludeShared("libs/loader")

XeninUI.Loader():setName("Xenin Framework"):setAcronym("Xenin"):setDirectory("xeninui"):setColor(XeninUI.Theme.Red):load("libs", XENINUI_CLIENT, false, {
	ignoreFiles = {
	loader = true
	},
	overwriteRealm = {
		essentials_sh = XENINUI_SHARED,
		v0n_sh = XENINUI_SHARED,
		promises = XENINUI_SHARED,
		permissions = XENINUI_SHARED
	}
}):load("libs/network", XENINUI_SHARED):loadFile("server/orm/table_constraint", XENINUI_SERVER):load("server", XENINUI_SERVER, true):load("libs/languages", XENINUI_SHARED):load("libs/languages/network", {
	client = XENINUI_CLIENT,
	server = XENINUI_SERVER
}):load("libs/scripts", XENINUI_SHARED):load("libs/scripts/network", {
	client = XENINUI_CLIENT,
	server = XENINUI_SERVER
}):load("libs/configurator", XENINUI_SHARED):load("libs/configurator/classes", XENINUI_SHARED, false, {
overwriteRealm = {
database = XENINUI_SERVER
}
}):load("libs/configurator/network", {
	client = XENINUI_CLIENT,
	server = XENINUI_SERVER
}):load("libs/configurator/ui", XENINUI_CLIENT, true):load("libs/config", XENINUI_SHARED):load("libs/config/network", {
	client = XENINUI_CLIENT,
	server = XENINUI_SERVER
}):load("libs/players", XENINUI_SHARED, false, {
overwriteRealm = {
database = XENINUI_SERVER
}
}):load("libs/players/ui", XENINUI_CLIENT, true):load("libs/players/network", {
	shared = XENINUI_SHARED,
	client = XENINUI_CLIENT,
	server = XENINUI_SERVER
}):load("elements", XENINUI_CLIENT):load("core/ui", XENINUI_CLIENT):load("libs/units", XENINUI_SHARED, true):done()

XeninUI.Version = "2.1.0"

hook.Run("XeninUI.PreLoadAddons")
hook.Run("XeninUI.Loaded")
hook.Run("XeninUI.PostLoadAddons")
