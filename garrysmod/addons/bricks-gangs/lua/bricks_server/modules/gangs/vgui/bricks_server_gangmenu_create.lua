local PANEL = {}

function PANEL:Init()
    self.animMultiplier = 0
    self.leftBorderW = BRICKS_SERVER.Func.ScreenScale( 6 )
    self.currentStep = 1
end

function PANEL:CreateStepPanel( parent, h, text, subText )
    self.stepPanels = self.stepPanels or {}
    local stepNumber = #self.stepPanels+1

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

    local stepPanel = vgui.Create( "DPanel", parent )
    stepPanel:Dock( TOP )
    stepPanel:SetTall( h )
    stepPanel:DockMargin( 0, margin25, 0, 0 )
    stepPanel.leftW = BRICKS_SERVER.Func.ScreenScale( 50 )
    stepPanel.Paint = function( self2, w, h )
        local isAvailable = true--self.currentStep >= stepNumber or self.stepPanels[stepNumber-1].completed

        if( not isAvailable ) then
            surface.SetAlphaMultiplier( 0.5 )
        end

        draw.RoundedBox( rounding, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        draw.RoundedBox( rounding, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2, 200 ) )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, 100 ) )
        surface.DrawRect( self.leftBorderW, 0, self2.leftW, h )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 10 ) )
        surface.SetMaterial( self2.completed and completedIconMat or errorIconMat )
        surface.DrawTexturedRect( self.leftBorderW+self2.leftW/2-iconSize/2, h/2-iconSize/2, iconSize, iconSize )

        local highlightColor = BRICKS_SERVER.Func.GetTheme( 3 )
        if( isAvailable ) then
            highlightColor = self2.completed and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red
        end

        BRICKS_SERVER.Func.DrawPartialRoundedBox( rounding, 0, 0, 6, h, highlightColor, 2*self.leftBorderW, h )
    
        local leftMargin = self.leftBorderW+self2.leftW+margin25
        draw.SimpleText( string.upper( text ), "BRICKS_SERVER_Font22B", leftMargin, margin25, BRICKS_SERVER.Func.GetTheme( 5 ) )
        draw.SimpleText( subText, "BRICKS_SERVER_Font20B", leftMargin, margin25+textH, BRICKS_SERVER.Func.GetTheme( 6, 50 ) )
        surface.SetAlphaMultiplier( 1 )
    end
    stepPanel.requirementEntries = {}
    stepPanel.AddRequirement = function( self2, requirementText, hasPassed, infoFunc )
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
    stepPanel.UpdateCompletion = function( self2 )
        local requirementsCompleted = true
        for k, v in ipairs( self2.requirementEntries ) do
            local passed = v[2]()
            v[1].hasPassed = passed

            if( passed ) then continue end
            requirementsCompleted = false
        end

        self2.completed = self2.isCompletedFunc( requirementsCompleted )

        if( not self2.completed or self.currentStep > stepNumber ) then return end
        self.currentStep = stepNumber+1
    end

    stepPanel.requirementsPanel = vgui.Create( "Panel", stepPanel )
    stepPanel.requirementsPanel:SetTall( BRICKS_SERVER.Func.ScreenScale( 30 ) )
    stepPanel.requirementsPanel:SetPos( self.leftBorderW+stepPanel.leftW+margin25+subTextW+margin25, margin25+(textH+subTextH)/2-stepPanel.requirementsPanel:GetTall()/2 )

    table.insert( self.stepPanels, stepPanel )
    return stepPanel
end

