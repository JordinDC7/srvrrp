-- ============================================================
-- SmG RP - Home Page (v5)
-- Uses panelWide/panelTall directly - set by main menu
-- before FillPanel is called. No deferral, no GetWide.
-- ============================================================
local PANEL = {}

function PANEL:Init()
    hook.Add("BRS.Hooks.ConfigReceived", self, function()
        self:FillPanel()
    end)
end

function PANEL:FillPanel()
    self:Clear()
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}

    -- panelWide/panelTall are SET by SwitchToPage() before FillPanel() is called
    -- They are ALWAYS valid. Do NOT use self:GetWide() - it may return 0.
    local W = self.panelWide or (ScrW() * 0.72)
    local H = self.panelTall or (ScrH() * 0.6)

    -- DEBUG: Remove after fixing
    notification.AddLegacy("HOME FillPanel: W=" .. math.floor(W) .. " H=" .. math.floor(H) .. " GetW=" .. self:GetWide() .. " GetH=" .. self:GetTall(), NOTIFY_HINT, 8)

    local pad = 20
    local innerW = W - (pad * 2)

    -- ====== STATISTICS DATA ======
    local statistics = {
        { Title = BRICKS_SERVER.Func.L("unboxingCasesOpened"),      Value = function() return LocalPlayer():GetUnboxingStat("cases") end },
        { Title = BRICKS_SERVER.Func.L("unboxingTradesCompleted"),  Value = function() return LocalPlayer():GetUnboxingStat("trades") end },
        { Title = BRICKS_SERVER.Func.L("unboxingItemsPurchased"),   Value = function() return LocalPlayer():GetUnboxingStat("items") end },
    }

    -- ====== TOP ROW: STAT CARDS ======
    local cardSpacing = 10
    local cardH = 110
    local cardW = math.floor((innerW - (cardSpacing * (#statistics - 1))) / #statistics)

    for k, v in ipairs(statistics) do
        local x = pad + (k - 1) * (cardW + cardSpacing)
        local card = vgui.Create("DPanel", self)
        card:SetPos(x, pad)
        card:SetSize(cardW, cardH)

        local animValue = 0
        card.Paint = function(self2, w, h)
            draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
            surface.SetDrawColor(C.border or Color(50, 52, 65))
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.RoundedBoxEx(6, 0, 0, w, 3, C.accent_dim or Color(0, 160, 128), true, true, false, false)
            draw.SimpleText(string.upper(v.Title), "SMGRP_Bold12", w / 2, 28, C.text_muted or Color(90, 94, 110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            animValue = math.ceil(Lerp(FrameTime() * 5, animValue, v.Value()))
            draw.SimpleText(string.Comma(animValue), "SMGRP_Stat32", w / 2, 68, C.text_primary or Color(220, 222, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- ====== BOTTOM AREA ======
    local bottomY = pad + cardH + 10
    local bottomH = H - bottomY - pad
    if bottomH < 50 then bottomH = 400 end

    local colGap = 10
    local lbW = math.floor(innerW * 0.28)
    local actW = math.floor(innerW * 0.36)
    local featW = innerW - lbW - actW - (colGap * 2)

    local lbX = pad
    local featX = lbX + lbW + colGap
    local actX = featX + featW + colGap

    -- ====== COLUMN 1: LEADERBOARD ======
    local lbPanel = vgui.Create("DPanel", self)
    lbPanel:SetPos(lbX, bottomY)
    lbPanel:SetSize(lbW, bottomH)
    lbPanel.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.RoundedBoxEx(6, 0, 0, w, 36, C.bg_light or Color(34, 36, 46), true, true, false, false)
        draw.SimpleText("LEADERBOARD", "SMGRP_Bold12", 12, 18, C.text_secondary or Color(140, 144, 160), 0, TEXT_ALIGN_CENTER)
    end

    local lbScrollH = bottomH - 50
    local lbScroll = vgui.Create("bricks_server_scrollpanel_bar", lbPanel)
    lbScroll:SetPos(8, 42)
    lbScroll:SetSize(lbW - 16, lbScrollH)
    lbScroll:SetBarBackColor(C.bg_darkest or Color(12, 12, 18))

    local medalColors = { Color(255, 200, 50), Color(190, 195, 205), Color(200, 145, 60) }

    function self.RefreshPanel()
        if not IsValid(lbScroll) then return end
        lbScroll:Clear()

        for k, v in pairs(BRICKS_SERVER.TEMP.UnboxingLeaderboard or {}) do
            local entryH = 52
            local avatarSz = entryH - 14

            local playerName = BRICKS_SERVER.Func.L("unknown")
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
                draw.SimpleText(BRICKS_SERVER.Func.L("unboxingXCases", v.cases or 0), "SMGRP_Body12", tx, h / 2 - 1, C.text_muted or Color(90, 94, 110), 0, 0)
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
    BRICKS_SERVER.UNBOXING.Func.RequestLeaderboardStats()
    if not timer.Exists("BRS_TIMER_UNBOXING_LEADERBOARD") then
        timer.Create("BRS_TIMER_UNBOXING_LEADERBOARD", 60, 0, function()
            if IsValid(self) then BRICKS_SERVER.UNBOXING.Func.RequestLeaderboardStats()
            else timer.Remove("BRS_TIMER_UNBOXING_LEADERBOARD") end
        end)
    end

    -- ====== COLUMN 2: FEATURED ======
    local featPanel = vgui.Create("DPanel", self)
    featPanel:SetPos(featX, bottomY)
    featPanel:SetSize(featW, bottomH)
    featPanel.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.RoundedBoxEx(6, 0, 0, w, 36, C.bg_light or Color(34, 36, 46), true, true, false, false)
        draw.SimpleText("FEATURED", "SMGRP_Bold12", 12, 18, C.accent or Color(0, 212, 170), 0, TEXT_ALIGN_CENTER)
    end

    local featScroll = vgui.Create("bricks_server_scrollpanel_bar", featPanel)
    featScroll:SetPos(8, 42)
    featScroll:SetSize(featW - 16, bottomH - 50)
    featScroll:SetBarBackColor(C.bg_darkest or Color(12, 12, 18))

    for i = 1, BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount do
        local storeItem = BRICKS_SERVER.CONFIG.UNBOXING.Store.Items[BRICKS_SERVER.CONFIG.UNBOXING.Store.Featured[i] or 0]
        if not storeItem then continue end

        local slot = vgui.Create("bricks_server_unboxingmenu_itemslot", featScroll)
        slot:Dock(TOP)
        slot:DockMargin(0, 0, 4, 6)
        slot:SetTall(160)
        slot:FillPanel(storeItem.GlobalKey, 1)
        slot:AddTopInfo(BRICKS_SERVER.UNBOXING.Func.FormatCurrency(storeItem.Price or 0, storeItem.Currency), C.accent_dim or Color(0, 160, 128), Color(255, 255, 255))

        if storeItem.Group then
            local groupTable = {}
            for key, val in pairs(BRICKS_SERVER.CONFIG.GENERAL.Groups) do
                if val[1] == storeItem.Group then groupTable = val break end
            end
            slot:AddTopInfo(storeItem.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme(6))
        end
    end

    -- ====== COLUMN 3: ACTIVITY FEED ======
    local actPanel = vgui.Create("DPanel", self)
    actPanel:SetPos(actX, bottomY)
    actPanel:SetSize(actW, bottomH)
    actPanel.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.RoundedBoxEx(6, 0, 0, w, 36, C.bg_light or Color(34, 36, 46), true, true, false, false)
        draw.SimpleText("LIVE ACTIVITY", "SMGRP_Bold12", 12, 18, C.text_secondary or Color(140, 144, 160), 0, TEXT_ALIGN_CENTER)
    end

    local actScrollH = bottomH - 50
    local actScroll = vgui.Create("bricks_server_scrollpanel_bar", actPanel)
    actScroll:SetPos(8, 42)
    actScroll:SetSize(actW - 16, actScrollH)
    actScroll:SetBarBackColor(C.bg_darkest or Color(12, 12, 18))

    local scrollH = 0
    actScroll.pnlCanvas.Paint = function(self2, w, h)
        if scrollH ~= h then scrollH = h actScroll.VBar:AnimateTo(scrollH, 0) end
    end

    actScroll.Filler = vgui.Create("DPanel", actScroll)
    actScroll.Filler:Dock(TOP)
    actScroll.Filler:SetTall(actScrollH)
    actScroll.Filler.Paint = function() end

    self.activitySlots = 0

    function self.AddActivityEntry(plyName, rarityName, itemName)
        self.activitySlots = self.activitySlots + 1

        surface.SetFont("SMGRP_Body12")
        local _, textY = surface.GetTextSize("Ay")

        local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo(rarityName)
        local rarityColor = (SMGRP and SMGRP.UI and SMGRP.UI.GetRarityColor) and SMGRP.UI.GetRarityColor(rarityName) or BRICKS_SERVER.Func.GetRarityColor(rarityInfo)
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
            surface.DrawText(BRICKS_SERVER.Func.L("unboxingPlyUnboxedA1", plyName))
            surface.SetTextColor(rarityColor.r, rarityColor.g, rarityColor.b)
            surface.DrawText("'" .. itemName .. "'")
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
        actScroll.Filler:SetTall(actScrollH)
        actScroll.Filler.Paint = function() end

        for _, v in ipairs(BRS_UNBOXING_ACTIVITY or {}) do
            self.AddActivityEntry(v[1], v[2], v[3])
        end
    end
    self.RefreshActivity()

    hook.Add("BRS.Hooks.InsertUnboxingAlert", self, function(self2, activityKey)
        local t = (BRS_UNBOXING_ACTIVITY or {})[activityKey]
        if t then self.AddActivityEntry(t[1], t[2], t[3]) end
    end)
end

function PANEL:Paint(w, h)
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
    draw.RoundedBox(0, 0, 0, w, h, C.bg_darkest or Color(12, 12, 18))

    -- DEBUG: Remove after fixing
    draw.SimpleText("DEBUG: Paint w=" .. w .. " h=" .. h .. " panelWide=" .. tostring(self.panelWide) .. " panelTall=" .. tostring(self.panelTall), "DermaDefault", 10, h - 20, Color(255, 0, 0), 0, 0)
end

vgui.Register("bricks_server_unboxingmenu_home", PANEL, "DPanel")
