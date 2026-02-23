--[[

Author: tochnonement
Email: tochnonement@gmail.com

30/07/2024

--]]

local hud = onyx.hud
local COLOR_BAR = Color( 200, 200, 200, 10 )
local COLOR_GRAY = Color( 183, 183, 183)
local COLOR_XP = Color( 202, 183, 14)

local MAT_HEART = Material( 'onyx_hud/heart.png', 'smooth mips' )
local MAT_SHIELD = Material( 'onyx_hud/shield.png', 'smooth mips' )
local MAT_FOOD =   Material( 'onyx_hud/food.png', 'smooth mips' )
local MAT_LICENSE = Material( 'onyx_hud/license.png', 'smooth mips' )
local MAT_STAR = Material( 'onyx_hud/wanted.png', 'smooth mips' )
local MAT_MICROPHONE = Material( 'onyx_hud/microphone.png', 'smooth mips' )
local CONVAR_COMPACT = CreateClientConVar( 'cl_onyx_hud_compact', '0', true, false, '', 0, 1 )
local CONVAR_3D = CreateClientConVar( 'cl_onyx_hud_3d_models', '0', true, false, '', 0, 1 )
local CONVAR_HELP = CreateClientConVar( 'cl_onyx_hud_show_help', '1', true, false, '', 0, 1 )

-- They are scaled after
local UNSCALED_BAR_H = 6
local UNSCALED_BAR_ICON_SIZE = 12
local UNSCALED_ICON_SIZE = 18
local UNSCALED_SPACE = 5

local slowLabels = {}
local lastMaskY
local lerpHealth, lerpArmor, lerpHunger
local lerpMoney

local function formatSalary( salary )
    -- local iters = ( 3600 / GAMEMODE.Config.paydelay )
    -- local full = math.Round( salary * iters )
    -- local formatted = '+' .. DarkRP.formatMoney( full ) .. '/h'
    return '+ ' .. DarkRP.formatMoney( salary )
end

local function drawIndicator( x, y, w, h, material, color, fraction, value )
    local iconSize = h
    local iconSpace = hud.ScaleTall( UNSCALED_SPACE )

    local theme = hud:GetCurrentTheme()
    local isDark = theme.isDark
    local colors = theme.colors
    local colorTextPrimary = colors.textPrimary
    local colorTextSecondary = colors.textSecondary

    local contentW = w - ( iconSize + iconSpace )
    local rectX, rectW = x + ( iconSize + iconSpace ), contentW
    local rectH = math.min( h, hud.ScaleTall( UNSCALED_BAR_H ) )
    local rectY = math.floor( y + iconSize * .5 - rectH * .5 )
    
    local showNumbers = hud:GetOptionValue( 'hud_bar_type' ) or 0
    local valueText, valueWidth

    if ( showNumbers > 0 ) then
        valueText = math.Round( value ) .. ''

        surface.SetFont( hud.fonts.SmallBold )
        valueWidth = surface.GetTextSize( valueText )
        
        rectW = rectW - valueWidth - iconSpace * 2
    end

    surface.SetDrawColor( colorTextSecondary )
    surface.SetMaterial( material )
    surface.DrawTexturedRect( x, y, iconSize, iconSize )
    
    hud.DrawRoundedBox( rectX, rectY, rectW, rectH, ColorAlpha( colorTextPrimary, isDark and 10 or 200 ) )

    render.SetScissorRect( rectX, rectY, rectX + rectW * fraction, rectY + rectH, true )
        hud.DrawRoundedBox( rectX, rectY, rectW, rectH, color )
    render.SetScissorRect( 0, 0, 0, 0, false )

    if ( showNumbers > 0 ) then
        draw.SimpleText( valueText, hud.fonts.SmallBold, rectX + contentW, y + h * .5, ( showNumbers == 2 and color or colorTextPrimary ), 2, 1 )
    end
end

local function drawStatusIcon( x, y, w, h, material, color )
    surface.SetDrawColor( color or hud:GetColor( 'textTertiary' ) )
    surface.SetMaterial( material )
    surface.DrawTexturedRect( x, y, w, h )
end

