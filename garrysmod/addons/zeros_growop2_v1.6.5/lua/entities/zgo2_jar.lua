/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

AddCSLuaFile()
DEFINE_BASECLASS("zgo2_item_base")
ENT.Type                    = "anim"
ENT.Base                    = "zgo2_item_base"
ENT.AutomaticFrameAdvance   = false
ENT.PrintName               = "Jar"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros GrowOP 2"
ENT.Spawnable               = true
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_growop2/zgo2_jar.mdl"
ENT.RenderGroup             = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

function ENT:CanProperty(ply)
    return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function ENT:CanTool(ply, tab, str)
    return ply:IsSuperAdmin()
end

function ENT:CanDrive(ply)
    return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "WeedID")
	self:NetworkVar("Int", 1, "WeedAmount")
	self:NetworkVar("Int", 2, "WeedTHC")

	if SERVER then
		self:SetWeedID(0)
		self:SetWeedAmount(0)
		self:SetWeedTHC(0)
	end
end

if SERVER then
	function ENT:PostInitialize()
		zgo2.Jar.Initialize(self)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	function ENT:AcceptInput(inputName, activator, caller, data)
		if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
			zgo2.Jar.OnUse(self, activator)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		zgo2.Jar.OnTouch(self, data.HitEntity)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c98d49b320af02372d954ba403147b52446efe45185e82d35620a577545ff88

if CLIENT then
	function ENT:Initialize()
		self:DestroyShadow()

		timer.Simple(0.5, function()
			if IsValid(self) then
				self.m_Initialized = true
			end
		end)
	end

	function ENT:Think()
		zgo2.Jar.Think(self)
	end

	function ENT:Draw()
		self:DrawModel()
		zgo2.Jar.Draw(self)
	end
end
