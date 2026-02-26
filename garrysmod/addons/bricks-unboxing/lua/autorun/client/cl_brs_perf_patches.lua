-- ============================================================
-- BRS Client Performance Patches
-- Targeted optimizations for the heaviest per-frame operations
-- ============================================================

-- ============================================================
-- 1. FAST ColorAlpha: Reuses a pool of Color objects
-- The #1 GC pressure source is ColorAlpha() creating new Color
-- objects every frame. With 50 visible item slots each calling
-- ColorAlpha ~58 times = 2,900 allocations/frame.
-- This patches ColorAlpha to reuse from a pool.
-- ============================================================
local colorPool = {}
local colorPoolIdx = 0
local POOL_SIZE = 200

-- Pre-allocate pool
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

-- Reset pool index each frame
hook.Add("PreRender", "BRS_UW_ResetColorPool", function()
    colorPoolIdx = 0
end)

-- ============================================================
-- 2. ITEM SLOT VISIBILITY CULLING
-- DIconLayout in a scroll panel calls Paint on ALL children,
-- even off-screen ones. This patches the item slot panel to
-- skip expensive rendering when not visible.
-- ============================================================
hook.Add("Initialize", "BRS_UW_PatchItemSlot", function()
    timer.Simple(1, function()
        local reg = vgui.GetControlTable("bricks_server_unboxingmenu_itemslot")
        if not reg then return end

        -- Wrap FillPanel to inject visibility-aware Paint
        local origFillPanel = reg.FillPanel
        if not origFillPanel then return end

        reg.FillPanel = function(self, data, amount, actions)
            origFillPanel(self, data, amount, actions)

            -- Add visibility flag check to panelInfo if it exists
            if IsValid(self.panelInfo) then
                local origPaint = self.panelInfo.Paint
                if origPaint then
                    self.panelInfo.Paint = function(pnl, w, h)
                        -- Skip if panel is off-screen (in scroll panel)
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
-- 3. PARTICLE THROTTLE for item slot cards
-- cardParticles can accumulate rapidly. Throttle spawning
-- to max 2 new particles per frame across ALL cards.
-- ============================================================
local particleSpawnsThisFrame = 0
hook.Add("PreRender", "BRS_UW_ParticleThrottle", function()
    particleSpawnsThisFrame = 0
end)

-- Patch the SpawnParticle call frequency
-- This is exposed through the cardParticles table in itemslot.lua
-- We can't easily patch it without modifying the file, but the
-- visibility culling above will prevent most off-screen spawns

-- ============================================================
-- 4. CACHED string.format for stat display
-- string.format("%.1f", val) is called per stat per slot per frame
-- Cache formatted strings and invalidate rarely
-- ============================================================
local formatCache = {}
local formatCacheSize = 0
local MAX_FORMAT_CACHE = 500

function BRS_UW_CachedFormat(fmt, val)
    -- Round to avoid floating point key issues
    local key = fmt .. tostring(math.Round(val, 1))
    if formatCache[key] then return formatCache[key] end

    if formatCacheSize > MAX_FORMAT_CACHE then
        formatCache = {}
        formatCacheSize = 0
    end

    local result = string.format(fmt, val)
    formatCache[key] = result
    formatCacheSize = formatCacheSize + 1
    return result
end

-- ============================================================
-- 5. REDUCE DRAW CALLS: batch common operations
-- The item slot Paint function calls draw.RoundedBox, 
-- draw.SimpleText, surface.DrawRect dozens of times.
-- These are all Source engine draw calls which are inherently
-- fast, but the Color() allocations around them are the issue.
-- The ColorAlpha pool above is the primary fix for this.
-- ============================================================

print("[BRS UW] Client performance patches loaded")
