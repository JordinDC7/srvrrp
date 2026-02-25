--[[
    UNIQUE WEAPON SYSTEM - Shared Definitions
    CS:GO-style unboxing with unique stat-boosted weapons
    Each unboxed weapon is one-of-a-kind with randomized stat modifiers
]]--

BRS_WEAPONS = BRS_WEAPONS or {}

-- ============================================================
-- RARITY TIERS
-- ============================================================
BRS_WEAPONS.Rarities = {
    ["Common"] = {
        Order = 1, Color = Color(154, 154, 154),
        GradientFrom = Color(154, 154, 154), GradientTo = Color(200, 200, 200),
        MinBoost = 0.00, MaxBoost = 0.10, StatSlots = { min = 1, max = 2 }, GlowAlpha = 0,
    },
    ["Uncommon"] = {
        Order = 2, Color = Color(104, 255, 104),
        GradientFrom = Color(104, 255, 104), GradientTo = Color(156, 255, 156),
        MinBoost = 0.05, MaxBoost = 0.20, StatSlots = { min = 2, max = 3 }, GlowAlpha = 30,
    },
    ["Rare"] = {
        Order = 3, Color = Color(42, 133, 219),
        GradientFrom = Color(42, 133, 219), GradientTo = Color(100, 180, 255),
        MinBoost = 0.10, MaxBoost = 0.35, StatSlots = { min = 2, max = 4 }, GlowAlpha = 60,
    },
    ["Epic"] = {
        Order = 4, Color = Color(152, 68, 255),
        GradientFrom = Color(152, 68, 255), GradientTo = Color(200, 140, 255),
        MinBoost = 0.20, MaxBoost = 0.50, StatSlots = { min = 3, max = 4 }, GlowAlpha = 90,
    },
    ["Legendary"] = {
        Order = 5, Color = Color(253, 191, 45),
        GradientFrom = Color(253, 191, 45), GradientTo = Color(255, 220, 100),
        MinBoost = 0.35, MaxBoost = 0.75, StatSlots = { min = 3, max = 5 }, GlowAlpha = 120,
    },
    ["Glitched"] = {
        Order = 6, Color = Color(255, 50, 50),
        GradientFrom = Color(255, 50, 50), GradientTo = Color(255, 120, 50),
        MinBoost = 0.50, MaxBoost = 1.00, StatSlots = { min = 4, max = 5 }, GlowAlpha = 160,
        CanRollNegative = true,
    },
    ["Mythical"] = {
        Order = 7, Color = Color(255, 0, 200),
        GradientFrom = Color(255, 0, 200), GradientTo = Color(255, 100, 255),
        MinBoost = 0.75, MaxBoost = 1.50, StatSlots = { min = 5, max = 6 }, GlowAlpha = 200,
    },
}

-- ============================================================
-- STAT BOOSTER DEFINITIONS
-- ============================================================
BRS_WEAPONS.StatDefs = {
    ["DMG"] = {
        Name = "Damage", ShortName = "DMG",
        Color = Color(255, 60, 60),
        WeaponKey = "Primary.Damage",
        ApplyFunc = function(wep, base, boost) return math.Round(base * (1 + boost)) end,
    },
    ["ACC"] = {
        Name = "Accuracy", ShortName = "ACC",
        Color = Color(255, 220, 50),
        WeaponKey = "Primary.Spread",
        ApplyFunc = function(wep, base, boost) return base * (1 - boost * 0.5) end,
    },
    ["MAG"] = {
        Name = "Magazine", ShortName = "MAG",
        Color = Color(50, 255, 80),
        WeaponKey = "Primary.ClipSize",
        ApplyFunc = function(wep, base, boost) return math.Round(base * (1 + boost)) end,
    },
    ["RPM"] = {
        Name = "Fire Rate", ShortName = "RPM",
        Color = Color(50, 150, 255),
        WeaponKey = "Primary.RPM",
        ApplyFunc = function(wep, base, boost) return math.Round(base * (1 + boost * 0.5)) end,
    },
    ["SPD"] = {
        Name = "Speed", ShortName = "SPD",
        Color = Color(200, 50, 255),
        WeaponKey = "Primary.Recoil",
        ApplyFunc = function(wep, base, boost) return base * (1 - boost * 0.4) end,
    },
}

-- All stat keys for iteration
BRS_WEAPONS.StatKeys = { "DMG", "ACC", "MAG", "RPM", "SPD" }

-- ============================================================
-- QUALITY NAMES (based on average boost %)
-- ============================================================
BRS_WEAPONS.Qualities = {
    { name = "Junk",      minAvg = 0,    maxAvg = 0.08,  color = Color(120, 120, 120) },
    { name = "Raw",       minAvg = 0.08, maxAvg = 0.20,  color = Color(180, 180, 180) },
    { name = "Standard",  minAvg = 0.20, maxAvg = 0.40,  color = Color(104, 255, 104) },
    { name = "Refined",   minAvg = 0.40, maxAvg = 0.60,  color = Color(42, 180, 255) },
    { name = "Forged",    minAvg = 0.60, maxAvg = 0.85,  color = Color(255, 165, 0) },
    { name = "Perfected", minAvg = 0.85, maxAvg = 1.20,  color = Color(255, 50, 50) },
    { name = "Ascended",  minAvg = 1.20, maxAvg = 99,    color = Color(255, 0, 200) },
}

