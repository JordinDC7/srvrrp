-- ============================================================
-- SmG RP - Premium Unboxing Menu
-- Custom frame with horizontal navigation + player wallet
-- ============================================================
local PANEL = {}

local NAV_HEIGHT = 42
local HEADER_HEIGHT = 48
local TOTAL_TOP = HEADER_HEIGHT + NAV_HEIGHT

function PANEL:Init()
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}

    local frameW = math.min(ScrW() * 0.72, 1280)
    local frameH = math.min(ScrH() * 0.75, 820)
    self:SetSize( frameW, frameH )
    self:Center()
    self:SetTitle( "" )
    self:SetDraggable( true )
    self:ShowCloseButton( false )
    self:MakePopup()
    self:SetDeleteOnClose( false )
    -- Override DFrame's default padding (5, 24, 5, 5) which reserves space for title bar
    self:DockPadding( 0, 0, 0, 0 )

    self.contentWide = frameW
    self.contentTall = frameH - TOTAL_TOP

    -- ====== COMPATIBILITY SHIM: self.sheet ======
    -- Trading submodule checks BRICKS_SERVER_UNBOXINGMENU.sheet.ActiveButton.label
    -- Provide a fake sheet object that reflects our current page
    self.sheet = {
        ActiveButton = { label = "" }
    }
    self.sheet.SetActiveSheet = function(_, label)
        -- Find the page that matches this label and switch to it
        for k, v in pairs(self.pageInstances or {}) do
            if v.info and v.info.bricksLabel == label then
                self:SwitchToPage(k)
                return
            end
        end
    end

    -- ====== CLOSE CALLBACK (marketplace, coinflip cleanup) ======
    -- Store cleanup function; called from PANEL:OnClose()
    self._cleanupFunc = function()
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "marketplace" ) ) then
            net.Start( "BRS.Net.SendUnboxingMarketplaceClose" )
            net.SendToServer()
        end
        if( BRICKS_SERVER.Func.IsModuleEnabled( "coinflip" ) ) then
            net.Start( "BRS.Net.CloseCoinflipsMenu" )
            net.SendToServer()
        end
        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            BRICKS_SERVER.Func.SendAdminConfig()
        end
    end

    -- ====== HEADER BAR (drag area + player info + close) ======
    self.headerBar = vgui.Create( "DPanel", self )
    self.headerBar:Dock( TOP )
    self.headerBar:SetTall( HEADER_HEIGHT )
    self.headerBar.Paint = function( self2, w, h )
        local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
        draw.RoundedBoxEx( 8, 0, 0, w, h, C.bg_dark or Color(18,18,26), true, true, false, false )

        -- Logo text
        draw.SimpleText( "SmG", "SMGRP_Header", 18, h/2, C.accent or Color(0,212,170), 0, TEXT_ALIGN_CENTER )
        surface.SetFont("SMGRP_Header")
        local logoW = surface.GetTextSize("SmG")
        draw.SimpleText( " RP", "SMGRP_Header", 18 + logoW, h/2, C.text_primary or Color(220,222,230), 0, TEXT_ALIGN_CENTER )

        -- Subtle bottom line
        surface.SetDrawColor(C.border or Color(50,52,65))
        surface.DrawRect(0, h-1, w, 1)
    end

    -- Player avatar in header
    local avatarSize = 32
    local avatarPanel = vgui.Create( "DPanel", self.headerBar )
    avatarPanel:Dock( RIGHT )
    avatarPanel:DockMargin( 0, 8, 52, 8 )
    avatarPanel:SetWide( 200 )
    avatarPanel.Paint = function( self2, w, h )
        local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
        -- Player name
        draw.SimpleText( LocalPlayer():Nick(), "SMGRP_Bold13", w - avatarSize - 8, h/2 + 1, C.text_primary or Color(220,222,230), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
        -- Wallet balance
        local balance = ""
        if BRICKS_SERVER and BRICKS_SERVER.UNBOXING and BRICKS_SERVER.UNBOXING.Func and BRICKS_SERVER.UNBOXING.Func.FormatCurrency then
            local money = 0
            if LocalPlayer().getDarkRPVar then
                money = LocalPlayer():getDarkRPVar("money") or 0
            end
            if DarkRP and DarkRP.formatMoney then
                balance = DarkRP.formatMoney(money)
            else
                balance = "$" .. string.Comma(money)
            end
        end
        draw.SimpleText( balance, "SMGRP_Body12", w - avatarSize - 8, h/2 - 1, C.accent or Color(0,212,170), TEXT_ALIGN_RIGHT, 0 )
    end

    local avatar = vgui.Create( "AvatarImage", avatarPanel )
    avatar:Dock( RIGHT )
    avatar:SetWide( avatarSize )
    avatar:DockMargin( 4, 0, 0, 0 )
    avatar:SetPlayer( LocalPlayer(), 64 )

    -- Close button
    local closeBtn = vgui.Create( "DButton", self.headerBar )
    closeBtn:Dock( RIGHT )
    closeBtn:DockMargin( 0, 8, 12, 8 )
    closeBtn:SetWide( 32 )
    closeBtn:SetText( "" )
    closeBtn.hoverAlpha = 0
    closeBtn.Paint = function( self2, w, h )
        local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
        if self2:IsHovered() then
            self2.hoverAlpha = math.Clamp(self2.hoverAlpha + 12, 0, 255)
        else
            self2.hoverAlpha = math.Clamp(self2.hoverAlpha - 12, 0, 255)
        end
        if self2.hoverAlpha > 0 then
            draw.RoundedBox( 4, 0, 0, w, h, Color(220, 60, 60, self2.hoverAlpha) )
        end
        -- X icon
        local cx, cy = w/2, h/2
        local s = 6
        surface.SetDrawColor(200, 200, 210)
        surface.DrawLine(cx-s, cy-s, cx+s, cy+s)
        surface.DrawLine(cx+s, cy-s, cx-s, cy+s)
        surface.DrawLine(cx-s+1, cy-s, cx+s+1, cy+s)
        surface.DrawLine(cx+s+1, cy-s, cx-s+1, cy+s)
    end
    closeBtn.DoClick = function()
        self:Close()
    end

    -- ====== NAVIGATION BAR ======
    self.navBar = vgui.Create( "DPanel", self )
    self.navBar:Dock( TOP )
    self.navBar:SetTall( NAV_HEIGHT )
    self.navBar.Paint = function( self2, w, h )
        local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
        draw.RoundedBox( 0, 0, 0, w, h, C.bg_darkest or Color(12,12,18) )
        surface.SetDrawColor(C.border or Color(50,52,65))
        surface.DrawRect(0, h-1, w, 1)
    end

    self.navButtons = {}
    self.activePage = nil
    self.activePageKey = nil
    self.pageInstances = {}

    -- ====== CONTENT AREA ======
    self.contentPanel = vgui.Create( "DPanel", self )
    self.contentPanel:Dock( FILL )
    self.contentPanel.Paint = function( self2, w, h )
        local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
        draw.RoundedBoxEx( 6, 0, 0, w, h, C.bg_darkest or Color(12,12,18), false, false, true, true )
    end

    self:BuildPages()
end

function PANEL:BuildPages()
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}

    -- Define all pages
    local pages = {}
    table.insert( pages, { key = "home",      label = "HOME",      panel = "bricks_server_unboxingmenu_home",      bricksLabel = BRICKS_SERVER.Func.L( "unboxingHome" ) } )
    table.insert( pages, { key = "store",     label = "STORE",     panel = "bricks_server_unboxingmenu_store",     bricksLabel = BRICKS_SERVER.Func.L( "unboxingStore" ) } )
    table.insert( pages, { key = "inventory", label = "INVENTORY", panel = "bricks_server_unboxingmenu_inventory", bricksLabel = BRICKS_SERVER.Func.L( "unboxingInventory" ) } )

    if( SH_EASYSKINS ) then
        table.insert( pages, { key = "skins", label = "SKINS", panel = "bricks_server_unboxingmenu_easyskins", bricksLabel = BRICKS_SERVER.Func.L( "unboxingSkins" ), extraInit = function(page) if page.RefreshCategory then page.RefreshCategory() end end } )
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "trading" ) ) then
        table.insert( pages, { key = "trading", label = "TRADING", panel = "bricks_server_unboxingmenu_trading", bricksLabel = BRICKS_SERVER.Func.L( "unboxingTrading" ) } )
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "marketplace" ) ) then
        table.insert( pages, { key = "marketplace", label = "MARKET", panel = "bricks_server_unboxingmenu_marketplace", bricksLabel = BRICKS_SERVER.Func.L( "unboxingMarketplace" ) } )
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "rewards" ) ) then
        table.insert( pages, { key = "rewards", label = "REWARDS", panel = "bricks_server_unboxingmenu_rewards", bricksLabel = BRICKS_SERVER.Func.L( "unboxingRewards" ) } )
    end

    if( BRICKS_SERVER.Func.IsModuleEnabled( "coinflip" ) ) then
        table.insert( pages, { key = "coinflip",  label = "COINFLIP", panel = "bricks_server_coinflip_flips",   bricksLabel = BRICKS_SERVER.Func.L( "coinflips" ) } )
        table.insert( pages, { key = "cfhistory", label = "CF HISTORY", panel = "bricks_server_coinflip_history", bricksLabel = BRICKS_SERVER.Func.L( "coinflipHistory" ) } )
    end

    local isAdmin = BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() )
    if isAdmin then
        table.insert( pages, { key = "admin",  label = "ADMIN",  panel = "bricks_server_unboxingmenu_admin",  admin = true, bricksLabel = BRICKS_SERVER.Func.L( "admin" ) } )
        table.insert( pages, { key = "config", label = "CONFIG", panel = "bricks_server_config",               admin = true, wideMode = true, bricksLabel = BRICKS_SERVER.Func.L( "config" ) } )
    end

    -- Create nav buttons
    local navLeft = vgui.Create( "DPanel", self.navBar )
    navLeft:Dock( LEFT )
    navLeft:DockMargin( 12, 0, 0, 0 )
    navLeft:SetWide( #pages * 100 )
    navLeft.Paint = function() end

    for i, pageInfo in ipairs(pages) do
        -- Create the page panel (hidden initially)
        local page = vgui.Create( pageInfo.panel, self.contentPanel )
        page:SetPos( 0, 0 )
        page:SetSize( self.contentWide, self.contentTall )
        page.panelWide = self.contentWide
        page:SetVisible( false )

        if pageInfo.key == "coinflip" or pageInfo.key == "cfhistory" then
            page.panelWide = self.contentWide
        end

        self.pageInstances[pageInfo.key] = { page = page, info = pageInfo, filled = false }

        -- Nav button
        local btn = vgui.Create( "DButton", navLeft )
        btn:Dock( LEFT )
        btn:SetWide( pageInfo.admin and 80 or 95 )
        btn:DockMargin( 0, 4, 2, 4 )
        btn:SetText( "" )
        btn.pageKey = pageInfo.key
        btn.hoverAlpha = 0

        btn.Paint = function( self2, w, h )
            local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
            local isActive = (self.activePageKey == self2.pageKey)

            if self2:IsHovered() and not isActive then
                self2.hoverAlpha = math.Clamp(self2.hoverAlpha + 10, 0, 255)
            else
                self2.hoverAlpha = math.Clamp(self2.hoverAlpha - 10, 0, 255)
            end

            if isActive then
                draw.RoundedBox( 4, 0, 0, w, h, C.bg_light or Color(34,36,46) )
                -- Active accent underline
                draw.RoundedBox( 2, 4, h - 3, w - 8, 3, C.accent or Color(0,212,170) )
                draw.SimpleText( pageInfo.label, "SMGRP_Bold11", w/2, h/2 - 1, C.text_primary or Color(220,222,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            else
                if self2.hoverAlpha > 0 then
                    draw.RoundedBox( 4, 0, 0, w, h, Color(255,255,255, math.floor(self2.hoverAlpha * 0.04)) )
                end
                local textCol = pageInfo.admin and (C.amber or Color(255,185,50)) or (C.text_muted or Color(90,94,110))
                draw.SimpleText( pageInfo.label, "SMGRP_Bold11", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end

        btn.DoClick = function()
            self:SwitchToPage( pageInfo.key )
        end

        self.navButtons[pageInfo.key] = btn
    end

    -- Open first page
    self:SwitchToPage( "home" )

    -- Hook: switch to trading page when trade invite accepted
    hook.Add( "BRS.Hooks.OpenUnboxingTradePage", self, function()
        self:SwitchToPage( "trading" )
    end )
end

function PANEL:SwitchToPage( pageKey )
    if self.activePageKey == pageKey then return end

    local pageData = self.pageInstances[pageKey]
    if not pageData then return end

    -- Hide current page
    if self.activePage then
        self.activePage:SetVisible( false )
    end

    -- Handle config panel resize
    local frameW = math.min(ScrW() * 0.72, 1280)
    local frameH = math.min(ScrH() * 0.75, 820)

    if pageData.info.wideMode then
        local newW = frameW + 200
        self:SizeTo( newW, frameH, 0.2 )
        pageData.page:SetSize( newW, frameH - TOTAL_TOP )
        pageData.page.panelWide = newW
    elseif self:GetWide() ~= frameW then
        self:SizeTo( frameW, frameH, 0.2 )
    end

    -- Show and fill new page
    local page = pageData.page
    -- Use actual content panel size (may differ from initial calc due to docking)
    local cw, ch = self.contentPanel:GetSize()
    if cw < 10 then cw = self.contentWide end
    if ch < 10 then ch = self.contentTall end
    page:SetSize( cw, ch )
    page:SetVisible( true )
    page:SetPos( 0, 0 )
    page.panelWide = cw
    -- Set panelTall for pages that use it (marketplace, trading, store, etc.)
    page.panelTall = ch

    if not pageData.filled and page.FillPanel then
        page:FillPanel()
        pageData.filled = true

        if pageData.info.extraInit then
            pageData.info.extraInit(page)
        end
    end

    self.activePage = page
    self.activePageKey = pageKey

    -- Update sheet compatibility shim for trading/other submodules
    if self.sheet then
        self.sheet.ActiveButton.label = pageData.info.bricksLabel or pageData.info.label
    end

    -- Fire switchpage hook
    hook.Run( "BRS.Hooks.UnboxingSwitchpage", pageData.info.bricksLabel or pageData.info.label )
end

-- ====== FRAME PAINTING ======
function PANEL:Paint( w, h )
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}

    -- Drop shadow
    draw.RoundedBox( 10, -4, -2, w+8, h+6, Color(0, 0, 0, 80) )
    draw.RoundedBox( 8, -2, -1, w+4, h+3, Color(0, 0, 0, 40) )

    -- Main background
    draw.RoundedBox( 8, 0, 0, w, h, C.bg_darkest or Color(12,12,18) )

    -- Border
    surface.SetDrawColor(C.border or Color(50,52,65))
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

-- ====== KEEP COMPATIBILITY ======
PANEL.removeOnClose = false

function PANEL:SetHeader() end -- no-op (was bricks title)

-- DFrame calls OnClose after SetVisible(false) when deleteOnClose is false
function PANEL:OnClose()
    if self._cleanupFunc then self._cleanupFunc() end
end

function PANEL:Refresh()
    -- Rebuild pages
    for k, v in pairs(self.pageInstances) do
        if IsValid(v.page) then v.page:Remove() end
    end
    self.pageInstances = {}
    self.navButtons = {}
    self.activePage = nil
    self.activePageKey = nil

    if IsValid(self.navBar) then
        for _, child in ipairs(self.navBar:GetChildren()) do
            child:Remove()
        end
    end

    self:BuildPages()
end

function PANEL:OnSizeChanged(w, h)
    self:Center()
    self.contentWide = w
    self.contentTall = h - TOTAL_TOP
end

-- CRITICAL: DFrame:PerformLayout resets DockPadding to (5, 24+, 5, 5) every frame
-- Override to keep our zero padding
function PANEL:PerformLayout(w, h)
    self:DockPadding( 0, 0, 0, 0 )
end

vgui.Register( "bricks_server_unboxingmenu", PANEL, "DFrame" )
