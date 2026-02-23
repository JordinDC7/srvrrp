-- This is serverside "global" settings.



-- Quick guide on type ints:
-- 0 - String  1 - Bool  2 - Table  3 - Int
-- String, Bool and Int aren't turned into JSON. Table is. (fucking obviously)

-- Why lua not have switch statements ;-;
-- (and yes i know i probably could've just done some fancy shit with table indexing but that seems kinda unnessasary for something that probably wont even get called that much anyway)
function UltimatePartySystem.Settings.StorableToLua(val, typeint)
    if(typeint == 0) then
        return val
    end
    if(typeint == 1) then
        return tobool(val)
    end
    if(typeint == 2) then
        return util.JSONToTable(val)
    end
    if(typeint == 3) then
        return tonumber(val)
    end
end
function UltimatePartySystem.Settings.LuaToStorable(val)
    if(type(val) == "string") then
        return val, 0
    end
    if(type(val) == "number") then
        return val, 3
    end
    if(type(val) == "boolean") then
        return val, 1
    end
    if(type(val) == "table") then
        return util.TableToJSON(val), 2
    end
end


UltimatePartySystem.Settings.Defaults = UltimatePartySystem.Settings.Defaults or {}
-- General
UltimatePartySystem.Settings.Defaults['prefix'] = "UPS >>" -- Prefix of all messages.
UltimatePartySystem.Settings.Defaults['prefixColor'] = Color(37, 199, 116) -- The prefix color.
UltimatePartySystem.Settings.Defaults['messageColor'] = Color(255, 255, 255) -- The message color.
UltimatePartySystem.Settings.Defaults['themeColor'] = Color(9, 150, 89) -- The theme color.
UltimatePartySystem.Settings.Defaults['moneyFormat'] = "$%s" -- How the addon formats money. %s is the amount in commas.

UltimatePartySystem.Settings.Defaults['chatCommand'] = "!party" -- The chat command for opening the party ui.
UltimatePartySystem.Settings.Defaults['hideChatCommand'] = true -- If the chat command should not be sent to chat when used.
UltimatePartySystem.Settings.Defaults['uiMessage'] = true -- If there should be a chat message for opening the ui.

UltimatePartySystem.Settings.Defaults['maxNameLength'] = 30 -- The maximum length a Party Name can have.
UltimatePartySystem.Settings.Defaults['allowPrivateParties'] = true -- Whether to allow private parties.
UltimatePartySystem.Settings.Defaults['maxSlots'] = 15 -- The maximum amount of slots in a party.
UltimatePartySystem.Settings.Defaults['defaultSlots'] = 5 -- The default amount of slots in a party.
UltimatePartySystem.Settings.Defaults['partyCreationCost'] = 500 -- How much should creating a party cost a player. Set this to 0 for no cost.
UltimatePartySystem.Settings.Defaults['inviteTimeOut'] = 30 -- Time in seconds for invites being timed out. 0 for no timeout.

UltimatePartySystem.Settings.Defaults['radioEnable'] = true -- Enable the party radio.
UltimatePartySystem.Settings.Defaults['markerEnable'] = true -- Enable markers.
UltimatePartySystem.Settings.Defaults['enableFriendlyFire'] = true -- If friendly fire should be enabled.
UltimatePartySystem.Settings.Defaults['enablePartyChat'] = true -- If party chat should be enabled.
UltimatePartySystem.Settings.Defaults['partyChatCommand'] = "!pc" -- The command for Party Chat.

UltimatePartySystem.Settings.Values = UltimatePartySystem.Settings.Values or {}

function UltimatePartySystem.Settings.GetValue(key)
    if(UltimatePartySystem.Settings.Defaults[key] == nil) then return end

    if(UltimatePartySystem.Settings.Values[key] == nil) then
        return UltimatePartySystem.Settings.Defaults[key]
    end
    return UltimatePartySystem.Settings.Values[key]
end

if(SERVER) then
    util.AddNetworkString("ultimatepartysystem.settings.clientready")
    util.AddNetworkString("ultimatepartysystem.settings.clientpayload")
    util.AddNetworkString("ultimatepartysystem.settings.saveconfig")
    util.AddNetworkString("ultimatepartysystem.settings.purgeconfig")

    function UltimatePartySystem.Settings.LoadSettings()
        if(!sql.TableExists("ultimatepartysystem_settings")) then
            local create = sql.Query("CREATE TABLE `ultimatepartysystem_settings`(`key` VARCHAR(255), `type` INT(1), `value` VARCHAR(255));")

            if(create == false) then
                UltimatePartySystem.Core.Print("Something went wrong creating the settings table. This will most likely cause errors. Try restarting your server, if that doesn't work then create a ticket on gmodstore.")
                UltimatePartySystem.Core.Print("Not continuing to fetch settings. Using default values.")

                return
            end
        end

        local q = sql.Query("SELECT * FROM `ultimatepartysystem_settings`;")
        if(q == nil) then return end -- No need to do anything else since its all just default values.
        if(q == false) then
            UltimatePartySystem.Core.Print("Something went wrong fetching from the settings table. This will most likely cause errors. Try restarting your server, if that doesn't work then create a ticket on gmodstore.")
            UltimatePartySystem.Core.Print("Not continuing to fetch settings. Using default values.")

            return
        end

        for k,v in pairs(q) do
            if(!UltimatePartySystem.Settings.Defaults[v.key]) then continue end

            local value = UltimatePartySystem.Settings.StorableToLua(v.value, tonumber(v.type))
            if(UltimatePartySystem.Settings.Defaults[v.key] == value) then
                sql.Query("DELETE FROM `ultimatepartysystem_settings` WHERE `key` = " .. sql.SQLStr(k) .. ";")
                continue
            end

            UltimatePartySystem.Settings.Values[v.key] = value
        end

        UltimatePartySystem.Core.Print("Successfully loaded settings.")
    end

    function UltimatePartySystem.Settings.SetValue(key, val)
        if(UltimatePartySystem.Settings.Values[key] == val) then return end

        UltimatePartySystem.Settings.Values[key] = val

        local storable,type = UltimatePartySystem.Settings.LuaToStorable(val)
        local q1 = sql.Query("SELECT key FROM `ultimatepartysystem_settings` WHERE key = " .. sql.SQLStr(key) .. ";") -- purely to check if it's in the table

        if(q1 == nil) then
            local q2 = sql.Query("INSERT INTO `ultimatepartysystem_settings`(`key`, `type`, `value`) VALUES(" .. sql.SQLStr(key) .. ", " .. type .. ", " .. sql.SQLStr(storable) .. ");")
        else
            sql.Query("UPDATE `ultimatepartysystem_settings` SET `value` = " .. sql.SQLStr(storable) .. ", `type` = " .. type .. " WHERE key = " .. sql.SQLStr(key) .. ";")
        end

        for k,v in pairs(player.GetAll()) do
            UltimatePartySystem.Settings.UpdateClientCache(v)
        end
    end

    function UltimatePartySystem.Settings.UpdateClientCache(ply)
        net.Start("ultimatepartysystem.settings.clientpayload")
        net.WriteTable(UltimatePartySystem.Settings.Values)
        net.Send(ply)
    end

    net.Receive("ultimatepartysystem.settings.clientready", function(len, ply)
        UltimatePartySystem.Settings.UpdateClientCache(ply)
    end)

    -- Admin updating the in-game config.
    net.Receive("ultimatepartysystem.settings.saveconfig", function(len, ply)
        if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

        if(!UltimatePartySystem.Config.ConfigGroups[ply:GetUserGroup()] && !UltimatePartySystem.Config.ConfigGroups[ply:SteamID()]) then
            UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("noPermission"))
            return
        end

        local updated = net.ReadTable()
        for k,v in pairs(updated) do
            UltimatePartySystem.Settings.SetValue(k, v)
        end
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("configUpdate"))
    end)
    net.Receive("ultimatepartysystem.settings.purgeconfig", function(len, ply)
        if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

        if(!UltimatePartySystem.Config.ConfigGroups[ply:GetUserGroup()] && !UltimatePartySystem.Config.ConfigGroups[ply:SteamID()]) then
            UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("noPermission"))
            return
        end

        for k,v in pairs(UltimatePartySystem.Settings.Defaults) do
            UltimatePartySystem.Settings.SetValue(k, v)
        end

        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("configReset"))
    end)
