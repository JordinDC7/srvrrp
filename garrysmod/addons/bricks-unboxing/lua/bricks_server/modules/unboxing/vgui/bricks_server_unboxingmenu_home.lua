-- ============================================================
-- SmG RP - Custom Home Page
-- Dark tactical theme with stat cards + activity feed
-- ============================================================
local PANEL = {}

function PANEL:Init()
    self.panelTall = ScrH()*0.65-40

    self:DockMargin( 20, 16, 20, 16 )

    hook.Add( "BRS.Hooks.ConfigReceived", self, function()
        self:FillPanel()
    end )
end

function PANEL:FillPanel()
    self:Clear()
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}

    local statistics = {
        { Title = BRICKS_SERVER.Func.L( "unboxingCasesOpened" ), Value = function() return LocalPlayer():GetUnboxingStat( "cases" ) end, Icon = "📦" },
        { Title = BRICKS_SERVER.Func.L( "unboxingTradesCompleted" ), Value = function() return LocalPlayer():GetUnboxingStat( "trades" ) end, Icon = "🤝" },
        { Title = BRICKS_SERVER.Func.L( "unboxingItemsPurchased" ), Value = function() return LocalPlayer():GetUnboxingStat( "items" ) end, Icon = "🛒" },
    }

    -- ====== TOP: STAT CARDS ======
    local topBack = vgui.Create( "DPanel", self )
    topBack:Dock( TOP )
    topBack:SetTall( 130 )
    topBack.Paint = function() end

    local topBackW = self.panelWide-40
    local entrySpacing = 10
    local entryWide = (topBackW-((#statistics-1)*entrySpacing))/#statistics

    for k, v in ipairs( statistics ) do
        local statisticEntry = vgui.Create( "DPanel", topBack )
        statisticEntry:Dock( LEFT )
        statisticEntry:DockMargin( 0, 0, entrySpacing, 0 )
        statisticEntry:SetWide( entryWide )
        local value = 0
        statisticEntry.Paint = function( self2, w, h ) 
            draw.RoundedBox( 6, 0, 0, w, h, C.bg_mid or Color(26,27,35) )
            surface.SetDrawColor(C.border or Color(50,52,65))
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            -- Accent bar at top
            draw.RoundedBoxEx( 6, 0, 0, w, 3, C.accent_dim or Color(0,160,128), true, true, false, false )
    
            -- Title
            draw.SimpleText( string.upper( v.Title ), "SMGRP_Bold12", w/2, 28, C.text_muted or Color(90,94,110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            
            -- Animated value
            value = math.ceil( Lerp( FrameTime()*5, value, v.Value() ) )
            draw.SimpleText( string.Comma( value ), "SMGRP_Stat32", w/2, 72, C.text_primary or Color(220,222,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    -- ====== BOTTOM: COLUMNS ======
    local bottomBack = vgui.Create( "DPanel", self )
    bottomBack:Dock( FILL )
    bottomBack:DockMargin( 0, 10, 0, 0 )
    bottomBack.Paint = function() end

    -- ====== ACTIVITY FEED (right) ======
    local activityBack = vgui.Create( "DPanel", bottomBack )
    activityBack:Dock( RIGHT )
    activityBack:SetWide( self.panelWide*0.38 )
    activityBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 6, 0, 0, w, h, C.bg_mid or Color(26,27,35) )
        surface.SetDrawColor(C.border or Color(50,52,65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        -- Header area
        draw.RoundedBoxEx( 6, 0, 0, w, 40, C.bg_light or Color(34,36,46), true, true, false, false )
        draw.SimpleText( "LIVE ACTIVITY", "SMGRP_Bold13", 16, 20, C.text_secondary or Color(140,144,160), 0, TEXT_ALIGN_CENTER )
    end

    local bottomBackTall = self.panelTall-40-topBack:GetTall()-10
    local activityEntryHeight, activityEntrySpacing = 40, 8
    local activityScrollMaxH = bottomBackTall-50-20

    local activityScroll = vgui.Create( "bricks_server_scrollpanel_bar", activityBack )
    activityScroll:Dock( FILL )
    activityScroll:DockMargin( 12, 50, 12, 12 )
    activityScroll:SetBarBackColor( C.bg_darkest or Color(12,12,18) )
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

        surface.SetFont( "SMGRP_Body13" )
        local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingPlyUnboxedA", plyName, itemName ) )

        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( rarityName )
        local curActivitySlot = self.activitySlots
        local rarityColor = (SMGRP and SMGRP.UI) and SMGRP.UI.GetRarityColor(rarityName) or BRICKS_SERVER.Func.GetRarityColor(rarityInfo)

        local activityEntry = vgui.Create( "DPanel", activityScroll )
        activityEntry:Dock( TOP )
        activityEntry:DockMargin( 0, curActivitySlot > 1 and activityEntrySpacing or 0, 6, 0 )
        activityEntry:SetTall( activityEntryHeight )
        activityEntry.Paint = function( self2, w, h ) 
            draw.RoundedBox( 4, 0, 0, w, h, C.bg_light or Color(34,36,46) )

            surface.SetFont( "SMGRP_Body13" )
            surface.SetTextPos( 12, (h/2)-(textY/2) ) 
            surface.SetTextColor( (C.text_secondary or Color(140,144,160)).r, (C.text_secondary or Color(140,144,160)).g, (C.text_secondary or Color(140,144,160)).b )
            surface.DrawText( BRICKS_SERVER.Func.L( "unboxingPlyUnboxedA1", plyName ) )
            surface.SetTextColor( rarityColor.r, rarityColor.g, rarityColor.b )
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
        activityScroll.Filler.Paint = function() end
        for k, v in ipairs( BRS_UNBOXING_ACTIVITY or {} ) do
            self.AddActivityEntry( v[1], v[2], v[3], v[4] )
        end
    end
    self.RefreshActivity()

    hook.Add( "BRS.Hooks.InsertUnboxingAlert", self, function( self2, activityKey )
        local activityTable = (BRS_UNBOXING_ACTIVITY or {})[activityKey]
        if( not activityTable ) then return end
        self.AddActivityEntry( activityTable[1], activityTable[2], activityTable[3] )
    end )

    -- ====== LEADERBOARD (left) ======
    local leaderboardBack = vgui.Create( "DPanel", bottomBack )
    leaderboardBack:Dock( LEFT )
    leaderboardBack:SetWide( entryWide )
    leaderboardBack:DockMargin( 0, 0, 10, 0 )
    leaderboardBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 6, 0, 0, w, h, C.bg_mid or Color(26,27,35) )
        surface.SetDrawColor(C.border or Color(50,52,65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        draw.RoundedBoxEx( 6, 0, 0, w, 40, C.bg_light or Color(34,36,46), true, true, false, false )
        draw.SimpleText( "LEADERBOARD", "SMGRP_Bold13", 16, 20, C.text_secondary or Color(140,144,160), 0, TEXT_ALIGN_CENTER )
    end

    function self.RefreshPanel()
        leaderboardBack:Clear()

        local height, spacing = 60, 8
        local slots = #(BRICKS_SERVER.TEMP.UnboxingLeaderboard or {})
        local scrollPanelTall = bottomBackTall-50-20
        local displayBar = (slots*(height+spacing))-spacing > scrollPanelTall

        local leaderboardScroll = vgui.Create( displayBar and "bricks_server_scrollpanel_bar" or "bricks_server_scrollpanel", leaderboardBack )
        leaderboardScroll:Dock( FILL )
        leaderboardScroll:DockMargin( 12, 50, 12, 12 )
        if( displayBar ) then leaderboardScroll:SetBarBackColor( C.bg_darkest or Color(12,12,18) ) end

        local medalColors = {
            Color(255, 200, 50),  -- Gold
            Color(190, 195, 205), -- Silver
            Color(200, 145, 60),  -- Bronze
        }

        for k, v in pairs( BRICKS_SERVER.TEMP.UnboxingLeaderboard or {} ) do
            local avatarBackSize = height-14
            local textStartPos = height

            local playerName = BRICKS_SERVER.Func.L( "unknown" )
            if( v.steamID64 ) then
                steamworks.RequestPlayerInfo( v.steamID64, function( steamName )
                    playerName = steamName
                end )
            end

            local playerBack = vgui.Create( "DPanel", leaderboardScroll )
            playerBack:Dock( TOP )
            playerBack:DockMargin( 0, 0, displayBar and 6 or 0, spacing )
            playerBack:SetTall( height )
            playerBack.Paint = function( self2, w, h )
                draw.RoundedBox( 4, 0, 0, w, h, C.bg_light or Color(34,36,46) )

                -- Rank medal
                if k <= 3 then
                    local medalCol = medalColors[k]
                    draw.RoundedBox( 2, 2, 2, 4, h-4, medalCol )
                end

                draw.SimpleText( playerName, "SMGRP_Bold13", textStartPos, h/2+1, C.text_primary or Color(220,222,230), 0, TEXT_ALIGN_BOTTOM )
                draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingXCases", (v.cases or 0) ), "SMGRP_Body12", textStartPos, h/2-1, C.text_muted or Color(90,94,110), 0, 0 )

                -- Rank number
                draw.SimpleText( "#" .. k, "SMGRP_Bold14", w-12, h/2, k <= 3 and medalColors[k] or (C.text_muted or Color(90,94,110)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
            end

            local avatarIcon = vgui.Create( "bricks_server_circle_avatar", playerBack )
            avatarIcon:SetPos( 12, (height-avatarBackSize)/2 )
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

    -- ====== FEATURED ITEMS (center) ======
    local featuredBack = vgui.Create( "DPanel", bottomBack )
    featuredBack:Dock( FILL )
    featuredBack:DockMargin( 0, 0, 10, 0 )
    featuredBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 6, 0, 0, w, h, C.bg_mid or Color(26,27,35) )
        surface.SetDrawColor(C.border or Color(50,52,65))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        draw.RoundedBoxEx( 6, 0, 0, w, 40, C.bg_light or Color(34,36,46), true, true, false, false )
        draw.SimpleText( "FEATURED", "SMGRP_Bold13", 16, 20, C.accent or Color(0,212,170), 0, TEXT_ALIGN_CENTER )
    end

    local featuredScroll = vgui.Create( "bricks_server_scrollpanel_bar", featuredBack )
    featuredScroll:Dock( FILL )
    featuredScroll:DockMargin( 12, 50, 12, 12 )
    featuredScroll:SetBarBackColor( C.bg_darkest or Color(12,12,18) )

    local featuredSlotWide = self.panelWide-40-leaderboardBack:GetWide()-activityBack:GetWide()-10-10-24-20
    for i = 1, BRICKS_SERVER.DEVCONFIG.UnboxingFeaturedAmount do
        local storeItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Store.Items[BRICKS_SERVER.CONFIG.UNBOXING.Store.Featured[i] or 0]
        if( not storeItemTable ) then continue end

        local slotBack = vgui.Create( "bricks_server_unboxingmenu_itemslot", featuredScroll )
        slotBack:Dock( TOP )
        slotBack:DockMargin( 0, 0, 6, 8 )
        slotBack:SetSize( featuredSlotWide, featuredSlotWide*1.2 )
        slotBack:FillPanel( storeItemTable.GlobalKey, 1 )
        slotBack:AddTopInfo( BRICKS_SERVER.UNBOXING.Func.FormatCurrency( storeItemTable.Price or 0, storeItemTable.Currency ), C.accent_dim or Color(0,160,128), Color(255,255,255) )
    
        if( storeItemTable.Group ) then
            local groupTable = {}
            for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                if( val[1] == storeItemTable.Group ) then groupTable = val break end
            end
            slotBack:AddTopInfo( storeItemTable.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme( 6 ) )
        end
    end
end

function PANEL:Paint( w, h )
    local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
    draw.RoundedBox( 0, 0, 0, w, h, C.bg_darkest or Color(12,12,18) )
end

vgui.Register( "bricks_server_unboxingmenu_home", PANEL, "DPanel" )
