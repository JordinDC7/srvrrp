--[[
    UNIQUE WEAPON SYSTEM - Client Side (v6 - standalone UI)
    
    Does NOT touch bricks panels at all.
    Instead provides:
    1. HUD overlay showing stat bars on your current held weapon
    2. !inspect chat command to open detailed stat popup
    3. Data sync from server
]]--

if not CLIENT then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.PlayerWeapons = BRS_WEAPONS.PlayerWeapons or {}

-- ============================================================
-- FONTS
-- ============================================================
surface.CreateFont("BRS_HUD_10", { font = "Roboto", size = 10, weight = 500 })
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

    -- Show unbox notification
    local quality, avg = BRS_WEAPONS.GetQuality(data.stat_boosters or {})
    local rarityDef = BRS_WEAPONS.Rarities[data.rarity]
    local col = rarityDef and rarityDef.Color or Color(255,255,255)

    chat.AddText(
        col, "[UNIQUE] ",
        Color(255,255,255), "You unboxed a ",
        col, data.weapon_name,
        Color(180,180,180), " (" .. quality.name .. " Quality, +" .. math.Round((avg or 0)*100,1) .. "% avg)"
    )
end)

-- ============================================================
-- FIND BEST UNIQUE WEAPON FOR A CLASS
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

-- ============================================================
-- HUD OVERLAY - Shows stat bars on current held weapon
-- Appears bottom-right, above ammo display
-- ============================================================

local hudAlpha = 0
local hudTarget = 0
local lastWeaponClass = ""

hook.Add("HUDPaint", "BRS_UW_WeaponStats", function()
    if not BRS_WEAPONS.StatDefs then return end
    if not BRS_WEAPONS.GetQuality then return end

    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then hudTarget = 0 end

    local wep = ply:GetActiveWeapon()
    local weaponData = nil

    if IsValid(wep) then
        local wepClass = wep:GetClass()
        weaponData = BRS_WEAPONS.FindForClass(wepClass)
        if weaponData and weaponData.stat_boosters and table.Count(weaponData.stat_boosters) > 0 then
            hudTarget = 255
        else
            hudTarget = 0
        end
    else
        hudTarget = 0
    end

    -- Smooth fade
    hudAlpha = Lerp(FrameTime() * 8, hudAlpha, hudTarget)
    if hudAlpha < 1 then return end
    if not weaponData then return end

    local boosters = weaponData.stat_boosters
    local quality, avg = BRS_WEAPONS.GetQuality(boosters)
    local rarityDef = BRS_WEAPONS.Rarities[weaponData.rarity]
    local rarityColor = rarityDef and rarityDef.Color or Color(200,200,200)

    -- Position: bottom-right corner
    local scrW, scrH = ScrW(), ScrH()
    local panelW, panelH = 220, 120
    local px = scrW - panelW - 20
    local py = scrH - panelH - 80

    local alpha = math.floor(hudAlpha)

    -- Background
    draw.RoundedBox(8, px, py, panelW, panelH, Color(12, 12, 18, math.floor(alpha * 0.85)))

    -- Rarity accent line
    surface.SetDrawColor(rarityColor.r, rarityColor.g, rarityColor.b, alpha)
    surface.DrawRect(px, py, panelW, 2)

    -- Weapon name
    draw.SimpleText(weaponData.weapon_name, "BRS_HUD_14", px + 8, py + 6, ColorAlpha(Color(255,255,255), alpha), TEXT_ALIGN_LEFT)

    -- Rarity + Quality
    draw.SimpleText(weaponData.rarity, "BRS_HUD_12", px + 8, py + 22, ColorAlpha(rarityColor, alpha))
    draw.SimpleText(quality.name .. " +" .. math.Round((avg or 0)*100,1) .. "%", "BRS_HUD_12", px + panelW - 8, py + 22, ColorAlpha(quality.color, alpha), TEXT_ALIGN_RIGHT)

    -- Stat bars
    local statOrder = { "DMG", "ACC", "MAG", "RPM", "SPD" }
    local barStartY = py + 40
    local barH = 10
    local barSpacing = 15

    for i, statKey in ipairs(statOrder) do
        local def = BRS_WEAPONS.StatDefs[statKey]
        if not def then continue end

        local boost = boosters[statKey]
        local by = barStartY + (i-1) * barSpacing

        -- Label
        draw.SimpleText(def.ShortName, "BRS_HUD_10", px + 8, by, ColorAlpha(boost and def.Color or Color(60,60,70), alpha))

        -- Bar bg
        local bx = px + 42
        local bw = panelW - 50
        draw.RoundedBox(3, bx, by, bw, barH, ColorAlpha(Color(30, 30, 40), alpha))

        -- Bar fill
        if boost then
            local fill = math.Clamp(math.abs(boost) / 0.4, 0, 1) -- 40% = full bar
            local col = boost >= 0 and def.Color or Color(255, 50, 50)
            draw.RoundedBox(3, bx, by, bw * fill, barH, ColorAlpha(col, math.floor(alpha * 0.8)))

            -- Value text
            local sign = boost >= 0 and "+" or ""
            draw.SimpleText(sign .. math.Round(boost * 100, 1) .. "%", "BRS_HUD_10", bx + bw - 2, by, ColorAlpha(Color(220,220,220), alpha), TEXT_ALIGN_RIGHT)
        end
    end

    -- Hint
    draw.SimpleText("Type !inspect for details", "BRS_HUD_10", px + panelW/2, py + panelH - 10, ColorAlpha(Color(80,80,100), alpha), TEXT_ALIGN_CENTER)
end)

