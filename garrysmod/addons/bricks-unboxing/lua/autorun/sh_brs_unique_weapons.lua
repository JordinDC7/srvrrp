-- ============================================================
-- UNIQUE WEAPONS SYSTEM - Shared Definitions
-- CS:GO-style unique weapons with stat boosters for Bricks Unboxing
-- ============================================================

BRS_UW = BRS_UW or {}
BRS_UW.Weapons = BRS_UW.Weapons or {}
BRS_UW.Rarities = BRS_UW.Rarities or {}
BRS_UW.Stats = BRS_UW.Stats or {}
BRS_UW.Qualities = BRS_UW.Qualities or {}
BRS_UW.WeaponData = BRS_UW.WeaponData or {} -- client cache of unique weapon data

-- ============================================================
-- WEAPON CATEGORIES
-- ============================================================
BRS_UW.Categories = {
    Pistol = { order = 1, color = Color(200,200,200) },
    SMG = { order = 2, color = Color(104,255,104) },
    Rifle = { order = 3, color = Color(42,133,219) },
    Shotgun = { order = 4, color = Color(255,165,0) },
    Sniper = { order = 5, color = Color(152,68,255) },
    Heavy = { order = 6, color = Color(255,50,50) },
}

-- ============================================================
-- ALL 78 M9K WEAPONS
-- ============================================================
BRS_UW.Weapons = {
    -- PISTOLS (16)
    { class = "m9k_colt1911",       name = "Colt 1911",            cat = "Pistol" },
    { class = "m9k_model3russian",  name = "S&W Model 3 Russian",  cat = "Pistol" },
    { class = "m9k_glock",          name = "Glock 18",             cat = "Pistol" },
    { class = "m9k_hk45",           name = "HK45C",                cat = "Pistol" },
    { class = "m9k_luger",          name = "Luger P08",            cat = "Pistol" },
    { class = "m9k_m92baretta",     name = "Beretta M92",          cat = "Pistol" },
    { class = "m9k_sig_p229r",      name = "SIG P229R",            cat = "Pistol" },
    { class = "m9k_usp",            name = "HK USP",               cat = "Pistol" },
    { class = "m9k_remington1858",  name = "Remington 1858",       cat = "Pistol" },
    { class = "m9k_deagle",         name = "Desert Eagle",         cat = "Pistol" },
    { class = "m9k_coltpython",     name = "Colt Python",          cat = "Pistol" },
    { class = "m9k_model627",       name = "S&W Model 627",        cat = "Pistol" },
    { class = "m9k_m29satan",       name = "S&W Model 29 Satan",   cat = "Pistol" },
    { class = "m9k_model500",       name = "S&W Model 500",        cat = "Pistol" },
    { class = "m9k_ragingbull",     name = "Taurus Raging Bull",   cat = "Pistol" },
    { class = "m9k_tec9",           name = "TEC-9",                cat = "Pistol" },

    -- SMGS (12)
    { class = "m9k_mp5",            name = "MP5",                  cat = "SMG" },
    { class = "m9k_mp5sd",          name = "MP5SD",                cat = "SMG" },
    { class = "m9k_mp7",            name = "MP7",                  cat = "SMG" },
    { class = "m9k_mp9",            name = "MP9",                  cat = "SMG" },
    { class = "m9k_mac10",          name = "MAC-10",               cat = "SMG" },
    { class = "m9k_uzi",            name = "Uzi",                  cat = "SMG" },
    { class = "m9k_bizonp19",       name = "PP-Bizon",             cat = "SMG" },
    { class = "m9k_ump45",          name = "UMP-45",               cat = "SMG" },
    { class = "m9k_smgp90",         name = "P90",                  cat = "SMG" },
    { class = "m9k_vector",         name = "Kriss Vector",         cat = "SMG" },
    { class = "m9k_thompson",       name = "Thompson M1A1",        cat = "SMG" },
    { class = "m9k_sten",           name = "Sten MkII",            cat = "SMG" },

    -- RIFLES (20)
    { class = "m9k_ak47",           name = "AK-47",                cat = "Rifle" },
    { class = "m9k_ak74",           name = "AK-74",                cat = "Rifle" },
    { class = "m9k_m4a1",           name = "M4A1",                 cat = "Rifle" },
    { class = "m9k_m16a4_acog",     name = "M16A4 ACOG",           cat = "Rifle" },
    { class = "m9k_m416",           name = "HK416",                cat = "Rifle" },
    { class = "m9k_acr",            name = "ACR",                  cat = "Rifle" },
    { class = "m9k_scar",           name = "SCAR-H",               cat = "Rifle" },
    { class = "m9k_fal",            name = "FN FAL",               cat = "Rifle" },
    { class = "m9k_g36",            name = "G36C",                 cat = "Rifle" },
    { class = "m9k_g3a3",           name = "G3A3",                 cat = "Rifle" },
    { class = "m9k_tar21",          name = "TAR-21",               cat = "Rifle" },
    { class = "m9k_sig_sg552",      name = "SIG SG552",            cat = "Rifle" },
    { class = "m9k_amd65",          name = "AMD-65",               cat = "Rifle" },
    { class = "m9k_an94",           name = "AN-94",                cat = "Rifle" },
    { class = "m9k_l85",            name = "L85A2",                cat = "Rifle" },
    { class = "m9k_val",            name = "AS VAL",               cat = "Rifle" },
    { class = "m9k_vikhr",          name = "SR-3M Vikhr",          cat = "Rifle" },
    { class = "m9k_sl8",            name = "HK SL8",               cat = "Rifle" },
    { class = "m9k_honeybadger",    name = "Honey Badger",         cat = "Rifle" },
    { class = "m9k_svt40",          name = "SVT-40",               cat = "Rifle" },

    -- SHOTGUNS (10)
    { class = "m9k_remington870",   name = "Remington 870",        cat = "Shotgun" },
    { class = "m9k_mossberg590",    name = "Mossberg 590",         cat = "Shotgun" },
    { class = "m9k_spas12",         name = "SPAS-12",              cat = "Shotgun" },
    { class = "m9k_ithacam37",      name = "Ithaca M37",           cat = "Shotgun" },
    { class = "m9k_browningauto5",  name = "Browning Auto-5",      cat = "Shotgun" },
    { class = "m9k_dbarrel",        name = "Double Barrel",        cat = "Shotgun" },
    { class = "m9k_winchester73",   name = "Winchester 1873",       cat = "Shotgun" },
    { class = "m9k_striker12",      name = "Striker-12",           cat = "Shotgun" },
    { class = "m9k_jackhammer",     name = "Pancor Jackhammer",    cat = "Shotgun" },
    { class = "m9k_usas",           name = "USAS-12",              cat = "Shotgun" },

    -- SNIPERS (10)
    { class = "m9k_intervention",   name = "Intervention",         cat = "Sniper" },
    { class = "m9k_m24",            name = "M24",                  cat = "Sniper" },
    { class = "m9k_remington7615p", name = "Remington 7615P",      cat = "Sniper" },
    { class = "m9k_m98b",           name = "Barrett M98B",         cat = "Sniper" },
    { class = "m9k_barret_m82",     name = "Barrett M82",          cat = "Sniper" },
    { class = "m9k_aw50",           name = "AW50",                 cat = "Sniper" },
    { class = "m9k_dragunov",       name = "SVD Dragunov",         cat = "Sniper" },
    { class = "m9k_psg1",           name = "PSG-1",                cat = "Sniper" },
    { class = "m9k_contender",      name = "Contender G2",         cat = "Sniper" },
    { class = "m9k_m14sp",          name = "M14 EBR",              cat = "Sniper" },

    -- HEAVY (10)
    { class = "m9k_m249lmg",        name = "M249 LMG",             cat = "Heavy" },
    { class = "m9k_m60",            name = "M60",                  cat = "Heavy" },
    { class = "m9k_pkm",            name = "PKM",                  cat = "Heavy" },
    { class = "m9k_ares_shrike",    name = "Ares Shrike",          cat = "Heavy" },
    { class = "m9k_minigun",        name = "M134 Minigun",         cat = "Heavy" },
    { class = "m9k_magpulpdr",      name = "Magpul PDR",           cat = "Heavy" },
    { class = "m9k_dao12",          name = "DAO-12",               cat = "Heavy" },
    { class = "m9k_m3",             name = "M3 Super 90",          cat = "Heavy" },
    { class = "m9k_m202",           name = "M202 Flash",           cat = "Heavy" },
    { class = "m9k_milkormgl",      name = "Milkor MGL",           cat = "Heavy" },
}

