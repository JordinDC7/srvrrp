net.Receive( "BRS.Net.SetGangID", function()
    -- BRS_GANGID = net.ReadUInt( 16 )
    
    timer.Simple( 0.1, function() 
        hook.Run( "BRS.Hooks.RefreshGang" ) 
    end )
end )

net.Receive( "BRS.Net.SetGangTable", function()
    local gangID = net.ReadUInt( 16 )
    local gangTable = net.ReadTable()

    if( not BRICKS_SERVER_GANGS ) then
        BRICKS_SERVER_GANGS = {}
    end

    BRICKS_SERVER_GANGS[gangID] = gangTable

    hook.Run( "BRS.Hooks.RefreshGang" )
end )

net.Receive( "BRS.Net.SetGangTableValues", function()
    local gangID = net.ReadUInt( 16 )
    local valuesTable = net.ReadTable()

    if( not BRICKS_SERVER_GANGS ) then
        BRICKS_SERVER_GANGS = {}
    end

    if( not BRICKS_SERVER_GANGS[gangID] ) then
        BRICKS_SERVER_GANGS[gangID] = {}
    end

    local valuesChanged = {}
    for k, v in pairs( valuesTable ) do
        BRICKS_SERVER_GANGS[gangID][k] = v

        valuesChanged[k] = true
    end

    hook.Run( "BRS.Hooks.RefreshGang", valuesChanged )
end )

net.Receive( "BRS.Net.SetGangTableValue", function()
    local gangID = net.ReadUInt( 16 )
    local tableKey = net.ReadString()

    local dataType = (BRICKS_SERVER.DEVCONFIG.GangTableKeys[tableKey] or {})[2]

    if( not dataType ) then return end

    local tableValue
    if( dataType == "string" ) then
        tableValue = net.ReadString()
    elseif( dataType == "integer" ) then
        tableValue = net.ReadUInt( 32 )
    elseif( dataType == "table" ) then
        tableValue = net.ReadTable()
    end

    if( not tableValue ) then return end
    
    if( not BRICKS_SERVER_GANGS ) then
        BRICKS_SERVER_GANGS = {}
    end

    if( not BRICKS_SERVER_GANGS[gangID] ) then
        BRICKS_SERVER_GANGS[gangID] = {}
    end

    BRICKS_SERVER_GANGS[gangID][tableKey] = tableValue 

    hook.Run( "BRS.Hooks.RefreshGang", { [tableKey] = true } )
end )