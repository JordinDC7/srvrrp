XeninUI:CreateFont("Xenin.Configurator.Inputs.Label", 14)
XeninUI:CreateFont("Xenin.Configurator.KeyValue", 18)

XeninUI.Configurator.InputPanels = {
  ["Blank"] = {
  panel = function(self, tbl)
    return vgui.Create("Panel")
  end
  },
  ["Textentry"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("XeninUI.TextEntry")
    panel:DockMargin(0, 6, -4, 6)
    panel:SetBackgroundColor(XeninUI.Theme.Background)
    panel.SetInput = function(pnl, input)
      pnl:SetText(input)
      pnl.textentry:OnValueChange(input)
    end
    panel:SetPlaceholder(tbl.placeholder or "")
    panel.GetSettingValue = function(pnl)
      return pnl:GetText()
    end
    panel.textentry:SetNumeric(tbl.number or ((tbl and tbl.data) and tbl.data.number))
    panel.textentry.min = tbl.min
    panel.textentry.max = tbl.max
    panel.textentry:SetUpdateOnType(true)
    panel.textentry.OnValueChange = function(pnl, text)
      local currentCaret
      if (pnl:GetNumeric() and (pnl.min or pnl.max)) then
        local num = tonumber(text)
        if num then
          if (pnl.min and pnl.min > num) then
            currentCaret = pnl:GetCaretPos()
            pnl:SetText(pnl.min)
          elseif (pnl.max and pnl.max < num) then
            currentCaret = pnl:GetCaretPos()
            pnl:SetText(pnl.max)
          end
        end
      end

      if (text == "") then
        text = panel:GetPlaceholder()
      end
      surface.SetFont(pnl:GetFont())
      local tw = surface.GetTextSize(text)
      tw = tw + 24
      local width = math.Clamp(tw, 28, 600)
      panel:SetWide(width)

      if currentCaret then
        pnl:SetCaretPos(currentCaret)
      end
      if panel.onChange then
        panel:onChange(pnl:GetText())
      end
    end

    return panel
  end
  },
  ["TextentryWithLabel"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("Panel")
    panel:DockMargin(0, 6, -8, 6)
    panel.GetSettingValue = function(pnl)
      return pnl.textentry:GetText()
    end

    local label = panel:Add("DLabel")
    label:Dock(LEFT)
    label:DockMargin(12, 2, 0, 0)
    label:SetTextColor(tbl.labelColor or Color(127, 127, 127))
    label:SetFont("Xenin.Configurator.Inputs.Label")
    label:SetText(((tbl and tbl.data) and tbl.data.label) or tbl.label or "Label")

    local textentry = XeninUI.Configurator:CreateInputPanel("Textentry", self, tbl)
    textentry:SetParent(panel)
    textentry:Dock(FILL)
    textentry:DockMargin(0, 0, 0, 0)
    textentry:SetPlaceholder(tbl.placeholder or "")
    textentry.DoSizing = function(pnl, text)
      if (text == "") then
        text = pnl:GetPlaceholder()
      end
      surface.SetFont(pnl.textentry:GetFont())
      local tw = surface.GetTextSize(text)
      tw = tw + 24
      local width = math.Clamp(tw, 28, 600)

      label:SizeToContents()
      panel:SetWide(width + label:GetWide() + 16)
    end
    textentry.onChange = function(pnl, text)
      if panel.onChange then
        panel:onChange(text)
      end

      pnl:DoSizing(text)
    end

    panel.label = label
    panel.textentry = textentry

    if tbl.value then
      textentry:SetText(tbl.value)
    end
    textentry:DoSizing(textentry:GetText())

    return panel
  end
  },
  ["Selectbox"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("DButton")
    panel:SetText("")
    panel:DockMargin(0, 6, 6, 6)
    panel.Choices = {}
    panel.AddChoice = function(pnl, name, data)
      if data == nil then data = true
      end
      pnl.Choices[#pnl.Choices + 1] = {
        name = name,
        data = data
      }
    end
    panel.GetSettingValue = function(pnl)
      return pnl.Text
    end
    panel.TextColor = Color(182, 182, 182)
    XeninUI:DownloadIcon(panel, "2QGKAd6")
    panel.SetInput = function(pnl, text)
      pnl:SetChoice(text)
    end
    panel.SetChoice = function(pnl, text)
      local startText = pnl.Text
      pnl.Text = text
      local data = istable(pnl.Choices[text])
      if (data and (pnl.Choices[text] and pnl.Choices[text].__color)) then
        pnl.TextColor = pnl.Choices[text].__color
      end
      pnl:SizeToContents()

      if (startText and startText != "" and pnl.onChange) then
        pnl:onChange(text)
      end
    end
    panel.SetChoices = function(pnl, tbl)
      for i, v in pairs(tbl) do
        pnl:AddChoice(v.name, v.data)
      end
    end
    panel.SetData = function(pnl, data)
      if data.fetch then
        pnl:SetChoices(data:fetch())
      end
      if data.fetchAsync then
        data:fetchAsync():next(function(result)
          pnl:SetChoices(result)
        end, ErrorNoHalt)
      end
    end
    panel.Font = "Xenin.Configurator.Admin.Panel.Selectbox"
    panel.Outline = ((tbl and tbl.outline) and tbl.outline.standard) or XeninUI.Theme.Navbar
    panel.Rotation = 0
    panel.Paint = function(pnl, w, h)
      XeninUI:MaskInverse(function()
        XeninUI:DrawRoundedBox(6, 1, 1, w - 2, h - 2, color_white)
      end, function()
        XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Outline)
      end)

      local size = h / 3
      XeninUI:DrawIconRotated(w - size / 2 - 8, h / 2, size, size, pnl.Rotation, pnl, Color(182, 182, 182))

      draw.SimpleText(pnl.Text, pnl.Font, 8, h / 2, pnl.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    panel.SizeToContents = function(pnl)
      local width = 36
      surface.SetFont(pnl.Font)
      local tw = surface.GetTextSize(pnl.Text)
      width = width + tw

      pnl:SetWide(width)
    end
    panel.OnCursorEntered = function(pnl)
      pnl:LerpColor("Outline", ((tbl and tbl.outline) and tbl.outline.hover) or XeninUI.Theme.Primary)
      pnl:Lerp("Rotation", 180)
    end
    panel.OnCursorExited = function(pnl)
      if (IsValid(pnl.Popup)) then return end

      pnl:LerpColor("Outline", ((tbl and tbl.outline) and tbl.outline.standard) or XeninUI.Theme.Navbar)
      pnl:Lerp("Rotation", 0)
    end
    panel.RemovePopup = function(pnl)
      if (!IsValid(pnl.Popup)) then return end

      pnl.Popup:Remove()
    end
    panel.OnRemove = panel.RemovePopup
    panel.DoClick = function(pnl)
      pnl:RemovePopup()

      local aX, aY = pnl:LocalToScreen()

      local popup = vgui.Create("EditablePanel")
      pnl.Popup = popup
      popup:SetDrawOnTop(true)
      popup:SetZPos(125)
      popup:DockPadding(8, 8, 8, 8)
      local width = 16
      local height = 12
      surface.SetFont(pnl.Font)
      for i, v in ipairs(pnl.Choices) do
        local tw = surface.GetTextSize(v.name)
        tw = tw + 32
        if (tw > width) then
          width = tw
        end

        local btn = popup:Add("DButton")
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 4)
        btn:SetText(v.name)
        btn:SetFont("Xenin.Configurator.Admin.Panel.Selectbox")
        btn:SizeToContentsY(8)
        btn.BackgroundColor = Color(22, 22, 22, 0)
        local col = istable(v) and v.__color
        btn.TextColor = col and ColorAlpha(col, 150) or Color(182, 182, 182)
        btn.Paint = function(pnl, w, h)
          pnl:SetTextColor(pnl.TextColor)

          XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.BackgroundColor)
        end
        btn.OnCursorEntered = function(pnl)
          pnl:LerpColor("BackgroundColor", col or Color(22, 22, 22))
          pnl:LerpColor("TextColor", color_white)
        end
        btn.OnCursorExited = function(pnl)
          pnl:LerpColor("BackgroundColor", Color(22, 22, 22, 0))
          pnl:LerpColor("TextColor", col and ColorAlpha(col, 150) or Color(182, 182, 182))
        end
        btn.DoClick = function(pnl)
          panel:SetChoice(pnl:GetText())
          popup:Remove()
          panel:Lerp("Rotation", 0)
        end

        height = height + (btn:GetTall() + 4)
      end
      popup:SetWide(width)
      popup:SetTall(0)
      popup:LerpHeight(height, 0.3)
      popup.Alpha = 0
      popup:LerpAlpha(255, 0.3)
      popup.OnFocusChanged = function(pnl, gained)
        if (gained) then return end

        pnl:Remove()
        panel:OnCursorExited()
      end
      popup.Paint = function(pnl, w, h)
        local aX, aY = pnl:LocalToScreen()

        BSHADOWS.BeginShadow()
        XeninUI:DrawRoundedBox(6, aX, aY, w, h, XeninUI.Theme.Background)
        BSHADOWS.EndShadow(1, 1, 1, 150 * (255 / pnl:GetAlpha()))
      end
      popup:SetPos(aX + pnl:GetWide() - popup:GetWide(), aY + pnl:GetTall())
      popup:MakePopup()
    end

    return panel
  end
  },
  ["Toggle"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("XeninUI.Checkbox")
    panel:DockMargin(0, 6, 6, 6)
    local off = "OFF"
    local on = "ON"
    if tbl.data then
      if tbl.data.toggle then
        off = tbl.data.toggle[1]
        on = tbl.data.toggle[2]
      end
    end
    local width = 0
    surface.SetFont(panel.font)
    local twOff = surface.GetTextSize(off)
    local twOn = surface.GetTextSize(on)
    local increaseBy = math.max(twOn, twOff)
    width = width + (24 + increaseBy * 2)
    panel.offText = off
    panel.onText = on
    panel:SetWide(width)
    panel.SetInput = function(pnl, input)
      pnl:SetState(input, true)
    end
    panel.GetSettingValue = function(pnl)
      return tobool(pnl:GetState())
    end

    return panel
  end
  },
  ["Checkbox"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("XeninUI.CheckboxV2")
    panel:DockMargin(0, 12, 0, 12)
    panel.Background = XeninUI.Theme.Background
    panel:SetWide(32)
    panel.SetInput = function(pnl, value)
      pnl:SetState(tobool(value), true)
    end
    panel.GetSettingValue = function(pnl)
      return tobool(pnl.State)
    end

    return panel
  end
  },
  ["Color"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("DButton")
    panel:SetText("")
    panel.RemovePopup = function(pnl)
      if (!IsValid(pnl.Popup)) then return end

      pnl.Popup:Remove()
    end
    panel.OnRemove = panel.RemovePopup
    panel.DoClick = function(pnl)
      if IsValid(pnl.Popup) then return end

      local popup = vgui.Create("EditablePanel")
      pnl.Popup = popup
      pnl.Popup.OnFocusChanged = function(popup, gained)
        if (gained) then return end


        timer.Simple(0, function()
          if (!IsValid(popup)) then return end
          if (popup:HasHierarchicalFocus()) then return end

          popup:Remove()
        end)
      end
      pnl.Popup.Think = function(pnl)
        if (pnl:HasHierarchicalFocus()) then return end
        if (!pnl.SingleFramedPassed) then
          pnl.SingleFramedPassed = true

          return
        end

        pnl:Remove()
      end
      local aX, aY = pnl:LocalToScreen()
      pnl.Popup:SetSize(180, 216)
      pnl.Popup:SetPos(aX - pnl.Popup:GetWide() + 48, aY + 48)
      pnl.Popup:SetDrawOnTop(true)
      pnl.Popup:MakePopup()
      pnl.Popup.Paint = function(pnl, w, h)
        XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Primary, false, false, true, true)
      end
      pnl.Popup:DockPadding(8, 8, 8, 8)

      local top = pnl.Popup:Add("Panel")
      pnl.Popup.Top = top
      top:Dock(TOP)
      top:SetTall(36)
      top.PerformLayout = function(pnl, w, h)
        local width = w / 3 - 2

        for i, v in ipairs(pnl:GetChildren()) do
          v:SetWide(width)
        end
      end
      top.SetColor = function(pnl, color)
        local children = pnl:GetChildren()
        assert(color ~= nil, "cannot destructure nil value")
        local r, g, b = color.r, color.g, color.b

        children[1]:SetValue(r)
        children[2]:SetValue(g)
        children[3]:SetValue(b)

        panel.Color = Color(r, g, b)
      end
      top.GetColor = function(pnl)
        local children = pnl:GetChildren()

        return Color(children[1]:GetValue(), children[2]:GetValue(), children[3]:GetValue())
      end

      local function color(i, val)
        local _panel = top:Add("DPanel")
        _panel:Dock(LEFT)
        _panel:DockMargin(0, 0, 4, 0)
        _panel.Paint = function(pnl, w, h)
          local col
          if (i == 1) then
            col = XeninUI.Theme.Red
          elseif (i == 2) then
            col = XeninUI.Theme.Green
          elseif (i == 3) then
            col = XeninUI.Theme.Blue
          end

          XeninUI:DrawRoundedBox(6, 0, 0, w, h, col)
        end

        _panel.Textentry = _panel:Add("XeninUI.TextEntry")
        local textentry = _panel.Textentry
        textentry:Dock(FILL)
        textentry:DockMargin(1, 1, 1, 1)
        textentry.textentry:SetNumeric(true)
        textentry.textentry:SetUpdateOnType(true)
        textentry.textentry.OnValueChange = function(s, text)
          pnl.Popup.Picker:SetColor(top:GetColor())

          if s:HasFocus() then
            s:SetCaretPos(#s:GetText())
          end
        end
        _panel.SetValue = function(pnl, value)
          textentry:SetText(value)
        end
        _panel.GetValue = function(pnl)
          return tonumber(textentry:GetText()) or 0
        end
      end

      for i = 1, 3 do
        color(i)end

      pnl.Popup.Picker = pnl.Popup:Add("DColorMixer")
      local picker = pnl.Popup.Picker
      picker:SetPalette(false)
      picker:SetAlphaBar(false)
      picker:SetWangs(false)
      picker:Dock(FILL)
      picker:DockMargin(0, 8, 0, 0)
      picker.OnChange = function(pnl, color)
        local r = math.Round(color.r)
        local g = math.Round(color.g)
        local b = math.Round(color.b)

        top:SetColor(color)

        if panel.onChange then
          panel:onChange(color)
        end
      end
      picker.ValueChanged = picker.OnChange
      picker:SetColor(panel.Color)
    end
    panel:SetWide(48)
    panel.Color = Color(180, 180, 180)
    panel.Paint = function(pnl, w, h)
      local size = h / 4

      XeninUI:DrawCircle(h / 2, h / 2, size, 30, pnl.Color)
    end
    panel.SetInput = function(pnl, input)
      if isstring(input) then
        pnl.Color = XeninUI:HexToRGB("#" .. input)
      else
        pnl.Color = input
      end
    end
    panel.GetSettingValue = function(pnl)
      return pnl.Color
    end

    return panel
  end
  },
  ["Popup"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("DButton")
    panel:SetText("")
    panel:DockMargin(0, 8, 6, 8)
    panel:SetWide(32)
    XeninUI:DownloadIcon(panel, "CEIrmnK")
    panel.Data = {}
    panel.GetSettingValue = function(pnl)
      return pnl.Data end
    panel.SetInput = function(pnl, value) end
    panel.Color = Color(180, 180, 180)
    panel.Paint = function(pnl, w, h)
      XeninUI:DrawIcon(4, 4, w - 8, h - 8, pnl, pnl.Color)
    end
    panel.OnCursorEntered = function(pnl, w, h)
      pnl:LerpColor("Color", color_white)
    end
    panel.OnCursorExited = function(pnl, w, h)
      pnl:LerpColor("Color", Color(180, 180, 180))
    end
    panel.RemovePopup = function(pnl)
      if (!IsValid(pnl.Popup)) then return end

      pnl.Popup:Remove()
    end
    panel.OnRemove = panel.RemovePopup
    panel.DoClick = function(pnl)
      pnl:RemovePopup()
    end

    return panel
  end
  },
  ["Range"] = {
  panel = function(self)
    local panel = vgui.Create("Panel")
    panel:DockMargin(0, 6, 6, 6)
    panel.SizeToContents = function(pnl)
      local h = pnl:GetTall()
      pnl.Min:SetTall(h)
      pnl.Separator:SetTall(h)
      pnl.Max:SetTall(h)


      local tw = 0
      surface.SetFont(pnl.Min.textentry:GetFont())
      tw = surface.GetTextSize(pnl.Min:GetText())
      tw = tw + 24
      tw = math.Clamp(tw, 28, 250)
      pnl.Min:SetWide(tw)


      tw = 0
      surface.SetFont(pnl.Max.textentry:GetFont())

      tw = surface.GetTextSize(pnl.Max:GetText())
      tw = tw + 24
      tw = math.Clamp(tw, 28, 250)
      pnl.Max:SetWide(tw)

      pnl.Separator:SizeToContents()

      local width = 0
      width = width + pnl.Min:GetWide()
      width = width + (8 + pnl.Separator:GetWide() + 8)
      width = width + pnl.Max:GetWide()

      pnl:SetWide(width)

      pnl.Min:SetPos(0, 0)
      pnl.Separator:SetPos(pnl.Min:GetWide() + 8, 9)
      pnl.Max:SetPos(pnl.Separator.x + pnl.Separator:GetWide() + 8, 0)
    end
    panel.PerformLayout = panel.SizeToContents

    panel.Min = panel:Add("XeninUI.TextEntry")
    panel.Min.textentry:SetUpdateOnType(true)
    panel.Min.textentry.OnValueChange = function(pnl)
      panel:SizeToContents()end

    panel.Separator = panel:Add("DLabel")
    panel.Separator:SetText("to")
    panel.Separator:SetFont("Xenin.Configurator.Inputs.Label")
    panel.Separator:SetContentAlignment(2)

    panel.Max = panel:Add("XeninUI.TextEntry")
    panel.Max.textentry:SetUpdateOnType(true)
    panel.Max.textentry.OnValueChange = function(pnl)
      panel:SizeToContents()end

    panel:SizeToContents()

    return panel
  end
  },
  ["TextentryList"] = {
  panel = function(self, tbl, extra)
    local split = {}
    if istable(tbl.value) then
      split = tbl.value
    else

      local value = string.Trim(tbl.value or "")
      split = util.JSONToTable(value)

      if (!split) then
        split = string.Explode(",", value)
      end
      if (value == "" or !split) then
        split = {}
      end
    end

    local panel = vgui.Create("DLabel")
    panel:DockMargin(0, 0, 8, 0)
    panel:SetFont("Xenin.Configurator.Inputs.Label")
    panel.SetTableData = function(pnl, data)
      local amt = #data
      tbl.dataRows = data

      pnl:SetAmount(amt)
    end
    panel.GetSettingValue = function(pnl)
      return tbl.dataRows
    end
    panel.SetAmount = function(pnl, amt)
      local suffix = "result" .. (amt != 1 and "s" or "")
      pnl:SetText(tostring(amt) .. " " .. tostring(suffix))
      pnl:SizeToContents()
    end
    panel.OnCursorEntered = function(pnl)
      pnl:SetCursor("hand")
    end
    panel.OnCursorExited = function(pnl)
      pnl:SetCursor("blank")
    end
    panel.RemovePopup = function(pnl)
      if (!IsValid(pnl.Popup)) then return end

      pnl.Popup:Remove()
    end
    panel.OnRemove = panel.RemovePopup
    panel.DoClick = function(pnl)
      local popup = vgui.Create("XeninUI.Configurator.DataPopup")
      pnl.Popup = popup
      popup:SetData(tbl, extra)
    end
    panel:SetTableData(split)

    return panel
  end
  },
  ["Key"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("Panel")
    panel:DockMargin(0, 8, 6, 8)
    panel.Key = tbl.defaultValue
    panel.Font = "Xenin.Configurator.Inputs.Label"
    panel:SetCursor("hand")
    panel.Paint = function(pnl, w, h)
      local code = input.GetKeyName(pnl.Key) or "NONE"
      draw.SimpleText(code:upper(), pnl.Font, w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

      XeninUI:MaskInverse(function()
        XeninUI:DrawRoundedBox(6, 1, 1, w - 2, h - 2, color_white)
      end, function()
        XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Active and XeninUI.Theme.Accent or XeninUI.Theme.Primary)
      end)
    end
    panel.OnMousePressed = function(pnl)
      pnl.Active = true
      pnl:RequestFocus()
    end
    panel.OnFocusChanged = function(pnl, gained)
      pnl.Active = gained
    end
    panel.OnKeyCodeReleased = function(pnl, keyCode)
      if (!pnl.Active) then return end

      pnl.Key = keyCode == KEY_ESCAPE and KEY_NONE or keyCode
      pnl:SizeToContentsX()
      pnl:KillFocus()
      pnl.Active = nil
    end
    panel.GetSettingValue = function(pnl)
      return pnl.Key
    end
    panel.SizeToContentsX = function(pnl)
      local code = input.GetKeyName(pnl.Key) or "NONE"
      local font = pnl.Font
      local tw = surface.GetTextSize(code:upper())

      pnl:SetWide(tw + 16)
    end
    panel:SizeToContentsX()

    return panel
  end
  },
  ["KeyValue"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("Panel")
    XeninUI:DownloadIcon(panel, "2QGKAd6")
    panel.ArrowColor = Color(180, 180, 180)
    panel.Rotation = 0
    panel:SetCursor("hand")
    panel.Paint = function(pnl, w, h)
      local size = 48 / 3
      XeninUI:DrawIconRotated(w - size, size + size / 2, size, size, pnl.Rotation, pnl, pnl.ArrowColor)
    end
    panel.SetExpanded = function(pnl, state)
      pnl.Active = state
      pnl:Lerp("Rotation", state and 180 or 0, 0.4)

      if (!IsValid(pnl.SettingsDropdown) and state) then
        pnl:CreateDropdown()
      end

      pnl:SetHeight(state)
    end
    panel.SetHeight = function(pnl, state)
      local parent = pnl:GetParent()
      local height = 48
      if state then height = height + pnl.SettingsDropdown:GetHeight()
      end
      pnl.Think = function()

        parent:GetParent():GetParent():GetParent():InvalidateLayout(true)
      end
      parent:EndAnimations()
      parent:Lerp("Height", height, 0.4)
      parent:LerpHeight(height, 0.4, function()
        if (!IsValid(pnl)) then return end

        pnl.Think = function() end
      end)
    end
    panel.OnCursorEntered = function(pnl)
      pnl:LerpColor("ArrowColor", color_white)
    end
    panel.OnCursorExited = function(pnl)
      if (pnl.Active) then return end

      pnl:LerpColor("ArrowColor", Color(180, 180, 180))
    end
    panel.OnMousePressed = function(pnl)
      pnl:SetExpanded(!pnl.Active)
    end
    panel.CreateDropdown = function(pnl)
      local settings = pnl:Add("Panel")
      pnl.SettingsDropdown = settings
      settings:Dock(FILL)
      settings:DockMargin(0, 48, 0, 8)
      settings.GetHeight = function(pnl)
        local h = 48
        for i, v in ipairs(pnl.Rows) do
          h = h + (v:GetTall() + 4)
        end

        return h
      end

      settings.Content = settings:Add("Panel")
      settings.Content:Dock(FILL)
      settings.Content:DockMargin(0, 0, 0, 8)

      settings.Rows = {}

      settings.Bottom = settings:Add("Panel")
      settings.Bottom:Dock(BOTTOM)
      settings.Bottom:SetTall(32)

      settings.New = settings.Bottom:Add("XeninUI.ButtonV2")
      settings.New:Dock(RIGHT)
      settings.New:SetText("Create New")
      settings.New:SetFont("Xenin.Configurator.KeyValue")
      settings.New:SizeToContentsX(24)
      settings.New:SetRoundness(6)
      settings.New:SetSolidColor(XeninUI.Theme.Primary)
      settings.New:SetHoverColor(XeninUI.Theme.Green)
      settings.New.DoClick = function(pnl)
        settings:CreateRow(nil, tbl.data.right.default)

        settings:GetParent():SetHeight(true)
      end

      settings.SetData = function(pnl, data)
        for i, v in pairs(data) do
          pnl:CreateRow(i, v)
        end
      end

      settings.CreateRow = function(pnl, i, v)
        local col = XeninUI.Theme.Navbar
        local row = settings.Content:Add("Panel")
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 4)
        row:SetTall(40)
        row.Think = function(pnl)
          pnl.Delete:SetVisible(pnl:IsHovered() or pnl:IsChildHovered())
        end
        row.Paint = function(pnl, w, h)
          XeninUI:DrawRoundedBox(6, 0, 0, w, h, col)
        end

        local left = tbl.data.left or {}
        row.Left = XeninUI.Configurator:CreateInputPanel(left.type, self, tbl)
        row.Left:SetParent(row)
        row.Left:Dock(LEFT)
        row.Left:DockMargin(0, 0, 0, 0)
        if (left.type == "Textentry") then
          row.Left:SetPlaceholder(left.placeholder or "")
          row.Left:SetInput(i or "")
          row.Left:SetTextColor(Color(180, 180, 180))
          local paint = row.Left.Paint
          row.Left.OutlineColor = XeninUI.Theme.Primary
          row.Left.Paint = function(pnl, w, h)
            if paint then paint(pnl, w, h)end

            XeninUI:MaskInverse(function()
              XeninUI:DrawRoundedBoxEx(6, 1, 1, w - 2, h - 2, pnl.OutlineColor, true, false, true, false)
            end, function()
              XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, pnl.textentry:HasFocus() and XeninUI.Theme.Accent or pnl.OutlineColor, true, false, true, false)
            end)
          end
        end
        if row.Left.SetData then
          row.Left:SetData(tbl.data.left)
          row.Left:SetInput(i or tbl.data.left.default)
        end
        if row.Left.SetBackgroundColor then
          row.Left:SetBackgroundColor(col)
        end

        local right = tbl.data.right or {}
        row.Right = XeninUI.Configurator:CreateInputPanel(right.type, self, right)
        row.Right:SetParent(row)
        row.Right:Dock(RIGHT)
        row.Right:DockMargin(0, 0, 0, 0)
        if (right.type == "Textentry") then
          if right.placeholder then
            row.Right:SetPlaceholder(right.placeholder)
          end
          row.Right:SetInput(tostring(v))
          if right.readOnly then
            row.Right:SetEnabled(false)
            row.Right.textentry:SetEnabled(false)
            row.Right.textentry:SetCursor("no")
          end
          if right.number then
            row.Right:SetNumeric(true)
          end
        elseif (right.type == "TextentryWithLabel") then
          row.Right.textentry:SetPlaceholder(right.placeholder or "")
          row.Right.textentry:SetText(v or right.default or "")
          row.Right.textentry:DoSizing(row.Right.textentry:GetText())
        end

        if row.Right.SetBackgroundColor then
          row.Right:SetBackgroundColor(col)
        end

        row.Right:SetVisible(!right.hide)

        row.Delete = row:Add("DButton")
        row.Delete:SetVisible(false)
        row.Delete:Dock(RIGHT)
        row.Delete:SetText("")
        row.Delete.Paint = function(pnl, w, h)
          XeninUI:DrawRoundedBox(6, 4, 4, w - 8, h - 8, XeninUI.Theme.Red)

          surface.SetMaterial(XeninUI.Materials.CloseButton)
          surface.SetDrawColor(color_white)
          local size = h * 0.35
          surface.DrawTexturedRect(w / 2 - size / 2, h / 2 - size / 2, size, size)
        end
        row.Delete.DoClick = function(pnl, w, h)
          for i, v in ipairs(settings.Rows) do
            if (tobool(v != row)) then continue end

            table.remove(settings.Rows, i)
          end

          row:Remove()
          settings:GetParent():SetHeight(true)
        end
        row.Delete:SetWide(40)

        row.GetSettingValue = function(pnl)
          return {
            key = pnl.Left:GetSettingValue(),
            value = pnl.Right:GetSettingValue()
          }
        end

        table.insert(pnl.Rows, row)
      end

      settings:SetData(tbl.value)
    end
    panel:SetWide(600)
    panel.GetSettingValue = function(pnl)
      if (!IsValid(pnl.SettingsDropdown)) then
        pnl:CreateDropdown()
      end

      local tbl = {}

      for i, v in ipairs(pnl.SettingsDropdown.Rows) do
        local rowTbl = v:GetSettingValue()
        tbl[rowTbl.key] = rowTbl.value
      end

      return tbl
    end

    return panel
  end
  },
  ["SliderPad"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("XeninUI.SliderPad")
    panel:DockMargin(0, 8, 0, 8)
    panel.GetSettingValue = function(pnl)
      return pnl:GetValue()
    end
    panel.Textentry:SetWide(((tbl and tbl.data) and tbl.data.textWidth) or 40)

    panel:SetMin(((tbl and tbl.data) and tbl.data.min) or 0)
    panel:SetMax(((tbl and tbl.data) and tbl.data.max) or 10)
    panel:SetValue(tbl.value)
    panel:SetWide(((tbl and tbl.data) and tbl.data.width) or 200)
    panel:SetColor(((tbl and tbl.data) and tbl.data.color) or XeninUI.Theme.Accent)

    return panel
  end
  },
  ["ListDropdownDarkRPCategories"] = {
  panel = function(self, tbl)
    local panel = vgui.Create("Panel")
    XeninUI:DownloadIcon(panel, "2QGKAd6")
    panel.ArrowColor = Color(180, 180, 180)
    panel.Rotation = 0
    panel:SetCursor("hand")
    panel.Paint = function(pnl, w, h)
      local size = 48 / 3
      XeninUI:DrawIconRotated(w - size, size + size / 2, size, size, pnl.Rotation, pnl, pnl.ArrowColor)
    end
    panel.SetExpanded = function(pnl, state)
      pnl.Active = state
      pnl:Lerp("Rotation", state and 180 or 0, 0.4)

      if (!IsValid(pnl.SettingsDropdown) and state) then
        pnl:CreateDropdown()
      end

      pnl:SetHeight(state)
    end
    panel.SetHeight = function(pnl, state)
      local parent = pnl:GetParent()
      local height = 48
      if state then height = height + pnl.SettingsDropdown:GetHeight()
      end
      pnl.Think = function()

        parent:GetParent():GetParent():GetParent():InvalidateLayout(true)
      end
      parent:EndAnimations()
      parent:Lerp("Height", height, 0.4)
      parent:LerpHeight(height, 0.4, function()
        if (!IsValid(pnl)) then return end

        pnl.Think = function() end
      end)
    end
    panel.OnCursorEntered = function(pnl)
      pnl:LerpColor("ArrowColor", color_white)
    end
    panel.OnCursorExited = function(pnl)
      if (pnl.Active) then return end

      pnl:LerpColor("ArrowColor", Color(180, 180, 180))
    end
    panel.OnMousePressed = function(pnl)
      pnl:SetExpanded(!pnl.Active)
    end
    panel.CreateDropdown = function(pnl)
      local settings = pnl:Add("Panel")
      pnl.SettingsDropdown = settings
      settings:Dock(FILL)
      settings:DockMargin(0, 48, 0, 8)
      settings.GetHeight = function(pnl)
        local h = 48
        for i, v in ipairs(pnl.Rows) do
          h = h + (v:GetTall() + 4)
        end

        return h
      end

      settings.Content = settings:Add("Panel")
      settings.Content:Dock(FILL)
      settings.Content:DockMargin(0, 0, 0, 8)

      settings.Rows = {}

      settings.Bottom = settings:Add("Panel")
      settings.Bottom:Dock(BOTTOM)
      settings.Bottom:SetTall(32)

      settings.New = settings.Bottom:Add("XeninUI.ButtonV2")
      settings.New:Dock(RIGHT)
      settings.New:SetText("Add New")
      settings.New:SetFont("Xenin.Configurator.KeyValue")
      settings.New:SizeToContentsX(24)
      settings.New:SetRoundness(6)
      settings.New:SetSolidColor(XeninUI.Theme.Primary)
      settings.New:SetHoverColor(XeninUI.Theme.Green)
      settings.New.DoClick = function(btn)
        local existingCategories = pnl:GetSettingValue()
        local allCategories = DarkRP.getCategories().jobs
        local categories = {}
        for i, v in ipairs(allCategories) do
          if (existingCategories[v.name]) then continue end

          table.insert(categories, v)
        end

        local options = XeninUI.Options(pnl)
        for i, v in ipairs(categories) do
          options:addButton({
            text = v.name,
            onClick = function()
              settings:CreateRow(v.name)
              settings:GetParent():SetHeight(true)
            end
          })
        end
        options:create()
      end

      settings.SetData = function(pnl, data)
        for i, v in pairs(data) do
          print(i, v)
          pnl:CreateRow(i)
        end
      end
      settings.CreateRow = function(pnl, name)
        local col = XeninUI.Theme.Navbar
        local row = settings.Content:Add("Panel")
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 4)
        row:SetTall(40)
        row.Think = function(pnl)
          pnl.Delete:SetVisible(pnl:IsHovered() or pnl:IsChildHovered())
        end
        row.Paint = function(pnl, w, h)
          XeninUI:DrawRoundedBox(6, 0, 0, w, h, col)
        end

        row.Left = row:Add("DLabel")
        row.Left:Dock(LEFT)
        row.Left:DockMargin(12, 0, 0, 0)
        row.Left:SetFont("XeninUI.TextEntry")
        row.Left:SetText(name)
        row.Left:SetTextColor(Color(180, 180, 180))
        row.Left:SizeToContentsX()

        row.Delete = row:Add("DButton")
        row.Delete:SetVisible(false)
        row.Delete:Dock(RIGHT)
        row.Delete:SetText("")
        row.Delete.Paint = function(pnl, w, h)
          XeninUI:DrawRoundedBox(6, 4, 4, w - 8, h - 8, XeninUI.Theme.Red)

          surface.SetMaterial(XeninUI.Materials.CloseButton)
          surface.SetDrawColor(color_white)
          local size = h * 0.35
          surface.DrawTexturedRect(w / 2 - size / 2, h / 2 - size / 2, size, size)
        end
        row.Delete.DoClick = function(pnl, w, h)
          for i, v in ipairs(settings.Rows) do
            if (tobool(v != row)) then continue end

            table.remove(settings.Rows, i)
          end

          row:Remove()
          settings:GetParent():SetHeight(true)
        end
        row.Delete:SetWide(40)

        row.GetSettingValue = function(pnl)
          return {
            key = pnl.Left:GetText(),
            value = true
          }
        end

        table.insert(pnl.Rows, row)
      end

      settings:SetData(tbl.value)
    end
    panel:SetWide(600)
    panel.GetSettingValue = function(pnl)
      if (!IsValid(pnl.SettingsDropdown)) then
        pnl:CreateDropdown()
      end

      local tbl = {}

      for i, v in ipairs(pnl.SettingsDropdown.Rows) do
        local rowTbl = v:GetSettingValue()
        tbl[rowTbl.key] = rowTbl.value
      end

      return tbl
    end

    return panel
  end
  }
}

