function Nexus.JobCreator:CanAccessJob(ply, jobID)
    if not Nexus.JobCreator.ActiveJobs[jobID] then
        return false, "ERROR"
    end

    local data = Nexus.JobCreator.ActiveJobs[jobID]
    if data.Disabled then
        return false, Nexus.JobCreator:GetPhrase("Job Disabled", ply)
    end

    if data.Owner == ply:SteamID64() then
        return true, ""
    end

    data.Players = data.Players or {}
    if data.Players[ply:SteamID64()] then
        return true, ""
    end

    return false, Nexus.JobCreator:GetPhrase("This is a Custom Job", ply)
end

function Nexus.JobCreator:KickOffJob(jobID, ply)
    if ply then
        if ply:Team() == Nexus.JobCreator.JobCache[jobID] then
            ply:changeTeam(GAMEMODE.DefaultTeam, true)
        end
        return
    end

    for _, v in ipairs(player.GetAll()) do
        if v:Team() == Nexus.JobCreator.JobCache[jobID] then
            v:changeTeam(GAMEMODE.DefaultTeam, true)
        end
    end
end

function Nexus.JobCreator:CreateJob(ownerSteamid64, data)
    local formattedModels = {}

    if table.Count(data.SteamModels or {}) > 0 then
        formattedModels.localModels = {}
        for int, bool in pairs(data.SteamModels) do
            if not bool then continue end
            formattedModels.localModels[int] = true
        end
    end

    formattedModels.workshop = data.ImportedModels

    Nexus.JobCreator:Query([[INSERT INTO nexus_jobcreator_jobs
        (owner, name, description, color, extraHealth, extraArmor, extraSalary, gunLicense, models, guns, verified, disabled)
        VALUES(
            ]]..sql.SQLStr(ownerSteamid64)..[[,
            ]]..sql.SQLStr(data.Name)..[[,
            ]]..sql.SQLStr(data.Description)..[[,
            ]]..sql.SQLStr(util.TableToJSON(data.Color))..[[,
            ]]..data.Health..[[,
            ]]..data.Armor..[[,
            ]]..data.Salary..[[,
            ]]..tostring(data.GunLicense)..[[,
            ]]..sql.SQLStr(util.TableToJSON(formattedModels))..[[,
            ]]..sql.SQLStr(util.TableToJSON(data.SelectedGuns))..[[,
            0, 0
        )
    ]])

    Nexus.JobCreator:GetLastID(function(lastID)
        if not lastID then return end

        for steamid64, bool in pairs(data.Players or {}) do
            if not bool then continue end
            Nexus.JobCreator:Query([[INSERT INTO nexus_jobcreator_friends
            (jobID, steamid64)
            VALUES(]]..lastID..[[, ]]..sql.SQLStr(steamid64)..[[)
            ]])
        end

        data.id = lastID
        Nexus.JobCreator:LoadF4Job(data)
    end)
end

function Nexus.JobCreator:EditJob(jobID, data, blockStatus)
    data.id = jobID 
    if not blockStatus then
        Nexus.JobCreator:Query("UPDATE nexus_jobcreator_jobs SET verified = 0 WHERE id = "..data.id)
    end

    local formattedModels = {}

    Nexus.JobCreator:KickOffJob(jobID)

    if table.Count(data.SteamModels or {}) > 0 then
        formattedModels.localModels = {}
        for int, bool in pairs(data.SteamModels) do
            if not bool then continue end
            formattedModels.localModels[int] = true
        end
    end

    formattedModels.workshop = data.ImportedModels

    Nexus.JobCreator:Query([[UPDATE nexus_jobcreator_jobs SET 
        name = ]]..sql.SQLStr(data.Name)..[[,
        description = ]]..sql.SQLStr(data.Description)..[[,
        color = ]]..sql.SQLStr(util.TableToJSON(data.Color))..[[,
        extraHealth = ]]..data.Health..[[,
        extraArmor = ]]..data.Armor..[[,
        extraSalary = ]]..data.Salary..[[,
        gunLicense = ]]..tostring(data.GunLicense)..[[,
        models = ]]..sql.SQLStr(util.TableToJSON(formattedModels))..[[,
        guns = ]]..sql.SQLStr(util.TableToJSON(data.SelectedGuns))..[[

        WHERE id = ]]..jobID..[[;
    ]])

    for steamid64, bool in pairs(data.Players) do
        if not bool then continue end
        Nexus.JobCreator:Query([[INSERT INTO nexus_jobcreator_friends
        (jobID, steamid64)
        VALUES(]]..jobID..[[, ]]..sql.SQLStr(steamid64)..[[)
        ]])
    end

    Nexus.JobCreator:LoadF4Job(data)
end

util.AddNetworkString("Nexus:JobCreator:NetworkJob")
function Nexus.JobCreator:NetworkJob(jobID, ply)
    Nexus.JobCreator:ConstructJobFromSQL(jobID, function(data)
        net.Start("Nexus:JobCreator:NetworkJob")
        net.WriteUInt(Nexus.JobCreator.JobCache[tonumber(jobID)], 12)
        net.WriteString(RPExtraTeams[Nexus.JobCreator.JobCache[tonumber(jobID)]].command)
        Nexus.JobCreator:NetworkJobContents(data)
        if ply then 
            net.Send(ply)
        else
            net.Broadcast()
        end
    end)
end

function Nexus.JobCreator:DeleteJob(jobID)
    Nexus.JobCreator:Query("DELETE FROM nexus_jobcreator_jobs WHERE id = "..jobID..";")
    Nexus.JobCreator:Query("DELETE FROM nexus_jobcreator_friends WHERE jobID = "..jobID..";")

    net.Start("Nexus:JobCreator:JobDeleted")
    net.WriteUInt(jobID, 32)
    net.Broadcast()

    Nexus.JobCreator:KickOffJob(jobID)

    DarkRP.removeJob(Nexus.JobCreator.JobCache[tonumber(jobID)])
    Nexus.JobCreator.JobCache[tonumber(jobID)] = nil

    Nexus.JobCreator.ActiveJobs[jobID] = nil
end

function Nexus.JobCreator:JobDisabled(id, callback)
    Nexus.JobCreator:Query("SELECT disabled fROM nexus_jobcreator_jobs WHERE id = "..id..";", function(data)
        if #(data or {}) == 0 then return false end

        return tonumber(data[1].disabled) == 1
    end)
end