-- Build lookup tables
BRS_UW.WeaponByClass = {}
BRS_UW.WeaponByIndex = {}
for i, wep in ipairs(BRS_UW.Weapons) do
    wep.index = i
    BRS_UW.WeaponByClass[wep.class] = wep
    BRS_UW.WeaponByIndex[i] = wep
end

-- ============================================================
-- 5 STAT TYPES
-- ============================================================
BRS_UW.Stats = {
    { key = "dmg",  name = "DAMAGE",   shortName = "DMG",  color = Color(255, 80, 80),   applyKey = "Damage" },
    { key = "acc",  name = "ACCURACY", shortName = "ACC",  color = Color(80, 200, 255),  applyKey = "Spread" },
    { key = "ctrl", name = "CONTROL",  shortName = "CTRL", color = Color(255, 180, 40),  applyKey = "Recoil" },
    { key = "rpm",  name = "RPM",      shortName = "RPM",  color = Color(80, 255, 120),  applyKey = "RPM" },
    { key = "mob",  name = "MOBILITY", shortName = "MOB",  color = Color(220, 80, 255),  applyKey = "Mobility" },
}

BRS_UW.StatByKey = {}
for i, stat in ipairs(BRS_UW.Stats) do
    BRS_UW.StatByKey[stat.key] = stat
