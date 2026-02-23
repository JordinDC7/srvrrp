-- Applies Elite Arsenal rolled unboxing stats to equipped unboxing weapons.
if( CLIENT ) then return end

local function brsGetPlayerFromWeaponOwner( owner )
    if( IsValid( owner ) and owner:IsPlayer() ) then return owner end
    return nil
end

local function brsGetStatTrakRuntime()
    BRICKS_SERVER.UNBOXING.RUNTIME = BRICKS_SERVER.UNBOXING.RUNTIME or {}
    BRICKS_SERVER.UNBOXING.RUNTIME.StatTrak = BRICKS_SERVER.UNBOXING.RUNTIME.StatTrak or {}

    return BRICKS_SERVER.UNBOXING.RUNTIME.StatTrak
end

local function brsGetFraudState( ply )
    local runtime = brsGetStatTrakRuntime()
    local sid64 = IsValid( ply ) and ply:SteamID64() or "unknown"

    runtime.Fraud = runtime.Fraud or {}
    runtime.Fraud[sid64] = runtime.Fraud[sid64] or {
        Flags = 0,
        LastKillAt = 0,
        DuplicateVictims = {},
        LastAlert = 0
    }

    return runtime.Fraud[sid64]
end

local function brsIncrementProfileStat( profile, key, amount, isMaxValue )
    local delta = tonumber( amount ) or 0
    if( delta == 0 ) then return end

    local current = tonumber( profile[key] ) or 0
    if( isMaxValue ) then
        profile[key] = math.max( current, delta )
    else
        profile[key] = current+delta
    end
end

local function brsAwardWeaponProgressionXP( ply, globalKey, eventKey )
    if( not IsValid( ply ) or not globalKey ) then return end

    local progressionCfg = (BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig().Progression or {})
    if( not progressionCfg.Enabled ) then return end

    local xpTable = progressionCfg.XP or {}
    local xpAmount = tonumber( xpTable[eventKey] ) or 0
    if( xpAmount <= 0 ) then return end

    BRICKS_SERVER.UNBOXING.Func.AddWeaponProgressionXP( ply, globalKey, xpAmount, string.lower( string.Replace( eventKey, "XP", "" ) ) )
end

local function brsBuildValidationContext( attacker, victim, dmgInfo, statScalars )
    local weaponClass = IsValid( statScalars and statScalars.Weapon ) and statScalars.Weapon:GetClass() or "unknown"
    local distance = 0
    if( IsValid( attacker ) and IsValid( victim ) ) then
        distance = attacker:GetPos():Distance( victim:GetPos() )
    end

    return {
        Attacker = attacker,
        Victim = victim,
        DamageInfo = dmgInfo,
        GlobalKey = statScalars and statScalars.GlobalKey,
        WeaponClass = weaponClass,
        Distance = distance,
        Time = CurTime()
    }
end

