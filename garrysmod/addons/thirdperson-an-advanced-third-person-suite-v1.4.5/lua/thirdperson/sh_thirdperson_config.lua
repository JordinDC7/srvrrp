--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561199109663690)

CONFIGURATION FILE
]]--

-- Defaults --
    -- Default Third-Person setting
    -- Options: true or false
    -- Default value: true
    THIRDPERSON.default.ThirdPerson = false;

    -- Default Key Bind setting
    -- Options: none or key
    -- Default value: none
    THIRDPERSON.default.Bind = "none";

    -- Default Prevent Wall Collisions setting
    -- Options: true or false
    -- Default value: true.
    THIRDPERSON.default.PreventWallCollisions = true;

    -- Default Bullet Correction setting
    -- Options: true or false
    -- Default value: true
    THIRDPERSON.default.BulletCorrections = true;

    -- Default First-Person Scoping while in Third-Person setting
    -- Options: true or false
    -- Default value: true
    THIRDPERSON.default.Scoping = true;

    -- Default Distance setting
    -- Options: Number 0 to max distance configuration setting
    -- Default value: 100
    THIRDPERSON.default.Distance = 100;

    -- Default Vertical View setting
    -- Options: Number -50 to 50
    -- Default value: 5
    THIRDPERSON.default.VerticalView = 5;

    -- Default Horizontal View setting
    -- Options: Number -50 to 50
    -- Default value: 20
    THIRDPERSON.default.HorizontalView = 20;

    -- Default Third-Person Crosshair setting
    -- Options: A crosshair number (1-6); "None" for no crosshair by default
    -- Default value: None
    THIRDPERSON.default.Crosshair = "None";

    -- Default Crosshair Color setting
    -- Options: Color code r, g, b, a
    -- Default value: 0, 255, 0, 255
    THIRDPERSON.default.CrosshairColor = "0, 255, 0, 255";

    -- Default First-person while looking at the configured first-person entities.
    -- Options: true or false
    -- Default value: true
    THIRDPERSON.default.EntityView = true;
-- --

-- Sets the maximum view distance a user can configure.
-- Options: Number
-- Default value: 100
THIRDPERSON.maxDistance = 100;

-- Sets whether to have temporary first-person while keypad cracking or lock picking.
-- Options: true or false
-- Default value: true
THIRDPERSON.LockpickKeypadcrack = true;

-- Sets whether !ThirdPerson will have an icon for the menu in the context menu.
-- Options: true or false
-- Default value: true
THIRDPERSON.contextMenu = true;

-- Sets whether the !ThirdPerson set crosshair will be in first and third-person modes.
-- Options: true or false
-- Default value: true
THIRDPERSON.persistentCrosshair = true;

-- Sets the method by which !ThirdPerson will download content to players.
-- Options: direct, workshop, none (if you have another way of downloading)
-- Default value: direct
THIRDPERSON.downloadMethod = "direct";

-- Sets whether !ThirdPerson will put chat messages in the chat.
-- Options: true or false
-- Default value: true
THIRDPERSON.broadcastChat = true;

-- Sets whether !ThirdPerson will enable permissions support for detected admin mods (ULX, ServerGuard, xAdmin, xAdmin 2, SAM, or any CAMI-Supporting Admin Mod)
-- Options: true or false
-- Default value: true
THIRDPERSON.permissionsSupport = true;

-- Sets whether !ThirdPerson will use nicer fonts on the menu (that require download).
-- Options: true or false
-- Default value: true
THIRDPERSON.useFonts = true;

-- Sets whether !ThirdPerson will attempt to force compatibility by only allowing configured forceHooks when !ThirdPerson mode is not engaged/active.
-- Options: true or false
-- Default value: false
THIRDPERSON.forceCompatibility = false;

-- List of hooks to disengage when !ThirdPerson is active and forceCompatibility is true.
-- Options: List of strings
-- Default values: "CalcView", "ShouldDrawLocalPlayer"
THIRDPERSON.forceHooks = {
    "CalcView",
    "ShouldDrawLocalPlayer"
}

-- Commands:
-- Be sure to add a comma between entries in the tables.
THIRDPERSON.toggleCommands = {
    "!thirdperson",
    "!firstperson",
    "!fp",
    "!3p",
    "!1p",
};

THIRDPERSON.menuCommands = {
    "!thirdperson menu",
    "!thirdperson_menu",
    "!3p_menu",
    "!3p menu",
};

