BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "unboxingVariables" ), "bricks_server_config_unboxing", "unboxing" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "unboxingItems" ), "bricks_server_config_unboxing_items", "unboxing" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "unboxingCases" ), "bricks_server_config_unboxing_cases", "unboxing" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "unboxingKeys" ), "bricks_server_config_unboxing_keys", "unboxing" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "unboxingStoreFull" ), "bricks_server_config_unboxing_store", "unboxing" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "unboxingNotifications" ), "bricks_server_config_unboxing_notifications", "unboxing" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "unboxingCfgDrops" ), "bricks_server_config_unboxing_drops", "unboxing" )

function BRICKS_SERVER.Func.ConfigRemoveUnboxingItem( type, key )
    local globalKey = type .. "_" .. key

    if( type == "ITEM" ) then
        BS_ConfigCopyTable.UNBOXING.Items[key] = nil
    elseif( type == "CASE" ) then
        BS_ConfigCopyTable.UNBOXING.Cases[key] = nil
    elseif( type == "KEY" ) then
        BS_ConfigCopyTable.UNBOXING.Keys[key] = nil
    end

    BS_ConfigCopyTable.UNBOXING.UsedIDs = BS_ConfigCopyTable.UNBOXING.UsedIDs or {}
    BS_ConfigCopyTable.UNBOXING.UsedIDs[type] = BS_ConfigCopyTable.UNBOXING.UsedIDs[type] or {}
    BS_ConfigCopyTable.UNBOXING.UsedIDs[type][key] = true

    for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Cases ) do
        if( v.Items and v.Items[globalKey] ) then
            v.Items[globalKey] = nil
        end
    end

    for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Store.Items ) do
        if( v.GlobalKey == globalKey ) then
            BS_ConfigCopyTable.UNBOXING.Store.Items[k] = nil
        end
    end

    for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Rewards ) do
        if( v[globalKey] ) then
            v[globalKey] = nil
        end
    end

    BS_ConfigCopyTable.UNBOXING.Drops.Items[globalKey] = nil

    BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
end

function BRICKS_SERVER.Func.ConfigGenerateUnboxingID( type )
    local longestUsedKey = 0
    if( BS_ConfigCopyTable.UNBOXING.UsedIDs and BS_ConfigCopyTable.UNBOXING.UsedIDs[type] ) then
        longestUsedKey = table.maxn( BS_ConfigCopyTable.UNBOXING.UsedIDs[type] )
    end

    local longestActiveKey = 0
    for k, v in pairs( ((type == "ITEM" and BS_ConfigCopyTable.UNBOXING.Items) or (type == "KEY" and BS_ConfigCopyTable.UNBOXING.Keys)) or BS_ConfigCopyTable.UNBOXING.Cases ) do
        longestActiveKey = math.max( longestActiveKey, tonumber(string.Replace( k, type .. "_", "" )) )
    end
    
    return math.max( longestUsedKey, longestActiveKey )+1
end

net.Receive( "BRS.Net.SendUnboxingAdminPlayerData", function()
    local steamID64 = net.ReadString()
    local playerData = net.ReadTable()

    hook.Run( "BRS.Hooks.UnboxingAdminPlayerData", steamID64, playerData )
end )

concommand.Add( "unboxing_admin_market_health", function()
    if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

    net.Start( "BRS.Net.RequestUnboxingMarketHealth" )
    net.SendToServer()
end )

concommand.Add( "unboxing_request_odds_history", function( _, _, args )
    local caseKey = tonumber( args[1] or 0 ) or 0

    net.Start( "BRS.Net.RequestUnboxingOddsHistory" )
        net.WriteUInt( math.max( 0, caseKey ), 16 )
    net.SendToServer()
end )

concommand.Add( "unboxing_request_missions", function()
    net.Start( "BRS.Net.RequestUnboxingMissionState" )
    net.SendToServer()
end )

concommand.Add( "unboxing_claim_mission", function( _, _, args )
    local missionID = tostring( args[1] or "" )
    if( missionID == "" ) then return end

    net.Start( "BRS.Net.ClaimUnboxingMissionReward" )
        net.WriteString( missionID )
    net.SendToServer()
end )
