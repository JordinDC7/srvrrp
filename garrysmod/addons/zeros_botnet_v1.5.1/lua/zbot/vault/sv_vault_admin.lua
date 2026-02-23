/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Vault = zbf.Vault or {}

/*

	The admin vault allows admins to edit players vaults

*/

/*
	Opens a interface to show all currencys the player currently has stored away
*/
zclib.Hook.Add("PlayerSay", "zbf_vaultadmin_open", function(ply, text)
	if string.sub(string.lower(text), 1, string.len("!adminvault")) == "!adminvault" then
		// Open Interface to select player
		zbf.Vault.Admin(ply)
		return ""
	end
end)

/*
	Opens a interface to ask which players vault we wanna inspect
*/
util.AddNetworkString("zbf_Vault_Admin")
function zbf.Vault.Admin(ply)
	if not zclib.Player.IsAdmin(ply) then return end
	net.Start("zbf_Vault_Admin")
	net.WriteEntity(NULL)
	net.Send(ply)
end
net.Receive("zbf_Vault_Admin", function(len, ply)
	zclib.Debug_Net("zbf_Vault_Admin", len)
	if zclib.Player.Timeout(nil, ply) then return end
	if not zclib.Player.IsAdmin(ply) then return end
	local target = net.ReadEntity()
	if not IsValid(ply) then return end
	if not IsValid(target) then return end

	zbf.Wallet.UpdateCurrency(target,ply)

	timer.Simple(0.05,function()
		if not IsValid(ply) then return end
		if not IsValid(target) then return end
		net.Start("zbf_Vault_Admin")
		net.WriteEntity(target)
		net.Send(ply)
	end)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a


util.AddNetworkString("zbf_Vault_Admin_Request")
net.Receive("zbf_Vault_Admin_Request", function(len, ply)
	zclib.Debug_Net("zbf_Vault_Admin_Request", len)
	if zclib.Player.Timeout(nil, ply) then return end
	if not zclib.Player.IsAdmin(ply) then return end

	local CleanList = {}
	local function AddPlayerWallet(id64,wallet)
		local total = 0
		for a,b in pairs(wallet) do
			if not a or not b then continue end
			total = total + zbf.Currency.GetValue(a,b)
		end
		total = math.Round(total)

		table.insert(CleanList, {
			id = id64,
			total = total
		})
	end

	// First lets get the wallets instead of savefiles from all the players on the server
	local OnServer = {}
	for k,v in pairs(player.GetAll()) do
		if not IsValid(v) then continue end
		OnServer[v:SteamID64()] = true
		AddPlayerWallet(v:SteamID64(),zbf.Wallet.Get(v))
	end

	// Next let get the savefiles from anyone we have not found on the server but has a savefile
	local files = file.Find( "zbf/vault/*", "DATA" )
	for k,v in pairs(files) do
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

		local steamid64 = string.Replace(v, ".txt", "")

		// Ignore this one, we found him and his wallet on the server right now
		if OnServer[steamid64] then continue end

		// Load savefile from wallet
		local data = file.Read("zbf/vault/" .. v, "DATA")
		if not data then continue end
		data = util.JSONToTable(data)
		if not data then continue end
		local converted = zbf.Wallet.ConvertToID(data)
		if not converted then continue end

		AddPlayerWallet(steamid64,converted)
	end

	// Sort by money
	table.sort(CleanList, function(a, b) return a.total > b.total end)

	// Convert number to money string
	for k, v in ipairs(CleanList) do
		v.total = zclib.Money.Display(zbf.Currency.Format(10, v.total))
	end

	timer.Simple(0.1,function()

		local e_String = util.TableToJSON(CleanList)
		local e_Compressed = util.Compress(e_String)
		net.Start("zbf_Vault_Admin_Request")
		net.WriteUInt(#e_Compressed,16)
		net.WriteData(e_Compressed,#e_Compressed)
		net.Send(ply)
	end)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

util.AddNetworkString("zbf_Vault_Admin_RequestData")
net.Receive("zbf_Vault_Admin_RequestData", function(len, ply)
	zclib.Debug_Net("zbf_Vault_Admin_RequestData", len)
	if zclib.Player.Timeout(nil, ply) then return end
	if not zclib.Player.IsAdmin(ply) then return end

	local id = net.ReadString()

	local target = player.GetBySteamID64(id)

	local wallet = {}
	if IsValid(target) then
		wallet = zbf.Wallet.Get(target)
	else

		local data = file.Read("zbf/vault/" .. id .. ".txt", "DATA")
		if not data then return end

		data = util.JSONToTable(data)
		if not data then return end

		local converted = zbf.Wallet.ConvertToID(data)
		if not converted then return end
		wallet = converted
	end

	timer.Simple(0.1,function()
		net.Start("zbf_Vault_Admin_RequestData")
		net.WriteString(id)
		net.WriteUInt(table.Count(wallet),20)
		for ctype,camount in pairs(wallet) do
			net.WriteUInt(ctype,20)
			net.WriteFloat(camount)
		end
		net.Send(ply)
	end)
end)

util.AddNetworkString("zbf_Vault_Admin_SaveData")
net.Receive("zbf_Vault_Admin_SaveData", function(len, ply)
	zclib.Debug_Net("zbf_Vault_Admin_SaveData", len)
	if zclib.Player.Timeout(nil, ply) then return end
	if not zclib.Player.IsAdmin(ply) then return end

	local steamID64 = net.ReadString()
	local wallet = {}
	local count = net.ReadUInt(32)
	for i = 1, count do
		wallet[net.ReadUInt(20)] = net.ReadFloat()
	end

	// Is the target currently on the server?
	local target = player.GetBySteamID64( steamID64 )
	if IsValid(target) then

		if target.zbf_Wallet == nil then target.zbf_Wallet = {} end

		for k,v in pairs(wallet) do
			target.zbf_Wallet[k] = v
		end

		zbf.Vault.Save(target)
	else
		zbf.Vault.SaveData(wallet,steamID64)
	end

	zclib.Notify(ply, "Crypto savefile updated! [" .. tostring(steamID64) .. "]", 0)
end)

util.AddNetworkString("zbf_Vault_Admin_Delete")
net.Receive("zbf_Vault_Admin_Delete", function(len, ply)
	zclib.Debug_Net("zbf_Vault_Admin_SaveData", len)
	if zclib.Player.Timeout(nil, ply) then return end
	if not zclib.Player.IsAdmin(ply) then return end

	local steamID64 = net.ReadString()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	// Is the target currently on the server?
	local target = player.GetBySteamID64( steamID64 )
	if IsValid(target) then
		target.zbf_Wallet = {}
	end

	local path = "zbf/vault/" .. tostring(steamID64) .. ".txt"

	local name = steamID64
	if IsValid(target) then name = target:Nick() end


	if file.Exists(path, "DATA") then
		file.Delete(path)
		zbf.Print("Removed " .. name .. " crypto savefile because his wallet was empty!")
		hook.Run("zbf_Vault_removed", target, steamID64)
	end

	zclib.Notify(ply, "Crypto savefile removed! [" .. tostring(steamID64) .. "]", 0)
end)
