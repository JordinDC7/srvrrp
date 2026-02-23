ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Printer"
ENT.Author = "Stromic"
ENT.Category = "sPrinter"
ENT.Spawnable = false
ENT.sPrinter_ent = true
ENT.upgStringToInt = {}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Money")
	self:NetworkVar("Int", 1, "PrintSpeed")
	self:NetworkVar("Int", 2, "Temperature")
	self:NetworkVar("Int", 3, "ClockSpeed")
	self:NetworkVar("Bool", 0, "Power")
	self:NetworkVar("Float", 0, "Battery")
	self:NetworkVar("Entity", 0, "Rack")
	self:NetworkVar("Entity", 1, "owning_ent")
end

function ENT:GetWithdrawAmount()
	local amount = self:GetMoney()

	local result = hook.Run("sP:PreWithdraw", self, amount)

	return result or amount
end

function ENT:GetUpgradePrice(upgrade, stage)
	local price = self.data.upgrades[upgrade].enforced_pricing and self.data.upgrades[upgrade].enforced_pricing[stage] or (self.data.upgrades[upgrade].baseprice * stage)

	local new_price = hook.Run("sP:PrePrinterUpgradePrice", self, price, upgrade, stage)

	return isnumber(new_price) and new_price or price
end

function ENT:GetFullUpgradePrice(upg_int)
	local cur_stage = self.data.upgrades[upg_int].stage or 0
    local sum = 0

    for i = (cur_stage + 1), self.data.upgrades[upg_int].max do
        sum = sum + self:GetUpgradePrice(upg_int, i)
    end

    return sum
end

function ENT:GetUpgrade(upgrade)
	if table.IsEmpty(self.upgStringToInt) then
		for k,v in pairs(self.data.upgrades) do
			self.upgStringToInt[v.upgrade] = k
		end
	end

	local upg = self.upgStringToInt[upgrade] and self.data.upgrades[self.upgStringToInt[upgrade]] or self.data.upgrades[upgrade]
	
	return istable(upg) and upg.stage or 0
end

function ENT:GetMaxStorage()
	local upgradedStorage = 0
	local upgradeIndex = self.upgStringToInt["storage"]

	if upgradeIndex then
		local upgradeLevel = self:GetUpgrade("storage")

		upgradedStorage = upgradeLevel * self.data.upgrades[upgradeIndex].increment
	end

	return self.data.maxstorage + upgradedStorage
end

function ENT:GetRechargePrice()
	local rechargePrice = self.data.rechargeprice

	if sPrinter.config["recharge_price_per_percentage"] then
		rechargePrice = rechargePrice * (1 - self:GetBattery())
	end

	return math.Round(rechargePrice)
end