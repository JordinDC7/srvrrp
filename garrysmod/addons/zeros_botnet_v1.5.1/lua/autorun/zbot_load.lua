/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

local DebugPrint = false

local function NicePrint(txt)
    if DebugPrint == false then return end

    if SERVER then
        MsgC(Color(84, 150, 197), txt .. "\n")
    else
        MsgC(Color(193, 193, 98), txt .. "\n")
    end
end

local function PreLoadFile(path)
	if CLIENT then
		include(path)
	else
		AddCSLuaFile(path)
		include(path)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

local function LoadFiles(path)
	local files, _ = file.Find(path .. "/*", "LUA")

	for _, v in ipairs(files) do
		if string.sub(v, 1, 3) == "sh_" then
			if CLIENT then
				include(path .. "/" .. v)
			else
				AddCSLuaFile(path .. "/" .. v)
				include(path .. "/" .. v)
			end
			NicePrint("// Loaded " .. string.sub(v,1,38) .. string.rep(" ", 38 - v:len()) .. " //")
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	for _, v in ipairs(files) do
		if string.sub(v, 1, 3) == "cl_" then
			if CLIENT then
				include(path .. "/" .. v)
				NicePrint("// Loaded " .. string.sub(v,1,38) .. string.rep(" ", 38 - v:len()) .. " //")
			else
				AddCSLuaFile(path .. "/" .. v)
			end
		elseif string.sub(v, 1, 3) == "sv_" then
			include(path .. "/" .. v)
			NicePrint("// Loaded " .. string.sub(v,1,38) .. string.rep(" ", 38 - v:len()) .. " //")
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

local function Initialize()
	NicePrint(" ")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("//////////////// Zero´s BotNet ///////////////////")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("//                                               //")
	PreLoadFile("sh_zbf_main_config.lua")

	// Load languages
	LoadFiles("zbot/languages")

	PreLoadFile("zbot/util/sh_materials.lua")
	PreLoadFile("zbot/bot/sh_bot_error.lua")
	LoadFiles("zbot/jobs")
	LoadFiles("zbot/generic")

	PreLoadFile("sh_zbf_job_config_illegal.lua")
	PreLoadFile("sh_zbf_job_config_botnet.lua")
	PreLoadFile("sh_zbf_job_config_neuro.lua")
	PreLoadFile("sh_zbf_job_config_legal.lua")

	PreLoadFile("sh_zbf_bot_config.lua")
	LoadFiles("zbot/util")
	LoadFiles("zbot/util/player")

	LoadFiles("zbot/rack")
	LoadFiles("zbot/bot")
	LoadFiles("zbot/controller")
	LoadFiles("zbot/vault")
	LoadFiles("zbot/usb")
	LoadFiles("zbot/wallet")
	LoadFiles("zbot/atm")
	LoadFiles("zbot/sign")

	PreLoadFile("sh_zbf_hooks.lua")

	NicePrint("//                                               //")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("///////////////////////////////////////////////////")

	if DebugPrint == false then
		if SERVER then
			MsgC(Color(84, 150, 197), "Zeros BotNet - Loaded\n")
		else
			MsgC(Color(193, 193, 98), "Zeros BotNet - Loaded\n")
		end
	end
end

PreLoadFile("zbot/util/cl_settings.lua")


timer.Simple(0,function()

	// If zeros libary is not installed on the server then lets tell them
	if zclib == nil then
		local function Warning(ply, msg)
			if DarkRP and DarkRP.notify then
				DarkRP.notify(ply, 1, 8, msg)
			else
				ply:ChatPrint(msg)
			end
		end

		MsgC(Color(255, 0, 0), "[Zero´s BotNet] > Zeros Lua Libary not found!")
		MsgC(Color(255, 0, 0), "https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111")

		if CLIENT then
			surface.PlaySound( "common/warning.wav" )
		end

		if SERVER then
			for k,v in ipairs(player.GetAll()) do
				if IsValid(v) then
					Warning(v, "[Zero´s BotNet] > Zeros Lua Libary not found!")
					Warning(v, "https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111")
				end
			end
		end
		return
	end

	Initialize()
end)