local function recreateAvatar( self )
    local bUse3DModel = CONVAR_3D:GetBool()
    local bUseModel = hud:GetOptionValue( 'main_avatar_mode' ) == 1
    local client = LocalPlayer()

    if ( IsValid( self.AvatarPanel ) ) then
        self.AvatarPanel:Remove()
    end

    if ( bUseModel ) then
        if ( bUse3DModel ) then
            self.AvatarPanel = vgui.Create( 'DModelPanel' )
            self.AvatarPanel.LayoutEntity = function() end
            self.AvatarPanel.PostUpdateLook = function( panel, model )
                local ent = panel.Entity
    
                if ( IsValid( ent ) ) then
                    local boneID = ent:LookupBone( 'ValveBiped.Bip01_Head1' )
                    if ( boneID ) then       
                        local bonePos = ent:GetBonePosition( boneID )
                        if ( bonePos ) then
                            bonePos:Add( Vector( 0, 0, 2 ) )
                    
                            panel:SetLookAt (bonePos)
                            panel:SetCamPos( bonePos - Vector(-20, 0, 0) )
                            panel:SetFOV( 45 )
                    
                            ent:SetEyeTarget( bonePos - Vector(-20, 0, 0) )
                        end
                    end
                end
            end
        else
            self.AvatarPanel = vgui.Create( 'SpawnIcon' )
        end

        self.AvatarPanel.UpdateLook = function( panel, modelData )
            panel.modelData = modelData

            hud.UpdateModelIcon( panel, modelData )

            if ( panel.PostUpdateLook ) then
                panel:PostUpdateLook()
            end
        end

        local nextComparison = 0
        self.AvatarPanel.Think = function( panel )
            if ( nextComparison <= CurTime() ) then
                nextComparison = CurTime() + 1
            
                local actualData = hud.GetModelData( LocalPlayer() )
                local currentData = panel.modelData
    
                if ( not currentData or not hud.CompareModelData( currentData, actualData ) ) then
                    panel:UpdateLook( actualData )
                end
            end
        end
    else
        self.AvatarPanel = vgui.Create( 'AvatarImage' )
        self.AvatarPanel:SetPlayer( client, 128 )
    end

    self.AvatarPanel:SetPaintedManually( true )
    self.AvatarPanel:ParentToHUD()
end

local updateSlowLabels do
    local nextUpdate = 0
    local thinkRate = 1 / 10

    local function findBestFont( text, maxWidth, ... )
        local bestFont = select( 1, ... )
        assert( bestFont, 'no fonts given' )

        local lastWidth = math.huge
        for _, font in ipairs( { ... } ) do
            local width = onyx.GetTextSize( text, font )
            local isGood = width <= maxWidth

            if ( isGood or width < lastWidth ) then
                bestFont = font
                lastWidth = width

                if ( isGood ) then
                    break
                end
            end
        end

        return bestFont
    end

    function updateSlowLabels( client, maxWidth )
        if ( nextUpdate <= CurTime() ) then
            nextUpdate = CurTime() + thinkRate
            slowLabels = {}

            local name = client:Name()
            local job = ( client:getDarkRPVar( 'job' ) or team.GetName( client:Team() ) )

            slowLabels.name = {
                text = name,
                font = findBestFont( name, maxWidth, hud.fonts.Name, hud.fonts.SmallBold, hud.fonts.TinyBold, hud.fonts.ExtraTinyBold )
            }

            slowLabels.job = {
                text = job,
                font = findBestFont( job, maxWidth, hud.fonts.Small, hud.fonts.Tiny )
            }
        end
    end
end

