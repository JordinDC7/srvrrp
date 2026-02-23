--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561199109663690)

ServerGuard Plugin for !ThirdPerson Support
]]--

if serverguard then
    local plugin = plugin;

    plugin:IncludeFile( "shared.lua", SERVERGUARD.STATE.CLIENT );
end