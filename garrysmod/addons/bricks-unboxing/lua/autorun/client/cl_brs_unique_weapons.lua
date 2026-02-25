--[[
    UNIQUE WEAPON SYSTEM - Client Side (v7 - hooks into bricks properly)
    
    Now that we know bricks panel structure:
    - bricks_server_unboxingmenu_itemslot has FillPanel(data, amount, actions)
    - data is globalKey string like "ITEM_65"
    - configItemTable is LOCAL (not on self)
    - We hook FillPanel to store globalKey, then use PaintOver for overlay
    - We hook inventory AddSlot to inject "Inspect" into actions menu
]]--

if not CLIENT then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.PlayerWeapons = BRS_WEAPONS.PlayerWeapons or {}

-- ============================================================
-- FONTS
-- ============================================================
surface.CreateFont("BRS_HUD_10", { font = "Roboto", size = 10, weight = 500 })
surface.CreateFont("BRS_HUD_11", { font = "Roboto", size = 11, weight = 600 })
surface.CreateFont("BRS_HUD_12", { font = "Roboto", size = 12, weight = 500 })
surface.CreateFont("BRS_HUD_13", { font = "Roboto", size = 13, weight = 600 })
surface.CreateFont("BRS_HUD_14", { font = "Roboto", size = 14, weight = 700 })
surface.CreateFont("BRS_HUD_16", { font = "Roboto", size = 16, weight = 600 })
surface.CreateFont("BRS_HUD_20", { font = "Roboto", size = 20, weight = 700 })
surface.CreateFont("BRS_HUD_24", { font = "Roboto", size = 24, weight = 700 })

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

    -- Chat notification
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
-- FIND UNIQUE WEAPON FOR A CLASS
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

-- Given a globalKey like "ITEM_65", find the weapon class from config
function BRS_WEAPONS.GetWeaponClassFromKey(globalKey)
    if not globalKey or not isstring(globalKey) then return nil end
    if not string.StartWith(globalKey, "ITEM_") then return nil end
    if not BRICKS_SERVER or not BRICKS_SERVER.UNBOXING or not BRICKS_SERVER.UNBOXING.Func then return nil end

    local configItem = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey(globalKey)
    if not configItem then return nil end
    if configItem.Type ~= "PermWeapon" and configItem.Type ~= "Weapon" then return nil end

    return configItem.ReqInfo and configItem.ReqInfo[1] or nil
end

-- ============================================================
-- HOOK INTO BRICKS ITEM SLOT PANEL
-- Waits for bricks to register the panel, then modifies it
-- ============================================================

local _panelHooked = false

