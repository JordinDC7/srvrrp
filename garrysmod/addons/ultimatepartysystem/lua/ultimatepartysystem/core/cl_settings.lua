-- Client specific settings. Config is in sh_settings.lua
-- These are stored in cl.db so their settings persist over servers.

-- This entire file is pretty much just a copied and pasted sh_settings.lua but made to work with clientside only.


UltimatePartySystem.ClientSettings.Defaults = {}
UltimatePartySystem.ClientSettings.Defaults["drawHUD"] = true -- If the addon should draw the party HUD.
UltimatePartySystem.ClientSettings.Defaults["hudOffsetX"] = 15 -- The offset position on X axis.
UltimatePartySystem.ClientSettings.Defaults["hudOffsetY"] = 15 -- The offset position on Y axis.
UltimatePartySystem.ClientSettings.Defaults["hudOpaque"] = 255 -- The opaqueness of the HUD.
UltimatePartySystem.ClientSettings.Defaults["drawMarkers"] = true -- If to draw markers.
UltimatePartySystem.ClientSettings.Defaults["displayPartyChat"] = true -- If to display party chat.

UltimatePartySystem.ClientSettings.Values = {}

function UltimatePartySystem.ClientSettings.Load()
    if(!sql.TableExists("ultimatepartysystem_clientsettings")) then
        local create = sql.Query("CREATE TABLE `ultimatepartysystem_clientsettings`(`key` VARCHAR(255), `type` INT(1), `value` VARCHAR(255));")

        if(create == false) then
            UltimatePartySystem.Core.Print("Something went wrong creating the client-based settings table. This will most likely cause errors. Try re-joining the game, if that doesn't work then tell the server developers to create a ticket on gmodstore.")
            UltimatePartySystem.Core.Print("Not continuing to fetch settings. Using default values.")

            return
        end
    end

    local q = sql.Query("SELECT * FROM `ultimatepartysystem_clientsettings`;")
    if(q == nil) then return end -- No need to do anything else since its all just default values.
    if(q == false) then
        UltimatePartySystem.Core.Print("Something went wrong fetching from the client-based settings table. This will most likely cause errors. Try re-joining the game, if that doesn't work then tell the server developers to create a ticket on gmodstore.")
        UltimatePartySystem.Core.Print("Not continuing to fetch settings. Using default values.")

        return
    end

    for k,v in pairs(q) do
        if(!UltimatePartySystem.ClientSettings.Defaults[v.key]) then continue end

        local value = UltimatePartySystem.Settings.StorableToLua(v.value, tonumber(v.type)) -- This func is declared shared in sh_settings and shared files are loaded before client files in the autoloader, so this function definitely exists.
        if(UltimatePartySystem.ClientSettings.Defaults[v.key] == value) then
            sql.Query("DELETE FROM `ultimatepartysystem_clientsettings` WHERE `key` = " .. sql.SQLStr(k) .. ";")
            continue
        end

        UltimatePartySystem.ClientSettings.Values[v.key] = value
    end

    UltimatePartySystem.Core.Print("Successfully loaded client's settings.")
end

function UltimatePartySystem.ClientSettings.SetValue(key, val)
    if(UltimatePartySystem.ClientSettings.Values[key] == val) then return end

    UltimatePartySystem.ClientSettings.Values[key] = val

    local storable,type = UltimatePartySystem.Settings.LuaToStorable(val)
    local q1 = sql.Query("SELECT key FROM `ultimatepartysystem_clientsettings` WHERE key = " .. sql.SQLStr(key) .. ";") -- purely to check if it's in the table

    if(q1 == nil) then
        local q2 = sql.Query("INSERT INTO `ultimatepartysystem_clientsettings`(`key`, `type`, `value`) VALUES(" .. sql.SQLStr(key) .. ", " .. type .. ", " .. sql.SQLStr(storable) .. ");")
    else
        sql.Query("UPDATE `ultimatepartysystem_clientsettings` SET `value` = " .. sql.SQLStr(storable) .. ", `type` = " .. type .. " WHERE key = " .. sql.SQLStr(key) .. ";")
    end
end
function UltimatePartySystem.ClientSettings.GetValue(key)
    if(UltimatePartySystem.ClientSettings.Defaults[key] == nil) then return end

    if(UltimatePartySystem.ClientSettings.Values[key] == nil) then
        return UltimatePartySystem.ClientSettings.Defaults[key]
    end
    return UltimatePartySystem.ClientSettings.Values[key]
end

hook.Add("ultimatepartysystem.core.loaded", "ultimatepartysystem.settings.loadclientdisplay", function()
    -- Display stuff.
    UltimatePartySystem.ClientSettings.ConfigDisplay = {
        [1] = {
            key = "drawHUD",
            name = UltimatePartySystem.Core.GetLanguage("clientConfigDrawHUDName"),
            description = UltimatePartySystem.Core.GetLanguage("clientConfigDrawHUDDescription"),
            type = "boolean"
        },
        [2] = {
            key = "hudOffsetX",
            name = UltimatePartySystem.Core.GetLanguage("clientConfigHUDXName"),
            description = UltimatePartySystem.Core.GetLanguage("clientConfigHUDXDescription"),
            type = "number"
        },
        [3] = {
            key = "hudOffsetY",
            name = UltimatePartySystem.Core.GetLanguage("clientConfigHUDYName"),
            description = UltimatePartySystem.Core.GetLanguage("clientConfigHUDYDescription"),
            type = "number"
        },
        [4] = {
            key = "hudOpaque",
            name = UltimatePartySystem.Core.GetLanguage("clientConfigHUDOpacityName"),
            description = UltimatePartySystem.Core.GetLanguage("clientConfigHUDOpacityDescription"),
            type = "number"
        },
        [5] = {
            key = "drawMarkers",
            name = UltimatePartySystem.Core.GetLanguage("clientConfigDrawMarkersName"),
            description = UltimatePartySystem.Core.GetLanguage("clientConfigDrawMarkersDescription"),
            type = "boolean"
        },
        [6] = {
            key = "displayPartyChat",
            name = UltimatePartySystem.Core.GetLanguage("clientConfigDisplayPartyChatName"),
            description = UltimatePartySystem.Core.GetLanguage("clientConfigDisplayPartyChatDescription"),
            type = "boolean"
        },
    }
end)
