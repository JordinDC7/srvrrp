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
BRICKS_SERVER.BASECONFIG.GANGS["Max Level"] = 150
BRICKS_SERVER.BASECONFIG.GANGS["Original EXP Required"] = 125
BRICKS_SERVER.BASECONFIG.GANGS["EXP Required Increase"] = 1.17
BRICKS_SERVER.BASECONFIG.GANGS["Creation Fee"] = 5000
BRICKS_SERVER.BASECONFIG.GANGS["Minimum Deposit"] = 1000
BRICKS_SERVER.BASECONFIG.GANGS["Minimum Withdraw"] = 1000
BRICKS_SERVER.BASECONFIG.GANGS["Max Storage Item Stack"] = 10
BRICKS_SERVER.BASECONFIG.GANGS["Territory Capture Distance"] = 20000
BRICKS_SERVER.BASECONFIG.GANGS["Territory UnCapture Time"] = 3
BRICKS_SERVER.BASECONFIG.GANGS["Territory Capture Time"] = 3
BRICKS_SERVER.BASECONFIG.GANGS["Leaderboard Refresh Time"] = 300
BRICKS_SERVER.BASECONFIG.GANGS["Gang Display Limit"] = 10
BRICKS_SERVER.BASECONFIG.GANGS["Gang Friendly Fire"] = true
BRICKS_SERVER.BASECONFIG.GANGS["Disable Gang Chat"] = false
BRICKS_SERVER.BASECONFIG.GANGS["Gang Display Distance"] = 10000
BRICKS_SERVER.BASECONFIG.GANGS.Upgrades = {
    ["MaxMembers"] = {
        Name = "Recruitment Network",
        Description = "Raise your gang capacity so you can scale into a real organization.",
        Icon = "members_upgrade.png",
        Default = { 6 },
        Tiers = {
            [1] = { Price = 15000, Level = 3, ReqInfo = { 10 } },
            [2] = { Price = 35000, Level = 10, ReqInfo = { 14 } },
            [3] = { Price = 70000, Level = 20, ReqInfo = { 18 } },
            [4] = { Price = 125000, Level = 35, ReqInfo = { 24 } },
            [5] = { Price = 225000, Level = 50, ReqInfo = { 32 } }
        }
    },
    ["MaxBalance"] = {
        Name = "Treasury Security",
        Description = "Increase protected gang account capacity for long-term wealth.",
        Icon = "balance.png",
        Default = { 25000 },
        Tiers = {
            [1] = { Price = 10000, Level = 2, ReqInfo = { 75000 } },
            [2] = { Price = 35000, Level = 8, ReqInfo = { 150000 } },
            [3] = { Price = 75000, Level = 18, ReqInfo = { 350000 } },
            [4] = { Price = 150000, Level = 30, ReqInfo = { 750000 } },
            [5] = { Price = 300000, Level = 45, ReqInfo = { 1500000 } },
            [6] = { Price = 500000, Level = 65, ReqInfo = { 3000000 } }
        }
    },
    ["StorageSlots"] = {
        Name = "Logistics Warehouse",
        Description = "Expand storage infrastructure for raids, wars and market play.",
        Icon = "storage_64.png",
        Default = { 12 },
        Tiers = {
            [1] = { Price = 12000, Level = 4, ReqInfo = { 24 } },
            [2] = { Price = 28000, Level = 12, ReqInfo = { 36 } },
            [3] = { Price = 55000, Level = 22, ReqInfo = { 48 } },
            [4] = { Price = 100000, Level = 32, ReqInfo = { 64 } },
            [5] = { Price = 175000, Level = 48, ReqInfo = { 80 } }
        }
    },
    ["Health"] = {
        Name = "Combat Conditioning",
        Description = "Boost member spawn health for better frontline staying power.",
        Icon = "health_upgrade.png",
        Default = { 0 },
        Tiers = {
            [1] = { Price = 15000, Level = 8, ReqInfo = { 10 } },
            [2] = { Price = 35000, Level = 16, ReqInfo = { 20 } },
            [3] = { Price = 75000, Level = 26, ReqInfo = { 35 } },
            [4] = { Price = 125000, Level = 40, ReqInfo = { 50 } },
            [5] = { Price = 250000, Level = 58, ReqInfo = { 75 } }
        }
    },
    ["Armor"] = {
        Name = "Ballistics Program",
        Description = "Spawn with stronger armor during captures and defensive fights.",
        Icon = "armor_upgrade.png",
        Default = { 0 },
        Tiers = {
            [1] = { Price = 15000, Level = 8, ReqInfo = { 10 } },
            [2] = { Price = 35000, Level = 16, ReqInfo = { 20 } },
            [3] = { Price = 65000, Level = 24, ReqInfo = { 35 } },
            [4] = { Price = 110000, Level = 36, ReqInfo = { 50 } },
            [5] = { Price = 220000, Level = 55, ReqInfo = { 75 } }
        }
    },
    ["Salary"] = {
        Name = "Payroll Division",
        Description = "Increase paycheck value to keep members funded and active.",
        Icon = "salary_upgrade.png",
        Default = { 0 },
        Tiers = {
            [1] = { Price = 20000, Level = 10, ReqInfo = { 50 } },
            [2] = { Price = 45000, Level = 18, ReqInfo = { 100 } },
            [3] = { Price = 90000, Level = 30, ReqInfo = { 175 } },
            [4] = { Price = 175000, Level = 44, ReqInfo = { 275 } },
            [5] = { Price = 350000, Level = 62, ReqInfo = { 400 } }
        }
    },
    ["Weapon_1"] = {
        Name = "Armory: AK47",
        Description = "Permanent AK47 for every gang member.",
        Icon = "https://i.imgur.com/iDezZ62.png",
        Price = 45000,
        Level = 12,
        Type = "Weapon",
        ReqInfo = { "weapon_ak472" }
    },
    ["Weapon_2"] = {
        Name = "Armory: Sniper",
        Description = "Permanent sniper rifle for all members.",
        Icon = "https://i.imgur.com/mPSQunx.png",
        Price = 110000,
        Level = 30,
        Type = "Weapon",
        ReqInfo = { "ls_sniper" }
    },
    ["Weapon_3"] = {
        Name = "Armory: Shotgun",
        Description = "Permanent shotgun unlock for close-quarter pushes.",
        Icon = "gang_upgrade.png",
        Price = 65000,
        Level = 20,
        Type = "Weapon",
        ReqInfo = { "weapon_shotgun" }
    },
    ["Weapon_4"] = {
        Name = "Armory: SMG",
        Description = "Permanent SMG unlock for high mobility skirmishes.",
        Icon = "gang_upgrade.png",
        Price = 80000,
        Level = 24,
        Type = "Weapon",
        ReqInfo = { "weapon_smg1" }
    },
    ["Weapon_5"] = {
        Name = "Armory: AR2",
        Description = "Permanent AR2 unlock for elite late-game squads.",
        Icon = "gang_upgrade.png",
        Price = 180000,
        Level = 48,
        Type = "Weapon",
        ReqInfo = { "weapon_ar2" }
    }
}

