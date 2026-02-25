local PANEL = {}

function PANEL:Init()
    
end

function PANEL:FillPanel()
    self.panelTall = ScrH()*0.65-40

    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )
    end 

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( ScrW()*0.2 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:RefreshStore()
    end

    local cartButton = vgui.Create( "DButton", self.topBar )
    cartButton:SetSize( 40, 40 )
    cartButton:SetPos( 25+self.panelWide-50-cartButton:GetWide(), (self.topBar:GetTall()/2)-(cartButton:GetTall()/2) )
    cartButton:SetText( "" )
    local Alpha = 0
    local inboxMat = Material( "bricks_server/unboxing_cart.png" )
    cartButton.Paint = function( self2, w, h )
        if( self2:IsDown() ) then
            Alpha = 0
        elseif( self2:IsHovered() ) then
            Alpha = math.Clamp( Alpha+5, 0, 35 )
        else
            Alpha = math.Clamp( Alpha-5, 0, 35 )
        end
    
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        surface.SetAlphaMultiplier( Alpha/255 )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
        surface.SetAlphaMultiplier( 1 )
    
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
        surface.SetMaterial( inboxMat )
        local iconSize = 24
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    local buttonX, buttonY = cartButton:GetPos()
    cartButton.DoClick = function()
        if( IsValid( cartButton.CartPanel ) ) then 
            cartButton.CartPanel:SizeTo( 0, 0, 0.2, 0, -1, function()
                cartButton.CartPanel:Remove()
            end )
            return
        end

        local cartSlotTall = 50
        local triangleSizeW, triangleSizeH = 15, 10
        local triangleSpacing = (cartButton:GetWide()-triangleSizeW)/2
        local bottomBarH = 50

        cartButton.CartPanel = vgui.Create( "DPanel", self )
        cartButton.CartPanel:SizeTo( ScrW()*0.15, 40+triangleSizeH+bottomBarH+(5*cartSlotTall), 0.2, 0, -1, function()
            cartButton.CartPanel:SetPos( self.panelWide-50+25-cartButton.CartPanel:GetWide(), buttonY+cartButton:GetTall()-5 )
        end )
        cartButton.CartPanel:SetPos( self.panelWide-50+25-cartButton.CartPanel:GetWide(), buttonY+cartButton:GetTall()-5 )
        cartButton.CartPanel.Paint = function( self2, w, h )
            local x, y = self2:LocalToScreen( 0, 0 )

            local triangle = {
                { x = x+w-triangleSpacing-triangleSizeW, y = y+triangleSizeH },
                { x = x+w-triangleSpacing-(triangleSizeW/2), y = y },
                { x = x+w-triangleSpacing, y = y+triangleSizeH }
            }
        
            BRICKS_SERVER.BSHADOWS.BeginShadow()
            draw.RoundedBox( 8, x, y+triangleSizeH, w, h-triangleSizeH, BRICKS_SERVER.Func.GetTheme( 2 ) )	
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
            draw.NoTexture()
            surface.DrawPoly( triangle )
            BRICKS_SERVER.BSHADOWS.EndShadow(1, 4, 1, 255, 0, 0, false )

            draw.RoundedBoxEx( 8, 0, triangleSizeH, w, 40, BRICKS_SERVER.Func.GetTheme( 3 ), true, true, false, false )
        
            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingCart" ), "BRICKS_SERVER_Font25", 10, triangleSizeH+40/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        end
        cartButton.CartPanel.Think = function( self2 )
            if( not IsValid( cartButton ) ) then 
                self2:Remove()
            end
        end
        cartButton.CartPanel.OnSizeChanged = function( self2 )
            self2:SetPos( self.panelWide-50+25-cartButton.CartPanel:GetWide(), buttonY+cartButton:GetTall()-5 )
        end

        local fonts = {
            "BRICKS_SERVER_Font23",
            "BRICKS_SERVER_Font22",
            "BRICKS_SERVER_Font21",
            "BRICKS_SERVER_Font20",
            "BRICKS_SERVER_Font17"
        }

        local function getFont( width, text )
            for k, v in ipairs( fonts ) do
                surface.SetFont( v )
                local textX, textY = surface.GetTextSize( text )

                if( textX <= width ) then
                    return v
                end
            end

            return fonts[#fonts]
        end

        local cartTotalW = ScrW()*0.15-20-25

        local cartBottomBar = vgui.Create( "DPanel", cartButton.CartPanel )
        cartBottomBar:Dock( BOTTOM )
        cartBottomBar:SetTall( bottomBarH )
        local totalCosts = {}
        cartBottomBar.Paint = function( self2, w, h )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, false, true, true )

            local costString = ""
            for k, v in pairs( totalCosts ) do
                if( costString == "" ) then
                    costString = BRICKS_SERVER.UNBOXING.Func.FormatCurrency( v, k )
                else
                    costString = costString .. ", " .. BRICKS_SERVER.UNBOXING.Func.FormatCurrency( v, k )
                end
            end

            local finalString = BRICKS_SERVER.Func.L( "unboxingCartTotal", costString )
            draw.SimpleText( finalString, getFont( cartTotalW, finalString ), 10, h/2-1, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 100 ), 0, TEXT_ALIGN_CENTER )
        end

        surface.SetFont( "BRICKS_SERVER_Font23" )
        local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingPurchase" ) )

        local cartCheckoutButton = vgui.Create( "DButton", cartBottomBar )
        cartCheckoutButton:Dock( RIGHT )
        cartCheckoutButton:DockMargin( 8, 8, 8, 8 )
        cartCheckoutButton:SetWide( textX+30 )
        cartCheckoutButton:SetText( "" )
        local alpha = 0
        cartCheckoutButton.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
    
            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 200 )
            else
                alpha = math.Clamp( alpha-10, 0, 200 )
            end

            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen, 8 )

            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingPurchase" ), "BRICKS_SERVER_Font23", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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
                    net.WriteUInt( v, 8 )
                end
            net.SendToServer()
        end

        cartTotalW = cartTotalW-cartCheckoutButton:GetWide()

        local cartScroll = vgui.Create( "bricks_server_scrollpanel_bar", cartButton.CartPanel )
        cartScroll:Dock( FILL )
        cartScroll:DockMargin( 0, 40+triangleSizeH, 0, 0 )
        cartScroll:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
        cartScroll:GetVBar():SetRounded( 0 )

        function cartButton.RefreshShoppingCartPanel()
            if( not IsValid( cartScroll ) ) then return end

            cartScroll:Clear()

            totalCosts = {}

            local itemCount = 0
            for k, v in pairs( BRS_UNBOXING_CART or {} ) do
                local shopItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Store.Items[k] or {}

                if( not shopItemTable.GlobalKey ) then continue end
                local itemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( shopItemTable.GlobalKey )

                if( not itemTable ) then 
                    BRS_UNBOXING_CART[k] = nil
                    continue 
                end

                local currency = shopItemTable.Currency or BRICKS_SERVER.UNBOXING.LUACFG.DefaultCurrency
                totalCosts[currency] = (totalCosts[currency] or 0)+((shopItemTable.Price or 0)*v)

                itemCount = itemCount+1
                local currentItemPos = itemCount

                local cartEntry = vgui.Create( "DPanel", cartScroll )
                cartEntry:Dock( TOP )
                cartEntry:SetTall( cartSlotTall )
                cartEntry.Paint = function( self2, w, h )
                    if( currentItemPos % 2 == 0 ) then
                        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
                        surface.DrawRect( 0, 0, w, h )
                    end

                    draw.SimpleText( (itemTable.Name or BRICKS_SERVER.Func.L( "unknown" )), "BRICKS_SERVER_Font23", 10, h/2, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 150 ), 0, TEXT_ALIGN_CENTER )
                end

                local cartEntryDelete = vgui.Create( "DButton", cartEntry )
                cartEntryDelete:Dock( RIGHT )
                cartEntryDelete:SetWide( cartEntry:GetTall() )
                cartEntryDelete:SetText( "" )
                local alpha = 0
                local deleteMat = Material( "bricks_server/delete.png" )
                cartEntryDelete.Paint = function( self2, w, h )
                    if( self2:IsDown() ) then
                        alpha = 255
                    elseif( self2:IsHovered() and alpha < 75 ) then
                        alpha = math.Clamp( alpha+5, 0, 255 )
                    else
                        alpha = math.Clamp( alpha-5, 0, 255 )
                    end

                    local circleRadius = (w/2)-3
                
                    surface.SetAlphaMultiplier( alpha/255 )
                    BRICKS_SERVER.Func.DrawCircle( w/2, h/2, circleRadius, BRICKS_SERVER.Func.GetTheme( 0 ) )
                    surface.SetAlphaMultiplier( 1 )

                    if( alpha > 75 ) then
                        BRICKS_SERVER.Func.DrawCircle( w/2, h/2, ((alpha-75)/180)*(circleRadius), BRICKS_SERVER.Func.GetTheme( 0 ) )
                    end
                
                    surface.SetDrawColor( BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
                    surface.SetMaterial( deleteMat )
                    local iconSize = 24
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end
                cartEntryDelete.DoClick = function()
                    BRS_UNBOXING_CART[k] = nil
                    self:RefreshShoppingCart()
                end

                surface.SetFont( "BRICKS_SERVER_Font17" )
                local textX, textY = surface.GetTextSize( v )
                local amountH = 32

                local cartEntryAmount = vgui.Create( "DPanel", cartEntry )
                cartEntryAmount:Dock( RIGHT )
                cartEntryAmount:SetWide( 100 )
                cartEntryAmount.Paint = function( self2, w, h )
                    draw.RoundedBox( 16, 0, (h/2)-(amountH/2), w, amountH, BRICKS_SERVER.Func.GetTheme( ((currentItemPos % 2 == 0) and 2) or 1 ) )

                    draw.SimpleText( v, "BRICKS_SERVER_Font17", w/2, h/2, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                local cartEntryAmountAdd = vgui.Create( "DButton", cartEntryAmount )
                cartEntryAmountAdd:Dock( RIGHT )
                cartEntryAmountAdd:SetWide( amountH )
                cartEntryAmountAdd:SetText( "" )
                local alpha = 0
                local addMat = Material( "bricks_server/add_16.png" )
                cartEntryAmountAdd.Paint = function( self2, w, h )
                    if( self2:IsDown() ) then
                        alpha = 255
                    elseif( self2:IsHovered() and alpha < 75 ) then
                        alpha = math.Clamp( alpha+5, 0, 255 )
                    else
                        alpha = math.Clamp( alpha-5, 0, 255 )
                    end
                
                    surface.SetAlphaMultiplier( alpha/255 )
                    BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2, BRICKS_SERVER.Func.GetTheme( 0 ) )
                    surface.SetAlphaMultiplier( 1 )

                    if( alpha > 75 ) then
                        BRICKS_SERVER.Func.DrawCircle( w/2, h/2, ((alpha-75)/180)*(w/2), BRICKS_SERVER.Func.GetTheme( 0 ) )
                    end
                
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                    surface.SetMaterial( addMat )
                    local iconSize = 16
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end
                cartEntryAmountAdd.DoClick = function()
                    BRS_UNBOXING_CART[k] = BRS_UNBOXING_CART[k]+1
                    self:RefreshShoppingCart()
                end

                local cartEntryAmountMinus = vgui.Create( "DButton", cartEntryAmount )
                cartEntryAmountMinus:Dock( LEFT )
                cartEntryAmountMinus:SetWide( amountH )
                cartEntryAmountMinus:SetText( "" )
                local alpha = 0
                local minusMat = Material( "bricks_server/minus_16.png" )
                cartEntryAmountMinus.Paint = function( self2, w, h )
                    if( self2:IsDown() ) then
                        alpha = 255
                    elseif( self2:IsHovered() and alpha < 75 ) then
                        alpha = math.Clamp( alpha+5, 0, 255 )
                    else
                        alpha = math.Clamp( alpha-5, 0, 255 )
                    end
                
                    surface.SetAlphaMultiplier( alpha/255 )
                    BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2, BRICKS_SERVER.Func.GetTheme( 0 ) )
                    surface.SetAlphaMultiplier( 1 )

                    if( alpha > 75 ) then
                        BRICKS_SERVER.Func.DrawCircle( w/2, h/2, ((alpha-75)/180)*(w/2), BRICKS_SERVER.Func.GetTheme( 0 ) )
                    end
                
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                    surface.SetMaterial( minusMat )
                    local iconSize = 16
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end
                cartEntryAmountMinus.DoClick = function()
                    BRS_UNBOXING_CART[k] = BRS_UNBOXING_CART[k]-1

                    if( BRS_UNBOXING_CART[k] <= 0 ) then
                        BRS_UNBOXING_CART[k] = nil
                    end

                    self:RefreshShoppingCart()
                end
            end
        end
        cartButton.RefreshShoppingCartPanel()
    end

    function self:RefreshShoppingCart()
        if( cartButton.RefreshShoppingCartPanel ) then
            cartButton.RefreshShoppingCartPanel()
        end
        
        if( IsValid( cartButton.itemsNotification ) ) then
            cartButton.itemsNotification:Remove()
        end

        if( table.Count( BRS_UNBOXING_CART or {} ) > 0 ) then
            local extraDistance = 4

            cartButton.itemsNotification = vgui.Create( "DPanel", self )
            cartButton.itemsNotification:SetSize( 14, 14 )
            cartButton.itemsNotification:SetPos( self.panelWide-50+25-(cartButton.itemsNotification:GetWide()/2)-extraDistance, buttonY+cartButton:GetTall()-(cartButton.itemsNotification:GetTall()/2)-extraDistance )
            cartButton.itemsNotification.Paint = function( self2, w, h )
                surface.SetDrawColor( 207, 72, 72 )
                draw.NoTexture()
                BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2, 45 )		
            end
        end
    end
    self:RefreshShoppingCart()

    hook.Add( "BRS.Hooks.RefreshUnboxingCart", self, function()
        self:RefreshShoppingCart()

        if( IsValid( cartButton ) and IsValid( cartButton.CartPanel ) ) then 
            cartButton.CartPanel:SizeTo( 0, 0, 0.2, 0, -1, function()
                cartButton.CartPanel:Remove()
            end )
        end
    end )

    hook.Add( "BRS.Hooks.ConfigReceived", self, function()
        self:RefreshStore()
    end )

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self, w, h ) end 

    self.scrollPanelWide = self.panelWide-50-20

    self:RefreshStore()
