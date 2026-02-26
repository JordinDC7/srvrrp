local PANEL = {}

function PANEL:Init()
    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:Dock( FILL )
    self.mainPanel.Paint = function( self2, w, h ) end

    self.pageWide = self.panelWide or self:GetWide()
end

function PANEL:Refresh()
    self.mainPanel:Clear()

    local originalW, originalH = ScrW()*0.6, ScrH()*0.65 
    local newW = originalW+200

    self.sheet = vgui.Create( "bricks_server_colsheet", self.mainPanel )
    self.sheet:Dock( FILL )
    self.sheet.OnSheetChange = function( activeButton )
        hook.Run( "BRS.Hooks.UnboxingSwitchpage", activeButton.label )
    end
    self.sheet.Navigation:SetWide( BRICKS_SERVER.DEVCONFIG.MainNavWidth )
    self.sheet.Navigation.Paint = function( self2, w, h )
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, 125 ) )
        surface.DrawRect( 0, 0, w, h )
	end

    local group = BRICKS_SERVER.Func.GetGroup( LocalPlayer() )
    local rankName = group and group[1] or BRICKS_SERVER.Func.GetAdminGroup( LocalPlayer() )

    local height = 55
    local avatarBackSize = height
    local textStartPos = 65
    
    local avatarBack = vgui.Create( "DPanel", self.sheet.Navigation )
    avatarBack:Dock( TOP )
    avatarBack:DockMargin( 10, 10, 0, 10 )
    avatarBack:SetTall( height )
    avatarBack.Paint = function( self2, w, h )
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.NoTexture()
        BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )

        draw.SimpleText( LocalPlayer():Nick(), "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )

        draw.SimpleText( rankName, "BRICKS_SERVER_Font20", textStartPos, h/2-2, ((group or {})[3] or BRICKS_SERVER.Func.GetTheme( 5 )), 0, 0 )
    end

    local distance = 2

    local avatarIcon = vgui.Create( "bricks_server_circle_avatar" , avatarBack )
    avatarIcon:SetPos( (height-avatarBackSize)/2+distance, (height-avatarBackSize)/2+distance )
    avatarIcon:SetSize( avatarBackSize-(2*distance), avatarBackSize-(2*distance) )
    avatarIcon:SetPlayer( LocalPlayer(), 64 )

    local pages = {}
    table.insert( pages, { BRICKS_SERVER.Func.L( "unboxingHome" ), "bricks_server_unboxingmenu_home", "unboxing_home.png" } )
    table.insert( pages, { BRICKS_SERVER.Func.L( "unboxingStore" ), "bricks_server_unboxingmenu_store", "unboxing_store.png" } )
    table.insert( pages, { BRICKS_SERVER.Func.L( "unboxingInventory" ), "bricks_server_unboxingmenu_inventory", "unboxing_inventory.png" } )

    if( SH_EASYSKINS ) then
        table.insert( pages, { BRICKS_SERVER.Func.L( "unboxingSkins" ), "bricks_server_unboxingmenu_easyskins", "unboxing_skin.png", false, false, function( page ) page.RefreshCategory() end } )
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "trading" ) ) then
        table.insert( pages, { BRICKS_SERVER.Func.L( "unboxingTrading" ), "bricks_server_unboxingmenu_trading", "unboxing_trading.png" } )
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "marketplace" ) ) then
        table.insert( pages, { BRICKS_SERVER.Func.L( "unboxingMarketplace" ), "bricks_server_unboxingmenu_marketplace", "unboxing_marketplace.png" } )
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "rewards" ) ) then
        table.insert( pages, { BRICKS_SERVER.Func.L( "unboxingRewards" ), "bricks_server_unboxingmenu_rewards", "unboxing_rewards.png" } )
    end

    if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
        table.insert( pages, { BRICKS_SERVER.Func.L( "admin" ), "bricks_server_unboxingmenu_admin", "admin_badge.png", BRICKS_SERVER.Func.GetTheme( 4 ), BRICKS_SERVER.Func.GetTheme( 5 ) } )
    end

    for k, v in pairs( pages ) do
        local page = vgui.Create( v[2], self.sheet )
        page:Dock( FILL )
        page.panelWide = self.pageWide

        if( page.FillPanel ) then
            if( not v[6] ) then
                self.sheet:AddSheet( v[1], page, function()
                    if( v[7] ) then v[7]( page ) end
                    page:FillPanel() 
                end, v[3], v[4], v[5] )
            else
                self.sheet:AddSheet( v[1], page, { function()
                    if( v[7] ) then v[7]( page ) end
                    page:FillPanel() 
                end, function() v[6]( page ) end }, v[3], v[4], v[5] )
            end
        else
            self.sheet:AddSheet( v[1], page, false, v[3], v[4], v[5] )
        end
    end

    hook.Add( "BRS.Hooks.OpenUnboxingTradePage", self, function()
        self.sheet:SetActiveSheet( BRICKS_SERVER.Func.L( "unboxingTrading" ) )
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_page_version", PANEL, "DPanel" )