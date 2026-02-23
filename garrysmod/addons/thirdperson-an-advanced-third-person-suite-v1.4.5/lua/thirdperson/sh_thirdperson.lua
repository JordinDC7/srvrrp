--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561199109663690)

SHARED FILE
]]--
function THIRDPERSON.registerPermission( permission, description, default_access )
    if (THIRDPERSON.permissionsSupport) then
        if ( CAMI ) and not ( ulx or sam or THIRDPERSON.detectRealxAdmin() ) then
            -- Common Admin Mod Interface (CAMI) - https://github.com/glua/CAMI
            -- ULX, SAM, and xAdmin support CAMI, however proper categorization is easily implemented otherwise.
            local CAMI_PRIVILEGE = {
                ["Name"]        = permission,
                ["MinAccess"]   = default_access,
                ["Description"] = description,
            };

            CAMI.RegisterPrivilege( CAMI_PRIVILEGE );
        end
        if ulx and SERVER then
            local access = {};
            access.user       = ULib.ACCESS_ALL;
            access.admin      = ULib.ACCESS_ADMIN;
            access.superadmin = ULib.ACCESS_SUPERADMIN;

            ULib.ucl.registerAccess( permission, access[ default_access ], description, "!ThirdPerson" );
        end
        if sam then
            sam.permissions.add( permission, "!ThirdPerson", default_access );
        end
        if THIRDPERSON.detectRealxAdmin() then
            xAdmin.RegisterPermission( permission, permission, "!ThirdPerson" );
        end
        if evolve and SERVER then
            table.insert( evolve.privileges, permission );

            if THIRDPERSON.evolve.firstrun == true then
                local access = {};
                access.user       = "guest";
                access.admin      = "admin";
                access.superadmin = "superadmin";

                table.insert( evolve.ranks[ access[ default_access ] ].Privileges, permission );

                if default_access == "user" then
                    table.insert( evolve.ranks.respected.Privileges, permission );
                    table.insert( evolve.ranks.admin.Privileges, permission );
                    table.insert( evolve.ranks.superadmin.Privileges, permission );
                end
                if default_access == "admin" then
                    table.insert( evolve.ranks.superadmin.Privileges, permission );
                end
            end
        end
        if serverguard and SERVER then
            if THIRDPERSON.serverguard.firstrun == true then
                function registerSGPerm( unique, permission )
                    local permissions = serverguard.ranks:GetData( unique, "Permissions", {} );
                    permissions[ permission ] = true;

                    serverguard.ranks:SetData( unique, "Permissions", permissions );
                    serverguard.netstream.Start( nil, "sgNetworkRankData", { unique, "Permissions", permissions } );
                    serverguard.ranks:SaveTable( unique );
                end
                
                local access = {};
                access.user       = "user";
                access.admin      = "admin";
                access.superadmin = "superadmin";

                registerSGPerm( access[ default_access ], permission );
                
                if default_access == "user" then
                    registerSGPerm( "admin", permission );
                    registerSGPerm( "superadmin", permission );
                end
                if default_access == "admin" then
                    registerSGPerm( "superadmin", permission );
                end
            end
        end
    end
end

-- In place due to an unrelated copycat admin mod known as xAdmin that is free on GitHub
-- !ThirdPerson does not support that admin mod because of how lacking in
-- features it is (no permissions support). 
-- !ThirdPerson supports the xAdmin that is available on gmodstore.
function THIRDPERSON.detectRealxAdmin()
    if ( xAdmin ) then
        if ( xAdmin["RegisterPermission"] ~= nil and xAdmin["RegisterCategory"] ~= nil and xAdmin["Config"] ~= nil and xAdmin.Config["Name"] ~= nil ) then
            return true;
        end
    end

    return false;
end

THIRDPERSON.nextPermissionCache = nil
THIRDPERSON.permissionCache = {}

function THIRDPERSON.hasPermission( pl, permission )
    if SERVER then
        return true -- Client views cannot be enforced serverside
    end

    local permissionCache = THIRDPERSON.permissionCache

    local curTime = CurTime()
    if not THIRDPERSON.nextPermissionCache or THIRDPERSON.nextPermissionCache < curTime or not permissionCache[permission] then
        THIRDPERSON.nextPermissionCache = curTime + 4
        local hasPermission = THIRDPERSON.hasPermissionInternal(pl, permission)
        permissionCache[permission] = hasPermission

        return hasPermission
    end

    return permissionCache[permission]
end

