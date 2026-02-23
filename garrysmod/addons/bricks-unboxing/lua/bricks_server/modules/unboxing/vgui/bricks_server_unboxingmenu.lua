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
    self.mainPanel.Paint = function() end

    self.baseWidth = ScrW()*0.6
    self.baseHeight = ScrH()*0.65
    self.configExtraWidth = 200
    self.currentSearchText = ""
    self.quickButtonHeight = 36

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

function PANEL:GetSheetLabel( sheet )
    if( not sheet ) then return "" end

    if( isstring( sheet.label ) ) then return sheet.label end
    if( isstring( sheet.Name ) ) then return sheet.Name end
    if( IsValid( sheet.Tab ) and isstring( sheet.Tab.label ) ) then return sheet.Tab.label end

    return ""
end

function PANEL:GetSheetButton( sheet )
    if( not sheet ) then return nil end

    if( IsValid( sheet.Tab ) ) then return sheet.Tab end
    if( IsValid( sheet.Button ) ) then return sheet.Button end

    return nil
end

function PANEL:GetSheetByLabel( label )
    local sheetItems = IsValid( self.sheet ) and (self.sheet.Items or {}) or {}
    for _, sheetData in pairs( sheetItems ) do
        local sheetLabel = self:GetSheetLabel( sheetData )
        if( sheetLabel == label ) then
            return sheetData
        end
    end
end

function PANEL:SetActiveSheetByLabel( label )
    if( not IsValid( self.sheet ) or not label ) then return end

    local sheetData = self:GetSheetByLabel( label )
    if( not sheetData ) then return end

    local button = self:GetSheetButton( sheetData )
    if( IsValid( button ) ) then
        if( isfunction( button.DoClick ) ) then
            button:DoClick()
            return
        elseif( self.sheet.SetActiveButton ) then
            self.sheet:SetActiveButton( button )
            return
        end
    end

    if( self.sheet.SetActiveSheet ) then
        self.sheet:SetActiveSheet( label )
    end
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

