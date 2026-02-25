--[[
    UNIQUE WEAPON SYSTEM - Client (v9 - MUTINY style)
    
    Hooks into bricks menu to add:
    1. Rarity-colored border around weapon cards
    2. Quality label + avg boost on each card
    3. 5 colored stat bars (DMG/ACC/MAG/RPM/SPD)
    4. "Inspect Stats" in right-click menu (no equip needed)
    5. Detailed inspect popup matching MUTINY style
]]--

if not CLIENT then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.PlayerWeapons = BRS_WEAPONS.PlayerWeapons or {}

-- ============================================================
-- FONTS
-- ============================================================
surface.CreateFont("BRS_UW_9",  { font = "Roboto", size = 9,  weight = 600 })
surface.CreateFont("BRS_UW_10", { font = "Roboto", size = 10, weight = 600 })
surface.CreateFont("BRS_UW_11", { font = "Roboto", size = 11, weight = 700 })
surface.CreateFont("BRS_UW_12", { font = "Roboto", size = 12, weight = 500 })
surface.CreateFont("BRS_UW_13", { font = "Roboto", size = 13, weight = 600 })
surface.CreateFont("BRS_UW_14", { font = "Roboto", size = 14, weight = 700 })
surface.CreateFont("BRS_UW_16", { font = "Roboto", size = 16, weight = 600 })
surface.CreateFont("BRS_UW_18", { font = "Roboto", size = 18, weight = 700 })
surface.CreateFont("BRS_UW_22", { font = "Roboto", size = 22, weight = 700 })

-- ============================================================
-- NET
-- ============================================================
net.Receive("BRS.UW.Sync", function()
    local len = net.ReadUInt(32)
    local compressed = net.ReadData(len)
    local json = util.Decompress(compressed)
    if not json then return end
    BRS_WEAPONS.PlayerWeapons = util.JSONToTable(json) or {}
    print("[BRS UW] Synced " .. table.Count(BRS_WEAPONS.PlayerWeapons) .. " unique weapons")
end)

net.Receive("BRS.UW.NewWeapon", function()
    local data = util.JSONToTable(net.ReadString())
    if not data then return end
    BRS_WEAPONS.PlayerWeapons[data.weapon_uid] = data

    if BRS_WEAPONS.GetQuality and BRS_WEAPONS.Rarities then
        local q, avg = BRS_WEAPONS.GetQuality(data.stat_boosters or {})
        local rd = BRS_WEAPONS.Rarities[data.rarity]
        local col = rd and rd.Color or Color(255,255,255)
        chat.AddText(col, "[UNIQUE] ", Color(255,255,255), data.weapon_name,
            Color(180,180,180), " | " .. q.name .. " +" .. math.Round((avg or 0)*100,1) .. "%")
    end
end)

-- ============================================================
-- HELPERS
-- ============================================================
function BRS_WEAPONS.FindForClass(wepClass)
    local best, bestT = nil, -1
    for uid, d in pairs(BRS_WEAPONS.PlayerWeapons) do
        if d.weapon_class == wepClass then
            local t = 0
            for _, v in pairs(d.stat_boosters or {}) do t = t + math.abs(v) end
            if t > bestT then best, bestT = uid, t end
        end
    end
    return best and BRS_WEAPONS.PlayerWeapons[best] or nil
end

function BRS_WEAPONS.GetWeaponClassFromKey(gk)
    if not gk or not isstring(gk) or not string.StartWith(gk, "ITEM_") then return nil end
    if not BRICKS_SERVER or not BRICKS_SERVER.UNBOXING or not BRICKS_SERVER.UNBOXING.Func then return nil end
    local cfg = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey(gk)
    if not cfg then return nil end
    if cfg.Type ~= "PermWeapon" and cfg.Type ~= "Weapon" then return nil end
    return cfg.ReqInfo and cfg.ReqInfo[1] or nil
end

function BRS_WEAPONS.GetWeaponDataFromKey(gk)
    local cls = BRS_WEAPONS.GetWeaponClassFromKey(gk)
    if not cls then return nil end
    return BRS_WEAPONS.FindForClass(cls)
end

-- ============================================================
-- HOOK INTO BRICKS PANELS
-- ============================================================
local _hooked = false

