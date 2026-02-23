local panelInt = 1
local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin()

    self.backgroundCol = Color(29, 35, 47)
    self.backgroundCol.a = 200
    self:SetColor(self.backgroundCol)

    self.gradientCol = Color(29, 35, 47)
    self.gradientCol.a = 80

    self.ModelPanel = self:Add("DModelPanel")
    self.ModelPanel:Dock(FILL)

    self.Overlay = self:Add("DButton")
    self.Overlay:Dock(FILL)
    self.Overlay:SetText("")
    self.Overlay.Paint = nil

    self.IsHovered = function(s)
        return self.Overlay:IsHovered()
    end

    self.Overlay.DoClick = function(s)
        self:DoClick()
        if self.Shared then
            if not self.id then return end

            local menu = DermaMenu()
            menu:AddOption(Nexus.JobCreator:GetPhrase("Leave Job"), function()
                net.Start("Nexus:JobCreator:LeaveJob")
                net.WriteUInt(self.id, 32)
                net.SendToServer()

                self.data = nil
                self.id = nil
                self.Models = nil
                self.ModelPanel:SetModel("")
                self.ModelPanel.PaintOver = nil
            end)

            menu:Open()
            return
        end

        if self.Admin then
            if not self.id then return end

            local menu = DermaMenu()
            menu:AddOption(Nexus.JobCreator:GetPhrase("Validate"), function()
                local function success(data)
                    net.Start("Nexus:JobCreator:ValidateJob")
                    net.WriteUInt(self.id, 32)
                    net.WriteUInt(table.Count(data), 12)
                    for model, bool in pairs(data) do
                        net.WriteString(model)
                    end
                    net.SendToServer()
                end

                if not self.data.ImportedModels.ModelID then
                    success({})
                    return
                end

                Nexus.JobCreator:MountModel(self.data.ImportedModels.ModelID, function(successBool, data)
                    if not successBool then
                        Nexus.JobCreator:CreateNotification(Nexus.JobCreator:GetPhrase("Failed Validation"), 3)
                        return
                    end

                    local models = {}
                    for _, v in ipairs(data.Models) do
                        models[v.model] = true
                    end

                    success(models)
                end, true)
            end)

            menu:AddOption(Nexus.JobCreator:GetPhrase("Edit"), function()
                local data = table.Copy(self.data)
                if self.id then
                    if not Nexus.JobCreator.ActiveJobs[self.id] then return end
                    data.InitialData = table.Copy(data)
                    data.IsAdmin = true
                end
        
                Nexus.JobCreator:OpenPageMenu(data)
            end)

            menu:AddOption(Nexus.JobCreator.ActiveJobs[self.id].Disabled and Nexus.JobCreator:GetPhrase("Enable") or Nexus.JobCreator:GetPhrase("Disable"), function()
                net.Start("Nexus:JobCreator:EnableDisableJob")
                net.WriteUInt(self.id, 32)
                net.WriteBool(Nexus.JobCreator.ActiveJobs[self.id].Disabled and true or false)
                net.SendToServer()
            end)

            menu:Open()
            return
        end

        local data = table.Copy(self.data)
        if self.id then
            if not Nexus.JobCreator.ActiveJobs[self.id] then return end
            data.InitialData = table.Copy(data)
        end

        Nexus.JobCreator:OpenPageMenu(data)
    end

    self:SetText("")

    self.PanelInt = panelInt
    hook.Add("Nexus:JobCreator:JobDeleted", "Nexus:JobCreator:JobDeleted:"..panelInt, function(data)
        if data.id == self.id then
            self.data = nil
            self.id = nil
            self.Models = nil
            self.ModelPanel:SetModel("")
            self.ModelPanel.PaintOver = nil
        end
    end)

    panelInt = panelInt + 1
end

function PANEL:OnRemove()
    hook.Remove("Nexus:JobCreator:JobDeleted", "Nexus:JobCreator:JobDeleted:"..self.PanelInt)
end

