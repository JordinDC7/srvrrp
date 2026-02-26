-- ============================================================
-- BRS Unique Weapons - Projectile System (Server)
--
-- KEY FIX: return false to FULLY suppress hitscan. No 0-damage
-- ghost bullet, no Source impact effects. Our projectile is the
-- ONLY damage source.
--
-- Server: authoritative hit detection + damage application
-- Client: receives spawn data, predicts trajectory for visuals
-- ============================================================

util.AddNetworkString("BRS_UW.ProjSpawn")
util.AddNetworkString("BRS_UW.ProjHit")

-- ============================================================
-- PROJECTILE POOL (array, reverse-iterate removal)
-- ============================================================
local projectiles = {}
local MAX_PROJECTILES = 128
local _lastThink = 0

-- ============================================================
-- ENTITY FILTER CACHE: player + their vehicle
-- ============================================================
local function GetFilter(ply)
    local veh = ply:GetVehicle()
    if IsValid(veh) then return { ply, veh } end
    return ply
end

-- ============================================================
-- HOOK: EntityFireBullets
-- Suppress hitscan entirely, spawn projectile instead
-- ============================================================
hook.Add("EntityFireBullets", "BRS_UW_ProjectileSystem", function(ent, data)
    if not IsValid(ent) or not ent:IsPlayer() then return end

    local wep = ent:GetActiveWeapon()
    if not IsValid(wep) or not wep.BRS_UW_Boosted then return end

    local uwData = wep.BRS_UW_Data
    if not uwData then return end

    local rarity = uwData.rarity or "Common"
    local quality = uwData.quality or "Junk"
    local isAscended = (quality == "Ascended")
    local rarityIdx = BRS_UW.RarityOrder[rarity] or 1
    local category = uwData.category or "Rifle"
    local phys = BRS_UW.Projectiles.GetPhysics(category)

    -- Capture original bullet data
    local src = data.Src
    local dir = data.Dir
    local spread = data.Spread or Vector(0, 0, 0)
    local damage = data.Damage or 10
    local num = data.Num or 1
    local force = data.Force or 1
    local filter = GetFilter(ent)

    -- Spawn projectile for each bullet
    for i = 1, num do
        -- Apply spread
        local bulletDir = dir
        if spread:LengthSqr() > 0 then
            local ang = dir:Angle()
            bulletDir = (ang:Forward()
                + ang:Right() * math.Rand(-1, 1) * spread.x
                + ang:Up() * math.Rand(-1, 1) * spread.y):GetNormalized()
        end

        -- Pool limit
        while #projectiles >= MAX_PROJECTILES do
            table.remove(projectiles, 1)
        end

        local vel = bulletDir * phys.velocity

        projectiles[#projectiles + 1] = {
            owner = ent,
            filter = filter,
            pos = Vector(src.x, src.y, src.z),
            vel = vel,
            gravity = phys.gravity,
            damage = damage,
            force = force,
            spawnTime = CurTime(),
            dist = 0,
        }

        -- Network to clients (unreliable for perf)
        net.Start("BRS_UW.ProjSpawn", true)
            net.WriteVector(src)
            net.WriteVector(vel)
            net.WriteFloat(phys.gravity)
            net.WriteUInt(rarityIdx, 4)
            net.WriteEntity(ent)
            net.WriteBool(isAscended)
        net.SendPVS(src)
    end

    -- RETURN FALSE: completely suppress hitscan bullet
    -- M9K still runs PrimaryAttack (ammo consumed, sound plays, anim plays)
    -- but NO hitscan bullet fires. Our projectile is the only damage source.
    return false
end)

-- ============================================================
-- THINK: Advance projectiles, trace for hits
-- ============================================================
hook.Add("Think", "BRS_UW_ProjectileThink", function()
    local count = #projectiles
    if count == 0 then return end

    local ct = CurTime()
    local dt = ct - _lastThink
    _lastThink = ct
    if dt <= 0 or dt > 0.1 then dt = engine.TickInterval() end

    local Step = BRS_UW.Projectiles.Step
    local maxLife = BRS_UW.Projectiles.MAX_LIFETIME
    local maxDist = BRS_UW.Projectiles.MAX_DISTANCE

    for i = count, 1, -1 do
        local p = projectiles[i]

        -- Expire check
        if ct - p.spawnTime > maxLife or p.dist > maxDist then
            projectiles[i] = projectiles[#projectiles]
            projectiles[#projectiles] = nil
            continue
        end

        -- Physics step
        local oldPos = p.pos
        local newPos, newVel = Step(p.pos, p.vel, p.gravity, dt)
        local moveDist = oldPos:Distance(newPos)

        -- Trace for collision
        local tr = util.TraceLine({
            start = oldPos,
            endpos = newPos,
            filter = p.filter,
            mask = MASK_SHOT,
        })

        if tr.Hit then
            -- Apply damage
            if IsValid(p.owner) then
                local dmg = DamageInfo()
                dmg:SetDamage(p.damage)
                dmg:SetAttacker(p.owner)
                dmg:SetInflictor(IsValid(p.owner:GetActiveWeapon()) and p.owner:GetActiveWeapon() or p.owner)
                dmg:SetDamageType(DMG_BULLET)
                dmg:SetDamagePosition(tr.HitPos)
                dmg:SetDamageForce(p.vel:GetNormalized() * p.force * 100)

                if IsValid(tr.Entity) then
                    tr.Entity:TakeDamageInfo(dmg)
                end

                -- Source impact effects (blood or sparks)
                local isNPCorPlayer = IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC())
                local ed = EffectData()
                ed:SetOrigin(tr.HitPos)
                ed:SetNormal(tr.HitNormal)
                if isNPCorPlayer then
                    util.Effect("BloodImpact", ed)
                else
                    ed:SetScale(1)
                    util.Effect("Impact", ed)
                end
            end

            -- Network hit for custom impact effects
            if not tr.HitSky then
                net.Start("BRS_UW.ProjHit", true)
                    net.WriteVector(tr.HitPos)
                    net.WriteNormal(tr.HitNormal)
                net.SendPVS(tr.HitPos)
            end

            -- Swap-remove (fast)
            projectiles[i] = projectiles[#projectiles]
            projectiles[#projectiles] = nil
        else
            p.pos = newPos
            p.vel = newVel
            p.dist = p.dist + moveDist
        end
    end
end)

print("[BRS UW] Projectile physics server loaded")