function XeninUI.Configurator:CreateInputPanel(panel, bindTo, tbl, extra)
  if extra == nil then extra = {}
  end
  return self.InputPanels[panel].panel(bindTo, tbl, extra)
end

local PANEL = {}

XeninUI:CreateFont("Xenin.Configurator.Admin.Data.Title", 22)
XeninUI:CreateFont("Xenin.Configurator.Admin.Data.Button", 16)
XeninUI:CreateFont("Xenin.Configurator.Admin.Data.Row", 16)

function PANEL:Init()
  self:SetSize(ScrW(), ScrH())
  self:SetBackgroundWidth(500)
  self:SetBackgroundHeight(500)
  self:MakePopup()

  self.Body = self:Add("Panel")
  self.Body:Dock(FILL)
  self.Body:DockPadding(16, 16, 16, 16)

  self.Top = self.Body:Add("Panel")
  self.Top:Dock(TOP)
  self.Top:SetTall(28)

  self.Title = self.Top:Add("DLabel")
  self.Title:Dock(LEFT)
  self.Title:SetFont("Xenin.Configurator.Admin.Data.Title")

  self.Save = self.Top:Add("XeninUI.ButtonV2")
  self.Save:Dock(RIGHT)
  self.Save:SetFont("Xenin.Configurator.Admin.Data.Button")
  self.Save:SetText("Save Rows")
  self.Save:SizeToContentsX(16)
  self.Save:SetRoundness(6)
  self.Save:SetSolidColor(XeninUI.Theme.Blue)
  self.Save.DoClick = function(pnl)
    self:OnSave(self.Results)
  end

  self.Create = self.Top:Add("XeninUI.ButtonV2")
  self.Create:Dock(RIGHT)
  self.Create:DockMargin(0, 0, 8, 0)
  self.Create:SetFont("Xenin.Configurator.Admin.Data.Button")
  self.Create:SetText("Create New")
  self.Create:SizeToContentsX(16)
  self.Create:SetRoundness(6)
  self.Create:SetSolidColor(XeninUI.Theme.Primary)
  self.Create.DoClick = function(pnl)
    local newId = #self.Results + 1

    self:CreateRow(newId, "")
    self:SetResultsTitle()
  end

  self.Scroll = self.Body:Add("XeninUI.Scrollpanel.Wyvern")
  self.Scroll:Dock(FILL)
  self.Scroll:DockMargin(0, 16, 0, 0)
