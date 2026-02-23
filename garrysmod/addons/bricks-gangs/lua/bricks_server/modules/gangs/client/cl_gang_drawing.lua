local ownerMat = Material( "bricks_server/crown.png" )
function BRICKS_SERVER.Func.GangCreateMemberSlot( parent, width, height, steamID, name, groupID, gangTable, actions )
    local playerEnt = player.GetBySteamID( steamID )
    local playerName = name

    if( IsValid( playerEnt ) ) then
        playerName = playerEnt:Nick()
    end

    local avatarBackSize = height-12
    local textStartPos = height+5

    local onlineSize = 22
    
    local playerBack = parent:Add( "DPanel" )
    playerBack:SetSize( width, height )
    local alpha = 0
    local playerButton
    local clickColor = Color( BRICKS_SERVER.Func.GetTheme( 0 ).r, BRICKS_SERVER.Func.GetTheme( 0 ).g, BRICKS_SERVER.Func.GetTheme( 0 ).b, 50 )
    playerBack.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        
        if( IsValid( playerButton ) ) then
            if( not playerButton:IsDown() and playerButton:IsHovered() ) then
                alpha = math.Clamp( alpha+3, 0, 50 )
            else
                alpha = math.Clamp( alpha-3, 0, 50 )
            end
    
            draw.RoundedBox( 5, 0, 0, w, h, Color( BRICKS_SERVER.Func.GetTheme( 1 ).r, BRICKS_SERVER.Func.GetTheme( 1 ).g, BRICKS_SERVER.Func.GetTheme( 1 ).b, alpha ) )

            BRICKS_SERVER.Func.DrawClickCircle( playerButton, w, h, clickColor )
        end

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.NoTexture()
        BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )

        draw.SimpleText( playerName, "BRICKS_SERVER_Font30", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( gangTable.Roles[groupID][1], "BRICKS_SERVER_Font20", textStartPos+1, h/2-2, (gangTable.Roles[groupID][2] or BRICKS_SERVER.Func.GetTheme( 6 )), 0, 0 )

        draw.NoTexture()
        if( IsValid( playerEnt ) ) then
            surface.SetDrawColor( BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
        else
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        end
        BRICKS_SERVER.Func.DrawArc( width-(height-onlineSize)/2-(onlineSize/2), height/2, onlineSize/2, 1, 0, 360, (IsValid( playerEnt ) and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green) or BRICKS_SERVER.Func.GetTheme( 2 ) )
        BRICKS_SERVER.Func.DrawCircle( width-(height-onlineSize)/2-(onlineSize/2), height/2, (onlineSize-6)/2, 45 )
    end

    if( (gangTable.Owner or "") == steamID ) then
        surface.SetFont( "BRICKS_SERVER_Font30" )
        local nameX, nameY = surface.GetTextSize( playerName )

        local iconSize = 16

        local playerOwner = vgui.Create( "DPanel", playerBack )
        playerOwner:SetSize( iconSize, iconSize )
        playerOwner:SetPos( textStartPos+nameX+5, (height/2+2-(nameY/2))-(iconSize/2) )
        playerOwner.Paint = function( self2, w, h )
            surface.SetDrawColor( 243, 156, 18 )
            surface.SetMaterial( ownerMat )
            surface.DrawTexturedRect( 0, 0, w, h )
        end
    end

    local distance = 2

    local playerIcon = vgui.Create( "bricks_server_circle_avatar" , playerBack )
    playerIcon:SetPos( (height-avatarBackSize)/2+distance, (height-avatarBackSize)/2+distance )
    playerIcon:SetSize( avatarBackSize-(2*distance), avatarBackSize-(2*distance) )
    if( IsValid( playerEnt ) ) then
        playerIcon:SetPlayer( playerEnt, 64 )
    else
        playerIcon:SetSteamID( util.SteamIDTo64( steamID ), 64 )
    end

    playerButton = vgui.Create( "DButton" , playerBack )
    playerButton:SetSize( width, height )
    playerButton:SetText( "" )
    local x, y, w, h = 0, 0, playerButton:GetWide(), playerButton:GetTall()
    playerButton.Paint = function( self2, w, h )
        local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
        if( x != toScreenX or y != toScreenY ) then
            x, y = toScreenX, toScreenY
        end
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
                                    net.WriteString( steamID )
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
                            net.WriteString( steamID )
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

    return playerBack
end

function BRICKS_SERVER.Func.GangGenerateInbox()
    local sortedInbox = {}
    for k, v in pairs( BRS_GANG_INBOXES or {} ) do
        if( k != LocalPlayer():SteamID() and k != LocalPlayer():GetGangID() ) then continue end

        for key, val in pairs( v ) do
            local notificationTable = val
            notificationTable.Key = key
            notificationTable.ReceiverKey = k

            table.insert( sortedInbox, notificationTable )
        end
    end

    return sortedInbox
end

function BRICKS_SERVER.Func.GangCreateInbox( buttonParent, button, showRight, extraY, buttonX, buttonY )
    button.DoClick = function()
        if( IsValid( button.InboxPanel ) ) then 
            button.InboxPanel:Remove()
            return
        end

        button.InboxPanel = vgui.Create( "DPanel", buttonParent )
        button.InboxPanel:SetSize( ScrW()*0.15, ScrH()*0.25 )
        if( not showRight ) then
            button.InboxPanel:SetPos( buttonX-button.InboxPanel:GetWide()+button:GetWide(), buttonY+button:GetTall()+5+extraY )
        else
            button.InboxPanel:SetPos( buttonX, buttonY+button:GetTall()+5+extraY )
        end
        local inboxCount = 0
        button.InboxPanel.Paint = function( self2, w, h )
            local x, y = self2:LocalToScreen( 0, 0 )

            BRICKS_SERVER.BSHADOWS.BeginShadow()
            draw.RoundedBox( 5, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )			
            BRICKS_SERVER.BSHADOWS.EndShadow( 1, 2, 2, 255, 0, 0, false )

            draw.RoundedBoxEx( 5, 0, 0, w, 40, BRICKS_SERVER.Func.GetTheme( 3 ), true, true, false, false )
        
            draw.SimpleText( BRICKS_SERVER.Func.L( "gangInbox" ) .. " - " .. ((inboxCount != 1 and BRICKS_SERVER.Func.L( "gangXMessages", inboxCount )) or BRICKS_SERVER.Func.L( "gangXMessage", inboxCount )), "BRICKS_SERVER_Font25", 10, 40/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        end
        button.InboxPanel.Think = function( self2 )
            if( not IsValid( button ) ) then 
                self2:Remove()
            end
        end

        local inboxScroll = vgui.Create( "bricks_server_scrollpanel", button.InboxPanel )
        inboxScroll:Dock( FILL )
        inboxScroll:DockMargin( 0, 40, 0, 0 )


        function button.RefreshGangInbox()
            if( not IsValid( inboxScroll ) ) then return end

            inboxScroll:Clear()

            local sortedInbox = BRICKS_SERVER.Func.GangGenerateInbox()

            inboxCount = #sortedInbox

            table.SortByMember( sortedInbox, "Time", false )

            for k, v in pairs( sortedInbox ) do
                local devConfigTable = BRICKS_SERVER.DEVCONFIG.GangNotifications[v.Type]

                if( not devConfigTable ) then continue end

                local header = string.upper( devConfigTable.Name )
                if( devConfigTable.FormatHeader ) then
                    header = string.upper( devConfigTable.FormatHeader( v.ReqInfo ) )
                end

                surface.SetFont( "BRICKS_SERVER_Font23" )
                local headerX, headerY = surface.GetTextSize( header )

                local inboxEntry = vgui.Create( "DPanel", inboxScroll )
                inboxEntry:Dock( TOP )
                inboxEntry:SetTall( 120 )
                inboxEntry.Paint = function( self2, w, h )
                    draw.SimpleText( header, "BRICKS_SERVER_Font23", 10, 5, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 150 ), 0, 0 )

                    local timeSince = math.max( 0, math.floor( os.time()-v.Time ) )

                    draw.SimpleText( string.upper( BRICKS_SERVER.Func.L( "gangTimeAgo", BRICKS_SERVER.Func.FormatWordTime( timeSince ) ) ), "BRICKS_SERVER_Font17", w-10, 5+headerY, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
                end
                local buttonCount = 0
                inboxEntry.AddButton = function( icon, func, color, clickColor )
                    buttonCount = buttonCount+1

                    local inboxEntryButton = vgui.Create( "DButton", inboxEntry )
                    inboxEntryButton:SetSize( BRICKS_SERVER.Func.ScreenScale( 24 ), BRICKS_SERVER.Func.ScreenScale( 24 ) )
                    inboxEntryButton:SetPos( button.InboxPanel:GetWide()-(buttonCount*(8+inboxEntryButton:GetWide())), inboxEntry:GetTall()-inboxEntryButton:GetTall()-8 )
                    inboxEntryButton:SetText( "" )
                    local Alpha = 0
                    local inboxMat = Material( icon )
                    inboxEntryButton.Paint = function( self2, w, h )
                        if( self2:IsDown() ) then
                            Alpha = 0
                        elseif( self2:IsHovered() ) then
                            Alpha = math.Clamp( Alpha+5, 0, 75 )
                        else
                            Alpha = math.Clamp( Alpha-5, 0, 75 )
                        end
                    
                        draw.RoundedBox( 6, 0, 0, w, h, color )
                        surface.SetAlphaMultiplier( Alpha/255 )
                        draw.RoundedBox( 6, 0, 0, w, h, clickColor )
                        surface.SetAlphaMultiplier( 1 )
                    
                        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                        surface.SetMaterial( inboxMat )
                        local iconSize = BRICKS_SERVER.Func.ScreenScale( 16 )
                        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                    end
                    inboxEntryButton.DoClick = func
                end

                if( (v.ReceiverKey or "") == LocalPlayer():SteamID() or LocalPlayer():GangHasPermission( "EditInbox" ) ) then
                    inboxEntry.AddButton( "bricks_server/decline_16.png", function()
                        net.Start( "BRS.Net.DeleteGangInboxEntry" )
                            net.WriteString( v.ReceiverKey )
                            net.WriteUInt( v.Key, 16 )
                        net.SendToServer()
                    end, Color( 207, 72, 72 ), Color( 167, 32, 32 ) )

                    if( devConfigTable.AcceptFunc ) then
                        inboxEntry.AddButton( "bricks_server/accept_16.png", function()
                            devConfigTable.AcceptFunc( v.ReqInfo, v.Key )
                        end, Color( 60, 174, 101 ), Color( 20, 134, 61 ) )
                    end
                end

                local inboxDescription = vgui.Create( "DPanel", inboxEntry )
                inboxDescription:Dock( FILL )
                inboxDescription:DockMargin( 10, 30, 10, 29 )
                inboxDescription.Paint = function( self2, w, h )
                    local description = BRICKS_SERVER.Func.TextWrap( (devConfigTable.FormatDescription( v.ReqInfo ) or BRICKS_SERVER.Func.L( "noDescription" )), "BRICKS_SERVER_Font19", w )

                    BRICKS_SERVER.Func.DrawNonParsedText( description, "BRICKS_SERVER_Font19", 0, 0, BRICKS_SERVER.Func.GetTheme( 6 ), 0 )
                end
            end

            button.InboxPanel:SetTall( 40+(math.Clamp( inboxCount, 1, 3 )*120) )
        end
        button.RefreshGangInbox()
    end

    local function RefreshGangInboxNotification()
        if( IsValid( button.inboxNotification ) ) then
            button.inboxNotification:Remove()
        end

        local inboxCount = table.Count( BRICKS_SERVER.Func.GangGenerateInbox() or {} )
        if( inboxCount > 0 ) then
            local extraDistance = 4

            button.inboxNotification = vgui.Create( "DPanel", buttonParent )
            button.inboxNotification:SetSize( BRICKS_SERVER.Func.ScreenScale( 14 ), BRICKS_SERVER.Func.ScreenScale( 14 ) )
            button.inboxNotification:SetPos( buttonX+button:GetWide()-(button.inboxNotification:GetWide()/2)-extraDistance, buttonY+button:GetTall()-(button.inboxNotification:GetTall()/2)-extraDistance+extraY )
            button.inboxNotification.Paint = function( self2, w, h )
                surface.SetDrawColor( 207, 72, 72 )
                draw.NoTexture()
                BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2, 45 )		
            end
        end
    end
    RefreshGangInboxNotification()

    hook.Add( "BRS.Hooks.RefreshGangInbox", "BricksServerHooks_BRS_RefreshGangInbox_Dashboard_" .. tostring( button ), function()
        if( IsValid( button ) ) then
            if( button.RefreshGangInbox ) then button.RefreshGangInbox() end

            RefreshGangInboxNotification()
        else
            hook.Remove( "BRS.Hooks.RefreshGangInbox", "BricksServerHooks_BRS_RefreshGangInbox_Dashboard_" .. tostring( button ) )
        end
    end )
end