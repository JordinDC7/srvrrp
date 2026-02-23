--[[

Author: tochnonement
Email: tochnonement@gmail.com

30/07/2024

--]]

onyx.hud.elements = onyx.hud.elements or {}
onyx.hud.sortedElements = onyx.hud.sortedElements or {}

local CONVAR_ROUNDNESS = CreateClientConVar( 'cl_onyx_hud_roundness', '8', true, false, '', 0, 16 )
local CONVAR_PADDING = CreateClientConVar( 'cl_onyx_hud_screen_padding', '30', true, false, '', 5, 40 )

RunConsoleCommand( 'mp_show_voice_icons', '0' )

local function updateSortedElements()
    onyx.hud.sortedElements = {}

    for id, element in pairs( onyx.hud.elements ) do
        table.insert( onyx.hud.sortedElements, element )        
    end

    table.sort( onyx.hud.sortedElements, function( a, b )
        return a.priority < b.priority -- reverse
    end )
end

do
    local cachedPadding = CONVAR_PADDING:GetInt()
    
    cvars.AddChangeCallback( 'cl_onyx_hud_screen_padding', function( _, _, new )
        cachedPadding = tonumber( new ) or CONVAR_PADDING:GetDefault()
    end, 'onyx.hud.internal' )

    function onyx.hud.GetScreenPadding()
        return onyx.ScaleTall( cachedPadding )
    end
end

do
    local parseRoundness = function( value ) return ( math.floor( value / 4 ) * 4 ) end
    local cachedRoundness = parseRoundness( CONVAR_ROUNDNESS:GetInt() )
    
    cvars.AddChangeCallback( 'cl_onyx_hud_roundness', function( _, _, new )
        cachedRoundness = parseRoundness( tonumber( new ) or CONVAR_ROUNDNESS:GetDefault() )
    end, 'onyx.hud.internal' )

    function onyx.hud.GetRoundness()
        return cachedRoundness
    end
end

function onyx.hud.IsElementEnabled( id )
    local optionID = 'hud_display_' .. id
    local optionTable = onyx.inconfig.options[ optionID ]

    if ( optionTable ) then
        return onyx.hud:GetOptionValue( 'display_' .. id )
    end

    return true
end

function onyx.hud.UpdateModelIcon( modelIcon, modelData )
    local is2D = modelIcon.ClassName == 'SpawnIcon'
    local model = modelData.model
    local skin = modelData.skin
    local bodygroups = modelData.bodygroups
    
    if ( is2D ) then
        -- This one is always rebuilding spawnicons...
        -- local bodygroupsStr = ''
        -- for index = 1, 9 do
        --     local id = index - 1
        --     local value = bodygroups[ id ] or 0            

        --     bodygroupsStr = bodygroupsStr .. tostring( value )
        -- end
        
        -- modelIcon:SetModel( model, skin, bodygroupsStr )

        if ( modelIcon:GetModelName() ~= model ) then
            modelIcon:SetModel( model )
        end
    else
        if ( modelIcon:GetModel() ~= model ) then
            modelIcon:SetModel( model ) 
        end

        local ent = modelIcon.Entity
        if ( IsValid( ent ) ) then
            ent:SetSkin( skin )

            for id, value in pairs( bodygroups ) do
                ent:SetBodygroup( id, value )
            end
        end
    end
end

function onyx.hud.GetModelData( ent )
    local bodygroups = {}
    for _, bodygroup in ipairs( ent:GetBodyGroups() ) do
        local id = bodygroup.id
        local value = ent:GetBodygroup( bodygroup.id )
    
        bodygroups[ id ] = value
    end
    
    return {
        model = ent:GetModel(),
        skin = ent:GetSkin(),
        bodygroups = bodygroups
    }
end

function onyx.hud.CompareModelData( modelData1, modelData2 )
    for key, value in pairs( modelData1 ) do
        local otherValue = modelData2[ key ]

        if ( istable( value ) ) then
            for key2, value2 in pairs( value ) do
                local otherValue2 = otherValue[ key2 ]
                if ( not otherValue2 or otherValue2 ~= value2 ) then
                    return false
                end
            end
        else
            if ( value ~= otherValue ) then
                return false
            end
        end
    end

    return true
end

do
    local COLOR_RED = Color( 255, 52, 52)
    local COLOR_BLUE = Color( 55, 52, 255)
    function onyx.hud.GetAnimColor( id )
        if ( id == 0 ) then
            return onyx.LerpColor( math.abs( math.sin( CurTime() ) ), COLOR_RED, COLOR_BLUE )
        end
    end
end

function onyx.hud.OverrideGamemode( id, fn )
    if ( GM or GAMEMODE ) then
        fn()
    end

    -- it's a bit harder to override darkrp func
    -- lol I've had super weird bug on my laptop, that not all InitPostEntity hooks were initiated (without any errors) so I've found this solution
    hook.Add( 'Think', id, function()
        hook.Remove( 'Think', id )
        timer.Create( id, engine.TickInterval(), 1, function()
            fn()
        end )
    end )
end

function onyx.hud.GetMaxProps( client )
    -- SAM / Other admin mod support, however source is unknown so we should avoid errors and stuff :\
    if ( client.GetLimit ) then
        local success, value = pcall( client.GetLimit, client, 'props' )
        if ( success and isnumber( value ) ) then
            return value
        end
    end

    return GetConVar( 'sbox_maxprops' ):GetInt()
end

