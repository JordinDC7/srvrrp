local PANEL = {}

function PANEL:Init()
    self.panelTall = ScrH()*0.65-40

    self.RefreshCategory = function()
        self:Clear()
    
        local panel = vgui.Create( 'p_easyskins_inventory', self )
        panel:SetPos( 25, 25 )
        panel:SetSize( self.panelWide, self.panelTall-50 )
        panel:Init(true)
    end
end

function PANEL:FillPanel()
    self.RefreshCategory()
end

function PANEL:Paint( w, h )
    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, 50 ) )
    surface.DrawRect( 0, 0, w, h )

    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
    surface.DrawRect( 30, 25, w-60, 40 )
end

vgui.Register( "bricks_server_unboxingmenu_easyskins", PANEL, "DPanel" )