/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 5
	local ang = (ply:GetPos() - SpawnPos):Angle()
	ang = Angle(0, 180 + ang.y, 0)
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	zclib.Player.SetOwner(ent, ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

	return ent
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function ENT:Initialize()
	zgo2.Destruction.SetupHealth(self)
	zgo2.Crate.Initialize(self)
end

function ENT:AcceptInput(inputName, activator, caller, data)
	if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
		zgo2.Crate.OnUse(self, activator)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d95ede022471e32e4a4b21a5ceaeb1f2c170bb22540bb623b92f31411b4103f1

function ENT:PhysicsCollide(data, physobj)
	zgo2.Crate.OnTouch(self, data.HitEntity)
end

function ENT:OnTakeDamage(dmginfo)
	-- Make sure we're not already applying damage a second time
	-- This prevents infinite loops
	if not self.m_bApplyingDamage then
		self.m_bApplyingDamage = true
		self:TakeDamageInfo(dmginfo)
		zgo2.Destruction.OnDamaged(self, dmginfo)
		self.m_bApplyingDamage = false
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
