local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin()

    self.Name = self:QuickTextEntry(Nexus.JobCreator:GetPhrase("Name"), 3, Nexus:GetValue("nexus-jobcreator-max-nameLength"), function(value)
        if not self.Data then return end
        self.Data.Name = value
    end)

    self.Description = self:QuickTextEntry(Nexus.JobCreator:GetPhrase("Description"), 0, Nexus:GetValue("nexus-jobcreator-max-descriptionLength"), function(value)
        if not self.Data then return end
        self.Data.Description = value
    end)

    self.JobColor = self:QuickColorBox(Nexus.JobCreator:GetPhrase("Job Color"), function(value)
        if not self.Data then return end
        self.Data.Color = value
    end)

    self.HealthSlider = self:QuickSlider(Nexus.JobCreator:GetPhrase("Extra Health"), Nexus:GetValue("nexus-jobcreator-max-health"), Nexus:GetValue("nexus-jobcreator-price-health"), function(value)
        if not self.Data then return end
        self.Data.Health = value
    end)

    self.ArmorSlider = self:QuickSlider(Nexus.JobCreator:GetPhrase("Extra Armor"), Nexus:GetValue("nexus-jobcreator-max-armor"), Nexus:GetValue("nexus-jobcreator-price-armor"), function(value)
        if not self.Data then return end
        self.Data.Armor = value
    end)

    self.SalarySlider = self:QuickSlider(Nexus.JobCreator:GetPhrase("Extra Salary"), Nexus:GetValue("nexus-jobcreator-max-salary"), Nexus:GetValue("nexus-jobcreator-price-Salary"), function(value)
        if not self.Data then return end
        self.Data.Salary = value
    end)

    self.GunLicense = self:QuickCheckBox(Nexus.JobCreator:GetPhrase("Gun License"), function(value)
        if not self.Data then return end
        self.Data.GunLicense = value
    end)
end

function PANEL:SetData(data)
    self.Data = data

    self.Name:SetText(data.Name)
    self.Name:OnChange()

    self.Description:SetText(data.Description)
    self.Description:OnChange()

    self.JobColor:SetColor(data.Color)
    self.HealthSlider:SetValue(data.Health)
    self.ArmorSlider:SetValue(data.Armor)
    self.SalarySlider:SetValue(data.Salary)
    self.GunLicense:SetState(data.GunLicense)
end

function PANEL:QuickTextEntry(str, min, max, func)
    local block = self:Add("DPanel")
    block:SetTall(Nexus:Scale(30))
    block.Paint = nil

    local text = block:Add("DLabel")
    text:Dock(LEFT)
    text:SetText(str)
    text:SetFont(Nexus:GetFont(block:GetTall(), true))
    text:SizeToContents()

    local minMax = block:Add("DLabel")
    minMax:Dock(RIGHT)
    minMax:SetFont(Nexus:GetFont(block:GetTall()*.7, true))
    minMax:SizeToContents()
    minMax:SetContentAlignment(3)
    minMax:SetTextColor(Nexus:GetColor("red"))

    local textEntry = self:Add("Nexus:V2:TextEntry")
    textEntry.bottomMargin = self.margin*2
    textEntry.OnChange = function(s)
        if #s:GetText() < min then
            minMax:SetText(string.format(Nexus.JobCreator:GetPhrase("Minimum Chars"), min))
            minMax:SetTextColor(Nexus:GetColor("red"))
        elseif #s:GetText() > max then
            minMax:SetText(string.format(Nexus.JobCreator:GetPhrase("Maximum Chars"), #s:GetText() - max))
            minMax:SetTextColor(Nexus:GetColor("red"))
        else
            minMax:SetText(#s:GetText().." / "..max)
            minMax:SetTextColor(Nexus:GetColor("green"))            
        end

        func(s:GetText())
        minMax:SizeToContents()
    end
    textEntry:OnChange()

    return textEntry
end

function PANEL:QuickColorBox(str, func)
    local block = self:Add("DPanel")
    block:SetTall(Nexus:Scale(30))
    block.Paint = nil

    local text = block:Add("DLabel")
    text:Dock(LEFT)
    text:SetText(str)
    text:SetFont(Nexus:GetFont(block:GetTall(), true))
    text:SizeToContents()

    local block = self:Add("DPanel")
    block:SetTall(Nexus:Scale(50))
    block.Paint = nil
    block.ColorObjects = {}
    block.PerformLayout = function(s, w, h)
        block.colorBlock:SetWide(h)

        local x = h + self.margin
        local size = (w - self.margin*3 - h) / 3
        for _, data in ipairs(block.ColorObjects) do
            local v = data.panel
            v:SetSize(size, h)
            v:SetX(x)
            x = x + size + self.margin
        end
    end

    local values = {"r", "g", "b"}
    local col = table.Copy(Nexus:GetColor("background"))
    block.colorBlock = block:Add("DPanel")
    block.colorBlock:Dock(LEFT)
    block.colorBlock.SetColor = function(s, inputCol)
        col = inputCol

        for _, v in ipairs(block.ColorObjects) do
            v.panel:SetValue(inputCol[v.value])
        end
    end

    block.bottomMargin = self.margin*2
    block.colorBlock.Paint = function(s, w, h)
        draw.RoundedBox(self.margin, 0, 0, w, h, col)
    end

    for i = 1, 3 do
        local inputBox = block:Add("Nexus:V2:NumSlider")
        inputBox:SetTall(40)
        inputBox:SetMax(255)
        inputBox:SetValue(col[values[i]])
        inputBox:SetBoxWide(Nexus:Scale(60))
        inputBox.OnChange = function(s, value)
            col[values[i]] = value
            func(col)
        end

        table.Add(block.ColorObjects, {{panel = inputBox, value = values[i]}})
    end

    return block.colorBlock
end

function PANEL:QuickSlider(str, max, pricePer, func)
    local block = self:Add("DPanel")
    block:SetTall(Nexus:Scale(30))
    block.Paint = nil

    local text = block:Add("DLabel")
    text:Dock(LEFT)
    text:SetText(str)
    text:SetFont(Nexus:GetFont(block:GetTall(), true))
    text:SizeToContents()

    local priceLabal = block:Add("DLabel")
    priceLabal:Dock(FILL)
    priceLabal:SetFont(Nexus:GetFont(block:GetTall()*.7, true))
    priceLabal:SizeToContents()
    priceLabal:SetTextColor(Nexus:GetColor("orange"))
    priceLabal:SetText("")
    priceLabal.Paint = function(s, w, h)
        draw.SimpleText(s.Text, s:GetFont(), w, h, s:GetTextColor(), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end

    local slider = self:Add("Nexus:V2:NumSlider")
    slider:SetMax(max)
    slider.bottomMargin = self.margin*2
    slider.OnChange = function(s, val)
        priceLabal.Text = (Nexus.JobCreator:FormatPrice(pricePer*val))
        func(val)
    end

    slider:OnChange(0)

    return slider
end

function PANEL:QuickCheckBox(str, func)
    local block = self:Add("Nexus:V2:CheckBox")
    block:SetText(str)
    block.OnStateChanged = function(s)
        func(block:GetState())
    end

    return block
end

function PANEL:PerformLayout(w, h)
    local y = self.margin*2
    for _, v in ipairs(self:GetChildren()) do
        v:SetWide(w*.6)
        v:SetPos((w/2) - (w*.6/2), y)
        y = y + v:GetTall() + (v.bottomMargin or 0)
    end
end

function PANEL:Paint(w, h)
end
vgui.Register("Nexus:JobCreator:Pages:One", PANEL, "EditablePanel")