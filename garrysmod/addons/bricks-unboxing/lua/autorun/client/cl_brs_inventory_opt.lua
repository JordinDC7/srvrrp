-- ============================================================
-- BRS Inventory Optimization (Client)
-- Receives delta and compressed inventory updates
-- Also hooks the framework's original channel as fallback
-- ============================================================

-- ============================================================
-- DELTA INVENTORY UPDATE
-- ============================================================
net.Receive("BRS_UW.InvDelta", function()
    local count = net.ReadUInt(8)
    if not count or count < 1 then return end

    BRS_UNBOXING_INVENTORY = BRS_UNBOXING_INVENTORY or {}

    local changed = 0
    for i = 1, count do
        local key = net.ReadString()
        local amount = net.ReadInt(32)

        if amount <= 0 then
            if BRS_UNBOXING_INVENTORY[key] then
                BRS_UNBOXING_INVENTORY[key] = nil
                changed = changed + 1
            end
        else
            if BRS_UNBOXING_INVENTORY[key] ~= amount then
                BRS_UNBOXING_INVENTORY[key] = amount
                changed = changed + 1
            end
        end
    end

    if changed > 0 then
        BRS_UW_DebouncedRefresh()
    end
end)

-- ============================================================
-- COMPRESSED FULL INVENTORY
-- ============================================================
net.Receive("BRS_UW.InvFull", function()
    local len = net.ReadUInt(32)
    if not len or len < 1 then return end

    local compressed = net.ReadData(len)
    if not compressed then return end

    local json = util.Decompress(compressed)
    if not json then return end

    local inv = util.JSONToTable(json)
    if not inv then return end

    BRS_UNBOXING_INVENTORY = inv

    -- Immediate refresh for full sync (initial load)
    hook.Run("BRS.Hooks.FillUnboxingInventory")
end)

-- ============================================================
-- DEBOUNCED UI REFRESH
-- Waits 0.15s after last delta before rebuilding inventory UI
-- ============================================================
local refreshTimer = "BRS_UW_InvRefresh"

function BRS_UW_DebouncedRefresh()
    timer.Create(refreshTimer, 0.15, 1, function()
        hook.Run("BRS.Hooks.FillUnboxingInventory")
    end)
end

print("[BRS UW] Inventory optimization (client) loaded")
