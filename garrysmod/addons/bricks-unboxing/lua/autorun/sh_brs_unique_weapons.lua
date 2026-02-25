--[[
    UNIQUE WEAPON SYSTEM - Shared Definitions
    CS:GO-style unboxing with unique stat-boosted weapons
    Each unboxed weapon is one-of-a-kind with randomized stat modifiers
]]--

BRS_WEAPONS = BRS_WEAPONS or {}

-- ============================================================
-- RARITY TIERS (least to greatest)
-- Each tier defines the min/max percentage boost for stat rolls
-- ============================================================
BRS_WEAPONS.Rarities = {
    ["Common"] = {
        Order = 1,
        Color = Color(154, 154, 154),
        GradientFrom = Color(154, 154, 154),
        GradientTo = Color(200, 200, 200),
        MinBoost = 0.00,
        MaxBoost = 0.10,
        StatSlots = { min = 1, max = 2 },
        GlowAlpha = 0,
    },
    ["Uncommon"] = {
        Order = 2,
        Color = Color(104, 255, 104),
        GradientFrom = Color(104, 255, 104),
        GradientTo = Color(156, 255, 156),
        MinBoost = 0.05,
        MaxBoost = 0.20,
        StatSlots = { min = 2, max = 3 },
        GlowAlpha = 30,
    },
    ["Rare"] = {
        Order = 3,
        Color = Color(42, 133, 219),
        GradientFrom = Color(42, 133, 219),
        GradientTo = Color(63, 200, 255),
        MinBoost = 0.10,
        MaxBoost = 0.35,
        StatSlots = { min = 2, max = 4 },
        GlowAlpha = 60,
    },
    ["Epic"] = {
        Order = 4,
        Color = Color(152, 68, 255),
        GradientFrom = Color(152, 68, 255),
        GradientTo = Color(200, 120, 255),
        MinBoost = 0.20,
        MaxBoost = 0.50,
        StatSlots = { min = 3, max = 4 },
        GlowAlpha = 90,
    },
    ["Legendary"] = {
        Order = 5,
        Color = Color(253, 191, 45),
        GradientFrom = Color(253, 191, 45),
        GradientTo = Color(255, 220, 100),
        MinBoost = 0.35,
        MaxBoost = 0.75,
        StatSlots = { min = 3, max = 5 },
        GlowAlpha = 120,
    },
    ["Glitched"] = {
        Order = 6,
        Color = Color(255, 50, 50),
        GradientFrom = Color(255, 50, 50),
        GradientTo = Color(50, 255, 50),
        MinBoost = 0.50,
        MaxBoost = 1.00,
        StatSlots = { min = 4, max = 5 },
        GlowAlpha = 160,
        CanNegative = true, -- Glitched can roll negative modifiers too
    },
    ["Mythical"] = {
        Order = 7,
        Color = Color(255, 0, 200),
        GradientFrom = Color(255, 0, 200),
        GradientTo = Color(0, 200, 255),
        MinBoost = 0.75,
        MaxBoost = 1.50,
        StatSlots = { min = 5, max = 6 },
        GlowAlpha = 200,
    },
}

