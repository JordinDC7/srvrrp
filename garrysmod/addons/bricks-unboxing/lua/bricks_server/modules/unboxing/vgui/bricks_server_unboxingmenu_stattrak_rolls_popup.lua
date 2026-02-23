local PANEL = {}


function PANEL:Init()
end

function PANEL:CreatePopout()
    self.panelWide, self.panelTall = self:GetWide(), ScrH() * 0.65 - 40
    self.popoutWide, self.popoutTall = self.panelWide * 0.62, self.panelTall * 0.9

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

    self.topBar = vgui.Create( "DPanel", self.mainPanel )
    self.topBar:Dock( TOP )
    self.topBar:DockMargin( 20, 20, 20, 0 )
    self.topBar:SetTall( 44 )
    self.topBar.Paint = function( self2, w, h )
        draw.RoundedBox( 6, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
    end

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 10, 7, 10, 7 )
    self.searchBar:SetWide( 190 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:RefreshRows()
    end

    self.sortBy = vgui.Create( "bricks_server_combo", self.topBar )
    self.sortBy:Dock( RIGHT )
    self.sortBy:DockMargin( 10, 7, 10, 7 )
    self.sortBy:SetWide( 180 )
    self.sortBy:SetBackColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
    self.sortBy:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.sortBy:AddChoice( "Score (High to Low)", "score_desc" )
    self.sortBy:AddChoice( "Score (Low to High)", "score_asc" )
    self.sortBy:AddChoice( "Newest", "time_desc" )
    self.sortBy:AddChoice( "Oldest", "time_asc" )
    self.sortBy:SetValue( "Score (High to Low)" )
    self.sortChoice = "score_desc"
    self.sortBy.OnSelect = function( _, _, _, data )
        self.sortChoice = data
        self:RefreshRows()
    end

    self.scroll = vgui.Create( "bricks_server_scrollpanel_bar", self.mainPanel )
    self.scroll:Dock( FILL )
    self.scroll:DockMargin( 20, 12, 20, 12 )

    self.list = vgui.Create( "DListView", self.scroll )
    self.list:Dock( FILL )
    self.list:SetMultiSelect( false )
    self.list:AddColumn( "#" )
    self.list:AddColumn( "Tier" )
    self.list:AddColumn( "Score" )
    self.list:AddColumn( "DMG" )
    self.list:AddColumn( "ACC" )
    self.list:AddColumn( "CTRL" )
    self.list:AddColumn( "HND" )
    self.list:AddColumn( "MOV" )
    self.list:AddColumn( "Roll Time" )

    timer.Simple( 0, function()
        if( not IsValid( self.list ) ) then return end

        local fixedWidths = { 40, 70, 70, 52, 52, 58, 52, 52, 150 }
        for i, column in ipairs( self.list.Columns or {} ) do
            if( fixedWidths[i] ) then
                column:SetFixedWidth( fixedWidths[i] )
            end
        end
    end )

    self.emptyLabel = vgui.Create( "DLabel", self.scroll )
    self.emptyLabel:Dock( TOP )
    self.emptyLabel:DockMargin( 6, 6, 6, 0 )
    self.emptyLabel:SetFont( "BRICKS_SERVER_Font19" )
    self.emptyLabel:SetTextColor( BRICKS_SERVER.Func.GetTheme( 6, 120 ) )
    self.emptyLabel:SetText( "No rolls found for this item yet." )
    self.emptyLabel:SetVisible( false )

    self.list.OnRowSelected = function( _, _, row )
        local rollIndex = row.RollIndex
        if( not rollIndex ) then return end

        self.inspectPopup = vgui.Create( "bricks_server_unboxingmenu_stattrak_popup", self )
        self.inspectPopup:SetPos( 0, 0 )
        self.inspectPopup:SetSize( self.panelWide, ScrH() * 0.65 - 40 )
        self.inspectPopup:CreatePopout()
        self.inspectPopup:FillPanel( self.globalKey, false, rollIndex )
    end

    self.closeButton = vgui.Create( "DButton", self.mainPanel )
    self.closeButton:Dock( BOTTOM )
    self.closeButton:SetTall( 40 )
    self.closeButton:SetText( "" )
    self.closeButton:DockMargin( 20, 0, 20, 20 )
    self.closeButton.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
        draw.SimpleText( BRICKS_SERVER.Func.L( "close" ), "BRICKS_SERVER_Font20", w / 2, h / 2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    self.closeButton.DoClick = self.popoutPanel.ClosePopout
end

function PANEL:FillPanel( globalKey )
    self.globalKey = globalKey
    self.rolls = BRICKS_SERVER.UNBOXING.Func.GetStatTrakRolls( LocalPlayer(), globalKey ) or {}
    self:RefreshRows()
end

function PANEL:RefreshRows()
    if( not IsValid( self.list ) ) then return end

    self.list:Clear()

    if( IsValid( self.emptyLabel ) ) then
        self.emptyLabel:SetVisible( false )
    end

    local rows = {}
    for idx, roll in ipairs( self.rolls or {} ) do
        local stats = roll.Stats or {}
        table.insert( rows, {
            Index = idx,
            Tier = tostring( roll.TierTag or "RAW" ),
            Score = tonumber( roll.Score ) or 0,
            Time = tonumber( roll.Created ) or 0,
            Stamp = os.date( "%d/%m/%Y %H:%M:%S", tonumber( roll.Created ) or os.time() ),
            Stats = {
                DMG = tonumber( stats.DMG ) or 0,
                ACC = tonumber( stats.ACC ) or 0,
                CTRL = tonumber( stats.CTRL ) or 0,
                HND = tonumber( stats.HND ) or 0,
                MOV = tonumber( stats.MOV ) or 0
            }
        } )
    end

    local searchText = string.lower( string.Trim( tostring( IsValid( self.searchBar ) and self.searchBar:GetValue() or "" ) ) )
    if( searchText != "" ) then
        local filtered = {}

        for _, row in ipairs( rows ) do
            local haystack = string.lower( string.format( "%s %.2f %d %d %d %d %d", row.Tier, row.Score, row.Stats.DMG, row.Stats.ACC, row.Stats.CTRL, row.Stats.HND, row.Stats.MOV ) )
            if( string.find( haystack, searchText, 1, true ) ) then
                table.insert( filtered, row )
            end
        end
        rows = filtered
    end

    table.sort( rows, function( a, b )
        if( self.sortChoice == "score_asc" ) then
            return a.Score < b.Score
        elseif( self.sortChoice == "time_desc" ) then
            return a.Time > b.Time
        elseif( self.sortChoice == "time_asc" ) then
            return a.Time < b.Time
        end

        return a.Score > b.Score
    end )

    if( #rows == 0 and IsValid( self.emptyLabel ) ) then
        self.emptyLabel:SetVisible( true )
        return
    end

    for _, row in ipairs( rows ) do
        local line = self.list:AddLine(
            row.Index,
            row.Tier,
            string.format( "%.2f", row.Score ),
            row.Stats.DMG,
            row.Stats.ACC,
            row.Stats.CTRL,
            row.Stats.HND,
            row.Stats.MOV,
            row.Stamp
        )
        line.RollIndex = row.Index
    end
end

vgui.Register( "bricks_server_unboxingmenu_stattrak_rolls_popup", PANEL, "DPanel" )