timer.Create("BRS_UW_HookPanels", 1, 60, function()
    if _panelHooked then timer.Remove("BRS_UW_HookPanels") return end

    local ITEMSLOT = vgui.GetControlTable("bricks_server_unboxingmenu_itemslot")
    if not ITEMSLOT then return end

    -- ==========================================
    -- HOOK 1: FillPanel - store globalKey on self
    -- ==========================================
    if not ITEMSLOT._BRS_OrigFillPanel then
        ITEMSLOT._BRS_OrigFillPanel = ITEMSLOT.FillPanel

        ITEMSLOT.FillPanel = function(self, data, amount, actions)
            -- Store the globalKey for our overlay
            if data then
                if istable(data) then
                    self._BRS_globalKey = data[1]
                else
                    self._BRS_globalKey = data
                end
            end

            -- Call original - all bricks functionality preserved
            ITEMSLOT._BRS_OrigFillPanel(self, data, amount, actions)
        end
    end

    -- ==========================================
    -- HOOK 2: PaintOver - draw stat overlay on top
    -- ==========================================
    ITEMSLOT.PaintOver = function(self, w, h)
        if not self._BRS_globalKey then return end
        if not BRS_WEAPONS.StatDefs then return end
        if not BRS_WEAPONS.GetQuality then return end

        local weaponClass = BRS_WEAPONS.GetWeaponClassFromKey(self._BRS_globalKey)
        if not weaponClass then return end

        local weaponData = BRS_WEAPONS.FindForClass(weaponClass)
        if not weaponData or not weaponData.stat_boosters then return end

        local boosters = weaponData.stat_boosters
        if table.Count(boosters) == 0 then return end

        local quality, avg = BRS_WEAPONS.GetQuality(boosters)

        -- Quality label (bottom area, above rarity bar)
        local qualY = h - 50
        draw.SimpleText(quality.name, "BRS_HUD_11", 8, qualY, quality.color, TEXT_ALIGN_LEFT)
        if avg then
            draw.SimpleText("+" .. math.Round(avg * 100, 1) .. "%", "BRS_HUD_10", w - 8, qualY, Color(200, 200, 200, 200), TEXT_ALIGN_RIGHT)
        end

        -- Mini stat bars
        local barY = qualY + 14
        local barH = 3
        local totalBarW = w - 16
        local barW = totalBarW / 5

        local statOrder = { "DMG", "ACC", "MAG", "RPM", "SPD" }
        for i, statKey in ipairs(statOrder) do
            local def = BRS_WEAPONS.StatDefs[statKey]
            if not def then continue end

            local x = 8 + (i - 1) * barW
            local boost = boosters[statKey]

            -- Bar background
            draw.RoundedBox(2, x, barY, barW - 2, barH, Color(0, 0, 0, 120))

            -- Bar fill
            if boost then
                local fill = math.Clamp(math.abs(boost) / 0.4, 0, 1)
                local col = boost >= 0 and def.Color or Color(255, 50, 50)
                draw.RoundedBox(2, x, barY, (barW - 2) * fill, barH, ColorAlpha(col, 200))
            end

            -- Stat label
            local labelCol = boost and ColorAlpha(def.Color, 200) or Color(50, 50, 60, 100)
            draw.SimpleText(def.ShortName, "BRS_HUD_10", x + (barW - 2) / 2, barY + barH + 1, labelCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
    end

    _panelHooked = true
    timer.Remove("BRS_UW_HookPanels")
    print("[BRS UW] Hooked into bricks_server_unboxingmenu_itemslot!")

    -- ==========================================
    -- HOOK 3: Inventory AddSlot - inject Inspect action
    -- ==========================================
    local INVENTORY = vgui.GetControlTable("bricks_server_unboxingmenu_inventory")
    if INVENTORY and not INVENTORY._BRS_OrigAddSlot then
        INVENTORY._BRS_OrigAddSlot = INVENTORY.AddSlot

        INVENTORY.AddSlot = function(self, globalKey, amount, actions)
            -- Inject "Inspect" action for weapons that have unique data
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

            -- Call original
            INVENTORY._BRS_OrigAddSlot(self, globalKey, amount, actions)
        end

        print("[BRS UW] Hooked into bricks_server_unboxingmenu_inventory!")
    end
end)

-- ============================================================
-- HUD OVERLAY - Shows stats on current held weapon
-- ============================================================

local hudAlpha = 0

hook.Add("HUDPaint", "BRS_UW_WeaponHUD", function()
    if not BRS_WEAPONS.StatDefs or not BRS_WEAPONS.GetQuality then return end

    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then hudAlpha = Lerp(FrameTime() * 8, hudAlpha, 0) return end

    local wep = ply:GetActiveWeapon()
    local weaponData = nil
    local hudTarget = 0

    if IsValid(wep) then
        weaponData = BRS_WEAPONS.FindForClass(wep:GetClass())
        if weaponData and weaponData.stat_boosters and table.Count(weaponData.stat_boosters) > 0 then
            hudTarget = 255
        end
    end

    hudAlpha = Lerp(FrameTime() * 8, hudAlpha, hudTarget)
    if hudAlpha < 1 then return end
    if not weaponData then return end

    local boosters = weaponData.stat_boosters
    local quality, avg = BRS_WEAPONS.GetQuality(boosters)
    local rarityDef = BRS_WEAPONS.Rarities[weaponData.rarity]
    local rarityColor = rarityDef and rarityDef.Color or Color(200,200,200)

    local scrW, scrH = ScrW(), ScrH()
    local pw, ph = 220, 120
    local px, py = scrW - pw - 20, scrH - ph - 80
    local a = math.floor(hudAlpha)

    draw.RoundedBox(8, px, py, pw, ph, Color(12, 12, 18, math.floor(a * 0.85)))
    surface.SetDrawColor(rarityColor.r, rarityColor.g, rarityColor.b, a)
    surface.DrawRect(px, py, pw, 2)

    draw.SimpleText(weaponData.weapon_name, "BRS_HUD_14", px + 8, py + 6, ColorAlpha(Color(255,255,255), a))
    draw.SimpleText(weaponData.rarity, "BRS_HUD_12", px + 8, py + 22, ColorAlpha(rarityColor, a))
    draw.SimpleText(quality.name .. " +" .. math.Round((avg or 0)*100,1) .. "%", "BRS_HUD_12", px + pw - 8, py + 22, ColorAlpha(quality.color, a), TEXT_ALIGN_RIGHT)

    local statOrder = { "DMG", "ACC", "MAG", "RPM", "SPD" }
    local barStartY = py + 40

    for i, statKey in ipairs(statOrder) do
        local def = BRS_WEAPONS.StatDefs[statKey]
        if not def then continue end
        local boost = boosters[statKey]
        local by = barStartY + (i-1) * 15

        draw.SimpleText(def.ShortName, "BRS_HUD_10", px + 8, by, ColorAlpha(boost and def.Color or Color(60,60,70), a))
        draw.RoundedBox(3, px + 42, by, pw - 50, 10, ColorAlpha(Color(30, 30, 40), a))

        if boost then
            local fill = math.Clamp(math.abs(boost) / 0.4, 0, 1)
            local col = boost >= 0 and def.Color or Color(255, 50, 50)
            draw.RoundedBox(3, px + 42, by, (pw - 50) * fill, 10, ColorAlpha(col, math.floor(a * 0.8)))
            draw.SimpleText((boost >= 0 and "+" or "") .. math.Round(boost*100,1) .. "%", "BRS_HUD_10", px + pw - 8, by, ColorAlpha(Color(220,220,220), a), TEXT_ALIGN_RIGHT)
        end
    end
end)

-- ============================================================
-- !inspect and !weapons CHAT COMMANDS
-- ============================================================

hook.Add("OnPlayerChat", "BRS_UW_ChatCmds", function(ply, text)
    if ply ~= LocalPlayer() then return end
    text = string.lower(string.Trim(text))

    if text == "!inspect" or text == "/inspect" then
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) then return end
        local data = BRS_WEAPONS.FindForClass(wep:GetClass())
        if data then
            BRS_WEAPONS.OpenInspectPopup(data)
        else
            chat.AddText(Color(255,100,100), "[UNIQUE] ", Color(200,200,200), "No unique stats on this weapon.")
        end
    elseif text == "!weapons" or text == "/weapons" then
        BRS_WEAPONS.OpenWeaponsList()
    end
end)

