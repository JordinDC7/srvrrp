--[[
    UNIQUE WEAPON SYSTEM - Server Side
    Handles: MySQL storage, unique weapon creation on unbox,
    stat booster application, network sync to clients
]]--

if not SERVER then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.Cache = BRS_WEAPONS.Cache or {} -- uid -> weapon data cache

-- ============================================================
-- DATABASE SETUP
-- Uses the same MySQL connection as bricks_unboxing
-- ============================================================

local function WaitForDB(callback)
    if BRS_UNBOXING_DB then
        callback()
        return
    end
    timer.Create("BRS_UniqueWeapons_WaitDB", 1, 30, function()
        if BRS_UNBOXING_DB then
            timer.Remove("BRS_UniqueWeapons_WaitDB")
            callback()
        end
    end)
end

local function QueryDB(query, callback, singleRow)
    if not BRS_UNBOXING_DB then
        print("[BRS UniqueWeapons] ERROR: Database not connected!")
        return
    end
    local q = BRS_UNBOXING_DB:query(query)
    if callback then
        function q:onSuccess(data)
            data = data or {}
            if singleRow then data = data[1] or {} end
            callback(data)
        end
    end
    function q:onError(err)
        print("[BRS UniqueWeapons] SQL Error: " .. err)
        print("[BRS UniqueWeapons] Query: " .. string.sub(query, 1, 200))
    end
    q:start()
end

local function EscapeStr(str)
    if not BRS_UNBOXING_DB then return str end
    return BRS_UNBOXING_DB:escape(tostring(str))
end

-- Create the unique weapons table
WaitForDB(function()
    QueryDB([[
        CREATE TABLE IF NOT EXISTS bricks_server_unboxing_unique_weapons (
            weapon_uid VARCHAR(16) NOT NULL PRIMARY KEY,
            owner_steamid64 VARCHAR(20) NOT NULL,
            item_index INT NOT NULL,
            weapon_class VARCHAR(64) NOT NULL,
            weapon_name VARCHAR(128) NOT NULL,
            rarity VARCHAR(32) NOT NULL,
            stat_boosters TEXT NOT NULL,
            created_at INT NOT NULL,
            INDEX idx_owner (owner_steamid64),
            INDEX idx_rarity (rarity)
        );
    ]])
    print("[BRS UniqueWeapons] Database table validated!")
end)

-- ============================================================
-- UNIQUE WEAPON CRUD OPERATIONS
-- ============================================================

--- Save a new unique weapon to the database
function BRS_WEAPONS.SaveWeapon(uid, steamID64, itemIndex, weaponClass, weaponName, rarity, statBoosters)
    local boostersJSON = util.TableToJSON(statBoosters)
    local query = string.format(
        "INSERT INTO bricks_server_unboxing_unique_weapons (weapon_uid, owner_steamid64, item_index, weapon_class, weapon_name, rarity, stat_boosters, created_at) VALUES ('%s', '%s', %d, '%s', '%s', '%s', '%s', %d);",
        EscapeStr(uid), EscapeStr(steamID64), itemIndex,
        EscapeStr(weaponClass), EscapeStr(weaponName),
        EscapeStr(rarity), EscapeStr(boostersJSON),
        os.time()
    )
    QueryDB(query)

    -- Cache it
    BRS_WEAPONS.Cache[uid] = {
        weapon_uid = uid,
        owner_steamid64 = steamID64,
        item_index = itemIndex,
        weapon_class = weaponClass,
        weapon_name = weaponName,
        rarity = rarity,
        stat_boosters = statBoosters,
        created_at = os.time()
    }
end

--- Fetch all weapons for a player
function BRS_WEAPONS.FetchPlayerWeapons(steamID64, callback)
    QueryDB(
        "SELECT * FROM bricks_server_unboxing_unique_weapons WHERE owner_steamid64 = '" .. EscapeStr(steamID64) .. "';",
        function(data)
            local weapons = {}
            for _, row in ipairs(data) do
                row.stat_boosters = util.JSONToTable(row.stat_boosters or "{}") or {}
                row.item_index = tonumber(row.item_index) or 0
                weapons[row.weapon_uid] = row
                BRS_WEAPONS.Cache[row.weapon_uid] = row
            end
            if callback then callback(weapons) end
        end
    )
end

