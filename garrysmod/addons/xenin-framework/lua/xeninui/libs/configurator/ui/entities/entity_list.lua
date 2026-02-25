local PANEL = {}

local matArrow = Material("xenin/next.png", "smooth")

XeninUI:CreateFont("Xenin.Configurator.Row.Title", 20)
XeninUI:CreateFont("Xenin.Configurator.Row.Subtitle", 14)

function PANEL:Init()
  self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
  self.Scroll:Dock(FILL)

  self.Body = self.Scroll:Add("Panel")

  self.Save.DoClick = function(pnl)
    for _, row in pairs(self.Rows) do
      row.Entity:save(true)
    end
  end
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

  if (!self.Template.getListView) then
    error("To use a list you need to implement a static getListView function for your model")
  end

  self.New = self.Body:Add("DButton")
  self.New:Dock(TOP)
  self.New:DockMargin(0, 0, 0, 12)
  self.New:SetText("")
  self.New:SetTall(48)
  self.New.Color = XeninUI.Theme.Background
  self.New.OutlineColor = XeninUI.Theme.Primary
  self.New.TextColor = Color(174, 174, 174)
  self.New.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Color)

    XeninUI:MaskInverse(function()
      XeninUI:DrawRoundedBox(6, 1, 1, w - 2, h - 2, pnl.OutlineColor)
    end, function()
      XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.OutlineColor)
    end)

    draw.SimpleText("Create New", "Xenin.Configurator.Row.Title", w / 2, h / 2, pnl.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  self.New.OnCursorEntered = function(pnl)
    pnl:LerpColor("OutlineColor", XeninUI.Theme.Green)
    pnl:LerpColor("TextColor", color_white)
  end
  self.New.OnCursorExited = function(pnl)
    pnl:LerpColor("OutlineColor", XeninUI.Theme.Primary)
    pnl:LerpColor("TextColor", Color(174, 174, 174))
  end
  self.New.DoClick = function(pnl)
    self.Body.Alpha = self.Body.Alpha || 255
    self.Body:LerpAlpha(0, 0.15, function()
      self.Body:SetAlpha(0)
      self:CreateNew(self.Template)
    end)
  end

  self.ToDelete = {}

  local rows = self.Template.getAllEntities()
  self.Rows = {}
  self.RowsIds = {}
  for i, v in pairs(rows) do
    self:CreateRow(v, i)
  end
end

function PANEL:CreateNew()
  local entity = XeninUI.Configurator.Entities:create(self.Entity)

  for i, v in pairs(self.Rows) do
    if (!IsValid(v)) then continue end

    v:SetVisible(false)
  end
  self.New:SetVisible(false)

  if IsValid(self.ListBody) then self.ListBody:Remove()end

  self.Body:LerpAlpha(255, 0.15, function()
    self.Body:SetAlpha(255)
  end)

  self.ListBody = self.Body:Add("Panel")
  self.ListBody.Alpha = 0
  self.ListBody:LerpAlpha(255, nil, function()
    self.ListBody:SetAlpha(255)
  end)
  self.ListBody:Dock(TOP)
  self.ListBody.Rows = {}

  self.ListBody.Header = self.ListBody:Add("Panel")
  self.ListBody.Header:Dock(TOP)
  self.ListBody.Header:DockMargin(0, 0, 0, 8)
  self.ListBody.Header:SetTall(32)
  self.ListBody.Header.Paint = function(pnl, w, h)
    draw.SimpleText(self.Template.selectRowString or "Select a row", "Xenin.Configurator.Row.Title", 8, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end

  self.ListBody.Header.Back = self.ListBody.Header:Add("XeninUI.ButtonV2")
  self.ListBody.Header.Back:Dock(RIGHT)
  self.ListBody.Header.Back:DockMargin(0, 6, 6, 0)
  self.ListBody.Header.Back:SetText("")
  self.ListBody.Header.Back:SetSolidColor(XeninUI.Theme.Primary)
  self.ListBody.Header.Back:SetRoundness(6)
  self.ListBody.Header.Back.Text = "Go Back"
  self.ListBody.Header.Back.PaintOver = function(pnl, w, h)
    surface.SetMaterial(matArrow)
    surface.SetDrawColor(color_white)
    local size = h - 14
    surface.DrawTexturedRectRotated(size, h / 2, size, size, 180)

    draw.SimpleText(pnl.Text, "Xenin.Configurator.Row.Subtitle", size * 1.75, h / 2, Color(174, 174, 174), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end
  surface.SetFont("Xenin.Configurator.Row.Subtitle")
  local tw = surface.GetTextSize(self.ListBody.Header.Back.Text)
  self.ListBody.Header.Back:SetWide((14 * 1.75) + tw + 8)
  self.ListBody.Header.Back.HasClicked = false
  self.ListBody.Header.Back.DoClick = function(pnl)
    if (pnl.HasClicked) then return end
    pnl.HasClicked = true

    self.ListBody:LerpAlpha(0, 0.15, function()
      self.ListBody:Remove()
      self.Body.Alpha = 0
      self.Body:LerpAlpha(255, 0.15)

      for i, v in pairs(self.Rows) do
        if (!IsValid(v)) then continue end

        v:SetVisible(true)
      end
      self.New:SetVisible(true)
      self:InvalidateLayout(true)
    end)
  end

  for i, v in ipairs(self.Template.getGridContent()) do
    local data = self.Template.getGridData(v)
    if (!data) then continue end
    local ent = XeninUI.Configurator.Entities:create(self.Entity)
    self.Template.gridSetDefaultData(ent, data, i)
    if (self.RowsIds[ent:getId()]) then continue end
    local search = self.Template.getListView(ent).search

    local row = self.ListBody:Add("Xenin.Configurator.Admin.EntityList.Row")
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 4)
    row:SetTall(56)
    row.DeleteDisabled = true
    row:SetEntity(ent, self.Template, true)
    row.Search = search or function(pnl, text)
      return pnl.Entity:getId():lower():find(text)
    end

    row.Edit:SetText("Select")
    row.Edit:SetSolidColor(XeninUI.Theme.OrangeRed)
    row.Edit.DoClick = function(pnl)
      self.ListBody:LerpAlpha(0, 0.15, function()
        self.ListBody:Remove()
        local newId = #self.Rows + 1
        self:CreateRow(row.Entity, newId)
        self:SwitchToEdit(row.Entity, self.Rows[newId], true)
        self:InvalidateLayout(true)
      end)
    end

    table.insert(self.ListBody.Rows, row)
  end

  self.ListBody.PerformLayout = function(pnl, w, h)
    pnl:SizeToChildren(false, true)
  end

  self:InvalidateLayout(true)
end

function PANEL:SwitchToEdit(entity, parent, isNew)
  local copy = table.Copy(entity)

  for i, v in pairs(self.Rows) do
    if (!IsValid(v)) then continue end

    v:SetVisible(false)
  end
  self.New:SetVisible(false)

  if IsValid(self.SettingsPanel) then self.SettingsPanel:Remove()end

  self.Body:LerpAlpha(255, 0.15, function()
    self.Body:SetAlpha(255)
  end)

  self.SettingsPanel = self.Body:Add("Xenin.Configurator.Admin.Entity.Row.Settings")
  self.SettingsPanel:DockMargin(0, 0, 0, 0)
  self.SettingsPanel.FadeOut = function(pnl)
    self.Body:LerpAlpha(0, 0.15, function()
      self.Body:SetAlpha(0)
      self.SettingsPanel:Remove()

      self.Body:LerpAlpha(255, 0.15, function()
        self.Body:SetAlpha(255)
      end)
      for i, v in pairs(self.Rows) do
        if (!IsValid(v)) then continue end

        v:SetVisible(true)
      end
      self.New:SetVisible(true)
      self:InvalidateLayout(true)
    end)
  end

  self.SettingsPanel.Header = self.SettingsPanel:Add("Panel")
  self.SettingsPanel.Header:Dock(TOP)
  self.SettingsPanel.Header:DockMargin(0, 0, 0, 8)
  self.SettingsPanel.Header:SetTall(32)
  self.SettingsPanel.Header.Text = isNew and "Creating New Object" or "Editing Object"
  self.SettingsPanel.Header.Paint = function(pnl, w, h)
    draw.SimpleText(pnl.Text, "Xenin.Configurator.Row.Title", 8, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end

  self.SettingsPanel.Header.Back = self.SettingsPanel.Header:Add("XeninUI.ButtonV2")
  self.SettingsPanel.Header.Back:Dock(RIGHT)
  self.SettingsPanel.Header.Back:DockMargin(0, 6, 6, 0)
  self.SettingsPanel.Header.Back:SetText("")
  self.SettingsPanel.Header.Back:SetSolidColor(XeninUI.Theme.Primary)
  self.SettingsPanel.Header.Back:SetRoundness(6)
  self.SettingsPanel.Header.Back.Text = isNew and "Cancel" or "Go Back"
  self.SettingsPanel.Header.Back.PaintOver = function(pnl, w, h)
    surface.SetMaterial(matArrow)
    surface.SetDrawColor(color_white)
    local size = h - 14
    surface.DrawTexturedRectRotated(size, h / 2, size, size, 180)

    draw.SimpleText(pnl.Text, "Xenin.Configurator.Row.Subtitle", size * 1.75, h / 2, Color(174, 174, 174), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end
  surface.SetFont("Xenin.Configurator.Row.Subtitle")
  local tw = surface.GetTextSize(self.SettingsPanel.Header.Back.Text)
  self.SettingsPanel.Header.Back:SetWide((14 * 1.75) + tw + 8)
  self.SettingsPanel.Header.Back.DoClick = function(pnl)
    if isNew then
      local foundAt
      for i, v in ipairs(self.Rows) do
        if (v.Id != parent.Id) then continue end

        v:Remove()

        foundAt = i
      end
      if foundAt then
        table.remove(self.Rows, foundAt)

        parent:Remove()
      end

      self.SettingsPanel:LerpAlpha(0, 0.15, function()
        self.SettingsPanel:Remove()
        self:CreateNew()
        self:InvalidateLayout(true)
      end)
    else
      self.SettingsPanel:FadeOut()
    end
  end

  self.SettingsPanel.Top = self.SettingsPanel:Add("Xenin.Configurator.Admin.EntityList.Row")
  self.SettingsPanel.Top:Dock(TOP)
  self.SettingsPanel.Top:DockMargin(0, 0, 0, 4)
  self.SettingsPanel.Top:SetTall(56)
  self.SettingsPanel.Top.DeleteDisabled = true
  self.SettingsPanel.Top:SetEntity(entity, self.Template)

  self.SettingsPanel.Top.Edit:SetText(isNew and "Create" or "Save")
  self.SettingsPanel.Top.Edit.DoClick = function(pnl, w, h)
    parent:SetEntity(copy, self.Template)


    self.SettingsPanel:FadeOut()
  end

  self.SettingsPanel:AddSettings(entity)
  self.SettingsPanel.OnValueChanged = function(pnl)
    local settings = pnl:GetSettings()
    for i, v in pairs(settings) do
      copy["set" .. tostring(i)](copy, v)
    end

    pnl.Top:SetEntity(copy, self.Template)
    pnl.Top:InvalidateLayout(true)

  end

  self.SettingsPanel:Dock(TOP)
  self.SettingsPanel.GetChildSize = function(pnl)
    local height = 0
    local size = 0
    for i, v in ipairs(pnl.Settings) do
      if (!v:IsVisible()) then continue end

      size = size + 1
      height = height + v:GetTall()
    end
    height = height - (size * 3)

    return height + 8 + pnl.Top:GetTall() + 8 + 40
  end

  self:InvalidateLayout(true)
end

function PANEL:CreateRow(entity, index)
  local listView = self.Template.getListView(entity)
  if (!listView) then return end
  assert(listView ~= nil, "cannot destructure nil value")
  local height, search = listView.height, listView.search

  self.RowsIds[entity:getId()] = true

  local row = self.Body:Add("Xenin.Configurator.Admin.EntityList.Row")
  row:Dock(TOP)
  row:DockMargin(0, 0, 0, 4)
  row:SetTall(height or 56)
  row.Id = index
  row:SetEntity(entity, self.Template)
  row.DoClick = function(pnl)
    self.Body.Alpha = 255
    self.Body:LerpAlpha(0, 0.15, function()
      self.Body:SetAlpha(0)
      self:SwitchToEdit(pnl.Entity, pnl)
    end)
  end
  row.OnRemove = function(pnl)
    self.RowsIds[pnl.Entity:getId()] = nil end
  row.OnDelete = function(pnl)
    XeninUI:SimpleQuery("Delete", "Are you sure you want to delete this?", "Yes", function()
      local foundAt
      for i, v in ipairs(self.Rows) do
        if (v.Id != pnl.Id) then continue end

        v:Remove()

        foundAt = i
      end
      if (!foundAt) then return end

      table.remove(self.Rows, foundAt)

      self.RowsIds[pnl.Entity:getId()] = nil
      pnl.Entity:delete(true)

      pnl:Remove()
    end, "No", function() end)
  end
  row.Search = search or function(pnl, text)
    return pnl.Entity:getId():lower():find(text)
  end

  table.insert(self.Rows, row)
end

function PANEL:OnSearch(text)
  text = text:lower()

  local panels = self.Rows
  if IsValid(self.ListBody) then
    panels = self.ListBody.Rows
  end
  if (IsValid(self.SettingsPanel)) then return end

  for i, v in pairs(panels) do
    local result = v:Search(text)
    v:SetVisible(result)
  end

  self:InvalidateLayout(true)

  if IsValid(self.ListBody) then
    self.ListBody:InvalidateLayout(true)
    self.ListBody:SizeToChildren(false, true)
  end
end

function PANEL:PerformLayout(w, h)
  self.BaseClass.PerformLayout(self, w, h)

  self.Body:SetWide(math.min(600, w))
  self.Body:CenterHorizontal()
  self.Body:SizeToChildren(false, true)

  if (!IsValid(self.SettingsPanel)) then return end

  self.SettingsPanel:SetTall(self.SettingsPanel:GetChildSize())
end

vgui.Register("Xenin.Configurator.Admin.EntityList", PANEL, "Xenin.Configurator.Admin.Panel")
