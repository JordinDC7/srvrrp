sPrinter = sPrinter or {}
sPrinter.config = sPrinter.config or {}
sPrinter.config.printers = sPrinter.config.printers or {}

--  _______                               _  
-- (_______)                             | | 
--  _   ___ _____ ____  _____  ____ _____| | 
-- | | (_  | ___ |  _ \| ___ |/ ___|____ | | 
-- | |___) | ____| | | | ____| |   / ___ | | 
--  \_____/|_____)_| |_|_____)_|   \_____|\_)

sPrinter.config["language"] = "en"

sPrinter.config["prefix"] = "[sPrinter] "

sPrinter.config["logging_col"] = Color(200,0,0)

sPrinter.config["currency"] = "$"

sPrinter.config["hack_speed"] = 6

sPrinter.config["punish_exploit"] = true

sPrinter.config["hack_words"] = {
    ["HACKING"] = true,
    ["L33T"] = true,
    ["1337"] = true,
    ["LULZ"] = true
}

sPrinter.config["max_printer_bag"] = { --- This is the max printers the printer bag can hold!
    ["default"] = 3,
    ["superadmin"] = 5
}

sPrinter.config["rack_repair_price"] = 12000

sPrinter.config["DarkRPFireSystem_Spawn_Flame_On_Explode"] = true --- This will spawn a flame if you have the darkrp fire system and this is enabled!

sPrinter.config["disable_topscreen_in_rack"] = true --- This will disable drawing the topscreen while the printer is in a rack, good for performance!

sPrinter.config["maxdistance"] = 8000

sPrinter.config["maxdrawdistance"] = 30000

sPrinter.config["logo"] = {
    ["sprinter_base"] = {
        enabled = true,
        id = "YtNiTIU",
        size = {w = 420, h = 420},
        pos = Vector(-13.135, 19.546, 4.8),
        ang = Angle(0,0,0)
    },
    ["sprinter_rack"] = {
        enabled = true,
        id = "YtNiTIU",
        size = {w = 420, h = 420},
        pos = Vector(-3, -10.7, 44.187),
        ang = Angle(0,0,90)
    },
}

sPrinter.config["soundradius"] = 60

sPrinter.config["damageradius"] = {20,50}

sPrinter.config["blastdamage"] = {30,80}

sPrinter.config["recharge_price_per_percentage"] = true --- This is enabled it will only charge per percent you charge based on the charge price the printer has defined.

--  ______              _     ______  ______  
-- (______)            | |   (_____ \(_____ \ 
--  _     _ _____  ____| |  _ _____) )_____) )
-- | |   | (____ |/ ___) |_/ )  __  /|  ____/ 
-- | |__/ // ___ | |   |  _ (| |  \ \| |      
-- |_____/ \_____|_|   |_| \_)_|   |_|_|      

