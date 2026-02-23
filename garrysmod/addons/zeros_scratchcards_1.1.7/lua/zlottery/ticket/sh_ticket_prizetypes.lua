zlt = zlt or {}
zlt.Ticket = zlt.Ticket or {}

zlt.Ticket.PrizeTypes = {}
local function AddPrizeType(data) return table.insert(zlt.Ticket.PrizeTypes,data) end

/*
    1 = NoWin
    2 = Money
    3 = Entity
    4 = Weapon
    5 = Health
    6 = Armor
    7 = Accessory HatID
    8 = Pointshop01 Points
    9 = Pointshop02 StandardPoints
    10 = Pointshop02 PremiumPoints
    11 = Blues Unboxing 3
    12 = Underdone
    13 = MTokens
    14 = Lua Input
    15 = EasySkins
    16 = sReward
    17 = EliteXP
    18 = Essentials - Level
    19 = Essentials - XP
    20 = Glorified - Level
    21 = Glorified - XP
    22 = Vrondakis - Level
    23 = Vrondakis - XP
    24 = WOS - Level
    25 = WOS - XP
    26 = WOS - Points
    27 = WOS - Item
    28 = SantosRP - GiveItem
    29 = DarkRP - Shipment
    30 = Xenin - Deathscreen
*/



// NO WIN
AddPrizeType({
    name = "No Win",
    installed = true,
    display_value = function(data) return "" end,
    func = function(ply, data)
    end
})

// Money
AddPrizeType({
    name = "Money",
    installed = true,
    //icon = Material("materials/zerochain/zerolib/gameicons/moneystack.png", "noclamp smooth"),
    display_value = function(data)
        return zclib.Money.Display(data.money or 0)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "money" , type = "text_numeric",title = zlt.language["Amount"]}
    },
    func = function(ply, data)
        if data.money == nil then return end
        if SERVER then
            zlt.Money.Give(ply, data.money)
            zclib.Notify(ply, string.Replace(zlt.language["YouWon"],"$PrizeName",zclib.Money.Display(data.money)), 0)
        end
    end,
})

// Entity
AddPrizeType({
    name = "Entity",
    installed = true,
    icon = Material("materials/zerochain/zerolib/gameicons/lockedchest.png", "noclamp smooth"),
    display_value = function(data)
        return tostring(data.class)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "class" ,type = "text_default",title = zlt.language["Class"]},
        [5] = {var = "model" ,type = "text_default",title = zlt.language["Model"]},
        [6] = {var = "lua" ,type = "text_lua",title = zlt.language["Lua"],emptytext = zlt.language["Lua_ent_emptytext"]},
    },
    func = function(ply, data)
        if data.class == nil then return end
        if SERVER then
            local ent = ents.Create(data.class)
            if not IsValid(ent) then return end
            ent:SetPos(ply:LocalToWorld(Vector(80,0,80)))
            ent:SetAngles(Angle(0, 0, 0))
            ent:Spawn()
            ent:Activate()
            if data.model then ent:SetModel(data.model) end
            zclib.Player.SetOwner(ent, ply)

            if data.lua then
                local bootstrap = [[
                local ent = Entity(]] .. ent:EntIndex() .. [[)
                ]]
                local func = CompileString(bootstrap .. data.lua, "zlt_lua_code_" .. math.random(10000, 10000000), true)
                func()
            end

            if zclib.Inventory.Pickup(ply,ent,data.class) then
                local str = string.Replace(zlt.language["InvAutoPickup_entity"],"$Entity",data.class)
                zclib.Notify(ply, str, 0)
            end
        end
    end,
})

// Weapon
AddPrizeType({
    name = "Weapon",
    installed = true,
    icon = Material("materials/zerochain/zerolib/gameicons/pistolgun.png", "noclamp smooth"),
    display_value = function(data)
        local val = data.class or "Invalid"
        local swep_data = weapons.Get( val )
        if swep_data and swep_data.PrintName then
            val = swep_data.PrintName
        end
        return val
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "class" ,type = "text_default",title = zlt.language["Class"],AutoSearchForImgurID = true},
    },
    func = function(ply, data)
        if data.class == nil then return end
        if SERVER then
            if ply:HasWeapon(data.class) == true then

                local ent = ents.Create(data.class)
                if not IsValid(ent) then return end
                ent:SetPos(ply:LocalToWorld(Vector(80,0,80)))
                ent:SetAngles(Angle(0, 0, 0))
                ent:Spawn()
                ent:Activate()

                return
            end
            ply:Give(data.class)
            ply:SelectWeapon(data.class)
        end
    end
})

