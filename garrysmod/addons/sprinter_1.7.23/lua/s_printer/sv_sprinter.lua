sPrinter = sPrinter or {}
sPrinter.printersCache = sPrinter.printersCache or {}
sPrinter.authCache = sPrinter.authCache or {}

resource.AddWorkshop("2264178565")

util.AddNetworkString("sP:Networking") --- Add netstring:76561199109663690

sPrinter.recreateSound = function(vol)
    sound.Add( {
        name = "sPrinter_Printing",
        channel = CHAN_STATIC,
        volume = vol or 1,
        level = sPrinter.config["soundradius"],
        pitch = 100,
        sound = "sprinter/printing_loop.wav"
    } )
end

sPrinter.recreateSound()

local function networkUpgrade(ply, ent, specific)
    net.Start("sP:Networking")
    net.WriteEntity(ent)
    net.WriteUInt(0, 2)
    net.WriteUInt(specific, 3)
    net.WriteUInt(ent.data.upgrades[specific].stage or 0, 4)
    net.Send(ply)
end

sPrinter.networkUpgrades = function(ent, specific, ply)
    if !specific then
        for k,v in pairs(ent.data.upgrades) do
            sPrinter.networkUpgrades(ent, k, ply)
        end
    return end

    if ply then
        networkUpgrade(ply, ent, specific)
    return end

    for k,v in pairs(ent.upgradesNetwork) do
        networkUpgrade(k, ent, specific)
    end
end

local function networkSetting(ply, ent, specific)
    net.Start("sP:Networking")
    net.WriteEntity(ent)
    net.WriteUInt(1, 2)
    net.WriteUInt(specific, 3)
    net.WriteBool(ent.settings[specific])
    net.Send(ply)
end

local networkSettings
networkSettings = function(ent, specific, ply)
    if !specific then
        for setting,v in pairs(ent.settings) do
            networkSettings(ent, setting, ply)
        end
    return end
    
    if ply then
        networkSetting(ply, ent, specific)
    return end

    for k,v in pairs(ent.settingsNetwork) do
        networkSetting(k, ent, specific)
    end
end

local function networkLog(ply, ent, specific)
    local data = ent.logs[specific]
    data = util.TableToJSON(data)
    data = util.Compress(data)

    net.Start("sP:Networking")
    net.WriteEntity(ent)
    net.WriteUInt(2, 2)
    net.WriteUInt(#data, 32)
    net.WriteData(data, #data)
    net.Send(ply)
end

local networkLogs
networkLogs = function(ent, specific, ply)
    if !specific then
        for log,v in pairs(ent.logs) do
            networkLogs(ent, log, ply)
        end
    return end
    
    if ply then
        networkLog(ply, ent, specific)
    return end

    for k,v in pairs(ent.logsNetwork) do
        if !IsValid(k) then continue end
        networkLog(k, ent, specific)
    end
end

local acceptedClass = {
    ["sprinter_base"] = true,
    ["sprinter_rack"] = true,
    ["sprinter_base_phys"] = true
}

local startedCracks = {}

local function networkAuthorization(ply, printer)
    local sid64 = ply:SteamID64()

    net.Start("sP:Networking")
    net.WriteEntity(printer)
    net.WriteUInt(3, 2)
    net.WriteBool(!!printer.authorized[sid64])
    net.Send(ply)
end

net.Receive("sP:Networking", function(len, ply)
    if !ply:Alive() or ply:InVehicle() then return end
    
    local ent = net.ReadEntity()

    if !IsValid(ent) then return end

    local action = net.ReadUInt(3)

    if !acceptedClass[ent:GetClass()] and !acceptedClass[ent.Base] then return end
    local isRack = ent.isRack

    if !isRack and !ent.networkedAll[ply] then
        ent.networkedAll[ply] = true
        ent.upgradesNetwork[ply] = true
        sPrinter.networkUpgrades(ent, nil, ply)
    return end

    local trace = ply:GetEyeTrace()
    local trEnt = trace.Entity

    if !trEnt.sPrinter_ent then return end

    local entpos = ent:GetPos()
    local plypos = ply:GetPos()
    entpos.z = plypos.z

    local distance = entpos:DistToSqr(plypos)

    if distance > sPrinter.config["maxdistance"] then return end

    if (ent ~= trEnt and ent.rack ~= trEnt and trEnt.Printer ~= ent) and (isfunction(ent.GetRack) and ent:GetRack() ~= trEnt) then return end

    local isLocked = false

    if isRack then
        isLocked = ent:GetLocked()
    else
        local rack = ent:GetRack()

        if IsValid(rack) and rack:GetLocked() then isLocked = true end
    end

    if isLocked and action ~= 5 then return end

    if action == 1 then
        local subaction = net.ReadUInt(2)

        if subaction == 1 then
            ent:Withdraw(ply)
        elseif subaction == 2 and !isRack then
            ent:Eject(ply)
        elseif subaction == 3 then
            ent:Power()
        end
    elseif action == 2 then
        local subaction = net.ReadUInt(2)

        if subaction == 1 then
            ent:Recharge(ply)
        elseif subaction == 2 then
            if isRack then
                ent:Repair(ply, net.ReadBool())
            else
                ent:Repair(ply)
            end
        elseif subaction == 3 and !isRack then
            local setting = net.ReadUInt(3)
            local result = net.ReadBool()
            ent.settings[setting] = result

            networkSettings(ent, setting)
        end
        
    elseif action == 3 and !isRack then
        local upgrade = net.ReadUInt(3)
        local full = net.ReadBool()
        
        ent:Upgrade(ply, upgrade, full)
    elseif action == 4 and !isRack then
        local subaction = net.ReadUInt(2)
        if subaction == 1 and !ent.settingsNetwork[ply] then
            ent.settingsNetwork[ply] = true
            networkSettings(ent, nil, ply)
        elseif subaction == 2 and !ent.logsNetwork[ply] then
            ent.logsNetwork[ply] = true
            networkLogs(ent, nil, ply)
        end
    elseif action == 5 and isRack then
        local subaction = net.ReadUInt(2)

        if subaction == 0 then
            local owner = ent:Getowning_ent()

            local sid64 = ply:SteamID64()

            if owner ~= ply and !ent.authorized[sid64] then return end

            local toLock = net.ReadBool()

            ent:SetLocked(toLock)
            ent:EmitSound(toLock and "buttons/combine_button3.wav" or "buttons/combine_button1.wav")
        elseif subaction == 1 then
            local owner = ent:Getowning_ent()

            if !IsValid(owner) or owner ~= ply then return end

            local target = net.ReadUInt(17)
            local access = net.ReadBool()

            target = Entity(target)

            if !IsValid(target) or !target:IsPlayer() then return end

            local sid64 = target:SteamID64()

            ent.authorized[sid64] = access or nil

            sPrinter.authCache[sid64] = sPrinter.authCache[sid64] or {}
            sPrinter.authCache[sid64][ent] = ent.authorized[sid64]

            networkAuthorization(target, ent)
        elseif subaction == 2 then
            local start = net.ReadBool()
            local sid64 = ply:SteamID64()

            if start then
                startedCracks[sid64] = CurTime()
            else
                local min_time = (((300 / sPrinter.config["hack_speed"]) / 60) * 3) - 1 // -1 to take networking into consideration
                if !startedCracks[sid64] or CurTime() - startedCracks[sid64] < min_time then
                    if sPrinter.config["punish_exploit"] then
                        slib.punish(ply, 2, slib.getLang("sprinter", sPrinter.config["language"], "exploit_attempted"), 0)
                    end
                return end

                ent:SetLocked(false)

                ent:EmitSound("buttons/button19.wav")
            end

        elseif subaction == 3 then
            local price = 0

            for i = 1, 8 do
                local printer = ent.printers[i]
                if !IsValid(printer) then continue end
                
                for k, v in ipairs(printer.data.upgrades) do
                    price = price + printer:GetFullUpgradePrice(k)
                end
            end

            if sPrinter.config.canAfford(ply, price) then           
                for i = 1, 8 do
                    local printer = ent.printers[i]
                    if !IsValid(printer) then continue end
                    
                    for k,v in ipairs(printer.data.upgrades) do
                        printer:Upgrade(ply, k, true, true)
                    end
                end

                slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "upgraded-rack", sPrinter.config["currency"]..string.Comma(price)), ply)
            end
        end
    end
end)