hook.Add("loadCustomDarkRPItems", "sP:LoadEnts", function()
    ------------------------------------------------------------------------------------
    --  You can use any DarkRP create entity variables here just like normal in here.
    ------------------------------------------------------------------------------------

    sPrinter.config["reward_teams"] = {
        --[TEAM_CITIZEN] = true -- Add whatever you want in here! 
    }
    
    sPrinter.config["drp_categories"] = { -- This can be used to setup custom categories, for example Premium Printers etc...
        {
            name = "Printers",
            color = Color(200,0,0),
            canSee = function(ply)
                return true
            end,
            sortOrder = 999,
        },
        // {
        //     name = "Example1",
        //     color = Color(230,0,0),
        //     sortOrder = 20,
        // },
    }

    sPrinter.config["rack"] = {
        ["body_color"] = Color(112,112,112),
        ["godmode"] = true, -- Should we godmode the printer rack?
        ["water_affect"] = 2, -- 0 = Ignore, 1 = Blow up & 2 = Eject

        ["price"] = 20000, --- This is the price of the rack in the DarkRP Entities
        ["max"] = 1,
        ["min_recharge"] = .8, --- If printers are below this percentage it will recharge them if done through the rack, 0.8 is default and is equal to 80%.
        // ["category"] = "Printers",
        // ["allowed"] = {}, --- This is where you add allowed teams.
        // ["disabled"] = true, --- If you wanna disable the printer rack.

        // ["sortOrder"] = -100,
        // ["CustomCheckFailMsg"] = "This is a test",
        // ["customCheck"] = function() end 
    }

    sPrinter.config.printers["Tier 1"] = {
        bodycolor = Color(174,174,174),
        clockspeed = 3.4,
        baseincome = 40,
        maxstorage = 200000,
        sortorder = 1,
        batteryconsumption = .3, --- This is how many percent it will take per 10 seconds
        rechargeprice = 2000,
        repairprice = 2000,
        // category = "Example",
        // cantwithdrawjobs = {["Citizen"] = true},
        // withdrawjobswhitelist = true,
        water_affect = 1, --- 0 = Ignore, 1 = Blow up & 2 = Turn off
        reward = .4, --- This is how much of the cost that the person to destroy the printer will earn, based on the price of the printer!
        // countUpgradesToReward = true, --- This will make the upgrades count into the reward amount!
        dmgresistance = 1, --- This is the damage multiplier the printer receive
        price = 4000, --- This is the cost of buying the printer in the entities list!
        max = 3,
        upgrades = {
            {upgrade = "overclocking", baseprice = 2000, max = 10, icon = Material("sprinter/overclock.png", "smooth")}, --- You can enforce pricing for each upgrade level like this ([upgrade_stage] = price) : , enforced_pricing = {[1] = 200, [2] = 400}
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Tier 2"] = {
        bodycolor = Color(0,188,178),
        clockspeed = 3.7,
        baseincome = 50,
        maxstorage = 400000,
        sortorder = 2,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = .4,
        dmgresistance = .9,
        price = 5000,
        max = 2,
        upgrades = {
            {upgrade = "overclocking", baseprice = 2000, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Tier 3"] = {
        bodycolor = Color(94,188,0),
        clockspeed = 4.1,
        baseincome = 60,
        maxstorage = 600000,
        sortorder = 3,
        batteryconsumption = .26,
        rechargeprice = 4000,
        repairprice = 2000,
        water_affect = 1,
        reward = .4,
        dmgresistance = .8,
        price = 7000,
        max = 2,
        upgrades = {
            {upgrade = "overclocking", baseprice = 2000, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Tier 4"] = {
        bodycolor = Color(188,188,0),
        clockspeed = 4.6,
        baseincome = 70,
        maxstorage = 800000,
        // sortorder = 4,
        batteryconsumption = .26,
        rechargeprice = 5000,
        repairprice = 2000,
        water_affect = 1,
        reward = .4,
        // basevolume = 0.5, -- This is the base volume the printer makes, do not make it above 1 - each upgrade remove .1 from the basevolume. Example: basevolume as 0.5 will make it completely quiet if you have max 5 noise reduction upgrades.
        // cantwithdrawjobs = {["Citizen"] = true},
        // withdrawjobswhitelist = true -- this will determing if the list above is a whitelist or a blacklist
        // cantwithdrawusergroups = {["superadmin"] = true},
        // xpmultiplier = .3, -- This is the amount of xp you will receive from withdrawing money - amount * multiplier
        // ignoretemperature = true,
        dmgresistance = .8,
        price = 12000,
        usergroup = {
    ["user"] = true,
    ["vip"] = true,
    ["admin"] = true,
    ["superadmin"] = true
},
failmsg = "You are not allowed to purchase this printer.",
        max = 1,
        upgrades = {
            {upgrade = "overclocking", baseprice = 2000, max = 10, usergroup = {["vip"] = true, ["*"] = true}, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 8, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }
    
    sPrinter.loadDarkRPContent()
end)