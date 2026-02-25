--[[
    UNIQUE WEAPON SYSTEM - Client Side (v5 - discovery mode)
    First run: discovers bricks panel structure and properties
    Then hooks into the correct panels for stat overlay display
]]--

if not CLIENT then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.PlayerWeapons = BRS_WEAPONS.PlayerWeapons or {}
BRS_WEAPONS._discoveredProp = BRS_WEAPONS._discoveredProp or nil

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
    print("[BRS UniqueWeapons] New weapon: " .. (weaponData.weapon_name or "?") .. " [" .. (weaponData.rarity or "?") .. "]")
end)

net.Receive("BRS.UniqueWeapons.Inspect", function()
    local jsonData = net.ReadString()
    local weaponData = util.JSONToTable(jsonData)
    if not weaponData then return end
    BRS_WEAPONS.OpenInspectPopup(weaponData)
end)

-- ============================================================
-- FIND UNIQUE WEAPON DATA BY WEAPON CLASS
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
    return bestUID and BRS_WEAPONS.PlayerWeapons[bestUID] or nil
end

-- ============================================================
-- STAT OVERLAY DRAWING
-- ============================================================
local function DrawStatOverlay(panel, w, h, weaponClass)
    local weaponData = BRS_WEAPONS.FindForClass(weaponClass)
    if not weaponData or not weaponData.stat_boosters then return end

    local boosters = weaponData.stat_boosters
    if table.Count(boosters) == 0 then return end

    if not BRS_WEAPONS.StatDefs then return end
    if not BRS_WEAPONS.GetQuality then return end

    local quality, avg = BRS_WEAPONS.GetQuality(boosters)

    -- Quality label
    local qualY = h - 48
    draw.SimpleText(quality.name, "BRS_WEP_11", 6, qualY, quality.color, TEXT_ALIGN_LEFT)
    if avg then
        draw.SimpleText("+" .. math.Round(avg * 100, 1) .. "%", "BRS_WEP_10", w - 6, qualY, Color(200, 200, 200, 200), TEXT_ALIGN_RIGHT)
    end

    -- Stat bars
    local barY = qualY + 14
    local barH = 4
    local barW = (w - 12) / 5

    local statOrder = { "DMG", "ACC", "MAG", "RPM", "SPD" }
    for i, statKey in ipairs(statOrder) do
        local statDef = BRS_WEAPONS.StatDefs[statKey]
        if not statDef then continue end

        local x = 6 + (i - 1) * barW
        local boost = boosters[statKey]

        draw.RoundedBox(2, x, barY, barW - 2, barH, Color(40, 40, 40, 200))

        if boost then
            local fillFrac = math.Clamp(math.abs(boost) / 0.5, 0, 1)
            local col = boost >= 0 and statDef.Color or Color(255, 50, 50)
            draw.RoundedBox(2, x, barY, (barW - 2) * fillFrac, barH, ColorAlpha(col, 220))
        end

        local labelCol = boost and ColorAlpha(statDef.Color, 220) or Color(60, 60, 60, 150)
        draw.SimpleText(statDef.ShortName, "BRS_WEP_8", x + (barW - 2) / 2, barY + barH + 1, labelCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    -- Rarity top border
    if BRS_WEAPONS.GetRarityColor then
        local rarityColor = BRS_WEAPONS.GetRarityColor(weaponData.rarity)
        if rarityColor then
            surface.SetDrawColor(rarityColor.r, rarityColor.g, rarityColor.b, 200)
            surface.DrawRect(0, 0, w, 2)
        end
    end
end

-- ============================================================
-- EXTRACT WEAPON CLASS FROM ANY PANEL
-- Tries every possible way bricks might store item data
-- ============================================================
local function ExtractWeaponClass(panel)
    -- Check for direct item table with various property names
    local propNames = {
        "itemTable", "ItemTable", "item", "Item",
        "itemData", "ItemData", "data", "Data",
        "configItem", "ConfigItem", "config",
        "inventoryItem", "InventoryItem",
        "slotItem", "SlotItem"
    }

    for _, prop in ipairs(propNames) do
        local val = rawget(panel:GetTable(), prop)
        if istable(val) then
            -- Look for weapon class in the table
            if val.ReqInfo and val.ReqInfo[1] then
                if (val.Type == "PermWeapon" or val.Type == "Weapon") then
                    return val.ReqInfo[1]
                end
            end
            -- Maybe ReqInfo is stored differently
            if val.weaponClass then return val.weaponClass end
            if val.WeaponClass then return val.WeaponClass end
            if val.class then return val.class end
            if val.Class then return val.Class end
        end
    end

    -- Check globalKey -> config lookup
    local globalKey = rawget(panel:GetTable(), "globalKey") or rawget(panel:GetTable(), "GlobalKey") or rawget(panel:GetTable(), "key") or rawget(panel:GetTable(), "Key")
    if globalKey and isstring(globalKey) and string.StartWith(globalKey, "ITEM_") then
        local itemKey = tonumber(string.match(globalKey, "ITEM_(%d+)"))
        if itemKey and BRICKS_SERVER and BRICKS_SERVER.CONFIG and
           BRICKS_SERVER.CONFIG.UNBOXING and BRICKS_SERVER.CONFIG.UNBOXING.Items then
            local configItem = BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey]
            if configItem and configItem.ReqInfo and configItem.ReqInfo[1] then
                if configItem.Type == "PermWeapon" or configItem.Type == "Weapon" then
                    return configItem.ReqInfo[1]
                end
            end
        end
    end

    return nil
