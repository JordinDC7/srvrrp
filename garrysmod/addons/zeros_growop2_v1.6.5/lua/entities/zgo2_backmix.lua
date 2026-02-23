/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

AddCSLuaFile()
DEFINE_BASECLASS("zgo2_item_base")
ENT.Type                    = "anim"
ENT.Base                    = "zgo2_item_base"
ENT.AutomaticFrameAdvance   = false
ENT.PrintName               = "Backmix"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros GrowOP 2"
ENT.Spawnable               = false
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_growop2/zgo2_backmix_muffin.mdl"
ENT.RenderGroup             = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2

function ENT:CanProperty(ply)
    return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function ENT:CanTool(ply, tab, str)
    return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2

function ENT:CanDrive(ply)
    return false
end

if SERVER then
	function ENT:PostInitialize()
		self:SetModel(zgo2.config.Edibles[self.EdibleID].backmix_model)
	end
end
