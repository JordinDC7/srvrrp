local PANEL = {}

XeninUI:CreateFont("Xenin.Framework.Load", 48)
XeninUI:CreateFont("Xenin.Framework.Tab", 20)

function PANEL:Init()
  self:SetSize(XeninUI.Frame.Width, XeninUI.Frame.Height)
  self:Center()
  self:SetTitle("Xenin Framework - Admin")
  self:MakePopup()

  self:AddHook("Xenin.Framework.ReceivedScripts", "Xenin.Framework", function(self, scripts)
    self:CreateSidebar()
  end)

  XeninUI.ScriptsNetwork:requestScripts()
end

function PANEL:CreateCategory(name, col)
  if col == nil then col = Color(64, 64, 64)
  end
  local panel = self.Sidebar.Scroll:Add("DPanel")
  panel:Dock(TOP)
  panel:SetTall(draw.GetFontHeight("Xenin.Framework.Tab") + 16)
  panel.Paint = function(pnl, w, h)
    draw.SimpleText(name, "Xenin.Framework.Tab", w / 2, h / 2, Color(212, 212, 212), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    surface.SetDrawColor(col)
    if (name != "1st party") then
      surface.DrawRect(0, 0, w, 1)
    end
    surface.DrawRect(0, h - 1, w, 1)
  end
end

function PANEL:CreateSidebar(tbl)
  self.Sidebar = self:Add("XeninUI.SidebarV2")
  self.Sidebar:Dock(LEFT)
  self.Sidebar:SetBody(self)

  local scripts = XeninUI.Scripts:getAll()


  for i, v in pairs(scripts) do
    self.Sidebar:CreatePanel(v.name, v.desc, "Xenin.Framework.Tab", v.icon, v)
  end





  self.Sidebar:SetActive(1)
end

function PANEL:PerformLayout(w, h)
  self.BaseClass.PerformLayout(self, w, h)

  if (!IsValid(self.Sidebar)) then return end

  local sw = 0
  for i, v in ipairs(self.Sidebar.Sidebar) do
    surface.SetFont("XeninUI.SidebarV2.Name")
    local nameTw = surface.GetTextSize(v.Name or "")
    surface.SetFont("XeninUI.SidebarV2.Desc")
    local descTw = surface.GetTextSize(v.Desc or "")

    local tw = math.max(nameTw, descTw) + 8
    if v.Icon then
      tw = tw + 68
    end

    sw = math.max(sw, tw)
  end

  self.Sidebar:SetWide(math.max(140, sw))
end

function PANEL:Paint(w, h)
  self.BaseClass.Paint(self, w, h)

  if self.Sidebar then return end

  XeninUI:DrawLoadingCircle(w / 2, h / 2 + 18, h / 4)
  XeninUI:DrawShadowText("Loading all addons", "Xenin.Framework.Load", w / 2, h / 2 - h / 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, 150)
end

vgui.Register("Xenin.Framework", PANEL, "XeninUI.Frame")

concommand.Add("xenin_admin", function()
  if (!XeninUI.Permissions:canAccessFramework(LocalPlayer())) then
    chat.AddText(XeninUI.Theme.Red, "[Xenin] ", color_white, "You don't have the required authority to do this")

    return
  end

  vgui.Create("Xenin.Framework")
end)
