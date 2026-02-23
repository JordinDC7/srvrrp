local PANEL = {}

local statRows = {
    { Key = "DMG", Label = "Damage", Color = Color( 255, 70, 70 ) },
    { Key = "HND", Label = "Rate", Color = Color( 20, 210, 50 ) },
    { Key = "CTRL", Label = "Control", Color = Color( 255, 174, 0 ) },
    { Key = "ACC", Label = "Precision", Color = Color( 36, 223, 224 ) },
    { Key = "MOV", Label = "Mobility", Color = Color( 173, 118, 255 ) }
}

local function BRS_UC_AlphaColor( col, alpha )
    if( not IsColor( col ) ) then
        return Color( 255, 255, 255, alpha or 255 )
    end

    return Color( col.r, col.g, col.b, alpha or col.a or 255 )
end

local function BRS_UC_GetDisplayName( itemName, rarityName )
    local cleanName = string.Trim( tostring( itemName or "" ) )
    local cleanRarity = string.Trim( tostring( rarityName or "" ) )
    if( cleanName == "" or cleanRarity == "" ) then return cleanName end

    local lowerName = string.lower( cleanName )
    local lowerRarity = string.lower( cleanRarity )
    if( string.StartWith( lowerName, lowerRarity .. " " ) ) then
        return string.Trim( string.sub( cleanName, #cleanRarity+2 ) )
    end

    return cleanName
end

function PANEL:Init()
end

function PANEL:CreatePopout()
    self.panelWide, self.panelTall = self:GetWide(), ScrH() * 0.65 - 40
    self.popoutWide, self.popoutTall = self.panelWide * 0.36, self.panelTall * 0.9

    self.popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall, self.popoutWide, self.popoutTall )
    self.popoutPanel.Paint = function( self2, w, h )
        Derma_DrawBackgroundBlur( self2, SysTime() )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2, 245 ) )
    end
    self.popoutPanel.OnRemove = function()
        self:Remove()
    end

    self.mainPanel = vgui.Create( "DPanel", self.popoutPanel )
    self.mainPanel:Dock( FILL )
    self.mainPanel.Paint = nil

    self.closeButton = vgui.Create( "DButton", self.mainPanel )
    self.closeButton:Dock( BOTTOM )
    self.closeButton:SetTall( 40 )
    self.closeButton:SetText( "" )
    self.closeButton:DockMargin( 25, 0, 25, 25 )
    self.closeButton.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
        draw.SimpleText( BRICKS_SERVER.Func.L( "close" ), "BRICKS_SERVER_Font20", w / 2, h / 2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    self.closeButton.DoClick = self.popoutPanel.ClosePopout

    self.card = vgui.Create( "DPanel", self.mainPanel )
    self.card:Dock( FILL )
    self.card:DockMargin( 25, 20, 25, 20 )
    self.card.Paint = function( self2, w, h )
        local baseBg = BRICKS_SERVER.Func.GetTheme( 2 )
        local innerBg = BRICKS_SERVER.Func.GetTheme( 1 )
        local txtCol = BRICKS_SERVER.Func.GetTheme( 6 )
        local rarityColor = BRICKS_SERVER.Func.GetRarityColor( self.rarityInfo ) or Color( 255, 255, 255 )

        draw.RoundedBox( 10, 0, 0, w, h, baseBg )
        surface.SetDrawColor( BRS_UC_AlphaColor( rarityColor, 32 ) )
        surface.DrawOutlinedRect( 0, 0, w, h, 1 )

        local topStripH = 26
        draw.RoundedBoxEx( 10, 0, 0, w, topStripH, BRS_UC_AlphaColor( innerBg, 175 ), true, true, false, false )

        local contentTop = topStripH + 6
        local bottomPad = 40
        local previewBottom = h - 246
        local contentH = math.max( 80, previewBottom - contentTop )

        draw.RoundedBox( 8, 6, contentTop, w - 12, contentH, BRS_UC_AlphaColor( innerBg, 155 ) )
        draw.RoundedBox( 8, 6, contentTop, w - 12, 4, BRS_UC_AlphaColor( rarityColor, 175 ) )

        draw.SimpleText( self.displayName or self.itemName or "Unknown", "BRICKS_SERVER_Font20", w / 2, h - bottomPad + 8, BRS_UC_AlphaColor( txtCol, 210 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( self.rarityInfo or "", "BRICKS_SERVER_Font17", w / 2, h - bottomPad + 24, BRS_UC_AlphaColor( rarityColor, 230 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        if( self.rollTierName and (tonumber( self.rollCount ) or 1) <= 1 ) then
            draw.SimpleText( string.format( "%s | Forge %.2f", tostring( self.rollTierName ), tonumber( self.rollScore ) or 0 ), "BRICKS_SERVER_Font17", w / 2, h - bottomPad + 40, BRS_UC_AlphaColor( txtCol, 180 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        draw.RoundedBoxEx( 6, 0, h - 6, w, 6, rarityColor, false, false, true, true )
    end

    self.preview = vgui.Create( "bricks_server_unboxing_itemdisplay", self.card )
    self.preview:SetPos( 6, 32 )
    self.preview:SetSize( self.popoutWide - 62, 250 )
    self.preview:SetIconSizeAdjust( 0.82 )

    self.detailsBack = vgui.Create( "DPanel", self.card )
    self.detailsBack:Dock( BOTTOM )
    self.detailsBack:DockMargin( 10, 0, 10, 10 )
    self.detailsBack:SetTall( 240 )
    self.detailsBack.Paint = function( self2, w, h )
        draw.RoundedBox( 6, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 120 ) )
    end

    self.detailsScroll = vgui.Create( "bricks_server_scrollpanel_bar", self.detailsBack )
    self.detailsScroll:Dock( FILL )
    self.detailsScroll:DockMargin( 0, 0, 0, 0 )
end

function PANEL:FillPanel( globalKey, rankingMode, rollIndex )
    local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
    if( not configItemTable ) then return end

    local summary = BRICKS_SERVER.UNBOXING.Func.GetStatTrakRollByIndex( LocalPlayer(), globalKey, rollIndex )
    if( not summary ) then return end

    self.globalKey = globalKey
    self.itemName = configItemTable.Name or "Unknown"
    self.rarityInfo = configItemTable.Rarity or ""
    self.displayName = BRS_UC_GetDisplayName( self.itemName, self.rarityInfo )
    self.rollCount = tonumber( (LocalPlayer():GetUnboxingInventory() or {})[globalKey] ) or 1

    self.preview:SetItemData( "ITEM", configItemTable )

    self.rollTierName = summary.TierName
    self.rollScore = summary.Score

    if( IsValid( self.detailsScroll ) ) then
        self.detailsScroll:Clear()
    end

    local parentPanel = IsValid( self.detailsScroll ) and self.detailsScroll or self.detailsBack
    local stats = summary.Stats or {}

    if( rankingMode ) then
        local rankings = BRICKS_SERVER.UNBOXING.Func.GetStatTrakRankings( LocalPlayer(), (configItemTable.ReqInfo or {})[1], stats )

        local title = vgui.Create( "DLabel", parentPanel )
        title:Dock( TOP )
        title:DockMargin( 10, 10, 10, 10 )
        title:SetText( "Weapon Ranking" )
        title:SetFont( "BRICKS_SERVER_Font22" )
        title:SetTextColor( Color( 72, 255, 72 ) )

        for _, row in ipairs( statRows ) do
            local data = rankings[row.Key] or { Rank = 1, Percentile = 100, Total = 1 }
            local line = vgui.Create( "DLabel", parentPanel )
            line:Dock( TOP )
            line:DockMargin( 10, 3, 10, 0 )
            line:SetText( string.format( "%s: #%d/%d | Top %.2f%%", row.Label:upper(), data.Rank or 1, data.Total or 1, data.Percentile or 100 ) )
            line:SetFont( "BRICKS_SERVER_Font18" )
            line:SetTextColor( row.Color )
        end

        local scoreLine = vgui.Create( "DLabel", parentPanel )
        scoreLine:Dock( TOP )
        scoreLine:DockMargin( 10, 10, 10, 0 )
        scoreLine:SetText( string.format( "Overall Booster Score: %.2f (%s)", tonumber( summary.Score ) or 0, tostring( summary.TierName or "Unranked" ) ) )
        scoreLine:SetFont( "BRICKS_SERVER_Font18" )
        scoreLine:SetTextColor( BRICKS_SERVER.Func.GetTheme( 6 ) )

        return
    end

    for _, row in ipairs( statRows ) do
        local val = tonumber( stats[row.Key] ) or 0

        local line = vgui.Create( "DPanel", parentPanel )
        line:Dock( TOP )
        line:DockMargin( 8, 6, 8, 0 )
        line:SetTall( 24 )
        line.Paint = function( self2, w, h )
            draw.SimpleText( string.format( "%s: +%d%%", row.Label:upper(), val ), "BRICKS_SERVER_Font18", w / 2, 0, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )

            draw.RoundedBox( 3, 0, 16, w, 8, BRICKS_SERVER.Func.GetTheme( 1 ) )
            draw.RoundedBox( 3, 0, 16, w * (math.Clamp( val, 0, 100 ) / 100), 8, row.Color )
        end
    end

    local infoRows = {
        string.format( "Forge Tier: %s (%s)", tostring( summary.TierName or "Raw" ), tostring( summary.TierTag or "RAW" ) ),
        string.format( "Roll Flavor: %s", tostring( summary.RollFlavor or "Field" ) ),
        string.format( "Jackpot: %s", (summary.IsJackpot and "YES" or "No") ),
        string.format( "Booster ID: %s", tostring( summary.BoosterID or "N/A" ) ),
        string.format( "UUID: %s", tostring( summary.UUID or "N/A" ) ),
        string.format( "Unboxed by: %s", tostring( summary.UnboxedBy or "Unknown" ) ),
        string.format( "Unboxer SteamID64: %s", tostring( summary.UnboxedBySteamID64 or "Unknown" ) ),
        string.format( "Unboxed at: %s", os.date( "%d/%m/%Y %H:%M:%S", tonumber( summary.Created ) or os.time() ) )
    }

    for i, text in ipairs( infoRows ) do
        local infoLine = vgui.Create( "DLabel", parentPanel )
        infoLine:Dock( TOP )
        infoLine:DockMargin( 10, i == 1 and 10 or 2, 10, 0 )
        infoLine:SetTall( 18 )
        infoLine:SetFont( "BRICKS_SERVER_Font17" )
        infoLine:SetTextColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        infoLine:SetText( text )
    end
end

vgui.Register( "bricks_server_unboxingmenu_stattrak_popup", PANEL, "DPanel" )
