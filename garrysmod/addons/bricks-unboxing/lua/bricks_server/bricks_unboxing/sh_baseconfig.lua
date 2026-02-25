--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame or use the f4menu
    !!WARNING!!
]]--

--[[ MODULES CONFIG ]]--
BRICKS_SERVER.BASECONFIG.MODULES = BRICKS_SERVER.BASECONFIG.MODULES or {}
BRICKS_SERVER.BASECONFIG.MODULES["unboxing"] = { true, {
    ["marketplace"] = true,
    ["rewards"] = true,
    ["trading"] = true
} }

--[[ UNBOXING CONFIG ]]--
BRICKS_SERVER.BASECONFIG.UNBOXING = {}
BRICKS_SERVER.BASECONFIG.UNBOXING["Case UI Open Time"] = 5
BRICKS_SERVER.BASECONFIG.UNBOXING["Case Open Time"] = 5
BRICKS_SERVER.BASECONFIG.UNBOXING["Activity Entry Limit"] = 25
BRICKS_SERVER.BASECONFIG.UNBOXING["Auction Minimum Starting Price"] = 1000
BRICKS_SERVER.BASECONFIG.UNBOXING["Auction Maximum Starting Price"] = 1000000000
BRICKS_SERVER.BASECONFIG.UNBOXING["Auction Minimum Duration"] = 600
BRICKS_SERVER.BASECONFIG.UNBOXING["Auction Maximum Duration"] = 604800
BRICKS_SERVER.BASECONFIG.UNBOXING["Auctions Per Page"] = 12
BRICKS_SERVER.BASECONFIG.UNBOXING["Auctions Minimum Bid Increase"] = 1.1
BRICKS_SERVER.BASECONFIG.UNBOXING["Dead Auction Remove Time"] = 259200
BRICKS_SERVER.BASECONFIG.UNBOXING["Cases Leaderboard Limit"] = 10
BRICKS_SERVER.BASECONFIG.UNBOXING["Disable Item Halos"] = false
BRICKS_SERVER.BASECONFIG.UNBOXING["Disable Case Collisions"] = false

