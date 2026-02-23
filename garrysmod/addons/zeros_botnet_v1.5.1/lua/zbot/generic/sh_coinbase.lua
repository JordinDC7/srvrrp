/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Coinbase = zbf.Coinbase or {}

/*

	This system will automaticly catch the registred CRYPTO Currencys from Coinbase and send them to the clients

*/

zbf.Coinbase.List = zbf.Coinbase.List or {}
zbf.Coinbase.ShortToID = zbf.Coinbase.ShortToID or {}
function zbf.Coinbase.Reg(url,hist_url,OnCatch,OnCatchHist,short)
	local id = table.insert(zbf.Coinbase.List,{
		url = url,
		OnCatch = OnCatch,

		hist_url = hist_url,
		OnCatchHist = OnCatchHist,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		short = short,
		//CachedVar = 0,
	})
	zbf.Coinbase.ShortToID[short] = id
end
function zbf.Coinbase.Get(id) return zbf.Coinbase.List[id] end

function zbf.Coinbase.Fetch(id)
	local data = zbf.Coinbase.Get(id)
	if data == nil then return end
	if data.url == nil then return end

	// Whats the current price
	http.Fetch(data.url, function(bod)
		if bod == nil then
			zbf.Print("zbf.Coinbase.Fetch " .. data.short .. " JSON INVALID!")
			return
		end
		local respone = util.JSONToTable(bod)
		if respone == nil then
			zbf.Print("zbf.Coinbase.Fetch " .. data.short .. " TABLE INVALID!")
			return
		end
		if respone.data == nil then
			print(" ")
			zbf.Print("zbf.Coinbase.Fetch " .. data.short .. " DATA INVALID!")
			PrintTable(respone)
			print(" ")
			return
		end

		local val = respone.data.amount

		data.CachedVar = val
		pcall(data.OnCatch,val)

		//zbf.Print("zbf.Coinbase.Fetch " .. data.short .. " " .. tostring(val))

		if SERVER then
			net.Start("zbf_coinbase_update")
			net.WriteDouble(val)
			net.WriteUInt(id,8)
			net.Broadcast()
		end
	end,function(error)
		zbf.Print("zbf.Coinbase.Fetch " .. data.short .. " " .. error)
	end)

	// What was the price one hour ago?
	http.Fetch(data.hist_url, function(bod)
		if bod == nil then return end
		local respone = util.JSONToTable(bod)
		if respone == nil then return end
		if respone.data == nil then return end

		if not istable(respone.data.prices) then return end

		// The Last item in the respone.data.prices list is the price value 1 hour ago
		local val = respone.data.prices[#respone.data.prices].price

		data.HistoricCachedVar = val

		// Lets store the whole historic data on the SERVER and send it to a CLIENT once he requets it
		data.HistoricCache = respone.data
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

		pcall(data.OnCatchHist,val)

		//zbf.Print(data.Short .. " Historic: " .. val)
		if SERVER then
			net.Start("zbf_coinbase_update_hist")
			net.WriteDouble(val)
			net.WriteUInt(id,8)
			net.Broadcast()
		end
	end,function(error)
		zbf.Print("zbf.Coinbase.Fetch " .. data.short .. " " .. error)
	end)
end

if SERVER then
	util.AddNetworkString("zbf_coinbase_update")
	util.AddNetworkString("zbf_coinbase_update_hist")

	zbf.Coinbase.FirstTimeLoaded = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

	function zbf.Coinbase.FetchAll()
		//zbf.Print("Fetch Crypto Prices - Start")
		local NextUpdate = 0
		local delay = zbf.config.Crypto.http_delay
		for id,_ in pairs(zbf.Coinbase.List) do
			timer.Simple(delay,function()

				zbf.Coinbase.Fetch(id)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

				NextUpdate = NextUpdate + 1
				if NextUpdate >= 10 then
					NextUpdate = 0
					//zbf.Print("Fetch Crypto Prices - " .. math.Round(100 / table.Count(zbf.Coinbase.List) * id) .. "%")
				end

				if id >= table.Count(zbf.Coinbase.List) then
					// zbf.Print("Fetch Crypto Prices - Completed")
					zbf.Coinbase.FirstTimeLoaded = true
				end
			end)
			delay = delay + zbf.config.Crypto.http_delay
		end
	end

	zclib.Timer.Remove("zbf_coinbase_update")
	zclib.Timer.Create("zbf_coinbase_update",math.Clamp(zbf.config.Crypto.interval,300,999999999999),0,function()
		zbf.Coinbase.FetchAll()
	end)

	timer.Simple(5,function() zbf.Coinbase.FetchAll() end)
	// 224293224

	/*
		Sends the player the first update about Coinbase
	*/
	function zbf.Coinbase.OnJoin(ply)

		zbf.Print("Send coinbase data to > " .. ply:Nick())

		for id,v in pairs(zbf.Coinbase.List) do
			if v == nil then continue end

			if v.CachedVar then
				net.Start("zbf_coinbase_update")
				net.WriteDouble(v.CachedVar)
				net.WriteUInt(id,8)
				net.Send(ply)
			end

			if v.HistoricCachedVar then
				net.Start("zbf_coinbase_update_hist")
				net.WriteDouble(v.HistoricCachedVar)
				net.WriteUInt(id,8)
				net.Send(ply)
			end
		end
	end
else
	net.Receive("zbf_coinbase_update", function()
		local val = net.ReadDouble()
		local id = net.ReadUInt(8)

		val = math.Round(val,zbf.Currency.GetPrecision(id))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

		local data = zbf.Coinbase.Get(id)
		if data == nil then return end

		data.CachedVar = val
		pcall(data.OnCatch,val)
	end)

	net.Receive("zbf_coinbase_update_hist", function()
		local val = net.ReadDouble()
		local id = net.ReadUInt(8)

		val = math.Round(val,zbf.Currency.GetPrecision(id))

		local data = zbf.Coinbase.Get(id)
		if data == nil then return end

		data.HistoricCachedVar = val
		pcall(data.OnCatchHist,val)
	end)

	zbf.Coinbase.HistoricData = {}
	function zbf.Coinbase.FetchHistoricData(short, period, OnFetched, OnFail)

		// If we got a cached version then use that till we are allowed to fetch a fresh one
		if zbf.Coinbase.HistoricData[short] and zbf.Coinbase.HistoricData[short][period] and CurTime() < zbf.Coinbase.HistoricData[short][period].NextFetch then
			pcall(OnFetched, zbf.Coinbase.HistoricData[short][period].Data)
			return
		end
		//print("Fetching Historic data for " .. short)
		http.Fetch("https://api.coinbase.com/v2/prices/" .. short .. "-" .. (zclib.config.Currency == "€" and "EUR" or "USD") .. "/historic?period=" .. period, function(bod)
			if bod == nil then return end
			local respone = util.JSONToTable(bod)
			if respone == nil then return end
			if respone.data == nil then return end

			if zbf.Coinbase.HistoricData[short] == nil then zbf.Coinbase.HistoricData[short] = {} end

			zbf.Coinbase.HistoricData[short][period] = {
				Data = respone.data,
				NextFetch = CurTime() + 600
			}

			pcall(OnFetched, respone.data)
		end, function(error)
			pcall(OnFail, error)
		end)
	end
end
