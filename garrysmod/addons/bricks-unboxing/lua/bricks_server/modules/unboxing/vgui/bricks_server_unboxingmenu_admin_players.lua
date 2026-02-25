local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    self.panelWide, self.panelTall = self:GetWide(), ScrH()*0.65-40

    self.searchBar = vgui.Create( "bricks_server_searchbar", self:GetParent().topBarContent )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( ScrW()*0.2 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:RefreshSearchPopup()
    end
    self.searchBar.Think = function()
        if( not self.searchBar.search:IsEditing() ) then
            if( IsValid( self.searchPopup ) ) then
                self.searchPopup:AlphaTo( 0, 0.1, 0, function() self.searchPopup:Remove() end )
                self.searchBar:SetRoundedCorners( true, true, true, true )
            end
        elseif( not IsValid( self.searchPopup ) ) then
            self:RefreshSearchPopup()
            self.searchBar:SetRoundedCorners( true, true, false, false )
        end
    end

    hook.Add( "BRS.Hooks.UnboxingAdminPlayerData", self, function( self, steamID64, playerData )
        self:RefreshPanel( steamID64, playerData )

        if( IsValid( self.loadingPopout ) ) then
            self.loadingPopout.ClosePopout()
        end
    end )
end

function PANEL:RefreshSearchPopup()
    if( not IsValid( self.searchPopup ) ) then
        self.searchPopup = vgui.Create( "DPanel", self:GetParent() )
        self.searchPopup:SetSize( self.searchBar:GetWide(), 0 )
        self.searchPopup:SetPos( 25, 10+40 )
        self.searchPopup.Paint = function( self2, w, h )
            BRICKS_SERVER.BSHADOWS.BeginShadow()
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBoxEx( 8, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), false, false, true, true )
            BRICKS_SERVER.BSHADOWS.EndShadow( 1, 1, 1, 255, 0, 5, false )

            draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 100 ), false, false, true, true )

            if( (self.searchPopup.entries or 0) <= 0 ) then
                draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingNoPlayersFound" ), "BRICKS_SERVER_Font21", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end
    end

    self.searchPopup.entries = 0

    self.searchPopup:Clear()

    local function CreatePlayerEntry( ply, steamID64 )
        if( not steamID64 ) then return end

        local entryNum = self.searchPopup.entries+1

        local playerName = (IsValid( ply ) and ply:Nick()) or BRICKS_SERVER.Func.L( "unknown" )
        if( not IsValid( ply ) ) then
            steamworks.RequestPlayerInfo( steamID64 or "", function( steamName )
                playerName = steamName
            end )
        end

        local steamID = util.SteamIDFrom64( steamID64 )

        local playerBack = vgui.Create( "DPanel", self.searchPopup )
        playerBack:Dock( TOP )
        playerBack:SetTall( 60 )
        local alpha = 0
        playerBack.Paint = function( self2, w, h )
            if( IsValid( self2.button ) ) then
                if( not self2.button:IsDown() and self2.button:IsHovered() ) then
                    alpha = math.Clamp( alpha+3, 0, 50 )
                else
                    alpha = math.Clamp( alpha-3, 0, 50 )
                end

                if( entryNum == self.searchPopup.entries ) then
                    draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, alpha ), false, false, true, true )
                else
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1, alpha ) )
                    surface.DrawRect( 0, 0, w, h )
                end
    
                BRICKS_SERVER.Func.DrawClickCircle( self2.button, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), 8 )
            end
    
            draw.SimpleText( playerName, "BRICKS_SERVER_Font22", h+5, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
            draw.SimpleText( steamID, "BRICKS_SERVER_Font17", h+5, h/2-2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, 0 )
        end

        local avatarH = playerBack:GetTall()-15
        local avatarIcon = vgui.Create( "bricks_server_circle_avatar", playerBack )
        avatarIcon:SetPos( (playerBack:GetTall()/2)-(avatarH/2), (playerBack:GetTall()/2)-(avatarH/2) )
        avatarIcon:SetSize( avatarH, avatarH )

        if( IsValid( ply ) ) then
            avatarIcon:SetPlayer( ply, 64 )
        else
            avatarIcon:SetSteamID( steamID64, 64 )
        end

        playerBack.button = vgui.Create( "DButton", playerBack )
        playerBack.button:Dock( FILL )
        playerBack.button:SetText( "" )
        playerBack.button.Paint = function( self2, w, h ) end
        playerBack.button.DoClick = function( self2 )
            self:CreateLoadingPopout()

            net.Start( "BRS.Net.RequestUnboxingAdminPlayerData" )
                net.WriteString( steamID64 )
            net.SendToServer()
        end

        self.searchPopup.entries = self.searchPopup.entries+1
    end

    local searchValue = self.searchBar:GetValue()
    if( string.len( searchValue ) == 17 and string.StartWith( searchValue, "7" ) ) then
        CreatePlayerEntry( player.GetBySteamID64( searchValue ), searchValue )
    elseif( string.StartWith( searchValue, "STEAM_" ) ) then
        CreatePlayerEntry( player.GetBySteamID( searchValue ), util.SteamIDTo64( searchValue ) )
    else
        local entryCount = 0
        for k, v in ipairs( player.GetAll() ) do
            if( not IsValid( v ) or entryCount >= 3 ) then continue end

            if( searchValue != "" and not string.find( string.lower( v:Nick() ), string.lower( searchValue ) ) ) then
                continue
            end

            CreatePlayerEntry( v, v:SteamID64() )

            entryCount = entryCount+1
        end
    end

    self.searchPopup:SetTall( math.max( 1, self.searchPopup.entries )*60 )
end

function PANEL:RefreshPanel( steamID64, playerData )
    self:Clear()

    local sideMargin = self.panelWide*0.15
    self.backPanel = vgui.Create( "DPanel", self )
    self.backPanel:Dock( FILL )
    self.backPanel:DockMargin( sideMargin, 25, sideMargin, 25 )
    self.backPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 125 ) )
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.backPanel )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )

    self.contentWide = self.panelWide-(2*sideMargin)-50-10-10

    local playerInfoH = 100
    local avatarSize = playerInfoH*0.75

    local playerName = BRICKS_SERVER.Func.L( "unknown" )
    steamworks.RequestPlayerInfo( steamID64 or "", function( steamName )
        playerName = steamName
    end )

    local playerInfo = vgui.Create( "DPanel", self.scrollPanel )
    playerInfo:Dock( TOP )
    playerInfo:DockMargin( 0, 0, 10, 0 )
    playerInfo:SetTall( playerInfoH+10 )
    playerInfo.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1, 75 ) )
        draw.NoTexture()
        BRICKS_SERVER.Func.DrawCircle( (h-10-avatarSize)/2+(avatarSize/2), (h-10)/2, avatarSize/2, 45 )

        draw.SimpleText( playerName, "BRICKS_SERVER_Font23", h, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( steamID64, "BRICKS_SERVER_Font17", h, h/2-2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, 0 )
    end

    local playerInfoGradient = vgui.Create( "bricks_server_gradientanim", playerInfo )
    playerInfoGradient:SetPos( 0, playerInfo:GetTall()-10 )
    playerInfoGradient:SetSize( self.contentWide+2, 10 )
    playerInfoGradient:SetColors( Color(26, 188, 156), Color(46, 204, 113) )
    playerInfoGradient:SetCornerRadius( 8 )
    playerInfoGradient:SetRoundedBoxDimensions( false, -10, false, 20 )
    playerInfoGradient:StartAnim()

    local avatarIcon = vgui.Create( "bricks_server_circle_avatar", playerInfo )
    avatarIcon:SetPos( playerInfoH/2-avatarSize/2, (playerInfoH/2)-(avatarSize/2) )
    avatarIcon:SetSize( avatarSize, avatarSize )
    avatarIcon:SetSteamID( steamID64 or "", 64 )

    local statistics = {}
    statistics[1] = {
        Title = BRICKS_SERVER.Func.L( "unboxingCasesOpened" ),
        Value = function()
            return tonumber( (playerData.stats or {}).cases or 0 ) or 0
        end
    }
    statistics[2] = {
        Title = BRICKS_SERVER.Func.L( "unboxingTradesCompleted" ),
        Value = function()
            return tonumber( (playerData.stats or {}).trades or 0 ) or 0
        end
    }
    statistics[3] = {
        Title = BRICKS_SERVER.Func.L( "unboxingItemsPurchased" ),
        Value = function()
            return tonumber( (playerData.stats or {}).items or 0 ) or 0
        end
    }

    local entrySpacing = 10
    local entryWide = self.contentWide*0.21
    for k, v in ipairs( statistics ) do
        local statisticEntry = vgui.Create( "DPanel", playerInfo )
        statisticEntry:Dock( RIGHT )
        statisticEntry:DockMargin( entrySpacing, 0, 0, 10 )
        statisticEntry:SetWide( entryWide )
        local value = 0
        statisticEntry.Paint = function( self2, w, h ) 
            if( k == 1 ) then
                draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), false, true, false, false )
            else
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
                surface.DrawRect( 0, 0, w, h )
            end
    
            draw.SimpleText( string.upper( v.Title ), "BRICKS_SERVER_Font20", w/2, h/2-3, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            
            value = math.ceil( Lerp( FrameTime()*5, value, v.Value() ) )
            draw.SimpleText( string.Comma( value ), "BRICKS_SERVER_Font40B", w/2, h/2-3, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        end
    end

    -- Inventory
    local inventoryPanel = self:CreateCategory( BRICKS_SERVER.Func.L( "unboxingInventory" ) )
    
    local gridWide = self.contentWide-20
    local slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 150 ) )
    local spacing = 10
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    local inventoryGrid = vgui.Create( "DIconLayout", inventoryPanel )
    inventoryGrid:Dock( FILL )
    inventoryGrid:DockMargin( 10, 10, 10, 10 )
    inventoryGrid:SetSpaceY( spacing )
    inventoryGrid:SetSpaceX( spacing )

    local inventoryTable = playerData.inventory or {}

    local sortedItems = {}
    for k, v in pairs( inventoryTable ) do
        local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )

        if( not configItemTable ) then continue end
        
        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( configItemTable.Rarity or "" )
        
        table.insert( sortedItems, { rarityKey, k, v } )
    end

    table.SortByMember( sortedItems, 1, false )

    for k, v in pairs( sortedItems ) do
        local slotBack = inventoryGrid:Add( "bricks_server_unboxingmenu_itemslot" )
        slotBack:SetSize( slotSize, slotSize*1.2 )
        slotBack.themeNum = 1
        slotBack:FillPanel( v[2], v[3], function() 
            BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "unboxingTradeRemove" ), 1, function( text ) 
                net.Start( "BRS.Net.AdminUnboxingPlayerInventoryChange" )
                    net.WriteString( steamID64 )
                    net.WriteString( v[2] )
                    net.WriteInt( -tonumber( text ), 32 )
                net.SendToServer()
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
        end )
    end

    local addMat = Material( "bricks_server/unboxing_add_64.png" )
    local addButton = inventoryGrid:Add( "DButton" )
    addButton:SetSize( slotSize, slotSize*1.2 )
    addButton:SetText( "" )
    local alpha = 0
    addButton.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 75 )
        else
            alpha = math.Clamp( alpha-10, 0, 75 )
        end

        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2, alpha ) )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), 8 )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
        surface.SetMaterial( addMat )
        local iconSize = 64
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    addButton.DoClick = function()
        self.popoutWide, self.popoutTall = self.panelWide*0.9, (self.panelTall-60)*0.9

        self.popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall-60, self.popoutWide, self.popoutTall )

        self.popoutPanel.closeButton = vgui.Create( "DButton", self.popoutPanel )
        self.popoutPanel.closeButton:Dock( BOTTOM )
        self.popoutPanel.closeButton:SetTall( 40 )
        self.popoutPanel.closeButton:SetText( "" )
        self.popoutPanel.closeButton:DockMargin( 25, 0, 25, 25 )
        local changeAlpha = 0
        self.popoutPanel.closeButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
            
            draw.SimpleText( BRICKS_SERVER.Func.L( "cancel" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        self.popoutPanel.closeButton.DoClick = self.popoutPanel.ClosePopout

        local searchBar = vgui.Create( "bricks_server_searchbar", self.popoutPanel )
        searchBar:Dock( TOP )
        searchBar:DockMargin( 25, 25, 25, 0 )
        searchBar:SetTall( 40 )

        local scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.popoutPanel )
        scrollPanel:Dock( FILL )
        scrollPanel:DockMargin( 25, 10, 25, 25 )
        scrollPanel:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )

        local gridWide = self.popoutWide-50-10-10
        local slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 175 ) )
        local spacing = 10
        local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

        local grid = vgui.Create( "DIconLayout", scrollPanel )
        grid:Dock( TOP )
        grid:SetSpaceY( spacing )
        grid:SetSpaceX( spacing )

        function self.RefreshItems()
            grid:Clear()

            local showItems = {}
            for k, v in pairs( BRICKS_SERVER.CONFIG.UNBOXING.Items ) do
                local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                
                local globalKey = "ITEM_" .. k
                table.insert( showItems, { rarityKey, globalKey, v } )
            end
    
            for k, v in pairs( BRICKS_SERVER.CONFIG.UNBOXING.Cases ) do
                local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                
                local globalKey = "CASE_" .. k
                table.insert( showItems, { rarityKey, globalKey, v } )
            end
    
            for k, v in pairs( BRICKS_SERVER.CONFIG.UNBOXING.Keys ) do
                local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
                
                local globalKey = "KEY_" .. k
                table.insert( showItems, { rarityKey, globalKey, v } )
            end
    
            table.SortByMember( showItems, 1, true )
        
            for k, v in pairs( showItems ) do
                local globalKey, configItemTable  = v[2], v[3]
        
                if( not configItemTable ) then continue end

                if( searchBar:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( searchBar:GetValue() ) ) ) then
                    continue
                end

                local slotBack = grid:Add( "bricks_server_unboxingmenu_itemslot" )
                slotBack:SetSize( slotSize, slotSize*1.2 )
                slotBack:FillPanel( { globalKey, configItemTable }, 1, function()
                    BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "unboxingTradeAdd" ), 1, function( text ) 
                        net.Start( "BRS.Net.AdminUnboxingPlayerInventoryChange" )
                            net.WriteString( steamID64 )
                            net.WriteString( v[2] )
                            net.WriteInt( tonumber( text ), 32 )
                        net.SendToServer()
                    end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
                end )
                slotBack.themeNum = 1
            end
        end
        self.RefreshItems()

        searchBar.OnChange = function()
            self.RefreshItems()
        end
    end

    inventoryPanel:SetExpandedTall( (math.ceil( (table.Count( sortedItems )+1)/slotsWide )*((slotSize*1.2)+spacing))+spacing )
