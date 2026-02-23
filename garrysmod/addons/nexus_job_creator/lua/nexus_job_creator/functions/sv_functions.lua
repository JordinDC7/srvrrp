util.AddNetworkString("Nexus:JobCreator:Notification")
function Nexus.JobCreator:Notification(ply, str, time)
    time = time or 3

    net.Start("Nexus:JobCreator:Notification")
    net.WriteString(str)
    net.WriteUInt(time, 6)
    net.Send(ply)
end

local cooldowns = {}
function Nexus.JobCreator:AddCooldown(ply)
    cooldowns[ply] = CurTime() + Nexus:GetValue("nexus-jobcreator-cooldown")
end

function Nexus.JobCreator:HasCooldown(ply)
    if cooldowns[ply] and CurTime() < cooldowns[ply] then
        Nexus.JobCreator:Notification(ply, string.format(Nexus.JobCreator:GetPhrase("On Cooldown", ply), tostring(math.Round(cooldowns[ply]-CurTime()))), 3)
        return true
    end

    return false
end

local timeOuts = {}
function Nexus.JobCreator:IsTimedOut(ply)
    if timeOuts[ply] and CurTime() < timeOuts[ply] then
        Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Processing", ply), 3)
        return false
    end
    
    return timeOuts[ply]
end

function Nexus.JobCreator:Timeout(ply)
    timeOuts[ply] = CurTime() + 60
end

function Nexus.JobCreator:Untimeout(ply)
    timeOuts[ply] = false
end

function Nexus.JobCreator:ConstructClientToServerJob(onSuccess, onError, ply)
    local data = {
        Name = net.ReadString(),
        Description = net.ReadString(),
        Color = net.ReadColor(),
        Health = math.Clamp(net.ReadUInt(12), 0, Nexus:GetValue("nexus-jobcreator-max-health")),
        Armor = math.Clamp(net.ReadUInt(12), 0, Nexus:GetValue("nexus-jobcreator-max-armor")),
        Salary = math.Clamp(net.ReadUInt(12), 0, Nexus:GetValue("nexus-jobcreator-max-salary")),
        GunLicense = net.ReadBool(),

        ImportedModels = {},
        SteamModels = {},
        SelectedGuns = {},
        Players = {},
    }

    if net.ReadBool() then
        local modelID = net.ReadUInt(32)
        local count = net.ReadUInt(10)

        data.ImportedModels.ModelID = modelID
        data.ImportedModels.Models = {}

        for i = 1, count do
            local modelPath = net.ReadString()
            local bodygroupCount = net.ReadUInt(10)
            data.ImportedModels.Models[modelPath] = {}

            for i = 1, bodygroupCount do
                local bodygroup = net.ReadUInt(10)
                local value = net.ReadUInt(10)

                data.ImportedModels.Models[modelPath][bodygroup] = value
            end
        end
    end

    // local models
    local localModelsCache = {}
    for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-localModels")) do
        localModelsCache[v.m_id] = v
    end

    local count = net.ReadUInt(10)
    for i = 1, count do
        local m_id = net.ReadUInt(15)
        if not localModelsCache[m_id] then
            local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
            str = string.format(str, Nexus.JobCreator:GetPhrase("Local Models", ply))
            onError(str)
            return
        end

        data.SteamModels[m_id] = true
    end

    // selected guns
    local localGunsCache = {}
    for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-guns")) do
        localGunsCache[v.m_id] = v
    end

    count = net.ReadUInt(10)
    for i = 1, count do
        local m_id = net.ReadUInt(15)
        if not localGunsCache[m_id] then
            local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
            str = string.format(str, Nexus.JobCreator:GetPhrase("Guns", ply))
            onError(str)
            return
        end

        data.SelectedGuns[m_id] = true
    end

    // players
    count = net.ReadUInt(10)
    for i = 1, count do
        local steamid64 = net.ReadString()
        if count > Nexus:GetValue("nexus-jobcreator-max-players") then
            onError(Nexus.JobCreator:GetPhrase("Too many players", ply))
            return
        end
        data.Players[steamid64] = true
    end

    if Nexus:GetValue("nexus-jobcreator-useWorkshopModels") == 0 and Nexus:GetValue("nexus-jobcreator-useLocalModels") == 1 then
        // if we can only use local models
        onSuccess(data)
        return
    end

    http.Post("https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/", {
        ["itemcount"] = "1",
        ["publishedfileids[0]"] = tostring(data.ImportedModels.ModelID),
    }, function(body, size, headers, code)
        local tbl = util.JSONToTable(body)
        if not tbl or not tbl.response or not tbl.response.publishedfiledetails or not tbl.response.publishedfiledetails[1] or not tbl.response.publishedfiledetails[1].file_size then
            if (Nexus:GetValue("nexus-jobcreator-useWorkshopModels") == 1 and Nexus:GetValue("nexus-jobcreator-useLocalModels") == 0) then
                // if we can only use workshop models then throw an error
                local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
                str = string.format(str, Nexus.JobCreator:GetPhrase("Steamworkshop Model", ply))
                onError(str)
                return
            else
                // we potentially may have data in local models list
                onSuccess(data)
                return
            end
        end

        local size = tbl.response.publishedfiledetails[1].file_size
        size = math.Round(size / 1024 / 1024, 3)

        if size > Nexus:GetValue("nexus-jobcreator-maxMB") then
            local str = Nexus.JobCreator:GetPhrase("Maximum MB", ply)
            str = string.format(str, Nexus:GetValue("nexus-jobcreator-maxMB").."MB")
            onError(str)
            return
        end

        data.ImportedModels.Size = size
        onSuccess(data)
    end, function(err)
        local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
        str = string.format(str, Nexus.JobCreator:GetPhrase("Steamworkshop Model", ply))
        onError(str)
    end)
