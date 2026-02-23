if( not BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "territories" ) ) then return end

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Brick's Gangs"
MODULE.Name = "Territories"
MODULE.Colour = Color( 201, 70, 70 )

MODULE:Setup(function()
	MODULE:Hook("BRS.Hooks.GangStartCapture", "BLogs.GangStartCapture", function( ply, territoryName )
		MODULE:Log("{1} started capturing the territory '" .. territoryName .. "'.", GAS.Logging:FormatPlayer(ply))
    end)
    
	MODULE:Hook("BRS.Hooks.GangStartUnCapture", "BLogs.GangStartUnCapture", function( ply, territoryName )
		MODULE:Log("{1} started uncapturing the territory '" .. territoryName .. "'.", GAS.Logging:FormatPlayer(ply))
	end)
end)

GAS.Logging:AddModule(MODULE)