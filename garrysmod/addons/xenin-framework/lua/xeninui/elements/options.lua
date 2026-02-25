local function __laux_concat_0(...)
  local arr = {
  ...
  }
  local result = {}
  for _, obj in ipairs(arr) do
    for i = 1, #obj do
      result[#result + 1] = obj[i]
    end
    for k, v in pairs(obj) do
      if type(k) == "number" and k > #obj then result[k] = v
      elseif type(k) ~= "number" then
        result[k] = v
      end
    end
  end
  return result
end
local PANEL = {}

AccessorFunc(PANEL, "m_font", "Font")

XeninUI:CreateFont("XeninUI.Options.Button", 22)

function PANEL:Init()
  self:SetDrawOnTop(true)
  self:SetZPos(125)
  self:DockPadding(8, 8, 8, 8)
  self.Alpha = 0
  self:LerpAlpha(255, 0.3)
  self:SetFont("XeninUI.Options.Button")
end

function PANEL:OnFocusChanged(gained)
  if (gained) then return end

  self:Close()
end

function PANEL:Close()
  if (self.Removing) then return end

  self.Removing = true
  self:LerpAlpha(255, 0.1)
  self:LerpHeight(0, 0.1, function()
    if (!IsValid(self)) then return end

    self:Remove()
  end)
end

function PANEL:GetNewSize()
  local width = 16
  local height = 16

  local children = self:GetChildren()
  local size = #children
  for i, v in ipairs(children) do
    if (v.RowType == self.Options.BUTTON) then
      surface.SetFont(v.Font)
      local tW = surface.GetTextSize(v.Text)

      tW = tW + 32

      if v.IconBackground then tW = tW + 53
      end

      width = math.max(width, tW)
    end

    height = height + v:GetTall()
    if (i != size) then height = height + 8
    end
  end

  return math.max(150, width), height
end

function PANEL:UpdatePos()
  local parent = self.Parent
  if (!IsValid(parent)) then self:Remove()end

  local aX, aY = parent:LocalToScreen()
  local x = self:GetWide() - parent:GetWide()
  local y = parent:GetTall()
  self:SetPos(aX - x, aY + y)
end

function PANEL:CreateButton(data)
  local btn = self:Add("DButton")
  btn:SetTall(53)
  btn:SetText("")
  local hoverColor = data.hoverColor or XeninUI.Theme.Primary
  btn.Background = ColorAlpha(hoverColor, 0)
  btn.Text = data.text
  btn.TextColor = data.textColor or color_white
  btn.Font = data.font or self:GetFont()
  if data.icon then
    XeninUI:DownloadIcon(btn, data.icon)
    btn.IconBackground = Color(58, 58, 58)
    btn.IconColor = data.iconColor or btn.TextColor
    btn.IconHoverColor = data.iconHoverColor or btn.IconColor
  end
  btn.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Background)

    local x = 8
    if pnl.Icon then
      local size = h - 16
      XeninUI:DrawCircle(x + size / 2, size / 2 + x, size / 2, 30, pnl.IconBackground)
      size = size - 16
      XeninUI:DrawIcon(x + 8, 16, size, size, pnl, pnl.IconColor)

      x = x + h
    end

    draw.SimpleText(pnl.Text, pnl.Font, x, h / 2, pnl.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end
  btn.PaintOver = function(pnl, w, h)
    if (!pnl.Pressing) then return end
    local frac = math.TimeFraction(pnl.Pressing, pnl.End, CurTime())
    local col = XeninUI:LerpColor(frac, XeninUI.Theme.Red, XeninUI.Theme.Green)

    local aX, aY = pnl:LocalToScreen()
    render.SetScissorRect(aX, aY, aX + (w * frac), aX + h, true)
    XeninUI:DrawRoundedBox(6, 0, 0, w, h, ColorAlpha(data.hold.color, 100))
    render.SetScissorRect(0, 0, ScrW(), ScrH(), false)
  end
  btn.OnCursorEntered = function(pnl)
    pnl:LerpColor("Background", ColorAlpha(hoverColor, 100))
    if data.icon then
      pnl:LerpColor("IconColor", pnl.IconHoverColor)
    end
  end
  btn.OnCursorExited = function(pnl)
    pnl:LerpColor("Background", ColorAlpha(hoverColor, 0))
    if data.icon then
      pnl:LerpColor("IconColor", data.iconColor or btn.TextColor)
    end
  end
  if data.hold then
    btn.Think = function(pnl)
      if (!pnl.Pressing) then return end
      local frac = math.Clamp(math.TimeFraction(pnl.Pressing, pnl.End, CurTime()), 0, 1)
      if (frac < 1) then return end
      if (pnl.Clicked) then return end
      pnl.Clicked = true

      if data.onClick then
        data:onClick(pnl)
      end

      self:Close()
    end
    btn.OnMousePressed = function(pnl)
      local wait = data.hold.time
      local time = CurTime()

      pnl.Clicked = nil
      pnl.Pressing = time
      pnl.End = CurTime() + wait
    end
    btn.OnMouseReleased = function(pnl)
      pnl.Clicked = nil
      pnl.Pressing = nil
      pnl.End = nil
    end
  else
    btn.DoClick = function(pnl)
      if data.onClick then
        local stop = data:onClick(pnl) != nil

        if (stop) then return end
      end

      self:Close()
    end
  end

  return btn
end

function PANEL:CreateDivider(data)
  local divider = self:Add("DPanel")
  divider:SetTall(data.thickness or 1)
  divider.Color = data.color or Color(64, 64, 64)
  divider.Paint = function(pnl, w, h)
    surface.SetDrawColor(pnl.Color)
    surface.DrawRect(0, 0, w, h)
  end

  return divider
end

function PANEL:SetOptions(options)
  self.Options = options
  assert(options ~= nil, "cannot destructure nil value")
  local rows, BUTTON, DIVIDER = options.rows, options.BUTTON, options.DIVIDER

  for i, v in ipairs(rows) do
    local row
    if (v.rowType == BUTTON) then
      row = self:CreateButton(v)
    elseif (v.rowType == DIVIDER) then
      row = self:CreateDivider(v)
    end

    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 8)
    row.RowType = v.rowType
  end

  local width, height = self:GetNewSize()
  self:SetWide(width)
  self:SetTall(0)
  self:LerpHeight(height, 0.3)
  self:MakePopup()
  self:UpdatePos()
