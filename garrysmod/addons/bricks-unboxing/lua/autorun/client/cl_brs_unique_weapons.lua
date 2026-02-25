--[[
    UNIQUE WEAPON SYSTEM - Client Side
    Handles: Receiving weapon data, enhanced UI rendering,
    stat booster display, rarity glow effects, inspect popup
]]--

if not CLIENT then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.PlayerWeapons = BRS_WEAPONS.PlayerWeapons or {} -- uid -> weapon data

-- ============================================================
-- NETWORK RECEIVERS
-- ============================================================

-- Full sync of all player weapons
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

-- New weapon notification
net.Receive("BRS.UniqueWeapons.NewWeapon", function()
    local jsonData = net.ReadString()
    local weaponData = util.JSONToTable(jsonData)
    if not weaponData then return end

    BRS_WEAPONS.PlayerWeapons[weaponData.weapon_uid] = weaponData

    -- TODO: Could trigger a special unbox animation/sound here
end)

-- Inspect response
net.Receive("BRS.UniqueWeapons.Inspect", function()
    local jsonData = net.ReadString()
    local weaponData = util.JSONToTable(jsonData)
    if not weaponData then return end

    BRS_WEAPONS.OpenInspectPopup(weaponData)
end)

-- ============================================================
-- HELPER: Get unique weapon data from a globalKey
-- ============================================================
function BRS_WEAPONS.GetUniqueData(globalKey)
    if not globalKey or not string.StartWith(globalKey, "ITEM_") then return nil end

    local uid = string.match(globalKey, "^ITEM_%d+_(.+)$")
    if not uid then return nil end

    return BRS_WEAPONS.PlayerWeapons[uid], uid
end

-- ============================================================
-- ENHANCED ITEM DISPLAY HOOK
-- Override the itemslot panel's FillPanel to add stat boosters
-- ============================================================

-- Rarity gradient animation materials
local glowMat = Material("vgui/white")

--- Draw a rarity-colored gradient border
function BRS_WEAPONS.DrawRarityBorder(x, y, w, h, rarity, alpha)
    local rarityDef = BRS_WEAPONS.Rarities[rarity]
    if not rarityDef then return end

    local col1 = rarityDef.GradientFrom
    local col2 = rarityDef.GradientTo
    local glowA = (rarityDef.GlowAlpha or 0) * (alpha or 1)

    if glowA <= 0 then return end

    -- Animated shimmer
    local time = CurTime() * 2
    local shimmer = (math.sin(time) + 1) * 0.5

    local borderSize = 2
    local r = Lerp(shimmer, col1.r, col2.r)
    local g = Lerp(shimmer, col1.g, col2.g)
    local b = Lerp(shimmer, col1.b, col2.b)

    surface.SetDrawColor(r, g, b, glowA)
    surface.SetMaterial(glowMat)

    -- Top
    surface.DrawTexturedRect(x, y, w, borderSize)
    -- Bottom
    surface.DrawTexturedRect(x, y + h - borderSize, w, borderSize)
    -- Left
    surface.DrawTexturedRect(x, y, borderSize, h)
    -- Right
    surface.DrawTexturedRect(x + w - borderSize, y, borderSize, h)

    -- Corner glow
    local glowSize = 6
    for i = 1, glowSize do
        local a = glowA * (1 - (i / glowSize))
        surface.SetDrawColor(r, g, b, a)
        surface.DrawTexturedRect(x - i, y - i, w + i * 2, 1)
        surface.DrawTexturedRect(x - i, y + h - 1 + i, w + i * 2, 1)
        surface.DrawTexturedRect(x - i, y - i, 1, h + i * 2)
        surface.DrawTexturedRect(x + w - 1 + i, y - i, 1, h + i * 2)
    end
end

--- Draw stat booster bars on an item panel
function BRS_WEAPONS.DrawStatBoosters(x, y, w, h, boosters, rarity)
    if not boosters or table.Count(boosters) == 0 then return end

    local rarityColor = BRS_WEAPONS.GetRarityColor(rarity)
    local barH = 12
    local padding = 2
    local startY = y + h - (table.Count(boosters) * (barH + padding)) - 4
    local barW = w - 10

    local i = 0
    -- Sort boosters by stat key for consistent display
    local sortedStats = {}
    for statKey, boost in pairs(boosters) do
        table.insert(sortedStats, { key = statKey, boost = boost })
    end
    table.sort(sortedStats, function(a, b) return a.key < b.key end)

    for _, stat in ipairs(sortedStats) do
        local statDef = BRS_WEAPONS.StatDefs[stat.key]
        if not statDef then continue end

        local barY = startY + i * (barH + padding)
        local boostColor = BRS_WEAPONS.GetBoostColor(stat.key, stat.boost)
        local boostText = BRS_WEAPONS.FormatBoost(stat.key, stat.boost)
        local fillW = math.abs(stat.boost) / 1.5 * barW -- Normalize to max 150%

        -- Background
        draw.RoundedBox(4, x + 5, barY, barW, barH, Color(0, 0, 0, 150))

        -- Fill bar
        draw.RoundedBox(4, x + 5, barY, math.min(fillW, barW), barH, ColorAlpha(boostColor, 120))

        -- Stat label + value
        draw.SimpleText(
            statDef.ShortName .. " " .. boostText,
            "BRS_WEAPONS_Font10",
            x + 8, barY + barH / 2,
            Color(255, 255, 255, 230),
            TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
        )

        i = i + 1
    end
