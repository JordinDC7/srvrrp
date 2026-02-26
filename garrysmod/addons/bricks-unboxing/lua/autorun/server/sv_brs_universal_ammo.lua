-- ============================================================
-- BRS Universal Ammo System
-- - Sets ammo capacity to essentially unlimited (99999)
-- - F4 entities tab: spawns brs_universal_ammo entity
-- - Entity Use() gives +100 rounds to all weapons (see entities/brs_universal_ammo)
-- ============================================================
if not SERVER then return end

local AMMO_MAX = 99999

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

print("[BRS] Universal Ammo System loaded - F4 entities tab, capacity " .. AMMO_MAX)
