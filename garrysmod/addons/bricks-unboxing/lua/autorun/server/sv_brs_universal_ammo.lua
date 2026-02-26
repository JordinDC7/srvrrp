-- ============================================================
-- BRS Universal Ammo System
-- - Sets ammo capacity to essentially unlimited
-- - /buyammo ($1000) - instant refill all weapons (no crate needed)
-- - F4 menu ammo crate entity also available
-- ============================================================
if not SERVER then return end

local AMMO_PER_BUY = 100
local AMMO_MAX = 99999   -- max capacity so players can stockpile
local AMMO_PRICE = 100
local COOLDOWN = 1.0

-- ============================================================
-- SET ALL AMMO TYPES TO UNLIMITED CAPACITY
-- This runs once on server start so players can hold 99999
-- ============================================================
hook.Add("Initialize", "BRS_SetAmmoMax", function()
    timer.Simple(1, function()
        -- Common ammo types used by M9K and Source weapons
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

        -- Also catch any ammo type a player might use
        -- by hooking into weapon equip and setting max for that type
        print("[BRS] Ammo capacity set to " .. AMMO_MAX .. " for all types")
    end)
end)

-- Ensure any new ammo type encountered also gets unlimited cap
hook.Add("WeaponEquip", "BRS_EnsureAmmoMax", function(wep, ply)
    if not IsValid(wep) then return end
    timer.Simple(0.1, function()
        if not IsValid(wep) then return end
        local ammoType = wep:GetPrimaryAmmoType()
        if ammoType >= 0 then
            local ammoName = game.GetAmmoName(ammoType)
            if ammoName then
                game.SetAmmoMax(ammoType, AMMO_MAX)
            end
        end
        local ammoType2 = wep:GetSecondaryAmmoType()
        if ammoType2 >= 0 then
            game.SetAmmoMax(ammoType2, AMMO_MAX)
        end
    end)
end)

-- ============================================================
-- CORE: Refill all weapons for a player
-- ============================================================
local function RefillAllWeapons(ply)
    local count = 0
    for _, wep in ipairs(ply:GetWeapons()) do
        if not IsValid(wep) then continue end

        local clipMax = wep:GetMaxClip1()
        if clipMax > 0 then wep:SetClip1(clipMax) end

        local ammoType = wep:GetPrimaryAmmoType()
        if ammoType >= 0 then
            ply:GiveAmmo(AMMO_PER_BUY, ammoType, true)
            count = count + 1
        end

        local clipMax2 = wep:GetMaxClip2()
        if clipMax2 > 0 then wep:SetClip2(clipMax2) end

        local ammoType2 = wep:GetSecondaryAmmoType()
        if ammoType2 >= 0 then
            ply:GiveAmmo(AMMO_PER_BUY, ammoType2, true)
        end
    end
    return count
end

-- ============================================================
-- CHAT COMMAND: /buyammo - instant refill (convenience)
-- ============================================================
local lastBuy = {}

hook.Add("PlayerSay", "BRS_UniversalAmmo", function(ply, text)
    local lower = string.lower(string.Trim(text))

    if lower == "/buyammo" or lower == "!buyammo" then
        local sid = ply:SteamID64()
        if lastBuy[sid] and CurTime() - lastBuy[sid] < COOLDOWN then
            BRICKS_SERVER.Func.SendNotification(ply, 2, 3, "Please wait before buying ammo again.")
            return ""
        end

        if not ply:canAfford(AMMO_PRICE) then
            BRICKS_SERVER.Func.SendNotification(ply, 2, 3, "You need $" .. string.Comma(AMMO_PRICE) .. " to buy ammo.")
            return ""
        end

        ply:addMoney(-AMMO_PRICE)
        local count = RefillAllWeapons(ply)
        lastBuy[sid] = CurTime()

        BRICKS_SERVER.Func.SendNotification(ply, 1, 3, "+" .. AMMO_PER_BUY .. " rounds added to " .. count .. " weapons! (-$" .. string.Comma(AMMO_PRICE) .. ")")
        return ""
    end
end)

hook.Add("PlayerDisconnected", "BRS_AmmoCleanup", function(ply)
    lastBuy[ply:SteamID64()] = nil
end)

print("[BRS] Universal Ammo System loaded - /buyammo ($" .. AMMO_PRICE .. " for " .. AMMO_PER_BUY .. " rounds) | F4 Ammo Crate ($100)")
