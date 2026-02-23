/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 15
	local ang = (ply:GetPos() - SpawnPos):Angle()
	ang = Angle(0, ang.y, 0)
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	zclib.Player.SetOwner(ent, ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	return ent
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phy = self:GetPhysicsObject()

	if IsValid(phy) then
		phy:Wake()
		phy:EnableMotion(true)
	end

	zclib.EntityTracker.Add(self)
	zbf.Controller.Initialize(self)
end

function ENT:AcceptInput(inputName, activator, caller, data)
	if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
		zbf.Controller.OnUse(self, activator)
	end
end

function ENT:OnRemove()
	zbf.Controller.OnRemove(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:OnTakeDamage(dmginfo)
	zbf.Controller.OnTakeDamage(self, dmginfo)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a