--- Transfer weapon ownership
function BRS_WEAPONS.TransferWeapon(uid, newSteamID64)
    QueryDB(string.format(
        "UPDATE bricks_server_unboxing_unique_weapons SET owner_steamid64 = '%s' WHERE weapon_uid = '%s';",
        EscapeStr(newSteamID64), EscapeStr(uid)
    ))
    if BRS_WEAPONS.Cache[uid] then
        BRS_WEAPONS.Cache[uid].owner_steamid64 = newSteamID64
    end
end

--- Delete a unique weapon
function BRS_WEAPONS.DeleteWeapon(uid)
    QueryDB("DELETE FROM bricks_server_unboxing_unique_weapons WHERE weapon_uid = '" .. EscapeStr(uid) .. "';")
    BRS_WEAPONS.Cache[uid] = nil
end

-- ============================================================
-- NETWORKING - Send unique weapon data to clients
-- ============================================================
util.AddNetworkString("BRS.UniqueWeapons.Sync")
util.AddNetworkString("BRS.UniqueWeapons.NewWeapon")
util.AddNetworkString("BRS.UniqueWeapons.Inspect")

--- Sync all unique weapons for a player
function BRS_WEAPONS.SyncToClient(ply)
    BRS_WEAPONS.FetchPlayerWeapons(ply:SteamID64(), function(weapons)
        -- Store on player entity for server-side access
        ply.BRS_UNIQUE_WEAPONS = weapons

        local jsonData = util.TableToJSON(weapons)

        -- Compress for large inventories
        local compressed = util.Compress(jsonData)
        if not compressed then return end

        net.Start("BRS.UniqueWeapons.Sync")
            net.WriteUInt(#compressed, 32)
            net.WriteData(compressed, #compressed)
        net.Send(ply)
    end)
end

--- Notify client of a newly unboxed weapon
function BRS_WEAPONS.NotifyNewWeapon(ply, weaponData)
    net.Start("BRS.UniqueWeapons.NewWeapon")
        net.WriteString(util.TableToJSON(weaponData))
    net.Send(ply)
end

-- Sync on player spawn
hook.Add("PlayerInitialSpawn", "BRS_UniqueWeapons_InitSync", function(ply)
    timer.Simple(3, function()
        if IsValid(ply) then
            BRS_WEAPONS.SyncToClient(ply)
        end
    end)
end)

-- Handle inspect requests
net.Receive("BRS.UniqueWeapons.Inspect", function(len, ply)
    local uid = net.ReadString()
    local weaponData = BRS_WEAPONS.Cache[uid]
    if not weaponData then return end

    net.Start("BRS.UniqueWeapons.Inspect")
        net.WriteString(util.TableToJSON(weaponData))
    net.Send(ply)
end)

-- ============================================================
-- CASE OPENING HOOK
-- Override case opening to create unique weapons instead of
-- just adding generic ITEM_X to inventory
-- ============================================================

hook.Add("BRS.Hooks.CaseUnboxed", "BRS_UniqueWeapons_OnCaseUnboxed", function(ply, amount)
    -- This hook fires AFTER the case is opened.
    -- The actual unique weapon creation happens in our net receive override below.
end)

-- We hook into the net message BEFORE the addon processes it
-- by overriding the case result handling
hook.Add("Initialize", "BRS_UniqueWeapons_HookCaseOpen", function()
    timer.Simple(5, function()
        -- Store the original UnboxCase handler to chain to
        -- We'll wrap the AddUnboxingInventoryItem function instead
        local origAdd = FindMetaTable("Player").AddUnboxingInventoryItem

        -- Keep original for non-weapon items (cases, keys, currency)
        FindMetaTable("Player").AddUnboxingInventoryItem_Original = origAdd

        -- Override to intercept weapon additions and make them unique
        FindMetaTable("Player").AddUnboxingInventoryItem = function(self, ...)
            local args = { ... }
            local newArgs = {}
            local weaponsToCreate = {}

            for i = 1, #args, 2 do
                local globalKey = args[i]
                local amount = args[i + 1] or 1

                if isstring(globalKey) and string.StartWith(globalKey, "ITEM_") then
                    local itemKey = tonumber(string.Replace(globalKey, "ITEM_", ""))

                    if itemKey and BRICKS_SERVER and BRICKS_SERVER.CONFIG and
                       BRICKS_SERVER.CONFIG.UNBOXING and BRICKS_SERVER.CONFIG.UNBOXING.Items and
                       BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey] then

                        local configItem = BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey]

                        -- Check if this is a weapon type item (PermWeapon or Weapon)
                        if configItem.Type == "PermWeapon" or configItem.Type == "Weapon" then
                            -- Create unique weapon(s) instead
                            for n = 1, amount do
                                table.insert(weaponsToCreate, {
                                    globalKey = globalKey,
                                    itemKey = itemKey,
                                    configItem = configItem
                                })
                            end
                        else
                            -- Non-weapon item, pass through normally
                            table.insert(newArgs, globalKey)
                            table.insert(newArgs, amount)
                        end
                    else
                        table.insert(newArgs, globalKey)
                        table.insert(newArgs, amount)
                    end
                else
                    table.insert(newArgs, globalKey)
                    table.insert(newArgs, amount)
                end
            end

            -- Add non-weapon items normally
            if #newArgs > 0 then
                origAdd(self, unpack(newArgs))
            end

            -- Create unique weapons
            for _, wepData in ipairs(weaponsToCreate) do
                local uid = BRS_WEAPONS.GenerateUID()
                local configItem = wepData.configItem
                local rarity = configItem.Rarity or "Common"
                local weaponClass = configItem.ReqInfo and configItem.ReqInfo[1] or ""
                local weaponName = configItem.Name or "Unknown"

                -- Roll stat boosters based on rarity
                local boosters = BRS_WEAPONS.RollStatBoosters(rarity)

                -- Save to database
                BRS_WEAPONS.SaveWeapon(
                    uid,
                    self:SteamID64(),
                    wepData.itemKey,
                    weaponClass,
                    weaponName,
                    rarity,
                    boosters
                )

                -- Add to inventory with unique key format: ITEM_X_uid
                local uniqueKey = wepData.globalKey .. "_" .. uid
                local inventoryTable = self:GetUnboxingInventory()
                inventoryTable[uniqueKey] = 1
                self:SetUnboxingInventory(inventoryTable)

                -- Store in player cache
                self.BRS_UNIQUE_WEAPONS = self.BRS_UNIQUE_WEAPONS or {}
                local weaponRecord = {
                    weapon_uid = uid,
                    owner_steamid64 = self:SteamID64(),
                    item_index = wepData.itemKey,
                    weapon_class = weaponClass,
                    weapon_name = weaponName,
                    rarity = rarity,
                    stat_boosters = boosters,
                    created_at = os.time()
                }
                self.BRS_UNIQUE_WEAPONS[uid] = weaponRecord

                -- Notify the client about the new weapon
                BRS_WEAPONS.NotifyNewWeapon(self, weaponRecord)

                print(string.format("[BRS UniqueWeapons] %s unboxed %s [%s] UID:%s with %d boosters",
                    self:Nick(), weaponName, rarity, uid, table.Count(boosters)))
            end
        end

        print("[BRS UniqueWeapons] Case opening hook installed!")
    end)
end)

