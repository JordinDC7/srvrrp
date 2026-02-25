ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Unboxing Case"
ENT.Category		= "Brick's Server"
ENT.Author			= "Brickwall"

ENT.Spawnable		= false
ENT.AutomaticFrameAdvance = true
ENT.WinningItemDuration = 0.5

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "CaseKey" )
	self:NetworkVar( "Int", 1, "CaseAnimTime" )
	self:NetworkVar( "String", 0, "WinningItemKey" )
	self:NetworkVar( "Bool", 0, "CaseSet" )
end