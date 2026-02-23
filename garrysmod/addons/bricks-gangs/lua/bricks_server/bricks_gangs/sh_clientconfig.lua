--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame or use the f4menu
    !!WARNING!!
]]--

-- Gangs --
if( BRICKS_SERVER.Func.IsModuleEnabled( "gangs" ) ) then
    BRICKS_SERVER.BASECLIENTCONFIG.GangMenuBind = { BRICKS_SERVER.Func.L( "gangMenuBind" ), "bind", 0 }
end