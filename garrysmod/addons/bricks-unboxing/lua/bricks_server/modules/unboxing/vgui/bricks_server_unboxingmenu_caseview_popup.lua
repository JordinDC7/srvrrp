local PANEL = {}

function PANEL:Init()

end

function PANEL:CreatePopout()
    self.panelWide, self.panelTall = self:GetSize()
    self.popoutWide, self.popoutTall = self.panelWide * 0.9, self.panelTall * 0.9

    self.popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel(self, self.panelWide, self.panelTall, self.popoutWide, self.popoutTall)
    self.popoutPanel.Paint = function(self2, w, h)
        draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))
    end
    self.popoutPanel.OnRemove = function()
        self:Remove()
    end

    self.leftPanel = vgui.Create("DPanel", self.popoutPanel)
    self.leftPanel:Dock(LEFT)
    self.leftPanel:SetWide(self.popoutWide * 0.25)
    self.leftPanel.Paint = function(self2, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(3), true, false, true, false)
    end

    local infoHeader = vgui.Create("DPanel", self.leftPanel)
    infoHeader:Dock(TOP)
    infoHeader:SetTall(60)
    infoHeader.Paint = function(self2, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2), true, false, false, false)
        draw.SimpleText(BRICKS_SERVER.Func.L("unboxingInformation"), "BRICKS_SERVER_Font21", w / 2, h / 2, BRICKS_SERVER.Func.GetTheme(6, 75), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.mainPanel = vgui.Create("DPanel", self.popoutPanel)
    self.mainPanel:Dock(FILL)
    self.mainPanel.Paint = function() end

    self.closeButton = vgui.Create("DButton", self.mainPanel)
    self.closeButton:Dock(BOTTOM)
    self.closeButton:SetTall(40)
    self.closeButton:SetText("")
    self.closeButton:DockMargin(25, 0, 25, 25)
    local changeAlpha = 0
    self.closeButton.Paint = function(self2, w, h)
        if (not self2:IsDown() and self2:IsHovered()) then
            changeAlpha = math.Clamp(changeAlpha + 10, 0, 255)
        else
            changeAlpha = math.Clamp(changeAlpha - 10, 0, 255)
        end

        draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(5))

        surface.SetAlphaMultiplier(changeAlpha / 255)
        draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(4))
        surface.SetAlphaMultiplier(1)

        BRICKS_SERVER.Func.DrawClickCircle(self2, w, h, BRICKS_SERVER.Func.GetTheme(4), 8)
        draw.SimpleText(BRICKS_SERVER.Func.L("close"), "BRICKS_SERVER_Font20", w / 2, h / 2, BRICKS_SERVER.Func.GetTheme(6), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.closeButton.DoClick = self.popoutPanel.ClosePopout

    self.topPanel = vgui.Create("DPanel", self.mainPanel)
    self.topPanel:Dock(TOP)
    self.topPanel:SetTall(self.popoutTall * 0.3)
    self.topPanel.Paint = function(self2, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(1), self.leftPanel:GetWide() <= 0, true, false, false)
    end

    local gridWide = self.popoutWide - self.leftPanel:GetWide() - 50
    local slotsWide = math.max(1, math.floor(gridWide / BRICKS_SERVER.Func.ScreenScale(150)))
    local spacing = 10
    self.slotSize = (gridWide - ((slotsWide - 1) * spacing)) / slotsWide

    local itemsScroll = vgui.Create("bricks_server_scrollpanel", self.mainPanel)
    itemsScroll:Dock(FILL)
    itemsScroll:DockMargin(25, 25, 25, 25)
    itemsScroll.Paint = function() end

    self.itemsGrid = vgui.Create("DIconLayout", itemsScroll)
    self.itemsGrid:Dock(FILL)
    self.itemsGrid:SetSpaceY(spacing)
    self.itemsGrid:SetSpaceX(spacing)
end

function PANEL:FillPanel(caseKey, buttonFunc, inventoryView)
    self.itemsGrid:Clear()

    local caseTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey]
    if (not caseTable) then return end

    self.buttonFunc = buttonFunc
    self.inventoryView = inventoryView

    local buttonText = (not self.inventoryView and BRICKS_SERVER.Func.L("unboxingAddToCart")) or BRICKS_SERVER.Func.L("unboxingUnlock")
    surface.SetFont("BRICKS_SERVER_Font21")
    local textX = surface.GetTextSize(buttonText)
    local totalContentW = 16 + 5 + textX

    local bottomButton = vgui.Create("DButton", self.leftPanel)
    bottomButton:Dock(BOTTOM)
    bottomButton:DockMargin(25, 0, 25, 25)
    bottomButton:SetTall(40)
    bottomButton:SetText("")
    local alpha = 0
    local bottomButtonMat = self.inventoryView and Material("bricks_server/unboxing_unlock_16.png") or Material("bricks_server/unboxing_cart_16.png")
    bottomButton.Paint = function(self2, w, h)
        if (not self2:IsDown() and self2:IsHovered()) then
            alpha = math.Clamp(alpha + 10, 0, 255)
        else
            alpha = math.Clamp(alpha - 10, 0, 255)
        end

        draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))
        surface.SetAlphaMultiplier(alpha / 255)
        draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(1))
        surface.SetAlphaMultiplier(1)

        BRICKS_SERVER.Func.DrawClickCircle(self2, w, h, BRICKS_SERVER.Func.GetTheme(1), 8)

        surface.SetDrawColor(BRICKS_SERVER.Func.GetTheme(6))
        surface.SetMaterial(bottomButtonMat)
        local iconSize = 16
        surface.DrawTexturedRect((w / 2) - (totalContentW / 2), (h / 2) - (iconSize / 2), iconSize, iconSize)

        draw.SimpleText(buttonText, "BRICKS_SERVER_Font21", (w / 2) - (totalContentW / 2) + iconSize + 5, h / 2 - 1, BRICKS_SERVER.Func.GetTheme(6), 0, TEXT_ALIGN_CENTER)
    end
    bottomButton.DoClick = function()
        if (not self.inventoryView) then
            self.buttonFunc()
        else
            local canOpen, message = LocalPlayer():UnboxingCanOpenCase(caseKey)
            if (not canOpen) then
                BRICKS_SERVER.Func.CreateTopNotification(message, 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red)
                return
            end

            self:UnlockCase(caseKey)
        end
    end

    if (table.Count(caseTable.Keys or {}) > 0) then
        local keysRequired = vgui.Create("DPanel", self.leftPanel)
        keysRequired:Dock(TOP)
        keysRequired:DockMargin(15, 15, 15, 0)
        keysRequired:DockPadding(10, 40, 10, 0)
        keysRequired:SetTall(40)
        keysRequired.Paint = function(self2, w, h)
            draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))
            draw.RoundedBoxEx(8, 0, 40, w, h - 40, BRICKS_SERVER.Func.GetTheme(3, 75), false, false, true, true)
            draw.SimpleText(BRICKS_SERVER.Func.L("unboxingKeyRequired"), "BRICKS_SERVER_Font21", w / 2, 40 / 2, BRICKS_SERVER.Func.GetTheme(6), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        for k, v in pairs(caseTable.Keys or {}) do
            local keyTable = BRICKS_SERVER.CONFIG.UNBOXING.Keys[k]
            if (not keyTable) then continue end

            local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo(keyTable.Rarity or "")

            local itemBack = vgui.Create("DPanel", keysRequired)
            itemBack:Dock(TOP)
            itemBack:SetTall(70)
            local displaySize = itemBack:GetTall() - 10
            itemBack:DockMargin(0, 10, 0, 0)
            itemBack.Paint = function(self2, w, h)
                draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))
                draw.RoundedBox(8, 10, 5, displaySize, displaySize, BRICKS_SERVER.Func.GetTheme(1))

                draw.SimpleText(keyTable.Name, "BRICKS_SERVER_Font20", 5 + displaySize + 20, h / 2 + 2, BRICKS_SERVER.Func.GetTheme(6), 0, TEXT_ALIGN_BOTTOM)
                draw.SimpleText((rarityInfo[1] or BRICKS_SERVER.Func.L("none")), "BRICKS_SERVER_Font17", 5 + displaySize + 20, h / 2 - 2, BRICKS_SERVER.Func.GetRarityColor(rarityInfo), 0, 0)
            end

            local rarityBox = vgui.Create("bricks_server_raritybox", itemBack)
            rarityBox:SetSize(5, itemBack:GetTall())
            rarityBox:SetPos(0, 0)
            rarityBox:SetRarityName(rarityInfo[1], 1)
            rarityBox:SetCornerRadius(8)
            rarityBox:SetRoundedBoxDimensions(false, false, 16, false)

            local itemModel = vgui.Create("bricks_server_unboxing_itemdisplay", itemBack)
            itemModel:SetSize(displaySize, displaySize)
            itemModel:SetPos(10, 5)
            itemModel:SetItemData("KEY", keyTable)
            itemModel:SetIconSizeAdjust(0.8)

            if (keysRequired:GetTall() == 40) then
                keysRequired:SetTall(keysRequired:GetTall() + 20 + itemBack:GetTall())
            else
                keysRequired:SetTall(keysRequired:GetTall() + 10 + itemBack:GetTall())
            end
        end
    end

    local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo(caseTable.Rarity)

    self.caseName = vgui.Create("DPanel", self.topPanel)
    self.caseName:Dock(BOTTOM)
    self.caseName:DockMargin(0, 0, 0, 10)
    self.caseName:SetTall(60)
    self.caseName.Paint = function(self2, w, h)
        draw.SimpleText(caseTable.Name, "BRICKS_SERVER_Font23", w / 2, (h / 2) + 2, BRICKS_SERVER.Func.GetTheme(6, 75), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText((caseTable.Rarity or ""), "BRICKS_SERVER_Font20", w / 2, (h / 2) - 2, BRICKS_SERVER.Func.GetRarityColor(rarityInfo), TEXT_ALIGN_CENTER, 0)
    end

    self.caseModel = vgui.Create("bricks_server_unboxing_itemdisplay", self.topPanel)
    self.caseModel:SetSize(self.topPanel:GetTall() - 10, self.topPanel:GetTall() - 10 - self.caseName:GetTall())
    self.caseModel:SetPos(((self.popoutWide - self.leftPanel:GetWide()) / 2) - (self.caseModel:GetWide() / 2), 0)
    self.caseModel:SetItemData("CASE", caseTable)
    self.caseModel:SetIconSizeAdjust(0.8)

    self.rarityBox = vgui.Create("bricks_server_raritybox", self.topPanel)
    self.rarityBox:SetSize(self.popoutWide, 10)
    self.rarityBox:SetPos(0, self.topPanel:GetTall() - self.rarityBox:GetTall())
    self.rarityBox:SetRarityName(caseTable.Rarity or "")
    self.rarityBox:SetCornerRadius(0)

    self:FillCaseItems(caseKey)
end

-- True accurate chance with 2 decimals
function PANEL:FormatChanceCompact(chancePercent)
    return string.format("%.2f%%", tonumber(chancePercent) or 0)
end

-- Use itemslot's AddTopInfo for the chance pill so it shares the no-overlap lane layout
function PANEL:AddChanceBadgeToSlot(slotBack, chancePercent)
    if (not IsValid(slotBack)) then return end
    if (not IsValid(slotBack.topBar)) then return end

    local chanceText = self:FormatChanceCompact(chancePercent)
    slotBack:AddTopInfo(chanceText, Color(18, 18, 18, 230), Color(240, 240, 240), false)
end

function PANEL:FillCaseItems(caseKey)
    self.itemsGrid:Clear()

    local caseTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey]
    if (not caseTable) then return end

    local caseItems = caseTable.Items
    if (not caseItems) then return end

    local items = {}
    local totalChance = 0

    for globalKey, itemData in pairs(caseItems) do
        local chance = (istable(itemData) and tonumber(itemData[1])) or 0
        if (chance <= 0) then continue end

        local configItemTable

        if (string.StartWith(globalKey, "ITEM_")) then
            local actualKey = tonumber(string.Replace(globalKey, "ITEM_", ""))
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[actualKey]
        elseif (string.StartWith(globalKey, "CASE_")) then
            local actualKey = tonumber(string.Replace(globalKey, "CASE_", ""))
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[actualKey]
        elseif (string.StartWith(globalKey, "KEY_")) then
            local actualKey = tonumber(string.Replace(globalKey, "KEY_", ""))
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Keys[actualKey]
        end

        if (not configItemTable) then continue end

        local _, rarityKey = BRICKS_SERVER.Func.GetRarityInfo(configItemTable.Rarity or "")

        table.insert(items, {
            GlobalKey = globalKey,
            Chance = chance,
            Config = table.Copy(configItemTable),
            RarityKey = rarityKey or 0
        })

        totalChance = totalChance + chance
    end

    table.sort(items, function(a, b)
        if ((a.RarityKey or 0) == (b.RarityKey or 0)) then
            return (a.Config.Name or "") < (b.Config.Name or "")
        end
        return (a.RarityKey or 0) > (b.RarityKey or 0)
    end)

    for _, entry in ipairs(items) do
        local slotBack = self.itemsGrid:Add("bricks_server_unboxingmenu_itemslot")
        slotBack:SetSize(self.slotSize, self.slotSize * 1.2)
        slotBack.themeNum = 1
        slotBack:FillPanel(entry.GlobalKey, 1)

        local percent = (totalChance > 0) and ((entry.Chance / totalChance) * 100) or 0
        self:AddChanceBadgeToSlot(slotBack, percent)
    end
