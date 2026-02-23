-- Same as TabSelect but on the side

local PANEL = {}

function PANEL:Init()
    self.buttons = {}
    self.selected = 0
    self.buttonColor = UltimatePartySystem.Cache.Colors.SlightlyLighterDarkerGray

    self.scroll = vgui.Create("ultimatepartysystem.scrollpanel", self)

    self.animPanel = vgui.Create("DPanel", self)
    self.animPanel:SetWide(2)
    self.animPanel.lerp = 0
    self.animPanel.Paint = function(s, w, h)
        s.lerp = Lerp(RealFrameTime() * 5, s.lerp, self.selected * (h * 0.1))
        draw.RoundedBox(0, 0, s.lerp, w, h * 0.1, UltimatePartySystem.Settings.GetValue("themeColor"))
    end
end

function PANEL:AddTab(name, callback)
    local btn = vgui.Create("ultimatepartysystem.button", self.scroll)
    btn:Dock(TOP)
    btn:SetColor(self.buttonColor)
    btn:SetLabel(name)
    btn:SetFont("ultimatepartysystem.scaled.bold.8")
    btn.callback = callback
    btn.id = #self.buttons + 1
    btn.DoClick = function()
        self:SetSelected(btn.id)
    end

    self.buttons[btn.id] = btn
end

function PANEL:SetSelected(id)
    self.selected = id - 1
    self.buttons[id].callback()
end

function PANEL:PerformLayout()
    for k,v in pairs(self.buttons) do
        v:Dock(TOP)
        v:SetHeight(self:GetTall() * 0.1)
    end

    self.animPanel:Dock(LEFT)
    self.scroll:Dock(FILL)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.SlightlyIDKDarkerGray)
end

vgui.Register("ultimatepartysystem.sideselect", PANEL, "DPanel")