end

function Nexus.JobCreator:ValidateData(data)
    if string.len(data.Name) < 3 or string.len(data.Name) > Nexus:GetValue("nexus-jobcreator-max-nameLength") then
        local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
        str = string.format(str, Nexus.JobCreator:GetPhrase("Name", ply))
        return false, str
    end

    if string.len(data.Description) > Nexus:GetValue("nexus-jobcreator-max-descriptionLength") then
        local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
        str = string.format(str, Nexus.JobCreator:GetPhrase("Description", ply))
        return false, str
    end

    if data.Health > Nexus:GetValue("nexus-jobcreator-max-health") then
        local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
        str = string.format(str, Nexus.JobCreator:GetPhrase("Extra Health", ply))
        return false, str
    end

    if data.Armor > Nexus:GetValue("nexus-jobcreator-max-armor") then
        local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
        str = string.format(str, Nexus.JobCreator:GetPhrase("Extra Armor", ply))
        return false, str
    end

    if data.Salary > Nexus:GetValue("nexus-jobcreator-max-salary") then
        local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
        str = string.format(str, Nexus.JobCreator:GetPhrase("Extra Salary", ply))
        return false, str
    end

    if Nexus:GetValue("nexus-jobcreator-useWorkshopModels") == 1 and Nexus:GetValue("nexus-jobcreator-useLocalModels") == 0 then
        // if we can only use workshop models
        if not data.ImportedModels or not data.ImportedModels.Models or table.Count(data.ImportedModels.Models) < 1 then
            local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
            str = string.format(str, Nexus.JobCreator:GetPhrase("Steamworkshop Model", ply))
            return false, str
        end
    elseif Nexus:GetValue("nexus-jobcreator-useWorkshopModels") == 0 and Nexus:GetValue("nexus-jobcreator-useLocalModels") == 1 then
        // if we can only use local models
        if table.Count(data.SteamModels) < 1 then
            local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
            str = string.format(str, Nexus.JobCreator:GetPhrase("Local Model", ply))
            return false, str
        end
    elseif (table.Count(data.SteamModels) < 1) and (not data.ImportedModels or not data.ImportedModels.Models or table.Count(data.ImportedModels.Models) < 1) then
        // if we can use both and we have no models supplied
        local str = Nexus.JobCreator:GetPhrase("Invalid %", ply)
        str = string.format(str, Nexus.JobCreator:GetPhrase("Models", ply))
        return false, str
    end

    // all guns, models ect get validated in the constructClient->Server
    return true, ""