-- ============================================================
-- STAT BOOSTER APPLICATION
-- When a unique weapon is equipped, modify its stats
-- ============================================================

-- Track which weapons have had boosters applied
local appliedWeapons = {} -- Entity index -> uid

--- Apply stat boosters to a weapon entity
function BRS_WEAPONS.ApplyBoosters(wep, uid)
    if not IsValid(wep) then return end

    local weaponData = BRS_WEAPONS.Cache[uid]
    if not weaponData or not weaponData.stat_boosters then return end

    local boosters = weaponData.stat_boosters
    local primary = wep.Primary
    if not primary then return end

    for statKey, boostValue in pairs(boosters) do
        local statDef = BRS_WEAPONS.StatDefs[statKey]
        if statDef and statDef.WeaponKey then
            local keys = string.Split(statDef.WeaponKey, ".")
            if #keys == 2 and keys[1] == "Primary" and primary[keys[2]] then
                local baseVal = primary[keys[2]]
                if isnumber(baseVal) then
                    local newVal = statDef.ApplyFunc(wep, baseVal, boostValue)
                    primary[keys[2]] = newVal

                    -- Also update Weapon table for clip size
                    if keys[2] == "ClipSize" then
                        wep:SetClip1(math.min(wep:Clip1(), newVal))
                    end
                end
            end
        end
    end

    -- Store that we applied boosters
    appliedWeapons[wep:EntIndex()] = uid

    -- Recalculate delay from RPM if RPM was boosted
    if boosters["RPM"] and primary.RPM then
        primary.Delay = 60 / primary.RPM
    end
end

