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
BRICKS_SERVER.BASECONFIG.GANGS["Max Level"] = 100
BRICKS_SERVER.BASECONFIG.GANGS["Original EXP Required"] = 100
BRICKS_SERVER.BASECONFIG.GANGS["EXP Required Increase"] = 1.25
BRICKS_SERVER.BASECONFIG.GANGS["Creation Fee"] = 1500
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
        Name = "Max Members", 
        Description = "Maximum allowed members.",
        Icon = "members_upgrade.png",
        Default = { 4 },
        Tiers = {
            [1] = {
                Price = 5000,
                ReqInfo = { 8 }
            },
            [2] = {
                Price = 25000,
                ReqInfo = { 16 }
            }
        }
    },
    ["MaxBalance"] = {
        Name = "Max Balance", 
        Description = "Maximum allowed balance.",
        Icon = "balance.png",
        Default = { 10000 },
        Tiers = {
            [1] = {
                Price = 5000,
                ReqInfo = { 25000 }
            },
            [2] = {
                Price = 25000,
                ReqInfo = { 100000 }
            }
        }
    },
    ["StorageSlots"] = {
        Name = "Storage Slots", 
        Description = "Amount of storage slots.",
        Icon = "storage_64.png",
        Default = { 10 },
        Tiers = {
            [1] = {
                Price = 5000,
                ReqInfo = { 20 }
            },
            [2] = {
                Price = 25000,
                ReqInfo = { 40 }
            }
        }
    },
    ["Health"] = {
        Name = "Increased Health", 
        Description = "Gives extra health on spawn.",
        Icon = "health_upgrade.png",
        Default = { 0 },
        Tiers = {
            [1] = {
                Price = 5000,
                ReqInfo = { 25 }
            },
            [2] = {
                Price = 10000,
                ReqInfo = { 50 }
            },
            [3] = {
                Price = 25000,
                ReqInfo = { 75 }
            },
            [4] = {
                Price = 50000,
                ReqInfo = { 100 }
            }
        }
    },
    ["Armor"] = {
        Name = "Increased Armor", 
        Description = "Gives extra armor on spawn.",
        Icon = "armor_upgrade.png",
        Default = { 0 },
        Tiers = {
            [1] = {
                Price = 5000,
                ReqInfo = { 10 }
            },
            [2] = {
                Price = 10000,
                ReqInfo = { 25 }
            },
            [3] = {
                Price = 25000,
                ReqInfo = { 50 }
            }
        }
    },
    ["Salary"] = {
        Name = "Increased Salary", 
        Description = "Gives a higher salary.",
        Icon = "salary_upgrade.png",
        Default = { 0 },
        Tiers = {
            [1] = {
                Price = 5000,
                ReqInfo = { 75 }
            },
            [2] = {
                Price = 10000,
                ReqInfo = { 150 }
            },
            [3] = {
                Price = 25000,
                ReqInfo = { 250 }
            }
        }
    },
    ["Weapon_1"] = {
        Name = "Permanent AK47",
        Description = "All members spawn with an AK47!",
        Icon = "https://i.imgur.com/iDezZ62.png",
        Price = 5000,
        Type = "Weapon",
        ReqInfo = { "weapon_ak472" }
    },
    ["Weapon_2"] = {
        Name = "Permanent Sniper",
        Description = "All members spawn with a sniper!",
        Icon = "https://i.imgur.com/mPSQunx.png",
        Price = 15000,
        Type = "Weapon",
        ReqInfo = { "ls_sniper" }
    }
}

BRICKS_SERVER.BASECONFIG.GANGS.Achievements = {
    [1] = {
        Name = "Members 1", 
        Description = "Reach a member count of 4.",
        Icon = "members_upgrade.png",
        Category = "Members Achievements",
        Type = "Members",
        ReqInfo = { 4 },
        Rewards = { ["GangBalance"] = { 500 }, ["GangExperience"] = { 100 } }
    },
    [2] = {
        Name = "Members 2", 
        Description = "Reach a member count of 8.",
        Icon = "members_upgrade.png",
        Category = "Members Achievements",
        Type = "Members",
        ReqInfo = { 8 },
        Rewards = { ["GangBalance"] = { 1000 }, ["GangExperience"] = { 200 } }
    },
    [3] = {
        Name = "Members 3", 
        Description = "Reach a member count of 16.",
        Icon = "members_upgrade.png",
        Category = "Members Achievements",
        Type = "Members",
        ReqInfo = { 16 },
        Rewards = { ["GangBalance"] = { 2000 }, ["GangExperience"] = { 400 } }
    },
    [4] = {
        Name = "Balance 1", 
        Description = "Reach a gang balance of $10,000.",
        Icon = "balance.png",
        Category = "Balance Achievements",
        Type = "Balance",
        ReqInfo = { 10000 },
        Rewards = { ["GangBalance"] = { 500 }, ["GangExperience"] = { 100 } }
    },
    [5] = {
        Name = "Balance 2", 
        Description = "Reach a gang balance of $25,000.",
        Icon = "balance.png",
        Category = "Balance Achievements",
        Type = "Balance",
        ReqInfo = { 25000 },
        Rewards = { ["GangBalance"] = { 1000 }, ["GangExperience"] = { 200 } }
    },
    [6] = {
        Name = "Balance 3", 
        Description = "Reach a gang balance of $100,000.",
        Icon = "balance.png",
        Category = "Balance Achievements",
        Type = "Balance",
        ReqInfo = { 100000 },
        Rewards = { ["GangBalance"] = { 2000 }, ["GangExperience"] = { 400 } }
    },
    [7] = {
        Name = "Storage 1", 
        Description = "Have at least 5 items in storage.",
        Icon = "inventory_64.png",
        Category = "Storage Achievements",
        Type = "Storage",
        ReqInfo = { 5 },
        Rewards = { ["GangBalance"] = { 500 }, ["GangExperience"] = { 100 } }
    },
    [8] = {
        Name = "Storage 2", 
        Description = "Have at least 15 items in storage.",
        Icon = "inventory_64.png",
        Category = "Storage Achievements",
        Type = "Storage",
        ReqInfo = { 15 },
        Rewards = { ["GangBalance"] = { 1000 }, ["GangExperience"] = { 200 } }
    },
    [9] = {
        Name = "Storage 3", 
        Description = "Have at least 35 items in storage.",
        Icon = "inventory_64.png",
        Category = "Storage Achievements",
        Type = "Storage",
        ReqInfo = { 35 },
        Rewards = { ["GangBalance"] = { 2000 }, ["GangExperience"] = { 400 } }
    },
    [10] = {
        Name = "Level 10", 
        Description = "Reach a gang level of 10.",
        Icon = "levelling.png",
        Category = "Level Achievements",
        Type = "Level",
        ReqInfo = { 10 },
        Rewards = { ["GangBalance"] = { 500 }, ["GangExperience"] = { 100 } }
    },
    [11] = {
        Name = "Level 25", 
        Description = "Reach a gang level of 25.",
        Icon = "levelling.png",
        Category = "Level Achievements",
        Type = "Level",
        ReqInfo = { 25 },
        Rewards = { ["GangBalance"] = { 1000 }, ["GangExperience"] = { 200 } }
    }
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