function BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
    if( territoryKey and BRS_GANG_TERRITORIES and BRS_GANG_TERRITORIES[territoryKey] ) then return BRS_GANG_TERRITORIES[territoryKey] end

    if( BRICKS_SERVER.CONFIG.GANGS.Territories[territoryKey] ) then
        if( not BRS_GANG_TERRITORIES ) then
            BRS_GANG_TERRITORIES = {}
        end

        BRS_GANG_TERRITORIES[territoryKey] = { 
            Claimed = false
        }

        return BRS_GANG_TERRITORIES[territoryKey]
    end

    return false
end