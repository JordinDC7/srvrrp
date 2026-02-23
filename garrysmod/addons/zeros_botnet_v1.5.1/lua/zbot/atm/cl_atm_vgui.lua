/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.ATM = zbf.ATM or {}

net.Receive("zbf_ATM_Open", function(len)
	zclib.Debug_Net("zbf_ATM_Open", len)
	zbf.ATM.MainMenu()
end)

/*
	Here we display all the diffrent currencys which are currently inside the usb
*/
function zbf.ATM.MainMenu()
	zclib.vgui.Page(zbf.language[ "Crypto Point" ], function(main, top)
		main:SetSize(1300 * zclib.wM, 800 * zclib.hM)
		top:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

		local oldPaint = main.Paint
		main.Paint = function(s,w,h)
			oldPaint(s,w,h)
			draw.RoundedBox(0, 0,443 * zclib.hM, w, 450 * zclib.hM, zclib.colors[ "ui_highlight" ])
		end

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		zbf.vgui.AddTopSepeartor(top)

		local SunBox = vgui.Create("DPanel", main)
		SunBox:SetSize(1000 * zclib.wM, 350 * zclib.hM)
		SunBox:Dock(TOP)
		SunBox:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		SunBox.Paint = function(s, w, h)
			for i = 1,12 do zclib.util.DrawCircleAdv(w / 2 , 350 * zclib.hM, 30 * (CurTime() * 0.15) + (30 * i), 4, 15, w / 1.6,  zclib.colors["ui_highlight"]) end
		end

		// That box just exist to take up space
		local BottomBox = vgui.Create("DPanel", main)
		BottomBox:SetSize(500 * zclib.wM, 300 * zclib.hM)
		BottomBox:Dock(FILL)
		BottomBox:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		BottomBox.Paint = function(s, w, h) end

		main:InvalidateLayout(true)

		// Spawns crypto icons
		local Duration = 15
		local NextCoin
		local CoinObjects = {}
		local function AddCoin(width,height,timeoffset)
			local id = math.random(#zbf.Currency.List)
			if id <= 1 then return end

			local _x = math.abs(math.sin((CurTime() * 15) - timeoffset)) * width

			table.insert(CoinObjects,{
				icon = zbf.Currency.GetIcon(id),
				time = CurTime() - timeoffset,
				x = _x,
				y = math.Rand(0,height * 0.5),
				scale = math.Rand(1.5,3)
			})
		end

		local IconsBox = vgui.Create("DPanel", main)
		IconsBox:SetSize(main:GetWide(),main:GetTall())
		IconsBox:SetPos(0,top:GetTall() + (15 * zclib.hM))
		IconsBox.Paint = function(s, w, h)

			if NextCoin == nil then
				NextCoin = CurTime() + 1
				for i = 1,4 do AddCoin(w,h,math.Rand(1,4)) end
			end

			if CurTime() > NextCoin then
				NextCoin = CurTime() + 2
				AddCoin(w,h,0)
			end

			for k,v in pairs(CoinObjects) do
				if CurTime() > (v.time + Duration) then
					CoinObjects[k] = nil
					continue
				end

				local fract = (1 / Duration) * math.Clamp(CurTime() - v.time,0,Duration)

				surface.SetDrawColor(255,255,255,255 - (255 * fract))
				surface.SetMaterial(v.icon)
				surface.DrawTexturedRectRotated(v.x,(h + (100 * zclib.hM)) - ((h * 0.8) * fract), 50 * v.scale, 50 * v.scale,math.sin(CurTime()) * 15)
			end

			zclib.util.DrawBlur(s,1,5)


			draw.SimpleText(zbf.language[ "Welcome" ], zclib.GetFont("zclib_font_giant"), w / 2, 150 * zclib.hM, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.RoundedBox(5, w / 3,150 * zclib.hM, w / 3, 4, zclib.colors[ "text01" ])
		end

		// Creates the button box
		local ContentPanel = vgui.Create("DPanel", main)
		ContentPanel:SetSize(500 * zclib.wM, 310 * zclib.hM)
		ContentPanel:Center()

		local xPos = ContentPanel:GetPos()
		ContentPanel:SetPos(xPos,300 * zclib.hM)

		ContentPanel:DockPadding(20 * zclib.wM, 20 * zclib.hM, 20 * zclib.wM, 20 * zclib.hM)
		ContentPanel.Paint = function(s, w, h)
			local x,y = s:LocalToScreen(0,0)
			BSHADOWS.BeginShadow()
			surface.SetDrawColor(255, 0, 0)
			surface.DrawRect(x, y, w, h)
			BSHADOWS.EndShadow(1,3,1,150,0,0,true)

			draw.RoundedBox(5, 0,0, w, h, zclib.colors[ "ui02" ])
			draw.RoundedBox(5, 0,0, w, h, zclib.colors[ "black_a25" ])
		end

		// Add Button "VAULT"
		local VaultButton = zbf.vgui.Button(ContentPanel,zbf.language[ "Your Vault" ], zclib.GetFont("zclib_font_big"), zbf.colors[ "orange03" ], function(s)
			zbf.Vault.Open(function() zbf.ATM.MainMenu() end)
		end)
		VaultButton:SetTall(50)
		VaultButton:Dock(TOP)
		VaultButton:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 20 * zclib.hM)

		// Add Button "TRADE"
		local TradeButton = zbf.vgui.Button(ContentPanel,zbf.language[ "Trade" ], zclib.GetFont("zclib_font_big"), zbf.colors[ "orange03" ], function(s)
			zbf.ATM.Trade()
		end)
		TradeButton:SetTall(50)
		TradeButton:Dock(TOP)
		TradeButton:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 20 * zclib.hM)

		// Add Button "SEND" (Maybe add this as button in the vault)
		local SendButton = zbf.vgui.Button(ContentPanel,zbf.language[ "Transfer" ], zclib.GetFont("zclib_font_big"), zbf.colors[ "orange03" ], function(s)
			zbf.ATM.Transfer()
		end)
		SendButton:SetTall(50)
		SendButton:Dock(TOP)
		SendButton:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 20 * zclib.hM)

		ContentPanel:InvalidateLayout(true)
		ContentPanel:SizeToChildren(true,true)
	end)
