--[[
    UNIQUE WEAPON SYSTEM - Server Side (v5 - inventory safe)
    
    CRITICAL: All custom code wrapped in pcall. If ANYTHING errors,
    bricks' original functions still run perfectly.
    
    Does NOT modify bricks inventory storage/loading.
    Uses a SEPARATE MySQL table for unique weapon data.
]]--

if not SERVER then return end

BRS_WEAPONS = BRS_WEAPONS or {}
BRS_WEAPONS.Cache = BRS_WEAPONS.Cache or {}
BRS_WEAPONS.PlayerWeapons = BRS_WEAPONS.PlayerWeapons or {}

-- ============================================================
-- DATABASE (separate table, never touches bricks tables)
-- ============================================================

local function WaitForDB(cb)
    if BRS_UNBOXING_DB then cb() return end
    timer.Create("BRS_UW_WaitDB", 1, 60, function()
        if BRS_UNBOXING_DB then timer.Remove("BRS_UW_WaitDB") cb() end
    end)
end

local function RunQuery(query, cb, single)
    if not BRS_UNBOXING_DB then return end
    local q = BRS_UNBOXING_DB:query(query)
    if cb then
        function q:onSuccess(data)
            data = data or {}
            if single then data = data[1] or {} end
            cb(data)
        end
    end
    function q:onError(err) print("[BRS UW] SQL: " .. err) end
    q:start()
end

local function Esc(s)
    if not BRS_UNBOXING_DB then return tostring(s) end
    return BRS_UNBOXING_DB:escape(tostring(s))
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
    );]], function() print("[BRS UW] DB table ready!") end)
end)

-- ============================================================
-- CRUD
-- ============================================================

function BRS_WEAPONS.SaveWeapon(uid, sid64, idx, cls, name, rar, boosters)
    RunQuery(string.format(
        "INSERT INTO brs_unique_weapons VALUES ('%s','%s',%d,'%s','%s','%s','%s',%d);",
        Esc(uid), Esc(sid64), idx, Esc(cls), Esc(name), Esc(rar),
        Esc(util.TableToJSON(boosters)), os.time()
    ))
    local data = {
        weapon_uid = uid, owner_steamid64 = sid64, item_index = idx,
        weapon_class = cls, weapon_name = name, rarity = rar,
        stat_boosters = boosters, created_at = os.time()
    }
    BRS_WEAPONS.Cache[uid] = data
    BRS_WEAPONS.PlayerWeapons[sid64] = BRS_WEAPONS.PlayerWeapons[sid64] or {}
    BRS_WEAPONS.PlayerWeapons[sid64][uid] = data
    return data
end

function BRS_WEAPONS.FetchPlayerWeapons(sid64, cb)
    RunQuery("SELECT * FROM brs_unique_weapons WHERE owner_steamid64='" .. Esc(sid64) .. "';", function(rows)
        local weapons = {}
        for _, row in ipairs(rows) do
            row.stat_boosters = util.JSONToTable(row.stat_boosters or "{}") or {}
            row.item_index = tonumber(row.item_index) or 0
            weapons[row.weapon_uid] = row
            BRS_WEAPONS.Cache[row.weapon_uid] = row
        end
        BRS_WEAPONS.PlayerWeapons[sid64] = weapons
        if cb then cb(weapons) end
    end)
end

-- ============================================================
-- NETWORKING
-- ============================================================
util.AddNetworkString("BRS.UW.Sync")
util.AddNetworkString("BRS.UW.NewWeapon")

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

hook.Add("PlayerInitialSpawn", "BRS_UW_Sync", function(ply)
    timer.Simple(8, function()
        if IsValid(ply) then BRS_WEAPONS.SyncToClient(ply) end
    end)
end)

-- ============================================================
-- CASE OPEN HOOK - wrapped in pcall for safety
-- If our code errors, bricks STILL works perfectly
-- ============================================================

local _hooked = false

