--[[

Author: tochnonement
Email: tochnonement@gmail.com

30/07/2024

--]]

local COLOR_OUTLINE = onyx:Config( 'colors.primary' )
local COLOR_LOW = Color( 255, 98, 98)

local MAT_AMMO = Material( 'onyx_hud/ammo.png', 'smooth mips' )

local BUILD_WEAPONS = {
    [ 'weapon_physgun' ] = true,
    [ 'gmod_tool' ] = true,
}

local lastWeapon = NULL
local lerpClip1

local function drawAmmoHUD( client, scrW, scrH, weapon )
    local primaryAmmoType = weapon:GetPrimaryAmmoType()
    if ( primaryAmmoType < 0 ) then return end

    if ( lastWeapon ~= weapon ) then
        lastWeapon = weapon
        lerpClip1 = nil
    end

    local primaryAmmoCount = client:GetAmmoCount( primaryAmmoType )
    local primaryClip = weapon:Clip1()

    local secondaryAmmoType = weapon:GetSecondaryAmmoType()
    local hasSecondaryAmmo = secondaryAmmoType > 0
    local secondaryClip = weapon:Clip2()
    local secondaryAmmoCount = client:GetAmmoCount( secondaryAmmoType )
    
    local hideAmmoCount = false

    -- For grenades and etc.
    if ( primaryClip == -1 ) then 
        primaryClip = primaryAmmoCount
        hideAmmoCount = true
    end

    local lowAmmoStartRange = math.Round( weapon:GetMaxClip1() / 3 )
    local lowAmmoFraction = lowAmmoStartRange > 0 and math.min( 1, primaryClip / lowAmmoStartRange ) or 1
    if ( primaryClip == 0 ) then lowAmmoFraction = 0 end

    lerpClip1 = Lerp( FrameTime() * 16, lerpClip1 or primaryClip, primaryClip )
    
    -- Grab text size
    local textClip = math.Round( lerpClip1 )
    local textRemaining = hideAmmoCount and '' or ( ' / ' .. primaryAmmoCount )
    
    surface.SetFont( onyx.hud.fonts.AmmoClip )
    local textW1, textH1 = surface.GetTextSize( textClip )

    surface.SetFont( onyx.hud.fonts.AmmoRemaining )
    local textW2, textH2 = surface.GetTextSize( textRemaining )
    local totalW = textW1 + textW2
    
    -- Calculate positions and sizes
    local space = onyx.hud.GetScreenPadding()
    local padding = onyx.hud.ScaleTall( 20 )
    local w = totalW + padding * 2
    local h = onyx.hud.ScaleTall( 50 )

    local x = scrW - w - space
    local y = scrH - h - space

    local colorTextPrimary = onyx.hud:GetColor( 'textPrimary' )
    local colorTextSecondary = onyx.hud:GetColor( 'textSecondary' )

    -- Draw secondary ammo
    if ( hasSecondaryAmmo ) then
        local iconSize = h * .35
        surface.SetFont( onyx.hud.fonts.AmmoRemaining )
        local secAmmoTextW, secAmmoTextH = surface.GetTextSize( secondaryAmmoCount )
        local secAmmoTextSpace = onyx.hud.ScaleTall( 2 )
        local secAmmoTotalW = secAmmoTextW + secAmmoTextSpace + iconSize

        local secAmmoBlockWidth = secAmmoTotalW + padding * 1
        x = x - secAmmoBlockWidth

        local secAmmoStartX = x + w + secAmmoBlockWidth * .5 - secAmmoTotalW * .5
        local secAmmoColor = secondaryAmmoCount == 0 and colorTextSecondary or colorTextPrimary

        onyx.hud.DrawRoundedBoxEx( x + w, y, secAmmoBlockWidth, h, onyx.hud:GetColor( 'secondary' ), false, true, false, true )

        surface.SetDrawColor( colorTextSecondary )
        surface.SetMaterial( MAT_AMMO )
        surface.DrawTexturedRect( secAmmoStartX, y + h * .5 - iconSize * .5, iconSize, iconSize )

        onyx.hud.DrawCheapText( secondaryAmmoCount, onyx.hud.fonts.AmmoRemaining, secAmmoStartX + secAmmoTextSpace + iconSize, y + h * .5 - secAmmoTextH * .5, secAmmoColor )
    end

    -- Draw primary ammo
    local x0, y0 = x + w * .5, y + h * .5
    local textStartX = x0 - totalW * .5
    local colorClip = onyx.LerpColor( lowAmmoFraction, COLOR_LOW, colorTextPrimary )

    onyx.hud.DrawRoundedBoxEx( x, y, w, h, onyx.hud:GetColor( 'primary' ), true, not hasSecondaryAmmo, true, not hasSecondaryAmmo )
    onyx.hud.DrawCheapText( textClip, onyx.hud.fonts.AmmoClip, textStartX, y0 - textH1 * .5, colorClip, 0, 1 )
    onyx.hud.DrawCheapText( textRemaining, onyx.hud.fonts.AmmoRemaining, textStartX + textW1, y0 - textH2 * .5, colorTextSecondary, 0, 1 )

    -- Draw weapon name
    local name = weapon:GetPrintName()
    draw.SimpleTextOutlined( name, onyx.hud.fonts.SmallBold, scrW - space, y - onyx.hud.ScaleTall( 5 ), color_white, 2, 4, 1, COLOR_OUTLINE )
