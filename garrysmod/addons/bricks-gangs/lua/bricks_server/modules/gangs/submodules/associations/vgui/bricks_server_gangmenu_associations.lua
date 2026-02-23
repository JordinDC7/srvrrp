local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( gangTable )
    local panelTall = (ScrH()*0.65)-40

    local function CreateLoadingPopout()
        if( IsValid( self.popout ) ) then
            self.popout:Remove()
        end

        local popoutClose = vgui.Create( "DPanel", self )
        popoutClose:SetSize( self.panelWide, panelTall )
        popoutClose:SetAlpha( 0 )
        popoutClose:AlphaTo( 255, 0.2 )
        popoutClose.Paint = function( self2, w, h )
            surface.SetDrawColor( 0, 0, 0, 150 )
            surface.DrawRect( 0, 0, w, h )
            BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
        end

        local popoutWide, popoutTall = self.panelWide*0.65, panelTall*0.25

        self.popout = vgui.Create( "DPanel", self )
        self.popout:SetSize( 0, 0 )
        self.popout:SizeTo( popoutWide, popoutTall, 0.2 )
        self.popout.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        end
        self.popout.OnSizeChanged = function( self2 )
            self2:SetPos( (self.panelWide/2)-(self2:GetWide()/2), (panelTall/2)-(self2:GetTall()/2) )
        end
        self.popout.ClosePopout = function()
            if( IsValid( self.popout ) ) then
                self.popout:SizeTo( 0, 0, 0.2, 0, -1, function()
                    if( IsValid( self.popout ) ) then
                        self.popout:Remove()
                    end
                end )
            end

            popoutClose:AlphaTo( 0, 0.2, 0, function()
                if( IsValid( popoutClose ) ) then
                    popoutClose:Remove()
                end
            end )
        end

        local actionButton = vgui.Create( "DButton", self.popout )
        actionButton:Dock( BOTTOM )
        actionButton:SetTall( 40 )
        actionButton:SetText( "" )
        actionButton:DockMargin( 25, 0, 25, 25 )
        local changeAlpha = 0
        actionButton.Paint = function( self2, w, h )
            if( not self2:IsDown() and self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
    
            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
            surface.SetAlphaMultiplier( 1 )

            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
            
            draw.SimpleText( BRICKS_SERVER.Func.L( "cancel" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        actionButton.DoClick = self.popout.ClosePopout

        local loadingPanel = vgui.Create( "DPanel", self.popout )
        loadingPanel:Dock( FILL )
        loadingPanel:DockMargin( 25, 10, 25, 10 )
        local loadingIcon = Material( "materials/bricks_server/loading.png" )
        loadingPanel.Paint = function( self2, w, h )
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( loadingIcon )
            local size = 32
            surface.DrawTexturedRectRotated( w/2, h/2, size, size, -(CurTime() % 360 * 250) )
        
            draw.SimpleText( BRICKS_SERVER.Func.L( "loading" ), "BRICKS_SERVER_Font20", w/2, h/2+(size/2)+5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        end
    end

    local topBar = vgui.Create( "DPanel", self )
    topBar:Dock( TOP )
    topBar:DockMargin( 10, 10, 10, 5 )
    topBar:SetTall( 40 )
    topBar.Paint = function( self2, w, h ) end

    local searchBarBack = vgui.Create( "DPanel", topBar )
    searchBarBack:Dock( FILL )
    local search = Material( "materials/bricks_server/search.png" )
    local Alpha = 0
    local Alpha2 = 20
    local searchBar
    local color1 = BRICKS_SERVER.Func.GetTheme( 2 )
    searchBarBack.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        if( searchBar:IsEditing() ) then
            Alpha = math.Clamp( Alpha+5, 0, 100 )
            Alpha2 = math.Clamp( Alpha2+20, 20, 255 )
        else
            Alpha = math.Clamp( Alpha-5, 0, 100 )
            Alpha2 = math.Clamp( Alpha2-20, 20, 255 )
        end
        
        draw.RoundedBox( 5, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ) )
    
        surface.SetDrawColor( 255, 255, 255, Alpha2 )
        surface.SetMaterial(search)
        local size = 24
        surface.DrawTexturedRect( w-size-(h-size)/2, (h-size)/2, size, size )
    end
    
    searchBar = vgui.Create( "bricks_server_search", searchBarBack )
    searchBar:Dock( FILL )
    searchBar.OnEnter = function()
        CreateLoadingPopout()

        local canRequest, errorMsg, waitTime = BRICKS_SERVER.Func.RequestAssociationGangs( searchBar:GetValue() or "" )

        if( not canRequest ) then
            timer.Create( "BRS_ASSOCIATION_WAIT_" .. tostring( self ), (waitTime or 3), 1, function()
                local canRequest2, errorMsg2, waitTime2 = BRICKS_SERVER.Func.RequestAssociationGangs( searchBar:GetValue() or "" )
                if( not canRequest2 ) then
                    BRICKS_SERVER.Func.Message( errorMsg, BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ) )
                end
            end )
        end
    end

    local scrollPanel = vgui.Create( "bricks_server_scrollpanel", self )
    scrollPanel:Dock( FILL )
    scrollPanel:DockMargin( 10, 0, 10, 10 )
    scrollPanel.Paint = function( self, w, h ) end 

    BRICKS_SERVER.Func.RequestAssociationGangs( "" )

    function self.RefreshPanel( gangTables )
        scrollPanel:Clear()

        if( not gangTables or table.Count( gangTables or {} ) <= 0 ) then
            local text = BRICKS_SERVER.Func.L( "gangNoneFound" )
            surface.SetFont( "BRICKS_SERVER_Font25" )
            local textX, textY = surface.GetTextSize( text )
            textX, textY = textX+30, textY+20

            scrollPanel.Paint = function( self, w, h ) 
                draw.RoundedBox( 5, (w/2)-(textX/2), (h/2)-(textY/2), textX, textY, BRICKS_SERVER.Func.GetTheme( 3 ) )

                draw.SimpleText( text, "BRICKS_SERVER_Font23", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end 
        else
            scrollPanel.Paint = function( self, w, h ) end 
            
            for k, v in pairs( gangTables ) do
                local associationType = BRICKS_SERVER.Func.GangsGetAssociation( LocalPlayer():GetGangID(), k )

                local itemBack = vgui.Create( "DPanel", scrollPanel )
                itemBack:Dock( TOP )
                itemBack:DockMargin( 0, 0, 0, 5 )
                itemBack:SetTall( 100 )
                itemBack.Paint = function( self2, w, h )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                end

                if( LocalPlayer():GangHasPermission( "RequestAssociations" ) ) then
                    for key, val in pairs( BRICKS_SERVER.DEVCONFIG.GangAssociationTypes ) do
                        local associationButton = vgui.Create( "DButton", itemBack )
                        associationButton:Dock( RIGHT )
                        associationButton:DockMargin( 0, 10, 10, 10 )
                        associationButton:SetWide( itemBack:GetTall()-20 )
                        associationButton:SetText( "" )
                        local Alpha, iconAlpha = 0, 0
                        local iconMat
                        BRICKS_SERVER.Func.GetImage( val.Icon or "flag.png", function( mat ) 
                            iconMat = mat 
                        end )
                        local isAssociation = associationType == key
                        associationButton.Paint = function( self2, w, h )
                            if( self2:IsHovered() and not self2:IsDown() ) then
                                Alpha = math.Clamp( Alpha+5, 0, 50 )
                            else
                                Alpha = math.Clamp( Alpha-5, 0, 50 )
                            end
        
                            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        
                            surface.SetAlphaMultiplier( Alpha/255 )
                                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                            surface.SetAlphaMultiplier( 1 )

                            BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        
                            if( (self2:IsHovered() or isAssociation) and not self2:IsDown() ) then
                                iconAlpha = math.Clamp( iconAlpha+5, 20, 255 )
                            else
                                iconAlpha = math.Clamp( iconAlpha-5, 20, 255 )
                            end

                            surface.SetAlphaMultiplier( iconAlpha/255 )
                                if( iconMat ) then
                                    surface.SetDrawColor( (isAssociation and val.Color) or BRICKS_SERVER.Func.GetTheme( 6 ) )
                                    surface.SetMaterial( iconMat )
                                    local iconSize = 32
                                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                                end
        
                                draw.SimpleText( string.upper( key ), "BRICKS_SERVER_Font15", w/2, h-5, ((isAssociation and val.Color) or BRICKS_SERVER.Func.GetTheme( 6 )), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
                            surface.SetAlphaMultiplier( 1 )
                        end
                        associationButton.DoClick = function()
                            if( not isAssociation ) then
                                BRICKS_SERVER.Func.Query( val.Query, BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function() 
                                    net.Start( "BRS.Net.RequestGangAssociation" )
                                        net.WriteString( key )
                                        net.WriteUInt( k, 16 )
                                    net.SendToServer()
                                end )
                            else
                                BRICKS_SERVER.Func.Query( BRICKS_SERVER.Func.L( "gangDissolveAssociation" ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function() 
                                    net.Start( "BRS.Net.DissolveGangAssociation" )
                                        net.WriteUInt( k, 16 )
                                    net.SendToServer()
                                end )
                            end
                        end
                    end
                end

                local avatarBack = vgui.Create( "DPanel", itemBack )
                avatarBack:Dock( FILL )
                avatarBack:DockMargin( 15, 15, 15, 15 )
                local avatarBackSize = 70
                local avatarSize = (v.Icon and avatarBackSize*0.6) or 32
                avatarBack.Paint = function( self2, w, h )
                    local textStartPos = avatarBackSize+15

                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                    draw.NoTexture()
                    BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )
            
                    draw.SimpleText( (v.Name or BRICKS_SERVER.Func.L( "gangNone" )), "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
            
                    draw.SimpleText( BRICKS_SERVER.Func.L( "gangAssociationStatus", ((associationType and associationType) or BRICKS_SERVER.Func.L( "gangNeutral" )) ), "BRICKS_SERVER_Font17", textStartPos, h/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end

                local gangIcon = vgui.Create( "bricks_server_gangicon", avatarBack )
                gangIcon:SetSize( avatarSize, avatarSize )
                gangIcon:SetPos( (avatarBackSize-avatarSize)/2, (avatarBackSize-avatarSize)/2 )
                gangIcon:SetIconURL( v.Icon or "bricks_server/question.png" )
            end
        end

        if( IsValid( self.popout ) ) then
            self.popout.ClosePopout()
        end
    end

    hook.Add( "BRS.Hooks.RefreshGangAssociations", self, function( self, gangTables )
        if( IsValid( self ) ) then
            if( gangTables ) then
                self.RefreshPanel( gangTables )
            else
                BRICKS_SERVER.Func.RequestAssociationGangs( searchBar:GetValue() or "" )
            end
        else
            hook.Remove( "BRS.Hooks.RefreshGangAssociations", self )
        end
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_associations", PANEL, "DPanel" )