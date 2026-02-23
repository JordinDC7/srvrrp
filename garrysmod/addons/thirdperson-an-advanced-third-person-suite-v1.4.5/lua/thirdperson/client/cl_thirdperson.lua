--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561199109663690)

CLIENTSIDE FILE
]]--

function THIRDPERSON.getCrosshairColor()
    if THIRDPERSON.hasPermission( LocalPlayer(), "thirdperson_crosshaircolor" ) then
        local r = cvars.Number( "thirdperson_crosshair_color_r" );
        local g = cvars.Number( "thirdperson_crosshair_color_g" );
        local b = cvars.Number( "thirdperson_crosshair_color_b" );
        local a = cvars.Number( "thirdperson_crosshair_color_a" );

        return Color( r, g, b, a );
    else
        local colors = string.Explode( ",", string.gsub( THIRDPERSON.default.CrosshairColor, "%s+", "" ) );

        local r = tonumber( colors[1] );
        local g = tonumber( colors[2] );
        local b = tonumber( colors[3] );
        local a = tonumber( colors[4] );
        
        return Color( r, g, b, a );
    end
end

function THIRDPERSON.resetSetting( pl, cmd, setting )
    setting = setting[1];

    if ( setting == nil or ( THIRDPERSON.permissions[ "thirdperson_" .. setting ] == nil and setting ~= "all" and setting ~= "crosshaircolor" ) ) then
        if ( THIRDPERSON.broadcastChat ) then
            chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Please provide a valid setting to reset. If all, use the argument 'all'." );
        end
        return;
    end

    function resetCrosshairColor()
        local colors = string.Explode( ",", string.gsub( THIRDPERSON.default.CrosshairColor, "%s+", "" ) );

        local r = tonumber( colors[1] );
        local g = tonumber( colors[2] );
        local b = tonumber( colors[3] );
        local a = tonumber( colors[4] );
        
        RunConsoleCommand( "thirdperson_crosshair_color_r", r );
        RunConsoleCommand( "thirdperson_crosshair_color_g", g );
        RunConsoleCommand( "thirdperson_crosshair_color_b", b );
        RunConsoleCommand( "thirdperson_crosshair_color_a", a );
    end

    if setting == "all" then
        for permission, configuration in pairs( THIRDPERSON.permissions ) do
            if permission == "thirdperson_view" then
                continue;
            end
            local value = THIRDPERSON.default[ configuration ];
            if type( value ) == "boolean" then
                RunConsoleCommand( permission, THIRDPERSON.boolToNumber( value ) );
            else
                RunConsoleCommand( permission, value );
            end
        end

        resetCrosshairColor();

        if ( THIRDPERSON.broadcastChat ) then
            chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "All Third-Person settings have been reset to their default values." );
        end
    elseif setting == "crosshaircolor" then
        resetCrosshairColor();
        if ( THIRDPERSON.broadcastChat ) then
            chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "The ", Color(243, 156, 18), "crosshaircolor", Color(255, 255, 255), " setting has been reset to its default value." );
        end
    else
        local value = THIRDPERSON.default[ THIRDPERSON.permissions[ "thirdperson_" .. setting ] ];

        if type( value ) == "boolean" then
            RunConsoleCommand( "thirdperson_" .. setting, THIRDPERSON.boolToNumber( value ) );
        else
            RunConsoleCommand( "thirdperson_" .. setting, value );
        end

        if ( THIRDPERSON.broadcastChat ) then
            chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "The ", Color(243, 156, 18), setting, Color(255, 255, 255), " setting has been reset to its default value." );
        end
    end
end

local function autoCompleteReset()
    local tbl = { "thirdperson_reset all", "thirdperson_reset crosshaircolor" };

    for configuration, type in pairs( THIRDPERSON.configuration ) do
        configuration = string.gsub( configuration, "thirdperson_", "" );
        table.insert( tbl, "thirdperson_reset " .. configuration );
    end

    return tbl;
end

concommand.Add( "thirdperson_reset", THIRDPERSON.resetSetting, autoCompleteReset );

local function toggleThirdPerson()
    if THIRDPERSON.Setting("thirdperson_view") then
        RunConsoleCommand( "thirdperson_view", "0" );

        if THIRDPERSON.hasPermission( LocalPlayer(), "thirdperson_view" ) then
            if ( THIRDPERSON.broadcastChat ) then
                chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Third-person mode has been disabled." );
            end
        else
            if ( THIRDPERSON.broadcastChat ) then
                chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 50 ,50), "Error: ", Color(255, 255, 255), "You do not have permission to change your third-person state." );
            end
        end
    else
        RunConsoleCommand( "thirdperson_view", "1" );

        if THIRDPERSON.hasPermission( LocalPlayer(), "thirdperson_view" ) then
            if ( THIRDPERSON.broadcastChat ) then
                chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Third-person mode has been enabled. Use ", Color(243, 156, 18), THIRDPERSON.menuCommands[1], Color(255, 255, 255), " for settings." );
            end
        else
            if ( THIRDPERSON.broadcastChat ) then
                chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 50 ,50), "Error: ", Color(255, 255, 255), "You do not have permission to change your third-person state." );
            end
        end
    end
end

concommand.Add( "thirdperson_toggle", toggleThirdPerson ); -- ConCommand. Changing this *will* break the addon.
    
local function DrawThirdPerson( pl )
    if THIRDPERSON.Setting("thirdperson_view") and ( LocalPlayer():Alive() and LocalPlayer():IsValid() ) then

        -- Weapon Scope Compatibility --                                                                                                                                                                                                                                                            // 76561223073791539
        local weapon = pl:GetActiveWeapon();

        if THIRDPERSON.runChecks( weapon ) then
            return;
        end
        -- --

        return true;
    end
