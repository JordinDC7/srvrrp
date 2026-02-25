local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local gridWide = self.panelWide-50-20
    self.slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 200 ) )
    self.spacing = 10
    self.slotSize = (gridWide-((self.slotsWide-1)*self.spacing))/self.slotsWide
    
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
    self.searchBar:SetWide( ScrW()*0.15 )
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

    self.sortChoice = "rarity_high_to_low"

    self.sortBy = vgui.Create( "bricks_server_combo", self.topBar )
    self.sortBy:Dock( RIGHT )
    self.sortBy:DockMargin( 10, 10, 25, 10 )
    self.sortBy:SetWide( 150 )
    self.sortBy:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.sortBy:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.sortBy:SetValue( BRICKS_SERVER.Func.L( "unboxingHighestRarity" ) )
    self.sortBy:AddChoice( BRICKS_SERVER.Func.L( "unboxingHighestRarity" ), "rarity_high_to_low" )
    self.sortBy:AddChoice( BRICKS_SERVER.Func.L( "unboxingLowestRarity" ), "rarity_low_to_high" )
    self.sortBy.OnSelect = function( self2, index, value, data )
        self.sortChoice = data
        self:FillInventory()
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

function PANEL:AddSlot( globalKey, amount, actions )
    local slotBack = self.grid:Add( "bricks_server_unboxingmenu_itemslot" )
    slotBack:SetSize( self.slotSize, self.slotSize*1.2 )
    slotBack:FillPanel( globalKey, amount, actions )

    if( LocalPlayer():UnboxingIsItemEquipped( globalKey ) ) then
        slotBack:AddTopInfo( "Equipped", Color(200, 50, 50, 200), Color(255,255,255), true )
    end
end

function PANEL:FillInventory()
    self.grid:Clear()

    local sortedItems = {}
    for k, v in pairs( LocalPlayer():GetUnboxingInventory() ) do
        local configItemTable, itemKey2, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )

        if( not configItemTable ) then continue end

        -- ====== FILTER LOGIC ======
        if self.filterChoice == "weapons" and not isItem then continue end
        if self.filterChoice == "cases" and not isCase then continue end
        if self.filterChoice == "keys" and not isKey then continue end

        -- Search filter
        local searchName = configItemTable.Name or ""
        -- For unique weapons, also check rarity and quality in search
        local isUW = BRS_UW and BRS_UW.IsUniqueWeapon and BRS_UW.IsUniqueWeapon(k)
        local uwData = isUW and BRS_UW.GetWeaponData(k)
        if uwData then
            searchName = searchName .. " " .. (uwData.rarity or "") .. " " .. (uwData.quality or "")
        end

        if( self.searchBar:GetValue() ~= "" and not string.find( string.lower( searchName ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end
        
        -- Use unique weapon rarity for sorting if available
        local sortRarity = configItemTable.Rarity or ""
        if uwData and uwData.rarity then
            sortRarity = uwData.rarity
        end
        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( sortRarity )
        
        -- For unique weapons with custom rarities, use our ordering
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

    -- Item count display
    local itemCountText = #sortedItems .. " items"
    -- Could add a label here if desired

    for k2, v in pairs( sortedItems ) do
        local globalKey, itemAmount = v[2], v[3]
        local configItemTable, itemKey2, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )

        local actions = {}

        -- ====== UNIQUE WEAPON ACTIONS ======
        local isUW = BRS_UW and BRS_UW.IsUniqueWeapon and BRS_UW.IsUniqueWeapon(globalKey)

        if( isItem ) then
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

            -- ====== INSPECT ACTION FOR UNIQUE WEAPONS ======
            if isUW then
                table.insert( actions, 1, { "Inspect", function()
                    local uwData = BRS_UW.GetWeaponData(globalKey)
                    if uwData then
                        BRS_UW.OpenInspectPopup(globalKey, uwData)
                    else
                        -- Request from server
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
