/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

AddCSLuaFile()
DEFINE_BASECLASS("zgo2_item_base")
ENT.Type                    = "anim"
ENT.Base                    = "zgo2_item_base"
ENT.AutomaticFrameAdvance   = false
ENT.PrintName               = "Jar Crate"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros GrowOP 2"
ENT.Spawnable               = true
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_growop2/zgo2_jarcrate.mdl"
ENT.RenderGroup             = RENDERGROUP_BOTH

function ENT:CanProperty(ply)
    return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

function ENT:CanTool(ply, tab, str)
    return ply:IsSuperAdmin()
end

function ENT:CanDrive(ply)
    return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c5b22d0c464981a2a2cb55407ea8523b955c581541c9aaa45b7d50e2253186c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

if SERVER then
	function ENT:Initialize()
		zgo2.JarCrate.Initialize(self)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	function ENT:OnRemove()
		zgo2.JarCrate.OnRemove(self)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

	function ENT:AcceptInput(inputName, activator, caller, data)
		if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
			zgo2.JarCrate.OnUse(self, activator)
		end
	end

	function ENT:StartTouch(other)
		zgo2.JarCrate.OnStartTouch(self, other)
	end
end
