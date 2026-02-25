-- ============================================================
-- UNIQUE WEAPONS SYSTEM - Server
-- Handles: MySQL storage, unique weapon generation, stat application, sync
-- ============================================================
if not SERVER then return end

BRS_UW = BRS_UW or {}
BRS_UW.ServerCache = BRS_UW.ServerCache or {} -- steamid64 -> { [globalKey] = data }

-- Migrate old "mob" stat key to "mag" for existing weapons
function BRS_UW.MigrateStats(stats)
    if stats and stats.mob and not stats.mag then
        stats.mag = stats.mob
        stats.mob = nil
    end
    return stats
end

util.AddNetworkString("BRS_UW.SyncWeaponData")
util.AddNetworkString("BRS_UW.SyncAllWeapons")
util.AddNetworkString("BRS_UW.RequestInspect")
util.AddNetworkString("BRS_UW.InspectResult")

-- ============================================================
-- DATABASE TABLE CREATION
-- ============================================================
local function CreateUniqueWeaponsTable()
    -- Wait for bricks DB to be ready
    timer.Simple(5, function()
        if not BRS_UNBOXING_DB then
            print("[BRS UW] WARNING: BRS_UNBOXING_DB not found, retrying in 5s...")
            CreateUniqueWeaponsTable()
            return
        end

        local createQuery = BRS_UNBOXING_DB:query([[
            CREATE TABLE IF NOT EXISTS bricks_server_unique_weapons (
                uid VARCHAR(8) NOT NULL,
                steamid64 VARCHAR(20) NOT NULL,
                global_key VARCHAR(30) NOT NULL,
                base_item_key INT NOT NULL,
                weapon_class VARCHAR(50) NOT NULL,
                weapon_name VARCHAR(100) NOT NULL,
                rarity VARCHAR(20) NOT NULL,
                quality VARCHAR(20) NOT NULL,
                stats TEXT NOT NULL,
                avg_boost FLOAT NOT NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (uid),
                INDEX idx_steamid (steamid64),
                INDEX idx_globalkey (global_key)
            );
        ]])

        function createQuery:onSuccess(data)
            print("[BRS UW] unique_weapons table validated!")
        end
        function createQuery:onError(err)
            print("[BRS UW] Table creation error: " .. err)
        end
        createQuery:start()
    end)
end
CreateUniqueWeaponsTable()

-- ============================================================
-- DATABASE OPERATIONS
-- ============================================================
function BRS_UW.SaveWeaponDB(uid, steamid64, globalKey, baseItemKey, weaponClass, weaponName, rarity, quality, stats, avgBoost)
    if not BRS_UNBOXING_DB then return end

    local statsJSON = util.TableToJSON(stats)
    local q = BRS_UNBOXING_DB:query(string.format(
        "REPLACE INTO bricks_server_unique_weapons (uid, steamid64, global_key, base_item_key, weapon_class, weapon_name, rarity, quality, stats, avg_boost) VALUES ('%s', '%s', '%s', %d, '%s', '%s', '%s', '%s', '%s', %.1f);",
        BRS_UNBOXING_DB:escape(uid),
        BRS_UNBOXING_DB:escape(steamid64),
        BRS_UNBOXING_DB:escape(globalKey),
        baseItemKey,
        BRS_UNBOXING_DB:escape(weaponClass),
        BRS_UNBOXING_DB:escape(weaponName),
        BRS_UNBOXING_DB:escape(rarity),
        BRS_UNBOXING_DB:escape(quality),
        BRS_UNBOXING_DB:escape(statsJSON),
        avgBoost
    ))
    function q:onError(err) print("[BRS UW] Save error: " .. err) end
    q:start()
end

function BRS_UW.DeleteWeaponDB(uid)
    if not BRS_UNBOXING_DB then return end
    local q = BRS_UNBOXING_DB:query("DELETE FROM bricks_server_unique_weapons WHERE uid = '" .. BRS_UNBOXING_DB:escape(uid) .. "';")
    function q:onError(err) print("[BRS UW] Delete error: " .. err) end
    q:start()
end

