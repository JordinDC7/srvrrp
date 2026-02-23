local PANEL = {}

function PANEL:Init()
    self:SetHeader( "ELITE ARSENAL // " .. string.upper( BRICKS_SERVER.Func.L( "unboxingMenu" ) ) )
    self:SetSize( ScrW()*0.6, ScrH()*0.65 )
    self:Center()
    self.removeOnClose = false
    self.centerOnSizeChanged = true

    self.onCloseFunc = function()
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "marketplace" ) ) then
            net.Start( "BRS.Net.SendUnboxingMarketplaceClose" )
            net.SendToServer()
        end

        if( BRICKS_SERVER.Func.IsModuleEnabled( "coinflip" ) ) then
            net.Start( "BRS.Net.CloseCoinflipsMenu" )
            net.SendToServer()
        end

        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            BRICKS_SERVER.Func.SendAdminConfig()
        end
    end

    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:Dock( FILL )
    self.mainPanel.Paint = function( self2, w, h ) end

    self.baseWidth = ScrW()*0.6
    self.baseHeight = ScrH()*0.65
    self.configExtraWidth = 200

    self:SetResponsiveSize( self.baseWidth, self.baseHeight )

    self:Refresh()
end

function PANEL:SetResponsiveSize( wide, tall )
    self.baseWidth = wide or self.baseWidth or (ScrW()*0.6)
    self.baseHeight = tall or self.baseHeight or (ScrH()*0.65)

    self.pageWide = math.max( 1, self.baseWidth-BRICKS_SERVER.DEVCONFIG.MainNavWidth )
end

function PANEL:GetTargetSize( isConfig )
    local baseW, baseH = self.baseWidth or (ScrW()*0.6), self.baseHeight or (ScrH()*0.65)
    if( isConfig ) then
        return baseW+(self.configExtraWidth or 200), baseH
    end

    return baseW, baseH
end

function PANEL:ApplyCurrentPageSize( animate )
    local activeButton
    if( IsValid( self.sheet ) ) then
        if( isfunction( self.sheet.GetActiveButton ) ) then
            activeButton = self.sheet:GetActiveButton()
        elseif( isfunction( self.sheet.GetActiveSheet ) ) then
            activeButton = self.sheet:GetActiveSheet()
        else
            activeButton = self.sheet.ActiveButton
        end
    end

    local activeLabel = IsValid( activeButton ) and activeButton.label
    local isConfig = (activeLabel == BRICKS_SERVER.Func.L( "config" ))

    local targetW, targetH = self:GetTargetSize( isConfig )
    if( self:GetWide() == targetW and self:GetTall() == targetH ) then return end

    if( animate ) then
        self:SizeTo( targetW, targetH, 0.2 )
    else
        self:SetSize( targetW, targetH )
        self:Center()
    end
end

function PANEL:UpdatePageWidths()
    local navigationWide = IsValid( self.sheet ) and IsValid( self.sheet.Navigation ) and self.sheet.Navigation:GetWide() or BRICKS_SERVER.DEVCONFIG.MainNavWidth
    local activePageWide = math.max( 1, self:GetWide()-navigationWide )

    for _, sheet in pairs( IsValid( self.sheet ) and (self.sheet.Items or {}) or {} ) do
        local panel = IsValid( sheet.Panel ) and sheet.Panel
        if( not panel ) then continue end

        panel.panelWide = activePageWide

        if( panel.FillInventory ) then
            panel:CalculateGrid()
            panel:FillInventory()
        end
    end
end

function PANEL:Refresh()
    self.mainPanel:Clear()

    self.sheet = vgui.Create( "bricks_server_colsheet", self.mainPanel )
    self.sheet:Dock( FILL )
    self.sheet.Paint = function( self2, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
    end

    self.sheet.Navigation:SetWide( BRICKS_SERVER.DEVCONFIG.MainNavWidth )
    self.sheet.Navigation.Paint = function( self2, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 8 ) )
        surface.DrawRect( w-2, 0, 2, h )
    end

    self.sheet.OnSheetChange = function( activeButton )
        hook.Run( "BRS.Hooks.UnboxingSwitchpage", activeButton.label )

        self:ApplyCurrentPageSize( true )

        timer.Simple( 0, function()
            if( IsValid( self ) ) then
                self:UpdatePageWidths()
            end
        end )
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
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.RoundedBoxEx( 8, 0, 0, 6, h, BRICKS_SERVER.Func.GetTheme( 3 ), true, false, true, false )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
        draw.NoTexture()
        BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )

        draw.SimpleText( LocalPlayer():Nick(), "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( "Operator Rank: " .. tostring(rankName or "Rookie"), "BRICKS_SERVER_Font17", textStartPos, h/2-2, ((group or {})[3] or BRICKS_SERVER.Func.GetTheme( 5 )), 0, 0 )
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

    if( BRICKS_SERVER.Func.IsModuleEnabled( "coinflip" ) ) then
        table.insert( pages, { BRICKS_SERVER.Func.L( "coinflips" ), "bricks_server_coinflip_flips", "coins_32.png", false, false, false, function( page ) page.panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth end } )
        table.insert( pages, { BRICKS_SERVER.Func.L( "coinflipHistory" ), "bricks_server_coinflip_history", "history.png", false, false, false, function( page ) page.panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth end } )
    end

    if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
        table.insert( pages, { BRICKS_SERVER.Func.L( "admin" ), "bricks_server_unboxingmenu_admin", "admin_badge.png", BRICKS_SERVER.Func.GetTheme( 4 ), BRICKS_SERVER.Func.GetTheme( 5 ) } )
        table.insert( pages, { BRICKS_SERVER.Func.L( "config" ), "bricks_server_config", "admin_24.png", BRICKS_SERVER.Func.GetTheme( 4 ), BRICKS_SERVER.Func.GetTheme( 5 ) } )
    end

    for _, v in ipairs( pages ) do
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

    self.OnSizeChanged = function()
        self:UpdatePageWidths()
    end

    timer.Simple( 0, function()
        if( IsValid( self ) ) then
            self:ApplyCurrentPageSize( false )
            self:UpdatePageWidths()
        end
    end )
end

vgui.Register( "bricks_server_unboxingmenu", PANEL, "bricks_server_dframe" )
