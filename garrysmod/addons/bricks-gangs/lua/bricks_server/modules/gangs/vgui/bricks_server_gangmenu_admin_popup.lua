local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( panelWide, panelTall )
    self.panelWide, self.panelTall = panelWide, panelTall

    local popoutClose = vgui.Create( "DButton", self )
    popoutClose:SetSize( self.panelWide, self.panelTall )
    popoutClose:SetText( "" )
    popoutClose:SetAlpha( 0 )
    popoutClose:AlphaTo( 255, 0.2 )
    popoutClose:SetCursor( "arrow" )
    popoutClose.Paint = function( self2, w, h )
        surface.SetDrawColor( 0, 0, 0, 150 )
        surface.DrawRect( 0, 0, w, h )
        BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
    end
    local function closePopoutFunc()
        if( IsValid( self.popout ) ) then
            self.popout:SizeTo( 0, 0, 0.2, 0, -1, function()
                if( IsValid( self.popout ) ) then
                    self.popout:Remove()
                end
            end )
        end

        popoutClose:AlphaTo( 0, 0.2, 0, function()
            if( IsValid( popoutClose ) ) then
                popoutClose:Remove()
            end
        end )

        timer.Simple( 0.2, function()
            if( IsValid( self ) ) then
                self:Remove()
            end
        end )
    end
    popoutClose.DoClick = closePopoutFunc

    self.popout = vgui.Create( "DPanel", self )
    self.popout:SetSize( 0, 0 )
    self.popout:SizeTo( self.panelWide*0.65, self.panelTall*0.25, 0.2 )
    self.popout.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    end
    self.popout.OnSizeChanged = function( self2 )
        self2:SetPos( (self.panelWide/2)-(self2:GetWide()/2), (self.panelTall/2)-(self2:GetTall()/2) )
    end

    self.closeButton = vgui.Create( "DButton", self.popout )
    self.closeButton:Dock( BOTTOM )
    self.closeButton:SetTall( 40 )
    self.closeButton:SetText( "" )
    self.closeButton:DockMargin( 25, 0, 25, 25 )
    local changeAlpha = 0
    self.closeButton.Paint = function( self2, w, h )
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
        
        draw.SimpleText( BRICKS_SERVER.Func.L( "close" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    self.closeButton.DoClick = closePopoutFunc

    self.popoutContent = vgui.Create( "DPanel", self.popout )
    self.popoutContent:Dock( FILL )
    self.popoutContent.Paint = function( self2, w, h ) end

    local loadingPanel = vgui.Create( "DPanel", self.popoutContent )
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

    hook.Add( "BRS.Hooks.RefreshGangAdminData", "BricksServerHooks_BRS_RefreshGangAdminData_" .. tostring( self.popout ), function( gangID, gangTable )
        if( IsValid( self ) and IsValid( self.popout ) ) then
            self:RefreshPanel( gangID, gangTable )
        else
            hook.Remove( "BRS.Hooks.RefreshGangAdminData", "BricksServerHooks_BRS_RefreshGangAdminData_" .. tostring( self.popout ) )
        end
    end )
end

function PANEL:RefreshPanel( gangID, gangTable )
    if( not gangTable ) then 
        closePopoutFunc()
        
        BRICKS_SERVER.Func.Message( BRICKS_SERVER.Func.L( "gangFailedToLoad" ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ) )
        return 
    end

    self.gangID, self.gangTable = gangID, gangTable

    if( self.activePage and self.activePage != BRICKS_SERVER.Func.L( "main" ) ) then return end

    self.activePage = BRICKS_SERVER.Func.L( "main" )

    self.popoutContent:Clear()

    local popoutWide = self.panelWide*0.75

    local avatarBackSize = 70

    local infoPanel = vgui.Create( "DPanel", self.popoutContent )
    infoPanel:Dock( TOP )
    infoPanel:DockMargin( 25, 25, 25, 0 )
    infoPanel:SetTall( avatarBackSize )
    local avatarSize = (gangTable.Icon and avatarBackSize*0.6) or 32
    infoPanel.Paint = function( self2, w, h )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
        draw.NoTexture()
        BRICKS_SERVER.Func.DrawCircle( h/2, h/2, avatarBackSize/2, avatarBackSize/2 )

        draw.SimpleText( (gangTable.Name or BRICKS_SERVER.Func.L( "gangNone" )), "BRICKS_SERVER_Font25", h+15, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )

        draw.SimpleText( BRICKS_SERVER.Func.L( "gangID", (gangID or 0) ), "BRICKS_SERVER_Font20", h+15, h/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
    end

    local gangIcon = vgui.Create( "bricks_server_gangicon", infoPanel )
    gangIcon:SetSize( avatarSize, avatarSize )
    gangIcon:SetPos( (avatarBackSize-avatarSize)/2, (avatarBackSize-avatarSize)/2 )
    gangIcon:SetIconURL( gangTable.Icon or "bricks_server/question.png" )

    local gridWide = popoutWide-50

    local graphs = {
        [1] = {
            Title = BRICKS_SERVER.Func.L( "gangMembers" ),
            Color = Color( 41, 128, 185 ),
            GetValue = function() return table.Count( gangTable.Members or {} ) end,
            GetMax = function() return BRICKS_SERVER.Func.GangGetUpgradeInfo( gangID, "MaxMembers", gangTable )[1] end
        },
        [2] = {
            Title = BRICKS_SERVER.Func.L( "gangBalance" ),
            Color = Color( 39, 174, 96 ),
            GetValue = function() return gangTable.Money or 0 end,
            GetMax = function() return BRICKS_SERVER.Func.GangGetUpgradeInfo( gangID, "MaxBalance", gangTable )[1] end,
            Format = function( value ) return DarkRP.formatMoney( value ) end
        },
        [4] = {
            Title = function() return BRICKS_SERVER.Func.L( "levelX", (gangTable.Level or 0) ) end,
            Color = Color( 22, 160, 133 ),
            GetValue = function() return (gangTable.Experience or 0)-BRICKS_SERVER.Func.GetGangExpToLevel( 0, (gangTable.Level or 0) ) end,
            GetMax = function() return BRICKS_SERVER.Func.GetGangExpToLevel( (gangTable.Level or 0), (gangTable.Level or 0)+1 ) end,
            Format = function( value ) return BRICKS_SERVER.Func.FormatGangEXP( value+BRICKS_SERVER.Func.GetGangExpToLevel( 0, (gangTable.Level or 0) ) ) end
        }
    }

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "storage" ) ) then
        graphs[3] = {
            Title = BRICKS_SERVER.Func.L( "gangStorage" ),
            Color = Color( 231, 76, 60 ),
            GetValue = function() return table.Count( gangTable.Storage or {} ) end,
            GetMax = function() return BRICKS_SERVER.Func.GangGetUpgradeInfo( gangID, "StorageSlots", gangTable )[1] end
        }
    else
        graphs[3] = {
            Title = BRICKS_SERVER.Func.L( "gangStorage" ),
            Color = Color( 231, 76, 60 ),
            GetValue = function() return 0 end,
            GetMax = function() return 1 end
        }
    end

    local spacing = 25
    local graphWide = (gridWide-((#graphs-1)*spacing))/#graphs

    local graphPanel = vgui.Create( "DPanel", self.popoutContent )
    graphPanel:Dock( TOP )
    graphPanel:DockMargin( 25, 25, 25, 0 )
    graphPanel:SetTall( graphWide )
    graphPanel.Paint = function( self2, w, h ) end

    for k, v in ipairs( graphs ) do
        local graph = vgui.Create( "DPanel", graphPanel )
        graph:Dock( LEFT )
        graph:DockMargin( 0, 0, spacing, 0 )
        graph:SetWide( graphWide )
        local outerWidth = 5
        local themeColor = v.Color or BRICKS_SERVER.Func.GetTheme( 5 )
        local shadowColor = Color( 0, 0, 0 )
        local txtSpacing = 1
        graph.Paint = function( self2, w, h ) 
            BRICKS_SERVER.Func.DrawArc( w/2, h/2, w/2, outerWidth, 0, 360, BRICKS_SERVER.Func.GetTheme( 3 ) )

            local value, max = v.GetValue(), v.GetMax()
            local degree = math.Clamp( 360*(value/max), 0, 360 )

            BRICKS_SERVER.Func.DrawArc( w/2, h/2, w/2, outerWidth, 90, degree+90, themeColor )

            --BRICKS_SERVER.Func.DrawCircle( w/2, h/2, (w-outerWidth)/2, Color( themeColor.r, themeColor.g, themeColor.b, 75 ), -90, degree-90 )

            local title = v.Title
            if( isfunction( title ) ) then
                title = title()
            end

            draw.SimpleText( title, "BRICKS_SERVER_Font23", w/2-1, h/2+txtSpacing+1, shadowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            draw.SimpleText( title, "BRICKS_SERVER_Font23", w/2, h/2+txtSpacing, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

            local valueTxt, maxTxt = value, max
            if( v.Format ) then
                valueTxt, maxTxt = v.Format( value ), v.Format( max )
            end

            draw.SimpleText( valueTxt .. "/" .. maxTxt, "BRICKS_SERVER_Font17", w/2-1, h/2-txtSpacing+1, shadowColor, TEXT_ALIGN_CENTER, 0 )
            draw.SimpleText( valueTxt .. "/" .. maxTxt, "BRICKS_SERVER_Font17", w/2, h/2-txtSpacing, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        end
    end

    local spacing = 5
    local actionGrid = vgui.Create( "DIconLayout", self.popoutContent )
    actionGrid:Dock( TOP )
    actionGrid:DockMargin( 25, 25, 25, 0 )
    actionGrid:SetSpaceY( spacing )
    actionGrid:SetSpaceX( spacing )

    local wantedSlotSize = 125
    local slotsWide = math.floor( gridWide/wantedSlotSize )
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    local function GetNextQuery( currentQuery, reqInfo, currentReqInfo, func )
        currentQuery = currentQuery+1

        if( currentQuery > #reqInfo ) then return end

        local reqInfoEntry = reqInfo[currentQuery]

        if( reqInfoEntry[2] == "string" or reqInfoEntry[2] == "integer" ) then 
            BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), reqInfoEntry[4], 0, function( text ) 
                currentReqInfo[currentQuery] = text

                if( currentQuery >= #reqInfo ) then
                    func( currentReqInfo )
                end
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), (reqInfoEntry[2] == "integer") )
        elseif( reqInfoEntry[2] == "table" and reqInfoEntry[3] and BRICKS_SERVER.Func.GetList( reqInfoEntry[3] ) ) then 
            BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "admin" ), reqInfoEntry[4], "", BRICKS_SERVER.Func.GetList( reqInfoEntry[3] ), function( value, data ) 
                if( BRICKS_SERVER.Func.GetList( reqInfoEntry[3] )[data] ) then
                    currentReqInfo[currentQuery] = data

                    if( currentQuery >= #reqInfo ) then
                        func( currentReqInfo )
                    end
                else
                    notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidChoice" ), 1, 3 )
                end
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
        end

        GetNextQuery( currentQuery, reqInfo, currentReqInfo, func )
    end

    local actionButtons = 0
    for k, v in ipairs( BRICKS_SERVER.DEVCONFIG.GangAdminCmds ) do
        if( not v.Icon or not v.Name ) then continue end
        
        actionButtons = actionButtons+1
        local newTall = (math.ceil( actionButtons/slotsWide )*slotSize)+((math.ceil( actionButtons/slotsWide )-1)*spacing)

        if( actionGrid:GetTall() != newTall ) then
            actionGrid:SetTall( newTall )
        end


        local actionButton = actionGrid:Add( "DButton" )
        actionButton:SetSize( slotSize, slotSize )
        actionButton:SetText( "" )
        local Alpha, iconAlpha = 0, 0
        local iconMat
        BRICKS_SERVER.Func.GetImage( v.Icon or "admin.png", function( mat ) 
            iconMat = mat 
        end )
        actionButton.Paint = function( self2, w, h )
            if( self2:IsHovered() and not self2:IsDown() ) then
                Alpha = math.Clamp( Alpha+10, 0, 50 )
            else
                Alpha = math.Clamp( Alpha-10, 0, 50 )
            end

            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            draw.RoundedBox( 5, 0, 0, w, h, Color( BRICKS_SERVER.Func.GetTheme( 3 ).r, BRICKS_SERVER.Func.GetTheme( 3 ).g, BRICKS_SERVER.Func.GetTheme( 3 ).b, Alpha ) )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

            if( self2:IsHovered() and not self2:IsDown() ) then
                iconAlpha = math.Clamp( iconAlpha+10, 20, 255 )
            else
                iconAlpha = math.Clamp( iconAlpha-10, 20, 255 )
            end

            if( iconMat ) then
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, iconAlpha )
                surface.SetMaterial( iconMat )
                local iconSize = 64
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end

            draw.SimpleText( v.Name, "BRICKS_SERVER_Font15", w/2, h-5, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, iconAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end
        actionButton.DoClick = function()
            if( v.ClientFunc ) then
                v.ClientFunc( gangTable, gangID, self )
            elseif( v.ServerFunc ) then
                GetNextQuery( 0, v.ReqInfo, {}, function( reqInfo )
                    net.Start( "BRS.Net.AdminGangCMD" )
                        net.WriteUInt( k, 8 )
                        net.WriteUInt( gangID, 16 )
                        net.WriteTable( reqInfo )
                    net.SendToServer()
                end )
            end
        end
    end

    if( self.popoutContent:GetAlpha() != 255 ) then
        self.popoutContent:SetAlpha( 0 )
        self.popoutContent:AlphaTo( 255, 0.2 )
    end

    local popoutTall = self.closeButton:GetTall()+25+infoPanel:GetTall()+25+graphPanel:GetTall()+25+actionGrid:GetTall()+50
    if( self.popout:GetWide() != popoutWide or self.popout:GetTall() != popoutTall ) then
        self.popout:SizeTo( popoutWide, popoutTall, 0.2 )
    end
end

function PANEL:FillMembers()
    self.popoutContent:Clear()

    local topBar = vgui.Create( "DPanel", self.popoutContent )
    topBar:Dock( TOP )
    topBar:DockMargin( 10, 10, 10, 0 )
    topBar:SetTall( 40 )
    topBar.Paint = function( self2, w, h ) 

    end

    local backButton = vgui.Create( "DButton", topBar )
    backButton:Dock( LEFT )
    backButton:SetWide( topBar:GetTall() )
    backButton:SetText( "" )
    local Alpha = 0
    local backMat = Material( "bricks_server/back.png" )
    backButton.Paint = function( self2, w, h ) 
        if( not self2:IsDown() and self2:IsHovered() ) then
            Alpha = math.Clamp( Alpha+5, 0, 100 )
        else
            Alpha = math.Clamp( Alpha-5, 0, 100 )
        end

        surface.SetAlphaMultiplier( Alpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        surface.SetDrawColor( 255, 255, 255, 20+(235*(Alpha/100)) )
        surface.SetMaterial( backMat )
        local iconSize = 24
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    backButton.DoClick = function()
        self.activePage = BRICKS_SERVER.Func.L( "main" )

        self:RefreshPanel( self.gangID, self.gangTable )
    end

    local searchBarBack = vgui.Create( "DPanel", topBar )
    searchBarBack:Dock( FILL )
    searchBarBack:DockMargin( 5, 0, 0, 0 )
    local search = Material( "materials/bricks_server/search.png" )
    local Alpha = 0
    local Alpha2 = 20
    local searchBar
    local color1 = BRICKS_SERVER.Func.GetTheme( 2 )
    searchBarBack.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        if( searchBar:IsEditing() ) then
            Alpha = math.Clamp( Alpha+5, 0, 100 )
            Alpha2 = math.Clamp( Alpha2+20, 20, 255 )
        else
            Alpha = math.Clamp( Alpha-5, 0, 100 )
            Alpha2 = math.Clamp( Alpha2-20, 20, 255 )
        end
        
        draw.RoundedBox( 5, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ) )
    
        surface.SetDrawColor( 255, 255, 255, Alpha2 )
        surface.SetMaterial(search)
        local size = 24
        surface.DrawTexturedRect( w-size-(h-size)/2, (h-size)/2, size, size )
    end
    
    searchBar = vgui.Create( "bricks_server_search", searchBarBack )
    searchBar:Dock( FILL )

    local scrollPanel = vgui.Create( "bricks_server_scrollpanel", self.popoutContent )
    scrollPanel:Dock( FILL )
    scrollPanel:DockMargin( 10, 5, 10, 10 )

    function self.RefreshMembers()
        scrollPanel:Clear()

        local showMembers = {}
        for k, v in pairs( self.gangTable.Members ) do
            if( (searchBar:GetValue() != "" and not string.find( string.lower( v[1] ), string.lower( searchBar:GetValue() ) )) ) then
                continue
            end
            
            local memberPly = player.GetBySteamID( k )

            table.insert( showMembers, { v[2]+((not IsValid( memberPly ) and 100) or 0), IsValid( memberPly ), k, v[1], v[2] } ) -- sort value, online, steamid, name, groupid
        end

        table.SortByMember( showMembers, 1, true )

        for k, v in ipairs( showMembers ) do
            local actions = {}

            table.insert( actions, { BRICKS_SERVER.Func.L( "gangSetRank" ), function()
                local options = {}
                for k, v in pairs( self.gangTable.Roles or {} ) do
                    options[k] = v[1]
                end

                BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "gangRankQuery" ), (v[5] or 1), options, function( value, data ) 
                    if( (self.gangTable.Roles or {})[data] ) then
                        if( v[5] != data ) then
                            net.Start( "BRS.Net.AdminGangCMD" )
                                net.WriteUInt( 7, 8 )
                                net.WriteUInt( self.gangID, 16 )
                                net.WriteTable( { v[3], data } )
                            net.SendToServer()
                        else
                            notification.AddLegacy( BRICKS_SERVER.Func.L( "gangPlayerAlreadyRank" ), 1, 3 )
                        end
                    else
                        notification.AddLegacy( BRICKS_SERVER.Func.L( "gangInvalidRank" ), 1, 3 )
                    end
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
            end } )

            if( self.gangTable.Owner != v[3] ) then
                table.insert( actions, { BRICKS_SERVER.Func.L( "gangKick" ), function()
                    net.Start( "BRS.Net.AdminGangCMD" )
                        net.WriteUInt( 6, 8 )
                        net.WriteUInt( self.gangID, 16 )
                        net.WriteTable( { v[3] } )
                    net.SendToServer()
                end } )

                table.insert( actions, { BRICKS_SERVER.Func.L( "gangSetOwner" ), function()
                    net.Start( "BRS.Net.AdminGangCMD" )
                        net.WriteUInt( 8, 8 )
                        net.WriteUInt( self.gangID, 16 )
                        net.WriteTable( { v[3] } )
                    net.SendToServer()
                end } )
            end

            local playerBack = BRICKS_SERVER.Func.GangCreateMemberSlot( scrollPanel, (self.panelWide*0.3)-20, 75, v[3], v[4], v[5], self.gangTable, actions )
            playerBack:Dock( TOP )
            playerBack:DockMargin( 0, 0, 0, 5 )
        end
    end
    self.RefreshMembers()

    searchBar.OnChange = function()
        self.RefreshMembers()
    end
end

function PANEL:ViewMembers()
    self.activePage = BRICKS_SERVER.Func.L( "gangMembers" )

    self.popoutContent:AlphaTo( 0, 0.1, 0, function()
        self:FillMembers()
        self.popoutContent:AlphaTo( 255, 0.1 )
    end )

    local popoutWide, popoutTall = self.panelWide*0.3, self.panelTall*0.7
    self.popout:SizeTo( popoutWide, popoutTall, 0.2 )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_admin_popup", PANEL, "DPanel" )