function THIRDPERSON.hasPermissionInternal( pl, permission )
    if (THIRDPERSON.permissionsSupport) then
        if CAMI then
            -- ULX, xAdmin, SAM, and any other admin mods that support CAMI
            local hasAccess = false;
            CAMI.PlayerHasAccess( pl, permission, function( bool, err )
                hasAccess = bool;
            end );
            
            return hasAccess;
        end
        if serverguard then
            if serverguard.player:HasPermission( pl, permission ) then
                return true;
            end
        end
        if evolve then
            if pl:EV_HasPrivilege( permission ) then
                return true;
            end
        end
    end
    if (THIRDPERSON.permissionsSupport == false) || (not ulx and not serverguard and not evolve and not THIRDPERSON.detectRealxAdmin() and not sam and not CAMI) then
        if pl:IsAdmin() and ( table.HasValue( THIRDPERSON.access.User, permission ) or table.HasValue( THIRDPERSON.access.Admin, permission ) ) then
            return true;
        end
        if pl:IsSuperAdmin() and ( table.HasValue( THIRDPERSON.access.User, permission ) or table.HasValue( THIRDPERSON.access.Admin, permission ) or table.HasValue( THIRDPERSON.access.SuperAdmin, permission ) ) then
            return true;
        end
        if table.HasValue( THIRDPERSON.access.User, permission ) then
            return true;
        end
    end
    
    return false;
end

function THIRDPERSON.boolToNumber( bool )
    if bool == true then
        return 1;
    elseif bool == false then
        return 0;
    end
end

function THIRDPERSON.sharedInit()
    if (THIRDPERSON.permissionsSupport) then
        if ( SERVER ) then
            if not file.Exists( "thirdperson", "DATA" ) then
                file.CreateDir( "thirdperson" );
            end

            if evolve then
                if THIRDPERSON.getData( "evolve" ) == false then
                    THIRDPERSON.writeData( "evolve", true );
                    THIRDPERSON.evolve.firstrun = true;
                end
            else
                if THIRDPERSON.getData( "evolve" ) == true then
                    THIRDPERSON.writeData( "evolve", false );
                end
            end

            if serverguard then
                if THIRDPERSON.getData( "serverguard" ) == false then
                    THIRDPERSON.writeData( "serverguard", true );
                    THIRDPERSON.serverguard.firstrun = true;
                end
            else
                if THIRDPERSON.getData( "serverguard" ) == true then
                    THIRDPERSON.writeData( "serverguard", false );
                end
            end
        end

        if ( THIRDPERSON.detectRealxAdmin() and xAdmin.Config.AddonID == 6310 ) then
            xAdmin.RegisterCategory( "!ThirdPerson", "!ThirdPerson", "xadmin/002-settings.png" );
        end
    end
    
    -- Register Permissions --
    THIRDPERSON.registerPermission( "thirdperson_view", "Ability to use !ThirdPerson", "user" );
    THIRDPERSON.registerPermission( "thirdperson_preventwallcollisions", "Ability to turn on and off wall collisions in third-person.", "superadmin" );
    THIRDPERSON.registerPermission( "thirdperson_entityview", "Whether or not viewing certain entities should temporarily switch to first-person.", "user" );
    THIRDPERSON.registerPermission( "thirdperson_crosshair", "Ability to customize their crosshair while in third-person.", "user" );
    THIRDPERSON.registerPermission( "thirdperson_crosshaircolor", "Ability to change the color of their crosshair while in third-person.", "user" );
    THIRDPERSON.registerPermission( "thirdperson_scoping", "Ability to turn on and off first-person scoping while in third-person.", "user" );
    THIRDPERSON.registerPermission( "thirdperson_bulletcorrection", "Ability to turn on and off third-person bullet correction.", "user" );
    THIRDPERSON.registerPermission( "thirdperson_distance", "Ability to change third-person view distance.", "user" );
    THIRDPERSON.registerPermission( "thirdperson_viewangles", "Ability to change third-person vertical and horizontal views.", "user" );
    THIRDPERSON.registerPermission( "thirdperson_bind", "Ability to bind a key to !ThirdPerson.", "user" );
    -- --
end

hook.Add("InitPostEntity", "thirdperson_shared_init", THIRDPERSON.sharedInit);

