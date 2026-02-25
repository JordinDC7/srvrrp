--[[
    UNIQUE WEAPON SYSTEM - Server Side (v4 - safe & minimal)
    
    ONLY does:
    1. Creates unique weapon records when players unbox weapons
    2. Syncs data to clients
    3. Applies stat boosters to equipped weapons
    
    Does NOT touch bricks inventory, UI, or database functions.
]]--

if not SERVER then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.Cache = BRS_WEAPONS.Cache or {}
BRS_WEAPONS.PlayerWeapons = BRS_WEAPONS.PlayerWeapons or {}

-- ============================================================
-- DATABASE (uses bricks' existing connection, our own table)
-- ============================================================

local function WaitForDB(callback)
    if BRS_UNBOXING_DB then callback() return end
    timer.Create("BRS_UW_WaitDB", 1, 60, function()
        if BRS_UNBOXING_DB then
            timer.Remove("BRS_UW_WaitDB")
            callback()
        end
    end)
end

local function RunQuery(query, callback, singleRow)
    if not BRS_UNBOXING_DB then return end
    local q = BRS_UNBOXING_DB:query(query)
    if callback then
        function q:onSuccess(data)
            data = data or {}
            if singleRow then data = data[1] or {} end
            callback(data)
        end
    end
    function q:onError(err)
        print("[BRS UW] SQL Error: " .. err)
    end
    q:start()
end

local function Esc(str)
    if not BRS_UNBOXING_DB then return tostring(str) end
    return BRS_UNBOXING_DB:escape(tostring(str))
end

WaitForDB(function()
    RunQuery([[CREATE TABLE IF NOT EXISTS brs_unique_weapons (
        weapon_uid VARCHAR(16) NOT NULL PRIMARY KEY,
        owner_steamid64 VARCHAR(20) NOT NULL,
        item_index INT NOT NULL,
        weapon_class VARCHAR(64) NOT NULL,
        weapon_name VARCHAR(128) NOT NULL,
        rarity VARCHAR(32) NOT NULL,
        stat_boosters TEXT NOT NULL,
        created_at INT NOT NULL,
        INDEX idx_owner (owner_steamid64)
    );]], function()
        print("[BRS UW] Database table ready!")
    end)
end)

-- ============================================================
-- CRUD
-- ============================================================

function BRS_WEAPONS.SaveWeapon(uid, sid64, itemIdx, wepClass, wepName, rarity, boosters)
    RunQuery(string.format(
        "INSERT INTO brs_unique_weapons VALUES ('%s','%s',%d,'%s','%s','%s','%s',%d);",
        Esc(uid), Esc(sid64), itemIdx, Esc(wepClass), Esc(wepName),
        Esc(rarity), Esc(util.TableToJSON(boosters)), os.time()
    ))
    local data = {
        weapon_uid = uid, owner_steamid64 = sid64, item_index = itemIdx,
        weapon_class = wepClass, weapon_name = wepName, rarity = rarity,
        stat_boosters = boosters, created_at = os.time()
    }
    BRS_WEAPONS.Cache[uid] = data
    BRS_WEAPONS.PlayerWeapons[sid64] = BRS_WEAPONS.PlayerWeapons[sid64] or {}
    BRS_WEAPONS.PlayerWeapons[sid64][uid] = data
    return data
end

function BRS_WEAPONS.FetchPlayerWeapons(sid64, callback)
    RunQuery("SELECT * FROM brs_unique_weapons WHERE owner_steamid64='" .. Esc(sid64) .. "';", function(rows)
        local weapons = {}
        for _, row in ipairs(rows) do
            row.stat_boosters = util.JSONToTable(row.stat_boosters or "{}") or {}
            row.item_index = tonumber(row.item_index) or 0
            weapons[row.weapon_uid] = row
            BRS_WEAPONS.Cache[row.weapon_uid] = row
        end
        BRS_WEAPONS.PlayerWeapons[sid64] = weapons
        if callback then callback(weapons) end
    end)
end

-- ============================================================
-- NETWORKING
-- ============================================================
util.AddNetworkString("BRS.UW.Sync")
util.AddNetworkString("BRS.UW.NewWeapon")
util.AddNetworkString("BRS.UW.RequestInspect")

function BRS_WEAPONS.SyncToClient(ply)
    BRS_WEAPONS.FetchPlayerWeapons(ply:SteamID64(), function(weapons)
        local json = util.TableToJSON(weapons)
        local compressed = util.Compress(json)
        if not compressed then return end
        net.Start("BRS.UW.Sync")
            net.WriteUInt(#compressed, 32)
            net.WriteData(compressed, #compressed)
        net.Send(ply)
        print("[BRS UW] Synced " .. table.Count(weapons) .. " weapons to " .. ply:Nick())
    end)
end

function BRS_WEAPONS.NotifyNewWeapon(ply, weaponData)
    net.Start("BRS.UW.NewWeapon")
        net.WriteString(util.TableToJSON(weaponData))
    net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "BRS_UW_Sync", function(ply)
    timer.Simple(8, function()
        if IsValid(ply) then BRS_WEAPONS.SyncToClient(ply) end
    end)
end)

-- ============================================================
-- CASE OPENING HOOK - Wraps Player:AddUnboxingInventoryItem
-- Only wraps ONE function, does not touch inventory DB at all
-- ============================================================

local _hookInstalled = false

local function GetConfigItem(globalKey)
    if not BRICKS_SERVER or not BRICKS_SERVER.CONFIG then return nil end
    if not BRICKS_SERVER.CONFIG.UNBOXING or not BRICKS_SERVER.CONFIG.UNBOXING.Items then return nil end
    local itemKey = tonumber(string.match(tostring(globalKey), "ITEM_(%d+)"))
    if not itemKey then return nil end
    return BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey], itemKey
end

local function OnWeaponUnboxed(ply, globalKey)
    if not IsValid(ply) then return end
    local configItem, itemKey = GetConfigItem(globalKey)
    if not configItem then return end
    if configItem.Type ~= "PermWeapon" and configItem.Type ~= "Weapon" then return end

    local wepClass = configItem.ReqInfo and configItem.ReqInfo[1] or ""
    local wepName = configItem.Name or "Unknown"
    local rarity = configItem.Rarity or "Common"

    local uid = BRS_WEAPONS.GenerateUID()
    local boosters = BRS_WEAPONS.RollStatBoosters(rarity)
    local data = BRS_WEAPONS.SaveWeapon(uid, ply:SteamID64(), itemKey or 0, wepClass, wepName, rarity, boosters)
    BRS_WEAPONS.NotifyNewWeapon(ply, data)

    print(string.format("[BRS UW] %s unboxed %s [%s] UID:%s | DMG:%.1f%% ACC:%.1f%% MAG:%.1f%% RPM:%.1f%% SPD:%.1f%%",
        ply:Nick(), wepName, rarity, uid,
        (boosters.DMG or 0)*100, (boosters.ACC or 0)*100,
        (boosters.MAG or 0)*100, (boosters.RPM or 0)*100, (boosters.SPD or 0)*100
    ))
end

-- Try to install hook - retries until bricks loads
timer.Create("BRS_UW_InstallHook", 2, 60, function()
    if _hookInstalled then timer.Remove("BRS_UW_InstallHook") return end

    -- Strategy 1: Player metatable
    local meta = FindMetaTable("Player")
    if meta and meta.AddUnboxingInventoryItem and not meta._BRS_ORIG_AddItem then
        meta._BRS_ORIG_AddItem = meta.AddUnboxingInventoryItem
        meta.AddUnboxingInventoryItem = function(self, ...)
            meta._BRS_ORIG_AddItem(self, ...)
            local args = { ... }
            for i = 1, #args, 2 do
                local key = args[i]
                if isstring(key) and string.StartWith(key, "ITEM_") then
                    OnWeaponUnboxed(self, key)
                end
            end
        end
        _hookInstalled = true
        print("[BRS UW] Hook installed via Player:AddUnboxingInventoryItem!")
        timer.Remove("BRS_UW_InstallHook")
        return
    end

    -- Strategy 2: BRICKS_SERVER.UNBOXING.Func functions
    if BRICKS_SERVER and BRICKS_SERVER.UNBOXING and BRICKS_SERVER.UNBOXING.Func then
        for _, fn in ipairs({"AddInventoryItem", "AddItem", "GiveItem"}) do
            local orig = BRICKS_SERVER.UNBOXING.Func[fn]
            if orig and not BRICKS_SERVER.UNBOXING.Func["_BRS_ORIG_" .. fn] then
                BRICKS_SERVER.UNBOXING.Func["_BRS_ORIG_" .. fn] = orig
                BRICKS_SERVER.UNBOXING.Func[fn] = function(ply, ...)
                    orig(ply, ...)
                    if IsValid(ply) then
                        local args = { ... }
                        for i = 1, #args, 2 do
                            local key = args[i]
                            if isstring(key) and string.StartWith(key, "ITEM_") then
                                OnWeaponUnboxed(ply, key)
                            end
                        end
                    end
                end
                _hookInstalled = true
                print("[BRS UW] Hook installed via Func." .. fn .. "!")
                timer.Remove("BRS_UW_InstallHook")
                return
            end
        end
    end

    -- Debug every 10 attempts
    BRS_WEAPONS._attempts = (BRS_WEAPONS._attempts or 0) + 1
    if BRS_WEAPONS._attempts % 5 == 1 then
        print("[BRS UW] Hook attempt #" .. BRS_WEAPONS._attempts)
        print("  BRICKS_SERVER: " .. tostring(BRICKS_SERVER ~= nil))
        if BRICKS_SERVER and BRICKS_SERVER.UNBOXING and BRICKS_SERVER.UNBOXING.Func then
            for k, v in pairs(BRICKS_SERVER.UNBOXING.Func) do
                if isfunction(v) then print("  Func." .. k .. "()") end
            end
        end
        print("  Meta.AddUnboxingInventoryItem: " .. tostring(meta.AddUnboxingInventoryItem ~= nil))
    end
end)

-- ============================================================
-- STAT BOOSTER APPLICATION ON EQUIP
-- ============================================================

local appliedWeapons = {}

function BRS_WEAPONS.FindBestForPlayer(ply, weaponClass)
    local pw = BRS_WEAPONS.PlayerWeapons[ply:SteamID64()]
    if not pw then return nil end
    local bestUID, bestTotal = nil, -1
    for uid, data in pairs(pw) do
        if data.weapon_class == weaponClass then
            local total = 0
            for _, v in pairs(data.stat_boosters or {}) do total = total + v end
            if total > bestTotal then bestUID, bestTotal = uid, total end
        end
    end
    return bestUID
end

function BRS_WEAPONS.ApplyBoosters(wep, uid)
    if not IsValid(wep) then return end
    local data = BRS_WEAPONS.Cache[uid]
    if not data or not data.stat_boosters then return end
    local primary = wep.Primary
    if not primary then return end

    for statKey, boost in pairs(data.stat_boosters) do
        local def = BRS_WEAPONS.StatDefs and BRS_WEAPONS.StatDefs[statKey]
        if def and def.ApplyFunc then
            local keys = string.Split(def.WeaponKey or "", ".")
            if #keys == 2 and keys[1] == "Primary" and primary[keys[2]] and isnumber(primary[keys[2]]) then
                primary[keys[2]] = def.ApplyFunc(wep, primary[keys[2]], boost)
            end
        end
    end
    appliedWeapons[wep:EntIndex()] = uid
    if data.stat_boosters["RPM"] and primary.RPM then primary.Delay = 60 / primary.RPM end
end

hook.Add("WeaponEquip", "BRS_UW_ApplyOnEquip", function(wep, ply)
    timer.Simple(0.1, function()
        if IsValid(wep) and IsValid(ply) and not appliedWeapons[wep:EntIndex()] then
            local uid = BRS_WEAPONS.FindBestForPlayer(ply, wep:GetClass())
            if uid then BRS_WEAPONS.ApplyBoosters(wep, uid) end
        end
    end)
end)

hook.Add("PlayerLoadout", "BRS_UW_ApplyOnLoadout", function(ply)
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        for _, wep in ipairs(ply:GetWeapons()) do
            if IsValid(wep) and not appliedWeapons[wep:EntIndex()] then
                local uid = BRS_WEAPONS.FindBestForPlayer(ply, wep:GetClass())
                if uid then BRS_WEAPONS.ApplyBoosters(wep, uid) end
            end
        end
    end)
end)

hook.Add("EntityRemoved", "BRS_UW_Cleanup", function(ent)
    if ent:IsWeapon() then appliedWeapons[ent:EntIndex()] = nil end
end)

-- ============================================================
-- DEBUG
-- ============================================================
concommand.Add("brs_debug_sv", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    print("=== BRS UW Debug ===")
    print("Hook: " .. tostring(_hookInstalled) .. " | DB: " .. tostring(BRS_UNBOXING_DB ~= nil))
    for sid, weps in pairs(BRS_WEAPONS.PlayerWeapons) do
        print("  " .. sid .. ": " .. table.Count(weps) .. " weapons")
    end
    print("====================")
end)

print("[BRS UW] Server loaded (v4)!")
