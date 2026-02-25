--[[
    UNIQUE WEAPON SYSTEM - Client Side (v8 - bricks menu only)
    
    Hooks into bricks panels to add:
    1. Stat bars + quality label on each weapon item slot
    2. "Inspect Stats" option in right-click menu
    3. Inspect popup opened from within bricks menu
]]--

if not CLIENT then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.PlayerWeapons = BRS_WEAPONS.PlayerWeapons or {}

-- ============================================================
-- FONTS
-- ============================================================
surface.CreateFont("BRS_UW_10", { font = "Roboto", size = 10, weight = 500 })
surface.CreateFont("BRS_UW_11", { font = "Roboto", size = 11, weight = 600 })
surface.CreateFont("BRS_UW_12", { font = "Roboto", size = 12, weight = 500 })
surface.CreateFont("BRS_UW_14", { font = "Roboto", size = 14, weight = 700 })
surface.CreateFont("BRS_UW_16", { font = "Roboto", size = 16, weight = 600 })
surface.CreateFont("BRS_UW_20", { font = "Roboto", size = 20, weight = 700 })
surface.CreateFont("BRS_UW_24", { font = "Roboto", size = 24, weight = 700 })

-- ============================================================
-- NETWORK RECEIVERS
-- ============================================================
net.Receive("BRS.UW.Sync", function()
    local len = net.ReadUInt(32)
    local compressed = net.ReadData(len)
    local json = util.Decompress(compressed)
    if not json then return end
    local weapons = util.JSONToTable(json)
    if not weapons then return end
    BRS_WEAPONS.PlayerWeapons = weapons
    print("[BRS UW] Synced " .. table.Count(weapons) .. " unique weapons")
end)

net.Receive("BRS.UW.NewWeapon", function()
    local data = util.JSONToTable(net.ReadString())
    if not data then return end
    BRS_WEAPONS.PlayerWeapons[data.weapon_uid] = data

    if BRS_WEAPONS.GetQuality and BRS_WEAPONS.Rarities then
        local quality, avg = BRS_WEAPONS.GetQuality(data.stat_boosters or {})
        local rarityDef = BRS_WEAPONS.Rarities[data.rarity]
        local col = rarityDef and rarityDef.Color or Color(255,255,255)
        chat.AddText(
            col, "[UNIQUE] ",
            Color(255,255,255), "You unboxed a ",
            col, data.weapon_name,
            Color(180,180,180), " (" .. quality.name .. " Quality, +" .. math.Round((avg or 0)*100,1) .. "% avg)"
        )
    end
end)

-- ============================================================
-- HELPERS
-- ============================================================
function BRS_WEAPONS.FindForClass(weaponClass)
    local bestUID, bestTotal = nil, -1
    for uid, data in pairs(BRS_WEAPONS.PlayerWeapons) do
        if data.weapon_class == weaponClass then
            local total = 0
            for _, v in pairs(data.stat_boosters or {}) do total = total + math.abs(v) end
            if total > bestTotal then bestUID, bestTotal = uid, total end
        end
    end
    return bestUID and BRS_WEAPONS.PlayerWeapons[bestUID] or nil
end

function BRS_WEAPONS.GetWeaponClassFromKey(globalKey)
    if not globalKey or not isstring(globalKey) or not string.StartWith(globalKey, "ITEM_") then return nil end
    if not BRICKS_SERVER or not BRICKS_SERVER.UNBOXING or not BRICKS_SERVER.UNBOXING.Func then return nil end

    local configItem = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey(globalKey)
    if not configItem then return nil end
    if configItem.Type ~= "PermWeapon" and configItem.Type ~= "Weapon" then return nil end

    return configItem.ReqInfo and configItem.ReqInfo[1] or nil
end

-- ============================================================
-- HOOK INTO BRICKS PANELS
-- ============================================================
local _hooked = false