end

-- ============================================================
-- PANEL DISCOVERY & HOOKING
-- ============================================================
local _discovered = false
local _scannedPanels = {}

local function ScanAndHook(parent, depth)
    if not IsValid(parent) then return end
    if depth > 8 then return end -- don't go too deep

    for _, child in ipairs(parent:GetChildren()) do
        if not IsValid(child) then continue end

        -- Skip already hooked panels
        local panelID = tostring(child)
        if _scannedPanels[panelID] then continue end

        local weaponClass = ExtractWeaponClass(child)
        if weaponClass then
            _scannedPanels[panelID] = true

            -- Hook PaintOver so we draw ON TOP of everything
            local origPaintOver = child.PaintOver
            child.PaintOver = function(self, w, h)
                if origPaintOver then origPaintOver(self, w, h) end
                -- Re-extract each frame in case panel data changes
                local wc = ExtractWeaponClass(self)
                if wc then
                    DrawStatOverlay(self, w, h, wc)
                end
            end

            if not _discovered then
                _discovered = true
                -- Log what we found for debugging
                print("[BRS UniqueWeapons] Found item panel! Class: " .. child:GetClassName())
                print("[BRS UniqueWeapons] Weapon: " .. weaponClass)
                local tbl = child:GetTable()
                for k, v in pairs(tbl) do
                    if istable(v) and v.Type then
                        print("[BRS UniqueWeapons] Item property: '" .. k .. "' Type=" .. tostring(v.Type) .. " Name=" .. tostring(v.Name))
                    end
                end
            end
        end

        -- Recurse
        ScanAndHook(child, depth + 1)
    end
end

-- Scan whenever unboxing menu is likely open
local nextScan = 0
hook.Add("Think", "BRS_UniqueWeapons_Scanner", function()
    if CurTime() < nextScan then return end
    nextScan = CurTime() + 0.3

    -- Must have weapon data and stat defs
    if table.Count(BRS_WEAPONS.PlayerWeapons) == 0 then return end
    if not BRS_WEAPONS.StatDefs then return end

    -- Scan all top-level visible panels
    for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
        if IsValid(panel) and panel:IsVisible() then
            local w, h = panel:GetSize()
            if w > 400 and h > 250 then
                ScanAndHook(panel, 0)
            end
        end
    end
end)

-- Clear scanned panels cache when menu closes/reopens
hook.Add("Think", "BRS_UniqueWeapons_ClearCache", function()
    -- Every 2 seconds, clean up invalid panels from cache
    if CurTime() % 2 > 0.05 then return end
    for panelID, _ in pairs(_scannedPanels) do
        -- Panel IDs include memory addresses, can't validate them
        -- Just clear periodically to re-scan
    end
end)

-- Force clear cache every 5 seconds so new panels get picked up
timer.Create("BRS_UniqueWeapons_ResetScan", 5, 0, function()
    _scannedPanels = {}
end)

