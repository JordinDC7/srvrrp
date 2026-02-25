local PANEL = {}

XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Setting", 18)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Setting.Italic", 18, nil, {
italic = true
})

function PANEL:Init()
  self:Dock(TOP)
  self:DockMargin(0, 48, 0, 0)
  self:DockPadding(0, 0, 0, 0)

  self.Settings = {}
end

function PANEL:AddSettings() end

function PANEL:AddSetting(id, name, type, tbl)
  if tbl == nil then tbl = {}
  end
  tbl.data = tbl.data or {}

  local panel = self:Add("DPanel")
  panel.Id = id
  panel:Dock(TOP)
  panel:SetTall(48)
  panel:DockMargin(0, 0, 0, -4)
  panel.Paint = function(pnl, w, h)
    draw.SimpleText(name, "Xenin.Configurator.Admin.Panel.Setting", 8, 48 / 2, Color(145, 145, 145), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end
  panel.PerformLayout = function(pnl, w, h)
    if IsValid(panel.Overlay) then
      panel.Overlay:SetSize(w, h)
    end
  end

  if tbl.readOnly then
    panel.Overlay = panel:Add("DPanel")
    panel.Overlay:SetZPos(2)
    panel.Overlay.Color = ColorAlpha(XeninUI.Theme.Navbar, 150)
    panel.Overlay.Paint = function(pnl, w, h)
      XeninUI:DrawRoundedBox(6, 0, 8, w, h - 16, pnl.Color)

      if (!pnl:IsHovered()) then return end

      draw.SimpleText("Read only", "Xenin.Configurator.Admin.Panel.Setting", w / 2, h / 2, XeninUI.Theme.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
  end
  if tbl.hide then
    panel:SetVisible(false)
  end

  local input = XeninUI.Configurator:CreateInputPanel(type, self, tbl, {
    id = id,
    name = name,
    type = type,
    parent = panel
  })
  input:Dock(RIGHT)
  input:SetParent(panel)
  if (input.SetData and tbl.data) then
    input:SetData(tbl.data)
  end
  if (input.SetInput and tbl.value) then
    input:SetInput(tbl.value)
  end
  if tbl.func then
    tbl.func(input)
  end
  if tbl.fetch then
    tbl.fetch(input)
  end
  input.onChange = function(pnl, ...)
    if (!isfunction(tbl.onChange)) then return end

    tbl.onChange(pnl, ...)
  end
  panel.Input = input

  table.insert(self.Settings, panel)
end

function PANEL:GetSettings()
  local tbl = {}
  for i, v in ipairs(self.Settings) do
    tbl[v.Id] = v.Input:GetSettingValue()
  end

  return tbl
end

function PANEL:Paint(w, h)
  surface.SetDrawColor(100, 100, 100)
  surface.DrawLine(1, h - 1, w - 1, h - 1)
end

vgui.Register("Xenin.Configurator.Admin.SettingsBase", PANEL, "DPanel")
