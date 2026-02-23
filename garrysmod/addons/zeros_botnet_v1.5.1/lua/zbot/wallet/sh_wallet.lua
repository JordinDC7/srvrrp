/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Wallet = zbf.Wallet or {}

/*
	Sets up the list which later holds all types of currencys
*/
function zbf.Wallet.Setup(ent)
	ent.zbf_Wallet = {
		// [CurrencyID] = Amount
	}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

/*
	Returns the whole wallet
*/
function zbf.Wallet.Get(ent)
	return ent.zbf_Wallet or {}
end

/*
	Returns the specified currency or 0
*/
function zbf.Wallet.GetCurrency(ent,c_type)
	if ent.zbf_Wallet == nil then ent.zbf_Wallet = {} end
	return ent.zbf_Wallet[c_type] or 0
end

/*
	Convert the LIST ID to Currency SHORT
*/
function zbf.Wallet.ConvertToShort(Wallet)
	local clean = {}
	for c_id,c_amount in pairs(Wallet) do
		if c_id == nil then continue end
		if c_amount == nil then continue end
		local dat = zbf.Currency.Get(c_id)
		if dat == nil then continue end
		if dat.short == nil then continue end
		if c_amount <= 0 then continue end
		clean[dat.short] = c_amount
	end
	return clean
end

/*
	Convert the Currency SHORT to LIST ID
*/
function zbf.Wallet.ConvertToID(Wallet)
	local clean = {}
	for c_short,c_amount in pairs(Wallet) do

		if c_short == nil then continue end
		if c_amount == nil then continue end
		local c_id = zbf.Currency.GetID(c_short)
		if c_id == nil then continue end
		local dat = zbf.Currency.Get(c_id)
		if dat == nil then continue end
		if c_amount <= 0 then continue end
		clean[c_id] = c_amount
	end
	return clean
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

/*
	Calculates the current money value of all currencies combined
*/
function zbf.Wallet.GetMoneyValue(ent)
	local CurrentMoneyValue = 0
	for c_type,c_amount in pairs(ent.zbf_Wallet) do
		if c_amount == nil or c_amount == 0 then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

		// Thats the money value of this currency
		local currencyValue = zbf.Currency.GetValue(c_type)

		// Thats the money value amount of this currency inside the portfolio
		local moneyValue = currencyValue * c_amount

		CurrentMoneyValue = CurrentMoneyValue + moneyValue
	end
	return math.Round(CurrentMoneyValue)
end
