UltimatePartySystem = UltimatePartySystem or {}
UltimatePartySystem.Core = UltimatePartySystem.Core or {}
UltimatePartySystem.Settings = UltimatePartySystem.Settings or {}
UltimatePartySystem.Languages = UltimatePartySystem.Languages or {}
UltimatePartySystem.NetCooldowns = UltimatePartySystem.NetCooldowns or {}
UltimatePartySystem.UI = UltimatePartySystem.UI or {}
UltimatePartySystem.Cache = UltimatePartySystem.Cache or {}

UltimatePartySystem.Parties = UltimatePartySystem.Parties or {}
UltimatePartySystem.Radios = UltimatePartySystem.Radios or {}
UltimatePartySystem.Invites = UltimatePartySystem.Invites or {}

UltimatePartySystem.Config = UltimatePartySystem.Config or {}

function UltimatePartySystem.Core.Print(message)
    MsgC(Color(37, 199, 116), "[UPS] ", color_white, message, "\n")
end

UltimatePartySystem.Core.Print("Loading Ultimate Party System...")
UltimatePartySystem.Core.Print("")
if(SERVER) then
    local files,dirs = file.Find("ultimatepartysystem/*", "LUA")

    for k,v in pairs(dirs) do
        UltimatePartySystem.Core.Print(v)
        for x,y in pairs(file.Find("ultimatepartysystem/" .. v .. "/sv*.lua", "LUA")) do
            UltimatePartySystem.Core.Print("  - " .. y)
            include(string.format("ultimatepartysystem/%s/%s", v, y))
        end
        for x,y in pairs(file.Find("ultimatepartysystem/" .. v .. "/sh*.lua", "LUA")) do
            UltimatePartySystem.Core.Print("  - " .. y)
            include(string.format("ultimatepartysystem/%s/%s", v, y))
            AddCSLuaFile(string.format("ultimatepartysystem/%s/%s", v, y))
        end
        for x,y in pairs(file.Find("ultimatepartysystem/" .. v .. "/cl*.lua", "LUA")) do
            UltimatePartySystem.Core.Print("  - " .. y)
            AddCSLuaFile(string.format("ultimatepartysystem/%s/%s", v, y))
        end
    end

    UltimatePartySystem.Settings.LoadSettings()

    if(UltimatePartySystem.Config.FastDL) then
        resource.AddWorkshop("2251982296")
    end
else
    UltimatePartySystem.ClientSettings = UltimatePartySystem.ClientSettings or {}
    UltimatePartySystem.Markers = UltimatePartySystem.Markers or {}

    local files,dirs = file.Find("ultimatepartysystem/*", "LUA")

    for k,v in pairs(dirs) do
        UltimatePartySystem.Core.Print(v)
        for x,y in pairs(file.Find("ultimatepartysystem/" .. v .. "/sh*.lua", "LUA")) do
            UltimatePartySystem.Core.Print("  - " .. y)
            include(string.format("ultimatepartysystem/%s/%s", v, y))
        end
        for x,y in pairs(file.Find("ultimatepartysystem/" .. v .. "/cl*.lua", "LUA")) do
            UltimatePartySystem.Core.Print("  - " .. y)
            include(string.format("ultimatepartysystem/%s/%s", v, y))
        end
    end

    UltimatePartySystem.ClientSettings.Load()
end

hook.Add("libgmodstore_init", "7417_libgmodstore", function()
    libgmodstore:InitScript(7417, "🤝 UPS [Ultimate Party System] (Party/Squad System)", {
        version = "1.0.11",
        licensee = "76561198121018313"
    })
end)

if(!UltimatePartySystem.Languages[UltimatePartySystem.Config.Language]) then
    UltimatePartySystem.Core.Print("Couldn't find selected language. Loading English as final resort.")
    UltimatePartySystem.Config.Language = "en"
end
function UltimatePartySystem.Core.GetLanguage(key, ...)
    if(!UltimatePartySystem.Languages[UltimatePartySystem.Config.Language][key]) then
        return "Error loading text with key '" .. key .. "'. Double check the language file and try again."
    end

    local args = {...}
    return string.format(UltimatePartySystem.Languages[UltimatePartySystem.Config.Language][key], unpack(args))
end

hook.Run("ultimatepartysystem.core.loaded") -- settings visual tables are loaded here
UltimatePartySystem.Core.Print("")
UltimatePartySystem.Core.Print("Loaded Ultimate Party System.")