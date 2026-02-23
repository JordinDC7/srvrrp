include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local basepos = Vector(0, -2, 0)

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

function ENT:Initialize()
	self:SetModel("models/stromic/rack.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetColor(sPrinter.config["rack"]["body_color"])
	self.printers = {}
	self:SetHealth(100)
	self:SetLocked(false)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(101)
	end
end

function ENT:StartTouch(ent)
	if !ent.sPrinter_ent then return end

	local closest_slot = {distance = 1e309, slot = 1}
	local closest_side = {distance = 1e309, side = 1}
	local entpos = self:WorldToLocal(ent:GetPos())

	for i=1,#sides do
		local comparepos = basepos
		comparepos.x = sides[i]
		local comparison = entpos:DistToSqr(comparepos)

		if closest_side.distance > comparison then
			closest_side.distance = comparison
			closest_side.side = i
		end
	end

	if !closest_side.side then return end

	for i=1,#slots do
		local realSlot = closest_side.side == 1 and math.floor((closest_side.side * 1.9) * i) or i * closest_side.side
		if IsValid(self.printers[realSlot]) then continue end
		local comparepos = Vector(closest_side.side, basepos.y, slots[i])
		local comparison = entpos:DistToSqr(comparepos)
		if closest_slot.distance > comparison then
			closest_slot.distance = comparison
			closest_slot.slot = i
		end
	end

	if self.printers[closest_side.side] and IsValid(self.printers[closest_side.side][closest_slot.slot]) then return end

	timer.Simple(0, function()
		self:addPrinter(ent, closest_side.side, closest_slot.slot)
	end)
end

local powerHandle = false
function ENT:Power(bool)
	local power = self:GetPower()
	
	self:SetPower(!power)

	for i = 1, 8 do
		local printer = self.printers[i]
		if !IsValid(printer) or printer:GetPower() == power then continue end
		printer:Power(power, true)
		self:EmitSound(power and "buttons/button1.wav" or "buttons/button9.wav")
	end
end

function ENT:addPrinter(ent, side, slot)
	if !ent.Base or (ent.Base ~= "sprinter_base") then return end
	local realSlot = side == 1 and math.floor((side * 1.9) * slot) or slot * side
	
	if IsValid(self.printers[realSlot]) then return end

	local pos, ang = self:LocalToWorld(Vector(sides[side], basepos.y, slots[slot])), self:LocalToWorldAngles(Angle(0,0,0))
	self.printers[realSlot] = ent

	ent.slot = realSlot
	ent:SetRack(self)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetParent(self)

	ent.PrinterPhys = ents.Create("sprinter_base_phys")
	ent.PrinterPhys:SetPos(pos)
	ent.PrinterPhys:SetAngles(ang)
	ent.PrinterPhys:Spawn()

	ent.PrinterPhys.Printer = ent

	constraint.Weld(ent.PrinterPhys, self, 0, 0, 0, true, true)

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end
	self:SetSkin(1)
end

function ENT:Recharge(ply)
	local money = 0
	local rechargePrinters = {}
	for i = 1, 8 do
		local printer = self.printers[i]
		if !IsValid(printer) or printer:GetBattery() >= 0.8 then continue end
		money = money + printer:GetRechargePrice()
		
		rechargePrinters[#rechargePrinters + 1] = printer
	end

	if sPrinter.config.canAfford(ply, money) and money > 0 then
		for i = 1, #rechargePrinters do
			local printer = rechargePrinters[i]
			if !IsValid(printer) then continue end
			printer:Recharge(ply, true)
		end

		if #rechargePrinters >= table.Count(self.printers) then
			slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "recharged-all", sPrinter.config["currency"]..string.Comma(money)), ply)
		else
			slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "recharged-this-many", #rechargePrinters, sPrinter.config["currency"]..string.Comma(money)), ply)
		end
	end
end

function ENT:Repair(ply, all)
	if all then
		local money = 0
		local repairPrinters = {}
		for i = 1, 8 do
			local printer = self.printers[i]
			if !IsValid(printer) or printer:Health() >= 100 then continue end
			money = money + printer.data.repairprice
			repairPrinters[#repairPrinters + 1] = printer
		end

		if sPrinter.config.canAfford(ply, money) and money > 0 then
			for i = 1, #repairPrinters do
				local printer = repairPrinters[i]
				if !IsValid(printer) then continue end
				printer:Repair(ply, true)
			end

			if #repairPrinters >= table.Count(self.printers) then
				slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "repaired-all", sPrinter.config["currency"]..string.Comma(money)), ply)
			else
				slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "repaired-this-many", #repairPrinters, sPrinter.config["currency"]..string.Comma(money)), ply)
			end
		end
	else
		if sPrinter.config.canAfford(ply, sPrinter.config["rack_repair_price"]) then
			sPrinter.config.addMoney(ply, -sPrinter.config["rack_repair_price"])
			self:SetHealth(100)

			slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "repaired-rack", sPrinter.config["currency"]..string.Comma(sPrinter.config["rack_repair_price"])), ply)
		end
	end
end

function ENT:Withdraw(ply)
	local money, total_xp = 0, 0

	for i = 1, 8 do
		local printer = self.printers[i]
		if !IsValid(printer) or !printer:CanWithdraw(ply) then continue end
		local stored = printer:GetWithdrawAmount()
		money = money + stored
		printer:OnWithdrawn(ply, true)

		if printer.data and printer.data.xpmultiplier then
			total_xp = total_xp + (stored * printer.data.xpmultiplier)
		end

		hook.Run("sP:Withdrawn", ply, printer, stored, self)
	end

	if money <= 0 then return end

	if hook.Run("sP:WithdrawOverride", ply, self, money) then return end

	sPrinter.config.addMoney(ply, money)

	slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "withdrawn", sPrinter.config["currency"]..string.Comma(money)), ply)

	hook.Run("sP:WithdrawnRack", ply, self, money, total_xp)
end

function ENT:Explode()
	local entPos = self:GetPos()
	local edata = EffectData()
	edata:SetStart( entPos )
	edata:SetOrigin( entPos )
	edata:SetScale( 1 )

	util.Effect( "Explosion", edata )

	if sPrinter.config["DarkRPFireSystem_Spawn_Flame_On_Explode"] and CH_FireSystem then
		local fire = ents.Create("fire")
		fire:SetPos( entPos )
		fire:Spawn()
	end

	self:Remove()
end

function ENT:OnRemove()
	for i = 1, 8 do
		local printer = self.printers[i]
		if !IsValid(printer) then continue end
		printer:Eject()
	end
end

function ENT:OnTakeDamage(data)
	if sPrinter.config["rack"]["godmode"] then return end
	local dmg = data:GetDamage()
	local hp = self:Health() - (dmg * .3)

	self:SetHealth(hp)

	if hp <= 0 then
		self:Explode()
	end
end