end

-- ============================================================
-- 7 RARITIES with stat boost ranges
-- Below Legendary = weak, Legendary+ = moderately stronger, Glitched/Mythical = strongest
-- ============================================================
BRS_UW.Rarities = {
    { key = "Common",    order = 1, color = Color(180,180,180), min = 1,  max = 8,   dropWeight = 40 },
    { key = "Uncommon",  order = 2, color = Color(120,200,80),  min = 3,  max = 12,  dropWeight = 28 },
    { key = "Rare",      order = 3, color = Color(42,133,219),  min = 5,  max = 20,  dropWeight = 16 },
    { key = "Epic",      order = 4, color = Color(152,68,255),  min = 8,  max = 30,  dropWeight = 9 },
    { key = "Legendary", order = 5, color = Color(255,165,0),   min = 20, max = 55,  dropWeight = 4.5 },
    { key = "Glitched",  order = 6, color = Color(0,255,200),   min = 35, max = 75,  dropWeight = 2 },
    { key = "Mythical",  order = 7, color = Color(255,50,50),   min = 50, max = 100, dropWeight = 0.5 },
}

BRS_UW.RarityByKey = {}
BRS_UW.RarityOrder = {}
for i, r in ipairs(BRS_UW.Rarities) do
    BRS_UW.RarityByKey[r.key] = r
    BRS_UW.RarityOrder[r.key] = r.order
end