-- ============================================================
-- 78 M9K WEAPONS - 7 RARITY TIERS
-- ============================================================
BRICKS_SERVER.BASECONFIG.UNBOXING.Items = {
    [1] = {
        Name = "Colt 1911",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_colt_1911" }
    },
    [2] = {
        Name = "Browning Hi-Power",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_browninghp" }
    },
    [3] = {
        Name = "Glock 18",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_glock" }
    },
    [4] = {
        Name = "HK45C",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_hk45" }
    },
    [5] = {
        Name = "Luger P08",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_luger" }
    },
    [6] = {
        Name = "Beretta M92",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_m92beretta" }
    },
    [7] = {
        Name = "SIG P229R",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_sig_p229r" }
    },
    [8] = {
        Name = "HK USP",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_usp" }
    },
    [9] = {
        Name = "Remington 1858",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_remington1858" }
    },
    [10] = {
        Name = "MAC-10",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_mac10" }
    },
    [11] = {
        Name = "MP40",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_mp40" }
    },
    [12] = {
        Name = "Uzi",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_uzi" }
    },
    [13] = {
        Name = "TEC-9",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_tec9" }
    },
    [14] = {
        Name = "Winchester 1873",
        Type = "PermWeapon",
        Rarity = "Common",
        ReqInfo = { "m9k_Winchester73" }
    },
    [15] = {
        Name = "Desert Eagle",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_deagle" }
    },
    [16] = {
        Name = "Colt Python",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_coltpython" }
    },
    [17] = {
        Name = "S&W Model 627",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_model627" }
    },
    [18] = {
        Name = "MP5",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_mp5" }
    },
    [19] = {
        Name = "MP5SD",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_mp5sd" }
    },
    [20] = {
        Name = "MP7",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_mp7" }
    },
    [21] = {
        Name = "MP9",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_mp9" }
    },
    [22] = {
        Name = "UMP-45",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_ump45" }
    },
    [23] = {
        Name = "Bizon PP-19",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_bizonp19" }
    },
    [24] = {
        Name = "Thompson M1A1",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_thompson" }
    },
    [25] = {
        Name = "PPSh-41",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_ppsh" }
    },
    [26] = {
        Name = "Browning Auto-5",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_browningauto5" }
    },
    [27] = {
        Name = "Ithaca M37",
        Type = "PermWeapon",
        Rarity = "Uncommon",
        ReqInfo = { "m9k_ithacam37" }
    },
    [28] = {
        Name = "AK-47",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_ak47" }
    },
    [29] = {
        Name = "AK-74",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_ak74" }
    },
    [30] = {
        Name = "M4A1",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_m4a1" }
    },
    [31] = {
        Name = "AMD-65",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_amd65" }
    },
    [32] = {
        Name = "G36",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_g36" }
    },
    [33] = {
        Name = "L85A2",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_l85" }
    },
    [34] = {
        Name = "Kriss Vector",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_vector" }
    },
    [35] = {
        Name = "FN P90",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_smgp90" }
    },
    [36] = {
        Name = "Honey Badger",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_honeybadger" }
    },
    [37] = {
        Name = "Mossberg 590",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_mossberg590" }
    },
    [38] = {
        Name = "Remington 870",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_remington870" }
    },
    [39] = {
        Name = "SPAS-12",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_spas12" }
    },
    [40] = {
        Name = "SVT-40",
        Type = "PermWeapon",
        Rarity = "Rare",
        ReqInfo = { "m9k_svt40" }
    },
    [41] = {
        Name = "Remington ACR",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_acr" }
    },
    [42] = {
        Name = "HK416",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_m416" }
    },
    [43] = {
        Name = "FN FAL",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_fal" }
    },
    [44] = {
        Name = "SCAR-H",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_scar" }
    },
    [45] = {
        Name = "SCAR-L",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_scarl" }
    },
    [46] = {
        Name = "TAR-21",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_tar21" }
    },
    [47] = {
        Name = "SIG SG552",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_sig_sg552" }
    },
    [48] = {
        Name = "AN-94",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_an94" }
    },
    [49] = {
        Name = "SR-3M Vikhr",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_vikhr" }
    },
    [50] = {
        Name = "M24",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_m24" }
    },
    [51] = {
        Name = "PSG-1",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_psg1" }
    },
    [52] = {
        Name = "Remington 7615P",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_remington7615p" }
    },
    [53] = {
        Name = "Benelli M3",
        Type = "PermWeapon",
        Rarity = "Epic",
        ReqInfo = { "m9k_m3" }
    },
    [54] = {
        Name = "G3A3",
        Type = "PermWeapon",
        Rarity = "Legendary",
        ReqInfo = { "m9k_g3a3" }
    },
    [55] = {
        Name = "M16A4 ACOG",
        Type = "PermWeapon",
        Rarity = "Legendary",
        ReqInfo = { "m9k_m16a4_acog" }
    },
    [56] = {
        Name = "M14 SP",
        Type = "PermWeapon",
        Rarity = "Legendary",
        ReqInfo = { "m9k_m14sp" }
    },
    [57] = {
        Name = "S&W Model 29 Satan",
        Type = "PermWeapon",
        Rarity = "Legendary",
        ReqInfo = { "m9k_m29satan" }
    },
    [58] = {
        Name = "S&W Model 500",
        Type = "PermWeapon",
        Rarity = "Legendary",
        ReqInfo = { "m9k_model500" }
    },
    [59] = {
        Name = "Scoped Taurus",
        Type = "PermWeapon",
        Rarity = "Legendary",
        ReqInfo = { "m9k_scoped_taurus" }
    },
    [60] = {
        Name = "Taurus Raging Bull",
        Type = "PermWeapon",
        Rarity = "Legendary",
        ReqInfo = { "m9k_ragingbull" }
    },
    [61] = {
        Name = "HK SL8",
        Type = "PermWeapon",
        Rarity = "Legendary",
        ReqInfo = { "m9k_sl8" }
    },
    [62] = {
        Name = "SVD Dragunov",
        Type = "PermWeapon",
        Rarity = "Legendary",
        ReqInfo = { "m9k_dragunov" }
    },
    [63] = {
        Name = "Contender G2",
        Type = "PermWeapon",
        Rarity = "Legendary",
        ReqInfo = { "m9k_contender" }
    },
    [64] = {
        Name = "DAO-12",
        Type = "PermWeapon",
        Rarity = "Glitched",
        ReqInfo = { "m9k_dao12" }
    },
    [65] = {
        Name = "Pancor Jackhammer",
        Type = "PermWeapon",
        Rarity = "Glitched",
        ReqInfo = { "m9k_jackhammer" }
    },
    [66] = {
        Name = "Striker-12",
        Type = "PermWeapon",
        Rarity = "Glitched",
        ReqInfo = { "m9k_striker12" }
    },
    [67] = {
        Name = "USAS-12",
        Type = "PermWeapon",
        Rarity = "Glitched",
        ReqInfo = { "m9k_usas" }
    },
    [68] = {
        Name = "Intervention",
        Type = "PermWeapon",
        Rarity = "Glitched",
        ReqInfo = { "m9k_intervention" }
    },
    [69] = {
        Name = "M98B",
        Type = "PermWeapon",
        Rarity = "Glitched",
        ReqInfo = { "m9k_m98b" }
    },
    [70] = {
        Name = "AW50",
        Type = "PermWeapon",
        Rarity = "Glitched",
        ReqInfo = { "m9k_aw50" }
    },
    [71] = {
        Name = "M249 SAW",
        Type = "PermWeapon",
        Rarity = "Glitched",
        ReqInfo = { "m9k_m249lmg" }
    },
    [72] = {
        Name = "PKM",
        Type = "PermWeapon",
        Rarity = "Glitched",
        ReqInfo = { "m9k_pkm" }
    },
    [73] = {
        Name = "Barrett M82",
        Type = "PermWeapon",
        Rarity = "Mythical",
        ReqInfo = { "m9k_barrettm82" }
    },
    [74] = {
        Name = "M60",
        Type = "PermWeapon",
        Rarity = "Mythical",
        ReqInfo = { "m9k_m60" }
    },
    [75] = {
        Name = "Ares Shrike",
        Type = "PermWeapon",
        Rarity = "Mythical",
        ReqInfo = { "m9k_ares_shrike" }
    },
    [76] = {
        Name = "Minigun",
        Type = "PermWeapon",
        Rarity = "Mythical",
        ReqInfo = { "m9k_minigun" }
    },
    [77] = {
        Name = "Milkor MGL",
        Type = "PermWeapon",
        Rarity = "Mythical",
        ReqInfo = { "m9k_milkormgl" }
    },
    [78] = {
        Name = "M202 Flash",
        Type = "PermWeapon",
        Rarity = "Mythical",
        ReqInfo = { "m9k_m202" }
    }
}