end

function PANEL:AddStoreItem( storeTable, itemKey, grid, itemWidth, itemHeight )
    if( not storeTable or not storeTable.GlobalKey ) then return end

    local function addToCart()
        BRS_UNBOXING_CART = BRS_UNBOXING_CART or {}
        BRS_UNBOXING_CART[itemKey] = (BRS_UNBOXING_CART[itemKey] or 0)+1
        self:RefreshShoppingCart()

        BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "unboxingCartItemAdded" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
    end

    local slotBack = grid:Add( "bricks_server_unboxingmenu_itemslot" )
    slotBack:SetSize( itemWidth, itemHeight )
    slotBack:FillPanel( storeTable.GlobalKey, 1, function()
        local isCase, isKey = string.StartWith( storeTable.GlobalKey, "CASE_" ), string.StartWith( storeTable.GlobalKey, "KEY_" )
        if( not isCase and not isKey ) then
            addToCart()
        else
            local itemKey = tonumber( string.Replace( storeTable.GlobalKey, (isCase and "CASE_") or "KEY_", "" ) )
            self.popoutPanel = vgui.Create( (isCase and "bricks_server_unboxingmenu_caseview_popup") or "bricks_server_unboxingmenu_keyview_popup", self )
            self.popoutPanel:SetPos( 0, 0 )
            self.popoutPanel:SetSize( self.panelWide, self.panelTall )
            self.popoutPanel:CreatePopout()
            self.popoutPanel:FillPanel( itemKey, function()
                addToCart()

                if( not IsValid( self.popoutPanel.popoutPanel ) ) then return end
                self.popoutPanel.popoutPanel.ClosePopout()
            end )
        end
    end )
    slotBack:AddTopInfo( BRICKS_SERVER.UNBOXING.Func.FormatCurrency( storeTable.Price or 0, storeTable.Currency ) )

    if( storeTable.Group ) then
        local groupTable = {}
        for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
            if( val[1] == storeTable.Group ) then
                groupTable = val
                break
            end
        end

        slotBack:AddTopInfo( storeTable.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme( 6 ) )
    end
