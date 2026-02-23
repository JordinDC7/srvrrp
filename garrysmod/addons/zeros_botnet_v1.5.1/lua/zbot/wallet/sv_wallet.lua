/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Wallet = zbf.Wallet or {}

/*
	Adds the specified currency to the ent
*/
function zbf.Wallet.AddCurrency(ent,c_type,c_amount,SkipUpdate)
	if ent.zbf_Wallet == nil then ent.zbf_Wallet = {} end

	local amount = c_amount,zbf.Currency.GetPrecision(c_type)
	if not isnumber(amount) or amount > 9999999999 then amount = 0 end

	ent.zbf_Wallet[c_type] = (ent.zbf_Wallet[c_type] or 0) + amount

	if c_amount <= 0 then
		ent.zbf_Wallet[c_type] = nil
	end

	// Update all clients
	if not SkipUpdate then
		zbf.Wallet.UpdateCurrency(ent,zclib.Player.GetAll())
	end
end

/*
	Lets use this for testing
*/
concommand.Add("zbf.Wallet.AddCurrency", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()

		if tr then
			if IsValid(tr.Entity) then
				if tr.Entity.zbf_Wallet then
					for k, v in pairs(zbf.Currency.List) do
						zbf.Wallet.AddCurrency(tr.Entity, k, 1)
					end
				end
			else
				if ply.zbf_Wallet == nil then ply.zbf_Wallet = {} end
				for k, v in pairs(zbf.Currency.List) do
					zbf.Wallet.AddCurrency(ply, k, 25)
				end
			end
		end
	end
end)

/*
	Goes through all the currencys inside the wallet and adds its currencies piece by piece to a list till the TargetAmount of MoneyValue is reached
*/
function zbf.Wallet.GetCurrencyMoneyAmount(ent,TargetAmount)
	local CurrentMoneyValue = 0
	local CurrencyList = {}
	for c_type,c_amount in pairs(ent.zbf_Wallet) do
		if c_amount == nil or c_amount == 0 then continue end

		// Thats the money value of this currency
		local currencyValue = zbf.Currency.GetValue(c_type)

		// Thats the money value amount of this currency inside the portfolio
		local moneyValue = currencyValue * c_amount

		if (CurrentMoneyValue + moneyValue) <= TargetAmount then
			// Add everything
			CurrencyList[c_type] = c_amount

			// Keep track on how much we already added to the list
			CurrentMoneyValue = CurrentMoneyValue + moneyValue
		else
			// Calculate how much we need to take in order to reach our limit
			local goalMoney = TargetAmount - CurrentMoneyValue
			if goalMoney <= 0 then continue end

			// Convert to its CurrencyAmount
			local CurrencyAmount = goalMoney / currencyValue
			if CurrencyAmount <= 0 then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

			// Add the specific amount
			CurrencyList[c_type] = CurrencyAmount

			// Keep track on how much we already added to the list
			CurrentMoneyValue = CurrentMoneyValue + goalMoney
		end
	end
	return CurrencyList
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

/*
	Debugs which currency and how much can be stolen and prints it in the console
*/
concommand.Add("zbf.Wallet.GetCurrencyMoneyAmount", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()
		if tr and IsValid(tr.Entity) and tr.Entity.zbf_Wallet then
			local list = zbf.Wallet.GetCurrencyMoneyAmount(tr.Entity,40000)
			PrintTable(list)
		end
	end
end)

/*
	Sets the specified currency to the specified amount in the ent
*/
function zbf.Wallet.SetCurrency(ent,c_type,c_amount)
	if ent.zbf_Wallet == nil then ent.zbf_Wallet = {} end
	ent.zbf_Wallet[c_type] = c_amount

	if c_amount <= 0 then
		ent.zbf_Wallet[c_type] = nil
	end

	// Update all clients
	zbf.Wallet.UpdateCurrency(ent,zclib.Player.GetAll())
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

/*
	Updates the specified player / players about which currency this ent currently holds
*/
util.AddNetworkString("zbf_Wallet_UpdateCurrency")
function zbf.Wallet.UpdateCurrency(ent,ply)

	net.Start("zbf_Wallet_UpdateCurrency")
	net.WriteEntity(ent)
	net.WriteUInt(table.Count(ent.zbf_Wallet),8)
	for k,v in pairs(ent.zbf_Wallet) do
		net.WriteUInt(k,8)
		net.WriteDouble(v)
	end
	net.Send(ply)

	hook.Run("zbf_Wallet_OnCurrencyUpdated",ent,ent.zbf_Wallet)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

