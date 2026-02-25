-- ============================================================
-- SmG RP - Custom Store Page
-- Dark tactical theme with enhanced cart UX
-- ============================================================
local PANEL = {}

function PANEL:Init()
    
end

function PANEL:FillPanel()
    self.panelTall = ScrH()*0.65-40
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}

    -- ====== TOP BAR ======
    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 52 )
    self.topBar.Paint = function( self2, w, h ) 
        draw.RoundedBox( 0, 0, 0, w, h, C.bg_dark or Color(18,18,26) )
        surface.SetDrawColor(C.border or Color(50,52,65))
        surface.DrawRect(0, h - 1, w, 1)
    end 

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 20, 8, 8, 8 )
    self.searchBar:SetWide( ScrW()*0.2 )
    self.searchBar:SetBackColor( C.bg_input or Color(22,23,30) )
    self.searchBar:SetHighlightColor( C.accent_dim or Color(0,160,128) )
    self.searchBar.OnChange = function()
        self:RefreshStore()
    end

    -- ====== CART BUTTON ======
    local cartButton = vgui.Create( "DButton", self.topBar )
    cartButton:SetSize( 36, 36 )
    cartButton:SetPos( 20+self.panelWide-50-cartButton:GetWide(), (self.topBar:GetTall()/2)-(cartButton:GetTall()/2) )
    cartButton:SetText( "" )
    local cartAlpha = 0
    local inboxMat = Material( "bricks_server/unboxing_cart.png" )
    cartButton.Paint = function( self2, w, h )
        if( self2:IsDown() ) then
            cartAlpha = 0
        elseif( self2:IsHovered() ) then
            cartAlpha = math.Clamp( cartAlpha+8, 0, 60 )
        else
            cartAlpha = math.Clamp( cartAlpha-8, 0, 60 )
        end
        draw.RoundedBox( 6, 0, 0, w, h, C.bg_light or Color(34,36,46) )
        if cartAlpha > 0 then
            draw.RoundedBox( 6, 0, 0, w, h, Color(255,255,255, cartAlpha) )
        end
        surface.SetDrawColor( C.text_secondary or Color(140,144,160) )
        surface.SetMaterial( inboxMat )
        local iconSize = 20
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    local buttonX, buttonY = cartButton:GetPos()

    -- ====== CART PANEL (dropdown) ======
    cartButton.DoClick = function()
        if( IsValid( cartButton.CartPanel ) ) then 
            cartButton.CartPanel:SizeTo( 0, 0, 0.15, 0, -1, function()
                cartButton.CartPanel:Remove()
            end )
            return
        end

        local cartSlotTall = 44
        local triangleSizeW, triangleSizeH = 12, 8
        local triangleSpacing = (cartButton:GetWide()-triangleSizeW)/2
        local bottomBarH = 44

        cartButton.CartPanel = vgui.Create( "DPanel", self )
        cartButton.CartPanel:SizeTo( ScrW()*0.16, 36+triangleSizeH+bottomBarH+(5*cartSlotTall), 0.15, 0, -1, function()
            cartButton.CartPanel:SetPos( self.panelWide-50+20-cartButton.CartPanel:GetWide(), buttonY+cartButton:GetTall()-3 )
        end )
        cartButton.CartPanel:SetPos( self.panelWide-50+20-cartButton.CartPanel:GetWide(), buttonY+cartButton:GetTall()-3 )
        cartButton.CartPanel.Paint = function( self2, w, h )
            local sx, sy = self2:LocalToScreen( 0, 0 )

            local triangle = {
                { x = sx+w-triangleSpacing-triangleSizeW, y = sy+triangleSizeH },
                { x = sx+w-triangleSpacing-(triangleSizeW/2), y = sy },
                { x = sx+w-triangleSpacing, y = sy+triangleSizeH }
            }
        
            BRICKS_SERVER.BSHADOWS.BeginShadow()
            draw.RoundedBox( 6, sx, sy+triangleSizeH, w, h-triangleSizeH, C.bg_mid or Color(26,27,35) )
            surface.SetDrawColor( C.bg_light or Color(34,36,46) )
            draw.NoTexture()
            surface.DrawPoly( triangle )
            BRICKS_SERVER.BSHADOWS.EndShadow(1, 4, 1, 255, 0, 0, false )

            draw.RoundedBoxEx( 6, 0, triangleSizeH, w, 36, C.bg_light or Color(34,36,46), true, true, false, false )
            draw.SimpleText( "CART", "SMGRP_Bold14", 10, triangleSizeH+18, C.text_primary or Color(220,222,230), 0, TEXT_ALIGN_CENTER )
        end
        cartButton.CartPanel.Think = function( self2 )
            if( not IsValid( cartButton ) ) then self2:Remove() end
        end
        cartButton.CartPanel.OnSizeChanged = function( self2 )
            self2:SetPos( self.panelWide-50+20-cartButton.CartPanel:GetWide(), buttonY+cartButton:GetTall()-3 )
        end

        local cartTotalW = ScrW()*0.16-20-20

        -- Bottom bar with total + checkout
        local cartBottomBar = vgui.Create( "DPanel", cartButton.CartPanel )
        cartBottomBar:Dock( BOTTOM )
        cartBottomBar:SetTall( bottomBarH )
        local totalCosts = {}
        cartBottomBar.Paint = function( self2, w, h )
            draw.RoundedBoxEx( 6, 0, 0, w, h, C.bg_light or Color(34,36,46), false, false, true, true )

            local costString = ""
            for k, v in pairs( totalCosts ) do
                if( costString == "" ) then
                    costString = BRICKS_SERVER.UNBOXING.Func.FormatCurrency( v, k )
                else
                    costString = costString .. ", " .. BRICKS_SERVER.UNBOXING.Func.FormatCurrency( v, k )
                end
            end

            draw.SimpleText( "Total: " .. costString, "SMGRP_Body12", 10, h/2, C.text_muted or Color(90,94,110), 0, TEXT_ALIGN_CENTER )
        end

        -- Checkout button
        local cartCheckoutButton = vgui.Create( "DButton", cartBottomBar )
        cartCheckoutButton:Dock( RIGHT )
        cartCheckoutButton:DockMargin( 6, 6, 6, 6 )
        cartCheckoutButton:SetWide( 80 )
        cartCheckoutButton:SetText( "" )
        local checkAlpha = 0
        cartCheckoutButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                checkAlpha = math.Clamp( checkAlpha+10, 0, 255 )
            else
                checkAlpha = math.Clamp( checkAlpha-10, 0, 255 )
            end
            local baseCol = C.accent_dim or Color(0,160,128)
            local hoverCol = C.accent or Color(0,212,170)
            local r = Lerp(checkAlpha/255, baseCol.r, hoverCol.r)
            local g = Lerp(checkAlpha/255, baseCol.g, hoverCol.g)
            local b = Lerp(checkAlpha/255, baseCol.b, hoverCol.b)
            draw.RoundedBox( 4, 0, 0, w, h, Color(r, g, b) )
            draw.SimpleText( "BUY", "SMGRP_Bold12", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        cartCheckoutButton.DoClick = function()
            if( not BRS_UNBOXING_CART or table.Count( BRS_UNBOXING_CART ) <= 0 ) then
                BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "unboxingCartEmpty" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                return
            end
            for k, v in pairs( totalCosts ) do
                if( not BRICKS_SERVER.UNBOXING.Func.CanAffordCurrency( LocalPlayer(), v, k ) ) then
                    BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "unboxingCartCantAfford" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                    return
                end
            end
            net.Start( "BRS.Net.PurchaseShopUnboxingItems" )
                net.WriteUInt( table.Count( BRS_UNBOXING_CART ), 8 )
                for k, v in pairs( BRS_UNBOXING_CART ) do
                    net.WriteUInt( k, 16 )
                    net.WriteUInt( v, 16 )
                end
            net.SendToServer()
        end

        cartTotalW = cartTotalW-cartCheckoutButton:GetWide()

        -- Cart scroll area
        local cartScroll = vgui.Create( "bricks_server_scrollpanel_bar", cartButton.CartPanel )
        cartScroll:Dock( FILL )
        cartScroll:DockMargin( 0, 36+triangleSizeH, 0, 0 )
        cartScroll:SetBarBackColor( C.bg_darkest or Color(12,12,18) )
        cartScroll:GetVBar():SetRounded( 0 )

        function cartButton.RefreshShoppingCartPanel()
            if( not IsValid( cartScroll ) ) then return end
            cartScroll:Clear()
            totalCosts = {}

            local itemCount = 0
            for k, v in pairs( BRS_UNBOXING_CART or {} ) do
                local shopItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Store.Items[k] or {}
                if( not shopItemTable.GlobalKey ) then continue end
                local itemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( shopItemTable.GlobalKey )
                if( not itemTable ) then BRS_UNBOXING_CART[k] = nil continue end

                local currency = shopItemTable.Currency or BRICKS_SERVER.UNBOXING.LUACFG.DefaultCurrency
                totalCosts[currency] = (totalCosts[currency] or 0)+((shopItemTable.Price or 0)*v)

                itemCount = itemCount+1
                local currentItemPos = itemCount

                local cartEntry = vgui.Create( "DPanel", cartScroll )
                cartEntry:Dock( TOP )
                cartEntry:SetTall( cartSlotTall )
                cartEntry.Paint = function( self2, w, h )
                    if( currentItemPos % 2 == 0 ) then
                        surface.SetDrawColor( C.bg_darkest or Color(12,12,18) )
                        surface.DrawRect( 0, 0, w, h )
                    end
                    draw.SimpleText( (itemTable.Name or "?"), "SMGRP_Body13", 10, h/2, C.text_secondary or Color(140,144,160), 0, TEXT_ALIGN_CENTER )
                end

                -- Delete button
                local cartEntryDelete = vgui.Create( "DButton", cartEntry )
                cartEntryDelete:Dock( RIGHT )
                cartEntryDelete:SetWide( cartEntry:GetTall() )
                cartEntryDelete:SetText( "" )
                local delAlpha = 0
                local deleteMat = Material( "bricks_server/delete.png" )
                cartEntryDelete.Paint = function( self2, w, h )
                    if self2:IsHovered() then delAlpha = math.Clamp(delAlpha+8, 0, 200)
                    else delAlpha = math.Clamp(delAlpha-8, 0, 200) end
                    if delAlpha > 0 then
                        draw.RoundedBox(4, 2, 2, w-4, h-4, Color(220,60,60, math.floor(delAlpha*0.3)))
                    end
                    surface.SetDrawColor( C.red or Color(220,60,60) )
                    surface.SetMaterial( deleteMat )
                    local iconSize = 16
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end
                cartEntryDelete.DoClick = function()
                    BRS_UNBOXING_CART[k] = nil
                    self:RefreshShoppingCart()
                end

                -- Quantity controls
                local amountH = 28
                local cartEntryAmount = vgui.Create( "DPanel", cartEntry )
                cartEntryAmount:Dock( RIGHT )
                cartEntryAmount:SetWide( 90 )
                cartEntryAmount.Paint = function( self2, w, h )
                    draw.RoundedBox( 4, 0, (h/2)-(amountH/2), w, amountH, C.bg_darkest or Color(12,12,18) )
                    draw.SimpleText( v, "SMGRP_Bold12", w/2, h/2, C.text_primary or Color(220,222,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                -- Click quantity to type custom amount
                local cartEntryAmountBtn = vgui.Create( "DButton", cartEntryAmount )
                cartEntryAmountBtn:Dock( FILL )
                cartEntryAmountBtn:DockMargin( amountH, 0, amountH, 0 )
                cartEntryAmountBtn:SetText( "" )
                cartEntryAmountBtn.Paint = function() end
                cartEntryAmountBtn.DoClick = function()
                    BRICKS_SERVER.Func.StringRequest( "Quantity", "Enter amount:", v, function( text )
                        local num = tonumber(text)
                        if num and num >= 1 then
                            BRS_UNBOXING_CART[k] = math.floor(num)
                            self:RefreshShoppingCart()
                        end
                    end, function() end, "Set", "Cancel", true )
                end

                -- + button
                local addBtn = vgui.Create( "DButton", cartEntryAmount )
                addBtn:Dock( RIGHT )
                addBtn:SetWide( amountH )
                addBtn:SetText( "" )
                addBtn.Paint = function( self2, w, h )
                    local col = self2:IsHovered() and (C.accent or Color(0,212,170)) or (C.text_muted or Color(90,94,110))
                    draw.SimpleText( "+", "SMGRP_Bold14", w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                addBtn.DoClick = function()
                    BRS_UNBOXING_CART[k] = BRS_UNBOXING_CART[k]+1
                    self:RefreshShoppingCart()
                end

                -- - button
                local minusBtn = vgui.Create( "DButton", cartEntryAmount )
                minusBtn:Dock( LEFT )
                minusBtn:SetWide( amountH )
                minusBtn:SetText( "" )
                minusBtn.Paint = function( self2, w, h )
                    local col = self2:IsHovered() and (C.red or Color(220,60,60)) or (C.text_muted or Color(90,94,110))
                    draw.SimpleText( "-", "SMGRP_Bold14", w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                minusBtn.DoClick = function()
                    BRS_UNBOXING_CART[k] = BRS_UNBOXING_CART[k]-1
                    if( BRS_UNBOXING_CART[k] <= 0 ) then BRS_UNBOXING_CART[k] = nil end
                    self:RefreshShoppingCart()
                end
            end
        end
        cartButton.RefreshShoppingCartPanel()
    end

    -- ====== CART REFRESH + BADGE ======
    function self:RefreshShoppingCart()
        if( cartButton.RefreshShoppingCartPanel ) then cartButton.RefreshShoppingCartPanel() end
        if( IsValid( cartButton.itemsNotification ) ) then cartButton.itemsNotification:Remove() end

        if( table.Count( BRS_UNBOXING_CART or {} ) > 0 ) then
            cartButton.itemsNotification = vgui.Create( "DPanel", self )
            cartButton.itemsNotification:SetSize( 12, 12 )
            cartButton.itemsNotification:SetPos( self.panelWide-50+20-(cartButton.itemsNotification:GetWide()/2)-3, buttonY+cartButton:GetTall()-(cartButton.itemsNotification:GetTall()/2)-3 )
            cartButton.itemsNotification.Paint = function( self2, w, h )
                draw.RoundedBox(w/2, 0, 0, w, h, C.accent or Color(0,212,170))
            end
        end
    end
    self:RefreshShoppingCart()

    hook.Add( "BRS.Hooks.RefreshUnboxingCart", self, function()
        self:RefreshShoppingCart()
        if( IsValid( cartButton ) and IsValid( cartButton.CartPanel ) ) then 
            cartButton.CartPanel:SizeTo( 0, 0, 0.15, 0, -1, function() cartButton.CartPanel:Remove() end )
        end
    end )
    hook.Add( "BRS.Hooks.ConfigReceived", self, function() self:RefreshStore() end )

    -- ====== STORE SCROLL ======
    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 20, 16, 20, 16 )
    self.scrollPanel.Paint = function() end

    self.scrollPanelWide = self.panelWide-40-20

    self:RefreshStore()
end

function PANEL:AddStoreItem( storeTable, itemKey, grid, itemWidth, itemHeight )
    if( not storeTable or not storeTable.GlobalKey ) then return end

    local function addToCart( amount )
        amount = amount or 1
        BRS_UNBOXING_CART = BRS_UNBOXING_CART or {}
        BRS_UNBOXING_CART[itemKey] = (BRS_UNBOXING_CART[itemKey] or 0) + amount
        self:RefreshShoppingCart()
        BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "unboxingCartItemAdded" ) .. " (x" .. amount .. ")", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
    end

    local slotBack = grid:Add( "bricks_server_unboxingmenu_itemslot" )
    slotBack:SetSize( itemWidth, itemHeight )
    slotBack:FillPanel( storeTable.GlobalKey, 1, function( ax, ay, aw, ah )
        local isCase, isKey = string.StartWith( storeTable.GlobalKey, "CASE_" ), string.StartWith( storeTable.GlobalKey, "KEY_" )
        if( not isCase and not isKey ) then
            local menu = DermaMenu()
            menu:AddOption( "Add 1 to Cart", function() addToCart(1) end )
            menu:AddOption( "Add 5 to Cart", function() addToCart(5) end )
            menu:AddOption( "Add 10 to Cart", function() addToCart(10) end )
            menu:AddOption( "Add 25 to Cart", function() addToCart(25) end )
            menu:AddSpacer()
            menu:AddOption( "Custom Amount...", function()
                BRICKS_SERVER.Func.StringRequest( "Quantity", "How many to add to cart?", "1", function( text )
                    local num = tonumber(text)
                    if num and num >= 1 then addToCart(math.floor(num)) end
                end, function() end, "Add", "Cancel", true )
            end )
            menu:Open()
        else
            local menu = DermaMenu()
            menu:AddOption( "View Contents", function()
                local itmKey = tonumber( string.Replace( storeTable.GlobalKey, (isCase and "CASE_") or "KEY_", "" ) )
                self.popoutPanel = vgui.Create( (isCase and "bricks_server_unboxingmenu_caseview_popup") or "bricks_server_unboxingmenu_keyview_popup", self )
                self.popoutPanel:SetPos( 0, 0 )
                self.popoutPanel:SetSize( self.panelWide, self.panelTall )
                self.popoutPanel:CreatePopout()
                self.popoutPanel:FillPanel( itmKey, function()
                    addToCart(1)
                    if( not IsValid( self.popoutPanel.popoutPanel ) ) then return end
                    self.popoutPanel.popoutPanel.ClosePopout()
                end )
            end )
            menu:AddSpacer()
            menu:AddOption( "Add 1 to Cart", function() addToCart(1) end )
            menu:AddOption( "Add 5 to Cart", function() addToCart(5) end )
            menu:AddOption( "Add 10 to Cart", function() addToCart(10) end )
            menu:AddOption( "Add 25 to Cart", function() addToCart(25) end )
            menu:AddSpacer()
            menu:AddOption( "Custom Amount...", function()
                BRICKS_SERVER.Func.StringRequest( "Quantity", "How many to add to cart?", "1", function( text )
                    local num = tonumber(text)
                    if num and num >= 1 then addToCart(math.floor(num)) end
                end, function() end, "Add", "Cancel", true )
            end )
            menu:Open()
        end
    end )

    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
    slotBack:AddTopInfo( BRICKS_SERVER.UNBOXING.Func.FormatCurrency( storeTable.Price or 0, storeTable.Currency ), C.accent_dim or Color(0,160,128), Color(255,255,255) )

    if( storeTable.Group ) then
        local groupTable = {}
        for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
            if( val[1] == storeTable.Group ) then groupTable = val break end
        end
        slotBack:AddTopInfo( storeTable.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme( 6 ) )
    end
end

function PANEL:RefreshStore()
    self.scrollPanel:Clear()
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
    
    local storeConfig = BRICKS_SERVER.CONFIG.UNBOXING.Store
    local storeItemsConfig = storeConfig.Items

    -- ====== FEATURED SECTION ======
    if( storeConfig.Featured ) then
        self.featuredHeader = vgui.Create( "DPanel", self.scrollPanel )
        self.featuredHeader:Dock( TOP )
        self.featuredHeader:DockMargin( 0, 0, 10, 6 )
        self.featuredHeader:SetTall( 24 )
        self.featuredHeader.Paint = function( self2, w, h ) 
            draw.SimpleText( "FEATURED", "SMGRP_Bold16", 0, h/2, C.accent or Color(0,212,170), 0, TEXT_ALIGN_CENTER )
        end

        self.featuredBack = vgui.Create( "DPanel", self.scrollPanel )
        self.featuredBack:Dock( TOP )
        self.featuredBack:DockMargin( 0, 0, 10, 0 )
        self.featuredBack:SetTall( ScrH()*0.35 )
        self.featuredBack.Paint = function() end

        local featuredSpacing = 8
        local featuredWide = (self.scrollPanelWide-((BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount-1)*featuredSpacing))/BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount
        
        self.featuredGrid = vgui.Create( "DIconLayout", self.featuredBack )
        self.featuredGrid:Dock( FILL )
        self.featuredGrid:SetSpaceY( featuredSpacing )
        self.featuredGrid:SetSpaceX( featuredSpacing )

        for i = 1, BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount do
            self:AddStoreItem( (storeItemsConfig[storeConfig.Featured[i] or 0] or {}), storeConfig.Featured[i], self.featuredGrid, featuredWide, self.featuredBack:GetTall() )
        end
    end

    -- ====== CATEGORY SECTIONS ======
    local itemSpacing = 6
    local wantedItemSize = 200
    local itemSlotsWide = math.floor( self.scrollPanelWide/wantedItemSize )
    local itemSlotWidth = (self.scrollPanelWide-((itemSlotsWide-1)*itemSpacing))/itemSlotsWide
    local itemSlotTall = itemSlotWidth*1.25

    local sortedCategories = {}
    for k, v in pairs( storeConfig.Categories ) do
        table.insert( sortedCategories, { k, v } )
    end
    table.sort( sortedCategories, function(a, b) return (((a or {})[2] or {}).SortOrder or 1000) < (((b or {})[2] or {}).SortOrder or 1000) end )

    self.categories = {}
    local categoryHeaderTall = 24
    local categoryHeaderSpacing = 6
    for _, val in pairs( sortedCategories ) do
        local k, v = val[1], val[2]

        self.categories[k] = vgui.Create( "DPanel", self.scrollPanel )
        self.categories[k]:Dock( TOP )
        self.categories[k]:DockMargin( 0, 20, 10, 0 )
        self.categories[k]:DockPadding( 0, categoryHeaderTall+categoryHeaderSpacing, 0, 0 )
        self.categories[k]:SetTall( categoryHeaderTall )
        self.categories[k].Paint = function( self2, w, h )
            -- Category header with subtle accent line
            draw.SimpleText( string.upper( v.Name ), "SMGRP_Bold16", 0, 0, C.text_primary or Color(220,222,230), 0, 0 )
            surface.SetDrawColor(C.accent_dim or Color(0,160,128))
            -- Accent underline
            surface.SetFont("SMGRP_Bold16")
            local tw = surface.GetTextSize(string.upper(v.Name))
            surface.DrawRect(0, 22, tw, 2)
        end

        self.categories[k].grid = vgui.Create( "DIconLayout", self.categories[k] )
        self.categories[k].grid:Dock( TOP )
        self.categories[k].grid:SetTall( 0 )
        self.categories[k].grid:SetSpaceY( itemSpacing )
        self.categories[k].grid:SetSpaceX( itemSpacing )
    end

    local sortedStoreItems = {}
    for k, v in pairs( storeItemsConfig ) do
        local itemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( v.GlobalKey )
        if( not itemTable or (self.searchBar:GetValue() != "" and not string.find( string.lower( itemTable.Name ), string.lower( self.searchBar:GetValue() ) )) ) then
            continue
        end
        sortedStoreItems[k] = table.Copy( v )
        sortedStoreItems[k].Key = k
    end
    table.sort( sortedStoreItems, function(a, b) return ((a or {}).SortOrder or 1000) < ((b or {}).SortOrder or 1000) end )

    for k, v in pairs( sortedStoreItems ) do
        local categoryPanel = self.categories[v.Category or 0]
        if( not IsValid( categoryPanel ) ) then continue end
        local gridPanel = categoryPanel.grid
        if( not IsValid( gridPanel ) ) then continue end

        self:AddStoreItem( v, v.Key, gridPanel, itemSlotWidth, itemSlotTall )

        gridPanel.entries = (gridPanel.entries or 0)+1
        local newGridTall = (math.ceil(gridPanel.entries/itemSlotsWide)*(itemSlotTall+itemSpacing))-itemSpacing
        if( gridPanel:GetTall() != newGridTall ) then
            gridPanel:SetTall( newGridTall )
            categoryPanel:SetTall( categoryHeaderTall+categoryHeaderSpacing+newGridTall )
        end
    end
end

function PANEL:Paint( w, h )
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
    draw.RoundedBox( 0, 0, 0, w, h, C.bg_darkest or Color(12,12,18) )
end

vgui.Register( "bricks_server_unboxingmenu_store", PANEL, "DPanel" )