-- ============================================================
-- INSPECT POPUP
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
        draw.SimpleText("X", "BRS_HUD_16", w/2, h/2, s:IsHovered() and Color(255,80,80) or Color(140,140,150), 1, 1)
    end
    cb.DoClick = function() frame:Remove() end

    local hp = vgui.Create("DPanel", frame)
    hp:SetPos(16, 8); hp:SetSize(fw - 60, 50)
    hp.Paint = function(_, w, h)
        draw.SimpleText(weaponData.weapon_name or "Unknown", "BRS_HUD_24", 0, 0, Color(255,255,255))
        draw.SimpleText(weaponData.rarity, "BRS_HUD_14", 0, 28, rarityColor)
        draw.SimpleText(quality.name .. " Quality", "BRS_HUD_12", 100, 30, quality.color)
        if avg then
            draw.SimpleText("Avg +" .. math.Round(avg*100,1) .. "%", "BRS_HUD_12", w, 30, Color(160,160,170), TEXT_ALIGN_RIGHT)
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
            draw.SimpleText(def.Name, "BRS_HUD_14", 12, 6, Color(210,210,220))
            draw.SimpleText(boostTxt, "BRS_HUD_16", w - 12, 6, boostCol, TEXT_ALIGN_RIGHT)
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
        draw.SimpleText("UID: " .. (weaponData.weapon_uid or "?"), "BRS_HUD_10", 0, 2, Color(60,60,80))
        draw.SimpleText(weaponData.weapon_class or "", "BRS_HUD_10", w, 2, Color(60,60,80), TEXT_ALIGN_RIGHT)
    end
end

