/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Vault = zbf.Vault or {}

net.Receive("zbf_Vault_Open", function(len)
	zclib.Debug_Net("zbf_Vault_Open", len)
	zbf.Vault.Open()
end)

/*
	Here we display all the diffrent currencys which are currently inside the vault
*/
function zbf.Vault.Open(OnBack)

	local title = zbf.language[ "Your Vault" ]
	if OnBack then title = "       " .. zbf.language[ "Your Vault" ] end

	zclib.vgui.Page(title, function(main, top)
		main:SetSize(1200 * zclib.wM, 800 * zclib.hM)

		main.ATM_Vault = true

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		zbf.vgui.AddTopSepeartor(top)

		local drop_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("dropcrypto"), function()

			// Let the player create a list of which currency and how much should be dropped
			zbf.vgui.CurrencySelector(LocalPlayer().zbf_Wallet, function(list)
				zbf.Vault.Drop(list)
			end,function()
				zbf.Vault.Open()
			end,zbf.language[ "Drop" ],zbf.language[ "DropCrypto_tooltip" ])
		end, false)
		drop_btn:Dock(RIGHT)
		drop_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		drop_btn.IconColor = zclib.colors[ "orange01" ]
		drop_btn:SetTooltip(zbf.language[ "DropCrypto_tooltip" ])

		if zbf.config.Crypto.ChatCommand then

			local info = zbf.language[ "ChatCommandInfo" ]
			info = string.Replace(info,"$ChatCommand",zbf.config.Crypto.ChatCommand)

			local InfoBox = vgui.Create("DLabel", top)
		    InfoBox:SetSize(600 * zclib.wM, 80 * zclib.hM)
		    InfoBox:Dock(RIGHT)
		    InfoBox:DockMargin(0 * zclib.wM, 0 * zclib.hM, 10 * zclib.wM, 0 * zclib.hM)
			InfoBox:SetFont(zclib.GetFont("zclib_font_mediumsmall_thin"))
			InfoBox:SetTextColor(zclib.colors["text01"])
			InfoBox:SetText(info)
			InfoBox:SizeToContentsX(0)
			InfoBox:SetContentAlignment(6)
			if zclib.util.GetTextSize(info,zclib.GetFont("zclib_font_mediumsmall_thin")) > 600 then
				InfoBox:SetFont(zclib.GetFont("zclib_font_small"))
			end
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

		if OnBack then
			local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
				pcall(OnBack)
			end, false)
			back_btn:Dock(LEFT)
			back_btn:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			back_btn.IconColor = zclib.colors[ "orange01" ]
		end

		zbf.Vault.Rebuild(main)
	end)
end

