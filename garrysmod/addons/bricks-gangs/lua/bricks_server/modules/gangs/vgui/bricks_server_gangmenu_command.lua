local PANEL = {}

local function getDefaultContribution()
    return {
        Name = "Unknown",
        Deposited = 0,
        Withdrawn = 0,
        UpgradeSpend = 0,
        Actions = 0,
        LastAction = 0
    }
end

function PANEL:FillPanel( gangTable )
    BRICKS_SERVER.Func.RequestGangCommandData()

    local outerMargin = 24

    local shell = vgui.Create( "DPanel", self )
    shell:Dock( FILL )
    shell:DockMargin( outerMargin, outerMargin, outerMargin, outerMargin )
    shell.Paint = function( self2, w, h ) end

    local header = vgui.Create( "DPanel", shell )
    header:Dock( TOP )
    header:SetTall( BRICKS_SERVER.Func.ScreenScale( 90 ) )
    header.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        draw.SimpleText( "COMMAND CENTER", "BRICKS_SERVER_Font30", 20, 18, BRICKS_SERVER.Func.GetTheme( 6 ) )

        local contributionData = ((BRS_GANG_COMMANDDATA or {})[LocalPlayer():GetGangID()] or {}).Contributions or {}
        local activeContributors = table.Count( contributionData )

        draw.SimpleText( "Unified gang operations, planning and contribution tracking.", "BRICKS_SERVER_Font20", 20, 52, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 170 ) )
        draw.SimpleText( "Tracked Contributors: " .. activeContributors, "BRICKS_SERVER_Font20", w-20, 52, Color( 255, 214, 103 ), TEXT_ALIGN_RIGHT )
    end

    local content = vgui.Create( "DPanel", shell )
    content:Dock( FILL )
    content:DockMargin( 0, 14, 0, 0 )
    content.Paint = function( self2, w, h ) end

    local left = vgui.Create( "DPanel", content )
    left:Dock( LEFT )
    left:SetWide( self.panelWide*0.42 )
    left.Paint = function( self2, w, h ) end

    local motdCard = vgui.Create( "DPanel", left )
    motdCard:Dock( TOP )
    motdCard:SetTall( BRICKS_SERVER.Func.ScreenScale( 260 ) )
    motdCard.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.SimpleText( "GANG BULLETIN", "BRICKS_SERVER_Font23", 18, 14, BRICKS_SERVER.Func.GetTheme( 6 ) )
    end

    local motdEntry = vgui.Create( "DTextEntry", motdCard )
    motdEntry:Dock( FILL )
    motdEntry:DockMargin( 16, 46, 16, 54 )
    motdEntry:SetMultiline( true )
    motdEntry:SetFont( "BRICKS_SERVER_Font20" )
    motdEntry:SetUpdateOnType( true )

    local saveMotd = vgui.Create( "bricks_server_buttong", motdCard )
    saveMotd:Dock( BOTTOM )
    saveMotd:DockMargin( 16, 0, 16, 16 )
    saveMotd:SetTall( 34 )
    saveMotd:SetText( "SAVE BULLETIN" )
    saveMotd.DoClick = function()
        if( not LocalPlayer():GangHasPermission( "EditSettings" ) ) then return end

        net.Start( "BRS.Net.GangSetMOTD" )
            net.WriteString( string.sub( string.Trim( motdEntry:GetValue() or "" ), 1, 240 ) )
        net.SendToServer()
    end

    local prioritiesCard = vgui.Create( "DPanel", left )
    prioritiesCard:Dock( FILL )
    prioritiesCard:DockMargin( 0, 12, 0, 0 )
    prioritiesCard.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.SimpleText( "OPERATION PRIORITIES", "BRICKS_SERVER_Font23", 18, 14, BRICKS_SERVER.Func.GetTheme( 6 ) )
    end

    local prioritiesScroll = vgui.Create( "bricks_server_scrollpanel_bar", prioritiesCard )
    prioritiesScroll:Dock( FILL )
    prioritiesScroll:DockMargin( 16, 46, 16, 16 )

    local priorityEntries = {}
    for i = 1, 5 do
        local priorityEntry = vgui.Create( "DTextEntry", prioritiesScroll )
        priorityEntry:Dock( TOP )
        priorityEntry:DockMargin( 0, 0, 0, 8 )
        priorityEntry:SetTall( 32 )
        priorityEntry:SetFont( "BRICKS_SERVER_Font20" )
        priorityEntry:SetPlaceholderText( "Priority #" .. i )

        priorityEntries[i] = priorityEntry
    end

    local savePriorities = vgui.Create( "bricks_server_buttong", prioritiesScroll )
    savePriorities:Dock( TOP )
    savePriorities:SetTall( 34 )
    savePriorities:SetText( "SAVE PRIORITIES" )
    savePriorities.DoClick = function()
        if( not LocalPlayer():GangHasPermission( "EditSettings" ) ) then return end

        local priorities = {}
        for i = 1, 5 do
            table.insert( priorities, string.sub( string.Trim( priorityEntries[i]:GetValue() or "" ), 1, 80 ) )
        end

        net.Start( "BRS.Net.GangSetPriorities" )
            net.WriteTable( priorities )
        net.SendToServer()
    end

    local right = vgui.Create( "DPanel", content )
    right:Dock( FILL )
    right:DockMargin( 14, 0, 0, 0 )
    right.Paint = function( self2, w, h ) end

    local activityCard = vgui.Create( "DPanel", right )
    activityCard:Dock( TOP )
    activityCard:SetTall( BRICKS_SERVER.Func.ScreenScale( 250 ) )
    activityCard.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.SimpleText( "ACTIVITY FEED", "BRICKS_SERVER_Font23", 18, 14, BRICKS_SERVER.Func.GetTheme( 6 ) )
    end

    local activityScroll = vgui.Create( "bricks_server_scrollpanel_bar", activityCard )
    activityScroll:Dock( FILL )
    activityScroll:DockMargin( 16, 46, 16, 16 )

    local contributionCard = vgui.Create( "DPanel", right )
    contributionCard:Dock( FILL )
    contributionCard:DockMargin( 0, 12, 0, 0 )
    contributionCard.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.SimpleText( "CONTRIBUTION LEADERBOARD", "BRICKS_SERVER_Font23", 18, 14, BRICKS_SERVER.Func.GetTheme( 6 ) )
    end

    local contributionScroll = vgui.Create( "bricks_server_scrollpanel_bar", contributionCard )
    contributionScroll:Dock( FILL )
    contributionScroll:DockMargin( 16, 46, 16, 16 )

    function self.RefreshCommandCenter()
        local commandData = ((BRS_GANG_COMMANDDATA or {})[LocalPlayer():GetGangID()] or {})

        motdEntry:SetValue( commandData.MOTD or "" )

        for i = 1, 5 do
            priorityEntries[i]:SetValue( (commandData.Priorities or {})[i] or "" )
        end

        local canEdit = LocalPlayer():GangHasPermission( "EditSettings" )
        motdEntry:SetEditable( canEdit )
        saveMotd:SetEnabled( canEdit )
        for i = 1, 5 do
            priorityEntries[i]:SetEditable( canEdit )
        end
        savePriorities:SetEnabled( canEdit )

        activityScroll:Clear()

        for _, v in ipairs( commandData.Activity or {} ) do
            local row = vgui.Create( "DPanel", activityScroll )
            row:Dock( TOP )
            row:DockMargin( 0, 0, 0, 8 )
            row:SetTall( 48 )
            row.Paint = function( self2, w, h )
                draw.RoundedBox( 6, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
                draw.SimpleText( v.Message or "", "BRICKS_SERVER_Font20", 12, 10, v.Color or BRICKS_SERVER.Func.GetTheme( 6 ) )
                draw.SimpleText( os.date( "%H:%M:%S", v.Time or os.time() ), "BRICKS_SERVER_Font17", w-12, 10, Color( 190, 190, 190 ), TEXT_ALIGN_RIGHT )
            end
        end

        contributionScroll:Clear()

        local leaderboard = {}
        for steamID, contribution in pairs( commandData.Contributions or {} ) do
            local score = (contribution.Deposited or 0)+(contribution.UpgradeSpend or 0)-((contribution.Withdrawn or 0)*0.5)
            table.insert( leaderboard, { score, steamID, contribution } )
        end

        table.SortByMember( leaderboard, 1, true )

        for index, rowData in ipairs( leaderboard ) do
            local contribution = rowData[3] or getDefaultContribution()

            local row = vgui.Create( "DPanel", contributionScroll )
            row:Dock( TOP )
            row:DockMargin( 0, 0, 0, 8 )
            row:SetTall( 54 )
            row.Paint = function( self2, w, h )
                draw.RoundedBox( 6, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

                draw.SimpleText( "#" .. index .. "  " .. (contribution.Name or "Unknown"), "BRICKS_SERVER_Font20", 12, 8, BRICKS_SERVER.Func.GetTheme( 6 ) )
                draw.SimpleText( "Deposited: " .. DarkRP.formatMoney( contribution.Deposited or 0 ) .. "   Withdrawn: " .. DarkRP.formatMoney( contribution.Withdrawn or 0 ) .. "   Upgrades: " .. DarkRP.formatMoney( contribution.UpgradeSpend or 0 ), "BRICKS_SERVER_Font17", 12, 29, Color( 205, 205, 205 ) )
                draw.SimpleText( "Actions: " .. (contribution.Actions or 0), "BRICKS_SERVER_Font17", w-12, 8, Color( 255, 214, 103 ), TEXT_ALIGN_RIGHT )
            end
        end
    end

    self:RefreshCommandCenter()

    hook.Add( "BRS.Hooks.GangCommandDataUpdated", self, function( self2, gangID )
        if( not IsValid( self2 ) ) then
            hook.Remove( "BRS.Hooks.GangCommandDataUpdated", self )
            return
        end

        if( gangID == LocalPlayer():GetGangID() ) then
            self2:RefreshCommandCenter()
        end
    end )
end

vgui.Register( "bricks_server_gangmenu_command", PANEL, "DPanel" )
