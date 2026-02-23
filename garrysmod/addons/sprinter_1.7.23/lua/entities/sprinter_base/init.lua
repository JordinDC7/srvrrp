include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
	self:SetModel("models/stromic/money_printer.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetMoney(0)
	self:SetPrintSpeed(10)
	self:SetBattery(1)
	self:SetPower(true)
	self:SetSkin(1)
	self:SetHealth(100)
	self:PhysWake()

	self:PostInit()

	self:PrintSound()
	
	self.settingsNetwork = {}
	self.upgradesNetwork = {}
	self.logsNetwork = {}
	self.networkedAll = {}
	self.settings = {}
	self.notifyCD = {}
	self.logs = {}
	self.totalSpent = 0
	
	local identifier = self:EntIndex().."_printing_sound"
	timer.Create(self:EntIndex().."_printing_sound", 2, 0, function()
		if !IsValid(self) then
			timer.Remove(identifier)
		return end

		if !self:GetPower() then return end
		self:PrintSound()
	end)
end

function ENT:PrintSound()
	local noiseReductionLevel = self:GetUpgrade("noisereduction")
	local volume = (self.data.basevolume and self.data.basevolume or 1) - (noiseReductionLevel * .1)

	if volume <= 0 then return end

	sPrinter.recreateSound(volume)
	self:EmitSound("sPrinter_Printing")
end

function ENT:Upgrade(ply, upgrade, full, no_notify)
	self.data.upgrades[upgrade] = self.data.upgrades[upgrade] or {}
	self.data.upgrades[upgrade].stage = self.data.upgrades[upgrade].stage or 0

	if self.data.upgrades[upgrade].stage == self.data.upgrades[upgrade].max then return end

	if self.data.upgrades[upgrade].usergroup and (!self.data.upgrades[upgrade].usergroup[ply:GetUserGroup()] and !self.data.upgrades[upgrade].usergroup["*"]) then 
		slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "insufficient-permissions"), ply)    
	return end

	local cur_stage = self.data.upgrades[upgrade].stage
	local price = !full and self:GetUpgradePrice(upgrade, cur_stage + 1) or self:GetFullUpgradePrice(upgrade)

	self.totalSpent = self.totalSpent + price

	if sPrinter.config.canAfford(ply, price) then
		sPrinter.config.addMoney(ply, -price)
		if !no_notify then slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "upgraded", sPrinter.config["currency"]..string.Comma(price)), ply) end
		self.data.upgrades[upgrade].stage = !full and cur_stage + 1 or self.data.upgrades[upgrade].max
		sPrinter.networkUpgrades(self, upgrade)
		self:Log(3)

		hook.Run("sP:Upgraded", ply, self, price)
	end
end

function ENT:OnTakeDamage(data)
	if IsValid(self) then
		if self:GetUpgrade("notifications") then
			local owner = self:Getowning_ent()

			if IsValid(owner) then
				if self.settings[4] then
					if self.notifyCD and self.notifyCD["ondmg"] and CurTime() - self.notifyCD["ondmg"] < 1 then return end
					self.notifyCD["ondmg"] = CurTime()
					slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "printer-was-damaged", self.name), owner)
				elseif self.settings[1] and self:Health() <= 30 then
					if self.notifyCD and self.notifyCD["lowhp"] and CurTime() - self.notifyCD["lowhp"] < 1 then return end
					self.notifyCD["lowhp"] = CurTime()
					slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "printer-low-hp", self.name), owner)
				end
			end
		end

		local dmgupgraderesistance = 1
		local dmgupg = self:GetUpgrade("dmgresistance")
		if dmgupg then
			dmgupgraderesistance = dmgupgraderesistance - (dmgupg / 10)
		end
		
		local dmg = data:GetDamage()
		local hp = math.Clamp(self:Health() - ((dmg * self.data.dmgresistance) * dmgupgraderesistance), 0, 100)

		self:Log(2)
		self:SetHealth(hp)

		if hp == 0 then
			self:Overheat()

			if self.data.reward and (self.data.reward > 0) and !self.rewarded then
				local attacker = data:GetAttacker()
				if IsValid(attacker) and attacker:IsPlayer() then
					if !table.IsEmpty(sPrinter.config["reward_teams"]) and !sPrinter.config["reward_teams"][attacker:Team()] then return end
					self.rewarded = true
					
					local reward = (self.data.price + (self.data.countUpgradesToReward and self.totalSpent or 0)) * self.data.reward

					sPrinter.config.addMoney(attacker, reward)
					slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "rewarded-on-destroy",  sPrinter.config["currency"]..string.Comma(reward)), attacker)
				end
			end
		end
	end
