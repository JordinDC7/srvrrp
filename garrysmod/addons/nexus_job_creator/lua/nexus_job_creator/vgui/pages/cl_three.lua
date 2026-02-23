local function GetDamage(data)
    if (data.Primary and data.Primary.Damage) then
        return data.Primary.Damage
    end

    return 0
end

local function GetFirerate(data)
    if (data.Primary and data.Primary.Delay) then
        return (1 / data.Primary.Delay) * 60
    end

    if (data.Primary and data.Primary.RPM) then
        return data.Primary.RPM
    end

    return 0
end

local function GetClipSize(data)
    if (data.Primary and data.Primary.ClipSize) then
        return data.Primary.ClipSize
    end 

    return 0
end

local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin()

    self.Scroll = self:Add("Nexus:V2:ScrollPanel")
    self.Scroll.Fill = true

    self.HighestValues = {
        Damage = 0,
        RPM = 0,
        Clipsize = 0,
    }

    for _, v in ipairs(weapons.GetList()) do
        self.HighestValues.Damage = math.max(self.HighestValues.Damage, GetDamage(v))
        self.HighestValues.RPM = math.max(self.HighestValues.RPM, GetFirerate(v))
        self.HighestValues.Clipsize = math.max(self.HighestValues.Clipsize, GetClipSize(v))
    end

    local categories = {}

    local sorted = Nexus:GetValue("nexus-jobcreator-price-guns")
    table.SortByMember(sorted, "m_id")

    for _, v in ipairs(sorted) do
        local category
        if categories[v.Category] then
            category = categories[v.Category]
        else
            category = self.Scroll:Add("Nexus:Category")
            category:SetText(v.Category)
            category:Dock(TOP)
            category:DockMargin(0, 0, 0, self.margin)

            local row = category:AddItem("DPanel")
            row.Paint = nil
            row.PerformLayout = function(s, w, h)
                local x, y = 0, 0
                self.BoxWidth = (w - self.margin*2)/3
                for _, v in ipairs(s:GetChildren()) do
                    v:SetSize(self.BoxWidth, Nexus:Scale(175))
                    v:SetPos(x, y)
                    x = x + self.BoxWidth + self.margin

                    if x + self.BoxWidth > w then
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
            Nexus.RNDX.Draw(self.margin, 0, 0, w, h, self.Data.SelectedGuns[v.m_id] and Nexus:GetColor("green") or Nexus:GetColor("secondary-2"))
        end

        local modelDATA = weapons.Get(v.Class)

        local model = button:Add("DModelPanel")
        model:Dock(FILL)
        model.LayoutEntity = function() end
        model.PaintOver = function(s, w, h)
            draw.SimpleTextOutlined(v.Name, Nexus:GetFont(20), w/2, self.margin, Nexus:GetColor("primary-text"), 1, 0, 1, color_black)
            draw.SimpleTextOutlined(Nexus.JobCreator:FormatPrice(v.Price), Nexus:GetFont(20), w/2, h-self.margin, Nexus:GetColor("orange"), 1, TEXT_ALIGN_BOTTOM, 1, color_black)
        end
        model.DoClick = function()
            self.Data.SelectedGuns[v.m_id] = not self.Data.SelectedGuns[v.m_id]
            if not self.Data.SelectedGuns[v.m_id] then
                self.Data.SelectedGuns[v.m_id] = nil
            end
        end

        if modelDATA then
            model:SetModel(modelDATA.WorldModel)
        end

        if IsValid(model:GetEntity()) then
            local mn, mx = model.Entity:GetRenderBounds()
            local size = 0
            size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
            size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
            size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
            
            model:SetFOV(30)
            model:SetCamPos(Vector(size, size, size))
            model:SetLookAt((mn + mx) * 0.5)
        end

        if modelDATA then
            self:GenerateTooltip(model, modelDATA)
        end

        local rowCount = math.ceil(#category:GetChildren()/3)
        category:SetTall(rowCount * Nexus:Scale(175) + ((rowCount-1) * self.margin))
    end
end

local function CreateBar(panel, text, value, maxValue)
    local label = panel:Add("DLabel")
    label:Dock(TOP)
    label:DockMargin(Nexus:Scale(10), 0, Nexus:Scale(10), 0)
    label:SetText(text)
    label:SizeToContents()
    label:SetFont(Nexus:GetFont(20))

    local box = panel:Add("DPanel")
    box:Dock(TOP)
    box:DockMargin(Nexus:Scale(10), Nexus:Scale(5), Nexus:Scale(10), Nexus:Scale(5))
    box:SetTall(label:GetTall()/2)
    box.Paint = function(s, w, h)
        Nexus.RNDX.Draw(0, 0, 0, w, h, Nexus:GetColor("header"))
        Nexus.RNDX.Draw(0, 0, 0, (value / maxValue) * w, h, Nexus:GetColor("green"))
    end

    return label:GetTall() + box:GetTall() + Nexus:Scale(10)
end

function PANEL:GenerateTooltip(modelPanel, data)
    modelPanel.OnCursorEntered = function(s)
        if IsValid(s.Box) then
            s.Box:Remove()
        end

        s.Box = vgui.Create("DPanel")
        s.Box:MakePopup()
        s.Box:DockPadding(0, Nexus:Scale(5), 0, 0)
        s.Box.Paint = function(s, w, h)
            Nexus.RNDX.Draw(self.margin, 0, 0, w, h, Nexus:GetColor("background"))
        end

        local tall = CreateBar(s.Box, Nexus.JobCreator:GetPhrase("Damage")..": "..GetDamage(data), GetDamage(data), self.HighestValues.Damage)
        local tall2 = CreateBar(s.Box, Nexus.JobCreator:GetPhrase("Firerate")..": "..GetFirerate(data), GetFirerate(data), self.HighestValues.RPM)
        local tall3 = CreateBar(s.Box, Nexus.JobCreator:GetPhrase("Clipsize")..": "..GetClipSize(data), GetClipSize(data), self.HighestValues.Clipsize)

        s.Box:SetTall(self.margin + tall + tall2 + tall3)
        s.Box.Think = function(box)
            if not IsValid(s) then
                box:Remove()
            end

            if not IsValid(box) then
                return
            end

            box:MoveToFront()

            local x, y = s:LocalToScreen(0, 0)
            box:SetPos(x, y - box:GetTall() - self.margin/2)
            box:SetWide(self.BoxWidth)
        end
    end

    modelPanel.OnCursorExited = function(s)
        if IsValid(s.Box) then
            s.Box:Remove()
        end
    end
end

function PANEL:SetData(data)
    self.Data = data
end

function PANEL:PerformLayout(w, h)
    local y = self.margin*2
    for _, v in ipairs(self:GetChildren()) do
        v:SetWide(w*.6)
        v:SetPos((w/2) - (w*.6/2), y)
    
        if v.Fill then
            v:SetTall(h - y)
        end

        y = y + v:GetTall() + (v.bottomMargin or 0)
    end
end

function PANEL:Paint(w, h)
end
vgui.Register("Nexus:JobCreator:Pages:Three", PANEL, "EditablePanel")