-- ============================================================
-- 7 CASES - Common through Mythical
-- ============================================================
BRICKS_SERVER.BASECONFIG.UNBOXING.Cases = {
    [1] = {
        Name = "Standard Case", Model = 1, Rarity = "Common",
        Color = Color( 154, 154, 154 ),
        Keys = { [1] = true },
        Items = {
            ["ITEM_1"] = { 8 }, ["ITEM_2"] = { 8 }, ["ITEM_3"] = { 8 }, ["ITEM_4"] = { 8 },
            ["ITEM_5"] = { 8 }, ["ITEM_6"] = { 8 }, ["ITEM_7"] = { 8 }, ["ITEM_8"] = { 8 },
            ["ITEM_9"] = { 8 }, ["ITEM_10"] = { 8 }, ["ITEM_11"] = { 8 }, ["ITEM_12"] = { 8 },
            ["ITEM_13"] = { 8 }, ["ITEM_14"] = { 8 },
            ["ITEM_15"] = { 2 }, ["ITEM_16"] = { 2 }, ["ITEM_17"] = { 2 }, ["ITEM_18"] = { 2 }
        }
    },
    [2] = {
        Name = "Surplus Case", Model = 1, Rarity = "Uncommon",
        Color = Color( 104, 255, 104 ),
        Keys = { [2] = true },
        Items = {
            ["ITEM_10"] = { 4 }, ["ITEM_11"] = { 4 }, ["ITEM_12"] = { 4 }, ["ITEM_13"] = { 4 }, ["ITEM_14"] = { 4 },
            ["ITEM_15"] = { 7 }, ["ITEM_16"] = { 7 }, ["ITEM_17"] = { 7 }, ["ITEM_18"] = { 7 },
            ["ITEM_19"] = { 7 }, ["ITEM_20"] = { 7 }, ["ITEM_21"] = { 7 }, ["ITEM_22"] = { 7 },
            ["ITEM_23"] = { 7 }, ["ITEM_24"] = { 7 }, ["ITEM_25"] = { 7 }, ["ITEM_26"] = { 7 }, ["ITEM_27"] = { 7 },
            ["ITEM_28"] = { 2 }, ["ITEM_29"] = { 2 }, ["ITEM_30"] = { 2 }
        }
    },
    [3] = {
        Name = "Tactical Case", Model = 1, Rarity = "Rare",
        Color = Color( 42, 133, 219 ),
        Keys = { [3] = true },
        Items = {
            ["ITEM_24"] = { 3 }, ["ITEM_25"] = { 3 }, ["ITEM_26"] = { 3 }, ["ITEM_27"] = { 3 },
            ["ITEM_28"] = { 8 }, ["ITEM_29"] = { 8 }, ["ITEM_30"] = { 8 }, ["ITEM_31"] = { 8 },
            ["ITEM_32"] = { 8 }, ["ITEM_33"] = { 8 }, ["ITEM_34"] = { 8 }, ["ITEM_35"] = { 8 },
            ["ITEM_36"] = { 8 }, ["ITEM_37"] = { 8 }, ["ITEM_38"] = { 8 }, ["ITEM_39"] = { 8 }, ["ITEM_40"] = { 8 },
            ["ITEM_41"] = { 2 }, ["ITEM_42"] = { 2 }, ["ITEM_43"] = { 2 }
        }
    },
    [4] = {
        Name = "Elite Case", Model = 1, Rarity = "Epic",
        Color = Color( 152, 68, 255 ),
        Keys = { [4] = true },
        Items = {
            ["ITEM_37"] = { 2 }, ["ITEM_38"] = { 2 }, ["ITEM_39"] = { 2 }, ["ITEM_40"] = { 2 },
            ["ITEM_41"] = { 7 }, ["ITEM_42"] = { 7 }, ["ITEM_43"] = { 7 }, ["ITEM_44"] = { 7 },
            ["ITEM_45"] = { 7 }, ["ITEM_46"] = { 7 }, ["ITEM_47"] = { 7 }, ["ITEM_48"] = { 7 },
            ["ITEM_49"] = { 7 }, ["ITEM_50"] = { 7 }, ["ITEM_51"] = { 7 }, ["ITEM_52"] = { 7 }, ["ITEM_53"] = { 7 },
            ["ITEM_54"] = { 2 }, ["ITEM_55"] = { 2 }, ["ITEM_56"] = { 2 }
        }
    },
    [5] = {
        Name = "Legendary Case", Model = 1, Rarity = "Legendary",
        Color = Color( 253, 191, 45 ),
        Keys = { [5] = true },
        Items = {
            ["ITEM_50"] = { 2 }, ["ITEM_51"] = { 2 }, ["ITEM_52"] = { 2 }, ["ITEM_53"] = { 2 },
            ["ITEM_54"] = { 7 }, ["ITEM_55"] = { 7 }, ["ITEM_56"] = { 7 }, ["ITEM_57"] = { 7 },
            ["ITEM_58"] = { 7 }, ["ITEM_59"] = { 7 }, ["ITEM_60"] = { 7 }, ["ITEM_61"] = { 7 },
            ["ITEM_62"] = { 7 }, ["ITEM_63"] = { 7 },
            ["ITEM_64"] = { 2 }, ["ITEM_65"] = { 2 }
        }
    },
    [6] = {
        Name = "Glitched Case", Model = 1, Rarity = "Glitched",
        Color = Color( 255, 50, 50 ),
        Keys = { [6] = true },
        Items = {
            ["ITEM_61"] = { 2 }, ["ITEM_62"] = { 2 }, ["ITEM_63"] = { 2 },
            ["ITEM_64"] = { 8 }, ["ITEM_65"] = { 8 }, ["ITEM_66"] = { 8 }, ["ITEM_67"] = { 8 },
            ["ITEM_68"] = { 8 }, ["ITEM_69"] = { 8 }, ["ITEM_70"] = { 8 }, ["ITEM_71"] = { 8 }, ["ITEM_72"] = { 8 },
            ["ITEM_73"] = { 1 }, ["ITEM_74"] = { 1 }
        }
    },
    [7] = {
        Name = "Mythical Case", Model = 1, Rarity = "Mythical",
        Color = Color( 255, 0, 200 ),
        Keys = { [7] = true },
        Items = {
            ["ITEM_69"] = { 3 }, ["ITEM_70"] = { 3 }, ["ITEM_71"] = { 3 }, ["ITEM_72"] = { 3 },
            ["ITEM_73"] = { 8 }, ["ITEM_74"] = { 8 }, ["ITEM_75"] = { 8 },
            ["ITEM_76"] = { 8 }, ["ITEM_77"] = { 8 }, ["ITEM_78"] = { 8 }
        }
    }
}

