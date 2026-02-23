--[[

Author: tochnonement
Email: tochnonement@gmail.com

14/08/2024

--]]

local SHOW_DURATION = 1.5
local MAX_SLOTS = 6
local CONVAR_SOUNDS = CreateClientConVar( 'cl_onyx_hud_wpnsel_sounds', '1', true, false, '', 0, 1 )

local hud = onyx.hud
local toggleFraction = 0
local toggleState = false
local slotsCache = {}
local selectorData = {
    selectedSlot = 1,
    selectedPos = 0,
    activeWeapon = NULL
}

local quickSwitchEnabled = GetConVar( 'hud_fastswitch' ):GetBool()

cvars.AddChangeCallback( 'hud_fastswitch', function(cname, old, new)
    quickSwitchEnabled = tobool( new )
end, 'onyx.hud' )

local function resetSlotsCache()
    slotsCache = {}
    for index = 1, MAX_SLOTS do
        slotsCache[ index ] = {}
    end
end

local function toggleWeaponSelector( state, bScroll )
    local oldState = toggleState
    
    toggleState = state

    if ( not state ) then
        toggleFraction = 0
        timer.Remove( 'onyx.hud.HideWeaponSelector' )
    else
        timer.Create( 'onyx.hud.HideWeaponSelector', SHOW_DURATION, 1, function()
            toggleWeaponSelector( false )
        end )

        if ( bScroll and not oldState and toggleFraction == 0 ) then
            local activeWeapon = selectorData.activeWeapon
            for slotIndex, slotWeapons in ipairs( slotsCache ) do
                for pos, weapon in ipairs( slotWeapons ) do
                    if ( weapon == activeWeapon ) then
                        selectorData.selectedSlot = slotIndex
                        selectorData.selectedPos = pos
                        break
                    end
                end
            end
        end
    end
end

