--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561199109663690)

CLIENTSIDE FILE
]]--

if ( THIRDPERSON.contextMenu == true ) then
    list.Set( "DesktopWindows", "ThirdPerson", {
        title       = "!ThirdPerson",
        icon        = "icon64/thirdperson/thirdperson-icon.png",
        onewindow   = false,
        init        = function( icon, window )
            RunConsoleCommand( "-menu_context" );
            RunConsoleCommand( "thirdperson_menu" );
        end
    } );

    local function ThirdPersonContextMenu( menubar )
        local m  = menubar:AddOrGetMenu( "!ThirdPerson" );

        -- Toggle Option --
        m:AddCVar( "Enable !ThirdPerson", "thirdperson_view", "1", "0" );
        -- --

        m:AddSpacer()

        -- Wall Collisions Option --
        m:AddCVar( "Prevent wall collisions", "thirdperson_preventwallcollisions", "1", "0" );
        -- --

        -- Scoping Option --
        m:AddCVar( "Enable first-person scoping", "thirdperson_scoping", "1", "0" );
        -- --

        -- Correct Bullets Option --
        m:AddCVar( "Correct bullets with static crosshairs", "thirdperson_bulletcorrection", "1", "0" );
        -- --

        -- View Entities Option --
        m:AddCVar( "Enable first-person while viewing certain entities", "thirdperson_entityview", "1", "0" );
        -- --

        m:AddSpacer()

        -- Viewing Angle --
        m:AddOption( "Setting: View Angles", function()
            RunConsoleCommand( "thirdperson_menu" );
        end );
        -- --

        -- View Distance --
        m:AddOption( "Setting: View Distance", function()
            RunConsoleCommand( "thirdperson_menu" );
        end );
        -- --

        -- Crosshair --
        m:AddOption( "Setting: Crosshair & Color", function()
            RunConsoleCommand( "thirdperson_menu" );
        end );
        -- --

        m:AddSpacer();

        -- Menu Option --
        m:AddOption( "!ThirdPerson Full Menu", function()
            RunConsoleCommand( "thirdperson_menu" );
        end );
        -- --

    end

    if ( hook.GetTable()[ "PopulateMenuBar" ] ~= nil ) then
        hook.Add( "PopulateMenuBar", "ThirdPersonContextMenu", ThirdPersonContextMenu );
    end
end