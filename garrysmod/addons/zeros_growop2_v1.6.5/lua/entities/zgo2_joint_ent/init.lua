/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	zclib.Player.SetOwner(ent, ply)

	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:UseClientSideAnimation()
	self:PhysWake()
	zclib.EntityTracker.Add(self)
	self.LastPickUp = CurTime() + 1
	zgo2.Destruction.SetupHealth(self)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d95ede022471e32e4a4b21a5ceaeb1f2c170bb22540bb623b92f31411b4103f1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

	if zgo2.config.DoobyTable.ColoredJoints then
		self:SetColor(zgo2.Plant.GetColor(self:GetWeedID()))
	end
end

function ENT:AcceptInput(input, activator, caller, data)
	if string.lower(input) == "use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
		if self.LastPickUp > CurTime() then return end
		self.LastPickUp = CurTime() + 1

		if activator:HasWeapon("zgo2_joint") == false then
			activator:Give("zgo2_joint", false)
			local joint = activator:GetWeapon("zgo2_joint")
			if not IsValid(joint) then return end
			if joint.SetWeedID == nil then return end
			joint:SetWeedID(self:GetWeedID())
			joint:SetWeedTHC(self:GetWeedTHC())
			joint:SetWeedAmount(self:GetWeedAmount())
			joint:SetIsBurning(self:GetIsBurning())
			activator:SelectWeapon("zgo2_joint")
			SafeRemoveEntity(self)
		else
			zclib.Notify(activator, "Player already has a joint!", 1)
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function ENT:OnTakeDamage(dmginfo)
	if not self.m_bApplyingDamage then
		self.m_bApplyingDamage = true
		self:TakeDamageInfo(dmginfo)
		zgo2.Destruction.OnDamaged(self, dmginfo)
		self.m_bApplyingDamage = false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
