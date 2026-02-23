include("shared.lua")

function ENT:Initialize()
	zlt.Machine.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zlt.Machine.Draw(self)
end

function ENT:Think()
	zlt.Machine.Think(self)
end

function ENT:OnRemove()
	zlt.Machine.OnRemove(self)
end
