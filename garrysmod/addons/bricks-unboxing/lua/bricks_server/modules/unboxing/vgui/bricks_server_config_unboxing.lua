local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( configPanel )
    BRICKS_SERVER.Func.FillVariableConfigs( self, "UNBOXING", "UNBOXING" )
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_unboxing", PANEL, "bricks_server_scrollpanel" )