-- ============================================================
-- !inspect CHAT COMMAND - Opens detailed popup
-- ============================================================

hook.Add("OnPlayerChat", "BRS_UW_InspectCmd", function(ply, text)
    if ply ~= LocalPlayer() then return end
    text = string.lower(string.Trim(text))

    if text == "!inspect" or text == "/inspect" then
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) then return end
        local data = BRS_WEAPONS.FindForClass(wep:GetClass())
        if data then
            BRS_WEAPONS.OpenInspectPopup(data)
        else
            chat.AddText(Color(255,100,100), "[UNIQUE] ", Color(200,200,200), "This weapon has no unique stats.")
        end
    end

    if text == "!weapons" or text == "/weapons" then
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
        -- Animated rarity accent
        local t = CurTime() * 1.5
        local s = (math.sin(t) + 1) * 0.5
        local gr = rarityDef.GradientFrom or rarityColor
        local gt = rarityDef.GradientTo or rarityColor
        draw.RoundedBoxEx(10, 0, 0, w, 3, Color(
            Lerp(s, gr.r, gt.r), Lerp(s, gr.g, gt.g), Lerp(s, gr.b, gt.b), 230
        ), true, true, false, false)
        -- Border
        surface.SetDrawColor(40, 40, 50, 200)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    -- Close button
    local cb = vgui.Create("DButton", frame)
    cb:SetSize(30, 30); cb:SetPos(fw - 36, 4); cb:SetText("")
    cb.Paint = function(s, w, h)
        draw.SimpleText("X", "BRS_HUD_16", w/2, h/2, s:IsHovered() and Color(255,80,80) or Color(140,140,150), 1, 1)
    end
    cb.DoClick = function() frame:Remove() end

    -- Header
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

    -- Stats
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
            -- Bar
            local bx, by, bw, bh = 12, h - 14, w - 24, 8
            draw.RoundedBox(4, bx, by, bw, bh, Color(35, 35, 45))
            local fill = math.Clamp(pct / 0.5, 0, 1)
            if fill > 0 then
                draw.RoundedBox(4, bx, by, bw * fill, bh, ColorAlpha(boostCol, 180))
            end
        end
    end

    -- Footer
    local fp = vgui.Create("DPanel", frame)
    fp:SetPos(16, fh - 28); fp:SetSize(fw - 32, 20)
    fp.Paint = function(_, w, h)
        draw.SimpleText("UID: " .. (weaponData.weapon_uid or "?"), "BRS_HUD_10", 0, 2, Color(60,60,80))
        draw.SimpleText(weaponData.weapon_class or "", "BRS_HUD_10", w, 2, Color(60,60,80), TEXT_ALIGN_RIGHT)
    end
end