end

function PANEL:CreateCategory( title )
    local category = vgui.Create( "DPanel", self.scrollPanel )
    category:Dock( TOP )
    category:DockMargin( 0, 10, 10, 0 )
    category:SetTall( expandedTall )
    category.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 200 ) )
    end

    category.title = title
    function category:SetExpandedTall( expandedTall )
        category.expandedTall = expandedTall
        category:SetTall( 40+expandedTall )
    end

    category.header = vgui.Create( "DButton", category )
    category.header:Dock( TOP )
    category.header:SetTall( 40 )
    category.header:SetText( "" )
    local alpha = 0
    local arrow = Material( "bricks_server/down_16.png" )
    category.header.textureRotation = 0
    local catHeaderW
    category.header.Paint = function( self2, w, h )
        if( not catHeaderW ) then
            catHeaderW = w
        end
        
        local expanded = category:GetTall() > 40

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+5, 0, 150 )
        else
            alpha = math.Clamp( alpha-5, 0, 150 )
        end

        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, 75 ), true, true, not expanded, not expanded )

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, not expanded, not expanded )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ), 8 )

        draw.SimpleText( title, "BRICKS_SERVER_Font20", 15, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        surface.SetMaterial( arrow )
        local iconSize = 16
        surface.DrawTexturedRectRotated( w-((h-iconSize)/2)-(iconSize/2), h/2, iconSize, iconSize, math.Clamp( (self2.textureRotation or 0), -90, 0 ) )
    end
    category.header.DoAnim = function( expanding )
        local anim = category.header:NewAnimation( 0.2, 0, -1 )
    
        anim.Think = function( anim, pnl, fraction )
            if( expanding ) then
                category.header.textureRotation = (1-fraction)*-90
            else
                category.header.textureRotation = fraction*-90
            end
        end
    end
    category.header.DoClick = function()
        if( category:GetTall() != 40 ) then
            category:SizeTo( catHeaderW, 40, 0.2 )
            category.header.DoAnim( false )
        else
            category:SizeTo( catHeaderW, 40+category.expandedTall, 0.2 )
            category.header.DoAnim( true )
        end
    end

    return category
end

function PANEL:CreateLoadingPopout()
    if( IsValid( self.loadingPopout ) ) then
        self.loadingPopout:Remove()
    end

    local popoutClose = vgui.Create( "DPanel", self )
    popoutClose:SetSize( self.panelWide, self.panelTall-60 )
    popoutClose:SetAlpha( 0 )
    popoutClose:AlphaTo( 255, 0.2 )
    popoutClose.Paint = function( self2, w, h )
        surface.SetDrawColor( 0, 0, 0, 150 )
        surface.DrawRect( 0, 0, w, h )
        BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
    end

    local popoutWide, popoutTall = self.panelWide*0.65, (self.panelTall-60)*0.25

    self.loadingPopout = vgui.Create( "DPanel", self )
    self.loadingPopout:SetSize( 0, 0 )
    self.loadingPopout:SizeTo( popoutWide, popoutTall, 0.2 )
    self.loadingPopout.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    end
    self.loadingPopout.OnSizeChanged = function( self2 )
        self2:SetPos( (self.panelWide/2)-(self2:GetWide()/2), ((self.panelTall-60)/2)-(self2:GetTall()/2) )
    end
    self.loadingPopout.ClosePopout = function()
        if( IsValid( self.loadingPopout ) ) then
            self.loadingPopout:SizeTo( 0, 0, 0.2, 0, -1, function()
                if( IsValid( self.loadingPopout ) ) then
                    self.loadingPopout:Remove()
                end
            end )
        end

        popoutClose:AlphaTo( 0, 0.2, 0, function()
            if( IsValid( popoutClose ) ) then
                popoutClose:Remove()
            end
        end )
    end

    local actionButton = vgui.Create( "DButton", self.loadingPopout )
    actionButton:Dock( BOTTOM )
    actionButton:SetTall( 40 )
    actionButton:SetText( "" )
    actionButton:DockMargin( 25, 0, 25, 25 )
    local changeAlpha = 0
    actionButton.Paint = function( self2, w, h )
        if( not self2:IsDown() and self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
        end
        
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )

        surface.SetAlphaMultiplier( changeAlpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        
        draw.SimpleText( BRICKS_SERVER.Func.L( "cancel" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    actionButton.DoClick = self.loadingPopout.ClosePopout

    local loadingPanel = vgui.Create( "DPanel", self.loadingPopout )
    loadingPanel:Dock( FILL )
    loadingPanel:DockMargin( 25, 10, 25, 10 )
    local loadingIcon = Material( "materials/bricks_server/loading.png" )
    loadingPanel.Paint = function( self2, w, h )
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( loadingIcon )
        local size = 32
        surface.DrawTexturedRectRotated( w/2, h/2, size, size, -(CurTime() % 360 * 250) )
    
        draw.SimpleText( BRICKS_SERVER.Func.L( "loading" ), "BRICKS_SERVER_Font20", w/2, h/2+(size/2)+5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
    end
end

function PANEL:Paint( w, h )
    if( not IsValid( self.backPanel ) ) then
        surface.SetFont( "BRICKS_SERVER_Font25" )
        local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingSearchPlayers" ) )
        textX, textY = textX+30, textY+20

        draw.RoundedBox( 5, (w/2)-(textX/2), (h/2)-(textY/2), textX, textY, BRICKS_SERVER.Func.GetTheme( 3 ) )

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingSearchPlayers" ), "BRICKS_SERVER_Font23", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end

vgui.Register( "bricks_server_unboxingmenu_admin_players", PANEL, "DPanel" )