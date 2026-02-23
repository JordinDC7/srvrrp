net.Receive( "BRS.Net.SendAdminGangTables", function()
    hook.Run( "BRS.Hooks.RefreshGangAdmin", net.ReadTable() or {} )
end )

function BRICKS_SERVER.Func.RequestAdminGangs( searchString )
    if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return false end

    if( CurTime() < (BRS_REQUEST_ADMINGANG_COOLDOWN or 0) ) then return false, BRICKS_SERVER.Func.L( "gangRequestCooldown" ), ((BRS_REQUEST_ADMINGANG_COOLDOWN or 0)-CurTime()) end

    BRS_REQUEST_ADMINGANG_COOLDOWN = CurTime()+3

    net.Start( "BRS.Net.RequestAdminGangs" )
        net.WriteString( searchString )
    net.SendToServer()

    return true
end

net.Receive( "BRS.Net.SendAdminGangData", function()
    local gangID = net.ReadUInt( 16 )
    local gangTable = net.ReadTable()

    hook.Run( "BRS.Hooks.RefreshGangAdminData", gangID, gangTable )
end )

function BRICKS_SERVER.Func.RequestAdminGangData( gangID )
    if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return false end

    if( CurTime() < (BRS_REQUEST_ADMINGANGDATA_COOLDOWN or 0) ) then return false, BRICKS_SERVER.Func.L( "gangRequestDataCooldown" ), ((BRS_REQUEST_ADMINGANGDATA_COOLDOWN or 0)-CurTime()) end

    BRS_REQUEST_ADMINGANGDATA_COOLDOWN = CurTime()+2

    net.Start( "BRS.Net.RequestAdminGangData" )
        net.WriteUInt( gangID, 16 )
    net.SendToServer()

    return true
end