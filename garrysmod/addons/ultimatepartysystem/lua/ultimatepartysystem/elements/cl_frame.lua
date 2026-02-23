local PANEL = {}

function PANEL:Init()
    self.topPanel = vgui.Create("DPanel", self)
    self.topPanel:SetHeight(40) -- Temp value before being set by PANEL:SetTopBarHeight so it scales with screen resolutions just like every one of my addons at this point
    self.topPanel.title = "um"
    self.topPanel.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.SlightGray)
        draw.SimpleText(self.topPanel.title, "ultimatepartysystem.scaled.bold.10", h / 4, h / 2, color_white, 0, 1)
    end

    self.closeButton = vgui.Create("DButton", self.topPanel)
    self.closeButton:SetText("")
    self.closeButton.DoClick = function()
        self:Remove()
    end
    self.closeButton.Paint = function(s, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(UltimatePartySystem.Cache.Materials.Cross)
        surface.DrawTexturedRect((h / 3) / 2, (h / 3) / 2, h / 1.5, h / 1.5)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.SlightlyDarkerGray)
end

function PANEL:SetTopBarHeight(h)
    self.topPanel:SetHeight(h)
end
function PANEL:SetTopBarTitle(txt)
    self.topPanel.title = txt
end

function PANEL:RemoveCloseButton()
    self.closeButton:Remove()
    self.closeButton = nil
end

function PANEL:PerformLayout()
    self.topPanel:Dock(TOP)

    if(self.closeButton) then
        self.closeButton:Dock(RIGHT)
        self.closeButton:SetSize(self.topPanel:GetTall(), self.topPanel:GetTall())
    end
end

vgui.Register("ultimatepartysystem.frame", PANEL, "EditablePanel")