hook.Add("OnEntityWaterLevelChanged", "sP:HandleWater", function(ent, old, new)
    if ent.sPrinter_ent and new >= 2 then
        local isRack = ent.isRack
        local action = isRack and sPrinter.config["rack"]["water_affect"] or (ent.data and ent.data["water_affect"]) or 1
        local identifier = ent:EntIndex().."_recheck_water"
        if timer.Exists(identifier) then return end
        timer.Create(identifier, 1.5, 1, function()
            if !IsValid(ent) or ent:WaterLevel() < 2 then return end
            if action > 0 then
                if action == 1 and ent.Explode then
                    ent:Explode()
                end

                if action == 2 then
                    if isRack then
                        for i = 1, 8 do
                            local printer = ent.printers[i]
                            if !IsValid(printer) then continue end
                            printer:Explode()
                        end
                    else
                        ent:Power(false)
                    end
                end
            end
        end)
    end
end)

hook.Add("sP:LogAdded", "sP:NetworkLogs", networkLogs)

local function cacheSpawned(ply, ent)
    if ent.sPrinter_ent then
        ply = ply or isfunction(ent.Getowning_ent) and ent:Getowning_ent()

        if !ply or !IsValid(ply) then return end

        local sid64 = ply:SteamID64()

        sPrinter.printersCache[sid64] = sPrinter.printersCache[sid64] or {}
        sPrinter.printersCache[sid64][ent] = true
    end
end

hook.Add("playerBoughtCustomEntity", "sP:HandlePurchasingCache", function(ply, enttbl, ent, price)
    cacheSpawned(ply, ent)
end)

hook.Add("OnEntityCreated", "sP:HandleSpawnRack", function(ent)
    timer.Simple(0, function()
        cacheSpawned(nil, ent)
    end)
end)

hook.Add("CarTrunk:OnItemTaken", "sP:CarTrunkCompatibility", function(ply, veh, ent)
    ent.networkedAll = {}
    ent.logsNetwork = {}
    ent.settingsNetwork = {}
end)

hook.Add("slib.FullLoaded", "sP:HandleDisconnects", function(ply)
    local sid64 = ply:SteamID64()

    if sPrinter.printersCache[sid64] then
        for printer, v in pairs(sPrinter.printersCache[sid64]) do
            if !IsValid(printer) then sPrinter.printersCache[printer] = nil continue end
            printer:Setowning_ent(ply)
        end
    end

    if sPrinter.authCache[sid64] then
        for printer, v in pairs(sPrinter.authCache[sid64]) do
            if !IsValid(printer) then sPrinter.authCache[printer] = nil continue end

            networkAuthorization(ply, printer)
        end
    end
end)