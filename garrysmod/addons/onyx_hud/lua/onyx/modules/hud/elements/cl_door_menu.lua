--[[

Author: tochnonement
Email: tochnonement@gmail.com

16/08/2024

--]]

local MAX_DISTANCE = 128 ^ 2 -- DarkRP default is 200
local L = function( ... ) return onyx.lang:Get( ... ) end
local doorFrame

local MAT_DOORENABLE = Material("onyx_hud/door_enable_own.png", "smooth")
local MAT_DOORDISABLE = Material("onyx_hud/disable_own.png", "smooth")
local MAT_DOORTITLE = Material("onyx_hud/door_title.png", "smooth")
local MAT_DOOROWN = Material("onyx_hud/door_own.png", "smooth")
local MAT_DOORSELL = Material("onyx_hud/door_sell.png", "smooth")
local MAT_ADDUSER = Material("onyx_hud/door_add_user.png", "smooth")
local MAT_REMOVEUSER = Material("onyx_hud/door_remove_user.png", "smooth")
local MAT_DOORGROUPS = Material("onyx_hud/door_groups.png", "smooth")
local MAT_RADIAL_CLOSE = Material("onyx_hud/radial_close.png", "smooth")

local function checkEntity( client, ent )
    if ( not IsValid( ent ) ) then return false end
    if ( not ent:isKeysOwnable() ) then return false end
    if ( ent:GetPos():DistToSqr( client:GetPos() ) > MAX_DISTANCE ) then return false end

    return true
end

local function safeClose( panel )
    if ( IsValid( panel ) ) then
        panel:Close()
    end
end

local function choosePlayer( ... )
    local colors = onyx.hud:GetCurrentTheme().colors
    local frame = onyx.ChoosePlayer( ... )

    frame.colorBG = onyx.OffsetColor( colors.primary, -5 )
    frame.lblDesc:SetTextColor( colors.textPrimary )
    frame.divHeader.colorBG = colors.secondary
    frame.divHeader.lblText:SetTextColor( colors.textPrimary )
    frame.divHeader.btnClose:SetColorIdle( colors.textPrimary )

    for _, button in ipairs( frame.buttons ) do
        button:SetColorIdle( colors.primary )
        button:SetColorHover( colors.secondary )
        button.lblTitle:SetTextColor( colors.textPrimary )
        button.colorTertiary = colors.tertiary
    end
end