-- ============================================================
-- STAT BOOSTER DEFINITIONS
-- These are the weapon stats that can be randomly boosted
-- ============================================================
BRS_WEAPONS.StatDefs = {
    ["DMG"] = {
        Name = "Damage",
        ShortName = "DMG",
        Icon = "☠",
        Description = "Increases bullet damage",
        WeaponKey = "Primary.Damage",
        IsPositive = true,
        FormatFunc = function(base, boost) return string.format("+%d%%", boost * 100) end,
        ApplyFunc = function(wep, base, boost)
            return math.floor(base * (1 + boost))
        end,
    },
    ["MAG"] = {
        Name = "Magazine",
        ShortName = "MAG",
        Icon = "🔋",
        Description = "Increases magazine capacity",
        WeaponKey = "Primary.ClipSize",
        IsPositive = true,
        FormatFunc = function(base, boost) return string.format("+%d%%", boost * 100) end,
        ApplyFunc = function(wep, base, boost)
            return math.floor(base * (1 + boost))
        end,
    },
    ["RPM"] = {
        Name = "Fire Rate",
        ShortName = "RPM",
        Icon = "⚡",
        Description = "Increases rate of fire",
        WeaponKey = "Primary.RPM",
        IsPositive = true,
        FormatFunc = function(base, boost) return string.format("+%d%%", boost * 100) end,
        ApplyFunc = function(wep, base, boost)
            return math.floor(base * (1 + boost))
        end,
    },
    ["ACC"] = {
        Name = "Accuracy",
        ShortName = "ACC",
        Icon = "🎯",
        Description = "Reduces bullet spread",
        WeaponKey = "Primary.Spread",
        IsPositive = false, -- Lower spread = better
        FormatFunc = function(base, boost) return string.format("+%d%%", boost * 100) end,
        ApplyFunc = function(wep, base, boost)
            return base * (1 - boost * 0.5) -- Cap at 50% reduction
        end,
    },
    ["RCL"] = {
        Name = "Recoil Control",
        ShortName = "RCL",
        Icon = "🔧",
        Description = "Reduces weapon recoil",
        WeaponKey = "Primary.Recoil",
        IsPositive = false, -- Lower recoil = better
        FormatFunc = function(base, boost) return string.format("+%d%%", boost * 100) end,
        ApplyFunc = function(wep, base, boost)
            return base * (1 - boost * 0.5)
        end,
    },
    ["RNG"] = {
        Name = "Range",
        ShortName = "RNG",
        Icon = "📏",
        Description = "Increases effective range",
        WeaponKey = "Primary.Range",
        IsPositive = true,
        FormatFunc = function(base, boost) return string.format("+%d%%", boost * 100) end,
        ApplyFunc = function(wep, base, boost)
            return math.floor(base * (1 + boost))
        end,
    },
}