function zbf.Vault.Rebuild(main)
	zbf.vgui.CurrencyList(main, LocalPlayer().zbf_Wallet, true, function(itm,id,IsEmpty)
		if zbf.Currency.IsMoney(id) then
			local payout_btn = zbf.vgui.Button(itm,zbf.language[ "Payout" ], zclib.GetFont("zclib_font_small"), zclib.colors[ "green01" ], function()
				zbf.vgui.CurrencyAmountSelector(1, LocalPlayer().zbf_Wallet[1], function(val)
					net.Start("zbf_Wallet_PayoutMoney")
					net.WriteEntity(LocalPlayer())
					net.WriteDouble(val)
					net.SendToServer()
				end)
			end)
			payout_btn:Dock(LEFT)
			payout_btn:DockMargin(270 * zclib.wM, 10 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
		end
	end,nil,true)
end


/*
	Lets the player choose a position where to spawn the Hardware Wallet with the selected Currencys
*/
function zbf.Vault.Drop(CurrencyList)
	if IsValid(zclib_main_panel) then zclib_main_panel:Remove() end

	// Start pointer system to let the player choose where he wants to drop it
	zclib.PointerSystem.Start(LocalPlayer(), function()
		// OnInit
		zclib.PointerSystem.Data.MainColor = zclib.colors[ "orange01" ]
		zclib.PointerSystem.Data.ActionName = zbf.language[ "Drop" ]
		zclib.PointerSystem.Data.CancelName = zbf.language[ "Cancel" ]
	end, function()
		// OnLeftClick

		// Send currency list to server
		if zclib.PointerSystem.Data.Pos == nil then return end
		if not zclib.util.InDistance(zclib.PointerSystem.Data.Pos, LocalPlayer():GetPos(), 500) then return end
		if CurrencyList == nil then return end
		if table.Count(CurrencyList) <= 0 then return end

		net.Start("zbf_Vault_Drop")
		net.WriteVector(zclib.PointerSystem.Data.Pos)
		net.WriteUInt(table.Count(CurrencyList), 8)
		for k,v in pairs(CurrencyList) do
			net.WriteUInt(k,8)
			net.WriteDouble(v)
		end
		net.SendToServer()

		zclib.PointerSystem.Stop()
	end, function()

		// Catch the Target
		if IsValid(zclib.PointerSystem.Data.HitEntity) then
			zclib.PointerSystem.Data.Target = zclib.PointerSystem.Data.HitEntity
		else
			zclib.PointerSystem.Data.Target = nil
		end

		if zclib.util.InDistance(zclib.PointerSystem.Data.Pos, LocalPlayer():GetPos(), 500) then
			zclib.PointerSystem.Data.MainColor = zclib.colors[ "green01" ]
		else
			zclib.PointerSystem.Data.MainColor = zclib.colors[ "red01" ]
		end

		// Update PreviewModel
		if IsValid(zclib.PointerSystem.Data.PreviewModel) then
			if IsValid(zclib.PointerSystem.Data.Target) then
				zclib.PointerSystem.Data.PreviewModel:SetColor(zclib.PointerSystem.Data.MainColor)
				zclib.PointerSystem.Data.PreviewModel:SetPos(zclib.PointerSystem.Data.Target:GetPos())
				zclib.PointerSystem.Data.PreviewModel:SetAngles(zclib.PointerSystem.Data.Target:GetAngles())
				zclib.PointerSystem.Data.PreviewModel:SetModel(zclib.PointerSystem.Data.Target:GetModel())
				zclib.PointerSystem.Data.PreviewModel:SetModelScale(zclib.PointerSystem.Data.Target:GetModelScale())
				zclib.PointerSystem.Data.PreviewModel:SetNoDraw(false)
			else
				zclib.PointerSystem.Data.PreviewModel:SetNoDraw(true)
			end
		end
	end, nil, function() end)
end

zclib.Hook.Add("zbf_Wallet_OnCurrencyUpdated", "zbf_Wallet_OnCurrencyUpdated_vault", function(ent, wallet)
	if IsValid(zclib_main_panel) and ent == LocalPlayer() and zclib_main_panel.ATM_Vault then
		zbf.Vault.Rebuild(zclib_main_panel)
	end
end)

/*
	Allows admins to look at other players Vaults
*/
local Target
net.Receive("zbf_Vault_Admin", function(len)
	zclib.Debug_Net("zbf_Vault_Admin", len)

	Target = net.ReadEntity()

	zbf.Vault.Admin()
end)

concommand.Add("zbf_vault_admin", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
		Target = nil
        zbf.Vault.AdminMain()
    end
end)

function zbf.Vault.AdminMain()
	zclib.vgui.Page("Admin Vault", function(main, top)
		main:SetSize(500 * zclib.wM, 500 * zclib.hM)

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		zbf.vgui.AddTopSepeartor(top)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

		local ContentPanel = vgui.Create("DPanel", main)
		ContentPanel:SetSize(500 * zclib.wM, 180 * zclib.hM)
		ContentPanel:Dock(TOP)
		ContentPanel:DockMargin(50 * zclib.wM, 0 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
		ContentPanel:DockPadding(20 * zclib.wM, 20 * zclib.hM, 20 * zclib.wM, 20 * zclib.hM)
		ContentPanel.Paint = function(s, w, h)
			draw.RoundedBox(5, 0,0, w, h, zclib.colors[ "ui02" ])
			draw.RoundedBox(5, 0,0, w, h, zclib.colors[ "black_a25" ])
		end

		local OnlinePlayers = zbf.vgui.Button(ContentPanel,"Online Players", zclib.GetFont("zclib_font_big"), zbf.colors[ "orange03" ], function(s)
			zbf.Vault.Admin()
		end)
		OnlinePlayers:SetTall(50)
		OnlinePlayers:Dock(TOP)
		OnlinePlayers:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 20 * zclib.hM)

		local Savefiles = zbf.vgui.Button(ContentPanel,"Savefile Editor", zclib.GetFont("zclib_font_big"), zbf.colors[ "orange03" ], function(s)
			main:Close()
			zbf.Vault.AdminSavefiles()
		end)
		Savefiles:SetTall(50)
		Savefiles:Dock(TOP)
		Savefiles:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 20 * zclib.hM)
	end)
