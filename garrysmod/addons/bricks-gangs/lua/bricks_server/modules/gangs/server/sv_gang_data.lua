util.AddNetworkString( "BRS.Net.SetGangTableValue" )
util.AddNetworkString( "BRS.Net.SetGangTableValues" )
function BRICKS_SERVER.Func.UpdateGangTable( gangID, ... )
    if( BRICKS_SERVER_GANGS[gangID] ) then
        local varTable = { ... }

        local valuesChanged = {}
        for i = 1, #varTable do
            if( i % 2 == 0 ) then continue end

            if( not varTable[i] or not varTable[i+1] or not isstring( varTable[i] ) or not BRICKS_SERVER.DEVCONFIG.GangTableKeys[varTable[i]] ) then continue end

            local key, value = varTable[i], varTable[i+1]

            if( BRICKS_SERVER.DEVCONFIG.GangTableKeys[key][1] ) then
                BRICKS_SERVER.Func.UpdateGangDB( gangID, (BRICKS_SERVER.DEVCONFIG.GangTableKeys[key][1] or key), (BRICKS_SERVER.DEVCONFIG.GangTableKeys[key][2] != "table" and value) or util.TableToJSON( value ) )
            end

            BRICKS_SERVER_GANGS[gangID][key] = value

            valuesChanged[key] = value
        end

        local onlineMembers = {}
        for k, v in pairs( BRICKS_SERVER_GANGS[gangID].Members ) do
            local ply = player.GetBySteamID( k )

            if( IsValid( ply ) ) then
                table.insert( onlineMembers, ply )
            end
        end

        if( #onlineMembers > 0 ) then
            if( table.Count( valuesChanged ) == 1 ) then
                local key = table.GetKeys( valuesChanged )[1]

                if( not valuesChanged[key] or not BRICKS_SERVER.DEVCONFIG.GangTableKeys[key] ) then return end

                local dataType = BRICKS_SERVER.DEVCONFIG.GangTableKeys[key][2]

                net.Start( "BRS.Net.SetGangTableValue" )
                    net.WriteUInt( gangID, 16 )
                    net.WriteString( key )

                    if( dataType == "string" ) then
                        net.WriteString( valuesChanged[key] )
                    elseif( dataType == "integer" ) then
                        net.WriteUInt( valuesChanged[key], 32 )
                    elseif( dataType == "table" ) then
                        net.WriteTable( valuesChanged[key] )
                    end
                net.Send( onlineMembers )
            else
                net.Start( "BRS.Net.SetGangTableValues" )
                    net.WriteUInt( gangID, 16 )
                    net.WriteTable( valuesChanged )
                net.Send( onlineMembers )
            end
        end
	end
end

function BRICKS_SERVER.Func.CreateGangTable( ownerPly, gangName, gangIcon )
    if( not BRICKS_SERVER_GANGS ) then
        BRICKS_SERVER_GANGS = {}
    end

    local gangTable = {
        Name = gangName,
        Icon = gangIcon,
        Owner = ownerPly:SteamID(),
        Members = { [ownerPly:SteamID()] = { ownerPly:Nick(), 1 } },
        Roles = { 
            { BRICKS_SERVER.Func.L( "gangOwner" ), Color( 231, 76, 60 ), {
                ["DepositItem"] = true,
                ["WithdrawItem"] = true,
                ["ViewItem"] = true,
                ["DepositMoney"] = true,
                ["WithdrawMoney"] = true,
                ["EditRoles"] = true,
                ["EditSettings"] = true,
                ["InvitePlayers"] = true,
                ["KickPlayers"] = true,
                ["ChangePlayerRoles"] = true,
                ["PurchaseUpgrades"] = true,
                ["EditInbox"] = true,
                ["RequestAssociations"] = true,
                ["AcceptAssociations"] = true,
                ["SendMessages"] = true
            } },
            { BRICKS_SERVER.Func.L( "gangOfficer" ), Color( 52, 152, 219 ), {
                ["DepositItem"] = true,
                ["WithdrawItem"] = true,
                ["ViewItem"] = true,
                ["DepositMoney"] = true,
                ["WithdrawMoney"] = true,
                ["InvitePlayers"] = true,
                ["KickPlayers"] = true,
                ["ChangePlayerRoles"] = true,
                ["PurchaseUpgrades"] = true,
                ["EditInbox"] = true,
                ["RequestAssociations"] = true,
                ["AcceptAssociations"] = true,
                ["SendMessages"] = true
            } },
            { BRICKS_SERVER.Func.L( "gangMember" ), Color( 189, 195, 199 ), {
                ["DepositItem"] = true,
                ["ViewItem"] = true,
                ["DepositMoney"] = true,
                ["InvitePlayers"] = true,
                ["SendMessages"] = true
            } }
        }
    }

    local gangID = table.insert( BRICKS_SERVER_GANGS, gangTable )

    ownerPly:SetGangID( gangID )

    BRICKS_SERVER.Func.SendGangTable( ownerPly, gangID )

    BRICKS_SERVER.Func.InsertGangDB( gangID, gangName, gangIcon, ownerPly:SteamID(), gangTable.Members, gangTable.Roles )
end

function BRICKS_SERVER.Func.DeleteGangTable( gangID )
    if( BRICKS_SERVER_GANGS and BRICKS_SERVER_GANGS[gangID] ) then
        local gangTable = BRICKS_SERVER_GANGS[gangID]

        BRICKS_SERVER_GANGS[gangID] = nil

        BRICKS_SERVER.Func.ClearGangFromDB( gangID )

        for k, v in pairs( gangTable.Members ) do
            local ply = player.GetBySteamID( k )

            if( IsValid( ply ) ) then
                ply:SetGangID( 0 )
            end
        end

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "printers" ) and BRS_ACTIVE_GANGPRINTERS and BRS_ACTIVE_GANGPRINTERS[gangID] ) then
            for k, v in pairs( BRS_ACTIVE_GANGPRINTERS[gangID] ) do
                if( IsValid( v ) ) then
                    v:Remove()
                end 
            end

            BRS_ACTIVE_GANGPRINTERS[gangID] = nil
        end
    end
