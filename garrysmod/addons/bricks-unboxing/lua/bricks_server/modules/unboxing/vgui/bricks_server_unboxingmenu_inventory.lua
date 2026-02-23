local PANEL = {}

function PANEL:Init()

end

function PANEL:CalculateGrid()
    local gridWide = self.panelWide - 50 - 20

    self.spacing = 10

    -- Make inventory cards a bit wider so top pills (Permanent / Equipped / x10) don't clip
    local targetSlotW = BRICKS_SERVER.Func.ScreenScale(220)
    local minSlotW = BRICKS_SERVER.Func.ScreenScale(205)

    self.slotsWide = math.max(1, math.floor((gridWide + self.spacing) / (targetSlotW + self.spacing)))
    self.slotSize = (gridWide - ((self.slotsWide - 1) * self.spacing)) / self.slotsWide

    -- If slots are still too narrow, reduce columns until pills fit comfortably
    while self.slotsWide > 1 and self.slotSize < minSlotW do
        self.slotsWide = self.slotsWide - 1
        self.slotSize = (gridWide - ((self.slotsWide - 1) * self.spacing)) / self.slotsWide
    end
end

function PANEL:FillPanel()
    self:CalculateGrid()

    self.topBar = vgui.Create("DPanel", self)
    self.topBar:Dock(TOP)
    self.topBar:SetTall(64)
    self.topBar.Paint = function(self2, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2), true, true, false, false)

        -- subtle highlight + divider for a premium bar feel
        surface.SetDrawColor(255, 255, 255, 8)
        surface.DrawRect(1, 1, w - 2, 1)

        surface.SetDrawColor(0, 0, 0, 28)
        surface.DrawRect(0, h - 1, w, 1)
    end

    self.searchBar = vgui.Create("bricks_server_searchbar", self.topBar)
    self.searchBar:Dock(LEFT)
    self.searchBar:DockMargin(25, 12, 10, 12)
    self.searchBar:SetWide(math.min(ScrW() * 0.2, math.max(180, self.panelWide * 0.32)))
    self.searchBar:SetBackColor(BRICKS_SERVER.Func.GetTheme(1))
    self.searchBar:SetHighlightColor(BRICKS_SERVER.Func.GetTheme(0))
    self.searchBar.OnChange = function()
        self:FillInventory()
    end

    self.sortChoice = self.sortChoice or "rarity_high_to_low"

    self.sortBy = vgui.Create("bricks_server_combo", self.topBar)
    self.sortBy:Dock(RIGHT)
    self.sortBy:DockMargin(10, 12, 25, 12)
    self.sortBy:SetWide(170)
    self.sortBy:SetBackColor(BRICKS_SERVER.Func.GetTheme(1))
    self.sortBy:SetHighlightColor(BRICKS_SERVER.Func.GetTheme(0))
    self.sortBy:SetValue(BRICKS_SERVER.Func.L("unboxingHighestRarity"))
    self.sortBy:AddChoice(BRICKS_SERVER.Func.L("unboxingHighestRarity"), "rarity_high_to_low")
    self.sortBy:AddChoice(BRICKS_SERVER.Func.L("unboxingLowestRarity"), "rarity_low_to_high")
    self.sortBy.OnSelect = function(self2, index, value, data)
        self.sortChoice = data
        self:FillInventory()
    end

    self.scrollPanel = vgui.Create("bricks_server_scrollpanel_bar", self)
    self.scrollPanel:Dock(FILL)
    self.scrollPanel:DockMargin(25, 20, 25, 25)
    self.scrollPanel.Paint = function(self2, w, h)
        -- optional depth layer (kept minimal)
    end

    self.grid = vgui.Create("DIconLayout", self.scrollPanel)
    self.grid:Dock(TOP)
    self.grid:SetSpaceY(self.spacing)
    self.grid:SetSpaceX(self.spacing)

    -- Empty state (shown/hidden in FillInventory)
    self.emptyState = vgui.Create("DPanel", self.scrollPanel)
    self.emptyState:Dock(TOP)
    self.emptyState:DockMargin(0, 10, 10, 0)
    self.emptyState:SetTall(110)
    self.emptyState:SetVisible(false)
    self.emptyState.Paint = function(self2, w, h)
        draw.RoundedBox(10, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))

        surface.SetDrawColor(255, 255, 255, 8)
        surface.DrawRect(1, 1, w - 2, 1)

        draw.SimpleText(BRICKS_SERVER.Func.L("unboxingInventory") or "Inventory", "BRICKS_SERVER_Font25", 20, 30, BRICKS_SERVER.Func.GetTheme(6), 0, TEXT_ALIGN_CENTER)
        draw.SimpleText("No items found.", "BRICKS_SERVER_Font20", 20, 62, BRICKS_SERVER.Func.GetTheme(6, 70), 0, TEXT_ALIGN_CENTER)
        draw.SimpleText("Try clearing your search or changing sort.", "BRICKS_SERVER_Font17", 20, 84, BRICKS_SERVER.Func.GetTheme(6, 45), 0, TEXT_ALIGN_CENTER)
    end

    self:FillInventory()

    hook.Add("BRS.Hooks.FillUnboxingInventory", self, function()
        self:FillInventory()
    end)
