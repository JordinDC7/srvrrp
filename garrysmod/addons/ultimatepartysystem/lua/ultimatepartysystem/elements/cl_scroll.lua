local PANEL = {}

function PANEL:Init()
    self.vBar = self:GetVBar()
    self.vBar:SetWide(5)
    self.vBar:SetHideButtons(true)
    self.vBar.bgClr = UltimatePartySystem.Cache.Colors.SlightlyLighterDarkerGray
    self.vBar.gripClr = UltimatePartySystem.Cache.Colors.Gray
    self.vBar.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, s.bgClr)
    end
    self.vBar.btnGrip.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, self.vBar.gripClr)
    end
end

function PANEL:Paint(w, h)
end

vgui.Register("ultimatepartysystem.scrollpanel", PANEL, "DScrollPanel")