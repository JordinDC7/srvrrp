-- ============================================================
-- UNIQUE WEAPONS SYSTEM - Server
-- Handles: MySQL storage, unique weapon generation, stat application, sync
-- ============================================================
if not SERVER then return end

BRS_UW = BRS_UW or {}
BRS_UW.ServerCache = BRS_UW.ServerCache or {} -- steamid64 -> { [globalKey] = data }

-- Migrate old stat keys for existing weapons
-- mob → mag, acc → spd, ctrl → removed
function BRS_UW.MigrateStats(stats)
    if not stats then return stats end
    if stats.mob and not stats.mag then
        stats.mag = stats.mob
        stats.mob = nil
    end
    if stats.acc and not stats.spd then
        stats.spd = stats.acc
        stats.acc = nil
    end
    stats.ctrl = nil -- M9K has no modifiable recoil

    -- Migrate: add VEL stat for weapons that don't have it
    -- Derived from average of existing stats with ±15% variance
    if not stats.vel then
        local sum, cnt = 0, 0
        for _, k in ipairs({"dmg", "spd", "rpm", "mag"}) do
            if stats[k] and stats[k] > 0 then
                sum = sum + stats[k]
                cnt = cnt + 1
            end
        end
        if cnt > 0 then
            stats.vel = math.Round(math.Clamp(sum / cnt * math.Rand(0.85, 1.15), 1, 125), 1)
        else
            stats.vel = 0
        end
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
    local quality = BRS_UW.RollQuality(rarityKey)
    local stats = BRS_UW.GenerateStats(rarityKey, quality)
    local avgBoost = BRS_UW.CalcAvgBoost(stats)

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
-- Queue individual weapon syncs and batch them to prevent net overflow
BRS_UW._SyncQueue = BRS_UW._SyncQueue or {}

function BRS_UW.SyncWeaponToClient(ply, globalKey, data)
    local sid = ply:SteamID64()
    BRS_UW._SyncQueue[sid] = BRS_UW._SyncQueue[sid] or { ply = ply, weapons = {} }
    BRS_UW._SyncQueue[sid].weapons[globalKey] = data

    -- Debounce: flush queue after a short delay
    if not BRS_UW._SyncQueue[sid].timerActive then
        BRS_UW._SyncQueue[sid].timerActive = true
        timer.Simple(0.1, function()
            BRS_UW.FlushSyncQueue(sid)
        end)
    end
end

