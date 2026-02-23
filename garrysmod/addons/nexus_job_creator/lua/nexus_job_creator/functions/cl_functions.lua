function Nexus.JobCreator:OpenMenu()
    if IsValid(self.Frame) then self.Frame:Remove() end
    if IsValid(self.PagesMain) then self.PagesMain:Remove() end
    self.Frame = vgui.Create("Nexus:JobCreator:Menu")
    self.Frame:SetSize(ScrW(), ScrH())
    self.Frame:MakePopup()
end

concommand.Add("job_creator", function()
    Nexus.JobCreator:OpenMenu()
end)

function Nexus.JobCreator:OpenPageMenu(data)
    if IsValid(self.Frame) then self.Frame:Remove() end
    if IsValid(self.PagesMain) then self.PagesMain:Remove() end

    self.PagesMain = vgui.Create("Nexus:JobCreator:Pages:Main")
    self.PagesMain:SetSize(ScrW(), ScrH())
    self.PagesMain:MakePopup()
    if data then
        self.PagesMain:SetMasterData(data)
    end
end

function Nexus.JobCreator:OpenAdminPage()
    if IsValid(self.Frame) then self.Frame:Remove() end
    if IsValid(self.PagesMain) then self.PagesMain:Remove() end
    if IsValid(self.AdminPage) then self.AdminPage:Remove() end
    self.AdminPage = vgui.Create("Nexus:JobCreator:Authenticate")
    self.AdminPage:SetSize(ScrW(), ScrH())
    self.AdminPage:MakePopup()
end

function Nexus.JobCreator:CreateNotification(str, length)
    surface.PlaySound("buttons/button14.wav")

    Nexus.JobCreator.Notification = {
        Text = str,
        EndTime = CurTime() + length,
        Length = length,
    }

    notification.AddLegacy(str, NOTIFY_HINT, length)
end

net.Receive("Nexus:JobCreator:Notification", function()
    Nexus.JobCreator:CreateNotification(net.ReadString(), net.ReadUInt(6))
end)

net.Receive("Nexus:JobCreator:JobDeleted", function()
    local id = net.ReadUInt(32)
    hook.Run("Nexus:JobCreator:JobDeleted", Nexus.JobCreator.ActiveJobs[tonumber(id)])

    Nexus.JobCreator.ActiveJobs[tonumber(id)] = nil
    DarkRP.removeJob(Nexus.JobCreator.JobCache[tonumber(id)])
    Nexus.JobCreator.JobCache[tonumber(id)] = nil
end)

net.Receive("Nexus:JobCreator:PlayerRemoved", function()
    local steamid = net.ReadString()
    local id = net.ReadUInt(32)

    Nexus.JobCreator.ActiveJobs[id].Players[steamid] = nil
end)

Nexus.JobCreator.Mounted = Nexus.JobCreator.Mounted or {}
function Nexus.JobCreator:MountModel(id, callback, forceRefresh)
    callback = callback or function() end
    if Nexus.JobCreator.Mounted[id] and not forceRefresh then callback(true, Nexus.JobCreator.Mounted[id]) return end

    steamworks.DownloadUGC(id, function(path, fileHandle)
        if not path or not fileHandle then
            callback(false, Nexus.JobCreator:GetPhrase("Model Download Error"))
            return
        end

        local bool, files = game.MountGMA(path)
        if not bool then
            callback(false, Nexus.JobCreator:GetPhrase("Model Download Error"))
            return
        end

        local models = {}
        for _, v in ipairs(files) do
            if (!v:find(".lua")) then continue end

            local contents = file.Read(v, "GAME")
            for name, path in string.gmatch(contents, "player_manager%.AddValidModel%(%s*[\"'](.-)[\"']%s*,%s*[\"'](%g-)[\"']%s*%g*%)") do
                table.Add(models, {{model = path, enabled = true, bodygroups = {}}})
            end
        end

        if table.Count(models) == 0 then
            callback(false, Nexus.JobCreator:GetPhrase("Model Download Error"))
            return
        end

        steamworks.FileInfo(id, function(result)
            if not result or result.error or result.disabled or result.banned then
                callback(false, Nexus.JobCreator:GetPhrase("Model Download Error"))
                return
            end

            if models == 0 then
                callback(false, Nexus.JobCreator:GetPhrase("Model Download Error"))
                return
            end

            local size = math.Round(result.size / 1024 / 1024, 3)
            Nexus.JobCreator.Mounted[id] = {
                Models = models,
                Size = size,
                Title = result.title,
            }

            callback(true, Nexus.JobCreator.Mounted[id])
        end)
    end)
end

Nexus.JobCreator.PlayerCache = Nexus.JobCreator.PlayerCache or {}
function Nexus.JobCreator:GetName(steamid64, callback)
    callback = callback or function() end

    if Nexus.JobCreator.PlayerCache[steamid64] then
        return callback(Nexus.JobCreator.PlayerCache[steamid64])
    end

    steamworks.RequestPlayerInfo(steamid64, function(steamName)
        Nexus.JobCreator.PlayerCache[steamid64] = steamName

        callback(steamName)
    end)
end

function Nexus.JobCreator:ConstructServerToClientJob()
    local data = {
        id = net.ReadUInt(32),
        Owner = net.ReadString(),

        Disabled = net.ReadBool(),
        Verified = net.ReadBool(),

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
        local size = net.ReadFloat()
        data.ImportedModels.ModelID = modelID
        data.ImportedModels.Models = {}
        data.ImportedModels.Size = size

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
        if not localModelsCache[m_id] then continue end

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
        if not localGunsCache[m_id] then continue end

        data.SelectedGuns[m_id] = true
    end

    // players
    count = net.ReadUInt(10)
    for i = 1, count do
        local steamid64 = net.ReadString()
        data.Players[steamid64] = true
    end

    return data
end

Nexus.JobCreator.ActiveJobs = Nexus.JobCreator.ActiveJobs or {}
net.Receive("Nexus:JobCreator:NetworkJob", function()
    local darkrpJobID = net.ReadUInt(12)
    local command = net.ReadString()
    local data = Nexus.JobCreator:ConstructServerToClientJob()

    Nexus.JobCreator:LoadF4Job(data, {darkrpJobID, command})

    if data.Owner == LocalPlayer():SteamID64() and (IsValid(Nexus.JobCreator.Frame) or IsValid(Nexus.JobCreator.PagesMain)) then
        Nexus.JobCreator:OpenMenu()
    end
end)

net.Receive("Nexus:JobCreator:DownloadModel", function()
    local bool = net.ReadBool()
    local count = 1
    if bool then
        count = net.ReadUInt(10)
    end
    for i = 1, count do
        local id = net.ReadString()
        Nexus.JobCreator:MountModel(id, function(success, jobData)
            if not success then
                return
            end
        end)
    end
end)

net.Receive("Nexus:JobCreator:NetworkCredits", function()
    local amount = net.ReadUInt(32)
    LocalPlayer().JobCredits = amount
end)