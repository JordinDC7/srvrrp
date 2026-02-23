local PANEL = {}

function PANEL:Init()
  self.VBar:SetWide(12)
  self.VBar:SetHideButtons(true)

  self.VBar.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(XeninUI.Theme.Navbar, 150))
  end
  self.VBar.btnGrip.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Primary)
  end
end

function PANEL:HideScrollBar(hide)
  self.VBar:SetWide((hide and 0) or 12)
end

vgui.Register("XeninUI.ScrollPanel", PANEL, "DScrollPanel")
