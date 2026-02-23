AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if( BRICKS_SERVER.CONFIG.UNBOXING["Disable Case Collisions"] ) then
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	end
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:GetPhysicsObject():EnableMotion( false )

	self.deleteTimer = CurTime()+BRICKS_SERVER.CONFIG.UNBOXING["Case Open Time"]+10
end

function ENT:Think()
	if( self:GetCaseSet() ) then
		if( not IsValid( self.openerPly ) ) then
			self:Remove()
		end

		if( CurTime() >= self.caseOpenTime ) then
			if( IsValid( self.openerPly ) ) then
				self.openerPly:AddUnboxingInventoryItem( self:GetWinningItemKey() )
				BRICKS_SERVER.UNBOXING.Func.TryRollAndStoreStatTrak( self.openerPly, self:GetWinningItemKey() )
		
				local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( self:GetWinningItemKey() )
				if( configItemTable and configItemTable.Rarity and (BRICKS_SERVER.CONFIG.UNBOXING.NotificationRarities or {})[configItemTable.Rarity] ) then
					net.Start( "BRS.Net.UnboxCaseAlert" )
						net.WriteEntity( self.openerPly )
						net.WriteString( self:GetWinningItemKey() )
					net.Broadcast()
				end
		
				self.openerPly:SendUnboxingItemNotification( BRICKS_SERVER.Func.L( "unboxingCaseOpened" ), self:GetWinningItemKey(), 1 )
		
				self.openerPly:UpdateUnboxingStat( "cases", 1, true )
			end

			self:Remove()
		end
	end

	if( CurTime() >= self.deleteTimer ) then
		self:Remove()
	end

	self:NextThink( CurTime() ) 
	return true
end

function ENT:DoMyAnimationThing( SequenceName, PlaybackRate )
	PlaybackRate = PlaybackRate or 1
	local sequenceID, sequenceDuration = self:LookupSequence( SequenceName )
	if (sequenceID != -1) then
		self:ResetSequence(sequenceID)
		self:ResetSequenceInfo()
		self:SetCycle(0)
		return CurTime() + sequenceDuration * (1 / PlaybackRate) 
	else
		return CurTime()
	end
end

function ENT:OnRemove()

end

function ENT:OpenCase( caseKey, ply, winningItemKey, keyUsed )
	local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey] or {}
	local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels[configItemTable.Model or 0]

	if( not devConfigTable ) then 
		self:Remove()
		return 
	end

	if( configItemTable.Color ) then
		self:SetNWVector( "CaseColor", Color( configItemTable.Color.r, configItemTable.Color.g, configItemTable.Color.b ):ToVector() )
	end

	local keyUsedTable = BRICKS_SERVER.CONFIG.UNBOXING.Keys[keyUsed or 0]
	if( keyUsedTable and keyUsedTable.Color ) then
		self:SetNWVector( "KeyColor", Color( keyUsedTable.Color.r, keyUsedTable.Color.g, keyUsedTable.Color.b ):ToVector() )
	end

	self:SetBodygroup( 2, 1 )

	self:SetCaseKey( caseKey )
	self:SetModel( devConfigTable.Model )
	self:SetWinningItemKey( winningItemKey )
	self.openerPly = ply
	self:SetCaseSet( true )

	local sequenceID, sequenceDuration = self:LookupSequence( "open" )
	local openEndTime = self:DoMyAnimationThing( "open", 1/((BRICKS_SERVER.CONFIG.UNBOXING["Case Open Time"]-self.WinningItemDuration-0.5)/sequenceDuration) )

	self:SetCaseAnimTime( openEndTime )
	self.caseOpenTime = openEndTime+self.WinningItemDuration+0.5
end