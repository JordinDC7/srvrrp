/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Vault = zbf.Vault or {}

/*

	The Vault system allows the player to store his Crypto Currencys in a save place

	Here the Concept:
		A CryptoVault system can be used to collect / save the players currencies.
		The player can send the crypto he mined to his CryptoVault via SendToVault which saves his crypto currencies
		The CryptoVault can be accessed via !crypto
		The player can drop Crypto Currencies from his Vault which will look like a USB Hardware Wallet
		The crypto on the USB Hardware wallet can be picked up via "E"

*/

/*
	Opens a interface to show all currencys the player currently has stored away
*/
zclib.Hook.Add("PlayerSay", "zbf_vault_open", function(ply, text)
	if zbf.config.Crypto.ChatCommand and string.sub(string.lower(text), 1, string.len(zbf.config.Crypto.ChatCommand)) == zbf.config.Crypto.ChatCommand then
		// Send net message to open vault interface
		zbf.Vault.Open(ply)
		return ""
	end
end)

/*
	Opens a interface to show all currencys the player currently has stored away
*/
util.AddNetworkString("zbf_Vault_Open")
function zbf.Vault.Open(ply)

	zbf.Wallet.UpdateCurrency(ply,ply)

	timer.Simple(0.05,function()
		if not IsValid(ply) then return end
		net.Start("zbf_Vault_Open")
		net.Send(ply)
	end)
end


/*
	Returns how many usb the player can spawn
*/
function zbf.Vault.GetUSBLimit(ply)
	if not IsValid(ply) then return 3 end
	local limit = zbf.config.USB.SpawnLimit[zclib.Player.GetRank(ply)]
	if limit == nil then limit = zbf.config.Controller.BotLimit["default"] end
	if limit == nil then limit = 3 end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	return limit
end

/*
	This drops a certain amount of currency on the ground as a hardware wallet
*/
util.AddNetworkString("zbf_Vault_Drop")
net.Receive("zbf_Vault_Drop", function(len, ply)
	zclib.Debug_Net("zbf_Vault_Drop", len)
	if zclib.Player.Timeout(nil, ply) then return end

	local pos = net.ReadVector()
	local CurrencyList = {}
	local length = net.ReadUInt(8)
	for i = 1, length do
		local c_type = net.ReadUInt(8)
		local c_amount = net.ReadDouble()
		CurrencyList[ c_type ] = c_amount
	end

	if not IsValid(ply) then return end
	if not zclib.util.InDistance(pos, ply:GetPos(), 500) then return end
	if CurrencyList == nil then return end
	if table.Count(CurrencyList) <= 0 then return end

	local SpawnCount = 0
	for k,v in pairs(zbf.USB.List) do
		if IsValid(v) and zclib.Player.IsOwner(ply, v) then
			SpawnCount = SpawnCount + 1
		end
	end
	if SpawnCount >= zbf.Vault.GetUSBLimit(ply) then
		zclib.Notify(ply,zbf.language[ "USBLimit" ], 1)
		return
	end

	local RealList = {}

	// Verify how much they got in their wallet
	for k,v in pairs(CurrencyList) do
		// Check if the player even got that much
		local amount = math.Clamp(zbf.Wallet.GetCurrency(ply,k),0,v)
		if amount <= 0 then continue end

		// Remove the amount
		zbf.Wallet.SetCurrency(ply,k,zbf.Wallet.GetCurrency(ply,k) - amount)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

		// Remove the money amount the player just dropped from the moneytrackker
		local c_value = zbf.Currency.GetValue(k)
		local money = math.Round(amount * c_value)
		zbf.MoneyTrack.Remove(ply,k,money)

		// Add to spawnlist
		RealList[k] = amount
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

		// Inform the player how much we just dropped
		zclib.Notify(ply, "-" .. math.Round(amount,zbf.Currency.GetPrecision(k)) .. " " .. zbf.Currency.GetShort(k), 0)
	end

	// Spawn harware wallet and give it the list
	local ent = ents.Create("zbf_usb")
	ent:SetPos(pos + Vector(0,0,25))
	ent:Spawn()
	ent:Activate()
	zclib.Player.SetOwner(ent, ply)

	zbf.Wallet.Setup(ent)
	for k, v in pairs(RealList) do zbf.Wallet.SetCurrency(ent, k, v) end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c
