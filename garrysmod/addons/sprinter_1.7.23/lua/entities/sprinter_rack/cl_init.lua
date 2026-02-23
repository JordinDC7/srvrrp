include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	
	if !sPrinter then return end

	if sPrinter.config["logo"]["sprinter_rack"].enabled then
		sPrinter.drawLogo(self, sPrinter.config["logo"]["sprinter_rack"].id)
	end

	local opacity = sPrinter.fadeByDistance(self)
	if opacity > 0 then
		sPrinter.drawRackScreen(self, opacity)
	end
end

function ENT:OnRemove()
	if IsValid(self.rackScreen) then
		self.rackScreen:Remove()
	end
end

local slots = {
	[1] = 70.5,
	[2] = 58.56,
	[3] = 46.6,
	[4] = 34.56
}

local sides = {
	[1] = -21.8,
	[2] = 34.3
}

function ENT:AttemptUnlock()
	net.Start("sP:Networking")
	net.WriteEntity(self)
	net.WriteUInt(5,3)
	net.WriteUInt(0,2)
	net.WriteBool(false)
	net.SendToServer()
end

function ENT:HackHandler(success)
	net.Start("sP:Networking")
	net.WriteEntity(self)
	net.WriteUInt(5,3)
	net.WriteUInt(2,2)
	net.WriteBool(!success)
	net.SendToServer()
end

function ENT:drawingOverlay(type)
	return self:GetLocked() or self.overlayDrawn and type ~= "topbar"
end

local cache = {}
local cooldown = {}

function ENT:hasPrinter(slot)
	if cooldown[self] and cooldown[self][slot] and CurTime() - cooldown[self][slot] < .3 then return cache[self] and cache[self][slot] end

	cooldown[self] = cooldown[self] or {}
	cooldown[self][slot] = CurTime()

	local side = #tostring(slot / 2) > #tostring(slot) and 1 or 2
	local pos = self:LocalToWorld(Vector(sides[side], -2, slots[math.ceil(slot / 2)]))
	posetion = pos
	local printer

	for k,v in pairs(ents.FindInSphere(pos, 3)) do
		if v.Base == "sprinter_base" then
			printer = v
		break end
	end

	cache[self] = cache[self] or {}
	cache[self][slot] = printer

	return printer
end

function ENT:GetUpgradeAllPrice()
	local price = 0

	for i = 1,8 do
		local printer = self:hasPrinter(i)
		if !IsValid(printer) then continue end

		for k, v in ipairs(printer.data.upgrades) do
			price = price + printer:GetFullUpgradePrice(k)
		end
	end

	return price
end