--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561199109663690)

SHARED FILE
]]--

AddCSLuaFile();

THIRDPERSON               = THIRDPERSON or {};
THIRDPERSON.default       = THIRDPERSON.default or {};
THIRDPERSON.permissions   = THIRDPERSON.permissions or {};
THIRDPERSON.configuration = THIRDPERSON.configuration or {};
THIRDPERSON.client        = THIRDPERSON.client or {};
THIRDPERSON.clients       = THIRDPERSON.clients or {}; -- Serverside only
THIRDPERSON.access        = THIRDPERSON.access or {};
THIRDPERSON.dataTable     = THIRDPERSON.dataTable or {};

THIRDPERSON.dataTable["evolve"]      = false;
THIRDPERSON.dataTable["serverguard"] = false;

THIRDPERSON.evolve        = THIRDPERSON.evolve or {};
THIRDPERSON.serverguard   = THIRDPERSON.serverguard or {};

local include_sv = ( SERVER ) and include or function() end
local include_cl = ( SERVER ) and AddCSLuaFile or include
local include_sh = function( path )
    include_sv( path );
    include_cl( path );
end

-- Shared Includes --
include_sh( "thirdperson/sh_thirdperson_config.lua" );
include_sh( "thirdperson/sh_thirdperson.lua" );
-- Serverside Includes --
include_sv( "thirdperson/server/sv_thirdperson.lua" );
include_sv( "thirdperson/server/sv_resource.lua" );

-- Configuration Defines --
    function THIRDPERSON.registerConfigValue( permission, configuration, type )
        THIRDPERSON.permissions[ permission ] = configuration;
        THIRDPERSON.configuration[ permission ] = type;
    end

    THIRDPERSON.registerConfigValue( "thirdperson_view", "ThirdPerson", "bool" );
    THIRDPERSON.registerConfigValue( "thirdperson_bind", "Bind", "string" );
    THIRDPERSON.registerConfigValue( "thirdperson_preventwallcollisions", "PreventWallCollisions", "bool" );
    THIRDPERSON.registerConfigValue( "thirdperson_scoping", "Scoping", "bool" );
    THIRDPERSON.registerConfigValue( "thirdperson_entityview", "EntityView", "bool" );
    THIRDPERSON.registerConfigValue( "thirdperson_bulletcorrection", "BulletCorrections", "bool" );
    THIRDPERSON.registerConfigValue( "thirdperson_verticalview", "VerticalView", "number" );
    THIRDPERSON.registerConfigValue( "thirdperson_horizontalview", "HorizontalView", "number" );
    THIRDPERSON.registerConfigValue( "thirdperson_distance", "Distance", "number" );
    THIRDPERSON.registerConfigValue( "thirdperson_crosshair", "Crosshair", "string" );

    -- Setup Client Convars --
        -- General Convars--
        CreateClientConVar( "thirdperson_view", THIRDPERSON.boolToNumber( THIRDPERSON.default.ThirdPerson ), true, false, "Whether to enable third-person view or not." );
        CreateClientConVar( "thirdperson_bind", THIRDPERSON.default.Bind, true, false, "A key toggle for !ThirdPerson mode." );
        CreateClientConVar( "thirdperson_scoping", THIRDPERSON.boolToNumber( THIRDPERSON.default.Scoping ), true, false, "Whether or not scoping should temporarily switch to first-person." );
        CreateClientConVar( "thirdperson_entityview", THIRDPERSON.boolToNumber( THIRDPERSON.default.EntityView ), true, false, "Whether or not viewing certain entities should temporarily switch to first-person." );
        CreateClientConVar( "thirdperson_preventwallcollisions", THIRDPERSON.boolToNumber( THIRDPERSON.default.PreventWallCollisions ), true, false, "Whether or not to prevent wall collisions in third-person." );
        CreateClientConVar( "thirdperson_bulletcorrection", THIRDPERSON.boolToNumber( THIRDPERSON.default.BulletCorrections ), true, false, "Whether or not to correct where bullets land in third-person. Disable this if it interferes with a custom crosshair or HUD." );
        CreateClientConVar( "thirdperson_bulletcorrection_save", THIRDPERSON.boolToNumber( THIRDPERSON.default.BulletCorrections ), true, false, "Save of client config value (thirdperson_bulletcorrection)." );
        -- View Angle Convars --
        CreateClientConVar( "thirdperson_distance", THIRDPERSON.default.Distance, true, false, "The view distance in third-person." );
        CreateClientConVar( "thirdperson_verticalview", THIRDPERSON.default.VerticalView, true, false, "The vertical view angle in third-person." );
        CreateClientConVar( "thirdperson_horizontalview", THIRDPERSON.default.HorizontalView, true, false, "The horizontal view angle in third-person." );
        -- Crosshair Convars --
        CreateClientConVar( "thirdperson_crosshair", THIRDPERSON.default.Crosshair, true, false, "Whether or not to use the third-person crosshair and if so, which to use." );

        local crosshairColors = string.Explode( ",", string.gsub( THIRDPERSON.default.CrosshairColor, "%s+", "" ) );
        
        CreateClientConVar( "thirdperson_crosshair_color_r", crosshairColors[1], true, false, "Color (R) of the third-person crosshair." );
        CreateClientConVar( "thirdperson_crosshair_color_g", crosshairColors[2], true, false, "Color (G) of the third-person crosshair." );
        CreateClientConVar( "thirdperson_crosshair_color_b", crosshairColors[3], true, false, "Color (B) of the third-person crosshair." );
        CreateClientConVar( "thirdperson_crosshair_color_a", crosshairColors[4], true, false, "Color (A) of the third-person crosshair." );
    -- --
-- --

-- Clientside Includes --
include_cl( "thirdperson/client/ferma/cl_ferma.lua" );
include_cl( "thirdperson/client/ferma/cl_ferma_fpanel.lua" );
include_cl( "thirdperson/client/ferma/cl_ferma_fcheckboxlabel.lua" );
include_cl( "thirdperson/client/ferma/cl_ferma_flabel.lua" );
include_cl( "thirdperson/client/ferma/cl_ferma_fbutton.lua" );
include_cl( "thirdperson/client/ferma/cl_ferma_fpointmapper.lua" );
include_cl( "thirdperson/client/ferma/cl_ferma_fslider.lua" );
include_cl( "thirdperson/client/ferma/cl_ferma_fcolormixer.lua" );
include_cl( "thirdperson/client/ferma/cl_ferma_ftitlebar.lua" );
include_cl( "thirdperson/client/ferma/cl_ferma_fbinder.lua" );

include_cl( "thirdperson/client/cl_thirdperson.lua" );
include_cl( "thirdperson/client/cl_thirdperson_hud.lua" );
include_cl( "thirdperson/client/cl_thirdperson_menu.lua" );
include_cl( "thirdperson/client/cl_thirdperson_contextmenu.lua" );