local function SafeOnWeaponUnboxed(ply, globalKey)
    if not IsValid(ply) then return end
    if not BRICKS_SERVER or not BRICKS_SERVER.CONFIG then return end
    if not BRICKS_SERVER.CONFIG.UNBOXING or not BRICKS_SERVER.CONFIG.UNBOXING.Items then return end

    local itemKey = tonumber(string.match(tostring(globalKey), "ITEM_(%d+)"))
    if not itemKey then return end

    local cfg = BRICKS_SERVER.CONFIG.UNBOXING.Items[itemKey]
    if not cfg then return end
    if cfg.Type ~= "PermWeapon" and cfg.Type ~= "Weapon" then return end

    local cls = cfg.ReqInfo and cfg.ReqInfo[1] or ""
    local name = cfg.Name or "Unknown"
    local rar = cfg.Rarity or "Common"

    local uid = BRS_WEAPONS.GenerateUID()
    local boosters = BRS_WEAPONS.RollStatBoosters(rar)
    local data = BRS_WEAPONS.SaveWeapon(uid, ply:SteamID64(), itemKey, cls, name, rar, boosters)

    net.Start("BRS.UW.NewWeapon")
        net.WriteString(util.TableToJSON(data))
    net.Send(ply)

    print(string.format("[BRS UW] %s unboxed %s [%s] UID:%s | DMG:%.1f%% ACC:%.1f%% MAG:%.1f%% RPM:%.1f%% SPD:%.1f%%",
        ply:Nick(), name, rar, uid,
        (boosters.DMG or 0)*100, (boosters.ACC or 0)*100,
        (boosters.MAG or 0)*100, (boosters.RPM or 0)*100, (boosters.SPD or 0)*100
    ))
end

timer.Create("BRS_UW_Hook", 2, 60, function()
    if _hooked then timer.Remove("BRS_UW_Hook") return end

    local meta = FindMetaTable("Player")
    if not meta or not meta.AddUnboxingInventoryItem then return end
    if meta._BRS_HOOKED then _hooked = true timer.Remove("BRS_UW_Hook") return end

    -- Store original as upvalue (not on meta) for safety
    local originalFunc = meta.AddUnboxingInventoryItem

    meta.AddUnboxingInventoryItem = function(self, ...)
        -- ALWAYS call original FIRST, capture return value
        local ret = originalFunc(self, ...)

        -- Our code in pcall - if it errors, bricks is unaffected
        local ok, err = pcall(function()
            local args = { ... }
            for i = 1, #args, 2 do
                local key = args[i]
                if isstring(key) and string.StartWith(key, "ITEM_") then
                    SafeOnWeaponUnboxed(self, key)
                end
            end
        end)

        if not ok then
            print("[BRS UW] Hook error (bricks unaffected): " .. tostring(err))
        end

        return ret
    end

    meta._BRS_HOOKED = true
    _hooked = true
    timer.Remove("BRS_UW_Hook")
    print("[BRS UW] Hook installed (pcall-safe)!")
end)

-- ============================================================
-- STAT BOOSTER APPLICATION
-- ============================================================

local applied = {}

function BRS_WEAPONS.FindBestForPlayer(ply, wepClass)
    local pw = BRS_WEAPONS.PlayerWeapons[ply:SteamID64()]
    if not pw then return nil end
    local best, bestT = nil, -1
    for uid, d in pairs(pw) do
        if d.weapon_class == wepClass then
            local t = 0
            for _, v in pairs(d.stat_boosters or {}) do t = t + v end
            if t > bestT then best, bestT = uid, t end
        end
    end
    return best
end

hook.Add("WeaponEquip", "BRS_UW_Apply", function(wep, ply)
    timer.Simple(0.1, function()
        if not IsValid(wep) or not IsValid(ply) then return end
        if applied[wep:EntIndex()] then return end

        local uid = BRS_WEAPONS.FindBestForPlayer(ply, wep:GetClass())
        if not uid then return end

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
        if data.stat_boosters["RPM"] and primary.RPM then primary.Delay = 60 / primary.RPM end
        applied[wep:EntIndex()] = uid
    end)
end)

hook.Add("EntityRemoved", "BRS_UW_Cleanup", function(ent)
    if ent:IsWeapon() then applied[ent:EntIndex()] = nil end
end)

-- Debug
concommand.Add("brs_debug_sv", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    print("=== BRS UW Server ===")
    print("Hook: " .. tostring(_hooked) .. " | DB: " .. tostring(BRS_UNBOXING_DB ~= nil))
    for sid, w in pairs(BRS_WEAPONS.PlayerWeapons) do print("  " .. sid .. ": " .. table.Count(w)) end
    print("====================")
end)

print("[BRS UW] Server loaded (v5 - pcall safe)!")