BRICKS_SERVER.BASECONFIG.GANGS.Achievements = {
    [1] = { Name = "Crew Formed", Description = "Reach 6 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 6 }, Rewards = { ["GangBalance"] = { 4000 }, ["GangExperience"] = { 300 } } },
    [2] = { Name = "Trusted Lieutenants", Description = "Reach 10 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 10 }, Rewards = { ["GangBalance"] = { 8000 }, ["GangExperience"] = { 500 } } },
    [3] = { Name = "Full Platoon", Description = "Reach 16 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 16 }, Rewards = { ["GangBalance"] = { 14000 }, ["GangExperience"] = { 900 } } },
    [4] = { Name = "City Syndicate", Description = "Reach 24 gang members.", Icon = "members_upgrade.png", Category = "Roster", Type = "Members", ReqInfo = { 24 }, Rewards = { ["GangBalance"] = { 22000 }, ["GangExperience"] = { 1400 } } },

    [5] = { Name = "Cashflow I", Description = "Reach a gang balance of $75,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 75000 }, Rewards = { ["GangBalance"] = { 5000 }, ["GangExperience"] = { 400 } } },
    [6] = { Name = "Cashflow II", Description = "Reach a gang balance of $250,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 250000 }, Rewards = { ["GangBalance"] = { 12000 }, ["GangExperience"] = { 900 } } },
    [7] = { Name = "Cashflow III", Description = "Reach a gang balance of $750,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 750000 }, Rewards = { ["GangBalance"] = { 25000 }, ["GangExperience"] = { 1700 } } },
    [8] = { Name = "Cashflow IV", Description = "Reach a gang balance of $1,500,000.", Icon = "balance.png", Category = "Economy", Type = "Balance", ReqInfo = { 1500000 }, Rewards = { ["GangBalance"] = { 50000 }, ["GangExperience"] = { 2600 } } },

    [9] = { Name = "Supply Locker", Description = "Store at least 20 items in gang storage.", Icon = "storage_64.png", Category = "Logistics", Type = "Storage", ReqInfo = { 20 }, Rewards = { ["GangBalance"] = { 6000 }, ["GangExperience"] = { 450 } } },
    [10] = { Name = "Supply Depot", Description = "Store at least 45 items in gang storage.", Icon = "storage_64.png", Category = "Logistics", Type = "Storage", ReqInfo = { 45 }, Rewards = { ["GangBalance"] = { 14000 }, ["GangExperience"] = { 950 } } },
    [11] = { Name = "Supply Empire", Description = "Store at least 70 items in gang storage.", Icon = "storage_64.png", Category = "Logistics", Type = "Storage", ReqInfo = { 70 }, Rewards = { ["GangBalance"] = { 28000 }, ["GangExperience"] = { 1600 } } },

    [12] = { Name = "Street Presence", Description = "Reach gang level 10.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 10 }, Rewards = { ["GangBalance"] = { 5000 }, ["GangExperience"] = { 350 } } },
    [13] = { Name = "Regional Threat", Description = "Reach gang level 20.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 20 }, Rewards = { ["GangBalance"] = { 10000 }, ["GangExperience"] = { 700 } } },
    [14] = { Name = "Underground Power", Description = "Reach gang level 35.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 35 }, Rewards = { ["GangBalance"] = { 18000 }, ["GangExperience"] = { 1200 } } },
    [15] = { Name = "City Controller", Description = "Reach gang level 55.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 55 }, Rewards = { ["GangBalance"] = { 35000 }, ["GangExperience"] = { 2200 } } },
    [16] = { Name = "Legendary Cartel", Description = "Reach gang level 80.", Icon = "levelling.png", Category = "Progression", Type = "Level", ReqInfo = { 80 }, Rewards = { ["GangBalance"] = { 60000 }, ["GangExperience"] = { 3200 } } }
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
        Rewards = { ["GangBalance"] = { 250 }, ["GangExperience"] = { 25 } }
    },
    [2] = {
        Name = "Park",
        Color = Color( 231, 76, 60 ),
        RewardTime = 120,
        Rewards = { ["GangBalance"] = { 500 }, ["GangExperience"] = { 50 } }
    }
}

--[[ GANG PRINTER CONFIG ]]--
BRICKS_SERVER.BASECONFIG.GANGPRINTERS = {}
BRICKS_SERVER.BASECONFIG.GANGPRINTERS["Income Update Time"] = 10
BRICKS_SERVER.BASECONFIG.GANGPRINTERS["Base Printer Health"] = 100
BRICKS_SERVER.BASECONFIG.GANGPRINTERS.Printers = {
    [1] = {
        Name = "Printer 1",
        Price = 5000,
        ServerPrices = { 1000, 1500, 2500, 4000, 6500, 8000 },
        ServerAmount = 100,
        ServerHeat = 8,
        MaxHeat = 60,
        BaseHeat = 20,
        ServerTime = 2
    },
    [2] = {
        Name = "Printer 2",
        Price = 15000,
        ServerPrices = { 1500, 2500, 4000, 6500, 8000, 10000 },
        ServerAmount = 100,
        ServerHeat = 8,
        MaxHeat = 60,
        BaseHeat = 20,
        ServerTime = 3
    }
}
BRICKS_SERVER.BASECONFIG.GANGPRINTERS.Upgrades = {
    ["Health"] = {
        Name = "PRINTER HEALTH",
        Tiers = {
            [1] = {
                Price = 1000,
                ReqInfo = { 10 }
            },
            [2] = {
                Price = 2500,
                ReqInfo = { 25 }
            },
            [3] = {
                Price = 3500,
                ReqInfo = { 50 }
            },
            [4] = {
                Price = 4500,
                ReqInfo = { 75 }
            },
            [5] = {
                Price = 5000,
                ReqInfo = { 90 }
            },
            [6] = {
                Price = 7500,
                ReqInfo = { 100 }
            },
        }
    },
    ["RGB"] = {
        Name = "RGB LEDS",
        Price = 2500
    }
}
BRICKS_SERVER.BASECONFIG.GANGPRINTERS.ServerUpgrades = {
    ["Cooling"] = {
        Name = "Cooling",
        Tiers = {
            [1] = {
                Price = 1000,
                ReqInfo = { 10 }
            },
            [2] = {
                Price = 2500,
                Level = 5,
                ReqInfo = { 25 }
            }
        }
    },
    ["Speed"] = {
        Name = "Speed",
        Tiers = {
            [1] = {
                Price = 1000,
                ReqInfo = { 10 }
            },
            [2] = {
                Price = 2500,
                Level = 5,
                ReqInfo = { 25 }
            },
            [3] = {
                Price = 2500,
                Level = 5,
                ReqInfo = { 35 }
            },
            [4] = {
                Price = 5000,
                Level = 5,
                ReqInfo = { 40 }
            },
            [5] = {
                Price = 7500,
                Level = 5,
                ReqInfo = { 50 }
            },
            [6] = {
                Price = 10000,
                Level = 5,
                ReqInfo = { 75 }
            }
        }
    },
    ["Amount"] = {
        Name = "Amount",
        Tiers = {
            [1] = {
                Price = 1000,
                ReqInfo = { 10 }
            },
            [2] = {
                Price = 2500,
                Level = 5,
                ReqInfo = { 25 }
            },
            [3] = {
                Price = 5000,
                Level = 5,
                ReqInfo = { 50 }
            },
            [4] = {
                Price = 8500,
                Level = 5,
                ReqInfo = { 75 }
            }
        }
    }
}

--[[ NPCS ]]--
BRICKS_SERVER.BASECONFIG.NPCS = BRICKS_SERVER.BASECONFIG.NPCS or {}
table.insert( BRICKS_SERVER.BASECONFIG.NPCS, {
    Name = "Gang",
    Type = "Gang"
} )
