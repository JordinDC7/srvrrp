local PANEL = {}

function PANEL:Init()
  if IsValid(XeninUI.Players.Frame) then
    XeninUI.Players.Frame:Remove()
  end

  XeninUI.Players.Frame = self

  self:SetTitle("Xenin Hub")
  self:MakePopup()

  self.Sidebar = self:Add("XeninUI.SidebarV2")
  self.Sidebar:Dock(LEFT)
  self.Sidebar:SetBody(self)
  self.Sidebar:CreateDivider()
  self.Sidebar:CreatePanel("Notifications", nil, "XeninUI.Players.Notifications", "8JweIot")
  self.Sidebar:SetActiveByName("Notifications")

  self.Player = self.Sidebar:Add("XeninUI.Sidebar.Player")
  self.Player:Dock(TOP)
end

function PANEL:PerformLayout(w, h)
  self.BaseClass.PerformLayout(self, w, h)

  self:SetSize(XeninUI.Frame.Width, XeninUI.Frame.Height)
  self:Center()

  local sw = 0
  for i, v in ipairs(self.Player.Text.Rows) do
    surface.SetFont(v.font)
    local tw = surface.GetTextSize(v.text)

    sw = math.max(sw, 68 + tw + 68 / 2 + 8)
  end
  for i, v in ipairs(self.Sidebar.Sidebar) do
    surface.SetFont("XeninUI.SidebarV2.Name")
    local nameTw = surface.GetTextSize(v.Name or "")
    surface.SetFont(v.DescFont)
    local descTw = surface.GetTextSize(v.Desc or "")

    local tw = math.max(nameTw, descTw) + 12 + 8
    if v.Icon then
      tw = tw + 68
    end

    sw = math.max(sw, tw)
  end
  self.Sidebar:SetWide(sw)
  self.Sidebar:SetTall(56)

  self.Player:SetTall(68)
end

vgui.Register("XeninUI.Players", PANEL, "XeninUI.Frame")
