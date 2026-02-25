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

function PANEL:Init()
  self.textentry:SetUpdateOnType(true)
  self.textentry.OnValueChange = function(pnl, text)
    self:Search(text:lower())
  end
end

function PANEL:RemovePopup()
  if IsValid(self.Popup) then self.Popup:Remove()end
end

PANEL.OnRemove = PANEL.RemovePopup

XeninUI:CreateFont("Xenin.Configurator.Admin.SearchBar.Title", 18)
XeninUI:CreateFont("Xenin.Configurator.Admin.SearchBar.Subtitle", 13)

function PANEL:Paint(w, h)
  if IsValid(self.Popup) then
    return draw.RoundedBoxEx(self:GetRounded(), 0, 0, w, h, self:GetBackgroundColor(), true, true, false, false)
  end

  draw.RoundedBox(self:GetRounded(), 0, 0, w, h, self:GetBackgroundColor())
end

function PANEL:CreatePopup(results)
  local size = #results
  local x, y = self:GetPos()
  x = x + 16
  y = y + 16
  y = y + self:GetTall()
  local w = self:GetWide()
  local h = 16 + (size * 48 + ((size - 1) * 4))
  if (size == 0) then h = h + 30
  end

  self.Popup = XeninUI.Configurator.AdminMenu:Add("DPanel")
  self.Popup:SetPos(x, y)
  self.Popup:SetSize(w, h)
  self.Popup:SetZPos(100)
  self.Popup:SetDrawOnTop(true)
  self.Popup.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Navbar, false, false, true, true)
  end

  self.Popup.Layout = self.Popup:Add("DListLayout")
  self.Popup.Layout:DockPadding(8, 8, 8, 8)
  self.Popup.Layout:Dock(TOP)

  if (size == 0) then
    local panel = self.Popup.Layout:Add("DLabel")
    panel:SetText("No Results")
    panel:SetFont("Xenin.Configurator.Admin.SearchBar.Title")
    panel:SetTextColor(color_white)
    panel:SetContentAlignment(5)

    return
  end

  for i = 1, size do
    local result = results[i]
    local panel = self.Popup.Layout:Add("DButton")
    panel:DockMargin(0, 0, 0, 4)
    panel:SetText("")
    panel:SetTall(48)
    panel.Result = result
    panel.Color = XeninUI.Theme.Navbar
    local cat = {
      icon = result.icon,
      color = result.color
    }
    XeninUI:DownloadIcon(panel, cat.icon)
    local desc = result.desc
    if (#desc >= 58) then
      desc = result.desc:sub(1, 58 - 3) .. "..."
    end
    panel.Markup = markup.Parse("<font=Xenin.Configurator.Admin.SearchBar.Title><color=255,255,255>" .. tostring(result.name) .. "</color></font>")
    panel.Paint = function(pnl, w, h)
      XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Color)
      XeninUI:DrawIcon(8, 8, h - 16, h - 16, pnl, cat.color)

      pnl.Markup:Draw(h, h / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
      XeninUI:DrawShadowText(desc, "Xenin.Configurator.Admin.SearchBar.Subtitle", h, h / 2, Color(179, 179, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 150)

      surface.SetFont("Xenin.Configurator.Admin.SearchBar.Title")
      local tw, th = pnl.Markup:GetWidth(), pnl.Markup:GetHeight()
      surface.SetFont("Xenin.Configurator.Admin.SearchBar.Subtitle")
      local sw, sh = surface.GetTextSize(result.category)
      XeninUI:DrawRoundedBox(6, h + tw + 4, h / 2 - th / 2 - 6, sw + 8, sh, result.color or cat.color)
      local col = XeninUI:GetContrastColor(result.color or cat.color, color_white, Color(65, 65, 65))
      draw.SimpleText(result.category, "Xenin.Configurator.Admin.SearchBar.Subtitle", h + tw + 4 + 4, h / 2 - th / 2 - 6, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    panel.OnCursorEntered = function(pnl, w, h)
      pnl:LerpColor("Color", XeninUI.Theme.Background)
    end
    panel.OnCursorExited = function(pnl, w, h)
      pnl:LerpColor("Color", XeninUI.Theme.Navbar)
    end
    panel.DoClick = function(pnl)
      if result.onClick then
        result.onClick(pnl, XeninUI.Configurator.AdminMenu)
      end

      self:RemovePopup()
    end
  end
end

function PANEL:Find(text, search)
  return text:find(search, nil, nil, true)
end

function PANEL:SetScript(script, ctr)
  self.script = script
  self.ctr = ctr
end

function PANEL:AddToSearch(name, desc, category, id, extra)
  if extra == nil then extra = {}
  end
  table.insert(self.Results, __laux_concat_0({
    name = name,
    desc = desc,
    category = category,
    catId = id
  }, extra))
end

function PANEL:GetSettings()
  if (self:HasReachedSearchLimit()) then return end
end

function PANEL:HasReachedSearchLimit()
  return #self.Results >= 4
end

function PANEL:Search(text)
  self:RemovePopup()
  if (#text == 0) then return end
  self.Results = self.ctr:getSearch(text)

  self:CreatePopup(self.Results)
end

vgui.Register("Xenin.Configurator.Admin.SearchBar", PANEL, "XeninUI.TextEntry")
