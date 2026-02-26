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
    { class = "m9k_uzi",            name = "Uzi",                  cat = "SMG" },
    { class = "m9k_bizonp19",       name = "PP-Bizon",             cat = "SMG" },
    { class = "m9k_ump45",          name = "UMP-45",               cat = "SMG" },
    { class = "m9k_smgp90",         name = "P90",                  cat = "SMG" },
    { class = "m9k_vector",         name = "Kriss Vector",         cat = "SMG" },
    { class = "m9k_thompson",       name = "Thompson M1A1",        cat = "SMG" },
    { class = "m9k_sten",           name = "Sten MkII",            cat = "SMG" },
    { class = "m9k_magpulpdr",      name = "Magpul PDR",           cat = "SMG" },

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
    { class = "m9k_amd65",          name = "AMD-65",               cat = "Rifle" },
    { class = "m9k_an94",           name = "AN-94",                cat = "Rifle" },
    { class = "m9k_l85",            name = "L85A2",                cat = "Rifle" },
    { class = "m9k_val",            name = "AS VAL",               cat = "Rifle" },
    { class = "m9k_vikhr",          name = "SR-3M Vikhr",          cat = "Rifle" },
    { class = "m9k_sl8",            name = "HK SL8",               cat = "Rifle" },
    { class = "m9k_honeybadger",    name = "Honey Badger",         cat = "Rifle" },
    { class = "m9k_svt40",          name = "SVT-40",               cat = "Rifle" },
    { class = "m9k_remington7615p", name = "Remington 7615P",      cat = "Rifle" },

    -- SHOTGUNS (11)
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
    { class = "m9k_m3",             name = "M3 Super 90",          cat = "Shotgun" },

    -- SNIPERS (9)
    { class = "m9k_intervention",   name = "Intervention",         cat = "Sniper" },
    { class = "m9k_m24",            name = "M24",                  cat = "Sniper" },
    { class = "m9k_m98b",           name = "Barrett M98B",         cat = "Sniper" },
    { class = "m9k_barret_m82",     name = "Barrett M82",          cat = "Sniper" },
    { class = "m9k_aw50",           name = "AW50",                 cat = "Sniper" },
    { class = "m9k_dragunov",       name = "SVD Dragunov",         cat = "Sniper" },
    { class = "m9k_psg1",           name = "PSG-1",                cat = "Sniper" },
    { class = "m9k_contender",      name = "Contender G2",         cat = "Sniper" },
    { class = "m9k_m14sp",          name = "M14 EBR",              cat = "Sniper" },

    -- HEAVY (7 - LMGs, Minigun, Launchers)
    { class = "m9k_m249lmg",        name = "M249 LMG",             cat = "Heavy" },
    { class = "m9k_m60",            name = "M60",                  cat = "Heavy" },
    { class = "m9k_pkm",            name = "PKM",                  cat = "Heavy" },
    { class = "m9k_ares_shrike",    name = "Ares Shrike",          cat = "Heavy" },
    { class = "m9k_minigun",        name = "M134 Minigun",         cat = "Heavy" },
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
-- 4 STAT TYPES (matches actual M9K weapon properties)
-- ============================================================
BRS_UW.Stats = {
    { key = "dmg",  name = "DAMAGE",   shortName = "DMG",  color = Color(255, 80, 80),   applyKey = "Damage" },
    { key = "spd",  name = "ACCURACY", shortName = "ACC",  color = Color(80, 200, 255),  applyKey = "Spread", inverted = true },
    { key = "rpm",  name = "RPM",      shortName = "RPM",  color = Color(80, 255, 120),  applyKey = "RPM" },
    { key = "mag",  name = "MAGAZINE", shortName = "MAG",  color = Color(220, 80, 255),  applyKey = "ClipSize" },
}

BRS_UW.StatByKey = {}
for i, stat in ipairs(BRS_UW.Stats) do
    BRS_UW.StatByKey[stat.key] = stat
end

-- ============================================================
-- 7 RARITIES with stat boost ranges
-- Rarity determines the CEILING of possible rolls
-- Quality (forge tier) is derived from how well it actually rolled
-- Below Legendary = weak, Legendary+ = strong, Glitched/Mythical = god tier
-- ============================================================
BRS_UW.Rarities = {
    { key = "Common",    order = 1, color = Color(180,180,180), dropWeight = 40 },
    { key = "Uncommon",  order = 2, color = Color(120,200,80),  dropWeight = 28 },
    { key = "Rare",      order = 3, color = Color(42,133,219),  dropWeight = 16 },
    { key = "Epic",      order = 4, color = Color(152,68,255),  dropWeight = 9 },
    { key = "Legendary", order = 5, color = Color(255,165,0),   dropWeight = 4.5 },
    { key = "Glitched",  order = 6, color = Color(0,255,200),   dropWeight = 2 },
    { key = "Mythical",  order = 7, color = Color(255,50,50),   dropWeight = 0.5 },
}

BRS_UW.RarityByKey = {}
BRS_UW.RarityOrder = {}
for i, r in ipairs(BRS_UW.Rarities) do
    BRS_UW.RarityByKey[r.key] = r
    BRS_UW.RarityOrder[r.key] = r.order
end

