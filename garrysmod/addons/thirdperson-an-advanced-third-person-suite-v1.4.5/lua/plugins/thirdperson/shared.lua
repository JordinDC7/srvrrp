--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561199109663690)

ServerGuard Plugin for !ThirdPerson Support
]]--

if serverguard then
    local plugin = plugin;

    plugin.name = "!ThirdPerson";
    plugin.author = "Imperial Knight";
    plugin.version = "ccd8705a-cc13-4851-80b1-ab8ec7722202";
    plugin.description = "!ThirdPerson support for ServerGuard.";
    plugin.permissions = {
        "thirdperson_view",
        "thirdperson_bind",
        "thirdperson_preventwallcollisions",
        "thirdperson_crosshair",
        "thirdperson_crosshaircolor",
        "thirdperson_scoping",
        "thirdperson_bulletcorrection",
        "thirdperson_distance",
        "thirdperson_viewangles",
        "thirdperson_entityview",
    };
end