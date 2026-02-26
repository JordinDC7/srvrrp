-- ============================================================
-- BRS Universal Ammo System
-- /buyammo - Refill current weapon's ammo (costs DarkRP money)
-- /buyammoall - Refill ALL weapons' ammo
-- Works with any weapon (M9K, default, custom)
-- ============================================================
if not SERVER then return end

local AMMO_PRICE_PER_CLIP = 500      -- Cost per clip refill
local AMMO_PRICE_ALL = 2500           -- Cost to refill all weapons
local COOLDOWN = 1.0                  -- Seconds between purchases

local lastBuy = {} -- steamid -> time

-- ============================================================
-- CORE: Refill a weapon's ammo
-- ============================================================
local function RefillWeapon(ply, wep)
    if not IsValid(wep) then return false end

    local refilled = false

    -- Refill clip (magazine)
    local clipMax = wep:GetMaxClip1()
    if clipMax > 0 and wep:Clip1() < clipMax then
        wep:SetClip1(clipMax)
        refilled = true
    end

    -- Refill reserve ammo
    local ammoType = wep:GetPrimaryAmmoType()
    if ammoType >= 0 then
        local maxAmmo = game.GetAmmoMax(ammoType)
        if maxAmmo <= 0 then maxAmmo = clipMax * 5 end -- fallback: 5 clips worth
        if maxAmmo <= 0 then maxAmmo = 200 end -- absolute fallback

        local currentReserve = ply:GetAmmoCount(ammoType)
        if currentReserve < maxAmmo then
            ply:SetAmmo(maxAmmo, ammoType)
            refilled = true
        end
    end

    -- Secondary ammo (shotgun underbarrel, etc)
    local clipMax2 = wep:GetMaxClip2()
    if clipMax2 > 0 and wep:Clip2() < clipMax2 then
        wep:SetClip2(clipMax2)
        refilled = true
    end

    local ammoType2 = wep:GetSecondaryAmmoType()
    if ammoType2 >= 0 then
        local maxAmmo2 = game.GetAmmoMax(ammoType2)
        if maxAmmo2 <= 0 then maxAmmo2 = 30 end
        local cur2 = ply:GetAmmoCount(ammoType2)
        if cur2 < maxAmmo2 then
            ply:SetAmmo(maxAmmo2, ammoType2)
            refilled = true
        end
    end

    return refilled
end

-- ============================================================
-- COMMAND: /buyammo - Refill current weapon
-- ============================================================
local function BuyAmmo(ply)
    if not IsValid(ply) then return end

    -- Cooldown
    local sid = ply:SteamID64()
    if lastBuy[sid] and CurTime() - lastBuy[sid] < COOLDOWN then
        BRICKS_SERVER.Func.SendNotification(ply, 2, 3, "Please wait before buying ammo again.")
        return
    end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then
        BRICKS_SERVER.Func.SendNotification(ply, 2, 3, "You're not holding a weapon.")
        return
    end

    -- Check if already full
    local clipMax = wep:GetMaxClip1()
    local ammoType = wep:GetPrimaryAmmoType()
    local isFull = true
    if clipMax > 0 and wep:Clip1() < clipMax then isFull = false end
    if ammoType >= 0 then
        local maxAmmo = game.GetAmmoMax(ammoType)
        if maxAmmo <= 0 then maxAmmo = clipMax * 5 end
        if maxAmmo <= 0 then maxAmmo = 200 end
        if ply:GetAmmoCount(ammoType) < maxAmmo then isFull = false end
    end

    if isFull then
        BRICKS_SERVER.Func.SendNotification(ply, 2, 3, "Your " .. (wep:GetPrintName() or "weapon") .. " is already fully loaded.")
        return
    end

    -- Check money
    if not ply:canAfford(AMMO_PRICE_PER_CLIP) then
        BRICKS_SERVER.Func.SendNotification(ply, 2, 3, "You need $" .. string.Comma(AMMO_PRICE_PER_CLIP) .. " to buy ammo.")
        return
    end

    -- Purchase
    ply:addMoney(-AMMO_PRICE_PER_CLIP)
    RefillWeapon(ply, wep)
    lastBuy[sid] = CurTime()

    BRICKS_SERVER.Func.SendNotification(ply, 1, 3, "Ammo refilled for " .. (wep:GetPrintName() or "weapon") .. "! (-$" .. string.Comma(AMMO_PRICE_PER_CLIP) .. ")")
end

-- ============================================================
-- COMMAND: /buyammoall - Refill ALL weapons
-- ============================================================
local function BuyAmmoAll(ply)
    if not IsValid(ply) then return end

    local sid = ply:SteamID64()
    if lastBuy[sid] and CurTime() - lastBuy[sid] < COOLDOWN then
        BRICKS_SERVER.Func.SendNotification(ply, 2, 3, "Please wait before buying ammo again.")
        return
    end

    -- Check if any weapon needs ammo
    local weapons = ply:GetWeapons()
    local needsAmmo = false
    for _, wep in ipairs(weapons) do
        if IsValid(wep) then
            local clipMax = wep:GetMaxClip1()
            if clipMax > 0 and wep:Clip1() < clipMax then needsAmmo = true break end
            local ammoType = wep:GetPrimaryAmmoType()
            if ammoType >= 0 then
                local maxAmmo = game.GetAmmoMax(ammoType)
                if maxAmmo <= 0 then maxAmmo = clipMax * 5 end
                if maxAmmo <= 0 then maxAmmo = 200 end
                if ply:GetAmmoCount(ammoType) < maxAmmo then needsAmmo = true break end
            end
        end
    end

    if not needsAmmo then
        BRICKS_SERVER.Func.SendNotification(ply, 2, 3, "All your weapons are already fully loaded.")
        return
    end

    if not ply:canAfford(AMMO_PRICE_ALL) then
        BRICKS_SERVER.Func.SendNotification(ply, 2, 3, "You need $" .. string.Comma(AMMO_PRICE_ALL) .. " to refill all weapons.")
        return
    end

    ply:addMoney(-AMMO_PRICE_ALL)
    local count = 0
    for _, wep in ipairs(weapons) do
        if IsValid(wep) and RefillWeapon(ply, wep) then
            count = count + 1
        end
    end
    lastBuy[sid] = CurTime()

    BRICKS_SERVER.Func.SendNotification(ply, 1, 3, "All weapons refilled! (" .. count .. " weapons, -$" .. string.Comma(AMMO_PRICE_ALL) .. ")")
end

-- ============================================================
-- REGISTER CHAT COMMANDS
-- ============================================================
hook.Add("PlayerSay", "BRS_UniversalAmmo", function(ply, text)
    local lower = string.lower(string.Trim(text))

    if lower == "/buyammo" or lower == "!buyammo" then
        BuyAmmo(ply)
        return ""
    end

    if lower == "/buyammoall" or lower == "!buyammoall" or lower == "/buyammo all" or lower == "!buyammo all" then
        BuyAmmoAll(ply)
        return ""
    end
end)

-- Cleanup on disconnect
hook.Add("PlayerDisconnected", "BRS_AmmoCleanup", function(ply)
    lastBuy[ply:SteamID64()] = nil
end)

print("[BRS] Universal Ammo System loaded - /buyammo ($" .. AMMO_PRICE_PER_CLIP .. ") | /buyammoall ($" .. AMMO_PRICE_ALL .. ")")
