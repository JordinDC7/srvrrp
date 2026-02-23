function Nexus.JobCreator:CalculatePrice(data)
    local price = 0
    price = price + data.Health * Nexus:GetValue("nexus-jobcreator-price-health")
    price = price + data.Armor * Nexus:GetValue("nexus-jobcreator-price-armor")
    price = price + data.Salary * Nexus:GetValue("nexus-jobcreator-price-Salary")
    price = price + (data.GunLicense and Nexus:GetValue("nexus-jobcreator-price-GunLicense") or 0)

    price = price + (data.ImportedModels.ModelID and data.ImportedModels.Size*Nexus:GetValue("nexus-jobcreator-price-perMB") or 0)

    local localModelsCache = {}
    for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-localModels")) do
        localModelsCache[v.m_id] = v
    end

    for int, val in pairs(data.SteamModels) do
        price = price + localModelsCache[int].Price
    end

    local localGunsCache = {}
    for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-guns")) do
        localGunsCache[v.m_id] = v
    end

    for int, val in pairs(data.SelectedGuns) do
        price = price + localGunsCache[int].Price
    end

    price = price + Nexus:GetValue("nexus-jobcreator-price-baseCost")

    price = price + table.Count(data.Players) * Nexus:GetValue("nexus-jobcreator-price-player")


    return math.Round(price)
end

function Nexus.JobCreator:NetworkJobContents(data)
    if SERVER then
        Nexus.JobCreator.ActiveJobs[data.id] = data

        net.WriteUInt(data.id, 32)
        net.WriteString(data.Owner)
        net.WriteBool(data.Disabled)
        net.WriteBool(data.Verified)
    end

    net.WriteString(data.Name) -- name
    net.WriteString(data.Description) -- description
    net.WriteColor(data.Color) -- colour
    net.WriteUInt(data.Health, 12) -- health
    net.WriteUInt(data.Armor, 12) -- armor
    net.WriteUInt(data.Salary, 12) -- salary
    net.WriteBool(data.GunLicense) -- Gun License

    net.WriteBool(data.ImportedModels.ModelID)
    if data.ImportedModels.ModelID then
        net.WriteUInt(data.ImportedModels.ModelID, 32)
        net.WriteUInt(table.Count(data.ImportedModels.Models), 10)
        if SERVER then
            net.WriteFloat(data.ImportedModels.Size)
        end
        for modelID, bodygroups in pairs(data.ImportedModels.Models) do
            net.WriteString(modelID)
            net.WriteUInt(table.Count(bodygroups), 10)
            for bodygroup, value in pairs(bodygroups) do
                net.WriteUInt(bodygroup, 10)
                net.WriteUInt(value, 10)
            end
        end
    end

    net.WriteUInt(table.Count(data.SteamModels or {}), 10)
    for int, val in pairs(data.SteamModels or {}) do
        if not val then continue end
        net.WriteUInt(int, 15)
    end

    net.WriteUInt(table.Count(data.SelectedGuns or {}), 10)
    for int, val in pairs(data.SelectedGuns or {}) do
        if not val then continue end
        net.WriteUInt(int, 15)
    end

    net.WriteUInt(table.Count(data.Players or {}), 10)
    for steamid64, _ in pairs(data.Players or {}) do
        net.WriteString(steamid64)
    end
end

function Nexus.JobCreator:GetModelFromID(id)
    local localModelsCache = {}
    for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-localModels")) do
        localModelsCache[v.m_id] = v.Model
    end

    return localModelsCache[id]
end

function Nexus.JobCreator:GetGunFromID(id)
    local localGunsCache = {}
    for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-guns")) do
        localGunsCache[v.m_id] = v.Class
    end

    return localGunsCache[id]
end

