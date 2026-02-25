local PANEL = {}

XeninUI:CreateFont("XeninUI.Players.Notifications", 20)

function PANEL:Init()
  self:DockPadding(16, 16, 16, 16)

  self.Top = self:Add("Panel")
  self.Top:Dock(TOP)

  self.Top.Title = self.Top:Add("DLabel")
  self.Top.Title:Dock(LEFT)
  self.Top.Title:SetFont("XeninUI.Players.Notifications")
  self.Top.Title:SetTextColor(Color(222, 222, 222))
  self.Top.Title:SetText("Latest Notifications")

  self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
  self.Scroll:Dock(FILL)
  self.Scroll:DockMargin(0, 8, 0, 0)

  self.Layout = self.Scroll:Add("DListLayout")
  self.Layout:Dock(TOP)
  self.Layout:DockMargin(0, 0, 8, 0)

  self.Loading = true
  hook.Add("XeninUI.Players.GotNotifications", self, function(self, notifications)
    if self.Loading then
      self:ClearNotifications()
      for i, v in ipairs(notifications) do
        self:AddNotification(v)
      end
      self.Loading = false
      self:InvalidateLayout()
    end
  end)

  self:GetNotifications()

  self:AddTimer("XeninUI.Players.Notifications.UpdateRead", 1, 0, function()
    if (!IsValid(self)) then return end

    local notificationPanels = self:GetNotificationsInView()
    local notifications = {}
    for i, v in ipairs(notificationPanels) do
      if (!v.Notification) then continue end
      if (v.Notification.readAt) then continue end

      v.Notification.readAt = os.time()
      v.BackgroundColor = XeninUI.Theme.Primary

      table.insert(notifications, v.Notification.id)
    end

    if (#notifications == 0) then return end
    XeninUI.Players.Network:sendReadNotifications(notifications)
  end)
end

function PANEL:GetNotifications()
  XeninUI.Players.Network:sendReceiveNotifications()
end

function PANEL:ClearNotifications()
  self.Layout:Clear()
end

function PANEL:AddNotification(notification)
  local row = self.Layout:Add("XeninUI.Players.Notifications.Row")
  row:Dock(TOP)
  row:DockMargin(0, 0, 0, 4)
  row:SetNotification(notification)
end

function PANEL:PerformLayout(w, h)
  self.Top.Title:SizeToContents()

  for i, v in ipairs(self.Layout:GetChildren()) do
    v:SetTall(v:CalculateHeight())
    print(v:IsVisible())
  end
end

function PANEL:Paint(w, h)
  if self.Loading then
    draw.SimpleText("Loading", "XeninJC.Admin.Queue.Loading", w / 2, h / 2 - h / 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    XeninUI:DrawLoadingCircle(w / 2, h / 2 + 16, h / 4, XeninUI.Theme.Accent)
  end
end

function PANEL:GetNotificationsInView()
  local sH = self.Scroll:GetTall()
  local sY = self.Scroll.VBar.Scroll
  local sB = sH + sY

  local notifications = {}
  for i, v in ipairs(self.Layout:GetChildren()) do
    assert(v ~= nil, "cannot destructure nil value")
    local y = v.y
    if (y > sB) then continue end
    if (sY > y) then continue end
    if (sB < y) then continue end
    if (!v.Notification) then continue end
    if (v.Notification.readAt) then continue end

    table.insert(notifications, v)
  end

  return notifications
end

vgui.Register("XeninUI.Players.Notifications", PANEL)
