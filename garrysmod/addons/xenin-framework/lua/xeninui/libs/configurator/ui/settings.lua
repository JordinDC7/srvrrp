local PANEL = {}

XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Title", 40)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Navbar", 24)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Setting", 18)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Setting.Italic", 18, nil, {
italic = true
})
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Category", 22)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Selectbox", 18)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Save", 24)

AccessorFunc(PANEL, "m_networkId", "NetworkId")

function PANEL:OnSearch() end

function PANEL:Init()
  self.Categories = {}
  self.Settings = {}

  self:DockPadding(16, 16, 16, 16)

  self:SetNetworkId("settings")

  self.Navbar = self:Add("XeninUI.Navbar")
  self.Navbar:Dock(TOP)
  self.Navbar.accent = XeninUI.Theme.Purple
  self.Navbar.textActive = color_white
  self.Navbar.font = "Xenin.Configurator.Admin.Panel.Navbar"
  self.Navbar.padding = 40
  self.Navbar.startHeight = 50
  self.Navbar.dockLeft = 0
  self.Navbar.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Primary, true, true, false, false)
  end
  self.Navbar:SetBody(self)

  self.Bottom = self:Add("Panel")
  self.Bottom:Dock(BOTTOM)
  self.Bottom:DockMargin(0, 16, 0, 0)
  self.Bottom:SetTall(32)

  self.Save = self.Bottom:Add("XeninUI.ButtonV2")
  self.Save:Dock(RIGHT)
  self.Save:SetText("Save")
  self.Save:SetFont("Xenin.Configurator.Admin.Panel.Save")
  self.Save:SetRoundness(6)
  self.Save:SetSolidColor(XeninUI.Theme.Accent)
  self.Save:SetHoverColor(XeninUI.Theme.Green)
  self.Save:SetTextColor(color_white)
  self.Save:SizeToContentsX(24)
  self.Save.DoClick = function(pnl)
    local id = self:GetNetworkId()
    local settings = {}
    for tabName, tab in pairs(self.Navbar.panels) do
      for i, v in ipairs(tab.Settings) do
        if (!v:IsVisible()) then continue end

        local id = v.Data.id
        local val = v.Input:GetSettingValue()

        self.ctr:set(id, val)
        settings[id] = val
      end
    end

    XeninUI.Configurator.Network:sendSaveSettings(self.script, settings)
  end
  XeninUI:AddRippleClickEffect(self.Save, color_black)
end

function PANEL:PerformLayout(w, h)
  self.Navbar:SetTall(self.Navbar.startHeight)
end

function PANEL:SetTitle(title) end

function PANEL:CreateCategory(name)
  local panel = self.Body:Add("DPanel")
  panel:Dock(TOP)
  panel:DockPadding(0, 36, 0, 40)
  panel.Name = name
  panel.Paint = function(pnl, w, h)

    draw.SimpleText(pnl.Name, "Xenin.Configurator.Admin.Panel.Category", 8, 32 / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end
  panel.PerformLayout = function(pnl, w, h)
    pnl:SizeToChildren(false, true)
  end

  return panel
end

function PANEL:GetCategories()
  return self.Categories
end

function PANEL:GetCategory(cat)
  return self.Categories[cat]
end

function PANEL:SetController(ctr)
  local tabs = self.ctr:getSettingTabs()
  local settings = self.ctr:getSettingsByCategory()
  for i, v in ipairs(tabs) do
    self.Navbar:AddTab(v.name, "Xenin.Configurator.Admin.Panel.Setting", settings[v.name])
  end
  if tabs[1] then
    self.Navbar:SetActive(tabs[1].name)
  end
end

function PANEL:SetSettings(tbl)
  self.settings = tbl

  for i, v in ipairs(tbl) do
    self:AddSetting(v)
  end
end

function PANEL:SetScript(script)
  self.script = script
  self.ctr = XeninUI.Configurator:FindControllerByScriptName(script)
end

function PANEL:SetData(data)
  self:SetTitle(data.name)
  self:SetController(self.ctr)
end

vgui.Register("Xenin.Configurator.Admin.Panel", PANEL, "XeninUI.Panel")


local PANEL = {}

function PANEL:Init()
  self.Categories = {}
  self.Settings = {}

  self.Top = self:Add("Panel")
  self.Top:Dock(TOP)
  self.Top.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Navbar, false, false, true, true)
  end

  self.Navbar = self.Top:Add("DPanel")
  self.Navbar:Dock(FILL)
  self.Navbar.Paint = function() end
  self.Navbar.SetActive = function(pnl, id)
    local active = pnl.Active
    pnl.Active = id

    local btn = pnl.Buttons[active]
    if IsValid(btn) then
      btn:LerpColor("TextColor", Color(145, 145, 145))
    end

    btn = pnl.Buttons[id]
    if (!IsValid(btn)) then return end

    if active then
      btn:LerpColor("TextColor", color_white)
      local cat = self:GetCategory(btn:GetText())
      if ispanel(cat) then
        self.Scroll:ScrollToChild(cat)
      end
    else
      btn.TextColor = color_white
    end
  end
  self.Navbar.Buttons = {}
  self.Navbar.AddButton = function(pnl, name)
    local btn = pnl:Add("DButton")
    btn:Dock(LEFT)
    btn:SetText(name)
    btn:SetFont("Xenin.Configurator.Admin.Panel.Setting.Navbar")
    btn:SizeToContentsX(24)
    btn:SizeToContentsY()
    btn.TextColor = Color(145, 145, 145)
    btn.Paint = function(pnl, w, h)
      pnl:SetTextColor(pnl.TextColor)
    end
    btn.OnCursorEntered = function(pnl)
      pnl:LerpColor("TextColor", color_white)
    end
    btn.OnCursorExited = function()
      if (pnl.Active == btn.Id) then return end

      btn:LerpColor("TextColor", Color(145, 145, 145))
    end
    btn.DoClick = function()
      pnl:SetActive(btn.Id)
    end

    local id = table.insert(pnl.Buttons, btn)
    pnl.Buttons[id].Id = id
  end
  self.Navbar.SetActiveButtonByName = function(pnl, name)
    for i, v in ipairs(pnl.Buttons) do
      if (v:GetText() != name) then continue end

      v:LerpColor("TextColor", color_white)
      pnl:SetActive(v.Id)
    end
  end

  self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
  self.Scroll:Dock(FILL)
  self.Scroll:DockMargin(0, 16, 0, 0)

  self.Body = self.Scroll:Add("Panel")

  self:SetActive(1)