-- ============================================================
-- !weapons LIST - Show all your unique weapons
-- ============================================================
function BRS_WEAPONS.OpenWeaponsList()
    if IsValid(BRS_WEAPONS.ListFrame) then BRS_WEAPONS.ListFrame:Remove() end
    if not BRS_WEAPONS.StatDefs then return end

    local fw, fh = 500, 400
    local frame = vgui.Create("DFrame")
    frame:SetSize(fw, fh)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    BRS_WEAPONS.ListFrame = frame

    frame.Paint = function(_, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(16, 16, 22, 248))
        draw.RoundedBoxEx(10, 0, 0, w, 3, Color(100, 140, 255, 200), true, true, false, false)
        draw.SimpleText("YOUR UNIQUE WEAPONS", "BRS_HUD_16", 16, 8, Color(200,200,220))
        surface.SetDrawColor(40, 40, 50, 200)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local cb = vgui.Create("DButton", frame)
    cb:SetSize(30, 30); cb:SetPos(fw - 36, 4); cb:SetText("")
    cb.Paint = function(s, w, h)
        draw.SimpleText("X", "BRS_HUD_16", w/2, h/2, s:IsHovered() and Color(255,80,80) or Color(140,140,150), 1, 1)
    end
    cb.DoClick = function() frame:Remove() end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(8, 35)
    scroll:SetSize(fw - 16, fh - 45)

    -- Sort weapons by rarity
    local rarityOrder = { Mythical=1, Glitched=2, Legendary=3, Epic=4, Rare=5, Uncommon=6, Common=7 }
    local weaponList = {}
    for uid, data in pairs(BRS_WEAPONS.PlayerWeapons) do
        table.insert(weaponList, data)
    end
    table.sort(weaponList, function(a, b)
        return (rarityOrder[a.rarity] or 99) < (rarityOrder[b.rarity] or 99)
    end)

    if #weaponList == 0 then
        local empty = vgui.Create("DPanel", scroll)
        empty:SetSize(fw - 20, 40)
        empty:Dock(TOP)
        empty.Paint = function(_, w, h)
            draw.SimpleText("No unique weapons yet. Unbox some cases!", "BRS_HUD_14", w/2, h/2, Color(100,100,120), 1, 1)
        end
        return
    end

    for _, data in ipairs(weaponList) do
        local rarityDef = BRS_WEAPONS.Rarities[data.rarity] or BRS_WEAPONS.Rarities["Common"]
        local quality, avg = BRS_WEAPONS.GetQuality(data.stat_boosters or {})

        local row = vgui.Create("DButton", scroll)
        row:SetSize(fw - 20, 50)
        row:Dock(TOP)
        row:DockMargin(4, 2, 4, 2)
        row:SetText("")

        row.Paint = function(s, w, h)
            local bgCol = s:IsHovered() and Color(30, 30, 42) or Color(22, 22, 32)
            draw.RoundedBox(6, 0, 0, w, h, bgCol)

            -- Rarity accent
            surface.SetDrawColor(rarityDef.Color.r, rarityDef.Color.g, rarityDef.Color.b, 180)
            surface.DrawRect(0, 0, 3, h)

            -- Name + Rarity
            draw.SimpleText(data.weapon_name, "BRS_HUD_14", 12, 6, Color(240,240,240))
            draw.SimpleText(data.rarity, "BRS_HUD_12", 12, 24, rarityDef.Color)

            -- Quality + avg
            draw.SimpleText(quality.name, "BRS_HUD_13", w - 12, 6, quality.color, TEXT_ALIGN_RIGHT)
            draw.SimpleText("+" .. math.Round((avg or 0)*100,1) .. "% avg", "BRS_HUD_12", w - 12, 24, Color(160,160,170), TEXT_ALIGN_RIGHT)

            -- Mini stat indicators
            local sx = 160
            for _, statKey in ipairs({"DMG","ACC","MAG","RPM","SPD"}) do
                local boost = data.stat_boosters[statKey]
                if boost then
                    local def = BRS_WEAPONS.StatDefs[statKey]
                    if def then
                        draw.SimpleText(def.ShortName, "BRS_HUD_10", sx, 28, ColorAlpha(def.Color, 180))
                        sx = sx + 30
                    end
                end
            end
        end

        row.DoClick = function()
            BRS_WEAPONS.OpenInspectPopup(data)
        end
    end
end

-- ============================================================
-- DEBUG
-- ============================================================
concommand.Add("brs_debug", function()
    print("=== BRS UW Client Debug ===")
    print("Weapons: " .. table.Count(BRS_WEAPONS.PlayerWeapons))
    for uid, d in pairs(BRS_WEAPONS.PlayerWeapons) do
        print("  " .. (d.weapon_name or "?") .. " [" .. (d.rarity or "?") .. "] " .. (d.weapon_class or ""))
    end
    print("StatDefs: " .. tostring(BRS_WEAPONS.StatDefs ~= nil))
    print("===========================")
end)

print("[BRS UW] Client loaded (v6 - standalone HUD + inspect)!")
