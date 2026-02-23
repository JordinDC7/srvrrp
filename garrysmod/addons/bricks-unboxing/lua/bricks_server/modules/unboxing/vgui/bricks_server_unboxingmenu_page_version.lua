local PANEL = {}

function PANEL:Init()
    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:Dock( FILL )
    self.mainPanel.Paint = function( self2, w, h )
        -- Transparent wrapper (pages handle most visuals)
    end

    self.pageWide = ScrW() * 0.6 - BRICKS_SERVER.DEVCONFIG.MainNavWidth
end

function PANEL:Refresh()
    self.mainPanel:Clear()

    -- Recalculate on refresh in case resolution/ui scale changed
    self.pageWide = ScrW() * 0.6 - BRICKS_SERVER.DEVCONFIG.MainNavWidth

    self.sheet = vgui.Create( "bricks_server_colsheet", self.mainPanel )
    self.sheet:Dock( FILL )
    self.sheet.OnSheetChange = function( activeButton )
        hook.Run( "BRS.Hooks.UnboxingSwitchpage", activeButton.label )
    end

    -- Sidebar width
    self.sheet.Navigation:SetWide( BRICKS_SERVER.DEVCONFIG.MainNavWidth )

    -- Premium sidebar background + header area behind avatar card
    self.sheet.Navigation.Paint = function( self2, w, h )
        -- Main sidebar background
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, 245 ) )
        surface.DrawRect( 0, 0, w, h )

        -- Soft inner edge highlight (modern panel separation)
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 10 ) )
        surface.DrawRect( w - 2, 0, 2, h )

        -- Top accent bar
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5, 190 ) )
        surface.DrawRect( 0, 0, w, 3 )

        -- Gentle top fade (gives depth under header)
        surface.SetDrawColor( 0, 0, 0, 35 )
        surface.DrawRect( 0, 3, w, 18 )
	end

    local group = BRICKS_SERVER.Func.GetGroup( LocalPlayer() )
    local rankName = group and group[1] or BRICKS_SERVER.Func.GetAdminGroup( LocalPlayer() )

    local height = 64
    local avatarBackSize = 44
    local textStartPos = 68

    local avatarBack = vgui.Create( "DPanel", self.sheet.Navigation )
    avatarBack:Dock( TOP )
    avatarBack:DockMargin( 10, 10, 10, 10 )
    avatarBack:SetTall( height )

    avatarBack.Paint = function( self2, w, h )
        -- Card background
        draw.RoundedBox( 10, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2, 245 ) )

        -- Subtle top highlight
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 14 ) )
        surface.DrawRect( 10, 1, w - 20, 1 )

        -- Subtle bottom divider
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1, 140 ) )
        surface.DrawRect( 10, h - 1, w - 20, 1 )

        -- Accent ring (rank color if available)
        local rankColor = ((group or {})[3] or BRICKS_SERVER.Func.GetTheme( 5 ))
        surface.SetDrawColor( rankColor.r or 255, rankColor.g or 255, rankColor.b or 255, 28 )
        draw.NoTexture()
        BRICKS_SERVER.Func.DrawCircle( 12 + (avatarBackSize / 2), h / 2, (avatarBackSize / 2) + 6, 48 )

        -- Inner avatar circle background
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
        draw.NoTexture()
        BRICKS_SERVER.Func.DrawCircle( 12 + (avatarBackSize / 2), h / 2, (avatarBackSize / 2) + 2, 48 )

        -- Player name
        draw.SimpleText(
            LocalPlayer():Nick(),
            "BRICKS_SERVER_Font23",
            textStartPos,
            (h / 2) + 3,
            BRICKS_SERVER.Func.GetTheme( 6 ),
            0,
            TEXT_ALIGN_BOTTOM
        )

        -- Rank text
        draw.SimpleText(
            rankName or "",
            "BRICKS_SERVER_Font20",
            textStartPos,
            (h / 2) - 3,
            rankColor,
            0,
            0
        )
    end

    local distance = 2
    local avatarIcon = vgui.Create( "bricks_server_circle_avatar", avatarBack )
    avatarIcon:SetPos( 12 + distance, (height - avatarBackSize) / 2 + distance )
    avatarIcon:SetSize( avatarBackSize - (2 * distance), avatarBackSize - (2 * distance) )
    avatarIcon:SetPlayer( LocalPlayer(), 64 )

    -- Pages list (order preserved)
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
    -- Base panel intentionally blank (sheet + children draw everything)
end

vgui.Register( "bricks_server_unboxingmenu_page_version", PANEL, "DPanel" )