local PANEL = {}

local function BRS_UNBOXING_SendTradeNotification( message )
    if( BRICKS_SERVER and BRICKS_SERVER.Func and isfunction( BRICKS_SERVER.Func.SendTopNotification ) ) then
        BRICKS_SERVER.Func.SendTopNotification( message )
        return
    end

    notification.AddLegacy( tostring( message or "" ), NOTIFY_ERROR, 3 )
    surface.PlaySound( "buttons/button10.wav" )
end

local function BRS_UNBOXING_GetTradeRollChoices( globalKey )
    local choices = {}

    for idx, rollData in ipairs( BRICKS_SERVER.UNBOXING.Func.GetStatTrakRolls( LocalPlayer(), globalKey ) or {} ) do
        local boosterID = tostring( rollData.BoosterID or "" )
        if( boosterID == "" ) then continue end

        local stats = rollData.Stats or {}
        local total = (tonumber( stats.DMG ) or 0)+(tonumber( stats.ACC ) or 0)+(tonumber( stats.CTRL ) or 0)+(tonumber( stats.HND ) or 0)+(tonumber( stats.MOV ) or 0)

        table.insert( choices, {
            BoosterID = boosterID,
            Label = string.format( "#%d | %s | %.2f", idx, tostring( rollData.TierTag or "RAW" ), tonumber( rollData.Score ) or total )
        } )
    end

    return choices
end

function PANEL:Init()
    
end

function PANEL:FillPanel()
    self.panelTall = ScrH()*0.65-40

    self.playersPanel = vgui.Create( "DPanel", self )
    self.playersPanel:SetPos( 0, 0 )
    self.playersPanel:SetSize( self.panelWide, self.panelTall )
    self.playersPanel.Paint = function( self, w, h ) end 

    self.tradePanel = vgui.Create( "DPanel", self )
    self.tradePanel:SetPos( self.panelWide, 0 )
    self.tradePanel:SetSize( self.panelWide, self.panelTall )
    self.tradePanel.Paint = function( self, w, h ) end 

    self:OpenPlayers()

    hook.Add( "BRS.Hooks.RefreshUnboxingTrades", self, function()
        if( self.activePage == "Players" ) then
            self:RefreshPlayers()
        end
    end )

    hook.Add( "BRS.Hooks.OpenUnboxingTrade", self, function( self, partnerSteamID64, partnerIsSender )
        self:OpenTrade( partnerSteamID64, partnerIsSender )
    end )

    hook.Add( "BRS.Hooks.CancelUnboxingTrade", self, function()
        self:OpenPlayers()
    end )

    hook.Add( "BRS.Hooks.CompleteUnboxingTrade", self, function( self, partnerSteamID64, partnerIsSender, senderItems, receiverItems, senderCurrencies, receiverCurrencies )
        self:OpenPlayers()
    end )
end

function PANEL:OpenPlayers()
    if( self.activePage and self.activePage != "Players" ) then
        self.tradePanel:MoveTo( self.panelWide, 0, 0.2, 0, -1, function()
            self.tradePanel:Clear()
        end )

        self.playersPanel:MoveTo( 0, 0, 0.2 )
    end

    self.activePage = "Players"

    self.playersPanel:Clear()

    self.spacing = 10
    local gridWide = self.panelWide-50-10-self.spacing
    self.slotsWide = 4
    self.slotWide = (gridWide-((self.slotsWide-1)*self.spacing))/self.slotsWide
    self.slotTall = 75

    self.topBar = vgui.Create( "DPanel", self.playersPanel )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )
    end 

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( ScrW()*0.2 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:RefreshPlayers()
    end

    local refreshButton = vgui.Create( "DButton", self.topBar )
    refreshButton:Dock( RIGHT )
    refreshButton:DockMargin( 0, 10, 25, 10 )
    refreshButton:SetWide( self.topBar:GetTall()-20 )
    refreshButton:SetText( "" )
    local alpha = 0
    local refreshMat = Material( "bricks_server/refresh.png" )
    refreshButton.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 200 )
        else
            alpha = math.Clamp( alpha-10, 0, 200 )
        end

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

        surface.SetDrawColor( 255, 255, 255, 20+(235*(alpha/100)) )
        surface.SetMaterial( refreshMat )
        local iconSize = 24
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    refreshButton.DoClick = function()
        self:RefreshPlayers()
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.playersPanel )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self, w, h ) end 

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( self.spacing )
    self.grid:SetSpaceX( self.spacing )

    self:RefreshPlayers()

    local hasActiveTrade, partnerSteamID64, partnerIsSender = LocalPlayer():HasActiveUnboxingTrade()
    if( hasActiveTrade ) then
        local partnerPly = player.GetBySteamID64( partnerSteamID64 )

        BRICKS_SERVER.Func.CreatePopoutQuery( BRICKS_SERVER.Func.L( "unboxingActiveTradeWith", ((IsValid( partnerPly ) and partnerPly:Nick()) or BRICKS_SERVER.Func.L( "unknown" )) ), self.playersPanel, self.panelWide, self.panelTall, BRICKS_SERVER.Func.L( "return" ), BRICKS_SERVER.Func.L( "cancel" ), function() 
            self:OpenTrade( partnerSteamID64, partnerIsSender )
        end, function()
            net.Start( "BRS.Net.CancelUnboxingActiveTrade" )
                net.WriteString( partnerSteamID64 )
                net.WriteBool( partnerIsSender )
            net.SendToServer()
        end, true )
    end
end

