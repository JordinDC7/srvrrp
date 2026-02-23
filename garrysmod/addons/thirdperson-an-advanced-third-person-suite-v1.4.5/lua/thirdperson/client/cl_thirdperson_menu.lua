--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561199109663690)

CLIENTSIDE FILE
]]--

function THIRDPERSON.menuThirdPerson( pl )  
    if( BackPlane ~= nil ) then
        BackPlane:Remove()
    end

    -- Font initialization & management --
    local fonts = {
        ["title"]   = "GModNotify",
        ["heading"] = "GModNotify",
        ["setting"] = "Trebuchet18",
    };

    if ( THIRDPERSON.useFonts and file.Exists( "resource/fonts/roboto-thirdperson-ad3fc.ttf", "GAME" ) ) then
        surface.CreateFont( "Roboto-Thirdperson-AD3FCUnscaled15", { font = "Roboto-Thirdperson-AD3FC", size = 15, weight = 200 } );
        surface.CreateFont( "Roboto-Thirdperson-AD3FCUnscaled17", { font = "Roboto-Thirdperson-AD3FC", size = 17, weight = 200 } );

        local RobotoUnscaled15 = "Roboto-Thirdperson-AD3FCUnscaled15";
        local RobotoUnscaled17 = "Roboto-Thirdperson-AD3FCUnscaled17";

        fonts = {
            ["title"]   = RobotoUnscaled15,
            ["heading"] = RobotoUnscaled17,
            ["setting"] = RobotoUnscaled15,
        };
    end
    -- --

    local backPlaneHeight = 570;
    local backPlaneOffset = 0.40 * ScrH();

    if ( ( backPlaneOffset + backPlaneHeight ) > ScrH() ) then
        backPlaneOffset = backPlaneOffset - (  ScrH() - ( ( ScrH() / 2 ) + backPlaneOffset ) );
    end

    BackPlane = vgui.Create( "FPanel" )
    BackPlane:Style
    {
        ["width"] = 700,
        ["height"] = backPlaneHeight,
        ["float"] = "right",
        ["top"] = backPlaneOffset,
        ["bottom"] = "10%",
        ["right"] = "5%",
        ["blur"] = 3,
        ["border"] = { 4 },
        ["border-color"] = Color( 0, 0, 0 ),
        ["background-color"] = Color( 0, 0, 0, 230 ),
        ["popup"] = true,
    }

    local TP = TP or {}

    TP.TitleBar = vgui.Create( "FTitleBar", BackPlane )
    TP.TitleBar:Style
    {
        ["width"] = "100%",
        ["height"] = "8%",
        ["background-color"] = Color( 0, 0, 0 ),
        ["content"] = "!ThirdPerson - Settings",
        ["font-family"] = fonts["title"]
    }

    TP.InnerPlane = vgui.Create( "FPanel", BackPlane )
    TP.InnerPlane:Style
    {
        ["width"] = "100%",
        ["height"] = "92%",
        ["margin"] = { 20 },
        ["visibility"] = "hidden",
        ["below"] = TP.TitleBar
    }
    
    TP.Area1 = vgui.Create( "FPanel", TP.InnerPlane )
    TP.Area1:Style
    {
        ["width"] = "50%",
        ["height"] = "65%",
        ["margin"] = { 0, 0, 10, 20 },
        ["border"] = { 3 },
        ["border-color"] = Color( 0, 0, 0 ),
    }

    TP.Heading1 = vgui.Create( "FLabel", TP.Area1 )
    TP.Heading1:Style
    {
        ["width"] = "100%",
        ["height"] = 50,
        ["font-family"] = fonts["heading"],
        ["content"] = "Third Person Settings",
        ["background-color"] = Color( 0, 0, 0, 170 ),
        ["border"] = { 3 },
        ["border-color"] = Color( 0, 0, 0 )
    }

    local bindContent;

    if ( THIRDPERSON.Setting("thirdperson_bind") ~= nil && THIRDPERSON.Setting("thirdperson_bind") ~= "none" ) then
        bindContent = "BIND: " .. THIRDPERSON.Setting("thirdperson_bind");
    else
        bindContent = "Key Bind";
    end

    TP.Setting7 = vgui.Create( "FBinder", TP.Area1 )
    TP.Setting7:Style
    {
        ["below"] = TP.Heading1,
        ["height"] = 40,
        ["width"] = 150,
        ["top"] = 12,
        ["left"] = "27%",
        ["margin"] = { 10, 0 },
        ["font-family"] = fonts["setting"],
        ["content"] = bindContent,
        ["border"] = { 3 },
        ["border-color"] = Color( 0, 0, 0, 150 ),
    }

    if not THIRDPERSON.hasPermission( pl, "thirdperson_bind" ) then
        TP.Setting7:SetDisabled( true )
    end

    function TP.Setting7:OnChange( num )
        if THIRDPERSON.hasPermission( pl, "thirdperson_bind" ) then
            RunConsoleCommand( "thirdperson_bind", input.GetKeyName( num ) );
            if ( THIRDPERSON.broadcastChat ) then
                chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Your third-person toggle bind key is now set to ", Color(61, 61, 61), input.GetKeyName( num ), Color(255, 255, 255), "." );
            end
        end
    end

    TP.Setting1 = vgui.Create( "FCheckBoxLabel", TP.Area1 )
    TP.Setting1:Style
    {
        ["below"] = TP.Setting7,
        ["height"] = 20,
        ["width"] = "100%",
        ["left"] = 7,
        ["top"] = 12,
        ["margin"] = { 10, 0 },
        ["font-family"] = fonts["setting"],
        ["content"] = "Enable !ThirdPerson.",
        ["cvar"] = "thirdperson_view"
    }

    if not THIRDPERSON.hasPermission( pl, "thirdperson_view" ) then
        TP.Setting1:SetDisabled( true )
    end

    TP.Setting2 = vgui.Create( "FCheckBoxLabel", TP.Area1 )
    TP.Setting2:Style
    {
        ["below"] = TP.Setting1,
        ["height"] = 20,
        ["width"] = "100%",
        ["left"] = 7,
        ["top"] = 8,
        ["margin"] = { 10, 0 },
        ["font-family"] = fonts["setting"],
        ["content"] = "Prevent ability to see through walls.",
        ["cvar"] = "thirdperson_preventwallcollisions"
    }

    if not THIRDPERSON.hasPermission( pl, "thirdperson_preventwallcollisions" ) then
        TP.Setting2:SetDisabled( true )
    end

    TP.Setting3 = vgui.Create( "FCheckBoxLabel", TP.Area1 )
    TP.Setting3:Style
    {
        ["below"] = TP.Setting2,
        ["height"] = 20,
        ["width"] = "100%",
        ["left"] = 7,
        ["top"] = 8,
        ["margin"] = { 10, 0 },
        ["font-family"] = fonts["setting"],
        ["content"] = "Enter first person while scoping weapons.",
        ["cvar"] = "thirdperson_scoping"
    }

    if not THIRDPERSON.hasPermission( pl, "thirdperson_scoping" ) then
        TP.Setting3:SetDisabled( true )
    end

    TP.Setting4 = vgui.Create( "FCheckBoxLabel", TP.Area1 )
    TP.Setting4:Style
    {
        ["below"] = TP.Setting3,
        ["height"] = 20,
        ["width"] = "100%",
        ["left"] = 7,
        ["top"] = 8,
        ["margin"] = { 10, 0 },
        ["font-family"] = fonts["setting"],
        ["content"] = "Correct bullets with the crosshair.",
        ["cvar"] = "thirdperson_bulletcorrection"
    }

    if not THIRDPERSON.hasPermission( pl, "thirdperson_bulletcorrection" ) or THIRDPERSON.Setting("thirdperson_crosshair") ~= "None" then
        TP.Setting4:SetDisabled( true )
    end

    TP.Setting5 = vgui.Create( "FCheckBoxLabel", TP.Area1 )
    TP.Setting5:Style
    {
        ["below"] = TP.Setting4,
        ["height"] = 20,
        ["width"] = "100%",
        ["left"] = 7,
        ["top"] = 8,
        ["margin"] = { 10, 0 },
        ["font-family"] = fonts["setting"],
        ["content"] = "View certain entities in first person.",
        ["cvar"] = "thirdperson_entityview",
    }

    if not THIRDPERSON.hasPermission( pl, "thirdperson_entityview" ) then
        TP.Setting5:SetDisabled( true )
    end
    
    TP.Setting6 = vgui.Create( "FButton", TP.Area1 )
    TP.Setting6:Style
    {
        ["height"] = 25,
        ["right"] = 10,
        ["top"] = 12,
        ["float"] = "right",
        ["below"] = TP.Setting5,
        ["content"] = "Reset Settings",
        ["border"] = { 3 },
        ["border-color"] = Color( 0, 0, 0, 150 )
    }

    TP.Setting6.DoClick = function()
        RunConsoleCommand( "thirdperson_reset", "all" )
        timer.Simple( .1, function() THIRDPERSON.menuThirdPerson( pl ) end )
    end

    TP.Area2 = vgui.Create( "FPanel", TP.InnerPlane )
    TP.Area2:Style
    {
        ["width"] = "50%",
        ["height"] = "50%",
        ["after"] = TP.Area1,
        ["margin"] = { 10, 0, 0, 20 },
        ["border"] = { 3 },
        ["border-color"] = Color( 0, 0, 0 ),
    }

    TP.Heading2 = vgui.Create( "FLabel", TP.Area2 )
    TP.Heading2:Style
    {
        ["width"] = "100%",
        ["height"] = 50,
        ["font-family"] = fonts["heading"],
        ["content"] = "Viewing Angle",
        ["background-color"] = Color( 0, 0, 0, 170 ),
        ["border"] = { 3 },
        ["border-color"] = Color( 0, 0, 0 ),
    }

    TP.AngleBox = vgui.Create( "FPointMapper", TP.Area2 )
    TP.AngleBox:Style
    {
        ["width"] = "88%",
        ["height"] = "100%",
        ["margin"] = { 10, 10, 5, 60 },
        ["background-color"] = Color( 255, 255, 255, 3 ),
        ["below"] = TP.Heading2,
        ["border"] = { 1 },
        ["knob"] = { TP.AngleBox:ConvertX( THIRDPERSON.Setting("thirdperson_horizontalview"), 0, 1, -50, 50 ), TP.AngleBox:ConvertY( THIRDPERSON.Setting("thirdperson_verticalview"), 1, 0, -50, 50 ) } 
    }

    if not THIRDPERSON.hasPermission( pl, "thirdperson_viewangles" ) then
        TP.AngleBox:SetLockX( TP.AngleBox:ConvertX( THIRDPERSON.Setting("thirdperson_horizontalview"), 0, 1, -50, 50 ) );
        TP.AngleBox:SetLockY( TP.AngleBox:ConvertY( THIRDPERSON.Setting("thirdperson_verticalview"), 1, 0, -50, 50 ) );
    else
        TP.AngleBox.Think = function()
            if( TP.AngleBox:GetDragging() ) then
                local Horizontal = TP.AngleBox:ConvertX( "knob", -50, 50, 0, TP.AngleBox:GetWide() )
                local Vertical = TP.AngleBox:ConvertY( "knob", 50, -50, 0, TP.AngleBox:GetTall() )
                RunConsoleCommand( "thirdperson_horizontalview", Horizontal )
                RunConsoleCommand( "thirdperson_verticalview", Vertical )
            end
        end
    end

    TP.AngleSliderBox = vgui.Create( "FPanel", TP.Area2 )
    TP.AngleSliderBox:Style
    {
        ["width"] = "12%",
        ["height"] = "100%",
        ["margin"] = { 5, 10, 10, 60 },
        ["background-color"] = Color( 255, 255, 255, 5 ),
        ["after"] = TP.AngleBox,
        ["below"] = TP.Heading2,
        ["border"] = { 1 },
        ["border-color"] = Color( 0, 0, 0 )
    }

    TP.DistanceSlider = vgui.Create( "FSlider", TP.AngleSliderBox )
    TP.DistanceSlider:Style
    {
        ["width"] = "100%",
        ["height"] = "100%",
        ["visibility"] = "hidden",
        ["margin"] = { 2, 15, 0, 15 },
        ["border-color"] = Color( 0, 0, 0, 100 ),
        ["x-axis"] = 0.5,
        ["noclip"] = true,
        ["vbar"] = true,
        ["knob"] = { 0.5, TP.DistanceSlider:ConvertY( THIRDPERSON.Setting("thirdperson_distance"), 0, 1, 0, THIRDPERSON.maxDistance ) }
    }

    if not THIRDPERSON.hasPermission( pl, "thirdperson_distance" ) then
        TP.DistanceSlider:SetLockY( TP.DistanceSlider:ConvertY( THIRDPERSON.Setting("thirdperson_distance"), 0, 1, 0, THIRDPERSON.maxDistance ) );
    else
        TP.DistanceSlider.Think = function()
            if( TP.DistanceSlider:GetDragging() == true ) then
                local Vertical = TP.DistanceSlider:ConvertY( "knob", 0, THIRDPERSON.maxDistance, 0, TP.DistanceSlider:GetTall() )
                RunConsoleCommand( "thirdperson_distance", Vertical )
            end
        end
    end

    if not THIRDPERSON.hasPermission( pl, "thirdperson_viewangles" ) and not THIRDPERSON.hasPermission( pl, "thirdperson_distance" ) then
        TP.Area2:SetDisabled( true );
    end

    TP.Area3 = vgui.Create( "FPanel", TP.InnerPlane )
    TP.Area3:Style
    {
        ["width"] = "50%",
        ["height"] = "35%",
        ["below"] = TP.Area1,
        ["margin"] = { 0, 0, 10, 0 },
        ["border"] = { 3 },
        ["border-color"] = Color( 0, 0, 0 ),
    }

    TP.Heading3 = vgui.Create( "FLabel", TP.Area3 )
    TP.Heading3:Style
    {
        ["width"] = "100%",
        ["height"] = 50,
        ["font-family"] = fonts["heading"],
        ["content"] = "Crosshair Selection",
        ["background-color"] = Color( 0, 0, 0, 170 ),
        ["border"] = { 3 },
        ["border-color"] = Color( 0, 0, 0 ),
    }

    TP.Area4 = vgui.Create( "FPanel", TP.InnerPlane )
    TP.Area4:Style
    {
        ["width"] = "50%",
        ["height"] = "50%",
        ["after"] = TP.Area1,
        ["below"] = TP.Area2,
        ["margin"] = { 10, 0, 0, 0 },
        ["border"] = { 3 },
        ["border-color"] = Color( 0, 0, 0 ),
    }

    TP.Heading4 = vgui.Create( "FLabel", TP.Area4 )
    TP.Heading4:Style
    {
        ["width"] = "100%",
        ["height"] = 50,
        ["font-family"] = fonts["heading"],
        ["content"] = "Crosshair Color",
        ["background-color"] = Color( 0, 0, 0, 170 ),
        ["border"] = { 3 },
        ["border-color"] = Color( 0, 0, 0 ),
    }


    TP.Area4ColorMixer = vgui.Create( "FColorMixer", TP.Area4 )
    TP.Area4ColorMixer:Style
    {
        ["height"] = "100%",
        ["width"] = "100%",
        ["margin"] = { 10, 10, 10, 60 },
        ["below"] = TP.Heading3
    }

    TP.CrossHair1 = vgui.Create( "FButton", TP.Area3 )
    TP.CrossHair1:Style
    {
        ["height"] = 38,
        ["width"] = 38,
        ["below"] = TP.Heading3,
        ["left"] = 15,
        ["top"] = 9,
        ["content"] = ""
    }
    
    local SelectedCrosshair = 0
    local thirdperson_crosshair = THIRDPERSON.Setting("thirdperson_crosshair")

    TP.CrossHair1.Paint = function( self, w, h )
        // Button
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawBox{ ["color"] = Color( 0, 0, 0, 150 ), ["x"] = 0, ["y"] = 0, ["width"] = w, ["height"] = h }
    
        // Crosshair
        FERMA.CORE.DrawHorizontalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = w / 2, ["y"] = h / 2, ["thickness"] = 1, ["length"] = 1 }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 10, ["y"] = 19, ["thickness"] = 1, ["length"] = 4 }
        FERMA.CORE.DrawVerticalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 19, ["y"] = 10, ["thickness"] = 1, ["length"] = 4 }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 24, ["y"] = 19, ["thickness"] = 1, ["length"] = 4 }
        FERMA.CORE.DrawVerticalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 19, ["y"] = 24, ["thickness"] = 1, ["length"] = 4 }
    
        if( self:IsHovered() ) then
            FERMA.CORE.DrawBox{ ["color"] = Color( 255, 255, 255, 10 ), ["x"] = 3, ["y"] = 3, ["width"] = w - 6, ["height"] = h - 6 }
        end

        if( SelectedCrosshair == 1 or thirdperson_crosshair == "1" ) then
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        end
    end

    TP.CrossHair1.DoClick = function( self, w, h )
        SelectedCrosshair = 1
        TP.Setting4:SetDisabled(true);
        RunConsoleCommand( "thirdperson_crosshair", "1" );
    end

    TP.CrossHair2 = vgui.Create( "FButton", TP.Area3 )
    TP.CrossHair2:Style
    {
        ["height"] = 38,
        ["width"] = 38,
        ["below"] = TP.Heading3,
        ["after"] = TP.CrossHair1,
        ["left"] = 12,
        ["top"] = 9,
        ["content"] = ""
    }

    TP.CrossHair2.Paint = function( self, w, h )
        // Button
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawBox{ ["color"] = Color( 0, 0, 0, 150 ), ["x"] = 0, ["y"] = 0, ["width"] = w, ["height"] = h }
    
        // Crosshair
        draw.RoundedBox( 2, w / 2 - 2, h / 2 - 2, 4, 4, TP.Area4ColorMixer:GetColor() )
    
        if( self:IsHovered() ) then
            FERMA.CORE.DrawBox{ ["color"] = Color( 255, 255, 255, 10 ), ["x"] = 3, ["y"] = 3, ["width"] = w - 6, ["height"] = h - 6 }
        end
            
        if( SelectedCrosshair == 2 or thirdperson_crosshair == "2") then
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        end
    end

    TP.CrossHair2.DoClick = function( self, w, h )
        SelectedCrosshair = 2
        TP.Setting4:SetDisabled( true );
        RunConsoleCommand( "thirdperson_crosshair", "2" );
    end

    TP.CrossHair3 = vgui.Create( "FButton", TP.Area3 )
    TP.CrossHair3:Style
    {
        ["height"] = 38,
        ["width"] = 38,
        ["below"] = TP.Heading3,
        ["after"] = TP.CrossHair2,
        ["left"] = 12,
        ["top"] = 9,
        ["content"] = ""
    }

    TP.CrossHair3.Paint = function( self, w, h )
        // Button                                                                                                                                // 76561199109663690
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawBox{ ["color"] = Color( 0, 0, 0, 150 ), ["x"] = 0, ["y"] = 0, ["width"] = w, ["height"] = h }

        // Crosshair
        FERMA.CORE.DrawHorizontalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 10, ["y"] = 19, ["thickness"] = 1, ["length"] = 18 }
        FERMA.CORE.DrawVerticalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 19, ["y"] = 10, ["thickness"] = 1, ["length"] = 18 }
    
        if( self:IsHovered() ) then
            FERMA.CORE.DrawBox{ ["color"] = Color( 255, 255, 255, 10 ), ["x"] = 3, ["y"] = 3, ["width"] = w - 6, ["height"] = h - 6 }
        end

        if( SelectedCrosshair == 3 or thirdperson_crosshair == "3" ) then
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        end
    end

    TP.CrossHair3.DoClick = function( self, w, h )
        SelectedCrosshair = 3
        TP.Setting4:SetDisabled( true );
        RunConsoleCommand( "thirdperson_crosshair", "3" );
    end

    TP.CrossHair4 = vgui.Create( "FButton", TP.Area3 )
    TP.CrossHair4:Style
    {
        ["height"] = 38,
        ["width"] = 38,
        ["below"] = TP.Heading3,
        ["after"] = TP.CrossHair3,
        ["left"] = 12,
        ["top"] = 9,
        ["content"] = ""
    }

    TP.CrossHair4.Paint = function( self, w, h )
        // Button
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawBox{ ["color"] = Color( 0, 0, 0, 150 ), ["x"] = 0, ["y"] = 0, ["width"] = w, ["height"] = h }

        // Crosshair
        FERMA.CORE.DrawHorizontalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 10, ["y"] = 19, ["thickness"] = 1, ["length"] = 5 }
        FERMA.CORE.DrawVerticalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 19, ["y"] = 10, ["thickness"] = 1, ["length"] = 5 }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 23, ["y"] = 19, ["thickness"] = 1, ["length"] = 5 }
        FERMA.CORE.DrawVerticalLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 19, ["y"] = 23, ["thickness"] = 1, ["length"] = 5 }
    
        if( self:IsHovered() ) then
            FERMA.CORE.DrawBox{ ["color"] = Color( 255, 255, 255, 10 ), ["x"] = 3, ["y"] = 3, ["width"] = w - 6, ["height"] = h - 6 }
        end

        if( SelectedCrosshair == 4 or thirdperson_crosshair == "4" ) then
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        end
    end

    TP.CrossHair4.DoClick = function( self, w, h )
        SelectedCrosshair = 4
        TP.Setting4:SetDisabled( true );
        RunConsoleCommand( "thirdperson_crosshair", "4" );
    end

    TP.CrossHair5 = vgui.Create( "FButton", TP.Area3 )
    TP.CrossHair5:Style
    {
        ["height"] = 38,
        ["width"] = 38,
        ["below"] = TP.Heading3,
        ["after"] = TP.CrossHair4,
        ["left"] = 12,
        ["top"] = 9,
        ["content"] = ""
    }

    TP.CrossHair5.Paint = function( self, w, h )
        // Button
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawBox{ ["color"] = Color( 0, 0, 0, 150 ), ["x"] = 0, ["y"] = 0, ["width"] = w, ["height"] = h }

        // Crosshair
        FERMA.CORE.DrawLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 10, ["y"] = 28, ["end-x"] = 28, ["end-y"] = 10 }
        FERMA.CORE.DrawLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 10, ["y"] = 10, ["end-x"] = 28, ["end-y"] = 28 }
    
        if( self:IsHovered() ) then
            FERMA.CORE.DrawBox{ ["color"] = Color( 255, 255, 255, 10 ), ["x"] = 3, ["y"] = 3, ["width"] = w - 6, ["height"] = h - 6 }
        end

        if( SelectedCrosshair == 5 or thirdperson_crosshair == "5" ) then
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        end
    end

    -- 76561223073791539

    TP.CrossHair5.DoClick = function( self, w, h )
        SelectedCrosshair = 5
        TP.Setting4:SetDisabled( true );
        RunConsoleCommand( "thirdperson_crosshair", "5" );
    end

    TP.CrossHair6 = vgui.Create( "FButton", TP.Area3 )
    TP.CrossHair6:Style
    {
        ["height"] = 38,
        ["width"] = 38,
        ["below"] = TP.Heading3,
        ["after"] = TP.CrossHair5,
        ["left"] = 12,
        ["top"] = 9,
        ["content"] = ""
    }

    TP.CrossHair6.Paint = function( self, w, h )
        // Button
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawBox{ ["color"] = Color( 0, 0, 0, 150 ), ["x"] = 0, ["y"] = 0, ["width"] = w, ["height"] = h }

        // Crosshair
        FERMA.CORE.DrawLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 10, ["y"] = 28, ["end-x"] = 17, ["end-y"] = 22 }
        FERMA.CORE.DrawLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 10, ["y"] = 10, ["end-x"] = 17, ["end-y"] = 16 }
        FERMA.CORE.DrawLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 21, ["y"] = 16, ["end-x"] = 28, ["end-y"] = 10 }
        FERMA.CORE.DrawLine{ ["color"] = TP.Area4ColorMixer:GetColor(), ["x"] = 21, ["y"] = 22, ["end-x"] = 28, ["end-y"] = 28 }
    
        if( self:IsHovered() ) then
            FERMA.CORE.DrawBox{ ["color"] = Color( 255, 255, 255, 10 ), ["x"] = 3, ["y"] = 3, ["width"] = w - 6, ["height"] = h - 6 }
        end

        if( SelectedCrosshair == 6 or thirdperson_crosshair == "6" ) then
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        end
    end

    TP.CrossHair6.DoClick = function( self, w, h )
        SelectedCrosshair = 6
        TP.Setting4:SetDisabled( true );
        RunConsoleCommand( "thirdperson_crosshair", "6" );
    end

    TP.CrossHairDefault = vgui.Create( "FButton", TP.Area3 )
    TP.CrossHairDefault:Style
    {
        ["height"] = 30,
        ["width"] = "30%",
        ["below"] = TP.Heading3,
        ["left"] = "35%",
        ["top"] = "40%",
        ["content"] = "Default",
        ["font-family"] = fonts["setting"]
    }

    TP.CrossHairDefault.Paint = function( self, w, h )
        // Button
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 0, 0, 0 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        FERMA.CORE.DrawBox{ ["color"] = Color( 0, 0, 0, 150 ), ["x"] = 0, ["y"] = 0, ["width"] = w, ["height"] = h }
    
        if( self:IsHovered() ) then
            FERMA.CORE.DrawBox{ ["color"] = Color( 255, 255, 255, 10 ), ["x"] = 3, ["y"] = 3, ["width"] = w - 6, ["height"] = h - 6 }
        end

        if( SelectedCrosshair == "None" or thirdperson_crosshair == "None" ) then
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 0, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawVerticalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = w - 3, ["y"] = 0, ["thickness"] = 3, ["length"] = h }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = 0, ["thickness"] = 3, ["length"] = w - 3 }
            FERMA.CORE.DrawHorizontalLine{ ["color"] = Color( 30, 30, 30 ), ["x"] = 3, ["y"] = h - 3, ["thickness"] = 3, ["length"] = w - 3 }
        end
    end

    TP.CrossHairDefault.DoClick = function( self, w, h )
        SelectedCrosshair = "None"
        TP.Setting4:SetDisabled( false );
        RunConsoleCommand( "thirdperson_crosshair", "None" );
    end

    TP.Area4ColorMixer:SetConVarR( "thirdperson_crosshair_color_r" )
    TP.Area4ColorMixer:SetConVarG( "thirdperson_crosshair_color_g" )
    TP.Area4ColorMixer:SetConVarB( "thirdperson_crosshair_color_b" )
    TP.Area4ColorMixer:SetConVarA( "thirdperson_crosshair_color_a" )

    if not THIRDPERSON.hasPermission( pl, "thirdperson_crosshair" ) then
        TP.Area3:SetDisabled( true )
    end

    if not THIRDPERSON.hasPermission( pl, "thirdperson_crosshaircolor" ) then
        TP.Area4:SetDisabled( true )
        TP.Area4ColorMixer:SetDisabled( true )
    end
end

concommand.Add( "thirdperson_menu", THIRDPERSON.menuThirdPerson )  -- ConCommand. Changing this *will* break the addon.
