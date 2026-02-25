XeninUI.CachedIcons = XeninUI.CachedIcons or {}

if (!file.IsDir("xenin/icons", "DATA")) then
	file.CreateDir("xenin/icons")
end
if (!file.IsDir("xenin/icons/imgur", "DATA")) then
	file.CreateDir("xenin/icons/imgur")
end



local function DownloadImage(tbl)
	local p = XeninUI.Promises.new()

	if (!isstring(tbl.id)) then
		return p:reject("ID invalid")
	end

	local id = tbl.id
	local idLower = id:lower()
	local url = tbl.url or "https://i.imgur.com"
	local type = tbl.type or "png"

	if (XeninUI.CachedIcons[id] and XeninUI.CachedIcons[id] != "Loading") then
		return p:resolve(XeninUI.CachedIcons[id])
	end

	local read = file.Read("xenin/icons/imgur/" .. idLower .. "." .. type)
	if read then
		XeninUI.CachedIcons[id] = Material("../data/xenin/icons/imgur/" .. idLower .. "." .. type, "smooth")

		return p:resolve(XeninUI.CachedIcons[id])
	end

	local fullURL = tbl.fullURL or url .. "/" .. id .. "." .. type
	http.Fetch(fullURL, function(body, size, headers, code)
		if (code != 200) then
			return p:reject("Unable to download image due to code not being 200. Code: " .. code .. " ID:  " .. id .. " URL: " .. url .. "/" .. id .. "." .. type)
		end

		local str = "xenin/icons/imgur/" .. idLower .. "." .. type
		file.Write(str, body)

		XeninUI.CachedIcons[id] = Material("../data/" .. str, "smooth")

		p:resolve(XeninUI.CachedIcons[id])
	end, function(err)
		p:reject("Unable to download image. ID: " .. id .. " URL: " .. url .. "/" .. id .. "." .. type)
	end)

	return p
end

function XeninUI:DownloadIcon(pnl, tbl, pnlVar)
	if (!tbl) then return end

	local p = XeninUI.Promises.new()

	if isstring(tbl) then
		tbl = {
		{
		id = tbl } }
	end

	local i = 1
	local function AsyncDownload()
		if (!tbl[i]) then p:reject()end

		pnl[pnlVar or "Icon"] = "Loading"
		DownloadImage(tbl[i]):next(function(result)
			p:resolve(result):next(function()
				pnl[pnlVar or "Icon"] = result
			end, function(err)
				print(err)
			end)
		end, function(err)
			print(err)

			i = i + 1

			AsyncDownload()
		end)
	end

	AsyncDownload()

	return p
end

function XeninUI:DrawIcon(x, y, w, h, pnl, col, loadCol, var)
	col = col or color_white
	loadCol = loadCol or XeninUI.Theme.Accent
	var = var or "Icon"

	if (pnl[var] and type(pnl[var]) == "IMaterial") then
		surface.SetMaterial(pnl[var])
		surface.SetDrawColor(col)
		surface.DrawTexturedRect(x, y, w, h)
	elseif (pnl[var] != nil) then
		XeninUI:DrawLoadingCircle(h, h, h, loadCol)
	end
end



function XeninUI:GetIcon(id)
	local _type = type(id)
	if (_type == "IMaterial") then
		return id
	end

	if self.CachedIcons[id] then
		return self.CachedIcons[id]
	end

	local read = file.Read("xenin/icons/" .. id:lower() .. ".png")
	if read then
		self.CachedIcons[id] = Material("../data/xenin/icons/" .. id:lower() .. ".png", "smooth")
	else
		self.CachedIcons[id] = "Loading"
	end

	http.Fetch("https://i.imgur.com/" .. id .. ".png", function(body, len)
		local str = "xenin/icons/" .. id:lower() .. ".png"
		file.Write(str, body)

		self.CachedIcons[id] = Material("../data/" .. str, "smooth")
	end)
end
