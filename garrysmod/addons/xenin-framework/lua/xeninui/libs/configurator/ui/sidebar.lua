local PANEL = {}

XeninUI:CreateFont("Xenin.Configurator.Admin.Sidebar", 20)

function PANEL:Init()
  self.Tabs = {}
  self.Panels = {}

  self:DockPadding(5, 8, 16, 16)

end

function PANEL:SetActiveByName(name)
  for i, v in ipairs(self.Tabs) do
    if (v.Name != name) then continue end

    self:SetActive(v.Id)
    break
  end
end

function PANEL:GetActivePanel()
  return self.Panels[self.Active]
end

function PANEL:SetActive(id)
  local active = self.Active
  self.Active = id

  local tab = self.Tabs[active]
  local pnl = self.Panels[active]
  if IsValid(tab) then
    tab:OnCursorExited()
  end
  if IsValid(pnl) then
    pnl:SetVisible(false)
  end

  tab = self.Tabs[id]
  pnl = self.Panels[id]
  if IsValid(tab) then
    tab:OnCursorEntered()
  end
  if IsValid(pnl) then
    pnl:SetVisible(true)
  end
end

function PANEL:AddTab(name, icon, color, panel, script, rawData)
  local btn = self:Add("DButton")
  btn:Dock(TOP)
  btn:DockMargin(0, 0, 0, -4)
  btn:SetText("")
  btn:SetTall(42)
  btn.Name = name
  btn.Color = color
  btn.TextColor = Color(208, 208, 208)
  XeninUI:DownloadIcon(btn, icon)
  btn.Paint = function(pnl, w, h)
    XeninUI:DrawIcon(11, 11, h - 22, h - 22, pnl, color, color)

    draw.SimpleText(pnl.Name, "Xenin.Configurator.Admin.Sidebar", h, h / 2, pnl.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end
  btn.OnCursorEntered = function(pnl)
    pnl:LerpColor("TextColor", pnl.Color)
  end
  btn.OnCursorExited = function(pnl)
    if (self.Active == pnl.Id) then return end

    pnl:LerpColor("TextColor", Color(208, 208, 208))
  end
  btn.DoClick = function(pnl)
    self:SetActive(pnl.Id)
  end

  local panel = self:GetParent():Add(panel)
  panel:Dock(FILL)
  panel:SetVisible(false)
  if panel.SetScript then
    panel:SetScript(script)
  end
  if panel.SetData then
    panel:SetData(rawData)
  end

  local id = table.insert(self.Tabs, btn)
  self.Tabs[id].Id = id
  self.Panels[id] = panel
  self.Panels[id].Id = id
end

function PANEL:Paint(w, h)
  XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Navbar, false, false, true, false)
end

vgui.Register("Xenin.Configurator.Admin.Sidebar", PANEL)
