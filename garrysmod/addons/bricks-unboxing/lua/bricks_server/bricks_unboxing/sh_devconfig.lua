--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame or use the f4menu
    !!WARNING!!
]]--

BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount = 3

BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes = {
    ["Currency"] = {
        Name = "Currency",
        ReqInfo = {
            [1] = { "Currency", "table", "currencies" },
            [2] = { "Amount", "integer" }
        },
        UseMultiple = true,
        UseFunction = function( ply, reqInfo, amount )
            if( not BRICKS_SERVER.DEVCONFIG.Currencies[reqInfo[1]] ) then return end

            BRICKS_SERVER.DEVCONFIG.Currencies[reqInfo[1]].addFunction( ply, (reqInfo[2] or 0)*amount )

            return "Currency added from inventory!"
        end
    },
    ["Weapon"] = {
        Name = "Weapon",
        ReqInfo = {
            [1] = { "Weapon", "table", "weapons", function( itemTable )
                if( itemTable.ReqInfo and itemTable.ReqInfo[1] ) then
                    itemTable.Name = BRICKS_SERVER.Func.GetWeaponName( itemTable.ReqInfo[1] ) or itemTable.Name

                    local newModel = BRICKS_SERVER.Func.GetWeaponModel( itemTable.ReqInfo[1] )
                    if( newModel ) then
                        itemTable.Icon = nil
                        itemTable.Model = newModel
                    end

                    return itemTable
                end
            end }
        },
        UseFunction = function( ply, reqInfo )
            ply:Give( reqInfo[1] or "" )
            ply:SelectWeapon( reqInfo[1] or "" )
            
            return "Weapon equipped from inventory!"
        end
    },
    ["ConCommand"] = {
        Name = "Console Command",
        ReqInfo = {
            [1] = { "Command", "string" },
            [2] = { "Argument", "table", false, "Add Argument" }
        },
        UseFunction = function( ply, reqInfo )
            local arguments = {}
            for k, v in ipairs( reqInfo[2] or {} ) do
                arguments[k] = string.Replace( v, "{steamid64}", ply:SteamID64() )
                arguments[k] = string.Replace( arguments[k], "{steamid}", ply:SteamID() )
                arguments[k] = string.Replace( arguments[k], "{name}", ply:Nick() )
            end

            RunConsoleCommand( reqInfo[1] or "", unpack( arguments ) )

            return "Item used!"
        end
    },
    ["PermWeapon"] = {
        Name = "Permanent Weapon",
        TagName = "Permanent",
        ReqInfo = {
            [1] = { "Weapon", "table", "weapons", function( itemTable )
                if( itemTable.ReqInfo and itemTable.ReqInfo[1] ) then
                    itemTable.Name = BRICKS_SERVER.Func.GetWeaponName( itemTable.ReqInfo[1] ) or itemTable.Name

                    local newModel = BRICKS_SERVER.Func.GetWeaponModel( itemTable.ReqInfo[1] )
                    if( newModel ) then
                        itemTable.Icon = nil
                        itemTable.Model = newModel
                    end
                    
                    return itemTable
                end
            end }
        },
        EquipFunction = function( ply, reqInfo )
            if( not BRICKS_SERVER.UNBOXING.LUACFG.TTT ) then
                ply:Give( reqInfo[1] or "", true )
                ply:SelectWeapon( reqInfo[1] or "" )

                local ammoType = ply:GetActiveWeapon():GetPrimaryAmmoType()
                if( ply:GetAmmoCount( ammoType ) <= 0 ) then
                    ply:GiveAmmo( 50, ammoType, true )
                end
            end
            
            return "Weapon equipped from inventory!"
        end,
        UnEquipFunction = function( ply, reqInfo )
            ply:StripWeapon( reqInfo[1] or "" )
            
            return "Weapon unequipped from inventory!"
        end
    },
    ["PermPlayermodel"] = {
        Name = "Permanent Playermodel",
        TagName = "Permanent",
        ReqInfo = {
            [1] = { "Playermodel", "string" }
        },
        EquipFunction = function( ply, reqInfo )
            ply.BRS_UNBOXING_OLDMODEL = ply:GetModel()
            ply:SetModel( reqInfo[1] or "" )
            ply:SetupHands()
            
            return "Playermodel equipped from inventory!"
        end,
        UnEquipFunction = function( ply, reqInfo )
            local oldModel = ply.BRS_UNBOXING_OLDMODEL

            if( DarkRP ) then
                local darkRPModel = (RPExtraTeams[ply:Team()] or {}).model or {}
                oldModel = istable( darkRPModel ) and darkRPModel[1] or darkRPModel
            end

            if( oldModel ) then
                ply:SetModel( oldModel )
                ply:SetupHands()
            end
            
            return "Playermodel unequipped from inventory!"
        end
    },
    ["Entity"] = {
        Name = "Entity",
        ReqInfo = {
            [1] = { "Entity", "string" }
        },
        UseFunction = function( ply, reqInfo )
            local ent = ents.Create( reqInfo[1] )
            if( not IsValid( ent ) ) then return end
            ent:SetPos( ply:GetPos()+Vector( 0, 0, 30 )+(ply:GetForward()*30) )
            ent:Spawn()
            ent:DropToFloor()

            return "Entity spawned from inventory!"
        end
    }
}

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then
    BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes["Booster"] = {
        Name = "Booster",
        ReqInfo = {
            [1] = { "Booster", "table", "boosters" }
        },
        UseFunction = function( ply, reqInfo )
            ply:AddBooster( reqInfo[1] )

            return "Booster added to your inventory!"
        end
    }
