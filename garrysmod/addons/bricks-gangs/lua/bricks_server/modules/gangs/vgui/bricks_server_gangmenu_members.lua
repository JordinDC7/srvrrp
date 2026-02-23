local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( gangTable )
    local topBar = vgui.Create( "DPanel", self )
    topBar:Dock( TOP )
    topBar:DockMargin( 10, 10, 10, 5 )
    topBar:SetTall( 40 )
    topBar.Paint = function( self2, w, h ) end

    if( LocalPlayer():GangHasPermission( "InvitePlayers" ) ) then
        local invite = vgui.Create( "DButton", topBar )
        invite:Dock( RIGHT )
        invite:DockMargin( 5, 0, 0, 0 )
        invite:SetWide( 40 )
        invite:SetText( "" )
        local Alpha = 0
        local inviteMat = Material( "bricks_server/invite.png" )
        invite.Paint = function( self2, w, h )
            if( self2:IsDown() ) then
                Alpha = 0
            elseif( self2:IsHovered() ) then
                Alpha = math.Clamp( Alpha+5, 0, 100 )
            else
                Alpha = math.Clamp( Alpha-5, 0, 100 )
            end
        
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            surface.SetAlphaMultiplier( Alpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )
        
            surface.SetDrawColor( 255, 255, 255, 20+(235*(Alpha/100)) )
            surface.SetMaterial( inviteMat )
            local iconSize = 24
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        invite.DoClick = function()
            local options = {}
            for k, v in pairs( player.GetAll() ) do
                if( gangTable.Members[v:SteamID()] ) then continue end
                
                options[v:SteamID()] = v:Nick() .. " (" .. ((not v:IsBot() and v:SteamID()) or "BOT") .. ")"
            end

            BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "gangInvitePlayerQuery" ), BRICKS_SERVER.Func.L( "none" ), options, function( value, data ) 
                if( options[data] ) then
                    net.Start( "BRS.Net.GangInvite" )
                        net.WriteString( data )
                    net.SendToServer()
                else
                    notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidPlayer" ), 1, 3 )
                end
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
        end
    end

    local sortBy = vgui.Create( "bricks_server_combo", topBar )
    sortBy:Dock( RIGHT )
    sortBy:DockMargin( 5, 0, 0, 0 )
    sortBy:SetWide( 150 )
    sortBy:SetValue( BRICKS_SERVER.Func.L( "gangHighestRank" ) )
    local sortChoice = "rank_low_to_high"
    sortBy:AddChoice( BRICKS_SERVER.Func.L( "gangHighestRank" ), "rank_low_to_high" )
    sortBy:AddChoice( BRICKS_SERVER.Func.L( "gangLowestRank" ), "rank_high_to_low" )
    sortBy:AddChoice( "Online First", "online" )
    sortBy.OnSelect = function( self2, index, value, data )
        sortChoice = data
        self.RefreshPanel()
    end

    local searchBarBack = vgui.Create( "DPanel", topBar )
    searchBarBack:Dock( FILL )
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


    local memberCount = table.Count( gangTable.Members or {} )
    local onlineCount = 0
    for steamID, _ in pairs( gangTable.Members or {} ) do
        if( IsValid( player.GetBySteamID( steamID ) ) ) then
            onlineCount = onlineCount+1
        end
    end

    local statsBar = vgui.Create( "DPanel", self )
    statsBar:Dock( TOP )
    statsBar:DockMargin( 10, 0, 10, 5 )
    statsBar:SetTall( 20 )
    statsBar.Paint = function( self2, w, h )
        draw.SimpleText( BRICKS_SERVER.Func.L( "gangMembers" ) .. ": " .. string.Comma( memberCount ), "BRICKS_SERVER_Font17", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 1 )
        draw.SimpleText( "ONLINE: " .. string.Comma( onlineCount ), "BRICKS_SERVER_Font17", w, h/2, Color( 100, 220, 120 ), TEXT_ALIGN_RIGHT, 1 )
    end

    local scrollPanel = vgui.Create( "bricks_server_scrollpanel", self )
    scrollPanel:Dock( FILL )
    scrollPanel:DockMargin( 10, 0, 10, 10 )
    scrollPanel.Paint = function( self, w, h ) end 

    local spacing = 5
    local gridWide = self.panelWide-20
    local slotsWide = 3
    local slotWide = (gridWide-((slotsWide-1)*spacing))/slotsWide
    local slotTall = 75

    local grid = vgui.Create( "DIconLayout", scrollPanel )
    grid:Dock( TOP )
    grid:SetTall( slotTall )
    grid:SetSpaceY( spacing )
    grid:SetSpaceX( spacing )

    local ownerMat = Material( "bricks_server/crown.png" )

    function self.RefreshPanel()
        grid:Clear()
        grid.slots = 0
        onlineCount = 0

        local showMembers = {}
        for k, v in pairs( gangTable.Members or {} ) do
            local searchValue = string.Trim( string.lower( searchBar:GetValue() or "" ) )
            if( searchValue != "" ) then
                local memberName = string.lower( v[1] or "" )
                local memberSteamID = string.lower( k or "" )
                if( not string.find( memberName, searchValue, 1, true ) and not string.find( memberSteamID, searchValue, 1, true ) ) then
                    continue
                end
            end

            local memberPly = player.GetBySteamID( k )
            if( IsValid( memberPly ) ) then
                onlineCount = onlineCount+1
            end

            local onlineWeight = (IsValid( memberPly ) and 0) or 100

            local sortValue = v[2]+onlineWeight
            if( sortChoice == "online" ) then
                sortValue = onlineWeight
            end

            table.insert( showMembers, { sortValue, k, v[2] } )
        end
        
        if( sortChoice and string.EndsWith( sortChoice, "high_to_low" ) ) then
            table.SortByMember( showMembers, 1, false )
        else
            table.SortByMember( showMembers, 1, true )
        end

        if( sortChoice == "online" ) then
            table.sort( showMembers, function( a, b )
                if( a[1] == b[1] ) then
                    return a[3] < b[3]
                end

                return a[1] < b[1]
            end )
        end

        for k, v in pairs( showMembers ) do
            local memberKey, memberTable = v[2], (gangTable.Members or {})[v[2]]

            grid.slots = (grid.slots or 0)+1
            local slots = grid.slots
            local slotsTall = math.ceil( slots/slotsWide )
            grid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) ) 

            BRICKS_SERVER.Func.GangCreateMemberSlot( grid, slotWide, slotTall, memberKey, memberTable[1], memberTable[2], gangTable )
        end
    end
    self.RefreshPanel()

    searchBar.OnChange = function()
        self.RefreshPanel()
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_members", PANEL, "DPanel" )