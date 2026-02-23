local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin()

    self.Scroll = self:Add("Nexus:V2:ScrollPanel")
    self.Scroll.Fill = true
end

function PANEL:AddSpacer()
    local box = self.Scroll:Add("DPanel")
    box:Dock(TOP)
    box:DockMargin(0, 0, 0, self.margin)
    box:SetTall(Nexus:Scale(40))
    box.Paint = nil
end

function PANEL:AddLabel(text)
    local box = self.Scroll:Add("DPanel")
    box:Dock(TOP)
    box:DockMargin(0, 0, 0, self.margin)
    box:SetTall(Nexus:Scale(40))
    box.Paint = nil

    local nameLabel = box:Add("DLabel")
    nameLabel:SetText(text)
    nameLabel:Dock(LEFT)
    nameLabel:SetFont(Nexus:GetFont(25))
    nameLabel:SizeToContents()
end

function PANEL:AddPrice(name, value, pricePer, forceShow)
    if (value * pricePer) == 0 and not forceShow then
        return
    end

    local box = self.Scroll:Add("DPanel")
    box:Dock(TOP)
    box:DockMargin(0, 0, 0, self.margin)
    box:SetTall(Nexus:Scale(40))
    box.Paint = nil

    local nameLabel = box:Add("DLabel")
    nameLabel:SetText(name)
    nameLabel:Dock(LEFT)
    nameLabel:SetFont(Nexus:GetFont(25))
    nameLabel:SizeToContents()

    local priceLabel = box:Add("DLabel")
    priceLabel:SetText(Nexus.JobCreator:FormatPrice(math.Round(value*pricePer, 2)))
    priceLabel:Dock(LEFT)
    priceLabel:DockMargin(self.margin, 0, 0, 0)
    priceLabel:SetFont(Nexus:GetFont(25))
    priceLabel:SizeToContents()
    priceLabel:SetTextColor(Nexus:GetColor("orange"))
end

function PANEL:GetOptionsMultiplier(data)
    local optionCount = 0

    if data.Health > 0 then optionCount = optionCount + 1 end
    if data.Armor > 0 then optionCount = optionCount + 1 end
    if data.Salary > 0 then optionCount = optionCount + 1 end
    if data.GunLicense then optionCount = optionCount + 1 end
    if data.ImportedModels.ModelID then optionCount = optionCount + 1 end

    optionCount = optionCount + table.Count(data.SteamModels or {})
    optionCount = optionCount + table.Count(data.SelectedGuns or {})
    optionCount = optionCount + table.Count(data.Players or {})

    local optionStep = math.max(tonumber(Nexus:GetValue("nexus-jobcreator-price-optionStep")) or 0, 0)
    local maxMultiplier = math.max(tonumber(Nexus:GetValue("nexus-jobcreator-price-maxMultiplier")) or 1, 1)

    local optionMultiplier = 1
    if optionCount > 1 and optionStep > 0 then
        optionMultiplier = math.min(1 + ((optionCount - 1) * optionStep), maxMultiplier)
    end

    return optionMultiplier
end