end

function ENT:Think()
	local ct = CurTime()

	if !self.TemperatureLogicCD or (ct - self.TemperatureLogicCD > 2) then
		self.TemperatureLogicCD = CurTime()
		self:TemperatureLogic()
	end

	if !self:GetPower() then return end

	if !self.BatteryLogicCD or (ct - self.BatteryLogicCD > 10) then
		self.BatteryLogicCD = CurTime()
		self:BatteryLogic()
	end

	if !self.LastPrinted or (ct - self.LastPrinted > self:GetPrintSpeed()) then
		self.LastPrinted = CurTime()
		self:Print()
	end
end

function ENT:Log(type)
	local key = #self.logs + 1
	self.logs[#self.logs + 1] = {action = type, time = os.time()}

	hook.Run("sP:LogAdded", self, key)
end

function ENT:Power(bool, silent)
	if bool == nil then bool = !self:GetPower() end
	
	if bool and self:GetBattery() <= 0 then return end

	if !silent then
		self:EmitSound(bool and "buttons/button1.wav" or "buttons/button9.wav")
	end

	self:SetSkin(bool and 1 or 0)
	self:SetPower(bool)
	self:Log(bool and 4 or 5)
	if bool then
		self:PrintSound()
	else
		self:StopSound("sPrinter_Printing")
	end
end

function ENT:Recharge(ply, silent)
	local rechargePrice = self:GetRechargePrice()

	if sPrinter.config.canAfford(ply, rechargePrice) and rechargePrice > 0 then
		sPrinter.config.addMoney(ply, -rechargePrice)
		
		if !silent then
			slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "recharged", sPrinter.config["currency"]..string.Comma(rechargePrice)), ply)
		end

		self:SetBattery(1)
		self.notifiedLowBattery = nil
	end
end

function ENT:Repair(ply, silent)
	local repairprice = self.data.repairprice
	if sPrinter.config.canAfford(ply, repairprice) then
		sPrinter.config.addMoney(ply, -repairprice)

		if !silent then
			slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "repaired", sPrinter.config["currency"]..string.Comma(repairprice)), ply)
		end

		self:SetHealth(100)
	end
end

function ENT:Eject(ply)
	local rack = self:GetRack()
	if !IsValid(rack) then return end
	local slot = self.slot

	local newpos = rack:WorldToLocal(self:GetPos())
	newpos.y = newpos.y - 40

	newpos = rack:LocalToWorld(newpos)

	if ply then
		local obscurants = ents.FindInSphere(newpos, 5)

		for k,v in ipairs(obscurants) do
			if IsValid(v) then
				if v:IsPlayer() then
					return slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "no-eject-space"), ply)
				elseif v:GetClass() == self:GetClass() then
					newpos.z = newpos.z + 10
				end
			end
		end
	end

	self:EmitSound("ambient/materials/shutter6.wav")
	self:SetParent()
	self:SetMoveType(MOVETYPE_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(true) phys:Wake() end

	self:SetRack()
	self:SetPos(newpos)
	rack.printers[slot] = nil
	if IsValid(self.PrinterPhys) then self.PrinterPhys:Remove() end

	self.slot = nil

	if table.IsEmpty(rack.printers) then rack:SetSkin(0) end
end

function ENT:GetPrintAmount()
	return self.data.baseincome * (self:GetUpgrade("overclocking") + self.data.clockspeed)
end

function ENT:Print(amount)
	self:SetMoney(math.Clamp(self:GetMoney() + self:GetPrintAmount(), 0, self:GetMaxStorage()))
end

function ENT:CanWithdraw(ply)
	local result = hook.Run("sP:CanWithdraw", ply, self)
	if result == false then return false end

	local data = self.data
	local team = ply:Team()
	local team_name = RPExtraTeams[team].name
	local isListed = data.cantwithdrawjobs and data.cantwithdrawjobs[team_name]

	if (tobool(isListed) ~= tobool(data.withdrawjobswhitelist)) or (data.cantwithdrawusergroups and data.cantwithdrawusergroups[ply:GetUserGroup()]) then return false end
	return true
end

function ENT:OnWithdrawn(ply, rack)
	self:SetMoney(0)
	self:Log(1)

	if self:GetUpgrade("notifications") then
		local owner = self:Getowning_ent()

		if IsValid(owner) and ply ~= owner and self.settings[2] then
			if owner.sPnotifyCD and owner.sPnotifyCD["onWithdraw"] and CurTime() - owner.sPnotifyCD["onWithdraw"] < 1 then return end

			owner.sPnotifyCD = owner.sPnotifyCD or {}
			owner.sPnotifyCD["onWithdraw"] = CurTime()

			slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], rack and "someone-has-withdrawn-rack" or "someone-has-withdrawn", self.name), owner)
		end
	end

