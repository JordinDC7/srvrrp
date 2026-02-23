/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Wallet = zbf.Wallet or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

/*
	Updates the player about which currencies are currently stored inside the controller
*/
net.Receive("zbf_Wallet_UpdateCurrency", function(len)
	zclib.Debug_Net("zbf_Wallet_UpdateCurrency", len)
	local ent = net.ReadEntity()
	if not IsValid(ent) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

	// If we got a wallet before then lets store the last state
	if ent.zbf_Wallet then
		ent.zbf_LastWallet = table.Copy(ent.zbf_Wallet)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	ent.zbf_Wallet = {}

	local count = net.ReadUInt(8)
	for i = 1, count do
		local id = net.ReadUInt(8)
		local amount = math.Round(net.ReadDouble(),zbf.Currency.GetPrecision(id))
		ent.zbf_Wallet[ id ] = amount
	end

	hook.Run("zbf_Wallet_OnCurrencyUpdated",ent,ent.zbf_Wallet)
end)
