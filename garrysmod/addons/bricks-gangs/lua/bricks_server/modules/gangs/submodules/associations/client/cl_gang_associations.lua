net.Receive( "BRS.Net.SendGangAssociations", function()
    if( not BRS_GANG_ASSOCIATIONS ) then
        BRS_GANG_ASSOCIATIONS = {}
    end

    for k, v in pairs( net.ReadTable() or {} ) do
        if( not BRS_GANG_ASSOCIATIONS[k] ) then
            BRS_GANG_ASSOCIATIONS[k] = v
            continue
        end

        table.Merge( BRS_GANG_ASSOCIATIONS[k], v )
    end

    hook.Run( "BRS.Hooks.RefreshGangAssociations" )
end )

net.Receive( "BRS.Net.SendGangAssociationValue", function()
    local gang1ID = net.ReadUInt( 16 )
    local gang2ID = net.ReadUInt( 16 )
    local associationType = net.ReadString()

    if( not BRS_GANG_ASSOCIATIONS ) then
        BRS_GANG_ASSOCIATIONS = {}
    end

    if( BRS_GANG_ASSOCIATIONS[gang2ID] and BRS_GANG_ASSOCIATIONS[gang2ID][gang1ID] ) then
        BRS_GANG_ASSOCIATIONS[gang2ID][gang1ID] = nil
    end

    if( not BRS_GANG_ASSOCIATIONS[gang1ID] ) then
        BRS_GANG_ASSOCIATIONS[gang1ID] = {}
    end

    if( associationType and BRICKS_SERVER.DEVCONFIG.GangAssociationTypes[associationType] ) then
        BRS_GANG_ASSOCIATIONS[gang1ID][gang2ID] = associationType
    else
        BRS_GANG_ASSOCIATIONS[gang1ID][gang2ID] = nil
    end

    hook.Run( "BRS.Hooks.RefreshGangAssociations" )
end )

net.Receive( "BRS.Net.SendAssociationGangTables", function()
    hook.Run( "BRS.Hooks.RefreshGangAssociations", net.ReadTable() or {} )
end )

function BRICKS_SERVER.Func.RequestAssociationGangs( searchString )
    if( CurTime() < (BRS_REQUEST_ASSOCIATIONGANG_COOLDOWN or 0) ) then return false, BRICKS_SERVER.Func.L( "gangRequestCooldown" ), ((BRS_REQUEST_ASSOCIATIONGANG_COOLDOWN or 0)-CurTime()) end

    BRS_REQUEST_ASSOCIATIONGANG_COOLDOWN = CurTime()+3

    net.Start( "BRS.Net.RequestAssociationGangs" )
        net.WriteString( searchString )
    net.SendToServer()

    return true
end