end

function PANEL:Add(pnl)
  return self.background:Add(pnl)
end

function PANEL:SetData(data, extra)
  self.Results = data.dataRows
  self.Data = data
  self.Extra = extra

  self:SetTitle(extra.name)
  self:CreateRows(self.Results)
end

function PANEL:SetResultsTitle()
  local amt = #self.Results
  local str = "row" .. (amt != 1 and "s" or "")
  self.Title:SetText(amt .. " " .. str)
  self.Title:SizeToContents()
end

function PANEL:CreateRows(data)
  for i, v in ipairs(data) do
    self:CreateRow(i, v)
  end

  self:SetResultsTitle()
end

function PANEL:CreateRow(id, val)
  local row = self.Scroll:Add("DPanel")
  row:Dock(TOP)
  row:DockMargin(0, 0, 8, 4)
  row:SetTall(36)
  row.Id = id
  row.Color = id % 2 == 0 and XeninUI.Theme.Primary or XeninUI.Theme.Navbar
  row.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Color)

    draw.SimpleText("#" .. tostring(pnl.Id), "Xenin.Configurator.Admin.Data.Row", 8, h / 2, Color(174, 174, 174), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    pnl.Delete:SetVisible(pnl:IsHovered() or pnl:IsChildHovered())
  end

  row.Delete = row:Add("DButton")
  row.Delete:Dock(LEFT)
  row.Delete:SetWide(40)
  row.Delete:SetText("")
  row.Delete.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Red, true, false, true, false)

    surface.SetMaterial(XeninUI.Materials.CloseButton)
    surface.SetDrawColor(color_white)
    local size = h * 0.4
    surface.DrawTexturedRect(w / 2 - size / 2, h / 2 - size / 2, size, size)
  end
  row.Delete.DoClick = function(pnl, w, h)
    table.remove(self.Results, row.Id)
    row:Remove()

    local index = 1
    for i, v in ipairs(self.Scroll:GetCanvas():GetChildren()) do
      if (!IsValid(v)) then continue end

      v.Id = index
      v.Input.textentry:OnValueChange(v.Input:GetText())

      index = index + 1
    end

    self:SetResultsTitle()
  end

  row.Input = row:Add("XeninUI.TextEntry")
  row.Input:Dock(RIGHT)
  row.Input:SetBackgroundColor(row.Color)
  row.Input:SetFont("Xenin.Configurator.Admin.Data.Row")
  row.Input:SetPlaceholder("Value")
  row.Input.textentry:SetUpdateOnType(true)
  row.Input.textentry.OnValueChange = function(pnl, text)
    surface.SetFont(pnl:GetFont())
    local text = pnl:GetText()
    self.Results[row.Id] = text
    if (text == "") then text = row.Input:GetPlaceholder()end
    local tw = surface.GetTextSize(text)
    tw = tw + 24
    local width = math.Clamp(tw, 28, 600)
    row.Input:SetWide(width)
  end
  row.Input:SetText(val)
  row.Input.textentry:OnValueChange(val)
end

function PANEL:OnSave(data)
  self.Extra.parent.Input:SetTableData(data)
end

vgui.Register("XeninUI.Configurator.DataPopup", PANEL, "XeninUI.Popup")
