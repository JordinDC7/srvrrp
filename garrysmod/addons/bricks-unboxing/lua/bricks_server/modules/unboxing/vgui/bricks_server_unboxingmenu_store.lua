local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    self.panelTall = ScrH() * 0.65 - 40

    self.topBar = vgui.Create("DPanel", self)
    self.topBar:Dock(TOP)
    self.topBar:SetTall(64)
    self.topBar.Paint = function(self2, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2), true, true, false, false)

        -- subtle top highlight / bottom divider for a modern look
        surface.SetDrawColor(255, 255, 255, 8)
        surface.DrawRect(1, 1, math.max(0, w - 2), 1)

        surface.SetDrawColor(0, 0, 0, 30)
        surface.DrawRect(0, h - 1, w, 1)

        -- soft depth fade on the lower half (premium feel)
        surface.SetDrawColor(0, 0, 0, 18)
        surface.DrawRect(0, math.floor(h / 2), w, math.ceil(h / 2))
    end

    self.searchBar = vgui.Create("bricks_server_searchbar", self.topBar)
    self.searchBar:Dock(LEFT)
    self.searchBar:DockMargin(25, 12, 10, 12)
    self.searchBar:SetWide(math.Clamp(ScrW() * 0.2, 220, 420))
    self.searchBar:SetBackColor(BRICKS_SERVER.Func.GetTheme(1))
    self.searchBar:SetHighlightColor(BRICKS_SERVER.Func.GetTheme(0))
    self.searchBar.OnChange = function()
        self:RefreshStore()
    end

    local cartButton = vgui.Create("DButton", self.topBar)
    cartButton:SetSize(42, 42)
    cartButton:SetText("")

    local function PositionCartButton()
        if (not IsValid(cartButton) or not IsValid(self.topBar)) then return end
        local w, h = self.topBar:GetWide(), self.topBar:GetTall()
        cartButton:SetPos(w - 25 - cartButton:GetWide(), math.floor((h / 2) - (cartButton:GetTall() / 2)))
    end
    self.topBar.PerformLayout = function()
        PositionCartButton()
    end
    PositionCartButton()

    local cartAlpha = 0
    local cartBorderAlpha = 0
    local inboxMat = Material("bricks_server/unboxing_cart.png")

    cartButton.Paint = function(self2, w, h)
        if self2:IsDown() then
            cartAlpha = 0
            cartBorderAlpha = math.Clamp(cartBorderAlpha + 15, 0, 70)
        elseif self2:IsHovered() then
            cartAlpha = math.Clamp(cartAlpha + 8, 0, 45)
            cartBorderAlpha = math.Clamp(cartBorderAlpha + 8, 0, 55)
        else
            cartAlpha = math.Clamp(cartAlpha - 8, 0, 45)
            cartBorderAlpha = math.Clamp(cartBorderAlpha - 8, 0, 55)
        end

        draw.RoundedBox(10, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(1))

        surface.SetAlphaMultiplier(cartAlpha / 255)
        draw.RoundedBox(10, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(0))
        surface.SetAlphaMultiplier(1)

        if cartBorderAlpha > 0 then
            surface.SetDrawColor(255, 255, 255, cartBorderAlpha)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        surface.SetDrawColor(BRICKS_SERVER.Func.GetTheme(3))
        surface.SetMaterial(inboxMat)
        local iconSize = 22
        surface.DrawTexturedRect(math.floor((w / 2) - (iconSize / 2)), math.floor((h / 2) - (iconSize / 2)), iconSize, iconSize)
    end

    local function GetCartButtonPos()
        if (not IsValid(cartButton)) then return 0, 0 end
        return cartButton:GetPos()
    end

    cartButton.DoClick = function()
        if IsValid(cartButton.CartPanel) then
            cartButton.CartPanel:SizeTo(0, 0, 0.2, 0, -1, function()
                if IsValid(cartButton.CartPanel) then
                    cartButton.CartPanel:Remove()
                end
            end)
            return
        end

        local cartSlotTall = 52
        local triangleSizeW, triangleSizeH = 15, 10
        local triangleSpacing = (cartButton:GetWide() - triangleSizeW) / 2
        local bottomBarH = 52

        cartButton.CartPanel = vgui.Create("DPanel", self)
        cartButton.CartPanel:SetSize(0, 0)

        local buttonX, buttonY = GetCartButtonPos()
        cartButton.CartPanel:SetPos(buttonX + cartButton:GetWide(), buttonY + cartButton:GetTall() - 5)

        local targetW = math.Clamp(ScrW() * 0.16, 280, 420) -- slightly wider = less cramped totals + nicer cart rows
        local targetH = 40 + triangleSizeH + bottomBarH + (5 * cartSlotTall)

        local function RepositionCartPanel()
            if (not IsValid(cartButton.CartPanel) or not IsValid(cartButton)) then return end
            local bx, by = GetCartButtonPos()
            cartButton.CartPanel:SetPos(bx + cartButton:GetWide() - cartButton.CartPanel:GetWide(), by + cartButton:GetTall() - 5)
        end

        cartButton.CartPanel:SizeTo(targetW, targetH, 0.2, 0, -1, function()
            RepositionCartPanel()
        end)

        cartButton.CartPanel.Paint = function(self2, w, h)
            local x, y = self2:LocalToScreen(0, 0)

            local triangle = {
                { x = x + w - triangleSpacing - triangleSizeW, y = y + triangleSizeH },
                { x = x + w - triangleSpacing - (triangleSizeW / 2), y = y },
                { x = x + w - triangleSpacing, y = y + triangleSizeH }
            }

            BRICKS_SERVER.BSHADOWS.BeginShadow()
                draw.RoundedBox(10, x, y + triangleSizeH, w, h - triangleSizeH, BRICKS_SERVER.Func.GetTheme(2))
                surface.SetDrawColor(BRICKS_SERVER.Func.GetTheme(3))
                draw.NoTexture()
                surface.DrawPoly(triangle)
            BRICKS_SERVER.BSHADOWS.EndShadow(1, 4, 1, 255, 0, 0, false)

            -- Header strip
            draw.RoundedBoxEx(10, 0, triangleSizeH, w, 40, BRICKS_SERVER.Func.GetTheme(3), true, true, false, false)

            -- subtle divider
            surface.SetDrawColor(255, 255, 255, 10)
            surface.DrawRect(10, triangleSizeH + 1, math.max(0, w - 20), 1)
            surface.SetDrawColor(0, 0, 0, 25)
            surface.DrawRect(0, triangleSizeH + 39, w, 1)

            draw.SimpleText(BRICKS_SERVER.Func.L("unboxingCart"), "BRICKS_SERVER_Font25", 12, triangleSizeH + 20 - 1, BRICKS_SERVER.Func.GetTheme(6), 0, TEXT_ALIGN_CENTER)
        end

        cartButton.CartPanel.Think = function(self2)
            if not IsValid(cartButton) then
                self2:Remove()
                return
            end

            -- keep anchored to button if layout changes
            RepositionCartPanel()
        end

        cartButton.CartPanel.OnSizeChanged = function(self2)
            RepositionCartPanel()
        end

        local fonts = {
            "BRICKS_SERVER_Font23",
            "BRICKS_SERVER_Font22",
            "BRICKS_SERVER_Font21",
            "BRICKS_SERVER_Font20",
            "BRICKS_SERVER_Font17"
        }

        local function getFont(width, text)
            for _, font in ipairs(fonts) do
                surface.SetFont(font)
                local textX = surface.GetTextSize(text or "")
                if textX <= width then
                    return font
                end
            end
            return fonts[#fonts]
        end

        local cartTotalW = targetW - 20 - 25

        local cartBottomBar = vgui.Create("DPanel", cartButton.CartPanel)
        cartBottomBar:Dock(BOTTOM)
        cartBottomBar:SetTall(bottomBarH)

        local totalCosts = {}

        cartBottomBar.Paint = function(self2, w, h)
            draw.RoundedBoxEx(10, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(3), false, false, true, true)

            -- inner highlight
            surface.SetDrawColor(255, 255, 255, 8)
            surface.DrawRect(10, 1, math.max(0, w - 20), 1)

            local costString = ""
            for currency, value in pairs(totalCosts) do
                if costString == "" then
                    costString = BRICKS_SERVER.UNBOXING.Func.FormatCurrency(value, currency)
                else
                    costString = costString .. ", " .. BRICKS_SERVER.UNBOXING.Func.FormatCurrency(value, currency)
                end
            end

            local finalString = BRICKS_SERVER.Func.L("unboxingCartTotal", costString)
            draw.SimpleText(
                finalString,
                getFont(cartTotalW, finalString),
                12,
                h / 2 - 1,
                Color(BRICKS_SERVER.Func.GetTheme(6).r, BRICKS_SERVER.Func.GetTheme(6).g, BRICKS_SERVER.Func.GetTheme(6).b, 110),
                0,
                TEXT_ALIGN_CENTER
            )
        end

        surface.SetFont("BRICKS_SERVER_Font23")
        local purchaseText = BRICKS_SERVER.Func.L("unboxingPurchase")
        local textX = surface.GetTextSize(purchaseText)

        local cartCheckoutButton = vgui.Create("DButton", cartBottomBar)
        cartCheckoutButton:Dock(RIGHT)
        cartCheckoutButton:DockMargin(8, 8, 8, 8)
        cartCheckoutButton:SetWide(textX + 34)
        cartCheckoutButton:SetText("")

        local checkoutAlpha = 0
        cartCheckoutButton.Paint = function(self2, w, h)
            draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green)

            if (not self2:IsDown() and self2:IsHovered()) then
                checkoutAlpha = math.Clamp(checkoutAlpha + 10, 0, 200)
            else
                checkoutAlpha = math.Clamp(checkoutAlpha - 10, 0, 200)
            end

            surface.SetAlphaMultiplier(checkoutAlpha / 255)
            draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen)
            surface.SetAlphaMultiplier(1)

            BRICKS_SERVER.Func.DrawClickCircle(self2, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen, 8)

            draw.SimpleText(purchaseText, "BRICKS_SERVER_Font23", w / 2, h / 2 - 1, BRICKS_SERVER.Func.GetTheme(0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        cartCheckoutButton.DoClick = function()
            if (not BRS_UNBOXING_CART or table.Count(BRS_UNBOXING_CART) <= 0) then
                BRICKS_SERVER.Func.CreateTopNotification(BRICKS_SERVER.Func.L("unboxingCartEmpty"), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red)
                return
            end

            for currency, value in pairs(totalCosts) do
                if (not BRICKS_SERVER.UNBOXING.Func.CanAffordCurrency(LocalPlayer(), value, currency)) then
                    BRICKS_SERVER.Func.CreateTopNotification(BRICKS_SERVER.Func.L("unboxingCartCantAfford"), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red)
                    return
                end
            end

            net.Start("BRS.Net.PurchaseShopUnboxingItems")
                net.WriteUInt(table.Count(BRS_UNBOXING_CART), 8)

                for k, v in pairs(BRS_UNBOXING_CART) do
                    net.WriteUInt(k, 16)
                    net.WriteUInt(v, 8)
                end
            net.SendToServer()
        end

        cartTotalW = cartTotalW - cartCheckoutButton:GetWide()

        local cartScroll = vgui.Create("bricks_server_scrollpanel_bar", cartButton.CartPanel)
        cartScroll:Dock(FILL)
        cartScroll:DockMargin(0, 40 + triangleSizeH, 0, 0)
        cartScroll:SetBarBackColor(BRICKS_SERVER.Func.GetTheme(1))
        cartScroll:GetVBar():SetRounded(0)

        function cartButton.RefreshShoppingCartPanel()
            if (not IsValid(cartScroll)) then return end

            cartScroll:Clear()
            totalCosts = {}

            local itemCount = 0
            for k, v in pairs(BRS_UNBOXING_CART or {}) do
                local shopItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Store.Items[k] or {}

                if (not shopItemTable.GlobalKey) then continue end

                local itemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey(shopItemTable.GlobalKey)
                local actualItemTable = itemTable

                if (not actualItemTable) then
                    BRS_UNBOXING_CART[k] = nil
                    continue
                end

                local currency = shopItemTable.Currency or BRICKS_SERVER.UNBOXING.LUACFG.DefaultCurrency
                totalCosts[currency] = (totalCosts[currency] or 0) + ((shopItemTable.Price or 0) * v)

                itemCount = itemCount + 1
                local currentItemPos = itemCount

                local cartEntry = vgui.Create("DPanel", cartScroll)
                cartEntry:Dock(TOP)
                cartEntry:SetTall(cartSlotTall)
                cartEntry:DockMargin(8, 6, 8, 0)
                cartEntry.Paint = function(self2, w, h)
                    local rowCol = (currentItemPos % 2 == 0) and BRICKS_SERVER.Func.GetTheme(1) or BRICKS_SERVER.Func.GetTheme(2)
                    draw.RoundedBox(10, 0, 0, w, h, rowCol)

                    surface.SetDrawColor(255, 255, 255, 6)
                    surface.DrawRect(10, 1, math.max(0, w - 20), 1)

                    draw.SimpleText(
                        (actualItemTable.Name or BRICKS_SERVER.Func.L("unknown")),
                        "BRICKS_SERVER_Font23",
                        12,
                        h / 2,
                        Color(BRICKS_SERVER.Func.GetTheme(6).r, BRICKS_SERVER.Func.GetTheme(6).g, BRICKS_SERVER.Func.GetTheme(6).b, 165),
                        0,
                        TEXT_ALIGN_CENTER
                    )
                end

                local cartEntryDelete = vgui.Create("DButton", cartEntry)
                cartEntryDelete:Dock(RIGHT)
                cartEntryDelete:DockMargin(4, 0, 6, 0)
                cartEntryDelete:SetWide(cartEntry:GetTall() - 4)
                cartEntryDelete:SetText("")
                local deleteAlpha = 0
                local deleteMat = Material("bricks_server/delete.png")
                cartEntryDelete.Paint = function(self2, w, h)
                    if self2:IsDown() then
                        deleteAlpha = 255
                    elseif self2:IsHovered() and deleteAlpha < 75 then
                        deleteAlpha = math.Clamp(deleteAlpha + 8, 0, 255)
                    else
                        deleteAlpha = math.Clamp(deleteAlpha - 8, 0, 255)
                    end

                    local circleRadius = (w / 2) - 3

                    surface.SetAlphaMultiplier(deleteAlpha / 255)
                    BRICKS_SERVER.Func.DrawCircle(w / 2, h / 2, circleRadius, BRICKS_SERVER.Func.GetTheme(0))
                    surface.SetAlphaMultiplier(1)

                    if (deleteAlpha > 75) then
                        BRICKS_SERVER.Func.DrawCircle(w / 2, h / 2, ((deleteAlpha - 75) / 180) * (circleRadius), BRICKS_SERVER.Func.GetTheme(0))
                    end

                    surface.SetDrawColor(BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed)
                    surface.SetMaterial(deleteMat)
                    local iconSize = 20
                    surface.DrawTexturedRect((w / 2) - (iconSize / 2), (h / 2) - (iconSize / 2), iconSize, iconSize)
                end
                cartEntryDelete.DoClick = function()
                    BRS_UNBOXING_CART[k] = nil
                    self:RefreshShoppingCart()
                end

                local amountH = 32

                local cartEntryAmount = vgui.Create("DPanel", cartEntry)
                cartEntryAmount:Dock(RIGHT)
                cartEntryAmount:DockMargin(0, 0, 6, 0)
                cartEntryAmount:SetWide(102)
                cartEntryAmount.Paint = function(self2, w, h)
                    draw.RoundedBox(16, 0, (h / 2) - (amountH / 2), w, amountH, BRICKS_SERVER.Func.GetTheme(((currentItemPos % 2 == 0) and 2) or 1))

                    draw.SimpleText(
                        tostring(v),
                        "BRICKS_SERVER_Font17",
                        w / 2,
                        h / 2,
                        Color(BRICKS_SERVER.Func.GetTheme(6).r, BRICKS_SERVER.Func.GetTheme(6).g, BRICKS_SERVER.Func.GetTheme(6).b, 90),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER
                    )
                end

                local cartEntryAmountAdd = vgui.Create("DButton", cartEntryAmount)
                cartEntryAmountAdd:Dock(RIGHT)
                cartEntryAmountAdd:SetWide(amountH)
                cartEntryAmountAdd:SetText("")
                local addAlpha = 0
                local addMat = Material("bricks_server/add_16.png")
                cartEntryAmountAdd.Paint = function(self2, w, h)
                    if self2:IsDown() then
                        addAlpha = 255
                    elseif self2:IsHovered() and addAlpha < 75 then
                        addAlpha = math.Clamp(addAlpha + 8, 0, 255)
                    else
                        addAlpha = math.Clamp(addAlpha - 8, 0, 255)
                    end

                    surface.SetAlphaMultiplier(addAlpha / 255)
                    BRICKS_SERVER.Func.DrawCircle(w / 2, h / 2, w / 2, BRICKS_SERVER.Func.GetTheme(0))
                    surface.SetAlphaMultiplier(1)

                    if (addAlpha > 75) then
                        BRICKS_SERVER.Func.DrawCircle(w / 2, h / 2, ((addAlpha - 75) / 180) * (w / 2), BRICKS_SERVER.Func.GetTheme(0))
                    end

                    surface.SetDrawColor(BRICKS_SERVER.Func.GetTheme(3))
                    surface.SetMaterial(addMat)
                    local iconSize = 14
                    surface.DrawTexturedRect((w / 2) - (iconSize / 2), (h / 2) - (iconSize / 2), iconSize, iconSize)
                end
                cartEntryAmountAdd.DoClick = function()
                    BRS_UNBOXING_CART[k] = (BRS_UNBOXING_CART[k] or 0) + 1
                    self:RefreshShoppingCart()
                end

                local cartEntryAmountMinus = vgui.Create("DButton", cartEntryAmount)
                cartEntryAmountMinus:Dock(LEFT)
                cartEntryAmountMinus:SetWide(amountH)
                cartEntryAmountMinus:SetText("")
                local minusAlpha = 0
                local minusMat = Material("bricks_server/minus_16.png")
                cartEntryAmountMinus.Paint = function(self2, w, h)
                    if self2:IsDown() then
                        minusAlpha = 255
                    elseif self2:IsHovered() and minusAlpha < 75 then
                        minusAlpha = math.Clamp(minusAlpha + 8, 0, 255)
                    else
                        minusAlpha = math.Clamp(minusAlpha - 8, 0, 255)
                    end

                    surface.SetAlphaMultiplier(minusAlpha / 255)
                    BRICKS_SERVER.Func.DrawCircle(w / 2, h / 2, w / 2, BRICKS_SERVER.Func.GetTheme(0))
                    surface.SetAlphaMultiplier(1)

                    if (minusAlpha > 75) then
                        BRICKS_SERVER.Func.DrawCircle(w / 2, h / 2, ((minusAlpha - 75) / 180) * (w / 2), BRICKS_SERVER.Func.GetTheme(0))
                    end

                    surface.SetDrawColor(BRICKS_SERVER.Func.GetTheme(3))
                    surface.SetMaterial(minusMat)
                    local iconSize = 14
                    surface.DrawTexturedRect((w / 2) - (iconSize / 2), (h / 2) - (iconSize / 2), iconSize, iconSize)
                end
                cartEntryAmountMinus.DoClick = function()
                    BRS_UNBOXING_CART[k] = (BRS_UNBOXING_CART[k] or 1) - 1

                    if (BRS_UNBOXING_CART[k] <= 0) then
                        BRS_UNBOXING_CART[k] = nil
                    end

                    self:RefreshShoppingCart()
                end
            end

            -- empty state inside cart
            if itemCount <= 0 then
                local empty = vgui.Create("DPanel", cartScroll)
                empty:Dock(TOP)
                empty:DockMargin(10, 10, 10, 0)
                empty:SetTall(64)
                empty.Paint = function(self2, w, h)
                    draw.RoundedBox(10, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(1))
                    draw.SimpleText(BRICKS_SERVER.Func.L("unboxingCartEmpty"), "BRICKS_SERVER_Font20", w / 2, h / 2 - 1, BRICKS_SERVER.Func.GetTheme(6, 90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end

        cartButton.RefreshShoppingCartPanel()
    end

    function self:RefreshShoppingCart()
        if (cartButton.RefreshShoppingCartPanel) then
            cartButton.RefreshShoppingCartPanel()
        end

        if (IsValid(cartButton.itemsNotification)) then
            cartButton.itemsNotification:Remove()
        end

        if (table.Count(BRS_UNBOXING_CART or {}) > 0) then
            local extraDistance = 4
            local buttonX, buttonY = GetCartButtonPos()

            cartButton.itemsNotification = vgui.Create("DPanel", self.topBar)
            cartButton.itemsNotification:SetSize(16, 16)
            cartButton.itemsNotification:SetPos(
                buttonX + cartButton:GetWide() - (cartButton.itemsNotification:GetWide() / 2) - extraDistance,
                buttonY + cartButton:GetTall() - (cartButton.itemsNotification:GetTall() / 2) - extraDistance
            )
            cartButton.itemsNotification.Paint = function(self2, w, h)
                -- base dot
                surface.SetDrawColor(207, 72, 72)
                draw.NoTexture()
                BRICKS_SERVER.Func.DrawCircle(w / 2, h / 2, w / 2, 45)

                -- highlight
                surface.SetDrawColor(255, 255, 255, 35)
                BRICKS_SERVER.Func.DrawCircle(w / 2, h / 2, (w / 2) - 2, 45)
            end
        end
    end
    self:RefreshShoppingCart()

    hook.Add("BRS.Hooks.RefreshUnboxingCart", self, function()
        self:RefreshShoppingCart()

        if (IsValid(cartButton) and IsValid(cartButton.CartPanel)) then
            cartButton.CartPanel:SizeTo(0, 0, 0.2, 0, -1, function()
                if IsValid(cartButton.CartPanel) then
                    cartButton.CartPanel:Remove()
                end
            end)
        end
    end)

    hook.Add("BRS.Hooks.ConfigReceived", self, function()
        self:RefreshStore()
    end)

    self.scrollPanel = vgui.Create("bricks_server_scrollpanel_bar", self)
    self.scrollPanel:Dock(FILL)
    self.scrollPanel:DockMargin(25, 20, 25, 25)
    self.scrollPanel.Paint = function(self2, w, h)
        -- optional background pass for depth
    end

    self.scrollPanelWide = self.panelWide - 50 - 20

    self:RefreshStore()
end

function PANEL:AddStoreItem(storeTable, itemKey, grid, itemWidth, itemHeight)
    if (not storeTable or not storeTable.GlobalKey) then return end

    local function addToCart()
        BRS_UNBOXING_CART = BRS_UNBOXING_CART or {}
        BRS_UNBOXING_CART[itemKey] = (BRS_UNBOXING_CART[itemKey] or 0) + 1
        self:RefreshShoppingCart()

        BRICKS_SERVER.Func.CreateTopNotification(BRICKS_SERVER.Func.L("unboxingCartItemAdded"), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green)
    end

    local slotBack = grid:Add("bricks_server_unboxingmenu_itemslot")
    slotBack:SetSize(itemWidth, itemHeight)
    slotBack:FillPanel(storeTable.GlobalKey, 1, function()
        local isCase = string.StartWith(storeTable.GlobalKey or "", "CASE_")
        local isKey = string.StartWith(storeTable.GlobalKey or "", "KEY_")

        if (not isCase and not isKey) then
            addToCart()
        else
            local itemKeyNum = tonumber(string.Replace(storeTable.GlobalKey, (isCase and "CASE_") or "KEY_", ""))
            self.popoutPanel = vgui.Create((isCase and "bricks_server_unboxingmenu_caseview_popup") or "bricks_server_unboxingmenu_keyview_popup", self)
            self.popoutPanel:SetPos(0, 0)
            self.popoutPanel:SetSize(self.panelWide, self.panelTall)
            self.popoutPanel:CreatePopout()
            self.popoutPanel:FillPanel(itemKeyNum, function()
                addToCart()

                if (not IsValid(self.popoutPanel.popoutPanel)) then return end
                self.popoutPanel.popoutPanel.ClosePopout()
            end)
        end
    end)

    slotBack:AddTopInfo(BRICKS_SERVER.UNBOXING.Func.FormatCurrency(storeTable.Price or 0, storeTable.Currency))

    if (storeTable.Group) then
        local groupTable = {}
        for _, val in pairs(BRICKS_SERVER.CONFIG.GENERAL.Groups or {}) do
            if (val[1] == storeTable.Group) then
                groupTable = val
                break
            end
        end

        slotBack:AddTopInfo(storeTable.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme(6))
    end
end

function PANEL:RefreshStore()
    if (not IsValid(self.scrollPanel)) then return end
    self.scrollPanel:Clear()

    local storeConfig = BRICKS_SERVER.CONFIG.UNBOXING.Store or {}
    local storeItemsConfig = storeConfig.Items or {}

    surface.SetFont("BRICKS_SERVER_Font33")
    local _, featuredY = surface.GetTextSize(BRICKS_SERVER.Func.L("unboxingFeaturedHeader"))

    if (storeConfig.Featured and istable(storeConfig.Featured) and BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount and BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount > 0) then
        self.featuredHeader = vgui.Create("DPanel", self.scrollPanel)
        self.featuredHeader:Dock(TOP)
        self.featuredHeader:DockMargin(0, 0, 10, 8)
        self.featuredHeader:SetTall(featuredY + 2)
        self.featuredHeader.Paint = function(self2, w, h)
            draw.SimpleText(BRICKS_SERVER.Func.L("unboxingFeaturedHeader"), "BRICKS_SERVER_Font33", 0, 0, BRICKS_SERVER.Func.GetTheme(6), 0, 0)

            -- tiny subtitle line for visual polish (no localization dependency)
            surface.SetDrawColor(BRICKS_SERVER.Func.GetTheme(6, 20))
            surface.DrawRect(0, h - 1, math.min(w, 220), 1)
        end

        self.featuredBack = vgui.Create("DPanel", self.scrollPanel)
        self.featuredBack:Dock(TOP)
        self.featuredBack:DockMargin(0, 0, 10, 4)
        self.featuredBack:SetTall(ScrH() * 0.35)
        self.featuredBack.Paint = function(self2, w, h)
            -- soft backing layer for featured section
            draw.RoundedBox(10, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2, 45))
            surface.SetDrawColor(255, 255, 255, 8)
            surface.DrawRect(10, 1, math.max(0, w - 20), 1)
        end

        local featuredAmount = math.max(1, BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount)
        local featuredSpacing = 10
        local featuredWide = (self.scrollPanelWide - ((featuredAmount - 1) * featuredSpacing)) / featuredAmount

        self.featuredGrid = vgui.Create("DIconLayout", self.featuredBack)
        self.featuredGrid:Dock(FILL)
        self.featuredGrid:SetSpaceY(featuredSpacing)
        self.featuredGrid:SetSpaceX(featuredSpacing)

        for i = 1, featuredAmount do
            self:AddStoreItem((storeItemsConfig[storeConfig.Featured[i] or 0] or {}), storeConfig.Featured[i], self.featuredGrid, featuredWide, self.featuredBack:GetTall())
        end
    end

    local itemSpacing = 6
    local wantedItemSize = 200
    local itemSlotsWide = math.max(1, math.floor(self.scrollPanelWide / wantedItemSize))
    local itemSlotWidth = (self.scrollPanelWide - ((itemSlotsWide - 1) * itemSpacing)) / itemSlotsWide
    local itemSlotTall = itemSlotWidth * 1.25

    surface.SetFont("BRICKS_SERVER_Font30")
    local _, headerY = surface.GetTextSize("CATEGORY")

    local sortedCategories = {}
    for k, v in pairs(storeConfig.Categories or {}) do
        table.insert(sortedCategories, { k, v })
    end

    table.sort(sortedCategories, function(a, b)
        return (((a or {})[2] or {}).SortOrder or 1000) < (((b or {})[2] or {}).SortOrder or 1000)
    end)

    self.categories = {}
    local categoryHeaderTall, categoryHeaderSpacing = headerY, 6

    for _, val in pairs(sortedCategories) do
        local k, v = val[1], val[2]

        self.categories[k] = vgui.Create("DPanel", self.scrollPanel)
        self.categories[k]:Dock(TOP)
        self.categories[k]:DockMargin(0, 20, 10, 0)
        self.categories[k]:DockPadding(0, categoryHeaderTall + categoryHeaderSpacing + 4, 0, 0)
        self.categories[k]:SetTall(categoryHeaderTall)

        self.categories[k].Paint = function(self2, w, h)
            draw.SimpleText(string.upper(v.Name or "CATEGORY"), "BRICKS_SERVER_Font30", 0, 0, BRICKS_SERVER.Func.GetTheme(6), 0, 0)

            -- modern thin divider accent
            local lineY = categoryHeaderTall + categoryHeaderSpacing - 2
            surface.SetDrawColor(BRICKS_SERVER.Func.GetTheme(6, 18))
            surface.DrawRect(0, lineY, w, 1)
        end

        self.categories[k].grid = vgui.Create("DIconLayout", self.categories[k])
        self.categories[k].grid:Dock(TOP)
        self.categories[k].grid:SetTall(0)
        self.categories[k].grid:SetSpaceY(itemSpacing)
        self.categories[k].grid:SetSpaceX(itemSpacing)
    end

    local sortedStoreItems = {}

    local searchValue = ""
    if IsValid(self.searchBar) and self.searchBar.GetValue then
        searchValue = string.Trim(tostring(self.searchBar:GetValue() or ""))
    end
    local searchLower = string.lower(searchValue)

    for k, v in pairs(storeItemsConfig) do
        local itemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey(v.GlobalKey)
        local actualItemTable = itemTable

        if (not actualItemTable) then
            continue
        end

        local itemName = tostring(actualItemTable.Name or "")
        if (searchLower ~= "" and not string.find(string.lower(itemName), searchLower, 1, true)) then
            continue
        end

        sortedStoreItems[#sortedStoreItems + 1] = table.Copy(v)
        sortedStoreItems[#sortedStoreItems].Key = k
    end

    table.sort(sortedStoreItems, function(a, b)
        return ((a or {}).SortOrder or 1000) < ((b or {}).SortOrder or 1000)
    end)

    local categoryCounts = {}

    for _, v in ipairs(sortedStoreItems) do
        local categoryPanel = self.categories[v.Category or 0]

        if (not IsValid(categoryPanel)) then
            print("[Brick's Unboxing] ERROR MISSING ITEM CATEGORY!")
            continue
        end

        local gridPanel = categoryPanel.grid
        if (not IsValid(gridPanel)) then continue end

        self:AddStoreItem(v, v.Key, gridPanel, itemSlotWidth, itemSlotTall)

        gridPanel.entries = (gridPanel.entries or 0) + 1
        categoryCounts[v.Category or 0] = (categoryCounts[v.Category or 0] or 0) + 1

        local rows = math.ceil(gridPanel.entries / itemSlotsWide)
        local newGridTall = (rows * (itemSlotTall + itemSpacing)) - itemSpacing
        newGridTall = math.max(0, newGridTall)

        if (gridPanel:GetTall() ~= newGridTall) then
            gridPanel:SetTall(newGridTall)
            categoryPanel:SetTall(categoryHeaderTall + categoryHeaderSpacing + 4 + newGridTall)
        end
    end

    -- Hide empty categories so the page feels cleaner during search
    for categoryID, panel in pairs(self.categories or {}) do
        local count = categoryCounts[categoryID] or 0
        panel:SetVisible(count > 0)
        if count <= 0 then
            panel:SetTall(0)
        end
    end

    -- Empty search/store state
    if (#sortedStoreItems <= 0) then
        local emptyState = vgui.Create("DPanel", self.scrollPanel)
        emptyState:Dock(TOP)
        emptyState:DockMargin(0, 20, 10, 0)
        emptyState:SetTall(100)
        emptyState.Paint = function(self2, w, h)
            draw.RoundedBox(10, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))
            draw.SimpleText("No items found", "BRICKS_SERVER_Font25", 20, h / 2 - 10, BRICKS_SERVER.Func.GetTheme(6), 0, TEXT_ALIGN_CENTER)
            draw.SimpleText("Try a different search.", "BRICKS_SERVER_Font18", 20, h / 2 + 14, BRICKS_SERVER.Func.GetTheme(6, 60), 0, TEXT_ALIGN_CENTER)
        end
    end
end

function PANEL:Paint(w, h)

end

vgui.Register("bricks_server_unboxingmenu_store", PANEL, "DPanel")