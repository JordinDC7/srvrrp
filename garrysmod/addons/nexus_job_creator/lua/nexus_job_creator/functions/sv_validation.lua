util.AddNetworkString("Nexus:JobCreator:ValidateJob")
net.Receive("Nexus:JobCreator:ValidateJob", function(len, ply)
    local id = net.ReadUInt(32)
    local count = net.ReadUInt(12)

    if not Nexus:GetValue("nexus-jobcreator-admins")[ply:GetUserGroup()] then
        Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Incorrect Usergroup", ply))
        return
    end

    if Nexus.JobCreator:IsTimedOut(ply) then
        return
    end

    local models = {}
    for i = 1, count do
        local modelStr = net.ReadString()
        models[modelStr] = true
    end

    Nexus.JobCreator:Timeout(ply)

    Nexus.JobCreator:ConstructJobFromSQL(id, function(data)
        if not IsValid(ply) then return end

        Nexus.JobCreator:Untimeout(ply)

        if not data then Nexus.JobCreator:Notification(ply, "ERROR") return end

        local function onSuccess(data)
            if not IsValid(ply) then return end
            Nexus.JobCreator:Untimeout(ply)
            Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Success", ply))

            Nexus.JobCreator:Query("UPDATE nexus_jobcreator_jobs SET verified = 1 WHERE id = "..data.id..";")
            data.Verified = true
            Nexus.JobCreator:EditJob(id, data, true)
        end

        local function onError()
            if not IsValid(ply) then return end
            Nexus.JobCreator:Untimeout(ply)
            Nexus.JobCreator:Notification(ply, "ERROR")
        end

        if not data.ImportedModels or not data.ImportedModels.ModelID then
            onSuccess(data)
            return
        end

        http.Post("https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/", {
            ["itemcount"] = "1",
            ["publishedfileids[0]"] = tostring(data.ImportedModels.ModelID),
        }, function(body, size, headers, code)
            if not IsValid(ply) then return end

            local tbl = util.JSONToTable(body)
            if not tbl or not tbl.response or not tbl.response.publishedfiledetails or not tbl.response.publishedfiledetails[1] or not tbl.response.publishedfiledetails[1].file_size then
                onError()
                return
            end
    
            local size = tbl.response.publishedfiledetails[1].file_size
            size = math.Round(size / 1024 / 1024, 3)

            if math.Round(data.ImportedModels.Size, 3) ~= size then
                Nexus.JobCreator:Notification(ply, Nexus.JobCreator:GetPhrase("Cannot validate", ply))
                Nexus.JobCreator:Untimeout(ply)
                return
            end

            for model, _ in pairs(data.ImportedModels.Models) do
                if not models[model] then
                    data.ImportedModels.Models[model] = nil
                end
            end

            for model, _ in pairs(models) do
                if not data.ImportedModels.Models[model] then
                    data.ImportedModels.Models[model] = {}
                end
            end

            onSuccess(data)
        end, function(err)
            onError()
        end)
    end)
end)