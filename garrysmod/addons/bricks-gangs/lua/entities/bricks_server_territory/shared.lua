ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Territory"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "TerritoryKey" )
    self:NetworkVar( "Int", 1, "CaptureEndTime" )
    self:NetworkVar( "Int", 2, "UnCaptureEndTime" )
    self:NetworkVar( "Entity", 0, "Captor" )
end