-- ============================================================
-- QUALITY SYSTEM (rolled independently of rarity)
-- Every quality can appear on every rarity EXCEPT Ascended
-- Ascended is EXCLUSIVE to Glitched and Mythical rarities
-- Quality + Rarity together determine stat boost ranges
-- ============================================================
BRS_UW.Qualities = {
    { key = "Junk",     order = 1, weight = 10, color = Color(120,120,120) },
    { key = "Raw",      order = 2, weight = 20, color = Color(140,180,100) },
    { key = "Standard", order = 3, weight = 30, color = Color(80,160,220) },
    { key = "Forged",   order = 4, weight = 22, color = Color(180,120,255) },
    { key = "Refined",  order = 5, weight = 12, color = Color(255,180,40) },
    { key = "Ascended", order = 6, weight = 10, color = Color(255,60,60) },
}

BRS_UW.QualityByKey = {}
BRS_UW.QualityOrder = {}
for i, q in ipairs(BRS_UW.Qualities) do
    BRS_UW.QualityByKey[q.key] = q
    BRS_UW.QualityOrder[q.key] = i
end

-- Rarities that can roll Ascended quality
BRS_UW.AscendedRarities = {
    ["Glitched"] = true,
    ["Mythical"] = true,
}

-- ============================================================
-- STAT RANGE MATRIX: StatRanges[rarity][quality] = {min, max}
-- Both rarity and quality push stats higher
-- Common-Legendary: Refined is the best quality (capped at 100%)
-- Glitched Ascended: up to 115%
-- Mythical Ascended: up to 125%
-- ============================================================
BRS_UW.StatRanges = {
    Common = {
        Junk = {1, 5},       Raw = {2, 8},       Standard = {3, 14},
        Forged = {6, 22},    Refined = {10, 32},
    },
    Uncommon = {
        Junk = {2, 10},      Raw = {5, 16},      Standard = {8, 24},
        Forged = {12, 34},   Refined = {18, 46},
    },
    Rare = {
        Junk = {4, 16},      Raw = {8, 24},      Standard = {14, 36},
        Forged = {20, 50},   Refined = {28, 64},
    },
    Epic = {
        Junk = {6, 22},      Raw = {12, 34},     Standard = {20, 48},
        Forged = {30, 64},   Refined = {40, 78},
    },
    Legendary = {
        Junk = {10, 30},     Raw = {18, 44},     Standard = {28, 58},
        Forged = {38, 74},   Refined = {50, 92},
    },
    Glitched = {
        Junk = {14, 38},     Raw = {24, 52},     Standard = {34, 68},
        Forged = {46, 82},   Refined = {58, 96},  Ascended = {72, 115},
    },
    Mythical = {
        Junk = {20, 46},     Raw = {30, 62},     Standard = {42, 78},
        Forged = {56, 92},   Refined = {68, 100}, Ascended = {82, 125},
    },
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

-- Roll a random quality (Ascended only available for Glitched/Mythical)
function BRS_UW.RollQuality(rarityKey)
    local canAscend = BRS_UW.AscendedRarities[rarityKey] or false

    -- Build eligible pool
    local totalWeight = 0
    local pool = {}
    for _, q in ipairs(BRS_UW.Qualities) do
        if q.key ~= "Ascended" or canAscend then
            table.insert(pool, q)
            totalWeight = totalWeight + q.weight
        end
    end

    local roll = math.Rand(0, totalWeight)
    local current = 0
    for _, q in ipairs(pool) do
        current = current + q.weight
        if roll <= current then
            return q.key, q.color
        end
    end
    return "Junk", BRS_UW.Qualities[1].color
end

-- Get quality from average boost (legacy compat for old weapons)
function BRS_UW.GetQuality(avgBoost)
    -- Legacy thresholds for existing weapons in DB
    local thresholds = {
        { "Junk", 4 }, { "Raw", 10 }, { "Standard", 20 },
        { "Forged", 38 }, { "Refined", 60 }, { "Ascended", 200 },
    }
    for _, t in ipairs(thresholds) do
        if avgBoost < t[2] then return t[1] end
    end
    return "Ascended"
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

-- Generate random stats based on BOTH rarity and quality
function BRS_UW.GenerateStats(rarityKey, qualityKey)
    qualityKey = qualityKey or "Standard"

    -- Look up stat range from 2D matrix
    local rarityRanges = BRS_UW.StatRanges[rarityKey]
    if not rarityRanges then rarityRanges = BRS_UW.StatRanges["Common"] end
    local range = rarityRanges[qualityKey]
    if not range then range = rarityRanges["Standard"] end

    local statMin, statMax = range[1], range[2]
    local span = statMax - statMin

    local stats = {}
    for _, statDef in ipairs(BRS_UW.Stats) do
        -- Each stat rolls independently with variance
        -- 70% chance: normal roll (mild bell curve)
        -- 20% chance: low roll (bottom 40% of range)
        -- 10% chance: high roll (top 30% of range)
        local roll = math.random()
        local value

        if roll < 0.10 then
            value = statMin + span * math.Rand(0.70, 1.0)
        elseif roll < 0.30 then
            value = statMin + span * math.Rand(0.0, 0.40)
        else
            local r1 = math.Rand(0, 1)
            local r2 = math.Rand(0, 1)
            value = statMin + span * ((r1 + r2) / 2)
        end

        stats[statDef.key] = math.Round(math.Clamp(value, statMin, statMax), 1)
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
