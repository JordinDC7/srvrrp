local PANEL = {}

function PANEL:Init() end

function PANEL:GetEntities()
  return {
  i }
end

function PANEL:SetScript(script)
  self.script = script
  self.ctr = XeninUI.Configurator:FindControllerByScriptName(script)
end

function PANEL:OnSearch(text)
  XeninUI.Configurator.Network:sendGetEntities(self.BaseEnt, nil, nil, text)
end

function PANEL:SetData(tbl)
  assert(tbl ~= nil, "cannot destructure nil value")
  local __entity, name, script = tbl.__entity, tbl.name, tbl.script

  self:SetScript(script)
  self.Entity = __entity
  self:SetTitle(name)
  self.Navbar:SetVisible(false)
  self.BaseEnt = XeninUI.Configurator.Entities:create(self.Entity)
  XeninUI.Configurator.Network:sendGetEntities(self.BaseEnt)

  self.TopBar = self:Add("Panel")
  self.TopBar:Dock(TOP)
  self.TopBar:DockMargin(0, 16, 0, 0)

  self.Subtitle = self.TopBar:Add("DLabel")
  self.Subtitle:SetFont("Xenin.Configurator.Admin.Panel.Navbar")
  self.Subtitle:SetText("Loading")

  self.Create = self.TopBar:Add("XeninUI.ButtonV2")
  self.Create:Dock(RIGHT)
  self.Create:SetText("Create New")
  self.Create:SetFont("Xenin.Configurator.Admin.Panel.Navbar")
  self.Create:SetRoundness(6)
  self.Create:SetSolidColor(XeninUI.Theme.Primary)
  self.Create:SetHoverColor(XeninUI.Theme.Navbar)
  self.Create:SetTextColor(Color(182, 182, 182))
  self.Create.DoClick = function(pnl)
    local ent = XeninUI.Configurator.Entities:create(self.Entity)
    XeninUI.Configurator.Network:sendCreateEntity(ent)
  end
  self.Save.DoClick = function(pnl)
    for _, row in ipairs(self.Rows) do
      local ent = XeninUI.Configurator.Entities:create(self.Entity)
      local settings = IsValid(row.Settings) and row.Settings:GetSettings()
      if (!settings) then continue end

      for i, v in pairs(settings) do
        ent["set" .. tostring(i)](ent, v)
      end

      ent:save(true)
    end
  end

  hook.Add("XeninUI.Configurator.CreatedEntity", self, function(self, ent)
    local entity = ent:getDatabaseEntity()
    if (entity != self.Entity) then return end

    local id = ent.getId and ent:getId() or #self.Rows + 1
    self:CreateEntity(ent, id)
    self:UpdateTitle(#self.Rows)
  end)
  self.Scroll:DockMargin(0, 16, 0, 0)

  self.Rows = {}

  self.RowController = self.Body:Add("Panel")
  self.RowController:Dock(TOP)
  self.RowController.Think = function(pnl, w, h)
    w = pnl:GetWide()
    h = pnl:GetTall()

    local y = 0
    for i, v in ipairs(self.Rows) do
      if (!IsValid(v)) then continue end

      v:SizeToChildren(false, true)
      local height = v:GetTall() >= 48 and v:GetTall() or 48
      v:SetSize(w, height)
      v:SetPos(0, y)

      y = y + v:GetTall()
    end

    pnl:SizeToChildren(false, true)
  end

  hook.Add("XeninUI.Configurator.GetEntities", self, function(self, entities)
    if entities == nil then entities = {}
    end
    self:UpdateTitle(#entities)

    self.Rows = {}
    for i, v in ipairs(entities) do
      self:CreateEntity(v, i)
    end
  end)
end

function PANEL:UpdateTitle(size)
  size = size or #self.Rows
  if (!IsValid(self.Title)) then return end

  local name = self.Title:GetText()
  name = name:sub(1, 1):lower() .. name:sub(2, #name - 1)
  if (size != 1) then name = name .. "s"
  end

  self.Subtitle:SetText(tostring(size) .. " " .. tostring(name))
end

function PANEL:CreateEntity(entity, id)
  local columns = entity:getColumns()
  local name = entity.__name

  local panel = self.RowController:Add("Xenin.Configurator.Admin.Entity.Row")
  panel:SetEntity(entity)
  panel.OnRemove = function(pnl)
    table.remove(self.Rows, id)

    self:UpdateTitle(#self.Rows - 1)
  end

  local id = table.insert(self.Rows, panel)
  self.Rows[id].RowId = id
end

function PANEL:Paint(w, h)
  self.BaseClass.Paint(self, w, h)

  if (self.Subtitle:GetText() != "Loading") then return end

  XeninUI:DrawLoadingCircle(w / 2, h / 2, h / 4)
end

function PANEL:PerformLayout(w, h)
  self.BaseClass.PerformLayout(self, w, h)

  self.TopBar:SetTall(32)
  self.Subtitle:SizeToContents()
  self.Create:SizeToContentsX(24)
end

vgui.Register("Xenin.Configurator.Admin.Entity", PANEL, "Xenin.Configurator.Admin.Panel")