end

local function loadGangs()
    BRICKS_SERVER_GANGS = {}
    BRICKS_SERVER.Func.FetchGangsDB( function( data )
        for k, v in pairs( data ) do
            BRICKS_SERVER_GANGS[tonumber( v.gangID )] = {
                Name = v.gangName or BRICKS_SERVER.Func.L( "nil" ),
                Icon = v.gangIcon or "",
                Owner = v.owner or "",
                Level = tonumber( v.level or 0 ),
                Experience = tonumber( v.experience or 0 ),
                Money = tonumber( v.money or 0 ),
                Storage = util.JSONToTable( v.storage or "" ) or {},
                Members = util.JSONToTable( v.members or "" ) or {},
                Roles = util.JSONToTable( v.roles or "" ) or {},
                Upgrades = util.JSONToTable( v.upgrades or "" ) or {},
                Achievements = util.JSONToTable( v.achievements or "" ) or {},
                Printers = v.printers or {}
            }
        end

        hook.Run( "BRS.Hooks.GangDataLoaded" )

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "printers" ) ) then
            BRICKS_SERVER.Func.FetchGangPrinterDB( function( data )
                for k, v in pairs( data ) do
                    local gangID = tonumber( v.gangID )

                    if( BRICKS_SERVER_GANGS[gangID] ) then
                        BRICKS_SERVER_GANGS[gangID].Printers = BRICKS_SERVER_GANGS[gangID].Printers or {}
        
                        BRICKS_SERVER_GANGS[gangID].Printers[tonumber(v.printerID)] = {
                            Servers = util.JSONToTable( v.servers or "" ) or {},
                            Upgrades = util.JSONToTable( v.upgrades or "" ) or {}
                        }
                    end
                end
            end )
        end
    end )
end

if( BRICKS_SERVER.INITIALIZE_LOADED ) then
    loadGangs()
else
    hook.Add( "Initialize", "BricksServerHooks_Initialize_Gangs", loadGangs )
end

hook.Add( "BRS.Hooks.PlayerFullLoad", "BricksServerHooks_BRS_PlayerFullLoad_Gangs", function( ply )	
    for k, v in pairs( BRICKS_SERVER_GANGS or {} ) do
        if( (v.Members or {})[ply:SteamID() or ""] ) then
            ply:SetGangID( k )
            BRICKS_SERVER.Func.SendGangTable( ply, k ) 
            break
        end
    end

    hook.Run( "BRS.Hooks.PlayerGangInitialize", ply ) 
end )

util.AddNetworkString( "BRS.Net.SetGangTable" )
function BRICKS_SERVER.Func.SendGangTable( ply, gangID )
    local gangTable = BRICKS_SERVER_GANGS[gangID]

    net.Start( "BRS.Net.SetGangTable" )
        net.WriteUInt( gangID, 16 )
        net.WriteTable( gangTable or {} )
    net.Send( ply )
end