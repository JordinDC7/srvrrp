function BRICKS_SERVER.Func.GangsGetAssociation( gang1, gang2 )
    if( not BRS_GANG_ASSOCIATIONS ) then return false end

    if( BRS_GANG_ASSOCIATIONS[gang1] and BRS_GANG_ASSOCIATIONS[gang1][gang2] ) then
        return BRS_GANG_ASSOCIATIONS[gang1][gang2]
    end

    if( BRS_GANG_ASSOCIATIONS[gang2] and BRS_GANG_ASSOCIATIONS[gang2][gang1] ) then
        return BRS_GANG_ASSOCIATIONS[gang2][gang1]
    end

    return false
end

function BRICKS_SERVER.Func.GangHasAssociationInvite( toGang, fromGang )
    if( BRS_GANG_INBOXES and BRS_GANG_INBOXES[toGang] ) then 
        for k, v in pairs( BRS_GANG_INBOXES[toGang] ) do
            if( istable( v ) and v.Type == "AssociationInvite" and v.ReqInfo and v.ReqInfo[1] and v.ReqInfo[1] == fromGang ) then
                return k
            end
        end
    end

    return false
end

local playerMeta = FindMetaTable("Player")
function playerMeta:GetGangAssociationWith( otherPly )
    local gang1, gang2 = self:GetGangID(), otherPly:GetGangID()

    if( not gang1 or not gang2 ) then return false end

    return BRICKS_SERVER.Func.GangsGetAssociation( gang1, gang2 )
end