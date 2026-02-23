local PANEL = {}

function PANEL:Init()
    self:SetHeader( string.upper( BRICKS_SERVER.Func.L( "gangMenu" ) ) )
    self:SetSize( ScrW()*0.6, ScrH()*0.65 )
    self:Center()
    self.removeOnClose = false

    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:Dock( FILL )
    self.mainPanel.Paint = function( self2, w, h ) end

    self:RefreshGang()

    hook.Add( "BRS.Hooks.RefreshGang", self, function(  self, valuesChanged, refreshGang )
        if( IsValid( self ) ) then
            self:RefreshGang()
        else
            hook.Remove( "BRS.Hooks.RefreshGang", self )
        end
    end )

    hook.Add( "BRS.Hooks.ConfigReceived", self, function( self, valuesChanged )
        if( IsValid( self ) ) then
            if( not valuesChanged or valuesChanged.GANGS ) then
                self:RefreshGang()
            end
        else
            hook.Remove( "BRS.Hooks.ConfigReceived", self )
        end
    end )
end

function PANEL:RefreshGang()
    if( IsValid( self.sheet ) ) then
        if( IsValid( self.sheet.ActiveButton ) ) then
            self.previousSheet = self.sheet.ActiveButton.label
        end
        self.sheet:Remove()
    end

    self.mainPanel:Clear()

    self.sheet = vgui.Create( "bricks_server_colsheet", self.mainPanel )
    self.sheet:Dock( FILL )
    self.sheet.Navigation:SetWide( BRICKS_SERVER.DEVCONFIG.MainNavWidth )

    local gangTable = (BRICKS_SERVER_GANGS or {})[LocalPlayer():GetGangID()]

    local height = BRICKS_SERVER.Func.ScreenScale( 55 )
    local avatarSize = ((gangTable or {}).Icon and height-2*BRICKS_SERVER.UI.Margin5) or 32
    local textStartPos = BRICKS_SERVER.Func.ScreenScale( 65 )

    local gangIconBack = vgui.Create( "DPanel", self.sheet.Navigation )
    gangIconBack:Dock( TOP )
    gangIconBack:DockMargin( 10, 10, 10, 0 )
    gangIconBack:SetTall( height )
    local groupData = LocalPlayer():GangGetGroupData()
    gangIconBack.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, h, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        draw.SimpleText( ((gangTable and (gangTable.Name or BRICKS_SERVER.Func.L( "nil" ))) or BRICKS_SERVER.Func.L( "gangNone" )), "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( ((groupData and groupData[1]) or "None"), "BRICKS_SERVER_Font17", textStartPos+1, h/2-2, ((groupData and groupData[2]) or BRICKS_SERVER.Func.GetTheme( 6 )), 0, 0 )
    end

    local gangIcon = vgui.Create( "bricks_server_gangicon", gangIconBack )
    gangIcon:SetSize( avatarSize, avatarSize )
    gangIcon:SetPos( BRICKS_SERVER.UI.Margin5, BRICKS_SERVER.UI.Margin5 )
    gangIcon:SetIconURL( (gangTable or {}).Icon or "bricks_server/question.png" )

    local levelBarH = 16
    local levelBack = vgui.Create( "DPanel", self.sheet.Navigation )
    levelBack:Dock( TOP )
    levelBack:DockMargin( 10, 10, 10, 25 )
    levelBack:SetTall( levelBarH+20 )
    levelBack.Paint = function( self2, w, h )
        draw.SimpleText( string.upper( BRICKS_SERVER.Func.L( "levelX", (gangTable or {}).Level or 0) ), "BRICKS_SERVER_Font15", 0, h-levelBarH-3, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )

        local currentXP = math.max( 0, ((gangTable or {}).Experience or 0)-BRICKS_SERVER.Func.GetGangExpToLevel( 0, ((gangTable or {}).Level or 0) ) )
        local goalXP = math.max( 0, BRICKS_SERVER.Func.GetGangExpToLevel( ((gangTable or {}).Level or 0), ((gangTable or {}).Level or 0)+1 ) )

        draw.SimpleText( string.Comma( math.floor( currentXP ) ) .. "/" .. string.Comma( math.floor( goalXP ) ) .. "XP", "BRICKS_SERVER_Font15", w, h-levelBarH-3, Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

        draw.RoundedBox( levelBarH/2, 0, h-levelBarH, w, levelBarH, BRICKS_SERVER.Func.GetTheme( 1 ) )
        draw.RoundedBox( levelBarH/2, 0, h-levelBarH, math.Clamp( w*(currentXP/goalXP), 0, w ), levelBarH, BRICKS_SERVER.Func.GetTheme( 5 ) )
    end

    if( not gangTable ) then
        local inboxButton = vgui.Create( "DButton", self.sheet.Navigation )
        inboxButton:SetSize( 36, 36 )
        inboxButton:SetPos( self.sheet.Navigation:GetWide()-10-inboxButton:GetWide(), 10 )
        inboxButton:SetText( "" )
        local Alpha = 0
        local inboxMat = Material( "bricks_server/invite.png" )
        inboxButton.Paint = function( self2, w, h )
            if( self2:IsDown() ) then
                Alpha = 0
            elseif( self2:IsHovered() ) then
                Alpha = math.Clamp( Alpha+5, 0, 75 )
            else
                Alpha = math.Clamp( Alpha-5, 0, 75 )
            end
        
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( Alpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            surface.SetAlphaMultiplier( 1 )
        
            surface.SetDrawColor( 255, 255, 255, 20+(235*(Alpha/75)) )
            surface.SetMaterial( inboxMat )
            local iconSize = 24
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end

        BRICKS_SERVER.Func.GangCreateInbox( self, inboxButton, true, inboxButton:GetTall()+5, inboxButton:GetPos() )
    end

    local pages = {}
    if( gangTable ) then
        table.insert( pages, { BRICKS_SERVER.Func.L( "gangDashboard" ), "bricks_server_gangmenu_dashboard", "dashboard.png" } )
        table.insert( pages, { BRICKS_SERVER.Func.L( "gangMembers" ), "bricks_server_gangmenu_members", "gangs_24.png" } )

        if( LocalPlayer():GangHasPermission( "ViewItem" ) and BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "storage" ) ) then
            table.insert( pages, { BRICKS_SERVER.Func.L( "gangStorage" ), "bricks_server_gangmenu_storage", "crate_24.png" } )
        end

        table.insert( pages, { BRICKS_SERVER.Func.L( "gangUpgrades" ), "bricks_server_gangmenu_upgrades", "gang_upgrades.png" } )

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "achievements" ) ) then
            table.insert( pages, { BRICKS_SERVER.Func.L( "gangAchievements" ), "bricks_server_gangmenu_achievements", "gang_achievements.png" } )
        end

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "associations" ) ) then
            table.insert( pages, { BRICKS_SERVER.Func.L( "gangAssociations" ), "bricks_server_gangmenu_associations", "gang_relation.png" } )
        end

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "leaderboards" ) ) then
            table.insert( pages, { BRICKS_SERVER.Func.L( "gangLeaderboards" ), "bricks_server_gangmenu_leaderboards", "gang_leaderboard.png" } )
        end

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "territories" ) ) then
            table.insert( pages, { BRICKS_SERVER.Func.L( "gangTerritories" ), "bricks_server_gangmenu_territories", "gang_territory.png" } )
        end

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "printers" ) ) then
            table.insert( pages, { BRICKS_SERVER.Func.L( "gangPrinters" ), "bricks_server_gangmenu_printers", "gang_printers.png" } )
        end

        if( LocalPlayer():GangHasPermission( "EditSettings" ) ) then
            table.insert( pages, { BRICKS_SERVER.Func.L( "settings" ), "bricks_server_gangmenu_settings", "settings_24.png" } )
        end

        if( LocalPlayer():GangHasPermission( "EditRoles" ) ) then
            table.insert( pages, { BRICKS_SERVER.Func.L( "gangRanks" ), "bricks_server_gangmenu_roles", "gang_ranks.png" } )
        end
    else
        table.insert( pages, { BRICKS_SERVER.Func.L( "gangCreate" ), "bricks_server_gangmenu_create", "gang_new.png" } )
    end

    if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
        table.insert( pages, { BRICKS_SERVER.Func.L( "admin" ), "bricks_server_gangmenu_admin", "admin_24.png", BRICKS_SERVER.Func.GetTheme( 4 ), BRICKS_SERVER.Func.GetTheme( 5 ) } )
    end

    for k, v in pairs( pages ) do
        local page = vgui.Create( v[2], self.sheet )
        page:Dock( FILL )
        page.panelWide, page.panelHeight = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth, ScrH()*0.65-self.headerHeight
        page.Paint = function( self, w, h ) end 

        if( page.FillPanel ) then
            self.sheet:AddSheet( v[1], page, function()
                page:FillPanel( gangTable ) 
            end, v[3], v[4], v[5] )
        else
            self.sheet:AddSheet( v[1], page, false, v[3], v[4], v[5] )
        end
    end

    if( self.previousSheet ) then
        self.sheet:SetActiveSheet( self.previousSheet )
    end
end

vgui.Register( "bricks_server_gangmenu", PANEL, "bricks_server_dframe" )
