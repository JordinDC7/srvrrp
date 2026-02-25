local PANEL = {}

function PANEL:SetScript(script)
  self.script = script
  self.ctr = XeninUI.Configurator:FindControllerByScriptName(script)
end

function PANEL:Call(id, default, ...)
  local value = self.Template[id] or default

  if isfunction(value) then
    return value(...)
  else
    return value
  end
end

function PANEL:OnSearch(text)
  text = text:lower()

  local panels = self.Layout:GetChildren()
  for i, v in ipairs(panels) do
    local result = v:Search(text)
    v:SetVisible(result)
  end

  self.Layout:InvalidateLayout()
end

function PANEL:SetData(tbl)
  assert(tbl ~= nil, "cannot destructure nil value")
  local __entity, name, script = tbl.__entity, tbl.name, tbl.script

  self:SetScript(script)
  self.Entity = __entity
  self:SetTitle(name)

  self.Navbar:SetVisible(false)
  self.Template = XeninUI.Configurator.Entities:get(self.Entity)
  self.BaseEnt = XeninUI.Configurator.Entities:create(self.Entity)

  self.TopBar = self:Add("Panel")
  self.TopBar:Dock(TOP)
  self.TopBar:DockMargin(0, 16, 0, 8)

  self.Subtitle = self.TopBar:Add("DLabel")
  self.Subtitle:SetFont("Xenin.Configurator.Admin.Panel.Navbar")
  self.Subtitle:SetText("Subtitle")

  self.Save.DoClick = function(pnl)
    for _, row in ipairs(self.Layout:GetChildren()) do
      if (row.StartedActive and !row.Active) then
        row.Entity:delete(true)
        row:DoSaveAnimation(XeninUI.Theme.Red)
        row.StartedActive = false

        continue
      end
      if (!row.Active) then continue end

      local ent = XeninUI.Configurator.Entities:create(self.Entity)
      local settings = IsValid(row.Settings) and row.Settings.Rows:GetSettings()
      if (!settings) then continue end
      for i, v in pairs(settings) do
        ent["set" .. tostring(i)](ent, v)
      end

      row.StartedActive = true
      row:DoSaveAnimation(XeninUI.Theme.Green)
      ent:save(true)
    end
  end

  self.Layout = self.Scroll:Add("DIconLayout")
  self.Layout:Dock(TOP)
  self.Layout:DockMargin(0, 0, 8, 0)
  self.Layout:SetBorder(0)
  self.Layout:SetSpaceY(8)
  self.Layout:SetSpaceX(8)
  self.Layout.Columns = self:Call("gridColumns", 5)
  self.Layout.PerformLayout = function(pnl, w, h)
    local children = pnl:GetChildren()
    local count = pnl.Columns
    local width = w / math.min(count, #children)

    local x = 0
    local y = 0

    local spacingX = pnl:GetSpaceX()
    local spacingY = pnl:GetSpaceY()
    local border = pnl:GetBorder()
    local innerWidth = w - border * 2 - spacingX * (count - 1)

    for i, child in ipairs(children) do
      if (!IsValid(child)) then continue end
      if (!child:IsVisible()) then continue end

      child:SetPos(border + x * innerWidth / count + spacingX * x, border + y * child:GetTall() + spacingY * y)
      child:SetSize(self:Call("gridColumnWidth", function()
        return innerWidth / count
      end, innerWidth, count, w, h, x, y), self:Call("gridColumnHeight", function()
        return innerWidth / count
      end, innerWidth, count, w, h, x, y))

      x = x + 1
      if (x >= count) then
        x = 0
        y = y + 1
      end
    end

    pnl:SizeToChildren(false, true)
  end

  self:CreateContent()
end

XeninUI:CreateFont("Xenin.Configurator.Grid", 12)

local matTick = Material("xenin/tick.png", "smooth")
function PANEL:CreateColumn(data, index)
  local panel = self.Layout:Add("DButton")
  panel:SetText("")
  panel.BackgroundColor = XeninUI.Theme.Background
  panel.OutlineColor = XeninUI.Theme.Navbar
  panel.TextColor = Color(174, 174, 174)
  panel.StartedActive = tobool(data.isActive)
  panel.Search = data.search or function(pnl, text)
    return pnl.Name:find(text)
  end
  panel.Entity = data.isActive or XeninUI.Configurator.Entities:create(self.Entity)
  panel.Name = panel.Entity and panel.Entity.getName and panel.Entity:getName()
  if (!panel.Name) then
    panel.Name = data.name or "Unknown name"
  end
  self:Call("gridSetDefaultData", function() end, panel.Entity, data, index)
  panel.SelectionAlpha = 0
  panel.Paint = function(...)
    self:Call("gridPaint", function(pnl, w, h)
      draw.RoundedBox(6, 0, 0, w, h, pnl.BackgroundColor)

      pnl:DrawSelected(w, h)
    end, ...)
  end
  panel.DrawSelected = function(...)
    self:Call("gridDrawSelected", function(pnl, w, h)
      local alpha = pnl.SelectionAlpha
      if (alpha <= 1) then return end

      local size = h * 0.25
      local x = w / 2 - size / 2
      local y = h / 2 - size / 2
      local col = ColorAlpha(XeninUI.Theme.Accent, alpha / 8)

      local topRight = !pnl.Settings:IsVisible()
      local bottomRight = true
      if pnl.Settings:IsVisible() then
        bottomRight = pnl.Settings:GetTall() < (h * 0.95)
      end
      XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, col, true, topRight, true, bottomRight)

      if (true) then return end
      XeninUI:MaskInverse(function()
        XeninUI:DrawCircle(w / 2, h / 2, size * 0.85, 30, col)
      end, function()
        XeninUI:DrawCircle(w / 2, h / 2, size, 30, col)
      end)

      surface.SetDrawColor(col)
      surface.SetMaterial(matTick)
      surface.DrawTexturedRect(x + 1, y + 1, size, size)
    end, ...)
  end
  panel.PaintOver = function(pnl, w, h)
    self:Call("gridPaintOver", function(pnl, w, h)
      local topRight = !pnl.Settings:IsVisible()
      local bottomRight = true
      if pnl.Settings:IsVisible() then
        bottomRight = pnl.Settings:GetTall() < (h * 0.95)
      end
      XeninUI:MaskInverse(function()
        XeninUI:DrawRoundedBoxEx(6, 1, 1, w - 2, h - 2, pnl.OutlineColor, true, topRight, true, bottomRight)
      end, function()
        XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, pnl.OutlineColor, true, topRight, true, bottomRight)
      end)

      if (!IsValid(pnl.Display)) then
        draw.SimpleText("No Image", "Xenin.Configurator.Grid", w / 2, h / 2, Color(174, 174, 174), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end



      XeninUI.DrawMultiLine(pnl.Name, "Xenin.Configurator.Grid", w - 16, 16, w / 2, h - 8, pnl.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end, pnl, w, h)

    if (!pnl.SaveAnimation) then return end

    local size = math.max(w, h)
    XeninUI:Mask(function()
      XeninUI:DrawRoundedBox(6, 0, 0, w, h, color_white)
    end, function()
      XeninUI:DrawCircle(w / 2, h / 2, size * (pnl.SaveAnimation * 1.2), 30, ColorAlpha(pnl.SaveColor, 255 - (pnl.SaveAnimation * 255)))
    end)
  end
  panel.OnCursorEntered = function(...)
    self:Call("gridOnCursorEntered", function(pnl)
      pnl:LerpColor("TextColor", color_white)
      pnl:LerpColor("OutlineColor", ColorAlpha(XeninUI.Theme.Accent, 150))
    end, ...)
  end
  panel.OnCursorExited = function(...)
    if (panel.Settings:IsVisible()) then return end

    self:Call("gridOnCursorExited", function(pnl)
      pnl:LerpColor("TextColor", Color(174, 174, 174))
      pnl:LerpColor("OutlineColor", XeninUI.Theme.Navbar)
    end, ...)
  end
  panel.DoSaveAnimation = function(pnl, color)
    if color == nil then color = XeninUI.Theme.Green
    end
    pnl.SaveColor = color
    pnl.SaveAnimation = 0
    pnl:Lerp("SaveAnimation", 1, 0.7, function()
      pnl.SaveAnimation = nil
    end)
  end
  panel.DoClick = function(pnl)
    self:Call("gridDoClick", function(pnl)
      pnl:SetState(!pnl.Active)
    end, pnl)
  end
  panel.SetState = function(pnl, state)
    local instant = pnl.Active == nil
    pnl.Active = state

    local val = state and 255 or 0
    if instant then
      pnl.SelectionAlpha = val
    else
      pnl:Lerp("SelectionAlpha", val)
    end
  end
  panel:SetState(tobool(data.isActive))

  if (data.display and data.display != "") then
    local isModel = data.display:find(".mdl")
    local panelClass = isModel and "DModelPanel" or "Panel"
    if (isModel and data.isSpawnIcon) then
      panelClass = "SpawnIcon"
    end
    panel.Display = panel:Add(panelClass)
    panel.Display:Dock(FILL)
    panel.Display:SetMouseInputEnabled(false)
    if isModel then
      panel.Display:SetModel(data.display)
      if data.isSpawnIcon then
        panel.Display:DockMargin(8, 8, 8, 8)
      else
        panel.Display.LayoutEntity = function() end
        if IsValid(panel.Display.Entity) then
          local mn, mx = panel.Display.Entity:GetRenderBounds()
          local size = 0
          size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
          size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
          size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
          panel.Display:SetFOV(45)
          panel.Display:SetCamPos(Vector(size, size, size))
          panel.Display:SetLookAt((mn + mx) * 0.5)
          if data.color then
            panel.Display:SetColor(data.color)
          end
        end
      end
    elseif (isstring(data.display) and data.display != "") then
      XeninUI:DownloadIcon(panel.Display, data.display)
      panel.Display.Paint = function(pnl, w, h)
        XeninUI:DrawIcon(8, 8, w - 16, h - 16, pnl)
      end
    end
  end

  panel.Cog = panel:Add("DButton")
  panel.Cog:SetText("")
  XeninUI:DownloadIcon(panel.Cog, "CEIrmnK")
  panel.Cog.Color = Color(174, 174, 174)
  panel.Cog.Paint = function(pnl, w, h)
    XeninUI:DrawIcon(4, 4, w - 8, h - 8, pnl, pnl.Color)
  end
  panel.Cog.OnCursorEntered = function(pnl)
    panel:OnCursorEntered()
    pnl:LerpColor("Color", XeninUI.Theme.Accent)
  end
  panel.Cog.OnCursorExited = function(pnl)
    panel:OnCursorExited()
    pnl:LerpColor("Color", Color(174, 174, 174))
  end
  panel.Cog.DoClick = function(pnl)
    local vis = !panel.Settings:IsVisible()
    panel.Settings:SetVisible(vis)

    if vis then
      panel.Settings.JustOpened = true
      panel.Settings:SetTall(panel.Settings.Rows:GetChildSize())
      local aX, aY = panel:LocalToScreen()
      aX = aX + panel:GetWide()
      panel.Settings:SetPos(aX, aY)
      panel.Settings:MakePopup()
    end
  end

  panel.Settings = vgui.Create("EditablePanel")
  panel.Settings:SetZPos(100)
  panel.Settings:SetDrawOnTop(true)
  panel.Settings:SetVisible(false)
  panel.Settings:SetTall(0)
  panel.Settings:SetWide(self:Call("gridSettingsWidth", 250))
  panel.Settings.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Background, false, true, false, true)

    local bottomLeft = panel:GetTall() < (h * 0.95)
    XeninUI:MaskInverse(function()
      XeninUI:DrawRoundedBoxEx(6, 1, 1, w - 2, h - 2, XeninUI.Theme.Background, false, true, bottomLeft, true)
    end, function()
      XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, panel.OutlineColor, false, true, bottomLeft, true)
    end)
  end
  panel.Settings.Think = function(pnl)

    local focus = pnl:HasHierarchicalFocus()
    if (focus) then return end
    if pnl.JustOpened then
      pnl.JustOpened = false

      return
    end

    pnl:SetVisible(false)
    if (panel:IsHovered() or panel:IsChildHovered()) then return end
    panel:OnCursorExited()
  end

  panel.Settings.Rows = panel.Settings:Add("Xenin.Configurator.Admin.Entity.Row.Settings")
  panel.Settings.Rows:DockMargin(4, 4, 4, 4)
  panel.Settings.Rows:AddSettings(panel.Entity or self.BaseEnt)
  panel.Settings.Rows.Parent = panel
  panel.Settings.Rows:Dock(FILL)
  panel.Settings.Rows.Paint = function() end
  panel.Settings.Rows.GetChildSize = function(pnl)
    local height = 0
    local size = 0
    for i, v in ipairs(pnl.Settings) do
      if (!v:IsVisible()) then continue end

      size = size + 1
      height = height + v:GetTall()
    end
    height = height - (size * 3)

    return height + 8
  end

  panel.OnRemove = function(pnl)
    if (!IsValid(panel.Settings)) then return end

    panel.Settings:Remove()
  end
  panel.PerformLayout = function(pnl, w, h)
    pnl.Cog:SetSize(24, 24)
    pnl.Cog:AlignTop(4)
    pnl.Cog:AlignRight(4)
  end


  self:Call("gridPostInit", function() end, panel)
end

function PANEL:CreateContent()
  local data = self.Template.getAllEntities()
  local content = self.Template.getGridContent()

  for i, v in ipairs(content) do
    local tbl = self:Call("getGridData", function(tbl)
      return tbl end, v)
    if (!tbl) then continue end

    self:CreateColumn(tbl, i)
  end
end

vgui.Register("Xenin.Configurator.Admin.EntityGrid", PANEL, "Xenin.Configurator.Admin.Panel")