-- ============================================================
-- 7 KEYS
-- ============================================================
BRICKS_SERVER.BASECONFIG.UNBOXING.Keys = {
    [1] = { Name = "Standard Key",  Model = 1, Rarity = "Common",    Color = Color( 200, 200, 200 ) },
    [2] = { Name = "Surplus Key",   Model = 1, Rarity = "Uncommon",  Color = Color( 130, 255, 130 ) },
    [3] = { Name = "Tactical Key",  Model = 1, Rarity = "Rare",      Color = Color( 80, 180, 255 ) },
    [4] = { Name = "Elite Key",     Model = 1, Rarity = "Epic",      Color = Color( 180, 100, 255 ) },
    [5] = { Name = "Legendary Key", Model = 1, Rarity = "Legendary", Color = Color( 255, 210, 80 ) },
    [6] = { Name = "Glitched Key",  Model = 1, Rarity = "Glitched",  Color = Color( 255, 80, 80 ) },
    [7] = { Name = "Mythical Key",  Model = 1, Rarity = "Mythical",  Color = Color( 255, 50, 220 ) }
}

-- ============================================================
-- STORE
-- ============================================================
BRICKS_SERVER.BASECONFIG.UNBOXING.Store = {
    Featured = { 1, 8, 15 },
    Categories = {
        [1] = { Name = "Weapons", SortOrder = 1 },
        [2] = { Name = "Cases", SortOrder = 2 },
        [3] = { Name = "Keys", SortOrder = 3 }
    },
    Items = {
        [1]  = { GlobalKey = "CASE_1", Category = 2, SortOrder = 7, Price = 1000 },
        [2]  = { GlobalKey = "CASE_2", Category = 2, SortOrder = 6, Price = 2500 },
        [3]  = { GlobalKey = "CASE_3", Category = 2, SortOrder = 5, Price = 5000 },
        [4]  = { GlobalKey = "CASE_4", Category = 2, SortOrder = 4, Price = 10000, Group = "VIP" },
        [5]  = { GlobalKey = "CASE_5", Category = 2, SortOrder = 3, Price = 25000, Group = "VIP" },
        [6]  = { GlobalKey = "CASE_6", Category = 2, SortOrder = 2, Price = 50000, Group = "VIP++" },
        [7]  = { GlobalKey = "CASE_7", Category = 2, SortOrder = 1, Price = 100000, Group = "VIP++" },
        [8]  = { GlobalKey = "KEY_1",  Category = 3, SortOrder = 7, Price = 1000 },
        [9]  = { GlobalKey = "KEY_2",  Category = 3, SortOrder = 6, Price = 2500 },
        [10] = { GlobalKey = "KEY_3",  Category = 3, SortOrder = 5, Price = 5000 },
        [11] = { GlobalKey = "KEY_4",  Category = 3, SortOrder = 4, Price = 10000, Group = "VIP" },
        [12] = { GlobalKey = "KEY_5",  Category = 3, SortOrder = 3, Price = 25000, Group = "VIP" },
        [13] = { GlobalKey = "KEY_6",  Category = 3, SortOrder = 2, Price = 50000, Group = "VIP++" },
        [14] = { GlobalKey = "KEY_7",  Category = 3, SortOrder = 1, Price = 100000, Group = "VIP++" }
    }
}