end

function ENT:Withdraw(ply)
	if !self:CanWithdraw(ply) then 
		slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "cannot-withdraw"), ply)	
	return end
	
	local money = self:GetWithdrawAmount()
	if !IsValid(ply) or !ply:Alive() or money <= 0 then return end

	self:OnWithdrawn(ply)

	hook.Run("sP:Withdrawn", ply, self, money)

	if hook.Run("sP:WithdrawOverride", ply, self, money) then return end

	sPrinter.config.addMoney(ply, money)
	
	slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "withdrawn", sPrinter.config["currency"]..string.Comma(money)), ply)
end

function ENT:OnRemove()
	self:StopSound("sPrinter_Printing")

	local rack = self:GetRack()
	if IsValid(rack) and self.slot then
		rack.printers[self.slot] = nil
	end

	if IsValid(self.PrinterPhys) then
		self.PrinterPhys:Remove()
	end
end

function ENT:Explode(attacker)
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

	if sPrinter.config["damageradius"] and !table.IsEmpty(sPrinter.config["damageradius"]) and sPrinter.config["blastdamage"] and !table.IsEmpty(sPrinter.config["blastdamage"]) then
		util.BlastDamage(self, attacker or self, self:GetPos(), math.random(sPrinter.config["damageradius"][1], sPrinter.config["damageradius"][2]), math.random(sPrinter.config["blastdamage"][1], sPrinter.config["blastdamage"][2]))
	end

	self:Remove()
end

function ENT:Overheat()
	self:Ignite(3)
	timer.Simple(3, function()
		if IsValid(self) then
			self:Explode()
		end
	end)
end

function ENT:BatteryLogic()
	local drained = math.Clamp(self:GetBattery() - (self.data.batteryconsumption / 100), 0, 1)
	if drained == 0 then self:Power(false) end

	if self:GetUpgrade("notifications") and drained <= .15 then
		local owner = self:Getowning_ent()

		if IsValid(owner) and self.settings[3] then
			if !self.notifiedLowBattery then
				self.notifiedLowBattery = true
				slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "battery-low", self.name), owner)
			end
		end
	end

	self:SetBattery(drained)
end

function ENT:TemperatureLogic()
	if !self:GetPower() then
		local temp = self:GetTemperature()

		if temp > 0 then
			self:SetTemperature(math.Clamp(temp - math.random(1, 10), 0, 999))
		end
	return end

	local temp = math.random(25, 30)
	local racktempsplit = 3
	local rack = self:GetRack()
	if IsValid(rack) then
		local racktemp = 0
		if rack:GetSkin() == 1 then
			racktemp = math.random(10, 15)
		else
			racktemp = math.random(25, 40)
		end

		if rack.printers then
			racktemp = racktemp + (racktempsplit * table.Count(rack.printers))
		end

		temp = temp + racktemp
	end

	self:SetTemperature(temp)

	if temp > 80 and !self.data.ignoretemperature then
		local chance = math.random(1, 100)

		if chance > 90 then
			self:Overheat()
		end
	end
end