end

function PANEL:Think()
  if (!self.Parent) then return end

  if (!IsValid(self.Parent)) then
    return self:Close()
  end

  if (!self.Parent:IsVisible()) then
    return self:Close()
  end
end

function PANEL:Paint(w, h)
  local aX, aY = self:LocalToScreen()

  BSHADOWS.BeginShadow()
  XeninUI:DrawRoundedBox(6, aX, aY, w, h, XeninUI.Theme.Background)
  BSHADOWS.EndShadow(1, 1, 1, 150 * (255 / self:GetAlpha()))

  XeninUI:MaskInverse(function()
    XeninUI:DrawRoundedBox(6, 1, 1, w - 2, h - 2, XeninUI.Theme.Background)
  end, function()
    XeninUI:DrawRoundedBox(6, 0, 0, w, h, ColorAlpha(XeninUI.Theme.Primary, self:GetAlpha()))
  end)
end

vgui.Register("XeninUI.Options", PANEL, "EditablePanel")

do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Options",
    addButton = function(self, data)
      table.insert(self.rows, __laux_concat_0({
      rowType = self.BUTTON
      }, data))

      return self
    end,
    addDivider = function(self, data)
      if data == nil then data = {}
      end
      table.insert(self.rows, __laux_concat_0({
      rowType = self.DIVIDER
      }, data))

      return self
    end,
    create = function(self)
      self.panel = vgui.Create("XeninUI.Options")
      self.panel.Parent = self.parent
      self.panel:SetOptions(self)

      return self.panel
    end,
    __type = function(self)
      return "XeninUI.Options"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, parent)
      self.rows = {}
      self.DIVIDER = 1
      self.BUTTON = 0
      self.parent = parent
    end,
    __base = _base_0
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  XeninUI.Options = _class_0
end
