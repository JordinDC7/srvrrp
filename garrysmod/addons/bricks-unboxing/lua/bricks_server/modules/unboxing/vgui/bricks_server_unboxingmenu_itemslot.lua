local PANEL = {}

local function BRS_UC_FitText(font, text, maxW)
    text = tostring(text or "")
    surface.SetFont(font)

    local tw = surface.GetTextSize(text)
    if tw <= maxW then return text end

    local ellipsis = "..."
    local ew = surface.GetTextSize(ellipsis)
    if ew >= maxW then return "" end

    local out = ""
    for i = 1, #text do
        local candidate = string.sub(text, 1, i)
        local cw = surface.GetTextSize(candidate)
        if (cw + ew) > maxW then break end
        out = candidate
    end

    return out .. ellipsis
end

local function BRS_UC_ResolveColor(col, fallback)
    if IsColor(col) then return col end

    if isnumber(col) then
        local themed = BRICKS_SERVER and BRICKS_SERVER.Func and BRICKS_SERVER.Func.GetTheme and BRICKS_SERVER.Func.GetTheme(col)
        if IsColor(themed) then
            return themed
        end
    end

    if IsColor(fallback) then return fallback end
    return Color(255, 255, 255)
end

local function BRS_UC_DrawTopPill(x, y, h, text, bgCol, txtCol, font, maxPillW)
    text = tostring(text or "")
    font = font or "BRICKS_SERVER_Font15"

    local innerPad = 8
    local minPillW = 28
    local textMaxW = math.max(1, (maxPillW or 120) - (innerPad * 2))

    local fitted = BRS_UC_FitText(font, text, textMaxW)

    surface.SetFont(font)
    local tw = surface.GetTextSize(fitted)

    local pillW = math.Clamp(tw + (innerPad * 2), minPillW, maxPillW or 120)

    local pillBgCol = BRS_UC_ResolveColor(bgCol, BRICKS_SERVER.Func.GetTheme(1))
    local pillTxtCol = BRS_UC_ResolveColor(txtCol, BRICKS_SERVER.Func.GetTheme(6))

    draw.RoundedBox(6, x, y, pillW, h, pillBgCol)
    draw.SimpleText(fitted, font, x + pillW / 2, y + h / 2, pillTxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    return pillW
end

local function alphaColor(col, a)
    if not col then return Color(255, 255, 255, a or 255) end
    return Color(col.r or 255, col.g or 255, col.b or 255, a or col.a or 255)
end

local function BRS_UC_GetDisplayName(itemName, rarityName)
    local cleanName = string.Trim(tostring(itemName or ""))
    local cleanRarity = string.Trim(tostring(rarityName or ""))
    if (cleanName == "" or cleanRarity == "") then return cleanName end

    local lowerName = string.lower(cleanName)
    local lowerRarity = string.lower(cleanRarity)
    if string.StartWith(lowerName, lowerRarity .. " ") then
        return string.Trim(string.sub(cleanName, #cleanRarity + 2))
    end

    return cleanName
end

function PANEL:Init()
    self.themeNum = self.themeNum or 2
    self.hoverAnim = 0
    self.topInfo = {}
    self.itemAmount = 1
    self.actions = nil
    self.clickFunc = nil
    self.globalKey = nil
    self.configItem = nil
    self.rarityInfo = nil
    self.rarityKey = nil

    self:SetCursor("hand")
end

function PANEL:FillPanel(globalKey, amount, actionsOrClickFunc)
    local suppliedItemTable
    if istable(globalKey) then
        self.globalKey = globalKey[1]
        suppliedItemTable = globalKey[2]
    else
        self.globalKey = globalKey
    end

    self.itemAmount = tonumber(amount) or 1
    self.actions = nil
    self.clickFunc = nil

    if istable(actionsOrClickFunc) then
        self.actions = actionsOrClickFunc
    elseif isfunction(actionsOrClickFunc) then
        self.clickFunc = actionsOrClickFunc
    end

    local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey(self.globalKey)
    self.configItem = configItemTable or suppliedItemTable

    if self.configItem then
        self.rarityInfo, self.rarityKey = BRICKS_SERVER.Func.GetRarityInfo(self.configItem.Rarity or "")
    else
        self.rarityInfo, self.rarityKey = BRICKS_SERVER.Func.GetRarityInfo("")
    end

    local itemType = tostring((self.configItem or {}).Type or "")
    local isWeaponItem = (itemType == "Weapon" or itemType == "PermWeapon")

    local statTrakSummary = BRICKS_SERVER.UNBOXING.Func.GetStatTrakSummary(LocalPlayer(), globalKey)
    if ((self.itemAmount or 1) <= 1 and not isWeaponItem and statTrakSummary and statTrakSummary.TierTag and statTrakSummary.Score) then
        self:AddTopInfo(
            string.format("%s %.2f", tostring(statTrakSummary.TierTag), tonumber(statTrakSummary.Score) or 0),
            statTrakSummary.TierColor,
            BRICKS_SERVER.Func.GetTheme(5),
            true
        )
    end

    if (self.itemAmount or 1) > 1 then
        self:AddTopInfo(tostring(self.itemAmount) .. "x")
    end

    self:RefreshItemPreviewPanel()

    return self
end

function PANEL:RefreshItemPreviewPanel()
    if IsValid(self.previewPanel) then
        self.previewPanel:Remove()
    end

    local itemTable = self.configItem or {}
    local globalKey = tostring(self.globalKey or "")
    local displayType = string.StartWith(globalKey, "CASE_") and "CASE" or (string.StartWith(globalKey, "KEY_") and "KEY" or "ITEM")

    self.previewPanel = vgui.Create("bricks_server_unboxing_itemdisplay", self)
    self.previewPanel:SetMouseInputEnabled(false)
    self.previewPanel:SetKeyboardInputEnabled(false)
    self.previewPanel:SetIconSizeAdjust(0.75)
    self.previewPanel:SetItemData(displayType, itemTable)

    self:InvalidateLayout(true)
end

function PANEL:AddTopInfo(text, bgColor, textColor, prioritizeLeft)
    self.topInfo = self.topInfo or {}

    table.insert(self.topInfo, {
        text = tostring(text or ""),
        bg = bgColor or BRICKS_SERVER.Func.GetTheme(1),
        fg = textColor or BRICKS_SERVER.Func.GetTheme(6),
        left = prioritizeLeft and true or false
    })

    return self
end

function PANEL:DoClick()
    if isfunction(self.clickFunc) then
        self.clickFunc()
        return
    end

    if istable(self.actions) and #self.actions > 0 then
        local menu = DermaMenu()

        for _, action in ipairs(self.actions) do
            local label = action[1]
            local fn = action[2]

            if isfunction(label) then
                label = label()
            end

            label = tostring(label or "Action")

            if isfunction(fn) then
                menu:AddOption(label, fn)
            else
                menu:AddOption(label)
            end
        end

        menu:Open()
    end
end

function PANEL:OnMousePressed(keyCode)
    if keyCode == MOUSE_RIGHT then
        self:DoClick()
        return
    end

    self.BaseClass.OnMousePressed(self, keyCode)
end

function PANEL:Paint(w, h)
    local hovered = self:IsHovered()
    self.hoverAnim = Lerp(FrameTime() * 12, self.hoverAnim, hovered and 1 or 0)

    local baseBg = BRICKS_SERVER.Func.GetTheme(self.themeNum or 2)
    local innerBg = BRICKS_SERVER.Func.GetTheme(((self.themeNum or 2) == 1 and 2) or 1)
    local txtCol = BRICKS_SERVER.Func.GetTheme(6)
    local item = self.configItem or {}
    local rarityName = tostring(item.Rarity or "")
    local rarityColor = BRICKS_SERVER.Func.GetRarityColor(self.rarityInfo or rarityName) or Color(255, 255, 255)

    draw.RoundedBox(10, 0, 0, w, h, baseBg)

    local borderGlow = 12 + (18 * self.hoverAnim)
    local blurLayers = math.floor((tonumber(self.hoverAnim) or 0) * 2)
    if blurLayers > 0 and BRICKS_SERVER and BRICKS_SERVER.Func and isfunction(BRICKS_SERVER.Func.DrawBlur) then
        BRICKS_SERVER.Func.DrawBlur(self, blurLayers, blurLayers)
    end
    surface.SetDrawColor(alphaColor(rarityColor, borderGlow))
    surface.DrawOutlinedRect(0, 0, w, h, 1)

    if self.hoverAnim > 0.001 then
        draw.RoundedBox(10, 0, 0, w, h, alphaColor(rarityColor, 12 * self.hoverAnim))
    end

    local topStripH = 26
    draw.RoundedBoxEx(10, 0, 0, w, topStripH, alphaColor(innerBg, 175), true, true, false, false)

    local infos = self.topInfo or {}
    if #infos > 0 then
        local pillH = 16
        local topPad = 5
        local sidePad = 6
        local pillGap = 4
        local pillFont = "BRICKS_SERVER_Font15"

        local leftX = sidePad
        local rightX = w - sidePad

        local leftPills = {}
        local rightPills = {}

        for _, info in ipairs(infos) do
            if info.left then
                leftPills[#leftPills + 1] = info
            else
                rightPills[#rightPills + 1] = info
            end
        end

        local maxPillW = math.floor((w - (sidePad * 2) - pillGap) * 0.48)

        for _, info in ipairs(leftPills) do
            local remaining = (rightX - leftX) - pillGap
            if remaining < 28 then break end

            local thisMax = math.min(maxPillW, remaining)
            local pw = BRS_UC_DrawTopPill(leftX, topPad, pillH, info.text, info.bg, info.fg, pillFont, thisMax)
            leftX = leftX + pw + pillGap
        end

        for _, info in ipairs(rightPills) do
            local remaining = (rightX - leftX) - pillGap
            if remaining < 28 then break end

            local thisMax = math.min(maxPillW, remaining)

            surface.SetFont(pillFont)
            local pad = 8
            local fitted = BRS_UC_FitText(pillFont, tostring(info.text or ""), math.max(1, thisMax - (pad * 2)))
            local tw = surface.GetTextSize(fitted)
            local pw = math.Clamp(tw + (pad * 2), 28, thisMax)

            rightX = rightX - pw
            BRS_UC_DrawTopPill(rightX, topPad, pillH, info.text, info.bg, info.fg, pillFont, thisMax)
            rightX = rightX - pillGap
        end
    end

    local contentTop = topStripH + 6
    local bottomPad = 34
    local contentH = math.max(20, h - contentTop - bottomPad)

    draw.RoundedBox(8, 6, contentTop, w - 12, contentH, alphaColor(innerBg, 155))
    draw.RoundedBox(8, 6, contentTop, w - 12, 4, alphaColor(rarityColor, 175))

    if IsValid(self.previewPanel) then
        self.previewPanel:SetPos(6, contentTop)
        self.previewPanel:SetSize(w - 12, contentH)
    end

    local itemName = tostring(item.Name or BRICKS_SERVER.Func.L("unknown") or "Unknown")
    local displayName = BRS_UC_GetDisplayName(itemName, rarityName)

    local textInset = 8
    local textW = w - (textInset * 2)

    local fitName = BRS_UC_FitText("BRICKS_SERVER_Font20", displayName, textW)
    local fitRarity = BRS_UC_FitText("BRICKS_SERVER_Font17", rarityName, textW)

    draw.SimpleText(fitName, "BRICKS_SERVER_Font20", w / 2, h - 26, alphaColor(txtCol, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(fitRarity, "BRICKS_SERVER_Font17", w / 2, h - 11, alphaColor(rarityColor, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.RoundedBoxEx(6, 0, h - 6, w, 6, rarityColor, false, false, true, true)

    return true
end

function PANEL:OnRemove()
    if IsValid(self.previewPanel) then
        self.previewPanel:Remove()
    end
end

vgui.Register("bricks_server_unboxingmenu_itemslot", PANEL, "DButton")
