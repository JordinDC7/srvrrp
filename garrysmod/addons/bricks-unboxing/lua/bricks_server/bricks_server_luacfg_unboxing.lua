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
    ProfileStats = {
        "kills",
        "headshots",
        "longest_streak",
        "assists",
        "objective_score"
    },
    PrestigeMilestones = { 10, 25, 50, 100, 250, 500, 1000 },
    PrestigeCooldownSeconds = 90,
    AssistWindowSeconds = 10,
    AntiFraud = {
        Enabled = true,
        MinKillInterval = 0.2,
        MaxDuplicateVictimsWindow = 90,
        MaxDuplicateVictimsPerWindow = 4,
        MaxKillDistance = 5000,
        FlagThreshold = 3
    },
    SeasonalLadders = {
        Enabled = true,
        LadderPoints = {
            Kill = 10,
            Headshot = 5,
            Assist = 4,
            ObjectiveScore = 1
        },
        CosmeticRewards = {
            { Points = 250, CosmeticID = "season_charm_bronze" },
            { Points = 750, CosmeticID = "season_charm_silver" },
            { Points = 1500, CosmeticID = "season_charm_gold" }
        }
    },
    Crafting = {
        RerollCostFragments = 35,
        AllowTargetedReroll = true
    },
    SocketedModifiers = {
        Enabled = true,
        MaxSockets = 2,
        EarnEveryKills = 40,
        BonusRange = {
            Min = 0.005,
            Max = 0.025
        },
        Modifiers = {
            "DamageScale",
            "AccuracySpreadScale",
            "ControlMoveSpreadScale",
            "HandlingFireDelayScale",
            "MobilitySpreadScale"
        }
    },
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
        ["Glitched"] = { Min = 44, Max = 82, BiasCurve = 1.16, HardCap = 89, JackpotChance = 0.0040, Flavor = "Unstable" },
        ["Mythical"] = { Min = 48, Max = 83, BiasCurve = 1.20, HardCap = 88, JackpotChance = 0.0025, Flavor = "Anomalous" }
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
    },
    -- Weapon condition tiers with family-specific float bands to keep collector depth without flooding perfect states.
    ConditionTiers = {
        { Name = "Factory New", Tag = "FN", MaxWear = 0.07 },
        { Name = "Minimal Wear", Tag = "MW", MaxWear = 0.15 },
        { Name = "Field-Tested", Tag = "FT", MaxWear = 0.38 },
        { Name = "Well-Worn", Tag = "WW", MaxWear = 0.45 },
        { Name = "Battle-Scarred", Tag = "BS", MaxWear = 1.00 }
    },
    ConditionBandsByCaseFamily = {
        ["common"] = { MinWear = 0.24, MaxWear = 0.95 },
        ["uncommon"] = { MinWear = 0.18, MaxWear = 0.82 },
        ["rare"] = { MinWear = 0.10, MaxWear = 0.62 },
        ["epic"] = { MinWear = 0.06, MaxWear = 0.45 },
        ["legendary"] = { MinWear = 0.03, MaxWear = 0.30 },
        ["glitched"] = { MinWear = 0.00, MaxWear = 0.22 },
        ["mythical"] = { MinWear = 0.00, MaxWear = 0.18 },
        ["default"] = { MinWear = 0.08, MaxWear = 0.80 }
    },
    Progression = {
        Enabled = true,
        XP = {
            ShotXP = 1,
            HitXP = 4,
            KillXP = 18
        },
        Milestones = {
            { XP = 250, Unlock = "sticker_slot_1", Label = "Sticker Slot I" },
            { XP = 700, Unlock = "sticker_slot_2", Label = "Sticker Slot II" },
            { XP = 1400, Unlock = "charm_slot", Label = "Charm Socket" },
            { XP = 2600, Unlock = "kill_banner", Label = "Kill Banner" }
        }
    }
}

-- Top-tier roadmap systems (pity, crafting, seasonal/liveops control surface).
BRICKS_SERVER.UNBOXING.LUACFG.TopTier = {
    MasteryXPPerOpen = 10,
    DuplicateProtection = {
        Enabled = true,
        WindowSeconds = 180,
        MaxRerolls = 3
    },
    SmartBundles = {
        Enabled = true,
        Rewards = {
            mission_starter = {
                Name = "Mission Starter Bundle",
                Items = {
                    ["CASE_1"] = 1,
                    ["KEY_1"] = 1
                },
                MasteryXP = 75
            }
        }
    },
    CollectionBooks = {
        ["urban_arsenal"] = {
            Name = "Urban Arsenal",
            Flair = "urban_arsenal_flair",
            Badge = "Urban Curator",
            RequiredItems = {
                ["ITEM_1"] = true,
                ["ITEM_2"] = true,
                ["ITEM_3"] = true
            }
        }
    },
    RetentionMissions = {
        Enabled = true,
        WeeklyResetWeek = os.date( "%Y-%W" ),
        Missions = {
            {
                ID = "open_cases_weekly",
                Name = "Open 10 cases",
                Type = "open_cases",
                Goal = 10,
                BundleReward = "mission_starter"
            },
            {
                ID = "unboxed_kills",
                Name = "Get 20 kills with unboxed gear",
                Type = "unboxed_kills",
                Goal = 20,
                BundleReward = "mission_starter"
            }
        }
    },
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
        MinNudgeMultiplier = 0.92,
        SupplyBalancing = {
            Enabled = true,
            WindowSeconds = 900,
            SoftCapPerItem = 12,
            PenaltyExponent = 0.70,
            MaxPenalty = 0.35,
            CaseFamilyIsolation = true
        }
    },
    LiveOps = {
        KillSwitchEnabled = false,
        DisabledCaseFamilies = {},
        HotfixWeightLimits = {
            Min = 0.10,
            Max = 5.00
        },
        SeasonModelEnabled = true,
        LegacyVaultFamilies = {
            ["legacy"] = true,
            ["anniversary"] = true
        },
        Seasons = {
            ["chapter_blacksite"] = {
                Name = "Chapter 1: Blacksite Protocol",
                StartUnix = 1730419200,
                EndUnix = 1735689600,
                FeaturedFamilies = {
                    ["blacksite"] = true,
                    ["urban_ops"] = true,
                    ["industrial"] = true
                }
            },
            ["chapter_anomaly"] = {
                Name = "Chapter 2: Anomaly Uprising",
                StartUnix = 1735689601,
                EndUnix = 1741046400,
                FeaturedFamilies = {
                    ["anomaly"] = true,
                    ["reactor"] = true,
                    ["biohazard"] = true
                }
            }
        },
        ActiveSeason = {
            Name = "Chapter 1: Blacksite Protocol",
            StartUnix = 1730419200,
            EndUnix = 1735689600
        },
        Experiments = {
            PresentationVariantA = true,
            PaceVariantB = false
        },
        EventMutations = {
            DoubleStatTrakWeekend = {
                Enabled = false,
                Weekdays = {
                    [1] = true,
                    [7] = true
                }
            },
            ThemedDropTable = {
                Enabled = false,
                FamilyMultipliers = {
                    ["blacksite"] = 1.15,
                    ["anomaly"] = 1.2
                }
            },
            FactionCaseBonus = {
                Enabled = false,
                FactionMultipliers = {
                    ["combine"] = 1.08,
                    ["resistance"] = 1.08
                }
            }
        }
    }
}
