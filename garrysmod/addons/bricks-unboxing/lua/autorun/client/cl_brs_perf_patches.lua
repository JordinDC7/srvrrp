-- ============================================================
-- BRS Client Performance Patches
-- Targeted optimizations for heaviest per-frame operations
-- ============================================================

-- ============================================================
-- 1. FAST ColorAlpha: Pool of 500 reusable Color objects
-- Eliminates ~2,900 Color allocations per frame from item slots
-- Pool must be large enough for all visible cards (40+ calls each)
-- ============================================================
local colorPool = {}
local colorPoolIdx = 0
local POOL_SIZE = 500

for i = 1, POOL_SIZE do
    colorPool[i] = Color(255, 255, 255, 255)
end

local origColorAlpha = ColorAlpha
function ColorAlpha(col, alpha)
    if not col then return origColorAlpha(col, alpha) end
    colorPoolIdx = colorPoolIdx + 1
    if colorPoolIdx > POOL_SIZE then colorPoolIdx = 1 end
    local c = colorPool[colorPoolIdx]
    c.r = col.r or 255
    c.g = col.g or 255
    c.b = col.b or 255
    c.a = alpha or 255
    return c
end

hook.Add("PreRender", "BRS_UW_ResetColorPool", function()
    colorPoolIdx = 0
end)

-- ============================================================
-- 2. ITEM SLOT VISIBILITY CULLING
-- Skip Paint on off-screen item slots in DScrollPanel
-- ============================================================
hook.Add("Initialize", "BRS_UW_PatchItemSlot", function()
    timer.Simple(1, function()
        local reg = vgui.GetControlTable("bricks_server_unboxingmenu_itemslot")
        if not reg then return end

        local origFillPanel = reg.FillPanel
        if not origFillPanel then return end

        reg.FillPanel = function(self, data, amount, actions)
            origFillPanel(self, data, amount, actions)

            if IsValid(self.panelInfo) then
                local origPaint = self.panelInfo.Paint
                if origPaint then
                    self.panelInfo.Paint = function(pnl, w, h)
                        local _, sy = pnl:LocalToScreen(0, 0)
                        if sy + h < 0 or sy > ScrH() then return end
                        origPaint(pnl, w, h)
                    end
                end
            end
        end

        print("[BRS UW] Item slot visibility culling patched")
    end)
end)

-- ============================================================
-- 3. CACHED string.format for stat display
-- Avoids repeated format calls for same values
-- ============================================================
local formatCache = {}
local formatCacheSize = 0

function BRS_UW_CachedFormat(fmt, val)
    local key = fmt .. tostring(math.Round(val, 1))
    local cached = formatCache[key]
    if cached then return cached end

    if formatCacheSize > 500 then
        formatCache = {}
        formatCacheSize = 0
    end

    local result = string.format(fmt, val)
    formatCache[key] = result
    formatCacheSize = formatCacheSize + 1
    return result
end

print("[BRS UW] Client performance patches loaded")
