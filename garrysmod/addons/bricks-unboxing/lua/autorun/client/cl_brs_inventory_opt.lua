-- ============================================================
-- BRS Inventory Optimization (Client)
-- Receives delta inventory updates and compressed full syncs
-- Debounces UI refresh to prevent rapid rebuilds
-- ============================================================

-- ============================================================
-- DELTA INVENTORY UPDATE: Apply only changed keys
-- Much faster than receiving entire inventory
-- ============================================================
net.Receive("BRS_UW.InvDelta", function()
    local count = net.ReadUInt(8)

    for i = 1, count do
        local key = net.ReadString()
        local amount = net.ReadInt(32)

        if amount <= 0 then
            BRS_UNBOXING_INVENTORY[key] = nil
        else
            BRS_UNBOXING_INVENTORY[key] = amount
        end
    end

    -- Debounced UI refresh (prevents rapid rebuilds during mass operations)
    BRS_UW_DebouncedRefresh()
end)

-- ============================================================
-- COMPRESSED FULL INVENTORY: JSON + compress
-- Replaces net.ReadTable() which is very slow for large tables
-- ============================================================
net.Receive("BRS_UW.InvFull", function()
    local len = net.ReadUInt(32)
    local compressed = net.ReadData(len)

    if not compressed then return end

    local json = util.Decompress(compressed)
    if not json then return end

    local inv = util.JSONToTable(json)
    if not inv then return end

    BRS_UNBOXING_INVENTORY = inv

    BRS_UW_DebouncedRefresh()
end)

-- ============================================================
-- DEBOUNCED UI REFRESH
-- Waits 0.1s after last change before rebuilding inventory UI
-- Prevents 50 rebuilds when opening 50 cases
-- ============================================================
local refreshTimer = "BRS_UW_InvRefresh"

function BRS_UW_DebouncedRefresh()
    -- Reset the timer on each call
    timer.Create(refreshTimer, 0.1, 1, function()
        hook.Run("BRS.Hooks.FillUnboxingInventory")
    end)
end

print("[BRS UW] Inventory optimization (client) loaded")
