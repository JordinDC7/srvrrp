local PANEL = {}

function PANEL:OnDelete() end
function PANEL:DoClick() end

function PANEL:SetEntity(entity, template, isList)
  local __lauxi0 = template.getListView(entity, isList)
  assert(__lauxi0 ~= nil, "cannot destructure nil value")
  local display, title, subtitle = __lauxi0.display, __lauxi0.title, __lauxi0.subtitle

  self.Entity = entity
  self.Title = markup.Parse("<font=Xenin.Configurator.Row.Title><color=255,255,255>" .. tostring(title) .. "</color></font>")
  self.Subtitle = markup.Parse("<font=Xenin.Configurator.Row.Subtitle><color=174,174,174>" .. tostring(subtitle) .. "</color></font>")
  self:SetDisplay(display)
end

function PANEL:Init()
  self.Edit = self:Add("XeninUI.ButtonV2")
  self.Edit:SetText("Edit")
  self.Edit:SetFont("Xenin.Configurator.Row.Title")
  self.Edit:SetSolidColor(XeninUI.Theme.GreenDark)
  self.Edit:SetRoundness(6)
  self.Edit.DoClick = function(pnl)
    self:DoClick()
  end

  self.Delete = self:Add("XeninUI.ButtonV2")
  self.Delete:SetVisible(false)
  self.Delete:SetText("")
  self.Delete:SetSolidColor(XeninUI.Theme.Red)
  self.Delete:SetRoundness(6)
  self.Delete.DoClick = function(pnl)
    self:OnDelete()
  end
  self.Delete.PaintOver = function(pnl, w, h)
    local size = h / 2
    surface.SetMaterial(XeninUI.Materials.CloseButton)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRect(w / 2 - size / 2 + 1, h / 2 - size / 2, size, size)
  end
end

function PANEL:Think()
  if (self.DeleteDisabled) then return end

  self.Delete:SetVisible(self:IsHovered() or self:IsChildHovered())
end

function PANEL:SetDisplay(display)
  if (!display) then return end
  if (IsValid(self.Display)) then return end

  self.Display = self:Add("SpawnIcon")
  self.Display:Dock(LEFT)
  self.Display:SetWide(56)
  self.Display.Model = display
  self.Display:SetMouseInputEnabled(false)


  timer.Simple(0, function()
    self.Display:SetModel(self.Display.Model)
  end)
end

function PANEL:Paint(w, h)
  XeninUI:DrawRoundedBox(6, 0, 0, w, h, XeninUI.Theme.Navbar)

  local x = h + 4

  self.Title:Draw(x, h / 2 + 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
  self.Subtitle:Draw(x, h / 2 + 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function PANEL:PerformLayout(w, h)
  self.Edit:SizeToContentsX(24)
  self.Edit:SizeToContentsY(8)
  self.Edit:AlignRight(12)
  self.Edit:CenterVertical()

  self.Delete:SetSize(self.Edit:GetTall(), self.Edit:GetTall())
  self.Delete:AlignRight(w - self.Edit.x + 12)
  self.Delete:CenterVertical()
end

vgui.Register("Xenin.Configurator.Admin.EntityList.Row", PANEL)
