/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Vault = zbf.Vault or {}

/*

	A system which saves the players Vault on the server

*/
file.CreateDir("zbf")
file.CreateDir("zbf/vault/")

/*
	Saves the players currency vault to file
*/
function zbf.Vault.Save(ply)
	if not IsValid(ply) then return end
	if not ply:IsPlayer() then return end

	// Prevent vaults being saved if the player has not yet fully loaded
	if not ply.zbf_FullyInitialized then return end

	local plyID = ply:SteamID64()
	local wallet = zbf.Wallet.Get(ply)

	zbf.Vault.SaveData(wallet,plyID,ply)
end

/*
	A quick function to save the wallet data directly
*/
function zbf.Vault.SaveData(wallet,steamID64,ply)
	// Convert the LIST ID to Currency SHORT
	local converted = zbf.Wallet.ConvertToShort(wallet)

	local data = {
		wallet = converted,
		moneytrack = zbf.Wallet.ConvertToShort(zbf.MoneyTrack.Get(ply))
	}

	local path = "zbf/vault/" .. tostring(steamID64) .. ".txt"

	local name = steamID64
	if IsValid(ply) then name = ply:Nick() end

	if table.Count(converted) <= 0 then
		local prevent = hook.Run("zbf_Vault_remove",ply)
		if prevent then return end
		if file.Exists(path,"DATA") then
			file.Delete(path)
			zbf.Print("Removed " .. name .. " crypto savefile because his wallet was empty!")
			hook.Run("zbf_Vault_removed",ply,steamID64)
		end
	else
		local prevent = hook.Run("zbf_Vault_save",ply,data,steamID64)
		if prevent then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

		file.Write(path, util.TableToJSON(data,true))
		hook.Run("zbf_Vault_saved",ply,steamID64)
		//zbf.Print("Saved " .. ply:Nick() .. " crypto savefile!")
	end
end

/*
	Save on PlayerDisconnected
*/
zclib.Hook.Add("zclib_PlayerDisconnect", "zbf_vault_save", function(steamid)
	local ply = player.GetBySteamID(steamid)
	if IsValid(ply) then
		zbf.Vault.Save(ply)
	end
end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

/*
	Save on ShutDown
*/
zclib.Hook.Add("ShutDown", "zbf_vault_save", function()
	print()
	zbf.Print("Saving player crypto vaults before ShutDown.")
	for k, v in pairs(zclib.Player.GetAll()) do zbf.Vault.Save(v) end
	print()
end)

/*
	Save every so often
*/
if zbf.config.Vault.AutoSave > 0 then
	zclib.Timer.Remove("zbf_vault_autosave")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	zclib.Timer.Create("zbf_vault_autosave", zbf.config.Vault.AutoSave, 0, function()
		// zbf.Print("Autosaved player crypto vaults!")
		for k, v in pairs(zclib.Player.GetAll()) do
			zbf.Vault.Save(v)
		end
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

/*
	Setup the players crypto vault and load any saved data
*/
function zbf.Vault.Load(ply)
	if not IsValid(ply) then return end

	// Setup the wallet / vault
	zbf.Wallet.Setup(ply)

	local data

	local path = "zbf/vault/" .. tostring(ply:SteamID64()) .. ".txt"

	local overwrite = hook.Run("zbf_Vault_load",ply)
	if overwrite then
		data = overwrite
	else
		// Load any saved crypto
		if file.Exists(path,"DATA") then
			data = file.Read(path, "DATA")
			if data == nil then return end
			data = util.JSONToTable(data)
		end
	end
	if data == nil then return end

	hook.Run("zbf_Vault_loaded",ply)

	zbf.Print("Loaded " .. ply:Nick() .. " crypto savefile!")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

	local wallet = {}
	local moneytrack = {}

	if data.moneytrack then
		wallet = data.wallet
		moneytrack = zbf.Wallet.ConvertToID(data.moneytrack)
	else
		// If the moneytrack does not exist in the savefile data then lets set it up for the first time
		wallet = data

		for c_type,c_amount in pairs(zbf.Wallet.ConvertToID(wallet)) do
			local c_value = zbf.Currency.GetValue(c_type)
			local money = math.Round(c_amount * c_value)
			moneytrack[c_type] = money
		end
	end

	// Assign the player his MoneyTrack so he knows how much he already has spend on crypto
	zbf.MoneyTrack.Set(ply,moneytrack)

	// Convert the Currency SHORT to LIST ID
	local converted = zbf.Wallet.ConvertToID(wallet)

	// Lets verify everything still exists and is valid
	for c_type,c_amount in pairs(converted) do
		if c_type and zbf.Currency.Get(c_type) and c_amount then
			ply.zbf_Wallet[c_type] = c_amount
		end
	end
end


/*
	Clean up any cargo savefile which is older then 1 month
*/
function zbf.Vault.CleanUp()
	local path = "zbf/vault/"
	local files = file.Find(path .. "*", "DATA")

	for k, v in pairs(files) do
		if file.Exists(path .. v, "DATA") and (os.time() - file.Time(path .. v, "DATA")) > (zbf.config.Vault.LifeTime or 5356800) then
			file.Delete(path .. v)
		end
	end
end

timer.Simple(3, zbf.Vault.CleanUp)