end
    
hook.Add( "ShouldDrawLocalPlayer", "THIRDPERSON.DrawThirdperson", DrawThirdPerson );
    
local function chatThirdPerson( pl, text, teamChat, isDead )
    if ( pl != LocalPlayer() ) then
        return;
    end

    if ( string.lower( text ) == "!thirdperson entity" ) then

        if ( not LocalPlayer():IsAdmin() ) then
            if ( THIRDPERSON.broadcastChat ) then
                chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(192, 57, 43), "Admin: ", Color(255, 255, 255), "You do not have access to this command." );
            end
            return true;
        end

        local ent = {};
        ent.entity = LocalPlayer():GetEyeTrace().Entity;

        if ent.entity:IsValid() then
            ent.distance = LocalPlayer():EyePos():Distance( ent.entity:GetPos() );
            ent.class = ent.entity:GetClass();
        else
            ent.entity = nil;
            ent.distance = nil;
            ent.class = nil;
        end

        if ( ent.entity == nil or ent.class == nil or ent.distance == nil ) then
            chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(192, 57, 43), "Admin: ", Color(255, 255, 255), "No entities were found. Please look directly at the entity before running the command." );
            return true;
        else
            chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(192, 57, 43), "Admin: ", Color(255, 255, 255), "The entity you are looking at is: ", Color(61, 61, 61), ent.class, Color(255, 255, 255), " (distance: " .. math.Round( ent.distance ) ..")" );
            return true;
        end
    end
end

hook.Add( "OnPlayerChat", "THIRDPERSON.chatThirdPersonClient", chatThirdPerson );

THIRDPERSON.bindDown = false;

function THIRDPERSON.bindThirdPerson()
    if ( THIRDPERSON.Setting("thirdperson_bind") ~= "none" and THIRDPERSON.Setting("thirdperson_bind") ~= nil ) then
        local bind = input.GetKeyCode( THIRDPERSON.Setting("thirdperson_bind") );

        local validBind = ( bind >= KEY_FIRST and bind <= KEY_LAST )
        if ( not LocalPlayer():IsTyping() and not gui.IsGameUIVisible() and bind and bind ~= KEY_ESCAPE and ( ( validBind and input.IsKeyDown( bind ) ) or ( input.IsMouseDown( bind ) and not validBind ) ) ) then
            local focusedPanel = vgui.GetKeyboardFocus()
            if not focusedPanel then
                if ( not THIRDPERSON.bindDown ) then 
                    RunConsoleCommand( "thirdperson_toggle" );
                end
                THIRDPERSON.bindDown = true;
            end
        else
            THIRDPERSON.bindDown = false;
        end
    end
end

hook.Add( "Think", "THIRDPERSON.bindThirdPerson", THIRDPERSON.bindThirdPerson );

function THIRDPERSON.RunForceCompatibility()
    for _, hookName in pairs(THIRDPERSON.forceHooks) do
        local hooks = hook.GetTable()
        local hookListing = hooks[hookName]

        for index, func in pairs(hookListing) do
            if not isstring(index) or (not string.StartsWith(index, "THIRDPERSON.")) then
                hookListing[index] = function(...)
                    return THIRDPERSON.hookCompatibility(func, ...)
                end
            end
        end
    end
end

--[[
Bullet correction networking fix after GMod update
]]--

local sentInitialClientData = false
THIRDPERSON.QueuedConvars = THIRDPERSON.QueuedConvars or {}

local function processSyncQueue()
    local convars = table.Copy(THIRDPERSON.QueuedConvars)
    THIRDPERSON.QueuedConvars = {}
    for convar, shouldSync in pairs(convars) do
        local dataType = THIRDPERSON.configuration[convar]
        if dataType then
            net.Start("THIRDPERSON.SendClientInfo")
            net.WriteString(convar)

            if dataType == "bool" then
                local newValue = GetConVar(convar):GetBool()
                net.WriteBool(newValue);
            elseif dataType == "number" then
                local newValue = GetConVar(convar):GetInt()
                net.WriteInt(newValue, 24);
            elseif dataType == "string" then
                local newValue = GetConVar(convar):GetString()
                net.WriteString(newValue);
            end

            net.SendToServer()
        end
    end
end

local function queueSync(convar)
    THIRDPERSON.QueuedConvars[convar] = true -- Mark for syncing

    if timer.Exists("THIRDPERSON.QueueSync") then
        return
    end

    THIRDPERSON.syncPending = true
    timer.Create("THIRDPERSON.QueueSync", 1.5, 1, function()
        processSyncQueue()
        THIRDPERSON.syncPending = false
    end)
end

local function syncClientData(convar, oldValue, newValue)
    queueSync(convar, newValue)
end

hook.Add("SetupMove", "THIRDPERSON.syncClientData", function()
    if (sentInitialClientData) then
        hook.Remove("SetupMove", "THIRDPERSON.syncClientData")
        return
    end

    for k, v in pairs(THIRDPERSON.configuration) do
        syncClientData(k, nil, THIRDPERSON.Setting(k))
    end

    timer.Simple(5, function()
        if (THIRDPERSON.forceCompatibility) then
            THIRDPERSON.RunForceCompatibility();
        end
    end)

    sentInitialClientData = true
end);

for configName, dataType in pairs(THIRDPERSON.configuration) do
    cvars.AddChangeCallback(configName, syncClientData)
end

function THIRDPERSON.hookCompatibility(hookFunc, ...)
    if (not isfunction(hookFunc)) then return end

    if THIRDPERSON.Setting("thirdperson_view") and (LocalPlayer():Alive() and LocalPlayer():IsValid()) and not THIRDPERSON.runChecks(LocalPlayer():GetActiveWeapon()) then
        return
    end

    return hookFunc(...)
end
