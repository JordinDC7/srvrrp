/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.MoneyTrack = zbf.MoneyTrack or {}

/*

	This system will keep track on how much money the player spend on his wallet
	It will also return the diffrence on how much his currency is worth now
	NOTE What we wanna do is create a savefile which stores how much money the player should have and compare that to how much he actully has

*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

/*
	Returns the full MoneyTrack list from the player
*/
function zbf.MoneyTrack.Get(ply)
	return ply.zbf_MoneyTrack or {}
end

/*
	Returns the diffrence between how much the player invested in the currency and how much money he has now
*/
function zbf.MoneyTrack.GetDifference(ply,c_type)
	if ply.zbf_MoneyTrack == nil then ply.zbf_MoneyTrack = {} end

	local c_amount = ply.zbf_Wallet[c_type]
	if not c_amount then return 0 end

	local InvestedMoney = ply.zbf_MoneyTrack[ c_type ] or 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	local CurrentMoney = math.Round(c_amount * zbf.Currency.GetValue(c_type))

	return CurrentMoney - InvestedMoney
end

if SERVER then
	/*
		Sets the moneytrack list for this player
	*/
	function zbf.MoneyTrack.Set(ply,list)
		ply.zbf_MoneyTrack = list
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

		zbf.MoneyTrack.Update(ply)
	end

	/*
		Adds the money amount which the player just paid for buying the currency
	*/
	function zbf.MoneyTrack.Add(ply,c_type,money)
		if ply.zbf_MoneyTrack == nil then ply.zbf_MoneyTrack = {} end
		ply.zbf_MoneyTrack[ c_type ] = (ply.zbf_MoneyTrack[ c_type ] or 0) + money
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		zbf.MoneyTrack.Update(ply)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	/*
		Removes the money amount which the player just got for selling the currency
	*/
	function zbf.MoneyTrack.Remove(ply,c_type,money)
		if ply.zbf_MoneyTrack == nil then ply.zbf_MoneyTrack = {} end
		ply.zbf_MoneyTrack[ c_type ] = math.Clamp((ply.zbf_MoneyTrack[ c_type ] or 0) - money, 0, 1000000000)

		zbf.MoneyTrack.Update(ply)
	end

	/*
		Updates the specified player / players about which currency this ent currently holds
	*/
	util.AddNetworkString("zbf_MoneyTrack_Update")
	function zbf.MoneyTrack.Update(ply)
		net.Start("zbf_MoneyTrack_Update")
		net.WriteUInt(table.Count(ply.zbf_MoneyTrack),8)
		for k,v in pairs(ply.zbf_MoneyTrack) do
			net.WriteUInt(k,8)
			net.WriteUInt(v,32)
		end
		net.Send(ply)
	end
else
	/*
		Updates the player about which currencies are currently stored inside the controller
	*/
	net.Receive("zbf_MoneyTrack_Update", function(len)
		zclib.Debug_Net("zbf_MoneyTrack_Update", len)

		LocalPlayer().zbf_MoneyTrack = {}

		local count = net.ReadUInt(8)
		for i = 1, count do
			local id = net.ReadUInt(8)
			local money = net.ReadUInt(32)
			LocalPlayer().zbf_MoneyTrack[ id ] = money
		end
	end)
end
