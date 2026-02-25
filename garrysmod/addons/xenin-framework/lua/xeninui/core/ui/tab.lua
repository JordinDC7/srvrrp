XeninUI:CreateFont("Xenin.Framework.Config.Container.Name", 24)
XeninUI:CreateFont("Xenin.Framework.Config.Container.Desc", 18)
XeninUI:CreateFont("Xenin.Framework.Config.Tabs", 26)

local PANEL = {}

function PANEL:Init()
  self.Name = "No Name"

  self:DockMargin(0, 0, 8, 0)

  self.Text = self:Add("DPanel")
  self.Text:Dock(TOP)
  self.Text.Offset = draw.GetFontHeight("Xenin.Framework.Config.Container.Name") + 4
  self.Text.Paint = function(pnl, w, h)
    XeninUI:DrawShadowText(self.Name, "Xenin.Framework.Config.Container.Name", 0, 0, Color(231, 232, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 150)
    XeninUI:DrawShadowText(self.Desc, "Xenin.Framework.Config.Container.Desc", 0, pnl.Offset, Color(156, 156, 156), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 150)
  end
  self.Text:SetTall(50)
end

function PANEL:Paint(w, h)
  draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Primary)
end

function PANEL:SetName(name)
  self.Name = name
end

function PANEL:SetDesc(desc)
  self.Desc = desc
end

function PANEL:PerformLayout(w, h) end

vgui.Register("Xenin.Framework.Config.Container", PANEL, "XeninUI.Panel")

local PANEL = {}

XeninUI:CreateFont("Xenin.Framework.Category", 22)

function PANEL:SetData(data, scriptId)
  self.Data = data
  self.Panels = {}
  self.Cats = {}

  self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
  self.Scroll:Dock(FILL)

  self.Tabs = self:Add("XeninUI.NavbarBody")
  self.Tabs:Dock(TOP)
  self.Tabs:DockMargin(-6, 0, -12, 8)
  self.Tabs:SetTall(32)
  self.Tabs:SetBody(self.Scroll)
  self.Tabs.Margin = 12

  self.Save = self:Add("XeninUI.ButtonV2")
  self.Save:SetVisible(false)
  self.Save:SetText("Save")
  self.Save:SetGradient(false)
  self.Save:SetSolidColor(XeninUI.Theme.GreenDark)
  self.Save.DoClick = function(pnl)
    local config = {}
    for i, v in pairs(self.Panels) do
      config[i] = v:GetValue()
    end
    for i, v in pairs(self.Cats) do
      config[i] = {}
    end

    XeninUI.Config:save(scriptId, config)
  end

  self:PostInit()
end

function PANEL:UpdateSaveVisibility()
  local difference
  local function recursiveCheck(tbl)
    for i, v in ipairs(tbl) do
      if (!v.children) then
        if (v.value != self.Panels[v.key]:GetValue()) then
          difference = true

          break
        end

        continue
      end

      recursiveCheck(v.children)
    end
  end

  for i, v in ipairs(self.Data) do
    recursiveCheck(v.children)
  end

  self.Save:SetVisible(difference)
  if difference then
    self:InvalidateLayout()
  end
end

function PANEL:PostInit()
  self:CreateConfigRecursive(self.Data)
end

