-- ============================================================
-- BRS Unique Weapons - Tracer System (Server)
-- Hooks into bullet firing and networks tracer data to clients
-- ============================================================

util.AddNetworkString("BRS_UW.Tracer")

-- ============================================================
-- HOOK: EntityFireBullets
-- Fires for ALL bullet-based weapons. We check if the shooter
-- has a boosted unique weapon and send tracer data to clients.
-- Actual damage is unchanged (hitscan stays).
-- ============================================================
hook.Add("EntityFireBullets", "BRS_UW_TracerCapture", function(ent, data)
    if not IsValid(ent) or not ent:IsPlayer() then return end

    local wep = ent:GetActiveWeapon()
    if not IsValid(wep) or not wep.BRS_UW_Boosted then return end

    local uwData = wep.BRS_UW_Data
    if not uwData then return end

    local rarity = uwData.rarity or "Common"
    local tier = BRS_UW.Tracers and BRS_UW.Tracers.GetTier(rarity)
    if not tier then return end

    -- Suppress default tracers - we render our own
    data.Tracer = 0
    data.TracerName = ""

    -- Use callback to get accurate hit position per bullet
    local origCallback = data.Callback
    local src = data.Src
    local rarityIdx = BRS_UW.RarityOrder[rarity] or 1

    data.Callback = function(attacker, tr, dmginfo)
        -- Call original callback if any
        if origCallback then
            origCallback(attacker, tr, dmginfo)
        end

        -- Network tracer with real hit position
        net.Start("BRS_UW.Tracer", true)
            net.WriteVector(src)
            net.WriteVector(tr.HitPos)
            net.WriteNormal(tr.HitNormal or Vector(0, 0, 1))
            net.WriteUInt(rarityIdx, 4)
            net.WriteEntity(ent)
            net.WriteBool(tr.Hit and not tr.HitSky)
        net.SendPVS(src)
    end

    return true -- apply modified bullet data
end)

print("[BRS UW] Tracer server system loaded")