-- This function is courtesy of !ThirdPerson 2, where some optimizations & fixes have been backported.
function THIRDPERSON.client.Setting(setting)
    if (not CLIENT) then
        return
    end

    local permission;

    if (setting == "thirdperson_verticalview" or setting == "thirdperson_horizontalview" or setting == "thirdperson_angleyaw" or setting == "thirdperson_anglepitch") then
        permission = "thirdperson_viewangles";
    else
        permission = setting;
    end

    local configuration = THIRDPERSON.permissions[setting]
    local cvarValue = THIRDPERSON.default[configuration];

    if (THIRDPERSON.hasPermission(LocalPlayer(), permission)) then
        if (THIRDPERSON.configuration[setting]  == "bool") then
            cvarValue = cvars.Bool(setting);
        elseif (THIRDPERSON.configuration[setting] == "number") then
            cvarValue = cvars.Number(setting);
        elseif (THIRDPERSON.configuration[setting] == "string") then
            cvarValue = cvars.String(setting);
        end
    end

    return cvarValue;
end

function THIRDPERSON.Setting(setting, pl)
    if (CLIENT and IsValid(LocalPlayer())) then
        return THIRDPERSON.client.Setting(setting)
    end

    if (not pl) then
        return
    end

    -- Then access as server
    local clientData = THIRDPERSON.clients[pl:SteamID64()];
    if (not clientData) then
        return
    end

    return clientData[setting]
end

