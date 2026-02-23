--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame or use the f4menu
    !!WARNING!!
]]--

-- Unboxing --
if( BRICKS_SERVER.Func.IsModuleEnabled( "unboxing" ) ) then
    BRICKS_SERVER.BASECLIENTCONFIG.UnboxingMenuBind = { BRICKS_SERVER.Func.L( "unboxingMenuBind" ), "bind", 0 }
end