function BRS_UW.TransferWeaponDB(uid, newSteamID64, newGlobalKey)
    if not BRS_UNBOXING_DB then return end
    local q = BRS_UNBOXING_DB:query(string.format(
        "UPDATE bricks_server_unique_weapons SET steamid64 = '%s', global_key = '%s' WHERE uid = '%s';",
        BRS_UNBOXING_DB:escape(newSteamID64),
        BRS_UNBOXING_DB:escape(newGlobalKey),
        BRS_UNBOXING_DB:escape(uid)
    ))
    function q:onError(err) print("[BRS UW] Transfer error: " .. err) end
    q:start()
end

function BRS_UW.FetchPlayerWeaponsDB(steamid64, callback)
    if not BRS_UNBOXING_DB then callback({}) return end

    local q = BRS_UNBOXING_DB:query("SELECT * FROM bricks_server_unique_weapons WHERE steamid64 = '" .. BRS_UNBOXING_DB:escape(steamid64) .. "';")
    function q:onSuccess(data)
        callback(data or {})
    end
    function q:onError(err)
        print("[BRS UW] Fetch error: " .. err)
        callback({})
    end
    q:start()
end

-- ============================================================
-- TRADE TRANSFER: Update DB ownership + move cache + sync client
-- ============================================================
function BRS_UW.TransferWeaponOwnership(uid, globalKey, newOwner)
    if not IsValid(newOwner) then return end
    local newSteamID64 = newOwner:SteamID64()

    -- Update MySQL
    BRS_UW.TransferWeaponDB(uid, newSteamID64, globalKey)

    -- Find weapon data in ANY player's server cache
    local weaponData = nil
    for oldSteamID64, cache in pairs(BRS_UW.ServerCache) do
        if cache[globalKey] then
            weaponData = cache[globalKey]
            cache[globalKey] = nil -- remove from old owner's cache
            break
        end
    end

    -- If not in cache, fetch from DB
    if weaponData then
        -- Store in new owner's cache
        BRS_UW.ServerCache[newSteamID64] = BRS_UW.ServerCache[newSteamID64] or {}
        BRS_UW.ServerCache[newSteamID64][globalKey] = weaponData

        -- Sync to new owner's client
        BRS_UW.SyncWeaponToClient(newOwner, globalKey, weaponData)

        print("[BRS UW] Transferred " .. (weaponData.weaponName or "weapon") .. " [" .. uid .. "] to " .. newOwner:Nick())
    else
        -- Fetch from DB and sync
        if not BRS_UNBOXING_DB then return end
        local q = BRS_UNBOXING_DB:query("SELECT * FROM bricks_server_unique_weapons WHERE uid = '" .. BRS_UNBOXING_DB:escape(uid) .. "';")
        function q:onSuccess(data)
            if not data or not data[1] then return end
            local row = data[1]
            local stats = util.JSONToTable(row.stats or "{}") or {}
            BRS_UW.MigrateStats(stats)
            local fetchedData = {
                uid = row.uid,
                globalKey = row.global_key,
                baseItemKey = tonumber(row.base_item_key),
                weaponClass = row.weapon_class,
                weaponName = row.weapon_name,
                rarity = row.rarity,
                quality = row.quality,
                stats = stats,
                avgBoost = tonumber(row.avg_boost) or 0,
            }
            local wepDef = BRS_UW.WeaponByClass[row.weapon_class]
            if wepDef then fetchedData.category = wepDef.cat end

            BRS_UW.ServerCache[newSteamID64] = BRS_UW.ServerCache[newSteamID64] or {}
            BRS_UW.ServerCache[newSteamID64][globalKey] = fetchedData

            if IsValid(newOwner) then
                BRS_UW.SyncWeaponToClient(newOwner, globalKey, fetchedData)
            end

            print("[BRS UW] Transferred (DB fetch) " .. (fetchedData.weaponName or "weapon") .. " [" .. uid .. "] to " .. (IsValid(newOwner) and newOwner:Nick() or newSteamID64))
        end
        function q:onError(err) print("[BRS UW] Transfer fetch error: " .. err) end
        q:start()
    end
end

