local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( gangTable )
    local graphs = {
        [1] = {
            Title = BRICKS_SERVER.Func.L( "gangMembers" ),
            Color1 = Color( 128, 38, 38 ),
            Color2 = Color( 210, 74, 74 ),
            HighlightColor = Color( 201, 70, 70 ),
            SubTitle = function() 
                local memberCount = table.Count( gangTable.Members or {} )
                return memberCount .. ((memberCount != 1 and " PLAYERS") or " PLAYER")
            end,
            BottomTitle = "MEMBERS ONLINE",
            BottomSubTitle = function() 
                local onlineCount = 0
                for k, v in pairs( gangTable.Members or {} ) do
                    local ply = player.GetBySteamID( k )

                    if( IsValid( ply ) ) then
                        onlineCount = onlineCount+1
                    end
                end
                return onlineCount
            end
        },
        [2] = {
            Title = BRICKS_SERVER.Func.L( "gangBalance" ),
            Color1 = Color( 39, 128, 100 ),
            Color2 = Color( 74, 211, 114 ),
            HighlightColor = Color( 71, 204, 112 ),
            SubTitle = function() return DarkRP.formatMoney( gangTable.Money or 0 ) end,
            BottomTitle = "LAST TRANSACTION",
            BottomSubTitle = function() 
                local transaction

                if( transaction ) then
                    return {
                        { ((transaction >= 0 and "+") or "-") .. DarkRP.formatMoney( transaction ), "BRICKS_SERVER_Font33", ((transaction >= 0 and Color( 71, 204, 112 )) or Color( 229, 62, 62 )) }
                    }
                else
                    return "???"
                end
            end
        },
        [4] = {
            Title = BRICKS_SERVER.Func.L( "gangLevel" ),
            Color1 = Color( 196, 32, 201 ),
            Color2 = Color( 166, 61, 212 ),
            HighlightColor = Color( 194, 34, 202 ),
            SubTitle = function() return gangTable.Level or 0 end,
            BottomTitle = "XP PROGRESS",
            BottomSubTitle = function() 
                local currentXP = math.max( 0, (gangTable.Experience or 0)-BRICKS_SERVER.Func.GetGangExpToLevel( 0, (gangTable.Level or 0) ) )
                local goalXP = math.max( 0, BRICKS_SERVER.Func.GetGangExpToLevel( (gangTable.Level or 0), (gangTable.Level or 0)+1 ) )
                return {
                    { string.Comma( math.floor( currentXP ) ) }, 
                    { "/" .. string.Comma( math.floor( goalXP ) ) .. "XP", "BRICKS_SERVER_Font28B", Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ) }
                }
            end,
        }
    }

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "storage" ) ) then
        graphs[3] = {
            Title = BRICKS_SERVER.Func.L( "gangStorage" ),
            Color1 = Color( 76, 113, 212 ),
            Color2 = Color( 81, 80, 171 ),
            HighlightColor = Color( 80, 84, 175 ),
            SubTitle = function() 
                return {
                    { table.Count( gangTable.Storage or {} ) }, 
                    { "/" .. BRICKS_SERVER.Func.GangGetUpgradeInfo( LocalPlayer():GetGangID(), "StorageSlots" )[1], "BRICKS_SERVER_Font28B" }
                }
            end,
            BottomTitle = "STORAGE USED",
            BottomSubTitle = function() return math.Clamp( 100*(table.Count( gangTable.Storage or {} )/BRICKS_SERVER.Func.GangGetUpgradeInfo( LocalPlayer():GetGangID(), "StorageSlots" )[1]), 0, 100 ) .. "% FILLED" end
        }
    else
        graphs[3] = {
            Title = BRICKS_SERVER.Func.L( "gangStorage" ),
            Color1 = Color( 76, 113, 212 ),
            Color2 = Color( 81, 80, 171 ),
            HighlightColor = Color( 80, 84, 175 ),
            SubTitle = function() 
                return {
                    { 0 }, 
                    { "/" .. 0, "BRICKS_SERVER_Font28B" }
                }
            end,
            BottomTitle = "STORAGE DISABLED",
            BottomSubTitle = function() return "0% FILLED" end
        }
    end

    local outerMargin = 24

    local panelWide = self.panelWide-(2*outerMargin)
    
    local statisticsBack = vgui.Create( "DPanel", self )
    statisticsBack:Dock( TOP )
    statisticsBack:DockMargin( outerMargin, outerMargin, outerMargin, 0 )
    statisticsBack:DockPadding( 0, 35, 0, 0 )
    statisticsBack:SetTall( BRICKS_SERVER.Func.ScreenScale( 275 ) )
    statisticsBack.Paint = function( self2, w, h ) 
        draw.SimpleText( BRICKS_SERVER.Func.L( "gangInformation" ), "BRICKS_SERVER_Font30", 0, 0, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 150 ), 0, 0 )
    end

    local graphSpacing = 30
    local graphWide = (panelWide-((#graphs-1)*graphSpacing))/#graphs
    local graphBackTall = statisticsBack:GetTall()-35

    for k, v in ipairs( graphs ) do
        local graphBack = vgui.Create( "DPanel", statisticsBack )
        graphBack:Dock( LEFT )
        graphBack:DockMargin( 0, 0, graphSpacing, 0 )
        graphBack:SetWide( graphWide )
        graphBack.Paint = function( self2, w, h ) end

        local graphTop = vgui.Create( "DPanel", graphBack )
        graphTop:Dock( TOP )
        graphTop:SetTall( graphBackTall*0.6 )
        graphTop.Paint = function( self2, w, h ) 
            BRICKS_SERVER.Func.DrawGradientRoundedBox( 8, 0, 0, w, h, 1, v.Color1, v.Color2 )

            draw.SimpleText( string.upper( v.Title ), "BRICKS_SERVER_Font28B", w/2, h/2+4, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

            if( not istable( v.SubTitle() ) ) then
                draw.SimpleText( v.SubTitle(), "BRICKS_SERVER_Font36B", w/2, h/2-4, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
            else
                local textW, textH = 0, 0
                for k, v in pairs( v.SubTitle() ) do
                    surface.SetFont( v[2] or "BRICKS_SERVER_Font36B" )
                    local addTextW, addTextH = surface.GetTextSize( v[1] or "" )
                    textW, textH = textW+addTextW, math.max( textH, addTextH )
                end

                local previousTextW = 0
                for k, v in pairs( v.SubTitle() ) do
                    surface.SetFont( v[2] or "BRICKS_SERVER_Font36B" )
                    local newTextW, newTextH = surface.GetTextSize( v[1] or "" )

                    draw.SimpleText( v[1], (v[2] or "BRICKS_SERVER_Font36B"), (w/2)-(textW/2)+previousTextW, h/2-4+textH, (v[3] or BRICKS_SERVER.Func.GetTheme( 6 )), 0, TEXT_ALIGN_BOTTOM )

                    previousTextW = previousTextW+newTextW
                end
            end
        end

        surface.SetFont( "BRICKS_SERVER_Font21" )
        local bottomTitleX, bottomTitleY = surface.GetTextSize( v.BottomTitle or "" )

        surface.SetFont( "BRICKS_SERVER_Font33" )
        local bottomSubTitleX, bottomSubTitleY = 0, 0

        if( not istable( v.BottomSubTitle() ) ) then
            bottomSubTitleX, bottomSubTitleY = surface.GetTextSize( v.BottomSubTitle() or "" )
        else
            for k, v in pairs( v.BottomSubTitle() ) do
                surface.SetFont( v[2] or "BRICKS_SERVER_Font33" )
                local addTextW, addTextH = surface.GetTextSize( v[1] or "" )
                bottomSubTitleX, bottomSubTitleY = bottomSubTitleX+addTextW, math.max( bottomSubTitleY, addTextH )
            end
        end

        local textSpacing = -6
        local contentH = bottomTitleY+textSpacing+bottomSubTitleY

        local graphBottom = vgui.Create( "DPanel", graphBack )
        graphBottom:Dock( BOTTOM )
        graphBottom:SetTall( graphBackTall-graphTop:GetTall()-BRICKS_SERVER.Func.ScreenScale( 20 ) )
        graphBottom.Paint = function( self2, w, h ) 
            draw.RoundedBox( 10, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

            BRICKS_SERVER.Func.DrawPartialRoundedBox( 8, 0, 0, w, 8, v.Color2, w, 20 )

            local startY = 8+((h-8)/2)-(contentH/2)-2

            draw.SimpleText( v.BottomTitle, "BRICKS_SERVER_Font21", 25, startY, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ) )

            if( not istable( v.BottomSubTitle() ) ) then
                draw.SimpleText( v.BottomSubTitle(), "BRICKS_SERVER_Font33", 25, startY+bottomTitleY+textSpacing, BRICKS_SERVER.Func.GetTheme( 6 ) )
            else
                local previousTextW = 0
                for k, v in pairs( v.BottomSubTitle() ) do
                    surface.SetFont( v[2] or "BRICKS_SERVER_Font33" )
                    local newTextW, newTextH = surface.GetTextSize( v[1] or "" )

                    draw.SimpleText( v[1], (v[2] or "BRICKS_SERVER_Font33"), 25+previousTextW, startY+bottomTitleY+textSpacing+bottomSubTitleY, (v[3] or BRICKS_SERVER.Func.GetTheme( 6 )), 0, TEXT_ALIGN_BOTTOM )

                    previousTextW = previousTextW+newTextW
                end
            end
        end
    end

    local bottomBack = vgui.Create( "DPanel", self )
    bottomBack:Dock( FILL )
    bottomBack:DockMargin( outerMargin, outerMargin, outerMargin, outerMargin )
    bottomBack.Paint = function( self2, w, h ) end

    local memberLeftMargin = 25

    local membersBack = vgui.Create( "DPanel", bottomBack )
    membersBack:Dock( LEFT )
    membersBack:SetWide( panelWide*0.38 )
    membersBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        BRICKS_SERVER.Func.DrawPartialRoundedBox( 8, 0, 0, w, 10, BRICKS_SERVER.Func.GetTheme( 3 ), w, 20 )

        draw.SimpleText( string.upper( BRICKS_SERVER.Func.L( "gangMembers" ) ), "BRICKS_SERVER_Font21", memberLeftMargin, 25, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ) )
    end

    local membersScroll = vgui.Create( "bricks_server_scrollpanel_bar", membersBack )
    membersScroll:Dock( FILL )
    membersScroll:DockMargin( memberLeftMargin, 60, 15, 25 )

    function self.RefreshMembers()
        membersScroll:Clear()

        local showMembers = {}
        for k, v in pairs( gangTable.Members ) do
            local memberPly = player.GetBySteamID( k )

            table.insert( showMembers, { v[2]+((not IsValid( memberPly ) and 100) or 0), IsValid( memberPly ), k, v[1], v[2] } ) -- sort value, online, steamid, name, groupid
        end

        table.SortByMember( showMembers, 1, true )

        for k, v in pairs( showMembers ) do
            local playerEnt = player.GetBySteamID( v[3] )
            local playerName = v[4]
        
            if( IsValid( playerEnt ) ) then
                playerName = playerEnt:Nick()
            end

            local avatarBoxH = BRICKS_SERVER.Func.ScreenScale( 50 )
            local circleRadius = BRICKS_SERVER.Func.ScreenScale( 7 )

            surface.SetFont( "BRICKS_SERVER_Font33" )
            local bottomTitleX, bottomTitleY = surface.GetTextSize( playerName or "" )
    
            surface.SetFont( "BRICKS_SERVER_Font21" )
            local bottomSubTitleX, bottomSubTitleY = surface.GetTextSize( gangTable.Roles[v[5]][1] or "" )
    
            local textSpacing = -2
            local contentH = bottomTitleY+textSpacing+bottomSubTitleY

            local playerBack = vgui.Create( "DPanel", membersScroll )
            playerBack:Dock( TOP )
            playerBack:DockMargin( 0, 0, 0, 15 )
            playerBack:SetTall( avatarBoxH+(circleRadius*0.45) )
            local alpha = 0
            local playerButton
            local clickColor = Color( BRICKS_SERVER.Func.GetTheme( 0 ).r, BRICKS_SERVER.Func.GetTheme( 0 ).g, BRICKS_SERVER.Func.GetTheme( 0 ).b, 50 )
            playerBack.Paint = function( self2, w, h )
                if( IsValid( playerButton ) ) then
                    if( not playerButton:IsDown() and playerButton:IsHovered() ) then
                        alpha = math.Clamp( alpha+3, 0, 50 )
                    else
                        alpha = math.Clamp( alpha-3, 0, 50 )
                    end
            
                    draw.RoundedBox( 5, 0, 0, w, h, Color( BRICKS_SERVER.Func.GetTheme( 0 ).r, BRICKS_SERVER.Func.GetTheme( 0 ).g, BRICKS_SERVER.Func.GetTheme( 0 ).b, alpha ) )
        
                    BRICKS_SERVER.Func.DrawClickCircle( playerButton, w, h, clickColor )
                end

                local startY = (avatarBoxH/2)-(contentH/2)-2

                draw.SimpleText( playerName, "BRICKS_SERVER_Font33", avatarBoxH+15, startY, BRICKS_SERVER.Func.GetTheme( 6 ) )
                draw.SimpleText( string.upper( gangTable.Roles[v[5]][1] ), "BRICKS_SERVER_Font21", avatarBoxH+15+1, startY+bottomTitleY+textSpacing, (gangTable.Roles[v[5]][2] or BRICKS_SERVER.Func.GetTheme( 6 )) )
            end

            local playerIcon = vgui.Create( "bricks_server_rounded_avatar" , playerBack )
            playerIcon:SetPos( 0, 0 )
            playerIcon:SetSize( avatarBoxH, avatarBoxH )
            playerIcon.rounded = 8
            if( IsValid( playerEnt ) ) then
                playerIcon:SetPlayer( playerEnt, 64 )
            else
                playerIcon:SetSteamID( util.SteamIDTo64( v[3] ), 64 )
            end

            playerButton = vgui.Create( "DButton", playerBack )
            playerButton:SetSize( (panelWide*0.38)-memberLeftMargin-15, avatarBoxH+(circleRadius*0.45) )
            playerButton:SetText( "" )
            local x, y, w, h = 0, 0, playerButton:GetWide(), playerButton:GetTall()
            playerButton.Paint = function( self2, w, h )
                local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
                if( x != toScreenX or y != toScreenY ) then
                    x, y = toScreenX, toScreenY
                end

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                draw.NoTexture()
                BRICKS_SERVER.Func.DrawCircle( h-circleRadius, h-circleRadius, circleRadius+2, 45 )
        
                draw.NoTexture()
                if( IsValid( playerEnt ) ) then
                    surface.SetDrawColor( BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
                else
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                end
                BRICKS_SERVER.Func.DrawCircle( h-circleRadius, h-circleRadius, circleRadius, 45 )
            end
            playerButton.DoClick = function( self2 )
                self2.Menu = vgui.Create( "bricks_server_dmenu" )

                if( not actions ) then
                    if( LocalPlayer():GangHasPermission( "ChangePlayerRoles" ) ) then
                        self2.Menu:AddOption( "Set rank", function()
                            local options = {}
                            for k, v in pairs( gangTable.Roles or {} ) do
                                options[k] = v[1]
                            end

                            BRICKS_SERVER.Func.ComboRequest( "Gang", BRICKS_SERVER.Func.L( "gangRankQuery" ), groupID, options, function( value, data ) 
                                if( (gangTable.Roles or {})[data] ) then
                                    if( groupID != data ) then
                                        net.Start( "BRS.Net.GangSetRank" )
                                            net.WriteString( v[3] )
                                            net.WriteUInt( data, 16 )
                                        net.SendToServer()
                                    else
                                        notification.AddLegacy( BRICKS_SERVER.Func.L( "gangPlayerAlreadyRank" ), 1, 3 )
                                    end
                                else
                                    notification.AddLegacy( BRICKS_SERVER.Func.L( "gangInvalidRank" ), 1, 3 )
                                end
                            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
                        end )
                    end

                    if( LocalPlayer():GangHasPermission( "KickPlayers" ) ) then
                        self2.Menu:AddOption( BRICKS_SERVER.Func.L( "gangKick" ), function()
                            BRICKS_SERVER.Func.Query( BRICKS_SERVER.Func.L( "gangKickConfirm" ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function() 
                                net.Start( "BRS.Net.GangKick" )
                                    net.WriteString( v[3] )
                                net.SendToServer()
                            end )
                        end )
                    end
                else
                    for k, v in pairs( actions ) do
                        self2.Menu:AddOption( v[1], v[2] )
                    end
                end

                self2.Menu:Open()
                self2.Menu:SetPos( x+w+5, y+(h/2)-(self2.Menu:GetTall()/2) )
            end
        end
    end
    self.RefreshMembers()

    local actionsBack = vgui.Create( "DPanel", bottomBack )
    actionsBack:Dock( RIGHT )
    actionsBack:SetWide( graphWide )
    actionsBack:DockPadding( 0, 35, 0, 0 )
    actionsBack.Paint = function( self2, w, h ) 
        draw.SimpleText( string.upper( BRICKS_SERVER.Func.L( "gangActions" ) ), "BRICKS_SERVER_Font21", 0, 0, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ) )
    end

    local actionsScroll = vgui.Create( "bricks_server_scrollpanel", actionsBack )
    actionsScroll:Dock( FILL )

    local actions = {}

    if( LocalPlayer():GangHasPermission( "DepositMoney" ) ) then
        table.insert( actions, {
            Name = BRICKS_SERVER.Func.L( "gangDepositMoney" ),
            Color = Color( 207, 72, 72 ),
            ColorDown = BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed,
            Func = function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "gangDepositMoneyQuery" ), (BRICKS_SERVER.CONFIG.GANGS["Minimum Deposit"] or 1000), function( number ) 
                    if( (gangTable.Money or 0)+number <= BRICKS_SERVER.Func.GangGetUpgradeInfo( LocalPlayer():GetGangID(), "MaxBalance" )[1] ) then
                        if( number >= (BRICKS_SERVER.CONFIG.GANGS["Minimum Deposit"] or 1000) ) then
                            net.Start( "BRS.Net.GangDepositMoney" )
                                net.WriteUInt( number, 32 )
                            net.SendToServer()
                        else
                            BRICKS_SERVER.Func.Message( BRICKS_SERVER.Func.L( "gangDepositMoneyLess", DarkRP.formatMoney( BRICKS_SERVER.CONFIG.GANGS["Minimum Deposit"] or 1000 ) ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ) )
                        end
                    else
                        BRICKS_SERVER.Func.Message( BRICKS_SERVER.Func.L( "gangDepositMoneyMuch" ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ) )
                    end
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            end
        } )
    end

    if( LocalPlayer():GangHasPermission( "WithdrawMoney" ) ) then
        table.insert( actions, {
            Name = BRICKS_SERVER.Func.L( "gangWithdrawMoney" ),
            Color = Color( 65, 190, 110 ),
            ColorDown = BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen,
            Func = function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "gangWithdrawMoneyQuery" ), (BRICKS_SERVER.CONFIG.GANGS["Minimum Withdraw"] or 1000), function( number ) 
                    if( (gangTable.Money or 0) >= number ) then
                        if( number >= (BRICKS_SERVER.CONFIG.GANGS["Minimum Withdraw"] or 1000) ) then
                            net.Start( "BRS.Net.GangWithdrawMoney" )
                                net.WriteUInt( number, 32 )
                            net.SendToServer()
                        else
                            BRICKS_SERVER.Func.Message( BRICKS_SERVER.Func.L( "gangWithdrawMoneyLess", DarkRP.formatMoney( BRICKS_SERVER.CONFIG.GANGS["Minimum Withdraw"] or 1000 ) ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ) )
                        end
                    else
                        BRICKS_SERVER.Func.Message( BRICKS_SERVER.Func.L( "gangWithdrawMoneyMuch" ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ) )
                    end
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            end
        } )
    end

    if( LocalPlayer():GangHasPermission( "InvitePlayers" ) ) then
        table.insert( actions, {
            Name = BRICKS_SERVER.Func.L( "gangInvitePlayer" ),
            Func = function()
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
        } )
    end

    if( gangTable.Owner == LocalPlayer():SteamID() ) then
        table.insert( actions, {
            Name = BRICKS_SERVER.Func.L( "gangDisband" ),
            Func = function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "gangDisbandQuery", string.upper( gangTable.Name ) ), "", function( text ) 
                    if( text == string.upper( gangTable.Name ) ) then
                        net.Start( "BRS.Net.GangDisband" )
                        net.SendToServer()
                    end
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
            end
        } )

        table.insert( actions, {
            Name = BRICKS_SERVER.Func.L( "gangTransfer" ),
            Func = function()
                local options = {}
                for k, v in pairs( gangTable.Members ) do
                    if( (gangTable.Owner or "") == k ) then continue end

                    options[k] = v[1]
                end
    
                BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "gangTransferQuery" ), BRICKS_SERVER.Func.L( "none" ), options, function( value, data ) 
                    if( options[data] ) then
                        net.Start( "BRS.Net.GangTransfer" )
                            net.WriteString( data )
                        net.SendToServer()
                    else
                        notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidPlayer" ), 1, 3 )
                    end
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            end
        } )
    else
        table.insert( actions, {
            Name = BRICKS_SERVER.Func.L( "gangLeave" ),
            Func = function()
                BRICKS_SERVER.Func.Query( BRICKS_SERVER.Func.L( "gangLeaveQuery" ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function() 
                    net.Start( "BRS.Net.GangLeave" )
                    net.SendToServer()
                end )
            end
        } )
    end

    for k, v in pairs( actions ) do
        local action = vgui.Create( "DButton", actionsScroll )
        action:Dock( TOP )
        action:SetTall( BRICKS_SERVER.Func.ScreenScale( 50 ) )
        action:DockMargin( 0, 0, 0, BRICKS_SERVER.Func.ScreenScale( 15 ) )
        action:SetText( "" )
        local Alpha = 0
        action.Paint = function( self2, w, h ) 
            if( not self2:IsDown() and self2:IsHovered() ) then
                Alpha = math.Clamp( Alpha+5, 0, 100 )
            else
                Alpha = math.Clamp( Alpha-5, 0, 100 )
            end
        
            draw.RoundedBox( 8, 0, 0, w, h, (v.Color or BRICKS_SERVER.Func.GetTheme( 2 )) )

            surface.SetAlphaMultiplier( Alpha/255 )
            draw.RoundedBox( 8, 0, 0, w, h, (v.ColorDown or BRICKS_SERVER.Func.GetTheme( 3 )) )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, (v.ColorDown or BRICKS_SERVER.Func.GetTheme( 3 )) )

            draw.SimpleText( string.upper( v.Name ), "BRICKS_SERVER_Font21", 15, h/2, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 100 ), 0, TEXT_ALIGN_CENTER )
        end
        action.DoClick = v.Func
    end

    local chatBack = vgui.Create( "DPanel", bottomBack )
    chatBack:Dock( FILL )
    chatBack:DockMargin( outerMargin, 0, outerMargin, 0 )
    chatBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        BRICKS_SERVER.Func.DrawPartialRoundedBox( 8, 0, 0, w, 10, BRICKS_SERVER.Func.GetTheme( 3 ), w, 20 )

        draw.SimpleText( string.upper( BRICKS_SERVER.Func.L( "gangChat" ) ), "BRICKS_SERVER_Font21", memberLeftMargin, 25, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ) )
    end

    local chatMessageBack
    if( LocalPlayer():GangHasPermission( "SendMessages" ) ) then
        chatMessageBack = vgui.Create( "DPanel", chatBack )
        chatMessageBack:Dock( BOTTOM )
        chatMessageBack:DockMargin( 15, 0, 15, 15 )
        chatMessageBack:SetTall( BRICKS_SERVER.Func.ScreenScale( 40 ) )
        chatMessageBack.Paint = function( self2, w, h ) 
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        end

        local chatMessageEntry
        local function sendChatMessage()
            if( BRICKS_SERVER.CONFIG.GANGS["Disable Gang Chat"] ) then
                BRICKS_SERVER.Func.Message( BRICKS_SERVER.Func.L( "gangMessageDisabled" ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ) )
                return
            end

            local message = chatMessageEntry:GetValue()
            if( message and message != "" ) then
                net.Start( "BRS.Net.GangSendMessage" )
                    net.WriteString( message )
                net.SendToServer()
            end

            chatMessageEntry:SetText( "" )
        end

        local chatMessageButton = vgui.Create( "DButton", chatMessageBack )
        chatMessageButton:Dock( RIGHT )
        chatMessageButton:SetWide( chatMessageBack:GetTall() )
        chatMessageButton:SetText( "" )
        local Alpha = 0
        local sendMat = Material( "bricks_server/gang_send.png" )
        chatMessageButton.Paint = function( self2, w, h ) 
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
            surface.SetMaterial( sendMat )
            local iconSize = BRICKS_SERVER.Func.ScreenScale( 24 )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        chatMessageButton.DoClick = sendChatMessage

        chatMessageEntry = vgui.Create( "bricks_server_search", chatMessageBack )
        chatMessageEntry:Dock( FILL )
        chatMessageEntry:DockMargin( 10, 0, 0, 0 )
        chatMessageEntry:SetFont( "BRICKS_SERVER_Font21" )
        chatMessageEntry.backFont = "BRICKS_SERVER_Font21"
        chatMessageEntry.backText = string.upper( BRICKS_SERVER.Func.L( "gangMessage" ) .. "..." )
        chatMessageEntry.backTextColor = Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 )
        chatMessageEntry.OnEnter = sendChatMessage
    end

    local chatScroll = vgui.Create( "bricks_server_scrollpanel_bar", chatBack )
    chatScroll:Dock( BOTTOM )
    chatScroll:DockMargin( 15, 0, 15, 15 )
    chatScroll.Paint = function( self2, w, h ) end
    local scrollH = 0
    chatScroll.pnlCanvas.Paint = function( self2, w, h ) 
        if( scrollH != h ) then
            scrollH = h
            chatScroll.VBar:AnimateTo( scrollH, 0 ) 
        end
    end

    local chatScrollMaxH = (ScrH()*0.65)-40-(2*outerMargin)-statisticsBack:GetTall()-outerMargin-60-((chatMessageBack and 55) or 0)-10

    self.chatSlots = 0
    function self.AddGangChatMessage( time, message, memberSteamID )
        self.chatSlots = self.chatSlots+1
        chatScroll:SetTall( math.min( chatScrollMaxH, chatScroll:GetTall()+((self.chatSlots % 2 == 0 and 15) or 0) ) )

        local memberTable = (gangTable.Members or {})[memberSteamID] or {}
        local groupData = (gangTable.Roles or {})[memberTable[2] or 0] or {}

        surface.SetFont( "BRICKS_SERVER_Font21" )
        local bottomTitleX, bottomTitleY = surface.GetTextSize( memberTable[1] or "NIL" )

        surface.SetFont( "BRICKS_SERVER_Font26" )
        local bottomSubTitleX, bottomSubTitleY = surface.GetTextSize( message or "" )

        surface.SetFont( "BRICKS_SERVER_Font17" )
        local timeTextX, timeTextY = surface.GetTextSize( BRICKS_SERVER.Func.FormatTimeInPlace( time ) or "" )

        local bottomTitleFullW = bottomTitleX+8+timeTextX
        local messageWidth = (2*12)+((bottomSubTitleX > bottomTitleFullW and bottomSubTitleX) or bottomTitleFullW)

        local textSpacing = -6
        local contentH = bottomTitleY+textSpacing+bottomSubTitleY

        local messageEntry = vgui.Create( "DPanel", chatScroll )
        messageEntry:Dock( TOP )
        messageEntry:DockMargin( 0, 15, math.max( 10, panelWide-(2*outerMargin)-membersBack:GetWide()-graphWide-messageWidth-30-10 ), 0 )
        messageEntry:SetTall( 60 )
        local messageWrap, lineCount
        messageEntry.Paint = function( self2, w, h ) 
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            local startY = (h/2)-(contentH/2)-2

            draw.SimpleText( (memberTable[1] or "NIL"), "BRICKS_SERVER_Font21", 12, startY, (groupData[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )

            if( not messageWrap ) then
                messageWrap, lineCount = BRICKS_SERVER.Func.TextWrap( message, "BRICKS_SERVER_Font26", w-24 )
                messageEntry:SetTall( 60+((lineCount-1)*bottomSubTitleY) )
                contentH = bottomTitleY+textSpacing+(lineCount*bottomSubTitleY)
                chatScroll:SetTall( math.min( chatScrollMaxH, chatScroll:GetTall()+messageEntry:GetTall() ) )
            end

            BRICKS_SERVER.Func.DrawNonParsedText( messageWrap, "BRICKS_SERVER_Font26", 12, startY+bottomTitleY+textSpacing, BRICKS_SERVER.Func.GetTheme( 6 ), 0 )

            draw.SimpleText( BRICKS_SERVER.Func.FormatTimeInPlace( time ), "BRICKS_SERVER_Font15", 12+bottomTitleX+8, startY+bottomTitleY-1, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ), 0, TEXT_ALIGN_BOTTOM )
        end

        return messageEntry
    end

    function self.RefreshGangChat()
        chatScroll:Clear()
        self.chatSlots = 0

        local gangID = LocalPlayer():GetGangID()

        if( not BRS_GANG_CHATS or not BRS_GANG_CHATS[gangID] ) then return end

        local sortedMessages = table.Copy( BRS_GANG_CHATS[gangID] )
        table.SortByMember( sortedMessages, 1, true )

        for k, v in ipairs( sortedMessages ) do
            local messageEntry = self.AddGangChatMessage( v[1], v[2], v[3] )
        end
    end
    self.RefreshGangChat()

    hook.Add( "BRS.Hooks.InsertGangChat", self, function( self, messageKey )
        if( IsValid( self ) ) then
            local gangID = LocalPlayer():GetGangID()
            local messageTable = ((BRS_GANG_CHATS or {})[gangID] or {})[messageKey]

            if( not messageTable ) then return end

            self.AddGangChatMessage( messageTable[1], messageTable[2], messageTable[3] )
            surface.PlaySound( "UI/buttonclick.wav" ) 
        else
            hook.Remove( "BRS.Hooks.InsertGangChat", self )
        end
    end )

    local inboxButton = vgui.Create( "DButton", self )
    inboxButton:SetSize( BRICKS_SERVER.Func.ScreenScale( 40 ), BRICKS_SERVER.Func.ScreenScale( 40 ) )
    inboxButton:SetPos( panelWide+outerMargin-inboxButton:GetWide(), ((outerMargin+35)/2)-(inboxButton:GetTall()/2) )
    inboxButton:SetText( "" )
    local Alpha = 0
    local inboxMat = Material( "bricks_server/invite.png" )
    inboxButton.Paint = function( self2, w, h )
        if( self2:IsDown() ) then
            Alpha = 0
        elseif( self2:IsHovered() ) then
            Alpha = math.Clamp( Alpha+5, 0, 35 )
        else
            Alpha = math.Clamp( Alpha-5, 0, 35 )
        end
    
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
        surface.SetAlphaMultiplier( Alpha/255 )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        surface.SetAlphaMultiplier( 1 )
    
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
        surface.SetMaterial( inboxMat )
        local iconSize = BRICKS_SERVER.Func.ScreenScale( 24 )
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end

    BRICKS_SERVER.Func.GangCreateInbox( self, inboxButton, false, 0, inboxButton:GetPos() )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_dashboard", PANEL, "DPanel" )