util.AddNetworkString( "BRS.Net.RequestGangCommandData" )
util.AddNetworkString( "BRS.Net.SendGangCommandData" )
util.AddNetworkString( "BRS.Net.GangSetMOTD" )
util.AddNetworkString( "BRS.Net.GangSetPriorities" )

BRS_GANG_COMMANDDATA = BRS_GANG_COMMANDDATA or {}

local function sanitizeText( text, maxLen )
    text = string.Trim( tostring( text or "" ) )

    if( string.len( text ) > maxLen ) then
        text = string.sub( text, 1, maxLen )
    end

    return text
end

function BRICKS_SERVER.Func.GangGetCommandData( gangID )
    if( not gangID or gangID <= 0 ) then return false end

    BRS_GANG_COMMANDDATA[gangID] = BRS_GANG_COMMANDDATA[gangID] or {
        MOTD = "",
        Priorities = {},
        Activity = {},
        Contributions = {}
    }

    return BRS_GANG_COMMANDDATA[gangID]
end

function BRICKS_SERVER.Func.GangSendCommandData( gangID, target )
    local commandData = BRICKS_SERVER.Func.GangGetCommandData( gangID )
    if( not commandData ) then return end

    local sendTarget = target
    if( not sendTarget ) then
        sendTarget = {}

        local gangTable = (BRICKS_SERVER_GANGS or {})[gangID]
        for steamID, _ in pairs( (gangTable or {}).Members or {} ) do
            local memberPly = player.GetBySteamID( steamID )
            if( IsValid( memberPly ) ) then
                table.insert( sendTarget, memberPly )
            end
        end
    end

    if( istable( sendTarget ) and #sendTarget <= 0 ) then return end

    net.Start( "BRS.Net.SendGangCommandData" )
        net.WriteUInt( gangID, 16 )
        net.WriteTable( commandData )
    net.Send( sendTarget )
end

function BRICKS_SERVER.Func.GangAddActivity( gangID, message, color, actorSteamID )
    local commandData = BRICKS_SERVER.Func.GangGetCommandData( gangID )
    if( not commandData ) then return end

    table.insert( commandData.Activity, 1, {
        Message = sanitizeText( message, 180 ),
        Time = os.time(),
        Color = color or Color( 200, 200, 200 ),
        ActorSteamID = actorSteamID or ""
    } )

    while( #commandData.Activity > 30 ) do
        table.remove( commandData.Activity, #commandData.Activity )
    end

    BRICKS_SERVER.Func.GangSendCommandData( gangID )
end

function BRICKS_SERVER.Func.GangAddContribution( gangID, memberPly, key, amount )
    if( not IsValid( memberPly ) ) then return end

    local commandData = BRICKS_SERVER.Func.GangGetCommandData( gangID )
    if( not commandData ) then return end

    local steamID = memberPly:SteamID()
    commandData.Contributions[steamID] = commandData.Contributions[steamID] or {
        Name = memberPly:Nick(),
        Deposited = 0,
        Withdrawn = 0,
        UpgradeSpend = 0,
        Actions = 0,
        LastAction = 0
    }

    local contribution = commandData.Contributions[steamID]
    contribution.Name = memberPly:Nick()
    contribution.Actions = (contribution.Actions or 0)+1
    contribution.LastAction = os.time()

    if( key == "Deposited" ) then
        contribution.Deposited = (contribution.Deposited or 0)+math.max( amount or 0, 0 )
    elseif( key == "Withdrawn" ) then
        contribution.Withdrawn = (contribution.Withdrawn or 0)+math.max( amount or 0, 0 )
    elseif( key == "UpgradeSpend" ) then
        contribution.UpgradeSpend = (contribution.UpgradeSpend or 0)+math.max( amount or 0, 0 )
    end

    BRICKS_SERVER.Func.GangSendCommandData( gangID )
end

net.Receive( "BRS.Net.RequestGangCommandData", function( _, ply )
    if( not IsValid( ply ) or not ply:HasGang() ) then return end

    BRICKS_SERVER.Func.GangSendCommandData( ply:GetGangID(), ply )
end )

net.Receive( "BRS.Net.GangSetMOTD", function( _, ply )
    if( not IsValid( ply ) or not ply:HasGang() or not ply:GangHasPermission( "EditSettings" ) ) then return end

    local commandData = BRICKS_SERVER.Func.GangGetCommandData( ply:GetGangID() )
    if( not commandData ) then return end

    commandData.MOTD = sanitizeText( net.ReadString(), 240 )

    BRICKS_SERVER.Func.GangAddActivity( ply:GetGangID(), ply:Nick() .. " updated the gang bulletin.", Color( 63, 180, 255 ), ply:SteamID() )
end )

net.Receive( "BRS.Net.GangSetPriorities", function( _, ply )
    if( not IsValid( ply ) or not ply:HasGang() or not ply:GangHasPermission( "EditSettings" ) ) then return end

    local priorities = net.ReadTable() or {}
    if( not istable( priorities ) ) then return end

    local commandData = BRICKS_SERVER.Func.GangGetCommandData( ply:GetGangID() )
    if( not commandData ) then return end

    local finalPriorities = {}
    for i = 1, math.min( 5, #priorities ) do
        local priorityText = sanitizeText( priorities[i], 80 )
        if( priorityText == "" ) then continue end

        table.insert( finalPriorities, priorityText )
    end

    commandData.Priorities = finalPriorities

    BRICKS_SERVER.Func.GangAddActivity( ply:GetGangID(), ply:Nick() .. " updated operation priorities.", Color( 255, 206, 84 ), ply:SteamID() )
end )
