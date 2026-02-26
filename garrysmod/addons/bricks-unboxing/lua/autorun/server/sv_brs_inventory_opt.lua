-- ============================================================
-- BRS Inventory Optimization (Server)
-- 
-- BUG FIX: The Bricks framework modifies the inventory table
-- IN-PLACE then passes the same reference to SetUnboxingInventory.
-- Comparing inventoryTable to self.BRS_UNBOXING_INVENTORY yields
-- zero delta because they're the SAME Lua table.
--
-- SOLUTION: Maintain a separate SNAPSHOT (shallow copy) of the
-- last-synced state. Compare against the snapshot, not the live
-- reference. This correctly detects all changes.
-- ============================================================

util.AddNetworkString("BRS_UW.InvDelta")
util.AddNetworkString("BRS_UW.InvFull")

-- ============================================================
-- SNAPSHOT STORAGE: Separate from framework's live table
-- Key = SteamID64, Value = shallow copy of inventory
-- ============================================================
local invSnapshots = {}

local function TakeSnapshot(sid, inv)
    local snap = {}
    for k, v in pairs(inv) do
        snap[k] = v
    end
    invSnapshots[sid] = snap
end

local function GetSnapshot(sid)
    return invSnapshots[sid]
end

-- ============================================================
-- BATCH SYSTEM
-- ============================================================
local batchMode = {}
local batchChanges = {}

local function StartBatch(ply)
    local sid = ply:SteamID64()
    batchMode[sid] = true
    batchChanges[sid] = {}
end

local function FlushBatch(ply)
    local sid = ply:SteamID64()
    if not batchMode[sid] then return end
    batchMode[sid] = nil

    local changes = batchChanges[sid]
    batchChanges[sid] = nil

    if not changes or not next(changes) then return end

    SendInventoryDelta(ply, changes)

    -- Take snapshot of current state
    local inv = ply.BRS_UNBOXING_INVENTORY
    if inv then
        TakeSnapshot(sid, inv)
        BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB(sid, inv)
    end
end

-- ============================================================
-- DELTA SYNC: Send only changed keys
-- ============================================================
function SendInventoryDelta(ply, changes)
    if not IsValid(ply) then return end

    local count = 0
    for _ in pairs(changes) do count = count + 1 end

    if count > 80 then
        SendFullInventory(ply)
        return
    end

    net.Start("BRS_UW.InvDelta")
        net.WriteUInt(count, 8)
        for key, amount in pairs(changes) do
            net.WriteString(key)
            net.WriteInt(amount, 32)
        end
    net.Send(ply)
end

