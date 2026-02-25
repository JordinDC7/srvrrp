local PANEL = {}

function PANEL:Init()
    self.panelTall = ScrH()*0.65-40

    self:DockMargin( 25, 25, 25, 25 )

    hook.Add( "BRS.Hooks.ConfigReceived", self, function()
        self:FillPanel()
    end )
end

function PANEL:FillPanel()
    self:Clear()

    local statistics = {}
    statistics[1] = {
        Title = BRICKS_SERVER.Func.L( "unboxingCasesOpened" ),
        Value = function()
            return LocalPlayer():GetUnboxingStat( "cases" )
        end
    }
    statistics[2] = {
        Title = BRICKS_SERVER.Func.L( "unboxingTradesCompleted" ),
        Value = function()
            return LocalPlayer():GetUnboxingStat( "trades" )
        end
    }
    statistics[3] = {
        Title = BRICKS_SERVER.Func.L( "unboxingItemsPurchased" ),
        Value = function()
            return LocalPlayer():GetUnboxingStat( "items" )
        end
    }

    local topBack = vgui.Create( "DPanel", self )
    topBack:Dock( TOP )
    topBack:SetTall( 225 )
    topBack.Paint = function( self2, w, h ) end

    local topBackW = self.panelWide-50
    local entrySpacing = 25
    local entryWide = (topBackW-((#statistics-1)*entrySpacing))/#statistics
    for k, v in ipairs( statistics ) do
        local statisticEntry = vgui.Create( "DPanel", topBack )
        statisticEntry:Dock( LEFT )
        statisticEntry:DockMargin( 0, 0, entrySpacing, 0 )
        statisticEntry:SetWide( entryWide )
        local value = 0
        statisticEntry.Paint = function( self2, w, h ) 
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    
            draw.SimpleText( string.upper( v.Title ), "BRICKS_SERVER_Font33", w/2, h/2, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            
            value = math.ceil( Lerp( FrameTime()*5, value, v.Value() ) )
            draw.SimpleText( string.Comma( value ), "BRICKS_SERVER_Font50", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        end

        local statisticGradient = vgui.Create( "bricks_server_gradientanim", statisticEntry )
        statisticGradient:SetPos( 0, topBack:GetTall()-10 )
        statisticGradient:SetSize( statisticEntry:GetWide(), 10 )
        statisticGradient:SetColors( Color(26, 188, 156), Color(46, 204, 113) )
        statisticGradient:SetCornerRadius( 8 )
        statisticGradient:SetRoundedBoxDimensions( false, -10, false, 20 )
        statisticGradient:StartAnim()
    end

    local bottomBack = vgui.Create( "DPanel", self )
    bottomBack:Dock( FILL )
    bottomBack:DockMargin( 0, 25, 0, 0 )
    bottomBack.Paint = function( self2, w, h ) end

    local activityBack = vgui.Create( "DPanel", bottomBack )
    activityBack:Dock( RIGHT )
    activityBack:DockMargin( 0, 0, 0, 0 )
    activityBack:SetWide( self.panelWide*0.38 )
    activityBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        BRICKS_SERVER.Func.DrawPartialRoundedBox( 8, 0, 0, w, 10, BRICKS_SERVER.Func.GetTheme( 3 ), w, 20 )

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingActivity" ), "BRICKS_SERVER_Font21", 25, 25, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ) )
    end

    local bottomBackTall = self.panelTall-75-topBack:GetTall()
    local activityEntryHeight, activityEntrySpacing = 45, 15
    local activityScrollMaxH = bottomBackTall-65-25

    local activityScroll = vgui.Create( "bricks_server_scrollpanel_bar", activityBack )
    activityScroll:Dock( FILL )
    activityScroll:DockMargin( 25, 65, 25, 25 )
    activityScroll:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    local scrollH = 0
    activityScroll.pnlCanvas.Paint = function( self2, w, h ) 
        if( scrollH != h ) then
            scrollH = h
            activityScroll.VBar:AnimateTo( scrollH, 0 ) 
        end
    end

    self.activitySlots = 0
    function self.AddActivityEntry( plyName, rarityName, itemName )
        self.activitySlots = self.activitySlots+1
        activityScroll:SetTall( math.min( activityScrollMaxH, activityScroll:GetTall()+activityEntryHeight+((self.activitySlots != 1 and activityEntrySpacing) or 0) ) )

        surface.SetFont( "BRICKS_SERVER_Font21" )
        local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingPlyUnboxedA", plyName, itemName ) )

        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( rarityName )

        local curActivitySlot = self.activitySlots

        local activityEntry = vgui.Create( "DPanel", activityScroll )
        activityEntry:Dock( TOP )
        activityEntry:DockMargin( 0, curActivitySlot > 1 and activityEntrySpacing or 0, 10, 0 )
        activityEntry:SetTall( activityEntryHeight )
        activityEntry.Paint = function( self2, w, h ) 
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            surface.SetFont( "BRICKS_SERVER_Font21" )
            surface.SetTextPos( 20, (h/2)-(textY/2) ) 
            surface.SetTextColor( 255, 255, 255 )
            surface.DrawText( BRICKS_SERVER.Func.L( "unboxingPlyUnboxedA1", plyName ) )
            surface.SetTextColor( BRICKS_SERVER.Func.GetRarityColor( rarityInfo ) )
            surface.DrawText( "'" .. itemName .. "'" )
        end

        activityScroll.Filler:SetTall( activityScroll.Filler:GetTall()-(activityEntry:GetTall()+((self.activitySlots != 1 and activityEntrySpacing) or 0)) )

        return activityEntry
    end

    function self.RefreshActivity()
        activityScroll:Clear()
        self.activitySlots = 0

        activityScroll.Filler = vgui.Create( "DPanel", activityScroll )
        activityScroll.Filler:Dock( TOP )
        activityScroll.Filler:SetTall( activityScrollMaxH )
        activityScroll.Filler.Paint = function( self2, w, h ) end

        for k, v in ipairs( BRS_UNBOXING_ACTIVITY or {} ) do
            local activityEntry = self.AddActivityEntry( v[1], v[2], v[3], v[4] )
        end
    end
    self.RefreshActivity()

    hook.Add( "BRS.Hooks.InsertUnboxingAlert", self, function( self, activityKey )
        local activityTable = (BRS_UNBOXING_ACTIVITY or {})[activityKey]

        if( not activityTable ) then return end

        self.AddActivityEntry( activityTable[1], activityTable[2], activityTable[3] )
    end )

    local leaderboardBack = vgui.Create( "DPanel", bottomBack )
    leaderboardBack:Dock( LEFT )
    leaderboardBack:SetWide( entryWide )
    leaderboardBack:DockMargin( 0, 0, 25, 0 )
    leaderboardBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        BRICKS_SERVER.Func.DrawPartialRoundedBox( 8, 0, 0, w, 10, BRICKS_SERVER.Func.GetTheme( 3 ), w, 20 )

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingLeaderboard" ), "BRICKS_SERVER_Font21", 25, 25, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ) )
    end

    function self.RefreshPanel()
        leaderboardBack:Clear()

        local height, spacing = 75, 10
        local slots = #(BRICKS_SERVER.TEMP.UnboxingLeaderboard or {})
        local scrollPanelTall = self.panelTall-topBack:GetTall()-75-25-65

        local displayBar = (slots*(height+spacing))-spacing > scrollPanelTall

        local leaderboardScroll = vgui.Create( displayBar and "bricks_server_scrollpanel_bar" or "bricks_server_scrollpanel", leaderboardBack )
        leaderboardScroll:Dock( FILL )
        leaderboardScroll:DockMargin( 25, 65, 25, 25 )

        if( displayBar ) then
            leaderboardScroll:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
        end

        for k, v in pairs( BRICKS_SERVER.TEMP.UnboxingLeaderboard or {} ) do
            local avatarBackSize = height-10
            local textStartPos = height+5

            local alpha = 0
            local playerButton
            local clickColor = Color( BRICKS_SERVER.Func.GetTheme( 0 ).r, BRICKS_SERVER.Func.GetTheme( 0 ).g, BRICKS_SERVER.Func.GetTheme( 0 ).b, 50 )

            local playerName = BRICKS_SERVER.Func.L( "unknown" )
            if( v.steamID64 ) then
                steamworks.RequestPlayerInfo( v.steamID64, function( steamName )
                    playerName = steamName
                end )
            end

            local playerBack = vgui.Create( "DPanel", leaderboardScroll )
            playerBack:Dock( TOP )
            playerBack:DockMargin( 0, 0, displayBar and 10 or 0, spacing )
            playerBack:SetTall( height )
            local leaderMat = Material( "bricks_server/trophy.png" )
            playerBack.Paint = function( self2, w, h )
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                draw.NoTexture()
                BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )
        
                draw.SimpleText( playerName, "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
                draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingXCases", (v.cases or 0) ), "BRICKS_SERVER_Font20", textStartPos, h/2-2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, 0 )

                if( k <= 3 ) then
                    surface.SetDrawColor( k == 1 and BRICKS_SERVER.DEVCONFIG.BaseThemes.Gold or k == 2 and BRICKS_SERVER.DEVCONFIG.BaseThemes.Silver or k == 3 and BRICKS_SERVER.DEVCONFIG.BaseThemes.Bronze )
                    surface.SetMaterial( leaderMat )
                    local iconSize = 32
                    surface.DrawTexturedRect( w-(h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end
            end

            local avatarIcon = vgui.Create( "bricks_server_circle_avatar", playerBack )
            avatarIcon:SetPos( (height-avatarBackSize)/2, (height-avatarBackSize)/2 )
            avatarIcon:SetSize( avatarBackSize, avatarBackSize )
            avatarIcon:SetSteamID( v.steamID64 or "", 64 )
        end
    end
    self.RefreshPanel()

    hook.Add( "BRS.Hooks.RefreshUnboxingLeaderboard", self, function()
        self.RefreshPanel()
    end )

    BRICKS_SERVER.UNBOXING.Func.RequestLeaderboardStats()

    if( not timer.Exists( "BRS_TIMER_UNBOXING_LEADERBOARD" ) ) then
        timer.Create( "BRS_TIMER_UNBOXING_LEADERBOARD", 60, 0, function()
            if( IsValid( self ) ) then
                BRICKS_SERVER.UNBOXING.Func.RequestLeaderboardStats()
            else
                timer.Remove( "BRS_TIMER_UNBOXING_LEADERBOARD" )
            end
        end )
    end

    local featuredBack = vgui.Create( "DPanel", bottomBack )
    featuredBack:Dock( FILL )
    featuredBack:DockMargin( 0, 0, 25, 0 )
    featuredBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        BRICKS_SERVER.Func.DrawPartialRoundedBox( 8, 0, 0, w, 10, BRICKS_SERVER.Func.GetTheme( 3 ), w, 20 )

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingFeaturedHome" ), "BRICKS_SERVER_Font21", 25, 25, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ) )
    end

    local featuredScroll = vgui.Create( "bricks_server_scrollpanel_bar", featuredBack )
    featuredScroll:Dock( FILL )
    featuredScroll:DockMargin( 25, 65, 25, 25 )
    featuredScroll:SetBarBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )

    local featuredSlotWide = self.panelWide-50-leaderboardBack:GetWide()-activityBack:GetWide()-50-50-20
    for i = 1, BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount do
        local storeItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Store.Items[BRICKS_SERVER.CONFIG.UNBOXING.Store.Featured[i] or 0]

        if( not storeItemTable ) then continue end

        local slotBack = vgui.Create( "bricks_server_unboxingmenu_itemslot", featuredScroll )
        slotBack:Dock( TOP )
        slotBack:DockMargin( 0, 0, 10, 10 )
        slotBack:SetSize( featuredSlotWide, featuredSlotWide*1.2 )
        slotBack.themeNum = 1
        slotBack:FillPanel( storeItemTable.GlobalKey, 1 )
        slotBack:AddTopInfo( BRICKS_SERVER.UNBOXING.Func.FormatCurrency( storeItemTable.Price or 0, storeItemTable.Currency ) )
    
        if( storeItemTable.Group ) then
            local groupTable = {}
            for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                if( val[1] == storeItemTable.Group ) then
                    groupTable = val
                    break
                end
            end
    
            slotBack:AddTopInfo( storeItemTable.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme( 6 ) )
        end
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_home", PANEL, "DPanel" )