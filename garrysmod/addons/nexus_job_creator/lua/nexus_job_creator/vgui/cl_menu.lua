local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin()

    self.backgroundCol = Color(29, 35, 47)
    self.backgroundCol.a = 200

    self.gradientCol = Color(29, 35, 47)
    self.gradientCol.a = 80

    self:CreateHeader()

    self:SelectContent("Nexus:JobCreator:YourJobs")
end

function PANEL:CreateHeader()
    local col = table.Copy(Nexus:GetColor("primary-text"))
    col.a = 50

    self.Header = self:Add("Panel")
    self.Header.CalculateSize = function(s)
        local tall = self.Header.YourJobs:GetTall()
        s:SetTall(tall)
    end

    self.SelectedPage = ""
    self.Header.YourJobs = self.Header:Add("Nexus:V2:Button")
    self.Header.YourJobs:Dock(LEFT)
    self.Header.YourJobs:SetSize(Nexus:Scale(200), Nexus:Scale(75))
    self.Header.YourJobs:SetText(Nexus.JobCreator:GetPhrase("Your Jobs"))
    self.Header.YourJobs:SetFont(Nexus:GetFont({size = 20}))
    self.Header.YourJobs:SetSecondary()
    self.Header.YourJobs.PaintOver = function(s, w, h)
        if self.SelectedPage == "Nexus:JobCreator:YourJobs" then
            Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("overlay"))
        end
    end
    self.Header.YourJobs.DoClick = function(s)
        self:SelectContent("Nexus:JobCreator:YourJobs")
    end

    self.Header.SharedJobs = self.Header:Add("Nexus:V2:Button")
    self.Header.SharedJobs:Dock(LEFT)
    self.Header.SharedJobs:DockMargin(self.margin, 0, 0, 0)
    self.Header.SharedJobs:SetSize(Nexus:Scale(200), self.Header.YourJobs:GetTall())
    self.Header.SharedJobs:SetText(Nexus.JobCreator:GetPhrase("Shared Jobs"))
    self.Header.SharedJobs:SetFont(Nexus:GetFont({size = 20}))
    self.Header.SharedJobs:SetSecondary()
    self.Header.SharedJobs.PaintOver = function(s, w, h)
        if self.SelectedPage == "Nexus:JobCreator:SharedJobs" then
            Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("overlay"))
        end
    end
    self.Header.SharedJobs.DoClick = function(s)
        self:SelectContent("Nexus:JobCreator:SharedJobs")
    end

    self.Header.CloseButton = self.Header:Add("Nexus:V2:Button")
    self.Header.CloseButton:Dock(RIGHT)
    self.Header.CloseButton:SetSize(Nexus:Scale(100), self.Header.YourJobs:GetTall())
    self.Header.CloseButton:SetColor(Nexus:GetColor("red"))
    self.Header.CloseButton:SetIcon("https://imgur.com/YNrikW3")
    self.Header.CloseButton:SetText("")
    self.Header.CloseButton.DoClick = function(s)
        self:Remove()
    end

    if Nexus:GetValue("nexus-jobcreator-admins")[LocalPlayer():GetUserGroup()] then
        self.Header.ConfigButton = self.Header:Add("Nexus:V2:Button")
        self.Header.ConfigButton:Dock(RIGHT)
        self.Header.ConfigButton:DockMargin(0, 0, self.margin, 0)
        self.Header.ConfigButton:SetSize(Nexus:Scale(100), self.Header.YourJobs:GetTall())
        self.Header.ConfigButton:SetSecondary()
        self.Header.ConfigButton:SetIcon("https://imgur.com/0Re6YrA")
        self.Header.ConfigButton:SetText("")

        self.Header.ConfigButton.DoClick = function(s)
            Nexus.JobCreator:OpenAdminPage()
        end
    end

    self.Header.BuyCredits = self.Header:Add("Nexus:V2:Button")
    self.Header.BuyCredits:Dock(RIGHT)
    self.Header.BuyCredits:DockMargin(0, 0, self.margin, 0)
    self.Header.BuyCredits:SetSize(Nexus:Scale(200), self.Header.YourJobs:GetTall())
    self.Header.BuyCredits:SetSecondary()
    self.Header.BuyCredits:SetText(Nexus.JobCreator:GetPhrase("Buy Credits"))
    self.Header.BuyCredits:SetFont(Nexus:GetFont({size = 20}))
    self.Header.BuyCredits.DoClick = function()
        Nexus.JobCreator:OpenShopURL()
    end

    self.Header.Community = self.Header:Add("Nexus:V2:Button")
    self.Header.Community:Dock(RIGHT)
    self.Header.Community:DockMargin(0, 0, self.margin, 0)
    self.Header.Community:SetSize(Nexus:Scale(160), self.Header.YourJobs:GetTall())
    self.Header.Community:SetSecondary()
    self.Header.Community:SetText(Nexus.JobCreator:GetPhrase("Open Community"))
    self.Header.Community:SetFont(Nexus:GetFont({size = 18}))
    self.Header.Community.DoClick = function()
        Nexus.JobCreator:OpenConfiguredURL("nexus-jobcreator-communityURL", "https://discord.gg/physgun")
    end

    self.Header.Guide = self.Header:Add("Nexus:V2:Button")
    self.Header.Guide:Dock(RIGHT)
    self.Header.Guide:DockMargin(0, 0, self.margin, 0)
    self.Header.Guide:SetSize(Nexus:Scale(150), self.Header.YourJobs:GetTall())
    self.Header.Guide:SetSecondary()
    self.Header.Guide:SetText(Nexus.JobCreator:GetPhrase("Open Rules"))
    self.Header.Guide:SetFont(Nexus:GetFont({size = 18}))
    self.Header.Guide.DoClick = function()
        Nexus.JobCreator:OpenConfiguredURL("nexus-jobcreator-guideURL", "https://smgrpdonate.shop/pages/custom-jobs-guide")
    end

    self.Header.Language = self.Header:Add("Nexus:V2:Button")
    self.Header.Language:Dock(RIGHT)
    self.Header.Language:DockMargin(0, 0, self.margin, 0)
    self.Header.Language:SetSize(Nexus:Scale(100), self.Header.YourJobs:GetTall())
    self.Header.Language:SetSecondary()
    self.Header.Language:SetText(string.upper(Nexus:GetSetting("nexus_language", "en")))
    self.Header.Language:SetFont(Nexus:GetFont({size = 20}))
    self.Header.Language.DoClick = function(s)
        Nexus:DermaMenu(Nexus:GetLanguages(), function(value)
            if not Nexus:IsLanguageLoaded(value) then
                Nexus:QueryPopup(string.format(Nexus:GetInstalledText(value, "download"), value), function()
                    Nexus:LoadLanguage(value, function(success)
                        if IsValid(self) and success then
                            Nexus:SetSetting("nexus_language", value)
                            self:Remove()
                        end
                    end)
                end, nil, Nexus:GetInstalledText(value, "yes"), Nexus:GetInstalledText(value, "no"))

                return
            end

            Nexus:SetSetting("nexus_language", value)
            self:Remove()
        end)
    end

    self.Header:CalculateSize()
