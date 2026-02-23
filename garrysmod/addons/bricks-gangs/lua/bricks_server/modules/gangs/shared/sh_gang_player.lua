local playerMeta = FindMetaTable("Player")

function playerMeta:HasGang()
    local gangID = self:GetGangID()
    
    if( not BRICKS_SERVER_GANGS or not BRICKS_SERVER_GANGS[gangID] ) then
        return false
    end

    return gangID
end

function playerMeta:GetGangID()
    -- if( SERVER ) then
    --     return self:GetNW2Int( "BRS_GANGID", 0 )
    -- elseif( CLIENT ) then
    --     if( self == LocalPlayer() ) then 
    --         return BRS_GANGID or self:GetNW2Int( "BRS_GANGID", 0 )
    --     else
    --         return self:GetNW2Int( "BRS_GANGID", 0 )
    --     end
    -- end
    return self:GetNW2Int( "BRS_GANGID", 0 )
end

function playerMeta:HasGangInvite( gangID )
    if( BRS_GANG_INBOXES and BRS_GANG_INBOXES[self:SteamID()] ) then 
        for k, v in pairs( BRS_GANG_INBOXES[self:SteamID()] ) do
            if( istable( v ) and v.Type == "GangInvite" and v.ReqInfo and v.ReqInfo[1] and v.ReqInfo[1] == gangID ) then
                return k
            end
        end
    end

    return false
end

function playerMeta:GangGetGroupData()
    local gangTable = (BRICKS_SERVER_GANGS or {})[self:GetGangID()] or {}

    if( not gangTable or not gangTable.Members or not gangTable.Members[self:SteamID()] or not gangTable.Members[self:SteamID()][2] ) then return false end
    
    local groupID = gangTable.Members[self:SteamID()][2]

    return gangTable.Roles[groupID]
end

function playerMeta:GangHasPermission( permission )
    local gangTable = (BRICKS_SERVER_GANGS or {})[self:GetGangID()] or {}

    if( gangTable.Owner == self:SteamID() ) then return true end

    if( not BRICKS_SERVER.DEVCONFIG.GangPermissions[permission] ) then return false end
    
    local groupData = self:GangGetGroupData()

    if( not groupData or not groupData[3] or not groupData[3][permission] ) then return false end

    return true
end

function playerMeta:GangCanTargetMember( targetPlySteamID )
    local gangTable = (BRICKS_SERVER_GANGS or {})[self:GetGangID()] or {}

    if( not gangTable.Members ) then return end

    local targetPlyTable = gangTable.Members[targetPlySteamID]
    if( not targetPlyTable ) then return false end

    if( gangTable.Owner == self:SteamID() ) then return true end

    local plyTable = gangTable.Members[self:SteamID()]
    if( not plyTable ) then return false end

    if( plyTable[2] >= targetPlyTable[2] ) then return false end

    return true
end

if( SERVER ) then
    util.AddNetworkString( "BRS.Net.SetGangID" )
    function playerMeta:SetGangID( gangID )
        net.Start( "BRS.Net.SetGangID" )
            -- net.WriteUInt( gangID, 16 )
        net.Send( self )
        
        self:SetNW2Int( "BRS_GANGID", (gangID or 0) )
    end
end