timer.Create("BRS_UW_HookPanels", 1, 60, function()
    if _hooked then timer.Remove("BRS_UW_HookPanels") return end

    local ITEMSLOT = vgui.GetControlTable("bricks_server_unboxingmenu_itemslot")
    if not ITEMSLOT then return end

    -- Hook FillPanel to store globalKey on self
    if not ITEMSLOT._BRS_OrigFillPanel then
        ITEMSLOT._BRS_OrigFillPanel = ITEMSLOT.FillPanel
        ITEMSLOT.FillPanel = function(self, data, amount, actions)
            if data then
                self._BRS_globalKey = istable(data) and data[1] or data
            end
            ITEMSLOT._BRS_OrigFillPanel(self, data, amount, actions)
        end
    end

    -- PaintOver to draw stat overlay on item slots
    ITEMSLOT.PaintOver = function(self, w, h)
        if not self._BRS_globalKey then return end
        if not BRS_WEAPONS.StatDefs or not BRS_WEAPONS.GetQuality then return end

        local weaponClass = BRS_WEAPONS.GetWeaponClassFromKey(self._BRS_globalKey)
        if not weaponClass then return end

        local weaponData = BRS_WEAPONS.FindForClass(weaponClass)
        if not weaponData or not weaponData.stat_boosters then return end

        local boosters = weaponData.stat_boosters
        if table.Count(boosters) == 0 then return end

        local quality, avg = BRS_WEAPONS.GetQuality(boosters)

        -- Quality label above the rarity bar
        local qualY = h - 50
        draw.SimpleText(quality.name, "BRS_UW_11", 8, qualY, quality.color, TEXT_ALIGN_LEFT)
        if avg then
            draw.SimpleText("+" .. math.Round(avg * 100, 1) .. "%", "BRS_UW_10", w - 8, qualY, Color(200, 200, 200, 200), TEXT_ALIGN_RIGHT)
        end

        -- Mini stat bars
        local barY = qualY + 14
        local barH = 3
        local barW = (w - 16) / 5
        local statOrder = { "DMG", "ACC", "MAG", "RPM", "SPD" }

        for i, statKey in ipairs(statOrder) do
            local def = BRS_WEAPONS.StatDefs[statKey]
            if not def then continue end

            local x = 8 + (i - 1) * barW
            local boost = boosters[statKey]

            draw.RoundedBox(2, x, barY, barW - 2, barH, Color(0, 0, 0, 120))

            if boost then
                local fill = math.Clamp(math.abs(boost) / 0.4, 0, 1)
                local col = boost >= 0 and def.Color or Color(255, 50, 50)
                draw.RoundedBox(2, x, barY, (barW - 2) * fill, barH, ColorAlpha(col, 200))
            end

            local labelCol = boost and ColorAlpha(def.Color, 200) or Color(50, 50, 60, 100)
            draw.SimpleText(def.ShortName, "BRS_UW_10", x + (barW - 2) / 2, barY + barH + 1, labelCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
    end

    _hooked = true
    timer.Remove("BRS_UW_HookPanels")
    print("[BRS UW] Hooked into itemslot!")

    -- Hook inventory AddSlot to inject "Inspect Stats" action
    local INVENTORY = vgui.GetControlTable("bricks_server_unboxingmenu_inventory")
    if INVENTORY and not INVENTORY._BRS_OrigAddSlot then
        INVENTORY._BRS_OrigAddSlot = INVENTORY.AddSlot
        INVENTORY.AddSlot = function(self, globalKey, amount, actions)
            local weaponClass = BRS_WEAPONS.GetWeaponClassFromKey(globalKey)
            if weaponClass then
                local weaponData = BRS_WEAPONS.FindForClass(weaponClass)
                if weaponData and weaponData.stat_boosters and table.Count(weaponData.stat_boosters) > 0 then
                    if istable(actions) then
                        table.insert(actions, { "Inspect Stats", function()
                            BRS_WEAPONS.OpenInspectPopup(weaponData)
                        end })
                    end
                end
            end
            INVENTORY._BRS_OrigAddSlot(self, globalKey, amount, actions)
        end
        print("[BRS UW] Hooked into inventory AddSlot!")
    end
end)

-- ============================================================
-- INSPECT POPUP (opened from bricks right-click menu)
-- ============================================================
function BRS_WEAPONS.OpenInspectPopup(weaponData)
    if IsValid(BRS_WEAPONS.InspectFrame) then BRS_WEAPONS.InspectFrame:Remove() end
    if not BRS_WEAPONS.StatDefs then return end

    local rarityDef = BRS_WEAPONS.Rarities[weaponData.rarity] or BRS_WEAPONS.Rarities["Common"]
    local rarityColor = rarityDef.Color
    local quality, avg = BRS_WEAPONS.GetQuality(weaponData.stat_boosters or {})

    local fw, fh = 460, 350
    local frame = vgui.Create("DFrame")
    frame:SetSize(fw, fh)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    BRS_WEAPONS.InspectFrame = frame

    frame.Paint = function(_, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(16, 16, 22, 248))
        local t = CurTime() * 1.5
        local s = (math.sin(t) + 1) * 0.5
        local gr = rarityDef.GradientFrom or rarityColor
        local gt = rarityDef.GradientTo or rarityColor
        draw.RoundedBoxEx(10, 0, 0, w, 3, Color(
            Lerp(s, gr.r, gt.r), Lerp(s, gr.g, gt.g), Lerp(s, gr.b, gt.b), 230
        ), true, true, false, false)
        surface.SetDrawColor(40, 40, 50, 200)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local cb = vgui.Create("DButton", frame)
    cb:SetSize(30, 30); cb:SetPos(fw - 36, 4); cb:SetText("")
    cb.Paint = function(s, w, h)
        draw.SimpleText("X", "BRS_UW_16", w/2, h/2, s:IsHovered() and Color(255,80,80) or Color(140,140,150), 1, 1)
    end
    cb.DoClick = function() frame:Remove() end

    local hp = vgui.Create("DPanel", frame)
    hp:SetPos(16, 8); hp:SetSize(fw - 60, 50)
    hp.Paint = function(_, w, h)
        draw.SimpleText(weaponData.weapon_name or "Unknown", "BRS_UW_24", 0, 0, Color(255,255,255))
        draw.SimpleText(weaponData.rarity, "BRS_UW_14", 0, 28, rarityColor)
        draw.SimpleText(quality.name .. " Quality", "BRS_UW_12", 100, 30, quality.color)
        if avg then
            draw.SimpleText("Avg +" .. math.Round(avg*100,1) .. "%", "BRS_UW_12", w, 30, Color(160,160,170), TEXT_ALIGN_RIGHT)
        end
    end

    local sorted = {}
    for k, v in pairs(weaponData.stat_boosters or {}) do
        table.insert(sorted, {key = k, boost = v})
    end
    table.sort(sorted, function(a, b) return math.abs(b.boost) < math.abs(a.boost) end)

    local sy = 65
    for i, stat in ipairs(sorted) do
        local def = BRS_WEAPONS.StatDefs[stat.key]
        if not def then continue end

        local ep = vgui.Create("DPanel", frame)
        ep:SetPos(16, sy + (i-1) * 48); ep:SetSize(fw - 32, 44)
        local boostCol = BRS_WEAPONS.GetBoostColor(stat.key, stat.boost)
        local boostTxt = BRS_WEAPONS.FormatBoost(stat.key, stat.boost)
        local pct = math.abs(stat.boost)

        ep.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(22, 22, 32, 220))
            draw.SimpleText(def.Name, "BRS_UW_14", 12, 6, Color(210,210,220))
            draw.SimpleText(boostTxt, "BRS_UW_16", w - 12, 6, boostCol, TEXT_ALIGN_RIGHT)
            local bx, by, bw, bh = 12, h - 14, w - 24, 8
            draw.RoundedBox(4, bx, by, bw, bh, Color(35, 35, 45))
            local fill = math.Clamp(pct / 0.5, 0, 1)
            if fill > 0 then
                draw.RoundedBox(4, bx, by, bw * fill, bh, ColorAlpha(boostCol, 180))
            end
        end
    end

    local fp = vgui.Create("DPanel", frame)
    fp:SetPos(16, fh - 28); fp:SetSize(fw - 32, 20)
    fp.Paint = function(_, w, h)
        draw.SimpleText("UID: " .. (weaponData.weapon_uid or "?"), "BRS_UW_10", 0, 2, Color(60,60,80))
        draw.SimpleText(weaponData.weapon_class or "", "BRS_UW_10", w, 2, Color(60,60,80), TEXT_ALIGN_RIGHT)
    end
end

-- ============================================================
-- DEBUG
-- ============================================================
concommand.Add("brs_debug", function()
    print("=== BRS UW Client ===")
    print("Weapons: " .. table.Count(BRS_WEAPONS.PlayerWeapons))
    print("Panel hooked: " .. tostring(_hooked))
    print("StatDefs: " .. tostring(BRS_WEAPONS.StatDefs ~= nil))
    for uid, d in pairs(BRS_WEAPONS.PlayerWeapons) do
        print("  " .. (d.weapon_name or "?") .. " [" .. (d.rarity or "?") .. "] " .. (d.weapon_class or ""))
    end
    print("=====================")
end)

print("[BRS UW] Client loaded (v8 - bricks menu only)!")
