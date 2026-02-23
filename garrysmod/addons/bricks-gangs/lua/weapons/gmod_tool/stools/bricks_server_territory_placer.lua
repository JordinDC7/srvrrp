TOOL.Category = "Bricks Server"
TOOL.Name = "Territory Placer"
TOOL.Command = nil
TOOL.ConfigName = ""

function TOOL:LeftClick( trace )
	if( !trace.HitPos || IsValid( trace.Entity ) && trace.Entity:IsPlayer() ) then return false end
	if( CLIENT ) then return true end

	local ply = self:GetOwner()
	
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
		DarkRP.notify( ply, 1, 2, BRICKS_SERVER.Func.L( "noToolPermission" ) )
		return
	end

	if( not BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "territories" ) ) then return end

	if( BRICKS_SERVER.CONFIG.GANGS.Territories[ply:GetNW2Int( "bricks_server_tool_territorykey" )] ) then
		local entity = ents.Create( "bricks_server_territory" )
		entity:SetPos( trace.HitPos )
		local EntAngles = entity:GetAngles()
		local PlayerAngle = ply:GetAngles()
		entity:SetAngles( Angle( EntAngles.p, PlayerAngle.y+180, EntAngles.r ) )
		entity:Spawn()
		entity:SetTerritoryKeyFunc( ply:GetNW2Int( "bricks_server_tool_territorykey" ) )
		
		DarkRP.notify( ply, 1, 2, BRICKS_SERVER.Func.L( "gangTerritoryPlaced" ) )
		ply:ConCommand( "bricks_server_saveentpositions" )
	else
		DarkRP.notify( ply, 1, 2, BRICKS_SERVER.Func.L( "gangInvalidTerritory" ) )
	end
end
 
function TOOL:RightClick( trace )
	if( !trace.HitPos ) then return false end
	if( !IsValid( trace.Entity ) or trace.Entity:IsPlayer() ) then return false end
	if( CLIENT ) then return true end

	local ply = self:GetOwner()
	
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
		DarkRP.notify( ply, 1, 2, BRICKS_SERVER.Func.L( "noToolPermission" ) )
		return
	end
	
	if( trace.Entity:GetClass() == "bricks_server_territory" ) then
		trace.Entity:Remove()
		DarkRP.notify( ply, 1, 2, BRICKS_SERVER.Func.L( "gangTerritoryRemoved" ) )
		ply:ConCommand( "bricks_server_saveentpositions" )
	else
		DarkRP.notify( ply, 1, 2, BRICKS_SERVER.Func.L( "gangTerritoryRemoveFail" ) )
		return false
	end
end

function TOOL:DrawToolScreen( width, height )
	if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

	surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
	surface.DrawRect( 0, 0, width, height )

	surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
	surface.DrawRect( 0, 0, width, 60 )
	
	draw.SimpleText( language.GetPhrase( "tool.bricks_server_territory_placer.name" ), "BRICKS_SERVER_Font33", width/2, 30, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	if( not BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "territories" ) ) then return end

	local territorySelected = (BRICKS_SERVER.CONFIG.GANGS.Territories or {})[LocalPlayer():GetNW2Int( "bricks_server_tool_territorykey", 0 )]
	draw.SimpleText( BRICKS_SERVER.Func.L( "selected" ), "BRICKS_SERVER_Font33", width/2, 60+((height-60)/2)-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( ((territorySelected and (territorySelected.Name or BRICKS_SERVER.Func.L( "error" ))) or BRICKS_SERVER.Func.L( "none" )), "BRICKS_SERVER_Font25", width/2, 60+((height-60)/2)-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = BRICKS_SERVER.Func.L( "gangTerritory" ), Description = BRICKS_SERVER.Func.L( "gangTerritoryDesc" ) })

	if( not BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "territories" ) ) then return end

	local combo = panel:AddControl( "ComboBox", { Label = BRICKS_SERVER.Func.L( "gangTerritory" ) } )
	for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Territories or {} ) do
		combo:AddOption( v.Name, { k } )
	end
	function combo:OnSelect( index, text, data )
		net.Start( "BRS.Net.ToolTerritoryPlacer" )
			net.WriteUInt( data[1], 8 )
		net.SendToServer()
	end
end

if( CLIENT ) then
	language.Add( "tool.bricks_server_territory_placer.name", BRICKS_SERVER.Func.L( "gangTerritoryPlacer" ) )
	language.Add( "tool.bricks_server_territory_placer.desc", BRICKS_SERVER.Func.L( "gangTerritoryDescSmall" ) )
	language.Add( "tool.bricks_server_territory_placer.0", BRICKS_SERVER.Func.L( "gangTerritoryInstructions" ) )
elseif( SERVER and BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "territories" ) ) then
	util.AddNetworkString( "BRS.Net.ToolTerritoryPlacer" )
	net.Receive( "BRS.Net.ToolTerritoryPlacer", function( len, ply )
		if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

		ply:SetNW2Int( "bricks_server_tool_territorykey", net.ReadUInt( 8 ) )
	end )
end