local function drawMainHUD( self, client, scrW, scrH )
    local showJob = not CONVAR_COMPACT:GetBool()
    local space = hud.GetScreenPadding()
    local padding = hud.ScaleTall( 10 )
    local w, h = hud.ScaleWide( 300 ), hud.ScaleTall( showJob and 120 or 100 )
    local x, y = space, scrH - h - space

    -- Colors
    local theme = hud:GetCurrentTheme()
    local colors = theme.colors

    local colorPrimary = colors.primary
    local colorSecondary = colors.secondary
    local colorTertiary = colors.tertiary
    local colorTextPrimary = colors.textPrimary
    local colorTextSecondary = colors.textSecondary
    local isDark = theme.isDark

    -- Player variables
    local animSpeed = FrameTime() * 16

    local healthValue = client:Health()
    local armorValue = client:Armor()

    local healthFraction = math.Clamp( healthValue / client:GetMaxHealth(), 0, 1 )
    local armorFraction = math.Clamp( armorValue / client:GetMaxArmor(), 0, 1 )
    local money = client:getDarkRPVar( 'money' ) or 0

    lerpHealth = Lerp( animSpeed, lerpHealth or healthFraction, healthFraction )
    lerpArmor = Lerp( animSpeed, lerpArmor or armorFraction, armorFraction )
    lerpMoney = Lerp( animSpeed, lerpMoney or money, money )

    local name = client:Name()
    local teamColor = team.GetColor( client:Team() )
    local moneyFormatted = DarkRP.formatMoney( math.Round( lerpMoney ) )
    local salary = client:getDarkRPVar( 'salary' ) or 0
    local salaryFormatted = formatSalary( salary )
    local hasHunger = not DarkRP.disabledDefaults[ 'modules' ][ 'hungermod' ]
    local hasArmor = math.Round( lerpArmor, 2 ) > 0
    local rectAmount = ( hasHunger or hasArmor ) and 2 or 1
    local rectH = hud.ScaleTall( UNSCALED_BAR_ICON_SIZE )

    -- Increase HUD height if there is multiple bars
    if ( rectAmount > 1 ) then
        local extraHeight = hud.ScaleTall( 10 )
        h = h + extraHeight
        y = y - extraHeight
    end

    local avatarSpaceWidth = hud.ScaleWide( 80 )
    local labelX = x + avatarSpaceWidth + padding
    local labelY = y + padding

    -- Draw background
    hud.DrawRoundedBox( x, y, w, h, colorPrimary )
    hud.DrawRoundedBoxEx( x, y, avatarSpaceWidth, h, colorSecondary, true, false, true )

    -- Draw labels
    local labelMaxW = w - avatarSpaceWidth - padding * 2
    
    updateSlowLabels( client, labelMaxW )
    
    -- Limited render bounds for labels
    render.SetScissorRect( 0, 0, labelX + labelMaxW, ScrH(), true )

    local _, nameHeight = draw.SimpleText( slowLabels.name.text, slowLabels.name.font, labelX, labelY, colorTextPrimary, 0, 0 )

    local teamHeight
    if ( showJob ) then
        _, teamHeight = draw.SimpleText( slowLabels.job.text, slowLabels.job.font, labelX, labelY + nameHeight, teamColor, 0, 0 )
    else
        teamHeight = 0
    end

    local _, moneyHeight = draw.SimpleText( moneyFormatted, hud.fonts.Small, labelX, labelY + nameHeight + teamHeight, colorTextSecondary, 0, 0 )
    draw.SimpleText( salaryFormatted, hud.fonts.Small, x + w - padding, labelY + nameHeight + teamHeight, colorTextSecondary, 2, 0 )

    render.SetScissorRect( 0, 0, 0, 0, false )

    local contentH = nameHeight + teamHeight + moneyHeight
    local topPartH = contentH + padding * 2
    local lineY = labelY + contentH + padding
    local lineW = w - avatarSpaceWidth - padding * 2
    local lineH = math.max( 1, hud.ScaleTall( 2 ) )
    
    -- Prepare a mask for avatar
    local avatarY = y + padding
    local avatarSize = math.min( contentH, avatarSpaceWidth - padding * 2 )
    local circleRadius = math.Round( avatarSize * .5 )
    local circleOutlineThickness = hud.ScaleTall( 2.5 )

    local maskX0 = x + math.Round( avatarSpaceWidth * .5 )
    local maskY0 = avatarY + circleRadius
    local maskX, maskY = maskX0 - circleRadius, avatarY

    if ( not self.AvatarMask or not lastMaskY or lastMaskY ~= maskY0 ) then
        lastMaskY = maskY0
        self.AvatarMask = onyx.CalculateCircle( maskX0, maskY0, circleRadius, 32 )
    end

    -- Draw avatar
    if ( IsValid( self.AvatarPanel ) ) then
        onyx.DrawWithPolyMask( self.AvatarMask, function()
            if ( self.AvatarPanel:GetClassName() ~= 'AvatarImage' ) then
                -- Draw fancy background for model icons
                onyx.DrawCircle( maskX0, maskY0, circleRadius, colorPrimary )
                onyx.DrawMatGradient( maskX, maskY, avatarSize, avatarSize, BOTTOM, ColorAlpha( teamColor, isDark and 25 or 150 )  )
            end

            self.AvatarPanel:SetPos( maskX, maskY )
            self.AvatarPanel:SetSize( avatarSize, avatarSize )
            self.AvatarPanel:PaintManual()

            if ( client:IsSpeaking() ) then
                local micSize = avatarSize * .5

                micSize = micSize + ( micSize * .2 * math.abs( math.sin( CurTime() * 2 ) ) )

                surface.SetDrawColor( 0, 0, 0, 225 )
                surface.DrawRect( maskX, maskY, avatarSize, avatarSize )
                
                surface.SetDrawColor( 255, 255, 255 )
                surface.SetMaterial( MAT_MICROPHONE )
                surface.DrawTexturedRectRotated( maskX0, maskY0, micSize, micSize, 0 )
            end
        end )

        onyx.DrawOutlinedCircle( maskX0, maskY0, circleRadius + circleOutlineThickness * .5, circleOutlineThickness, teamColor )
    end

    -- Draw separator
    if ( isDark ) then
        surface.SetDrawColor( 0, 0, 0, 50 )
    else
        surface.SetDrawColor( 100, 100, 100, 100 )
    end
    surface.DrawRect( x, lineY, w, lineH )

    local footerH = h - topPartH
    local footerY0 = lineY + footerH * .5

    -- Draw icons
    local iconSize = hud.ScaleTall( UNSCALED_ICON_SIZE )
    local iconSpace = hud.ScaleTall( UNSCALED_SPACE ) * .75
    local iconX0 = x + avatarSpaceWidth * .5
    local iconY0 = footerY0 - iconSize * .5
    
    drawStatusIcon( iconX0 - iconSize - iconSpace, iconY0, iconSize, iconSize, MAT_LICENSE, client:getDarkRPVar( 'HasGunlicense' ) and hud:GetColor( 'accent' )  )
    drawStatusIcon( iconX0 + iconSpace, iconY0, iconSize, iconSize, MAT_STAR, client:getDarkRPVar( 'wanted' ) and hud.GetAnimColor( 0 ) )

    -- Draw indicators
    local rectSpace = hud.ScaleTall( 3 )
    local totalIndictatorsH = rectAmount * rectH + ( rectAmount - 1 ) * rectSpace
    local rectY = footerY0 - totalIndictatorsH * .5
    
    drawIndicator( labelX, rectY, lineW, rectH, MAT_HEART, Color( 197, 54, 54), lerpHealth, healthValue )

    rectY = rectY + rectH + rectSpace

    if ( hasHunger ) then
        local iconSpace = hud.ScaleTall( UNSCALED_SPACE * 1 )
        local halfLineWidth = lineW * .5 - iconSpace * .5
        local hungerValue = client:getDarkRPVar( 'Energy', 0 )
        local hungerFraction = math.Clamp( hungerValue / 100, 0, 1 )

        lerpHunger = Lerp( animSpeed, lerpHunger or hungerFraction, hungerFraction )
        
        drawIndicator( labelX, rectY, halfLineWidth, rectH, MAT_FOOD, Color( 197, 157, 54), lerpHunger, hungerValue )
        drawIndicator( labelX + halfLineWidth + iconSpace, rectY, halfLineWidth, rectH, MAT_SHIELD, Color( 54, 102, 197), lerpArmor, armorValue )
    elseif ( hasArmor ) then
        drawIndicator( labelX, rectY, lineW, rectH, MAT_SHIELD, Color( 54, 102, 197), lerpArmor, armorValue )
    end

    -- Draw help
    local addBlockSpace = hud.ScaleTall( 7.5 )

    if ( CONVAR_HELP:GetBool() ) && hud.IsElementEnabled( 'alertsCommandHud' ) then
        local addBlockH = hud.ScaleTall( 50 )
        local blockY = y - addBlockH - addBlockSpace
    
        hud.OverrideAlpha( 0.5 + 0.5 * math.abs( math.sin( CurTime() * 2 ) ), function()
            local helpFont = hud.fonts.Small
            local helpText1 = onyx.lang:Get( 'hud_help_type' ) .. ' '
            local helpText2 = '!hud'
            local helpText3 = ' ' .. onyx.lang:Get( 'hud_help_to' )
        
            surface.SetFont( helpFont )
            local helpTextW1 = surface.GetTextSize( helpText1 )
            local helpTextW3 = surface.GetTextSize( helpText3 )
            surface.SetFont( hud.fonts.SmallBold )
            local helpTextW2 = surface.GetTextSize( helpText2 )
            local helpTextTotalW = ( helpTextW1 + helpTextW2 + helpTextW3 )
            local helpTextX = x + w * .5 - helpTextTotalW * .5
            
            hud.DrawRoundedBox( x, blockY, w, addBlockH, colorPrimary )
    
            draw.SimpleText( onyx.lang:Get( 'introduction_u' ), hud.fonts.TinyBold, x + w * .5, blockY + addBlockH * .5, colorTextSecondary, 1, 4 )
    
            draw.SimpleText( helpText1, helpFont, helpTextX, blockY + addBlockH * .5, colorTextPrimary, 0, 0 )
            draw.SimpleText( helpText2, hud.fonts.SmallBold, helpTextX + helpTextW1, blockY + addBlockH * .5, colors.accent, 0, 0 )
            draw.SimpleText( helpText3, helpFont, helpTextX + helpTextW1 + helpTextW2, blockY + addBlockH * .5, colorTextPrimary, 0, 0 )
        end )
    elseif ( onyx.hud:GetOptionValue( 'display_level' ) and onyx.hud.IsLevellingEnabled() ) then
        local addBlockH = hud.ScaleTall( 47.5 )
        local blockY = y - addBlockH - addBlockSpace
        local level, xp, maxXP = onyx.hud.GetLevelData( client )
        local nextLevelFraction = xp / maxXP
        local rectH = math.min( h, hud.ScaleTall( UNSCALED_BAR_H ) )

        hud.DrawRoundedBox( x, blockY, w, addBlockH, colorPrimary )

        local textW = draw.SimpleText( onyx.lang:Get( 'hud.level.name' ) .. ': ', hud.fonts.Tiny, x + padding, blockY + padding, colorTextSecondary, 0, 0 )
        draw.SimpleText( level, hud.fonts.SmallBold, x + padding + textW, blockY + padding, ( isDark and COLOR_XP or colorTextPrimary ), 0, 0 )

        local textW2 = draw.SimpleText( ' / ' .. maxXP, hud.fonts.Tiny, x + w - padding, blockY + padding, colorTextSecondary, 2, 0 )
        draw.SimpleText( xp, hud.fonts.TinyBold, x + w - padding - textW2, blockY + padding, colorTextPrimary, 2, 0 )

        hud.DrawRoundedBox( x + padding, blockY + addBlockH - padding - rectH, w - padding * 2, rectH, ColorAlpha( colorTextPrimary, isDark and 10 or 200 ) )
        onyx.hud.ScissorRect( x + padding, blockY + addBlockH - padding - rectH, ( w - padding * 2 ) * nextLevelFraction, rectH, function()
            hud.DrawRoundedBox( x + padding, blockY + addBlockH - padding - rectH, w - padding * 2, rectH, COLOR_XP )
        end )
    end
end

cvars.AddChangeCallback( 'cl_onyx_hud_3d_models', function()
    recreateAvatar( hud.elements[ 'main' ] )
end, 'hud.internal' )

hook.Add( 'onyx.inconfig.Updated', 'hud.RecreateAvatar', function( id, old, new )
    if ( id and id == 'hud_main_avatar_mode' ) then
        recreateAvatar( hud.elements[ 'main' ] )
    end
end )

hook.Add( 'onyx.inconfig.Synchronized', 'hud.RecreateAvatar', function( id )
    recreateAvatar( hud.elements[ 'main' ] )
end )

hud:RegisterElement( 'main', {
    priority = 100,
    drawFn = drawMainHUD,
    initFunc = recreateAvatar,
    onSizeChanged = function( self )
        self.AvatarMask = nil -- It will force to recalculate the circle mask
    end
} )