-- ============================================================
-- UNIQUE WEAPON GENERATION
-- Reads rarity/weapon info directly from the bricks config table
-- to avoid index calculation errors from mixed-category item layouts
-- ============================================================
function BRS_UW.CreateUniqueWeapon(ply, baseItemKey)
    -- Read the ACTUAL config entry for this item
    local configTable
    if BRICKS_SERVER.CONFIG and BRICKS_SERVER.CONFIG.UNBOXING and BRICKS_SERVER.CONFIG.UNBOXING.Items then
        configTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[baseItemKey]
    end
    if not configTable and BRICKS_SERVER.BASECONFIG and BRICKS_SERVER.BASECONFIG.UNBOXING then
        configTable = BRICKS_SERVER.BASECONFIG.UNBOXING.Items[baseItemKey]
    end
    if not configTable then return nil end

    -- Get weapon class from ReqInfo
    local weaponClass = configTable.ReqInfo and configTable.ReqInfo[1]
    if not weaponClass then return nil end

    -- Get rarity DIRECTLY from the config (not calculated)
    local rarityKey = configTable.Rarity or "Common"

    -- Get weapon definition from our lookup
    local weaponDef = BRS_UW.WeaponByClass[weaponClass]
    local weaponName = configTable.Name or (weaponDef and weaponDef.name) or weaponClass
    local category = weaponDef and weaponDef.cat or "Unknown"

    local uid = BRS_UW.GenerateUID()
    local globalKey = BRS_UW.MakeUniqueKey(baseItemKey, uid)
    local stats = BRS_UW.GenerateStats(rarityKey)
    local avgBoost = BRS_UW.CalcAvgBoost(stats)
    local quality = BRS_UW.GetQuality(avgBoost)

    local weaponData = {
        uid = uid,
        globalKey = globalKey,
        baseItemKey = baseItemKey,
        weaponClass = weaponClass,
        weaponName = weaponName,
        rarity = rarityKey,
        quality = quality,
        stats = stats,
        avgBoost = math.Round(avgBoost, 1),
        category = category,
    }

    -- Save to MySQL
    BRS_UW.SaveWeaponDB(uid, ply:SteamID64(), globalKey, baseItemKey, weaponClass, weaponName, rarityKey, quality, stats, avgBoost)

    -- Cache server-side
    BRS_UW.ServerCache[ply:SteamID64()] = BRS_UW.ServerCache[ply:SteamID64()] or {}
    BRS_UW.ServerCache[ply:SteamID64()][globalKey] = weaponData

    -- Sync to client
    BRS_UW.SyncWeaponToClient(ply, globalKey, weaponData)

    print(string.format("[BRS UW] Created %s %s (%s) for %s - Avg: %.1f%% [%s]",
        rarityKey, weaponName, quality, ply:Nick(), avgBoost, uid))

    return globalKey, weaponData
end

-- ============================================================
-- CLIENT SYNC
-- ============================================================
function BRS_UW.SyncWeaponToClient(ply, globalKey, data)
    net.Start("BRS_UW.SyncWeaponData")
        net.WriteString(globalKey)
        net.WriteString(util.TableToJSON(data))
    net.Send(ply)
end