-- ============================================================
-- QUALITY LABELS (based on average boost %)
-- ============================================================
BRS_UW.Qualities = {
    { key = "Junk",     minAvg = 0,  maxAvg = 10, color = Color(120,120,120) },
    { key = "Raw",      minAvg = 10, maxAvg = 20, color = Color(140,180,100) },
    { key = "Standard", minAvg = 20, maxAvg = 35, color = Color(80,160,220) },
    { key = "Forged",   minAvg = 35, maxAvg = 50, color = Color(180,120,255) },
    { key = "Refined",  minAvg = 50, maxAvg = 70, color = Color(255,180,40) },
    { key = "Ascended", minAvg = 70, maxAvg = 101, color = Color(255,60,60) },
}

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Generate a short unique ID (8 hex chars)
function BRS_UW.GenerateUID()
    local chars = "0123456789abcdef"
    local uid = ""
    for i = 1, 8 do
        local idx = math.random(1, #chars)
        uid = uid .. string.sub(chars, idx, idx)
    end
    return uid
end

-- Check if a globalKey is a unique weapon
function BRS_UW.IsUniqueWeapon(globalKey)
    return string.match(globalKey, "^ITEM_%d+_%x+$") ~= nil
end

-- Extract base item number and UID from unique key
function BRS_UW.ParseUniqueKey(globalKey)
    local baseNum, uid = string.match(globalKey, "^ITEM_(%d+)_(%x+)$")
    if baseNum then
        return tonumber(baseNum), uid
    end
    return nil, nil
end

-- Build unique key from base item number and UID
function BRS_UW.MakeUniqueKey(baseItemNum, uid)
    return "ITEM_" .. baseItemNum .. "_" .. uid
end

-- Get quality label from average boost
function BRS_UW.GetQuality(avgBoost)
    for _, q in ipairs(BRS_UW.Qualities) do
        if avgBoost >= q.minAvg and avgBoost < q.maxAvg then
            return q.key, q.color
        end
    end
    return "Junk", BRS_UW.Qualities[1].color
end

-- Get quality info by key
function BRS_UW.GetQualityInfo(qualityKey)
    for _, q in ipairs(BRS_UW.Qualities) do
        if q.key == qualityKey then return q end
    end
    return BRS_UW.Qualities[1]
end

-- Calculate average boost from stats table
function BRS_UW.CalcAvgBoost(stats)
    if not stats then return 0 end
    local total, count = 0, 0
    for _, statDef in ipairs(BRS_UW.Stats) do
        if stats[statDef.key] then
            total = total + stats[statDef.key]
            count = count + 1
        end
    end
    return count > 0 and (total / count) or 0
end

-- Generate random stats for a rarity
function BRS_UW.GenerateStats(rarityKey)
    local rarity = BRS_UW.RarityByKey[rarityKey]
    if not rarity then rarity = BRS_UW.Rarities[1] end

    local stats = {}
    for _, statDef in ipairs(BRS_UW.Stats) do
        -- Each stat gets a random value within the rarity's range
        -- Use weighted distribution: slight bell curve favoring middle
        local roll1 = math.Rand(rarity.min, rarity.max)
        local roll2 = math.Rand(rarity.min, rarity.max)
        local value = (roll1 + roll2) / 2 -- average of 2 rolls = slight bell curve
        stats[statDef.key] = math.Round(value, 1)
    end

    return stats
end

-- Get rarity color (handles both standard and unique weapons)
function BRS_UW.GetRarityColor(rarityKey)
    local r = BRS_UW.RarityByKey[rarityKey]
    return r and r.color or Color(180,180,180)
end

-- Get weapon data from unique weapon cache (client-side)
function BRS_UW.GetWeaponData(globalKey)
    return BRS_UW.WeaponData[globalKey]
end

-- Store weapon data in cache
function BRS_UW.SetWeaponData(globalKey, data)
    BRS_UW.WeaponData[globalKey] = data
end

-- ============================================================
-- OVERRIDE GetItemFromGlobalKey to handle unique keys
-- Must run after bricks loads, so we use a hook
-- ============================================================
hook.Add("Initialize", "BRS_UW_OverrideGetItemFromGlobalKey", function()
    timer.Simple(1, function()
        if not BRICKS_SERVER or not BRICKS_SERVER.UNBOXING or not BRICKS_SERVER.UNBOXING.Func then return end

        local originalGetItem = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey

        BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey = function(globalKey)
            -- Check if this is a unique weapon key (ITEM_XX_YYYYYYYY)
            local baseNum, uid = BRS_UW.ParseUniqueKey(globalKey)
            if baseNum then
                local configItemTable = BRICKS_SERVER.CONFIG and BRICKS_SERVER.CONFIG.UNBOXING and BRICKS_SERVER.CONFIG.UNBOXING.Items and BRICKS_SERVER.CONFIG.UNBOXING.Items[baseNum]
                if not configItemTable then
                    configItemTable = BRICKS_SERVER.BASECONFIG and BRICKS_SERVER.BASECONFIG.UNBOXING and BRICKS_SERVER.BASECONFIG.UNBOXING.Items and BRICKS_SERVER.BASECONFIG.UNBOXING.Items[baseNum]
                end

                if configItemTable then
                    -- Return a copy with unique weapon data merged in
                    local uwData = BRS_UW.GetWeaponData(globalKey)
                    if uwData then
                        -- Create a modified copy of the config table
                        local modifiedTable = table.Copy(configItemTable)
                        modifiedTable.Rarity = uwData.rarity or modifiedTable.Rarity
                        modifiedTable.UWData = uwData
                        modifiedTable.IsUniqueWeapon = true
                        return modifiedTable, baseNum, true, false, false
                    end

                    return configItemTable, baseNum, true, false, false
                end
            end

            -- Fall through to original
            return originalGetItem(globalKey)
        end

        print("[BRS UniqueWeapons] GetItemFromGlobalKey override installed")
    end)
end)

-- ============================================================
-- NOTE: Item-to-weapon/rarity mapping is done by reading
-- the actual baseconfig entry's Rarity and ReqInfo fields,
-- NOT by calculating from item index (since items are grouped
-- by weapon category, not by rarity blocks).
-- ============================================================

print("[BRS UniqueWeapons] Shared definitions loaded - " .. #BRS_UW.Weapons .. " weapons, " .. #BRS_UW.Stats .. " stat types, " .. #BRS_UW.Rarities .. " rarities")
