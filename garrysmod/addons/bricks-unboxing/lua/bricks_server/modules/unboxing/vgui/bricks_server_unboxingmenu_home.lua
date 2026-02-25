-- ============================================================
-- SmG RP - Home Page (Robust Layout)
-- No precomputed widths - fully dock-driven
-- ============================================================
local PANEL = {}

function PANEL:Init()
    hook.Add( "BRS.Hooks.ConfigReceived", self, function()
        self:FillPanel()
    end )
end

function PANEL:FillPanel()
    self:Clear()
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}

    -- ====== CONTENT WRAPPER (provides margins) ======
    local wrapper = vgui.Create("DPanel", self)
    wrapper:Dock(FILL)
    wrapper:DockMargin(20, 12, 20, 12)
    wrapper.Paint = function() end

    -- ====== STATISTICS ======
    local statistics = {
        { Title = BRICKS_SERVER.Func.L( "unboxingCasesOpened" ), Value = function() return LocalPlayer():GetUnboxingStat( "cases" ) end },
        { Title = BRICKS_SERVER.Func.L( "unboxingTradesCompleted" ), Value = function() return LocalPlayer():GetUnboxingStat( "trades" ) end },
        { Title = BRICKS_SERVER.Func.L( "unboxingItemsPurchased" ), Value = function() return LocalPlayer():GetUnboxingStat( "items" ) end },
    }

    -- ====== TOP: STAT CARDS ROW ======
    local topRow = vgui.Create("DPanel", wrapper)
    topRow:Dock(TOP)
    topRow:SetTall(120)
    topRow.Paint = function() end

    -- Use DIconLayout for evenly-spaced stat cards
    for k, v in ipairs(statistics) do
        local card = vgui.Create("DPanel", topRow)
        card:Dock(LEFT)
        -- On first PerformLayout, compute 1/3 width
        card.PerformLayout = function(self2, w, h)
            local parentW = topRow:GetWide()
            if parentW > 100 then
                local spacing = 10
                local cardW = (parentW - (spacing * (#statistics - 1))) / #statistics
                self2:SetWide(cardW)
            end
        end
        card:DockMargin(0, 0, k < #statistics and 10 or 0, 0)
        card:SetWide(200) -- initial, gets recalculated

        local animValue = 0
        card.Paint = function(self2, w, h)
            draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
            surface.SetDrawColor(C.border or Color(50, 52, 65))
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            -- Accent bar at top
            draw.RoundedBoxEx(6, 0, 0, w, 3, C.accent_dim or Color(0, 160, 128), true, true, false, false)

            -- Title (uppercase, muted)
            draw.SimpleText(string.upper(v.Title), "SMGRP_Bold12", w/2, 30, C.text_muted or Color(90, 94, 110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Animated counter
            animValue = math.ceil(Lerp(FrameTime() * 5, animValue, v.Value()))
            draw.SimpleText(string.Comma(animValue), "SMGRP_Stat32", w/2, 72, C.text_primary or Color(220, 222, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- ====== BOTTOM: 3-COLUMN LAYOUT ======
    local bottomRow = vgui.Create("DPanel", wrapper)
    bottomRow:Dock(FILL)
    bottomRow:DockMargin(0, 10, 0, 0)
    bottomRow.Paint = function() end

    -- ====== COLUMN 1: LEADERBOARD (left, 30%) ======
    local leaderboardBack = vgui.Create("DPanel", bottomRow)
    leaderboardBack:Dock(LEFT)
    leaderboardBack:DockMargin(0, 0, 10, 0)
    -- Responsive width
    leaderboardBack.PerformLayout = function(self2)
        local parentW = bottomRow:GetWide()
        if parentW > 100 then self2:SetWide(parentW * 0.28) end
    end
    leaderboardBack:SetWide(250)

    leaderboardBack.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.RoundedBoxEx(6, 0, 0, w, 38, C.bg_light or Color(34, 36, 46), true, true, false, false)
        draw.SimpleText("LEADERBOARD", "SMGRP_Bold12", 14, 19, C.text_secondary or Color(140, 144, 160), 0, TEXT_ALIGN_CENTER)
    end

    function self.RefreshPanel()
        leaderboardBack:Clear()
        local height, spacing = 56, 6
        local slots = #(BRICKS_SERVER.TEMP.UnboxingLeaderboard or {})

        local lbScroll = vgui.Create("bricks_server_scrollpanel_bar", leaderboardBack)
        lbScroll:Dock(FILL)
        lbScroll:DockMargin(10, 46, 10, 10)
        lbScroll:SetBarBackColor(C.bg_darkest or Color(12, 12, 18))

        local medalColors = {
            Color(255, 200, 50),
            Color(190, 195, 205),
            Color(200, 145, 60),
        }

        for k, v in pairs(BRICKS_SERVER.TEMP.UnboxingLeaderboard or {}) do
            local avatarSize = height - 16

            local playerName = BRICKS_SERVER.Func.L("unknown")
            if v.steamID64 then
                steamworks.RequestPlayerInfo(v.steamID64, function(n) playerName = n end)
            end

            local entry = vgui.Create("DPanel", lbScroll)
            entry:Dock(TOP)
            entry:DockMargin(0, 0, 4, spacing)
            entry:SetTall(height)
            entry.Paint = function(self2, w, h)
                draw.RoundedBox(4, 0, 0, w, h, C.bg_light or Color(34, 36, 46))
                if k <= 3 then
                    draw.RoundedBox(2, 2, 2, 3, h - 4, medalColors[k])
                end
                local tx = height - 4
                draw.SimpleText(playerName, "SMGRP_Bold12", tx, h/2 + 1, C.text_primary or Color(220, 222, 230), 0, TEXT_ALIGN_BOTTOM)
                draw.SimpleText(BRICKS_SERVER.Func.L("unboxingXCases", v.cases or 0), "SMGRP_Body12", tx, h/2 - 1, C.text_muted or Color(90, 94, 110), 0, 0)
                draw.SimpleText("#" .. k, "SMGRP_Bold13", w - 10, h/2, k <= 3 and medalColors[k] or (C.text_muted or Color(90, 94, 110)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            local av = vgui.Create("bricks_server_circle_avatar", entry)
            av:SetPos(8, (height - avatarSize) / 2)
            av:SetSize(avatarSize, avatarSize)
            av:SetSteamID(v.steamID64 or "", 64)
        end
    end
    self.RefreshPanel()

    hook.Add("BRS.Hooks.RefreshUnboxingLeaderboard", self, function()
        self.RefreshPanel()
    end)

    BRICKS_SERVER.UNBOXING.Func.RequestLeaderboardStats()
    if not timer.Exists("BRS_TIMER_UNBOXING_LEADERBOARD") then
        timer.Create("BRS_TIMER_UNBOXING_LEADERBOARD", 60, 0, function()
            if IsValid(self) then
                BRICKS_SERVER.UNBOXING.Func.RequestLeaderboardStats()
            else
                timer.Remove("BRS_TIMER_UNBOXING_LEADERBOARD")
            end
        end)
    end

    -- ====== COLUMN 3: ACTIVITY FEED (right, 38%) ======
    local activityBack = vgui.Create("DPanel", bottomRow)
    activityBack:Dock(RIGHT)
    activityBack:DockMargin(10, 0, 0, 0)
    activityBack.PerformLayout = function(self2)
        local parentW = bottomRow:GetWide()
        if parentW > 100 then self2:SetWide(parentW * 0.36) end
    end
    activityBack:SetWide(300)

    activityBack.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.RoundedBoxEx(6, 0, 0, w, 38, C.bg_light or Color(34, 36, 46), true, true, false, false)
        draw.SimpleText("LIVE ACTIVITY", "SMGRP_Bold12", 14, 19, C.text_secondary or Color(140, 144, 160), 0, TEXT_ALIGN_CENTER)
    end

    local actScroll = vgui.Create("bricks_server_scrollpanel_bar", activityBack)
    actScroll:Dock(FILL)
    actScroll:DockMargin(10, 46, 10, 10)
    actScroll:SetBarBackColor(C.bg_darkest or Color(12, 12, 18))
    local scrollH = 0
    actScroll.pnlCanvas.Paint = function(self2, w, h)
        if scrollH ~= h then
            scrollH = h
            actScroll.VBar:AnimateTo(scrollH, 0)
        end
    end

    -- Filler panel that pushes new entries to bottom
    local actScrollMaxH = 800 -- generous initial; will be constrained by panel size
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
        entry:DockMargin(0, curSlot > 1 and 6 or 0, 4, 0)
        entry:SetTall(36)
        entry.Paint = function(self2, w, h)
            draw.RoundedBox(4, 0, 0, w, h, C.bg_light or Color(34, 36, 46))
            surface.SetFont("SMGRP_Body12")
            surface.SetTextPos(10, (h/2) - (textY/2))
            local tc = C.text_secondary or Color(140, 144, 160)
            surface.SetTextColor(tc.r, tc.g, tc.b)
            surface.DrawText(BRICKS_SERVER.Func.L("unboxingPlyUnboxedA1", plyName))
            surface.SetTextColor(rarityColor.r, rarityColor.g, rarityColor.b)
            surface.DrawText("'" .. itemName .. "'")
        end

        if IsValid(actScroll.Filler) then
            local curFH = actScroll.Filler:GetTall()
            actScroll.Filler:SetTall(math.max(0, curFH - 42))
        end
        return entry
    end

    function self.RefreshActivity()
        actScroll:Clear()
        self.activitySlots = 0

        actScroll.Filler = vgui.Create("DPanel", actScroll)
        actScroll.Filler:Dock(TOP)
        actScroll.Filler:SetTall(actScrollMaxH)
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

    -- ====== COLUMN 2: FEATURED ITEMS (center, fills remaining) ======
    local featuredBack = vgui.Create("DPanel", bottomRow)
    featuredBack:Dock(FILL)
    featuredBack:DockMargin(0, 0, 0, 0)
    featuredBack.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.RoundedBoxEx(6, 0, 0, w, 38, C.bg_light or Color(34, 36, 46), true, true, false, false)
        draw.SimpleText("FEATURED", "SMGRP_Bold12", 14, 19, C.accent or Color(0, 212, 170), 0, TEXT_ALIGN_CENTER)
    end

    local featScroll = vgui.Create("bricks_server_scrollpanel_bar", featuredBack)
    featScroll:Dock(FILL)
    featScroll:DockMargin(10, 46, 10, 10)
    featScroll:SetBarBackColor(C.bg_darkest or Color(12, 12, 18))

    -- Featured items - use a reasonable fixed size, docked
    for i = 1, BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount do
        local storeItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Store.Items[BRICKS_SERVER.CONFIG.UNBOXING.Store.Featured[i] or 0]
        if not storeItemTable then continue end

        local slot = vgui.Create("bricks_server_unboxingmenu_itemslot", featScroll)
        slot:Dock(TOP)
        slot:DockMargin(0, 0, 4, 8)
        slot:SetTall(180)
        slot:FillPanel(storeItemTable.GlobalKey, 1)
        slot:AddTopInfo(BRICKS_SERVER.UNBOXING.Func.FormatCurrency(storeItemTable.Price or 0, storeItemTable.Currency), C.accent_dim or Color(0, 160, 128), Color(255, 255, 255))

        if storeItemTable.Group then
            local groupTable = {}
            for key, val in pairs(BRICKS_SERVER.CONFIG.GENERAL.Groups) do
                if val[1] == storeItemTable.Group then groupTable = val break end
            end
            slot:AddTopInfo(storeItemTable.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme(6))
        end
    end
end

function PANEL:Paint(w, h)
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
    draw.RoundedBox(0, 0, 0, w, h, C.bg_darkest or Color(12, 12, 18))
end

vgui.Register("bricks_server_unboxingmenu_home", PANEL, "DPanel")
