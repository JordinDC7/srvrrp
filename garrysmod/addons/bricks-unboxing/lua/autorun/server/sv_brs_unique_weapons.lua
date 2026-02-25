--[[
    UNIQUE WEAPON SYSTEM - Server Side (v3 - robust hooking)
    Handles: MySQL storage, unique weapon creation on unbox,
    stat booster application, network sync to clients
    
    Runs PARALLEL to bricks inventory. Bricks handles inventory
    normally; we track unique weapon data (UIDs, stat boosters)
    separately and apply boosters when weapons are equipped.
]]--

if not SERVER then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.Cache = BRS_WEAPONS.Cache or {}
BRS_WEAPONS.PlayerWeapons = BRS_WEAPONS.PlayerWeapons or {}

-- ============================================================
-- DATABASE SETUP
-- ============================================================

local function WaitForDB(callback)
    if BRS_UNBOXING_DB then
        callback()
        return
    end
    timer.Create("BRS_UniqueWeapons_WaitDB", 1, 60, function()
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

-- Create our unique weapons table
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
    ]], function()
        print("[BRS UniqueWeapons] Database table validated!")
    end)
end)

-- ============================================================
-- CRUD OPERATIONS
-- ============================================================

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

    local weaponData = {
        weapon_uid = uid,
        owner_steamid64 = steamID64,
        item_index = itemIndex,
        weapon_class = weaponClass,
        weapon_name = weaponName,
        rarity = rarity,
        stat_boosters = statBoosters,
        created_at = os.time()
    }

    BRS_WEAPONS.Cache[uid] = weaponData
    BRS_WEAPONS.PlayerWeapons[steamID64] = BRS_WEAPONS.PlayerWeapons[steamID64] or {}
    BRS_WEAPONS.PlayerWeapons[steamID64][uid] = weaponData

    return weaponData
end

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
            BRS_WEAPONS.PlayerWeapons[steamID64] = weapons
            if callback then callback(weapons) end
        end
    )
end

function BRS_WEAPONS.TransferWeapon(uid, newSteamID64)
    QueryDB(string.format(
        "UPDATE bricks_server_unboxing_unique_weapons SET owner_steamid64 = '%s' WHERE weapon_uid = '%s';",
        EscapeStr(newSteamID64), EscapeStr(uid)
    ))
    if BRS_WEAPONS.Cache[uid] then
        BRS_WEAPONS.Cache[uid].owner_steamid64 = newSteamID64
    end
end

function BRS_WEAPONS.DeleteWeapon(uid)
    QueryDB("DELETE FROM bricks_server_unboxing_unique_weapons WHERE weapon_uid = '" .. EscapeStr(uid) .. "';")
    BRS_WEAPONS.Cache[uid] = nil
end

-- ============================================================
-- NETWORKING
-- ============================================================
util.AddNetworkString("BRS.UniqueWeapons.Sync")
util.AddNetworkString("BRS.UniqueWeapons.NewWeapon")
util.AddNetworkString("BRS.UniqueWeapons.Inspect")