function PANEL:FillPanel()
    local rounding = BRICKS_SERVER.Func.ScreenScale( 10 )
    local margin5 = BRICKS_SERVER.Func.ScreenScale( 5 )
    local margin10 = BRICKS_SERVER.Func.ScreenScale( 10 )
    local margin25 = BRICKS_SERVER.Func.ScreenScale( 25 )
    local margin50 = BRICKS_SERVER.Func.ScreenScale( 50 )

    local contentPanel = vgui.Create( "Panel", self )
    contentPanel.OnSizeChanged = function( self2, w, h )
        self2:SetPos( margin50, self.panelHeight/2-h/2 )
    end
    contentPanel:SetSize( self.panelWide-2*margin50, 0 )

    local newPageIconMat = Material( "bricks_server/gang_page_new.png", "noclamp smooth" )
    local newPageIconSize = BRICKS_SERVER.Func.ScreenScale( 75 )
    local newIconMat = Material( "bricks_server/gang_new_banner.png", "noclamp smooth" )
    local newIconSize = BRICKS_SERVER.Func.ScreenScale( 75 )

    surface.SetFont( "BRICKS_SERVER_Font40B" )
    local contentH = select( 2, surface.GetTextSize( "CREATE A NEW GANG" ) )

    surface.SetFont( "BRICKS_SERVER_Font20B" )
    contentH = contentH+select( 2, surface.GetTextSize( "INVITE YOUR FRIENDS AND EARN MONEY!" ) )-BRICKS_SERVER.Func.ScreenScale( 20 )

    local headerPanel = vgui.Create( "DPanel", contentPanel )
    headerPanel:Dock( TOP )
    headerPanel:SetTall( BRICKS_SERVER.Func.ScreenScale( 150 ) )
    headerPanel.leftW = BRICKS_SERVER.Func.ScreenScale( 175 )
    headerPanel.Paint = function( self2, w, h )
        draw.RoundedBox( rounding, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
        draw.RoundedBox( rounding, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2, 200 ) )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, 100 ) )
        surface.DrawRect( self.leftBorderW, 0, self2.leftW, h )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 50 ) )
        surface.SetMaterial( newPageIconMat )
        surface.DrawTexturedRect( self.leftBorderW+self2.leftW/2-newPageIconSize/2, h/2-newPageIconSize/2, newPageIconSize, newPageIconSize )
        
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 25 ) )
        surface.SetMaterial( newIconMat )
        surface.DrawTexturedRect( self.leftBorderW+self2.leftW-newIconSize, 0, newIconSize, newIconSize )

        local leftMargin = self.leftBorderW+self2.leftW+(h-contentH)/2
        draw.SimpleText( "CREATE A NEW GANG", "BRICKS_SERVER_Font40B", leftMargin-1, h/2-contentH/2-BRICKS_SERVER.Func.ScreenScale( 10 ), BRICKS_SERVER.Func.GetTheme( 6, 50 ), 0, 0 )
        draw.SimpleText( "INVITE YOUR FRIENDS AND EARN MONEY!", "BRICKS_SERVER_Font20B", leftMargin, h/2+contentH/2+BRICKS_SERVER.Func.ScreenScale( 4 ), BRICKS_SERVER.Func.GetTheme( 6, 50 ), 0, TEXT_ALIGN_BOTTOM )
    
        if( not self2.startLoading or CurTime() >= self2.startLoading+1 or CurTime()-firstPanel.startLoading < 0.2 ) then return end

        local circleThick = BRICKS_SERVER.Func.ScreenScale( 5 )
        local circleR = BRICKS_SERVER.Func.ScreenScale( 25 )
        BRICKS_SERVER.Func.DrawArc( w-h/2, h/2, circleR, circleThick, 0, 360, BRICKS_SERVER.Func.GetTheme( 3 ) )

        local percent = CurTime()*1
        BRICKS_SERVER.Func.DrawArc( w-h/2, h/2, circleR, circleThick, -360*percent, -360*percent+50, BRICKS_SERVER.Func.GetTheme( 5 ) )
    end

    contentPanel:SetTall( headerPanel:GetTall() )

    headerPanel.gradient = vgui.Create( "bricks_server_gradientanim", headerPanel )
    headerPanel.gradient:SetPos( 0, 0 )
    headerPanel.gradient:SetSize( self.leftBorderW, headerPanel:GetTall() )
    headerPanel.gradient:SetDirection( 1 )
    headerPanel.gradient:SetCornerRadius( rounding )
    headerPanel.gradient:SetRoundedBoxDimensions( false, false, 20, false )
    headerPanel.gradient:TasteTheRainbow()
    headerPanel.gradient:StartAnim()

    local pricePanel
    local createButton = vgui.Create( "DButton", headerPanel )
    createButton:Dock( RIGHT )
    createButton:DockMargin( 0, margin50, margin25, margin50 )
    createButton:SetWide( BRICKS_SERVER.Func.ScreenScale( 200 ) )
    createButton:SetText( "" )
    createButton.Paint = function( self2, w, h )
        draw.RoundedBox( rounding, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 50 ) )

        self2.hoverPercent = math.Clamp( (self2.hoverPercent or 0)+(self2:IsHovered() and 5 or -5), 0, 100 )

        local x, y = self2:LocalToScreen( 0, 0 )
        render.SetScissorRect( x+w/2-w*(self2.hoverPercent/200), y, x+w/2+w*(self2.hoverPercent/200), y+h, true )
        draw.RoundedBox( rounding, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 100 ) )
        render.SetScissorRect( 0, 0, 0, 0, false )

        draw.SimpleText( "CREATE GANG", "BRICKS_SERVER_Font30B", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 50 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    pricePanel = vgui.Create( "DPanel", headerPanel )
    pricePanel:Dock( RIGHT )
    pricePanel:DockMargin( 0, margin50, margin25, margin50 )
    pricePanel:SetWide( BRICKS_SERVER.Func.ScreenScale( 150 ) )
    pricePanel.Paint = function( self2, w, h )
        draw.RoundedBox( rounding, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, 50 ) )

        draw.SimpleText( DarkRP.formatMoney( BRICKS_SERVER.CONFIG.GANGS["Creation Fee"] or 1500 ), "BRICKS_SERVER_Font30B", w/2, h/2, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    -- First Step
    local firstPanel = self:CreateStepPanel( contentPanel, BRICKS_SERVER.Func.ScreenScale( 150 ), "Gang Name", "A cool name for your new gang." )
    contentPanel:SetTall( contentPanel:GetTall()+margin25+firstPanel:GetTall() )

    local gangNameEntry = vgui.Create( "bricks_server_textentry", firstPanel )
    gangNameEntry:SetSize( contentPanel:GetWide()*0.3, BRICKS_SERVER.Func.ScreenScale( 40 ) )
    gangNameEntry:SetPos( self.leftBorderW+firstPanel.leftW+margin25, firstPanel:GetTall()-margin25-gangNameEntry:GetTall() )
    gangNameEntry:SetFont( "BRICKS_SERVER_Font22" )
    gangNameEntry.backColor = BRICKS_SERVER.Func.GetTheme( 0, 100 )
    local newGangName = ""
    gangNameEntry.OnChange = function()
        newGangName = string.Trim( gangNameEntry:GetValue() )
        firstPanel:UpdateCompletion()
    end

    firstPanel:AddRequirement( "+" .. BRICKS_SERVER.DEVCONFIG.GangNameCharMin .. " Length", function() 
        return string.len( newGangName ) >= BRICKS_SERVER.DEVCONFIG.GangNameCharMin
    end )

    firstPanel:AddRequirement( "< " .. BRICKS_SERVER.DEVCONFIG.GangNameCharMax .. " Length", function() 
        return string.len( newGangName ) <= BRICKS_SERVER.DEVCONFIG.GangNameCharMax
    end )

    firstPanel:AddRequirement( "Only Letters/Numbers", function() 
        return not string.match( string.Replace( newGangName, " ", "" ), "[%W]" )
    end )

    firstPanel.isCompletedFunc = function( requirementsPassed )
        return requirementsPassed
    end

    -- Second Step
    local secondPanel = self:CreateStepPanel( contentPanel, BRICKS_SERVER.Func.ScreenScale( 185 ), "Gang Icon", "An icon used when displaying your gang." )
    contentPanel:SetTall( contentPanel:GetTall()+margin25+secondPanel:GetTall() )

    secondPanel.bottom = vgui.Create( "Panel", secondPanel )
    secondPanel.bottom:Dock( BOTTOM )
    secondPanel.bottom:SetTall( BRICKS_SERVER.Func.ScreenScale( 75 ) )
    secondPanel.bottom:DockMargin( self.leftBorderW+secondPanel.leftW+margin25, 0, margin25, margin25 )

    local unselectedIconMat = Material( "bricks_server/icon_unselected.png" )
    local newGangIcon, loadingNewIcon, newGangIconMat = "", false

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
    
        local currentIconDisplay = vgui.Create( "DButton", presetsPanel )
        currentIconDisplay:Dock( LEFT )
        currentIconDisplay:SetWide( presetsPanel:GetTall() )
        currentIconDisplay:DockMargin( 0, 0, margin5, 0 )
        currentIconDisplay:SetText( "" )
        currentIconDisplay.Paint = function( self2, w, h )
            local isSelected = v == newGangIcon
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
            if( newGangIcon == v ) then
                newGangIcon = ""
                newGangIconMat = nil
            else
                newGangIcon = v
                newGangIconMat = presetIconMat
                loadingNewIcon = false
                customUrlEntry:SetValue( "" )
            end

            secondPanel:UpdateCompletion()
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
        if( not IsValid( customUrlEntry ) or customUrlEntry:GetValue() == "" or customUrlEntry:GetValue() == newGangIcon ) then return end

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
    customUrlEntry.OnEnter = function( self2 )
        local newValue = self2:GetValue()
        loadingNewIcon = true
        newGangIcon = newValue
        newGangIconMat = nil

        BRICKS_SERVER.Func.GetImage( newGangIcon, function( mat )
            if( newGangIcon != newValue ) then return end
            newGangIconMat = mat 
            loadingNewIcon = false
        end )

        secondPanel:UpdateCompletion()
    end

    local validImageEndings = { ".png", ".jpg", ".jpeg" }
    secondPanel:AddRequirement( ".png, .jpg or .jpeg", function() 
        if( table.HasValue( BRICKS_SERVER.DEVCONFIG.PresetGangIcons, newGangIcon ) ) then return true end

        for _, v in ipairs( validImageEndings ) do
            if( string.EndsWith( newGangIcon, v ) ) then return true end
        end

        return false
    end )

    -- BRICKS_SERVER.DEVCONFIG.GangURLWhitelist
    -- Show whitelsited urls when hovering?
    secondPanel:AddRequirement( "Whitelisted URL", function() 
        if( table.HasValue( BRICKS_SERVER.DEVCONFIG.PresetGangIcons, newGangIcon ) ) then return true end

        for _, v in ipairs( BRICKS_SERVER.DEVCONFIG.GangURLWhitelist ) do
            if( string.StartWith( newGangIcon, v ) ) then return true end
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

    -- Third Step
    local thirdPanel = self:CreateStepPanel( contentPanel, BRICKS_SERVER.Func.ScreenScale( 160 ), "Gang Colour", "The colour of your gang, displayed in various places." )
    contentPanel:SetTall( contentPanel:GetTall()+margin25+thirdPanel:GetTall() )

    thirdPanel.bottom = vgui.Create( "Panel", thirdPanel )
    thirdPanel.bottom:Dock( BOTTOM )
    thirdPanel.bottom:SetTall( BRICKS_SERVER.Func.ScreenScale( 50 ) )
    thirdPanel.bottom:DockMargin( self.leftBorderW+thirdPanel.leftW+margin25, 0, margin25, margin25 )

    local newGangColour

    local colourOptions = { 
        Color( 244, 67, 54 ),
        Color( 233, 30, 99 ),
        Color( 156, 39, 176 ),
        Color( 103, 58, 183 ),
        Color( 63, 81, 181 ),
        Color( 33, 150, 243 ),
        Color( 3, 169, 244 ),
        Color( 0, 188, 212 ),
        Color( 0, 150, 136 ),
        Color( 76, 175, 80 ),
        Color( 139, 195, 74 ),
        Color( 205, 220, 57 ),
        Color( 255, 235, 59 ),
        Color( 255, 193, 7 ),
        Color( 255, 152, 0 ),
        Color( 255, 87, 34 ),
    }

    -- colourOptions = {}
    -- for i = 0, 9 do
    --     table.insert( colourOptions, HSVToColor( (360/10)*i, 0.8, 1 ) )
    -- end

    local colourEntrySize = math.floor( (thirdPanel.bottom:GetTall()-margin5)/2 )

    local colourGrid = vgui.Create( "DIconLayout", thirdPanel.bottom )
    colourGrid:Dock( LEFT )
    colourGrid:SetWide( (math.ceil( #colourOptions/2 )*(colourEntrySize+margin5))-margin5 )
    colourGrid:SetSpaceX( margin5 )
    colourGrid:SetSpaceY( margin5 )
    
    local whiteColour = BRICKS_SERVER.DEVCONFIG.BaseThemes.White
    local circleBorder = BRICKS_SERVER.Func.ScreenScale( 2 )
    for k, v in ipairs( colourOptions ) do
        local colourEntry = vgui.Create( "DButton", colourGrid )
        colourEntry:SetSize( colourEntrySize, colourEntrySize )
        colourEntry:SetText( "" )
        colourEntry.Paint = function( self2, w, h )
            self2.hoverAlpha = math.Clamp( (self2.hoverAlpha or 0)+(self2:IsHovered() and 5 or -5), 0, 100 )

            local isSelected = v == newGangColour
            if( isSelected or self2.hoverAlpha != 0 ) then
                local oldClipping = DisableClipping( true )
                surface.SetAlphaMultiplier( isSelected and 1 or self2.hoverAlpha/255 )
                BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2+circleBorder, whiteColour )
                surface.SetAlphaMultiplier( 1 )
                DisableClipping( oldClipping )
            end

            BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2, v )
        end
        colourEntry.DoClick = function()
            if( newGangColour == v ) then
                newGangColour = nil
            else
                newGangColour = v
            end

            thirdPanel:UpdateCompletion()
        end
    end

    thirdPanel.isCompletedFunc = function( requirementsPassed )
        return newGangColour != nil
    end

    -- Create Button
    createButton.DoClick = function()
        for k, v in ipairs( self.stepPanels ) do
            if( not v.completed ) then return end
        end
        
        net.Start( "BRS.Net.CreateGang" )
            net.WriteString( newGangIcon )
            net.WriteString( newGangName )
        net.SendToServer()
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_create", PANEL, "DPanel" )