// Health
AddPrizeType({
    name = "Health",
    installed = true,
    icon = Material("materials/zerochain/zerolib/gameicons/healthcapsule.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Amount"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if SERVER then
            ply:SetHealth(math.Clamp(ply:Health() + (data.amount or 100), 0, ply:GetMaxHealth()))
        end
    end,
})

// Armor
AddPrizeType({
    name = "Armor",
    installed = true,
    icon = Material("materials/zerochain/zerolib/gameicons/armorupgrade.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Amount"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if SERVER then
            ply:SetArmor(math.Clamp(ply:Armor() + (data.amount or 100), 0, 100))
        end
    end
})

// SH Accessory
AddPrizeType({
    name = "SH Accessory",
    installed = SH_ACC,
    icon = Material("materials/zerochain/zerolib/gameicons/tophat.png", "noclamp smooth"),
    display_value = function(data)
        return tostring(data.hatid)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "hatid" ,type = "text_default",title = zlt.language["AccessoryID"]},
    },
    func = function(ply, data)
        if data.hatid == nil then return end
        if ply.SH_HasAccessory == nil then return end
        if SERVER and ply:SH_HasAccessory(data.hatid) == false then
            ply:SH_AddAccessory(data.hatid)
        end
    end
})

// Pointshop 1 - Points
AddPrizeType({
    name = "Pointshop 1 - Points",
    installed = PS,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Amount"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if SERVER then
            ply:PS_GivePoints(data.amount)
        end
    end
})

// Pointshop 2 - Standard
AddPrizeType({
    name = "Pointshop 2 - Standard",
    installed = Pointshop2,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Amount"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if SERVER then ply:PS2_AddStandardPoints(data.amount) end
    end
})

// Pointshop 2 - PP
AddPrizeType({
    name = "Pointshop 2 - Premium",
    installed = Pointshop2,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Amount"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if SERVER then ply:PS2_AddPremiumPoints(data.amount) end
    end
})

// Blues Unboxing 3
AddPrizeType({
    name = "Blues Unboxing 3",
    installed = BU3,
    icon = Material("materials/zerochain/zerolib/gameicons/key.png", "noclamp smooth"),
    display_value = function(data)
        return tostring(data.class) .. " x" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "class" ,type = "text_numeric",title = zlt.language["Item"]},
        [5] = {var = "amount" ,type = "text_numeric",title = zlt.language["Amount"]},
    },
    func = function(ply, data)
        if data.class == nil then return end
        if data.amount == nil then return end
        if SERVER then
            ply:UB3AddItem(tonumber(data.class), data.amount)
        end
    end
})

// Underdone
AddPrizeType({
    name = "Underdone",
    installed = engine.ActiveGamemode() == "underdone",
    icon = Material("materials/zerochain/zerolib/gameicons/lockedchest.png", "noclamp smooth"),
    display_value = function(data)
        return tostring(data.class) .. " x" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "class" ,type = "text_default",title = zlt.language["Class"]},
        [5] = {var = "amount" ,type = "text_numeric",title = zlt.language["Amount"]},
    },
    func = function(ply, data)
        if data.class == nil then return end
        if data.amount == nil then return end
        if SERVER and engine.ActiveGamemode() == "underdone" then
            ply:AddItem(data.class, data.amount)
        end
    end
})

// Mtokens
AddPrizeType({
    name = "MTokens",
    installed = mTokens,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Amount"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if SERVER then
            mTokens.AddPlayerTokens(ply, data.amount)
        end
    end
})

// Lua Input
AddPrizeType({
    name = "Lua",
    installed = true,
    icon = Material("materials/zerochain/zerolib/ui/edit.png", "smooth"),
    display_value = function(data)
        return data.name or "Lua Code"
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "lua" ,type = "text_lua",title = zlt.language["Lua"],emptytext = zlt.language["Lua_ply_emptytext"]},
    },
    func = function(ply, data)
        if SERVER and data.lua then
            local bootstrap = [[
            local ply = Player(]] .. ply:UserID() .. [[)
            ]]
            local func = CompileString(bootstrap .. data.lua, "zlt_lua_code_" .. math.random(10000, 10000000), true)
            func()
        end
    end
})

