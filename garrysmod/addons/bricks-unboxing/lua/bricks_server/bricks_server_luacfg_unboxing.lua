--[[ LUA CONFIG ]]--
BRICKS_SERVER.UNBOXING.LUACFG = {}
BRICKS_SERVER.UNBOXING.LUACFG.UseMySQL = true -- Whether or not MySQL should be used (enter your details in bricks-unboxing/lua/bricks_server/bricks_unboxing/sv_mysql.lua)

BRICKS_SERVER.UNBOXING.LUACFG.MenuCommands = {
    ["!unbox"] = true,
    ["/unbox"] = true,
    ["!bricksunboxing"] = true,
    ["/bricksunboxing"] = true
}

BRICKS_SERVER.UNBOXING.LUACFG.DefaultCurrency =  "darkrp_money" -- Options: darkrp_money, brcs_credits, mtokens, ps2_points, ps2_premium_points
BRICKS_SERVER.UNBOXING.LUACFG.TTT =  false -- Whether or not TTT is being used