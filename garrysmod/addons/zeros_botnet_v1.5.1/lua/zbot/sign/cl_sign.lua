/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Sign = zbf.Sign or {}
zbf.Sign.List = zbf.Sign.List or {}

/*

	The Crypto Sign displays a historical graph about the currencies growth

*/

function zbf.Sign.Initialize(Sign)
	Sign.Wait = true
	timer.Simple(1,function()
		if IsValid(Sign) then Sign.Wait = false end
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function zbf.Sign.OnDraw(Sign)
	if not zbf.Sign.List[Sign] then
		zbf.Sign.List[Sign] = true
	end
end

zclib.Hook.Add("PostDrawOpaqueRenderables", "zbf_draw_sign", function(depth, skybox, isDraw3DSkybox)
	if isDraw3DSkybox == false and zbf.Sign and zbf.Sign.List then
		for sign, _ in pairs(zbf.Sign.List) do
			if IsValid(sign) then
				zbf.Sign.Draw(sign)
			end
		end
	end
end)

function zbf.Sign.Draw(ent)
	if ent.Wait then return end
	if not LocalPlayer().zbf_Initialized then return end

	// Is the player in distance?
	if zclib.util.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 1000) then

		local curID = ent:GetCurrencyID()
		if ent.LastID ~= curID then
			ent.LastID = curID
			ent.FetchingData = nil
		end

		local curScale = ent:GetUIScale()
		if ent.LastUIScale ~= curScale then
			ent.LastUIScale = curScale
			ent.NewUIScale = curScale
			ent.FetchingData = nil
		end


		if not ent.FetchingData then
			ent.FetchingData = true

			local period = "week"

			local c_data = zbf.Currency.Get(ent:GetCurrencyID())
			if not c_data then return end
			zbf.Coinbase.FetchHistoricData(c_data.short, period, function(data)
				if IsValid(ent) then
					if IsValid(ent.MainPanel) then ent.MainPanel:Remove() end
					zbf.Sign.CreateInterface(ent,data,ent:GetCurrencyID(),period)
				end
			end, function() end)
		end

		if IsValid(ent.MainPanel) then
			zbf.Sign.DrawInterface(ent)
		end
	else
		// Hide the interface
		if IsValid(ent.MainPanel) and ent.MainPanel:IsVisible() then
			ent.MainPanel:SetVisible(false)
		end

		ent.FetchingData = nil
	end
end

local m_pos = Vector(-40 - 12.5,-60 - 12.5,0)
local m_ang = Angle(0, 90, 0)
function zbf.Sign.DrawInterface(ent)
	zclib.vgui3d.Start3D2D(ent:LocalToWorld(m_pos * ent.NewUIScale + Vector(6.4,5.3,1.5)), ent:LocalToWorldAngles(m_ang), 0.1 * (ent.NewUIScale or 1))

		if ent.MainPanel and ent.MainPanel:IsVisible() == false then
			ent.MainPanel:SetVisible(true)
		end

		ent.MainPanel:ZCLIBPaint3D2D()
		ent.MainPanel:Center()

		if zclib.vgui3d.IsPointingPanel(ent.MainPanel) then
			local x, y = zclib.vgui3d.GetCursorPosition(ent.MainPanel)
			draw.RoundedBox(0, x - 1, y - 1, 2, 2, color_white)

			ent.LastCursorX = Lerp(FrameTime() * 3,ent.LastCursorX or 0,x)
			ent.LastCursorY = Lerp(FrameTime() * 3,ent.LastCursorY or 0,y)
		end
	zclib.vgui3d.End3D2D()
end

