--[[

Author: tochnonement
Email: tochnonement@gmail.com

19/08/2024

--]]

local function createDisplayOption( id, default )
    if ( default == nil ) then default = true end

    onyx.hud:RegisterOption( 'display_' .. id, {
        title = 'hud.' .. id .. '.name',
        desc = 'hud_should_draw',
        category = 'display',
        cami = 'onyx_hud_edit',
        type = 'bool',
        default = default
    } )
end

CAMI.RegisterPrivilege({
    Name = 'onyx_hud_edit',
    MinAccess = 'superadmin',
    Description = 'Allows to configure Onyx HUD'
})

onyx.hud:RegisterOption( 'timeout', {
    title = 'hud.timeout.name',
    desc = 'hud.timeout.desc',
    category = 'general',
    cami = 'onyx_hud_edit',
    type = 'int',
    default = 45,
    min = 15,
    max = 180
} )

onyx.hud:RegisterOption( 'alert_queue', {
    title = 'hud.alert_queue.name',
    desc = 'hud.alert_queue.desc',
    category = 'general',
    cami = 'onyx_hud_edit',
    type = 'bool',
    default = false
} )

onyx.hud:RegisterOption( 'props_counter', {
    title = 'hud.props_counter.name',
    desc = 'hud.props_counter.desc',
    category = 'general',
    cami = 'onyx_hud_edit',
    type = 'bool',
    default = false
} )

onyx.hud:RegisterOption( 'restrict_themes', {
    title = 'hud.restrict_themes.name',
    desc = 'hud.restrict_themes.desc',
    category = 'general',
    cami = 'onyx_hud_edit',
    type = 'bool',
    default = false
} )

onyx.hud:RegisterOption( 'main_avatar_mode', {
    title = 'hud.main_avatar_mode.name',
    desc = 'hud.main_avatar_mode.desc',
    category = 'general',
    cami = 'onyx_hud_edit',
    type = 'int',
    default = 0,
    min = 0,
    max = 1,
    combo = {
        { 'Avatar', 0 },
        { 'Model', 1 }
    }
} )

onyx.hud:RegisterOption( 'voice_avatar_mode', {
    title = 'hud.voice_avatar_mode.name',
    desc = 'hud.voice_avatar_mode.desc',
    category = 'general',
    cami = 'onyx_hud_edit',
    type = 'int',
    default = 0,
    min = 0,
    max = 1,
    combo = {
        { 'Avatar', 0 },
        { 'Model', 1 }
    }
} )

onyx.hud:RegisterOption( 'hud_bar_type', {
    title = 'hud.hud_bar_type.name',
    desc = 'hud.hud_bar_type.desc',
    category = 'general',
    cami = 'onyx_hud_edit',
    type = 'int',
    default = 0,
    min = 0,
    max = 2,
    combo = {
        { 'No Number', 0 },
        { 'Number', 1 },
        { 'Color Number', 2 },
    }
} )

-- Speedometer

onyx.hud:RegisterOption( 'speedometer_mph', {
    title = 'hud.speedometer_mph.name',
    desc = 'hud.speedometer_mph.desc',
    category = 'speedometer',
    cami = 'onyx_hud_edit',
    type = 'bool',
    default = false
} )

onyx.hud:RegisterOption( 'speedometer_max_speed', {
    title = 'hud.speedometer_max_speed.name',
    desc = 'hud.speedometer_max_speed.desc',
    category = 'speedometer',
    cami = 'onyx_hud_edit',
    type = 'int',
    default = 260,
    min = 180,
    max = 300
} )

-- Display

createDisplayOption( 'main' )
createDisplayOption( 'ammo' )
createDisplayOption( 'agenda' )
createDisplayOption( 'pickup_history' )
createDisplayOption( 'voice' )
createDisplayOption( 'alerts' )
createDisplayOption( 'alertsCommandHud' )
createDisplayOption( 'vehicle' )
createDisplayOption( 'level' )
createDisplayOption( 'notifications' )
createDisplayOption( 'weaponsSelector' )
createDisplayOption( 'overhead_health', false )
createDisplayOption( 'overhead_armor', false )