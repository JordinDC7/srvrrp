-- ============================================================
-- BRS Inventory Optimization (Server)
-- Replaces net.WriteTable(entireInventory) with delta updates
-- Adds operation batching for mass open cases
-- Deferred to load AFTER Bricks framework
-- ============================================================

util.AddNetworkString("BRS_UW.InvDelta")
util.AddNetworkString("BRS_UW.InvFull")

-- ============================================================
-- BATCH SYSTEM: Collect changes, flush once
-- ============================================================
local batchMode = {}       -- [steamid] = true
local batchChanges = {}    -- [steamid] = { [key] = newAmount }

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

    -- Send one delta message
    SendInventoryDelta(ply, changes)

    -- Save to DB once
    local inv = ply.BRS_UNBOXING_INVENTORY
    if inv then
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

    -- Fallback to full sync if too many changes
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
        -- Fallback to framework method for huge inventories
        net.Start("BRS.Net.SetUnboxingInventory")
            net.WriteTable(inv)
        net.Send(ply)
    end
end

-- ============================================================
-- DEFERRED OVERRIDES: Apply after Bricks framework loads
-- ============================================================
hook.Add("Initialize", "BRS_UW_InvOptInit", function()
    timer.Simple(0, function()
        local playerMeta = FindMetaTable("Player")
        if not playerMeta or not playerMeta.SetUnboxingInventory then
            print("[BRS UW InvOpt] WARNING: Could not find SetUnboxingInventory, skipping optimization")
            return
        end

        -- Store original
        playerMeta._OrigSetUnboxingInventory = playerMeta._OrigSetUnboxingInventory or playerMeta.SetUnboxingInventory

        -- ========================================
        -- OVERRIDE: SetUnboxingInventory
        -- Uses delta sync instead of full table
        -- ========================================
        playerMeta.SetUnboxingInventory = function(self, inventoryTable, nosave)
            if not inventoryTable then return end

            local sid = self:SteamID64()
            local oldInv = self.BRS_UNBOXING_INVENTORY

            -- First time: use compressed full sync (no delta possible)
            if not oldInv then
                self.BRS_UNBOXING_INVENTORY = inventoryTable

                -- Send compressed instead of net.WriteTable
                SendFullInventory(self)

                if not nosave then
                    BRICKS_SERVER.UNBOXING.Func.UpdateInventoryDB(sid, inventoryTable)
                end
                return
            end

            -- Compute delta
            local changes = {}
            local hasChanges = false

            for k, v in pairs(inventoryTable) do
                if oldInv[k] ~= v then
                    changes[k] = v
                    hasChanges = true
                end
            end
            for k in pairs(oldInv) do
                if not inventoryTable[k] or inventoryTable[k] == 0 then
                    changes[k] = 0
                    hasChanges = true
                end
            end

            -- Update server memory
            self.BRS_UNBOXING_INVENTORY = inventoryTable

            if not hasChanges then return end

            -- Batched: accumulate
            if batchMode[sid] then
                local bc = batchChanges[sid]
                for k, v in pairs(changes) do bc[k] = v end
                return
            end

            -- Send delta
            SendInventoryDelta(self, changes)

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

            -- BATCH: prevents per-item full syncs
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

            -- FLUSH: one delta message + one DB write
            FlushBatch(ply)

            BRICKS_SERVER.Func.SendNotification(ply, 1, 5, BRICKS_SERVER.Func.L("unboxingCasesUnboxed", openAmount))
            hook.Run("BRS.Hooks.CaseUnboxed", ply, openAmount)
            ply:UpdateUnboxingStat("cases", openAmount, true)
        end)

        -- Export batch functions
        BRS_UW = BRS_UW or {}
        BRS_UW.StartBatch = StartBatch
        BRS_UW.FlushBatch = FlushBatch

        print("[BRS UW] Inventory optimization applied - delta sync + batching active")
    end)
end)

print("[BRS UW] Inventory optimization (server) loaded")
