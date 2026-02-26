local PANEL = {}

function PANEL:Init()
    self.animTime = 0.2

    self.panelTall = self.panelTall or (ScrH()*0.75-90)

    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )
    end 

    self.pages = {}
    self.pageButtonBack = vgui.Create( "DPanel", self.topBar )
    self.pageButtonBack:Dock( RIGHT )
    self.pageButtonBack:DockMargin( 0, 10, 25, 10 )
    self.pageButtonBack:SetWide( 0 )
    self.pageButtonBack.Paint = function( self, w, h ) end 

    self.topBarContent = vgui.Create( "DPanel", self.topBar )
    self.topBarContent:Dock( FILL )
    self.topBarContent.Paint = function( self, w, h ) end 
end

function PANEL:CreatePage( name, panel, onClick )
    panel:SetPos( self.panelWide, self.topBar:GetTall() )

    local pageNum = table.insert( self.pages, { panel, onClick } )

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local textX, textY = surface.GetTextSize( name )

    local pageButton = vgui.Create( "DButton", self.pageButtonBack )
    pageButton:Dock( LEFT )
    pageButton:SetWide( textX+25 )
    pageButton:SetText( "" )
    local alpha = 0
    pageButton.Paint = function( self2, w, h )
        local buttonColor, buttonDownColor = BRICKS_SERVER.Func.GetTheme( 1 ), BRICKS_SERVER.Func.GetTheme( 0 )
        if( self.activePage == pageNum ) then
            buttonColor, buttonDownColor = BRICKS_SERVER.Func.GetTheme( 5 ), BRICKS_SERVER.Func.GetTheme( 4 )
        end

        local roundLeft, roundRight = pageNum == 1, pageNum == #self.pages

        draw.RoundedBoxEx( 8, 0, 0, w, h, buttonColor, roundLeft, roundRight, roundLeft, roundRight )

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBoxEx( 8, 0, 0, w, h, buttonDownColor, roundLeft, roundRight, roundLeft, roundRight )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, buttonDownColor, 8 )

        draw.SimpleText( name, "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    pageButton.DoClick = function()
        self:OpenPage( pageNum )
    end

    self.pageButtonBack:SetWide( self.pageButtonBack:GetWide()+pageButton:GetWide() )
end

function PANEL:OpenPage( num, noAnim )
    if( num == self.activePage ) then return end
    
    local pagePanel, pageOnClick = self.pages[num][1], self.pages[num][2]

    if( IsValid( self.activePanel ) ) then
        local newX = self.panelWide

        local nextPanelX = pagePanel:GetPos()
        if( nextPanelX >= self.panelWide ) then
            newX = -self.panelWide
        end

        self.activePanel:MoveTo( newX, self.topBar:GetTall(), self.animTime )
    end

    self.activePanel = pagePanel
    self.activePage = num

    pagePanel:MoveTo( 0, self.topBar:GetTall(), noAnim and 0 or self.animTime )

    pageOnClick()
end

function PANEL:FillPanel()
    self.players = vgui.Create( "bricks_server_unboxingmenu_admin_players", self )
    self.players:SetSize( self.panelWide, self.panelTall-self.topBar:GetTall() )
    self.players.panelWide = self.panelWide
    self.players.panelTall = self.panelTall - self.topBar:GetTall()
    self:CreatePage( BRICKS_SERVER.Func.L( "unboxingPlayers" ), self.players, function() 
        if( not self.players.filled ) then
            self.players.filled = true
            self.players:FillPanel() 
        end
    end )

    self:OpenPage( 1, true )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_admin", PANEL, "DPanel" )