end

/*
	Opens the trading interface
*/
function zbf.ATM.Trade()
	zclib.vgui.Page("       " .. zbf.language[ "Trade" ], function(main, top)
		main:SetSize(1300 * zclib.wM, 800 * zclib.hM)

		main.ATM_Trade = true

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
			zbf.ATM.MainMenu()
		end, false)
		back_btn:Dock(LEFT)
		back_btn:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		back_btn.IconColor = zclib.colors[ "orange01" ]

		zbf.vgui.AddTopSepeartor(top)

		local ply = LocalPlayer()

		zbf.vgui.CurrencyList(main, ply.zbf_Wallet, false, function(itm,id,IsEmpty)

			// Add Buy Button
			if zbf.Currency.CanPurchase(id,ply) then
				zbf.vgui.TextButton(itm, zbf.language[ "Buy" ], zclib.GetFont("zclib_font_small"), zbf.colors[ "orange03" ], function()
					local PurchaseMax = math.Clamp(zbf.config.ATM.PurchaseLimit,0,zclib.Money.Get(ply))
					zbf.vgui.CurrencyAmountSelector(id, math.Round(PurchaseMax / zbf.Currency.GetValue(id)), function(val)
						local c_cost = math.Round(val * zbf.Currency.GetValue(id))
						if not zclib.Money.Has(ply, c_cost) then zclib.Notify(ply, zbf.language[ "Not enough money!" ], 1) return end

						net.Start("zbf_ATM_Purchase")
						net.WriteUInt(id,8)
						net.WriteDouble(val)
						net.SendToServer()
					end)
				end)
			end

			// Add Sell Button
			if not IsEmpty and zbf.Currency.CanSell(id,ply) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

				local sell_btn = zbf.vgui.TextButton(itm, zbf.language[ "Sell" ], zclib.GetFont("zclib_font_small"), zbf.colors[ "orange03" ], function()
					zbf.vgui.CurrencyAmountSelector(id, ply.zbf_Wallet[id], function(val)
						net.Start("zbf_ATM_Sell")
						net.WriteUInt(id,8)
						net.WriteDouble(val)
						net.SendToServer()
					end)
				end)
				sell_btn:DockMargin(10 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 10 * zclib.hM)
			end

			local statistic_btn = vgui.Create("DButton", itm)
			statistic_btn:SetWide(itm:GetTall())
			statistic_btn:Dock(RIGHT)
			statistic_btn:DockMargin(10 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 10 * zclib.hM)
			statistic_btn:SetText("")
			statistic_btn.Paint = function(s, w, h)
				zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2,s:IsHovered() and zbf.colors[ "orange03" ] or zclib.colors["black_a100"])
				surface.SetDrawColor(s:IsHovered() and zbf.colors[ "orange03" ] or zclib.colors["black_a100"])
				surface.SetMaterial(zclib.Materials.Get("statistic"))
				surface.DrawTexturedRect(0, 0,w, h)
			end
			statistic_btn.DoClick = function(s)
				zclib.vgui.PlaySound("UI/buttonclick.wav")
				zbf.ATM.LoadHistoricData(id,"day")
			end
			statistic_btn:SetTooltip(zbf.language[ "historicaldata_tooltip" ])
		end,function(id)
			// Dont let the player buy / sell money
			if zbf.Currency.IsMoney(id) then return false end
		end)
	end)