PANEL.Types = {
  cat = function(self, tbl, parent)





    self.Tabs:AddTab(tbl.name, "Panel", {
    fill = TOP })
    local panel = self.Tabs.Tabs[#self.Tabs.Tabs].Panel
    panel:DockMargin(0, 0, 0, 8)
    self.Tabs:SetActive(1)

    self:CreateConfigRecursive(tbl.children, panel)

    return panel
  end,
  textentry = function(self, tbl, parent)
    local panel = parent:Add("Xenin.Framework.Config.Container")
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 8, 8)
    panel:SetName(tbl.name)
    panel:SetDesc(tbl.desc)
    panel:SetTall(104)
    panel.GetValue = function(pnl)
      return panel.Content:GetText()
    end
    panel:DockPadding(8, 6, 8, 8)

    panel.Content = panel:Add("XeninUI.TextEntry")
    panel.Content:Dock(FILL)
    panel.Content:DockMargin(0, 4, 0, 0)
    panel.Content:SetText(XeninUI.Config:get(tbl.key) or tbl.value)
    panel.Content.textentry:SetUpdateOnType(true)
    panel.Content.textentry.OnValueChange = function(pnl, w, h)
      self:UpdateSaveVisibility()
    end

    if tbl.numeric then
      panel.Content.textentry:SetNumeric(true)
    end

    return panel
  end,
  checkbox = function(self, tbl, parent)
    local panel = parent:Add("Xenin.Framework.Config.Container")
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 8, 8)
    panel:SetName(tbl.name)
    panel:SetDesc(tbl.desc)
    panel:SetTall(104)
    panel.GetValue = function(pnl)
      return panel.Content:GetState()
    end
    panel:DockPadding(8, 6, 8, 8)

    panel.Content = panel:Add("XeninUI.Checkbox")
    panel.Content:Dock(LEFT)
    panel.Content:DockMargin(0, 4, 0, 0)
    panel.Content:SetWide(100)
    panel.Content:SetState(tbl.value, true)
    panel.Content.OnStateChanged = function()
      self:UpdateSaveVisibility()
    end

    return panel
  end
}

function PANEL:CreateConfigRecursive(tbl, parent)
  if parent == nil then parent = self.Scroll
  end
  for i, v in ipairs(tbl) do
    local panel = self.Types[v.type](self, v, parent)
    if (v.type == "cat") then
      self.Cats[v.key] = v

      continue
    end

    self.Panels[v.key] = panel
  end
end

function PANEL:PerformLayout(w, h)
  self.Save:AlignRight(24)
  self.Save:AlignBottom(8)
  self.Save:SizeToContentsX(24)
  self.Save:SizeToContentsY(8)
  self.Save:SetRoundness(self.Save:GetTall() / 2)

  for i, v in ipairs(self.Tabs.Tabs) do
    local pnl = v.Panel
    local h = 0
    for i, v in ipairs(pnl:GetChildren()) do
      h = h + v:GetTall()
      local l, t, b, r = v:GetDockMargin()
      h = h + (t + b)
    end

    pnl:SetTall(h)
  end
end

vgui.Register("Xenin.Framework.Config", PANEL, "XeninUI.Panel")

local PANEL = {}

XeninUI:CreateFont("Xenin.Framework.Title", 26)
XeninUI:CreateFont("Xenin.Framework.Subtitle", 18)

function PANEL:OnSwitchedTo()
  if self.HaveSwitchedTo then return end

  self.HaveSwitchedTo = true
  self:PostInit()
end

function PANEL:PostInit()
  self:DockPadding(16, 16, 16, 16)

  local __lauxi0 = self.Data
  assert(__lauxi0 ~= nil, "cannot destructure nil value")
  local version, author, config, id, licensee, licenseeProof = __lauxi0.version, __lauxi0.author, __lauxi0.config, __lauxi0.id, __lauxi0.licensee, __lauxi0.licenseeProof
  local titleHeight = draw.GetFontHeight("Xenin.Framework.Title")
  local versionStr = version == "{{ script_version_name }}" and "DEV BUILD" or version
  self.Info = self:Add("DPanel")
  self.Info:Dock(TOP)
  self.Info:SetTall(48)
  self.Info.Paint = function(pnl, w, h)
    XeninUI:DrawShadowText("Version " .. tostring(versionStr), "Xenin.Framework.Title", 0, 0, color_white, nil, nil, 1, 150)
    XeninUI:DrawShadowText("Author: " .. tostring(author), "Xenin.Framework.Subtitle", 0, titleHeight, Color(183, 183, 183), nil, nil, 1, 150)
  end

  self.Tabs = self:Add("XeninUI.NavbarBody")
  self.Tabs:Dock(TOP)
  self.Tabs:DockMargin(-12, 8, -12, 0)
  self.Tabs:SetTall(40)
  self.Tabs.Font = "Xenin.Framework.Config.Tabs"
  self.Tabs:SetBody(self)
  if XeninUI.Debug then
    self.Tabs:AddTab("Updates")
    self.Tabs:AddTab("Config", "Xenin.Framework.Config", config, id)
    self.Tabs:SetActive(2)
  else
    self.Tabs:AddTab("License", "Xenin.Framework.Dev", {
      licensee = licensee,
      proof = licenseeProof
    })
    self.Tabs:SetActive(1)
  end
