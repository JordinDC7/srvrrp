local PANEL = {}

function PANEL:Init()

end

function PANEL:CreatePopup( text )
    if( IsValid( self.popup ) ) then return end

    local margin = 25

    self.popup = vgui.Create( "DPanel", self )
    self.popup:SetSize( self.panelWide-(2*margin), 50 )
    self.popup:SetPos( margin, ScrH()*0.65-40 )
    self.popup:MoveTo( margin, ScrH()*0.65-40-margin-self.popup:GetTall(), 0.2 )
    local yBound = (ScrH()/2)-(ScrH()*0.65/2)
    self.popup.Paint = function( self2, w, h )
        local x, y = self2:LocalToScreen( 0, 0 )

        BRICKS_SERVER.BSHADOWS.BeginShadow( 0, yBound, ScrW(), yBound+(ScrH()*0.65) )
        draw.RoundedBox( 5, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )			
        BRICKS_SERVER.BSHADOWS.EndShadow( 1, 2, 2, 255, 0, 0, false )
    
        draw.SimpleText( text, "BRICKS_SERVER_Font23", 15, h/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    end

    return self.popup
end

function PANEL:SettingChanged()
    if( not self.roleChanged ) then
        self.roleChanged = true
        local popup = self:CreatePopup( BRICKS_SERVER.Func.L( "gangUnsavedChanges" ) )

        if( IsValid( popup ) ) then
            surface.SetFont( "BRICKS_SERVER_Font23" )
            local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "gangSaveChanges" ) )

            local margin = 8

            local saveChanges = vgui.Create( "DButton", popup )
            saveChanges:Dock( RIGHT )
            saveChanges:DockMargin( 0, margin, margin, margin )
            saveChanges:SetWide( textX+10 )
            saveChanges:SetText( "" )
            local alpha = 0
            saveChanges.Paint = function( self2, w, h )
                if( self2:IsDown() ) then
                    alpha = 0
                elseif( self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 255 )
                else
                    alpha = math.Clamp( alpha-10, 0, 255 )
                end

                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )

                surface.SetAlphaMultiplier( alpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )		
                surface.SetAlphaMultiplier( 1 )
            
                draw.SimpleText( BRICKS_SERVER.Func.L( "gangSaveChanges" ), "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            saveChanges.DoClick = function()
                local rolesData = util.Compress( util.TableToJSON( self.rolesTableCopy ) )
                net.Start( "BRS.Net.SaveGangRoles" )
                    net.WriteData( rolesData, string.len( rolesData ) )
                net.SendToServer()
            end

            surface.SetFont( "BRICKS_SERVER_Font23" )
            local text2X, text2Y = surface.GetTextSize( BRICKS_SERVER.Func.L( "gangReset" ) )

            local resetChanges = vgui.Create( "DButton", popup )
            resetChanges:Dock( RIGHT )
            resetChanges:DockMargin( margin, 10, margin, margin )
            resetChanges:SetWide( text2X+10 )
            resetChanges:SetText( "" )
            local alpha = 0
            local whiteColor = BRICKS_SERVER.Func.GetTheme( 6 )
            resetChanges.Paint = function( self2, w, h )
                if( self2:IsDown() ) then
                    alpha = 0
                elseif( self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 255 )
                else
                    alpha = math.Clamp( alpha-10, 0, 255 )
                end

                surface.SetAlphaMultiplier( alpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )		
                surface.SetAlphaMultiplier( 1 )
            
                draw.SimpleText( BRICKS_SERVER.Func.L( "gangReset" ), "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            resetChanges.DoClick = function()
                popup:MoveTo( 25, ScrH()*0.65-40, 0.2, 0, -1, function()
                    if( IsValid( popup ) ) then
                        popup:Remove()
                    end
                end )

                self.roleChanged = false
                self.rolesTableCopy = table.Copy( ((BRICKS_SERVER_GANGS or {})[LocalPlayer():GetGangID()] or {}).Roles or {} )

                self.RefreshPanel()
            end
        end
    end
end

function PANEL:FillPanel()
    self:Clear()

    self.sheet = vgui.Create( "bricks_server_colsheet_ranks", self )
    self.sheet:Dock( FILL )
    self.sheet:DockMargin( 10, 10, 10, 10 )

    self.roleChanged = false
    self.rolesTableCopy = table.Copy( ((BRICKS_SERVER_GANGS or {})[LocalPlayer():GetGangID()] or {}).Roles or {} )

    function self.RefreshPanel()
        if( IsValid( self.sheet.ActiveButton ) ) then
            self.previousSheet = self.sheet.ActiveButton.label
        end

        self.sheet:ClearSheets()

        local addNewRole = vgui.Create( "DPanel", self.sheet.Navigation )
        addNewRole:Dock( TOP )
        addNewRole:DockMargin( 0, 0, 0, 0 )
        addNewRole:SetTall( 35 )
        addNewRole.Paint = function( self2, w, h )
            draw.SimpleText( BRICKS_SERVER.Func.L( "gangRanksUpper" ), "BRICKS_SERVER_Font17", 10, h/2, BRICKS_SERVER.Func.GetTheme( 5 ), 0, TEXT_ALIGN_CENTER )
        end

        local addNewRoleButton = vgui.Create( "DButton", addNewRole )
        addNewRoleButton:Dock( RIGHT )
        addNewRoleButton:DockMargin( 0, 0, 0, 0 )
        addNewRoleButton:SetWide( addNewRole:GetTall() )
        addNewRoleButton:SetText( "" )
        local addMat = Material( "bricks_server/add_circle.png" )
        addNewRoleButton.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 4 ) )
            else
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
            end
			surface.SetMaterial( addMat )
			local iconSize = 16
			surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        addNewRoleButton.DoClick = function()
            if( table.Count( self.rolesTableCopy ) >= BRICKS_SERVER.DEVCONFIG.GangRankLimit ) then
                notification.AddLegacy( BRICKS_SERVER.Func.L( "gangRankLimit", BRICKS_SERVER.DEVCONFIG.GangRankLimit ), 1, 5 )
                return
            end

            if( not self.roleChanged ) then
                self:SettingChanged()
            end

            table.insert( self.rolesTableCopy, { BRICKS_SERVER.Func.L( "gangNewRank" ), Color( 189, 195, 199 ), {} } )

            self.RefreshPanel()
        end

        local draggingButton, dragTarget

        local dropSections, buttons = {}, {}
        local function addDropSection( topMargin, belowRank )
            local dropSection = vgui.Create( "DPanel", self.sheet.Navigation )
            dropSection:Dock( TOP )
            dropSection:DockMargin( 5, (topMargin or 0), 5, 0 )
            dropSection:SetTall( 0 )
            dropSection.belowRank = belowRank
            dropSection.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
            end
            dropSection.Think = function( self2 )
                if( self2:GetTall() != 0 ) then
                    if( not IsValid( draggingButton ) or dragTarget != self2 ) then
                        self2:SetTall( 0 )
                    else
                        local aboveButton, belowButton = buttons[belowRank], buttons[belowRank+1]

                        local aboveHovered = false
                        if( IsValid( aboveButton ) and aboveButton:IsHovered() ) then
                            aboveHovered = true
                        end

                        local belowHovered = false
                        if( IsValid( belowButton ) and belowButton:IsHovered() ) then
                            belowHovered = true
                        end

                        if( not self2:IsHovered() and not aboveHovered and not belowHovered ) then
                            self2:SetTall( 0 )
                        end
                    end
                end
            end

            table.insert( dropSections, belowRank, dropSection )
        end

        addDropSection( 5, 0 )

        for k, v in ipairs( self.rolesTableCopy ) do
            local rolePanel = vgui.Create( "bricks_server_scrollpanel", self.sheet )
            rolePanel:Dock( FILL )
            rolePanel:DockMargin( 5, 0, 0, 0 )
            rolePanel.Paint = function( self2, w, h ) end
            rolePanel.AddHeader = function( text )
                local roleHeader = vgui.Create( "DPanel", rolePanel )
                roleHeader:Dock( TOP )
                roleHeader:DockMargin( 0, 0, 0, 5 )
                roleHeader:DockPadding( 10, 25, 10, 0 )
                roleHeader:SetTall( 25 )
                roleHeader.Paint = function( self2, w, h )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                    draw.SimpleText( string.upper( text ), "BRICKS_SERVER_Font17", 10, 5, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )
                end

                return roleHeader
            end

            local roleNameBack = rolePanel.AddHeader( BRICKS_SERVER.Func.L( "gangRankName" ) )

            local roleName = vgui.Create( "bricks_server_textentry", roleNameBack )
            roleName:Dock( TOP )
            roleName:DockMargin( 0, 0, 0, 0 )
            roleName:SetTall( 40 )
            roleName:SetValue( v[1] )
            roleName.backColor = BRICKS_SERVER.Func.GetTheme( 2 )
            roleName.OnChange = function()
                if( not self.roleChanged ) then
                    self:SettingChanged()
                end

                self.rolesTableCopy[k][1] = roleName:GetValue()
            end

            roleNameBack:SetTall( roleNameBack:GetTall()+50 )

            local roleColorBack = rolePanel.AddHeader( BRICKS_SERVER.Func.L( "gangRankColor" ) )

            local roleColor = vgui.Create( "DColorMixer", roleColorBack )
            roleColor:Dock( TOP )
            roleColor:DockMargin( 0, 0, 0, 0 )
            roleColor:SetTall( 100 )
            roleColor:SetPalette( false )
            roleColor:SetAlphaBar( false) 
            roleColor:SetWangs( true )
            roleColor:SetColor( v[2] )
            roleColor.ValueChanged = function()
                if( not self.roleChanged ) then
                    self:SettingChanged()
                end

                self.rolesTableCopy[k][2] = roleColor:GetColor()
            end

            roleColorBack:SetTall( roleColorBack:GetTall()+110 )

            local permissions = {}
            for key, val in pairs( BRICKS_SERVER.DEVCONFIG.GangPermissions ) do
                if( not permissions[val[2]] ) then
                    permissions[val[2]] = {}
                end

                permissions[val[2]][key] = val
            end


            for key, val in pairs( permissions ) do
                local rolePermHeaderBack = rolePanel.AddHeader( key .. " Permissions" )
                rolePermHeaderBack:SetTall( rolePermHeaderBack:GetTall()+5 )

                for key2, val2 in pairs( val ) do
                    local rolePermBack = vgui.Create( "DPanel", rolePermHeaderBack )
                    rolePermBack:Dock( TOP )
                    rolePermBack:DockMargin( 0, 0, 0, 5 )
                    rolePermBack:SetTall( 25 )
                    rolePermBack.Paint = function( self2, w, h )
                        draw.SimpleText( val2[1], "BRICKS_SERVER_Font20", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
                    end

                    local rolePermToggle = vgui.Create( "bricks_server_dcheckbox", rolePermBack )
                    rolePermToggle:Dock( RIGHT )
                    rolePermToggle:DockMargin( 0, (rolePermBack:GetTall()-20)/2, 0, (rolePermBack:GetTall()-20)/2 )
                    rolePermToggle:SetWide( 50 )
                    rolePermToggle:SetValue( v[3][key2] or false )
                    rolePermToggle:SetTitle( "" )
                    rolePermToggle.backgroundCol = BRICKS_SERVER.Func.GetTheme( 2 )
                    rolePermToggle.OnChange = function( value )
                        if( not self.roleChanged ) then
                            self:SettingChanged()
                        end
        
                        self.rolesTableCopy[k][3][key2] = value
                    end

                    rolePermHeaderBack:SetTall( rolePermHeaderBack:GetTall()+30 )
                end
            end

            local actionsBack = vgui.Create( "DPanel", rolePanel )
            actionsBack:Dock( TOP )
            actionsBack:DockMargin( 0, 0, 0, 5 )
            actionsBack:SetTall( 35 )
            actionsBack.Paint = function( self2, w, h ) end

            local actions = {
                [1] = {
                    Name = BRICKS_SERVER.Func.L( "gangClearPerms" ),
                    Color = Color( 127, 140, 141 ),
                    Func = function()
                        if( not self.roleChanged ) then
                            self:SettingChanged()
                        end
        
                        self.rolesTableCopy[k][3] = {}

                        self.RefreshPanel()
                    end
                },
                [2] = {
                    Name = BRICKS_SERVER.Func.L( "gangDeleteRank" ),
                    Color = Color( 231, 76, 60 ),
                    Func = function()
                        BRICKS_SERVER.Func.Query( BRICKS_SERVER.Func.L( "gangDeleteRankQuery" ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function() 
                            if( table.Count( self.rolesTableCopy ) <= 1 ) then
                                notification.AddLegacy( BRICKS_SERVER.Func.L( "gangRankLowLimit" ), 1, 5 )
                                return
                            end

                            if( not self.roleChanged ) then
                                self:SettingChanged()
                            end
                
                            table.remove( self.rolesTableCopy, k )
                
                            self.RefreshPanel()
                        end )
                    end
                }
            }

            for k, v in ipairs( actions ) do
                surface.SetFont( "BRICKS_SERVER_Font20" )
                local textX, textY = surface.GetTextSize( v.Name )

                local actionButton = vgui.Create( "DButton", actionsBack )
                actionButton:Dock( LEFT )
                actionButton:DockMargin( 0, 0, 5, 0 )
                actionButton:SetText( "" )
                actionButton:SetWide( textX+20 )
                local changeAlpha = 0
                actionButton.Paint = function( self2, w, h )
                    local backColor = v.Color
            
                    if( self2:IsDown() or self2.m_bSelected ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 5, 50 )
                    elseif( self2:IsHovered() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 5, 25 )
                    else
                        changeAlpha = math.Clamp( changeAlpha-10, 5, 50 )
                    end
            
                    surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, backColor or BRICKS_SERVER.Func.GetTheme( 4 ) )
                    surface.SetAlphaMultiplier( 1 )
            
                    draw.SimpleText( v.Name, "BRICKS_SERVER_Font20", 10, h/2, (backColor or BRICKS_SERVER.Func.GetTheme( 5 )), 0, TEXT_ALIGN_CENTER )
                end
                actionButton.DoClick = v.Func
            end

            local rankSheet = self.sheet:AddSheet( function() return self.rolesTableCopy[k][1] end, rolePanel, function() return self.rolesTableCopy[k][2] end )

            rankSheet.Button.rankID = k
            rankSheet.Button:Droppable( "droppableRank" )
            rankSheet.Button.Think = function( self2 ) 
                if( self2:IsDragging() ) then
                    if( draggingButton != self2 ) then
                        draggingButton = self2
                    end
                elseif( IsValid( draggingButton ) ) then
                    if( draggingButton == self2 ) then
                        draggingButton = nil
                    end

                    if( self2:IsHovered() ) then
                        local targetPanel

                        local w, h = 190, self2:GetTall()
                        local cursorX, cursorY = input.GetCursorPos()
                        local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )

                        local withinXBounds = false
                        if( cursorX > toScreenX and cursorX < toScreenX+w ) then
                            withinXBounds = true
                        end

                        if( withinXBounds ) then
                            if( cursorY > toScreenY and cursorY < toScreenY+(h/2) ) then
                                if( dropSections[k-1] and IsValid( dropSections[k-1] ) ) then
                                    targetPanel = dropSections[k-1]
                                end
                            elseif( cursorY > toScreenY+(h/2) and cursorY < toScreenY+h ) then
                                if( dropSections[k] and IsValid( dropSections[k] ) ) then
                                    targetPanel = dropSections[k]
                                end
                            end
                            
                            if( IsValid( targetPanel ) and IsValid( draggingButton ) and targetPanel:GetTall() == 0 and targetPanel.belowRank != draggingButton.rankID-1 and targetPanel.belowRank != draggingButton.rankID ) then
                                dragTarget = targetPanel
                                targetPanel:SetTall( 30 )
                            end
                        end
                    end
                end
            end
            rankSheet.Button.OnStopDragging = function( self2 )
                if( not IsValid( dragTarget ) ) then return end

                local dropPanelRank = self2.rankID
                local receiverRank = dragTarget.belowRank

                if( dropPanelRank == receiverRank ) then return end

                local newRankPos
                if( dropPanelRank != 1 and receiverRank == 0 ) then
                    newRankPos = 1
                elseif( receiverRank == #self.rolesTableCopy ) then
                    newRankPos = #self.rolesTableCopy
                elseif( receiverRank != 0 ) then
                    newRankPos = receiverRank+1
                end

                if( newRankPos ) then
                    local rankTable = table.Copy( self.rolesTableCopy[dropPanelRank] )

                    table.remove( self.rolesTableCopy, dropPanelRank )
                    table.insert( self.rolesTableCopy, newRankPos, rankTable )

                    if( not self.roleChanged ) then
                        self:SettingChanged()
                    end
        
                    self.RefreshPanel()
                end
            end

            table.insert( buttons, k, rankSheet.Button )

            addDropSection( 0, k )
        end

        if( self.previousSheet ) then
            self.sheet:SetActiveSheet( self.previousSheet )
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_roles", PANEL, "DPanel" )