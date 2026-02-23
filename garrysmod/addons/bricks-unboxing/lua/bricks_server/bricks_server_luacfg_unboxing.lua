--[[ LUA CONFIG ]]--
BRICKS_SERVER.UNBOXING.LUACFG = {}
BRICKS_SERVER.UNBOXING.LUACFG.UseMySQL = true -- Whether or not MySQL should be used (enter your details in bricks-unboxing/lua/bricks_server/bricks_unboxing/sv_mysql.lua)

BRICKS_SERVER.UNBOXING.LUACFG.MenuCommands = {
    ["!unbox"] = true,
    ["/unbox"] = true,
    ["!bricksunboxing"] = true,
    ["/bricksunboxing"] = true
}

BRICKS_SERVER.UNBOXING.LUACFG.DefaultCurrency =  "darkrp_money" -- Options: darkrp_money, brcs_credits, mtokens, ps2_points, ps2_premium_points
BRICKS_SERVER.UNBOXING.LUACFG.TTT =  false -- Whether or not TTT is being used

-- Optional premium-credit redirect flow used when a store checkout fails for premium currency.
BRICKS_SERVER.UNBOXING.LUACFG.PremiumCreditRedirect = {
    Enabled = false,
    Currency = "ps2_premium_points",
    URL = ""
}

-- Elite Arsenal roll engine for unboxed weapons. Keeps top-end chase drops rare while still rewarding progression.
BRICKS_SERVER.UNBOXING.LUACFG.StatTrak = {
    Enabled = true,
    MaxSavedRolls = 400,
    EligibleItemTypes = {
        ["Weapon"] = true,
        ["PermWeapon"] = true
    },
    GodRollScore = 97,
    TierBreakpoints = {
        { Name = "Ascendant", MinScore = 97, Tag = "ASC", Color = Color( 255, 90, 90 ) },
        { Name = "Elite Class", MinScore = 90, Tag = "ELT", Color = Color( 100, 220, 255 ) },
        { Name = "Prime", MinScore = 82, Tag = "PRM", Color = Color( 120, 235, 130 ) },
        { Name = "Forged", MinScore = 72, Tag = "FRG", Color = Color( 208, 210, 212 ) },
        { Name = "Raw", MinScore = 0, Tag = "RAW", Color = Color( 164, 164, 164 ) }
    },
    Stats = {
        { Key = "DMG", Min = 1, Max = 100, Weight = 0.30 },
        { Key = "ACC", Min = 1, Max = 100, Weight = 0.23 },
        { Key = "CTRL", Min = 1, Max = 100, Weight = 0.19 },
        { Key = "HND", Min = 1, Max = 100, Weight = 0.16 },
        { Key = "MOV", Min = 1, Max = 100, Weight = 0.12 }
    },
    -- Rarity quality lanes (high-tier cases can still low roll, while jackpot procs create chase drops).
    RarityRollRanges = {
        ["Common"] = { Min = 20, Max = 64, BiasCurve = 1.10, HardCap = 72, JackpotChance = 0.0005, Flavor = "Field" },
        ["Uncommon"] = { Min = 26, Max = 72, BiasCurve = 1.03, HardCap = 80, JackpotChance = 0.0015, Flavor = "Standard" },
        ["Rare"] = { Min = 34, Max = 82, BiasCurve = 0.97, HardCap = 88, JackpotChance = 0.0030, Flavor = "Refined" },
        ["Epic"] = { Min = 40, Max = 87, BiasCurve = 0.92, HardCap = 91, JackpotChance = 0.0045, Flavor = "Combat" },
        ["Legendary"] = { Min = 48, Max = 90, BiasCurve = 0.88, HardCap = 93, JackpotChance = 0.0075, Flavor = "Prototype" },
        ["Glitched"] = { Min = 43, Max = 84, BiasCurve = 1.12, HardCap = 90, JackpotChance = 0.0125, Flavor = "Unstable" },
        ["Mythical"] = { Min = 46, Max = 86, BiasCurve = 1.08, HardCap = 92, JackpotChance = 0.0175, Flavor = "Anomalous" }
    },
    -- Higher-tier weapons get better minimum stats than all lower tiers.
    HighTierMinimums = {
        { MinStat = 70, Flavor = "Masterwork", Rarities = { ["Legendary"] = true } },
        { MinStat = 78, Flavor = "Prototype", Rarities = { ["Mythical"] = true, ["Glitched"] = true } }
    },
    JackpotBoost = { Min = 8, Max = 24 },
    -- Gameplay effect ranges (1-100 stat values are remapped between MinScale and MaxScale).
    StatEffects = {
        DamageScale = { MinScale = 0.86, MaxScale = 1.28 },
        AccuracySpreadScale = { MinScale = 1.26, MaxScale = 0.74 },
        ControlMoveSpreadScale = { MinScale = 1.30, MaxScale = 0.67 },
        HandlingFireDelayScale = { MinScale = 1.18, MaxScale = 0.84 },
        MobilitySpreadScale = { MinScale = 1.28, MaxScale = 0.76 }
    }
}

-- Top-tier roadmap systems (pity, crafting, seasonal/liveops control surface).
BRICKS_SERVER.UNBOXING.LUACFG.TopTier = {
    MasteryXPPerOpen = 10,
    ApexRarities = {
        ["Legendary"] = true,
        ["Glitched"] = true,
        ["Mythical"] = true
    },
    Pity = {
        SoftPityStart = 18,
        SoftPityBoostPerOpen = 0.04,
        HardPityCap = 40
    },
    DuplicateFragmentFallback = 1,
    DuplicateFragmentValues = {
        ["Common"] = 1,
        ["Uncommon"] = 2,
        ["Rare"] = 4,
        ["Epic"] = 7,
        ["Legendary"] = 12,
        ["Glitched"] = 18,
        ["Mythical"] = 25
    },
    CraftingRecipes = {
        ["legendary_weapon"] = {
            Name = "Legendary Weapon Cache",
            FragmentCost = 175,
            GlobalKey = "ITEM_5",
            Amount = 1
        },
        ["mythical_cash"] = {
            Name = "Mythical Currency Drop",
            FragmentCost = 250,
            GlobalKey = "ITEM_10",
            Amount = 1
        },
        ["glitched_weapon"] = {
            Name = "Glitched Weapon Cache",
            FragmentCost = 225,
            GlobalKey = "ITEM_8",
            Amount = 1
        }
    },
    TradeCooldownSeconds = 1800,
    DynamicDropNudges = {
        Enabled = true,
        MaxNudgeMultiplier = 1.08,
        MinNudgeMultiplier = 0.92
    },
    LiveOps = {
        KillSwitchEnabled = false,
        DisabledCaseFamilies = {},
        ActiveSeason = {
            Name = "Chapter 1: Blacksite Protocol",
            StartUnix = 1730419200,
            EndUnix = 1735689600
        },
        Experiments = {
            PresentationVariantA = true,
            PaceVariantB = false
        }
    }
}
