/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.ATM = zbf.ATM or {}

/*

	The Crypto ATM can be used to Buy / Sell / Send crypto and also gives the player access to this crypto vault

*/
function zbf.ATM.Initialize(ATM)
	ATM:SetModel("models/zerochain/props_clickfarm/zcf_atm.mdl")
	ATM:PhysicsInit(SOLID_VPHYSICS)
	ATM:SetSolid(SOLID_VPHYSICS)
	ATM:SetMoveType(MOVETYPE_VPHYSICS)
	ATM:SetUseType(SIMPLE_USE)
	//ATM:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phy = ATM:GetPhysicsObject()
	if IsValid(phy) then
		phy:Wake()
		phy:EnableMotion(false)
	end

	zclib.EntityTracker.Add(ATM)

	zbf.Wallet.Setup(ATM)
end

/*
	Open interface to let the user select which currencie he wants
*/
function zbf.ATM.OnUse(ATM,ply)

	// Send the player all the currencies which he currently has
	zbf.Wallet.UpdateCurrency(ply,ply)

	timer.Simple(0.05, function()
		if not IsValid(ply) then return end
		zbf.ATM.Open(ATM,ply)
	end)
end

/*
	Opens a interface to show all currencys the player currently has stored away
*/
util.AddNetworkString("zbf_ATM_Open")
function zbf.ATM.Open(ATM,ply)
	net.Start("zbf_ATM_Open")
	net.Send(ply)
end

