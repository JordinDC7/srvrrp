local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local gridWide = self.panelWide-50-20
    self.slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 200 ) )
    self.spacing = 10
    self.slotSize = (gridWide-((self.slotsWide-1)*self.spacing))/self.slotsWide
    self.selectedItems = {} -- track selected items for deletion
    self.selectMode = false
    
    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    self.topBar.Paint = function( self2, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )
    end 

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( ScrW()*0.12 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:FillInventory()
    end

    -- ====== FILTER TABS ======
    self.filterChoice = "all"
    local filterPanel = vgui.Create( "DPanel", self.topBar )
    filterPanel:Dock( LEFT )
    filterPanel:DockMargin( 5, 10, 10, 10 )
    filterPanel:SetWide( 310 )
    filterPanel.Paint = function() end

    local filters = {
        { key = "all",     label = "All Items" },
        { key = "weapons", label = "Weapons" },
        { key = "cases",   label = "Cases" },
        { key = "keys",    label = "Keys" },
    }

    for _, f in ipairs(filters) do
        local btn = vgui.Create( "DButton", filterPanel )
        btn:Dock( LEFT )
        btn:SetWide( 72 )
        btn:DockMargin( 0, 0, 5, 0 )
        btn:SetText( "" )
        btn.filterKey = f.key
        btn.Paint = function( self2, w, h )
            local isActive = (self.filterChoice == f.key)
            local bgCol = isActive and BRICKS_SERVER.Func.GetTheme( 0 ) or BRICKS_SERVER.Func.GetTheme( 1 )
            if self2:IsHovered() and not isActive then
                bgCol = BRICKS_SERVER.Func.GetTheme( 0, 100 )
            end
            draw.RoundedBox( 6, 0, 0, w, h, bgCol )
            local textCol = isActive and Color(255,255,255) or BRICKS_SERVER.Func.GetTheme( 6, 150 )
            draw.SimpleText( f.label, "BRICKS_SERVER_Font18", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        btn.DoClick = function()
            self.filterChoice = f.key
            self:FillInventory()
        end
    end

    -- ====== MANAGE BUTTON (toggle select mode) ======
    self.manageBtn = vgui.Create( "DButton", self.topBar )
    self.manageBtn:Dock( RIGHT )
    self.manageBtn:DockMargin( 5, 10, 25, 10 )
    self.manageBtn:SetWide( 80 )
    self.manageBtn:SetText( "" )
    self.manageBtn.Paint = function( self2, w, h )
        local bgCol = self.selectMode and Color(200,50,50) or BRICKS_SERVER.Func.GetTheme( 1 )
        if self2:IsHovered() then bgCol = self.selectMode and Color(220,70,70) or BRICKS_SERVER.Func.GetTheme( 0, 100 ) end
        draw.RoundedBox( 6, 0, 0, w, h, bgCol )
        local txt = self.selectMode and "Cancel" or "Manage"
        draw.SimpleText( txt, "BRICKS_SERVER_Font18", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    self.manageBtn.DoClick = function()
        self.selectMode = not self.selectMode
        self.selectedItems = {}
        if self.selectMode then
            self.actionBar:SetVisible(true)
        else
            self.actionBar:SetVisible(false)
        end
        self:FillInventory()
    end

    self.sortChoice = "rarity_high_to_low"

    self.sortBy = vgui.Create( "bricks_server_combo", self.topBar )
    self.sortBy:Dock( RIGHT )
    self.sortBy:DockMargin( 5, 10, 5, 10 )
    self.sortBy:SetWide( 140 )
    self.sortBy:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.sortBy:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.sortBy:SetValue( BRICKS_SERVER.Func.L( "unboxingHighestRarity" ) )
    self.sortBy:AddChoice( BRICKS_SERVER.Func.L( "unboxingHighestRarity" ), "rarity_high_to_low" )
    self.sortBy:AddChoice( BRICKS_SERVER.Func.L( "unboxingLowestRarity" ), "rarity_low_to_high" )
    self.sortBy.OnSelect = function( self2, index, value, data )
        self.sortChoice = data
        self:FillInventory()
    end

    -- ====== ACTION BAR (shown in select mode) ======
    self.actionBar = vgui.Create( "DPanel", self )
    self.actionBar:Dock( TOP )
    self.actionBar:SetTall( 40 )
    self.actionBar:SetVisible(false)
    self.actionBar.Paint = function( self2, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color(40, 20, 20) )
    end

    -- Select All button
    local selectAllBtn = vgui.Create( "DButton", self.actionBar )
    selectAllBtn:Dock( LEFT )
    selectAllBtn:DockMargin( 25, 5, 5, 5 )
    selectAllBtn:SetWide( 90 )
    selectAllBtn:SetText( "" )
    selectAllBtn.Paint = function( self2, w, h )
        local bgCol = self2:IsHovered() and Color(60,63,75) or Color(45,48,58)
        draw.RoundedBox( 6, 0, 0, w, h, bgCol )
        draw.SimpleText( "Select All", "BRS_UW_Font12B", w/2, h/2, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    selectAllBtn.DoClick = function()
        self:SelectAllVisible()
    end

    -- Deselect All button
    local deselectBtn = vgui.Create( "DButton", self.actionBar )
    deselectBtn:Dock( LEFT )
    deselectBtn:DockMargin( 0, 5, 5, 5 )
    deselectBtn:SetWide( 90 )
    deselectBtn:SetText( "" )
    deselectBtn.Paint = function( self2, w, h )
        local bgCol = self2:IsHovered() and Color(60,63,75) or Color(45,48,58)
        draw.RoundedBox( 6, 0, 0, w, h, bgCol )
        draw.SimpleText( "Deselect All", "BRS_UW_Font12B", w/2, h/2, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    deselectBtn.DoClick = function()
        self.selectedItems = {}
        self:FillInventory()
    end

    -- Selected count label
    self.selectedLabel = vgui.Create( "DPanel", self.actionBar )
    self.selectedLabel:Dock( LEFT )
    self.selectedLabel:DockMargin( 10, 5, 5, 5 )
    self.selectedLabel:SetWide( 120 )
    self.selectedLabel.Paint = function( self2, w, h )
        local count = table.Count(self.selectedItems)
        draw.SimpleText( count .. " selected", "BRS_UW_Font14", w/2, h/2, Color(180,180,180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    -- DELETE button
    local deleteBtn = vgui.Create( "DButton", self.actionBar )
    deleteBtn:Dock( RIGHT )
    deleteBtn:DockMargin( 5, 5, 25, 5 )
    deleteBtn:SetWide( 120 )
    deleteBtn:SetText( "" )
    deleteBtn.Paint = function( self2, w, h )
        local count = table.Count(self.selectedItems)
        local bgCol = count > 0 and (self2:IsHovered() and Color(220,40,40) or Color(180,30,30)) or Color(80,30,30)
        draw.RoundedBox( 6, 0, 0, w, h, bgCol )
        draw.SimpleText( "Delete (" .. count .. ")", "BRS_UW_Font14B", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    deleteBtn.DoClick = function()
        local count = table.Count(self.selectedItems)
        if count == 0 then return end

        -- Confirm
        Derma_Query("Delete " .. count .. " item(s)? This cannot be undone.", "Confirm Delete",
            "Delete", function()
                local keys = {}
                for k, _ in pairs(self.selectedItems) do
                    table.insert(keys, k)
                end

                net.Start("BRS_UW.DeleteWeapons")
                    net.WriteUInt(#keys, 16)
                    for _, key in ipairs(keys) do
                        net.WriteString(key)
                    end
                net.SendToServer()

                self.selectedItems = {}
                self.selectMode = false
                self.actionBar:SetVisible(false)

                timer.Simple(0.5, function()
                    if IsValid(self) then self:FillInventory() end
                end)
            end,
            "Cancel", function() end
        )
    end

    -- Item count footer
    self.itemCountBar = vgui.Create( "DPanel", self )
    self.itemCountBar:Dock( BOTTOM )
    self.itemCountBar:SetTall( 24 )
    self.itemCountBar.Paint = function( self2, w, h )
        draw.SimpleText( (self.itemCount or 0) .. " items", "BRS_UW_Font12B", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 100 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self2, w, h ) end 

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( self.spacing )
    self.grid:SetSpaceX( self.spacing )

    self:FillInventory()

    hook.Add( "BRS.Hooks.FillUnboxingInventory", self, function()
        self:FillInventory()
    end )
end

function PANEL:SelectAllVisible()
    -- Select all currently visible items that are unique weapons
    for k, v in pairs( LocalPlayer():GetUnboxingInventory() ) do
        if BRS_UW and BRS_UW.IsUniqueWeapon and BRS_UW.IsUniqueWeapon(k) then
            self.selectedItems[k] = true
        end
    end
    self:FillInventory()
end

function PANEL:AddSlot( globalKey, amount, actions )
    local slotWrapper = self.grid:Add( "DPanel" )
    slotWrapper:SetSize( self.slotSize, self.slotSize*1.2 )
    slotWrapper.Paint = function() end

    local slotBack = vgui.Create( "bricks_server_unboxingmenu_itemslot", slotWrapper )
    slotBack:SetSize( self.slotSize, self.slotSize*1.2 )
    slotBack:FillPanel( globalKey, amount, actions )

    if( LocalPlayer():UnboxingIsItemEquipped( globalKey ) ) then
        slotBack:AddTopInfo( "Equipped", Color(200, 50, 50, 200), Color(255,255,255), true )
    end

    -- ====== SELECTION CHECKBOX OVERLAY ======
    if self.selectMode and BRS_UW and BRS_UW.IsUniqueWeapon and BRS_UW.IsUniqueWeapon(globalKey) then
        local isSelected = self.selectedItems[globalKey] or false

        local checkbox = vgui.Create( "DButton", slotWrapper )
        checkbox:SetSize( 22, 22 )
        checkbox:SetPos( self.slotSize - 26, 4 )
        checkbox:SetText( "" )
        checkbox:SetZPos( 100 )
        checkbox.Paint = function( self2, w, h )
            local sel = self.selectedItems[globalKey] or false
            draw.RoundedBox( 4, 0, 0, w, h, sel and Color(200,50,50,220) or Color(30,30,30,180) )
            draw.RoundedBox( 3, 1, 1, w-2, h-2, sel and Color(220,60,60) or Color(50,50,50,200) )
            if sel then
                draw.SimpleText( "✓", "BRS_UW_Font14B", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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
        
        local sortRarity = configItemTable.Rarity or ""
        if uwData and uwData.rarity then
            sortRarity = uwData.rarity
        end
        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( sortRarity )
        
        if uwData and BRS_UW.RarityOrder and BRS_UW.RarityOrder[uwData.rarity] then
            rarityKey = BRS_UW.RarityOrder[uwData.rarity]
        end

        table.insert( sortedItems, { rarityKey, k, v } )
    end

    if( self.sortChoice == "rarity_high_to_low" ) then
        table.SortByMember( sortedItems, 1, false )
    elseif( self.sortChoice == "rarity_low_to_high" ) then
        table.SortByMember( sortedItems, 1, true )
    end

    self.grid:SetTall( (math.ceil(#sortedItems/self.slotsWide)*(self.slotSize*1.2+self.spacing))-self.spacing )
    self.itemCount = #sortedItems

    for k2, v in pairs( sortedItems ) do
        local globalKey, itemAmount = v[2], v[3]
        local configItemTable, itemKey2, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )

        local actions = {}
        local isUW = BRS_UW and BRS_UW.IsUniqueWeapon and BRS_UW.IsUniqueWeapon(globalKey)

        -- In select mode, clicking selects instead of showing actions
        if self.selectMode and isUW then
            actions = function(ax, ay, aw, ah)
                if self.selectedItems[globalKey] then
                    self.selectedItems[globalKey] = nil
                else
                    self.selectedItems[globalKey] = true
                end
            end
        elseif( isItem ) then
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
            table.insert( actions, { BRICKS_SERVER.Func.L( "view" ), function()
                self.popoutPanel = vgui.Create( "bricks_server_unboxingmenu_caseview_popup", self )
                self.popoutPanel:SetPos( 0, 0 )
                self.popoutPanel:SetSize( self.panelWide, ScrH()*0.65-40 )
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
            table.insert( actions, { BRICKS_SERVER.Func.L( "view" ), function()
                self.popoutPanel = vgui.Create( "bricks_server_unboxingmenu_keyview_popup", self )
                self.popoutPanel:SetPos( 0, 0 )
                self.popoutPanel:SetSize( self.panelWide, ScrH()*0.65-40 )
                self.popoutPanel:CreatePopout()
                self.popoutPanel:FillPanel( itemKey2, false, true )
            end } )
        end

        self:AddSlot( globalKey, (itemAmount or 1), actions )
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_inventory", PANEL, "DPanel" )
