-- Applies Elite Arsenal rolled unboxing stats to equipped unboxing weapons.
if( CLIENT ) then return end

local function brsGetPlayerFromWeaponOwner( owner )
    if( IsValid( owner ) and owner:IsPlayer() ) then return owner end
    return nil
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

    brsAwardWeaponProgressionXP( attacker, statScalars.GlobalKey, "HitXP" )
    if( IsValid( target ) and target:IsPlayer() and target:Health() > 0 and (target:Health() - dmgInfo:GetDamage()) <= 0 ) then
        brsAwardWeaponProgressionXP( attacker, statScalars.GlobalKey, "KillXP" )
    end

    dmgInfo:ScaleDamage( tonumber( statScalars.DamageScale ) or 1 )
end )
