/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

AddCSLuaFile()
DEFINE_BASECLASS("zgo2_item_base")
ENT.Type                    = "anim"
ENT.Base                    = "zgo2_item_base"
ENT.AutomaticFrameAdvance   = false
ENT.PrintName               = "Palette"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros GrowOP 2"
ENT.Spawnable               = true
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_growop2/zgo2_palette.mdl"
ENT.RenderGroup             = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c98d49b320af02372d954ba403147b52446efe45185e82d35620a577545ff88

function ENT:CanProperty(ply)
    return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c5b22d0c464981a2a2cb55407ea8523b955c581541c9aaa45b7d50e2253186c

function ENT:CanTool(ply, tab, str)
    return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function ENT:CanDrive(ply)
    return false
end

if SERVER then
	function ENT:Initialize()
		zgo2.Palette.Initialize(self)
	end

	function ENT:OnRemove()
		zgo2.Palette.OnRemove(self)
	end

	function ENT:AcceptInput(inputName, activator, caller, data)
		if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
			zgo2.Palette.OnUse(self, activator)
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c5b22d0c464981a2a2cb55407ea8523b955c581541c9aaa45b7d50e2253186c

	function ENT:StartTouch(other)
		zgo2.Palette.OnStartTouch(self, other)
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end
else
	function ENT:Initialize()
		zgo2.Palette.Initialize(self)
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:OnRemove()
		zgo2.Palette.OnRemove(self)
	end

	function ENT:Think()
		zgo2.Palette.Think(self)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
