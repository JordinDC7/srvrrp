local circleSize = 50
hook.Add( "PostPlayerDraw", "BricksServerHooks_PostPlayerDraw_DrawGangEntityDisplay", function( ply )
    if( not LocalPlayer():HasGang() ) then return end

    if( not IsValid( ply ) or not ply:Alive() or ply == LocalPlayer() ) then return end

    local drawColor

    if( ply:HasGang() and ply:GetGangID() == LocalPlayer():GetGangID() ) then 
        drawColor = BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen
    elseif( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "associations" ) ) then
        local associationType = LocalPlayer():GetGangAssociationWith( ply )
        if( associationType ) then 
            drawColor = (BRICKS_SERVER.DEVCONFIG.GangAssociationTypes[associationType] or {}).Color
        end
    end
    
	if( not drawColor ) then return end
    
    local Distance = LocalPlayer():GetPos():DistToSqr( ply:GetPos() )
    if( Distance > BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then return end

    cam.Start3D2D( ply:GetPos(), ply:GetAngles(), 0.5 )
        local AlphaMulti = 1-(Distance/BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"])
        surface.SetAlphaMultiplier( AlphaMulti )
            BRICKS_SERVER.Func.DrawArc( 0, 0, circleSize/2, 3, 0, 360, drawColor )
        surface.SetAlphaMultiplier( 1 )
    cam.End3D2D()
end )