local backgroundCol = Color(78, 85, 100)
backgroundCol.a = 200

local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin()
    self.Panels = {}

    self.Title = self:Add("DLabel")
    self.Title:Dock(TOP)
    self.Title:SetText(Nexus.JobCreator:GetPhrase("Kicking Note"))
    self.Title:SetFont(Nexus:GetFont(20))

    self.Header = self:Add("DPanel")
    self.Header:Dock(TOP)
    self.Header:DockMargin(0, 0, 0, self.margin)
    self.Header:SetTall(Nexus:Scale(50))
    self.Header.Paint = nil

    self.Header.SearchBox = self.Header:Add("Nexus:V2:TextEntry")
    self.Header.SearchBox:Dock(FILL)
    self.Header.SearchBox:DockMargin(0, 0, self.margin, 0)
    self.Header.SearchBox:SetPlaceholder(Nexus.JobCreator:GetPhrase("Search"))
    self.Header.SearchBox.OnChange = function(s, str)
        local str = s:GetText()
        for _, v in ipairs(self.Panels) do
            v:Hide()
            local start, _ = string.find(string.lower(Nexus.JobCreator.ActiveJobs[v.id].Name), string.lower(str))
            if not start then continue end
            v:Show()
        end
        self.Scroll:InvalidateLayout()
    end

    self.Scroll = self:Add("Nexus:V2:ScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:GetCanvas().PerformLayout = function(s, w, h)
        local wide = (w - self.margin*4)/4
        local x, y = 0, 0
        for _, v in ipairs(s:GetChildren()) do
            if not v:IsVisible() then continue end
            v:SetSize(wide, wide*1.5)
            v:SetPos(x, y)

            x = x + wide + self.margin
            if x + wide > w then
                x = 0
                y = y + wide*1.5 + self.margin
            end
        end
    end

    for id, data in pairs(Nexus.JobCreator.ActiveJobs) do
        local panel = self.Scroll:Add("Nexus:JobCreator:JobPanel")
        panel:SetAdmin(true)
        panel:SetID(id)
        table.insert(self.Panels, panel)
    end
end

function PANEL:Paint(w, h)
end
vgui.Register("Nexus:JobCreator:Authenticate:One", PANEL, "EditablePanel")