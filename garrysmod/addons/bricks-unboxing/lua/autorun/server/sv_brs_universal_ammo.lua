-- ============================================================
-- BRS Universal Ammo System
-- - Sets ammo capacity to essentially unlimited (99999)
-- - F4 ammo tab entry: gives +100 rounds to all weapons on buy
-- - No chat commands
-- ============================================================
if not SERVER then return end

local AMMO_MAX = 99999
local AMMO_PER_BUY = 100
local UNIVERSAL_AMMO_NAME = "Universal Ammo (100 rounds)"

-- ============================================================
-- SET ALL AMMO TYPES TO UNLIMITED CAPACITY
-- ============================================================
hook.Add("Initialize", "BRS_SetAmmoMax", function()
    timer.Simple(1, function()
        local ammoTypes = {
            "pistol", "smg1", "ar2", "357", "buckshot",
            "slam", "rpg_round", "smg1_grenade", "ar2_altfire",
            "sniperpenetratedround", "alyxgun", "SniperRound",
            "m9k_ammo_ar2", "m9k_ammo_buckshot", "m9k_ammo_pistol",
            "m9k_ammo_smg1", "m9k_ammo_357", "m9k_ammo_sniper_round",
            "AirboatGun", "StriderMinigun", "HelicopterGun",
        }
        for _, ammoType in ipairs(ammoTypes) do
            game.SetAmmoMax(game.GetAmmoID(ammoType), AMMO_MAX)
        end
        print("[BRS] Ammo capacity set to " .. AMMO_MAX .. " for all types")
    end)
end)

-- Catch any new ammo type encountered
hook.Add("WeaponEquip", "BRS_EnsureAmmoMax", function(wep, ply)
    if not IsValid(wep) then return end
    timer.Simple(0.1, function()
        if not IsValid(wep) then return end
        local at1 = wep:GetPrimaryAmmoType()
        if at1 >= 0 then game.SetAmmoMax(at1, AMMO_MAX) end
        local at2 = wep:GetSecondaryAmmoType()
        if at2 >= 0 then game.SetAmmoMax(at2, AMMO_MAX) end
    end)
end)

-- ============================================================
-- HOOK: When player buys our universal ammo from F4 ammo tab,
-- give +100 rounds to ALL weapons instead of just one type
-- ============================================================
hook.Add("playerBuyAmmo", "BRS_UniversalAmmoBuy", function(ply, ammoTable, ammoType)
    if not IsValid(ply) then return end
    if not ammoTable or ammoTable.name ~= UNIVERSAL_AMMO_NAME then return end

    -- Give 100 rounds to every weapon the player has
    for _, wep in ipairs(ply:GetWeapons()) do
        if not IsValid(wep) then continue end

        local clipMax = wep:GetMaxClip1()
        if clipMax > 0 then
            wep:SetClip1(clipMax)
        end

        local at = wep:GetPrimaryAmmoType()
        if at >= 0 then
            ply:GiveAmmo(AMMO_PER_BUY, at, true)
        end

        local clipMax2 = wep:GetMaxClip2()
        if clipMax2 > 0 then
            wep:SetClip2(clipMax2)
        end

        local at2 = wep:GetSecondaryAmmoType()
        if at2 >= 0 then
            ply:GiveAmmo(AMMO_PER_BUY, at2, true)
        end
    end
end)

-- Fallback: Verify our ammo entry registered
hook.Add("InitPostEntity", "BRS_UniversalAmmoHookFallback", function()
    timer.Simple(3, function()
        -- Check both possible ammo registration tables
        local found = false

        if CustomAmmoTypes then
            for id, tbl in pairs(CustomAmmoTypes) do
                if istable(tbl) and tbl.name == UNIVERSAL_AMMO_NAME then
                    found = true
                    print("[BRS] Universal Ammo registered in ammo tab (CustomAmmoTypes) as ID " .. id)
                    break
                end
            end
        end

        if not found and GAMEMODE and GAMEMODE.AmmoTypes then
            for id, tbl in pairs(GAMEMODE.AmmoTypes) do
                if istable(tbl) and tbl.name == UNIVERSAL_AMMO_NAME then
                    found = true
                    print("[BRS] Universal Ammo registered in ammo tab (GAMEMODE.AmmoTypes) as ID " .. id)
                    break
                end
            end
        end

        if not found and CustomShipments then
            for id, tbl in pairs(CustomShipments) do
                if istable(tbl) and tbl.name == UNIVERSAL_AMMO_NAME then
                    found = true
                    print("[BRS] Universal Ammo found in CustomShipments as ID " .. id)
                    break
                end
            end
        end

        if not found then
            print("[BRS] WARNING: Universal Ammo not found in any ammo table!")
        end
    end)
end)

print("[BRS] Universal Ammo System loaded - F4 ammo tab, capacity " .. AMMO_MAX)
