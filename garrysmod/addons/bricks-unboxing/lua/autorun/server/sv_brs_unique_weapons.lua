--[[
    TEMPORARILY DISABLED - Testing if bricks inventory saves without our hooks
    This file does NOTHING except setup networking for the client diagnostic
]]--
if not SERVER then return end

util.AddNetworkString("BRS.UW.Sync")
util.AddNetworkString("BRS.UW.NewWeapon")

print("[BRS UW] Server DISABLED for inventory testing - no hooks active")
