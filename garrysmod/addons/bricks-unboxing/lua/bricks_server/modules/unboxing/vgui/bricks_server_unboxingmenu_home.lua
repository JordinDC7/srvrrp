local PANEL = {}

local function FormatTimeRemaining(secondsLeft)
    secondsLeft = math.max(0, tonumber(secondsLeft) or 0)

    local days = math.floor(secondsLeft / 86400)
    local hours = math.floor((secondsLeft % 86400) / 3600)

    if days > 0 then
        return string.Comma(days) .. "d " .. string.format("%02dh", hours)
    end

    local minutes = math.floor((secondsLeft % 3600) / 60)
    return string.format("%02dh %02dm", hours, minutes)
end

function PANEL:Init()
    self.panelTall = ScrH() * 0.65 - 40
    self:DockMargin(25, 25, 25, 25)

    hook.Add("BRS.Hooks.ConfigReceived", self, function()
        self:FillPanel()
    end)
end

function PANEL:FillPanel()
    self:Clear()

    local statistics = {}
    statistics[1] = {
        Title = BRICKS_SERVER.Func.L("unboxingCasesOpened"),
        Value = function() return LocalPlayer():GetUnboxingStat("cases") end
    }
    statistics[2] = {
        Title = BRICKS_SERVER.Func.L("unboxingTradesCompleted"),
        Value = function() return LocalPlayer():GetUnboxingStat("trades") end
    }
    statistics[3] = {
        Title = BRICKS_SERVER.Func.L("unboxingItemsPurchased"),
        Value = function() return LocalPlayer():GetUnboxingStat("items") end
    }
    statistics[4] = {
        Title = "Fragments",
        Value = function() return (BRS_UNBOXING_PROGRESS or {}).Fragments or 0 end
    }

    local topBack = vgui.Create("DPanel", self)
    topBack:Dock(TOP)
    topBack:SetTall(225)
    topBack.Paint = function() end

    local topBackW = (self.panelWide or self:GetWide()) - 50
    local entrySpacing = 25
    local entryWide = (topBackW - ((#statistics - 1) * entrySpacing)) / #statistics

    for k, v in ipairs(statistics) do
        local statisticEntry = vgui.Create("DPanel", topBack)
        statisticEntry:Dock(LEFT)
        statisticEntry:DockMargin(0, 0, k < #statistics and entrySpacing or 0, 0)
        statisticEntry:SetWide(entryWide)

        local value = 0
        statisticEntry.Paint = function(self2, w, h)
            draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))

            draw.SimpleText(
                string.upper(v.Title),
                "BRICKS_SERVER_Font33",
                w / 2,
                h / 2,
                Color(BRICKS_SERVER.Func.GetTheme(6).r, BRICKS_SERVER.Func.GetTheme(6).g, BRICKS_SERVER.Func.GetTheme(6).b, 75),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_BOTTOM
            )

            value = math.ceil(Lerp(FrameTime() * 5, value, v.Value()))
            draw.SimpleText(string.Comma(value), "BRICKS_SERVER_Font50", w / 2, h / 2, BRICKS_SERVER.Func.GetTheme(6), TEXT_ALIGN_CENTER, 0)
        end

        local statisticGradient = vgui.Create("bricks_server_gradientanim", statisticEntry)
        statisticGradient:SetPos(0, topBack:GetTall() - 10)
        statisticGradient:SetSize(statisticEntry:GetWide(), 10)
        statisticGradient:SetColors(Color(26, 188, 156), Color(46, 204, 113))
        statisticGradient:SetCornerRadius(8)
        statisticGradient:SetRoundedBoxDimensions(false, -10, false, 20)
        statisticGradient:StartAnim()
    end

    local progressionBar = vgui.Create("DPanel", self)
    progressionBar:Dock(TOP)
    progressionBar:DockMargin(0, 25, 0, 0)
    progressionBar:SetTall(196)
    progressionBar.Paint = function(self2, w, h)
        draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))

        local progress = BRS_UNBOXING_PROGRESS or {}
        local topTierCfg = (BRICKS_SERVER.UNBOXING.LUACFG or {}).TopTier or {}
        local pityCfg = topTierCfg.Pity or {}

        local masteryXP = tonumber(progress.MasteryXP) or 0
        local pityByFamily = progress.Pity or {}
        local highestPity = 0
        local highestFamily = "All Cases"
        local season = progress.Season or {}
        local seasonData = season.Data or {}
        local seasonName = tostring(seasonData.Name or "No Active Season")
        local seasonEnds = tonumber(seasonData.EndUnix) or 0
        local nowUnix = tonumber(season.Now) or os.time()

        for family, value in pairs(pityByFamily) do
            local familyPity = tonumber(value) or 0
            if familyPity >= highestPity then
                highestPity = familyPity
                highestFamily = tostring(family or "All Cases")
            end
        end

        local softStart = math.max(0, tonumber(pityCfg.SoftPityStart) or 0)
        local hardCap = math.max(0, tonumber(pityCfg.HardPityCap) or 0)
        local opensLeft = hardCap > 0 and math.max(0, hardCap - highestPity) or 0
        local pityPercent = hardCap > 0 and math.Clamp(highestPity / hardCap, 0, 1) or 0

        draw.SimpleText("UNBOXING PROGRESSION", "BRICKS_SERVER_Font23", 20, 10, BRICKS_SERVER.Func.GetTheme(6, 220))
        draw.SimpleText("Your pity track increases each time you open a case in the same family.", "BRICKS_SERVER_Font18", 20, 35, BRICKS_SERVER.Func.GetTheme(6, 120))

        local pityHeader = "TRACKED FAMILY: " .. string.upper(highestFamily)
        if hardCap > 0 then
            pityHeader = pityHeader .. "  •  " .. string.Comma(highestPity) .. "/" .. string.Comma(hardCap)
        else
            pityHeader = pityHeader .. "  •  " .. string.Comma(highestPity) .. " opens"
        end
        draw.SimpleText(pityHeader, "BRICKS_SERVER_Font20", 20, 58, BRICKS_SERVER.Func.GetTheme(6, 220))

        local barX, barY = 20, 84
        local barW, barH = math.max(180, w - 40), 16
        draw.RoundedBox(6, barX, barY, barW, barH, BRICKS_SERVER.Func.GetTheme(1))

        local fillW = math.floor((barW - 4) * pityPercent)
        draw.RoundedBox(6, barX + 2, barY + 2, fillW, barH - 4, Color(235, 76, 76))

        if hardCap > 0 then
            draw.SimpleText(math.floor(pityPercent * 100) .. "%", "BRICKS_SERVER_Font17", barX + barW - 6, barY + (barH / 2), BRICKS_SERVER.Func.GetTheme(6, 180), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        if softStart > 0 and hardCap > 0 then
            local softX = barX + math.floor((barW - 1) * math.Clamp(softStart / hardCap, 0, 1))
            surface.SetDrawColor(255, 255, 255, 140)
            surface.DrawLine(softX, barY - 2, softX, barY + barH + 2)
            draw.SimpleText("SOFT PITY", "BRICKS_SERVER_Font15", softX, barY - 4, BRICKS_SERVER.Func.GetTheme(6, 170), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end

        if hardCap > 0 then
            draw.SimpleText("Apex guarantee at " .. string.Comma(hardCap) .. " opens. " .. string.Comma(opensLeft) .. " opens remaining.", "BRICKS_SERVER_Font17", 20, 104, BRICKS_SERVER.Func.GetTheme(6, 180))
        else
            draw.SimpleText("No hard pity cap configured on this server.", "BRICKS_SERVER_Font17", 20, 104, BRICKS_SERVER.Func.GetTheme(6, 180))
        end
        draw.SimpleText("Season: " .. seasonName, "BRICKS_SERVER_Font17", 20, 124, BRICKS_SERVER.Func.GetTheme(6, 150))

        local seasonCountdown = "Season window is open-ended"
        if seasonEnds > 0 and seasonEnds >= nowUnix then
            local secondsLeft = seasonEnds - nowUnix
            seasonCountdown = "Season ends in " .. FormatTimeRemaining(secondsLeft)
        end

        draw.SimpleText(seasonCountdown, "BRICKS_SERVER_Font17", 20, 142, BRICKS_SERVER.Func.GetTheme(6, 120))
        draw.SimpleText("Apex tiers include Legendary, Glitched, and Mythical rewards.", "BRICKS_SERVER_Font17", 20, 160, BRICKS_SERVER.Func.GetTheme(6, 100))

        draw.SimpleText("Tip: Focus one case family to reach apex pity faster.", "BRICKS_SERVER_Font17", w - 20, 36, BRICKS_SERVER.Func.GetTheme(6, 90), TEXT_ALIGN_RIGHT)
        draw.SimpleText("Mastery XP: " .. string.Comma(masteryXP), "BRICKS_SERVER_Font17", w - 20, 58, BRICKS_SERVER.Func.GetTheme(6, 165), TEXT_ALIGN_RIGHT)

        local trackedFamilies = {}
        for familyName, pityValue in pairs(pityByFamily) do
            table.insert(trackedFamilies, { Name = tostring(familyName), Value = tonumber(pityValue) or 0 })
        end
        table.sort(trackedFamilies, function(a, b) return a.Value > b.Value end)

        local familyText = "Top family tracks: "
        if #trackedFamilies <= 0 then
            familyText = familyText .. "none yet"
        else
            local maxDisplay = math.min(3, #trackedFamilies)
            for i = 1, maxDisplay do
                local familyData = trackedFamilies[i]
                familyText = familyText .. string.upper(familyData.Name) .. " " .. familyData.Value
                if i < maxDisplay then
                    familyText = familyText .. " | "
                end
            end
        end
        draw.SimpleText(familyText, "BRICKS_SERVER_Font17", w - 20, 78, BRICKS_SERVER.Func.GetTheme(6, 120), TEXT_ALIGN_RIGHT)

        local rarityOrder = { "Legendary", "Glitched", "Mythical" }
        local startX = w - 20
        local pillY = 168
        local pillH = 22

        surface.SetFont("BRICKS_SERVER_Font17")
        for i = #rarityOrder, 1, -1 do
            local rarityName = rarityOrder[i]
            local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo(rarityName)
            local rarityColor = BRICKS_SERVER.Func.GetRarityColor(rarityInfo) or BRICKS_SERVER.Func.GetTheme(5)
            local tw = surface.GetTextSize(rarityName)
            local pillW = tw + 20
            startX = startX - pillW

            draw.RoundedBox(6, startX, pillY, pillW, pillH, BRICKS_SERVER.Func.GetTheme(3))
            draw.RoundedBox(6, startX, pillY, 5, pillH, rarityColor)
            draw.SimpleText(rarityName, "BRICKS_SERVER_Font17", startX + (pillW / 2) + 3, pillY + (pillH / 2), BRICKS_SERVER.Func.GetTheme(6, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            startX = startX - 8
        end
    end

    local bottomBack = vgui.Create("DPanel", self)
    bottomBack:Dock(FILL)
    bottomBack:DockMargin(0, 25, 0, 0)
    bottomBack.Paint = function() end

    -- RIGHT: Activity panel
    local activityBack = vgui.Create("DPanel", bottomBack)
    activityBack:Dock(RIGHT)
    activityBack:SetWide((self.panelWide or self:GetWide()) * 0.38)
    activityBack.Paint = function(self2, w, h)
        draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))
        BRICKS_SERVER.Func.DrawPartialRoundedBox(8, 0, 0, w, 10, BRICKS_SERVER.Func.GetTheme(3), w, 20)

        draw.SimpleText(
            BRICKS_SERVER.Func.L("unboxingActivity"),
            "BRICKS_SERVER_Font21",
            25,
            25,
            Color(BRICKS_SERVER.Func.GetTheme(6).r, BRICKS_SERVER.Func.GetTheme(6).g, BRICKS_SERVER.Func.GetTheme(6).b, 75)
        )
    end

    local bottomBackTall = self.panelTall - 75 - topBack:GetTall()
    local activityEntryHeight, activityEntrySpacing = 45, 15
    local activityScrollMaxH = bottomBackTall - 65 - 25

    local activityScroll = vgui.Create("bricks_server_scrollpanel_bar", activityBack)
    activityScroll:Dock(FILL)
    activityScroll:DockMargin(25, 65, 25, 25)
    activityScroll:SetBarBackColor(BRICKS_SERVER.Func.GetTheme(1))

    self.activitySlots = 0

    function self.AddActivityEntry(plyName, rarityName, itemName)
        self.activitySlots = self.activitySlots + 1

        local desiredTall = activityScroll:GetTall() + activityEntryHeight + ((self.activitySlots ~= 1 and activityEntrySpacing) or 0)
        activityScroll:SetTall(math.min(activityScrollMaxH, desiredTall))

        surface.SetFont("BRICKS_SERVER_Font21")
        local _, textY = surface.GetTextSize(BRICKS_SERVER.Func.L("unboxingPlyUnboxedA", plyName, itemName))

        local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo(rarityName)
        local curActivitySlot = self.activitySlots

        local activityEntry = vgui.Create("DPanel", activityScroll)
        activityEntry:Dock(TOP)
        activityEntry:DockMargin(0, curActivitySlot > 1 and activityEntrySpacing or 0, 10, 0)
        activityEntry:SetTall(activityEntryHeight)
        activityEntry.Paint = function(self2, w, h)
            draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(3))

            surface.SetFont("BRICKS_SERVER_Font21")
            surface.SetTextPos(20, (h / 2) - (textY / 2))
            surface.SetTextColor(255, 255, 255)
            surface.DrawText(BRICKS_SERVER.Func.L("unboxingPlyUnboxedA1", plyName))
            surface.SetTextColor(BRICKS_SERVER.Func.GetRarityColor(rarityInfo))
            surface.DrawText("'" .. tostring(itemName or "") .. "'")
        end

        return activityEntry
    end

    function self.RefreshActivity()
        activityScroll:Clear()
        self.activitySlots = 0

        for _, v in ipairs(BRS_UNBOXING_ACTIVITY or {}) do
            self.AddActivityEntry(v[1], v[2], v[3])
        end
    end

    self.RefreshActivity()

    hook.Add("BRS.Hooks.InsertUnboxingAlert", self, function(_, activityKey)
        local activityTable = (BRS_UNBOXING_ACTIVITY or {})[activityKey]
        if not activityTable then return end

        self.AddActivityEntry(activityTable[1], activityTable[2], activityTable[3])
    end)

    -- LEFT: Leaderboard panel
    local leaderboardBack = vgui.Create("DPanel", bottomBack)
    leaderboardBack:Dock(LEFT)
    leaderboardBack:SetWide(entryWide)
    leaderboardBack:DockMargin(0, 0, 25, 0)
    leaderboardBack.Paint = function(self2, w, h)
        draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))
        BRICKS_SERVER.Func.DrawPartialRoundedBox(8, 0, 0, w, 10, BRICKS_SERVER.Func.GetTheme(3), w, 20)

        draw.SimpleText(
            BRICKS_SERVER.Func.L("unboxingLeaderboard"),
            "BRICKS_SERVER_Font21",
            25,
            25,
            Color(BRICKS_SERVER.Func.GetTheme(6).r, BRICKS_SERVER.Func.GetTheme(6).g, BRICKS_SERVER.Func.GetTheme(6).b, 75)
        )
    end

    function self.RefreshPanel()
        if not IsValid(leaderboardBack) then return end
        leaderboardBack:Clear()

        local height, spacing = 75, 10
        local slots = #(BRICKS_SERVER.TEMP.UnboxingLeaderboard or {})
        local scrollPanelTall = self.panelTall - topBack:GetTall() - 75 - 25 - 65
        local displayBar = (slots * (height + spacing)) - spacing > scrollPanelTall

        local leaderboardScroll = vgui.Create(displayBar and "bricks_server_scrollpanel_bar" or "bricks_server_scrollpanel", leaderboardBack)
        leaderboardScroll:Dock(FILL)
        leaderboardScroll:DockMargin(25, 65, 25, 25)

        if displayBar and leaderboardScroll.SetBarBackColor then
            leaderboardScroll:SetBarBackColor(BRICKS_SERVER.Func.GetTheme(1))
        end

        for k, v in pairs(BRICKS_SERVER.TEMP.UnboxingLeaderboard or {}) do
            local avatarBackSize = height - 10
            local textStartPos = height + 5

            local playerName = BRICKS_SERVER.Func.L("unknown")
            if v.steamID64 then
                steamworks.RequestPlayerInfo(v.steamID64, function(steamName)
                    playerName = steamName or playerName
                end)
            end

            local playerBack = vgui.Create("DPanel", leaderboardScroll)
            playerBack:Dock(TOP)
            playerBack:DockMargin(0, 0, displayBar and 10 or 0, spacing)
            playerBack:SetTall(height)

            local leaderMat = Material("bricks_server/trophy.png")
            playerBack.Paint = function(self2, w, h)
                draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(3))

                surface.SetDrawColor(BRICKS_SERVER.Func.GetTheme(2))
                draw.NoTexture()
                BRICKS_SERVER.Func.DrawCircle((h - avatarBackSize) / 2 + (avatarBackSize / 2), h / 2, avatarBackSize / 2, 45)

                draw.SimpleText(playerName, "BRICKS_SERVER_Font23", textStartPos, h / 2 + 2, BRICKS_SERVER.Func.GetTheme(6), 0, TEXT_ALIGN_BOTTOM)
                draw.SimpleText(
                    BRICKS_SERVER.Func.L("unboxingXCases", (v.cases or 0)),
                    "BRICKS_SERVER_Font20",
                    textStartPos,
                    h / 2 - 2,
                    BRICKS_SERVER.Func.GetTheme(6, 75),
                    0,
                    0
                )

                if k <= 3 then
                    surface.SetDrawColor(
                        k == 1 and BRICKS_SERVER.DEVCONFIG.BaseThemes.Gold or
                        k == 2 and BRICKS_SERVER.DEVCONFIG.BaseThemes.Silver or
                        BRICKS_SERVER.DEVCONFIG.BaseThemes.Bronze
                    )
                    surface.SetMaterial(leaderMat)

                    local iconSize = 32
                    surface.DrawTexturedRect(w - (h / 2) - (iconSize / 2), (h / 2) - (iconSize / 2), iconSize, iconSize)
                end
            end

            local avatarIcon = vgui.Create("bricks_server_circle_avatar", playerBack)
            avatarIcon:SetPos((height - avatarBackSize) / 2, (height - avatarBackSize) / 2)
            avatarIcon:SetSize(avatarBackSize, avatarBackSize)
            avatarIcon:SetSteamID(v.steamID64 or "", 64)
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

    -- CENTER: Featured panel
    local featuredBack = vgui.Create("DPanel", bottomBack)
    featuredBack:Dock(FILL)
    featuredBack:DockMargin(0, 0, 25, 0)
    featuredBack.Paint = function(self2, w, h)
        draw.RoundedBox(8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme(2))
        BRICKS_SERVER.Func.DrawPartialRoundedBox(8, 0, 0, w, 10, BRICKS_SERVER.Func.GetTheme(3), w, 20)

        draw.SimpleText(
            BRICKS_SERVER.Func.L("unboxingFeaturedHome"),
            "BRICKS_SERVER_Font21",
            25,
            25,
            Color(BRICKS_SERVER.Func.GetTheme(6).r, BRICKS_SERVER.Func.GetTheme(6).g, BRICKS_SERVER.Func.GetTheme(6).b, 75)
        )
    end

    local featuredScroll = vgui.Create("bricks_server_scrollpanel_bar", featuredBack)
    featuredScroll:Dock(FILL)
    featuredScroll:DockMargin(25, 65, 25, 25)
    featuredScroll:SetBarBackColor(BRICKS_SERVER.Func.GetTheme(1))

    local featuredLayout = vgui.Create("DIconLayout", featuredScroll)
    featuredLayout:Dock(TOP)
    featuredLayout:SetSpaceY(10)
    featuredLayout:SetSpaceX(10)

    local function BuildFeatured()
        if not IsValid(self) or not IsValid(featuredBack) or not IsValid(featuredScroll) or not IsValid(featuredLayout) then return end
        featuredLayout:Clear()

        -- Use the actual inner width after docking/layout resolves
        local innerW = featuredScroll:GetWide()
        if innerW <= 0 then return end

        -- one-column cards that fit the panel width cleanly
        local slotW = math.max(140, innerW - 10)
        local slotH = slotW * 1.2

        for i = 1, (BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount or 0) do
            local featuredList = BRICKS_SERVER.CONFIG.UNBOXING.Store.Featured or {}
            local storeItems = BRICKS_SERVER.CONFIG.UNBOXING.Store.Items or {}
            local featuredKey = featuredList[i]
            local storeItemTable = storeItems[featuredKey or 0]

            if not storeItemTable then continue end

            local slotBack = vgui.Create("bricks_server_unboxingmenu_itemslot", featuredLayout)
            slotBack:SetSize(slotW, slotH)
            slotBack.themeNum = 1
            slotBack:FillPanel(storeItemTable.GlobalKey, 1)

            -- price pill (right side)
            slotBack:AddTopInfo(BRICKS_SERVER.UNBOXING.Func.FormatCurrency(storeItemTable.Price or 0, storeItemTable.Currency))

            -- group pill (left side)
            if storeItemTable.Group then
                local groupTable = {}
                for _, val in pairs(BRICKS_SERVER.CONFIG.GENERAL.Groups or {}) do
                    if val[1] == storeItemTable.Group then
                        groupTable = val
                        break
                    end
                end

                slotBack:AddTopInfo(
                    storeItemTable.Group,
                    groupTable[3] or BRICKS_SERVER.Func.GetTheme(1, 120),
                    BRICKS_SERVER.Func.GetTheme(6),
                    true
                )
            end
        end

        featuredLayout:SizeToChildren(false, true)
    end

    -- Build after dock/layout sizes are valid
    timer.Simple(0, function()
        if IsValid(self) then
            BuildFeatured()
        end
    end)

    -- Rebuild on resize (resolution/UI scale/menu resize)
    featuredBack.OnSizeChanged = function()
        timer.Simple(0, function()
            if IsValid(self) then
                BuildFeatured()
            end
        end)
    end
end

function PANEL:Paint(w, h)
end

vgui.Register("bricks_server_unboxingmenu_home", PANEL, "DPanel")
