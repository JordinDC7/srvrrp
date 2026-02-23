function BRICKS_SERVER.Func.GangGetAchievementCompleted( gangID, key )
    local gangTable = (BRICKS_SERVER_GANGS or {})[gangID] or {}

    if( gangTable and gangTable.Achievements and gangTable.Achievements[key] and gangTable.Achievements[key] == true ) then
        return true
    end

    return false
end