end

/*
	Here we display all the diffrent currencys which are currently inside the Targets vault
*/
function zbf.Vault.Admin()

	// Ask who we want to inspect
	if not IsValid(Target) then
		zbf.vgui.PlayerSelection(false, function(ply)
			net.Start("zbf_Vault_Admin")
			net.WriteEntity(ply)
			net.SendToServer()
		end)
		return
	end

	zclib.vgui.Page(Target:Nick(), function(main, top)
		main:SetSize(1200 * zclib.wM, 800 * zclib.hM)

		main.ATM_AdminVault = true

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		zbf.vgui.AddTopSepeartor(top)

		local add_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("plus"), function()

			// Create a full dummy wallet to pick from
			// The values will be 10000000 in that currency
			local FullWallet = {}
			for k,v in pairs(zbf.Currency.List) do FullWallet[k] = 100000000 / zbf.Currency.GetValue(k) end

			// Let the player create a list of which currency and how much should be added
			zbf.vgui.CurrencySelector(FullWallet, function(list)

				// Send to server to be added list
				net.Start("zbf_Wallet_AddCurrencys")
				net.WriteEntity(Target)
				net.WriteUInt(table.Count(list),8)
				for k,v in pairs(list) do
					net.WriteUInt(k,8)
					net.WriteFloat(v)
				end
				net.SendToServer()

				zbf.Vault.Admin()
			end,function()
				zbf.Vault.Admin()
			end,"Add","Adds the specified amount of currencys to the players wallet.")
		end, false)
		add_btn:Dock(RIGHT)
		add_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		add_btn.IconColor = zclib.colors[ "green01" ]

		zbf.Vault.AdminRebuild(main)
	end)
end

