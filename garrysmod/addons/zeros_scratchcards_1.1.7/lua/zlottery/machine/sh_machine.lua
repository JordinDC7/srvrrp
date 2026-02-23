zlt = zlt or {}
zlt.Machine = zlt.Machine or {}

if CLIENT then

    // Called from interface after config change
    function zlt.Machine.UpdateConfig(ConfigData)
        zclib.config.Debug = ConfigData.Debug
        zclib.config.Currency = ConfigData.Currency
        zclib.config.CurrencyInvert = ConfigData.CurrencyInvert
        zlt.config.SelectedLanguage = ConfigData.SelectedLanguage
        zclib.config.AdminRanks = table.Copy(ConfigData.AdminRanks)
        zlt.config.Fonts = table.Copy(ConfigData.Fonts)

        zlt.config.AutoPickup = ConfigData.AutoPickup
        zlt.config.InstantUse = ConfigData.InstantUse

        local e_String = util.TableToJSON(ConfigData)
        local e_Compressed = util.Compress(e_String)
        net.Start("zlt_Config_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.SendToServer()
    end

    // Called from SERVER after config UPDATE
    net.Receive("zlt_Config_Update", function(len)
        zclib.Debug_Net("zlt_Config_Update", len)

        local dataLength = net.ReadUInt(16)
        local dataDecompressed = util.Decompress(net.ReadData(dataLength))
        local ConfigData = util.JSONToTable(dataDecompressed)

        zclib.config.Debug = ConfigData.Debug
        zclib.config.Currency = ConfigData.Currency
        zclib.config.CurrencyInvert = ConfigData.CurrencyInvert
        zlt.config.SelectedLanguage = ConfigData.SelectedLanguage
        zclib.config.AdminRanks = table.Copy(ConfigData.AdminRanks)
        zlt.config.Fonts = table.Copy(ConfigData.Fonts)

        zlt.config.AutoPickup = ConfigData.AutoPickup
        zlt.config.InstantUse = ConfigData.InstantUse

        // Rebuilds the fonts
        zlt.Font.Rebuild()
        zclib.LoadedFonts = {}

        // Reload the languages
        local files, _ = file.Find("zlt_languages/*", "LUA")
        for _, v in ipairs(files) do
            if string.sub(v, 1, 3) == "sh_" then
                if CLIENT then
                    include("zlt_languages/" .. v)
                else
                    AddCSLuaFile("zlt_languages/" .. v)
                    include("zlt_languages/" .. v)
                end
            end
        end

        // Reload prizetypes
        include("zlottery/ticket/sh_ticket_prizetypes.lua")
    end)
else

    // Loads the main Configs once the SERVER finished loading
    timer.Simple(1,function()
        if file.Exists("zlt/config_main.txt", "DATA") then
            local ConfigData = file.Read("zlt/config_main.txt","DATA")
            if ConfigData then
                ConfigData = util.JSONToTable(ConfigData)

                zclib.config.Debug = ConfigData.Debug
                zclib.config.Currency = ConfigData.Currency
                zclib.config.CurrencyInvert = ConfigData.CurrencyInvert
                zlt.config.SelectedLanguage = ConfigData.SelectedLanguage
                zclib.config.AdminRanks = table.Copy(ConfigData.AdminRanks)
                zlt.config.Fonts = table.Copy(ConfigData.Fonts)

                zlt.config.AutoPickup = ConfigData.AutoPickup
                zlt.config.InstantUse = ConfigData.InstantUse

                zlt.Print("Main Config loaded!")
                zlt.Machine.UpdateConfig(ConfigData)
            end
        end
    end)

    // Saves the main config
    util.AddNetworkString("zlt_Config_Update")
    net.Receive("zlt_Config_Update", function(len,ply)
        zclib.Debug_Net("zlt_Config_Update", len)

        if zclib.Player.Timeout(nil,ply) == true then return end
        if zclib.Player.IsAdmin(ply) == false then return end

        local dataLength = net.ReadUInt(16)
        local dataDecompressed = util.Decompress(net.ReadData(dataLength))
        local ConfigData = util.JSONToTable(dataDecompressed)

        zclib.config.Debug = ConfigData.Debug
        zclib.config.Currency = ConfigData.Currency
        zclib.config.CurrencyInvert = ConfigData.CurrencyInvert
        zlt.config.SelectedLanguage = ConfigData.SelectedLanguage
        zclib.config.AdminRanks = table.Copy(ConfigData.AdminRanks)
        zlt.config.Fonts = table.Copy(ConfigData.Fonts)

        zlt.config.AutoPickup = ConfigData.AutoPickup
        zlt.config.InstantUse = ConfigData.InstantUse

        // Save to file
        if not file.Exists("zlt", "DATA") then file.CreateDir("zlt") end
        file.Write("zlt/config_main.txt", util.TableToJSON(ConfigData,true))

        // Inform CLIENTS
        zlt.Machine.UpdateConfig(ConfigData)
    end)

    // Informs all CLIENTS about the config change, This is usally only needed if the config gets changed mid game without a restart
    function zlt.Machine.UpdateConfig(config)
        local e_String = util.TableToJSON(config)
        local e_Compressed = util.Compress(e_String)
        net.Start("zlt_Config_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.Broadcast()
    end

    function zlt.Machine.SendConfig(ply)
        zclib.Debug("zlt.Machine.SendConfig " .. tostring(ply))

        local ConfigData = {}
        ConfigData.Debug = zclib.config.Debug
        ConfigData.Currency = zclib.config.Currency
        ConfigData.CurrencyInvert = zclib.config.CurrencyInvert
        ConfigData.SelectedLanguage = zlt.config.SelectedLanguage
        ConfigData.AdminRanks = table.Copy(zclib.config.AdminRanks)
        ConfigData.Fonts = table.Copy(zlt.config.Fonts)

        ConfigData.AutoPickup = zlt.config.AutoPickup
        ConfigData.InstantUse = zlt.config.InstantUse

        local e_String = util.TableToJSON(ConfigData)
        local e_Compressed = util.Compress(e_String)
        net.Start("zlt_Config_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.Send(ply)
    end
end


zlt.MachinesData = zlt.MachinesData or {}
function zlt.Machine.SetupData(Entindex)
    zclib.Debug("zlt.Machine.SetupData")
    // Dont do that if its not nill
    if zlt.MachinesData[Entindex] then return end
    zlt.MachinesData[Entindex] = {
        Slot01 = -1,
        Slot02 = -1,
        Slot03 = -1,
        Slot04 = -1,
        Paint = Vector(1, 1, 1),
        Light = Vector(1, 1, 1),
        Logo = "",
        LogoScaleW = 1,
        LogoScaleH = 1,
        LogoPosX = 0.5,
        LogoPosY = 0.5
    }
end

function zlt.Machine.RemoveData(Entindex)
    zclib.Debug("zlt.Machine.RemoveData")
    zlt.MachinesData[Entindex] = nil
end

function zlt.Machine.SetData(Entindex, key, data)
    zclib.Debug("zlt.Machine.SetData")
    if zlt.MachinesData[Entindex] == nil then
        zlt.Machine.SetupData(Entindex)
    end

    zlt.MachinesData[Entindex][key] = data
end

function zlt.Machine.SetAllData(Entindex,data)
    zclib.Debug("zlt.Machine.SetAllData")
    zlt.MachinesData[Entindex] = data
end

function zlt.Machine.GetData(Entindex, key)
    if zlt.MachinesData[Entindex] == nil then
        zlt.Machine.SetupData(Entindex)
    end

    return zlt.MachinesData[Entindex][key]
end

function zlt.Machine.GetAllData(Entindex)
    if zlt.MachinesData[Entindex] == nil then
        zlt.Machine.SetupData(Entindex)
    end

    return zlt.MachinesData[Entindex]
end

if SERVER then
    // Sends the machines net data to the specified player
    util.AddNetworkString("zlt_Machine_Update")
    function zlt.Machine.SendData(Machine,ply)
        zclib.Debug("zlt.Machine.SendData")
        local e_index = Machine:EntIndex()
        local e_String = util.TableToJSON(zlt.MachinesData[e_index])
        local e_Compressed = util.Compress(e_String)
        net.Start("zlt_Machine_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.WriteUInt(e_index,16)
        net.Send(ply)
    end

    function zlt.Machine.SendDataToAll(Machine)
        zclib.Debug("zlt.Machine.SendDataToAll")
        local e_index = Machine:EntIndex()
        local e_String = util.TableToJSON(zlt.MachinesData[e_index])
        local e_Compressed = util.Compress(e_String)
        net.Start("zlt_Machine_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.WriteUInt(e_index,16)
        net.Broadcast()
    end
else
    net.Receive("zlt_Machine_Update", function(len)
        zclib.Debug_Net("zlt_Machine_Update", len)

        local dataLength = net.ReadUInt(16)
        local dataDecompressed = util.Decompress(net.ReadData(dataLength))
        local data = util.JSONToTable(dataDecompressed)
        local EntIndex = net.ReadUInt(16)
        if EntIndex == nil then return end

        zlt.Machine.SetAllData(EntIndex, data)
    end)
end