local function CreatePage(title, content)
	local mainframe = vgui.Create("DPanel")
	mainframe:SetSize(1200, 800)
	mainframe:DockPadding(0, 15, 0, 30)
	mainframe.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui02" ])
		surface.SetMaterial(zclib.Materials.Get("grib_horizontal"))
		surface.SetDrawColor(zclib.colors[ "white_a5" ])
		surface.DrawTexturedRectUV(0, 0, w, 20, 0, 0, w / 30, 20 / 20)
	end

	local top_pnl = vgui.Create("DPanel", mainframe)
	top_pnl:SetSize(600, 80)
	top_pnl:Dock(TOP)
	top_pnl:DockPadding(10, 10, 10 , 20)
	top_pnl:DockMargin(0, 0, 0, 10)
	top_pnl.Title_font = zclib.GetFont("zclib_font_big")

	top_pnl.Paint = function(s, w, h)
		draw.RoundedBox(5, 50 , h - 5, w - 50, 5, zclib.colors[ "ui01" ])
		draw.SimpleText(title, s.Title_font, 50, 35, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	pcall(content, mainframe, top_pnl)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	return mainframe
end

local function FormatTime(time)
	local t = os.date("*t", time)
	if not t then return end

	local day = t.day
	local month = t.month
	local year = t.year
	local hour = t.hour
	local min = t.min

	local short_day = day .. "/" .. month
	local short_time = hour .. ":" .. min
	local default = short_day .. " " .. short_time

	return {
		day = day,
		month = month,
		year = year,
		hour = hour,
		min = min,
		short_day = short_day,
		short_time = short_time,
		default = default
	}
end

function zbf.Sign.CreateInterface(ent,data,id,period)

	ent.MainPanel = CreatePage(zbf.language[ "historicaldata_title" ], function(main, top)

		local container = vgui.Create("DPanel", main)
		container:Dock(FILL)
		container:DockMargin(50,10 ,50 ,10 )
		container.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"])
		end

		local c_data = zbf.Currency.Get(id)

		local pnl = vgui.Create("DPanel", container)
		pnl:SetTall(80)
		pnl:Dock(TOP)
		pnl.Paint = function(s, w, h)
			if c_data.icon then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(c_data.icon)
				surface.DrawTexturedRectRotated(h / 2, h / 2, h * 0.8, h * 0.8, 0)
			end

			draw.SimpleText(c_data.name, zclib.GetFont("zclib_font_big"), h * 1.1, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(c_data.short, zclib.GetFont("zclib_font_big"), h * 1.1 + 10 + zclib.util.GetTextSize(c_data.name, zclib.GetFont("zclib_font_big")), h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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

		local currentValue = zclib.Money.Display(zbf.Currency.Format(id, c_data.value))

		local btnboxpnl = vgui.Create("DPanel", container)
		btnboxpnl:SetTall(80)
        btnboxpnl:Dock(TOP)
		btnboxpnl:DockPadding(0,10,0,0)
		btnboxpnl.Paint = function(s, w, h)
			draw.RoundedBox(0, 0, 0, w, 2, zclib.colors[ "white_a5" ])
			draw.SimpleText(currentValue, zclib.GetFont("zclib_font_bigger"), 20, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(perf_val, zclib.GetFont("zclib_font_medium_thin"), 35 + zclib.util.GetTextSize(currentValue, zclib.GetFont("zclib_font_bigger")), h / 2, perf_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

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

		local DataCount = #data.prices
		local Statlines = {}
		local diff = min - max

		for k, v in pairs(data.prices) do
			local NextData = data.prices[k+1]
			if not NextData then continue end

			local cur_height = Lerp(1 / diff * (min - v.price), 1, 0)
			local next_height = Lerp(1 / diff * (min - NextData.price), 1, 0)

			local price = tonumber(v.price)
			price = zbf.Currency.Format(id, price)
			price = zclib.Money.Display(price)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

			local formatTime = FormatTime(v.time) or "N/A"
			// 224293224
			table.insert(Statlines, {
				start_x = DataCount - (k - 1),
				start_y = cur_height,
				end_x = DataCount - k,
				end_y = next_height,
				time = formatTime,
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
		pnlstat.Paint = function(s, w, h)

			local height = h * 0.80

			local fieldSize = w / #Statlines

			// Dont draw if we dont hover this panel
			local DidDraw = not s:IsHovered()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

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

				if v.lowest then
					draw.SimpleText(min, zclib.GetFont("zclib_font_small"),(v.start_x * fieldSize) - fieldSize, h * 0.14 + v.start_y * height, zclib.colors[ "text01" ], align, TEXT_ALIGN_BOTTOM)
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
			draw.SimpleText(Statlines[ #Statlines ].time.default, zclib.GetFont("zclib_font_small"), 10 , h * 0.96, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(Statlines[ math.floor(#Statlines / 4) ].time.default, zclib.GetFont("zclib_font_small"), w / 1.333, h * 0.96, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Statlines[ math.floor(#Statlines / 2) ].time.default, zclib.GetFont("zclib_font_small"), w / 2, h * 0.96, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Statlines[ math.floor(#Statlines / 1.333) ].time.default, zclib.GetFont("zclib_font_small"), w / 4, h * 0.96, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Statlines[ 1 ].time.default, zclib.GetFont("zclib_font_small"), w - 10 , h * 0.96, zclib.colors[ "text01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		end
    end)
	ent.MainPanel:ParentToHUD()
	ent.MainPanel:SetMouseInputEnabled(true)
end