function THIRDPERSON.runChecks(weapon, pl, skipNoclipCheck)
    if (not pl and SERVER) then
        return
    elseif (not pl) then // CLIENT
        pl = LocalPlayer()
    end

    -- Zoom Compatibility --
    if pl:KeyDown( IN_ZOOM ) and pl:GetCanZoom() then
        return true;
    end
    -- --

    -- Observer Mode & Noclip Compatibility --
    if pl:GetObserverMode() ~= OBS_MODE_NONE or (not skipNoclipCheck and pl:GetMoveType() == MOVETYPE_NOCLIP) then
        return true;
    end
    -- --

    -- Vehicle & Sit Anywhere Compatibility --
    if pl:InVehicle() && (pl:GetVehicle():GetClass() ~= "prop_vehicle_prisoner_pod") then
        return true;
    end
    -- --

    -- Spectator Team  --
    if pl:Team() == TEAM_SPECTATOR then
        return true;
    end
    -- --

    -- Solaris --
    if WATCHING_CAM then
        return true;
    end
    -- --

    -- Custom Hooks --
    local showThirdpersonView = hook.Run("THIRDPERSON.ShowThirdpersonView", pl, weapon)

    if showThirdpersonView ~= nil and showThirdpersonView == false then
        return true;
    end
    -- --

    if IsValid(weapon) then
        -- Weapon Scoping Support --
        if THIRDPERSON.Setting("thirdperson_scoping", pl) then
            -- General Iron Sights and M9K Support --
            if ( weapon.GetIronsights and weapon:GetIronsights() ) and not pl:KeyDown( IN_SPEED ) then
                return true;
            end
            -- --

            -- FA:S 2 Support --
            -- https://steamcommunity.com/sharedfiles/filedetails/?id=180507408 --
            if weapon.IsFAS2Weapon and weapon.dt and ( weapon.dt.Status == FAS_STAT_ADS or weapon.dt.Status == FAS_STAT_CUSTOMIZE ) then
                return true;
            end
            -- --

            -- Customizable Weaponry 2.0 Support --
            -- https://steamcommunity.com/sharedfiles/filedetails/?id=349050451 --
            if weapon.CW20Weapon and weapon.dt then
                if weapon.dt.State == CW_CUSTOMIZE then
                    return true;
                end
                if weapon.dt.State == CW_AIMING then
                    return true;
                end
            end
            -- --

            -- TFA Support --
            -- https://steamcommunity.com/sharedfiles/filedetails/?id=2840031720 --
            if ( weapon.IsTFAWeapon and weapon:GetIronSights() ) then
                return true;
            end
            -- --

            -- ArcCW Weapons Support --
            -- https://steamcommunity.com/sharedfiles/filedetails/?id=2131057232 --
            if (weapon.ArcCW and (weapon:GetState() == 1 or weapon:GetState() == 4)) then
                return true;
            end
            -- --

            -- ARC9 Weapons Support --
            -- https://github.com/HaodongMo/ARC-9/ https://steamcommunity.com/sharedfiles/filedetails/?id=2910505837 --
            if (weapon.ARC9 and (weapon:GetInSights() or weapon:GetInspecting() or weapon:GetCustomize())) then
                return true;
            end
            -- --

            -- Modern Warfare Support --
            -- https://steamcommunity.com/sharedfiles/filedetails/?id=2459720887 --
            if (weapons.IsBasedOn(weapon:GetClass(), "mg_base") and pl:KeyDown(IN_ATTACK2)) then
                return true;
            end
            -- --

            -- Arctic's Tactical RP Weapons (TacRP) Support --
            -- https://steamcommunity.com/sharedfiles/filedetails/?id=2588031232 --
            if (weapon.ArcticTacRP and weapon:IsInScope()) then
                return true;
            end
            -- -- 

        end
        -- --

        -- gPhone Support --
        if weapon:GetClass() == "gmod_gphone" or weapon.PrintName == "gPhone" then
            return true;
        end
        -- --

        -- ARCPhone and General Phone Support --
        if weapon.PrintName == "Phone" then
            return true;
        end
        -- --

        -- Lockpicking & Keypad Cracking Support --                                                                                                                                                                                                                                                         // 76561199109663690
        if THIRDPERSON.LockpickKeypadcrack then
            if ( weapon.IsDarkRPLockpick or weapon:GetClass() == "lockpick" or weapon:GetClass() == "pro_lockpick" ) then
                if ( weapon.dt and weapon:GetIsLockpicking() ) then
                    return true;
                end
            end
        
            if weapon:GetClass() == "keypad_cracker" and weapon.dt and weapon.IsCracking then
                return true;
            end
        end
        -- --

        -- Configurable Weapons Support --
        if (THIRDPERSON.weapons[ weapon:GetClass() ] == true) then
            return true;
        elseif ( THIRDPERSON.weapons[ weapon:GetClass() ] ~= nil && type( THIRDPERSON.weapons[ weapon:GetClass() ] ) == "function" ) then
            local customWeaponCheck = THIRDPERSON.weapons[ weapon:GetClass() ];
            if ( customWeaponCheck( weapon ) == true ) then
                return true;
            end
        end
        -- --

        -- Entity Support --
        if THIRDPERSON.EntityViewActive then
            return true;
        end
        -- --

        -- Three's Builder Support (https://www.gmodstore.com/market/view/5501) --
        if ( ThreesBuilder and ThreesBuilder.IsBuilding ) then
            return true;
        end
        -- --

        -- Gamemode Prophunt Enhanced Support (https://github.com/prop-hunt-enhanced/prop-hunt-enhanced) --
        if ( PHE and (gmod.GetGamemode().Name == "Prop Hunt: ENHANCED" or gmod.GetGamemode().Name == "Prop Hunt: ENHANCED PLUS") ) then
            if ( pl:GetNWBool("isBlind") ) then
                return true;
            end
        end
        -- --

        -- Gamemode Prop Hunt support (https://github.com/andrewtheis/prophunt; https://github.com/kowalski7cc/prophunt-hidenseek-original) --
        if ( gmod.GetGamemode().Name == "Prop Hunt" ) then
            if ( blind ) then
                return true;
            end
        end
        -- --
    end

    return false;
end

THIRDPERSON.EntityViewActive = false

if CLIENT then
    timer.Create("THIRDPERSON.EntityCheckCache", 0.1, 0, function()
        local succ, err = pcall(function()
            if not THIRDPERSON.Setting("thirdperson_entityview") then
                THIRDPERSON.EntityViewActive = false

                return
            end

            local set = false
            local pl = LocalPlayer()
            local ent = {}
            ent.entity = pl.GetEyeTraceNoCursor(pl).Entity

            if IsValid(ent.entity) then
                ent.distance = pl:EyePos():DistToSqr(ent.entity:GetPos())
                ent.class = ent.entity:GetClass()
            else
                ent.entity = nil
                ent.distance = nil
                ent.class = nil
            end

            if ent.class then
                local entDistance = THIRDPERSON.entities[ent.class]

                if entDistance ~= nil and ent.distance <= entDistance then
                    THIRDPERSON.EntityViewActive = true
                    set = true
                end
            end

            if not set then
                THIRDPERSON.EntityViewActive = false
            end
        end)
    end)
end

local function viewThirdPerson(pl, pos, angles, fov)
    if solaris and solaris.InitialMainMenuIsVisible and solaris.InitialMainMenuIsVisible() then
        view = {
            origin = solaris.Config.MenuCamPos,
            angles = solaris.Config.MenuCamAng,
            fov = 70
        }
        return view
    end

    local thirdperson_view = THIRDPERSON.Setting("thirdperson_view", pl)
    local thirdperson_horizontalview = THIRDPERSON.Setting("thirdperson_horizontalview", pl)
    local thirdperson_verticalview = THIRDPERSON.Setting("thirdperson_verticalview", pl)
    local thirdperson_distance = THIRDPERSON.Setting("thirdperson_distance", pl)
    local thirdperson_preventwallcollisions = THIRDPERSON.Setting("thirdperson_preventwallcollisions", pl)
    
    if thirdperson_view and (pl:Alive() and pl:IsValid()) and not THIRDPERSON.runChecks(pl:GetActiveWeapon(), pl) then
        local offsets = {};

        if thirdperson_horizontalview < -50 then
            offsets.right = -50;
        elseif thirdperson_horizontalview > 50 then
            offsets.right = 50;
        else
            offsets.right = thirdperson_horizontalview;
        end

        if thirdperson_verticalview < -50 then
            offsets.up = -50;
        elseif thirdperson_verticalview > 50 then
            offsets.up = 50;
        else
            offsets.up = thirdperson_verticalview;
        end

        if thirdperson_distance < 0 then
            offsets.distance = 0;
        elseif thirdperson_distance > THIRDPERSON.maxDistance then
            offsets.distance = THIRDPERSON.maxDistance;
        else
            offsets.distance = thirdperson_distance;
        end

        local view = {};
        local trace = {};

        view.origin = pos - ( angles:Forward() * offsets.distance ) + ( angles:Right() * offsets.right ) + ( angles:Up() * offsets.up );

        if thirdperson_preventwallcollisions == true then
            -- This improved anti-wall collisions method is courtsey of !ThirdPerson 2.
            -- It has been backported for !ThirdPerson 1 customers to enjoy.
            trace.start = pos;
            trace.endpos = view.origin;
            trace.filter = {pl:GetActiveWeapon(), pl};
            trace.mins = Vector(-6, -6, -6);
            trace.maxs = Vector(6, 6, 6);

            trace = util.TraceHull(trace);

            if (trace.Hit) then
                view.origin = trace.HitPos;
            end
            -- End of backport from !ThirdPerson 2
        end

        view.angles = angles;
        view.fov = fov;
        return view;
    end
end

if (CLIENT) then
    hook.Add("CalcView", "THIRDPERSON.viewThirdperson", viewThirdPerson);
end

local function correctBulletsThirdPerson( entity, data )
    if (not entity:IsPlayer()) then
        return
    end

    if entity:IsValid() and THIRDPERSON.Setting("thirdperson_view", entity) and THIRDPERSON.Setting("thirdperson_bulletcorrection", entity) then
        if not data then
            return;
        end

        if not (entity:IsPlayer() or entity:IsWeapon()) then
            return;
        end

        local weapon;

        if (entity:IsWeapon()) then
            -- Some weapon bases are odd and use FireBullets() on the weapon itself as the entity, instead of the
            -- firing entity. To prevent this from causing problems, detect if it's a weapon.
            weapon = entity;
            entity = weapon:GetOwner();
        else
            weapon = entity:GetActiveWeapon();
        end

        if (THIRDPERSON.Setting("thirdperson_crosshair", entity) ~= "None" and not weapons.IsBasedOn(weapon:GetClass(), "mg_base")) then
            return
        end

        -- Check weapon state & whether it is one of the weapons that has their own crosshair which
        -- should not have bullet correction
        if (not weapons.IsBasedOn(weapon:GetClass(), "mg_base") and THIRDPERSON.runChecks(weapon, entity) or weapon.ArcCW or weapon.CW20Weapon or weapon.IsFAS2Weapon or weapon.IsTFAWeapon or weapon.ArcticTacRP) then
            return
        end

        local offset = Vector( 0, 0, 0 );
        if data.Dir:GetNormal() ~= entity:GetAimVector():GetNormal() then
            offset = ( data.Dir:GetNormal() - entity:GetAimVector():GetNormal() );
        end
        
        local cm = ( viewThirdPerson( entity, entity:EyePos(), entity:EyeAngles(), 10, 0, 0 ) );

        if not cm then
            return;
        end
        
        local trace = util.TraceLine( { start = cm.origin, endpos = cm.origin + ( ( cm.angles:Forward() + offset ) * 100000 ), filter = entity, mask = MASK_SHOT } )

        if not ( trace.Hit and trace.HitPos ) then
            return;
        end
        
        data.Dir = ( trace.HitPos - data.Src ):GetNormal();
        return true;
    end
end

hook.Add("EntityFireBullets", "THIRDPERSON.thirdperson_bulletcorrections", correctBulletsThirdPerson);