function SendFullInventory(ply)
    if not IsValid(ply) then return end
    local inv = ply.BRS_UNBOXING_INVENTORY or {}

    local json = util.TableToJSON(inv)
    local compressed = util.Compress(json)

    if compressed and #compressed < 65000 then
        net.Start("BRS_UW.InvFull")
            net.WriteUInt(#compressed, 32)
            net.WriteData(compressed, #compressed)
        net.Send(ply)
    else
        -- Fallback
        net.Start("BRS.Net.SetUnboxingInventory")
            net.WriteTable(inv)
        net.Send(ply)
    end
end

-- ============================================================
-- DEFERRED OVERRIDES
-- ============================================================
hook.Add("Initialize", "BRS_UW_InvOptInit", function()
    timer.Simple(0, function()
        local playerMeta = FindMetaTable("Player")
        if not playerMeta or not playerMeta.SetUnboxingInventory then
            print("[BRS UW InvOpt] WARNING: Could not find SetUnboxingInventory, skipping")
            return
        end

        playerMeta._OrigSetUnboxingInventory = playerMeta._OrigSetUnboxingInventory or playerMeta.SetUnboxingInventory

        -- ========================================
        -- OVERRIDE: SetUnboxingInventory
        -- Compares against SNAPSHOT, not live table
        -- ========================================
        playerMeta.SetUnboxingInventory = function(self, inventoryTable, nosave)
            if not inventoryTable then return end

            local sid = self:SteamID64()
            local snapshot = GetSnapshot(sid)

            -- First time: no snapshot exists, send full
            if not snapshot then
                self.BRS_UNBOXING_INVENTORY = inventoryTable
                TakeSnapshot(sid, inventoryTable)
                SendFullInventory(self)

                if not nosave then
                    BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB(sid, inventoryTable)
                end
                return
            end

            -- Update framework's live reference
            self.BRS_UNBOXING_INVENTORY = inventoryTable

            -- Compute delta against SNAPSHOT (not live table)
            local changes = {}
            local hasChanges = false

            -- New or changed keys
            for k, v in pairs(inventoryTable) do
                if snapshot[k] ~= v then
                    changes[k] = v
                    hasChanges = true
                end
            end
            -- Removed keys (in snapshot but not in new table)
            for k in pairs(snapshot) do
                if not inventoryTable[k] or inventoryTable[k] == 0 then
                    if snapshot[k] and snapshot[k] > 0 then
                        changes[k] = 0
                        hasChanges = true
                    end
                end
            end

            if not hasChanges then return end

            -- Batched: accumulate
            if batchMode[sid] then
                local bc = batchChanges[sid]
                for k, v in pairs(changes) do bc[k] = v end
                return
            end

            -- Send delta and take new snapshot
            SendInventoryDelta(self, changes)
            TakeSnapshot(sid, inventoryTable)

            -- Save to DB
            if not nosave then
                BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB(sid, inventoryTable)
            end
        end

        -- ========================================
        -- OVERRIDE: Mass case open with batching
        -- ========================================
        net.Receive("BRS.Net.UnboxingOpenAll", function(len, ply)
            local caseKey = net.ReadUInt(16)
            local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey or 0]
            if not configItemTable then return end

            local inventoryTable = ply:GetUnboxingInventory()
            local globalKey = "CASE_" .. caseKey
            if not inventoryTable or not inventoryTable[globalKey] then return end

            local openAmount = inventoryTable[globalKey]

            StartBatch(ply)

            ply:RemoveUnboxingInventoryItem(globalKey, openAmount)

            local totalChance = 0
            for k, v in pairs(configItemTable.Items) do
                totalChance = totalChance + v[1]
            end

            local itemsToGive = {}
            for i = 1, openAmount do
                local winningChance, currentChance = math.Rand(0, 100), 0
                for k, v in pairs(configItemTable.Items) do
                    local actualChance = (v[1] / totalChance) * 100
                    if winningChance > currentChance and winningChance <= currentChance + actualChance then
                        itemsToGive[k] = (itemsToGive[k] or 0) + 1
                        break
                    end
                    currentChance = currentChance + actualChance
                end
            end

            local formattedItems = {}
            for k, v in pairs(itemsToGive) do
                table.insert(formattedItems, k)
                table.insert(formattedItems, v)
            end

            ply:AddUnboxingInventoryItem(unpack(formattedItems))

            FlushBatch(ply)

            BRICKS_SERVER.Func.SendNotification(ply, 1, 5, BRICKS_SERVER.Func.L("unboxingCasesUnboxed", openAmount))
            hook.Run("BRS.Hooks.CaseUnboxed", ply, openAmount)
            ply:UpdateUnboxingStat("cases", openAmount, true)
        end)

        -- Export batch functions
        BRS_UW = BRS_UW or {}
        BRS_UW.StartBatch = StartBatch
        BRS_UW.FlushBatch = FlushBatch

        print("[BRS UW] Inventory optimization applied (snapshot-based delta)")
    end)
end)

-- Cleanup on disconnect
hook.Add("PlayerDisconnected", "BRS_UW_InvOptCleanup", function(ply)
    local sid = ply:SteamID64()
    invSnapshots[sid] = nil
    batchMode[sid] = nil
    batchChanges[sid] = nil
end)

print("[BRS UW] Inventory optimization (server) loaded")
