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
-- INSPECT POPUP - Premium Full Overlay
-- ============================================================
function BRS_UW.OpenInspectPopup(globalKey, data)
    if IsValid(BRS_UW.InspectFrame) then BRS_UW.InspectFrame:Remove() end

    local rarity = BRS_UW.RarityByKey[data.rarity] or BRS_UW.Rarities[1]
    local qualityInfo = BRS_UW.GetQualityInfo(data.quality or "Junk")
    local avgBoost = data.avgBoost or BRS_UW.CalcAvgBoost(data.stats)
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}

    local rarityCol = (SMGRP and SMGRP.UI and SMGRP.UI.GetRarityColor) and SMGRP.UI.GetRarityColor(data.rarity) or rarity.color

    -- ====== FULLSCREEN OVERLAY ======
    local overlay = vgui.Create("DPanel")
    overlay:SetSize(ScrW(), ScrH())
    overlay:SetPos(0, 0)
    overlay:MakePopup()
    overlay:SetMouseInputEnabled(true)
    overlay:SetKeyboardInputEnabled(true)
    overlay.fadeIn = 0
    BRS_UW.InspectFrame = overlay

    overlay.Paint = function(self2, w, h)
        self2.fadeIn = math.Clamp((self2.fadeIn or 0) + FrameTime() * 4, 0, 1)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180 * self2.fadeIn))
    end

    -- Close on clicking backdrop
    overlay.OnMousePressed = function(self2, mc)
        if mc == MOUSE_LEFT then self2:Remove() end
    end
    overlay.OnKeyCodePressed = function(self2, key)
        if key == KEY_ESCAPE or key == KEY_TAB then self2:Remove() end
    end

    -- ====== MAIN PANEL ======
    local fw, fh = 580, 520
    local frame = vgui.Create("DPanel", overlay)
    frame:SetSize(fw, fh)
    frame:Center()
    frame.startTime = CurTime()

    -- Prevent click-through to overlay
    frame.OnMousePressed = function() end

    local borderT = 2
    frame.Paint = function(self2, w, h)
        local age = CurTime() - self2.startTime

        -- Drop shadow
        draw.RoundedBox(10, 4, 4, w, h, Color(0, 0, 0, 60))

        -- Main bg
        draw.RoundedBox(8, 0, 0, w, h, C.bg_dark or Color(18, 18, 26))

        -- Rarity border
        local bCol = BRS_UW.GetBorderColor(data.rarity)
        draw.RoundedBoxEx(8, 0, 0, w, borderT, bCol, true, true, false, false)
        draw.RoundedBoxEx(8, 0, h - borderT, w, borderT, bCol, false, false, true, true)
        surface.SetDrawColor(bCol)
        surface.DrawRect(0, borderT, borderT, h - borderT * 2)
        surface.DrawRect(w - borderT, borderT, borderT, h - borderT * 2)

        -- Top gradient tint from rarity color
        local tint = ColorAlpha(bCol, 12)
        for i = 0, 60 do
            surface.SetDrawColor(ColorAlpha(tint, math.max(0, 12 - i * 0.2)))
            surface.DrawRect(borderT, borderT + i, w - borderT * 2, 1)
        end

        -- Glow pulse for rare+ items
        if data.rarity == "Glitched" or data.rarity == "Mythical" or data.rarity == "Legendary" then
            local pulse = math.sin(CurTime() * 3) * 0.4 + 0.6
            draw.RoundedBox(10, -3, -3, w + 6, h + 6, ColorAlpha(bCol, 15 * pulse))
        end
    end

    -- ====== HEADER SECTION ======
    local header = vgui.Create("DPanel", frame)
    header:Dock(TOP)
    header:SetTall(70)
    header.Paint = function(self2, w, h)
        -- Weapon name
        draw.SimpleText(data.weaponName or "Unknown Weapon", "SMGRP_Header", 24, 18, C.text_primary or Color(220, 222, 230), 0, 0)

        -- Rarity + quality on second line
        draw.SimpleText(data.rarity or "Common", "SMGRP_Bold14", 24, 44, rarityCol, 0, 0)

        surface.SetFont("SMGRP_Bold14")
        local rw = surface.GetTextSize(data.rarity or "Common")
        draw.SimpleText("  ·  ", "SMGRP_Bold14", 24 + rw, 44, C.text_muted or Color(90, 94, 110), 0, 0)
        local dotW = surface.GetTextSize("  ·  ")
        draw.SimpleText(data.quality or "Junk", "SMGRP_Bold14", 24 + rw + dotW, 44, qualityInfo.color, 0, 0)

        -- Category + Class (right side)
        draw.SimpleText(data.category or "", "SMGRP_Body13", w - 24, 22, C.text_muted or Color(90, 94, 110), TEXT_ALIGN_RIGHT, 0)
        draw.SimpleText(data.weaponClass or "", "SMGRP_Body12", w - 24, 40, C.text_muted or Color(90, 94, 110), TEXT_ALIGN_RIGHT, 0)

        -- Divider
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawRect(24, h - 1, w - 48, 1)
    end

    -- Close X button (top right)
    local closeX = vgui.Create("DButton", header)
    closeX:SetSize(28, 28)
    closeX:SetPos(fw - 36, 8)
    closeX:SetText("")
    closeX.hoverA = 0
    closeX.Paint = function(s, w, h)
        s.hoverA = math.Clamp(s.hoverA + (s:IsHovered() and 12 or -12), 0, 255)
        if s.hoverA > 0 then draw.RoundedBox(4, 0, 0, w, h, Color(220, 60, 60, s.hoverA)) end
        local cx, cy, sz = w/2, h/2, 5
        surface.SetDrawColor(200, 200, 210)
        surface.DrawLine(cx-sz, cy-sz, cx+sz, cy+sz)
        surface.DrawLine(cx+sz, cy-sz, cx-sz, cy+sz)
    end
    closeX.DoClick = function() overlay:Remove() end

    -- ====== BODY: LEFT (model + radar) + RIGHT (stats) ======
    local body = vgui.Create("DPanel", frame)
    body:Dock(FILL)
    body:DockMargin(0, 0, 0, 0)
    body.Paint = function() end

    -- ====== LEFT COLUMN: WEAPON MODEL + RADAR CHART ======
    local leftCol = vgui.Create("DPanel", body)
    leftCol:Dock(LEFT)
    leftCol:SetWide(fw * 0.44)
    leftCol:DockMargin(16, 8, 0, 16)
    leftCol.Paint = function() end

    -- Weapon model display
    local modelPanel = vgui.Create("DPanel", leftCol)
    modelPanel:Dock(TOP)
    modelPanel:SetTall(180)
    modelPanel.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    -- Try to get weapon model from item config
    local weaponModel = nil
    if data.weaponClass then
        local weps = weapons.GetStored(data.weaponClass)
        if weps and weps.WorldModel then
            weaponModel = weps.WorldModel
        end
    end

    -- Also try looking up from bricks config
    if not weaponModel and globalKey then
        local baseKey = string.match(globalKey, "^ITEM_%d+") or globalKey
        local configItem = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey(baseKey)
        if configItem and configItem.Model then
            weaponModel = configItem.Model
        end
    end

    if weaponModel then
        local mdl = vgui.Create("DModelPanel", modelPanel)
        mdl:Dock(FILL)
        mdl:DockMargin(4, 4, 4, 4)
        mdl:SetModel(weaponModel)
        mdl:SetCursor("none")
        mdl.LayoutEntity = function() end
        mdl.PreDrawModel = function() render.ClearDepth() end

        local ent = mdl.Entity
        if IsValid(ent) then
            local mn, mx = ent:GetRenderBounds()
            local size = math.max(math.abs(mn.x) + math.abs(mx.x), math.abs(mn.y) + math.abs(mx.y), math.abs(mn.z) + math.abs(mx.z))
            mdl:SetFOV(45)
            mdl:SetCamPos(Vector(size * 1.1, size * 0.8, size * 0.4))
            mdl:SetLookAt((mn + mx) * 0.5)
        end
    else
        -- Fallback: show weapon name as text
        local fallback = vgui.Create("DPanel", modelPanel)
        fallback:Dock(FILL)
        fallback.Paint = function(s, w, h)
            draw.SimpleText(data.weaponName or "?", "SMGRP_SubHeader", w/2, h/2, C.text_muted or Color(90, 94, 110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- ====== PENTAGON RADAR CHART ======
    local radarPanel = vgui.Create("DPanel", leftCol)
    radarPanel:Dock(FILL)
    radarPanel:DockMargin(0, 8, 0, 0)

    radarPanel.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        local cx, cy = w / 2, h / 2 + 4
        local maxR = math.min(w, h) * 0.38
        local stats = data.stats or {}
        local statDefs = BRS_UW.Stats or {}
        local numStats = #statDefs
        if numStats < 3 then return end

        local age = math.Clamp((CurTime() - frame.startTime) * 2, 0, 1) -- animate in

        -- Draw grid rings
        for ring = 1, 4 do
            local r = maxR * (ring / 4)
            local pts = {}
            for i = 1, numStats do
                local angle = math.rad(-90 + (i - 1) * (360 / numStats))
                table.insert(pts, { x = cx + math.cos(angle) * r, y = cy + math.sin(angle) * r })
            end
            surface.SetDrawColor(C.border or Color(50, 52, 65))
            for i = 1, #pts do
                local next = (i % #pts) + 1
                surface.DrawLine(pts[i].x, pts[i].y, pts[next].x, pts[next].y)
            end
        end

        -- Draw axis lines + labels
        for i, statDef in ipairs(statDefs) do
            local angle = math.rad(-90 + (i - 1) * (360 / numStats))
            local ex, ey = cx + math.cos(angle) * maxR, cy + math.sin(angle) * maxR
            surface.SetDrawColor(C.border or Color(50, 52, 65))
            surface.DrawLine(cx, cy, ex, ey)

            -- Label
            local lx = cx + math.cos(angle) * (maxR + 16)
            local ly = cy + math.sin(angle) * (maxR + 16)
            draw.SimpleText(statDef.shortName, "SMGRP_Bold10", lx, ly, statDef.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Draw stat polygon (filled)
        local polyPts = {}
        local screenPts = {}
        for i, statDef in ipairs(statDefs) do
            local val = math.Clamp((stats[statDef.key] or 0) / 100, 0, 1) * age
            local angle = math.rad(-90 + (i - 1) * (360 / numStats))
            local r = maxR * val
            local px, py = cx + math.cos(angle) * r, cy + math.sin(angle) * r
            local sx, sy = self2:LocalToScreen(px, py)
            table.insert(polyPts, { x = sx, y = sy })
            table.insert(screenPts, { px, py })
        end

        -- Fill polygon
        if #polyPts >= 3 then
            local fillCol = ColorAlpha(rarityCol, 40)
            surface.SetDrawColor(fillCol)
            draw.NoTexture()
            surface.DrawPoly(polyPts)
        end

        -- Draw polygon outline
        surface.SetDrawColor(ColorAlpha(rarityCol, 180))
        for i = 1, #screenPts do
            local next = (i % #screenPts) + 1
            surface.DrawLine(screenPts[i][1], screenPts[i][2], screenPts[next][1], screenPts[next][2])
        end

        -- Draw stat dots
        for i, pt in ipairs(screenPts) do
            draw.RoundedBox(3, pt[1] - 3, pt[2] - 3, 6, 6, rarityCol)
        end

        -- Center power score
        draw.SimpleText(string.format("%.0f", avgBoost) .. "%", "SMGRP_Stat20", cx, cy, ColorAlpha(C.text_primary or Color(220,222,230), 200 * age), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- ====== RIGHT COLUMN: STAT BARS + INFO ======
    local rightCol = vgui.Create("DPanel", body)
    rightCol:Dock(FILL)
    rightCol:DockMargin(12, 8, 16, 16)
    rightCol.Paint = function() end

    -- ====== STAT BARS (animated fill) ======
    local statsPanel = vgui.Create("DPanel", rightCol)
    statsPanel:Dock(TOP)
    statsPanel:SetTall(24 + #(BRS_UW.Stats or {}) * 42 + 50)
    statsPanel.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        draw.SimpleText("WEAPON STATS", "SMGRP_Bold12", 14, 14, C.text_muted or Color(90, 94, 110), 0, TEXT_ALIGN_CENTER)
    end

    local statsInner = vgui.Create("DPanel", statsPanel)
    statsInner:Dock(FILL)
    statsInner:DockMargin(14, 28, 14, 8)
    statsInner.Paint = function() end

    for i, statDef in ipairs(BRS_UW.Stats or {}) do
        local val = (data.stats and data.stats[statDef.key]) or 0
        local delay = (i - 1) * 0.12 -- stagger animation

        local row = vgui.Create("DPanel", statsInner)
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 6)
        row:SetTall(36)
        row.Paint = function(self2, w, h)
            local age = math.Clamp((CurTime() - frame.startTime - delay) * 3, 0, 1)
            local animVal = val * age

            -- Stat name
            draw.SimpleText(statDef.name, "SMGRP_Bold13", 0, 4, statDef.color, 0, 0)

            -- Value text
            draw.SimpleText("+" .. string.format("%.1f", animVal) .. "%", "SMGRP_Bold13", w, 4, C.text_primary or Color(220, 222, 230), TEXT_ALIGN_RIGHT, 0)

            -- Bar track
            local barY = 24
            local barH = 8
            draw.RoundedBox(3, 0, barY, w, barH, Color(15, 15, 20, 200))

            -- Bar fill
            local fillW = math.Clamp(animVal / 100, 0, 1) * w
            if fillW > 2 then
                draw.RoundedBox(3, 0, barY, fillW, barH, statDef.color)
                -- Inner highlight
                surface.SetDrawColor(255, 255, 255, 40)
                surface.DrawRect(1, barY, fillW - 2, math.floor(barH / 2))
            end
        end
    end

    -- Overall Power row
    local overallRow = vgui.Create("DPanel", statsInner)
    overallRow:Dock(TOP)
    overallRow:DockMargin(0, 6, 0, 0)
    overallRow:SetTall(36)
    overallRow.Paint = function(self2, w, h)
        local age = math.Clamp((CurTime() - frame.startTime - #(BRS_UW.Stats or {}) * 0.12) * 3, 0, 1)
        local animVal = avgBoost * age

        -- Separator
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawRect(0, 0, w, 1)

        local powerCol = avgBoost >= 60 and (C.accent or Color(0, 212, 170)) or (avgBoost >= 35 and (C.amber or Color(255, 185, 50)) or (C.text_secondary or Color(140, 144, 160)))
        draw.SimpleText("OVERALL POWER", "SMGRP_Bold13", 0, 10, powerCol, 0, 0)
        draw.SimpleText("+" .. string.format("%.1f", animVal) .. "%", "SMGRP_Bold13", w, 10, powerCol, TEXT_ALIGN_RIGHT, 0)

        local barY = 28
        local barH = 8
        draw.RoundedBox(3, 0, barY, w, barH, Color(15, 15, 20, 200))
        local fillW = math.Clamp(animVal / 100, 0, 1) * w
        if fillW > 2 then
            draw.RoundedBox(3, 0, barY, fillW, barH, powerCol)
            surface.SetDrawColor(255, 255, 255, 40)
            surface.DrawRect(1, barY, fillW - 2, math.floor(barH / 2))
        end
    end

    -- ====== WEAPON INFO PANEL ======
    local infoPanel = vgui.Create("DPanel", rightCol)
    infoPanel:Dock(FILL)
    infoPanel:DockMargin(0, 8, 0, 0)
    infoPanel.Paint = function(self2, w, h)
        draw.RoundedBox(6, 0, 0, w, h, C.bg_mid or Color(26, 27, 35))
        surface.SetDrawColor(C.border or Color(50, 52, 65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        draw.SimpleText("DETAILS", "SMGRP_Bold12", 14, 14, C.text_muted or Color(90, 94, 110), 0, TEXT_ALIGN_CENTER)
    end

    local infoInner = vgui.Create("DPanel", infoPanel)
    infoInner:Dock(FILL)
    infoInner:DockMargin(14, 28, 14, 10)
    infoInner.Paint = function() end

    local infoPairs = {
        { "Category", data.category or "Unknown" },
        { "Rarity", data.rarity or "Common", rarityCol },
        { "Quality", data.quality or "Junk", qualityInfo.color },
        { "Avg Boost", string.format("+%.1f%%", avgBoost) },
        { "UID", data.uid or "N/A" },
    }

    for _, pair in ipairs(infoPairs) do
        local row = vgui.Create("DPanel", infoInner)
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 2)
        row:SetTall(20)
        row.Paint = function(self2, w, h)
            draw.SimpleText(pair[1], "SMGRP_Body12", 0, h/2, C.text_muted or Color(90, 94, 110), 0, TEXT_ALIGN_CENTER)
            draw.SimpleText(pair[2], "SMGRP_Bold12", w, h/2, pair[3] or (C.text_primary or Color(220, 222, 230)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end
end

-- ============================================================
-- FONTS (Montserrat to match SmG RP theme, old names kept for admin compat)
-- ============================================================
local fontBase = "Montserrat"
local fontFallback = "Segoe UI"
local fontDefs = {
    {"BRS_UW_Font8",   10, 700},
    {"BRS_UW_Font10",  12, 500},
    {"BRS_UW_Font10B", 12, 700},
    {"BRS_UW_Font12B", 14, 700},
    {"BRS_UW_Font14",  16, 500},
    {"BRS_UW_Font14B", 16, 700},
    {"BRS_UW_Font16",  18, 500},
    {"BRS_UW_Font18B", 20, 700},
    {"BRS_UW_Font22B", 24, 700},
}
for _, def in ipairs(fontDefs) do
    surface.CreateFont(def[1], { font = fontBase, size = def[2], weight = def[3], antialias = true })
end

print("[BRS UW] Client system loaded")