function PANEL:SetData(data)
    self.Data = data

    self:AddPrice(Nexus.JobCreator:GetPhrase("Extra Health")..":", data.Health, Nexus:GetValue("nexus-jobcreator-price-health"))
    self:AddPrice(Nexus.JobCreator:GetPhrase("Extra Armor")..":", data.Armor, Nexus:GetValue("nexus-jobcreator-price-armor"))
    self:AddPrice(Nexus.JobCreator:GetPhrase("Extra Salary")..":", data.Salary, Nexus:GetValue("nexus-jobcreator-price-Salary"))

    if self.Data.GunLicense then
        self:AddPrice(Nexus.JobCreator:GetPhrase("Gun License")..":", 1, Nexus:GetValue("nexus-jobcreator-price-GunLicense"))
    end

    self:AddSpacer()

    local localModelsCache = {}
    for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-localModels")) do
        localModelsCache[v.m_id] = v
    end

    if table.Count(data.SteamModels) > 0 or self.Data.ImportedModels.ModelID then
        self:AddLabel(Nexus.JobCreator:GetPhrase("Models")..":")
    end

    if table.Count(self.Data.SteamModels) > 0 then
        for int, val in pairs(self.Data.SteamModels) do
            local name = localModelsCache[int].Name
            local price = localModelsCache[int].Price
            self:AddPrice(name..":", 1, price)
        end
    end

    if self.Data.ImportedModels.ModelID then
        self:AddPrice((self.Data.ImportedModels.Title or "N/A")..":", self.Data.ImportedModels.Size, Nexus:GetValue("nexus-jobcreator-price-perMB"))
    end

    self:AddSpacer()

    local localGunsCache = {}
    for _, v in ipairs(Nexus:GetValue("nexus-jobcreator-price-guns")) do
        localGunsCache[v.m_id] = v
    end

    if table.Count(self.Data.SelectedGuns) > 0 then
        self:AddLabel(Nexus.JobCreator:GetPhrase("Guns")..":")
        for int, val in pairs(self.Data.SelectedGuns) do
            local name = localGunsCache[int].Name
            local price = localGunsCache[int].Price
            self:AddPrice(name..":", 1, price)
        end

        self:AddSpacer()
    end

    if table.Count(self.Data.Players) > 0 then
        self:AddLabel(Nexus.JobCreator:GetPhrase("Players")..":")
        for steamid64, v in pairs(self.Data.Players) do
            Nexus.JobCreator:GetName(steamid64, function(name)
                if not IsValid(self) then return end
                self:AddPrice(name..":", 1, Nexus:GetValue("nexus-jobcreator-price-player"))
            end)
        end
        self:AddSpacer()
    end

    if self.Data.id and Nexus:GetValue("nexus-jobcreator-canEdit") == "Yes" then
        self:AddPrice(Nexus.JobCreator:GetPhrase("Old Total")..":", 1, Nexus.JobCreator:CalculatePrice(data.InitialData))
        self:AddPrice(Nexus.JobCreator:GetPhrase("New Total")..":", 1, Nexus.JobCreator:CalculatePrice(data))

        local finalTotal = Nexus.JobCreator:CalculatePrice(data) - Nexus.JobCreator:CalculatePrice(data.InitialData)
        if finalTotal < 0 and Nexus:GetValue("nexus-jobcreator-canRefund") ~= "Yes" then
            self:AddPrice(Nexus.JobCreator:GetPhrase("Final Total")..":", 1, 0, true)
        elseif finalTotal < 0 then
            self:AddPrice(Nexus.JobCreator:GetPhrase("Final Total")..": ( "..Nexus.JobCreator:GetPhrase("Refund of").." )", 1, math.abs(finalTotal))
        else
            self:AddPrice(Nexus.JobCreator:GetPhrase("Final Total")..":", 1, finalTotal)
        end
    else
        self:AddPrice(Nexus.JobCreator:GetPhrase("Total")..":", 1, Nexus.JobCreator:CalculatePrice(data))
    end

    self:AddLabel(string.format("%s: x%.2f", Nexus.JobCreator:GetPhrase("Options Multiplier"), self:GetOptionsMultiplier(data)))

    self:AddPrice(Nexus.JobCreator:GetPhrase("Your Balance")..":", 1, Nexus.JobCreator:GetTotalMoney(LocalPlayer()))

    self:AddSpacer()

    if self.Data.id then
        self:AddLabel(Nexus.JobCreator:GetPhrase("Kicking Note"))
    end

    local panel = self.Scroll:Add("DPanel")
    panel:Dock(TOP)
    panel:SetTall(Nexus:Scale(50))
    panel.Paint = nil

    if (self.Data.id and Nexus:GetValue("nexus-jobcreator-canEdit") == "Yes") or not self.Data.id then
        local button = panel:Add("Nexus:V2:Button")
        button:Dock(LEFT)
        button:SetWide(Nexus:Scale(150))
        button:SetText(self.Data.id and Nexus.JobCreator:GetPhrase("Edit") or Nexus.JobCreator:GetPhrase("Purchase"))
        button.DoClick = function()
            if self.Data.id then
                net.Start("Nexus:JobCreator:EditJob")
                net.WriteUInt(self.Data.id, 32)
                Nexus.JobCreator:NetworkJobContents(data)
                net.SendToServer()
                return
            end

            net.Start("Nexus:JobCreator:PurchaseJob")
            Nexus.JobCreator:NetworkJobContents(data)
            net.SendToServer()
        end
    end

    if self.Data.id then
        local str = ""
        if Nexus:GetValue("nexus-jobcreator-canRefundDelete") == "Yes" and not self.Data.IsAdmin then
            str = Nexus.JobCreator:GetPhrase("Delete&Refund")
            str = string.format(str, Nexus:GetValue("nexus-jobcreator-refund%").."%")
        else
            str = Nexus.JobCreator:GetPhrase("Delete")
        end

        local button = panel:Add("Nexus:V2:Button")
        button:Dock(LEFT)
        button:DockMargin(self.margin, 0, 0, 0)
        button:SetWide(Nexus:Scale(150))
        button:SetText(str)
        button:SetColor(Nexus:GetColor("red"))
        button:AutoWide(true)
        button.DoClick = function()
            net.Start("Nexus:JobCreator:DeleteJob")
            net.WriteUInt(self.Data.id, 32)
            net.SendToServer()

            Nexus.JobCreator:OpenMenu()
        end
    end
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
vgui.Register("Nexus:JobCreator:Pages:Five", PANEL, "EditablePanel")