/*
	Called from the client to buy crypto
*/
util.AddNetworkString("zbf_ATM_Purchase")
net.Receive("zbf_ATM_Purchase", function(len, ply)
	zclib.Debug_Net("zbf_ATM_Purchase", len)
	if zclib.Player.Timeout(nil, ply) then return end

	local c_type = net.ReadUInt(8)
	local c_amount = net.ReadDouble()

	if not IsValid(ply) then return end
	if c_type == nil then return end
	if c_amount == nil then return end
	if c_amount <= 0 then return end
	if c_type == 1 then return end

	if not zbf.Currency.CanPurchase(c_type,ply) then return end

	local c_value = zbf.Currency.GetValue(c_type)
	local c_cost = math.Round(c_amount * c_value)

	if not zclib.Money.Has(ply, c_cost) then
		return
	end

	// Check if the user can purchase more Crypto
	local currentTotal = zbf.Wallet.GetMoneyValue(ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	local limit = zbf.ATM.GetPurchaseLimit()

	// How much is the player still allowed to buy
	local diff = math.Clamp(limit - currentTotal, 0, limit)
	if diff <= 0 then
		zclib.Notify(ply, zbf.language[ "purchaselimit" ] .. " " .. zclib.Money.Display(currentTotal) .. " / " .. zclib.Money.Display(limit), 1)
		return
	end
	local Converted = diff / c_value
	if Converted <= 0 then return end
	c_amount = math.Clamp(c_amount,0,Converted)
	c_cost = math.Round(c_amount * c_value)
	zclib.Money.Take(ply, c_cost)

	zbf.Wallet.AddCurrency(ply,c_type,c_amount)

	// Keep track on how much money the player has spend so far
	zbf.MoneyTrack.Add(ply,c_type,c_cost)

	local str = zbf.language[ "PurchaseConfirmation" ]
	str = string.Replace(str,"$Amount",math.Round(c_amount,zbf.Currency.GetPrecision(c_type)))
	str = string.Replace(str,"$Currency",zbf.Currency.GetShort(c_type))
	str = string.Replace(str,"$Money",zclib.Money.Display(c_cost))
	zclib.Notify(ply, str, 0)

	hook.Run("zbf_Crypto_OnBuy",ply,zbf.Currency.GetShort(c_type),c_amount,c_cost)
end)

/*
	This converts the currency to DarkRP money and give it to the player
*/
util.AddNetworkString("zbf_ATM_Sell")
net.Receive("zbf_ATM_Sell", function(len, ply)
	zclib.Debug_Net("zbf_ATM_Sell", len)
	if zclib.Player.Timeout(nil, ply) then return end

	local c_type = net.ReadUInt(8)
	local c_amount = net.ReadDouble()

	if not IsValid(ply) then return end
	if ply.zbf_Wallet == nil then return end
	if c_type == nil then return end
	if c_amount == nil then return end
	if c_amount <= 0 then return end

	if not zbf.Currency.CanSell(c_type,ply) then return end

	local real_amount = math.Clamp(zbf.Wallet.GetCurrency(ply,c_type),0,c_amount)
	if real_amount <= 0 then return end

	// Gets the currency amount from the ply and multiplys it with its value
	local money = real_amount * zbf.Currency.GetValue(c_type)
	if money <= 0 then return end
	money = math.Round(money)

	zbf.Wallet.SetCurrency(ply,c_type,zbf.Wallet.GetCurrency(ply,c_type) - real_amount)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	zclib.Money.Give(ply, money)

	// Remove the money amount the player just sold
	zbf.MoneyTrack.Remove(ply,c_type,money)

	local str = zbf.language[ "SellConfirmation" ]
	str = string.Replace(str,"$Amount",math.Round(real_amount, zbf.Currency.GetPrecision(c_type)))
	str = string.Replace(str,"$Currency",zbf.Currency.GetShort(c_type))
	str = string.Replace(str,"$Money",zclib.Money.Display(money))
	zclib.Notify(ply, str, 0)

	hook.Run("zbf_Crypto_OnSell",ply,zbf.Currency.GetShort(c_type),c_amount,money)
end)


/*
	This sends the specified crypto amount from one player to another one
*/
util.AddNetworkString("zbf_ATM_Transfer")
net.Receive("zbf_ATM_Transfer", function(len, ply)
	zclib.Debug_Net("zbf_ATM_Sell", len)
	if zclib.Player.Timeout(nil, ply) then return end

	local c_type = net.ReadUInt(8)
	local c_amount = net.ReadDouble()
	local target = net.ReadEntity()

	if not IsValid(ply) then return end
	if ply.zbf_Wallet == nil then return end
	if c_type == nil then return end
	if c_amount == nil then return end
	if not IsValid(target) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	if not zbf.Currency.CanSend(c_type,ply) then return end

	local real_amount = math.Clamp(zbf.Wallet.GetCurrency(ply,c_type),0,c_amount)
	if real_amount <= 0 then return end

	zbf.Wallet.SetCurrency(ply,c_type,zbf.Wallet.GetCurrency(ply,c_type) - real_amount)

	// Remove the money amount the player just send
	local c_value = zbf.Currency.GetValue(c_type)
	local money = math.Round(real_amount * c_value)
	zbf.MoneyTrack.Remove(ply,c_type,money)

	zbf.Wallet.AddCurrency(target,c_type,real_amount)

	local str = zbf.language[ "SendConfirmation" ]
	str = string.Replace(str,"$Amount",math.Round(real_amount, zbf.Currency.GetPrecision(c_type)))
	str = string.Replace(str,"$Currency",zbf.Currency.GetShort(c_type))
	str = string.Replace(str,"$PlayerName",target:Nick())
	zclib.Notify(ply, str, 0)

	local str02 = zbf.language[ "ReceiveConfirmation" ]
	str02 = string.Replace(str02,"$PlayerName",ply:Nick())
	str02 = string.Replace(str02,"$Amount",math.Round(real_amount, zbf.Currency.GetPrecision(c_type)))
	str02 = string.Replace(str02,"$Currency",zbf.Currency.GetShort(c_type))
	zclib.Notify(target, str02, 0)


	hook.Run("zbf_Crypto_OnSend",ply,zbf.Currency.GetShort(c_type),c_amount,target)
end)




/*
	Saves the ATMs to the Map and loads it after restart / cleanup
*/
file.CreateDir("zbf")
zclib.STM.Setup("zbf_atm", "zbf/" .. string.lower(game.GetMap()) .. "_atms.txt", function()
	local data = {}

	for k, v in ipairs(ents.FindByClass("zbf_atm")) do
		if IsValid(v) then
			table.insert(data, {
				pos = v:GetPos(),
				ang = v:GetAngles()
			})
		end
	end

	return data
end, function(data)
	for k, v in pairs(data) do
		local ent = ents.Create("zbf_atm")
		if not IsValid(ent) then continue end
		ent:SetPos(v.pos)
		ent:SetAngles(v.ang)
		ent:Spawn()
		ent:Activate()
	end

	zbf.Print("Finished loading ATMs!")
end, function()
	for k, v in pairs(ents.FindByClass("zbf_atm")) do
		if IsValid(v) then
			v:Remove()
		end
	end
end)

concommand.Add("zbf_atm_save", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		zclib.STM.Save("zbf_atm")
		zclib.Notify(ply, "ATMs saved for " .. string.lower(game.GetMap()) .. "!", 0)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

concommand.Add("zbf_atm_remove", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		zclib.STM.Remove("zbf_atm")
		zclib.Notify(ply, "Removed all ATMs!", 0)
	end
end)