function PANEL:RefreshPlayers()
    self.grid:Clear()

    local playerCount = 0

    local sortedPlayers = {}
    for k, v in pairs( player.GetAll() ) do
        if( not IsValid( v ) or v == LocalPlayer() ) then continue end

        if( self.searchBar:GetValue() != "" and not string.find( string.lower( v:Nick() ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end

        table.insert( sortedPlayers, v )
        playerCount = playerCount+1
    end

    self.grid:SetTall( (math.ceil(#sortedPlayers/self.slotsWide)*(self.slotTall+self.spacing))-self.spacing )

    for k, v in pairs( sortedPlayers ) do

        local avatarBackSize = self.slotTall-10
        local textStartPos = self.slotTall+5

        local alpha = 0
        local clickColor = Color( BRICKS_SERVER.Func.GetTheme( 0 ).r, BRICKS_SERVER.Func.GetTheme( 0 ).g, BRICKS_SERVER.Func.GetTheme( 0 ).b, 50 )

        local playerBackX, playerBackY, playerBackW, playerBackH = 0, 0, self.slotWide, self.slotTall

        local victimSteamID64, localPlayerSteamID64 = v:SteamID64(), LocalPlayer():SteamID64()

        local playerBack = self.grid:Add( "DPanel" )
        playerBack:SetSize( self.slotWide, self.slotTall )
        playerBack.Paint = function( self2, w, h )
            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( playerBackX != toScreenX or playerBackY != toScreenY ) then
                playerBackX, playerBackY = toScreenX, toScreenY
            end

            draw.RoundedBox( self.slotTall/2, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            if( IsValid( self2.button ) ) then
                if( not self2.button:IsDown() and self2.button:IsHovered() ) then
                    alpha = math.Clamp( alpha+3, 0, 50 )
                else
                    alpha = math.Clamp( alpha-3, 0, 50 )
                end
        
                draw.RoundedBox( self.slotTall/2, 0, 0, w, h, Color( BRICKS_SERVER.Func.GetTheme( 1 ).r, BRICKS_SERVER.Func.GetTheme( 1 ).g, BRICKS_SERVER.Func.GetTheme( 1 ).b, alpha ) )
    
                BRICKS_SERVER.Func.DrawClickCircle( self2.button, w, h, clickColor )
            end

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
            draw.NoTexture()
            BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )
    
            draw.SimpleText( ((IsValid( v ) and v:Nick()) or BRICKS_SERVER.Func.L( "unknown" )), "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )

            if( not IsValid( v ) ) then return end
            
            if( BRICKS_SERVER.TEMP.UnboxingTrades[victimSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[victimSteamID64][localPlayerSteamID64] ) then
                local tradeTable = BRICKS_SERVER.TEMP.UnboxingTrades[victimSteamID64][localPlayerSteamID64]
                draw.SimpleText( ((not tradeTable.Active and BRICKS_SERVER.Func.L( "unboxingTradeSent" )) or BRICKS_SERVER.Func.L( "unboxingTradeActive" )), "BRICKS_SERVER_Font20", textStartPos, h/2-2, ((not tradeTable.Active and Color( 230, 126, 34 )) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Green), 0, 0 )
            elseif( BRICKS_SERVER.TEMP.UnboxingTrades[localPlayerSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[localPlayerSteamID64][victimSteamID64] ) then
                local tradeTable = BRICKS_SERVER.TEMP.UnboxingTrades[localPlayerSteamID64][victimSteamID64]
                draw.SimpleText( ((not tradeTable.Active and BRICKS_SERVER.Func.L( "unboxingTradeReceived" )) or BRICKS_SERVER.Func.L( "unboxingTradeActive" )), "BRICKS_SERVER_Font20", textStartPos, h/2-2, ((not tradeTable.Active and Color( 230, 126, 34 )) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Green), 0, 0 )
            else
                local teamNum = v:Team()
                draw.SimpleText( (team.GetName( teamNum ) or BRICKS_SERVER.Func.L( "none" )), "BRICKS_SERVER_Font20", textStartPos, h/2-2, (team.GetColor( teamNum ) or BRICKS_SERVER.Func.GetTheme( 6 )), 0, 0 )
            end
        end

        local distance = 2

        local avatarIcon = vgui.Create( "bricks_server_circle_avatar", playerBack )
        avatarIcon:SetPos( (self.slotTall-avatarBackSize)/2+distance, (self.slotTall-avatarBackSize)/2+distance )
        avatarIcon:SetSize( avatarBackSize-(2*distance), avatarBackSize-(2*distance) )
        avatarIcon:SetPlayer( v, 64 )

        playerBack.button = vgui.Create( "DButton", playerBack )
        playerBack.button:SetSize( self.slotWide, self.slotTall )
        playerBack.button:SetText( "" )
        playerBack.button.Paint = function( self2, w, h ) end
        playerBack.button.DoClick = function( self2 )
            if( IsValid( self2.popoutPanel ) ) then 
                self2.popoutPanel:MakePopup()
                return 
            end

            local actions = {}

            if( BRICKS_SERVER.TEMP.UnboxingTrades[victimSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[victimSteamID64][localPlayerSteamID64] ) then
                table.insert( actions, { BRICKS_SERVER.Func.L( "unboxingCancelTrade" ), function()
                    net.Start( "BRS.Net.CancelUnboxingTrade" )
                        net.WriteString( victimSteamID64 )
                    net.SendToServer()
                end } )
            elseif( BRICKS_SERVER.TEMP.UnboxingTrades[localPlayerSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[localPlayerSteamID64][victimSteamID64] ) then
                table.insert( actions, { BRICKS_SERVER.Func.L( "unboxingAcceptTrade" ), function()
                    net.Start( "BRS.Net.AcceptUnboxingTrade" )
                        net.WriteString( victimSteamID64 )
                    net.SendToServer()
                end } )
            else
                table.insert( actions, { BRICKS_SERVER.Func.L( "unboxingSendTrade" ), function()
                    net.Start( "BRS.Net.SendUnboxingTrade" )
                        net.WriteString( v:SteamID64() )
                    net.SendToServer()
                end } )
            end

            self2.popoutPanel = vgui.Create( "DPanel" )
            self2.popoutPanel:SetSize( ScrW()*0.1, ScrH()*0.2 )
            self2.popoutPanel:SetPos( playerBackX+playerBackW+5, playerBackY )
            self2.popoutPanel:MakePopup()
            self2.popoutPanel.Paint = function( self2, w, h ) 
                local x, y = self2:LocalToScreen( 0, 0 )

                BRICKS_SERVER.BSHADOWS.BeginShadow()
                draw.RoundedBox( 8, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )	
                BRICKS_SERVER.BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )
            end
            self2.popoutPanel.Think = function( self3 )
                if( not IsValid( self2 ) or not self:GetParent():GetParent():GetParent():GetParent():IsVisible() or not self3:IsMouseInputEnabled() ) then
                    self3:Remove()
                end
            end

            local avatarBackSize, avatarTopSpacing = 100, 25

            local popoutContent = vgui.Create( "DPanel", self2.popoutPanel )
            popoutContent:SetSize( self2.popoutPanel:GetWide(), self2.popoutPanel:GetTall() )
            popoutContent.Paint = function( self2, w, h ) 
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                draw.NoTexture()
                BRICKS_SERVER.Func.DrawCircle( w/2, avatarTopSpacing+(avatarBackSize/2), avatarBackSize/2, 45 )

                local textYPos = avatarTopSpacing+avatarBackSize+25
                draw.SimpleText( ((IsValid( v ) and v:Nick()) or BRICKS_SERVER.Func.L( "unknown" )), "BRICKS_SERVER_Font23", w/2, textYPos+2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

                local teamNum = IsValid( v ) and v:Team() or 0
                draw.SimpleText( (team.GetName( teamNum ) or BRICKS_SERVER.Func.L( "none" )), "BRICKS_SERVER_Font20", w/2, textYPos-2, (team.GetColor( teamNum ) or BRICKS_SERVER.Func.GetTheme( 6 )), TEXT_ALIGN_CENTER, 0 )
            end

            local distance = 2
            local avatarIcon = vgui.Create( "bricks_server_circle_avatar", popoutContent )
            avatarIcon:SetPos( (popoutContent:GetWide()/2)-(avatarBackSize/2)+distance, avatarTopSpacing+distance )
            avatarIcon:SetSize( avatarBackSize-(2*distance), avatarBackSize-(2*distance) )
            avatarIcon:SetPlayer( v, 64 )

            for k, v in ipairs( actions ) do
                local actionButton = vgui.Create( "DButton", popoutContent )
                actionButton:Dock( BOTTOM )
                actionButton:DockMargin( 10, 5, 10, 10 )
                actionButton:SetTall( 35 )
                actionButton:SetText( "" )
                local alpha = 0
                actionButton.Paint = function( self2, w, h )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            
                    if( not self2:IsDown() and self2:IsHovered() ) then
                        alpha = math.Clamp( alpha+10, 0, 200 )
                    else
                        alpha = math.Clamp( alpha-10, 0, 200 )
                    end
        
                    surface.SetAlphaMultiplier( alpha/255 )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
                    surface.SetAlphaMultiplier( 1 )
        
                    BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        
                    draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                actionButton.DoClick = function()
                    v[2]()
                end
            end
        end
    end

    if( playerCount <= 0 ) then
        surface.SetFont( "BRICKS_SERVER_Font25" )
        local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingNoPlayersFound" ) )
        textX, textY = textX+30, textY+20

        self.scrollPanel.Paint = function( self, w, h ) 
            draw.RoundedBox( 5, (w/2)-(textX/2), (h/2)-(textY/2), textX, textY, BRICKS_SERVER.Func.GetTheme( 3 ) )

            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingNoPlayersFound" ), "BRICKS_SERVER_Font23", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    else
        self.scrollPanel.Paint = function( self, w, h ) end
    end
end

function PANEL:OpenTrade( partnerSteamID64, partnerIsSender )
    if( self.activePage and self.activePage != "Trade" ) then
        self.playersPanel:MoveTo( -self.panelWide, 0, 0.2, 0, -1, function()
            self.playersPanel:Clear()
        end )

        self.tradePanel:MoveTo( 0, 0, 0.2 )
    end

    self.activePage = "Trade"

    self.partnerSteamID64 = partnerSteamID64
    self.partnerIsSender = partnerIsSender
    self.tradeTable = nil
    self.tradeSelectedRolls = {}
    self.tradeSendItems, self.tradeReceiveItems, self.tradeSendCurrencies, self.tradeReceiveCurrencies = {}, {}, {}, {}

    local localPlayerSteamID64 = LocalPlayer():SteamID64()
    local function UpdateTradeTables()
        self.tradeTable = LocalPlayer():GetUnboxingTradeTable( partnerSteamID64, partnerIsSender ) or {}

        if( not self.tradeTable ) then return end

        if( partnerIsSender ) then
            self.tradeSendItems, self.tradeReceiveItems, self.tradeSendCurrencies, self.tradeReceiveCurrencies = self.tradeTable.ReceiverItems, self.tradeTable.SenderItems, self.tradeTable.ReceiverCurrencies, self.tradeTable.SenderCurrencies
            self.tradeSelfAccepted, self.tradePartnerAccepted, self.tradeSelfConfirmed, self.tradePartnerConfirmed = self.tradeTable.ReceiverAccepted, self.tradeTable.SenderAccepted, self.tradeTable.ReceiverConfirmed, self.tradeTable.SenderConfirmed
        else
            self.tradeSendItems, self.tradeReceiveItems, self.tradeSendCurrencies, self.tradeReceiveCurrencies = self.tradeTable.SenderItems, self.tradeTable.ReceiverItems, self.tradeTable.SenderCurrencies, self.tradeTable.ReceiverCurrencies
            self.tradeSelfAccepted, self.tradePartnerAccepted, self.tradeSelfConfirmed, self.tradePartnerConfirmed = self.tradeTable.SenderAccepted, self.tradeTable.ReceiverAccepted, self.tradeTable.SenderConfirmed, self.tradeTable.ReceiverConfirmed
        end
    end
    UpdateTradeTables()

    self.tradePanel:Clear()

    if( not self.tradeTable ) then return end

    self.topBar = vgui.Create( "DPanel", self.tradePanel )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 100 )
    local tradeMat = Material( "bricks_server/unboxing_trade_active.png" )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
        surface.SetMaterial( tradeMat )
        local iconSize = 32
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end

    local backButton = vgui.Create( "DButton", self.topBar )
    backButton:SetSize( 50, 50 )
    backButton:SetPos( 25, (self.topBar:GetTall()/2)-(backButton:GetTall()/2) )
    backButton:SetText( "" )
    local alpha = 0
    local backMat = Material( "bricks_server/back.png" )
    backButton.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 200 )
        else
            alpha = math.Clamp( alpha-10, 0, 200 )
        end

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

        surface.SetDrawColor( 255, 255, 255, 20+(235*(alpha/100)) )
        surface.SetMaterial( backMat )
        local iconSize = 24
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    backButton.DoClick = function()
        self:OpenPlayers()
    end

    local function CreatePlayerInfo( panelH, steamID64, text, subText, subColor )
        local avatarBackSize = panelH
        local textStartPos = avatarBackSize+10

        local panelW = textStartPos

        surface.SetFont( "BRICKS_SERVER_Font23" )
        local textX, textY = surface.GetTextSize( text )

        surface.SetFont( "BRICKS_SERVER_Font20" )
        local subTextX, subTextY = surface.GetTextSize( subText or "" )

        panelW = panelW+((textX > subTextX and textX) or subTextX)

        local playerInfoPanel = vgui.Create( "DPanel", self.topBar )
        playerInfoPanel:SetSize( panelW, panelH )
        playerInfoPanel.Paint = function( self2, w, h )
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
            draw.NoTexture()
            BRICKS_SERVER.Func.DrawCircle( avatarBackSize/2, h/2, avatarBackSize/2, 45 )
    
            draw.SimpleText( text, "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )

            if( subText ) then
                draw.SimpleText( subText, "BRICKS_SERVER_Font20", textStartPos, ((subText and h/2-2) and h/2), (subColor or BRICKS_SERVER.Func.GetTheme( 6 )), 0, (not subText and TEXT_ALIGN_CENTER) )
            end
        end

        local distance = 2

        local avatarIcon = vgui.Create( "bricks_server_circle_avatar", playerInfoPanel )
        avatarIcon:SetPos( (panelH-avatarBackSize)/2+distance, (panelH-avatarBackSize)/2+distance )
        avatarIcon:SetSize( avatarBackSize-(2*distance), avatarBackSize-(2*distance) )
        avatarIcon:SetSteamID( steamID64, 64 )

        return playerInfoPanel, panelW
    end

    local playerInfoH, middleSpacing = 75, self.panelWide/5

    local localPlayerInfo, panelW = CreatePlayerInfo( playerInfoH, LocalPlayer():SteamID64(), LocalPlayer():Nick(), team.GetName( LocalPlayer():Team() ), team.GetColor( LocalPlayer():Team() ) )
    localPlayerInfo:SetPos( (self.panelWide/2)-middleSpacing-panelW, (self.topBar:GetTall()/2)-(playerInfoH/2) )

    local partnerPly = player.GetBySteamID64( partnerSteamID64 )

    local partnerInfo, panelW = CreatePlayerInfo( playerInfoH, partnerSteamID64, ((IsValid( partnerPly ) and partnerPly:Nick()) or "Disconnected"), (IsValid( partnerPly ) and team.GetName( partnerPly:Team() )), (IsValid( partnerPly ) and team.GetColor( partnerPly:Team() )) )
    partnerInfo:SetPos( (self.panelWide/2)+middleSpacing, (self.topBar:GetTall()/2)-(playerInfoH/2) )

    local buttons = {
        [1] = { BRICKS_SERVER.Func.L( "unboxingStepAccept" ), function() 
            if( self.tradeSelfAccepted ) then return end

            if( not LocalPlayer():GetUnboxingTradeHasContents( partnerSteamID64, partnerIsSender ) ) then
                BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "unboxingNothingInTrade" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                return
            end

            net.Start( "BRS.Net.AcceptUnboxingActiveTrade" )
                net.WriteString( partnerSteamID64 )
                net.WriteBool( partnerIsSender )
            net.SendToServer()
        end },
        [2] = { BRICKS_SERVER.Func.L( "unboxingStepConfirm" ), function() 
            if( not self.tradeSelfAccepted or not self.tradePartnerAccepted ) then return end
            
            if( not LocalPlayer():GetUnboxingTradeHasContents( partnerSteamID64, partnerIsSender ) ) then
                BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "unboxingNothingInTrade" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                return
            end

            net.Start( "BRS.Net.ConfirmUnboxingActiveTrade" )
                net.WriteString( partnerSteamID64 )
                net.WriteBool( partnerIsSender )
            net.SendToServer()
        end },
        [3] = { BRICKS_SERVER.Func.L( "unboxingStepCompleted" ) }
    }

    local buttonSizes, stageWidths = {}, {}

    local progressBarW, progressBarH = self.panelWide-50, 10
    local renderStartX, renderStartY, renderEndX, renderEndY = 0, 0, 0, 0

    local newProgressPercentW = 0
    function self.SetTradingProgressNum( progressNum, numProgress )
        self.progressNum, self.numProgress = progresskey, numProgress

        local minusW, nextButtonW, currentButtonW = 0, 0, buttonSizes[progressNum][1]
        if( buttonSizes[progressNum+1] ) then
            minusW = buttonSizes[progressNum+1][1]/2

            if( progressNum+1 == #buttons ) then
                minusW = buttonSizes[progressNum+1][1]
            end

            nextButtonW = buttonSizes[progressNum+1][1]
        end

        local previousW = 0
        for k, v in ipairs( stageWidths ) do
            if( k >= progressNum ) then break end

            previousW = previousW+v
        end

        if( numProgress > 0 ) then
            newProgressPercentW = math.Clamp( previousW+currentButtonW+((stageWidths[progressNum]-currentButtonW)*numProgress), 0, progressBarW )
        else
            newProgressPercentW = math.Clamp( previousW+(stageWidths[progressNum]*numProgress), 0, progressBarW )
        end
    end

    self.bottomBar = vgui.Create( "DPanel", self.tradePanel )
    self.bottomBar:Dock( BOTTOM )
    self.bottomBar:SetTall( 85 )
    local progressPercentW = newProgressPercentW
    self.bottomBar.Paint = function( self2, w, h ) 
        progressPercentW = Lerp( FrameTime()*20, progressPercentW, newProgressPercentW )

        local progressBarY = h-10-(40/2)-(progressBarH/2)

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
        surface.DrawRect( 25, progressBarY, progressBarW, progressBarH )

        local toScreenX, toScreenY = self2:LocalToScreen( 25, 0 )
        renderStartX, renderStartY, renderEndX, renderEndY = toScreenX, toScreenY, toScreenX+progressPercentW, toScreenY+h

        render.SetScissorRect( renderStartX, renderStartY, renderEndX, renderEndY, true )
            surface.SetDrawColor( BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
            surface.DrawRect( 25, progressBarY, progressBarW, progressBarH )
        render.SetScissorRect( 0, 0, 0, 0, false )

        local progressText
        if( self.tradeSelfAccepted ) then
            if( self.tradePartnerAccepted ) then
                if( self.tradeSelfConfirmed ) then
                    if( self.tradePartnerConfirmed ) then
                        progressText = BRICKS_SERVER.Func.L( "unboxingTradeProcessing" )
                    else
                        progressText = BRICKS_SERVER.Func.L( "unboxingWaitingPartner" )
                    end
                else
                    progressText = BRICKS_SERVER.Func.L( "unboxingPressConfirm" )
                end
            else
                progressText = BRICKS_SERVER.Func.L( "unboxingWaitingPartnerAccept" )
            end
        else
            progressText = BRICKS_SERVER.Func.L( "unboxingPressAccept" )
        end

        draw.SimpleText( progressText, "BRICKS_SERVER_Font21", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
    end

    local buttonPanels = {}
    for k, v in ipairs( buttons ) do
        surface.SetFont( "BRICKS_SERVER_Font20" )
        local textX, textY = surface.GetTextSize( v[1] )

        local buttonW, buttonH = textX+25, 40
        buttonSizes[k] = { buttonW, buttonH }

        local xPos = 25
        if( k == #buttons ) then
            xPos = (25+progressBarW)-buttonW
        elseif( k != 1 ) then
            xPos = 25+((progressBarW/(#buttons-1))*(k-1))-(buttonW/2)
        end

        buttonPanels[k] = vgui.Create( ((v[2] and "DButton") or "DPanel"), self.bottomBar )
        buttonPanels[k]:SetSize( buttonW, buttonH )
        buttonPanels[k]:SetPos( xPos, self.bottomBar:GetTall()-10-buttonPanels[k]:GetTall() )
        local alpha = 0
        buttonPanels[k].Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

            render.SetScissorRect( renderStartX, renderStartY, renderEndX, renderEndY, true )
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
            render.SetScissorRect( 0, 0, 0, 0, false )

            if( v[2] ) then
                if( not self2:IsDown() and self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 200 )
                else
                    alpha = math.Clamp( alpha-10, 0, 200 )
                end

                local clickColor = BRICKS_SERVER.Func.GetTheme( 0 )
                local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
                if( renderEndX > toScreenX+w ) then
                    clickColor = BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen
                end
        
                surface.SetAlphaMultiplier( alpha/255 )
                draw.RoundedBox( 8, 0, 0, w, h, clickColor )
                surface.SetAlphaMultiplier( 1 )
        
                BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, clickColor, 8 )
            end

            render.SetScissorRect( renderEndX, renderStartY, renderStartX+progressBarW, renderEndY, true )
                draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            render.SetScissorRect( 0, 0, 0, 0, false )

            render.SetScissorRect( renderStartX, renderStartY, renderEndX, renderEndY, true )
                draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            render.SetScissorRect( 0, 0, 0, 0, false )
        end

        if( v[2] ) then
            buttonPanels[k]:SetText( "" )
            buttonPanels[k].DoClick = v[2]
        end
    end

    for k, v in ipairs( buttonSizes ) do
        local minusW = 0
        if( buttonSizes[k+1] ) then
            minusW = buttonSizes[k+1][1]/2

            if( k+1 == #buttons ) then
                minusW = buttonSizes[k+1][1]
            end
        end

        local previousW = 0
        for k, v in ipairs( stageWidths ) do
            previousW = previousW+v
        end

        stageWidths[k] = math.Clamp( ((progressBarW*(k/(#buttons-1)))-minusW)-previousW, 0, progressBarW )
    end

    self.SetTradingProgressNum( 1, 0 )

    -- Inventory
    local gridWide = self.panelWide-50-20-10-10
    self.slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 150 ) )
    self.spacing = 10
    self.slotSize = (gridWide-((self.slotsWide-1)*self.spacing))/self.slotsWide
    self.slotTall = self.slotSize*1.2

    self.inventoryPanel = vgui.Create( "DPanel", self.tradePanel )
    self.inventoryPanel:Dock( BOTTOM )
    self.inventoryPanel:DockMargin( 25, 25, 25, 25 )
    self.inventoryPanel:SetTall( self.slotTall+40+30 )
    self.inventoryPanel.Paint = function( self, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    end

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.inventoryPanel )
    self.searchBar:Dock( TOP )
    self.searchBar:DockMargin( 10, 10, 10, 10 )
    self.searchBar:SetTall( 40 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:FillTradeInventory()
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.inventoryPanel )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 10, 0, 10, 10 )
    self.scrollPanel:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.scrollPanel.Paint = function( self, w, h ) end

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( self.spacing )
    self.grid:SetSpaceX( self.spacing )

    self:FillTradeInventory()

    -- Center Panel
    self.centerPanel = vgui.Create( "DPanel", self.tradePanel )
    self.centerPanel:Dock( FILL )
    self.centerPanel:DockMargin( 25, 25, 25, 0 )
    self.centerPanel.Paint = function( self, w, h ) end

    -- Send Items
    self.send = {}
    self.send.panelWide = (self.panelWide-50-25)/2
    self.send.gridWide = self.send.panelWide-20-10-10
    self.send.slotsWide = math.floor( self.send.gridWide/125 )
    self.send.spacing = 10
    self.send.slotSize = (self.send.gridWide-((self.send.slotsWide-1)*self.send.spacing))/self.send.slotsWide
    self.send.slotTall = self.send.slotSize*1.2

    self.send.panel = vgui.Create( "DPanel", self.centerPanel )
    self.send.panel:Dock( LEFT )
    self.send.panel:SetWide( self.send.panelWide )
    self.send.panel.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    end

    self.send.currencyPanel = vgui.Create( "DPanel", self.send.panel )
    self.send.currencyPanel:Dock( BOTTOM )
    self.send.currencyPanel:SetTall( 60 )
    self.send.currencyPanel.Paint = function( self2, w, h ) 
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 150 ), false, false, true, true )
    end

    self:FillTradeSendCurrencies()

    self.send.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.send.panel )
    self.send.scrollPanel:Dock( FILL )
    self.send.scrollPanel:DockMargin( 10, 10, 10, 10 )
    self.send.scrollPanel:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.send.scrollPanel.Paint = function( self, w, h ) end

    self.send.grid = vgui.Create( "DIconLayout", self.send.scrollPanel )
    self.send.grid:Dock( TOP )
    self.send.grid:SetSpaceY( self.send.spacing )
    self.send.grid:SetSpaceX( self.send.spacing )

    self:FillTradeSendItems()

    -- Receive Items
    self.receive = {}
    self.receive.panelWide = (self.panelWide-50-25)/2
    self.receive.gridWide = self.receive.panelWide-20-10-10
    self.receive.slotsWide = math.floor( self.receive.gridWide/125 )
    self.receive.spacing = 10
    self.receive.slotSize = (self.receive.gridWide-((self.receive.slotsWide-1)*self.receive.spacing))/self.receive.slotsWide
    self.receive.slotTall = self.receive.slotSize*1.2

    self.receive.panel = vgui.Create( "DPanel", self.centerPanel )
    self.receive.panel:Dock( RIGHT )
    self.receive.panel:SetWide( self.receive.panelWide )
    self.receive.panel.Paint = function( self, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    end

    self.receive.currencyPanel = vgui.Create( "DPanel", self.receive.panel )
    self.receive.currencyPanel:Dock( BOTTOM )
    self.receive.currencyPanel:SetTall( 60 )
    self.receive.currencyPanel.Paint = function( self2, w, h ) 
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1, 150 ), false, false, true, true )
    end

    self:FillTradeReceiveCurrencies()

    self.receive.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.receive.panel )
    self.receive.scrollPanel:Dock( FILL )
    self.receive.scrollPanel:DockMargin( 10, 10, 10, 10 )
    self.receive.scrollPanel:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.receive.scrollPanel.Paint = function( self, w, h ) end

    self.receive.grid = vgui.Create( "DIconLayout", self.receive.scrollPanel )
    self.receive.grid:Dock( TOP )
    self.receive.grid:SetSpaceY( self.receive.spacing )
    self.receive.grid:SetSpaceX( self.receive.spacing )

    self:FillTradeReceiveItems()

    -- Update
    hook.Add( "BRS.Hooks.UpdateUnboxingTradeItems", self, function( self, partnerMadeChange )
        if( self.activePage == "Trade" ) then
            if( partnerMadeChange ) then
                self:FillTradeReceiveItems()
            else
                self:FillTradeSendItems()
                self:FillTradeInventory()
            end

            UpdateTradeTables()
        else
            hook.Remove( "BRS.Hooks.UpdateUnboxingTradeItems", self )
        end
    end )

    hook.Add( "BRS.Hooks.UpdateUnboxingTradeCurrencies", self, function( self, partnerMadeChange )
        if( self.activePage == "Trade" ) then
            if( partnerMadeChange ) then
                self:FillTradeReceiveCurrencies()
            else
                self:FillTradeSendCurrencies()
            end

            UpdateTradeTables()
        else
            hook.Remove( "BRS.Hooks.UpdateUnboxingTradeCurrencies", self )
        end
    end )

    hook.Add( "BRS.Hooks.UpdateUnboxingTradeStatus", self, function()
        if( self.activePage == "Trade" ) then
            UpdateTradeTables()

            if( not self.tradeSelfAccepted ) then
                buttonPanels[1]:SetDisabled( false )
                buttonPanels[2]:SetDisabled( true )
            else
                buttonPanels[1]:SetDisabled( true )

                if( self.tradePartnerAccepted ) then
                    if( not self.tradeSelfConfirmed ) then
                        buttonPanels[2]:SetDisabled( false )
                    else
                        buttonPanels[2]:SetDisabled( true )
                    end
                else
                    buttonPanels[2]:SetDisabled( true )
                end
            end

            if( self.tradeSelfConfirmed and self.tradePartnerConfirmed ) then
                self.SetTradingProgressNum( 3, 1 )
            elseif( self.tradeSelfConfirmed or self.tradePartnerConfirmed ) then
                self.SetTradingProgressNum( 2, 0.5 )
            elseif( self.tradeSelfAccepted and self.tradePartnerAccepted ) then
                self.SetTradingProgressNum( 1, 1 )
            elseif( self.tradeSelfAccepted or self.tradePartnerAccepted ) then
                self.SetTradingProgressNum( 1, 0.5 )
            else
                self.SetTradingProgressNum( 1, 0 )
            end
        else
            hook.Remove( "BRS.Hooks.UpdateUnboxingTradeStatus", self )
        end
    end )

    hook.Run( "BRS.Hooks.UpdateUnboxingTradeStatus" )

    -- Trade Chat
    self:CreateTradeChat()

    hook.Add( "BRS.Hooks.UnboxingSwitchpage", self, function( self, newPageLabel )
        if( newPageLabel == BRICKS_SERVER.Func.L( "unboxingTrading" ) and self.activePage == "Trade" ) then
            self:CreateTradeChat()
        end
    end )
end

function PANEL:OpenTradeRollSelector( globalKey, maxSelect, onConfirm )
    local choices = BRS_UNBOXING_GetTradeRollChoices( globalKey )
    if( #choices <= 0 ) then
        onConfirm( {} )
        return
    end

    local frame = vgui.Create( "DFrame" )
    frame:SetSize( math.min( 550, ScrW()*0.35 ), math.min( 500, ScrH()*0.65 ) )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( BRICKS_SERVER.Func.L( "unboxingTrade" ) )

    local info = vgui.Create( "DLabel", frame )
    info:Dock( TOP )
    info:DockMargin( 10, 10, 10, 5 )
    info:SetWrap( true )
    info:SetAutoStretchVertical( true )
    info:SetText( string.format( "Select up to %d roll(s) to trade:", math.max( 1, tonumber( maxSelect ) or 1 ) ) )

    local scroll = vgui.Create( "bricks_server_scrollpanel_bar", frame )
    scroll:Dock( FILL )
    scroll:DockMargin( 10, 5, 10, 10 )

    local selected = {}

    for i, choice in ipairs( choices ) do
        local row = vgui.Create( "DCheckBoxLabel", scroll )
        row:Dock( TOP )
        row:DockMargin( 0, 0, 0, 6 )
        row:SetText( choice.Label )
        row:SetValue( i <= maxSelect and 1 or 0 )
        row:SizeToContents()

        if( i <= maxSelect ) then
            selected[choice.BoosterID] = true
        end

        row.OnChange = function( _, val )
            if( val ) then
                selected[choice.BoosterID] = true
            else
                selected[choice.BoosterID] = nil
            end
        end
    end

    local confirm = vgui.Create( "DButton", frame )
    confirm:Dock( BOTTOM )
    confirm:DockMargin( 10, 0, 10, 10 )
    confirm:SetTall( 32 )
    confirm:SetText( BRICKS_SERVER.Func.L( "ok" ) )
    confirm.DoClick = function()
        local selectedIDs = {}
        for _, choice in ipairs( choices ) do
            if( selected[choice.BoosterID] ) then
                table.insert( selectedIDs, choice.BoosterID )
            end
        end

        if( #selectedIDs > maxSelect ) then
            BRS_UNBOXING_SendTradeNotification( BRICKS_SERVER.Func.L( "unboxingInvalidAmount" ) )
            return
        end

        frame:Close()
        onConfirm( selectedIDs )
    end
end

function PANEL:FillTradeInventory()
    self.grid:Clear()

    local sortedItems = {}
    for k, v in pairs( LocalPlayer():GetUnboxingInventory() ) do
        local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )

        if( not configItemTable ) then continue end

        if( self.searchBar:GetValue() != "" and not string.find( string.lower( configItemTable.Name ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end
        
        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( configItemTable.Rarity or "" )
        
        table.insert( sortedItems, { rarityKey, k, v } )
    end

    table.SortByMember( sortedItems, 1, false )

    self.grid:SetTall( (math.ceil(#sortedItems/self.slotsWide)*(self.slotSize+self.spacing))-self.spacing )

    for k, v in pairs( sortedItems ) do
        local globalKey  = v[2]
        local itemAmount  = v[3]-((self.tradeSendItems or {})[globalKey] or 0)

        if( itemAmount <= 0 ) then continue end

        local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )

        if( not configItemTable ) then continue end

        local slotBack = self.grid:Add( "bricks_server_unboxingmenu_itemslot" )
        slotBack:SetSize( self.slotSize, self.slotTall )
        slotBack:FillPanel( globalKey, (itemAmount or 1), function()
            BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "unboxingTrade" ), BRICKS_SERVER.Func.L( "unboxingTradeAdd" ), 1, function( text ) 
                local amount = math.Clamp( ((self.tradeSendItems or {})[globalKey] or 0)+tonumber( text ), 0, v[3] )
                if( amount <= 0 ) then return end

                local function sendTradeAdd( selectedRollIDs )
                    net.Start( "BRS.Net.UnboxingActiveTradeAddItem" )
                        net.WriteString( self.partnerSteamID64 )
                        net.WriteBool( self.partnerIsSender )
                        net.WriteString( globalKey )
                        net.WriteUInt( amount, 16 )
                        net.WriteTable( selectedRollIDs or {} )
                    net.SendToServer()
                end

                local availableRolls = BRS_UNBOXING_GetTradeRollChoices( globalKey )
                if( #availableRolls > 1 ) then
                    self:OpenTradeRollSelector( globalKey, amount, sendTradeAdd )
                else
                    local onlyRoll = (#availableRolls == 1 and { availableRolls[1].BoosterID }) or {}
                    sendTradeAdd( onlyRoll )
                end
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
        end )
        slotBack.themeNum = 1
    end
end

function PANEL:FillTradeSendItems()
    self.send.grid:Clear()

    local sortedItems = {}
    for k, v in pairs( self.tradeSendItems or {} ) do
        local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )
        
        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( configItemTable.Rarity or "" )
        
        table.insert( sortedItems, { rarityKey, k, v } )
    end

    table.SortByMember( sortedItems, 1, false )

    self.send.grid:SetTall( (math.ceil(#sortedItems/self.send.slotsWide)*(self.send.slotSize+self.send.spacing))-self.send.spacing )

    for k, v in pairs( sortedItems ) do
        local globalKey, itemAmount  = v[2], v[3]
        local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )

        if( not configItemTable ) then continue end

        local slotBack = self.send.grid:Add( "bricks_server_unboxingmenu_itemslot" )
        slotBack:SetSize( self.send.slotSize, self.send.slotTall )
        slotBack:FillPanel( globalKey, (itemAmount or 1), function()
            BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "unboxingTrade" ), BRICKS_SERVER.Func.L( "unboxingTradeRemove" ), 1, function( text ) 
                local amount = math.Clamp( ((self.tradeSendItems or {})[globalKey] or 0)-tonumber( text ), 0, (LocalPlayer():GetUnboxingInventory()[globalKey] or 0) )

                net.Start( "BRS.Net.UnboxingActiveTradeAddItem" )
                    net.WriteString( self.partnerSteamID64 )
                    net.WriteBool( self.partnerIsSender )
                    net.WriteString( globalKey )
                    net.WriteUInt( amount, 16 )
                    net.WriteTable( {} )
                net.SendToServer()
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
        end )
        slotBack.themeNum = 1
    end
end

function PANEL:FillTradeReceiveItems()
    self.receive.grid:Clear()

    local sortedItems = {}
    for k, v in pairs( self.tradeReceiveItems or {} ) do
        local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( k )
        
        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( configItemTable.Rarity or "" )
        
        table.insert( sortedItems, { rarityKey, k, v } )
    end

    table.SortByMember( sortedItems, 1, false )

    self.receive.grid:SetTall( (math.ceil(#sortedItems/self.receive.slotsWide)*(self.receive.slotSize+self.receive.spacing))-self.receive.spacing )

    for k, v in pairs( sortedItems ) do
        local globalKey, itemAmount  = v[2], v[3]
        local configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )

        if( not configItemTable ) then continue end

        local slotBack = self.receive.grid:Add( "bricks_server_unboxingmenu_itemslot" )
        slotBack:SetSize( self.receive.slotSize, self.receive.slotTall )
        slotBack:FillPanel( globalKey, (itemAmount or 1), {} )
        slotBack.themeNum = 1
    end
end

function PANEL:FillTradeSendCurrencies()
    self.send.currencyPanel:Clear()

    local function addButton( text, icon, doClick )
        surface.SetFont( "BRICKS_SERVER_Font21" )
        local textX, textY = surface.GetTextSize( text )

        local button = vgui.Create( "DButton", self.send.currencyPanel )
        button:Dock( LEFT )
        button:DockMargin( 10, 10, 0, 10 )
        button:SetText( "" )
        button:SetWide( textX+15+40 )
        local alpha = 0
        button.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            if( not self2:IsDown() and self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 200 )
            else
                alpha = math.Clamp( alpha-10, 0, 200 )
            end

            surface.SetAlphaMultiplier( alpha/255 )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

            if( icon ) then
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 75 ) )
                surface.SetMaterial( icon )
                local iconSize = 16
                surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

                draw.SimpleText( text, "BRICKS_SERVER_Font21", h, h/2-2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, TEXT_ALIGN_CENTER )
            else
                draw.SimpleText( text, "BRICKS_SERVER_Font21", w/2, h/2-2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end
        button.DoClick = doClick
    end

    addButton( "Currency", Material( "bricks_server/add_currency.png" ), function()
        local options = {}
        for k, v in pairs( BRICKS_SERVER.DEVCONFIG.Currencies ) do
            options[k] = v.Title
        end

        BRICKS_SERVER.Func.ComboRequest( BRICKS_SERVER.Func.L( "unboxingTrade" ), BRICKS_SERVER.Func.L( "unboxingTradeSelectCurrency" ), "", options, function( value, data ) 
            if( BRICKS_SERVER.DEVCONFIG.Currencies[data] ) then
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "unboxingTrade" ), BRICKS_SERVER.Func.L( "unboxingTradeAddCurrency" ), 0, function( text )
                    local newAmount = ((self.tradeSendCurrencies or {})[data] or 0)+tonumber( text )

                    if( newAmount > (BRICKS_SERVER.DEVCONFIG.Currencies[data].getFunction( LocalPlayer() ) or 0) ) then
                        BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "unboxingTradeNotEnoughCurrency" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                        return
                    end

                    newAmount = math.Clamp( newAmount, 0, (BRICKS_SERVER.DEVCONFIG.Currencies[data].getFunction( LocalPlayer() ) or 0) )
    
                    if( newAmount <= 0 ) then return end

                    net.Start( "BRS.Net.UnboxingActiveTradeAddCurrency" )
                        net.WriteString( self.partnerSteamID64 )
                        net.WriteBool( self.partnerIsSender )
                        net.WriteString( data )
                        net.WriteUInt( newAmount, 32 )
                    net.SendToServer()
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            else
                notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidType" ), 1, 3 )
            end
        end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
    end )

    for k, v in pairs( self.tradeSendCurrencies or {} ) do
        local devConfigTable = BRICKS_SERVER.DEVCONFIG.Currencies[k]

        if( not devConfigTable ) then continue end

        addButton( BRICKS_SERVER.DEVCONFIG.Currencies[k].formatFunction( v or 0 ), false, function()
            BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "unboxingTrade" ), BRICKS_SERVER.Func.L( "unboxingTradeRemoveCurrency" ), 0, function( text ) 
                local amount = math.Clamp( v-tonumber( text ), 0, (BRICKS_SERVER.DEVCONFIG.Currencies[k].getFunction( LocalPlayer() ) or 0) )

                net.Start( "BRS.Net.UnboxingActiveTradeAddCurrency" )
                    net.WriteString( self.partnerSteamID64 )
                    net.WriteBool( self.partnerIsSender )
                    net.WriteString( k )
                    net.WriteUInt( amount, 32 )
                net.SendToServer()
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
        end )
    end
end

function PANEL:FillTradeReceiveCurrencies()
    self.receive.currencyPanel:Clear()

    local function addPanel( text )
        surface.SetFont( "BRICKS_SERVER_Font21" )
        local textX, textY = surface.GetTextSize( text )

        local button = vgui.Create( "DPanel", self.receive.currencyPanel )
        button:Dock( LEFT )
        button:DockMargin( 10, 10, 0, 10 )
        button:SetWide( textX+15+40 )
        local alpha = 0
        button.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            draw.SimpleText( text, "BRICKS_SERVER_Font21", w/2, h/2-2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    for k, v in pairs( self.tradeReceiveCurrencies or {} ) do
        local devConfigTable = BRICKS_SERVER.DEVCONFIG.Currencies[k]

        if( not devConfigTable ) then continue end

        addPanel( BRICKS_SERVER.DEVCONFIG.Currencies[k].formatFunction( v or 0 ) )
    end
end

function PANEL:CreateTradeChat()
    if( IsValid( BRICKS_SERVER_UNBOXING_TRADECHAT ) ) then
        BRICKS_SERVER_UNBOXING_TRADECHAT:SetVisible( true )
        return
    end

    local spacing = ScrW()*0.02

    BRICKS_SERVER_UNBOXING_TRADECHAT = vgui.Create( "bricks_server_dframe" )
    BRICKS_SERVER_UNBOXING_TRADECHAT:SetHeader( BRICKS_SERVER.Func.L( "unboxingTradeChat" ) )
    BRICKS_SERVER_UNBOXING_TRADECHAT:SetSize( ((ScrW()-(ScrW()*0.6))/2)-(2*spacing), ScrH()*0.4 )
    local finalXPos, finalYPos = math.floor( ScrW()-BRICKS_SERVER_UNBOXING_TRADECHAT:GetWide()-spacing ), (ScrH()/2)-(BRICKS_SERVER_UNBOXING_TRADECHAT:GetTall()/2)
    local hideXPos = (ScrW()/2)+(ScrW()*0.6/2)-BRICKS_SERVER_UNBOXING_TRADECHAT:GetWide()
    BRICKS_SERVER_UNBOXING_TRADECHAT:SetPos( hideXPos, finalYPos )
    BRICKS_SERVER_UNBOXING_TRADECHAT:MoveTo( finalXPos, finalYPos, 0.2 )
    BRICKS_SERVER_UNBOXING_TRADECHAT.closeButton:Remove()
    BRICKS_SERVER_UNBOXING_TRADECHAT:MoveToBack()
    BRICKS_SERVER_UNBOXING_TRADECHAT.Think = function()
        if( not BRICKS_SERVER_UNBOXING_TRADECHAT:IsVisible() ) then return end

        if( not IsValid( BRICKS_SERVER_UNBOXINGMENU ) or not BRICKS_SERVER_UNBOXINGMENU:IsVisible() ) then
            BRICKS_SERVER_UNBOXING_TRADECHAT:Remove()
        else
            local tradeChatPanelX, tradeChatPanelY = BRICKS_SERVER_UNBOXING_TRADECHAT:GetPos()

            if( tradeChatPanelX == finalXPos ) then
                if( BRICKS_SERVER_UNBOXINGMENU.sheet.ActiveButton.label != BRICKS_SERVER.Func.L( "unboxingTrading" ) or self.activePage != "Trade" ) then
                    BRICKS_SERVER_UNBOXING_TRADECHAT:MoveTo( hideXPos, finalYPos, 0.2 )
                end
            elseif( tradeChatPanelX == hideXPos ) then
                if( BRICKS_SERVER_UNBOXINGMENU.sheet.ActiveButton.label == BRICKS_SERVER.Func.L( "unboxingTrading" ) and self.activePage == "Trade" ) then
                    BRICKS_SERVER_UNBOXING_TRADECHAT:MoveTo( finalXPos, finalYPos, 0.2 )
                end
            end
        end
    end

    local chatMessageBack = vgui.Create( "DPanel", BRICKS_SERVER_UNBOXING_TRADECHAT )
    chatMessageBack:Dock( BOTTOM )
    chatMessageBack:DockMargin( 25, 0, 25, 25 )
    chatMessageBack:SetTall( 40 )
    chatMessageBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    end

    local chatMessageEntry
    local function sendChatMessage()
        local message = chatMessageEntry:GetValue()
        if( message and message != "" ) then
            net.Start( "BRS.Net.UnboxingActiveTradeSendChat" )
                net.WriteString( self.partnerSteamID64 )
                net.WriteBool( self.partnerIsSender )
                net.WriteString( message )
            net.SendToServer()
        end

        chatMessageEntry:SetText( "" )

        chatMessageEntry:RequestFocus()
    end

    local chatMessageButton = vgui.Create( "DButton", chatMessageBack )
    chatMessageButton:Dock( RIGHT )
    chatMessageButton:SetWide( chatMessageBack:GetTall() )
    chatMessageButton:SetText( "" )
    local Alpha = 0
    local sendMat = Material( "bricks_server/send_message.png" )
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
        local iconSize = 24
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    chatMessageButton.DoClick = sendChatMessage

    chatMessageEntry = vgui.Create( "bricks_server_search", chatMessageBack )
    chatMessageEntry:Dock( FILL )
    chatMessageEntry:DockMargin( 10, 0, 0, 0 )
    chatMessageEntry:SetFont( "BRICKS_SERVER_Font21" )
    chatMessageEntry.backFont = "BRICKS_SERVER_Font21"
    chatMessageEntry.backText = string.upper( BRICKS_SERVER.Func.L( "unboxingTradeMessage" ) )
    chatMessageEntry.backTextColor = Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 )
    chatMessageEntry.OnEnter = sendChatMessage

    local chatScroll = vgui.Create( "bricks_server_scrollpanel_bar", BRICKS_SERVER_UNBOXING_TRADECHAT )
    chatScroll:Dock( FILL )
    chatScroll:DockMargin( 25, 25, 25, 25 )
    chatScroll.Paint = function( self2, w, h ) end
    local scrollH = 0
    chatScroll.pnlCanvas.Paint = function( self2, w, h ) 
        if( scrollH != h ) then
            scrollH = h
            chatScroll.VBar:AnimateTo( scrollH, 0 ) 
        end
    end

    local chatScrollMaxH = BRICKS_SERVER_UNBOXING_TRADECHAT:GetTall()-40-50-chatMessageBack:GetTall()-25

    self.chatSlots = 0
    function self.AddChatMessage( time, message, steamID64 )
        self.chatSlots = self.chatSlots+1

        local ply = player.GetBySteamID64( steamID64 )
        local name, nameColor = ((IsValid( ply ) and ply:Nick()) or BRICKS_SERVER.Func.L( "unknown" )), ((IsValid( ply ) and team.GetColor( ply:Team() )) or BRICKS_SERVER.Func.GetTheme( 5 ))

        surface.SetFont( "BRICKS_SERVER_Font20" )
        local messageX, messageY = surface.GetTextSize( message or "" )

        surface.SetFont( "BRICKS_SERVER_Font20" )
        local nameX, nameY = surface.GetTextSize( name )

        surface.SetFont( "BRICKS_SERVER_Font15" )
        local timeX, timeY = surface.GetTextSize( BRICKS_SERVER.Func.FormatTimeInPlace( time ) )

        local leftSpacing = math.max( nameX, timeX )

        local messageWrap, lineCount = BRICKS_SERVER.Func.TextWrap( message, "BRICKS_SERVER_Font20", (BRICKS_SERVER_UNBOXING_TRADECHAT:GetWide()-50)-20-(leftSpacing+10) )

        local messageEntry = vgui.Create( "DPanel", chatScroll )
        messageEntry:Dock( TOP )
        messageEntry:DockMargin( 0, ((self.chatSlots != 1 and 10) or 0), 10, 0 )
        messageEntry:SetTall( math.max( nameY+timeY, lineCount*messageY ) )
        messageEntry.Paint = function( self2, w, h ) 
            draw.SimpleText( name, "BRICKS_SERVER_Font20", 0, 0, nameColor )
            draw.SimpleText( BRICKS_SERVER.Func.FormatTimeInPlace( time ), "BRICKS_SERVER_Font15", 0, nameY, BRICKS_SERVER.Func.GetTheme( 6, 75 ) )

            BRICKS_SERVER.Func.DrawNonParsedText( messageWrap, "BRICKS_SERVER_Font20", leftSpacing+10, 0, BRICKS_SERVER.Func.GetTheme( 6 ) )
        end

        chatScroll.Filler:SetTall( chatScroll.Filler:GetTall()-(messageEntry:GetTall()+((self.chatSlots != 1 and 10) or 0)) )

        return messageEntry
    end

    function self.AddSystemMessage( time, message, steamID64 )
        self.chatSlots = self.chatSlots+1

        local ply = player.GetBySteamID64( steamID64 )
        local name = (IsValid( ply ) and ply:Nick()) or BRICKS_SERVER.Func.L( "unknown" )

        surface.SetFont( "BRICKS_SERVER_Font20" )
        local systemX, systemY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingTradeSystem" ) )

        surface.SetFont( "BRICKS_SERVER_Font15" )
        local timeX, timeY = surface.GetTextSize( BRICKS_SERVER.Func.FormatTimeInPlace( time ) )

        local leftSpacing = math.max( systemX, timeX )

        surface.SetFont( "BRICKS_SERVER_Font20" )
        local messageX, messageY = surface.GetTextSize( message )

        local messageWrap, lineCount = BRICKS_SERVER.Func.TextWrap( name .. " " .. message, "BRICKS_SERVER_Font20", (BRICKS_SERVER_UNBOXING_TRADECHAT:GetWide()-50)-20-(leftSpacing+10) )

        local messageEntry = vgui.Create( "DPanel", chatScroll )
        messageEntry:Dock( TOP )
        messageEntry:DockMargin( 0, ((self.chatSlots != 1 and 10) or 0), 10, 0 )
        messageEntry:SetTall( math.max( systemY+timeY, lineCount*messageY ) )
        messageEntry.Paint = function( self2, w, h ) 
            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingTradeSystem" ), "BRICKS_SERVER_Font20", 0, 0, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )
            draw.SimpleText( BRICKS_SERVER.Func.FormatTimeInPlace( time ), "BRICKS_SERVER_Font15", 0, systemY, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, 0 )

            BRICKS_SERVER.Func.DrawNonParsedText( messageWrap, "BRICKS_SERVER_Font20", leftSpacing+10, 0, BRICKS_SERVER.Func.GetTheme( 6 ), 0 )
        end

        chatScroll.Filler:SetTall( chatScroll.Filler:GetTall()-(messageEntry:GetTall()+((self.chatSlots != 1 and 10) or 0)) )

        return messageEntry
    end

    function self.RefreshChat()
        chatScroll:Clear()
        self.chatSlots = 0

        chatScroll.Filler = vgui.Create( "DPanel", chatScroll )
        chatScroll.Filler:Dock( TOP )
        chatScroll.Filler:SetTall( chatScrollMaxH )
        chatScroll.Filler.Paint = function( self2, w, h ) end

        local chatTable = (LocalPlayer():GetUnboxingTradeTable( self.partnerSteamID64, self.partnerIsSender ) or {}).ChatTable

        if( not chatTable ) then return end

        local sortedMessages = table.Copy( chatTable )
        table.SortByMember( sortedMessages, 1, true )

        for k, v in ipairs( sortedMessages ) do
            if( not v[4] ) then
                self.AddChatMessage( v[1], v[2], v[3] )
            else
                self.AddSystemMessage( v[1], v[2], v[3] )
            end
        end
    end
    self.RefreshChat()

    hook.Add( "BRS.Hooks.AddUnboxingChatMessage", self, function( self, messageKey )
        if( IsValid( BRICKS_SERVER_UNBOXING_TRADECHAT ) ) then
            local chatTable = (LocalPlayer():GetUnboxingTradeTable( self.partnerSteamID64, self.partnerIsSender ) or {}).ChatTable
            
            if( not chatTable ) then return end

            local messageTable = chatTable[messageKey]

            if( not messageTable ) then return end

            if( not messageTable[4] ) then
                self.AddChatMessage( messageTable[1], messageTable[2], messageTable[3] )
            else
                self.AddSystemMessage( messageTable[1], messageTable[2], messageTable[3] )
            end
        else
            hook.Remove( "BRS.Hooks.AddUnboxingChatMessage", self )
        end
    end )
end

function PANEL:Think()
    if( not IsValid( BRICKS_SERVER_UNBOXING_TRADECHAT ) or not BRICKS_SERVER_UNBOXING_TRADECHAT:IsVisible() ) then
        if( IsValid( BRICKS_SERVER_UNBOXINGMENU ) and BRICKS_SERVER_UNBOXINGMENU:IsVisible() and BRICKS_SERVER_UNBOXINGMENU.sheet.ActiveButton.label == BRICKS_SERVER.Func.L( "unboxingTrading" ) and self.activePage == "Trade" ) then
            self:CreateTradeChat()
        end
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_trading", PANEL, "DPanel" )
