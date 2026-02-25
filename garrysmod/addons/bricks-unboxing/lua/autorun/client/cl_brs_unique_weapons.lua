-- ============================================================
-- UNIQUE WEAPONS SYSTEM - Client
-- Handles: Data sync, inspect popup, UI helpers
-- ============================================================
if not CLIENT then return end

BRS_UW = BRS_UW or {}
BRS_UW.WeaponData = BRS_UW.WeaponData or {}

-- ============================================================
-- NET RECEIVERS
-- ============================================================

-- Receive single weapon data
net.Receive("BRS_UW.SyncWeaponData", function()
    local globalKey = net.ReadString()
    local jsonStr = net.ReadString()
    local data = util.JSONToTable(jsonStr)

    if data then
        BRS_UW.WeaponData[globalKey] = data
    end
end)

-- Receive all weapons (compressed batch)
net.Receive("BRS_UW.SyncAllWeapons", function()
    local len = net.ReadUInt(32)
    local compressed = net.ReadData(len)
    local jsonStr = util.Decompress(compressed)

    if not jsonStr then return end

    local allData = util.JSONToTable(jsonStr)
    if not allData then return end

    for globalKey, data in pairs(allData) do
        BRS_UW.WeaponData[globalKey] = data
    end

    print("[BRS UW] Received " .. table.Count(allData) .. " unique weapons from server")

    -- Refresh inventory display if open
    hook.Run("BRS.Hooks.FillUnboxingInventory")
end)

-- Receive inspect result
net.Receive("BRS_UW.InspectResult", function()
    local globalKey = net.ReadString()
    local jsonStr = net.ReadString()
    local data = util.JSONToTable(jsonStr)

    if data then
        BRS_UW.WeaponData[globalKey] = data
        BRS_UW.OpenInspectPopup(globalKey, data)
    end
end)

-- ============================================================
-- RARITY BORDER COLORS (for animated borders)
-- ============================================================
local rarityBorderColors = {
    Common    = { Color(140,140,140,180) },
    Uncommon  = { Color(80,180,60,200) },
    Rare      = { Color(30,120,210,220) },
    Epic      = { Color(140,50,240,230) },
    Legendary = { Color(255,150,0,240) },
    Glitched  = { -- Rainbow cycle
        Color(255,0,0), Color(255,127,0), Color(255,255,0),
        Color(0,255,0), Color(0,255,255), Color(0,0,255), Color(255,0,255)
    },
    Mythical  = { -- Hot cycle
        Color(255,0,50), Color(255,50,0), Color(255,200,0),
        Color(255,100,50), Color(255,0,100)
    },
}