end

vgui.Register("Xenin.Framework.Tab", PANEL)

local PANEL = {}

XeninUI:CreateFont("Xenin.Framework.Dev.Licensee", 48)
XeninUI:CreateFont("Xenin.Framework.Dev", 20)

function PANEL:Paint(w, h)
  XeninUI:DrawShadowText("Licensed to " .. tostring(self.licensee), "Xenin.Framework.Dev.Licensee", w / 2, 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 150)
  XeninUI:DrawShadowText("Proof: " .. tostring(self.proof), "Xenin.Framework.Dev", w / 2, 16 + draw.GetFontHeight("Xenin.Framework.Dev.Licensee") + 4, Color(242, 242, 242), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 150)
  XeninUI:DrawShadowText("This menu is currently in development, check back later", "Xenin.Framework.Dev", w / 2, h / 2, Color(183, 183, 183), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, 150)
end

function PANEL:SetData(data)
  self.licensee = data.licensee
  self.proof = data.proof
end

vgui.Register("Xenin.Framework.Dev", PANEL)

local PANEL = {}
XeninUI:CreateFont("XeninUI.NavbarBody", 18)
AccessorFunc(PANEL, "m_body", "Body")

function PANEL:Init()
  self.Tabs = {}
  self.Options = {}

  self.Line = self:Add("DPanel")
  self.Line:SetMouseInputEnabled(false)
  self.Line:SetTall(2)
  self.Line.x = 12
  self.Line.Paint = function(pnl, w, h)
    surface.SetDrawColor(XeninUI.Theme.Accent)
    surface.DrawRect(0, 0, w, h)
  end
end

function PANEL:PerformLayout(w, h)
  self.Line:SetPos(self.Line.x, h - 2)
end

function PANEL:SetActive(id)
  if IsValid(self.Tabs[self.Active]) then
    self.Tabs[self.Active]:LerpColor("TextColor", Color(183, 183, 183))
    self.Tabs[self.Active].Panel:SetVisible(false)
  end

  self.Active = id

  if IsValid(self.Tabs[self.Active]) then
    local margin = self.Margin or 24
    local x = margin / 2
    for i = 1, id - 1 do
      x = x + self.Tabs[i]:GetWide()
    end

    self.Line:LerpMoveX(x, 0.3)
    self.Line:LerpWidth(self.Tabs[id]:GetWide() - margin, 0.3)

    self.Tabs[self.Active]:LerpColor("TextColor", color_white)
    self.Tabs[self.Active].Panel:SetVisible(true)
  end
end

function PANEL:SetOptions(options)
  self.Options = options
end

function PANEL:AddTab(name, panelClass, data, scriptId)
  if data == nil then data = {}
  end
  if scriptId == nil then scriptId = "none"
  end
  local margin = self.Margin or 24
  local btn = self:Add("DButton")
  btn:Dock(LEFT)
  btn:SetText(self.Options.upper and name:upper() or name)
  btn:SetFont(self.Font or "XeninUI.NavbarBody")
  btn:SizeToContentsX(margin)
  btn:SizeToContentsY()
  btn.TextColor = Color(183, 183, 183)
  btn.Paint = function(pnl, w, h)
    pnl:SetTextColor(pnl.TextColor)
  end
  btn.DoClick = function(pnl)
    self:SetActive(pnl.Id)
  end

  local id = table.insert(self.Tabs, btn)
  self.Tabs[id].Id = id

  if (id == 1) then
    self.Line:SetWide(btn:GetWide() - margin)
  end

  local panel = self:GetBody():Add(panelClass or "XeninUI.Panel")
  panel:Dock(data.fill or FILL)
  panel:SetVisible(false)
  if panel.SetData then
    panel:SetData(data, scriptId)
  end

  btn.Panel = panel
end

vgui.Register("XeninUI.NavbarBody", PANEL)