-- ============================================================
-- DEEP DISCOVERY DEBUG COMMAND
-- Dumps ALL properties of ALL panels in the bricks menu
-- ============================================================
concommand.Add("brs_discover", function()
    print("=== BRS Panel Discovery ===")
    print("Weapons in cache: " .. table.Count(BRS_WEAPONS.PlayerWeapons))
    print("StatDefs loaded: " .. tostring(BRS_WEAPONS.StatDefs ~= nil))
    print("GetQuality loaded: " .. tostring(BRS_WEAPONS.GetQuality ~= nil))
    print("BRICKS_SERVER exists: " .. tostring(BRICKS_SERVER ~= nil))

    if BRICKS_SERVER and BRICKS_SERVER.CONFIG and BRICKS_SERVER.CONFIG.UNBOXING then
        print("CONFIG.UNBOXING.Items: " .. tostring(BRICKS_SERVER.CONFIG.UNBOXING.Items ~= nil))
        if BRICKS_SERVER.CONFIG.UNBOXING.Items then
            local count = 0
            for _ in pairs(BRICKS_SERVER.CONFIG.UNBOXING.Items) do count = count + 1 end
            print("  Item count: " .. count)
        end
    end

    local panelCount = 0
    local itemPanelCount = 0

    local function DumpPanel(panel, depth, maxDepth)
        if not IsValid(panel) then return end
        if depth > maxDepth then return end

        local indent = string.rep("  ", depth)
        local className = panel:GetClassName()
        local w, h = panel:GetSize()

        -- Check for any table properties that might be item data
        local tbl = panel:GetTable()
        local interesting = {}
        for k, v in pairs(tbl) do
            if istable(v) then
                -- Check if this table looks like item config
                if v.Name or v.Type or v.Rarity or v.ReqInfo or v.globalKey then
                    interesting[k] = v
                end
            elseif isstring(v) and (string.StartWith(v, "ITEM_") or string.find(v, "m9k_")) then
                interesting[k] = v
            end
        end

        if table.Count(interesting) > 0 or string.find(className, "ricks") or string.find(className, "nboxing") or string.find(className, "lot") then
            panelCount = panelCount + 1
            print(indent .. className .. " [" .. w .. "x" .. h .. "]")
            for k, v in pairs(interesting) do
                if istable(v) then
                    itemPanelCount = itemPanelCount + 1
                    print(indent .. "  ." .. k .. " = {")
                    for k2, v2 in pairs(v) do
                        if istable(v2) then
                            print(indent .. "    " .. tostring(k2) .. " = {" .. table.concat(v2, ", ") .. "}")
                        else
                            print(indent .. "    " .. tostring(k2) .. " = " .. tostring(v2))
                        end
                    end
                    print(indent .. "  }")
                else
                    print(indent .. "  ." .. k .. " = " .. tostring(v))
                end
            end
        end

        for _, child in ipairs(panel:GetChildren()) do
            DumpPanel(child, depth + 1, maxDepth)
        end
    end

    for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
        if IsValid(panel) and panel:IsVisible() then
            local w, h = panel:GetSize()
            if w > 400 and h > 250 then
                print("\n--- Top-level panel: " .. panel:GetClassName() .. " [" .. w .. "x" .. h .. "] ---")
                DumpPanel(panel, 0, 6)
            end
        end
    end

    print("\nTotal interesting panels: " .. panelCount)
    print("Panels with item data: " .. itemPanelCount)
    print("===========================")
end)

-- ============================================================
-- QUICK DEBUG
-- ============================================================
concommand.Add("brs_debug", function()
    print("=== BRS UniqueWeapons Debug ===")
    print("Weapons synced: " .. table.Count(BRS_WEAPONS.PlayerWeapons))
    for uid, data in pairs(BRS_WEAPONS.PlayerWeapons) do
        local boosters = {}
        for k, v in pairs(data.stat_boosters or {}) do
            table.insert(boosters, k .. ":" .. math.Round(v*100,1) .. "%")
        end
        print("  " .. (data.weapon_name or "?") .. " [" .. (data.rarity or "?") .. "] " .. table.concat(boosters, " "))
    end
    print("StatDefs: " .. tostring(BRS_WEAPONS.StatDefs ~= nil))
    print("GetQuality: " .. tostring(BRS_WEAPONS.GetQuality ~= nil))
    print("Panels scanned: " .. table.Count(_scannedPanels))
    print("===============================")
end)

