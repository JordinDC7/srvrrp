AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/ogl/ogl_flag.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:GetPhysicsObject():EnableMotion( false )
	self:SetUseType( SIMPLE_USE )
end

function ENT:SetTerritoryKeyFunc( territoryKey )
	self:SetTerritoryKey( territoryKey )

	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
	if( not territoryTable or not territoryTable.Claimed ) then
		self:DoMyAnimationThing( "flagdown", 1, 1 )
	end
end

function ENT:DoMyAnimationThing( SequenceName, PlaybackRate, cycle )
	local sequenceID, sequenceDuration = self:LookupSequence( SequenceName )
	if (sequenceID != -1) then
		self:ResetSequence(sequenceID)
		self:SetPlaybackRate(25)
		self:ResetSequenceInfo()
		self:SetCycle( cycle or 0 )
		return CurTime() + sequenceDuration * (1 / PlaybackRate) 
	else
		return CurTime()
	end
end

function ENT:StartCapture( ply )
	if( IsValid( self:GetCaptor() ) ) then return end

	if( ply:GetPos():DistToSqr( self:GetPos() ) > BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] ) then return end

	self:SetCaptor( ply )
	self:SetCaptureEndTime( CurTime()+BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"] )

	self:SetPlaybackRate(-1)
	self:ResetSequence(0)

	local territoryKey = self:GetTerritoryKey()

	hook.Run( "BRS.Hooks.GangStartCapture", ply, ((BRICKS_SERVER.CONFIG.GANGS.Territories or {})[territoryKey] or {}).Name or "NIL" )
end

function ENT:StartUnCapture( ply )
	if( IsValid( self:GetCaptor() ) ) then return end

	if( ply:GetPos():DistToSqr( self:GetPos() ) > BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] ) then return end

	self:SetPlaybackRate(1)
	self:ResetSequence(0)

	self:SetCaptor( ply )
	self:SetUnCaptureEndTime( CurTime()+(BRICKS_SERVER.CONFIG.GANGS["Territory UnCapture Time"] or 60) )

	local territoryKey = self:GetTerritoryKey()
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
	if( not territoryTable ) then return end

	local gangTable = BRICKS_SERVER_GANGS[territoryTable.GangID or 0]
	
	if( not gangTable ) then return end

	local onlineMembers = {}
	for k, v in pairs( gangTable.Members ) do
		local memberPly = player.GetBySteamID( k )
		if( IsValid( memberPly ) ) then
			table.insert( onlineMembers, memberPly )
		end
	end

	DarkRP.notify( onlineMembers, 1, 5, BRICKS_SERVER.Func.L( "gangTerritoryBeingCaptured", ((BRICKS_SERVER.CONFIG.GANGS.Territories or {})[territoryKey] or {}).Name or "NIL" ) )

	hook.Run( "BRS.Hooks.GangStartUnCapture", ply, ((BRICKS_SERVER.CONFIG.GANGS.Territories or {})[territoryKey] or {}).Name or "NIL" )
end

function ENT:Use( ply )
	local plyGangID = ply:HasGang()

	if( not plyGangID ) then return end

	local territoryKey = self:GetTerritoryKey()
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
	if( not territoryTable ) then return end

	if( territoryTable.Claimed ) then
		if( territoryTable.GangID != plyGangID ) then
			self:StartUnCapture( ply )
		else
			DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangTerritoryAlready" ) )
		end
	else
		self:StartCapture( ply )
	end
end

function ENT:FinishCapture()
	if( not IsValid( self:GetCaptor() ) ) then return end

	local plyGangID = self:GetCaptor():HasGang()

	self:SetCaptor( nil )
	self:SetCaptureEndTime( 0 )

	if( not plyGangID ) then return end

	local territoryKey = self:GetTerritoryKey()
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
	if( not territoryTable ) then return end

	BRICKS_SERVER.Func.GangCaptureTerritory( plyGangID, territoryKey )
end

function ENT:FinishUnCapture()
	if( not IsValid( self:GetCaptor() ) ) then return end

	local ply = self:GetCaptor()
	local plyGangID = self:GetCaptor():HasGang()

	self:SetCaptor( nil )
	self:SetUnCaptureEndTime( 0 )

	if( not plyGangID ) then return end

	local territoryKey = self:GetTerritoryKey()
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
	if( not territoryTable ) then return end

	BRICKS_SERVER.Func.GangUnCaptureTerritory( plyGangID, territoryKey )

	self:StartCapture( ply )
end

function ENT:CancelCapture()
	if( IsValid( self:GetCaptor() ) ) then 
		DarkRP.notify( self:GetCaptor(), 1, 5, BRICKS_SERVER.Func.L( "gangCaptureFail" ) )
	end

	self:SetCaptor( nil )
	self:SetCaptureEndTime( 0 )
	self:SetUnCaptureEndTime( 0 )
end

function ENT:Think()
	if( IsValid( self:GetCaptor() ) ) then 
		if( CurTime() >= (self:GetCaptureEndTime() or 0) and (self:GetUnCaptureEndTime() or 0) <= 0 ) then
			self:FinishCapture()
		elseif( CurTime() >= (self:GetUnCaptureEndTime() or 0) and (self:GetCaptureEndTime() or 0) <= 0 ) then
			self:FinishUnCapture()
		end

		if( not IsValid( self:GetCaptor() ) or self:GetCaptor():GetPos():DistToSqr( self:GetPos() ) > BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] or not self:GetCaptor():Alive() ) then
			self:CancelCapture()
		end
	end
end