end

/*
	Opens the transfer interface
*/
function zbf.ATM.Transfer()
	zclib.vgui.Page("       " .. zbf.language[ "Transfer" ], function(main, top)
		main:SetSize(1300 * zclib.wM, 800 * zclib.hM)

		main.ATM_Transfer = true

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
			zbf.ATM.MainMenu()
		end, false)
		back_btn:Dock(LEFT)
		back_btn:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		back_btn.IconColor = zclib.colors[ "orange01" ]

		zbf.vgui.AddTopSepeartor(top)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

		local aply = LocalPlayer()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		// Create list of all the currencys we got
		zbf.vgui.CurrencyList(main, aply.zbf_Wallet, true, function(itm,id,IsEmpty)

			zbf.vgui.TextButton(itm, zbf.language[ "Transfer" ], zclib.GetFont("zclib_font_small"), zbf.colors[ "orange03" ], function()
				// How much do we want to send?
				zbf.vgui.CurrencyAmountSelector(id, aply.zbf_Wallet[id], function(val)

					// Who should we send it to?
					zbf.vgui.PlayerSelection(true,function(ply)
						net.Start("zbf_ATM_Transfer")
						net.WriteUInt(id,8)
						net.WriteDouble(val)
						net.WriteEntity(ply)
						net.SendToServer()
					end,function()
						zbf.ATM.Transfer()
					end)
				end)
			end)
		end)
	end)
end