end

if(CLIENT) then
    -- https://wiki.facepunch.com/gmod/GM:PlayerInitialSpawn https://upload.livaco.dev/u/Dnm2L8oM1f.png
    -- Net messages are unreliable on PlayerInitialSpawn so I do this instead. If that page is inaccurate let me know and I'll swap this to the "correct" way of doing it.
    hook.Add("InitPostEntity", "ultimatepartysystem.settings.clientready", function()
        net.Start("ultimatepartysystem.settings.clientready")
        net.SendToServer()
    end)

    net.Receive("ultimatepartysystem.settings.clientpayload", function()
        UltimatePartySystem.Settings.Values = net.ReadTable()
    end)

    -- Big Ass Config Table
    -- While config values are stored in another table, this table is purely for the UI stuff. Only for visuals, does nothing functional. I do this so serverside's table doesn't get cluttered with info it doesn't need.
    hook.Add("ultimatepartysystem.core.loaded", "ultimatepartysystem.settings.loaddisplay", function()
        UltimatePartySystem.ConfigDisplay = {}
        UltimatePartySystem.ConfigDisplay["General"] = {
            [1] = {
                key = "prefix",
                name = UltimatePartySystem.Core.GetLanguage("configPrefixName"),
                description = UltimatePartySystem.Core.GetLanguage("configPrefixDescription"),
                type = "string"
            },
            [2] = {
                key = "prefixColor",
                name = UltimatePartySystem.Core.GetLanguage("configPrefixColorName"),
                description = UltimatePartySystem.Core.GetLanguage("configPrefixColorDescription"),
                type = "color"
            },
            [3] = {
                key = "messageColor",
                name = UltimatePartySystem.Core.GetLanguage("configMessageColorName"),
                description = UltimatePartySystem.Core.GetLanguage("configMessageColorDescription"),
                type = "color"
            },
            [4] = {
                key = "themeColor",
                name = UltimatePartySystem.Core.GetLanguage("configThemeColorName"),
                description = UltimatePartySystem.Core.GetLanguage("configThemeColorDescription"),
                type = "color"
            },
            [5] = {
                key = "moneyFormat",
                name = UltimatePartySystem.Core.GetLanguage("configMoneyFormatName"),
                description = UltimatePartySystem.Core.GetLanguageUnformatted("configMoneyFormatDescription", false),
                type = "string"
            },
        }
        UltimatePartySystem.ConfigDisplay["User Interface"] = {
            [1] = {
                key = "chatCommand",
                name = UltimatePartySystem.Core.GetLanguage("configChatCommandName"),
                description = UltimatePartySystem.Core.GetLanguage("configChatCommandDescription"),
                type = "string"
            },
            [2] = {
                key = "hideChatCommand",
                name = UltimatePartySystem.Core.GetLanguage("configHideCommandName"),
                description = UltimatePartySystem.Core.GetLanguage("configHideCommandDescription"),
                type = "boolean"
            },
            [3] = {
                key = "uiMessage",
                name = UltimatePartySystem.Core.GetLanguage("configUIMessageName"),
                description = UltimatePartySystem.Core.GetLanguage("configHideCommandDescription"),
                type = "boolean"
            },
        }
        UltimatePartySystem.ConfigDisplay["Parties"] = {
            [1] = {
                key = "maxNameLength",
                name = UltimatePartySystem.Core.GetLanguage("configMaxNameLengthName"),
                description = UltimatePartySystem.Core.GetLanguage("configMaxNameLengthDescription"),
                type = "number"
            },
            [2] = {
                key = "allowPrivateParties",
                name = UltimatePartySystem.Core.GetLanguage("configAllowPrivatePartiesName"),
                description = UltimatePartySystem.Core.GetLanguage("configAllowPrivatePartiesDescription"),
                type = "boolean"
            },
            [3] = {
                key = "maxSlots",
                name = UltimatePartySystem.Core.GetLanguage("configMaxSlotsName"),
                description = UltimatePartySystem.Core.GetLanguage("configMaxSlotsDescription"),
                type = "number"
            },
            [4] = {
                key = "defaultSlots",
                name = UltimatePartySystem.Core.GetLanguage("configDefaultSlotsName"),
                description = UltimatePartySystem.Core.GetLanguage("configDefaultSlotsDescription"),
                type = "number"
            },
            [5] = {
                key = "partyCreationCost",
                name = UltimatePartySystem.Core.GetLanguage("configPartyCreationCostName"),
                description = UltimatePartySystem.Core.GetLanguage("configPartyCreationCostDescription"),
                type = "number"
            },
        }
        UltimatePartySystem.ConfigDisplay["Misc"] = {
            [1] = {
                key = "radioEnable",
                name = UltimatePartySystem.Core.GetLanguage("configRadioEnabledName"),
                description = UltimatePartySystem.Core.GetLanguage("configRadioEnabledDescription"),
                type = "boolean"
            },
            [2] = {
                key = "markerEnable",
                name = UltimatePartySystem.Core.GetLanguage("configMarkerEnabledName"),
                description = UltimatePartySystem.Core.GetLanguage("configMarkerEnabledName"),
                type = "boolean"
            },
            [3] = {
                key = "inviteTimeOut",
                name = UltimatePartySystem.Core.GetLanguage("configInviteTimeoutName"),
                description = UltimatePartySystem.Core.GetLanguage("configInviteTimeoutDescription"),
                type = "number"
            },
            [4] = {
                key = "enableFriendlyFire",
                name = UltimatePartySystem.Core.GetLanguage("configEnableFriendlyFireName"),
                description = UltimatePartySystem.Core.GetLanguage("configEnableFriendlyFireDescription"),
                type = "boolean"
            },
            [5] = {
                key = "enablePartyChat",
                name = UltimatePartySystem.Core.GetLanguage("configEnablePartyChatName"),
                description = UltimatePartySystem.Core.GetLanguage("configEnablePartyChatDescription"),
                type = "boolean"
            },
            [6] = {
                key = "partyChatCommand",
                name = UltimatePartySystem.Core.GetLanguage("configPartyChatCommandName"),
                description = UltimatePartySystem.Core.GetLanguage("configPartyChatCommandDescription"),
                type = "string"
            },
        }
    end)
end