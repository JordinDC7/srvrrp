/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

ENT.Type                    = "anim"
ENT.Base                    = "base_anim"
ENT.AutomaticFrameAdvance   = false
ENT.PrintName               = "Controller"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros BotNet"
ENT.Spawnable               = true
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_clickfarm/zcf_controller.mdl"
ENT.RenderGroup             = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "JobID")
	self:NetworkVar("Float", 1, "JobProgress")
	self:NetworkVar("String", 0, "TargetName")

	if (SERVER) then
		self:SetJobID(-1)
		self:SetJobProgress(0)
		self:SetTargetName("")
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

function ENT:CanProperty(ply)
	return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

function ENT:CanTool(ply, tab, str)
	return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

function ENT:CanDrive(ply)
	return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e
