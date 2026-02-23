--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561199109663690)

SERVERSIDE FILE
]]--

function THIRDPERSON.getData( key )
    if key ~= "all" and THIRDPERSON.dataTable[ key ] == nil then
        return false;
    end

    if file.Exists( "thirdperson/data.txt", "DATA" ) then
        local fileContents = file.Read( "thirdperson/data.txt", "DATA" );
        if key == "all" then
            return util.JSONToTable( fileContents );
        else
            local returnData = util.JSONToTable( fileContents );

            if returnData[ key ] == nil then
                returnData.key = THIRDPERSON.dataTable.key;  
            end

            return returnData[ key ];
        end
    else
        if key == "all" then
            return THIRDPERSON.dataTable;
        else
            return THIRDPERSON.dataTable[ key ];
        end
    end
end

function THIRDPERSON.writeData( key, value )
    if THIRDPERSON.dataTable[ key ] == nil then
        return false;
    end

    local dataTable = THIRDPERSON.getData( "all" );
    dataTable[ key ] = value;

    file.Write( "thirdperson/data.txt", util.TableToJSON( dataTable ) );
end

function THIRDPERSON.init()
    if (THIRDPERSON.permissionsSupport) then
        if ( ulx ) then
            MsgC( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Detected the admin mod ", Color(0, 116, 240), "ULX", Color(255, 255, 255), " on this server. Compatibility enabled.\n" );
        end
        if ( serverguard ) then
            MsgC( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Detected the admin mod ", Color(0, 116, 240), "ServerGuard", Color(255, 255, 255), " on this server. Compatibility enabled.\n" );
        end
        if ( evolve ) then
            MsgC( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Detected the admin mod ", Color(0, 116, 240), "Evolve", Color(255, 255, 255), " on this server. Compatibility enabled.\n" );
        end
        if ( THIRDPERSON.detectRealxAdmin() ) then
            MsgC( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Detected the admin mod ", Color(0, 116, 240), "xAdmin", Color(255, 255, 255), " on this server. Compatibility enabled.\n" );
        end
        if ( sam ) then
            MsgC( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Detected the admin mod ", Color(0, 116, 240), "SAM", Color(255, 255, 255), " on this server. Compatibility enabled.\n" );
        end
        if ( CAMI and ( not THIRDPERSON.detectRealxAdmin() and not sam and not ulx and not evolve and not ServerGuard ) ) then
            MsgC( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Detected a CAMI interfacable admin mod or addon. Compatibility enabled.\n" );
        end

        if ulx or serverguard or evolve or THIRDPERSON.detectRealxAdmin() or sam or CAMI then
            local SuperAdminAccess = {
                "thirdperson_preventwallcollisions",
            };

            local AdminAccess = {

            };

            local UserAccess = {
                "thirdperson_view",
                "thirdperson_crosshair",
                "thirdperson_crosshaircolor",
                "thirdperson_scoping",
                "thirdperson_bulletcorrection",
                "thirdperson_distance",
                "thirdperson_viewangles",
                "thirdperson_entityview",
            };

            if unpack( THIRDPERSON.access.User ) ~= unpack( UserAccess ) or unpack( THIRDPERSON.access.Admin ) ~= unpack( AdminAccess ) or unpack( THIRDPERSON.access.SuperAdmin ) ~= unpack( SuperAdminAccess ) then
                MsgC( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 50 ,50), "Warning: ", Color(255, 255, 255), "You have changed the default access permissions via the config but a compatible admin mod has been detected on this server. Use the permissions system in your admin mod instead..\n" );
            end
        else
            MsgC( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "No compatible admin mods were detected. Diverting to the inbuilt permissions system (see config).\n" );
        end
    else
        MsgC( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "You have permissions support explicitly disabled (THIRDPERSON.permissionsSupport) in the config. Diverting to the inbuilt permissions system (see config).\n" );
    end
end

hook.Add( "InitPostEntity", "thirdperson_init", THIRDPERSON.init );

local function chatThirdPerson( pl, text, public )
    if ( table.HasValue( THIRDPERSON.toggleCommands, string.lower( text ) ) ) then
        pl:ConCommand( "thirdperson_toggle" );
        return "";
    end
    if ( table.HasValue( THIRDPERSON.menuCommands, string.lower( text ) ) ) then
        pl:ConCommand( "thirdperson_menu" );
        return "";
    end
end

hook.Add( "PlayerSay", "chatThirdPerson", chatThirdPerson );

util.AddNetworkString("THIRDPERSON.SendClientInfo")

net.Receive("THIRDPERSON.SendClientInfo", function(len, pl)
    local configuration = net.ReadString()
    local curTime = CurTime()
    pl.ThirdPersonNetRateLimit = pl.ThirdPersonNetRateLimit or {}
    local netRateLimit = pl.ThirdPersonNetRateLimit[configuration]
    if netRateLimit and netRateLimit > curTime then
        return
    end

    pl.ThirdPersonNetRateLimit[configuration] = curTime + 1

    if (not IsValid(pl)) then
        return
    end

    local dataType = THIRDPERSON.configuration[configuration]
    if (not dataType) then
        return
    end

    local value = nil

    if dataType == "bool" then
        value = net.ReadBool()
    elseif dataType == "number" then
        value = net.ReadInt(24)
    elseif dataType == "string" then
        value = net.ReadString()
    end

    if (not configuration or value == nil) then
        return
    end

    local steamId = pl:SteamID64()
    THIRDPERSON.clients[steamId] = THIRDPERSON.clients[steamId] or {}
    THIRDPERSON.clients[steamId][configuration] = value
end)

hook.Add("PlayerDisconnected", "THIRDPERSON.CleanupClientData", function(pl)
    THIRDPERSON.clients[pl:SteamID64()] = nil
end)
