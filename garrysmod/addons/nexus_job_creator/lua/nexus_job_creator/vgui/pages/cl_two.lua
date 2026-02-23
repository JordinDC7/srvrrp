local overlay = Color(0, 0, 0, 100)

local backgroundCol = Color(78, 85, 100)
backgroundCol.a = 200

local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin()
    self.Panels = {}

    self:CreateLoader()
end

function PANEL:SetData(data)
    self.Data = data
end

function PANEL:RefreshContent()
    for _, v in ipairs(self.Panels) do
        v:Remove()
    end
end

function PANEL:CreateImport()
    self:RefreshContent()

    self.ImportPage = self:Add("DPanel")
    self.ImportPage.Fill = true
    self.ImportPage.Paint = nil
    self.ImportPage.Panels = {}
    table.insert(self.Panels, self.ImportPage)

    self.BackButton = self:Add("DButton")
    self.BackButton:SetWide(Nexus:Scale(75))
    self.BackButton:SetText("<")
    self.BackButton:SetTextColor(Nexus:GetTextColor(backgroundCol))
    self.BackButton:SetFont(Nexus:GetFont(35))
    self.BackButton.BackButton = true
    self.BackButton.Paint = function(s, w, h)
        local isHovered = s:IsHovered()
        draw.RoundedBox(self.margin, 0, 0, w, h, s:IsHovered() and Nexus:OffsetColor(backgroundCol, 20) or backgroundCol)
    end
    self.BackButton.DoClick = function()
        self:CreateLoader()
    end
    table.insert(self.Panels, self.BackButton)

    self.Header = self.ImportPage:Add("Panel")
    self.Header:Dock(TOP)
    self.Header:SetTall(Nexus:Scale(50))

    self.Header.TextEntry = self.Header:Add("Nexus:V2:TextEntry")
    self.Header.TextEntry:Dock(FILL)
    self.Header.TextEntry:SetPlaceholder(Nexus.JobCreator:GetPhrase("Steamworkshop Model"))

    self.Header.Import = self.Header:Add("Nexus:V2:Button")
    self.Header.Import:Dock(RIGHT)
    self.Header.Import:DockMargin(self.margin, 0, 0, 0)
    self.Header.Import:SetWide(Nexus:Scale(100))
    self.Header.Import:SetText(Nexus.JobCreator:GetPhrase("Import"))
    self.Header.Import.DoClick = function(s)
        local prefix = "https://steamcommunity.com/sharedfiles/filedetails/?id="
        local id = self.Header.TextEntry:GetText()
        if string.Left(id, #prefix) == prefix then
            id = string.Right(id, #id - #prefix)
        end

        id = tonumber(id)

        if not id then
            Nexus.JobCreator:CreateNotification(Nexus.JobCreator:GetPhrase("Invalid ID"), 3)
            return
        end

        Nexus.JobCreator:MountModel(id, function(success, result)
            if not IsValid(self) then
                self.Data.ImportedModels.ModelID = nil
                return
            end

            if not success then
                Nexus.JobCreator:CreateNotification(result, 3)
                self.Data.ImportedModels.ModelID = nil
                return
            end

            for _, v in ipairs(self.ModelBackground.Panel.Panels) do
                v:Remove()
            end
            self.ModelBackground.Panel.Panels = {}

            for _, v in ipairs(self.ModelBackground.Bodygroups.Panels) do
                v:Remove()
            end

            local models = {}
            models = table.Copy(self.Data.ImportedModels.Models) or {}
            if self.Data.ImportedModels.ModelID ~= id then
                self.Data.ImportedModels.Models = {}
                self.Data.ImportedModels.ModelID = id
                self.Data.ImportedModels.Size = result.Size
                self.Data.ImportedModels.Title = result.Title
            end

            self.ModelBackground:SetModel(result.Models[1].model)

            for _, v in ipairs(result.Models) do
                models[v.model] = nil

                self.Data.ImportedModels.Models[v.model] = {}
                self.ModelBackground.Panel:AddModel(v.model)
            end

            for model, _ in pairs(models) do
                self.Data.ImportedModels.Models[model] = nil
            end
        end)
    end

    local str = "* "..Nexus.JobCreator:GetPhrase("$/MB").." "..Nexus.JobCreator:GetPhrase("Maximum Size MB")
    str = string.format(str, Nexus.JobCreator:FormatPrice(Nexus:GetValue("nexus-jobcreator-maxMB")), Nexus:GetValue("nexus-jobcreator-maxMB"))

    self.TextNote = self.ImportPage:Add("DLabel")
    self.TextNote:Dock(TOP)
    self.TextNote:SetText(str)
    self.TextNote:SizeToContents()
    self.TextNote:SetFont(Nexus:GetFont(20))

    self.ModelBackground = self.ImportPage:Add("Panel")
    self.ModelBackground:Dock(FILL)
    self.ModelBackground:DockMargin(0, self.margin, 0, 0)
    self.ModelBackground.SetModel = function(s, modelStr)
        self.ModelBackground.Bodygroups:SetWide(0)

        s.ModelPanel:SetModel(modelStr)

        local mn, mx = s.ModelPanel.Entity:GetRenderBounds()
        s.ModelPanel.Entity:SetAngles(Angle(-10, 45, 0))
    
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
    
        s.ModelPanel:SetFOV(25)
        s.ModelPanel:SetCamPos(Vector(size, size, size))
        s.ModelPanel:SetLookAt((mn + mx) * 0.5)

        self.Data.ImportedModels.Models[modelStr] = self.Data.ImportedModels.Models[modelStr] or {}

        for _, v in ipairs(s.ModelPanel.Entity:GetBodyGroups()) do
            if v.num < 2 then continue end
            self.ModelBackground.Bodygroups:SetWide(Nexus:Scale(200))

            local text = self.ModelBackground.Bodygroups:Add("DLabel")
            text:Dock(TOP)
            text:SetText(v.name)
            text:SetFont(Nexus:GetFont(30))
            text:SizeToContents()

            local slider = self.ModelBackground.Bodygroups:Add("Nexus:NumSlider")
            slider:Dock(TOP)
            slider:SetMax(v.num-1)
            slider:SetTall(Nexus:Scale(50))
            slider.TextBox:SetWide(Nexus:Scale(50))
            slider:SetValue(self.Data.ImportedModels.Models[modelStr][tonumber(v.id)] or 0)

            slider.OnChange = function(_, val)
                self.Data.ImportedModels.Models[modelStr][tonumber(v.id)] = val
                s.ModelPanel.Entity:SetBodygroup(v.id, val)
            end
            slider:OnChange(slider:GetValue())

            table.insert(self.ModelBackground.Bodygroups.Panels, text)
            table.insert(self.ModelBackground.Bodygroups.Panels, slider)
        end

        self.ModelBackground:InvalidateLayout(true)
    end

    self.ModelBackground.Bodygroups = self.ModelBackground:Add("Nexus:V2:ScrollPanel")
    self.ModelBackground.Bodygroups:Dock(RIGHT)
    self.ModelBackground.Bodygroups:SetWide(0)
    self.ModelBackground.Bodygroups.Panels = {}

    self.ModelBackground.ModelPanel = self.ModelBackground:Add("DModelPanel")
    self.ModelBackground.ModelPanel:Dock(FILL)
    self.ModelBackground.ModelPanel.LayoutEntity = function() end

    self.ModelBackground.ModelPanel.OnMouseWheeled = function(s, delta)
        self.ModelBackground.ModelPanel:SetFOV(self.ModelBackground.ModelPanel:GetFOV() - delta)
    end

    self.ModelBackground.Panel = self.ImportPage:Add("Nexus:V2:HorizontalScrollPanel")
    self.ModelBackground.Panel:Dock(BOTTOM)
    self.ModelBackground.Panel:SetTall(Nexus:Scale(125))
    self.ModelBackground.Panel.Panels = {}
    self.ModelBackground.Panel.PerformLayout = function(s, w, h)
        for _, v in ipairs(s.Panels) do
            if not v or not IsValid(v) then continue end
            v:SetWide(v:GetTall())
        end
    end

    self.ModelBackground.Panel.AddModel = function(s, model)
        local panel = s:Add("DModelPanel")
        panel:Dock(LEFT)
        panel:DockMargin(0, 0, self.margin, 0)
        panel:SetModel(model)
        panel.LayoutEntity = function() end
        local old = panel.Paint
        panel.Paint = function(s, w, h)
            draw.RoundedBox(self.margin, 0, 0, w, h, overlay)
            old(s, w, h)
        end

        local bonePos = panel.Entity:LookupBone("ValveBiped.Bip01_Head1")
        if bonePos then
            local eyepos = panel.Entity:GetBonePosition(bonePos)
            eyepos:Add(Vector(0, 0, 2))
            panel:SetLookAt(eyepos)
            panel:SetCamPos(eyepos-Vector(-15, 0, 0))
            panel.Entity:SetEyeTarget(eyepos-Vector(-15, 0, 0))
        end

        panel.DoClick = function()
            for _, v in ipairs(self.ModelBackground.Bodygroups.Panels) do
                v:Remove()
            end

            self.ModelBackground:SetModel(model)
        end

        table.insert(self.ModelBackground.Panel.Panels, panel)
    end

    if (self.Data.ImportedModels.ModelID) then
        self.Header.TextEntry:SetText(self.Data.ImportedModels.ModelID)
        self.Header.Import:DoClick()
    end
end

function PANEL:CreateLocal()
    self:RefreshContent()

    self.BackButton = self:Add("DButton")
    self.BackButton:SetWide(Nexus:Scale(75))
    self.BackButton:SetText("<")
    self.BackButton:SetTextColor(Nexus:GetTextColor(backgroundCol))
    self.BackButton:SetFont(Nexus:GetFont(35))
    self.BackButton.BackButton = true
    self.BackButton.Paint = function(s, w, h)
        local isHovered = s:IsHovered()
        draw.RoundedBox(self.margin, 0, 0, w, h, s:IsHovered() and Nexus:OffsetColor(backgroundCol, 20) or backgroundCol)
    end
    self.BackButton.DoClick = function()
        self:CreateLoader()
    end
    table.insert(self.Panels, self.BackButton)

    local categories = {}

    local sorted = Nexus:GetValue("nexus-jobcreator-price-localModels")
    table.SortByMember(sorted, "m_id")

    for _, v in ipairs(sorted) do
        local category
        if categories[v.Category] then
            category = categories[v.Category]
        else
            category = self:Add("Nexus:Category")
            category:SetText(v.Category)
            category.bottomMargin = self.margin
            table.insert(self.Panels, category)

            local row = category:AddItem("DPanel")
            row.Paint = nil
            row.PerformLayout = function(s, w, h)
                local x, y = 0, 0
                local width = (w - self.margin*2)/3
                for _, v in ipairs(s:GetChildren()) do
                    v:SetSize(width, Nexus:Scale(175))
                    v:SetPos(x, y)
                    x = x + width + self.margin

                    if x + width > w then
                        x = 0
                        y = y + Nexus:Scale(175) + self.margin
                    end
                end
            end

            categories[v.Category] = row
            category = row
        end

        local button = category:Add("DPanel")
        button:SetText("")
        button.Paint = function(s, w, h)
            Nexus.RNDX.Draw(self.margin, 0, 0, w, h, self.Data.SteamModels[v.m_id] and Nexus:GetColor("green") or Nexus:GetColor("secondary-2"))
        end

        local model = button:Add("DModelPanel")
        model:Dock(FILL)
        model:SetModel(v.Model)
        model.LayoutEntity = function() end
        model.PaintOver = function(s, w, h)
            draw.SimpleTextOutlined(v.Name, Nexus:GetFont(20), w/2, self.margin, Nexus:GetColor("primary-text"), 1, 0, 1, color_black)
            draw.SimpleTextOutlined(Nexus.JobCreator:FormatPrice(v.Price), Nexus:GetFont(20), w/2, h-self.margin, Nexus:GetColor("orange"), 1, TEXT_ALIGN_BOTTOM, 1, color_black)
        end
        model.DoClick = function()
            self.Data.SteamModels[v.m_id] = not self.Data.SteamModels[v.m_id]
            if not self.Data.SteamModels[v.m_id] then
                self.Data.SteamModels[v.m_id] = nil
            end
        end

        if IsValid(model:GetEntity()) then
            local eyepos = model.Entity:GetBonePosition(model.Entity:LookupBone("ValveBiped.Bip01_Head1"))
            eyepos:Add(Vector(0, 0, 2))
            model:SetLookAt(eyepos)
            model:SetCamPos(eyepos-Vector(-15, 0, 0))
            model.Entity:SetEyeTarget(eyepos-Vector(-12, 0, 0))
        end

        local rowCount = math.ceil(#category:GetChildren()/3)
        category:SetTall(rowCount * Nexus:Scale(175) + ((rowCount-1) * self.margin))
    end
end

function PANEL:CreateLoader()
    self:RefreshContent()

    self.ChooseLoader = self:Add("Panel")
    self.ChooseLoader:Dock(FILL)
    self.ChooseLoader.PerformLayout = function(s, w, h)
        local y = h*.1
        for _, v in ipairs(s:GetChildren()) do
            v:SetPos((w/2) - (v:GetWide()/2), y)
            y = y + v:GetTall() + self.margin*4
        end
    end

    local hoverCol = Color(255, 255, 255, 20)
    if Nexus:GetValue("nexus-jobcreator-useWorkshopModels") == 1 then
        self.ChooseLoader.ImportModel = self.ChooseLoader:Add("DButton")
        self.ChooseLoader.ImportModel:SetSize(Nexus:Scale(250), Nexus:Scale(250))
        self.ChooseLoader.ImportModel:SetText("")
        self.ChooseLoader.ImportModel.Paint = function(s, w, h)
            local size = h*.9
            Nexus:DrawImgur("https://imgur.com/evHxjHB", (w/2) - (size/2), (h/2) - (size/2), size, size, color_white)

            local text = Nexus.JobCreator:GetPhrase("Import Model")
            if s:IsHovered() then
                draw.RoundedBox(self.margin, 0, 0, w, h, hoverCol)
            end
        end
        self.ChooseLoader.ImportModel.DoClick = function()
            self:CreateImport()
        end
    end

    if Nexus:GetValue("nexus-jobcreator-useLocalModels") == 1 then
        self.ChooseLoader.LocalModel = self.ChooseLoader:Add("DButton")
        self.ChooseLoader.LocalModel:SetSize(Nexus:Scale(250), Nexus:Scale(250))
        self.ChooseLoader.LocalModel:SetText("")
        self.ChooseLoader.LocalModel.Paint = function(s, w, h)
            local size = h*.9
            Nexus:DrawImgur("https://imgur.com/gXvKUaP", (w/2) - (size/2), (h/2) - (size/2), size, size, color_white)

            local text = Nexus.JobCreator:GetPhrase("Local Model")
            if s:IsHovered() then
                draw.RoundedBox(self.margin, 0, 0, w, h, hoverCol)
            end
        end
        self.ChooseLoader.LocalModel.DoClick = function()
            self:CreateLocal()
        end
    end

    table.insert(self.Panels, self.ChooseLoader)
end

function PANEL:PerformLayout(w, h)
    local y = self.margin*2
    for _, v in ipairs(self:GetChildren()) do
        if not v or not IsValid(v) then continue end

        if v.BackButton then
            v:SetTall(Nexus:Scale(50))
            v:SetPos(self.margin*2, self.margin*2)
        else
            v:SetWide(w*.6)
            v:SetPos((w/2) - (w*.6/2), y)
    
            if v.Fill then
                v:SetTall(h - y)
            end    
        end

        y = y + v:GetTall() + (v.bottomMargin or 0)
    end
end

function PANEL:Paint(w, h)
end
vgui.Register("Nexus:JobCreator:Pages:Two", PANEL, "EditablePanel")