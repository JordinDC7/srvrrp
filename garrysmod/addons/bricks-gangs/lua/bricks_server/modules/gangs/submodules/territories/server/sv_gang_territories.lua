hook.Add( "Initialize", "BricksServerHooks_Initialize_GangTerritories", function()	
    BRS_GANG_TERRITORIES = {}

    for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Territories or {} ) do
        BRS_GANG_TERRITORIES[k] = { 
            Claimed = false
        }
    end
end )

util.AddNetworkString( "BRS.Net.SendTerritoryGangTables" )
function BRICKS_SERVER.Func.SendTerritoryGangTables( ply )
    local gangsToSend = {}
    for k, v in pairs( BRS_GANG_TERRITORIES or {} ) do
        if( v.Claimed and v.GangID and BRICKS_SERVER_GANGS and BRICKS_SERVER_GANGS[v.GangID] ) then
            local gangTable = BRICKS_SERVER_GANGS[v.GangID]
            gangsToSend[v.GangID] = {
                Name = gangTable.Name or BRICKS_SERVER.Func.L( "nil" ),
                Icon = gangTable.Icon or BRICKS_SERVER.Func.L( "nil" )
            }
        end
    end

    net.Start( "BRS.Net.SendTerritoryGangTables" )
        net.WriteTable( gangsToSend )
    net.Send( ply )
end

util.AddNetworkString( "BRS.Net.SendGangTerritoriesTable" )
hook.Add( "BRS.Hooks.PlayerGangInitialize", "BricksServerHooks_BRS_PlayerGangInitialize_GangTerritories", function( ply )	
    if( BRS_GANG_TERRITORIES ) then
        net.Start( "BRS.Net.SendGangTerritoriesTable" )
            net.WriteTable( BRS_GANG_TERRITORIES )
        net.Send( ply )

        BRICKS_SERVER.Func.SendTerritoryGangTables( ply )
    end
end )

util.AddNetworkString( "BRS.Net.SendGangTerritoriesValue" )
util.AddNetworkString( "BRS.Net.SendTerritoryGangValues" )

function BRICKS_SERVER.Func.GangUnCaptureTerritory( gangID, territoryKey )
    if( not gangID or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

    if( not BRICKS_SERVER.Func.GangTerritoryExists( territoryKey ) ) then return end

    if( BRS_GANG_TERRITORIES[territoryKey] and BRS_GANG_TERRITORIES[territoryKey].GangID ) then
        BRICKS_SERVER.Func.GangRemoveTerritoryRewards( BRS_GANG_TERRITORIES[territoryKey].GangID, territoryKey )
    end

    BRS_GANG_TERRITORIES[territoryKey] = { 
        Claimed = false
    }

    net.Start( "BRS.Net.SendGangTerritoriesValue" )
        net.WriteUInt( territoryKey, 8 )
        net.WriteTable( BRS_GANG_TERRITORIES[territoryKey] )
    net.Broadcast()

    if( timer.Exists( "BRS_GangTerritoryRewards_" .. territoryKey ) ) then
        timer.Remove( "BRS_GangTerritoryRewards_" .. territoryKey )
    end
end

function BRICKS_SERVER.Func.GangCaptureTerritory( gangID, territoryKey )
    if( not gangID or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

    if( not BRICKS_SERVER.Func.GangTerritoryExists( territoryKey ) or BRS_GANG_TERRITORIES[territoryKey].Claimed ) then return end

    BRS_GANG_TERRITORIES[territoryKey] = { 
        GangID = gangID,
        Claimed = true,
        ClaimedAt = os.time()
    }

    net.Start( "BRS.Net.SendGangTerritoriesValue" )
        net.WriteUInt( territoryKey, 8 )
        net.WriteTable( BRS_GANG_TERRITORIES[territoryKey] )
    net.Broadcast()

    if( timer.Exists( "BRS_GangTerritoryRewards_" .. territoryKey ) ) then
        timer.Remove( "BRS_GangTerritoryRewards_" .. territoryKey )
    end

    local configTable = BRICKS_SERVER.CONFIG.GANGS.Territories[territoryKey]
    if( configTable.RewardTime and configTable.Rewards and table.Count( configTable.Rewards ) > 0 ) then
        timer.Create( "BRS_GangTerritoryRewards_" .. territoryKey, configTable.RewardTime, 0, function()
            local remove = false
            if( not gangID or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then 
                remove = true
            end

            if( not BRICKS_SERVER.Func.GangTerritoryExists( territoryKey ) or not BRS_GANG_TERRITORIES[territoryKey].Claimed ) then 
                remove = true
            end

            if( remove ) then
                timer.Remove( "BRS_GangTerritoryRewards_" .. territoryKey )
                return
            end

            BRICKS_SERVER.Func.GangGiveTerritoryRewards( gangID, territoryKey )
        end )
    end

    local onlineMembers = {}
    for k, v in pairs( BRICKS_SERVER_GANGS[gangID].Members or {} ) do
        local ply = player.GetBySteamID( k )

        if( IsValid( ply ) ) then
            table.insert( onlineMembers, ply )
        end
    end

    DarkRP.notify( onlineMembers, 0, 5, BRICKS_SERVER.Func.L( "gangTerritoryCaptured", configTable.Name ) )

    hook.Run( "BRS.Hooks.GangTerritoryCaptured", gangID, territoryKey, onlineMembers )
end

function BRICKS_SERVER.Func.GangGiveTerritoryRewards( gangID, territoryKey )
    if( not gangID or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

    if( not BRICKS_SERVER.CONFIG.GANGS.Territories[territoryKey] ) then return end

    local rewards = BRICKS_SERVER.CONFIG.GANGS.Territories[territoryKey].Rewards

    if( not rewards ) then return end

    for k, v in pairs( rewards ) do
        if( BRICKS_SERVER.DEVCONFIG.GangRewards[k] and BRICKS_SERVER.DEVCONFIG.GangRewards[k].RewardFunc ) then
            BRICKS_SERVER.DEVCONFIG.GangRewards[k].RewardFunc( gangID, v )
        end
    end
end

function BRICKS_SERVER.Func.GangRemoveTerritoryRewards( gangID, territoryKey )
    if( not gangID or not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then return end

    if( not BRICKS_SERVER.CONFIG.GANGS.Territories[territoryKey] ) then return end

    local rewards = BRICKS_SERVER.CONFIG.GANGS.Territories[territoryKey].Rewards

    if( not rewards ) then return end

    for k, v in pairs( rewards ) do
        if( BRICKS_SERVER.DEVCONFIG.GangRewards[k] and BRICKS_SERVER.DEVCONFIG.GangRewards[k].UnRewardFunc ) then
            BRICKS_SERVER.DEVCONFIG.GangRewards[k].UnRewardFunc( gangID, v )
        end
    end
end

util.AddNetworkString( "BRS.Net.RequestTerritoryGangs" )
net.Receive( "BRS.Net.RequestTerritoryGangs", function( len, ply )
    if( CurTime() < (ply.BRS_REQUEST_TERRITORYGANG_COOLDOWN or 0) ) then return end

    ply.BRS_REQUEST_TERRITORYGANG_COOLDOWN = CurTime()+10

    BRICKS_SERVER.Func.SendTerritoryGangTables( ply )
end )