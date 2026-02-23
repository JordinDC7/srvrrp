include("shared.lua")

function ENT:Initialize()
	self.logs = {}
end

function ENT:Draw()
	self:DrawModel()
	
	if !sPrinter then return end

	if sPrinter.config["logo"][self.Base].enabled then
		sPrinter.drawLogo(self, sPrinter.config["logo"][self.Base].id)
	end
	
	local opacity = sPrinter.fadeByDistance(self)
	if opacity > 0 then
		sPrinter.drawSideScreen(self, opacity)
		sPrinter.drawTopScreen(self, opacity)
	end

	sPrinter.requestData(self)
end

function ENT:drawingOverlay(type)
	return self:GetLocked()
end

function ENT:GetLocked()
	local rack = self:GetRack()

	if IsValid(rack) and rack:GetLocked() then return true end
	
	return false
end

function ENT:OnRemove()
	if IsValid(self.topScreen) then
		self.topScreen:Remove()
	end

	if IsValid(self.sideScreen) then
		self.sideScreen:Remove()
	end
end