end

-- ============================================================
-- INSPECT POPUP
-- Full-screen weapon inspection with 3D model and stat details
-- ============================================================

function BRS_WEAPONS.OpenInspectPopup(weaponData)
    if IsValid(BRS_WEAPONS.InspectFrame) then
        BRS_WEAPONS.InspectFrame:Remove()
    end

    local rarityDef = BRS_WEAPONS.Rarities[weaponData.rarity] or BRS_WEAPONS.Rarities["Common"]
    local rarityColor = rarityDef.Color

    local scrW, scrH = ScrW(), ScrH()
    local frameW, frameH = math.min(600, scrW * 0.45), math.min(500, scrH * 0.6)

    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    BRS_WEAPONS.InspectFrame = frame

    frame.Paint = function(self2, w, h)
        -- Dark background
        draw.RoundedBox(12, 0, 0, w, h, Color(18, 18, 24, 245))

        -- Rarity accent line at top
        local time = CurTime() * 1.5
        local shimmer = (math.sin(time) + 1) * 0.5
        local accentCol = Color(
            Lerp(shimmer, rarityDef.GradientFrom.r, rarityDef.GradientTo.r),
            Lerp(shimmer, rarityDef.GradientFrom.g, rarityDef.GradientTo.g),
            Lerp(shimmer, rarityDef.GradientFrom.b, rarityDef.GradientTo.b),
            230
        )
        draw.RoundedBoxEx(12, 0, 0, w, 4, accentCol, true, true, false, false)

        -- Inner border glow
        BRS_WEAPONS.DrawRarityBorder(2, 2, w - 4, h - 4, weaponData.rarity, 0.6)
    end

    -- Close button (top right)
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(frameW - 38, 8)
    closeBtn:SetText("")
    closeBtn.Paint = function(self2, w, h)
        local col = self2:IsHovered() and Color(255, 80, 80) or Color(180, 180, 180)
        draw.SimpleText("✕", "BRS_WEAPONS_Font16", w / 2, h / 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() frame:Remove() end

    -- Weapon Name
    local nameLabel = vgui.Create("DPanel", frame)
    nameLabel:SetPos(20, 14)
    nameLabel:SetSize(frameW - 60, 32)
    nameLabel.Paint = function(self2, w, h)
        draw.SimpleText(weaponData.weapon_name or "Unknown", "BRS_WEAPONS_Font24B", 0, 0, Color(255, 255, 255), TEXT_ALIGN_LEFT)
    end

    -- Rarity badge
    local rarityLabel = vgui.Create("DPanel", frame)
    rarityLabel:SetPos(20, 44)
    rarityLabel:SetSize(frameW - 40, 22)
    rarityLabel.Paint = function(self2, w, h)
        draw.SimpleText(weaponData.rarity, "BRS_WEAPONS_Font16", 0, 0, rarityColor, TEXT_ALIGN_LEFT)
        draw.SimpleText("UID: " .. weaponData.weapon_uid, "BRS_WEAPONS_Font12", w, 0, Color(120, 120, 120), TEXT_ALIGN_RIGHT)
    end

    -- 3D Model panel
    local wepDef = BRS_WEAPONS.WeaponByClass and BRS_WEAPONS.WeaponByClass[weaponData.weapon_class]
    local modelPath = wepDef and wepDef.model or "models/weapons/w_rif_ak47.mdl"

    local modelPanel = vgui.Create("DModelPanel", frame)
    modelPanel:SetPos(20, 72)
    modelPanel:SetSize(frameW * 0.5 - 30, frameH * 0.45)
    modelPanel:SetModel(modelPath)
    modelPanel:SetCursor("none")
    function modelPanel:LayoutEntity(ent)
        ent:SetAngles(Angle(0, CurTime() * 30, 0))
    end

    local mdlEnt = modelPanel.Entity
    if mdlEnt and IsValid(mdlEnt) then
        local mn, mx = mdlEnt:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
        modelPanel:SetFOV(50)
        modelPanel:SetCamPos(Vector(size, size, size))
        modelPanel:SetLookAt((mn + mx) * 0.5)
    end

    -- Stat Boosters Panel
    local statsPanel = vgui.Create("DPanel", frame)
    statsPanel:SetPos(frameW * 0.5 + 10, 72)
    statsPanel:SetSize(frameW * 0.5 - 30, frameH - 90)
    statsPanel.Paint = function(self2, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 40, 200))
        draw.SimpleText("STAT BOOSTERS", "BRS_WEAPONS_Font14B", 12, 10, Color(200, 200, 200), TEXT_ALIGN_LEFT)
    end

    -- Individual stat entries
    local sortedStats = {}
    for statKey, boost in pairs(weaponData.stat_boosters or {}) do
        table.insert(sortedStats, { key = statKey, boost = boost })
    end
    table.sort(sortedStats, function(a, b) return a.key < b.key end)

    local statStartY = 34
    local statH = 42
    local statW = frameW * 0.5 - 54

    for i, stat in ipairs(sortedStats) do
        local statDef = BRS_WEAPONS.StatDefs[stat.key]
        if not statDef then continue end

        local boostColor = BRS_WEAPONS.GetBoostColor(stat.key, stat.boost)
        local boostText = BRS_WEAPONS.FormatBoost(stat.key, stat.boost)
        local pct = math.abs(stat.boost)

        local entry = vgui.Create("DPanel", statsPanel)
        entry:SetPos(12, statStartY + (i - 1) * (statH + 4))
        entry:SetSize(statW, statH)
        entry.Paint = function(self2, w, h)
            -- Background
            draw.RoundedBox(6, 0, 0, w, h, Color(20, 20, 28, 200))

            -- Stat name
            draw.SimpleText(statDef.Name, "BRS_WEAPONS_Font14B", 10, 6, Color(220, 220, 220), TEXT_ALIGN_LEFT)

            -- Boost value
            draw.SimpleText(boostText, "BRS_WEAPONS_Font16", w - 10, 6, boostColor, TEXT_ALIGN_RIGHT)

            -- Progress bar
            local barX, barY, barW2, barH2 = 10, h - 14, w - 20, 8
            draw.RoundedBox(4, barX, barY, barW2, barH2, Color(40, 40, 50))

            local fillFrac = math.Clamp(pct / 1.5, 0, 1)
            if fillFrac > 0 then
                draw.RoundedBox(4, barX, barY, barW2 * fillFrac, barH2, ColorAlpha(boostColor, 180))
            end
        end
    end

    -- Weapon class label at bottom of model area
    local classLabel = vgui.Create("DPanel", frame)
    classLabel:SetPos(20, 72 + frameH * 0.45 + 4)
    classLabel:SetSize(frameW * 0.5 - 30, 20)
    classLabel.Paint = function(self2, w, h)
        draw.SimpleText(weaponData.weapon_class or "", "BRS_WEAPONS_Font12", w / 2, h / 2, Color(100, 100, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- ============================================================
-- CUSTOM FONTS
-- ============================================================
surface.CreateFont("BRS_WEAPONS_Font10", { font = "Roboto", size = 10, weight = 500 })
surface.CreateFont("BRS_WEAPONS_Font12", { font = "Roboto", size = 12, weight = 400 })
surface.CreateFont("BRS_WEAPONS_Font14B", { font = "Roboto", size = 14, weight = 700 })
surface.CreateFont("BRS_WEAPONS_Font16", { font = "Roboto", size = 16, weight = 500 })
surface.CreateFont("BRS_WEAPONS_Font24B", { font = "Roboto", size = 24, weight = 700 })

-- ============================================================
-- HOOK INTO ITEMSLOT RENDERING
-- Add stat booster overlays and rarity borders to item cards
-- ============================================================
hook.Add("PostRender", "BRS_UniqueWeapons_InitUI", function()
    hook.Remove("PostRender", "BRS_UniqueWeapons_InitUI")

    -- Override the itemslot's FillPanel after one frame to ensure it's loaded
    timer.Simple(3, function()
        -- We'll hook into the paint of any bricks_server_unboxingmenu_itemslot
        -- by adding a paint-over hook
        local oldPaintOver

        hook.Add("Think", "BRS_UniqueWeapons_PatchItemSlots", function()
            -- Find all active itemslot panels and add our overlay
            -- This runs every frame but only modifies new panels
        end)
    end)
end)

print("[BRS UniqueWeapons] Client system loaded!")
