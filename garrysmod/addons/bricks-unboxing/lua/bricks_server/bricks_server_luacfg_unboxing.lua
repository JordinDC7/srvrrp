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

-- MUTINY-inspired stat tracking rolls applied to unboxed weapons.
BRICKS_SERVER.UNBOXING.LUACFG.StatTrak = {
    Enabled = true,
    EligibleItemTypes = {
        ["Weapon"] = true,
        ["PermWeapon"] = true
    },
    GodRollScore = 94,
    TierBreakpoints = {
        { Name = "God Roll", MinScore = 94, Tag = "GOD", Color = Color( 255, 215, 64 ) },
        { Name = "Mythic", MinScore = 88, Tag = "MYTH", Color = Color( 217, 110, 255 ) },
        { Name = "Elite", MinScore = 80, Tag = "ELITE", Color = Color( 77, 192, 255 ) },
        { Name = "Refined", MinScore = 70, Tag = "REF", Color = Color( 96, 212, 112 ) },
        { Name = "Standard", MinScore = 0, Tag = "STD", Color = Color( 164, 164, 164 ) }
    },
    Stats = {
        { Key = "DMG", Min = 1, Max = 100, Weight = 0.35 },
        { Key = "ACC", Min = 1, Max = 100, Weight = 0.25 },
        { Key = "CTRL", Min = 1, Max = 100, Weight = 0.2 },
        { Key = "HND", Min = 1, Max = 100, Weight = 0.2 }
    },
    -- Rarity controls the quality floor/ceiling for rolled stats.
    RarityRollRanges = {
        ["Common"] = { Min = 15, Max = 62 },
        ["Uncommon"] = { Min = 25, Max = 72 },
        ["Rare"] = { Min = 38, Max = 84 },
        ["Epic"] = { Min = 48, Max = 92 },
        ["Legendary"] = { Min = 58, Max = 97 },
        ["Glitched"] = { Min = 70, Max = 100 }
    },
    -- Gameplay effect ranges (1-100 stat values are remapped between MinScale and MaxScale).
    StatEffects = {
        DamageScale = { MinScale = 0.82, MaxScale = 1.32 },
        AccuracySpreadScale = { MinScale = 1.28, MaxScale = 0.72 },
        ControlMoveSpreadScale = { MinScale = 1.35, MaxScale = 0.65 },
        HandlingFireDelayScale = { MinScale = 1.22, MaxScale = 0.82 }
    }
}
