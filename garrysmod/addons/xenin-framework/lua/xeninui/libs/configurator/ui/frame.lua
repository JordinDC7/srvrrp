local PANEL = {}

function PANEL:Init()
  if IsValid(XeninUI.Configurator.AdminMenu) then XeninUI.Configurator.AdminMenu:Remove()end

  XeninUI.Configurator.AdminMenu = self

  self:SetSize(1020, 800)
  self:Center()
  self:MakePopup()

  self.Top = self:Add("Xenin.Configurator.Admin.Top")
  self.Top:Dock(TOP)
  self.Top:DockMargin(16, 16, 16, 16)
  self.Top:SetText({
    "Title",
    "Subtitle"
  })

  self.Sidebar = self:Add("Xenin.Configurator.Admin.Sidebar")
  self.Sidebar:Dock(LEFT)
end

function PANEL:AddTab(...)
  self.Sidebar:AddTab(...)
end

function PANEL:SetActive(id)
  self.Sidebar:SetActive(id)
end

function PANEL:PerformLayout(w, h)
  self.Top:SetTall(40)
  self.Sidebar:SetWide(200)
end

function PANEL:Paint(w, h)
  local x, y = self:LocalToScreen()

  BSHADOWS.BeginShadow()
  draw.RoundedBox(6, x, y, w, h, XeninUI.Theme.Background)
  BSHADOWS.EndShadow(1, 2, 2, 255, 0, 0)

  draw.RoundedBoxEx(6, 0, 0, w, 40 + 32, XeninUI.Theme.Primary, true, true, false, false)
end

function PANEL:SetScript(script)
  local __laux_type = (istable(script) and script.__type and script:__type()) or type(script)
  assert(__laux_type == "string", "Expected parameter `script` to be type `string` instead of `" .. __laux_type .. "`")
  self.script = script
  local ctr = XeninUI.Configurator:FindControllerByScriptName(script)
  local tabs = ctr:getTabs()
  for i, v in ipairs(tabs) do
    self.Sidebar:AddTab(v.name, v.icon, v.color, v.panel, script, v)
  end
  self.Top:SetScript(script, ctr)
  self.Top:SetText(ctr:getTitle())
  self.Sidebar:SetActive(1)
end

vgui.Register("Xenin.Configurator.Admin", PANEL, "EditablePanel")

concommand.Add("xenin_config", function(ply, cmd, args)
  assert(XeninUI.Permissions:canAccessFramework(ply), "You don't have access to this config")
  local script = args[1]
  assert(isstring(script), "You need the script ID you're looking for")
  local controller = XeninUI.Configurator:FindControllerByScriptName(script)
  assert(controller != nil, "That script does not exist")

  local frame = vgui.Create("Xenin.Configurator.Admin")
  frame:SetScript(script)
end, function(cmd, args)
  local script = string.lower(string.Trim(args))
  local tbl = {}
  for i, v in ipairs(XeninUI.Configurator:GetControllers()) do
    if (#script > 0 and !v:getScript():find(script)) then continue end

    table.insert(tbl, "xenin_config " .. v:getScript())
  end


  table.sort(tbl, function(a, b)
    return a > b end)

  return tbl
end)