function BRS_WEAPONS.SyncToClient(ply)
    BRS_WEAPONS.FetchPlayerWeapons(ply:SteamID64(), function(weapons)
        ply.BRS_UNIQUE_WEAPONS = weapons

        local jsonData = util.TableToJSON(weapons)
        local compressed = util.Compress(jsonData)
        if not compressed then return end

        net.Start("BRS.UniqueWeapons.Sync")
            net.WriteUInt(#compressed, 32)
            net.WriteData(compressed, #compressed)
        net.Send(ply)

        print("[BRS UniqueWeapons] Synced " .. table.Count(weapons) .. " weapons to " .. ply:Nick())
    end)
end

function BRS_WEAPONS.NotifyNewWeapon(ply, weaponData)
    net.Start("BRS.UniqueWeapons.NewWeapon")
        net.WriteString(util.TableToJSON(weaponData))
    net.Send(ply)
end

-- Sync on join
hook.Add("PlayerInitialSpawn", "BRS_UniqueWeapons_InitSync", function(ply)
    timer.Simple(8, function()
        if IsValid(ply) then
            BRS_WEAPONS.SyncToClient(ply)
        end
    end)
end)

-- Inspect requests
net.Receive("BRS.UniqueWeapons.Inspect", function(len, ply)
    local uid = net.ReadString()
    local weaponData = BRS_WEAPONS.Cache[uid]
    if not weaponData then return end

    net.Start("BRS.UniqueWeapons.Inspect")
        net.WriteString(util.TableToJSON(weaponData))
    net.Send(ply)
end)

-- ============================================================
-- CASE OPENING HOOK (v3 - ROBUST)
-- Multiple strategies to intercept weapon creation:
-- 1. Hook Player metatable AddUnboxingInventoryItem (if it exists)
-- 2. Hook BRICKS_SERVER.UNBOXING.Func.AddInventoryItem (if it exists)
-- 3. Hook the inventory update DB function to catch writes
-- 4. Periodically scan player inventories for new weapons
-- ============================================================

local _hookInstalled = false

-- The core function that creates a unique weapon record
local function OnWeaponUnboxed(ply, globalKey, configItem)
    if not IsValid(ply) then return end
    if not configItem then return end
    if configItem.Type ~= "PermWeapon" and configItem.Type ~= "Weapon" then return end

    local weaponClass = configItem.ReqInfo and configItem.ReqInfo[1] or ""
    local weaponName = configItem.Name or "Unknown"
    local rarity = configItem.Rarity or "Common"
    local itemKey = tonumber(string.match(tostring(globalKey), "ITEM_(%d+)")) or 0

    local uid = BRS_WEAPONS.GenerateUID()
    local boosters = BRS_WEAPONS.RollStatBoosters(rarity)

    local weaponData = BRS_WEAPONS.SaveWeapon(
        uid, ply:SteamID64(), itemKey,
        weaponClass, weaponName, rarity, boosters
    )

    BRS_WEAPONS.NotifyNewWeapon(ply, weaponData)

    print(string.format(
        "[BRS UniqueWeapons] %s unboxed %s [%s] UID:%s with %d boosters (DMG:%.1f%% ACC:%.1f%% MAG:%.1f%% RPM:%.1f%% SPD:%.1f%%)",
        ply:Nick(), weaponName, rarity, uid, table.Count(boosters),
        (boosters.DMG or 0) * 100, (boosters.ACC or 0) * 100,
        (boosters.MAG or 0) * 100, (boosters.RPM or 0) * 100,
        (boosters.SPD or 0) * 100
    ))
end

-- Look up a config item from a global key
local function GetConfigItem(globalKey)
    if not BRICKS_SERVER or not BRICKS_SERVER.CONFIG then return nil end
    if not BRICKS_SERVER.CONFIG.UNBOXING or not BRICKS_SERVER.CONFIG.UNBOXING.Items then return nil end

    local itemKey = tonumber(string.match(tostring(globalKey), "ITEM_(%d+)"))
    if not itemKey then return nil end

    return BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey]
end

-- STRATEGY 1: Wrap Player:AddUnboxingInventoryItem on the metatable
local function TryHookPlayerMeta()
    local meta = FindMetaTable("Player")
    if not meta then return false end
    if not meta.AddUnboxingInventoryItem then return false end
    if meta._BRS_ORIG_AddUnboxingInventoryItem then return true end -- already hooked

    meta._BRS_ORIG_AddUnboxingInventoryItem = meta.AddUnboxingInventoryItem
    meta.AddUnboxingInventoryItem = function(self, ...)
        -- Call original first
        meta._BRS_ORIG_AddUnboxingInventoryItem(self, ...)

        -- Process weapon additions
        local args = { ... }
        for i = 1, #args, 2 do
            local globalKey = args[i]
            local amount = args[i + 1] or 1
            if isstring(globalKey) and string.StartWith(globalKey, "ITEM_") then
                local configItem = GetConfigItem(globalKey)
                if configItem then
                    for n = 1, amount do
                        OnWeaponUnboxed(self, globalKey, configItem)
                    end
                end
            end
        end
    end

    print("[BRS UniqueWeapons] HOOK INSTALLED via Player metatable!")
    return true
end

-- STRATEGY 2: Wrap BRICKS_SERVER.UNBOXING.Func inventory functions
local function TryHookBricksFunc()
    if not BRICKS_SERVER then return false end
    if not BRICKS_SERVER.UNBOXING then return false end
    if not BRICKS_SERVER.UNBOXING.Func then return false end

    -- Try AddInventoryItem
    local funcNames = {
        "AddInventoryItem",
        "AddItem",
        "GiveItem",
        "AddUnboxingInventoryItem"
    }

    for _, funcName in ipairs(funcNames) do
        local origFunc = BRICKS_SERVER.UNBOXING.Func[funcName]
        if origFunc and not BRICKS_SERVER.UNBOXING.Func["_BRS_ORIG_" .. funcName] then
            BRICKS_SERVER.UNBOXING.Func["_BRS_ORIG_" .. funcName] = origFunc
            BRICKS_SERVER.UNBOXING.Func[funcName] = function(ply, ...)
                origFunc(ply, ...)

                if IsValid(ply) then
                    local args = { ... }
                    for i = 1, #args, 2 do
                        local globalKey = args[i]
                        local amount = args[i + 1] or 1
                        if isstring(globalKey) and string.StartWith(globalKey, "ITEM_") then
                            local configItem = GetConfigItem(globalKey)
                            if configItem then
                                for n = 1, amount do
                                    OnWeaponUnboxed(ply, globalKey, configItem)
                                end
                            end
                        end
                    end
                end
            end
            print("[BRS UniqueWeapons] HOOK INSTALLED via BRICKS_SERVER.UNBOXING.Func." .. funcName .. "!")
            return true
        end
    end

    return false
end

-- STRATEGY 3: Hook the inventory DB update to detect new weapons added
local function TryHookInventoryDB()
    if not BRICKS_SERVER then return false end
    if not BRICKS_SERVER.UNBOXING then return false end
    if not BRICKS_SERVER.UNBOXING.Func then return false end
    if not BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB then return false end
    if BRICKS_SERVER.UNBOXING.Func._BRS_ORIG_UpdateInventoryDB then return true end

    BRICKS_SERVER.UNBOXING.Func._BRS_ORIG_UpdateInventoryDB = BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB
    BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB = function(steamID64, inventory)
        -- Call original
        BRICKS_SERVER.UNBOXING.Func._BRS_ORIG_UpdateInventoryDB(steamID64, inventory)

        -- Scan inventory for weapons we haven't tracked yet
        if not inventory then return end

        local ply = nil
        for _, p in ipairs(player.GetAll()) do
            if p:SteamID64() == steamID64 then
                ply = p
                break
            end
        end
        if not IsValid(ply) then return end

        -- Track known items to detect new ones
        ply._BRS_KNOWN_ITEMS = ply._BRS_KNOWN_ITEMS or {}

        for globalKey, amount in pairs(inventory) do
            if isstring(globalKey) and string.StartWith(globalKey, "ITEM_") then
                local configItem = GetConfigItem(globalKey)
                if configItem and (configItem.Type == "PermWeapon" or configItem.Type == "Weapon") then
                    local prevAmount = ply._BRS_KNOWN_ITEMS[globalKey] or 0
                    local currentAmount = tonumber(amount) or 0

                    if currentAmount > prevAmount then
                        local newCount = currentAmount - prevAmount
                        for n = 1, newCount do
                            OnWeaponUnboxed(ply, globalKey, configItem)
                        end
                    end

                    ply._BRS_KNOWN_ITEMS[globalKey] = currentAmount
                end
            end
        end
    end

    print("[BRS UniqueWeapons] HOOK INSTALLED via UpdateInventoryDB wrapper!")
    return true
end

-- Master hook installer - tries all strategies repeatedly
timer.Create("BRS_UniqueWeapons_InstallHook", 2, 60, function()
    if _hookInstalled then
        timer.Remove("BRS_UniqueWeapons_InstallHook")
        return
    end

    -- Debug: print what's available
    local hasBricks = BRICKS_SERVER ~= nil
    local hasUnboxing = hasBricks and BRICKS_SERVER.UNBOXING ~= nil
    local hasFunc = hasUnboxing and BRICKS_SERVER.UNBOXING.Func ~= nil
    local hasMeta = FindMetaTable("Player").AddUnboxingInventoryItem ~= nil

    -- Try strategies in order of preference
    if TryHookPlayerMeta() then
        _hookInstalled = true
    elseif TryHookBricksFunc() then
        _hookInstalled = true
    elseif TryHookInventoryDB() then
        _hookInstalled = true
    else
        -- Print debug info every 10 seconds (every 5th attempt)
        local attempts = (BRS_WEAPONS._hookAttempts or 0) + 1
        BRS_WEAPONS._hookAttempts = attempts
        if attempts % 5 == 1 then
            print("[BRS UniqueWeapons] Hook attempt #" .. attempts .. " - waiting for bricks...")
            print("  BRICKS_SERVER: " .. tostring(hasBricks))
            print("  .UNBOXING: " .. tostring(hasUnboxing))
            print("  .Func: " .. tostring(hasFunc))
            print("  Player:AddUnboxingInventoryItem: " .. tostring(hasMeta))
            if hasFunc then
                print("  Available Func keys:")
                for k, v in pairs(BRICKS_SERVER.UNBOXING.Func) do
                    if isfunction(v) then
                        print("    " .. k .. "()")
                    end
                end
            end
        end
    end

    if _hookInstalled then
        timer.Remove("BRS_UniqueWeapons_InstallHook")
    end
end)

-- ============================================================
-- STAT BOOSTER APPLICATION
-- ============================================================

local appliedWeapons = {}

function BRS_WEAPONS.ApplyBoosters(wep, uid)
    if not IsValid(wep) then return end

    local weaponData = BRS_WEAPONS.Cache[uid]
    if not weaponData or not weaponData.stat_boosters then return end

    local boosters = weaponData.stat_boosters
    local primary = wep.Primary
    if not primary then return end

    for statKey, boostValue in pairs(boosters) do
        local statDef = BRS_WEAPONS.StatDefs and BRS_WEAPONS.StatDefs[statKey]
        if statDef and statDef.ApplyFunc then
            local keys = string.Split(statDef.WeaponKey or "", ".")
            if #keys == 2 and keys[1] == "Primary" and primary[keys[2]] then
                local baseVal = primary[keys[2]]
                if isnumber(baseVal) then
                    primary[keys[2]] = statDef.ApplyFunc(wep, baseVal, boostValue)
                end
            end
        end
    end

    appliedWeapons[wep:EntIndex()] = uid

    if boosters["RPM"] and primary.RPM then
        primary.Delay = 60 / primary.RPM
    end
end

function BRS_WEAPONS.FindBestForPlayer(ply, weaponClass)
    local steamID = ply:SteamID64()
    local playerWeapons = BRS_WEAPONS.PlayerWeapons[steamID]
    if not playerWeapons then return nil end

    local bestUID, bestTotal = nil, -1
    for uid, data in pairs(playerWeapons) do
        if data.weapon_class == weaponClass then
            local total = 0
            for _, v in pairs(data.stat_boosters or {}) do
                total = total + v
            end
            if total > bestTotal then
                bestUID, bestTotal = uid, total
            end
        end
    end

    return bestUID
end

function BRS_WEAPONS.ApplyEquippedBoosters(ply)
    if not IsValid(ply) then return end
    for _, wep in ipairs(ply:GetWeapons()) do
        if IsValid(wep) and not appliedWeapons[wep:EntIndex()] then
            local uid = BRS_WEAPONS.FindBestForPlayer(ply, wep:GetClass())
            if uid then
                BRS_WEAPONS.ApplyBoosters(wep, uid)
            end
        end
    end
end

hook.Add("PlayerLoadout", "BRS_UniqueWeapons_ApplyOnLoadout", function(ply)
    timer.Simple(0.5, function()
        if IsValid(ply) then
            BRS_WEAPONS.ApplyEquippedBoosters(ply)
        end
    end)
end)

hook.Add("WeaponEquip", "BRS_UniqueWeapons_ApplyOnEquip", function(wep, ply)
    timer.Simple(0.1, function()
        if IsValid(wep) and IsValid(ply) then
            local uid = BRS_WEAPONS.FindBestForPlayer(ply, wep:GetClass())
            if uid and not appliedWeapons[wep:EntIndex()] then
                BRS_WEAPONS.ApplyBoosters(wep, uid)
            end
        end
    end)
end)

hook.Add("EntityRemoved", "BRS_UniqueWeapons_CleanupTracking", function(ent)
    if ent:IsWeapon() then
        appliedWeapons[ent:EntIndex()] = nil
    end
end)

-- ============================================================
-- DEBUG COMMAND
-- ============================================================
concommand.Add("brs_debug_sv", function(ply)
    if not ply:IsSuperAdmin() then return end
    print("=== BRS UniqueWeapons Server Debug ===")
    print("Hook installed: " .. tostring(_hookInstalled))
    print("Hook attempts: " .. tostring(BRS_WEAPONS._hookAttempts or 0))
    print("DB connected: " .. tostring(BRS_UNBOXING_DB ~= nil))
    print("BRICKS_SERVER: " .. tostring(BRICKS_SERVER ~= nil))
    print("BRICKS_SERVER.UNBOXING: " .. tostring(BRICKS_SERVER and BRICKS_SERVER.UNBOXING ~= nil))
    print("BRICKS_SERVER.UNBOXING.Func: " .. tostring(BRICKS_SERVER and BRICKS_SERVER.UNBOXING and BRICKS_SERVER.UNBOXING.Func ~= nil))
    print("Player meta AddUnboxingInventoryItem: " .. tostring(FindMetaTable("Player").AddUnboxingInventoryItem ~= nil))

    if BRICKS_SERVER and BRICKS_SERVER.UNBOXING and BRICKS_SERVER.UNBOXING.Func then
        print("Func methods:")
        for k, v in pairs(BRICKS_SERVER.UNBOXING.Func) do
            if isfunction(v) then print("  " .. k .. "()") end
        end
    end

    local totalWeapons = 0
    for sid, weapons in pairs(BRS_WEAPONS.PlayerWeapons) do
        local count = table.Count(weapons)
        totalWeapons = totalWeapons + count
        print("Player " .. sid .. ": " .. count .. " weapons")
    end
    print("Total cached weapons: " .. totalWeapons)
    print("=====================================")
end)

print("[BRS UniqueWeapons] Server system loaded (v3 - robust hooking)!")
