local PANEL = {}

function PANEL:Init()
    self.animMultiplier = 0
    self.leftBorderW = BRICKS_SERVER.Func.ScreenScale( 6 )

    local margin50 = BRICKS_SERVER.Func.ScreenScale( 50 )

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( margin50, margin50, margin50, margin50 )
end

function PANEL:FillPanel( gangTable )
    self.gangTable = table.Copy( gangTable )
    self:Refresh()

    hook.Add( "BRS.Hooks.RefreshGang", self, function( self, valuesChanged )
        if( not valuesChanged or not (valuesChanged["Name"] or valuesChanged["Icon"]) ) then return end

        self.gangTable = table.Copy( (BRICKS_SERVER_GANGS or {})[LocalPlayer():GetGangID()] or {} )

        self:Refresh()
    end )
end

function PANEL:CreateSettingPanel( parent, h, text, subText )
    local rounding = BRICKS_SERVER.Func.ScreenScale( 10 )
    local margin10 = BRICKS_SERVER.Func.ScreenScale( 10 )
    local margin25 = BRICKS_SERVER.Func.ScreenScale( 25 )

    local errorIconMat = Material( "bricks_server/step_error.png", "noclamp smooth" )
    local completedIconMat = Material( "bricks_server/step_completed.png", "noclamp smooth" )
    local iconSize = BRICKS_SERVER.Func.ScreenScale( 24 )

    surface.SetFont( "BRICKS_SERVER_Font22B" )
    local textW, textH = surface.GetTextSize( string.upper( text ) )

    surface.SetFont( "BRICKS_SERVER_Font20B" )
    local subTextW, subTextH = surface.GetTextSize( subText )

    local settingPanel = vgui.Create( "DPanel", parent )
    settingPanel:Dock( TOP )
    settingPanel:SetTall( h )
    settingPanel:DockMargin( 0, 0, 0, margin25 )
    settingPanel.leftW = BRICKS_SERVER.Func.ScreenScale( 50 )
    settingPanel.Paint = function( self2, w, h )
        draw.RoundedBox( rounding, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        draw.RoundedBox( rounding, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2, 200 ) )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, 100 ) )
        surface.DrawRect( self.leftBorderW, 0, self2.leftW, h )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 10 ) )
        surface.SetMaterial( self2.completed and completedIconMat or errorIconMat )
        surface.DrawTexturedRect( self.leftBorderW+self2.leftW/2-iconSize/2, h/2-iconSize/2, iconSize, iconSize )

        BRICKS_SERVER.Func.DrawPartialRoundedBox( rounding, 0, 0, 6, h, self2.completed and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, 2*self.leftBorderW, h )
    
        local leftMargin = self.leftBorderW+self2.leftW+margin25
        draw.SimpleText( string.upper( text ), "BRICKS_SERVER_Font22B", leftMargin, margin25, BRICKS_SERVER.Func.GetTheme( 5 ) )
        draw.SimpleText( subText, "BRICKS_SERVER_Font20B", leftMargin, margin25+textH, BRICKS_SERVER.Func.GetTheme( 6, 50 ) )
    end
    settingPanel.requirementEntries = {}
    settingPanel.AddRequirement = function( self2, requirementText, hasPassed, infoFunc )
        surface.SetFont( "BRS.Font.Bold20" )
        requirementText = string.upper( requirementText )

        local tickIconMat = Material( "bricks_server/accept_16.png" )
        local crossIconMat = Material( "bricks_server/decline_16.png" )
        local iconSize = BRICKS_SERVER.Func.ScreenScale( 16 )
    
        local requirementEntry = vgui.Create( "DPanel", self2.requirementsPanel )
        requirementEntry:Dock( LEFT )
        requirementEntry:SetWide( self2.requirementsPanel:GetTall()+surface.GetTextSize( requirementText )+margin10+(infoFunc and self2.requirementsPanel:GetTall() or 0) )
        requirementEntry:DockMargin( 0, 0, margin10, 0 )
        requirementEntry.hasPassed = hasPassed()
        requirementEntry.Paint = function( self2, w, h )
            local highlightColor = self2.hasPassed and BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen or BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed

            draw.RoundedBox( 5, 0, 0, w, h, Color( highlightColor.r, highlightColor.g, highlightColor.b, 25 ) )

            surface.SetDrawColor( highlightColor )
            surface.SetMaterial( self2.hasPassed and tickIconMat or crossIconMat )
            surface.DrawTexturedRect( h/2-iconSize/2, h/2-iconSize/2, iconSize, iconSize )

            draw.SimpleText( requirementText, "BRS.Font.Bold20", w-margin10-(infoFunc and h or 0), h/2-1, highlightColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end

        if( infoFunc ) then
            local infoButton = vgui.Create( "DButton", requirementEntry )
            infoButton:Dock( RIGHT )
            infoButton:SetWide( self2.requirementsPanel:GetTall() )
            infoButton:SetText( "" )
            infoButton.Paint = function( self2, w, h )
                draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 6, 5+(self2:IsHovered() and 5 or 0) ), false, true, false, true )
        
                draw.SimpleText( "!", "BRICKS_SERVER_Font30B", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 50 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            infoButton.DoClick = infoFunc
        end

        local reqWide = self2.requirementsPanel:GetWide()
        self2.requirementsPanel:SetWide( reqWide+(reqWide != 0 and margin10 or 0)+requirementEntry:GetWide() )

        table.insert( self2.requirementEntries, { requirementEntry, hasPassed } )
    end
    settingPanel.UpdateCompletion = function( self2 )
        local requirementsCompleted = true
        for k, v in ipairs( self2.requirementEntries ) do
            local passed = v[2]()
            v[1].hasPassed = passed

            if( passed ) then continue end
            requirementsCompleted = false
        end

        self2.completed = self2.isCompletedFunc( requirementsCompleted )
    end

    settingPanel.requirementsPanel = vgui.Create( "Panel", settingPanel )
    settingPanel.requirementsPanel:SetTall( BRICKS_SERVER.Func.ScreenScale( 30 ) )
    settingPanel.requirementsPanel:SetPos( self.leftBorderW+settingPanel.leftW+margin25+subTextW+margin25, margin25+(textH+subTextH)/2-settingPanel.requirementsPanel:GetTall()/2 )

    table.insert( self.settingPanels, settingPanel )
    return settingPanel
end

function PANEL:Refresh()
    self.settingsTable = {
        name = self.gangTable.Name,
        icon = self.gangTable.Icon,
        colour = self.gangTable.Colour
    }

    self.settingPanels = {}
    self.settingsChanged = false

    self.scrollPanel:Clear()

    local rounding = BRICKS_SERVER.Func.ScreenScale( 10 )
    local margin5 = BRICKS_SERVER.Func.ScreenScale( 5 )
    local margin10 = BRICKS_SERVER.Func.ScreenScale( 10 )
    local margin25 = BRICKS_SERVER.Func.ScreenScale( 25 )
    local margin50 = BRICKS_SERVER.Func.ScreenScale( 50 )

    -- First Step
    local firstPanel = self:CreateSettingPanel( self.scrollPanel, BRICKS_SERVER.Func.ScreenScale( 150 ), "Gang Name", "A cool name for your new gang." )

    local gangNameEntry = vgui.Create( "bricks_server_textentry", firstPanel )
    gangNameEntry:SetSize( (self.panelWide-2*margin50)*0.3, BRICKS_SERVER.Func.ScreenScale( 40 ) )
    gangNameEntry:SetPos( self.leftBorderW+firstPanel.leftW+margin25, firstPanel:GetTall()-margin25-gangNameEntry:GetTall() )
    gangNameEntry:SetFont( "BRICKS_SERVER_Font22" )
    gangNameEntry.backColor = BRICKS_SERVER.Func.GetTheme( 0, 100 )
    gangNameEntry:SetValue( self.settingsTable.name )
    gangNameEntry.OnChange = function()
        self.settingsTable.name = string.Trim( gangNameEntry:GetValue() )
        firstPanel:UpdateCompletion()
        self:SettingChanged()
    end

    firstPanel:AddRequirement( "+" .. BRICKS_SERVER.DEVCONFIG.GangNameCharMin .. " Length", function() 
        return string.len( self.settingsTable.name ) >= BRICKS_SERVER.DEVCONFIG.GangNameCharMin
    end )

    firstPanel:AddRequirement( "< " .. BRICKS_SERVER.DEVCONFIG.GangNameCharMax .. " Length", function() 
        return string.len( self.settingsTable.name ) <= BRICKS_SERVER.DEVCONFIG.GangNameCharMax
    end )

    firstPanel:AddRequirement( "Only Letters/Numbers", function() 
        return not string.match( string.Replace( self.settingsTable.name, " ", "" ), "[%W]" )
    end )

    firstPanel.isCompletedFunc = function( requirementsPassed )
        return requirementsPassed
    end

    firstPanel:UpdateCompletion()

    -- Second Step
    local secondPanel = self:CreateSettingPanel( self.scrollPanel, BRICKS_SERVER.Func.ScreenScale( 185 ), "Gang Icon", "An icon used when displaying your gang." )

    secondPanel.bottom = vgui.Create( "Panel", secondPanel )
    secondPanel.bottom:Dock( BOTTOM )
    secondPanel.bottom:SetTall( BRICKS_SERVER.Func.ScreenScale( 75 ) )
    secondPanel.bottom:DockMargin( self.leftBorderW+secondPanel.leftW+margin25, 0, margin25, margin25 )

    local unselectedIconMat = Material( "bricks_server/icon_unselected.png" )
    local loadingNewIcon, newGangIconMat = false

    local currentIconDisplay = vgui.Create( "Panel", secondPanel.bottom )
    currentIconDisplay:Dock( LEFT )
    currentIconDisplay:SetWide( BRICKS_SERVER.Func.ScreenScale( 75 ) )
    currentIconDisplay.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, 100 ) )

        if( loadingNewIcon ) then
            if( CurTime() >= (self2.loadingStart or 0)+1.5 ) then
                self2.loadingStart = CurTime()
            end

            local percent = math.Clamp( (CurTime()-self2.loadingStart)/1.5, 0, 1 )

            local entrySize, entryMargin = BRICKS_SERVER.Func.ScreenScale( 10 ), margin5
            local yOffset = margin5
            local totalEntryW = 3*(entrySize+entryMargin)-entryMargin
            for i = 1, 3 do
                local min = (i-1)*(1/3)
                local isActive = percent >= min and percent < i*(1/3)
                local entryPercent = math.Clamp( (percent-min)*3, 0, 1 )
                local yAdjustment = isActive and (entryPercent < 0.5 and (entryPercent/0.5)*yOffset or yOffset-((entryPercent-0.5)/0.5*yOffset)) or 0

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                surface.DrawRect( w/2-totalEntryW/2+(i-1)*(entryMargin+entrySize), h/2-entrySize/2-yAdjustment, entrySize, entrySize )
            end

            return
        end
        
        local unselectedIconSize = newGangIconMat and h*0.75 or BRICKS_SERVER.Func.ScreenScale( 64 )

        surface.SetDrawColor( newGangIconMat and BRICKS_SERVER.DEVCONFIG.BaseThemes.White or BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.SetMaterial( newGangIconMat or unselectedIconMat )
        surface.DrawTexturedRect( w/2-unselectedIconSize/2, h/2-unselectedIconSize/2, unselectedIconSize, unselectedIconSize )
    end

    local presetsSpacer = vgui.Create( "Panel", secondPanel.bottom )
    presetsSpacer:Dock( LEFT )
    presetsSpacer:SetWide( 4 )
    presetsSpacer:DockMargin( margin50, margin10, margin50, margin10 )
    presetsSpacer.Paint = function( self2, w, h )
        draw.RoundedBox( w/2, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, 100 ) )
    end

    surface.SetFont( "BRICKS_SERVER_Font20B" )

    local presetsHeader = vgui.Create( "Panel", secondPanel.bottom )
    presetsHeader:Dock( LEFT )
    presetsHeader:SetWide( surface.GetTextSize( "Default icons" ) )
    presetsHeader.Paint = function( self2, w, h )
        draw.SimpleText( "PRESETS", "BRICKS_SERVER_Font22B", 0, h/2+2, BRICKS_SERVER.Func.GetTheme( 4 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( "Default icons", "BRICKS_SERVER_Font20B", 0, h/2-2, BRICKS_SERVER.Func.GetTheme( 6, 50 ), 0, 0 )
    end

    local presetsPanel = vgui.Create( "Panel", secondPanel.bottom )
    presetsPanel:Dock( LEFT )
    presetsPanel:SetTall( secondPanel.bottom:GetTall()-2*margin5 )
    presetsPanel:DockMargin( margin25, margin5, 0, margin5 )

    local customUrlEntry

    for k, v in ipairs( BRICKS_SERVER.DEVCONFIG.PresetGangIcons ) do
        local presetIconMat = Material( v, "noclamp smooth" )

        if( self.settingsTable.icon == v ) then
            newGangIconMat = presetIconMat
        end
    
        local currentIconDisplay = vgui.Create( "DButton", presetsPanel )
        currentIconDisplay:Dock( LEFT )
        currentIconDisplay:SetWide( presetsPanel:GetTall() )
        currentIconDisplay:DockMargin( 0, 0, margin5, 0 )
        currentIconDisplay:SetText( "" )
        currentIconDisplay.Paint = function( self2, w, h )
            local isSelected = v == self.settingsTable.icon
            self2.hoverAlpha = math.Clamp( (self2.hoverAlpha or 0)+(self2:IsHovered() and 5 or -5), 0, 100 )

            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, 100+(isSelected and 50 or self2.hoverAlpha) ) )

            local borderH = 3
            BRICKS_SERVER.Func.DrawPartialRoundedBox( 5, 0, h-borderH, w, borderH, BRICKS_SERVER.Func.GetTheme( 5, isSelected and 255 or self2.hoverAlpha ), w, 10, 0, h-10 )

            local iconSize = h*0.75
    
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( presetIconMat )
            surface.DrawTexturedRect( w/2-iconSize/2, h/2-iconSize/2, iconSize, iconSize )
        end
        currentIconDisplay.DoClick = function()
            if( self.settingsTable.icon == v ) then
                self.settingsTable.icon = ""
                newGangIconMat = nil
            else
                self.settingsTable.icon = v
                newGangIconMat = presetIconMat
                loadingNewIcon = false
                customUrlEntry:SetValue( "" )
            end

            secondPanel:UpdateCompletion()
            self:SettingChanged()
        end
    end

    presetsPanel:SetWide( #BRICKS_SERVER.DEVCONFIG.PresetGangIcons*(presetsPanel:GetTall()+margin5)-margin5 )

    local customSpacer = vgui.Create( "Panel", secondPanel.bottom )
    customSpacer:Dock( LEFT )
    customSpacer:SetWide( 4 )
    customSpacer:DockMargin( margin50, margin10, margin50, margin10 )
    customSpacer.Paint = function( self2, w, h )
        draw.RoundedBox( w/2, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0, 100 ) )
    end
    
    local customHeader = vgui.Create( "Panel", secondPanel.bottom )
    customHeader:Dock( LEFT )
    customHeader:SetWide( surface.GetTextSize( "A custom icons" ) )
    customHeader.Paint = function( self2, w, h )
        draw.SimpleText( "CUSTOM", "BRICKS_SERVER_Font22B", 0, h/2+2, BRICKS_SERVER.Func.GetTheme( 4 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( "A custom icon", "BRICKS_SERVER_Font20B", 0, h/2-2, BRICKS_SERVER.Func.GetTheme( 6, 50 ), 0, 0 )
    end

    local customEntryBar = vgui.Create( "Panel", secondPanel.bottom )
    customEntryBar:Dock( LEFT )
    customEntryBar:SetWide( ScrW()*0.1 )
    local verticalMargin = (secondPanel.bottom:GetTall()-BRICKS_SERVER.Func.ScreenScale( 40 ))/2
    customEntryBar:DockMargin( margin25, verticalMargin, 0, verticalMargin )
    customEntryBar.Paint = function( self2, w, h )
        if( not IsValid( customUrlEntry ) or customUrlEntry:GetValue() == "" or customUrlEntry:GetValue() == self.settingsTable.icon ) then return end

        local oldClipping = DisableClipping( true )
        draw.SimpleText( "PRESS ENTER TO SAVE", "BRICKS_SERVER_Font20B", w/2, h, BRICKS_SERVER.Func.GetTheme( 6, 50 ), TEXT_ALIGN_CENTER, 0 )
        DisableClipping( oldClipping )
    end

    customUrlEntry = vgui.Create( "bricks_server_textentry", customEntryBar )
    customUrlEntry:Dock( BOTTOM )
    customUrlEntry:SetTall( BRICKS_SERVER.Func.ScreenScale( 40 ) )
    customUrlEntry:DockMargin( 0, 0, 0, 0 )
    customUrlEntry:SetFont( "BRICKS_SERVER_Font22" )
    customUrlEntry.backColor = BRICKS_SERVER.Func.GetTheme( 0, 100 )
    customUrlEntry.UpdateIcon = function( self2 )
        loadingNewIcon = true
        newGangIconMat = nil

        BRICKS_SERVER.Func.GetImage( self.settingsTable.icon, function( mat )
            if( self.settingsTable.icon != self.settingsTable.icon ) then return end
            newGangIconMat = mat 
            loadingNewIcon = false
        end )
    end
    customUrlEntry.OnEnter = function( self2 )
        self.settingsTable.icon = self2:GetValue()

        secondPanel:UpdateCompletion()
        self:SettingChanged()

        self2:UpdateIcon()
    end

    if( not newGangIconMat ) then
        customUrlEntry:SetValue( self.settingsTable.icon )
        customUrlEntry:UpdateIcon()
    end

    local validImageEndings = { ".png", ".jpg", ".jpeg" }
    secondPanel:AddRequirement( ".png, .jpg or .jpeg", function() 
        if( table.HasValue( BRICKS_SERVER.DEVCONFIG.PresetGangIcons, self.settingsTable.icon ) ) then return true end

        for _, v in ipairs( validImageEndings ) do
            if( string.EndsWith( self.settingsTable.icon, v ) ) then return true end
        end

        return false
    end )

    -- BRICKS_SERVER.DEVCONFIG.GangURLWhitelist
    -- Show whitelsited urls when hovering?
    secondPanel:AddRequirement( "Whitelisted URL", function() 
        if( table.HasValue( BRICKS_SERVER.DEVCONFIG.PresetGangIcons, self.settingsTable.icon ) ) then return true end

        for _, v in ipairs( BRICKS_SERVER.DEVCONFIG.GangURLWhitelist ) do
            if( string.StartWith( self.settingsTable.icon, v ) ) then return true end
        end

        return false
    end, function( self2 )
        if( IsValid( self2.hoverPopup ) ) then
            self2.hoverPopup:Remove()
        end

        local x, y = self2:LocalToScreen( 0, 0 )

        self2.hoverPopup = vgui.Create( "DFrame" )
        self2.hoverPopup:SetSize( 300, 500 )
        self2.hoverPopup:Center()
        self2.hoverPopup:MakePopup()
        self2.hoverPopup:SetTitle( "" )
        self2.hoverPopup:DockPadding( 25, 50, 0, 0 )

        for k, v in ipairs( BRICKS_SERVER.DEVCONFIG.GangURLWhitelist ) do
            local urlEntry = vgui.Create( "DLabel", self2.hoverPopup )
            urlEntry:Dock( TOP )
            urlEntry:SetText( v )
            urlEntry:SetFont( "Trebuchet24" )
            urlEntry:SizeToContentsY()
        end
    end )

    secondPanel.isCompletedFunc = function( requirementsPassed )
        return requirementsPassed
    end

    secondPanel:UpdateCompletion()

    -- Third Step
    -- local thirdPanel = self:CreateSettingPanel( self.scrollPanel, BRICKS_SERVER.Func.ScreenScale( 160 ), "Gang Colour", "The colour of your gang, displayed in various places." )

    -- thirdPanel.bottom = vgui.Create( "Panel", thirdPanel )
    -- thirdPanel.bottom:Dock( BOTTOM )
    -- thirdPanel.bottom:SetTall( BRICKS_SERVER.Func.ScreenScale( 50 ) )
    -- thirdPanel.bottom:DockMargin( self.leftBorderW+thirdPanel.leftW+margin25, 0, margin25, margin25 )

    -- local colourOptions = { 
    --     Color( 244, 67, 54 ),
    --     Color( 233, 30, 99 ),
    --     Color( 156, 39, 176 ),
    --     Color( 103, 58, 183 ),
    --     Color( 63, 81, 181 ),
    --     Color( 33, 150, 243 ),
    --     Color( 3, 169, 244 ),
    --     Color( 0, 188, 212 ),
    --     Color( 0, 150, 136 ),
    --     Color( 76, 175, 80 ),
    --     Color( 139, 195, 74 ),
    --     Color( 205, 220, 57 ),
    --     Color( 255, 235, 59 ),
    --     Color( 255, 193, 7 ),
    --     Color( 255, 152, 0 ),
    --     Color( 255, 87, 34 )
    -- }

    -- local colourEntrySize = math.floor( (thirdPanel.bottom:GetTall()-margin5)/2 )

    -- local colourGrid = vgui.Create( "DIconLayout", thirdPanel.bottom )
    -- colourGrid:Dock( LEFT )
    -- colourGrid:SetWide( (math.ceil( #colourOptions/2 )*(colourEntrySize+margin5))-margin5 )
    -- colourGrid:SetSpaceX( margin5 )
    -- colourGrid:SetSpaceY( margin5 )
    
    -- local whiteColour = BRICKS_SERVER.DEVCONFIG.BaseThemes.White
    -- local circleBorder = BRICKS_SERVER.Func.ScreenScale( 2 )
    -- for k, v in ipairs( colourOptions ) do
    --     local colourEntry = vgui.Create( "DButton", colourGrid )
    --     colourEntry:SetSize( colourEntrySize, colourEntrySize )
    --     colourEntry:SetText( "" )
    --     colourEntry.Paint = function( self2, w, h )
    --         self2.hoverAlpha = math.Clamp( (self2.hoverAlpha or 0)+(self2:IsHovered() and 5 or -5), 0, 100 )

    --         local isSelected = v == self.settingsTable.colour
    --         if( isSelected or self2.hoverAlpha != 0 ) then
    --             local oldClipping = DisableClipping( true )
    --             surface.SetAlphaMultiplier( isSelected and 1 or self2.hoverAlpha/255 )
    --             BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2+circleBorder, whiteColour )
    --             surface.SetAlphaMultiplier( 1 )
    --             DisableClipping( oldClipping )
    --         end

    --         BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2, v )
    --     end
    --     colourEntry.DoClick = function()
    --         if( self.settingsTable.colour == v ) then
    --             self.settingsTable.colour = nil
    --         else
    --             self.settingsTable.colour = v
    --         end

    --         thirdPanel:UpdateCompletion()
    --         self:SettingChanged()
    --     end
    -- end

    -- thirdPanel.isCompletedFunc = function( requirementsPassed )
    --     return self.settingsTable.colour != nil
    -- end

    -- thirdPanel:UpdateCompletion()
end

function PANEL:SettingChanged()
    if( self.settingsChanged ) then
        local shouldRemove = true
        if( self.settingsTable.name != self.gangTable.Name ) then
            shouldRemove = false
        elseif( self.settingsTable.icon != self.gangTable.Icon ) then
            shouldRemove = false
        end

        if( shouldRemove and IsValid( self.popup ) ) then
            self.settingsChanged = false
            self.popup:Close()
        end

        return 
    end

    self.settingsChanged = true

    if( IsValid( self.popup ) ) then return end

    local margin25 = BRICKS_SERVER.Func.ScreenScale( 25 )

    local warningIconMat = Material( "bricks_server/gang_warning.png", "noclamp smooth" )
    local warningIconSize = BRICKS_SERVER.Func.ScreenScale( 64 )

    local popup = vgui.Create( "DPanel", self )
    popup:SetSize( self.panelWide-(2*margin25), BRICKS_SERVER.Func.ScreenScale( 100 ) )
    popup:SetPos( margin25, ScrH()*0.65-40 )
    popup:MoveTo( margin25, ScrH()*0.65-40-margin25-popup:GetTall(), 0.2 )
    local yBound = (ScrH()/2)-(ScrH()*0.65/2)
    popup.Paint = function( self2, w, h )
        local x, y = self2:LocalToScreen( 0, 0 )

        BRICKS_SERVER.BSHADOWS.BeginShadow( 0, yBound, ScrW(), yBound+(ScrH()*0.65) )
        draw.RoundedBox( 8, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        BRICKS_SERVER.BSHADOWS.EndShadow( 1, 1, 1, 255, 0, 0, false )

        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 50 ) )
    
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 15 ) )
        surface.SetMaterial( warningIconMat )
        surface.DrawTexturedRect( self.leftBorderW+h/2-warningIconSize/2, h/2-warningIconSize/2, warningIconSize, warningIconSize )

        draw.SimpleText( "WARNING", "BRICKS_SERVER_Font30B", h, h/2+BRICKS_SERVER.Func.ScreenScale( 2 ), BRICKS_SERVER.Func.GetTheme( 5 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( BRICKS_SERVER.Func.L( "gangUnsavedChanges" ), "BRICKS_SERVER_Font21", h, h/2-BRICKS_SERVER.Func.ScreenScale( 2 ), BRICKS_SERVER.Func.GetTheme( 6, 100 ), 0, 0 )
    end
    popup.Close = function( self2 )
        self2:MoveTo( margin25, ScrH()*0.65-40, 0.2, 0, -1, function()
            self2:Remove()
        end )
    end

    self.popup = popup

    local gradient = vgui.Create( "bricks_server_gradientanim", popup )
    gradient:SetPos( 0, 0 )
    gradient:SetSize( self.leftBorderW, popup:GetTall() )
    gradient:SetDirection( 1 )
    gradient:SetCornerRadius( rounding )
    gradient:SetRoundedBoxDimensions( false, false, 20, false )
    gradient:TasteTheRainbow()
    gradient:StartAnim()

    surface.SetFont( "BRICKS_SERVER_Font22B" )
    local text2X, text2Y = surface.GetTextSize( BRICKS_SERVER.Func.L( "gangReset" ) )

    local resetChanges = vgui.Create( "DButton", popup )
    resetChanges:Dock( RIGHT )
    resetChanges:DockMargin( 0, margin25, margin25, margin25 )
    resetChanges:SetWide( text2X+BRICKS_SERVER.Func.ScreenScale( 25 ) )
    resetChanges:SetText( "" )
    local alpha = 0
    local whiteColor = BRICKS_SERVER.Func.GetTheme( 6 )
    resetChanges.Paint = function( self2, w, h )
        self2.hoverAlpha = math.Clamp( (self2.hoverAlpha or 0)+(self2:IsHovered() and 5 or -5), 0, 100 )

        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 25+self2.hoverAlpha ) )
    
        draw.SimpleText( BRICKS_SERVER.Func.L( "gangReset" ), "BRICKS_SERVER_Font22B", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6, 25 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    resetChanges.DoClick = function()
        popup:Close()
        self:Refresh()
    end

    surface.SetFont( "BRICKS_SERVER_Font22B" )
    local textX = surface.GetTextSize( BRICKS_SERVER.Func.L( "gangSaveChanges" ) )

    local saveIconMat = Material( "bricks_server/gang_save.png", "noclamp smooth" )
    local saveIconSize = BRICKS_SERVER.Func.ScreenScale( 24 )
    
    local contentMargin = BRICKS_SERVER.Func.ScreenScale( 10 )

    local saveChanges = vgui.Create( "DButton", popup )
    saveChanges:Dock( RIGHT )
    saveChanges:DockMargin( 0, margin25, margin25, margin25 )
    saveChanges:SetWide( textX+saveIconSize+2*contentMargin+BRICKS_SERVER.Func.ScreenScale( 10 ) )
    saveChanges:SetText( "" )
    local alpha = 0
    saveChanges.Paint = function( self2, w, h )
        self2.hoverAlpha = math.Clamp( (self2.hoverAlpha or 0)+(self2:IsHovered() and 5 or -5), 0, 100 )

        self2.isPossible = true
        for k, v in ipairs( self.settingPanels ) do
            if( not v.completed ) then 
                self2.isPossible = false
                break
            end
        end

        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 50+self2.hoverAlpha ) )

        local edgeH = 4
        BRICKS_SERVER.Func.DrawPartialRoundedBox( 8, 0, h-edgeH, w, edgeH, self2.isPossible and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, w, 2*edgeH, 0, h-2*edgeH )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 50 ) )
        surface.SetMaterial( saveIconMat )
        surface.DrawTexturedRect( contentMargin, h/2-saveIconSize/2, saveIconSize, saveIconSize )
    
        draw.SimpleText( BRICKS_SERVER.Func.L( "gangSaveChanges" ), "BRICKS_SERVER_Font22B", w-contentMargin, h/2-1, BRICKS_SERVER.Func.GetTheme( 6, 50 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end
    saveChanges.DoClick = function( self2 )
        if( not self2.isPossible ) then return end

        popup:Close()

        net.Start( "BRS.Net.SaveGangSettings" )
            net.WriteString( self.settingsTable.name )
            net.WriteString( self.settingsTable.icon )
            -- net.WriteColor( self.settingsTable.colour )
        net.SendToServer()
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_settings", PANEL, "DPanel" )