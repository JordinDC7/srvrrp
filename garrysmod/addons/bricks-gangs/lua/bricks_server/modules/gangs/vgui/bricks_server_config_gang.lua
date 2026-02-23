local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( configPanel )
    BRICKS_SERVER.Func.FillVariableConfigs( self, "GANGS", "GANGS" )
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_gangs", PANEL, "bricks_server_scrollpanel" )