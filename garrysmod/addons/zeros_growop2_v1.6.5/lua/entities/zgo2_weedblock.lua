/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

AddCSLuaFile()
DEFINE_BASECLASS("zgo2_item_base")
ENT.Type                    = "anim"
ENT.Base                    = "zgo2_item_base"
ENT.AutomaticFrameAdvance   = false
ENT.PrintName               = "WeedBlock"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros GrowOP 2"
ENT.Spawnable               = true
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_growop2/zgo2_weedblock.mdl"
ENT.RenderGroup             = RENDERGROUP_BOTH

function ENT:CanProperty(ply)
	return ply:IsSuperAdmin()
end

function ENT:CanTool(ply, tab, str)
	return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

function ENT:CanDrive(ply)
	return false
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "WeedID")
	self:NetworkVar("Int", 1, "Progress")

	if SERVER then
		self:SetWeedID(1)
		self:SetProgress(0)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

if SERVER then
	function ENT:PostInitialize()
		zgo2.Weedblock.Initialize(self)
	end

	function ENT:AcceptInput(inputName, activator, caller, data)
		if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
			zgo2.Weedblock.OnUse(self, ply)
		end
	end
end

if CLIENT then
	function ENT:Initialize()
		zgo2.Weedblock.Initialize(self)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c98d49b320af02372d954ba403147b52446efe45185e82d35620a577545ff88
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d95ede022471e32e4a4b21a5ceaeb1f2c170bb22540bb623b92f31411b4103f1

	function ENT:Think()
		zgo2.Weedblock.Think(self)
	end

	function ENT:Draw()
		self:DrawModel()
		zgo2.Weedblock.Draw(self)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c5b22d0c464981a2a2cb55407ea8523b955c581541c9aaa45b7d50e2253186c