function BRS_UW.GetBorderColor(rarityKey)
    local colors = rarityBorderColors[rarityKey]
    if not colors then return Color(100,100,100,150) end

    if #colors == 1 then return colors[1] end

    -- Animated cycling
    local speed = 2
    local t = CurTime() * speed
    local idx = (t % #colors)
    local i1 = math.floor(idx) + 1
    local i2 = (i1 % #colors) + 1
    local frac = idx - math.floor(idx)

    local c1, c2 = colors[i1], colors[i2]
    return Color(
        Lerp(frac, c1.r, c2.r),
        Lerp(frac, c1.g, c2.g),
        Lerp(frac, c1.b, c2.b),
        Lerp(frac, c1.a or 255, c2.a or 255)
    )
end

-- ============================================================
-- DRAW HELPERS
-- ============================================================

-- Draw mini stat bars (for item cards)
function BRS_UW.DrawMiniStatBars(x, y, w, h, stats, rarity)
    if not stats then return end

    local barH = math.max(3, math.floor(h / (#BRS_UW.Stats + 1)))
    local barSpacing = 1
    local labelW = 28
    local barW = w - labelW - 8
    local totalH = #BRS_UW.Stats * (barH + barSpacing)
    local startY = y

    for i, statDef in ipairs(BRS_UW.Stats) do
        local val = stats[statDef.key] or 0
        local barY = startY + (i - 1) * (barH + barSpacing)

        -- Label
        draw.SimpleText(statDef.shortName, "BRS_UW_Font8", x + labelW - 2, barY + barH/2, statDef.color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        -- Bar background
        local barX = x + labelW + 2
        draw.RoundedBox(2, barX, barY, barW, barH, Color(30,30,30,200))

        -- Bar fill
        local fillW = math.Clamp(val / 100, 0, 1) * barW
        if fillW > 1 then
            draw.RoundedBox(2, barX, barY, fillW, barH, ColorAlpha(statDef.color, 200))
        end
    end

    return totalH
end

-- ============================================================
-- INSPECT POPUP
-- ============================================================
function BRS_UW.OpenInspectPopup(globalKey, data)
    if IsValid(BRS_UW.InspectFrame) then BRS_UW.InspectFrame:Remove() end

    local rarity = BRS_UW.RarityByKey[data.rarity] or BRS_UW.Rarities[1]
    local qualityInfo = BRS_UW.GetQualityInfo(data.quality or "Junk")
    local avgBoost = data.avgBoost or BRS_UW.CalcAvgBoost(data.stats)

    local fw, fh = 340, 480
    local frame = vgui.Create("DPanel")
    frame:SetSize(fw, fh)
    frame:Center()
    frame:MakePopup()
    frame:SetMouseInputEnabled(true)
    frame:SetKeyboardInputEnabled(true)
    BRS_UW.InspectFrame = frame

    local borderThickness = 3
    local startTime = CurTime()

    frame.Paint = function(self, w, h)
        -- Background
        draw.RoundedBox(12, 0, 0, w, h, Color(20, 22, 28, 250))

        -- Animated rarity border
        local borderColor = BRS_UW.GetBorderColor(data.rarity)
        local bT = borderThickness

        -- Top
        draw.RoundedBoxEx(12, 0, 0, w, bT, borderColor, true, true, false, false)
        -- Bottom
        draw.RoundedBoxEx(12, 0, h - bT, w, bT, borderColor, false, false, true, true)
        -- Left
        surface.SetDrawColor(borderColor)
        surface.DrawRect(0, bT, bT, h - bT * 2)
        -- Right
        surface.DrawRect(w - bT, bT, bT, h - bT * 2)

        -- Glow for Glitched/Mythical
        if data.rarity == "Glitched" or data.rarity == "Mythical" then
            local pulse = math.sin(CurTime() * 3) * 0.3 + 0.7
            local glowCol = ColorAlpha(borderColor, 30 * pulse)
            draw.RoundedBox(12, -2, -2, w + 4, h + 4, glowCol)
        end
    end

    -- Weapon Name
    local nameLabel = vgui.Create("DLabel", frame)
    nameLabel:SetFont("BRS_UW_Font22B")
    nameLabel:SetText(data.weaponName or "Unknown")
    nameLabel:SetContentAlignment(5)
    nameLabel:Dock(TOP)
    nameLabel:DockMargin(15, 20, 15, 0)
    nameLabel:SetTall(28)
    nameLabel:SetTextColor(Color(240,240,240))

    -- Rarity label
    local rarityLabel = vgui.Create("DLabel", frame)
    rarityLabel:SetFont("BRS_UW_Font16")
    rarityLabel:SetText(data.rarity or "Common")
    rarityLabel:SetContentAlignment(5)
    rarityLabel:Dock(TOP)
    rarityLabel:DockMargin(15, 2, 15, 0)
    rarityLabel:SetTall(22)
    rarityLabel:SetTextColor(rarity.color)

    -- Model display area (blank space for now - could add 3D model later)
    local modelArea = vgui.Create("DPanel", frame)
    modelArea:Dock(TOP)
    modelArea:DockMargin(15, 10, 15, 0)
    modelArea:SetTall(10)
    modelArea.Paint = function() end

    -- Quality + Booster Score bar
    local scoreBar = vgui.Create("DPanel", frame)
    scoreBar:Dock(TOP)
    scoreBar:DockMargin(20, 5, 20, 0)
    scoreBar:SetTall(28)
    scoreBar.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35,38,48))

        -- Quality badge
        draw.RoundedBox(4, 4, 4, 60, h - 8, ColorAlpha(qualityInfo.color, 180))
        draw.SimpleText(data.quality or "Junk", "BRS_UW_Font12B", 34, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Booster score
        draw.SimpleText("Booster Score: " .. string.format("%.1f", avgBoost), "BRS_UW_Font14", w/2 + 10, h/2, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Avg badge
        local avgColor = avgBoost >= 50 and Color(80,255,120) or (avgBoost >= 25 and Color(255,200,40) or Color(200,200,200))
        draw.SimpleText("+" .. string.format("%.0f", avgBoost) .. "% avg", "BRS_UW_Font12B", w - 8, h/2, avgColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    -- Tab bar
    local activeTab = "stats"
    local tabBar = vgui.Create("DPanel", frame)
    tabBar:Dock(TOP)
    tabBar:DockMargin(20, 12, 20, 0)
    tabBar:SetTall(32)
    tabBar.Paint = function() end

    local tabs = {"Stats", "Ranking", "Info"}
    local tabButtons = {}

    local contentPanel = vgui.Create("DPanel", frame)
    contentPanel:Dock(TOP)
    contentPanel:DockMargin(20, 8, 20, 0)
    contentPanel:SetTall(240)
    contentPanel.Paint = function() end

    local function FillContent()
        contentPanel:Clear()

        if activeTab == "stats" then
            -- Stat bars
            for i, statDef in ipairs(BRS_UW.Stats) do
                local val = (data.stats and data.stats[statDef.key]) or 0

                local row = vgui.Create("DPanel", contentPanel)
                row:Dock(TOP)
                row:DockMargin(0, 4, 0, 0)
                row:SetTall(30)
                row.Paint = function(self2, w, h)
                    -- Stat name
                    draw.SimpleText(statDef.name, "BRS_UW_Font14B", 0, h/2, statDef.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                    -- Value
                    draw.SimpleText("+" .. string.format("%.1f", val) .. "%", "BRS_UW_Font14", w, h/2, Color(220,220,220), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                    -- Bar background
                    local barX, barY, barW, barH = 100, h/2 - 5, w - 170, 10
                    draw.RoundedBox(4, barX, barY, barW, barH, Color(30,33,42))

                    -- Bar fill
                    local fillW = math.Clamp(val / 100, 0, 1) * barW
                    if fillW > 1 then
                        draw.RoundedBox(4, barX, barY, fillW, barH, ColorAlpha(statDef.color, 220))
                    end
                end
            end

            -- Overall Power
            local overallRow = vgui.Create("DPanel", contentPanel)
            overallRow:Dock(TOP)
            overallRow:DockMargin(0, 12, 0, 0)
            overallRow:SetTall(30)
            overallRow.Paint = function(self2, w, h)
                local overallColor = Color(255, 220, 100)
                draw.SimpleText("OVERALL POWER", "BRS_UW_Font14B", 0, h/2, overallColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("+" .. string.format("%.1f", avgBoost) .. "%", "BRS_UW_Font14", w, h/2, overallColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                local barX, barY, barW, barH = 130, h/2 - 5, w - 200, 10
                draw.RoundedBox(4, barX, barY, barW, barH, Color(30,33,42))
                local fillW = math.Clamp(avgBoost / 100, 0, 1) * barW
                if fillW > 1 then
                    draw.RoundedBox(4, barX, barY, fillW, barH, ColorAlpha(overallColor, 220))
                end
            end

        elseif activeTab == "ranking" then
            local infoLabel = vgui.Create("DLabel", contentPanel)
            infoLabel:Dock(TOP)
            infoLabel:DockMargin(0, 40, 0, 0)
            infoLabel:SetTall(30)
            infoLabel:SetFont("BRS_UW_Font16")
            infoLabel:SetText("Ranking system coming soon...")
            infoLabel:SetTextColor(Color(150,150,150))
            infoLabel:SetContentAlignment(5)

        elseif activeTab == "info" then
            local infoPairs = {
                {"Weapon", data.weaponName or "Unknown"},
                {"Class", data.weaponClass or "Unknown"},
                {"Rarity", data.rarity or "Common"},
                {"Quality", data.quality or "Junk"},
                {"Category", data.category or "Unknown"},
                {"UID", data.uid or "N/A"},
                {"Avg Boost", string.format("%.1f%%", avgBoost)},
            }

            for _, pair in ipairs(infoPairs) do
                local row = vgui.Create("DPanel", contentPanel)
                row:Dock(TOP)
                row:DockMargin(0, 4, 0, 0)
                row:SetTall(24)
                row.Paint = function(self2, w, h)
                    draw.SimpleText(pair[1], "BRS_UW_Font14", 0, h/2, Color(140,140,140), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(pair[2], "BRS_UW_Font14", w, h/2, Color(220,220,220), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
        end
    end

    for i, tabName in ipairs(tabs) do
        local btn = vgui.Create("DButton", tabBar)
        btn:Dock(LEFT)
        btn:SetWide(80)
        btn:DockMargin(0, 0, 5, 0)
        btn:SetText("")
        btn.Paint = function(self2, w, h)
            local isActive = (activeTab == string.lower(tabName))
            local bgCol = isActive and rarity.color or Color(40,43,55)
            draw.RoundedBox(6, 0, 0, w, h, bgCol)
            local textCol = isActive and Color(255,255,255) or Color(160,160,160)
            draw.SimpleText(tabName, "BRS_UW_Font14B", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btn.DoClick = function()
            activeTab = string.lower(tabName)
            FillContent()
        end
        tabButtons[i] = btn
    end

    FillContent()

    -- Close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:Dock(BOTTOM)
    closeBtn:DockMargin(20, 0, 20, 15)
    closeBtn:SetTall(36)
    closeBtn:SetText("")
    closeBtn.Paint = function(self2, w, h)
        local col = self2:IsHovered() and Color(60,63,75) or Color(40,43,55)
        draw.RoundedBox(8, 0, 0, w, h, col)
        draw.SimpleText("Close", "BRS_UW_Font16", w/2, h/2, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        frame:Remove()
    end
end

-- ============================================================
-- FONTS
-- ============================================================
surface.CreateFont("BRS_UW_Font8", { font = "Roboto", size = 10, weight = 700 })
surface.CreateFont("BRS_UW_Font10", { font = "Roboto", size = 12, weight = 500 })
surface.CreateFont("BRS_UW_Font10B", { font = "Roboto", size = 12, weight = 700 })
surface.CreateFont("BRS_UW_Font12B", { font = "Roboto", size = 14, weight = 700 })
surface.CreateFont("BRS_UW_Font14", { font = "Roboto", size = 16, weight = 500 })
surface.CreateFont("BRS_UW_Font14B", { font = "Roboto", size = 16, weight = 700 })
surface.CreateFont("BRS_UW_Font16", { font = "Roboto", size = 18, weight = 500 })
surface.CreateFont("BRS_UW_Font18B", { font = "Roboto", size = 20, weight = 700 })
surface.CreateFont("BRS_UW_Font22B", { font = "Roboto", size = 24, weight = 700 })

print("[BRS UW] Client system loaded")
