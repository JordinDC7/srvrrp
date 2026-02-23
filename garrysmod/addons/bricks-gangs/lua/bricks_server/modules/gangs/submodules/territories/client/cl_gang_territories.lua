BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "gangTerritories" ), "bricks_server_config_gang_territories", "gangs" )

BRS_GANG_TERRITORIES = BRS_GANG_TERRITORIES or {}
net.Receive( "BRS.Net.SendGangTerritoriesTable", function()
    BRS_GANG_TERRITORIES = net.ReadTable() or {}

    hook.Run( "BRS.Hooks.RefreshGangTerritories" )
end )

net.Receive( "BRS.Net.SendGangTerritoriesValue", function()
    if( not BRS_GANG_TERRITORIES ) then
        BRS_GANG_TERRITORIES = {}
    end

    BRS_GANG_TERRITORIES[net.ReadUInt( 8 ) or 0] = net.ReadTable() or {}

    hook.Run( "BRS.Hooks.RefreshGangTerritories" )
end )

net.Receive( "BRS.Net.SendTerritoryGangTables", function()
    if( not BRICKS_SERVER_GANGS ) then
        BRICKS_SERVER_GANGS = {}
    end

    for k, v in pairs( net.ReadTable() or {} ) do
        if( not BRICKS_SERVER_GANGS[k] ) then
            BRICKS_SERVER_GANGS[k] = {}
        end

        for key, val in pairs( v ) do
            BRICKS_SERVER_GANGS[k][key] = val
        end
    end

    hook.Run( "BRS.Hooks.RefreshGangTerritories" )
end )

function BRICKS_SERVER.Func.RequestTerritoryGangs()
    if( CurTime() < (BRS_REQUEST_TERRITORYGANG_COOLDOWN or 0) ) then return end

    BRS_REQUEST_TERRITORYGANG_COOLDOWN = CurTime()+10

    net.Start( "BRS.Net.RequestTerritoryGangs" )
    net.SendToServer()
end

function BRICKS_SERVER.Func.RequestTerritoryIconMat( territoryKey )
    if( CurTime() < (BRS_REQUEST_TERRITORYICONMAT_COOLDOWN or 0) ) then return end

    BRS_REQUEST_TERRITORYICONMAT_COOLDOWN = CurTime()+10

    local gangID = (BRS_GANG_TERRITORIES[territoryKey] or {}).GangID

    if( not BRICKS_SERVER_GANGS ) then return end
    
    local iconURL = (BRICKS_SERVER_GANGS[gangID] or {}).Icon
    if( not iconURL or not BRICKS_SERVER.Func.CheckGangIconURL( iconURL ) ) then return end

    if( not string.StartWith( iconURL, "http" ) ) then
        BRS_GANG_TERRITORIES[territoryKey].IconMat = Material( iconURL, "noclamp smooth" )
    end

    BRICKS_SERVER.Func.GetImage( iconURL, function( mat ) 
        BRS_GANG_TERRITORIES[territoryKey].IconMat = mat 
    end )
end