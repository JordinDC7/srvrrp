function BRICKS_SERVER.Func.RefreshGangLeaderboards()
    BRS_GANG_LEADERBOARDS = {}

    local sortValuesRequired, sortValues = {}, {}
    for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Leaderboards or {} ) do
        BRS_GANG_LEADERBOARDS[k] = {}

        if( v.Type and not sortValuesRequired[v.Type] and BRICKS_SERVER.DEVCONFIG.GangLeaderboards[v.Type] ) then
            sortValuesRequired[v.Type] = true
            sortValues[v.Type] = {}
        end
    end

    for k, v in pairs( BRICKS_SERVER_GANGS or {} ) do
        for key, val in pairs( sortValuesRequired ) do
            sortValues[key][k] = BRICKS_SERVER.DEVCONFIG.GangLeaderboards[key].GetSortValue( v )
        end
    end

    for k, v in pairs( sortValues ) do
        local winningGangID = table.GetWinningKey( v )

        if( winningGangID ) then
            for key, val in pairs( BRICKS_SERVER.CONFIG.GANGS.Leaderboards or {} ) do
                if( not val.Type or val.Type != k ) then continue end

                BRS_GANG_LEADERBOARDS[key] = { GangID = winningGangID, SortValue = sortValues[k][winningGangID] }
            end
        end
    end
end

hook.Add( "Initialize", "BricksServerHooks_Initialize_GangLeaderboards", function()
    BRS_GANG_LEADERBOARDS_REFRESH = CurTime()+(BRICKS_SERVER.CONFIG.GANGS["Leaderboard Refresh Time"] or 600)
end )

hook.Add( "BRS.Hooks.GangDataLoaded", "BricksServerHooks_BRS_GangDataLoaded_GangLeaderboards", function()
    BRICKS_SERVER.Func.RefreshGangLeaderboards()

    hook.Add( "Think", "BricksServerHooks_Think_GangLeaderboards", function()
        if( CurTime() >= (BRS_GANG_LEADERBOARDS_REFRESH or 0) )	then
            BRICKS_SERVER.Func.RefreshGangLeaderboards()
            BRS_GANG_LEADERBOARDS_REFRESH = CurTime()+(BRICKS_SERVER.CONFIG.GANGS["Leaderboard Refresh Time"] or 600)
        end
    end )
end )

util.AddNetworkString( "BRS.Net.SendLeaderboardGangTables" )
function BRICKS_SERVER.Func.SendLeaderboardGangTables( ply )
    local gangsToSend = {}
    for k, v in pairs( BRS_GANG_LEADERBOARDS or {} ) do
        if( v.GangID and BRICKS_SERVER_GANGS and BRICKS_SERVER_GANGS[v.GangID] ) then
            local gangTable = BRICKS_SERVER_GANGS[v.GangID]
            gangsToSend[v.GangID] = {
                Name = gangTable.Name or BRICKS_SERVER.Func.L( "nil" ),
                Icon = gangTable.Icon or BRICKS_SERVER.Func.L( "nil" )
            }
        end
    end

    net.Start( "BRS.Net.SendLeaderboardGangTables" )
        net.WriteTable( gangsToSend )
    net.Send( ply )
end

util.AddNetworkString( "BRS.Net.RequestLeaderboardGangs" )
net.Receive( "BRS.Net.RequestLeaderboardGangs", function( len, ply )
    if( CurTime() < (ply.BRS_REQUEST_LEADERBOARDGANG_COOLDOWN or 0) ) then return end

    ply.BRS_REQUEST_LEADERBOARDGANG_COOLDOWN = CurTime()+10

    BRICKS_SERVER.Func.SendLeaderboardGangTables( ply )
end )

util.AddNetworkString( "BRS.Net.SendGangLeaderboardTables" )
function BRICKS_SERVER.Func.SendGangLeaderboardTables( ply )
    net.Start( "BRS.Net.SendGangLeaderboardTables" )
        net.WriteTable( BRS_GANG_LEADERBOARDS or {} )
    net.Send( ply )
end

util.AddNetworkString( "BRS.Net.RequestGangLeaderboards" )
net.Receive( "BRS.Net.RequestGangLeaderboards", function( len, ply )
    if( CurTime() < (ply.BRS_REQUEST_GANGLEADERBOARDS_COOLDOWN or 0) ) then return end

    ply.BRS_REQUEST_GANGLEADERBOARDS_COOLDOWN = CurTime()+1

    BRICKS_SERVER.Func.SendGangLeaderboardTables( ply )
end )

hook.Add( "BRS.Hooks.PlayerGangInitialize", "BricksServerHooks_BRS_PlayerGangInitialize_GangLeaderboards", function( ply )
    BRICKS_SERVER.Func.SendGangLeaderboardTables( ply )
    BRICKS_SERVER.Func.SendLeaderboardGangTables( ply )
end )