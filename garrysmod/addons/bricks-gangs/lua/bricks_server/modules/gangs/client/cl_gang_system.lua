BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "gangVariables" ), "bricks_server_config_gangs", "gangs" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "gangUpgrades" ), "bricks_server_config_gang_upgrades", "gangs" )

net.Receive( "BRS.Net.OpenGangMenu", function()
    if( not IsValid( BRICKS_SERVER_GANGMENU ) ) then
		BRICKS_SERVER_GANGMENU = vgui.Create( "bricks_server_gangmenu" )
	elseif( not BRICKS_SERVER_GANGMENU:IsVisible() ) then
		BRICKS_SERVER_GANGMENU:SetVisible( true )
    end
end )

function BRICKS_SERVER.Func.RequestGangCommandData()
    if( not LocalPlayer():HasGang() ) then return end

    net.Start( "BRS.Net.RequestGangCommandData" )
    net.SendToServer()
end

net.Receive( "BRS.Net.SendGangCommandData", function()
    local gangID = net.ReadUInt( 16 )

    BRS_GANG_COMMANDDATA = BRS_GANG_COMMANDDATA or {}
    BRS_GANG_COMMANDDATA[gangID] = net.ReadTable() or {}

    hook.Run( "BRS.Hooks.GangCommandDataUpdated", gangID )
end )

hook.Add( "PlayerButtonDown", "BricksServerHooks_PlayerButtonDown_OpenGangMenu", function( ply, button )
	local bindText, bindButton = BRICKS_SERVER.Func.GetClientBind( "GangMenuBind" )
	if( button == bindButton and CurTime() >= (BRS_GANGMENUCOOLDOWN or 0) ) then
		BRS_GANGMENUCOOLDOWN = CurTime()+1
		RunConsoleCommand( "gang" )
	end
end )

net.Receive( "BRS.Net.GangNetworkMessage", function()
	local gangID = LocalPlayer():GetGangID()

	if( not BRS_GANG_CHATS ) then
		BRS_GANG_CHATS = {}
	end

	if( not BRS_GANG_CHATS[gangID] ) then
		BRS_GANG_CHATS[gangID] = {}
	end

	local messageKey = table.insert( BRS_GANG_CHATS[gangID], { (net.ReadInt( 32 ) or 0), net.ReadString(), net.ReadString() } )

	hook.Run( "BRS.Hooks.InsertGangChat", messageKey )
end )

function BRICKS_SERVER.Func.RequestPlyGangInfo( plySteamID )
    if( CurTime() < (BRS_REQUEST_PLYGANGINFO_COOLDOWN or 0) ) then return end

    BRS_REQUEST_PLYGANGINFO_COOLDOWN = CurTime()+1

	net.Start( "BRS.Net.RequestPlyGangInfo" )
		net.WriteString( plySteamID )
    net.SendToServer()
end

net.Receive( "BRS.Net.SendPlyGangInfo", function()
    if( not BRS_PLYGANGINFO ) then
        BRS_PLYGANGINFO = {}
    end

	local plySteamID = net.ReadString()

	if( not plySteamID ) then return end

	local hasGang = net.ReadBool()
	if( hasGang ) then
		local gangName, gangIcon, groupName, groupColor = net.ReadString(), net.ReadString(), net.ReadString(), net.ReadColor()

		BRS_PLYGANGINFO[plySteamID] = {
			Name = gangName,
			GroupName = groupName,
			GroupColor = groupColor
		}

		if( gangIcon ) then
			BRICKS_SERVER.Func.GetImage( gangIcon, function( mat ) 
				BRS_PLYGANGINFO[plySteamID].Icon  = mat 
			end )
		end
	else
		BRS_PLYGANGINFO[plySteamID] = {}
	end

	timer.Simple( 10, function () 
		BRS_PLYGANGINFO[plySteamID] = nil
	end )
end )

local questionMat = Material( "bricks_server/question.png" )
hook.Add( "HUDPaint", "BricksServerHooks_HUDPaint_DrawGangInfo", function()
    if( not LocalPlayer():Alive() ) then return end

	local ply = LocalPlayer():GetEyeTrace().Entity
	
	if( not IsValid( ply ) or not ply:IsPlayer() ) then return end
    
    local Distance = LocalPlayer():GetPos():DistToSqr( ply:GetPos() )
	if( Distance > (BRICKS_SERVER.CONFIG.GANGS["Gang Display Distance"] or 10000) ) then return end
	
	if( ply:GetGangID() <= 0 ) then return end
	
	local plyGangInfo = (BRS_PLYGANGINFO or {})[(not ply:IsBot() and ply:SteamID()) or ""]
	if( not plyGangInfo and not ply:IsBot() ) then
		BRICKS_SERVER.Func.RequestPlyGangInfo( ply:SteamID() )
		return
	end

	local gangName = (plyGangInfo or {}).Name or BRICKS_SERVER.Func.L( "gangNone" )
	local groupName = (plyGangInfo or {}).GroupName or "None"

	surface.SetFont( "BRICKS_SERVER_Font23" )
	local nameX, nameY = surface.GetTextSize( gangName )

	surface.SetFont( "BRICKS_SERVER_Font17" )
	local groupNameX, groupNameY = surface.GetTextSize( groupName )

	local h = 65
	local w = h+10+math.max( nameX, groupNameX )+20
	local x, y = (ScrW()/2)-(w/2), (ScrH()*0.9)-(h/2)

	draw.SimpleText( BRICKS_SERVER.Func.L( "gangInfo" ), "BRICKS_SERVER_Font20", x+w/2, y-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )	

	BRICKS_SERVER.BSHADOWS.BeginShadow()
	draw.RoundedBox( h/2, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )	
	BRICKS_SERVER.BSHADOWS.EndShadow( 1, 2, 2, 255, 0, 0, false )

	local iconSize = h-8
	
	surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
	draw.NoTexture()
	BRICKS_SERVER.Func.DrawCircle( x+(h/2), y+(h/2), iconSize/2, 45 )

	render.ClearStencil()
	render.SetStencilEnable( true )

	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )

	render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilPassOperation( STENCILOPERATION_ZERO )
	render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
	render.SetStencilReferenceValue( 1 )

	draw.NoTexture()
	surface.SetDrawColor( 0, 0, 0, 255 )
	BRICKS_SERVER.Func.DrawCircle( x+(h/2), y+(h/2), iconSize/2, 45 )

	render.SetStencilFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilReferenceValue( 1 )

	iconSize = (not (plyGangInfo or {}).Icon and 32) or iconSize

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( (plyGangInfo or {}).Icon or questionMat )
	surface.DrawTexturedRect( x+(h-iconSize)/2, y+(h-iconSize)/2, iconSize, iconSize )

	render.SetStencilEnable( false )
	render.ClearStencil()

	draw.SimpleText( gangName, "BRICKS_SERVER_Font23", x+h+10, y+h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( groupName, "BRICKS_SERVER_Font17", x+h+10, y+h/2-2, ((plyGangInfo or {}).GroupColor or BRICKS_SERVER.Func.GetTheme( 6 )), 0, 0 )
end )