end

function PANEL:RefreshStore()
    self.scrollPanel:Clear()
    
    local storeConfig = BRICKS_SERVER.CONFIG.UNBOXING.Store
    local storeItemsConfig = storeConfig.Items

    surface.SetFont( "BRICKS_SERVER_Font33" )
    local featuredX, featuredY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingFeaturedHeader" ) )

    if( storeConfig.Featured ) then
        self.featuredHeader = vgui.Create( "DPanel", self.scrollPanel )
        self.featuredHeader:Dock( TOP )
        self.featuredHeader:DockMargin( 0, 0, 10, 5 )
        self.featuredHeader:SetTall( featuredY )
        self.featuredHeader.Paint = function( self2, w, h ) 
            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingFeaturedHeader" ), "BRICKS_SERVER_Font33", 0, 0, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
        end

        self.featuredBack = vgui.Create( "DPanel", self.scrollPanel )
        self.featuredBack:Dock( TOP )
        self.featuredBack:DockMargin( 0, 0, 10, 0 )
        self.featuredBack:SetTall( ScrH()*0.35 )
        self.featuredBack.Paint = function( self2, w, h ) end

        local featuredSpacing = 10
        local featuredWide = (self.scrollPanelWide-((BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount-1)*featuredSpacing))/BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount
        
        self.featuredGrid = vgui.Create( "DIconLayout", self.featuredBack )
        self.featuredGrid:Dock( FILL )
        self.featuredGrid:SetSpaceY( featuredSpacing )
        self.featuredGrid:SetSpaceX( featuredSpacing )

        for i = 1, BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount do
            self:AddStoreItem( (storeItemsConfig[storeConfig.Featured[i] or 0] or {}), storeConfig.Featured[i], self.featuredGrid, featuredWide, self.featuredBack:GetTall() )
        end
    end

    local itemSpacing = 5
    local wantedItemSize = 200
    local itemSlotsWide = math.floor( self.scrollPanelWide/wantedItemSize )
    local itemSlotWidth = (self.scrollPanelWide-((itemSlotsWide-1)*itemSpacing))/itemSlotsWide
    local itemSlotTall = itemSlotWidth*1.25

    surface.SetFont( "BRICKS_SERVER_Font30" )
    local headerX, headerY = surface.GetTextSize( "CATEGORY" )

    local sortedCategories = {}
    for k, v in pairs( storeConfig.Categories ) do
        table.insert( sortedCategories, { k, v } )
    end

    table.sort( sortedCategories, function(a, b) return (((a or {})[2] or {}).SortOrder or 1000) < (((b or {})[2] or {}).SortOrder or 1000) end )

    self.categories = {}
    local categoryHeaderTall, categoryHeaderSpacing = headerY, 5
    for _, val in pairs( sortedCategories ) do
        local k, v = val[1], val[2]

        self.categories[k] = vgui.Create( "DPanel", self.scrollPanel )
        self.categories[k]:Dock( TOP )
        self.categories[k]:DockMargin( 0, 25, 10, 0 )
        self.categories[k]:DockPadding( 0, categoryHeaderTall+categoryHeaderSpacing, 0, 0 )
        self.categories[k]:SetTall( categoryHeaderTall )
        self.categories[k].Paint = function( self2, w, h )
            draw.SimpleText( string.upper( v.Name ), "BRICKS_SERVER_Font30", 0, 0, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
        end

        self.categories[k].grid = vgui.Create( "DIconLayout", self.categories[k] )
        self.categories[k].grid:Dock( TOP )
        self.categories[k].grid:SetTall( 0 )
        self.categories[k].grid:SetSpaceY( itemSpacing )
        self.categories[k].grid:SetSpaceX( itemSpacing )
    end

    local sortedStoreItems = {}

    for k, v in pairs( storeItemsConfig ) do
        local itemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( v.GlobalKey )

        if( not itemTable or (self.searchBar:GetValue() != "" and not string.find( string.lower( itemTable.Name ), string.lower( self.searchBar:GetValue() ) )) ) then
            continue
        end

        sortedStoreItems[k] = table.Copy( v )
        sortedStoreItems[k].Key = k
    end

    table.sort( sortedStoreItems, function(a, b) return ((a or {}).SortOrder or 1000) < ((b or {}).SortOrder or 1000) end )

    for k, v in pairs( sortedStoreItems ) do
        local categoryPanel = self.categories[v.Category or 0]

        if( not IsValid( categoryPanel ) ) then 
            print( "[Brick's Unboxing] ERROR MISSING ITEM CATEGORY!" )
            continue 
        end

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

end

vgui.Register( "bricks_server_unboxingmenu_store", PANEL, "DPanel" )