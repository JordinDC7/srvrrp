local PANEL = {}

function PANEL:Init()
    self.margin = 0
end

function PANEL:FillPanel()
    if self.panelWide == nil or self.panelWide < 100 then self.panelWide = self:GetWide() end; if self.panelWide < 100 then self.panelWide = math.min(ScrW() * 0.72, 1280) - 220 end; if self.panelTall == nil or self.panelTall < 100 then self.panelTall = self:GetTall() end; if self.panelTall < 100 then self.panelTall = math.min(ScrH() * 0.75, 820) - 220 end

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local headerX, headerY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingNotifConfigInfo" ) )
    local fullWidth = 60+headerX+35

    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    local noticeMat = Material( "bricks_server/unboxing_information.png" )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )

        -- Notice --
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
        surface.DrawRect( w-fullWidth, 0, fullWidth, h )
        
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
        surface.DrawRect( w-fullWidth, 0, h, h )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        surface.SetMaterial( noticeMat )
        local iconSize = 32
        surface.DrawTexturedRect( w-fullWidth+(h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingNotifConfigInfo" ), "BRICKS_SERVER_Font20", w-fullWidth+60+((fullWidth-60)/2), h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end 

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( math.min( ScrW()*0.2, self.panelWide-fullWidth-50 ) )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:Refresh()
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self, w, h ) end 

    self:Refresh()
end

function PANEL:Refresh()
    self.scrollPanel:Clear()

    for k, v in pairs( BS_ConfigCopyTable.GENERAL.Rarities ) do
        if( self.searchBar:GetValue() != "" and not string.find( string.lower( v[1] ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end

        local rarityEntry = vgui.Create( "DPanel", self.scrollPanel )
        rarityEntry:Dock( TOP )
        rarityEntry:DockMargin( 0, 0, 10, 10 )
        rarityEntry:SetTall( 40 )
        local alpha = 0
        local iconMat = Material( "bricks_server/unboxing_tick.png" )
        rarityEntry.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    
            if( IsValid( self2.button ) and self2.button:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 100 )
            else
                alpha = math.Clamp( alpha-10, 0, 100 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, alpha ) )

            draw.SimpleText( v[1] or "NIL", "BRICKS_SERVER_Font20", w/2, (h-5)/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            if( (BS_ConfigCopyTable.UNBOXING.NotificationRarities or {})[v[1]] ) then
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 75 ) )
                surface.SetMaterial( iconMat )
                local iconSize = 16
                surface.DrawTexturedRect( w-(h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end
        end

        rarityEntry.rarityBox = vgui.Create( "bricks_server_raritybox", rarityEntry )
        rarityEntry.rarityBox:SetSize( self.panelWide-50-20, 5 )
        rarityEntry.rarityBox:SetPos( 0, rarityEntry:GetTall()-rarityEntry.rarityBox:GetTall() )
        rarityEntry.rarityBox:SetRarityName( v[1] or "" )
        rarityEntry.rarityBox:SetCornerRadius( 8 )
        rarityEntry.rarityBox:SetRoundedBoxDimensions( false, -11, false, 16 )

        rarityEntry.button = vgui.Create( "DButton", rarityEntry )
        rarityEntry.button:Dock( FILL )
        rarityEntry.button:SetText( "" )
        rarityEntry.button.Paint = function( self2, w, h ) end
        rarityEntry.button.DoClick = function()
            if( not BS_ConfigCopyTable.UNBOXING.NotificationRarities ) then
                BS_ConfigCopyTable.UNBOXING.NotificationRarities = {}
            end

            if( BS_ConfigCopyTable.UNBOXING.NotificationRarities[v[1]] ) then
                BS_ConfigCopyTable.UNBOXING.NotificationRarities[v[1]] = nil
            else
                BS_ConfigCopyTable.UNBOXING.NotificationRarities[v[1]] = true
            end

            BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
        end
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_unboxing_notifications", PANEL, "DPanel" )