function BRS_UW.SyncAllWeaponsToClient(ply)
    local steamid64 = ply:SteamID64()

    BRS_UW.FetchPlayerWeaponsDB(steamid64, function(rows)
        BRS_UW.ServerCache[steamid64] = BRS_UW.ServerCache[steamid64] or {}

        local allData = {}
        for _, row in ipairs(rows) do
            local stats = util.JSONToTable(row.stats or "{}") or {}
            BRS_UW.MigrateStats(stats)
            local weaponData = {
                uid = row.uid,
                globalKey = row.global_key,
                baseItemKey = tonumber(row.base_item_key),
                weaponClass = row.weapon_class,
                weaponName = row.weapon_name,
                rarity = row.rarity,
                quality = row.quality,
                stats = stats,
                avgBoost = tonumber(row.avg_boost) or 0,
            }

            -- Derive category from weapon class
            local wepDef = BRS_UW.WeaponByClass[row.weapon_class]
            if wepDef then
                weaponData.category = wepDef.cat
            end

            BRS_UW.ServerCache[steamid64][row.global_key] = weaponData
            allData[row.global_key] = weaponData
        end

        -- Send in batches to avoid net overflow
        local jsonStr = util.TableToJSON(allData)
        local compressed = util.Compress(jsonStr)

        if not compressed then return end

        net.Start("BRS_UW.SyncAllWeapons")
            net.WriteUInt(#compressed, 32)
            net.WriteData(compressed, #compressed)
        net.Send(ply)

        print("[BRS UW] Synced " .. table.Count(allData) .. " unique weapons to " .. ply:Nick())
    end)
end

-- ============================================================
-- HOOK INTO CASE OPENING
-- When bricks adds a weapon item to inventory, intercept and make it unique
-- ============================================================
hook.Add("Initialize", "BRS_UW_HookCaseOpening", function()
    timer.Simple(3, function()
        local playerMeta = FindMetaTable("Player")
        if not playerMeta then return end

        -- Store original function
        local originalAddItem = playerMeta.AddUnboxingInventoryItem
        if not originalAddItem then
            print("[BRS UW] WARNING: AddUnboxingInventoryItem not found!")
            return
        end

        -- Override AddUnboxingInventoryItem
        playerMeta.AddUnboxingInventoryItem = function(self, ...)
            local itemsToAdd = { ... }
            local modifiedItems = {}
            local hasUniqueWeapons = false

            for k, v in ipairs(itemsToAdd) do
                if k % 2 == 0 then continue end -- skip amount entries

                local itemKey = v
                local amount = itemsToAdd[k + 1] or 1

                -- Check if this is a weapon item (ITEM_XX format, not already unique)
                if isstring(itemKey) and string.StartWith(itemKey, "ITEM_") then

                    -- UNIQUE WEAPON BEING TRADED: already has UID suffix
                    if BRS_UW.IsUniqueWeapon(itemKey) then
                        -- Transfer ownership in DB and cache
                        local baseNum, uid = BRS_UW.ParseUniqueKey(itemKey)
                        if uid then
                            BRS_UW.TransferWeaponOwnership(uid, itemKey, self)
                        end
                        -- Pass through to original (key stays the same)
                        table.insert(modifiedItems, itemKey)
                        table.insert(modifiedItems, amount)
                        continue
                    end

                    -- NON-UNIQUE WEAPON: convert to unique on unbox
                    local baseNum = tonumber(string.Replace(itemKey, "ITEM_", ""))

                    if baseNum then
                        local configTable
                        if BRICKS_SERVER.CONFIG and BRICKS_SERVER.CONFIG.UNBOXING and BRICKS_SERVER.CONFIG.UNBOXING.Items then
                            configTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[baseNum]
                        end
                        if not configTable and BRICKS_SERVER.BASECONFIG and BRICKS_SERVER.BASECONFIG.UNBOXING then
                            configTable = BRICKS_SERVER.BASECONFIG.UNBOXING.Items[baseNum]
                        end

                        -- Only convert PermWeapon items to unique
                        if configTable and configTable.Type == "PermWeapon" then
                            -- Create unique weapon(s) for each amount
                            for i = 1, (amount or 1) do
                                local uniqueKey, weaponData = BRS_UW.CreateUniqueWeapon(self, baseNum)
                                if uniqueKey then
                                    table.insert(modifiedItems, uniqueKey)
                                    table.insert(modifiedItems, 1) -- unique weapons always count 1
                                    hasUniqueWeapons = true
                                end
                            end
                            continue -- skip adding original item
                        end
                    end
                end

                -- Non-weapon items pass through unchanged
                table.insert(modifiedItems, itemKey)
                table.insert(modifiedItems, amount)
            end

            -- Call original with modified items
            if #modifiedItems > 0 then
                originalAddItem(self, unpack(modifiedItems))
            end
        end

        print("[BRS UW] AddUnboxingInventoryItem hook installed")
    end)
end)

-- ============================================================
-- SYNC WEAPONS ON PLAYER JOIN
-- ============================================================
hook.Add("PlayerInitialSpawn", "BRS_UW_SyncOnJoin", function(ply)
    -- Delay to let bricks load inventory first
    timer.Simple(5, function()
        if not IsValid(ply) then return end
        BRS_UW.SyncAllWeaponsToClient(ply)
    end)
end)

-- ============================================================
-- APPLY STAT BOOSTS WHEN WEAPON IS EQUIPPED
-- ============================================================
hook.Add("WeaponEquip", "BRS_UW_ApplyStatBoosts", function(wep, ply)
    if not IsValid(wep) or not IsValid(ply) then return end

    -- Delay slightly to let weapon initialize
    timer.Simple(0.1, function()
        if not IsValid(wep) or not IsValid(ply) then return end
        BRS_UW.ApplyBoostsToWeapon(ply, wep)
    end)
end)

-- Also apply on PlayerLoadout (for permanent weapons)
hook.Add("PlayerLoadout", "BRS_UW_ApplyOnLoadout", function(ply)
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        for _, wep in ipairs(ply:GetWeapons()) do
            BRS_UW.ApplyBoostsToWeapon(ply, wep)
        end
    end)
end)

function BRS_UW.ApplyBoostsToWeapon(ply, wep)
    if not IsValid(wep) or not IsValid(ply) then return end
    if wep.BRS_UW_Boosted then return end -- already boosted

    local wepClass = wep:GetClass()
    local steamid64 = ply:SteamID64()
    local cache = BRS_UW.ServerCache[steamid64]
    if not cache then return end

    -- Find the equipped unique weapon matching this class
    local inventory = ply:GetUnboxingInventory()
    local inventoryData = ply:GetUnboxingInventoryData()

    for globalKey, uwData in pairs(cache) do
        if uwData.weaponClass ~= wepClass then continue end
        if not inventory[globalKey] then continue end
        if not inventoryData[globalKey] or not inventoryData[globalKey].Equipped then continue end

        -- This unique weapon is equipped - apply boosts
        local stats = uwData.stats
        if not stats then continue end

        -- Save originals
        wep.BRS_UW_OriginalStats = wep.BRS_UW_OriginalStats or {}

        -- DAMAGE boost (capped at +100% = double damage)
        if stats.dmg and wep.Primary and wep.Primary.Damage then
            wep.BRS_UW_OriginalStats.Damage = wep.Primary.Damage
            wep.Primary.Damage = math.Round(wep.Primary.Damage * (1 + math.min(stats.dmg, 100) / 100))
        end

        -- ACCURACY boost (reduce spread - lower is better, max 50% reduction)
        if stats.acc and wep.Primary and wep.Primary.Spread then
            wep.BRS_UW_OriginalStats.Spread = wep.Primary.Spread
            wep.Primary.Spread = wep.Primary.Spread * (1 - math.min(stats.acc, 100) / 100 * 0.5)
        end

        -- CONTROL boost (reduce recoil - lower is better, max 50% reduction)
        if stats.ctrl and wep.Primary and wep.Primary.Recoil then
            wep.BRS_UW_OriginalStats.Recoil = wep.Primary.Recoil
            wep.Primary.Recoil = wep.Primary.Recoil * (1 - math.min(stats.ctrl, 100) / 100 * 0.5)
        end

        -- RPM boost (capped at +100%)
        if stats.rpm and wep.Primary and wep.Primary.RPM then
            wep.BRS_UW_OriginalStats.RPM = wep.Primary.RPM
            wep.Primary.RPM = math.Round(wep.Primary.RPM * (1 + math.min(stats.rpm, 100) / 100))
            -- Update delay based on RPM
            if wep.Primary.RPM > 0 then
                wep.Primary.Delay = 60 / wep.Primary.RPM
            end
        end

        -- MAGAZINE boost (clip size, capped at +100% = double mag)
        if stats.mag and wep.Primary and wep.Primary.ClipSize then
            wep.BRS_UW_OriginalStats.ClipSize = wep.Primary.ClipSize
            local newClip = math.Round(wep.Primary.ClipSize * (1 + math.min(stats.mag, 100) / 100))
            wep.Primary.ClipSize = newClip
        end

        wep.BRS_UW_Boosted = true
        wep.BRS_UW_GlobalKey = globalKey
        wep.BRS_UW_Data = uwData

        break -- only apply one unique weapon per class
    end
end

-- ============================================================
-- HANDLE INSPECT REQUEST
-- ============================================================
net.Receive("BRS_UW.RequestInspect", function(len, ply)
    local globalKey = net.ReadString()
    local steamid64 = ply:SteamID64()
    local cache = BRS_UW.ServerCache[steamid64]

    if cache and cache[globalKey] then
        net.Start("BRS_UW.InspectResult")
            net.WriteString(globalKey)
            net.WriteString(util.TableToJSON(cache[globalKey]))
        net.Send(ply)
    end
end)

-- ============================================================
-- CLEANUP ON DISCONNECT
-- ============================================================
hook.Add("PlayerDisconnected", "BRS_UW_Cleanup", function(ply)
    BRS_UW.ServerCache[ply:SteamID64()] = nil
end)

print("[BRS UW] Server system loaded")