end

function PANEL:UnlockCase(caseKey)
    local caseTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey]
    if (not caseTable) then return end

    local caseItems = caseTable.Items
    if (not caseItems) then return end

    local gridWide = self.popoutWide - 50 - 20
    local slotsWide = math.max(1, math.floor(gridWide / BRICKS_SERVER.Func.ScreenScale(150)))
    local spacing = 10
    self.slotSize = (gridWide - ((slotsWide - 1) * spacing)) / slotsWide

    self.rollSlotSize = 150
    self:FillCaseItems(caseKey)

    if (IsValid(self.caseName)) then
        self.caseName:AlphaTo(0, 0.2, 0, function()
            if IsValid(self.caseName) then self.caseName:Remove() end
        end)
    end

    if (IsValid(self.caseModel)) then
        self.caseModel:AlphaTo(0, 0.2, 0, function()
            if IsValid(self.caseModel) then self.caseModel:Remove() end
        end)
    end

    self.leftPanel:SizeTo(0, self.popoutTall, 0.2)
    self.leftPanel.OnSizeChanged = function(self2, w, h)
        if (IsValid(self.caseModel)) then
            self.caseModel:SetPos(((self.popoutWide - w) / 2) - (self.caseModel:GetWide() / 2), 0)
        end
    end

    local newTopH = (self.rollSlotSize * 1.2) + 10 + 50
    self.topPanel:SizeTo(self.popoutWide, newTopH, 0.2, 0, -1, function()
        if IsValid(self.rarityBox) then
            self.rarityBox:SetPos(0, self.topPanel:GetTall() - self.rarityBox:GetTall())
        end
    end)

    self.topPanel.OnSizeChanged = function()
        if IsValid(self.rarityBox) then
            self.rarityBox:SetPos(0, self.topPanel:GetTall() - self.rarityBox:GetTall())
        end
    end

    local items, totalChance = {}, 0
    for globalKey, itemData in pairs(caseItems) do
        local chance = (istable(itemData) and tonumber(itemData[1])) or 0
        if (chance <= 0) then continue end

        local configItemTable

        if (string.StartWith(globalKey, "ITEM_")) then
            local actualKey = tonumber(string.Replace(globalKey, "ITEM_", ""))
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[actualKey]
        elseif (string.StartWith(globalKey, "CASE_")) then
            local actualKey = tonumber(string.Replace(globalKey, "CASE_", ""))
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[actualKey]
        elseif (string.StartWith(globalKey, "KEY_")) then
            local actualKey = tonumber(string.Replace(globalKey, "KEY_", ""))
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Keys[actualKey]
        end

        if (not configItemTable) then continue end

        items[globalKey] = table.Copy(configItemTable)
        items[globalKey].Chance = chance
        items[globalKey].Hidden = false
        totalChance = totalChance + chance
    end

    local totalItems = 100

    local function GenerateRandomItem()
        if (totalChance <= 0) then return nil end

        local winningChance = math.Rand(0, 100)
        local currentChance = 0
        local winningItemKey

        for k, v in pairs(items) do
            local actualChance = (v.Chance / totalChance) * 100

            if (winningChance > currentChance and winningChance <= currentChance + actualChance) then
                winningItemKey = k
                break
            end

            currentChance = currentChance + actualChance
        end

        if (not winningItemKey) then
            for k, _ in pairs(items) do
                winningItemKey = k
                break
            end
        end

        return winningItemKey
    end

    local slotSpacing = 5
    local panelWide = self.popoutWide

    local rollBack = vgui.Create("DPanel", self.topPanel)
    rollBack:SetSize((totalItems * (self.rollSlotSize + slotSpacing)) - slotSpacing, self.rollSlotSize * 1.2)
    rollBack:SetPos(25, ((newTopH - 10) / 2) - (rollBack:GetTall() / 2))
    rollBack.Paint = function() end

    local previousSoundX = 0
    local soundCooldown = 0
    rollBack.Think = function()
        local xPos = select(1, rollBack:GetPos())

        if (xPos < previousSoundX - (self.rollSlotSize + slotSpacing) and CurTime() >= soundCooldown) then
            surface.PlaySound("bricks_server/ui_unboxing_scroll.wav")
            previousSoundX = xPos
            soundCooldown = CurTime() + 0.25
        end
    end

    local pinBack = vgui.Create("DPanel", self.topPanel)
    pinBack:SetSize(3, newTopH - 10)
    pinBack:SetPos(((panelWide - 50) / 2) - (pinBack:GetWide() / 2), 0)
    pinBack.Paint = function(self2, w, h)
        BRICKS_SERVER.BSHADOWS.BeginShadow()
        local x, y = self2:LocalToScreen(0, 0)
        surface.SetDrawColor(BRICKS_SERVER.Func.GetTheme(5))
        surface.DrawRect(x, y, w, h)
        BRICKS_SERVER.BSHADOWS.EndShadow(3, 2, 2, 255, 0, 0, false)
    end

    local finalItemSlotKey = math.random(math.floor(totalItems * 0.7), math.floor(totalItems * 0.8))
    local createdSlots = {}

    for i = 1, totalItems do
        local randomKey = GenerateRandomItem()

        local slotBack = rollBack:Add("bricks_server_unboxingmenu_itemslot")
        slotBack:SetSize(self.rollSlotSize, self.rollSlotSize * 1.2)
        slotBack:Dock(LEFT)
        slotBack:DockMargin(0, 0, slotSpacing, 0)

        if (i ~= finalItemSlotKey and randomKey) then
            slotBack:FillPanel(randomKey, 1, {})
        end

        createdSlots[i] = slotBack
    end

    function self.StartOpen(self2, globalKey)
        local keySlot = createdSlots[finalItemSlotKey]
        if (not IsValid(keySlot)) then return end

        keySlot:FillPanel(globalKey, 1, {})

        local keySlotX = select(1, keySlot:GetPos())
        local currentX, currentY = rollBack:GetPos()

        rollBack:MoveTo(
            -keySlotX + ((panelWide - 50) / 2) - (self.rollSlotSize / 2) + math.random(-((self.rollSlotSize - 15) / 2), ((self.rollSlotSize - 15) / 2)),
            currentY,
            BRICKS_SERVER.CONFIG.UNBOXING["Case UI Open Time"],
            0,
            0.25,
            function()
                self.popoutPanel.ClosePopout()
            end
        )

        surface.PlaySound("bricks_server/ui_unboxing_open.wav")
    end

    rollBack:SetAlpha(0)
    rollBack:AlphaTo(255, 0.2, 0, function()
        net.Start("BRS.Net.UnboxCase")
            net.WriteUInt(caseKey, 16)
        net.SendToServer()
    end)

    hook.Add("BRS.Hooks.UnboxingOpenCase", self, function(selfHook, globalKey)
        selfHook:StartOpen(globalKey)
    end)
end

function PANEL:Paint(w, h)

end

vgui.Register("bricks_server_unboxingmenu_caseview_popup", PANEL, "DPanel")