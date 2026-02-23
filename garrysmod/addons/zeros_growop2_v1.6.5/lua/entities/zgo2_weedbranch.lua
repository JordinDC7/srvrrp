/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

AddCSLuaFile()
DEFINE_BASECLASS("zgo2_item_base")
ENT.Type                    = "anim"
ENT.Base                    = "zgo2_item_base"
ENT.AutomaticFrameAdvance   = false
ENT.PrintName               = "Weed Branch"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros GrowOP 2"
ENT.Spawnable               = true
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_growop2/zgo2_weedstick.mdl"
ENT.RenderGroup             = RENDERGROUP_OPAQUE
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c5b22d0c464981a2a2cb55407ea8523b955c581541c9aaa45b7d50e2253186c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

function ENT:CanProperty(ply)
	return ply:IsSuperAdmin()
end

function ENT:CanTool(ply, tab, str)
	return ply:IsSuperAdmin()
end

function ENT:CanDrive(ply)
	return false
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "PlantID")
	self:NetworkVar("Bool", 0, "IsDried")

	if SERVER then
		self:SetPlantID(1)
		self:SetIsDried(false)
		//self:SetPlantID(zgo2.Plant.GetRandomID())
	end
end

if SERVER then
	function ENT:Initialize()
		zgo2.Weedbranch.Initialize(self)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

	function ENT:AcceptInput(inputName, activator, caller, data)
		if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
			zgo2.Weedbranch.OnUse(self, activator)
		end
	end
end

if CLIENT then
	function ENT:Initialize()
		self:DestroyShadow()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c5b22d0c464981a2a2cb55407ea8523b955c581541c9aaa45b7d50e2253186c

		timer.Simple(0.5, function()
			if IsValid(self) then
				self.m_Initialized = true
			end
		end)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	function ENT:Think()
		if zgo2.Plant.UpdateMaterials[ self ] == nil then
			zgo2.Plant.UpdateMaterials[ self ] = true
		end
	end
end