do
    -- Because draw.SimpleText and other functions have surface.GetTextSize & we do not need it.
    local SetTextColor = surface.SetTextColor
    local SetTextPos = surface.SetTextPos
    local SetFont = surface.SetFont
    local DrawText = surface.DrawText
    function onyx.hud.DrawCheapText( text, font, x, y, color )
        local color = color or color_white

        SetTextColor( color.r, color.g, color.b, color.a )
        SetTextPos( x, y )
        SetFont( font )
        DrawText( text )
    end
end

do
    -- Micro-optimization since we are drawing it a lot of times
    local Clamp = math.Clamp
    local SetDrawColor = surface.SetDrawColor
    local DrawRect = surface.DrawRect
    local RoundedBoxEx = draw.RoundedBoxEx
    local GetRoundness = onyx.hud.GetRoundness
    function onyx.hud.DrawRoundedBoxEx( x, y, w, h, color, co1, co2, co3, co4 )
        local roundness = Clamp( GetRoundness(), 0, h * .5 )
        if ( roundness == 0 ) then
            SetDrawColor( color )
            DrawRect( x, y, w, h )
        else
            RoundedBoxEx( roundness, x, y, w, h, color, co1, co2, co3, co4 )
        end
    end
end

do
    local GetAlphaMultiplier = surface.GetAlphaMultiplier
    local SetAlphaMultiplier = surface.SetAlphaMultiplier
    function onyx.hud.OverrideAlpha( alpha, callback )
        local prev = GetAlphaMultiplier()

        SetAlphaMultiplier( math.min( alpha, prev ) )
            callback()
        SetAlphaMultiplier( prev )
    end
end

do
    local SetScissorRect = render.SetScissorRect
    function onyx.hud.ScissorRect( x, y, w, h, callback )
        SetScissorRect( x, y, x + w, y + h, true )
            callback()
        SetScissorRect( 0, 0, 0, 0, false )
    end
end

function onyx.hud.DrawRoundedBox( x, y, w, h, color )
    onyx.hud.DrawRoundedBoxEx( x, y, w, h, color, true, true, true, true )
end

do
    function onyx.hud.DrawShadowText( text, font, x, y, color, ax, ay )
        local textW, textH
    
        -- Calculate & return size only if required
        if ( ax or ay ) then
            surface.SetFont( font )
            textW, textH = surface.GetTextSize( text )
        
            if ( ax == 1 ) then
                x = x - textW * .5
            end
        
            if ( ay == 1 ) then
                y = y - textH * .5
            end
        end
        
        onyx.hud.DrawCheapText( text, font .. '.Blur', x + 2, y + 2, color_black, ax, ay )
        onyx.hud.DrawCheapText( text, font, x, y, color, ax, ay )
    
        return textW, textH
    end
end

do
    local ELEMENT_MT = {}
    ELEMENT_MT.__index = ELEMENT_MT

    AccessorFunc( ELEMENT_MT, 'm_bInitiliazed', 'Initialized' )

    function ELEMENT_MT:GetID()
        return tostring( self.id )
    end

    function ELEMENT_MT:IsEnabled()
        return onyx.hud.IsElementEnabled( self:GetID() )
    end

    function ELEMENT_MT:Draw( client, scrW, scrH )
        local drawFn = self.drawFn
        assert( drawFn, '\'' .. self:GetID() .. '\' missing draw function' )
        
        drawFn( self, client, scrW, scrH )
    end

    function onyx.hud:RegisterElement( id, data )
        onyx.AssertType( id, 'string', 'RegisterElement', 1 )
        onyx.AssertType( data, 'table', 'RegisterElement', 2 )
    
        data.id = id
        data.priority = data.priority or 50

        self.elements[ id ] = setmetatable( data, ELEMENT_MT )

        updateSortedElements()

        return self.elements[ id ]
    end
end

hook.Add( 'HUDPaint', 'onyx.hud.Paint', function()
    local client = LocalPlayer()
    local scrW, scrH = ScrW(), ScrH()

    if ( IsValid( client ) ) then
        if ( not onyx.hud.builtFonts ) then
            onyx.hud.BuildFonts()
        end

        for _, element in ipairs( onyx.hud.sortedElements ) do
            local id = element.id

            if ( not element:GetInitialized() ) then
                element:SetInitialized( true )
                if ( element.initFunc ) then
                    element:initFunc( client )
                end
            end
            
            if ( element:IsEnabled() ) then
                onyx.hud.StartScaling( id )
                    ProtectedCall( element.Draw, element, client, scrW, scrH ) -- it won't break the whole cycle
                onyx.hud.EndScaling()
            end
        end
    end
end )

do
    local HIDE = {
        [ 'DarkRP_HUD' ] = true,
        [ 'DarkRP_LocalPlayerHUD' ] = true,
        [ 'DarkRP_EntityDisplay' ] = true,
        [ 'DarkRP_Hungermod' ] = true,
        [ 'CHudHealth' ] = true,
        [ 'CHudBattery' ] = true,
        [ 'CHudDamageIndicator' ] = true,
        [ 'CHUDQuickInfo' ] = true,
        [ 'CHudSuitPower' ] = true,
        [ 'CHudPoisonDamageIndicator' ] = true
    }

    hook.Add( 'HUDShouldDraw', 'onyx.hud.Hide', function( name )
        if ( HIDE[ name ] ) then
            return false
        else
            for id, element in pairs( onyx.hud.elements ) do
                if ( element.hideElements and element.hideElements[ name ] ) then
                    return false
                end
            end
        end
    end )

    hook.Add( 'HUDDrawTargetID', 'onyx.hud.Hide', function()
        return false
    end )

    hook.Add( 'DrawDeathNotice', 'onyx.hud.Hide', function()
        return false
    end )
end