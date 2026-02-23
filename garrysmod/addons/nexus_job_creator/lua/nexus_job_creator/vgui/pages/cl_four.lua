local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin()

    self.Scroll = self:Add("Nexus:V2:ScrollPanel")
    self.Scroll.Fill = true

    self.Header = self.Scroll:Add("Panel")
    self.Header:Dock(TOP)
    self.Header:SetTall(Nexus:Scale(50))

    self.Header.TextEntry = self.Header:Add("Nexus:V2:TextEntry")
    self.Header.TextEntry:Dock(FILL)
    self.Header.TextEntry:SetPlaceholder(Nexus.JobCreator:GetPhrase("Add Player"))
    self.Header.TextEntry:SetNumeric(true)

    self.Header.Import = self.Header:Add("Nexus:V2:Button")
    self.Header.Import:Dock(RIGHT)
    self.Header.Import:DockMargin(self.margin, 0, 0, 0)
    self.Header.Import:SetWide(Nexus:Scale(100))
    self.Header.Import:SetText(Nexus.JobCreator:GetPhrase("Add"))
    self.Header.Import.DoClick = function(s)
        local id = self.Header.TextEntry:GetText()
        if self.Data.Players[id] then Nexus.JobCreator:CreateNotification(Nexus.JobCreator:GetPhrase("Already On Job"), 3) return end
        self.Data.Players[id] = true

        self:AddPlayer(id)
    end
end

function PANEL:AddPlayer(steamid64)
    local box = self.Scroll:Add("DPanel")
    box:Dock(TOP)
    box:DockMargin(0, self.margin, 0, 0)
    box:SetTall(Nexus:Scale(50))
    box.Paint = function(s, w, h)
        draw.RoundedBox(self.margin, 0, 0, w, h, Nexus:GetColor("background"))
    end
    box.PerformLayout = function(s, w, h)
        box.modelBox:SetWide(h - self.margin*2)
        box.deleteBox:SetWide(h - self.margin*2)
    end

    box.modelBox = box:Add("AvatarImage")
    box.modelBox:Dock(LEFT)
    box.modelBox:DockMargin(self.margin, self.margin, 0, self.margin)
    box.modelBox:SetSteamID(steamid64, 32)

    box.nameLabel = box:Add("DLabel")
    box.nameLabel:Dock(LEFT)
    box.nameLabel:DockMargin(self.margin, 0, 0, 0)
    box.nameLabel:SetFont(Nexus:GetFont(20))

    Nexus.JobCreator:GetName(steamid64, function(name)
        if not IsValid(self) then return end
        box.nameLabel:SetText(name)
        box.nameLabel:SizeToContents()
    end)

    box.deleteBox = box:Add("Nexus:V2:Button")
    box.deleteBox:Dock(RIGHT)
    box.deleteBox:DockMargin(0, self.margin, self.margin, self.margin)
    box.deleteBox:SetFont(Nexus:GetFont(20))
    box.deleteBox:SetText("X")
    box.deleteBox:SetColor(Nexus:GetColor("red"))
    box.deleteBox.DoClick = function(s)
        self.Data.Players[steamid64] = nil
        box:Remove()
    end
end

function PANEL:SetData(data)
    self.Data = data

    for steamid64, v in pairs(self.Data.Players) do
        self:AddPlayer(steamid64)
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
vgui.Register("Nexus:JobCreator:Pages:Four", PANEL, "EditablePanel")