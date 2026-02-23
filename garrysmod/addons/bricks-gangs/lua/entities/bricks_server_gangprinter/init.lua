AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:StartPrinting()
	self:DoMyAnimationThing( "fanson", 5 )
	self.sound:Play()
	self:SetNextPrint( CurTime()+self:GetPrintTime() )
end

function ENT:StopPrinting()
	self:DoMyAnimationThing( "fanson", 0 )
	self.sound:Stop()
	self:SetNextPrint( 0 )
end

function ENT:Initialize()
	self:SetModel( "models/ogl/ogl_bricksprinterrack.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.IncomeTrackTable = {}
	
	self:SetHolding( 0 )
	self:SetHoldingEXP( 0 )
	self:SetHealth( self:GetTotalHealth() )
	self:SetGangID( 0 )
	self:SetPrinterID( 0 )
	self:SetServerCount( 1 )
	self:SetTemperature( (BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[self:GetPrinterID()] or {}).BaseHeat or 0 )
	
	self:SetStatus( true )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
    self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
    self.sound:SetSoundLevel(52)
    self.sound:PlayEx(1, 100)
end

function ENT:SetServerCount( amount )
	self:SetServers( math.min( BRICKS_SERVER.DEVCONFIG.GangPrinterSlots, amount ) )

	for i = 1, amount do
		self:SetBodygroup( i, 1 )
	end
end

function ENT:Think()
	local printerConfigTable = BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[self:GetPrinterID()] or {}

	if( self:GetStatus() ) then
		if( (self:GetNextPrint() or 0) > 0 ) then
			if( CurTime() >= self:GetNextPrint() ) then
				self:SetHolding( self:GetHolding()+self:GetPrintAmount() )
				self:SetHoldingEXP( self:GetHoldingEXP()+100 )
				self:SetTemperature( math.Clamp( self:GetTemperature()*1.1, (printerConfigTable.BaseHeat or 0), (printerConfigTable.BaseHeat or 0)+self:GetTargetTemp() ) )
				self:SetNextPrint( CurTime()+self:GetPrintTime() )
			end
		else
			self:StartPrinting()
		end
	else
		if( (self:GetNextPrint() or 0) > 0 ) then
			self:StopPrinting()
		end
	end

	if( self:GetTemperature() >= (printerConfigTable.MaxHeat or 60) ) then
		self:Overheat()
	end
	
	if( not self.sound ) then
		self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
		self.sound:SetSoundLevel(52)
		self.sound:PlayEx(1, 100)
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:OnTakeDamage( dmgInfo )
	self:SetHealth( math.max( self:Health()-dmgInfo:GetDamage(), 0 ) )

	if( self:Health() <= 0 ) then
		self:Overheat()
	end
end

function ENT:Overheat()
	if( self:GetOverheated() != true ) then
		self:SetOverheated( true )
		self:Ignite( 2 )

		timer.Simple( 2, function()
			if( IsValid( self ) ) then
				local vPoint = self:GetPos()
				local effectdata = EffectData()
				effectdata:SetStart(vPoint)
				effectdata:SetOrigin(vPoint)
				effectdata:SetScale(1)
				util.Effect("Explosion", effectdata)

				self:Remove()
			end
		end )
	end
end

function ENT:DoMyAnimationThing( SequenceName, PlaybackRate )
	local sequenceID = self:LookupSequence( SequenceName )
	self:ResetSequenceInfo()
	self:ResetSequence( sequenceID )
	self:SetPlaybackRate( PlaybackRate )
	self:SetCycle( 0 )
end

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng+Angle( 0, 180, 0 ) )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:OnRemove()
	if( self.sound ) then
		self.sound:Stop()
	end

	if( timer.Exists( tostring( self ) .. "_GangPrinterTimer" ) ) then
		timer.Remove( tostring( self ) .. "_GangPrinterTimer" )
	end
end