/*
	Rebuilds the targets crypto currency list
*/
function zbf.Vault.AdminRebuild(main)
	zbf.vgui.CurrencyList(main, Target.zbf_Wallet, true, function(itm,id,IsEmpty)
		local edit_btn = zbf.vgui.Button(itm,"Edit", zclib.GetFont("zclib_font_small"), zclib.colors[ "orange01" ], function()

			zbf.vgui.CurrencyAmountSelector(id, 100000000000, function(val)
				// Send to server to adjust currency amount
				net.Start("zbf_Wallet_SetCurrency")
				net.WriteEntity(Target)
				net.WriteUInt(id,8)
				net.WriteFloat(val)
				net.SendToServer()
			end,function() end,Target.zbf_Wallet[id] or 0,true)
		end)
		edit_btn:Dock(RIGHT)
		edit_btn:DockMargin(10 * zclib.wM, 10 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
	end)
end

/*
	Rebuilds the targets crypto currency list if it changes
*/
zclib.Hook.Add("zbf_Wallet_OnCurrencyUpdated", "zbf_Wallet_OnCurrencyUpdated_adminvault", function(ent, wallet)
	if IsValid(zclib_main_panel) and ent == Target and zclib_main_panel.ATM_AdminVault then
		zbf.Vault.AdminRebuild(zclib_main_panel)
	end
end)

/*

	This system allows admins to edit the savefiles

*/
local CachedSteamNames = {}
local function GetSteamName(id,Callback)

	if CachedSteamNames[id] then
		pcall(Callback,CachedSteamNames[id])
		return
	end

	steamworks.RequestPlayerInfo(id, function(steamName)
		CachedSteamNames[id] = steamName
		pcall(Callback,steamName)
	end)
end
net.Receive("zbf_Vault_Admin_Request", function(len)
	zclib.Debug_Net("zbf_Vault_Admin_Request", len)

	local dataLength = net.ReadUInt(16)
	local dataDecompressed = util.Decompress(net.ReadData(dataLength))
	local list = util.JSONToTable(dataDecompressed)

	for k,v in pairs(list) do
		GetSteamName(list[k].id,function(name)
			list[k].name = name
		end)
	end

	timer.Simple(1,function()
		zbf.Vault.AdminSavefiles(list)
	end)
end)

local CachedFilelist
function zbf.Vault.AdminSavefiles(Filelist)

	// Send net message to server and ask for the list of all savefiles and their current value
	if not Filelist then

		net.Start("zbf_Vault_Admin_Request")
		net.SendToServer()

		zclib.vgui.Page("Savefile Editor", function(main, top)
			main:SetSize(800 * zclib.wM, 800 * zclib.hM)

			local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
				main:Close()
			end, false)
			close_btn:Dock(RIGHT)
			close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			close_btn.IconColor = zclib.colors[ "red01" ]

			zbf.vgui.AddTopSepeartor(top)

			local ImgurImagePreview = vgui.Create("DPanel", main)
	        ImgurImagePreview:Dock(FILL)
	        ImgurImagePreview:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,10 * zclib.hM)
	        ImgurImagePreview.Paint = function(s, w, h)
	            draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"])

	            surface.SetDrawColor(zclib.colors["text01"])
	            surface.SetMaterial(zclib.Materials.Get("icon_loading"))
	            surface.DrawTexturedRectRotated(w / 2, h / 2, 300 * zclib.wM,300 * zclib.hM, zclib.util.SnapValue(36, CurTime() * -700))
	        end
		end)

		return
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	CachedFilelist = Filelist

	zclib.vgui.Page("Savefile Editor", function(main, top)
		main:SetSize(800 * zclib.wM, 800 * zclib.hM)

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		zbf.vgui.AddTopSepeartor(top)

		local SearchName
		local FullList

		local function RebuildList()
			if IsValid(FullList) then FullList:Remove() end

			local list, scroll = zclib.vgui.List(main)
			scroll:DockMargin(50 * zclib.wM, 0 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
			list:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			list:SetSpaceY(4 * zclib.hM)
			list:SetSpaceX(0 * zclib.wM)

			FullList = scroll

			for k, v in ipairs(Filelist) do

				local Name = string.sub(v.name or "Unkown",1,25)
				local id = v.id

				// If we search for a specific crypto then skip anything that doesent fit
				if SearchName and string.find( string.lower(id .. " " .. Name), string.lower(SearchName) ) == nil then continue end

				local itm = list:Add("DButton")
				itm:SetSize(680 * zclib.wM, 26 * zclib.hM)
				itm:SetText("")
				itm.Paint = function(s, w, h)
					draw.RoundedBox(5, 0, 0, w, h, s:IsHovered() and zclib.colors[ "ui_highlight" ] or zclib.colors[ "ui01" ])
					draw.SimpleText(Name, zclib.GetFont("zclib_font_small"), 10 * zclib.wM, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(id, zclib.GetFont("zclib_font_small"), w / 2 - 50 * zclib.wM, h / 2, zclib.colors[ "white_a100" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(v.total, zclib.GetFont("zclib_font_small"), w - 10 * zclib.wM, h / 2, zclib.colors[ "green01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				end
				itm.DoClick = function(s)
					zclib.vgui.PlaySound("UI/buttonclick.wav")

					// Ask the server to send you all the info about the requested steamid64
					net.Start("zbf_Vault_Admin_RequestData")
					net.WriteString(v.id)
					net.SendToServer()
				end
			end
		end

		local searchbox = zclib.vgui.TextEntry(top, zbf.language[ "Search" ],function(val)
			SearchName = val
			// Setup delay timer to only refresh 1-2 seconds after typing
			local timerid = "zbf_crypto_type_delay"
			zclib.Timer.Remove(timerid)
			zclib.Timer.Create(timerid,1,1,function()
				RebuildList()
			end)
		end)
		searchbox:SetSize(200 * zclib.wM,20 * zclib.hM )
		searchbox:SetPos(150 * zclib.wM,5 * zclib.hM)
		searchbox:Dock(RIGHT)

		RebuildList()
	end)
end

net.Receive("zbf_Vault_Admin_RequestData", function(len)
	zclib.Debug_Net("zbf_Vault_Admin_RequestData", len)

	local steamid64 = net.ReadString()
	local wallet = {}
	local count = net.ReadUInt(20)
	for i = 1,count do
		wallet[net.ReadUInt(20)] = net.ReadFloat()
	end

	zbf.Vault.AdminData(steamid64,wallet)
end)

function zbf.Vault.AdminData(steamid64, wallet)

	GetSteamName(steamid64,function(steamName)

		zclib.vgui.Page("          " .. steamName .. " | " .. steamid64, function(main, top)
			top.Title_font = zclib.GetFont("zclib_font_medium")
			main:SetSize(1200 * zclib.wM, 800 * zclib.hM)

			local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
				zbf.Vault.AdminSavefiles(CachedFilelist)
			end, false)

			back_btn:Dock(LEFT)
			back_btn:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			back_btn.IconColor = zclib.colors[ "orange01" ]

			local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
				main:Close()
			end, false)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

			close_btn:Dock(RIGHT)
			close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			close_btn.IconColor = zclib.colors[ "red01" ]
			zbf.vgui.AddTopSepeartor(top)

			local add_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("plus"), function()

				// Create a full dummy wallet to pick from
				// The values will be 10000000 in that currency
				local FullWallet = {}

				for k, v in pairs(zbf.Currency.List) do
					FullWallet[ k ] = 100000000 / zbf.Currency.GetValue(k)
				end

				// Let the player create a list of which currency and how much should be added
				zbf.vgui.CurrencySelector(FullWallet, function(list)
					for k, v in pairs(list) do
						wallet[ k ] = (wallet[ k ] or 0) + v
					end

					// Rebuild the interface
					zbf.Vault.AdminData(steamid64, wallet)
				end, function()
					zbf.Vault.AdminData(steamid64, wallet)
				end, "Add", "Adds the specified amount of currencys to the players wallet.")
			end, false)

			add_btn:Dock(RIGHT)
			add_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			add_btn.IconColor = zclib.colors[ "green01" ]
			zbf.vgui.AddTopSepeartor(top)

			local SaveAll = zbf.vgui.Button(top, zbf.language[ "Save" ], zclib.GetFont("zclib_font_medium"), zbf.colors[ "orange03" ], function(s)
				// Send the server the new wallet data
				net.Start("zbf_Vault_Admin_SaveData")
				net.WriteString(steamid64)
				net.WriteUInt(table.Count(wallet), 32)

				for k, v in pairs(wallet) do
					net.WriteUInt(k, 20)
					net.WriteFloat(v)
				end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

				net.SendToServer()
				main:Close()
			end)
			SaveAll:Dock(RIGHT)
			SaveAll:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

			local DeleteButton = zbf.vgui.Button(top, "Delete", zclib.GetFont("zclib_font_medium"), zclib.colors[ "red01" ], function(s)

				zbf.vgui.ConfirmationWindow("Delete savefile?", function()

					// Send the server the new wallet data
					net.Start("zbf_Vault_Admin_Delete")
					net.WriteString(steamid64)
					net.SendToServer()

					main:Close()

				end, function() end)
			end)
			DeleteButton:Dock(RIGHT)
			DeleteButton:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

			zbf.vgui.CurrencyList(main, wallet, true, function(itm, id, IsEmpty)
				local edit_btn = zbf.vgui.Button(itm, "Edit", zclib.GetFont("zclib_font_small"), zclib.colors[ "orange01" ], function()
					zbf.vgui.CurrencyAmountSelector(id, 100000000000, function(val)
						wallet[ id ] = val
						// Rebuild the interface
						zbf.Vault.AdminData(steamid64, wallet)
					end, function() end, wallet[ id ] or 0, true)
				end)

				edit_btn:Dock(RIGHT)
				edit_btn:DockMargin(10 * zclib.wM, 10 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
			end)
		end)
	end)
end
