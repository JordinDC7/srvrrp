local PANEL = {}

-- ---------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------
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

    draw.RoundedBox(6, x, y, pillW, h, bgCol)
    draw.SimpleText(fitted, font, x + pillW / 2, y + h / 2, txtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

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

-- ---------------------------------------------------------
-- Panel lifecycle
-- ---------------------------------------------------------
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

-- ---------------------------------------------------------
-- API used by store/inventory/case views
-- FillPanel(globalKey, amount, actionsOrClickFunc)
-- ---------------------------------------------------------
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

    -- Auto add stack count for inventory-like entries if >1 (right side pill)
    if (self.itemAmount or 1) > 1 then
        self:AddTopInfo(tostring(self.itemAmount) .. "x")
    end

    -- Ensure every slot has a concrete model/icon panel so previews render reliably.
    self:RefreshItemPreviewPanel()

    return self
end

-- Creates or refreshes the embedded preview panel used to display item models/icons.
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

-- ---------------------------------------------------------
-- Add top-left / top-right pill
-- prioritizeLeft=true draws on left side
-- ---------------------------------------------------------
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

-- ---------------------------------------------------------
-- Input
-- ---------------------------------------------------------
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

-- ---------------------------------------------------------
-- Paint
-- ---------------------------------------------------------
function PANEL:Paint(w, h)
    local hovered = self:IsHovered()
    self.hoverAnim = Lerp(FrameTime() * 10, self.hoverAnim, hovered and 1 or 0)

    local baseBg = BRICKS_SERVER.Func.GetTheme(self.themeNum or 2)
    local innerBg = BRICKS_SERVER.Func.GetTheme(((self.themeNum or 2) == 1 and 2) or 1)
    local txtCol = BRICKS_SERVER.Func.GetTheme(6)

    -- Card background
    draw.RoundedBox(8, 0, 0, w, h, baseBg)

    -- Soft hover brighten
    if self.hoverAnim > 0.001 then
        surface.SetAlphaMultiplier(self.hoverAnim * (18 / 255))
        draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255))
        surface.SetAlphaMultiplier(1)
    end

    -- Top info strip area background (subtle)
    local topStripH = 24
    draw.RoundedBoxEx(8, 0, 0, w, topStripH, alphaColor(innerBg, 160), true, true, false, false)

    -- -----------------------------------------------------
    -- TOP INFO PILLS (responsive; prevents clipping/overlap)
    -- -----------------------------------------------------
    do
        local infos = self.topInfo or {}
        if #infos > 0 then
            local pillH = 16
            local topPad = 4
            local sidePad = 5
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

            -- Draw left pills first
            for _, info in ipairs(leftPills) do
                local remaining = (rightX - leftX) - pillGap
                if remaining < 28 then break end

                local thisMax = math.min(maxPillW, remaining)
                local pw = BRS_UC_DrawTopPill(
                    leftX,
                    topPad,
                    pillH,
                    info.text,
                    info.bg,
                    info.fg,
                    pillFont,
                    thisMax
                )

                leftX = leftX + pw + pillGap
            end

            -- Draw right pills from right inward
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

                BRS_UC_DrawTopPill(
                    rightX,
                    topPad,
                    pillH,
                    info.text,
                    info.bg,
                    info.fg,
                    pillFont,
                    thisMax
                )

                rightX = rightX - pillGap
            end
        end
    end

    -- -----------------------------------------------------
    -- Item display region (background + child preview panel)
    -- -----------------------------------------------------
    local contentTop = topStripH + 6
    local bottomPad = 32
    local contentH = math.max(20, h - contentTop - bottomPad)

    -- Inner frame for icon/model area
    draw.RoundedBox(6, 5, contentTop, w - 10, contentH, alphaColor(innerBg, 135))

    local item = self.configItem or {}
    local itemName = tostring(item.Name or BRICKS_SERVER.Func.L("unknown") or "Unknown")
    local rarityName = tostring(item.Rarity or "")
    local displayName = BRS_UC_GetDisplayName(itemName, rarityName)

    local rarityColor = BRICKS_SERVER.Func.GetRarityColor(self.rarityInfo or rarityName) or Color(255,255,255)

    if IsValid(self.previewPanel) then
        self.previewPanel:SetPos(5, contentTop)
        self.previewPanel:SetSize(w - 10, contentH)
    end

    -- -----------------------------------------------------
    -- Bottom texts
    -- -----------------------------------------------------
    local nameY = h - 26
    local rarityY = h - 11
    local textInset = 8
    local textW = w - (textInset * 2)

    local nameFont = "BRICKS_SERVER_Font20"
    local rarityFont = "BRICKS_SERVER_Font17"

    local fitName = BRS_UC_FitText(nameFont, displayName, textW)
    local fitRarity = BRS_UC_FitText(rarityFont, rarityName, textW)

    draw.SimpleText(fitName, nameFont, w / 2, nameY, alphaColor(txtCol, 185), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(fitRarity, rarityFont, w / 2, rarityY, alphaColor(rarityColor, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Rarity accent bar at bottom
    draw.RoundedBoxEx(4, 0, h - 6, w, 6, rarityColor, false, false, true, true)

    -- subtle top edge
    surface.SetDrawColor(255, 255, 255, 6)
    surface.DrawRect(1, 1, w - 2, 1)

    return true
end

function PANEL:OnRemove()
    if IsValid(self.previewPanel) then
        self.previewPanel:Remove()
    end
end

vgui.Register("bricks_server_unboxingmenu_itemslot", PANEL, "DButton")