function BRICKS_SERVER.Func.GangGetPrinterEnt( gangID, printerID )
	if( BRS_ACTIVE_GANGPRINTERS and BRS_ACTIVE_GANGPRINTERS[gangID] and BRS_ACTIVE_GANGPRINTERS[gangID][printerID] and IsValid( BRS_ACTIVE_GANGPRINTERS[gangID][printerID] ) ) then
		return BRS_ACTIVE_GANGPRINTERS[gangID][printerID]
	end
end

util.AddNetworkString( "BRS.Net.GangPrinterIncomeTrackRequest" )
util.AddNetworkString( "BRS.Net.GangPrinterIncomeTrackSend" )
net.Receive( "BRS.Net.GangPrinterIncomeTrackRequest", function( len, ply ) 
	local printerEntity = net.ReadEntity()

	if( not printerEntity or not IsValid( printerEntity ) or printerEntity:GetClass() != "bricks_server_gangprinter" ) then return end

	local Distance = ply:GetPos():DistToSqr( printerEntity:GetPos() )

	if( Distance >= BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then return end

	if( not printerEntity.IncomeTrackTable ) then return end

	net.Start( "BRS.Net.GangPrinterIncomeTrackSend" )
		net.WriteEntity( printerEntity )
		net.WriteTable( printerEntity.IncomeTrackTable )
	net.Send( ply )
end )

local function CheckCanUsePrinter( ply, printerEntity )
	if( not printerEntity or not IsValid( printerEntity ) or printerEntity:GetClass() != "bricks_server_gangprinter" ) then return false end

	if( ply:GetPos():DistToSqr( printerEntity:GetPos() ) >= 20000 ) then return false end

	local trace = ply:GetEyeTrace()
	return trace != nil and IsValid( trace.Entity ) and trace.Entity == printerEntity
end

util.AddNetworkString( "BRS.Net.GangPrinterToggle" )
net.Receive( "BRS.Net.GangPrinterToggle", function( len, ply ) 
	local printerEntity = net.ReadEntity()

	if( not CheckCanUsePrinter( ply, printerEntity ) ) then return end

	printerEntity:SetStatus( not printerEntity:GetStatus() )

	DarkRP.notify( ply, 1, 4, "Printer status toggled!" )
end )

util.AddNetworkString( "BRS.Net.GangPrinterWithdraw" )
net.Receive( "BRS.Net.GangPrinterWithdraw", function( len, ply ) 
	local printerEntity = net.ReadEntity()

	if( not CheckCanUsePrinter( ply, printerEntity ) ) then return end

	local money = printerEntity:GetHolding()
	if( money > 0 ) then
		ply:addMoney( money )

		if( ply:GetGangID() != 0 ) then
			BRICKS_SERVER.Func.AddGangExperience( ply:GetGangID(), printerEntity:GetHoldingEXP(), ply )
		end

		DarkRP.notify( ply, 1, 4, "You withdrew " .. DarkRP.formatMoney( money ) .. " from a printer!" )

		printerEntity:SetHolding( 0 )
		printerEntity:SetHoldingEXP( 0 )

		hook.Run( "BRS.Hooks.GangPrinterWithdrew", ply, money )
	end
end )

util.AddNetworkString( "BRS.Net.GangPrinterPlace" )
net.Receive( "BRS.Net.GangPrinterPlace", function( len, ply ) 
	local gangID = ply:GetGangID()
	local gangTable = BRICKS_SERVER_GANGS[gangID]

	if( not gangTable or not ply:GangHasPermission( "PlacePrinters" ) ) then return end

	local printerID = net.ReadUInt( 8 )

	if( not printerID ) then return end

	local printerConfigTable = BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[printerID]

	if( not printerConfigTable ) then return end

	local gangPrinterTable = (gangTable.Printers or {})[printerID]

	if( not gangPrinterTable ) then return end

	if( BRICKS_SERVER.Func.GangGetPrinterEnt( gangID, printerID ) ) then
		DarkRP.notify( ply, 1, 5, "This printer has already been placed, it must destroyed before replacing it!" )
		return
	end

	local printerEnt = ents.Create( "bricks_server_gangprinter" )
	printerEnt:SetAngles( ply:GetAngles() )
	printerEnt:SetPos( ply:GetPos()+(ply:GetForward()*60)+(printerEnt:GetUp()*25) )
	printerEnt:Spawn()
	printerEnt:DropToFloor()
	if( printerEnt.CPPISetOwner ) then printerEnt:CPPISetOwner( ply ) end
	if( printerEnt.Setowning_ent ) then printerEnt:Setowning_ent( ply ) end

	printerEnt:SetGangID( gangID )
	printerEnt:SetPrinterID( printerID )
	printerEnt:SetServerCount( #(gangPrinterTable.Servers or {}) )
	printerEnt:SetTemperature( printerConfigTable.BaseHeat or 0 )

	for k, v in ipairs( gangPrinterTable.Servers or {} ) do
		for key, val in pairs( v ) do
			if( not BRICKS_SERVER.DEVCONFIG.GangServerUpgradeTypes[key] or not BRICKS_SERVER.DEVCONFIG.GangServerUpgradeTypes[key].SetFunc ) then return end

			BRICKS_SERVER.DEVCONFIG.GangServerUpgradeTypes[key].SetFunc( printerEnt, k, val, BRICKS_SERVER.CONFIG.GANGPRINTERS.ServerUpgrades[key] )
		end
	end

	for k, v in pairs( gangPrinterTable.Upgrades or {} ) do
		if( not BRICKS_SERVER.DEVCONFIG.GangPrinterUpgradeTypes[k] or not BRICKS_SERVER.DEVCONFIG.GangPrinterUpgradeTypes[k].SetFunc ) then return end

		BRICKS_SERVER.DEVCONFIG.GangPrinterUpgradeTypes[k].SetFunc( printerEnt, v )
	end

	printerEnt:SetHealth( printerEnt:GetTotalHealth() )

	BRS_ACTIVE_GANGPRINTERS = BRS_ACTIVE_GANGPRINTERS or {}
	BRS_ACTIVE_GANGPRINTERS[gangID] = BRS_ACTIVE_GANGPRINTERS[gangID] or {}
	BRS_ACTIVE_GANGPRINTERS[gangID][printerID] = printerEnt
end )

util.AddNetworkString( "BRS.Net.GangPrinterPurchase" )
net.Receive( "BRS.Net.GangPrinterPurchase", function( len, ply ) 
	local gangID = ply:GetGangID()
	local gangTable = BRICKS_SERVER_GANGS[gangID]

	if( not gangTable or not ply:GangHasPermission( "PurchasePrinters" ) ) then return end

	local printerID = net.ReadUInt( 8 )

	if( not printerID ) then return end

	local printerConfigTable = BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[printerID]

	if( not printerConfigTable ) then return end

	local gangPrinters = gangTable.Printers or {}

	if( gangPrinters[printerID] ) then return end

	if( (gangTable.Money or 0) < (printerConfigTable.Price or 0) ) then
		DarkRP.notify( ply, 1, 4, "Your gang cannot afford this!" )
		return
	end

	gangPrinters[printerID] = {
		Servers = {
			[1] = {}
		},
		Upgrades = {}
	}

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Money", math.max( (gangTable.Money or 0)-(printerConfigTable.Price or 0), 0 ), "Printers", gangPrinters )

	BRICKS_SERVER.Func.InsertGangPrinterDB( gangID, printerID, gangPrinters[printerID].Servers, gangPrinters[printerID].Upgrades )

	DarkRP.notify( ply, 1, 4, "Successfully purchased " .. printerConfigTable.Name .. " for your gang!" )
end )

util.AddNetworkString( "BRS.Net.GangPrinterBuyServer" )
net.Receive( "BRS.Net.GangPrinterBuyServer", function( len, ply ) 
	local gangID = ply:GetGangID()
	local gangTable = BRICKS_SERVER_GANGS[gangID]

	if( not gangTable or not ply:GangHasPermission( "PurchasePrinters" ) ) then return end

	local printerID = net.ReadUInt( 8 )
	local serverID = net.ReadUInt( 4 )

	if( not printerID or not serverID ) then return end

	local printerConfigTable = BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[printerID]

	if( not printerConfigTable ) then return end

	local gangPrinters = gangTable.Printers or {}
	local printerTable = gangPrinters[printerID]

	if( not printerTable ) then return end

	if( serverID != #printerTable.Servers+1 ) then 
		DarkRP.notify( ply, 1, 4, "You must buy the server's in order!" )
		return 
	end

	if( serverID > BRICKS_SERVER.DEVCONFIG.GangPrinterSlots ) then return end

	local serverPrice = (printerConfigTable.ServerPrices or {})[serverID] or 0
	if( (gangTable.Money or 0) < serverPrice ) then
		DarkRP.notify( ply, 1, 4, "Your gang cannot afford this!" )
		return
	end

	printerTable.Servers = printerTable.Servers or {}
	table.insert( printerTable.Servers, {} )

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Money", math.max( (gangTable.Money or 0)-serverPrice, 0 ), "Printers", gangPrinters )

	BRICKS_SERVER.Func.UpdateGangPrinterDB( gangID, printerID, printerTable.Servers )

	local printerEnt = BRICKS_SERVER.Func.GangGetPrinterEnt( gangID, printerID )
	if( IsValid( printerEnt ) ) then
		printerEnt:SetServerCount( #printerTable.Servers )
	end

	DarkRP.notify( ply, 1, 4, "Successfully purchased a new server the gang's " .. printerConfigTable.Name .. "!" )
end )

util.AddNetworkString( "BRS.Net.GangPrinterBuyServerUpgrade" )
net.Receive( "BRS.Net.GangPrinterBuyServerUpgrade", function( len, ply ) 
	local gangID = ply:GetGangID()
	local gangTable = BRICKS_SERVER_GANGS[gangID]

	if( not gangTable or not ply:GangHasPermission( "UpgradePrinters" ) ) then return end

	local printerID = net.ReadUInt( 8 )
	local serverID = net.ReadUInt( 3 )
	local upgradeType = net.ReadString()

	if( not printerID or not serverID or serverID > BRICKS_SERVER.DEVCONFIG.GangPrinterSlots or not upgradeType ) then return end

	local upgradeConfigTable, upgradeDevConfigTable = BRICKS_SERVER.CONFIG.GANGPRINTERS.ServerUpgrades[upgradeType], BRICKS_SERVER.DEVCONFIG.GangServerUpgradeTypes[upgradeType]

	if( not BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[printerID] or not upgradeConfigTable or not upgradeDevConfigTable or not upgradeConfigTable.Tiers ) then return end

	local gangPrinters = gangTable.Printers or {}
	local printerTable = gangPrinters[printerID]

	if( not printerTable ) then return end

	local serverTable = (printerTable.Servers or {})[serverID]

	if( not serverTable ) then return end

	local currentTier = serverTable[upgradeType] or 0
	local maxTier = #upgradeConfigTable.Tiers
	local nextTier = currentTier+1

	if( currentTier >= maxTier or not upgradeConfigTable.Tiers[nextTier] ) then return end

	local nextUpgradePrice = upgradeConfigTable.Tiers[nextTier].Price or 0
	if( (gangTable.Money or 0) < nextUpgradePrice ) then
		DarkRP.notify( ply, 1, 4, "Your gang cannot afford this!" )
		return
	end

	if( upgradeConfigTable.Tiers[nextTier].Group and not BRICKS_SERVER.Func.IsInGroup( ply, upgradeConfigTable.Tiers[nextTier].Group ) ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangIncorrectGroup" ) )
		return
	end

	if( upgradeConfigTable.Tiers[nextTier].Level and BRICKS_SERVER.Func.GangGetLevel( ply:GetGangID() ) < upgradeConfigTable.Tiers[nextTier].Level ) then
		DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangIncorrectLevel" ) )
		return
	end

	serverTable[upgradeType] = nextTier

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Money", math.max( (gangTable.Money or 0)-nextUpgradePrice, 0 ), "Printers", gangPrinters )

	BRICKS_SERVER.Func.UpdateGangPrinterDB( gangID, printerID, printerTable.Servers )

	local printerEnt = BRICKS_SERVER.Func.GangGetPrinterEnt( gangID, printerID )
	if( IsValid( printerEnt ) and upgradeDevConfigTable.SetFunc ) then
		upgradeDevConfigTable.SetFunc( printerEnt, serverID, nextTier, upgradeConfigTable )
	end

	DarkRP.notify( ply, 1, 4, "Successfully upgraded the " .. upgradeConfigTable.Name .. " for " .. DarkRP.formatMoney( nextUpgradePrice ) .. "!" )
end )

util.AddNetworkString( "BRS.Net.GangPrinterBuyUpgrade" )
net.Receive( "BRS.Net.GangPrinterBuyUpgrade", function( len, ply ) 
	local gangID = ply:GetGangID()
	local gangTable = BRICKS_SERVER_GANGS[gangID]

	if( not gangTable or not ply:GangHasPermission( "UpgradePrinters" ) ) then return end

	local printerID = net.ReadUInt( 8 )
	local upgradeType = net.ReadString()

	if( not printerID or not upgradeType ) then return end

	local upgradeConfigTable, upgradeDevConfigTable = BRICKS_SERVER.CONFIG.GANGPRINTERS.Upgrades[upgradeType], BRICKS_SERVER.DEVCONFIG.GangPrinterUpgradeTypes[upgradeType]

	if( not BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[printerID] or not upgradeConfigTable or not upgradeDevConfigTable ) then return end

	local gangPrinters = gangTable.Printers or {}
	local printerTable = gangPrinters[printerID]

	if( not printerTable ) then return end

	printerTable.Upgrades = printerTable.Upgrades or {}

	local upgradeCost = 0
	local newValue
	if( upgradeConfigTable.Tiers ) then
		local currentTier = printerTable.Upgrades[upgradeType] or 0
		local maxTier = #upgradeConfigTable.Tiers
		local nextTier = currentTier+1

		if( currentTier >= maxTier or not upgradeConfigTable.Tiers[nextTier] ) then return end

		upgradeCost = upgradeConfigTable.Tiers[nextTier].Price or 0
		newValue = nextTier
	else
		if( printerTable.Upgrades[upgradeType] ) then return end

		upgradeCost = upgradeConfigTable.Price or 0
		newValue = true
	end

	if( (gangTable.Money or 0) < upgradeCost ) then
		DarkRP.notify( ply, 1, 4, "Your gang cannot afford this!" )
		return
	end

	printerTable.Upgrades[upgradeType] = newValue

	BRICKS_SERVER.Func.UpdateGangTable( gangID, "Money", math.max( (gangTable.Money or 0)-upgradeCost, 0 ), "Printers", gangPrinters )

	BRICKS_SERVER.Func.UpdateGangPrinterDB( gangID, printerID, false, printerTable.Upgrades )

	local printerEnt = BRICKS_SERVER.Func.GangGetPrinterEnt( gangID, printerID )
	if( IsValid( printerEnt ) and upgradeDevConfigTable.SetFunc ) then
		upgradeDevConfigTable.SetFunc( printerEnt, newValue )
	end

	DarkRP.notify( ply, 1, 4, "Successfully upgraded the " .. upgradeConfigTable.Name .. " for " .. DarkRP.formatMoney( upgradeCost ) .. "!" )
end )