-- Hook into weapon equipping from the unboxing system
hook.Add("PlayerLoadout", "BRS_UniqueWeapons_ApplyOnLoadout", function(ply)
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        BRS_WEAPONS.ApplyEquippedBoosters(ply)
    end)
end)

hook.Add("WeaponEquip", "BRS_UniqueWeapons_ApplyOnEquip", function(wep, ply)
    timer.Simple(0.1, function()
        if not IsValid(wep) or not IsValid(ply) then return end
        BRS_WEAPONS.ApplyEquippedBoosters(ply)
    end)
end)

--- Check all equipped items and apply boosters to matching weapons
function BRS_WEAPONS.ApplyEquippedBoosters(ply)
    if not IsValid(ply) then return end

    local inventory = ply:GetUnboxingInventory()
    local inventoryData = ply:GetUnboxingInventoryData()

    for globalKey, amount in pairs(inventory) do
        if not string.StartWith(globalKey, "ITEM_") then continue end

        -- Check if equipped
        if not inventoryData[globalKey] or not inventoryData[globalKey].Equipped then continue end

        -- Extract UID from unique key format: ITEM_X_uid
        local uid = string.match(globalKey, "^ITEM_%d+_(.+)$")
        if not uid then continue end

        local weaponData = BRS_WEAPONS.Cache[uid] or (ply.BRS_UNIQUE_WEAPONS or {})[uid]
        if not weaponData then continue end

        -- Find the weapon entity on the player
        for _, wep in ipairs(ply:GetWeapons()) do
            if IsValid(wep) and wep:GetClass() == weaponData.weapon_class then
                -- Only apply if not already applied
                if appliedWeapons[wep:EntIndex()] ~= uid then
                    BRS_WEAPONS.ApplyBoosters(wep, uid)
                end
                break
            end
        end
    end
end

-- Clean up tracking on weapon removal
hook.Add("EntityRemoved", "BRS_UniqueWeapons_CleanupTracking", function(ent)
    if ent:IsWeapon() then
        appliedWeapons[ent:EntIndex()] = nil
    end
end)

-- ============================================================
-- OVERRIDE GetItemFromGlobalKey TO SUPPORT UNIQUE KEYS
-- The original function only handles ITEM_X format
-- We need it to also handle ITEM_X_uid format
-- ============================================================
hook.Add("Initialize", "BRS_UniqueWeapons_OverrideGetItem", function()
    timer.Simple(5, function()
        if not BRICKS_SERVER or not BRICKS_SERVER.UNBOXING then return end

        local origFunc = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey

        BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey = function(globalKey)
            -- First try the unique weapon format: ITEM_X_uid
            if string.StartWith(globalKey, "ITEM_") then
                local itemKeyStr = string.match(globalKey, "^ITEM_(%d+)")
                local uid = string.match(globalKey, "^ITEM_%d+_(.+)$")

                if itemKeyStr then
                    local itemKey = tonumber(itemKeyStr)
                    if itemKey and BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey] then
                        local configItem = table.Copy(BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey])

                        -- If this is a unique weapon, add the UID to the config
                        if uid then
                            configItem._uniqueUID = uid
                            local cachedData = BRS_WEAPONS.Cache[uid]
                            if cachedData then
                                configItem._uniqueData = cachedData
                                configItem.Name = cachedData.weapon_name
                                configItem.Rarity = cachedData.rarity
                            end
                        end

                        return configItem, itemKey, true, false, false
                    end
                end
            end

            -- Fall back to original for cases, keys, and standard items
            return origFunc(globalKey)
        end

        print("[BRS UniqueWeapons] GetItemFromGlobalKey override installed!")
    end)
end)

-- ============================================================
-- DAMAGE HOOK
-- Apply damage boosters to bullets from unique weapons
-- ============================================================
hook.Add("EntityTakeDamage", "BRS_UniqueWeapons_DamageBoost", function(target, dmgInfo)
    local attacker = dmgInfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then return end

    local wep = attacker:GetActiveWeapon()
    if not IsValid(wep) then return end

    local uid = appliedWeapons[wep:EntIndex()]
    if not uid then return end

    local weaponData = BRS_WEAPONS.Cache[uid]
    if not weaponData or not weaponData.stat_boosters or not weaponData.stat_boosters["DMG"] then return end

    -- Damage is already applied via Primary.Damage modification
    -- This hook is a fallback for weapons that calculate damage differently
end)

print("[BRS UniqueWeapons] Server system loaded!")
