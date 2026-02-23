local PANEL = {}

function PANEL:Init()
  self.OnPaint = {}
  self.BackgroundColor = XeninUI.Theme.Primary
end

function PANEL:SetNotification(notification)
  self.Notification = notification
  if self.Notification.readAt then
    self.BackgroundColor = XeninUI.Theme.Navbar
  end
  self.TypeData = XeninUI.Notification:getType(notification.scriptId, notification.type)

  self.Hooks = self.TypeData.hooks and self.TypeData.hooks(notification)
  local hooks = self.Hooks
  if (hooks and hooks.preInit) then
    hooks.preInit(notification, self)
  end

  local img = self.TypeData.img(notification)
  if img.custom then
    img.custom(notification, self)
  elseif img.src then
    XeninUI:DownloadIcon(self, img.src, "Image")
    self:AddPaint(function(self, w, h)
      XeninUI:DrawIcon(8, 8, 48 - 16, 48 - 16, self, self.color, self.color, "Image")
    end)
  elseif img.ply then
    self.PlayerAvatar = self:Add("XeninUI.Avatar")
    self.PlayerAvatar:SetSteamID(img.ply.sid64, 64)
    self.PlayerAvatar:SetVertices(30)
  end

  self.Title = {
    text = self.Notification.content,
    font = "XeninUI.Players.Notifications.Row.Title",
    color = Color(232, 232, 232)
  }
  self.Subtitle = {
    text = XeninUI:DateToString(self.Notification.createdAt),
    font = "XeninUI.Players.Notifications.Row.Subtitle",
    color = Color(175, 175, 175)
  }

  self.Button = self:Add("DButton")
  self.Button:SetText("")
  self.Button.Color = Color(87, 87, 87)
  XeninUI:DownloadIcon(self.Button, "oRwjOoj")
  self.Button.Paint = function(pnl, w, h)
    local s = 48 - 19
    XeninUI:DrawIcon(h / 2 - s / 4, h / 2 - s / 2, s, s, pnl, pnl.Color)
  end
  self.Button.OnCursorEntered = function(pnl)
    pnl:LerpColor("Color", XeninUI.Theme.Accent)
  end
  self.Button.OnCursorExited = function(pnl)
    pnl:LerpColor("Color", Color(87, 87, 87))
  end
  self.Button.DoClick = function(pnl)
    if self.TypeData.options then
      local options = XeninUI.Options(pnl)
      for i, v in ipairs(self.TypeData.options) do
        v(notification, options, self)
      end
      options:create()
    end
  end
  self.Button:SetVisible(self.TypeData.options)

  if (hooks and hooks.postInit) then
    hooks.postInit(notification, self)
  end
end

function PANEL:AddPaint(func)
  table.insert(self.OnPaint, func)
end

function PANEL:CalculateHeight()
  local h = 7 + draw.GetFontHeight(self.Subtitle.font) + 4
  local w = self:GetWide()

  if (w == 64) then
    w = 719
  end
  local lines = XeninUI:TextToLines(self.Title.text, self.Title.font, w - 48 - 24 - 8)
  h = h + (#lines * (draw.GetFontHeight(self.Title.font) - 2))

  return h
end

XeninUI:CreateFont("XeninUI.Players.Notifications.Row.Title", 18)
XeninUI:CreateFont("XeninUI.Players.Notifications.Row.Subtitle", 12)

function XeninUI:TextToLines(text, font, maxWidth)
  surface.SetFont(font)

  local strings = text:Split("\n")
  local lines = {}

  for i, str in ipairs(strings) do
    local buffer = {}
    for word in str:gmatch("%S+") do
      local w, h = surface.GetTextSize(table.concat(buffer, " ") .. " " .. word)
      if (w > maxWidth) then
        table.insert(lines, table.concat(buffer, " "))
        buffer = {}
      end

      table.insert(buffer, word)
    end

    if (#buffer > 0) then
      table.insert(lines, table.concat(buffer, " "))
    end
  end

  return lines
end

function XeninUI:DrawTextMultiline(text, font, x, y, col, xAlign, yAlign, maxWidth, spacing)
  if spacing == nil then spacing = draw.GetFontHeight(font)
  end
  local lines = self:TextToLines(text, font, maxWidth)

  local offset = y
  for i, v in ipairs(lines) do
    draw.SimpleText(v, font, x, offset, col, xAlign, yAlign)

    offset = offset + (spacing - 3)
  end
end

function PANEL:Paint(w, h)
  draw.RoundedBox(6, 0, 0, w, h, self.BackgroundColor)

  for i, v in ipairs(self.OnPaint) do
    v(self, w, h)
  end

  local x = 48
  draw.SimpleText("Job Disabled - " .. self.Subtitle.text, self.Subtitle.font, x, 7, self.Subtitle.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
  XeninUI:DrawTextMultiline(self.Title.text, self.Title.font, x, 7 + draw.GetFontHeight(self.Subtitle.font) * 2 + 4, self.Title.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, w - 48 - 24 - 8)
end

function PANEL:PerformLayout(w, h)
  if IsValid(self.PlayerAvatar) then
    self.PlayerAvatar:SetPos(8, 8)
    self.PlayerAvatar:SetSize(h - 16, h - 16)
  end

  if IsValid(self.Button) then
    self.Button:SetSize(h - 8, h - 8)
    self.Button:AlignRight(0)
    self.Button:CenterVertical()
  end
end

vgui.Register("XeninUI.Players.Notifications.Row", PANEL)
