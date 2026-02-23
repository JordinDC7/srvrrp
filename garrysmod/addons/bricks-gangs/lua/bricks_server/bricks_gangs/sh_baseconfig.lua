--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame or use the f4menu
    !!WARNING!!
]]--

--[[ MODULES CONFIG ]]--
BRICKS_SERVER.BASECONFIG.MODULES = BRICKS_SERVER.BASECONFIG.MODULES or {}
BRICKS_SERVER.BASECONFIG.MODULES["gangs"] = { true, {
    ["achievements"] = true,
    ["associations"] = true,
    ["leaderboards"] = true,
    ["printers"] = true,
    ["storage"] = true,
    ["territories"] = true
} }

--[[ GANGS CONFIG ]]--
BRICKS_SERVER.BASECONFIG.GANGS = {}
BRICKS_SERVER.BASECONFIG.GANGS["Max Level"] = 220
BRICKS_SERVER.BASECONFIG.GANGS["Original EXP Required"] = 140
BRICKS_SERVER.BASECONFIG.GANGS["EXP Required Increase"] = 1.18
BRICKS_SERVER.BASECONFIG.GANGS["Creation Fee"] = 12500
BRICKS_SERVER.BASECONFIG.GANGS["Minimum Deposit"] = 2500
BRICKS_SERVER.BASECONFIG.GANGS["Minimum Withdraw"] = 2500
BRICKS_SERVER.BASECONFIG.GANGS["Max Storage Item Stack"] = 15
BRICKS_SERVER.BASECONFIG.GANGS["Territory Capture Distance"] = 20000
BRICKS_SERVER.BASECONFIG.GANGS["Territory UnCapture Time"] = 5
BRICKS_SERVER.BASECONFIG.GANGS["Territory Capture Time"] = 7
BRICKS_SERVER.BASECONFIG.GANGS["Leaderboard Refresh Time"] = 180
BRICKS_SERVER.BASECONFIG.GANGS["Gang Display Limit"] = 12
BRICKS_SERVER.BASECONFIG.GANGS["Gang Friendly Fire"] = false
BRICKS_SERVER.BASECONFIG.GANGS["Disable Gang Chat"] = false
BRICKS_SERVER.BASECONFIG.GANGS["Gang Display Distance"] = 12000
BRICKS_SERVER.BASECONFIG.GANGS.Upgrades = {
    ["MaxMembers"] = {
        Name = "Recruitment Network",
        Description = "Scale your gang from a street crew into a server-wide empire.",
        Icon = "members_upgrade.png",
        Default = { 6 },
        Tiers = {
            [1] = { Price = 20000, Level = 4, ReqInfo = { 10 } },
            [2] = { Price = 50000, Level = 10, ReqInfo = { 14 } },
            [3] = { Price = 95000, Level = 18, ReqInfo = { 18 } },
            [4] = { Price = 165000, Level = 30, ReqInfo = { 24 } },
            [5] = { Price = 275000, Level = 44, ReqInfo = { 32 } },
            [6] = { Price = 425000, Level = 62, ReqInfo = { 40 } },
            [7] = { Price = 650000, Level = 84, ReqInfo = { 48 } },
            [8] = { Price = 950000, Level = 112, ReqInfo = { 56 } }
        }
    },
    ["MaxBalance"] = {
        Name = "Treasury Security",
        Description = "Raise secure balance caps so your gang can hoard and invest long-term.",
        Icon = "balance.png",
        Default = { 50000 },
        Tiers = {
            [1] = { Price = 20000, Level = 3, ReqInfo = { 125000 } },
            [2] = { Price = 55000, Level = 10, ReqInfo = { 300000 } },
            [3] = { Price = 110000, Level = 20, ReqInfo = { 650000 } },
            [4] = { Price = 225000, Level = 32, ReqInfo = { 1250000 } },
            [5] = { Price = 400000, Level = 46, ReqInfo = { 2500000 } },
            [6] = { Price = 700000, Level = 64, ReqInfo = { 4500000 } },
            [7] = { Price = 1200000, Level = 86, ReqInfo = { 8000000 } },
            [8] = { Price = 1850000, Level = 114, ReqInfo = { 13000000 } },
            [9] = { Price = 2600000, Level = 148, ReqInfo = { 20000000 } }
        }
    },
    ["StorageSlots"] = {
        Name = "Logistics Warehouse",
        Description = "Expand storage capacity for raid kits, stockpiles and war prep.",
        Icon = "storage_64.png",
        Default = { 14 },
        Tiers = {
            [1] = { Price = 15000, Level = 5, ReqInfo = { 24 } },
            [2] = { Price = 38000, Level = 12, ReqInfo = { 36 } },
            [3] = { Price = 70000, Level = 22, ReqInfo = { 52 } },
            [4] = { Price = 125000, Level = 34, ReqInfo = { 68 } },
            [5] = { Price = 210000, Level = 50, ReqInfo = { 84 } },
            [6] = { Price = 340000, Level = 70, ReqInfo = { 100 } },
            [7] = { Price = 525000, Level = 92, ReqInfo = { 118 } },
            [8] = { Price = 780000, Level = 122, ReqInfo = { 136 } }
        }
    },
    ["Health"] = {
        Name = "Combat Conditioning",
        Description = "Increase spawn HP to keep your frontline alive in long engagements.",
        Icon = "health_upgrade.png",
        Default = { 0 },
        Tiers = {
            [1] = { Price = 22000, Level = 10, ReqInfo = { 10 } },
            [2] = { Price = 50000, Level = 18, ReqInfo = { 20 } },
            [3] = { Price = 90000, Level = 28, ReqInfo = { 35 } },
            [4] = { Price = 160000, Level = 42, ReqInfo = { 50 } },
            [5] = { Price = 280000, Level = 60, ReqInfo = { 75 } },
            [6] = { Price = 450000, Level = 82, ReqInfo = { 100 } },
            [7] = { Price = 700000, Level = 106, ReqInfo = { 125 } },
            [8] = { Price = 1050000, Level = 136, ReqInfo = { 150 } }
        }
    },
    ["Armor"] = {
        Name = "Ballistics Program",
        Description = "Increase spawn armor so your gang can hold flags and defend printers.",
        Icon = "armor_upgrade.png",
        Default = { 0 },
        Tiers = {
            [1] = { Price = 22000, Level = 10, ReqInfo = { 10 } },
            [2] = { Price = 50000, Level = 18, ReqInfo = { 20 } },
            [3] = { Price = 85000, Level = 26, ReqInfo = { 35 } },
            [4] = { Price = 145000, Level = 38, ReqInfo = { 50 } },
            [5] = { Price = 260000, Level = 56, ReqInfo = { 75 } },
            [6] = { Price = 420000, Level = 78, ReqInfo = { 100 } },
            [7] = { Price = 660000, Level = 102, ReqInfo = { 125 } },
            [8] = { Price = 980000, Level = 132, ReqInfo = { 150 } }
        }
    },
    ["Salary"] = {
        Name = "Payroll Division",
        Description = "Reward active members with stronger passive income and retention.",
        Icon = "salary_upgrade.png",
        Default = { 0 },
        Tiers = {
            [1] = { Price = 30000, Level = 12, ReqInfo = { 75 } },
            [2] = { Price = 65000, Level = 20, ReqInfo = { 150 } },
            [3] = { Price = 120000, Level = 32, ReqInfo = { 250 } },
            [4] = { Price = 225000, Level = 46, ReqInfo = { 375 } },
            [5] = { Price = 400000, Level = 64, ReqInfo = { 550 } },
            [6] = { Price = 650000, Level = 90, ReqInfo = { 750 } },
            [7] = { Price = 980000, Level = 118, ReqInfo = { 975 } },
            [8] = { Price = 1400000, Level = 150, ReqInfo = { 1250 } }
        }
    },
    ["Weapon_1"] = {
        Name = "Armory: AK47",
        Description = "Permanent AK47 unlock for every gang member.",
        Icon = "https://i.imgur.com/iDezZ62.png",
        Price = 70000,
        Level = 18,
        Type = "Weapon",
        ReqInfo = { "weapon_ak472" }
    },
    ["Weapon_2"] = {
        Name = "Armory: Shotgun",
        Description = "Permanent shotgun unlock for close-quarter building clears.",
        Icon = "gang_upgrade.png",
        Price = 95000,
        Level = 24,
        Type = "Weapon",
        ReqInfo = { "weapon_shotgun" }
    },
    ["Weapon_3"] = {
        Name = "Armory: SMG",
        Description = "Permanent SMG unlock for mobile pushes and rotations.",
        Icon = "gang_upgrade.png",
        Price = 145000,
        Level = 34,
        Type = "Weapon",
        ReqInfo = { "weapon_smg1" }
    },
    ["Weapon_4"] = {
        Name = "Armory: Sniper",
        Description = "Permanent sniper unlock for map control and picks.",
        Icon = "https://i.imgur.com/mPSQunx.png",
        Price = 220000,
        Level = 48,
        Type = "Weapon",
        ReqInfo = { "ls_sniper" }
    },
    ["Weapon_5"] = {
        Name = "Armory: AR2",
        Description = "Permanent AR2 unlock for late-game domination.",
        Icon = "gang_upgrade.png",
        Price = 375000,
        Level = 68,
        Type = "Weapon",
        ReqInfo = { "weapon_ar2" }
    },
    ["Weapon_6"] = {
        Name = "Armory: Deagle",
        Description = "Permanent deagle unlock for precision sidearm duels.",
        Icon = "gang_upgrade.png",
        Price = 115000,
        Level = 28,
        Type = "Weapon",
        ReqInfo = { "weapon_deagle2" }
    },
    ["Weapon_7"] = {
        Name = "Armory: MP5",
        Description = "Permanent MP5 unlock for reliable mid-range pressure.",
        Icon = "gang_upgrade.png",
        Price = 180000,
        Level = 40,
        Type = "Weapon",
        ReqInfo = { "weapon_mp52" }
    },
    ["Weapon_8"] = {
        Name = "Armory: Famas",
        Description = "Permanent Famas unlock for disciplined burst control.",
        Icon = "gang_upgrade.png",
        Price = 265000,
        Level = 56,
        Type = "Weapon",
        ReqInfo = { "weapon_famas2" }
    },
    ["Weapon_9"] = {
        Name = "Armory: M4A1",
        Description = "Permanent M4A1 unlock for high-tier city warfare.",
        Icon = "gang_upgrade.png",
        Price = 420000,
        Level = 74,
        Type = "Weapon",
        ReqInfo = { "m9k_m4a1" }
    },
    ["Weapon_10"] = {
        Name = "Armory: AWP",
        Description = "Permanent AWP unlock for elite overwatch control.",
        Icon = "https://i.imgur.com/mPSQunx.png",
        Price = 680000,
        Level = 96,
        Type = "Weapon",
        ReqInfo = { "m9k_aw50" }
    }
}