-- ============================================================
-- !weapons LIST
-- ============================================================
function BRS_WEAPONS.OpenWeaponsList()
    if IsValid(BRS_WEAPONS.ListFrame) then BRS_WEAPONS.ListFrame:Remove() end
    if not BRS_WEAPONS.StatDefs then return end

    local fw, fh = 500, 400
    local frame = vgui.Create("DFrame")
    frame:SetSize(fw, fh); frame:Center(); frame:SetTitle(""); frame:SetDraggable(true); frame:MakePopup(); frame:ShowCloseButton(false)
    BRS_WEAPONS.ListFrame = frame

    frame.Paint = function(_, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(16, 16, 22, 248))
        draw.RoundedBoxEx(10, 0, 0, w, 3, Color(100, 140, 255, 200), true, true, false, false)
        draw.SimpleText("YOUR UNIQUE WEAPONS", "BRS_HUD_16", 16, 8, Color(200,200,220))
        surface.SetDrawColor(40, 40, 50, 200); surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local cb = vgui.Create("DButton", frame)
    cb:SetSize(30, 30); cb:SetPos(fw - 36, 4); cb:SetText("")
    cb.Paint = function(s, w, h) draw.SimpleText("X", "BRS_HUD_16", w/2, h/2, s:IsHovered() and Color(255,80,80) or Color(140,140,150), 1, 1) end
    cb.DoClick = function() frame:Remove() end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(8, 35); scroll:SetSize(fw - 16, fh - 45)

    local rarityOrder = { Mythical=1, Glitched=2, Legendary=3, Epic=4, Rare=5, Uncommon=6, Common=7 }
    local list = {}
    for _, data in pairs(BRS_WEAPONS.PlayerWeapons) do table.insert(list, data) end
    table.sort(list, function(a, b) return (rarityOrder[a.rarity] or 99) < (rarityOrder[b.rarity] or 99) end)

    if #list == 0 then
        local e = vgui.Create("DPanel", scroll); e:SetSize(fw-20, 40); e:Dock(TOP)
        e.Paint = function(_, w, h) draw.SimpleText("No unique weapons yet!", "BRS_HUD_14", w/2, h/2, Color(100,100,120), 1, 1) end
        return
    end

    for _, data in ipairs(list) do
        local rd = BRS_WEAPONS.Rarities[data.rarity] or BRS_WEAPONS.Rarities["Common"]
        local q, avg = BRS_WEAPONS.GetQuality(data.stat_boosters or {})

        local row = vgui.Create("DButton", scroll)
        row:SetSize(fw-20, 50); row:Dock(TOP); row:DockMargin(4,2,4,2); row:SetText("")
        row.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, s:IsHovered() and Color(30,30,42) or Color(22,22,32))
            surface.SetDrawColor(rd.Color.r, rd.Color.g, rd.Color.b, 180); surface.DrawRect(0, 0, 3, h)
            draw.SimpleText(data.weapon_name, "BRS_HUD_14", 12, 6, Color(240,240,240))
            draw.SimpleText(data.rarity, "BRS_HUD_12", 12, 24, rd.Color)
            draw.SimpleText(q.name, "BRS_HUD_13", w-12, 6, q.color, TEXT_ALIGN_RIGHT)
            draw.SimpleText("+" .. math.Round((avg or 0)*100,1) .. "%", "BRS_HUD_12", w-12, 24, Color(160,160,170), TEXT_ALIGN_RIGHT)
        end
        row.DoClick = function() BRS_WEAPONS.OpenInspectPopup(data) end
    end
end

-- ============================================================
-- DEBUG
-- ============================================================
concommand.Add("brs_debug", function()
    print("=== BRS UW Client ===")
    print("Weapons: " .. table.Count(BRS_WEAPONS.PlayerWeapons))
    print("Panel hooked: " .. tostring(_panelHooked))
    print("StatDefs: " .. tostring(BRS_WEAPONS.StatDefs ~= nil))
    for uid, d in pairs(BRS_WEAPONS.PlayerWeapons) do
        print("  " .. (d.weapon_name or "?") .. " [" .. (d.rarity or "?") .. "] " .. (d.weapon_class or ""))
    end
    print("=====================")
end)

print("[BRS UW] Client loaded (v7 - bricks integration)!")