--[[

> ENTITIES CONFIGURATION
  ----------------------

Use this to whitelist entities which switch to first-person view mode
so that the user can better interact with them.

**You want to whitelist an entity if you want the entity to be viewed in
first-person mode at a specific distance.

**You want to remove an entity if you do not want viewing the entity
to ever trigger first-person mode.

Whitelisting/Adding Entities
----------------------------
Entries must follow the following format:
    ["Entity Class Name"] = View Distance Squared,

- Entity Class Name is the classname of the entity. Do NOT forget the [""].
- To get the entity's class, simply look at it, and use the !thirdperson entity command.
- View Distance is the view distance less than or equal to that you want 
  the view mode to change to first-person while looking at the given entity.

Blacklisting/Removing Entities
------------------------------
Simply delete the line with the entity you wish to remove. Be sure
that there is a comma on the second to last line of the table.
]]--

THIRDPERSON.entities = {
    -- Keypad Support --
    ["Keypad"]              = 75 ^ 2,
    ["keypad_wire"]         = 75 ^ 2,
    -- ATM Support --
    ["sent_arc_atm"]        = 75 ^ 2,
    ["atm_wall"]            = 75 ^ 2,
    -- ATM Pin Machine Support --
    ["sent_arc_pinmachine"] = 60 ^ 2,
    ["atm_reader"]          = 60 ^ 2,
    -- Printer Support --
    -- Others --
};

--[[

> WEAPONS CONFIGURATION
  ---------------------

Use this to set which weapons are viewed in first-person while the user is
holding them or by a custom function check.

Note that this is separate from lockpicking and keypad cracking--check the
above settings for those DarkRP settings, unless yours is custom.

Weapons must follow *one of these two* formats:
1. ["weapon_class"] = function( weapon ) return weapon:CustomCheck() end,
    - Whenever the function provided returns true, first-person mode will engage.
  OR
2. ["weapon_class"] = true,
    - Whenever the user has this weapon out, first-person mode will engage.

If a function is provided, the user will only be put in first-person mode
while that function returns true. This is useful for weapons, such as custom
lockpicks or keypad crackers, where you only want temporary first-person
mode while the weapon is being used. Please check with the SWEP or SWEP
developer for what functions you can use to check what state the SWEP is in.
- Please note that custom function checks do require a bit of lua.
  if you need any help with the lua, feel free to put in a support ticket.

If you would like first-person mode to always be active while the user
has the weapon out, simply set the value to true.
]]--

THIRDPERSON.weapons = {
    -- ["weapon_example"]   = function( weapon ) return weapon:CustomCheck() end,
    -- ["weapon_example_2"] = true,
};

-- ** IGNORE IF YOU ARE USING ULX, ServerGuard, xAdmin, xAdmin 2, SAM, or a CAMI-Supporting Admin Mod **
-- This will have no effect if one of those admin systems is on the server as !ThirdPerson will
-- use their permission systems instead.
-- If the server does NOT have a supported admin mod, define permissions below:
-- The following permissions are available:
--[[

> PERMISSIONS CONFIGURATION
  -------------------------

Default SuperAdmin Access:
--------------------------
thirdperson_preventwallcollisions    Ability to switch from the default PreventWallCollisions setting.

Default Admin Access:
---------------------
None.

Default User Access:
--------------------
thirdperson_view                Ability to switch from the default ThirdPerson setting.
thirdperson_crosshair           Ability to switch from the default Crosshair setting.
thirdperson_crosshaircolor      Ability to switch from the default CrosshairColor setting.
thirdperson_scoping             Ability to switch from the default Scoping setting.
thirdperson_bulletcorrection    Ability to switch from the default BulletCorrection setting.
thirdperson_distance            Ability to switch from the default Distance setting.
thirdperson_viewangles          Ability to switch from the default VerticalView and HorizontalView settings.
thirdperson_entityview          Ability to switch from the default EntityView setting.

Note that permissions are inherited: User --> Admin --> SuperAdmin.
Not all permissions have to be used, if the permission is not in any of the access tables then
no one will have access to it.
]]--

THIRDPERSON.access.SuperAdmin = {
    "thirdperson_preventwallcollisions",
};

THIRDPERSON.access.Admin = {

};

THIRDPERSON.access.User = {
    "thirdperson_view",
    "thirdperson_crosshair",
    "thirdperson_crosshaircolor",
    "thirdperson_scoping",
    "thirdperson_bulletcorrection",
    "thirdperson_distance",
    "thirdperson_viewangles",
    "thirdperson_entityview",
};