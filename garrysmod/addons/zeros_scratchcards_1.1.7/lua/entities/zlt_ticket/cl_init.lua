include("shared.lua")

function ENT:Initialize()
	zlt.Ticket.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zlt.Ticket.Draw(self)
end

function ENT:Think()
end

function ENT:OnRemove()
end