end

function Nexus.JobCreator:ConstructJobFromSQL(jobID, callback)
    Nexus.JobCreator:Query("SELECT * FROM nexus_jobcreator_jobs WHERE id = "..jobID..";", function(jobs)
        if not jobs then return end
        jobs = jobs[1]
        Nexus.JobCreator:Query("SELECT * FROM nexus_jobcreator_friends WHERE jobID = "..jobID..";", function(friends)
            local players = {}
            for _, v in ipairs(friends or {}) do
                players[v.steamid64] = v
            end

            local col = util.JSONToTable(jobs.color)
            col = Color(col.r, col.g, col.b, col.a)

            local formatDATA = util.JSONToTable(jobs.models)

            local localModelsCache = {}
            for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-localModels")) do
                localModelsCache[v.m_id] = v
            end

            local localModels = {}
            for modelID, bool in pairs(formatDATA.localModels or {}) do
                if not bool or not localModelsCache[modelID] then continue end
                localModels[modelID] = true
            end

            local localGunsCache = {}
            for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-guns")) do
                localGunsCache[v.m_id] = v
            end

            local localGuns = {}
            for gunID, bool in pairs(util.JSONToTable(jobs.guns) or {}) do
                if not bool or not localGunsCache[gunID] then continue end
                localGuns[gunID] = true
            end

            local data = {
                ["id"] = jobID,
                ["Owner"] = jobs.owner,
                ["Name"] = jobs.name,
                ["Health"] = tonumber(jobs.extraHealth),
                ["Armor"] = tonumber(jobs.extraArmor),
                ["Salary"] = tonumber(jobs.extraSalary),
                ["Color"] = col,
                ["Description"] = jobs.description,
                ["GunLicense"] = tonumber(jobs.gunLicense) == 1 and true or false,
                ["ImportedModels"] = (formatDATA.workshop or {}),
                ["SteamModels"] = (localModels),
                ["Players"] = players,
                ["SelectedGuns"] = localGuns,
                ["Verified"] = tonumber(jobs.verified) == 1,
                ["Disabled"] = tonumber(jobs.disabled) == 1,
            }

            callback(data)
        end)
    end)
end

util.AddNetworkString("Nexus:JobCreator:PurchaseJob")
net.Receive("Nexus:JobCreator:PurchaseJob", function(len, ply)
    if Nexus.JobCreator:IsTimedOut(ply) then
        return
    end

    Nexus.JobCreator:Timeout(ply)

    Nexus.JobCreator:ConstructClientToServerJob(function(data)
        if not IsValid(ply) then return end

        Nexus.JobCreator:Untimeout(ply)

        local valid, message = Nexus.JobCreator:ValidateData(data)
        if not valid then
            Nexus.JobCreator:Notification(ply, message, 3)
            return
        end

        for _, v in pairs(team.GetAllTeams()) do
            if v.Name == data.Name then
                Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Bad Name", ply), 3)
                return
            end
        end

        Nexus.JobCreator:Timeout(ply)

        Nexus.JobCreator:Query("SELECT id FROM nexus_jobcreator_jobs WHERE owner = "..sql.SQLStr(ply:SteamID64())..";", function(tbl)            
            if not IsValid(ply) then return end

            Nexus.JobCreator:Untimeout(ply)

            if #(tbl or {}) >= Nexus:GetValue("nexus-jobcreator-max-ownedJobs") then                
                Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Created too many jobs", ply), 3)
                return
            end

            local finishedCount = 0
            local function finishedCheckPlayers()
                finishedCount = finishedCount + 1

                if finishedCount ~= table.Count(data.Players) and table.Count(data.Players) ~= 0 then
                    return
                end

                Nexus.JobCreator:Untimeout(ply)

                local price = Nexus.JobCreator:CalculatePrice(data)
                if not Nexus.JobCreator:CanAfford(ply, price) then
                    Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Not Afford", ply), 3)
                    return
                end

                Nexus.JobCreator:AddMoney(ply, -price)
                Nexus.JobCreator:CreateJob(ply:SteamID64(), data)
                Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Success", ply))
            end

            Nexus.JobCreator:Timeout(ply)

            finishedCheckPlayers()

            for steamid64, bool in pairs(data.Players) do
                Nexus.JobCreator:Query("SELECT id FROM nexus_jobcreator_friends WHERE steamid64 = "..sql.SQLStr(steamid64)..";", function(tbl)
                    if not IsValid(ply) then return end

                    if #(tbl or {}) >= Nexus:GetValue("nexus-jobcreator-max-sharedjobs") then
                        local str = Nexus.JobCreator:GetPhrase("Player cant join", ply)
                        str = string.format(str, steamid64)
                        Nexus.JobCreator:Notification(ply, str, 3)
                        return
                    end

                    finishedCheckPlayers()
                end)
            end
        end)
    end, function(err)
        Nexus.JobCreator:Untimeout(ply)

        Nexus.JobCreator:Notification(ply, err, 3)
    end, ply)
end)