-- ============================================================
-- COMPLETE M9K WEAPON DATABASE
-- All weapons from M9K Small Arms, Assault Rifles, Heavy Weapons, Specialties
-- ============================================================
BRS_WEAPONS.AllWeapons = {
    -- ========================
    -- M9K SMALL ARMS (Pistols & SMGs)
    -- ========================
    { class = "m9k_colt_1911",           name = "Colt 1911",              model = "models/weapons/w_1911.mdl",                  category = "Pistol" },
    { class = "m9k_browninghp",          name = "Browning Hi-Power",      model = "models/weapons/w_browning_hp.mdl",           category = "Pistol" },
    { class = "m9k_coltpython",          name = "Colt Python",            model = "models/weapons/w_colt_python.mdl",           category = "Pistol" },
    { class = "m9k_deagle",              name = "Desert Eagle",           model = "models/weapons/w_tcom_deagle.mdl",           category = "Pistol" },
    { class = "m9k_glock",               name = "Glock 18",              model = "models/weapons/w_dmg_glock.mdl",             category = "Pistol" },
    { class = "m9k_hk45",               name = "HK45C",                 model = "models/weapons/w_hk45c.mdl",                 category = "Pistol" },
    { class = "m9k_luger",               name = "Luger P08",             model = "models/weapons/w_luger_p08.mdl",             category = "Pistol" },
    { class = "m9k_m29satan",            name = "S&W Model 29 Satan",    model = "models/weapons/w_sw_model_29.mdl",           category = "Pistol" },
    { class = "m9k_m92beretta",          name = "Beretta M92",           model = "models/weapons/w_beretta_m92.mdl",           category = "Pistol" },
    { class = "m9k_model500",            name = "S&W Model 500",         model = "models/weapons/w_sw_model_500.mdl",          category = "Pistol" },
    { class = "m9k_model627",            name = "S&W Model 627",         model = "models/weapons/w_sw_model_627.mdl",          category = "Pistol" },
    { class = "m9k_ragingbull",          name = "Taurus Raging Bull",    model = "models/weapons/w_taurus_raging_bull.mdl",    category = "Pistol" },
    { class = "m9k_remington1858",       name = "Remington 1858",        model = "models/weapons/w_remington_1858.mdl",        category = "Pistol" },
    { class = "m9k_scoped_taurus",       name = "Scoped Taurus",         model = "models/weapons/w_raging_bull_scoped.mdl",    category = "Pistol" },
    { class = "m9k_sig_p229r",           name = "SIG P229R",             model = "models/weapons/w_sig_229r.mdl",              category = "Pistol" },
    { class = "m9k_usp",                 name = "HK USP",                model = "models/weapons/w_pist_fokkususp.mdl",        category = "Pistol" },
    { class = "m9k_tec9",                name = "TEC-9",                 model = "models/weapons/w_intratec_tec9.mdl",         category = "Pistol" },

    -- SMGs
    { class = "m9k_bizonp19",            name = "Bizon PP-19",           model = "models/weapons/w_pp19_bizon.mdl",            category = "SMG" },
    { class = "m9k_honeybadger",         name = "Honey Badger",          model = "models/weapons/w_aac_honeybadger.mdl",       category = "SMG" },
    { class = "m9k_mac10",               name = "MAC-10",                model = "models/weapons/w_mac_10.mdl",                category = "SMG" },
    { class = "m9k_mp5",                 name = "MP5",                   model = "models/weapons/w_hk_mp5.mdl",               category = "SMG" },
    { class = "m9k_mp5sd",               name = "MP5SD",                 model = "models/weapons/w_hk_mp5sd.mdl",             category = "SMG" },
    { class = "m9k_mp7",                 name = "MP7",                   model = "models/weapons/w_mp7_silenced.mdl",          category = "SMG" },
    { class = "m9k_mp9",                 name = "MP9",                   model = "models/weapons/w_brugger_thomet_mp9.mdl",    category = "SMG" },
    { class = "m9k_mp40",                name = "MP40",                  model = "models/weapons/w_mp40_ww2.mdl",              category = "SMG" },
    { class = "m9k_ppsh",                name = "PPSh-41",               model = "models/weapons/w_ppsh_41_ww2.mdl",           category = "SMG" },
    { class = "m9k_smgp90",              name = "FN P90",                model = "models/weapons/w_fn_p90.mdl",                category = "SMG" },
    { class = "m9k_thompson",            name = "Thompson M1A1",         model = "models/weapons/w_m1a1_thompson.mdl",         category = "SMG" },
    { class = "m9k_uzi",                 name = "Uzi",                   model = "models/weapons/w_uzi_imi.mdl",              category = "SMG" },
    { class = "m9k_ump45",               name = "UMP-45",                model = "models/weapons/w_hk_ump45.mdl",             category = "SMG" },
    { class = "m9k_vector",              name = "Kriss Vector",          model = "models/weapons/w_kriss_vector.mdl",          category = "SMG" },

    -- ========================
    -- M9K ASSAULT RIFLES
    -- ========================
    { class = "m9k_acr",                 name = "Remington ACR",         model = "models/weapons/w_masada_acr.mdl",            category = "Rifle" },
    { class = "m9k_ak47",               name = "AK-47",                 model = "models/weapons/w_ak47_m9k.mdl",              category = "Rifle" },
    { class = "m9k_ak74",               name = "AK-74",                 model = "models/weapons/w_tct_ak74.mdl",              category = "Rifle" },
    { class = "m9k_amd65",              name = "AMD-65",                model = "models/weapons/w_amd_65.mdl",                category = "Rifle" },
    { class = "m9k_an94",               name = "AN-94",                 model = "models/weapons/w_an_94.mdl",                 category = "Rifle" },
    { class = "m9k_m416",               name = "HK416",                 model = "models/weapons/w_hk_416.mdl",                category = "Rifle" },
    { class = "m9k_fal",                name = "FN FAL",                model = "models/weapons/w_fn_fal.mdl",                category = "Rifle" },
    { class = "m9k_g3a3",               name = "G3A3",                  model = "models/weapons/w_hk_g3.mdl",                 category = "Rifle" },
    { class = "m9k_g36",                name = "G36",                   model = "models/weapons/w_hk_g36.mdl",                category = "Rifle" },
    { class = "m9k_l85",                name = "L85A2",                 model = "models/weapons/w_l85a2.mdl",                 category = "Rifle" },
    { class = "m9k_m14sp",              name = "M14 SP",                model = "models/weapons/w_snip_m14sp.mdl",            category = "Rifle" },
    { class = "m9k_m16a4_acog",         name = "M16A4 ACOG",           model = "models/weapons/w_m16a4_acog.mdl",            category = "Rifle" },
    { class = "m9k_m4a1",               name = "M4A1",                  model = "models/weapons/w_m4a1_iron.mdl",             category = "Rifle" },
    { class = "m9k_scar",               name = "SCAR-H",               model = "models/weapons/w_fn_scar_h.mdl",             category = "Rifle" },
    { class = "m9k_scarl",              name = "SCAR-L",               model = "models/weapons/w_fn_scar_l.mdl",             category = "Rifle" },
    { class = "m9k_sig_sg552",          name = "SIG SG552",            model = "models/weapons/w_sig_sg552.mdl",             category = "Rifle" },
    { class = "m9k_tar21",              name = "TAR-21",                model = "models/weapons/w_imi_tar21.mdl",             category = "Rifle" },
    { class = "m9k_vikhr",              name = "SR-3M Vikhr",           model = "models/weapons/w_sr3m_vikhr.mdl",            category = "Rifle" },
    { class = "m9k_Winchester73",       name = "Winchester 1873",       model = "models/weapons/w_winchester_1873.mdl",       category = "Rifle" },

    -- ========================
    -- M9K HEAVY WEAPONS
    -- ========================
    -- Shotguns
    { class = "m9k_ares_shrike",        name = "Ares Shrike",           model = "models/weapons/w_ares_shrike.mdl",           category = "LMG" },
    { class = "m9k_browningauto5",      name = "Browning Auto-5",       model = "models/weapons/w_browning_auto_5.mdl",       category = "Shotgun" },
    { class = "m9k_dao12",              name = "DAO-12",                model = "models/weapons/w_dao12.mdl",                 category = "Shotgun" },
    { class = "m9k_ithacam37",          name = "Ithaca M37",            model = "models/weapons/w_ithaca_m37.mdl",            category = "Shotgun" },
    { class = "m9k_jackhammer",         name = "Pancor Jackhammer",     model = "models/weapons/w_pancor_jackhammer.mdl",     category = "Shotgun" },
    { class = "m9k_m3",                 name = "Benelli M3",            model = "models/weapons/w_benelli_m3.mdl",            category = "Shotgun" },
    { class = "m9k_mossberg590",        name = "Mossberg 590",          model = "models/weapons/w_mossberg_590.mdl",          category = "Shotgun" },
    { class = "m9k_remington870",       name = "Remington 870",         model = "models/weapons/w_remington_870_tact.mdl",    category = "Shotgun" },
    { class = "m9k_spas12",             name = "SPAS-12",               model = "models/weapons/w_spas_12.mdl",               category = "Shotgun" },
    { class = "m9k_striker12",          name = "Striker-12",            model = "models/weapons/w_striker_12g.mdl",            category = "Shotgun" },
    { class = "m9k_usas",               name = "USAS-12",               model = "models/weapons/w_usas_12.mdl",               category = "Shotgun" },

    -- Snipers
    { class = "m9k_aw50",               name = "AW50",                  model = "models/weapons/w_acc_int_aw50.mdl",          category = "Sniper" },
    { class = "m9k_barrettm82",         name = "Barrett M82",           model = "models/weapons/w_barrett_m82.mdl",           category = "Sniper" },
    { class = "m9k_contender",          name = "Contender G2",          model = "models/weapons/w_g2_contender.mdl",          category = "Sniper" },
    { class = "m9k_dragunov",           name = "SVD Dragunov",          model = "models/weapons/w_svd_dragunov.mdl",          category = "Sniper" },
    { class = "m9k_intervention",       name = "Intervention",          model = "models/weapons/w_cheytac_m200.mdl",          category = "Sniper" },
    { class = "m9k_m24",                name = "M24",                   model = "models/weapons/w_remington_m24.mdl",         category = "Sniper" },
    { class = "m9k_m98b",               name = "M98B",                  model = "models/weapons/w_barrett_m98b.mdl",          category = "Sniper" },
    { class = "m9k_psg1",               name = "PSG-1",                 model = "models/weapons/w_hk_psg1.mdl",              category = "Sniper" },
    { class = "m9k_remington7615p",     name = "Remington 7615P",       model = "models/weapons/w_remington_7615p.mdl",       category = "Sniper" },
    { class = "m9k_sl8",                name = "HK SL8",                model = "models/weapons/w_hk_sl8.mdl",               category = "Sniper" },
    { class = "m9k_svt40",              name = "SVT-40",                model = "models/weapons/w_svt_40.mdl",                category = "Sniper" },

    -- LMGs
    { class = "m9k_m60",                name = "M60",                   model = "models/weapons/w_m60_machine_gun.mdl",       category = "LMG" },
    { class = "m9k_m249lmg",            name = "M249 SAW",              model = "models/weapons/w_m249_machine_gun.mdl",      category = "LMG" },
    { class = "m9k_pkm",                name = "PKM",                   model = "models/weapons/w_pkm_mg.mdl",               category = "LMG" },

    -- Explosives & Specials
    { class = "m9k_milkormgl",          name = "Milkor MGL",            model = "models/weapons/w_milkor_mgl.mdl",            category = "Explosive" },
    { class = "m9k_m202",               name = "M202 Flash",            model = "models/weapons/w_m202_flash.mdl",            category = "Explosive" },
    { class = "m9k_minigun",            name = "Minigun",               model = "models/weapons/w_m134_minigun.mdl",          category = "LMG" },
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
-- STAT ROLLING FUNCTIONS
-- ============================================================

--- Generate a unique weapon ID
function BRS_WEAPONS.GenerateUID()
    local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    local uid = ""
    for i = 1, 8 do
        local idx = math.random(1, #chars)
        uid = uid .. string.sub(chars, idx, idx)
    end
    return uid
end

--- Roll random stat boosters for a weapon based on rarity
function BRS_WEAPONS.RollStatBoosters(rarity)
    local rarityDef = BRS_WEAPONS.Rarities[rarity]
    if not rarityDef then return {} end

    local statKeys = {}
    for k, _ in pairs(BRS_WEAPONS.StatDefs) do
        table.insert(statKeys, k)
    end

    -- Determine how many stats to boost
    local numStats = math.random(rarityDef.StatSlots.min, rarityDef.StatSlots.max)
    numStats = math.min(numStats, #statKeys)

    -- Shuffle and pick stats
    for i = #statKeys, 2, -1 do
        local j = math.random(1, i)
        statKeys[i], statKeys[j] = statKeys[j], statKeys[i]
    end

    local boosters = {}
    for i = 1, numStats do
        local statKey = statKeys[i]
        local boost = rarityDef.MinBoost + math.random() * (rarityDef.MaxBoost - rarityDef.MinBoost)

        -- Glitched rarity can roll negative modifiers on some stats
        if rarityDef.CanNegative and math.random() < 0.25 then
            boost = -boost * 0.5 -- Negative but less severe
        end

        -- Round to 2 decimal places
        boost = math.Round(boost, 2)

        boosters[statKey] = boost
    end

    return boosters
end

--- Get formatted stat boost text
function BRS_WEAPONS.FormatBoost(statKey, boostValue)
    local def = BRS_WEAPONS.StatDefs[statKey]
    if not def then return "" end

    local pct = math.Round(boostValue * 100)
    if pct >= 0 then
        return "+" .. pct .. "%"
    else
        return pct .. "%"
    end
end

--- Get boost color (green for positive, red for negative)
function BRS_WEAPONS.GetBoostColor(statKey, boostValue)
    if boostValue >= 0 then
        return Color(100, 255, 100)
    else
        return Color(255, 100, 100)
    end
end

--- Get rarity sort order
function BRS_WEAPONS.GetRarityOrder(rarity)
    local def = BRS_WEAPONS.Rarities[rarity]
    return def and def.Order or 0
end

--- Get rarity color
function BRS_WEAPONS.GetRarityColor(rarity)
    local def = BRS_WEAPONS.Rarities[rarity]
    return def and def.Color or Color(255, 255, 255)
end

print("[BRS UniqueWeapons] Shared definitions loaded - " .. #BRS_WEAPONS.AllWeapons .. " weapons, 7 rarity tiers")