Nexus.JobCreator.CurInt = Nexus.JobCreator.CurInt or 1
Nexus.JobCreator.JobCache = Nexus.JobCreator.JobCache or {}
function Nexus.JobCreator:LoadF4Job(data, tbl)
    if not data.id then return end
    if Nexus.JobCreator.JobCache[tonumber(data.id)] then
        DarkRP.removeJob(Nexus.JobCreator.JobCache[tonumber(data.id)])
    end

    local models = {}

    if data.ImportedModels and data.ImportedModels.ModelID and data.ImportedModels.Models then
        for modelID, bodygroups in pairs(data.ImportedModels.Models) do
            table.insert(models, modelID)
        end
    end

    for modelID, bool in pairs(data.SteamModels) do
        if not bool then continue end

        local model = Nexus.JobCreator:GetModelFromID(modelID)
        if not model then continue end

        table.insert(models, model)
    end

    if #models == 0 then
        models = "models/player/Group02/male_08.mdl"
    end

    local guns = {}
    for gunID, bool in pairs(data.SelectedGuns) do
        if not bool then continue end

        local class = Nexus.JobCreator:GetGunFromID(gunID)
        if not class then continue end

        table.insert(guns, class)
    end

    Nexus.JobCreator.CurInt = Nexus.JobCreator.CurInt + 1
    local jobid = DarkRP.createJob(data.Name, {
        customJob = data.id,
        color = data.Color,
        model = models,
        description = data.Description,
        weapons = guns,
        admin = 0,
        vote = false,
        category = "Custom Jobs",
        command = tbl and tbl[2] or "jobcreator_"..Nexus.JobCreator.CurInt,
        max = Nexus:GetValue("nexus-jobcreator-max-players"),
        salary = data.Salary,
        OnPlayerChangedTeam = function(ply)
            if CLIENT then return end

            timer.Simple(0.1, function()
                ply:SetHealth(ply:Health() + data.Health)
                ply:SetArmor(ply:Armor() + data.Armor)

                local models = {}
                for k, v in pairs(data.ImportedModels and data.ImportedModels.Models or {}) do
                    models[string.lower(k)] = v
                end

                for k, v in pairs(models[string.lower(ply:GetModel())] or {}) do
                    ply:SetBodygroup(k, v) 
                end
            end)
        end,
        PlayerSpawn = function(ply)
            if CLIENT then return end

            timer.Simple(0.1, function()
                ply:SetHealth(ply:Health() + data.Health)
                ply:SetArmor(ply:Armor() + data.Armor)

                local models = {}
                for k, v in pairs(data.ImportedModels and data.ImportedModels.Models or {}) do
                    models[string.lower(k)] = v
                end

                for k, v in pairs(models[string.lower(ply:GetModel())] or {}) do
                    ply:SetBodygroup(k, v) 
                end
            end)
        end,
        customCheck = function(ply)
            if CLIENT then return true end

            local success, msg = Nexus.JobCreator:CanAccessJob(ply, data.id)
            return success
        end,

        CustomCheckFailMsg = function() return Nexus.JobCreator:GetPhrase("This is a Custom Job") end,
    })

    if tbl then
        local teamID = tbl[1]
        local jobDATA = table.Copy(RPExtraTeams[jobid])
        RPExtraTeams[jobid] = nil
        RPExtraTeams[teamID] = jobDATA
        Nexus.JobCreator.JobCache[tonumber(data.id)] = teamID
    else
        Nexus.JobCreator.JobCache[tonumber(data.id)] = jobid
    end

    Nexus.JobCreator.ActiveJobs[data.id] = data

    if SERVER then
        Nexus.JobCreator:NetworkJob(data.id)
    end
end

function Nexus.JobCreator:FormatPrice(price)
    return Nexus.JobCreator.Currencies[Nexus:GetValue("nexus-jobcreator-selectedcurrency")].Format(price)
end

function Nexus.JobCreator:CanAfford(ply, amount)
    return Nexus.JobCreator.Currencies[Nexus:GetValue("nexus-jobcreator-selectedcurrency")].CanAfford(ply, amount)
end

function Nexus.JobCreator:AddMoney(ply, amount)
    return Nexus.JobCreator.Currencies[Nexus:GetValue("nexus-jobcreator-selectedcurrency")].AddMoney(ply, amount)
end

function Nexus.JobCreator:GetTotalMoney(ply)
    return Nexus.JobCreator.Currencies[Nexus:GetValue("nexus-jobcreator-selectedcurrency")].GetTotalMoney(ply)
end

function Nexus.JobCreator:GetCredits(ply)
    return ply.JobCredits or 0
end
