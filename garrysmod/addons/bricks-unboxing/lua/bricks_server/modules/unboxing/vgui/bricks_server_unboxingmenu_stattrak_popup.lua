local PANEL = {}

local statRows = {
    { Key = "DMG", Label = "Damage", Color = Color( 255, 70, 70 ) },
    { Key = "HND", Label = "Rate", Color = Color( 20, 210, 50 ) },
    { Key = "CTRL", Label = "Control", Color = Color( 255, 174, 0 ) },
    { Key = "ACC", Label = "Precision", Color = Color( 36, 223, 224 ) },
    { Key = "MOV", Label = "Mobility", Color = Color( 173, 118, 255 ) }
}

function PANEL:Init()
end

function PANEL:CreatePopout()
    self.panelWide, self.panelTall = self:GetWide(), ScrH() * 0.65 - 40
    self.popoutWide, self.popoutTall = self.panelWide * 0.36, self.panelTall * 0.9

    self.popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall, self.popoutWide, self.popoutTall )
    self.popoutPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
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
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        local rarityColor = BRICKS_SERVER.Func.GetRarityColor( self.rarityInfo ) or Color( 255, 255, 255 )
        surface.SetDrawColor( rarityColor )
        surface.DrawOutlinedRect( 3, 3, w - 6, h - 6, 2 )

        draw.SimpleText( self.itemName or "Unknown", "BRICKS_SERVER_Font30", w / 2, 30, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        draw.SimpleText( self.rarityInfo or "", "BRICKS_SERVER_Font24", w / 2, 62, rarityColor, TEXT_ALIGN_CENTER, 0 )
        if( self.rollTierName ) then
            draw.SimpleText( string.format( "%s | Forge %.2f", tostring( self.rollTierName ), tonumber( self.rollScore ) or 0 ), "BRICKS_SERVER_Font18", w / 2, 86, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        end
    end

    self.preview = vgui.Create( "bricks_server_unboxing_itemdisplay", self.card )
    self.preview:SetPos( 20, 92 )
    self.preview:SetSize( self.popoutWide - 90, 200 )
    self.preview:SetIconSizeAdjust( 0.9 )

    self.detailsBack = vgui.Create( "DPanel", self.card )
    self.detailsBack:Dock( BOTTOM )
    self.detailsBack:DockMargin( 10, 0, 10, 10 )
    self.detailsBack:SetTall( 190 )
    self.detailsBack.Paint = function( self2, w, h )
        draw.RoundedBox( 6, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 120 ) )
    end
end

function PANEL:FillPanel( globalKey, rankingMode, rollIndex )
    local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
    if( not configItemTable ) then return end

    local summary = BRICKS_SERVER.UNBOXING.Func.GetStatTrakRollByIndex( LocalPlayer(), globalKey, rollIndex )
    if( not summary ) then return end

    self.globalKey = globalKey
    self.itemName = configItemTable.Name or "Unknown"
    self.rarityInfo = configItemTable.Rarity or ""

    self.preview:SetItemData( "ITEM", configItemTable )

    self.rollTierName = summary.TierName
    self.rollScore = summary.Score

    self.detailsBack:Clear()

    local stats = summary.Stats or {}

    if( rankingMode ) then
        local rankings = BRICKS_SERVER.UNBOXING.Func.GetStatTrakRankings( LocalPlayer(), (configItemTable.ReqInfo or {})[1], stats )

        local title = vgui.Create( "DLabel", self.detailsBack )
        title:Dock( TOP )
        title:DockMargin( 10, 10, 10, 10 )
        title:SetText( "Booster Rankings" )
        title:SetFont( "BRICKS_SERVER_Font22" )
        title:SetTextColor( Color( 72, 255, 72 ) )

        for _, row in ipairs( statRows ) do
            local data = rankings[row.Key] or { Rank = 1, Percentile = 100, Total = 1 }
            local line = vgui.Create( "DLabel", self.detailsBack )
            line:Dock( TOP )
            line:DockMargin( 10, 3, 10, 0 )
            line:SetText( string.format( "%s: Rank %d/%d | Percentile %.2f%%", row.Label:upper(), data.Rank or 1, data.Total or 1, data.Percentile or 100 ) )
            line:SetFont( "BRICKS_SERVER_Font18" )
            line:SetTextColor( row.Color )
        end

        return
    end

    for _, row in ipairs( statRows ) do
        local val = tonumber( stats[row.Key] ) or 0

        local line = vgui.Create( "DPanel", self.detailsBack )
        line:Dock( TOP )
        line:DockMargin( 8, 6, 8, 0 )
        line:SetTall( 24 )
        line.Paint = function( self2, w, h )
            draw.SimpleText( string.format( "%s: +%d%%", row.Label:upper(), val ), "BRICKS_SERVER_Font18", w / 2, 0, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )

            draw.RoundedBox( 3, 0, 16, w, 8, BRICKS_SERVER.Func.GetTheme( 1 ) )
            draw.RoundedBox( 3, 0, 16, w * (math.Clamp( val, 0, 100 ) / 100), 8, row.Color )
        end
    end

    local infoLabel = vgui.Create( "DLabel", self.detailsBack )
    infoLabel:Dock( TOP )
    infoLabel:DockMargin( 10, 10, 10, 0 )
    infoLabel:SetWrap( true )
    infoLabel:SetAutoStretchVertical( true )
    infoLabel:SetFont( "BRICKS_SERVER_Font16" )
    infoLabel:SetTextColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
    infoLabel:SetText( string.format(
        "Forge Tier: %s (%s)\nRoll Flavor: %s\nJackpot: %s\nBooster ID: %s\nUUID: %s\nUnboxed by: %s\nUnboxer SteamID64: %s\nUnboxed at: %s",
        tostring( summary.TierName or "Raw" ),
        tostring( summary.TierTag or "RAW" ),
        tostring( summary.RollFlavor or "Field" ),
        (summary.IsJackpot and "YES" or "No"),
        tostring( summary.BoosterID or "N/A" ),
        tostring( summary.UUID or "N/A" ),
        tostring( summary.UnboxedBy or "Unknown" ),
        tostring( summary.UnboxedBySteamID64 or "Unknown" ),
        os.date( "%d/%m/%Y %H:%M:%S", tonumber( summary.Created ) or os.time() )
    ) )
end

vgui.Register( "bricks_server_unboxingmenu_stattrak_popup", PANEL, "DPanel" )