BRICKS_SERVER.BASECONFIG.GANGS.Achievements = {
    [1] = { Name = "Crew Formed", Description = "Reach 6 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 6 }, Rewards = { ["GangBalance"] = { 7000 }, ["GangExperience"] = { 450 } } },
    [2] = { Name = "Trusted Lieutenants", Description = "Reach 10 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 10 }, Rewards = { ["GangBalance"] = { 14000 }, ["GangExperience"] = { 700 } } },
    [3] = { Name = "Full Platoon", Description = "Reach 16 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 16 }, Rewards = { ["GangBalance"] = { 24000 }, ["GangExperience"] = { 1200 } } },
    [4] = { Name = "City Syndicate", Description = "Reach 24 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 24 }, Rewards = { ["GangBalance"] = { 40000 }, ["GangExperience"] = { 2000 } } },
    [5] = { Name = "Regional Cartel", Description = "Reach 32 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 32 }, Rewards = { ["GangBalance"] = { 65000 }, ["GangExperience"] = { 3200 } } },
    [6] = { Name = "National Outfit", Description = "Reach 40 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 40 }, Rewards = { ["GangBalance"] = { 95000 }, ["GangExperience"] = { 4300 } } },
    [7] = { Name = "Global Syndicate", Description = "Reach 48 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 48 }, Rewards = { ["GangBalance"] = { 135000 }, ["GangExperience"] = { 6000 } } },
    [8] = { Name = "Shadow Battalion", Description = "Reach 56 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 56 }, Rewards = { ["GangBalance"] = { 190000 }, ["GangExperience"] = { 8000 } } },

    [9] = { Name = "Cashflow I", Description = "Reach a gang balance of $125,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 125000 }, Rewards = { ["GangBalance"] = { 10000 }, ["GangExperience"] = { 600 } } },
    [10] = { Name = "Cashflow II", Description = "Reach a gang balance of $350,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 350000 }, Rewards = { ["GangBalance"] = { 22000 }, ["GangExperience"] = { 1200 } } },
    [11] = { Name = "Cashflow III", Description = "Reach a gang balance of $750,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 750000 }, Rewards = { ["GangBalance"] = { 40000 }, ["GangExperience"] = { 1900 } } },
    [12] = { Name = "Cashflow IV", Description = "Reach a gang balance of $1,500,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 1500000 }, Rewards = { ["GangBalance"] = { 75000 }, ["GangExperience"] = { 3000 } } },
    [13] = { Name = "Cashflow V", Description = "Reach a gang balance of $3,000,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 3000000 }, Rewards = { ["GangBalance"] = { 130000 }, ["GangExperience"] = { 4600 } } },
    [14] = { Name = "Cashflow VI", Description = "Reach a gang balance of $7,500,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 7500000 }, Rewards = { ["GangBalance"] = { 240000 }, ["GangExperience"] = { 7200 } } },
    [15] = { Name = "Cashflow VII", Description = "Reach a gang balance of $15,000,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 15000000 }, Rewards = { ["GangBalance"] = { 450000 }, ["GangExperience"] = { 10500 } } },

    [16] = { Name = "Supply Locker", Description = "Store at least 20 items in gang storage.", Icon = "storage_64.png", Category = "Logistics", Type = "Storage", ReqInfo = { 20 }, Rewards = { ["GangBalance"] = { 8000 }, ["GangExperience"] = { 500 } } },
    [17] = { Name = "Supply Depot", Description = "Store at least 45 items in gang storage.", Icon = "storage_64.png", Category = "Logistics", Type = "Storage", ReqInfo = { 45 }, Rewards = { ["GangBalance"] = { 18000 }, ["GangExperience"] = { 1000 } } },
    [18] = { Name = "Supply Armory", Description = "Store at least 80 items in gang storage.", Icon = "storage_64.png", Category = "Logistics", Type = "Storage", ReqInfo = { 80 }, Rewards = { ["GangBalance"] = { 35000 }, ["GangExperience"] = { 1750 } } },
    [19] = { Name = "Supply Complex", Description = "Store at least 120 items in gang storage.", Icon = "storage_64.png", Category = "Logistics", Type = "Storage", ReqInfo = { 120 }, Rewards = { ["GangBalance"] = { 65000 }, ["GangExperience"] = { 3000 } } },
    [20] = { Name = "Supply Megahub", Description = "Store at least 170 items in gang storage.", Icon = "storage_64.png", Category = "Logistics", Type = "Storage", ReqInfo = { 170 }, Rewards = { ["GangBalance"] = { 100000 }, ["GangExperience"] = { 4700 } } },
    [21] = { Name = "Supply Citadel", Description = "Store at least 230 items in gang storage.", Icon = "storage_64.png", Category = "Logistics", Type = "Storage", ReqInfo = { 230 }, Rewards = { ["GangBalance"] = { 155000 }, ["GangExperience"] = { 6700 } } },

    [22] = { Name = "Street Presence", Description = "Reach gang level 10.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 10 }, Rewards = { ["GangBalance"] = { 9000 }, ["GangExperience"] = { 600 } } },
    [23] = { Name = "Regional Threat", Description = "Reach gang level 20.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 20 }, Rewards = { ["GangBalance"] = { 16000 }, ["GangExperience"] = { 1100 } } },
    [24] = { Name = "Underground Power", Description = "Reach gang level 35.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 35 }, Rewards = { ["GangBalance"] = { 30000 }, ["GangExperience"] = { 1800 } } },
    [25] = { Name = "District Controller", Description = "Reach gang level 55.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 55 }, Rewards = { ["GangBalance"] = { 55000 }, ["GangExperience"] = { 3000 } } },
    [26] = { Name = "Metropolis Menace", Description = "Reach gang level 80.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 80 }, Rewards = { ["GangBalance"] = { 95000 }, ["GangExperience"] = { 4700 } } },
    [27] = { Name = "Empire Ascendant", Description = "Reach gang level 110.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 110 }, Rewards = { ["GangBalance"] = { 150000 }, ["GangExperience"] = { 7000 } } },
    [28] = { Name = "Command Authority", Description = "Reach gang level 135.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 135 }, Rewards = { ["GangBalance"] = { 230000 }, ["GangExperience"] = { 9800 } } },
    [29] = { Name = "Strategic Overlord", Description = "Reach gang level 160.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 160 }, Rewards = { ["GangBalance"] = { 340000 }, ["GangExperience"] = { 12800 } } },
    [30] = { Name = "Criminal Hegemony", Description = "Reach gang level 190.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 190 }, Rewards = { ["GangBalance"] = { 500000 }, ["GangExperience"] = { 17000 } } },

    [31] = { Name = "War Chest I", Description = "Reach a gang balance of $5,000,000.", Icon = "balance.png", Category = "Endgame Economy", Type = "Balance", ReqInfo = { 5000000 }, Rewards = { ["GangBalance"] = { 175000 }, ["GangExperience"] = { 6200 } } },
    [32] = { Name = "War Chest II", Description = "Reach a gang balance of $10,000,000.", Icon = "balance.png", Category = "Endgame Economy", Type = "Balance", ReqInfo = { 10000000 }, Rewards = { ["GangBalance"] = { 300000 }, ["GangExperience"] = { 9000 } } },
    [33] = { Name = "War Chest III", Description = "Reach a gang balance of $20,000,000.", Icon = "balance.png", Category = "Endgame Economy", Type = "Balance", ReqInfo = { 20000000 }, Rewards = { ["GangBalance"] = { 500000 }, ["GangExperience"] = { 13500 } } },

    [34] = { Name = "Fortified Reserve", Description = "Store at least 300 items in gang storage.", Icon = "storage_64.png", Category = "Endgame Logistics", Type = "Storage", ReqInfo = { 300 }, Rewards = { ["GangBalance"] = { 220000 }, ["GangExperience"] = { 9000 } } },
    [35] = { Name = "Siege Logistics", Description = "Store at least 380 items in gang storage.", Icon = "storage_64.png", Category = "Endgame Logistics", Type = "Storage", ReqInfo = { 380 }, Rewards = { ["GangBalance"] = { 325000 }, ["GangExperience"] = { 12500 } } },

    [36] = { Name = "Legion Command", Description = "Reach 56 gang members and run a full roster.", Icon = "members_upgrade.png", Category = "Endgame Roster", Type = "Members", ReqInfo = { 56 }, Rewards = { ["GangBalance"] = { 280000 }, ["GangExperience"] = { 12000 } } }
}

BRICKS_SERVER.BASECONFIG.GANGS.Leaderboards = {
    [1] = {
        Name = "Most Experience",
        Type = "Experience",
        Color = Color( 22, 160, 133 )
    },
    [2] = {
        Name = "Most Members",
        Type = "Members",
        Color = Color( 41, 128, 185 )
    },
    [3] = {
        Name = "Highest Balance",
        Type = "Balance",
        Color = Color( 39, 174, 96 )
    },
    [4] = {
        Name = "Most Items",
        Type = "StorageItems",
        Color = Color( 231, 76, 60 )
    }
}

BRICKS_SERVER.BASECONFIG.GANGS.Territories = {
    [1] = {
        Name = "Fountain",
        Color = Color( 52, 152, 219 ),
        RewardTime = 60,
        Rewards = { ["GangBalance"] = { 350 }, ["GangExperience"] = { 30 } }
    },
    [2] = {
        Name = "Park",
        Color = Color( 231, 76, 60 ),
        RewardTime = 90,
        Rewards = { ["GangBalance"] = { 500 }, ["GangExperience"] = { 45 } }
    },
    [3] = {
        Name = "Industrial",
        Color = Color( 241, 196, 15 ),
        RewardTime = 120,
        Rewards = { ["GangBalance"] = { 750 }, ["GangExperience"] = { 65 } }
    },
    [4] = {
        Name = "Downtown",
        Color = Color( 155, 89, 182 ),
        RewardTime = 180,
        Rewards = { ["GangBalance"] = { 1100 }, ["GangExperience"] = { 95 } }
    }
}

--[[ GANG PRINTER CONFIG ]]--
BRICKS_SERVER.BASECONFIG.GANGPRINTERS = {}
BRICKS_SERVER.BASECONFIG.GANGPRINTERS["Income Update Time"] = 10
BRICKS_SERVER.BASECONFIG.GANGPRINTERS["Base Printer Health"] = 150
BRICKS_SERVER.BASECONFIG.GANGPRINTERS.Printers = {
    [1] = {
        Name = "Starter Brick Printer",
        Price = 12000,
        ServerPrices = { 1800, 2600, 3800, 5200, 7000, 9000 },
        ServerAmount = 120,
        ServerHeat = 7,
        MaxHeat = 70,
        BaseHeat = 20,
        ServerTime = 2
    },
    [2] = {
        Name = "Industrial Brick Printer",
        Price = 35000,
        ServerPrices = { 2600, 3600, 5200, 7000, 9200, 11800 },
        ServerAmount = 150,
        ServerHeat = 8,
        MaxHeat = 75,
        BaseHeat = 22,
        ServerTime = 2.7
    },
    [3] = {
        Name = "Empire Brick Printer",
        Price = 90000,
        ServerPrices = { 3800, 5200, 7200, 9800, 12800, 16500 },
        ServerAmount = 185,
        ServerHeat = 9,
        MaxHeat = 80,
        BaseHeat = 24,
        ServerTime = 3.4
    }
}
BRICKS_SERVER.BASECONFIG.GANGPRINTERS.Upgrades = {
    ["Health"] = {
        Name = "PRINTER HEALTH",
        Tiers = {
            [1] = { Price = 2500, ReqInfo = { 10 } },
            [2] = { Price = 5000, ReqInfo = { 22 } },
            [3] = { Price = 8500, ReqInfo = { 35 } },
            [4] = { Price = 13000, ReqInfo = { 50 } },
            [5] = { Price = 19000, ReqInfo = { 70 } },
            [6] = { Price = 28000, ReqInfo = { 95 } },
            [7] = { Price = 40000, ReqInfo = { 125 } }
        }
    },
    ["RGB"] = {
        Name = "RGB LEDS",
        Price = 10000
    }
}
BRICKS_SERVER.BASECONFIG.GANGPRINTERS.ServerUpgrades = {
    ["Cooling"] = {
        Name = "Cooling",
        Tiers = {
            [1] = { Price = 2500, ReqInfo = { 12 } },
            [2] = { Price = 5000, Level = 8, ReqInfo = { 22 } },
            [3] = { Price = 9000, Level = 16, ReqInfo = { 35 } },
            [4] = { Price = 15000, Level = 28, ReqInfo = { 50 } },
            [5] = { Price = 24000, Level = 42, ReqInfo = { 70 } }
        }
    },
    ["Speed"] = {
        Name = "Speed",
        Tiers = {
            [1] = { Price = 2500, ReqInfo = { 10 } },
            [2] = { Price = 5000, Level = 8, ReqInfo = { 20 } },
            [3] = { Price = 9000, Level = 14, ReqInfo = { 30 } },
            [4] = { Price = 14000, Level = 24, ReqInfo = { 42 } },
            [5] = { Price = 22000, Level = 36, ReqInfo = { 58 } },
            [6] = { Price = 32000, Level = 50, ReqInfo = { 75 } },
            [7] = { Price = 46000, Level = 68, ReqInfo = { 95 } }
        }
    },
    ["Amount"] = {
        Name = "Amount",
        Tiers = {
            [1] = { Price = 2500, ReqInfo = { 10 } },
            [2] = { Price = 5500, Level = 8, ReqInfo = { 20 } },
            [3] = { Price = 10000, Level = 16, ReqInfo = { 32 } },
            [4] = { Price = 17000, Level = 28, ReqInfo = { 46 } },
            [5] = { Price = 26000, Level = 42, ReqInfo = { 62 } },
            [6] = { Price = 38000, Level = 60, ReqInfo = { 82 } }
        }
    }
}

--[[ NPCS ]]--
BRICKS_SERVER.BASECONFIG.NPCS = BRICKS_SERVER.BASECONFIG.NPCS or {}
table.insert( BRICKS_SERVER.BASECONFIG.NPCS, {
    Name = "Gang",
    Type = "Gang"
} )