local function brsValidateStatTrakEvent( attacker, context )
    local cfg = BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig()
    local antiFraudCfg = cfg.AntiFraud or {}
    if( not antiFraudCfg.Enabled ) then return true, "disabled" end

    if( not IsValid( attacker ) or not IsValid( context.Victim ) or attacker == context.Victim ) then
        return false, "invalid_actor"
    end

    if( context.WeaponClass == "unknown" ) then
        return false, "weapon_mismatch"
    end

    local state = brsGetFraudState( attacker )
    local now = CurTime()
    local minKillInterval = math.max( 0, tonumber( antiFraudCfg.MinKillInterval ) or 0.2 )
    if( (now-(state.LastKillAt or 0)) < minKillInterval ) then
        state.Flags = state.Flags+1
        return false, "kill_interval"
    end

    local maxDistance = tonumber( antiFraudCfg.MaxKillDistance ) or 5000
    if( maxDistance > 0 and (tonumber( context.Distance ) or 0) > maxDistance ) then
        state.Flags = state.Flags+1
        return false, "distance_spike"
    end

    local duplicateWindow = math.max( 1, tonumber( antiFraudCfg.MaxDuplicateVictimsWindow ) or 90 )
    local maxDuplicates = math.max( 1, tonumber( antiFraudCfg.MaxDuplicateVictimsPerWindow ) or 4 )
    local victimKey = IsValid( context.Victim ) and context.Victim:SteamID64() or "unknown"

    state.DuplicateVictims[victimKey] = state.DuplicateVictims[victimKey] or {}
    table.insert( state.DuplicateVictims[victimKey], now )

    local trimmed = {}
    for _, stamp in ipairs( state.DuplicateVictims[victimKey] ) do
        if( (now-stamp) <= duplicateWindow ) then
            table.insert( trimmed, stamp )
        end
    end
    state.DuplicateVictims[victimKey] = trimmed

    if( #trimmed > maxDuplicates ) then
        state.Flags = state.Flags+1
        return false, "duplicate_victim_farm"
    end

    state.LastKillAt = now
    return true, "ok"
end

hook.Add( "EntityFireBullets", "BricksServerHooks_EntityFireBullets_UnboxingStatTrak", function( ent, bulletData )
    if( not BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig().Enabled ) then return end

    local ply = brsGetPlayerFromWeaponOwner( ent )
    if( not IsValid( ply ) ) then return end

    local wep = ply:GetActiveWeapon()
    if( not IsValid( wep ) ) then return end

    local statScalars = BRICKS_SERVER.UNBOXING.Func.GetEquippedWeaponStatScalars( ply, wep:GetClass() )
    if( not statScalars ) then return end

    brsAwardWeaponProgressionXP( ply, statScalars.GlobalKey, "ShotXP" )

    bulletData.Spread = bulletData.Spread or Vector( 0, 0, 0 )
    local spreadScale = (tonumber( statScalars.AccuracySpreadScale ) or 1)*(tonumber( statScalars.ControlMoveSpreadScale ) or 1)

    local velocity = ply:GetVelocity():Length2D()
    local velocityRatio = math.Clamp( velocity/250, 0, 1 )
    local movementSpreadScale = Lerp( velocityRatio, 1, tonumber( statScalars.MobilitySpreadScale ) or 1 )

    bulletData.Spread.x = bulletData.Spread.x*spreadScale*movementSpreadScale
    bulletData.Spread.y = bulletData.Spread.y*spreadScale*movementSpreadScale

    local nextFireDelay = (wep:GetNextPrimaryFire() or CurTime())-CurTime()
    nextFireDelay = math.max( nextFireDelay, 0 )
    wep:SetNextPrimaryFire( CurTime()+(nextFireDelay*(tonumber( statScalars.HandlingFireDelayScale ) or 1)) )
end )

hook.Add( "EntityTakeDamage", "BricksServerHooks_EntityTakeDamage_UnboxingStatTrak", function( target, dmgInfo )
    if( not BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig().Enabled ) then return end

    local attacker = dmgInfo:GetAttacker()
    if( not IsValid( attacker ) or not attacker:IsPlayer() ) then return end

    local wep = attacker:GetActiveWeapon()
    if( not IsValid( wep ) ) then return end

    if( dmgInfo:IsDamageType( DMG_FALL ) or dmgInfo:IsDamageType( DMG_CRUSH ) ) then return end

    local statScalars = BRICKS_SERVER.UNBOXING.Func.GetEquippedWeaponStatScalars( attacker, wep:GetClass() )
    if( not statScalars ) then return end

    statScalars.Weapon = wep
    brsAwardWeaponProgressionXP( attacker, statScalars.GlobalKey, "HitXP" )

    if( IsValid( target ) and target:IsPlayer() ) then
        BRICKS_SERVER.UNBOXING.Func.RecordStatTrakCombatAssist( attacker, target )
    end

    if( IsValid( target ) and target:IsPlayer() and target:Health() > 0 and (target:Health() - dmgInfo:GetDamage()) <= 0 ) then
        local context = brsBuildValidationContext( attacker, target, dmgInfo, statScalars )
        local valid, reason = brsValidateStatTrakEvent( attacker, context )

        if( valid ) then
            brsAwardWeaponProgressionXP( attacker, statScalars.GlobalKey, "KillXP" )
            BRICKS_SERVER.UNBOXING.Func.RecordValidatedStatTrakKill( attacker, target, statScalars, {
                IsHeadshot = dmgInfo:HitGroup() == HITGROUP_HEAD,
                Distance = context.Distance
            } )
        else
            BRICKS_SERVER.UNBOXING.Func.FlagStatTrakAnomaly( attacker, reason, context )
        end
    end

    dmgInfo:ScaleDamage( tonumber( statScalars.DamageScale ) or 1 )
end )

hook.Add( "OnNPCKilled", "BricksServerHooks_OnNPCKilled_UnboxingStatTrak", function( npc, attacker, inflictor )
    if( not BRICKS_SERVER.UNBOXING.Func.GetStatTrakConfig().Enabled ) then return end
    if( not IsValid( attacker ) or not attacker:IsPlayer() ) then return end

    local wep = attacker:GetActiveWeapon()
    if( not IsValid( wep ) ) then return end

    local statScalars = BRICKS_SERVER.UNBOXING.Func.GetEquippedWeaponStatScalars( attacker, wep:GetClass() )
    if( not statScalars ) then return end

    BRICKS_SERVER.UNBOXING.Func.RecordValidatedStatTrakKill( attacker, npc, statScalars, {
        IsHeadshot = false,
        Distance = IsValid( npc ) and attacker:GetPos():Distance( npc:GetPos() ) or 0
    } )
end )


hook.Add( "PlayerDeath", "BricksServerHooks_PlayerDeath_UnboxingStatTrak", function( victim, inflictor, attacker )
    if( not IsValid( victim ) or not victim:IsPlayer() ) then return end

    local inventoryData = victim:GetUnboxingInventoryData()
    local changed = false
    for globalKey, itemData in pairs( inventoryData ) do
        if( not string.StartWith( tostring( globalKey ), "ITEM_" ) ) then continue end

        local profile = (((itemData or {}).StatTrak or {}).Profile or nil)
        if( not istable( profile ) ) then continue end

        profile.CurrentStreak = 0
        profile.LastDeathAt = CurTime()
        inventoryData[globalKey].StatTrak.Profile = profile
        changed = true
    end

    if( changed ) then
        victim:SetUnboxingInventoryData( inventoryData )
    end
end )