function BRS_UW.FlushSyncQueue(sid)
    local queueData = BRS_UW._SyncQueue[sid]
    if not queueData then return end
    BRS_UW._SyncQueue[sid] = nil

    local ply = queueData.ply
    if not IsValid(ply) then return end

    local count = table.Count(queueData.weapons)
    if count == 0 then return end

    if count <= 3 then
        -- Small batch: send individually (cheaper than compress)
        for gk, d in pairs(queueData.weapons) do
            net.Start("BRS_UW.SyncWeaponData")
                net.WriteString(gk)
                net.WriteString(util.TableToJSON(d))
            net.Send(ply)
        end
    else
        -- Large batch: compress and send via SyncAllWeapons channel
        local jsonStr = util.TableToJSON(queueData.weapons)
        local compressed = util.Compress(jsonStr)
        if not compressed then return end

        net.Start("BRS_UW.SyncAllWeapons")
            net.WriteUInt(#compressed, 32)
            net.WriteData(compressed, #compressed)
        net.Send(ply)
    end

    print("[BRS UW] Flushed " .. count .. " weapon sync(s) to " .. ply:Nick())
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
    -- Apply boosts with staggered attempts to catch late-loading weapons
    for _, delay in ipairs({0.5, 1.5, 3.0}) do
        timer.Simple(delay, function()
            if not IsValid(ply) then return end
            for _, wep in ipairs(ply:GetWeapons()) do
                BRS_UW.ApplyBoostsToWeapon(ply, wep)
            end
        end)
    end
end)

-- Also catch weapon switching / re-equipping
hook.Add("PlayerSwitchWeapon", "BRS_UW_ApplyOnSwitch", function(ply, oldWep, newWep)
    if not IsValid(newWep) or not IsValid(ply) then return end
    timer.Simple(0.05, function()
        if not IsValid(newWep) or not IsValid(ply) then return end
        BRS_UW.ApplyBoostsToWeapon(ply, newWep)
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

        -- CRITICAL: Deep copy Primary table to avoid modifying shared class reference
        -- M9K weapons share their Primary table across all instances by default
        if wep.Primary then
            local origPrimary = wep.Primary
            wep.Primary = {}
            for k, v in pairs(origPrimary) do
                wep.Primary[k] = v
            end
        else
            print("[BRS UW] WARNING: " .. wepClass .. " has no Primary table!")
            continue
        end

        -- Save originals for reference
        wep.BRS_UW_OriginalStats = {
            Damage = wep.Primary.Damage,
            Spread = wep.Primary.Spread,
            RPM = wep.Primary.RPM,
            ClipSize = wep.Primary.ClipSize,
        }

        local applied = {}

        -- DAMAGE boost (scales with stat value, no cap for Ascended)
        if stats.dmg and stats.dmg > 0 and wep.Primary.Damage then
            local orig = wep.Primary.Damage
            wep.Primary.Damage = math.Round(orig * (1 + stats.dmg / 100))
            table.insert(applied, "DMG:" .. orig .. "->" .. wep.Primary.Damage)
        end

        -- ACCURACY boost (reduce spread - lower spread = more accurate)
        if stats.spd and stats.spd > 0 and wep.Primary.Spread then
            local orig = wep.Primary.Spread
            local newSpread = orig * (1 - stats.spd / 100 * 0.5)
            wep.Primary.Spread = math.max(newSpread, orig * 0.1) -- floor at 10% of original
            table.insert(applied, "SPD:" .. string.format("%.4f", orig) .. "->" .. string.format("%.4f", wep.Primary.Spread))
        end

        -- RPM boost (TRUE percentage boost - no caps)
        if stats.rpm and stats.rpm > 0 and wep.Primary.RPM then
            local orig = wep.Primary.RPM
            local rpmMultiplier = 1 + stats.rpm / 100
            local newRPM = math.Round(orig * rpmMultiplier)
            local newDelay = 60 / newRPM

            wep.Primary.RPM = newRPM
            wep.Primary.Delay = newDelay

            -- Network values for client-side sync
            wep:SetNW2Float("BRS_UW_RPMMultiplier", rpmMultiplier)
            wep:SetNW2Float("BRS_UW_OrigDelay", 60 / orig)
            wep:SetNW2Float("BRS_UW_OrigRPM", orig)

            -- Scale down recoil to compensate for faster fire rate
            local recoilScale = 1 / math.sqrt(rpmMultiplier)
            if wep.Primary.Recoil then
                wep.BRS_UW_OrigRecoil = wep.Primary.Recoil
                wep.Primary.Recoil = wep.Primary.Recoil * recoilScale
            end
            if wep.Primary.KickUp then
                wep.BRS_UW_OrigKickUp = wep.Primary.KickUp
                wep.Primary.KickUp = wep.Primary.KickUp * recoilScale
            end
            if wep.Primary.KickDown then
                wep.BRS_UW_OrigKickDown = wep.Primary.KickDown
                wep.Primary.KickDown = wep.Primary.KickDown * recoilScale
            end
            if wep.Primary.KickHorizontal then
                wep.BRS_UW_OrigKickH = wep.Primary.KickHorizontal
                wep.Primary.KickHorizontal = wep.Primary.KickHorizontal * recoilScale
            end

            table.insert(applied, "RPM:" .. orig .. "->" .. newRPM .. " (" .. string.format("%.1f", stats.rpm) .. "% boost)")
        end

        -- MAGAZINE boost (clip size)
        if stats.mag and stats.mag > 0 and wep.Primary.ClipSize then
            local orig = wep.Primary.ClipSize
            local newClip = math.Round(orig * (1 + stats.mag / 100))
            wep.Primary.ClipSize = newClip
            -- Also update DefaultClip if it exists (M9K uses this)
            if wep.Primary.DefaultClip then
                wep.Primary.DefaultClip = newClip
            end
            table.insert(applied, "MAG:" .. orig .. "->" .. newClip)
        end

        wep.BRS_UW_Boosted = true
        wep.BRS_UW_GlobalKey = globalKey
        wep.BRS_UW_Data = uwData

        print("[BRS UW] Applied boosts to " .. ply:Nick() .. "'s " .. uwData.weaponName .. " (" .. uwData.rarity .. " " .. uwData.quality .. "): " .. table.concat(applied, ", "))

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
-- HANDLE DELETE ITEMS (bulk - supports ALL item types)
-- ============================================================
util.AddNetworkString("BRS_UW.DeleteItems")
util.AddNetworkString("BRS_UW.DeleteItemsConfirm")
net.Receive("BRS_UW.DeleteItems", function(len, ply)
    local count = net.ReadUInt(16)
    if not count or count < 1 or count > 500 then return end

    local keysToDelete = {}
    for i = 1, count do
        local globalKey = net.ReadString()
        if globalKey and (string.StartWith(globalKey, "ITEM_") or string.StartWith(globalKey, "CASE_") or string.StartWith(globalKey, "KEY_")) then
            table.insert(keysToDelete, globalKey)
        end
    end

    if #keysToDelete == 0 then return end

    local steamid64 = ply:SteamID64()
    local cache = BRS_UW.ServerCache[steamid64] or {}

    -- Get inventory ONCE, modify in memory, then sync ONCE
    -- This prevents net overflow from calling SetUnboxingInventory per item
    local inventory = ply:GetUnboxingInventory()
    local inventoryData = ply:GetUnboxingInventoryData()
    local inventoryDataChanged = false
    local deleteCount = 0

    for _, globalKey in ipairs(keysToDelete) do
        if inventory[globalKey] then
            -- Unequip if needed before removing
            if string.StartWith(globalKey, "ITEM_") and inventoryData[globalKey] and inventoryData[globalKey].Equipped then
                local baseNum = BRS_UW.IsUniqueWeapon(globalKey) and BRS_UW.ParseUniqueKey(globalKey) or tonumber(string.Replace(globalKey, "ITEM_", ""))
                local configItemTable = baseNum and BRICKS_SERVER.CONFIG.UNBOXING.Items[baseNum]
                if configItemTable then
                    local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type]
                    if devConfigTable and devConfigTable.UnEquipFunction then
                        devConfigTable.UnEquipFunction(ply, configItemTable.ReqInfo)
                    end
                end
                inventoryData[globalKey] = nil
                inventoryDataChanged = true
            end

            inventory[globalKey] = nil
            deleteCount = deleteCount + 1
        end

        -- If unique weapon, also clean MySQL + cache
        if BRS_UW.IsUniqueWeapon(globalKey) then
            local baseNum, uid = BRS_UW.ParseUniqueKey(globalKey)
            if uid then
                BRS_UW.DeleteWeaponDB(uid)
            end
            if cache[globalKey] then
                cache[globalKey] = nil
            end
        end
    end

    -- Single inventory sync (ONE net message instead of N)
    ply:SetUnboxingInventory(inventory)

    if inventoryDataChanged then
        ply:SetUnboxingInventoryData(inventoryData)
    end

    BRICKS_SERVER.Func.SendTopNotification(ply, "Deleted " .. deleteCount .. " item(s)", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green)
    print("[BRS UW] " .. ply:Nick() .. " deleted " .. deleteCount .. " items")

    -- Send confirmation so client refreshes immediately
    net.Start("BRS_UW.DeleteItemsConfirm")
        net.WriteUInt(deleteCount, 16)
    net.Send(ply)
end)

-- ============================================================
-- ADMIN: BULK DELETE FROM PLAYER INVENTORY
-- ============================================================
util.AddNetworkString("BRS_UW.AdminDeleteItems")
net.Receive("BRS_UW.AdminDeleteItems", function(len, ply)
    if not BRICKS_SERVER.Func.HasAdminAccess(ply) then return end

    local targetSteamID64 = net.ReadString()
    local count = net.ReadUInt(16)
    if not count or count < 1 or count > 500 then return end

    local keysToDelete = {}
    for i = 1, count do
        local globalKey = net.ReadString()
        if globalKey then
            table.insert(keysToDelete, globalKey)
        end
    end

    if #keysToDelete == 0 then return end

    local targetPly = player.GetBySteamID64(targetSteamID64)
    local deleteCount = 0

    if IsValid(targetPly) then
        -- Player is online - modify inventory in memory, sync once
        local cache = BRS_UW.ServerCache[targetSteamID64] or {}
        local inventory = targetPly:GetUnboxingInventory()

        for _, globalKey in ipairs(keysToDelete) do
            if inventory[globalKey] then
                inventory[globalKey] = nil
                deleteCount = deleteCount + 1
            end

            if BRS_UW.IsUniqueWeapon(globalKey) then
                local baseNum, uid = BRS_UW.ParseUniqueKey(globalKey)
                if uid then BRS_UW.DeleteWeaponDB(uid) end
                if cache[globalKey] then cache[globalKey] = nil end
            end
        end

        targetPly:SetUnboxingInventory(inventory)
    else
        -- Player is offline - update DB directly
        BRICKS_SERVER.UNBOXING.Func.FetchInventoryDB(targetSteamID64, function(data)
            local inventoryTable = util.JSONToTable((data or {}).inventory or "") or {}

            for _, globalKey in ipairs(keysToDelete) do
                if inventoryTable[globalKey] then
                    inventoryTable[globalKey] = nil

                    if BRS_UW.IsUniqueWeapon(globalKey) then
                        local baseNum, uid = BRS_UW.ParseUniqueKey(globalKey)
                        if uid then BRS_UW.DeleteWeaponDB(uid) end
                    end
                end
            end

            BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB(targetSteamID64, inventoryTable)
        end)
        deleteCount = #keysToDelete
    end

    BRICKS_SERVER.Func.SendTopNotification(ply, "Admin deleted " .. deleteCount .. " item(s) from player", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green)
    print("[BRS UW] ADMIN " .. ply:Nick() .. " deleted " .. deleteCount .. " items from " .. targetSteamID64)

    -- Refresh admin panel
    net.Start("BRS_UW.DeleteItemsConfirm")
        net.WriteUInt(deleteCount, 16)
    net.Send(ply)
end)

-- ============================================================
-- CLEANUP ON DISCONNECT
-- ============================================================
hook.Add("PlayerDisconnected", "BRS_UW_Cleanup", function(ply)
    BRS_UW.ServerCache[ply:SteamID64()] = nil
end)

print("[BRS UW] Server system loaded")

-- ============================================================
-- DEBUG COMMANDS
-- ============================================================
concommand.Add("brs_uw_debug", function(ply)
    if not IsValid(ply) then return end
    if not BRICKS_SERVER.Func.HasAdminAccess(ply) then return end

    local steamid64 = ply:SteamID64()
    local cache = BRS_UW.ServerCache[steamid64]
    local inv = ply:GetUnboxingInventory()
    local invData = ply:GetUnboxingInventoryData()

    print("=== BRS UW DEBUG for " .. ply:Nick() .. " ===")
    print("Cache entries: " .. (cache and table.Count(cache) or "NIL"))
    print("Inventory items: " .. (inv and table.Count(inv) or "NIL"))

    if cache then
        for gk, uwData in pairs(cache) do
            local equipped = invData[gk] and invData[gk].Equipped
            print("  " .. gk .. " | class=" .. (uwData.weaponClass or "?") .. " | " .. (uwData.rarity or "?") .. " " .. (uwData.quality or "?") .. " | equipped=" .. tostring(equipped))
            if uwData.stats then
                local parts = {}
                for statKey, val in pairs(uwData.stats) do
                    table.insert(parts, statKey .. "=" .. string.format("%.1f", val))
                end
                print("    stats: " .. table.concat(parts, ", "))
            end
        end
    end

    -- Check current weapons
    print("--- Current weapons ---")
    for _, wep in ipairs(ply:GetWeapons()) do
        local boosted = wep.BRS_UW_Boosted and "YES" or "no"
        local dmg = wep.Primary and wep.Primary.Damage or "?"
        local spread = wep.Primary and wep.Primary.Spread or "?"
        local rpm = wep.Primary and wep.Primary.RPM or "?"
        local clip = wep.Primary and wep.Primary.ClipSize or "?"
        local origDmg = wep.BRS_UW_OriginalStats and wep.BRS_UW_OriginalStats.Damage or "?"
        print("  " .. wep:GetClass() .. " | boosted=" .. boosted .. " | DMG:" .. tostring(origDmg) .. "->" .. tostring(dmg) .. " | SPD:" .. tostring(spread) .. " | RPM:" .. tostring(rpm) .. " | MAG:" .. tostring(clip))
    end

    -- Try forcing application now
    print("--- Forcing boost application ---")
    for _, wep in ipairs(ply:GetWeapons()) do
        -- Restore original stats before re-applying to avoid stacking
        if wep.BRS_UW_OriginalStats and wep.Primary then
            for k, v in pairs(wep.BRS_UW_OriginalStats) do
                wep.Primary[k] = v
            end
            -- Also restore RPM-derived delay
            if wep.Primary.RPM and wep.Primary.RPM > 0 then
                wep.Primary.Delay = 60 / wep.Primary.RPM
            end
        end
        -- Restore recoil values
        if wep.BRS_UW_OrigRecoil then wep.Primary.Recoil = wep.BRS_UW_OrigRecoil; wep.BRS_UW_OrigRecoil = nil end
        if wep.BRS_UW_OrigKickUp then wep.Primary.KickUp = wep.BRS_UW_OrigKickUp; wep.BRS_UW_OrigKickUp = nil end
        if wep.BRS_UW_OrigKickDown then wep.Primary.KickDown = wep.BRS_UW_OrigKickDown; wep.BRS_UW_OrigKickDown = nil end
        if wep.BRS_UW_OrigKickH then wep.Primary.KickHorizontal = wep.BRS_UW_OrigKickH; wep.BRS_UW_OrigKickH = nil end
        wep.BRS_UW_Boosted = nil -- reset so it re-applies
        BRS_UW.ApplyBoostsToWeapon(ply, wep)
    end
end)