util.AddNetworkString("Nexus:JobCreator:EditJob")
net.Receive("Nexus:JobCreator:EditJob", function(len, ply)
    local editID = net.ReadUInt(32)

    if Nexus:GetValue("nexus-jobcreator-canEdit") ~= "Yes" then
        return
    end

    if Nexus.JobCreator:IsTimedOut(ply) then
        return
    end

    if Nexus.JobCreator:HasCooldown(ply) then
        return
    end

    Nexus.JobCreator:Timeout(ply)

    Nexus.JobCreator:ConstructClientToServerJob(function(data)
        if not IsValid(ply) then return end

        Nexus.JobCreator:Untimeout(ply)

        local valid, message = Nexus.JobCreator:ValidateData(data)
        if not valid then
            Nexus.JobCreator:Notification(ply, message, 3)
            return
        end

        Nexus.JobCreator:Timeout(ply)

        Nexus.JobCreator:Query("SELECT owner, name, disabled FROM nexus_jobcreator_jobs WHERE id = "..editID..";", function(tbl)            
            if not IsValid(ply) then return end

            Nexus.JobCreator:Untimeout(ply)

            if #(tbl or {}) == 0 then Nexus.JobCreator:Notification(ply, ("ERROR"), 3) return end

            local adminEdit = false
            if Nexus:GetValue("nexus-jobcreator-admins")[ply:GetUserGroup()] and tbl[1].owner ~= ply:SteamID64() then
                adminEdit = true
            end

            if not adminEdit and tonumber(tbl[1].disabled) == 1 then
                Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Job Disabled", ply), 3)
                return
            end

            if #(tbl or {}) == 0 or tbl[1].owner ~= ply:SteamID64() and not adminEdit then
                Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Not Owner", ply), 3)
                return
            end

            for int, v in pairs(team.GetAllTeams()) do
                if (v.Name == data.Name) and data.Name ~= tbl[1].name then
                    Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Bad Name", ply), 3)
                    return
                end
            end

            local finishedCount = 0
            local function finishedCheckPlayers()
                finishedCount = finishedCount + 1

                if finishedCount ~= table.Count(data.Players) and table.Count(data.Players) ~= 0 then
                    return
                end

                Nexus.JobCreator:ConstructJobFromSQL(editID, function(oldJobData)
                    if not IsValid(ply) then return end

                    Nexus.JobCreator:Untimeout(ply)

                    if not oldJobData then return end
                    local oldPrice = Nexus.JobCreator:CalculatePrice(oldJobData)
                    local price = Nexus.JobCreator:CalculatePrice(data) - oldPrice

                    if adminEdit then
                        price = 0
                    end

                    if price < 0 and Nexus:GetValue("nexus-jobcreator-canRefund") ~= "Yes" then
                        price = 0
                    end
    
                    if price > 0 and not Nexus.JobCreator:CanAfford(ply, price) then
                        Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Not Afford", ply), 3)
                        return
                    end
    
                    if not adminEdit then
                        Nexus.JobCreator:AddCooldown(ply)
                    end

                    Nexus.JobCreator:Query("DELETE FROM nexus_jobcreator_friends WHERE jobID = "..editID..";")
                    Nexus.JobCreator:AddMoney(ply, -price)
                    Nexus.JobCreator:EditJob(editID, data)

                    Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Edited Job", ply).." "..(price<0 and Nexus.JobCreator:GetPhrase("Refund of", ply).." " or "")..Nexus.JobCreator:FormatPrice(math.abs(price)))
                end)
            end

            Nexus.JobCreator:Timeout(ply)

            finishedCheckPlayers()

            for steamid64, bool in pairs(data.Players) do
                Nexus.JobCreator:Query("SELECT id FROM nexus_jobcreator_friends WHERE steamid64 = "..sql.SQLStr(steamid64)..";", function(tbl)
                    if not IsValid(ply) then return end

                    if (#(tbl or {}))-1 >= Nexus:GetValue("nexus-jobcreator-max-sharedjobs") then
                        local str = Nexus.JobCreator:GetPhrase("Player cant join", ply)
                        str = string.format(str, steamid64)
                        Nexus.JobCreator:Notification(ply, str, 3)
                        return
                    end

                    finishedCheckPlayers()
                end)
            end
        end)
    end, function(err)
        Nexus.JobCreator:Untimeout(ply)

        Nexus.JobCreator:Notification(ply, err, 3)
    end, ply)
end)

util.AddNetworkString("Nexus:JobCreator:DeleteJob")
util.AddNetworkString("Nexus:JobCreator:JobDeleted")
net.Receive("Nexus:JobCreator:DeleteJob", function(len, ply)
    local jobID = net.ReadUInt(32)

    if Nexus.JobCreator:IsTimedOut(ply) then
        return
    end

    Nexus.JobCreator:Timeout(ply)

    Nexus.JobCreator:Query("SELECT * FROM nexus_jobcreator_jobs WHERE id = "..jobID..";", function(tbl)            
        if not IsValid(ply) then return end

        Nexus.JobCreator:Untimeout(ply)

        local adminEdit = false
        if Nexus:GetValue("nexus-jobcreator-admins")[ply:GetUserGroup()] and tbl[1].owner ~= ply:SteamID64() then
            adminEdit = true
        end

        if #(tbl or {}) == 0 or tbl[1].owner ~= ply:SteamID64() and not adminEdit then
            Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Not Owner", ply), 3)
            return
        end

        if Nexus:GetValue("nexus-jobcreator-canRefundDelete") == "Yes" then
            Nexus.JobCreator:Timeout(ply)

            Nexus.JobCreator:ConstructJobFromSQL(jobID, function(data)
                if not IsValid(ply) then return end

                Nexus.JobCreator:Untimeout(ply)

                if not data then Nexus.JobCreator:Notification(ply, "ERROR") return end

                local refundamount = math.Clamp(Nexus:GetValue("nexus-jobcreator-refund%"), 0, 100)
                refundamount = Nexus.JobCreator:CalculatePrice(data)*(refundamount/100)
                if not adminEdit then Nexus.JobCreator:AddMoney(ply, refundamount) end
                Nexus.JobCreator:Notification(ply, adminEdit and Nexus.JobCreator:GetPhrase("Success", ply) or Nexus.JobCreator:GetPhrase("Success", ply).." "..Nexus.JobCreator:GetPhrase("Refund of", ply).." "..Nexus.JobCreator:FormatPrice(refundamount))
                Nexus.JobCreator:DeleteJob(jobID)
            end)
        else
            Nexus.JobCreator:DeleteJob(jobID)
            Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Success", ply))
        end
    end)
end)

util.AddNetworkString("Nexus:JobCreator:LeaveJob")
util.AddNetworkString("Nexus:JobCreator:PlayerRemoved")
net.Receive("Nexus:JobCreator:LeaveJob", function(len, ply)
    local id = net.ReadUInt(32)

    if Nexus.JobCreator:IsTimedOut(ply) then
        return
    end

    Nexus.JobCreator:Timeout(ply)

    Nexus.JobCreator:Query("SELECT id FROM nexus_jobcreator_friends WHERE steamid64 = "..ply:SteamID64().." AND jobID = "..id..";", function(data)
        if not IsValid(ply) then return end

        Nexus.JobCreator:Untimeout(ply)

        if #(data or {}) == 0 then return end
        Nexus.JobCreator:Query("DELETE FROM nexus_jobcreator_friends WHERE steamid64 = "..ply:SteamID64().." AND jobID = "..id..";")

        net.Start("Nexus:JobCreator:PlayerRemoved")
        net.WriteString(ply:SteamID64())
        net.WriteUInt(id, 32)
        net.Broadcast()

        Nexus.JobCreator:KickOffJob(id, ply)

        Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Success", ply))

        Nexus.JobCreator.ActiveJobs[id].Players[ply:SteamID64()] = nil
    end)
end)

hook.Add("Nexus:FullyLoaded", "Nexus:Loaded:JobCreator", function(ply)
    Nexus.JobCreator:Query("SELECT id FROM nexus_jobcreator_jobs;", function(jobs)
        if not IsValid(ply) then return end
        if #(jobs or {}) == 0 then return end

        for _, v in ipairs(jobs) do
            Nexus.JobCreator:NetworkJob(v.id, ply)
        end
    end)

    local models = {}
    for _, v in ipairs(player.GetAll()) do
        local jobInt = RPExtraTeams[v:Team()] and RPExtraTeams[v:Team()].customJob or false
        if not jobInt then continue end

        local data = Nexus.JobCreator.ActiveJobs[jobInt]

        if not data then continue end

        if data.ImportedModels.ModelID then
            table.insert(models, data.ImportedModels.ModelID)
        end
    end

    if #models == 0 then return end

    net.Start("Nexus:JobCreator:DownloadModel")
    net.WriteBool(true)
    net.WriteUInt(#models, 10)
    for _, v in ipairs(models) do
        net.WriteString(v)
    end
    net.Send(ply)
end)

Nexus.JobCreator.ActiveJobs = Nexus.JobCreator.ActiveJobs or {}
local loaded = false
local function load()
    if loaded then return end
    loaded = true
    Nexus.JobCreator:Query("SELECT id FROM nexus_jobcreator_jobs;", function(jobs)
        if #(jobs or {}) == 0 then return end

        for _, v in ipairs(jobs) do
            Nexus.JobCreator:ConstructJobFromSQL(v.id, function(data)
                if not data then return end
                Nexus.JobCreator:LoadF4Job(data)
            end)
        end
    end)

    timer.Remove("Nexus:JobCreator:LoadF4")
end

timer.Create("Nexus:JobCreator:LoadF4", 0, 0, function()
    if DarkRP and Nexus and Nexus.JobCreator and not Nexus.JobCreator.F4Loaded then
        Nexus.JobCreator.F4Loaded = true
        load()
    end
end)

util.AddNetworkString("Nexus:JobCreator:EnableDisableJob")
net.Receive("Nexus:JobCreator:EnableDisableJob", function(len, ply)
    local id = net.ReadUInt(32)
    local shouldEnable = net.ReadBool()

    if Nexus.JobCreator:IsTimedOut(ply) then
        return
    end

    Nexus.JobCreator:Timeout(ply)

    if not Nexus:GetValue("nexus-jobcreator-admins")[ply:GetUserGroup()] then
        Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Incorrect Usergroup", ply))
        return
    end

    Nexus.JobCreator:Query("UPDATE nexus_jobcreator_jobs SET disabled = "..(shouldEnable and 0 or 1).." WHERE id = "..id..";")
    Nexus.JobCreator:ConstructJobFromSQL(id, function(data)
        Nexus.JobCreator:EditJob(id, data, true)

        if not IsValid(ply) then return end
        Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Success", ply))
    
        Nexus.JobCreator:Untimeout(ply)
    end)
end)

util.AddNetworkString("Nexus:JobCreator:DownloadModel")
hook.Add("PlayerChangedTeam", "PrintOldAndNewTeam", function(ply, oldTeam, newTeam) 
    local data = RPExtraTeams[newTeam] and RPExtraTeams[newTeam].customJob or false
    if not data then return end

    data = Nexus.JobCreator.ActiveJobs[data]

    if not data then return end

    if data.ImportedModels.ModelID then
        net.Start("Nexus:JobCreator:DownloadModel")
        net.WriteBool(false)
        net.WriteString(data.ImportedModels.ModelID)
        net.Broadcast()
    end
end)