BRICKS_SERVER.BASECONFIG.UNBOXING.Marketplace = {}
BRICKS_SERVER.BASECONFIG.UNBOXING.Marketplace.Slots = {
    [1] = {},
    [2] = { Price = 1000 },
    [3] = { Group = "VIP" },
    [4] = { Price = 25000, Group = "VIP++" }
}

BRICKS_SERVER.BASECONFIG.UNBOXING.Rewards = {
    [1] = { ["CASE_1"] = 1, ["KEY_1"] = 1 },
    [2] = { ["CASE_1"] = 2, ["KEY_1"] = 2 },
    [3] = { ["CASE_2"] = 1, ["KEY_2"] = 1 },
    [4] = { ["CASE_3"] = 1, ["KEY_3"] = 1 },
    [5] = { ["CASE_3"] = 2, ["KEY_3"] = 2 },
    [6] = { ["CASE_4"] = 1, ["KEY_4"] = 1 },
    [7] = { ["CASE_5"] = 1, ["KEY_5"] = 1 }
}

BRICKS_SERVER.BASECONFIG.UNBOXING.NotificationRarities = {
    ["Rare"] = true,
    ["Epic"] = true,
    ["Legendary"] = true,
    ["Glitched"] = true,
    ["Mythical"] = true
}

BRICKS_SERVER.BASECONFIG.UNBOXING.Drops = {}
BRICKS_SERVER.BASECONFIG.UNBOXING.Drops.TimeInterval = 900
BRICKS_SERVER.BASECONFIG.UNBOXING.Drops.Items = {
    { "CASE_1", 30 },
    { "KEY_1", 25 },
    { "CASE_2", 15 },
    { "KEY_2", 12 },
    { "CASE_3", 8 },
    { "KEY_3", 6 },
    { "CASE_4", 4 }
}

--[[ NPCS ]]--
BRICKS_SERVER.BASECONFIG.NPCS = BRICKS_SERVER.BASECONFIG.NPCS or {}
table.insert( BRICKS_SERVER.BASECONFIG.NPCS, {
    Name = "Unboxing",
    Type = "Unboxing"
} )