function zbf.ATM.LoadHistoricData(id,period)
    zclib.vgui.Page(zbf.language[ "fetching_data_title" ], function(main, top)
        main:SetSize(1300 * zclib.wM, 800 * zclib.hM)

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]


        local pnl = vgui.Create("DPanel", main)
        pnl:Dock(FILL)
        pnl:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,10 * zclib.hM)
		pnl.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])

			if s.ErrorMessage then
				draw.SimpleText(s.ErrorMessage, zclib.GetFont("zclib_font_medium"), w / 2, 300 * zclib.hM, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			else
				draw.SimpleText(zbf.language[ "fetching_data" ], zclib.GetFont("zclib_font_large"), w / 2, 200 * zclib.hM, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
				surface.SetDrawColor(zclib.colors[ "text01" ])
				surface.SetMaterial(zclib.Materials.Get("icon_loading"))
				surface.DrawTexturedRectRotated(w / 2, h / 2, 300 * zclib.wM, 300 * zclib.hM, zclib.util.SnapValue(36, CurTime() * -700))
			end
		end

		local cData = zbf.Currency.Get(id)
		zbf.Coinbase.FetchHistoricData(cData.short, period, function(data)
			zbf.ATM.DisplayStatistic(id,data,period)
		end, function(error)
			pnl.ErrorMessage = error
		end)
    end)
end

function zbf.ATM.DisplayStatistic(id,data,period)

    zclib.vgui.Page("       " .. zbf.language[ "historicaldata_title" ], function(main, top)
        main:SetSize(1300 * zclib.wM, 800 * zclib.hM)

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
			zbf.ATM.Trade()
		end, false)
		back_btn:Dock(LEFT)
		back_btn:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		back_btn.IconColor = zclib.colors[ "orange01" ]

		local container = vgui.Create("DPanel", main)
		container:Dock(FILL)
		container:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,10 * zclib.hM)
		container.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"])
		end

		local c_data = zbf.Currency.Get(id)

		local pnl = vgui.Create("DPanel", container)
		pnl:SetTall(80 * zclib.hM)
		pnl:Dock(TOP)

		pnl.Paint = function(s, w, h)
			if c_data.icon then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(c_data.icon)
				surface.DrawTexturedRectRotated(h / 2, h / 2, h * 0.8, h * 0.8, 0)
			end

			draw.SimpleText(c_data.name, zclib.GetFont("zclib_font_big"), h * 1.1, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(c_data.short, zclib.GetFont("zclib_font_big"), h * 1.1 + 10 * zclib.wM + zclib.util.GetTextSize(c_data.name, zclib.GetFont("zclib_font_big")), h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local OldValue = data.prices[ #data.prices ].price
		local NewValue = data.prices[ 1 ].price

		local perf_val = math.Round(((100 / OldValue) * NewValue) - 100, 2)
		local perf_color = zclib.colors[ "text01" ]

		if perf_val > 0 then
			perf_val = "+" .. perf_val .. "%"
			perf_color = zclib.colors[ "green01" ]
		elseif perf_val == 0 then
			perf_val = "--%"
			perf_color = zclib.colors[ "green01" ]
		else
			perf_val = perf_val .. "%"
			perf_color = zclib.colors[ "red01" ]
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

		local currentValue = zclib.Money.Display(zbf.Currency.Format(id, c_data.value))

		local btnboxpnl = vgui.Create("DPanel", container)
		btnboxpnl:SetTall(80 * zclib.hM)
        btnboxpnl:Dock(TOP)
		btnboxpnl:DockPadding(0,10,0,0)
		btnboxpnl.Paint = function(s, w, h)
			draw.RoundedBox(0, 0, 0, w, 2, zclib.colors[ "white_a5" ])
			draw.SimpleText(currentValue, zclib.GetFont("zclib_font_bigger"), 20 * zclib.wM, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(perf_val, zclib.GetFont("zclib_font_medium_thin"), 35 * zclib.wM + zclib.util.GetTextSize(currentValue, zclib.GetFont("zclib_font_bigger")), h / 2, perf_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end


		// Lets fine the largest and smallest number in this list
		local max = 0
		local min = 9999999999999
		local HighestID
		local LowestID
		for k,v in ipairs(data.prices) do
			if tonumber(v.price) > max then
				max = tonumber(v.price)
				HighestID = k
			end
			if tonumber(v.price) < min then
				min = tonumber(v.price)
				LowestID = k
			end
		end

		local function FormatTime(time)

			time = os.date( "%H:%M:%S - %d/%m/%Y",time )

			time = string.Split(time,"-")

			local date = string.Split(time[2],"/")

			local year = date[1]
			local month = date[2]
			local day = date[3]

			local glock = string.Split(time[1],":")

			local hour = glock[1]
			local minutes = glock[2]

			local short_time = hour .. ":" .. minutes
			local short_day = day .. ". " .. zbf.language[ "month_short_" .. month ]
			local short_year = zbf.language[ "month_short_" .. month ] .. " " .. year

			local time_data = {}
			if period == "hour" or period == "day" then

				time_data = {
					default = short_time,
					short_time = short_time,
					short_day = short_day,
					short_year = short_year,
				}

			elseif period == "week" or period == "month" then

				time_data = {
					default = short_day,
					short_time = short_time,
					short_day = short_day,
					short_year = short_year,
				}

			elseif period == "year" then

				time_data = {
					default = short_year,
					short_time = short_time,
					short_day = short_day,
					short_year = short_year,
				}

			end

			return time_data
		end

		local DataCount = #data.prices
		local Statlines = {}
		local diff = min - max

		for k,v in ipairs(data.prices) do
			local NextData = data.prices[k+1]
			if not NextData then continue end
			local cur_height = Lerp(1 / diff * (min - v.price), 1, 0)
			local next_height = Lerp(1 / diff * (min - NextData.price), 1, 0)

			local price = tonumber(v.price)
			price = zbf.Currency.Format(id, price)
			price = zclib.Money.Display(price)

			table.insert(Statlines, {
				start_x = DataCount - (k - 1),
				start_y = cur_height,
				end_x = DataCount - k,
				end_y = next_height,
				time = FormatTime(v.time),
				highest = k == HighestID,
				lowest = k == LowestID,
				price = price
			})
		end

		max = zclib.Money.Display(zbf.Currency.Format(id, max))
		min = zclib.Money.Display(zbf.Currency.Format(id, min))

		local function DrawHoverInfo(x,y,dat)
			draw.RoundedBox(5, x - 60, y - 30, 120, 60, zclib.colors["black_a50"])
			draw.SimpleText(dat.price, zclib.GetFont("zclib_font_mediumsmall"), x, y - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(dat.time.short_day .. " " .. dat.time.short_time, zclib.GetFont("zclib_font_mediumsmoll_thin"), x, y + 10, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local pnlstat = vgui.Create("DPanel", container)
		pnlstat:Dock(FILL)
		pnlstat:NoClipping( true )
		pnlstat.Paint = function(s, w, h)

			local height = h * 0.80

			local fieldSize = w / #Statlines

			// Dont draw if we dont hover this panel
			local DidDraw = not s:IsHovered()

			local cX,cY = input.GetCursorPos()
			local lX,lY = s:ScreenToLocal(cX,cY)

			for k, v in ipairs(Statlines) do

				surface.SetDrawColor(zbf.colors["orange03"])
				surface.DrawLine((v.start_x * fieldSize) - fieldSize, h * 0.075 + v.start_y * height, (v.end_x * fieldSize)  - fieldSize, h * 0.075 + v.end_y * height)
				local align = k < #Statlines / 2 and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT

				if v.highest then
					draw.SimpleText(max, zclib.GetFont("zclib_font_small"), (v.start_x * fieldSize) - fieldSize, h * 0.015 + v.start_y * height, zclib.colors[ "text01" ], align, TEXT_ALIGN_TOP)
					surface.SetDrawColor(color_white)
					surface.DrawLine((v.start_x * fieldSize) - fieldSize, h * 0.07 + v.start_y * height, (v.start_x * fieldSize) - fieldSize, h * 0.05 + v.start_y * height)
				end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

				if v.lowest then
					draw.SimpleText(min, zclib.GetFont("zclib_font_small"), (v.start_x * fieldSize) - fieldSize, h * 0.14 + v.start_y * height, zclib.colors[ "text01" ], align, TEXT_ALIGN_BOTTOM)
					surface.SetDrawColor(color_white)
					surface.DrawLine((v.start_x * fieldSize) - fieldSize, h * 0.08 + v.start_y * height, (v.start_x * fieldSize) - fieldSize, h * 0.10 + v.start_y * height)
				end


				// Draw hovered info
				if not DidDraw and lX > (v.start_x * fieldSize) and lX < ((v.start_x * fieldSize) + 5) then
					draw.RoundedBox(3,v.start_x * fieldSize - 3, h * 0.07 + v.start_y * height - 3, 6, 6, color_white)
					DrawHoverInfo(lX, lY - 40,v)
					DidDraw = true
				end
			end

			draw.RoundedBox(5, 0, h * 0.95, w, h * 0.05, zclib.colors[ "black_a50" ])
			draw.SimpleText(Statlines[ #Statlines ].time.default, zclib.GetFont("zclib_font_small"), 10 * zclib.wM, h * 0.96, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(Statlines[ math.floor(#Statlines / 4) ].time.default, zclib.GetFont("zclib_font_small"), w / 1.333, h * 0.96, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Statlines[ math.floor(#Statlines / 2) ].time.default, zclib.GetFont("zclib_font_small"), w / 2, h * 0.96, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Statlines[ math.floor(#Statlines / 1.333) ].time.default, zclib.GetFont("zclib_font_small"), w / 4, h * 0.96, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Statlines[ 1 ].time.default, zclib.GetFont("zclib_font_small"), w - 10 * zclib.wM, h * 0.96, zclib.colors[ "text01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		end

		local SelectedPeriod = period
		local function ChangePeriod(period_val,period_txt)
			local btn = vgui.Create("DButton", btnboxpnl)
			btn:SetSize(80 * zclib.wM, 40 * zclib.hM)
			btn:Dock(RIGHT)
			btn:SetText("")
			btn.Paint = function(s, w, h)
				if period_val == SelectedPeriod then
					draw.SimpleText(period_txt,zclib.GetFont("zclib_font_medium"), w / 2, 0,zbf.colors[ "orange03" ] or zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				else
					draw.SimpleText(period_txt,zclib.GetFont("zclib_font_medium"), w / 2, 0,s:IsHovered() and color_white or zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				end
			end
			btn.DoClick = function(s)
				zclib.vgui.PlaySound("UI/buttonclick.wav")
				zbf.ATM.LoadHistoricData(id,period_val)
			end
		end

		ChangePeriod("year",zbf.language[ "period_year" ])
		ChangePeriod("month",zbf.language[ "period_month" ])
		ChangePeriod("week",zbf.language[ "period_week" ])
		ChangePeriod("day",zbf.language[ "period_day" ])
		ChangePeriod("hour",zbf.language[ "period_hour" ])
    end)
end

zclib.Hook.Add("zbf_Wallet_OnCurrencyUpdated", "zbf_Wallet_OnCurrencyUpdated_atm", function(ent, wallet)
	if IsValid(zclib_main_panel) and ent == LocalPlayer() then
		if zclib_main_panel.ATM_Trade then
			zbf.ATM.Trade()
		end

		if zclib_main_panel.ATM_Transfer then
			zbf.ATM.Transfer()
		end
	end
end)