local function drawWeaponSelector( client, scrW, scrH )
    toggleFraction = math.Approach( toggleFraction, toggleState and 1 or 0, FrameTime() * 8 )
    if ( toggleFraction <= 0 ) then return end 

    local prevAlpha = surface.GetAlphaMultiplier()
    local screenPadding = onyx.hud.GetScreenPadding()

    local activeSlots, emptySlots = 0, 0
    for _, cachedWeapons in ipairs( slotsCache ) do
        if ( #cachedWeapons > 0 ) then
            activeSlots = activeSlots + 1
        else
            emptySlots = emptySlots + 1
        end
    end

    local slotSpace = onyx.hud.ScaleTall( 3 )
    local baseSlotH = onyx.hud.ScaleTall( 27.5 )
    local slotActiveW = onyx.hud.ScaleWide( 150 )
    local slotEmptyW = baseSlotH

    local totalW = slotSpace * ( MAX_SLOTS - 1) + activeSlots * slotActiveW + emptySlots * slotEmptyW

    local theme = hud:GetCurrentTheme()
    local colors = theme.colors
    local colorPrimary = colors.primary
    local colorSecondary = colors.secondary
    local colorTertiary = colors.tertiary
    local colorAccent = colors.accent
    local colorPrimaryText = colors.textPrimary
    local colorSecondaryText = colors.textSecondary
    local colorTertiaryText = colors.textTertiary
    local isDark = theme.dark

    local y = screenPadding
    local x = scrW * .5 - totalW * .5
    
    surface.SetAlphaMultiplier( toggleFraction )

    for slotIndex = 1, MAX_SLOTS do
        local slotWeapons = slotsCache[ slotIndex ]
        if ( not slotWeapons ) then break end

        local amount = #slotWeapons
        local isEmpty = amount == 0
        local isSlotSelected = selectorData.selectedSlot == slotIndex
        local slotW = isEmpty and slotEmptyW or slotActiveW
        local slotY = y

        hud.DrawRoundedBox( x, slotY, slotW, baseSlotH, isEmpty and colorPrimary or colorSecondary )
        draw.SimpleText( slotIndex, onyx.hud.fonts.SmallBold, x + slotW * .5, slotY + baseSlotH * .5, isEmpty and colorTertiaryText or colorSecondaryText, 1, 1 )

        slotY = slotY + baseSlotH + slotSpace

        if ( not isEmpty ) then
            for index = 1, amount do
                local wep = slotWeapons[ index ]
                if ( IsValid( wep ) ) then
                    local wepName = wep:GetPrintName()
                    local isSelected = isSlotSelected and ( index == selectorData.selectedPos )
                    local isActive = selectorData.activeWeapon == wep
                    local textColor = isSelected and ( isDark and colorAccent or onyx.LerpColor( .5, colorAccent, colorPrimaryText ) ) or ( isActive and colorPrimaryText or colorSecondaryText)
                    local slotH = isSelected and baseSlotH * 1.33 or baseSlotH
                    local slotFont = onyx.hud.fonts.TinyBold

                    if ( isSelected ) then
                        hud.DrawRoundedBox( x, slotY, slotW, slotH, colorAccent )
                        hud.DrawRoundedBox( x + 1, slotY + 1, slotW - 2, slotH - 2, colorPrimary )
                        hud.DrawRoundedBox( x + 1, slotY + 1, slotW - 2, slotH - 2, ColorAlpha( colorAccent, isDark and 5 or 150 ) )
                    else
                        hud.DrawRoundedBox( x, slotY, slotW, slotH, colorPrimary )
                    end
                    
                    -- This guarantee that weapon's name won't render outside slot's bounds
                    render.SetScissorRect( x, slotY, x + slotW, slotY + slotH, true )
                        draw.SimpleText( wepName, slotFont, x + slotW * .5, slotY + slotH * .5, textColor, 1, 1 )
                    render.SetScissorRect( 0, 0, 0, 0, false )

                    slotY = slotY + slotH + slotSpace
                end
            end
        end

        x = x + slotW + slotSpace
    end

    surface.SetAlphaMultiplier( prevAlpha )
end

local playSelectSound do
    local soundStation
    function playSelectSound()
        if ( not CONVAR_SOUNDS:GetBool() ) then return end

        soundStation = soundStation or CreateSound( LocalPlayer(), 'common/wpn_moveselect.wav' )
    
        if ( soundStation:IsPlaying() ) then
            soundStation:Stop()
        end
    
        soundStation:PlayEx( .5, 100 )
    end
end

do
    local binds = {}
    for index = 1, MAX_SLOTS do
        binds[ ( 'slot' .. index ) ] = index
    end

    local lastWeapon = NULL

    local function selectWeapon()
        local data = selectorData
        local slotWeapons = slotsCache[ data.selectedSlot ]
    
        if ( slotWeapons ) then
            local weapon = slotWeapons[ data.selectedPos ]
            if ( IsValid( weapon ) ) then
                lastWeapon = LocalPlayer():GetActiveWeapon()
                input.SelectWeapon( weapon )
                toggleWeaponSelector( false )
            end
        end
    end

    local function cycleWeapons( slot )
        local data = selectorData
        local wasActive = toggleState
        local prevSlot = data.selectedSlot
        
        toggleWeaponSelector( true )
        playSelectSound()

        if ( not wasActive and prevSlot == slot and not quickSwitchEnabled ) then return end

        local slotData = slotsCache[ slot ]
        local pos = data.selectedPos or 0
        local weaponsAmount = #slotData

        if ( prevSlot ~= slot ) then
            pos = 0
        end
        
        data.selectedSlot = slot
        data.selectedPos = pos + 1

        if ( data.selectedPos > weaponsAmount ) then
            data.selectedPos = 1
        end

        if ( quickSwitchEnabled ) then
            selectWeapon()
        end
    end

    local function scrollWeapons( delta )
        toggleWeaponSelector( true, true )
        playSelectSound()

        local data = selectorData
        local slot = data.selectedSlot or 1
        local slotData = slotsCache[ slot ]
        local pos = data.selectedPos or 0
        local weaponsAmount = #slotData

        data.selectedPos = pos + delta

        local bNext = data.selectedPos > weaponsAmount
        local bPrev = data.selectedPos < 1

        if ( bNext or bPrev ) then
            local newSlot = data.selectedSlot
            for _ = 1, MAX_SLOTS do
                newSlot = newSlot + delta
                if ( newSlot < 1 ) then newSlot = MAX_SLOTS end 
                if ( newSlot > MAX_SLOTS ) then newSlot = 1 end

                local amount = #slotsCache[ newSlot ]

                if ( amount > 0 ) then
                    data.selectedPos = ( bPrev and amount or 1 )
                    data.selectedSlot = newSlot
                    break
                end
            end
        end

        if ( quickSwitchEnabled ) then
            selectWeapon()
        end
    end

    hook.Add( 'PlayerBindPress', 'onyx.hud.HandleBinds', function( ply, bind, pressed, code )
        if not hud.IsElementEnabled( 'weaponsSelector' ) then
            return
        end

        local slot = binds[ bind ]

        if ( ply:InVehicle() ) then return end
        if ( vgui.CursorVisible() ) then return end -- an attempt to fix super weird customer's bug

        if ( slot ) then
            cycleWeapons( slot )
        elseif ( bind == '+attack' and not quickSwitchEnabled ) then
            if ( toggleState ) then
                selectWeapon()
                return true
            end
        elseif ( not ply:KeyDown( IN_ATTACK ) ) then
            if ( bind == 'invprev' ) then
                scrollWeapons( -1 )
            elseif ( bind == 'invnext' ) then
                scrollWeapons( 1 )
            elseif ( bind == 'lastinv' ) then
                if ( IsValid( lastWeapon ) ) then
                    local wep = ply:GetActiveWeapon()
                    input.SelectWeapon( lastWeapon )
                    lastWeapon = wep
                end
            end
        end
    end )
end

hook.Add( 'PostDrawHUD', 'onyx.hud.DrawWeaponSelector', function()
    if not hud.IsElementEnabled( 'weaponsSelector' ) then
        return
    end

    -- cam.Start2D fixes weird font issue in this hook
    cam.Start2D()
        drawWeaponSelector( LocalPlayer(), ScrW(), ScrH() )
    cam.End2D()
end )

hook.Add( 'HUDShouldDraw', 'onyx.hud.HideWeaponSelector', function( name )
    if not hud.IsElementEnabled( 'weaponsSelector' ) then
        return
    end

    if ( name == 'CHudWeaponSelection' ) then
        return false
    end
end )

hook.Add( 'Think', 'onyx.hud.UpdateWeaponSelector', function()
    if not hud.IsElementEnabled( 'weaponsSelector' ) then
        return
    end

    local client = LocalPlayer()
    local weaponsList = client:GetWeapons()
    
    resetSlotsCache()

    selectorData.activeWeapon = client:GetActiveWeapon()

    for _, wep in ipairs( weaponsList ) do
        if ( IsValid( wep ) ) then
            local slotIndex = math.Clamp( wep:GetSlot() + 1, 1, MAX_SLOTS )
            local slotWeapons = slotsCache[ slotIndex ]
            assert( slotWeapons, string.format( 'invalid slot index %d', slotIndex ) )
            table.insert( slotWeapons, wep )
        end
    end

    for index, cacheList in ipairs( slotsCache ) do
        table.sort( cacheList, function( a, b )
            return a:GetSlotPos() < b:GetSlotPos()
        end )
    end
end )