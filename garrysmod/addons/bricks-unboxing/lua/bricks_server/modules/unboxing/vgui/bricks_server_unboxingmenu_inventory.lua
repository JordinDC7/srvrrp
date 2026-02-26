-- ============================================================
-- SmG RP - Custom Inventory Page
-- Dark tactical theme with enhanced management tools
-- ============================================================
local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local gridWide = self.panelWide - 50 - 20
    self.slotsWide = math.floor( gridWide / BRICKS_SERVER.Func.ScreenScale( 200 ) )
    self.spacing = 8
    self.slotSize = (gridWide - ((self.slotsWide - 1) * self.spacing)) / self.slotsWide
    self.selectedItems = {}
    self.selectMode = false
    
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}

    -- ====== TOP BAR ======
    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 52 )
    self.topBar.Paint = function( self2, w, h ) 
        draw.RoundedBox( 0, 0, 0, w, h, C.bg_dark or Color(18,18,26) )
        -- Bottom divider line
        surface.SetDrawColor(C.border or Color(50,52,65))
        surface.DrawRect(0, h - 1, w, 1)
    end 

    -- Search bar
    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 20, 8, 8, 8 )
    self.searchBar:SetWide( ScrW() * 0.12 )
    self.searchBar:SetBackColor( C.bg_input or Color(22,23,30) )
    self.searchBar:SetHighlightColor( C.accent_dim or Color(0,160,128) )
    self.searchBar.OnChange = function()
        self:FillInventory()
    end

    -- ====== FILTER TABS ======
    self.filterChoice = "all"
    local filterPanel = vgui.Create( "DPanel", self.topBar )
    filterPanel:Dock( LEFT )
    filterPanel:DockMargin( 4, 8, 8, 8 )
    filterPanel:SetWide( 290 )
    filterPanel.Paint = function() end

    local filters = {
        { key = "all",     label = "ALL" },
        { key = "weapons", label = "WEAPONS" },
        { key = "cases",   label = "CASES" },
        { key = "keys",    label = "KEYS" },
    }

    local _filterHover = Color(255, 255, 255, 0)
    local _filterWhite = Color(255, 255, 255)

    for _, f in ipairs(filters) do
        local btn = vgui.Create( "DButton", filterPanel )
        btn:Dock( LEFT )
        btn:SetWide( 68 )
        btn:DockMargin( 0, 0, 4, 0 )
        btn:SetText( "" )
        btn.hoverAlpha = 0
        btn.Paint = function( self2, w, h )
            local isActive = (self.filterChoice == f.key)
            
            if self2:IsHovered() and not isActive then
                self2.hoverAlpha = math.Clamp(self2.hoverAlpha + 8, 0, 255)
            else
                self2.hoverAlpha = math.Clamp(self2.hoverAlpha - 8, 0, 255)
            end

            if isActive then
                draw.RoundedBox( 4, 0, 0, w, h, C.accent_dim or Color(0,160,128) )
                draw.SimpleText( f.label, "SMGRP_Bold11", w/2, h/2, _filterWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            else
                draw.RoundedBox( 4, 0, 0, w, h, C.bg_light or Color(34,36,46) )
                if self2.hoverAlpha > 0 then
                    _filterHover.a = math.floor(self2.hoverAlpha * 0.08)
                    draw.RoundedBox( 4, 0, 0, w, h, _filterHover )
                end
                draw.SimpleText( f.label, "SMGRP_Bold11", w/2, h/2, C.text_secondary or Color(140,144,160), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end
        btn.DoClick = function()
            self.filterChoice = f.key
            self:FillInventory()
        end
    end

    -- ====== MANAGE BUTTON ======
    self.manageBtn = vgui.Create( "DButton", self.topBar )
    self.manageBtn:Dock( RIGHT )
    self.manageBtn:DockMargin( 4, 8, 20, 8 )
    self.manageBtn:SetWide( 80 )
    self.manageBtn:SetText( "" )
    self.manageBtn.hoverAlpha = 0
    self.manageBtn.Paint = function( self2, w, h )
        if self2:IsHovered() then
            self2.hoverAlpha = math.Clamp(self2.hoverAlpha + 8, 0, 255)
        else
            self2.hoverAlpha = math.Clamp(self2.hoverAlpha - 8, 0, 255)
        end

        if self.selectMode then
            draw.RoundedBox( 4, 0, 0, w, h, C.red or Color(220,60,60) )
            draw.SimpleText( "CANCEL", "SMGRP_Bold11", w/2, h/2, _filterWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        else
            draw.RoundedBox( 4, 0, 0, w, h, C.bg_light or Color(34,36,46) )
            if self2.hoverAlpha > 0 then
                _filterHover.a = math.floor(self2.hoverAlpha * 0.08)
                draw.RoundedBox( 4, 0, 0, w, h, _filterHover )
            end
            draw.SimpleText( "MANAGE", "SMGRP_Bold11", w/2, h/2, C.text_secondary or Color(140,144,160), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end
    self.manageBtn.DoClick = function()
        self.selectMode = not self.selectMode
        self.selectedItems = {}
        self.actionBar:SetVisible(self.selectMode)
        self:FillInventory()
    end

    -- ====== UNEQUIP ALL BUTTON ======
    local _unequipRed = Color(180, 50, 50)
    local _unequipRedHover = Color(220, 60, 60)
    local unequipBtn = vgui.Create("DButton", self.topBar)
    unequipBtn:Dock(RIGHT)
    unequipBtn:DockMargin(2, 8, 4, 8)
    unequipBtn:SetWide(90)
    unequipBtn:SetText("")
    unequipBtn.hoverAlpha = 0
    unequipBtn.Paint = function(self2, w, h)
        local hovered = self2:IsHovered()
        self2.hoverAlpha = math.Clamp(self2.hoverAlpha + (hovered and 8 or -8), 0, 255)
        draw.RoundedBox(4, 0, 0, w, h, hovered and _unequipRedHover or _unequipRed)
        draw.SimpleText("UNEQUIP ALL", "SMGRP_Bold10", w/2, h/2, _filterWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    unequipBtn.DoClick = function()
        net.Start("BRS_UW.UnequipAll")
        net.SendToServer()
        timer.Simple(0.3, function()
            if IsValid(self) then self:FillInventory() end
        end)
    end

    -- ====== EQUIP BEST BUTTON + CRITERIA DROPDOWN ======
    local _equipGreen = Color(40, 150, 80)
    local _equipGreenHover = Color(50, 180, 100)
    self.equipBestCriteria = "avg"

    local equipBestPanel = vgui.Create("DPanel", self.topBar)
    equipBestPanel:Dock(RIGHT)
    equipBestPanel:DockMargin(2, 8, 2, 8)
    equipBestPanel:SetWide(156)
    equipBestPanel.Paint = function() end

    local equipBtn = vgui.Create("DButton", equipBestPanel)
    equipBtn:Dock(LEFT)
    equipBtn:SetWide(96)
    equipBtn:SetText("")
    equipBtn.Paint = function(self2, w, h)
        local hovered = self2:IsHovered()
        draw.RoundedBoxEx(4, 0, 0, w, h, hovered and _equipGreenHover or _equipGreen, true, false, true, false)
        draw.SimpleText("EQUIP BEST", "SMGRP_Bold10", w/2, h/2, _filterWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    equipBtn.DoClick = function()
        net.Start("BRS_UW.EquipBest")
            net.WriteString(self.equipBestCriteria or "avg")
        net.SendToServer()
        timer.Simple(0.3, function()
            if IsValid(self) then self:FillInventory() end
        end)
    end

    -- Criteria mini-dropdown
    local criteriaLabels = {
        { "AVG",  "avg" },
        { "DMG",  "dmg" },
        { "SPD",  "spd" },
        { "RPM",  "rpm" },
        { "MAG",  "mag" },
        { "VEL",  "vel" },
        { "DROP", "drp" },
    }
    local _critBg = Color(30, 120, 65)
    local _critBgHover = Color(35, 140, 75)
    local _critActive = Color(0, 212, 170)

    local criteriaBtn = vgui.Create("DButton", equipBestPanel)
    criteriaBtn:Dock(FILL)
    criteriaBtn:DockMargin(1, 0, 0, 0)
    criteriaBtn:SetText("")
    criteriaBtn.Paint = function(self2, w, h)
        local hovered = self2:IsHovered()
        draw.RoundedBoxEx(4, 0, 0, w, h, hovered and _critBgHover or _critBg, false, true, false, true)
        local label = "AVG"
        for _, cl in ipairs(criteriaLabels) do
            if cl[2] == self.equipBestCriteria then label = cl[1] break end
        end
        draw.SimpleText(label .. " ▾", "SMGRP_Bold10", w/2, h/2, _filterWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    criteriaBtn.DoClick = function(self2)
        local dmenu = DermaMenu()
        for _, cl in ipairs(criteriaLabels) do
            local opt = dmenu:AddOption(cl[1], function()
                self.equipBestCriteria = cl[2]
            end)
            if cl[2] == self.equipBestCriteria then
                opt:SetIcon("icon16/tick.png")
            end
        end
        dmenu:Open()
    end

    -- ====== SORT DROPDOWN ======
    self.sortChoice = "rarity_high_to_low"
    self.sortBy = vgui.Create( "bricks_server_combo", self.topBar )
    self.sortBy:Dock( RIGHT )
    self.sortBy:DockMargin( 4, 8, 4, 8 )
    self.sortBy:SetWide( 160 )
    self.sortBy:SetBackColor( C.bg_input or Color(22,23,30) )
    self.sortBy:SetHighlightColor( C.accent_dim or Color(0,160,128) )
    self.sortBy:SetValue( BRICKS_SERVER.Func.L( "unboxingHighestRarity" ) )
    self.sortBy:AddChoice( BRICKS_SERVER.Func.L( "unboxingHighestRarity" ), "rarity_high_to_low" )
    self.sortBy:AddChoice( BRICKS_SERVER.Func.L( "unboxingLowestRarity" ), "rarity_low_to_high" )
    self.sortBy:AddChoice( "Highest Quality", "quality_high" )
    self.sortBy:AddChoice( "Lowest Quality", "quality_low" )
    self.sortBy:AddChoice( "Highest Avg Boost", "avg_boost_high" )
    self.sortBy:AddChoice( "Highest DMG", "stat_dmg" )
    self.sortBy:AddChoice( "Highest ACC", "stat_spd" )
    self.sortBy:AddChoice( "Highest RPM", "stat_rpm" )
    self.sortBy:AddChoice( "Highest MAG", "stat_mag" )
    self.sortBy.OnSelect = function( self2, index, value, data )
        self.sortChoice = data
        self:FillInventory()
    end

    -- ====== ACTION BAR (select mode) ======
    self.actionBar = vgui.Create( "DPanel", self )
    self.actionBar:Dock( TOP )
    self.actionBar:SetTall( 38 )
    self.actionBar:SetVisible(false)
    self.actionBar.Paint = function( self2, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, C.bg_darkest or Color(12,12,18) )
        surface.SetDrawColor(C.red_bg or Color(220,60,60,20))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(C.border or Color(50,52,65))
        surface.DrawRect(0, h - 1, w, 1)
    end

    local selectAllBtn = vgui.Create( "DButton", self.actionBar )
    selectAllBtn:Dock( LEFT )
    selectAllBtn:DockMargin( 20, 5, 4, 5 )
    selectAllBtn:SetWide( 85 )
    selectAllBtn:SetText( "" )
    selectAllBtn.Paint = function( self2, w, h )
        draw.RoundedBox( 4, 0, 0, w, h, self2:IsHovered() and (C.bg_lighter or Color(44,46,58)) or (C.bg_light or Color(34,36,46)) )
        draw.SimpleText( "Select All", "SMGRP_Bold11", w/2, h/2, C.text_secondary or Color(140,144,160), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    selectAllBtn.DoClick = function()
        for k, v in pairs( LocalPlayer():GetUnboxingInventory() ) do
            local isItem = isstring(k) and string.StartWith(k, "ITEM_")
            local isCase = isstring(k) and string.StartWith(k, "CASE_")
            local isKey = isstring(k) and string.StartWith(k, "KEY_")
            if self.filterChoice == "weapons" and not isItem then continue end
            if self.filterChoice == "cases" and not isCase then continue end
            if self.filterChoice == "keys" and not isKey then continue end
            self.selectedItems[k] = true
        end
        self:FillInventory()
    end

    local deselectBtn = vgui.Create( "DButton", self.actionBar )
    deselectBtn:Dock( LEFT )
    deselectBtn:DockMargin( 0, 5, 4, 5 )
    deselectBtn:SetWide( 85 )
    deselectBtn:SetText( "" )
    deselectBtn.Paint = function( self2, w, h )
        draw.RoundedBox( 4, 0, 0, w, h, self2:IsHovered() and (C.bg_lighter or Color(44,46,58)) or (C.bg_light or Color(34,36,46)) )
        draw.SimpleText( "Deselect", "SMGRP_Bold11", w/2, h/2, C.text_secondary or Color(140,144,160), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    deselectBtn.DoClick = function()
        self.selectedItems = {}
        self:FillInventory()
    end

    -- Selected count label
    self.selectedLabel = vgui.Create( "DPanel", self.actionBar )
    self.selectedLabel:Dock( LEFT )
    self.selectedLabel:DockMargin( 10, 5, 4, 5 )
    self.selectedLabel:SetWide( 100 )
    self.selectedLabel.Paint = function( self2, w, h )
        local count = table.Count(self.selectedItems)
        draw.SimpleText( count .. " selected", "SMGRP_Body13", 0, h/2, C.text_muted or Color(90,94,110), 0, TEXT_ALIGN_CENTER )
    end

    -- Delete button
    local deleteBtn = vgui.Create( "DButton", self.actionBar )
    deleteBtn:Dock( RIGHT )
    deleteBtn:DockMargin( 4, 5, 20, 5 )
    deleteBtn:SetWide( 110 )
    deleteBtn:SetText( "" )
    deleteBtn.Paint = function( self2, w, h )
        local count = table.Count(self.selectedItems)
        if count > 0 then
            draw.RoundedBox( 4, 0, 0, w, h, self2:IsHovered() and (C.red or Color(220,60,60)) or (C.red_dim or Color(160,40,40)) )
            draw.SimpleText( "DELETE (" .. count .. ")", "SMGRP_Bold11", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        else
            draw.RoundedBox( 4, 0, 0, w, h, C.bg_light or Color(34,36,46) )
            draw.SimpleText( "DELETE (0)", "SMGRP_Bold11", w/2, h/2, C.text_muted or Color(90,94,110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end
    deleteBtn.DoClick = function()
        local count = table.Count(self.selectedItems)
        if count == 0 then return end

        Derma_Query("Delete " .. count .. " item(s)? This cannot be undone.", "Confirm Delete",
            "Delete", function()
                local keys = {}
                for k, _ in pairs(self.selectedItems) do
                    table.insert(keys, k)
                end

                -- Batch delete in chunks of 50
                local chunkSize = 50
                local totalChunks = math.ceil(#keys / chunkSize)
                for chunk = 1, totalChunks do
                    local startIdx = (chunk - 1) * chunkSize + 1
                    local endIdx = math.min(chunk * chunkSize, #keys)
                    local batchCount = endIdx - startIdx + 1

                    timer.Simple((chunk - 1) * 0.2, function()
                        net.Start("BRS_UW.DeleteItems")
                            net.WriteUInt(batchCount, 16)
                            for i = startIdx, endIdx do
                                net.WriteString(keys[i])
                            end
                        net.SendToServer()
                    end)
                end

                self.selectedItems = {}
                self.selectMode = false
                self.actionBar:SetVisible(false)

                timer.Simple(totalChunks * 0.2 + 0.5, function()
                    if IsValid(self) then self:FillInventory() end
                end)
            end,
            "Cancel", function() end
        )
    end

    -- Delete confirm listener
    net.Receive("BRS_UW.DeleteItemsConfirm", function()
        local deleted = net.ReadUInt(16)
        if IsValid(self) then
            self:FillInventory()
        end
    end)

    -- ====== ITEM COUNT FOOTER ======
    self.itemCountBar = vgui.Create( "DPanel", self )
    self.itemCountBar:Dock( BOTTOM )
    self.itemCountBar:SetTall( 22 )
    self.itemCountBar.Paint = function( self2, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, C.bg_dark or Color(18,18,26) )
        surface.SetDrawColor(C.border or Color(50,52,65))
        surface.DrawRect(0, 0, w, 1)
        draw.SimpleText( (self.itemCount or 0) .. " items", "SMGRP_Body12", w/2, h/2, C.text_muted or Color(90,94,110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    -- ====== SCROLL PANEL ======
    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 20, 16, 20, 8 )
    self.scrollPanel.Paint = function() end

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( self.spacing )
    self.grid:SetSpaceX( self.spacing )

    self:FillInventory()

    hook.Add( "BRS.Hooks.FillUnboxingInventory", self, function()
        -- Debounce: only rebuild once per 0.15s (prevents lag on equip/unequip/mass ops)
        if self._fillTimer then timer.Remove(self._fillTimer) end
        self._fillTimer = "BRS_InvFill_" .. tostring(self)
        timer.Create(self._fillTimer, 0.15, 1, function()
            if IsValid(self) then
                self:FillInventory()
            end
        end)
    end )
end

function PANEL:AddSlot( globalKey, amount, actions )
    local slotWrapper = self.grid:Add( "DPanel" )
    slotWrapper:SetSize( self.slotSize, self.slotSize * 1.2 )
    slotWrapper.Paint = function() end

    local slotBack = vgui.Create( "bricks_server_unboxingmenu_itemslot", slotWrapper )
    slotBack:SetSize( self.slotSize, self.slotSize * 1.2 )
    slotBack:FillPanel( globalKey, amount, actions )

    if( LocalPlayer():UnboxingIsItemEquipped( globalKey ) ) then
        slotBack:AddTopInfo( "EQUIPPED", SMGRP.UI.Colors.accent_dim or Color(0,160,128), Color(255,255,255), true )
    end

    -- Selection checkbox in manage mode
    if self.selectMode then
        local C = SMGRP.UI.Colors or {}
        local checkbox = vgui.Create( "DButton", slotWrapper )
        checkbox:SetSize( 20, 20 )
        checkbox:SetPos( self.slotSize - 24, 4 )
        checkbox:SetText( "" )
        checkbox:SetZPos( 100 )
        checkbox.Paint = function( self2, w, h )
            local sel = self.selectedItems[globalKey] or false
            if sel then
                draw.RoundedBox( 4, 0, 0, w, h, C.accent or Color(0,212,170) )
                draw.SimpleText( "✓", "SMGRP_Bold12", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            else
                draw.RoundedBox( 4, 0, 0, w, h, Color(0,0,0,140) )
                surface.SetDrawColor(C.border or Color(50,52,65))
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end
        end
        checkbox.DoClick = function()
            if self.selectedItems[globalKey] then
                self.selectedItems[globalKey] = nil
            else
                self.selectedItems[globalKey] = true
            end
        end
    end
end

function PANEL:FillInventory()
    self.grid:Clear()

    -- Cancel any pending chunked loading
    if self._chunkTimer then timer.Remove(self._chunkTimer) end

    local sortedItems = {}
    for k, v in pairs( LocalPlayer():GetUnboxingInventory() ) do
        local configItemTable, itemKey2, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )
        if( not configItemTable ) then continue end

        if self.filterChoice == "weapons" and not isItem then continue end
        if self.filterChoice == "cases" and not isCase then continue end
        if self.filterChoice == "keys" and not isKey then continue end

        local searchName = configItemTable.Name or ""
        local isUW = BRS_UW and BRS_UW.IsUniqueWeapon and BRS_UW.IsUniqueWeapon(k)
        local uwData = isUW and BRS_UW.GetWeaponData(k)
        if uwData then
            searchName = searchName .. " " .. (uwData.rarity or "") .. " " .. (uwData.quality or "")
        end

        if( self.searchBar:GetValue() ~= "" and not string.find( string.lower( searchName ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end
        
        -- Compute sort value based on current sort mode
        local sortVal = 0
        local sortMode = self.sortChoice

        if sortMode == "rarity_high_to_low" or sortMode == "rarity_low_to_high" then
            local sortRarity = configItemTable.Rarity or ""
            if uwData and uwData.rarity then sortRarity = uwData.rarity end
            local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( sortRarity )
            if uwData and BRS_UW.RarityOrder and BRS_UW.RarityOrder[uwData.rarity] then
                rarityKey = BRS_UW.RarityOrder[uwData.rarity]
            end
            sortVal = rarityKey or 0

        elseif sortMode == "quality_high" or sortMode == "quality_low" then
            if uwData and uwData.quality and BRS_UW.QualityOrder then
                sortVal = BRS_UW.QualityOrder[uwData.quality] or 0
            end

        elseif sortMode == "avg_boost_high" then
            if uwData then
                sortVal = uwData.avgBoost or (uwData.stats and BRS_UW.CalcAvgBoost(uwData.stats)) or 0
            end

        elseif string.StartWith(sortMode, "stat_") then
            local statKey = string.sub(sortMode, 6) -- e.g. "dmg", "spd", "rpm", "mag"
            if uwData and uwData.stats and uwData.stats[statKey] then
                sortVal = uwData.stats[statKey]
            end
        end

        table.insert( sortedItems, { sortVal, k, v, configItemTable, itemKey2, isItem, isCase, isKey, isUW, uwData } )
    end

    -- Sort direction: low sorts ascending, everything else descending
    if self.sortChoice == "rarity_low_to_high" or self.sortChoice == "quality_low" then
        table.sort( sortedItems, function(a, b) return a[1] < b[1] end )
    else
        table.sort( sortedItems, function(a, b) return a[1] > b[1] end )
    end

    self.grid:SetTall( (math.ceil(#sortedItems / self.slotsWide) * (self.slotSize * 1.2 + self.spacing)) - self.spacing )
    self.itemCount = #sortedItems

    -- ====== CHUNKED SLOT CREATION ======
    -- Create slots in batches to prevent frame stutter
    -- First batch is immediate (fills visible area), rest are deferred
    local BATCH_SIZE = 12  -- ~2 rows at a time
    local totalItems = #sortedItems
    local cursor = 1

    local function CreateBatch()
        if not IsValid(self) or not IsValid(self.grid) then return end
        local batchEnd = math.min(cursor + BATCH_SIZE - 1, totalItems)

        for idx = cursor, batchEnd do
            local v = sortedItems[idx]
            local globalKey, itemAmount = v[2], v[3]
            local configItemTable, itemKey2, isItem, isCase, isKey = v[4], v[5], v[6], v[7], v[8]
            local isUW = v[9]

            local actions

            if self.selectMode then
                actions = function(ax, ay, aw, ah)
                    if self.selectedItems[globalKey] then
                        self.selectedItems[globalKey] = nil
                    else
                        self.selectedItems[globalKey] = true
                    end
                end
            elseif( isItem ) then
                actions = {}
                local devConfigItemTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type] or {}

                if( devConfigItemTable.UseFunction ) then
                    local numKey = tonumber( string.Replace( string.match(globalKey, "^ITEM_%d+") or globalKey, "ITEM_", "" ) )
                    if numKey then
                        table.insert( actions, { BRICKS_SERVER.Func.L( "unboxingUse" ), function()
                            net.Start( "BRS.Net.UseUnboxingItem" )
                                net.WriteUInt( numKey, 16 )
                                net.WriteUInt( 1, 16 )
                            net.SendToServer()
                        end } )

                        if( devConfigItemTable.UseMultiple ) then
                            table.insert( actions, { BRICKS_SERVER.Func.L( "unboxingUseAll" ), function()
                                net.Start( "BRS.Net.UseUnboxingItem" )
                                    net.WriteUInt( numKey, 16 )
                                    net.WriteUInt( itemAmount, 16 )
                                net.SendToServer()
                            end } )
                        end
                    end
                end

                if( devConfigItemTable.EquipFunction or devConfigItemTable.UnEquipFunction ) then
                    table.insert( actions, { function() 
                        return LocalPlayer():UnboxingIsItemEquipped( globalKey ) and BRICKS_SERVER.Func.L( "unboxingUnEquip" ) or BRICKS_SERVER.Func.L( "unboxingEquip" )
                    end, function()
                        net.Start( LocalPlayer():UnboxingIsItemEquipped( globalKey ) and "BRS.Net.UnEquipUnboxingItem" or "BRS.Net.EquipUnboxingItem" )
                            net.WriteString( globalKey )
                        net.SendToServer()
                    end } )
                end

                if isUW then
                    table.insert( actions, 1, { "Inspect", function()
                        local uwData2 = BRS_UW.GetWeaponData(globalKey)
                        if uwData2 then
                            BRS_UW.OpenInspectPopup(globalKey, uwData2)
                        else
                            net.Start("BRS_UW.RequestInspect")
                                net.WriteString(globalKey)
                            net.SendToServer()
                        end
                    end } )
                end

            elseif( isCase ) then
                actions = {}
                table.insert( actions, { BRICKS_SERVER.Func.L( "view" ), function()
                    self.popoutPanel = vgui.Create( "bricks_server_unboxingmenu_caseview_popup", self )
                    self.popoutPanel:SetPos( 0, 0 )
                    self.popoutPanel:SetSize( self.panelWide, self.panelTall or self:GetTall() )
                    self.popoutPanel:CreatePopout()
                    self.popoutPanel:FillPanel( itemKey2, false, true )
                end } )

                if( configItemTable.Model and BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels[configItemTable.Model] ) then
                    table.insert( actions, { BRICKS_SERVER.Func.L( "unboxingPlace" ), function()
                        BRICKS_SERVER.UNBOXING.Func.StartPlacingCase( itemKey2 )
                    end } )
                end

                table.insert( actions, { BRICKS_SERVER.Func.L( "unboxingOpenAll" ), function()
                    local caseKey = tonumber( string.Replace( globalKey, "CASE_", "" ) )
                    if( not caseKey ) then return end
                    net.Start( "BRS.Net.UnboxingOpenAll" )
                        net.WriteUInt( caseKey, 16 )
                    net.SendToServer()
                end } )
            elseif( isKey ) then
                actions = {}
                table.insert( actions, { BRICKS_SERVER.Func.L( "view" ), function()
                    self.popoutPanel = vgui.Create( "bricks_server_unboxingmenu_keyview_popup", self )
                    self.popoutPanel:SetPos( 0, 0 )
                    self.popoutPanel:SetSize( self.panelWide, self.panelTall or self:GetTall() )
                    self.popoutPanel:CreatePopout()
                    self.popoutPanel:FillPanel( itemKey2, false, true )
                end } )
            end

            self:AddSlot( globalKey, (itemAmount or 1), actions )
        end

        cursor = batchEnd + 1

        -- Schedule next batch if more items remain
        if cursor <= totalItems then
            self._chunkTimer = "BRS_InvChunk_" .. tostring(self)
            timer.Create(self._chunkTimer, 0, 1, CreateBatch)
        end
    end

    -- Start first batch immediately
    CreateBatch()
end

function PANEL:OnRemove()
    if self._chunkTimer then timer.Remove(self._chunkTimer) end
    if self._fillTimer then timer.Remove(self._fillTimer) end
end

local _invBg = Color(12, 12, 18)

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, SMGRP and SMGRP.UI and SMGRP.UI.Colors and SMGRP.UI.Colors.bg_darkest or _invBg )
end

vgui.Register( "bricks_server_unboxingmenu_inventory", PANEL, "DPanel" )
