BRICKS_SERVER.UNBOXING = {}
BRICKS_SERVER.UNBOXING.Func = {}

local module = BRICKS_SERVER.Func.AddModule( "unboxing", "Brick's Unboxing", "materials/bricks_server/unboxing.png", "1.6.5" )
module:AddSubModule( "marketplace", "Marketplace" )
module:AddSubModule( "rewards", "Rewards" )
module:AddSubModule( "trading", "Trading" )

hook.Add( "BRS.Hooks.BaseConfigLoad", "BricksServerHooks_BRS_BaseConfigLoad_Unboxing", function()
    AddCSLuaFile( "bricks_server/bricks_unboxing/sh_baseconfig.lua" )
    include( "bricks_server/bricks_unboxing/sh_baseconfig.lua" )
end )

hook.Add( "BRS.Hooks.ClientConfigLoad", "BricksServerHooks_BRS_ClientConfigLoad_Unboxing", function()
    AddCSLuaFile( "bricks_server/bricks_unboxing/sh_clientconfig.lua" )
    include( "bricks_server/bricks_unboxing/sh_clientconfig.lua" )
end )

hook.Add( "BRS.Hooks.DevConfigLoad", "BricksServerHooks_BRS_DevConfigLoad_Unboxing", function()
    AddCSLuaFile( "bricks_server/bricks_unboxing/sh_devconfig.lua" )
    include( "bricks_server/bricks_unboxing/sh_devconfig.lua" )
end )

if( SERVER ) then
    resource.AddWorkshop( "2303752974" ) -- Brick's Unboxing
    resource.AddWorkshop( "2136421687" ) -- Brick's Server

    hook.Add( "BRS.Hooks.SQLLoad", "BricksServerHooks_BRS_SQLLoad_Unboxing", function()
        if( BRICKS_SERVER.UNBOXING.LUACFG.UseMySQL ) then
            include( "bricks_server/bricks_unboxing/sv_mysql.lua" )
        else
            include( "bricks_server/bricks_unboxing/sv_sqllite.lua" )
        end
    end )
end