local function openDoorMenu( client, setDoorOwnerAccess, canChangeSettings )
    local trace = client:GetEyeTrace()
    local ent = trace.Entity

    if ( not checkEntity( client, ent ) ) then return end

    local isClientOwner = ent:isKeysOwnedBy( client )
    local isOwned = ent:isKeysOwned()
    local isNonOwnable = ent:getKeysNonOwnable()
    local doorGroup = ent:getKeysDoorGroup()
    local doorTeams = ent:getKeysDoorTeams()
    local isAllowedToOwn = ent:isKeysAllowedToOwn( client )
    local entType = onyx.utf8.lower( L( ent:IsVehicle() and 'vehicle' or 'door' ) )
    local hasTeams = table.Count( doorTeams or {} ) > 0
    local colors = onyx.hud:GetCurrentTheme().colors

    local options = {}
    local insert = function( name, callback, mat )
        if ( isstring( callback ) ) then
            local cmd = tostring( callback )
            callback = function()
                RunConsoleCommand( 'darkrp', cmd )
            end
        end
        
        table.insert( options, {
            name = name,
            callback = callback,
            mat = mat
        } )
    end

    -- Buy door
    if ( not isOwned and ( not isNonOwnable and not doorGroup and not doorTeams ) or isAllowedToOwn ) then
        insert( L( 'door_purchase', { object = entType } ), 'toggleown', MAT_DOOROWN )
    end

    -- Sell door
    if ( isClientOwner ) then
        insert( L( 'door_sell', { object = entType } ), 'toggleown', MAT_DOORSELL )

        table.insert( options, { 
            name = L( 'door_addowner' ),
            ignoreClose = true,
            mat = MAT_ADDUSER,
            callback = function()
                choosePlayer( L( 'door_addowner' ), L( 'door_addowner_help' ), function(ply)
                    RunConsoleCommand( 'darkrp', 'ao', ply:SteamID() ) 
                end, false, function( ply )
                    return ( not ent:isKeysOwnedBy( ply ) and not ent:isKeysAllowedToOwn( ply ) )
                end )
            end
        } )

        table.insert( options, { 
            name = L( 'door_rmowner' ),
            ignoreClose = true,
            mat = MAT_REMOVEUSER,
            callback = function()
                choosePlayer( L( 'door_rmowner' ), L( 'door_rmowner_help' ), function( ply )
                    RunConsoleCommand( 'darkrp', 'ro', ply:SteamID() ) 
                end, false, function( ply )
                    return ( ( ent:isKeysOwnedBy( ply ) and not ent:isMasterOwner( ply ) ) or ent:isKeysAllowedToOwn( ply ) )
                end )
            end
        } )
    end

    -- Change title
    if ( canChangeSettings and ( isOwned or isNonOwnable or doorGroup or hasTeams ) or isClientOwner ) then
        local title = L( 'door_title' )
        insert( title, function()
            local frame = onyx.SimpleQuery( title, L( 'door_title_help' ), true, function( value )
                RunConsoleCommand( 'darkrp', 'title', value )
            end )

            frame.colorBG = onyx.OffsetColor( colors.primary, -5 )
            frame.divHeader.colorBG = colors.secondary
            frame.divHeader.lblText:SetTextColor( colors.textPrimary )

            frame.lblDesc:SetTextColor( colors.textPrimary )

            frame.textEntry:SetColorIdle( colors.primary )
            frame.textEntry:SetColorHover( onyx.OffsetColor( colors.primary, -10 ) )
            frame.textEntry:SetTextColor( colors.textPrimary )
            frame.textEntry:SetPlaceholderColor( colors.textTertiary )
            frame.textEntry.colors.accent = colors.accent
            frame.textEntry.colors.outline = colors.secondary
            frame.textEntry.currentOutlineColor = onyx.CopyColor( colors.secondary )
        end, MAT_DOORTITLE )
    end
    
    -- Admin settings
    if ( canChangeSettings ) then
        insert( L( isNonOwnable and 'door_admin_allow' or 'door_admin_disallow' ):gsub( ' ', '\n' ), 'toggleownable', isNonOwnable and MAT_DOORENABLE or MAT_DOORDISABLE )

        table.insert( options, {
            name = L( 'door_admin_edit' ),
            ignoreClose = true,
            mat = MAT_DOORGROUPS,
            callback = function( wheel )
                local dmenu = vgui.Create( 'onyx.Menu' )
                dmenu:ToCursor()
                dmenu.backgroundColor = colors.primary
                dmenu.outlineColor = colors.secondary
                dmenu.Think = function( this )
                    if ( not IsValid( wheel ) ) then
                        this:Close()
                    end
                end

                local groups = dmenu:AddSubMenu( L( 'door_groups' ) )
                local teams = dmenu:AddSubMenu( L( 'jobs' ) )
                local add = teams:AddSubMenu( L( 'add' ) )
                local remove = teams:AddSubMenu( L( 'remove' ) )
            
                dmenu:AddOption( L( 'none' ), function()
                    RunConsoleCommand( 'darkrp', 'togglegroupownable' )
                    safeClose( wheel )
                end )

                for name in pairs( RPExtraTeamDoors ) do
                    groups:AddOption( name, function()
                        RunConsoleCommand( 'darkrp', 'togglegroupownable', name )
                        safeClose( wheel )
                    end )
                end

                for index, data in ipairs( RPExtraTeams ) do
                    local which = ( not doorTeams or not doorTeams[ index ] ) and add or remove
                    which:AddOption( data.name, function()
                        RunConsoleCommand( 'darkrp', 'toggleteamownable', index )
                        safeClose( wheel )
                    end )
                end
            
                dmenu:Open()
            end
        } )
    end

    local amount = #options
    if ( amount == 1 ) then
        options[ 1 ].callback()
    elseif ( amount > 0 and not IsValid( doorFrame ) ) then
        local size = onyx.hud.ScaleTall( 512 )
    
        local choiceWheel = vgui.Create( 'onyx.hud.ChoiceWheel' )
        doorFrame = choiceWheel
        choiceWheel:SetSize( size, size )
        choiceWheel:SetShowLabel( true )
        choiceWheel:MakePopup()
        choiceWheel:Center()
        choiceWheel.OnRemove = function()
            doorFrame = nil
        end
        choiceWheel.PostThink = function( this )
            if ( not checkEntity( client, ent ) ) then
                this:Close()
            end
        end
        
        choiceWheel:AddChoice( { name = onyx.lang:Get( 'close' ), mat = MAT_RADIAL_CLOSE } )
    
        for _, data in ipairs( options ) do
            choiceWheel:AddChoice( data )
        end
    end
end

local function overrideDarkRP()
    local gmTable = GAMEMODE or GM
    
    DarkRP.openKeysMenu = function()
        local client = LocalPlayer()
        CAMI.PlayerHasAccess( client, 'DarkRP_SetDoorOwner', function( setDoorOwnerAccess )
            CAMI.PlayerHasAccess( client, 'DarkRP_ChangeDoorSettings', function( canChangeSettings )
                openDoorMenu( client, setDoorOwnerAccess, canChangeSettings )
            end )
        end )
    end

    gmTable.ShowTeam = DarkRP.openKeysMenu
    usermessage.Hook( 'KeysMenu', DarkRP.openKeysMenu )
end

onyx.hud.OverrideGamemode( 'onyx.hud.OverrideKeysMenu', overrideDarkRP )