end

hook.Add( "Initialize", "BricksServerHooks_Initialize_UnboxingDevCfg", function()
    timer.Simple( 10, function()
        if( SH_EASYSKINS ) then
            BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes["EasySkin"] = {
                Name = "Easy Skin",
                ReqInfo = {
                    [1] = { "Skin", "table", "easySkins", function( itemTable )
                        if( itemTable.ReqInfo ) then
                            itemTable.ReqInfo[2] = nil
                            return itemTable
                        end
                    end },
                    [2] = { "Weapon", "table", function( itemTable )
                        local skinTable = SH_EASYSKINS.GetSkins()[(itemTable.ReqInfo or {})[1] or 0] or {}
                        local weapons = {}
                        for k, v in pairs( skinTable.weaponTbl or {} ) do
                            weapons[v] = v
                        end
    
                        return weapons
                    end, function( itemTable )
                        if( itemTable.ReqInfo and itemTable.ReqInfo[1] ) then
                            itemTable.Name = BRICKS_SERVER.Func.GetWeaponName( itemTable.ReqInfo[2] ) or itemTable.Name
                            itemTable.Model = BRICKS_SERVER.Func.GetWeaponModel( itemTable.ReqInfo[2] ) or itemTable.Model
                            return itemTable
                        end
                    end }
                },
                ModelDisplay = function( panel, reqInfo )
                    local skin = SH_EASYSKINS.GetSkin( reqInfo[1] or 0 )
    
                    if( not skin or not skin.material or not skin.material.path ) then return end
    
                    panel.Entity:SetMaterial( skin.material.path )
                end,
                UseFunction = function( ply, reqInfo )
                    SV_EASYSKINS.GiveSkinToPlayer( ply:SteamID64(), reqInfo[1], { reqInfo[2] } )
    
                    return "Weapon skin redeemed from inventory!"
                end
            }
        end

        if( PROJECT0 ) then
            BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes["Project0Skin"] = {
                Name = "Project0 Skin",
                ReqInfo = {
                    [1] = { "Skin", "table", function()
                        local skins = {}
                        for k, v in pairs( PROJECT0.DEVCONFIG.WeaponSkins ) do
                            skins[k] = v.Name
                        end

                        return skins
                    end },
                    [2] = { "Weapon", "table", "weapons", function( itemTable )
                        itemTable.Name = BRICKS_SERVER.Func.GetWeaponName( itemTable.ReqInfo[2] ) or itemTable.Name
                        itemTable.Model = BRICKS_SERVER.Func.GetWeaponModel( itemTable.ReqInfo[2] ) or itemTable.Model
                        return itemTable
                    end }
                },
                ModelDisplay = function( panel, reqInfo )
                    local weaponConfig = PROJECT0.FUNC.GetConfiguredWeapon( reqInfo[2] )
                    local skinPath = (PROJECT0.DEVCONFIG.WeaponSkins[reqInfo[1]] or {}).Material
                    if( not skinPath or not weaponConfig ) then return end

                    for k, v in ipairs( weaponConfig.Skin.WorldModelMats ) do
                        panel.Entity:SetSubMaterial( v, skinPath )
                    end
                end,
                UseFunction = function( ply, reqInfo )
                    ply:Project0():AddWeaponSkin( reqInfo[1], reqInfo[2] )
    
                    return "Weapon skin redeemed from inventory!"
                end
            }

            BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes["Project0Charm"] = {
                Name = "Project0 Charm",
                ReqInfo = {
                    [1] = { "Charm", "table", function()
                        local charms = {}
                        for k, v in pairs( PROJECT0.CONFIG.CUSTOMISER.Charms ) do
                            charms[k] = v.Name
                        end

                        return charms
                    end, function( itemTable )
                        local charmConfig = PROJECT0.CONFIG.CUSTOMISER.Charms[itemTable.ReqInfo[1]]
                        if( not charmConfig ) then return itemTable end

                        itemTable.Name = charmConfig.Name
                        itemTable.Model = charmConfig.Model
                        return itemTable
                    end }
                },
                UseFunction = function( ply, reqInfo )
                    ply:Project0():AddCosmeticItem( 1, reqInfo[1] )
    
                    return "Weapon charm redeemed from inventory!"
                end
            }

            BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes["Project0Sticker"] = {
                Name = "Project0 Sticker",
                ReqInfo = {
                    [1] = { "Sticker", "table", function()
                        local stickers = {}
                        for k, v in pairs( PROJECT0.CONFIG.CUSTOMISER.Stickers ) do
                            stickers[k] = v.Name
                        end

                        return stickers
                    end, function( itemTable )
                        local stickerConfig = PROJECT0.CONFIG.CUSTOMISER.Stickers[itemTable.ReqInfo[1]]
                        if( not stickerConfig ) then return itemTable end

                        itemTable.Name = stickerConfig.Name
                        itemTable.Model = nil
                        itemTable.Icon = stickerConfig.Icon
                        return itemTable
                    end }
                },
                UseFunction = function( ply, reqInfo )
                    ply:Project0():AddCosmeticItem( 2, reqInfo[1] )
    
                    return "Weapon sticker redeemed from inventory!"
                end
            }
        end
    end )
end )

BRICKS_SERVER.DEVCONFIG.UnboxingStatTypes = {
    ["cases"] = {},
    ["trades"] = {},
    ["items"] = {}
}

BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels = {
    [1] = {
        Name = "Plastic Case",
        Model = "models/sterling/brickwall_lootbox_plastic.mdl",
        FOV = 60
    }
}

BRICKS_SERVER.DEVCONFIG.UnboxingKeyModels = {
    [1] = {
        Name = "Plastic Key",
        Model = "models/sterling/brickwall_lootbox_plastic_key.mdl"
    }
}

BRICKS_SERVER.DEVCONFIG.NPCTypes = BRICKS_SERVER.DEVCONFIG.NPCTypes or {}
BRICKS_SERVER.DEVCONFIG.NPCTypes["Unboxing"] = {
    UseFunction = function( ply, ent, NPCKey )
        BRICKS_SERVER.UNBOXING.Func.OpenMenu( ply )
    end
}