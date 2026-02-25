--[[
    UNIQUE WEAPON SYSTEM - Client Side
    Stat booster display on inventory items, quality system, inspect popup
]]--

if not CLIENT then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.PlayerWeapons = BRS_WEAPONS.PlayerWeapons or {}

-- ============================================================
-- FONTS
-- ============================================================
surface.CreateFont("BRS_WEP_8",  { font = "Roboto", size = 8,  weight = 600 })
surface.CreateFont("BRS_WEP_10", { font = "Roboto", size = 10, weight = 500 })
surface.CreateFont("BRS_WEP_11", { font = "Roboto", size = 11, weight = 600 })
surface.CreateFont("BRS_WEP_12", { font = "Roboto", size = 12, weight = 400 })
surface.CreateFont("BRS_WEP_14", { font = "Roboto", size = 14, weight = 700 })
surface.CreateFont("BRS_WEP_16", { font = "Roboto", size = 16, weight = 500 })
surface.CreateFont("BRS_WEP_20", { font = "Roboto", size = 20, weight = 700 })
surface.CreateFont("BRS_WEP_24", { font = "Roboto", size = 24, weight = 700 })

-- ============================================================
-- NETWORK RECEIVERS
-- ============================================================
net.Receive("BRS.UniqueWeapons.Sync", function()
    local len = net.ReadUInt(32)
    local compressed = net.ReadData(len)
    local jsonData = util.Decompress(compressed)
    if not jsonData then return end
    local weapons = util.JSONToTable(jsonData)
    if not weapons then return end
    BRS_WEAPONS.PlayerWeapons = weapons
    print("[BRS UniqueWeapons] Synced " .. table.Count(weapons) .. " unique weapons")
end)

net.Receive("BRS.UniqueWeapons.NewWeapon", function()
    local jsonData = net.ReadString()
    local weaponData = util.JSONToTable(jsonData)
    if not weaponData then return end
    BRS_WEAPONS.PlayerWeapons[weaponData.weapon_uid] = weaponData
end)

net.Receive("BRS.UniqueWeapons.Inspect", function()
    local jsonData = net.ReadString()
    local weaponData = util.JSONToTable(jsonData)
    if not weaponData then return end
    BRS_WEAPONS.OpenInspectPopup(weaponData)
end)

-- ============================================================
-- FIND UNIQUE WEAPON DATA FOR AN INVENTORY ITEM
-- Match by weapon class - find best unique weapon for this class
-- ============================================================
function BRS_WEAPONS.FindForClass(weaponClass)
    local bestUID, bestTotal = nil, -1
    for uid, data in pairs(BRS_WEAPONS.PlayerWeapons) do
        if data.weapon_class == weaponClass then
            local total = 0
            for _, v in pairs(data.stat_boosters or {}) do
                total = total + math.abs(v)
            end
            if total > bestTotal then
                bestUID = uid
                bestTotal = total
            end
        end
    end
    if bestUID then
        return BRS_WEAPONS.PlayerWeapons[bestUID]
    end
    return nil
end