end

function PANEL:AddSlot(globalKey, amount, actions)
    local slotBack = self.grid:Add("bricks_server_unboxingmenu_itemslot")
    -- Slightly taller ratio gives top pills a bit more breathing room visually too
    slotBack:SetSize(self.slotSize, self.slotSize * 1.22)
    slotBack:FillPanel(globalKey, amount, actions)

    if (LocalPlayer():UnboxingIsItemEquipped(globalKey)) then
        slotBack:AddTopInfo("Equipped", false, false, true)
    end
end

function PANEL:FillInventory()
    if (not IsValid(self.grid)) then return end

    -- Recalculate slot width in case panel size changed / UI scale changed
    self:CalculateGrid()
    self.grid:SetSpaceY(self.spacing)
    self.grid:SetSpaceX(self.spacing)

    self.grid:Clear()

    local sortedItems = {}

    local searchValue = ""
    if (IsValid(self.searchBar) and self.searchBar.GetValue) then
        searchValue = string.Trim(tostring(self.searchBar:GetValue() or ""))
    end
    local searchLower = string.lower(searchValue)

    for k, v in pairs(LocalPlayer():GetUnboxingInventory() or {}) do
        local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey(k)
        if (not configItemTable) then continue end

        local itemName = tostring(configItemTable.Name or "")
        if (searchLower ~= "" and not string.find(string.lower(itemName), searchLower, 1, true)) then
            continue
        end

        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo(configItemTable.Rarity or "")
        table.insert(sortedItems, { rarityKey or 0, k, v })
    end

    if (self.sortChoice == "rarity_high_to_low") then
        table.SortByMember(sortedItems, 1, false)
    elseif (self.sortChoice == "rarity_low_to_high") then
        table.SortByMember(sortedItems, 1, true)
    end

    -- Empty state toggle
    local hasItems = (#sortedItems > 0)
    if (IsValid(self.emptyState)) then
        self.emptyState:SetVisible(not hasItems)
        self.emptyState:SetTall((not hasItems and 110) or 0)
    end

    -- Grid height
    if (hasItems) then
        local rows = math.max(1, math.ceil(#sortedItems / (self.slotsWide or 1)))
        self.grid:SetTall((rows * ((self.slotSize * 1.22) + self.spacing)) - self.spacing)
    else
        self.grid:SetTall(0)
    end

    for _, v in ipairs(sortedItems) do
        local globalKey, itemAmount = v[2], v[3]
        local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey(globalKey)
        if (not configItemTable) then continue end

        local actions = {}

        if (isItem) then
            local devConfigItemTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type] or {}
            local statTrakSummary = BRICKS_SERVER.UNBOXING.Func.GetStatTrakSummary(LocalPlayer(), globalKey)

            if (statTrakSummary) then
                table.insert(actions, { "Inspect Best", function()
                    self.popoutPanel = vgui.Create("bricks_server_unboxingmenu_stattrak_popup", self)
                    self.popoutPanel:SetPos(0, 0)
                    self.popoutPanel:SetSize(self.panelWide, ScrH() * 0.65 - 40)
                    self.popoutPanel:CreatePopout()
                    self.popoutPanel:FillPanel(globalKey, false)
                end })

                table.insert(actions, { "Ranking", function()
                    self.popoutPanel = vgui.Create("bricks_server_unboxingmenu_stattrak_popup", self)
                    self.popoutPanel:SetPos(0, 0)
                    self.popoutPanel:SetSize(self.panelWide, ScrH() * 0.65 - 40)
                    self.popoutPanel:CreatePopout()
                    self.popoutPanel:FillPanel(globalKey, true)
                end })

                if ((tonumber(itemAmount) or 1) > 1) then
                    table.insert(actions, { "View All Rolls", function()
                        self.popoutPanel = vgui.Create("bricks_server_unboxingmenu_stattrak_rolls_popup", self)
                        self.popoutPanel:SetPos(0, 0)
                        self.popoutPanel:SetSize(self.panelWide, ScrH() * 0.65 - 40)
                        self.popoutPanel:CreatePopout()
                        self.popoutPanel:FillPanel(globalKey)
                    end })
                end
            end

            if (devConfigItemTable.UseFunction) then
                local itemKeyNum = tonumber(string.Replace(globalKey, "ITEM_", ""))

                table.insert(actions, { BRICKS_SERVER.Func.L("unboxingUse"), function()
                    net.Start("BRS.Net.UseUnboxingItem")
                        net.WriteUInt(itemKeyNum, 16)
                        net.WriteUInt(1, 16)
                    net.SendToServer()
                end })

                if (devConfigItemTable.UseMultiple) then
                    table.insert(actions, { BRICKS_SERVER.Func.L("unboxingUseAll"), function()
                        net.Start("BRS.Net.UseUnboxingItem")
                            net.WriteUInt(itemKeyNum, 16)
                            net.WriteUInt(itemAmount, 16)
                        net.SendToServer()
                    end })
                end
            end

            if (devConfigItemTable.EquipFunction or devConfigItemTable.UnEquipFunction) then
                table.insert(actions, { function()
                    return LocalPlayer():UnboxingIsItemEquipped(globalKey) and BRICKS_SERVER.Func.L("unboxingUnEquip") or BRICKS_SERVER.Func.L("unboxingEquip")
                end, function()
                    net.Start(LocalPlayer():UnboxingIsItemEquipped(globalKey) and "BRS.Net.UnEquipUnboxingItem" or "BRS.Net.EquipUnboxingItem")
                        net.WriteString(globalKey)
                    net.SendToServer()
                end })
            end
        elseif (isCase) then
            table.insert(actions, { BRICKS_SERVER.Func.L("view"), function()
                self.popoutPanel = vgui.Create("bricks_server_unboxingmenu_caseview_popup", self)
                self.popoutPanel:SetPos(0, 0)
                self.popoutPanel:SetSize(self.panelWide, ScrH() * 0.65 - 40)
                self.popoutPanel:CreatePopout()
                self.popoutPanel:FillPanel(itemKey, false, true)
            end })

            if (configItemTable.Model and BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels[configItemTable.Model]) then
                table.insert(actions, { BRICKS_SERVER.Func.L("unboxingPlace"), function()
                    BRICKS_SERVER.UNBOXING.Func.StartPlacingCase(itemKey)
                end })
            end

            table.insert(actions, { BRICKS_SERVER.Func.L("unboxingOpenAll"), function()
                local caseKey = tonumber(string.Replace(globalKey, "CASE_", ""))
                if (not caseKey) then return end

                net.Start("BRS.Net.UnboxingOpenAll")
                    net.WriteUInt(caseKey, 16)
                net.SendToServer()
            end })
        elseif (isKey) then
            table.insert(actions, { BRICKS_SERVER.Func.L("view"), function()
                self.popoutPanel = vgui.Create("bricks_server_unboxingmenu_keyview_popup", self)
                self.popoutPanel:SetPos(0, 0)
                self.popoutPanel:SetSize(self.panelWide, ScrH() * 0.65 - 40)
                self.popoutPanel:CreatePopout()
                self.popoutPanel:FillPanel(itemKey, false, true)
            end })
        end

        self:AddSlot(globalKey, (itemAmount or 1), actions)
    end
end

function PANEL:Paint(w, h)

end

vgui.Register("bricks_server_unboxingmenu_inventory", PANEL, "DPanel")