function PANEL:AddQuickNavigation( parent, pages )
    local quickPanel = vgui.Create( "DPanel", parent )
    quickPanel:Dock( TOP )
    quickPanel:SetTall( self.quickButtonHeight )
    quickPanel:DockMargin( 16, 10, 16, 0 )
    quickPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 140 ) )
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 15 ) )
        surface.DrawOutlinedRect( 0, 0, w, h )
    end

    local quickTargets = {
        BRICKS_SERVER.Func.L( "unboxingHome" ),
        BRICKS_SERVER.Func.L( "unboxingStore" ),
        BRICKS_SERVER.Func.L( "unboxingInventory" ),
        BRICKS_SERVER.Func.L( "unboxingTrading" )
    }

    local validTargets = {}
    local pageLookup = {}
    for _, page in ipairs( pages or {} ) do
        pageLookup[page[1]] = true
    end

    for _, target in ipairs( quickTargets ) do
        if( pageLookup[target] ) then
            table.insert( validTargets, target )
        end
    end

    local spacing = 6
    local buttonW = math.floor( (quickPanel:GetWide() - ((#validTargets+1)*spacing)) / math.max( #validTargets, 1 ) )

    local recalcLayout = function()
        if( not IsValid( quickPanel ) ) then return end

        buttonW = math.floor( (quickPanel:GetWide() - ((#validTargets+1)*spacing)) / math.max( #validTargets, 1 ) )
        local x = spacing
        for _, child in ipairs( quickPanel:GetChildren() ) do
            child:SetPos( x, 4 )
            child:SetSize( buttonW, quickPanel:GetTall()-8 )
            x = x + buttonW + spacing
        end
    end

    for _, target in ipairs( validTargets ) do
        local quickButton = vgui.Create( "DButton", quickPanel )
        quickButton:SetText( "" )
        quickButton.targetLabel = target
        quickButton.DoClick = function()
            self:SetActiveSheetByLabel( target )
        end
        quickButton.Paint = function( self2, w, h )
            local isActive = false
            local activeButton = IsValid( self.sheet ) and self.sheet.GetActiveButton and self.sheet:GetActiveButton()
            if( IsValid( activeButton ) and activeButton.label == self2.targetLabel ) then
                isActive = true
            end

            local bg = isActive and BRICKS_SERVER.Func.GetTheme( 5, 95 ) or BRICKS_SERVER.Func.GetTheme( 2, 175 )
            if( self2:IsHovered() and not isActive ) then
                bg = BRICKS_SERVER.Func.GetTheme( 2, 225 )
            end

            draw.RoundedBox( 8, 0, 0, w, h, bg )
            draw.SimpleText( self2.targetLabel, "BRICKS_SERVER_Font18", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    quickPanel.OnSizeChanged = recalcLayout
    timer.Simple( 0, recalcLayout )
end

function PANEL:Refresh()
    self.mainPanel:Clear()

    local wrapper = vgui.Create( "DPanel", self.mainPanel )
    wrapper:Dock( FILL )
    wrapper.Paint = function( self2, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 8 ) )
        surface.DrawOutlinedRect( 0, 0, w, h, 1 )
    end

    self.sheet = vgui.Create( "bricks_server_colsheet", wrapper )
    self.sheet:Dock( FILL )

    self.sheet.Navigation:SetWide( BRICKS_SERVER.DEVCONFIG.MainNavWidth+28 )
    self.sheet.Navigation.Paint = function( self2, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 10 ) )
        surface.DrawRect( w-2, 0, 2, h )

        draw.RoundedBox( 0, 0, 0, w, 3, BRICKS_SERVER.Func.GetTheme( 5, 140 ) )
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

    local profileCard = vgui.Create( "DPanel", self.sheet.Navigation )
    profileCard:Dock( TOP )
    profileCard:DockMargin( 10, 10, 10, 8 )
    profileCard:SetTall( 74 )
    profileCard.Paint = function( self2, w, h )
        draw.RoundedBox( 10, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.RoundedBoxEx( 10, 0, 0, 5, h, BRICKS_SERVER.Func.GetTheme( 5, 180 ), true, false, true, false )
        draw.SimpleText( LocalPlayer():Nick(), "BRICKS_SERVER_Font23", 64, h/2+3, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( "Operator Rank: " .. tostring( rankName or "Rookie" ), "BRICKS_SERVER_Font17", 64, h/2-2, ((group or {})[3] or BRICKS_SERVER.Func.GetTheme( 5 )), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    end

    local avatarIcon = vgui.Create( "bricks_server_circle_avatar", profileCard )
    avatarIcon:SetPos( 12, 12 )
    avatarIcon:SetSize( 50, 50 )
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

    self:AddQuickNavigation( wrapper, pages )

    local statusStrip = vgui.Create( "DPanel", self.sheet.Navigation )
    statusStrip:Dock( BOTTOM )
    statusStrip:DockMargin( 10, 8, 10, 10 )
    statusStrip:SetTall( 62 )
    statusStrip.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2, 220 ) )

        local indicators = {
            { "Trading", BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "trading" ) },
            { "Market", BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "marketplace" ) },
            { "Rewards", BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "rewards" ) }
        }

        local x, y = 10, 12
        for _, indicator in ipairs( indicators ) do
            local dotColor = indicator[2] and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red
            draw.RoundedBox( 4, x, y, 8, 8, dotColor )
            draw.SimpleText( indicator[1], "BRICKS_SERVER_Font17", x+14, y+4, BRICKS_SERVER.Func.GetTheme( 6, indicator[2] and 200 or 110 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
            x = x + 72
        end

        draw.SimpleText( "Tip: use top tabs to switch fast", "BRICKS_SERVER_Font17", 10, h-10, BRICKS_SERVER.Func.GetTheme( 6, 110 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
    end

    hook.Add( "BRS.Hooks.OpenUnboxingTradePage", self, function()
        self:SetActiveSheetByLabel( BRICKS_SERVER.Func.L( "unboxingTrading" ) )
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