-- ============================================================
-- INVENTORY ITEM OVERLAY
-- Hooks into bricks_server_unboxingmenu_itemslot to add stat bars
-- ============================================================
local function DrawStatOverlay(panel, w, h, itemTable)
    if not itemTable or (itemTable.Type ~= "PermWeapon" and itemTable.Type ~= "Weapon") then return end

    local weaponClass = itemTable.ReqInfo and itemTable.ReqInfo[1]
    if not weaponClass then return end

    local weaponData = BRS_WEAPONS.FindForClass(weaponClass)
    if not weaponData or not weaponData.stat_boosters then return end

    local boosters = weaponData.stat_boosters
    if table.Count(boosters) == 0 then return end

    local quality, avg = BRS_WEAPONS.GetQuality(boosters)

    -- Quality label + average boost
    local qualY = h - 48
    draw.SimpleText(quality.name, "BRS_WEP_11", 6, qualY, quality.color, TEXT_ALIGN_LEFT)
    if avg then
        draw.SimpleText("Avg +" .. math.Round(avg * 100, 1) .. "%", "BRS_WEP_10", w - 6, qualY, Color(200, 200, 200, 200), TEXT_ALIGN_RIGHT)
    end

    -- Stat bars
    local barY = qualY + 14
    local barH = 4
    local barW = (w - 12) / 5
    local gap = 0

    local statOrder = { "DMG", "ACC", "MAG", "RPM", "SPD" }
    for i, statKey in ipairs(statOrder) do
        local statDef = BRS_WEAPONS.StatDefs[statKey]
        if not statDef then continue end

        local x = 6 + (i - 1) * (barW + gap)
        local boost = boosters[statKey]

        -- Background bar
        draw.RoundedBox(2, x, barY, barW - 2, barH, Color(40, 40, 40, 200))

        -- Fill bar (if this stat has a boost)
        if boost then
            local fillFrac = math.Clamp(math.abs(boost) / 1.0, 0, 1)
            local col = boost >= 0 and statDef.Color or Color(255, 50, 50)
            draw.RoundedBox(2, x, barY, (barW - 2) * fillFrac, barH, ColorAlpha(col, 220))
        end

        -- Label underneath
        local labelCol = boost and ColorAlpha(statDef.Color, 220) or Color(60, 60, 60, 150)
        draw.SimpleText(statDef.ShortName, "BRS_WEP_8", x + (barW - 2) / 2, barY + barH + 1, labelCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    -- Rarity color top border
    local rarityColor = BRS_WEAPONS.GetRarityColor(weaponData.rarity)
    surface.SetDrawColor(rarityColor.r, rarityColor.g, rarityColor.b, 200)
    surface.DrawRect(0, 0, w, 2)
end

-- ============================================================
-- HOOK INTO BRICKS INVENTORY RENDERING
-- ============================================================
hook.Add("Initialize", "BRS_UniqueWeapons_HookInventory", function()
    timer.Simple(8, function()
        if not vgui or not vgui.GetControlTable then return end

        -- Hook into itemslot panel
        local itemslot = vgui.GetControlTable("bricks_server_unboxingmenu_itemslot")
        if not itemslot then
            print("[BRS UniqueWeapons] Could not find itemslot panel - will use Think hook")
            return
        end

        local origPaint = itemslot.Paint
        itemslot.Paint = function(self, w, h)
            if origPaint then origPaint(self, w, h) end

            -- Draw our stat overlay on top
            if self.itemTable then
                DrawStatOverlay(self, w, h, self.itemTable)
            end
        end

        print("[BRS UniqueWeapons] Inventory overlay hooked!")
    end)
end)

-- Fallback: periodically try to hook panels
timer.Create("BRS_UniqueWeapons_HookRetry", 5, 12, function()
    if not vgui or not vgui.GetControlTable then return end

    local itemslot = vgui.GetControlTable("bricks_server_unboxingmenu_itemslot")
    if not itemslot or itemslot._BRS_HOOKED then return end

    local origPaint = itemslot.Paint
    itemslot.Paint = function(self, w, h)
        if origPaint then origPaint(self, w, h) end
        if self.itemTable then
            DrawStatOverlay(self, w, h, self.itemTable)
        end
    end

    itemslot._BRS_HOOKED = true
    timer.Remove("BRS_UniqueWeapons_HookRetry")
    print("[BRS UniqueWeapons] Inventory overlay hooked (retry)!")
end)

-- ============================================================
-- INSPECT POPUP
-- ============================================================
function BRS_WEAPONS.OpenInspectPopup(weaponData)
    if IsValid(BRS_WEAPONS.InspectFrame) then
        BRS_WEAPONS.InspectFrame:Remove()
    end

    local rarityDef = BRS_WEAPONS.Rarities[weaponData.rarity] or BRS_WEAPONS.Rarities["Common"]
    local rarityColor = rarityDef.Color
    local quality, avg = BRS_WEAPONS.GetQuality(weaponData.stat_boosters or {})

    local scrW, scrH = ScrW(), ScrH()
    local fw, fh = math.min(550, scrW * 0.4), math.min(420, scrH * 0.5)

    local frame = vgui.Create("DFrame")
    frame:SetSize(fw, fh)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    BRS_WEAPONS.InspectFrame = frame

    frame.Paint = function(_, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(18, 18, 24, 245))
        -- Top accent
        local t = CurTime() * 1.5
        local s = (math.sin(t) + 1) * 0.5
        draw.RoundedBoxEx(10, 0, 0, w, 3, Color(
            Lerp(s, rarityDef.GradientFrom.r, rarityDef.GradientTo.r),
            Lerp(s, rarityDef.GradientFrom.g, rarityDef.GradientTo.g),
            Lerp(s, rarityDef.GradientFrom.b, rarityDef.GradientTo.b), 230
        ), true, true, false, false)
    end

    -- Close button
    local cb = vgui.Create("DButton", frame)
    cb:SetSize(28, 28); cb:SetPos(fw - 34, 6); cb:SetText("")
    cb.Paint = function(s, w, h)
        draw.SimpleText("✕", "BRS_WEP_14", w/2, h/2, s:IsHovered() and Color(255,80,80) or Color(180,180,180), 1, 1)
    end
    cb.DoClick = function() frame:Remove() end

    -- Weapon name + quality
    local np = vgui.Create("DPanel", frame)
    np:SetPos(16, 10); np:SetSize(fw - 50, 50)
    np.Paint = function(_, w, h)
        draw.SimpleText(weaponData.weapon_name or "Unknown", "BRS_WEP_24", 0, 0, Color(255,255,255))
        draw.SimpleText(weaponData.rarity, "BRS_WEP_14", 0, 28, rarityColor)
        draw.SimpleText(quality.name .. " Quality", "BRS_WEP_12", 120, 30, quality.color)
        if avg then
            draw.SimpleText("Avg +" .. math.Round(avg*100,1) .. "%", "BRS_WEP_12", w, 30, Color(180,180,180), TEXT_ALIGN_RIGHT)
        end
    end

    -- Stat boosters
    local sortedStats = {}
    for k, v in pairs(weaponData.stat_boosters or {}) do
        table.insert(sortedStats, {key = k, boost = v})
    end
    table.sort(sortedStats, function(a, b) return a.key < b.key end)

    local sy = 70
    local sh = 46
    local sw = fw - 32

    for i, stat in ipairs(sortedStats) do
        local statDef = BRS_WEAPONS.StatDefs[stat.key]
        if not statDef then continue end

        local ep = vgui.Create("DPanel", frame)
        ep:SetPos(16, sy + (i-1) * (sh + 3)); ep:SetSize(sw, sh)
        local boostCol = BRS_WEAPONS.GetBoostColor(stat.key, stat.boost)
        local boostTxt = BRS_WEAPONS.FormatBoost(stat.key, stat.boost)
        local pct = math.abs(stat.boost)

        ep.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 35, 220))
            draw.SimpleText(statDef.Name, "BRS_WEP_14", 10, 6, Color(220,220,220))
            draw.SimpleText(boostTxt, "BRS_WEP_16", w - 10, 6, boostCol, TEXT_ALIGN_RIGHT)
            -- Bar
            local bx, by, bw, bh = 10, h - 14, w - 20, 8
            draw.RoundedBox(4, bx, by, bw, bh, Color(40,40,50))
            local fill = math.Clamp(pct / 1.2, 0, 1)
            if fill > 0 then
                draw.RoundedBox(4, bx, by, bw * fill, bh, ColorAlpha(boostCol, 180))
            end
        end
    end

    -- UID at bottom
    local uid_p = vgui.Create("DPanel", frame)
    uid_p:SetPos(16, fh - 24); uid_p:SetSize(fw - 32, 20)
    uid_p.Paint = function(_, w, h)
        draw.SimpleText("UID: " .. (weaponData.weapon_uid or "?"), "BRS_WEP_10", 0, 0, Color(80,80,100))
        draw.SimpleText(weaponData.weapon_class or "", "BRS_WEP_10", w, 0, Color(80,80,100), TEXT_ALIGN_RIGHT)
    end
end

print("[BRS UniqueWeapons] Client system loaded (v3 - stat overlay)")
