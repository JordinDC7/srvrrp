local PANEL = {}

function PANEL:Init()
  self:SetText("")

  self.BackgroundColor = XeninUI.Theme.Navbar
  self.Name = "Common"
  self.Color = Color(180, 180, 180)
  self.Rotation = 0
  self.ArrowColor = self.Color
  self.State = false

  self.Delete = self:Add("DButton")
  self.Delete:SetVisible(false)
  self.Delete:SetText("")
  self.Delete.Color = ColorAlpha(XeninUI.Theme.Red, 150)
  self.Delete.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Color)

    surface.SetDrawColor(color_white)
    surface.SetMaterial(XeninUI.Materials.CloseButton)
    local margin = 8
    surface.DrawTexturedRect(margin, margin, w - (margin * 2), h - (margin * 2))
  end
  self.Delete.DoClick = function(pnl)
    local shiftDown = input.IsKeyDown(KEY_LSHIFT)
    if shiftDown then
      self.Entity:delete(true)
      self:Remove()
    else
      XeninUI:SimpleQuery("Delete", "Are you sure you want to delete this?", "Yes, delete", function()
        self.Entity:delete(true)
        self:Remove()
      end, "No", function()
        if (self:IsHovered()) then return end

        self.Delete:SetVisible(false)
      end)
    end
  end

  XeninUI:DownloadIcon(self, "2QGKAd6")
end

function PANEL:PerformLayout(w, h)
  self.Delete:SetPos(8, 8)
  local size = 48 - 16
  self.Delete:SetSize(size, size)
end

function PANEL:SetEntity(entity)
  self.Entity = entity
  self.Id = entity:getId()
  self.Name = entity.transformName and entity:transformName(entity:getName()) or entity:getName()
  if istable(self.Name) then
    local tbl = self.Name
    self.Name = tbl[1]
  end
  self.Color = entity.getColor and entity:getColor() or color_white
  if (type(self.Color) != "Color") then
    self.Color = color_white
  end

  timer.Simple(0.2, function()
    if (!IsValid(self)) then return end
    if (self.Id != 1) then return end


  end)
end

function PANEL:Paint(w, h)
  local name = self.Name
  local font = "Xenin.Configurator.Admin.Panel.Setting"
  if (!name or name == "") then
    name = "Unnamed"
    font = "Xenin.Configurator.Admin.Panel.Setting.Italic"
  end

  local x = self.Delete:IsVisible() and 8 + self.Delete:GetWide() + 8 or 8
  draw.SimpleText(name, font, x, 48 / 2, self.Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

  surface.SetDrawColor(100, 100, 100)
  surface.DrawLine(0, 48 - 1, w, 48 - 1)

  local size = 48 / 3
  XeninUI:DrawIconRotated(w - size - 8, size + size / 2, size, size, self.Rotation, self, self.ArrowColor)
end

function PANEL:CreateSettings()
  self.Settings = self:Add("Xenin.Configurator.Admin.Entity.Row.Settings")
  self.Settings:AddSettings(self.Entity)
  self.Settings:SetTall(0)
  self.Settings.GetChildSize = function(pnl)
    local height = 0
    local size = 0
    for i, v in ipairs(pnl.Settings) do
      if (!v:IsVisible()) then continue end

      size = size + 1
      height = height + v:GetTall()
    end
    height = height - (size * 3)

    return height
  end
end

function PANEL:SetExpanded(state)
  self:Lerp("Rotation", state and 180 or 0, 0.4)

  if (!IsValid(self.Settings)) then
    self:CreateSettings()
  end

  local size = self.Settings:GetChildSize()
  self.Settings:LerpHeight(state and size or 0, 0.4)
end

function PANEL:DoClick()
  self.State = !self.State
  self:SetExpanded(self.State)
end

function PANEL:OnCursorEntered()
  if (!self.Delete:IsHovered()) then
    self.Delete:SetVisible(true)
  end

  self:LerpColor("ArrowColor", color_white)
end

function PANEL:OnCursorExited()
  if (!self.Delete:IsHovered()) then
    self.Delete:SetVisible(false)
  end

  if (self.State) then return end

  self:LerpColor("ArrowColor", Color(180, 180, 180))
end

vgui.Register("Xenin.Configurator.Admin.Entity.Row", PANEL, "DButton")