/*
	Transfers all Currency from the WalletEntity to the player who send the net message
*/
util.AddNetworkString("zbf_Wallet_SendToVault")
net.Receive("zbf_Wallet_SendToVault", function(len, ply)
	zclib.Debug_Net("zbf_Wallet_SendToVault", len)
	if zclib.Player.Timeout(nil, ply) then return end

	local WalletEnt = net.ReadEntity()
	local c_type = net.ReadUInt(8)

	if not IsValid(WalletEnt) then return end
	if WalletEnt:IsPlayer() then return end
	if not IsValid(ply) then return end
	if c_type == nil then return end

	if zclib.util.InDistance(ply:GetPos(), WalletEnt:GetPos(), 500) == false then return end
	//if WalletEnt:GetClass() == "zbf_controller" and zclib.Player.IsOwner(ply, WalletEnt) == false then return end

	local c_amount = zbf.Wallet.GetCurrency(WalletEnt,c_type)
	if c_amount <= 0 then return end

	zbf.Wallet.AddCurrency(ply,c_type,c_amount)

	// Keep track on how much money the player should have
	local c_value = zbf.Currency.GetValue(c_type)
	local money = math.Round(c_amount * c_value)
	zbf.MoneyTrack.Add(ply,c_type,money)

	zbf.Wallet.SetCurrency(WalletEnt,c_type,0)

	hook.Run("zbf_Crypto_OnSendToVault",ply,zbf.Currency.GetShort(c_type),c_amount)

	local str = zbf.language[ "TransferComplete" ]
	str = string.Replace(str,"$Amount",math.Round(c_amount,zbf.Currency.GetPrecision(c_type)))
	str = string.Replace(str,"$Currency",zbf.Currency.GetShort(c_type))
	zclib.Notify(ply, str, 0)
end)

/*
	Paysout the MoneyCurrency to the player who send the net message
*/
util.AddNetworkString("zbf_Wallet_PayoutMoney")
net.Receive("zbf_Wallet_PayoutMoney", function(len, ply)
	zclib.Debug_Net("zbf_Wallet_PayoutMoney", len)
	if zclib.Player.Timeout(nil, ply) then return end

	local WalletEnt = net.ReadEntity()
	local c_amount = net.ReadDouble()
	if not IsValid(WalletEnt) then return end
	if not IsValid(ply) then return end
	if WalletEnt:IsPlayer() and WalletEnt ~= ply then return end

	if zclib.util.InDistance(ply:GetPos(), WalletEnt:GetPos(), 500) == false then return end
	if WalletEnt:GetClass() == "zbf_controller" and zclib.Player.IsOwner(ply, WalletEnt) == false then return end

	local real_amount = math.Clamp(zbf.Wallet.GetCurrency(WalletEnt,1),0,c_amount)
	if real_amount <= 0 then return end
	real_amount = math.Round(real_amount)

	zbf.Wallet.SetCurrency(WalletEnt,1,zbf.Wallet.GetCurrency(WalletEnt,1) - real_amount)

	zclib.Money.Give(ply, real_amount)

	zclib.Notify(ply, "+" .. zclib.Money.Display(real_amount), 0)
end)

/*
	Called from admins to set a specific currency value
*/
util.AddNetworkString("zbf_Wallet_SetCurrency")
net.Receive("zbf_Wallet_SetCurrency", function(len, ply)
	zclib.Debug_Net("zbf_Wallet_SetCurrency", len)
	if not zclib.Player.IsAdmin(ply) then return end

	local WalletEnt = net.ReadEntity()
	local c_type = net.ReadUInt(8)
	local c_amount = net.ReadFloat()

	if not IsValid(WalletEnt) then return end
	if c_type == nil then return end
	if c_amount == nil then return end

	zbf.Wallet.SetCurrency(WalletEnt,c_type,c_amount)

	zbf.Vault.Save(WalletEnt)
end)

/*
	Called from admins to add a list of currencies to the targets wallet
*/
util.AddNetworkString("zbf_Wallet_AddCurrencys")
net.Receive("zbf_Wallet_AddCurrencys", function(len, ply)
	zclib.Debug_Net("zbf_Wallet_AddCurrencys", len)
	if not zclib.Player.IsAdmin(ply) then return end

	local WalletEnt = net.ReadEntity()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	local size = net.ReadUInt(8)
	local list = {}
	for i = 1, size do list[ net.ReadUInt(8) ] = net.ReadFloat() end

	if not IsValid(WalletEnt) then return end
	if list and table.Count(list) > 0 then

		// Add all the currencies
		for k,v in pairs(list) do zbf.Wallet.AddCurrency(WalletEnt,k,v,true) end

		// Update everyone
		zbf.Wallet.UpdateCurrency(WalletEnt,zclib.Player.GetAll())
	end

	zbf.Vault.Save(WalletEnt)
end)