// EasySkins
AddPrizeType({
    name = "EasySkin",
    installed = SH_EASYSKINS,
    icon = Material("materials/zerochain/zerolib/gameicons/pistolgun.png", "noclamp smooth"),
    display_value = function(data)
        local name = "EasySkin"

        if SH_EASYSKINS and data.ezskin and data.ezskin.ezs_skinid and data.ezskin.ezs_weaponclass then
            local skin = SH_EASYSKINS.GetSkin(data.ezskin.ezs_skinid)
            if skin and skin.dispName then
                name = skin.dispName .. " " .. data.ezskin.ezs_weaponclass
            end
        end
        return name
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "ezskin" ,type = "ezs_editor",title = zlt.language["EasySkins Editor"]},
    },
    func = function(ply, data)
        if SERVER and data.ezskin.ezs_skinid and data.ezskin.ezs_weaponclass then

            if SH_EASYSKINS == nil then return end

			local skin = SH_EASYSKINS.GetSkin(data.ezskin.ezs_skinid)

			local WeaponClass = data.ezskin.ezs_weaponclass

			// If the weapon class Random is selected as reward then the player will get a random weapon for the specified Skin
			if WeaponClass == "Random" then

				WeaponClass = skin.weaponTbl[math.random(#skin.weaponTbl)]

				local NotOwnedYet
				for k,v in pairs(skin.weaponTbl) do
					if not SH_EASYSKINS.HasPurchasedSkin(ply,data.ezskin.ezs_skinid, v) then
						NotOwnedYet = v
						break
					end
				end

				if NotOwnedYet then
					WeaponClass = NotOwnedYet
				else
					WeaponClass = skin.weaponTbl[1]
				end
			end

            // Does the player already own this weapon skin?
            if SH_EASYSKINS.HasPurchasedSkin(ply,data.ezskin.ezs_skinid, WeaponClass) == true then


                local text = zlt.language["EasySkin_Owned"]
                text = string.Replace(text,"$SkinName",tostring(skin.dispName))
                text = string.Replace(text,"$WeaponClass",tostring(WeaponClass))
                zclib.Notify(ply, text, 3)

                return
            end
            SV_EASYSKINS.GiveSkinToPlayer(ply:SteamID64(), data.ezskin.ezs_skinid, {WeaponClass})
        end
    end
})

// sReward
AddPrizeType({
    name = "sReward",
    installed = sReward,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount) .. " " .. zlt.language["Tokens"]
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Tokens"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if sReward == nil then return end
        if SERVER then
            sReward.GiveTokens(ply,data.amount)
        end
    end
})

// EliteXP
AddPrizeType({
    name = "EliteXP",
    installed = EliteXP,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["XP"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if EliteXP == nil then return end
        if SERVER then
            EliteXP.CheckXP(ply, data.amount)
        end
    end
})

// Essentials - Level
AddPrizeType({
    name = "Essentials - Level",
    installed = BRICKS_SERVER,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Level"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if ply.AddLevel == nil then return end
        if SERVER then
            ply:AddLevel(data.amount)
        end
    end
})

// Essentials - XP
AddPrizeType({
    name = "Essentials - XP",
    installed = BRICKS_SERVER,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["XP"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if ply.AddExperience == nil then return end
        if SERVER then
            ply:AddExperience(data.amount,"")
        end
    end
})

// Glorified - Level
AddPrizeType({
    name = "Glorified - Level",
    installed = GlorifiedLeveling,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Level"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if GlorifiedLeveling == nil then return end
        if GlorifiedLeveling.AddPlayerLevels == nil then return end
        if SERVER then
            GlorifiedLeveling.AddPlayerLevels(ply, data.amount)
        end
    end
})

// Glorified - XP
AddPrizeType({
    name = "Glorified - XP",
    installed = GlorifiedLeveling,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["XP"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if GlorifiedLeveling == nil then return end
        if GlorifiedLeveling.AddPlayerXP == nil then return end
        if SERVER then
            GlorifiedLeveling.AddPlayerXP(ply, data.amount)
        end
    end
})

// Vrondakis - Level
AddPrizeType({
    name = "Vrondakis - Level",
    installed = LevelSystemConfiguration,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Level"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if ply.addLevels == nil then return end
        if SERVER then
            ply:addLevels(data.amount)
        end
    end
})

// Vrondakis - XP
AddPrizeType({
    name = "Vrondakis - XP",
    installed = LevelSystemConfiguration,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["XP"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end
        if ply.addXP == nil then return end
        if SERVER then
            ply:addXP(data.amount)
        end
    end
})

// WOS - Level
AddPrizeType({
    name = "WOS - Level",
    installed = wOS,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Level"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end

        if SERVER then
            if not isfunction(ply.SetSkillLevel) then return end
            local oldLevel = ply:GetSkillLevel()
            ply:SetSkillLevel(oldLevel + data.amount)
        end
    end
})

// WOS - XP
AddPrizeType({
    name = "WOS - XP",
    installed = wOS,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["XP"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end

        if SERVER then
            if not isfunction(ply.SetSkillXP) then return end
            local oldXP = ply:GetSkillXP()
            ply:SetSkillXP(oldXP + xp)
        end
    end
})

// WOS - Points
AddPrizeType({
    name = "WOS - Points",
    installed = wOS,
    icon = Material("materials/zerochain/zerolib/gameicons/twocoins.png", "noclamp smooth"),
    display_value = function(data)
        return "+" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "amount" ,type = "text_numeric",title = zlt.language["Points"]},
    },
    func = function(ply, data)
        if data.amount == nil then return end

        if SERVER then
            if not isfunction(ply.SetSkillPoints) then return end
            local oldPoints = ply:GetSkillPoints()
            ply:SetSkillPoints(oldPoints + points)
        end
    end
})

// WOS - Item
AddPrizeType({
    name = "WOS - Item",
    installed = wOS,
    icon = Material("materials/zerochain/zerolib/gameicons/lockedchest.png", "noclamp smooth"),
    display_value = function(data)
        return tostring(data.item)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "item" ,type = "text_default",title = zlt.language["Item"]},
    },
    func = function(ply, data)
        if data.item == nil then return end

        if SERVER and wOS and wOS.HandleItemPickup then
            wOS:HandleItemPickup( ply, data.item)
        end
    end
})

// SantosRP - GiveItem
AddPrizeType({
    name = "SantosRP - Item",
    installed = santosRP,
    icon = Material("materials/zerochain/zerolib/gameicons/key.png", "noclamp smooth"),
    display_value = function(data)
        return tostring(data.class) .. " x" .. tostring(data.amount)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "class" ,type = "text_default",title = zlt.language["Item"]},
        [5] = {var = "amount" ,type = "text_numeric",title = zlt.language["Amount"]},
    },
    func = function(ply, data)
        if data.class == nil then return end
        if data.amount == nil then return end
        if SERVER then

            if not GAMEMODE.Inv:ValidItem(data.class) then return end

            GAMEMODE.Inv:GivePlayerItem(ply, data.class,data.amount)
        end
    end
})

