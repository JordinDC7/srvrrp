-- ngl i ripped the base of this from uplink. modified the looks n stuff tho

local PANEL = {}

function PANEL:Init()
    self.tabs = {}
    self.buttons = {}
    self.selected = 0
    self.buttonColor = UltimatePartySystem.Cache.Colors.SlightlyLighterDarkerGray

    self.animPanel = vgui.Create("DPanel", self)
    self.animPanel:SetHeight(2)
    self.animPanel.lerp = 0
    self.animPanel.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, self.buttonColor)

        s.lerp = Lerp(RealFrameTime() * 5, s.lerp, self.selected * (w / #self.tabs))
        draw.RoundedBox(0, s.lerp, 0, w / #self.tabs, h, UltimatePartySystem.Settings.GetValue("themeColor"))
    end
end

function PANEL:AddTab(name, callback)
    self.tabs[#self.tabs + 1] = {
        name = name,
        callback = callback
    }

    self:UpdateButtons()
end

function PANEL:UpdateButtons()
    for k,v in pairs(self.buttons) do
        v:Remove()
    end
    self.buttons = {}

    for k,v in pairs(self.tabs) do
        self.buttons[k] = vgui.Create("ultimatepartysystem.button", self)
        self.buttons[k]:Dock(LEFT)
        self.buttons[k]:SetLabel(self.tabs[k].name)
        self.buttons[k]:SetColor(self.buttonColor)
        self.buttons[k]:SetFont("ultimatepartysystem.scaled.bold.8")
        self.buttons[k].DoClick = function(s, w, h)
            self:SetSelected(k)
        end
        self.buttons[k].Paint = function(s, w, h)
            if(s:IsHovered()) then
                s.lerp = Lerp(RealFrameTime() * 2, s.lerp, 150)
            else
                s.lerp = Lerp(RealFrameTime() * 2, s.lerp, 0)
            end

            draw.RoundedBox(0, 0, 0, w, h, s.color)

            surface.SetDrawColor(s.hoverColor.r, s.hoverColor.g, s.hoverColor.b, s.lerp)
            surface.SetMaterial(UltimatePartySystem.Cache.Materials.CircleyBoi)
            local x,y = s:CursorPos()
            surface.DrawTexturedRect(x - (w / 2), y - (w / 2), w, w)

            draw.SimpleText(s.label, s.font, w / 2, (h / 2) + 1, color_white, 1, 1)
        end
    end
end

function PANEL:SetSelected(id)
    self.selected = id - 1
    self.tabs[id].callback()
end

function PANEL:PerformLayout()
    for k,v in pairs(self.buttons) do
        v:SetSize(self:GetWide() / #self.tabs, self:GetTall())
    end

    self.animPanel:Dock(BOTTOM)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.SlightlyDarkerGray)
end

vgui.Register("ultimatepartysystem.tabselect", PANEL, "DPanel")