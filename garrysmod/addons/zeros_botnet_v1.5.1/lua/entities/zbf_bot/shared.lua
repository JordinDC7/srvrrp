/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

ENT.Type                    = "anim"
ENT.Base                    = "base_anim"
ENT.AutomaticFrameAdvance   = false
ENT.PrintName               = "Bot"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros BotNet"
ENT.Spawnable               = false
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_clickfarm/zcf_bot_lvl01.mdl"
ENT.RenderGroup             = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "BotID")

	self:NetworkVar("Entity", 0, "Controller")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

	// What type of error is this?
	self:NetworkVar("Int", 1, "ErrorType")

	// When did the error start?
	self:NetworkVar("Int", 2, "ErrorStart")

	// How long will the error last?
	self:NetworkVar("Int",3, "ErrorTime")

	// Sets the level of the bot
	self:NetworkVar("Int", 4, "Level")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699


	if (SERVER) then
		self:SetBotID(1)
		self:SetController(NULL)
		self:SetErrorType(-1)
		self:SetErrorStart(-1)
		self:SetErrorTime(-1)
		self:SetLevel(1)
	end
end

function ENT:CanProperty(ply)
    return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

function ENT:CanTool(ply, tab, str)
    return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

function ENT:CanDrive(ply)
    return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401