end

function PANEL:SelectContent(str)
    if IsValid(self.Content) then self.Content:Remove() end

    self.SelectedPage = str

    self.Content = self:Add(str)
    self:InvalidateLayout(true)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(1, 1, 15)
    surface.DrawRect(0, 0, w, h)

    local balanceY = self.Header:GetY() + self.Header:GetTall() + Nexus:Scale(10)
    draw.SimpleText(Nexus.JobCreator:GetPhrase("Your Balance")..": "..Nexus.JobCreator:FormatPrice(Nexus.JobCreator:GetTotalMoney(LocalPlayer())), Nexus:GetFont(30), self.Header:GetX(), balanceY, Nexus:GetColor("orange"))
    draw.SimpleText(Nexus.JobCreator:GetPhrase("Server Advantage")..": lower credit totals + premium style progression", Nexus:GetFont(20), self.Header:GetX(), balanceY + Nexus:Scale(32), Nexus:GetColor("primary-text"))
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
    self.Header:SetPos(self.margin*10, self.margin*7)
    self.Header:SetWide(w - self.Header:GetX()*2)
    if IsValid(self.Content) then
        self.Content:SetPos(self.Header:GetX(), self.Header:GetY()*2 + self.Header:GetTall())
        self.Content:SetSize(w - self.Header:GetX()*2, h - self.Content:GetY() - self.Header:GetY())
    end
end
vgui.Register("Nexus:JobCreator:Menu", PANEL, "EditablePanel")