function PANEL:SetID(id)
    if not id or not Nexus.JobCreator.ActiveJobs[id] then return end

    self.data = Nexus.JobCreator.ActiveJobs[id]
    self.id = id
    local data = Nexus.JobCreator.ActiveJobs[id]
    self.Models = {}
    if data.ImportedModels.ModelID then
        Nexus.JobCreator:MountModel(data.ImportedModels.ModelID, function(success, jobData)
            if not success then
                print("FAILED TO DOWNLOAD MODEL", data.ImportedModels.ModelID)
                return
            end
        end)

        for model, bodygroups in pairs(data.ImportedModels.Models) do
            table.Add(self.Models, {{model = model, bodygroups = bodygroups}})
        end
    end

    local localModelsCache = {}
    for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-localModels")) do
        localModelsCache[v.m_id] = v
    end

    for k, _ in pairs(data.SteamModels) do
        local model = k
        
        table.Add(self.Models, {{model = localModelsCache[model].Model, bodygroups = {}}})
    end

    self:SetModel(self.Models[1])
end

function PANEL:SetShared(bool)
    self.Shared = bool
end

function PANEL:Think()
    self.Timer = self.Timer or CurTime() + 1
    self.CurInt = self.CurInt or 1

    if self.id and CurTime() > self.Timer then
        self.CurInt = self.CurInt + 1
        self.Timer = CurTime() + 1

        if not self.Models[self.CurInt] then
            self.CurInt = 1
        end

        self:SetModel(self.Models[self.CurInt])
    end
end

local disabledOverlay = Color(200, 200, 200, 30)
function PANEL:SetModel(data)
    if not data or not data.model then return end
    self.ModelPanel:SetModel(data.model)

    local min, max = self.ModelPanel.Entity:GetRenderBounds()

    local size = 0
    size = math.max(size, math.abs(min.x) + math.abs(max.x))
    size = math.max(size, math.abs(min.y) + math.abs(max.y))
    size = math.max(size, math.abs(min.z) + math.abs(max.z))

    self.ModelPanel.Entity:SetAngles(Angle(-8, 45, 0))
    self.ModelPanel:SetCamPos(Vector(size, size, size))
    self.ModelPanel:SetLookAt((min + max) * 0.5)

    self.ModelPanel:SetFOV(30)
    self.ModelPanel.LayoutEntity = function() end
    self.ModelPanel.PaintOver = function(s, w, h)
        draw.SimpleText(self.data.Name, self.Admin and Nexus:GetFont(20) or Nexus:GetFont(35), w/2, self.Admin and h - self.margin or self.margin*2, Nexus:GetColor("primary-text"), 1, self.Admin and TEXT_ALIGN_BOTTOM or 0)
        if self.Overlay:IsHovered() then
            local size = Nexus:Scale(64)
            Nexus:DrawImgur("https://imgur.com/4sQhTbT", (w/2) - (size/2), self.Admin and (h/2) - (size/2) or (h - self.margin - size), size, size)
        end

        if self.id and Nexus.JobCreator.ActiveJobs[self.id].Disabled then
            draw.RoundedBox(self.margin, 0, 0, w, h, disabledOverlay)

            local size = Nexus:Scale(150)
            Nexus:DrawImgur("https://imgur.com/ZIWjfQm", (w/2) - (size/2), (h/2) - (size)/2, size, size)
        end
    end

    for bodygroup, val in pairs(data.bodygroups) do
        self.ModelPanel.Entity:SetBodygroup(tonumber(bodygroup), tonumber(val))
    end
end

function PANEL:SetAdmin(bool)
    self.Admin = true
    self.backgroundCol = Color(17, 19, 24)
    self.backgroundCol.a = 200
end

function PANEL:PaintOver(w, h)
    local isHovered = self.Overlay:IsHovered()
    if self.Admin and self.id then
        local verified = Nexus.JobCreator.ActiveJobs[self.id].Verified

        local size = Nexus:Scale(30)
        Nexus:DrawImgur(verified and "https://imgur.com/Tm13QHz" or "https://imgur.com/Uk7Me3Q", w - self.margin - size, self.margin, size, size, verified and Nexus:GetColor("green") or Nexus:GetColor("red"))
        return
    end

    if self.id or self.Shared then return end
    local size = math.min(w, h) * .1

    Nexus:DrawImgur("https://imgur.com/r2qBBJf", (w/2) - (size/2), (h/2) - (size/2), size, size, isHovered and Nexus:OffsetColor(color_white, 40) or color_white)
end
vgui.Register("Nexus:JobCreator:JobPanel", PANEL, "Nexus:V2:Button")