end

function PANEL:SetData(data)
  if (!istable(data)) then return end

  self.settings = data
  for i, v in ipairs(data) do
    self:AddSetting(v)
  end
  self:SetActive(1)
end

function PANEL:CreateCategory(name)
  local panel = self.Body:Add("DPanel")
  panel:Dock(TOP)
  panel:DockPadding(0, 28, 0, 20)
  panel.Name = name
  panel.Paint = function(pnl, w, h)

    draw.SimpleText(pnl.Name, "Xenin.Configurator.Admin.Panel.Category", 8, 32 / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end
  panel.PerformLayout = function(pnl, w, h)
    pnl:SizeToChildren(false, true)
  end

  return panel
end

function PANEL:GetCategory(cat)
  return self.Categories[cat]
end

function PANEL:HighlightSetting(cat, id)
  for catId, catPnl in pairs(self.Categories) do
    if (catId != cat) then continue end

    for i, v in ipairs(catPnl:GetChildren()) do
      if (v.Data.id != id) then continue end

      v:Highlight()

      return v, i
    end
  end
end

function PANEL:AddSetting(tbl)
  if (!self.Categories[tbl.subCategory]) then
    local foundCat
    for i, v in pairs(self.Navbar.Buttons) do
      if (v:GetText() != tbl.subCategory) then continue end

      foundCat = true
      break
    end
    if (!foundCat) then
      self:AddButton(tbl.subCategory)
    end
    self.Categories[tbl.subCategory] = self:CreateCategory(tbl.subCategory)
  end

  local input = XeninUI.Configurator:CreateInputPanel(tbl.type, self, tbl)
  if input.SetData then
    input:SetData(tbl.data)
  end
  if input.SetInput then
    input:SetInput(tbl.value)
  end

  local panel = self.Categories[tbl.subCategory]:Add("DPanel")
  input:SetParent(panel)
  panel:Dock(TOP)
  panel.Data = tbl
  panel.Height = input.Height or 48
  panel:SetTall(input.Height or 48)
  panel.Input = input
  panel.Markup = markup.Parse("<font=Xenin.Configurator.Admin.Panel.Setting><color=145,145,145>" .. tostring(tbl.name) .. "</color></font>")
  panel.Paint = function(pnl, w, h)
    local x = 0
    if tbl.onPaint then x = x + tbl.onPaint(pnl, w, h)
    end
    surface.SetDrawColor(100, 100, 100)
    surface.DrawRect(0, h - 1, w, 1)

    pnl.Markup:Draw(x + 8, 48 / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end
  panel.FlashAlpha = 0
  panel.PaintOver = function(pnl, w, h)
    local alpha = pnl.FlashAlpha
    if (alpha <= 1) then return end

    surface.SetDrawColor(ColorAlpha(XeninUI.Theme.Green, alpha / (255 / 50)))
    surface.DrawRect(0, 0, w, h)

    XeninUI:MaskInverse(function()
      surface.DrawRect(1, 1, w - 2, h - 2)
    end, function()
      surface.SetDrawColor(ColorAlpha(XeninUI.Theme.Green, alpha))
      surface.DrawRect(0, 0, w, h)
    end)
  end
  panel.Highlight = function(pnl)
    pnl:EndAnimations()

    pnl:Lerp("FlashAlpha", 255, 0.7, function()
      timer.Simple(0.2, function()
        if (!IsValid(pnl)) then return end

        pnl:Lerp("FlashAlpha", 0, 0.5)
      end)
    end)
  end

  if tbl.func then
    tbl.func(input, panel)
  end
  if (tbl.onChange or tbl.data.onChange) then
    input.onChange = tbl.onChange or tbl.data.onChange
  end
  if tbl.data.postInit then
    tbl.data.postInit(input, panel)
  end
  if tbl.data.hidden then
    panel:SetVisible(false)
  end
  panel.PerformLayout = function(pnl, w, h)
    local l, t, r, b = pnl.Input:GetDockMargin()
    pnl.Input:SetTall(h - t - b)
    pnl.Input:SetPos(w - l - pnl.Input:GetWide() - r, t)
  end

  table.insert(self.Settings, panel)
end

function PANEL:SetActive(id)
  self.Navbar:SetActive(id)
end

function PANEL:AddButton(name)
  self.Navbar:AddButton(name)
end

function PANEL:PerformLayout(w, h)
  self.Top:SetTall(38)

  if IsValid(self.Body) then
    self.Body:SetWide(math.min(600, w - 56))
    self.Body:SizeToContentsY()
    self.Body:Center()
    self.Body:SizeToChildren(false, true)
  end

  for i, v in ipairs(self.Settings) do
    v:SetTall(v.Height or 48)
  end
end

XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Setting.Navbar", 18)

vgui.Register("Xenin.Configurator.Admin.Panel.Setting", PANEL, "XeninUI.Panel")
