function BRICKS_SERVER.Func.GetGangExpToLevel( from, to )
    local totalExp = 0

    for i = 0, (to-from)-1 do
        local levelExp = BRICKS_SERVER.CONFIG.GANGS["Original EXP Required"]*(BRICKS_SERVER.CONFIG.GANGS["EXP Required Increase"]^(from+i) )
        totalExp = totalExp+levelExp
    end

    return totalExp
end

function BRICKS_SERVER.Func.GetGangCurLevelExp( gangID )
    local gangTable = (BRICKS_SERVER_GANGS or {})[gangID or 0]

    if( not gangTable ) then
        return 0
    end

    return (gangTable.Experience or 0)-BRICKS_SERVER.Func.GetGangExpToLevel( 0, gangTable.Level or 0 )
end

function BRICKS_SERVER.Func.GangGetLevel( gangID )
    local gangTable = (BRICKS_SERVER_GANGS or {})[gangID or 0]

    if( not gangTable ) then
        return 0
    end

    return gangTable.Level or 0
end

function BRICKS_SERVER.Func.FormatGangEXP( number )
	local finalString = number
	
	if( finalString > 1000000 ) then
		finalString = math.Round( finalString/1000000, 1 ) .. "M"
	elseif( finalString > 1000 ) then
		finalString = math.Round( finalString/1000, 1 ) .. "K"
	else
		finalString = math.Round( finalString )
	end

	return finalString
end

function BRICKS_SERVER.Func.GangGetUpgradeInfo( gangID, key, newGangTable )
    local gangTable = (not newGangTable and ((BRICKS_SERVER_GANGS or {})[gangID] or {})) or newGangTable

    local upgradesConfig = (BRICKS_SERVER.CONFIG.GANGS.Upgrades or {})[key] or {}
    local upgradesConfigTiers = upgradesConfig.Tiers or {}

    if( not gangTable or not gangTable.Upgrades or not gangTable.Upgrades[key] ) then
        return upgradesConfig.Default or {}
    end
    
    local upgrade = math.Clamp( (gangTable.Upgrades[key] or 1), 0, #upgradesConfigTiers )

    local reqInfo, devConfigReqInfo = (upgradesConfigTiers[upgrade] or {}).ReqInfo, (BRICKS_SERVER.DEVCONFIG.GangUpgrades[key] or {}).ReqInfo or {}
    if( reqInfo and #reqInfo >= #devConfigReqInfo ) then
        return reqInfo
    else
        local reqInfoDefault = {}
        for k, v in pairs( devConfigReqInfo ) do
            if( v[2] == "integer" ) then
                reqInfoDefault[k] = 0
            elseif( v[2] == "table" ) then
                reqInfoDefault[k] = {}
            else
                reqInfoDefault[k] = ""
            end
        end

        return reqInfoDefault
    end
end

function BRICKS_SERVER.Func.GangGetUpgradeBought( gangID, key )
    local gangTable = (BRICKS_SERVER_GANGS or {})[gangID] or {}

    if( gangTable and gangTable.Upgrades and gangTable.Upgrades[key] and gangTable.Upgrades[key] > 0 ) then
        return true
    end

    return false
end

function BRICKS_SERVER.Func.GangGetInboxReqInfo( receiverKey, inboxKey )
    if( BRS_GANG_INBOXES and BRS_GANG_INBOXES[receiverKey] and BRS_GANG_INBOXES[receiverKey][inboxKey] and BRS_GANG_INBOXES[receiverKey][inboxKey].ReqInfo ) then 
        return BRS_GANG_INBOXES[receiverKey][inboxKey].ReqInfo
    end

    return false
end

function BRICKS_SERVER.Func.CheckGangName( name )
	local nameLen = string.len( name )
	if( nameLen > BRICKS_SERVER.DEVCONFIG.GangNameCharMax or nameLen < BRICKS_SERVER.DEVCONFIG.GangNameCharMin ) then return false end

	if( string.match( string.Replace( name, " ", "" ), "[%W]" ) ) then return false end

    return true
end

function BRICKS_SERVER.Func.CheckGangIconURL( url )
    if( not string.StartWith( url, "http" ) ) then
        for k, v in ipairs( BRICKS_SERVER.DEVCONFIG.PresetGangIcons ) do
            if( url == v ) then return true end
        end

        return false
    end

    if( string.len( url ) > BRICKS_SERVER.DEVCONFIG.GangIconCharLimit ) then return false end 

    local validImageEndings = { ".png", ".jpg", ".jpeg" }
    local foundValidEnding = false
    for k, v in ipairs( validImageEndings ) do
        if( not string.EndsWith( url, v ) ) then continue end

        foundValidEnding = true
        break
    end

    if( not foundValidEnding ) then return false end

    for k, v in ipairs( BRICKS_SERVER.DEVCONFIG.GangURLWhitelist ) do
        if( string.StartWith( url, v ) ) then return true end
    end

    return false
end