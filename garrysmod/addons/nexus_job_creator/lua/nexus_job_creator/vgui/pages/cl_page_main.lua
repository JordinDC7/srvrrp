local pages = {
    "Nexus:JobCreator:Pages:One",
    "Nexus:JobCreator:Pages:Two",
    "Nexus:JobCreator:Pages:Three",
    "Nexus:JobCreator:Pages:Four",
    "Nexus:JobCreator:Pages:Five",
}

local function Circle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
	end

	local a = math.rad(0)
	table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})

	surface.DrawPoly(cir)
end

local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin()
    self.currentPage = 1
    self.JobData = {
        Name = "",
        Description = "",
        Color = table.Copy(Nexus:GetColor("primary")),
        Health = 0,
        Armor = 0,
        Salary = 0,
        GunLicense = false,

        ImportedModels = {},
        SteamModels = {},
        SelectedGuns = {},
        Players = {},
    }

    self.Header = self:Add("DPanel")
    self.Header.Paint = function(s, w, h)
        local tw, th = draw.SimpleText(Nexus.JobCreator:GetPhrase("Total Cost"), Nexus:GetFont(h/2, true), w, 0, Nexus:GetColor("primary-text"), TEXT_ALIGN_RIGHT, 0)
        draw.SimpleText(Nexus.JobCreator:FormatPrice(Nexus.JobCreator:CalculatePrice(self.JobData)).." / "..Nexus.JobCreator:FormatPrice(Nexus.JobCreator:GetTotalMoney(LocalPlayer())), Nexus:GetFont(h/2, true), w, th, Nexus:GetColor("orange"), TEXT_ALIGN_RIGHT, 0)

        local radius, margin = h/2, self.margin*4

        local totalWide = (#pages*radius*2) + ((#pages-1)*margin)
        local x, y = (w/2) - (totalWide/2), 0

        for i = 1, #pages do
            local background = (i <= self.currentPage) and Nexus:GetColor("primary") or Nexus:GetColor("secondary")
            surface.SetDrawColor(background.r, background.g, background.b, 200)
            draw.NoTexture()
            Circle(x+radius, radius, radius, radius)

            draw.SimpleText(i, Nexus:GetFont(radius, true), x + (radius) - 1, radius-1, Nexus:GetColor("primary-text"), 1, 1)
            local nextX = x + radius*2 + margin
            if i < #pages then
                surface.SetDrawColor(background.r, background.g, background.b, 200)
                surface.DrawRect(x + radius*2, h/2 - 1, margin, 2)
            end

            x = nextX
        end
    end

    local backgroundCol = Color(29, 35, 47)
    backgroundCol.a = 200

    local greyCol = Color(232, 234, 237)
    self.Header.Back = self.Header:Add("Nexus:V2:Button")
    self.Header.Back:Dock(LEFT)
    self.Header.Back:SetText(Nexus.JobCreator:GetPhrase("Back"))
    self.Header.Back:SetFont(Nexus:GetFont(self.Header:GetTall()*.9, true))
    self.Header.Back:SetTextColor(greyCol)
    self.Header.Back:SetWide(Nexus:Scale(150))
    self.Header.Back:SetSecondary()
    self.Header.Back.DoClick = function(s)
        Nexus.JobCreator:OpenMenu()
    end

    self.Content = self:Add("Panel")
    self.Content:DockPadding(self.margin, self.margin, self.margin, self.margin)
    self.Content.Paint = function(s, w, h)
        draw.RoundedBox(self.margin, 0, 0, w, h, backgroundCol)
    end

    self.NextPage = self:Add("Nexus:V2:Button")
    self.NextPage:SetText("")
    self.NextPage:SetFont(Nexus:GetFont(Nexus:Scale(125), true))
    self.NextPage:SetSize(Nexus:Scale(125), Nexus:Scale(125))
    self.NextPage:SetIcon("https://imgur.com/cJ7PO7b", function(h) return h*.45 end)
    self.NextPage:SetSecondary()
    self.NextPage.DoClick = function(s)
        self:SetPage(self.currentPage+1)
    end

    self.PreviousPage = self:Add("Nexus:V2:Button")
    self.PreviousPage:SetText("")
    self.PreviousPage:SetFont(Nexus:GetFont(Nexus:Scale(125), true))
    self.PreviousPage:SetSize(Nexus:Scale(125), Nexus:Scale(125))
    self.PreviousPage:SetIcon("left-arrow", function(h) return h*.45 end)
    self.PreviousPage:SetSecondary()

    self.PreviousPage.DoClick = function(s)
        self:SetPage(self.currentPage-1)
    end

    self:SetPage(1)
end

function PANEL:SetMasterData(data)
    self.JobData = data
    self:SetData(data)
end

function PANEL:SetData(data)
    if IsValid(self.Content.Content) then
        self.Content.Content:SetData(data)
    end
end

function PANEL:SetPage(page)
    self.currentPage = math.Clamp(page, 1, #pages)

    self.NextPage:Show()
    self.PreviousPage:Show()

    if self.currentPage == 1 then
        self.PreviousPage:Hide()
    elseif self.currentPage == #pages then
        self.NextPage:Hide()
    end

    if IsValid(self.Content.Content) then
        self.Content.Content:Remove()
    end

    self.Content.Content = self.Content:Add(pages[page])
    self.Content.Content:Dock(FILL)
    self.Content.Content:SetData(self.JobData)
end

function PANEL:Paint(w, h)
    Nexus:DrawImgur("https://imgur.com/O9B6fnv", 0, 0, w, h)

    if Nexus.JobCreator.Notification and CurTime() < Nexus.JobCreator.Notification.EndTime then
        local font = Nexus:GetFont(20)

        surface.SetFont(font)
        local wide, tall = surface.GetTextSize(Nexus.JobCreator.Notification.Text)
        wide, tall = wide + self.margin*4, tall + self.margin*2
    
        local x, y = (w/2) - (wide/2), self.margin*3
        draw.RoundedBox(self.margin, x, y, wide, tall, Nexus:GetColor("background"))
        draw.SimpleText(Nexus.JobCreator.Notification.Text, font, x + (wide/2), y + (tall/2), Nexus:GetColor("primary-text"), 1, 1)        

        draw.RoundedBox(self.margin, x + self.margin, y + tall - 2, (wide-self.margin*2) * (Nexus.JobCreator.Notification.EndTime - CurTime())/Nexus.JobCreator.Notification.Length, 2, Nexus:GetColor("primary"))
    end
end

function PANEL:PerformLayout(w, h)
    local wide, tall = w*.4, h*.8
    self.Header:SetSize(wide, Nexus:Scale(50))
    self.Header:SetPos((w/2) - (wide/2), (h/2) - (tall/2))

    self.Content:SetSize(wide, tall - self.Header:GetTall() - self.margin)
    self.Content:SetPos((w/2) - (wide/2), (h/2) - (tall/2) + self.Header:GetTall() + self.margin)

    self.NextPage:SetPos((w/2) - (wide/2) + self.Content:GetWide() + self.margin, (h/2) - (tall/2) + self.Header:GetTall() + self.margin + self.Content:GetTall()/2 - self.NextPage:GetTall()/2)
    self.PreviousPage:SetPos((w/2) - (wide/2) - self.PreviousPage:GetWide() - self.margin, (h/2) - (tall/2) + self.Header:GetTall() + self.margin + self.Content:GetTall()/2 - self.NextPage:GetTall()/2)
end
vgui.Register("Nexus:JobCreator:Pages:Main", PANEL, "EditablePanel")