function BRS_WEAPONS.GetQuality(statBoosters)
    if not statBoosters or table.Count(statBoosters) == 0 then
        return BRS_WEAPONS.Qualities[1]
    end
    local total, count = 0, 0
    for _, v in pairs(statBoosters) do
        total = total + math.abs(v)
        count = count + 1
    end
    local avg = total / count
    for _, q in ipairs(BRS_WEAPONS.Qualities) do
        if avg >= q.minAvg and avg < q.maxAvg then
            return q, avg
        end
    end
    return BRS_WEAPONS.Qualities[#BRS_WEAPONS.Qualities], total / count
end

-- ============================================================
-- WEAPON DATABASE (78 weapons, ordered by category)
-- ============================================================
BRS_WEAPONS.AllWeapons = {
    { class = "m9k_colt1911", name = "Colt 1911", category = "Pistol" },
    { class = "m9k_model3russian", name = "S&W Model 3 Russian", category = "Pistol" },
    { class = "m9k_glock", name = "Glock 18", category = "Pistol" },
    { class = "m9k_hk45", name = "HK45C", category = "Pistol" },
    { class = "m9k_luger", name = "Luger P08", category = "Pistol" },
    { class = "m9k_m92baretta", name = "Beretta M92", category = "Pistol" },
    { class = "m9k_sig_p229r", name = "SIG P229R", category = "Pistol" },
    { class = "m9k_usp", name = "HK USP", category = "Pistol" },
    { class = "m9k_remington1858", name = "Remington 1858", category = "Pistol" },
    { class = "m9k_deagle", name = "Desert Eagle", category = "Pistol" },
    { class = "m9k_coltpython", name = "Colt Python", category = "Pistol" },
    { class = "m9k_model627", name = "S&W Model 627", category = "Pistol" },
    { class = "m9k_m29satan", name = "S&W Model 29 Satan", category = "Pistol" },
    { class = "m9k_model500", name = "S&W Model 500", category = "Pistol" },
    { class = "m9k_ragingbull", name = "Taurus Raging Bull", category = "Pistol" },
    { class = "m9k_tec9", name = "TEC-9", category = "Pistol" },
    { class = "m9k_mac10", name = "MAC-10", category = "SMG" },
    { class = "m9k_mp5", name = "MP5", category = "SMG" },
    { class = "m9k_mp5sd", name = "MP5SD", category = "SMG" },
    { class = "m9k_mp7", name = "MP7", category = "SMG" },
    { class = "m9k_mp9", name = "MP9", category = "SMG" },
    { class = "m9k_sten", name = "Sten", category = "SMG" },
    { class = "m9k_ump45", name = "UMP-45", category = "SMG" },
    { class = "m9k_bizonp19", name = "Bizon PP-19", category = "SMG" },
    { class = "m9k_thompson", name = "Thompson M1A1", category = "SMG" },
    { class = "m9k_magpulpdr", name = "Magpul PDR", category = "SMG" },
    { class = "m9k_smgp90", name = "FN P90", category = "SMG" },
    { class = "m9k_uzi", name = "Uzi", category = "SMG" },
    { class = "m9k_vector", name = "Kriss Vector", category = "SMG" },
    { class = "m9k_honeybadger", name = "Honey Badger", category = "SMG" },
    { class = "m9k_ak47", name = "AK-47", category = "Rifle" },
    { class = "m9k_ak74", name = "AK-74", category = "Rifle" },
    { class = "m9k_m4a1", name = "M4A1", category = "Rifle" },
    { class = "m9k_acr", name = "Remington ACR", category = "Rifle" },
    { class = "m9k_m416", name = "HK416", category = "Rifle" },
    { class = "m9k_fal", name = "FN FAL", category = "Rifle" },
    { class = "m9k_g3a3", name = "G3A3", category = "Rifle" },
    { class = "m9k_g36", name = "G36", category = "Rifle" },
    { class = "m9k_l85", name = "L85A2", category = "Rifle" },
    { class = "m9k_amd65", name = "AMD-65", category = "Rifle" },
    { class = "m9k_an94", name = "AN-94", category = "Rifle" },
    { class = "m9k_scar", name = "SCAR-H", category = "Rifle" },
    { class = "m9k_val", name = "AS VAL", category = "Rifle" },
    { class = "m9k_sig_sg552", name = "SIG SG552", category = "Rifle" },
    { class = "m9k_tar21", name = "TAR-21", category = "Rifle" },
    { class = "m9k_vikhr", name = "SR-3M Vikhr", category = "Rifle" },
    { class = "m9k_m14sp", name = "M14 SP", category = "Rifle" },
    { class = "m9k_m16a4_acog", name = "M16A4 ACOG", category = "Rifle" },
    { class = "m9k_winchester73", name = "Winchester 1873", category = "Rifle" },
    { class = "m9k_browningauto5", name = "Browning Auto-5", category = "Shotgun" },
    { class = "m9k_ithacam37", name = "Ithaca M37", category = "Shotgun" },
    { class = "m9k_mossberg590", name = "Mossberg 590", category = "Shotgun" },
    { class = "m9k_remington870", name = "Remington 870", category = "Shotgun" },
    { class = "m9k_spas12", name = "SPAS-12", category = "Shotgun" },
    { class = "m9k_m3", name = "Benelli M3", category = "Shotgun" },
    { class = "m9k_dao12", name = "DAO-12", category = "Shotgun" },
    { class = "m9k_jackhammer", name = "Pancor Jackhammer", category = "Shotgun" },
    { class = "m9k_striker12", name = "Striker-12", category = "Shotgun" },
    { class = "m9k_usas", name = "USAS-12", category = "Shotgun" },
    { class = "m9k_dbarrel", name = "Double Barrel", category = "Shotgun" },
    { class = "m9k_m24", name = "M24", category = "Sniper" },
    { class = "m9k_psg1", name = "PSG-1", category = "Sniper" },
    { class = "m9k_dragunov", name = "SVD Dragunov", category = "Sniper" },
    { class = "m9k_svt40", name = "SVT-40", category = "Sniper" },
    { class = "m9k_remington7615p", name = "Remington 7615P", category = "Sniper" },
    { class = "m9k_sl8", name = "HK SL8", category = "Sniper" },
    { class = "m9k_contender", name = "Contender G2", category = "Sniper" },
    { class = "m9k_intervention", name = "Intervention", category = "Sniper" },
    { class = "m9k_m98b", name = "M98B", category = "Sniper" },
    { class = "m9k_aw50", name = "AW50", category = "Sniper" },
    { class = "m9k_barret_m82", name = "Barrett M82", category = "Sniper" },
    { class = "m9k_m249lmg", name = "M249 SAW", category = "LMG" },
    { class = "m9k_m60", name = "M60", category = "LMG" },
    { class = "m9k_pkm", name = "PKM", category = "LMG" },
    { class = "m9k_ares_shrike", name = "Ares Shrike", category = "LMG" },
    { class = "m9k_minigun", name = "Minigun", category = "LMG" },
    { class = "m9k_milkormgl", name = "Milkor MGL", category = "Explosive" },
    { class = "m9k_m202", name = "M202 Flash", category = "Explosive" },
}

-- Build lookup tables
BRS_WEAPONS.WeaponByClass = {}
BRS_WEAPONS.WeaponByIndex = {}
for i, wep in ipairs(BRS_WEAPONS.AllWeapons) do
    BRS_WEAPONS.WeaponByClass[wep.class] = wep
    wep.index = i
    BRS_WEAPONS.WeaponByIndex[i] = wep
end

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

function BRS_WEAPONS.GenerateUID()
    local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    local uid = ""
    for i = 1, 8 do
        local idx = math.random(1, #chars)
        uid = uid .. string.sub(chars, idx, idx)
    end
    return uid
end

function BRS_WEAPONS.RollStatBoosters(rarity)
    local rarityDef = BRS_WEAPONS.Rarities[rarity]
    if not rarityDef then rarityDef = BRS_WEAPONS.Rarities["Common"] end

    local numSlots = math.random(rarityDef.StatSlots.min, rarityDef.StatSlots.max)
    local available = table.Copy(BRS_WEAPONS.StatKeys)
    local boosters = {}

    for i = 1, math.min(numSlots, #available) do
        local idx = math.random(1, #available)
        local statKey = available[idx]
        table.remove(available, idx)

        local boost = math.Rand(rarityDef.MinBoost, rarityDef.MaxBoost)

        if rarityDef.CanRollNegative and math.random() < 0.15 then
            boost = -boost * 0.5
        end

        boosters[statKey] = math.Round(boost, 4)
    end

    return boosters
end

function BRS_WEAPONS.FormatBoost(statKey, boostValue)
    if boostValue >= 0 then
        return "+" .. math.Round(boostValue * 100, 1) .. "%"
    else
        return math.Round(boostValue * 100, 1) .. "%"
    end
end

function BRS_WEAPONS.GetBoostColor(statKey, boostValue)
    local statDef = BRS_WEAPONS.StatDefs[statKey]
    if boostValue < 0 then return Color(255, 50, 50) end
    return statDef and statDef.Color or Color(255, 255, 255)
end

function BRS_WEAPONS.GetRarityOrder(rarity)
    local def = BRS_WEAPONS.Rarities[rarity]
    return def and def.Order or 0
end

function BRS_WEAPONS.GetRarityColor(rarity)
    local def = BRS_WEAPONS.Rarities[rarity]
    return def and def.Color or Color(255, 255, 255)
end

print("[BRS UniqueWeapons] Shared definitions loaded - " .. #BRS_WEAPONS.AllWeapons .. " weapons, 6 stat types, 7 qualities")