-- ============================================================
-- INSPECT POPUP
-- ============================================================
function BRS_WEAPONS.OpenInspectPopup(weaponData)
    if IsValid(BRS_WEAPONS.InspectFrame) then BRS_WEAPONS.InspectFrame:Remove() end

    local rarityDef = BRS_WEAPONS.Rarities[weaponData.rarity] or BRS_WEAPONS.Rarities["Common"]
    local rarityColor = rarityDef.Color
    local quality, avg = BRS_WEAPONS.GetQuality(weaponData.stat_boosters or {})

    local fw, fh = math.min(550, ScrW() * 0.4), math.min(420, ScrH() * 0.5)

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
        local t = CurTime() * 1.5
        local s = (math.sin(t) + 1) * 0.5
        draw.RoundedBoxEx(10, 0, 0, w, 3, Color(
            Lerp(s, rarityDef.GradientFrom.r, rarityDef.GradientTo.r),
            Lerp(s, rarityDef.GradientFrom.g, rarityDef.GradientTo.g),
            Lerp(s, rarityDef.GradientFrom.b, rarityDef.GradientTo.b), 230
        ), true, true, false, false)
    end

    local cb = vgui.Create("DButton", frame)
    cb:SetSize(28, 28); cb:SetPos(fw - 34, 6); cb:SetText("")
    cb.Paint = function(s, w, h)
        draw.SimpleText("X", "BRS_WEP_14", w/2, h/2, s:IsHovered() and Color(255,80,80) or Color(180,180,180), 1, 1)
    end
    cb.DoClick = function() frame:Remove() end

    local np = vgui.Create("DPanel", frame)
    np:SetPos(16, 10); np:SetSize(fw - 50, 50)
    np.Paint = function(_, w, h)
        draw.SimpleText(weaponData.weapon_name or "Unknown", "BRS_WEP_24", 0, 0, Color(255,255,255))
        draw.SimpleText(weaponData.rarity, "BRS_WEP_14", 0, 28, rarityColor)
        draw.SimpleText(quality.name .. " Quality", "BRS_WEP_12", 120, 30, quality.color)
        if avg then
            draw.SimpleText("+" .. math.Round(avg*100,1) .. "%", "BRS_WEP_12", w, 30, Color(180,180,180), TEXT_ALIGN_RIGHT)
        end
    end

    local sortedStats = {}
    for k, v in pairs(weaponData.stat_boosters or {}) do
        table.insert(sortedStats, {key = k, boost = v})
    end
    table.sort(sortedStats, function(a, b) return a.key < b.key end)

    local sy = 70
    for i, stat in ipairs(sortedStats) do
        local statDef = BRS_WEAPONS.StatDefs[stat.key]
        if not statDef then continue end

        local ep = vgui.Create("DPanel", frame)
        ep:SetPos(16, sy + (i-1) * 49); ep:SetSize(fw - 32, 46)
        local boostCol = BRS_WEAPONS.GetBoostColor(stat.key, stat.boost)
        local boostTxt = BRS_WEAPONS.FormatBoost(stat.key, stat.boost)
        local pct = math.abs(stat.boost)

        ep.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 35, 220))
            draw.SimpleText(statDef.Name, "BRS_WEP_14", 10, 6, Color(220,220,220))
            draw.SimpleText(boostTxt, "BRS_WEP_16", w - 10, 6, boostCol, TEXT_ALIGN_RIGHT)
            local bx, by, bw, bh = 10, h - 14, w - 20, 8
            draw.RoundedBox(4, bx, by, bw, bh, Color(40,40,50))
            local fill = math.Clamp(pct / 1.2, 0, 1)
            if fill > 0 then
                draw.RoundedBox(4, bx, by, bw * fill, bh, ColorAlpha(boostCol, 180))
            end
        end
    end

    local uid_p = vgui.Create("DPanel", frame)
    uid_p:SetPos(16, fh - 24); uid_p:SetSize(fw - 32, 20)
    uid_p.Paint = function(_, w, h)
        draw.SimpleText("UID: " .. (weaponData.weapon_uid or "?"), "BRS_WEP_10", 0, 0, Color(80,80,100))
        draw.SimpleText(weaponData.weapon_class or "", "BRS_WEP_10", w, 0, Color(80,80,100), TEXT_ALIGN_RIGHT)
    end
end

print("[BRS UniqueWeapons] Client system loaded (v5 - discovery mode)")
