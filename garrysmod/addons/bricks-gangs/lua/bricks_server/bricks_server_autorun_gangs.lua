BRICKS_SERVER.GANGS = {}

local module = BRICKS_SERVER.Func.AddModule( "gangs", "Brick's Gangs", "materials/bricks_server/gangs.png", "1.7.6" )
module:AddSubModule( "achievements", "Achievements" )
module:AddSubModule( "associations", "Associations" )
module:AddSubModule( "leaderboards", "Leaderboards" )
module:AddSubModule( "printers", "Printers" )
module:AddSubModule( "storage", "Storage" )
module:AddSubModule( "territories", "Territories" )

hook.Add( "BRS.Hooks.BaseConfigLoad", "BricksServerHooks_BRS_BaseConfigLoad_Gangs", function()
    AddCSLuaFile( "bricks_server/bricks_gangs/sh_baseconfig.lua" )
    include( "bricks_server/bricks_gangs/sh_baseconfig.lua" )
end )

hook.Add( "BRS.Hooks.ClientConfigLoad", "BricksServerHooks_BRS_ClientConfigLoad_Gangs", function()
    AddCSLuaFile( "bricks_server/bricks_gangs/sh_clientconfig.lua" )
    include( "bricks_server/bricks_gangs/sh_clientconfig.lua" )
end )

hook.Add( "BRS.Hooks.DevConfigLoad", "BricksServerHooks_BRS_DevConfigLoad_Gangs", function()
    AddCSLuaFile( "bricks_server/bricks_gangs/sh_devconfig.lua" )
    include( "bricks_server/bricks_gangs/sh_devconfig.lua" )
end )

if( SERVER ) then
    resource.AddWorkshop( "2172708113" ) -- Brick's Gangs
    resource.AddWorkshop( "2136421687" ) -- Brick's Server

    hook.Add( "BRS.Hooks.SQLLoad", "BricksServerHooks_BRS_SQLLoad_Gangs", function()
        if( BRICKS_SERVER.GANGS.LUACFG.UseMySQL ) then
            include( "bricks_server/bricks_gangs/sv_mysql.lua" )
        else
            include( "bricks_server/bricks_gangs/sv_sqllite.lua" )
        end
    end )
end