end

local function drawPropsHUD( client, scrW, scrH )
    local curProps = client:GetCount( 'props' )
    local maxProps = onyx.hud.GetMaxProps( client)
    if ( maxProps < 1 ) then
        maxProps = '∞'
    end
    
    local clipText = curProps
    local maxText = ' / ' .. maxProps

    surface.SetFont( onyx.hud.fonts.AmmoRemaining )
    local clipTextW, clipTextH = surface.GetTextSize( clipText )
    local maxTextW, maxTextH = surface.GetTextSize( maxText )
    local totalTextW = clipTextW + maxTextW

    -- Positions
    local space = onyx.hud.GetScreenPadding()
    local horPadding = onyx.hud.ScaleTall( 20 )
    local verPadding = onyx.hud.ScaleTall( 5 )
    local w = totalTextW + horPadding * 2
    local h = onyx.hud.ScaleTall( 55 )

    local x = scrW - w - space
    local y = scrH - h - space

    local colorTextPrimary = onyx.hud:GetColor( 'textPrimary' )
    local colorTextSecondary = onyx.hud:GetColor( 'textSecondary' )

    -- Draw
    onyx.hud.DrawRoundedBox( x, y, w, h, onyx.hud:GetColor( 'primary' ) )
    draw.SimpleText( onyx.lang:Get( 'props' ), onyx.hud.fonts.Small, x + w * .5, y + verPadding, colorTextSecondary, 1, 0 )
    onyx.hud.DrawCheapText( clipText, onyx.hud.fonts.AmmoRemaining, x + horPadding, y + h - clipTextH - verPadding, colorTextPrimary )
    onyx.hud.DrawCheapText( maxText, onyx.hud.fonts.AmmoRemaining, x + horPadding + clipTextW, y + h - clipTextH - verPadding, colorTextSecondary )
end

onyx.hud:RegisterElement( 'ammo', {
    drawFn = function( self, client, scrW, scrH )
        local weapon = client:GetActiveWeapon()
        if ( not IsValid( weapon ) ) then return end
        if ( client:InVehicle() ) then return end

        local class = weapon:GetClass()
        if ( BUILD_WEAPONS[ class ] ) then
            if ( onyx.hud:GetOptionValue( 'props_counter' ) ) then
                drawPropsHUD( client, scrW, scrH )
            end
        else
            drawAmmoHUD( client, scrW, scrH, weapon )
        end
    end,
    hideElements = { 
        [ 'CHudAmmo' ] = true, 
        [ 'CHudSecondaryAmmo' ] = true 
    }
} )