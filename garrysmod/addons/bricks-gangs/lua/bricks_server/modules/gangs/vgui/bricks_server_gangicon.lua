local PANEL = {}

DEFINE_BASECLASS( "DImage" )

function PANEL:Init()

end

function PANEL:SetIconURL( path )
    if( not BRICKS_SERVER.Func.CheckGangIconURL( path ) ) then return end

    if( not string.StartWith( path, "http" ) ) then
        self:SetMaterial( path )
        return
    end

    self.loadingImage = true
    
    BRICKS_SERVER.Func.GetImage( path, function( mat )
        if( not IsValid( self ) ) then return end

        self.loadingImage = false
        if( IsValid( self.loadingPanel ) ) then
            self.loadingPanel:Remove()
        end

        self:SetMaterial( mat )
    end )
end

function PANEL:CreateLoadingPanel( w, h )
    self.loadingPanel = vgui.Create( "bricks_server_loading_square", self )
    self.loadingPanel:SetSize( BRICKS_SERVER.Func.Repeat( math.min( w, h, BRICKS_SERVER.Func.ScreenScale( 40 ) ), 2 ) )
    self.loadingPanel:SetPos( w/2-self.loadingPanel:GetWide()/2, h/2-self.loadingPanel:GetTall()/2 )
    self.loadingPanel:BeginAnimation()
end

function PANEL:Paint( w, h )
    if( not self.loadingImage ) then 
        BaseClass.Paint( self, w, h )
        return 
    end

    if( IsValid( self.loadingPanel ) ) then return end
    self:CreateLoadingPanel( w, h )
end

vgui.Register( "bricks_server_gangicon", PANEL, "DImage" )