timer.Create("BRS_UW_HookPanels", 1, 60, function()
    if _hooked then timer.Remove("BRS_UW_HookPanels") return end

    local SLOT = vgui.GetControlTable("bricks_server_unboxingmenu_itemslot")
    if not SLOT then return end

    -- HOOK FillPanel: store globalKey on self
    if not SLOT._BRS_OrigFill then
        SLOT._BRS_OrigFill = SLOT.FillPanel
        SLOT.FillPanel = function(self, data, amount, actions)
            if data then
                self._BRS_gk = istable(data) and data[1] or data
            end
            SLOT._BRS_OrigFill(self, data, amount, actions)
        end
    end

    -- HOOK PaintOver: draw quality, stat bars, rarity border
    SLOT.PaintOver = function(self, w, h)
        if not self._BRS_gk then return end
        if not BRS_WEAPONS.StatDefs or not BRS_WEAPONS.GetQuality then return end

        local wd = BRS_WEAPONS.GetWeaponDataFromKey(self._BRS_gk)
        if not wd or not wd.stat_boosters or table.Count(wd.stat_boosters) == 0 then return end

        local boosters = wd.stat_boosters
        local quality, avg = BRS_WEAPONS.GetQuality(boosters)
        local rd = BRS_WEAPONS.Rarities[wd.rarity]
        local rc = rd and rd.Color or Color(180,180,180)

        -- Rarity colored border (like MUTINY)
        local borderA = 180
        surface.SetDrawColor(rc.r, rc.g, rc.b, borderA)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        -- Quality label (bottom left) + Avg (bottom right)
        local infoY = h - 52

        -- Background strip for readability
        draw.RoundedBox(0, 0, infoY - 2, w, 14, Color(0, 0, 0, 140))

        draw.SimpleText(quality.name, "BRS_UW_11", 6, infoY, quality.color, TEXT_ALIGN_LEFT)
        if avg then
            draw.SimpleText("Avg +" .. math.Round(avg * 100, 1) .. "%", "BRS_UW_9", w - 6, infoY + 1, Color(200, 200, 200, 220), TEXT_ALIGN_RIGHT)
        end

        -- Stat bars (like MUTINY - colored bars with labels)
        local barY = infoY + 14
        local barH = 4
        local barW = (w - 14) / 5
        local statOrder = { "DMG", "ACC", "MAG", "RPM", "SPD" }

        for i, sk in ipairs(statOrder) do
            local def = BRS_WEAPONS.StatDefs[sk]
            if not def then continue end

            local x = 5 + (i - 1) * barW + (i - 1) * 1
            local boost = boosters[sk]

            -- Bar background
            draw.RoundedBox(1, x, barY, barW, barH, Color(20, 20, 25, 200))

            -- Bar fill
            if boost then
                local fill = math.Clamp(math.abs(boost) / 0.4, 0, 1)
                draw.RoundedBox(1, x, barY, barW * fill, barH, ColorAlpha(def.Color, 220))
            end

            -- Stat label under bar (colored like MUTINY)
            local lc = boost and def.Color or Color(60, 60, 70, 120)
            draw.SimpleText(def.ShortName, "BRS_UW_9", x + barW/2, barY + barH + 1, ColorAlpha(lc, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
    end

    _hooked = true
    timer.Remove("BRS_UW_HookPanels")
    print("[BRS UW] Itemslot hooked!")

    -- HOOK inventory AddSlot: inject "Inspect Stats" action
    local INV = vgui.GetControlTable("bricks_server_unboxingmenu_inventory")
    if INV and not INV._BRS_OrigAddSlot then
        INV._BRS_OrigAddSlot = INV.AddSlot
        INV.AddSlot = function(self, gk, amount, actions)
            local wd = BRS_WEAPONS.GetWeaponDataFromKey(gk)
            if wd and wd.stat_boosters and table.Count(wd.stat_boosters) > 0 then
                if istable(actions) then
                    table.insert(actions, { "Inspect Stats", function()
                        BRS_WEAPONS.OpenInspectPopup(wd)
                    end })
                end
            end
            INV._BRS_OrigAddSlot(self, gk, amount, actions)
        end
        print("[BRS UW] Inventory AddSlot hooked!")
    end
end)

-- ============================================================
-- INSPECT POPUP (MUTINY style)
-- ============================================================
function BRS_WEAPONS.OpenInspectPopup(wd)
    if IsValid(BRS_WEAPONS.InspectFrame) then BRS_WEAPONS.InspectFrame:Remove() end
    if not BRS_WEAPONS.StatDefs then return end

    local rd = BRS_WEAPONS.Rarities[wd.rarity] or BRS_WEAPONS.Rarities["Common"]
    local rc = rd.Color
    local gr = rd.GradientFrom or rc
    local gt = rd.GradientTo or rc
    local quality, avg = BRS_WEAPONS.GetQuality(wd.stat_boosters or {})

    local fw, fh = 380, 420
    local frame = vgui.Create("DFrame")
    frame:SetSize(fw, fh)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    BRS_WEAPONS.InspectFrame = frame

    -- Animated rarity border
    frame.Paint = function(_, w, h)
        -- Background
        draw.RoundedBox(8, 0, 0, w, h, Color(14, 14, 20, 250))

        -- Animated border
        local t = CurTime() * 2
        local s = (math.sin(t) + 1) * 0.5
        local bc = Color(
            Lerp(s, gr.r, gt.r),
            Lerp(s, gr.g, gt.g),
            Lerp(s, gr.b, gt.b), 200
        )
        surface.SetDrawColor(bc)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        -- Top accent bar
        draw.RoundedBoxEx(8, 0, 0, w, 4, bc, true, true, false, false)
    end

    -- Close button
    local cb = vgui.Create("DButton", frame)
    cb:SetSize(fw - 20, 36); cb:SetPos(10, fh - 46); cb:SetText("")
    cb.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, s:IsHovered() and Color(180, 50, 50, 200) or Color(50, 50, 60, 200))
        draw.SimpleText("Close", "BRS_UW_14", w/2, h/2, Color(220,220,220), 1, 1)
    end
    cb.DoClick = function() frame:Remove() end

    -- Weapon name + rarity
    local np = vgui.Create("DPanel", frame)
    np:SetPos(0, 10); np:SetSize(fw, 40)
    np.Paint = function(_, w, h)
        draw.SimpleText(wd.weapon_name or "Unknown", "BRS_UW_22", w/2, 0, Color(255,255,255), TEXT_ALIGN_CENTER)
        draw.SimpleText(wd.rarity, "BRS_UW_14", w/2, 24, rc, TEXT_ALIGN_CENTER)
    end

    -- Quality + booster score
    local qp = vgui.Create("DPanel", frame)
    qp:SetPos(12, 58); qp:SetSize(fw - 24, 22)
    qp.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 35, 220))
        draw.SimpleText(quality.name, "BRS_UW_13", 8, h/2, quality.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local score = math.Round((avg or 0) * 100, 1)
        draw.SimpleText("Booster Score: " .. score, "BRS_UW_12", w/2, h/2, Color(180,180,190), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("+" .. score .. "% avg", "BRS_UW_12", w - 8, h/2, Color(140,220,140), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    -- Stats section
    local statNames = {
        DMG = "DAMAGE",
        ACC = "ACCURACY",
        MAG = "CONTROL",
        RPM = "RPM",
        SPD = "MOBILITY"
    }
    local statOrder = { "DMG", "ACC", "MAG", "RPM", "SPD" }

    local sy = 90
    local sh = 44
    for i, sk in ipairs(statOrder) do
        local def = BRS_WEAPONS.StatDefs[sk]
        if not def then continue end

        local boost = wd.stat_boosters[sk] or 0
        local pct = math.abs(boost)
        local dispName = statNames[sk] or def.Name

        local sp = vgui.Create("DPanel", frame)
        sp:SetPos(12, sy + (i-1) * sh); sp:SetSize(fw - 24, sh - 4)
        sp.Paint = function(_, w, h)
            -- Label
            draw.SimpleText(dispName, "BRS_UW_13", 4, 2, def.Color)

            -- Percentage
            local sign = boost >= 0 and "+" or ""
            draw.SimpleText(sign .. math.Round(boost * 100, 1) .. "%", "BRS_UW_13", w - 4, 2, Color(220,220,220), TEXT_ALIGN_RIGHT)

            -- Bar background
            local bx, by, bw, bh = 0, 20, w, 12
            draw.RoundedBox(4, bx, by, bw, bh, Color(30, 30, 40))

            -- Bar fill
            local fill = math.Clamp(pct / 0.5, 0, 1)
            if fill > 0 then
                draw.RoundedBox(4, bx, by, bw * fill, bh, ColorAlpha(def.Color, 200))
            end
        end
    end

    -- Overall power
    local totalBoost = 0
    local statCount = 0
    for _, v in pairs(wd.stat_boosters or {}) do
        totalBoost = totalBoost + math.abs(v)
        statCount = statCount + 1
    end
    local overallPct = statCount > 0 and (totalBoost / 5) or 0

    local op = vgui.Create("DPanel", frame)
    op:SetPos(12, sy + 5 * sh); op:SetSize(fw - 24, sh - 4)
    op.Paint = function(_, w, h)
        draw.SimpleText("OVERALL POWER", "BRS_UW_13", 4, 2, Color(255, 215, 0))
        draw.SimpleText("+" .. math.Round(overallPct * 100, 1) .. "%", "BRS_UW_13", w - 4, 2, Color(220,220,220), TEXT_ALIGN_RIGHT)

        local bx, by, bw, bh = 0, 20, w, 12
        draw.RoundedBox(4, bx, by, bw, bh, Color(30, 30, 40))
        local fill = math.Clamp(overallPct / 0.5, 0, 1)
        if fill > 0 then
            draw.RoundedBox(4, bx, by, bw * fill, bh, ColorAlpha(Color(255, 215, 0), 200))
        end
    end
end

-- ============================================================
-- DEBUG
-- ============================================================
concommand.Add("brs_debug", function()
    print("=== BRS UW Client ===")
    print("Weapons: " .. table.Count(BRS_WEAPONS.PlayerWeapons))
    print("Hooked: " .. tostring(_hooked))
    for _, d in pairs(BRS_WEAPONS.PlayerWeapons) do
        print("  " .. (d.weapon_name or "?") .. " [" .. (d.rarity or "?") .. "]")
    end
    print("=====================")
end)

print("[BRS UW] Client loaded (v9 - MUTINY style)!")
