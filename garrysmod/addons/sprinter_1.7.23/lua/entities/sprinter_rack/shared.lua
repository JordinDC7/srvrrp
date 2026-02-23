ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Printer Rack"
ENT.Author = "Stromic"
ENT.Category = "sPrinter"
ENT.Spawnable = true
ENT.isRack = true
ENT.sPrinter_ent = true
ENT.authorized = {}

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Power")
	self:NetworkVar("Bool",1,"Locked")
	self:NetworkVar("Entity",0,"owning_ent")
end