// DarkRP - CustomShipments
AddPrizeType({
    name = "DarkRP - Shipment",
    installed = DarkRP and CustomShipments,
    icon = Material("materials/zerochain/zerolib/gameicons/lockedchest.png", "noclamp smooth"),
    display_value = function(data)
        if data.shipData and data.shipData.shipID and CustomShipments[data.shipData.shipID] then
            return tostring(CustomShipments[data.shipData.shipID].name)
        else
            return "Invalid Shipment"
        end
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "shipData" ,type = "darkrp_shipments",title = "Shipment:"},
    },
    func = function(ply, data)
        if data.shipData == nil then return end
        if data.shipData.shipID == nil then return end

        if SERVER then

            local found = CustomShipments[data.shipData.shipID]
            if found == nil then return end

            local crate = ents.Create(found.shipmentClass or "spawned_shipment")
            crate.SID = ply.SID
            crate:Setowning_ent(ply)
            crate:SetContents(data.shipData.shipID, data.shipData.shipAmount or found.amount)

            crate:SetPos(ply:LocalToWorld(Vector(80,0,80)))
            crate.nodupe = true
            crate.ammoadd = found.spareammo
            crate.clip1 = found.clip1
            crate.clip2 = found.clip2
            crate:Spawn()
            crate:SetPlayer(ply)

            local phys = crate:GetPhysicsObject()
            phys:Wake()
            if found.weight then phys:SetMass(found.weight) end
        end
    end,
})

// Xenin - Deathscreen
AddPrizeType({
    name = "Xenin - Deathscreen",
    installed = XeninDS,
    icon = Material("materials/zerochain/zerolib/gameicons/lockedchest.png", "noclamp smooth"),
    display_value = function(data)
        if XeninDS == nil then return tostring(data.item) end
        local cardData = XeninDS.Config.cards[data.item]
        if cardData == nil or cardData.name == nil then return tostring(data.item) end
        return cardData.name
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "item" ,type = "xenin_ds",title = zlt.language["Item"],AutoSearchForImgurID = true},
    },
    func = function(ply, data)
        if data.item == nil then return end
        if XeninDS == nil then return end

        if SERVER then
            local reward = data.item

            local ds = ply:XeninDeathscreen()
            if ds == nil then return end
            if (ds:getCard(reward)) then return end

            // Give him the card
            ds:addCard(reward)
            ds:saveCard(reward)

            // Send the client his new data
            ply.__XeninDSHasRequestedSync = true
            ply:XeninDeathscreen():load()
        end
    end
})

// AAS Accessory
AddPrizeType({
    name = "AAS Accessory",
    installed = AAS,
    icon = Material("materials/zerochain/zerolib/gameicons/tophat.png", "noclamp smooth"),
    display_value = function(data)
        return tostring(data.hatid)
    end,
    inputfields = {
        [1] = {var = "name" ,type = "text_default",title = zlt.language["Name"]},
        [2] = {var = "icon" ,type = "icon_editor",title = zlt.language["Icon"]},
        [3] = {type = "seperator"},
        [4] = {var = "hatid" ,type = "text_default",title = zlt.language["AccessoryID"]},
    },
    func = function(ply, data)
        if data.hatid == nil then return end
        if SERVER and ply:AASIsBought(data.hatid) == false then
            AAS.GiveItem(ply:SteamID64(), data.hatid, 0)
        end
    end
})
