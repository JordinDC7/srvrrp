-- ============================================================
-- SmG RP - Home Page v6
-- pcall-protected FillPanel with error display
-- ============================================================
local PANEL = {}

function PANEL:Init()
    self._homeError = nil
    self._homeFilled = false

    hook.Add("BRS.Hooks.ConfigReceived", self, function()
        self:FillPanel()
    end)
end

function PANEL:FillPanel()
    self:Clear()
    self._homeFilled = true

    -- Match store page: ensure panelWide/panelTall are set
    self.panelTall = self.panelTall or self:GetTall()
    self.panelWide = self.panelWide or self:GetWide()

    local ok, err = pcall(self.BuildContent, self)
    if not ok then
        self._homeError = tostring(err)
        -- Also print to console for debugging
        MsgN("[SmG RP Home] FillPanel error: " .. tostring(err))
    end
end

function PANEL:BuildContent()
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
    local pw = self.panelWide or 1000
    local ph = self.panelTall or 600

    -- Store debug info
    self._debugPW = pw
    self._debugPH = ph

    -- ====== STATISTICS DATA ======
    local statistics = {
        { Title = "CASES OPENED",      Value = function() return (LocalPlayer().GetUnboxingStat and LocalPlayer():GetUnboxingStat("cases")) or 0 end },
        { Title = "TRADES COMPLETED",  Value = function() return (LocalPlayer().GetUnboxingStat and LocalPlayer():GetUnboxingStat("trades")) or 0 end },
        { Title = "ITEMS PURCHASED",   Value = function() return (LocalPlayer().GetUnboxingStat and LocalPlayer():GetUnboxingStat("items")) or 0 end },
    }

    -- Try to get localized names (but don't crash if it fails)
    if BRICKS_SERVER and BRICKS_SERVER.Func and BRICKS_SERVER.Func.L then
        statistics[1].Title = BRICKS_SERVER.Func.L("unboxingCasesOpened") or "Cases Opened"
        statistics[2].Title = BRICKS_SERVER.Func.L("unboxingTradesCompleted") or "Trades Completed"
        statistics[3].Title = BRICKS_SERVER.Func.L("unboxingItemsPurchased") or "Items Purchased"
    end

    -- ====== TOP: STAT CARDS ======
    local topBack = vgui.Create("DPanel", self)
    topBack:Dock(TOP)
    topBack:DockMargin(20, 16, 20, 0)
    topBack:SetTall(110)
    topBack.Paint = function() end

    -- Width for cards = panelWide minus margins (20+20=40)
    local topInner = pw - 40
    local cardSpacing = 10
    local cardW = math.floor((topInner - (cardSpacing * (#statistics - 1))) / #statistics)

    for k, v in ipairs(statistics) do
        local card = vgui.Create("DPanel", topBack)
        card:Dock(LEFT)
        card:DockMargin(0, 0, k < #statistics and cardSpacing or 0, 0)
        card:SetWide(cardW)

        local animValue = 0
        card.Paint = function(self2, w, h)
            draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
            surface.SetDrawColor(C.border or Color(50, 52, 65))
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.RoundedBoxEx(6, 0, 0, w, 3, C.accent_dim or Color(0, 160, 128), true, true, false, false)

            local title = string.upper(tostring(v.Title or ""))
            draw.SimpleText(title, "SMGRP_Bold12", w / 2, 28, C.text_muted or Color(90, 94, 110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local target = 0
            local valOk, valResult = pcall(v.Value)
            if valOk then target = valResult or 0 end
            animValue = math.ceil(Lerp(FrameTime() * 5, animValue, target))
            draw.SimpleText(string.Comma(animValue), "SMGRP_Stat32", w / 2, 68, C.text_primary or Color(220, 222, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- ====== BOTTOM: 3-COLUMN LAYOUT ======
    local bottomBack = vgui.Create("DPanel", self)
    bottomBack:Dock(FILL)
    bottomBack:DockMargin(20, 10, 20, 16)
    bottomBack.Paint = function() end

    -- Column widths from panelWide
    local bottomInner = pw - 40
    local colGap = 10
    local lbW = math.floor(bottomInner * 0.28)
    local actW = math.floor(bottomInner * 0.36)

    -- ====== COLUMN 3: ACTIVITY FEED (Dock RIGHT - must be first) ======
    local actPanel = vgui.Create("DPanel", bottomBack)
    actPanel:Dock(RIGHT)
    actPanel:SetWide(actW)
    actPanel.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.RoundedBoxEx(6, 0, 0, w, 36, C.bg_light or Color(34, 36, 46), true, true, false, false)
        draw.SimpleText("LIVE ACTIVITY", "SMGRP_Bold12", 12, 18, C.text_secondary or Color(140, 144, 160), 0, TEXT_ALIGN_CENTER)
    end

    local actScroll = vgui.Create("bricks_server_scrollpanel_bar", actPanel)
    actScroll:Dock(FILL)
    actScroll:DockMargin(10, 44, 10, 10)
    actScroll:SetBarBackColor(C.bg_darkest or Color(12, 12, 18))

    -- Safe canvas paint
    if actScroll.pnlCanvas then
        local scrollH = 0
        actScroll.pnlCanvas.Paint = function(self2, w, h)
            if scrollH ~= h then
                scrollH = h
                if actScroll.VBar then actScroll.VBar:AnimateTo(scrollH, 0) end
            end
        end
    end

    -- Filler for bottom-aligned activity entries
    local actFillerH = math.max(100, ph - 200)
    actScroll.Filler = vgui.Create("DPanel", actScroll)
    actScroll.Filler:Dock(TOP)
    actScroll.Filler:SetTall(actFillerH)
    actScroll.Filler.Paint = function() end

    self.activitySlots = 0

    function self.AddActivityEntry(plyName, rarityName, itemName)
        if not IsValid(actScroll) then return end
        self.activitySlots = self.activitySlots + 1

        surface.SetFont("SMGRP_Body12")
        local _, textY = surface.GetTextSize("Ay")

        local rarityColor = Color(180, 180, 180)
        local ok2, _ = pcall(function()
            local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo(rarityName)
            if SMGRP and SMGRP.UI and SMGRP.UI.GetRarityColor then
                rarityColor = SMGRP.UI.GetRarityColor(rarityName)
            elseif rarityInfo then
                rarityColor = BRICKS_SERVER.Func.GetRarityColor(rarityInfo)
            end
        end)

        local curSlot = self.activitySlots
        local entry = vgui.Create("DPanel", actScroll)
        entry:Dock(TOP)
        entry:DockMargin(0, curSlot > 1 and 4 or 0, 4, 0)
        entry:SetTall(34)
        entry.Paint = function(self2, w, h)
            draw.RoundedBox(4, 0, 0, w, h, C.bg_light or Color(34, 36, 46))
            surface.SetFont("SMGRP_Body12")
            surface.SetTextPos(10, (h / 2) - (textY / 2))
            local tc = C.text_secondary or Color(140, 144, 160)
            surface.SetTextColor(tc.r, tc.g, tc.b)
            local ok3, _ = pcall(function()
                surface.DrawText(BRICKS_SERVER.Func.L("unboxingPlyUnboxedA1", plyName))
            end)
            if not ok3 then surface.DrawText(tostring(plyName) .. " unboxed ") end
            surface.SetTextColor(rarityColor.r, rarityColor.g, rarityColor.b)
            surface.DrawText("'" .. tostring(itemName) .. "'")
        end

        if IsValid(actScroll.Filler) then
            actScroll.Filler:SetTall(math.max(0, actScroll.Filler:GetTall() - 38))
        end
        return entry
    end

    function self.RefreshActivity()
        if not IsValid(actScroll) then return end
        actScroll:Clear()
        self.activitySlots = 0

        actScroll.Filler = vgui.Create("DPanel", actScroll)
        actScroll.Filler:Dock(TOP)
        actScroll.Filler:SetTall(actFillerH)
        actScroll.Filler.Paint = function() end

        for _, v in ipairs(BRS_UNBOXING_ACTIVITY or {}) do
            if v and v[1] and v[2] and v[3] then
                self.AddActivityEntry(v[1], v[2], v[3])
            end
        end
    end
    self.RefreshActivity()

    hook.Add("BRS.Hooks.InsertUnboxingAlert", self, function(self2, activityKey)
        local t = (BRS_UNBOXING_ACTIVITY or {})[activityKey]
        if t and t[1] and t[2] and t[3] then self.AddActivityEntry(t[1], t[2], t[3]) end
    end)

    -- ====== COLUMN 1: LEADERBOARD (Dock LEFT) ======
    local lbPanel = vgui.Create("DPanel", bottomBack)
    lbPanel:Dock(LEFT)
    lbPanel:DockMargin(0, 0, colGap, 0)
    lbPanel:SetWide(lbW)
    lbPanel.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.RoundedBoxEx(6, 0, 0, w, 36, C.bg_light or Color(34, 36, 46), true, true, false, false)
        draw.SimpleText("LEADERBOARD", "SMGRP_Bold12", 12, 18, C.text_secondary or Color(140, 144, 160), 0, TEXT_ALIGN_CENTER)
    end

    local lbScroll = vgui.Create("bricks_server_scrollpanel_bar", lbPanel)
    lbScroll:Dock(FILL)
    lbScroll:DockMargin(10, 44, 10, 10)
    lbScroll:SetBarBackColor(C.bg_darkest or Color(12, 12, 18))

    local medalColors = { Color(255, 200, 50), Color(190, 195, 205), Color(200, 145, 60) }

    function self.RefreshPanel()
        if not IsValid(lbScroll) then return end
        lbScroll:Clear()

        local lb = (BRICKS_SERVER and BRICKS_SERVER.TEMP and BRICKS_SERVER.TEMP.UnboxingLeaderboard) or {}
        for k, v in pairs(lb) do
            local entryH = 52
            local avatarSz = entryH - 14

            local playerName = "Unknown"
            if BRICKS_SERVER and BRICKS_SERVER.Func and BRICKS_SERVER.Func.L then
                playerName = BRICKS_SERVER.Func.L("unknown") or "Unknown"
            end
            if v.steamID64 then
                steamworks.RequestPlayerInfo(v.steamID64, function(n) playerName = n end)
            end

            local entry = vgui.Create("DPanel", lbScroll)
            entry:Dock(TOP)
            entry:DockMargin(0, 0, 4, 4)
            entry:SetTall(entryH)
            entry.Paint = function(self2, w, h)
                draw.RoundedBox(4, 0, 0, w, h, C.bg_light or Color(34, 36, 46))
                if k <= 3 then draw.RoundedBox(2, 2, 2, 3, h - 4, medalColors[k]) end
                local tx = entryH - 4
                draw.SimpleText(playerName, "SMGRP_Bold12", tx, h / 2 + 1, C.text_primary or Color(220, 222, 230), 0, TEXT_ALIGN_BOTTOM)
                local casesText = tostring(v.cases or 0) .. " cases"
                if BRICKS_SERVER and BRICKS_SERVER.Func and BRICKS_SERVER.Func.L then
                    casesText = BRICKS_SERVER.Func.L("unboxingXCases", v.cases or 0) or casesText
                end
                draw.SimpleText(casesText, "SMGRP_Body12", tx, h / 2 - 1, C.text_muted or Color(90, 94, 110), 0, 0)
                draw.SimpleText("#" .. k, "SMGRP_Bold13", w - 8, h / 2, k <= 3 and medalColors[k] or (C.text_muted or Color(90, 94, 110)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            local av = vgui.Create("bricks_server_circle_avatar", entry)
            av:SetPos(6, (entryH - avatarSz) / 2)
            av:SetSize(avatarSz, avatarSz)
            av:SetSteamID(v.steamID64 or "", 64)
        end
    end
    self.RefreshPanel()

    hook.Add("BRS.Hooks.RefreshUnboxingLeaderboard", self, function() self.RefreshPanel() end)

    if BRICKS_SERVER and BRICKS_SERVER.UNBOXING and BRICKS_SERVER.UNBOXING.Func and BRICKS_SERVER.UNBOXING.Func.RequestLeaderboardStats then
        BRICKS_SERVER.UNBOXING.Func.RequestLeaderboardStats()
        if not timer.Exists("BRS_TIMER_UNBOXING_LEADERBOARD") then
            timer.Create("BRS_TIMER_UNBOXING_LEADERBOARD", 60, 0, function()
                if IsValid(self) then BRICKS_SERVER.UNBOXING.Func.RequestLeaderboardStats()
                else timer.Remove("BRS_TIMER_UNBOXING_LEADERBOARD") end
            end)
        end
    end

    -- ====== COLUMN 2: FEATURED (Dock FILL - gets remaining space) ======
    local featPanel = vgui.Create("DPanel", bottomBack)
    featPanel:Dock(FILL)
    featPanel:DockMargin(0, 0, colGap, 0)
    featPanel.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.RoundedBoxEx(6, 0, 0, w, 36, C.bg_light or Color(34, 36, 46), true, true, false, false)
        draw.SimpleText("FEATURED", "SMGRP_Bold12", 12, 18, C.accent or Color(0, 212, 170), 0, TEXT_ALIGN_CENTER)
    end

    local featScroll = vgui.Create("bricks_server_scrollpanel_bar", featPanel)
    featScroll:Dock(FILL)
    featScroll:DockMargin(10, 44, 10, 10)
    featScroll:SetBarBackColor(C.bg_darkest or Color(12, 12, 18))

    if BRICKS_SERVER and BRICKS_SERVER.DEVCONFIG and BRICKS_SERVER.CONFIG and BRICKS_SERVER.CONFIG.UNBOXING then
        local storeConfig = BRICKS_SERVER.CONFIG.UNBOXING.Store
        if storeConfig and storeConfig.Items and storeConfig.Featured then
            for i = 1, (BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount or 0) do
                local storeItem = storeConfig.Items[storeConfig.Featured[i] or 0]
                if not storeItem then continue end

                local slot = vgui.Create("bricks_server_unboxingmenu_itemslot", featScroll)
                slot:Dock(TOP)
                slot:DockMargin(0, 0, 4, 6)
                slot:SetTall(160)
                slot:FillPanel(storeItem.GlobalKey, 1)

                if BRICKS_SERVER.UNBOXING and BRICKS_SERVER.UNBOXING.Func and BRICKS_SERVER.UNBOXING.Func.FormatCurrency then
                    slot:AddTopInfo(BRICKS_SERVER.UNBOXING.Func.FormatCurrency(storeItem.Price or 0, storeItem.Currency), C.accent_dim or Color(0, 160, 128), Color(255, 255, 255))
                end

                if storeItem.Group and BRICKS_SERVER.CONFIG.GENERAL and BRICKS_SERVER.CONFIG.GENERAL.Groups then
                    local groupTable = {}
                    for key, val in pairs(BRICKS_SERVER.CONFIG.GENERAL.Groups) do
                        if val[1] == storeItem.Group then groupTable = val break end
                    end
                    if groupTable[3] then
                        slot:AddTopInfo(storeItem.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme(6))
                    end
                end
            end
        end
    end
end

function PANEL:Paint(w, h)
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
    draw.RoundedBox(0, 0, 0, w, h, C.bg_darkest or Color(12, 12, 18))

    -- Show error if FillPanel crashed
    if self._homeError then
        draw.SimpleText("HOME PAGE ERROR:", "SMGRP_Bold14", 20, 20, Color(255, 80, 80))
        -- Wrap long error text
        local err = self._homeError
        local y = 44
        while #err > 0 and y < h - 20 do
            local chunk = string.sub(err, 1, 100)
            err = string.sub(err, 101)
            draw.SimpleText(chunk, "SMGRP_Body13", 20, y, Color(255, 150, 150))
            y = y + 18
        end
        draw.SimpleText("pw=" .. tostring(self._debugPW) .. " ph=" .. tostring(self._debugPH), "SMGRP_Body12", 20, y + 8, Color(200, 200, 200))
    end

    -- Show if never filled
    if not self._homeFilled then
        draw.SimpleText("FillPanel not called yet", "SMGRP_Bold14", w/2, h/2, Color(255, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("panelWide=" .. tostring(self.panelWide) .. " panelTall=" .. tostring(self.panelTall), "SMGRP_Body12", w/2, h/2 + 24, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("bricks_server_unboxingmenu_home", PANEL, "DPanel")
