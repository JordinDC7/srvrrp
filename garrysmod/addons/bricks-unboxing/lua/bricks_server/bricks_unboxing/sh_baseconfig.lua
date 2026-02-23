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
BRICKS_SERVER.BASECONFIG.UNBOXING.Items = {
    [1] = {          
        Name = "Five Seven",
        Model = "models/weapons/w_pist_fiveseven.mdl",
        Rarity = "Common",
        Type = "Weapon",
        ReqInfo = { "weapon_fiveseven2" }
    },
    [2] = {          
        Name = "Mac 10",
        Model = "models/weapons/w_smg_mac10.mdl",
        Rarity = "Uncommon",
        Type = "Weapon",
        ReqInfo = { "weapon_mac102" }
    },
    [3] = {          
        Name = "Pump Shotgun",
        Model = "models/weapons/w_shot_m3super90.mdl",
        Rarity = "Rare",
        Type = "Weapon",
        ReqInfo = { "weapon_pumpshotgun2" }
    },
    [4] = {          
        Name = "M4",
        Model = "models/weapons/w_rif_m4a1.mdl",
        Rarity = "Epic",
        Type = "Weapon",
        ReqInfo = { "weapon_m42" }
    },
    [5] = {          
        Name = "AK47",
        Model = "models/weapons/w_rif_ak47.mdl",
        Rarity = "Legendary",
        Type = "Weapon",
        ReqInfo = { "weapon_ak472" }
    },
    [6] = {          
        Name = "$250,000",
        Model = "models/props/cs_assault/money.mdl",
        Rarity = "Legendary",
        Type = "Currency",
        ReqInfo = { "darkrp_money", 250000 }
    },
    [7] = {          
        Name = "$1,000,000",
        Model = "models/props/cs_assault/money.mdl",
        Rarity = "Glitched",
        Type = "Currency",
        ReqInfo = { "darkrp_money", 1000000 }
    },
    [8] = {          
        Name = "Silenced Sniper",
        Model = "models/weapons/w_snip_g3sg1.mdl",
        Rarity = "Glitched",
        Type = "Weapon",
        ReqInfo = { "ls_sniper" }
    },
    [9] = {          
        Name = "RPG",
        Model = "models/weapons/w_rocket_launcher.mdl",
        Rarity = "Glitched",
        Type = "Weapon",
        ReqInfo = { "weapon_rpg" }
    },
    [10] = {
        Name = "$5,000,000",
        Model = "models/props/cs_assault/money.mdl",
        Rarity = "Mythical",
        Type = "Currency",
        ReqInfo = { "darkrp_money", 5000000 }
    }
}
BRICKS_SERVER.BASECONFIG.UNBOXING.Cases = {
    [1] = {          
        Name = "Common Case",
        Model = 1,
        Rarity = "Common",
        Color = Color( 164, 164, 164 ),
        Keys = { [1] = true },
        Items = { 
            ["ITEM_1"] = { 50 },
            ["ITEM_2"] = { 10 },
            ["ITEM_3"] = { 5 },
            ["CASE_1"] = { 25 },
            ["KEY_1"] = { 25 }
        }
    },
    [2] = {          
        Name = "Uncommon Case",
        Model = 1,
        Rarity = "Uncommon",
        Color = Color( 92, 217, 70 ),
        Keys = { [2] = true },
        Items = { 
            ["ITEM_1"] = { 45 },
            ["ITEM_2"] = { 25 },
            ["ITEM_3"] = { 15 },
            ["ITEM_4"] = { 10 },
            ["ITEM_5"] = { 5 }
        }
    },
    [3] = {          
        Name = "Rare Case",
        Model = 1,
        Rarity = "Rare",
        Color = Color( 77, 192, 255 ),
        Keys = { [3] = true },
        Items = { 
            ["ITEM_1"] = { 5 },
            ["ITEM_2"] = { 10 },
            ["ITEM_3"] = { 15 },
            ["ITEM_4"] = { 20 },
            ["ITEM_5"] = { 25 },
            ["CASE_2"] = { 20 },
            ["CASE_4"] = { 5 }
        }
    },
    [4] = {          
        Name = "Epic Case",
        Model = 1,
        Rarity = "Epic",
        Color = Color( 215, 43, 228 ),
        Keys = { [4] = true },
        Items = { 
            ["CASE_4"] = { 15 },
            ["CASE_5"] = { 5 },
            ["ITEM_2"] = { 10 },
            ["ITEM_3"] = { 20 },
            ["ITEM_4"] = { 30 },
            ["KEY_4"] = { 15 },
            ["KEY_5"] = { 5 }
        }
    },
    [5] = {          
        Name = "Legendary Case",
        Model = 1,
        Rarity = "Legendary",
        Color = Color( 250, 190, 38 ),
        Keys = { [5] = true },
        Items = { 
            ["CASE_5"] = { 10 },
            ["ITEM_2"] = { 5 },
            ["ITEM_3"] = { 10 },
            ["ITEM_4"] = { 25 },
            ["ITEM_5"] = { 20 },
            ["ITEM_6"] = { 20 },
            ["KEY_5"] = { 10 }
        }
    },
    [6] = {          
        Name = "Glitched Case",
        Model = 1,
        Rarity = "Glitched",
        Color = Color( 0, 0, 0 ),
        Keys = { [6] = true },
        Items = { 
            ["ITEM_5"] = { 35 },
            ["ITEM_6"] = { 35 },
            ["ITEM_7"] = { 10 },
            ["ITEM_8"] = { 10 },
            ["ITEM_9"] = { 10 }
        }
    },
    [7] = {
        Name = "Mythical Case",
        Model = 1,
        Rarity = "Mythical",
        Color = Color( 255, 66, 244 ),
        Keys = { [7] = true },
        Items = {
            ["ITEM_8"] = { 35 },
            ["ITEM_9"] = { 30 },
            ["ITEM_10"] = { 20 },
            ["CASE_6"] = { 10 },
            ["KEY_7"] = { 5 }
        }
    }
}
BRICKS_SERVER.BASECONFIG.UNBOXING.Keys = {
    [1] = {          
        Name = "Common Key",
        Model = 1,
        Rarity = "Common",
        Color = Color( 255, 255, 255 )
    },
    [2] = {          
        Name = "Uncommon Key",
        Model = 1,
        Rarity = "Uncommon",
        Color = Color( 148, 236, 133 )
    },
    [3] = {          
        Name = "Rare Key",
        Model = 1,
        Rarity = "Rare",
        Color = Color( 130, 211, 255 )
    },
    [4] = {          
        Name = "Epic Key",
        Model = 1,
        Rarity = "Epic",
        Color = Color( 213, 121, 224 )
    },
    [5] = {          
        Name = "Legendary Key",
        Model = 1,
        Rarity = "Legendary",
        Color = Color( 255, 208, 99 )
    },
    [6] = {          
        Name = "Glitched Key",
        Model = 1,
        Rarity = "Glitched",
        Color = Color( 137, 134, 134 )
    },
    [7] = {
        Name = "Mythical Key",
        Model = 1,
        Rarity = "Mythical",
        Color = Color( 244, 121, 255 )
    }
}
BRICKS_SERVER.BASECONFIG.UNBOXING.Store = {
    Featured = { 10, 4, 3 },
    Categories = {
        [1] = {
            Name = "Weapons",
            SortOrder = 1
        },
        [2] = {
            Name = "Cases",
            SortOrder = 2
        },
        [3] = {
            Name = "Keys",
            SortOrder = 3
        }
    },
    Items = {
        [1] = {
            GlobalKey = "ITEM_3",
            Category = 1,
            SortOrder = 4,
            Price = 1000
        },
        [2] = {
            GlobalKey = "ITEM_4",
            Category = 1,
            SortOrder = 3,
            Price = 2500
        },
        [3] = {
            GlobalKey = "ITEM_5",
            Category = 1,
            SortOrder = 2,
            Price = 5000,
            Group = "VIP"
        },
        [4] = {
            GlobalKey = "ITEM_8",
            Category = 1,
            SortOrder = 1,
            Price = 25000,
            Group = "VIP++"
        },
        [5] = {
            GlobalKey = "CASE_1",
            Category = 2,
            SortOrder = 6,
            Price = 1000
        },
        [6] = {
            GlobalKey = "CASE_2",
            Category = 2,
            SortOrder = 5,
            Price = 2500
        },
        [7] = {
            GlobalKey = "CASE_3",
            Category = 2,
            SortOrder = 4,
            Price = 5000
        },
        [8] = {
            GlobalKey = "CASE_4",
            Category = 2,
            SortOrder = 3,
            Price = 7500,
            Group = "VIP"
        },
        [9] = {
            GlobalKey = "CASE_5",
            Category = 2,
            SortOrder = 2,
            Price = 12500,
            Group = "VIP++"
        },
        [10] = {
            GlobalKey = "CASE_6",
            Category = 2,
            SortOrder = 1,
            Price = 25000,
            Group = "VIP++"
        },
        [11] = {
            GlobalKey = "CASE_7",
            Category = 2,
            SortOrder = 0,
            Price = 50000,
            Group = "VIP++"
        },
        [12] = {
            GlobalKey = "KEY_1",
            Category = 3,
            SortOrder = 6,
            Price = 1000
        },
        [13] = {
            GlobalKey = "KEY_2",
            Category = 3,
            SortOrder = 5,
            Price = 2500
        },
        [14] = {
            GlobalKey = "KEY_3",
            Category = 3,
            SortOrder = 4,
            Price = 5000
        },
        [15] = {
            GlobalKey = "KEY_4",
            Category = 3,
            SortOrder = 3,
            Price = 7500,
            Group = "VIP"
        },
        [16] = {
            GlobalKey = "KEY_5",
            Category = 3,
            SortOrder = 2,
            Price = 12500,
            Group = "VIP++"
        },
        [17] = {
            GlobalKey = "KEY_6",
            Category = 3,
            SortOrder = 1,
            Price = 25000,
            Group = "VIP++"
        },
        [18] = {
            GlobalKey = "KEY_7",
            Category = 3,
            SortOrder = 0,
            Price = 50000,
            Group = "VIP++"
        }
    },
}
BRICKS_SERVER.BASECONFIG.UNBOXING.Marketplace = {}
BRICKS_SERVER.BASECONFIG.UNBOXING.Marketplace.Slots = {
    [1] = {},
    [2] = {
        Price = 1000
    },
    [3] = {
        Group = "VIP"
    },
    [4] = {
        Price = 25000,
        Group = "VIP++"
    }
}
BRICKS_SERVER.BASECONFIG.UNBOXING.Rewards = {
    [1] = {
        ["CASE_1"] = 1,
        ["KEY_1"] = 1
    },
    [2] = {
        ["ITEM_1"] = 2,
        ["ITEM_2"] = 1
    },
    [3] = {
        ["CASE_2"] = 1,
        ["KEY_2"] = 1
    },
    [4] = {
        ["ITEM_3"] = 1
    },
    [5] = {
        ["CASE_2"] = 1
    },
    [6] = {
        ["ITEM_3"] = 1,
        ["CASE_2"] = 1
    },
    [7] = {
        ["CASE_6"] = 1
    },
    [8] = {
        ["CASE_7"] = 1,
        ["KEY_7"] = 1
    }
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
    { "CASE_1", 25 },
    { "KEY_1", 25 },
    { "ITEM_1", 20 },
    { "CASE_2", 10 },
    { "KEY_2", 10 },
    { "ITEM_2", 5 },
    { "CASE_1", 5, 5 }
}

--[[ NPCS ]]--
BRICKS_SERVER.BASECONFIG.NPCS = BRICKS_SERVER.BASECONFIG.NPCS or {}
table.insert( BRICKS_SERVER.BASECONFIG.NPCS, {
    Name = "Unboxing",
    Type = "Unboxing"
} )
