/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*
	Called when the player opens the controller interface
*/
local Controller
net.Receive("zbf_Controller_Open", function(len)
	zclib.Debug_Net("zbf_Controller_Open", len)
	Controller = net.ReadEntity()
	zbf.Controller.Main()
end)

/*
	Adds a panel for a BotImage
*/
local function AddBotItem(data)
	local BotID = data.ent:GetBotID()
	local BotData = zbf.Bot.GetData(BotID)

	local itm = vgui.Create("DPanel")
	itm:SetSize(data.PnlSize * zclib.wM, data.PnlSize * zclib.hM)
	itm.Paint = function(s, w, h)

		// If the bot is no longer highjacked and this controller is not the orignaly owner then remove it from the list
		if IsValid(data.ent) and not zbf.Bot.IsHighjacked(data.ent) and not zclib.Player.SharedOwner(data.Controller, data.ent) then
			s:Remove()
			return
		end

		// If the bot got destroyed then remove it from the list
		if not IsValid(data.ent) then
			zclib.vgui.PlayEffectAtPanel("Destroy", s)
			s:Remove()
			return
		end

		local _,_selected = xpcall(data.IsSelected,function() end)

		draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui00" ])
		draw.RoundedBox(5, 0, 0, w, h, _selected and zclib.colors[ "ui02" ] or zclib.colors[ "black_a50" ])
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

		if zbf.Bot.HasError(data.ent) and not zbf.Bot.IsHighjacked(data.ent) then
			draw.RoundedBox(5, 0, 0, w, h, zbf.Bot.GetErrorColor(data.ent:GetErrorType()))
			pcall(data.OnError)
			return
		end

		if IsValid(data.ent:GetController()) then
			if data.ent:GetController() == data.Controller then
				draw.RoundedBox(5, 0, 0, w, h, zclib.Player.SharedOwner(data.Controller, data.ent) and zbf.colors[ "green01" ] or zbf.colors[ "violett01" ])
			else
				draw.RoundedBox(5, 0, 0, w, h, zclib.Player.SharedOwner(data.ent:GetController(), data.ent) and zbf.colors[ "orange01" ] or zbf.colors[ "violett01" ])
			end
		end

		if data.JobID > 0 and not zbf.Bot.IsCompatible(data.ent, data.JobID) then
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "white_a50" ])
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a200" ])
		end

		if input.IsMouseDown(MOUSE_LEFT) then
			if s:IsHovered() and s.StateChanged == nil then
				s.StateChanged = true
				pcall(data.OnClick)
			end
		else
			s.StateChanged = nil
		end
	end

	itm.PaintOver = function(s,w,h)
		// If the controller is highjacked then lets display a violett line that shows for how long
		if IsValid(data.ent) and IsValid(data.ent:GetController()) and not zclib.Player.SharedOwner(data.ent:GetController(), data.ent) and zbf.Bot.IsHighjacked(data.ent) then
			local past = CurTime() - data.ent:GetErrorStart()
			local fract = (1 / data.ent:GetErrorTime()) * past
			fract = math.Clamp(1 - fract,0,1)

			local remain = math.Round(math.Clamp((data.ent:GetErrorStart() + data.ent:GetErrorTime()) - CurTime(),0,data.ent:GetErrorTime()))
			draw.RoundedBox(5, 0, h * 0.9, w * fract, h * 0.1, zclib.colors["black_a200"])
			draw.SimpleText(remain, zclib.GetFont("zclib_font_makro"), 2, 0, zclib.colors[ "black_a200" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end

	local tt = BotData.name

	// Display the level
	if zbf.config.LevelSystem.enabled then
		tt = tt .. " ( Lvl-" .. data.ent:GetLevel().." )"
	end

	if data.JobID > 0 and not zbf.Bot.IsCompatible(data.ent, data.JobID) then
		tt = tt .. "\n" .. zbf.language["[NOT Compatible!]"]
	else
		if IsValid(data.ent:GetController()) then

			if not zclib.Player.SharedOwner(data.ent:GetController(), data.ent) then
				tt = tt .. "\n" .. zbf.language["[Highjacked]"]
			else
				if data.ent:GetController() ~= data.Controller then
					tt = tt .. "\n" .. zbf.language["[Diffrent Controller]"]
				end
			end
		end
	end
	itm:SetTooltip(tt)

	data.list:Add(itm)

	local imgpnl = vgui.Create("DImage", itm)
	imgpnl:Dock(FILL)
	local img = zclib.Snapshoter.Get({
		class = "zbf_bot",
		model = BotData.mdl,
		BotID = BotData.uniqueid
	}, imgpnl)

	imgpnl:SetImage(img and img or "materials/zerochain/zerolib/ui/icon_loading.png")
	imgpnl:SetTooltip(BotData.name)
end

/*
	Creates the Main Menu
*/
local ContentPanel
local LeftSide
function zbf.Controller.Main()
	local owner = zclib.Player.GetOwner(Controller)
	local ownerName = ""
	if owner then ownerName = string.Replace(zbf.language["OwnerS"],"$PLAYENAME",zclib.Player.GetName(owner)) end

	zclib.vgui.Page(ownerName .. zbf.language["BotNet | IP:"] .. " " .. Controller.BotNetIP, function(main, top)
		main:SetSize(1200 * zclib.wM, 800 * zclib.hM)

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		zbf.vgui.AddTopSepeartor(top)

		local money_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("wallet"), function()
			zbf.Controller.CurrencyPortfolio()
		end, false)
		money_btn:Dock(RIGHT)
		money_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		money_btn.IconColor = zclib.colors[ "green01" ]
		money_btn:SetTooltip(zbf.language["Local Wallet"])

		local web_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("web"), function()
			// Open interface to IP Map
			zbf.Controller.IPMap(zbf.language["BotNet Map"], nil, nil, true)
		end, false)
		web_btn:Dock(RIGHT)
		web_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		web_btn.IconColor = zclib.colors[ "blue02" ]
		web_btn:SetTooltip(zbf.language["map_tooltip"])

		if zbf.config.Controller.sell_refund > 0 or not zbf.config.Controller.disable_shop or not zbf.config.Controller.disable_repair then
			zbf.vgui.AddTopSepeartor(top)
		end

		if zclib.Player.IsOwner(LocalPlayer(), Controller) then
			if zbf.config.Controller.sell_refund > 0 then
				local sell_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("minus"), function()
					// Open window to let player select which bot we wants as upgrade
					zbf.Controller.SellBot()
					main:Close()
				end, false)
				sell_btn:Dock(RIGHT)
				sell_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
				sell_btn.IconColor = zbf.colors[ "orange02" ]
				sell_btn:SetTooltip(zbf.language["sell_tooltip"])
			end

			if not zbf.config.Controller.disable_shop then
				local upgrade_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("plus"), function()
					// Open window to let player select which bot we wants as upgrade
					zbf.Controller.BotSelection()
				end, false)
				upgrade_btn:Dock(RIGHT)
				upgrade_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
				upgrade_btn.IconColor = zclib.colors[ "green01" ]
				upgrade_btn:SetTooltip(zbf.language["purchase_tooltip"])
			end

			if not zbf.config.Controller.disable_repair then
				local repair_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("repair"), function()
					zbf.Controller.RepairBot()
					main:Close()
				end, false)
				repair_btn:Dock(RIGHT)
				repair_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
				repair_btn.IconColor = zclib.colors[ "green01" ]
			end
		end

		if zclib.Player.IsAdmin(LocalPlayer()) then
			zbf.vgui.AddTopSepeartor(top)

			local editor_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("edit"), function()
				zbf.Bot.Editor.MainMenu()
			end, false)

			editor_btn:Dock(RIGHT)
			editor_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			editor_btn.IconColor = zclib.colors[ "orange01" ]
			editor_btn:SetTooltip(zbf.language["editor_tooltip"])
		end

		if IsValid(ContentPanel) then ContentPanel:Remove() end
		ContentPanel = vgui.Create("DPanel", main)
		ContentPanel:Dock(FILL)
		ContentPanel:DockMargin(50 * zclib.wM, 5 * zclib.hM, 50 * zclib.wM, 10 * zclib.hM)
		ContentPanel.Paint = function(s, w, h)
			if not IsValid(Controller) then main:Remove() end
		end

		LeftSide = vgui.Create("DPanel", ContentPanel)
		LeftSide:SetSize(300 * zclib.wM, 300 * zclib.hM)
		LeftSide:DockMargin(0 * zclib.wM, 0 * zclib.hM, 10 * zclib.wM, 0 * zclib.hM)
		LeftSide:Dock(LEFT)
		LeftSide.Paint = function(s, w, h) end

		// Setup the list of all near bots
		zbf.Controller.BotList(Controller:GetJobID())

		if Controller:GetJobID() > 0 then
			zbf.Controller.JobConfiguration()
		else
			zbf.Controller.JobSelection(main)
		end
	end)
end

/*
	Display all the available / connected Bots and all the stats
*/
local BotList
function zbf.Controller.BotList(JobID)
	if IsValid(BotList) then
		BotList:Remove()
	end

	BotList = vgui.Create("DPanel", LeftSide)
	BotList:Dock(FILL)
	BotList.Paint = function(s, w, h)
	end
	local stats_pnl

	local function RebuildStats()
		if IsValid(stats_pnl) then
			stats_pnl:Remove()
		end
		stats_pnl = zclib.vgui.Panel(BotList, "[ " .. zbf.language[ "Stats" ] .. " ]")
		stats_pnl:SetSize(300 * zclib.wM, 300 * zclib.hM)
		stats_pnl:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		stats_pnl:Dock(TOP)
		stats_pnl:DockPadding(10 * zclib.wM, 50 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)

		local function AddField(name, val, color)
			local pnl = vgui.Create("DPanel", stats_pnl)
			pnl:SetSize(280 * zclib.wM, 30 * zclib.hM)
			pnl:Dock(TOP)
			pnl.Paint = function(s, w, h)
				draw.RoundedBox(0, 0, 0, w, h, zclib.colors[ "black_a50" ])
				draw.SimpleText(name, zclib.GetFont("zclib_font_small"), 10 * zclib.wM, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.RoundedBox(0, 0, h - 3 * zclib.hM, w, 3 * zclib.hM, zclib.colors[ "black_a50" ])
				draw.SimpleText(val, zclib.GetFont("zclib_font_small"), w - 10 * zclib.wM, h / 2, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end
		end

		AddField(zbf.language[ "TickPerSecond" ] .. ":", zbf.Controller.GetStatValue(Controller, "tps"), zclib.colors[ "text01" ])
		AddField(zbf.language[ "Attack" ] .. ":", zbf.Controller.GetStatValue(Controller, "attack"), zclib.colors[ "red01" ])
		AddField(zbf.language[ "Defense" ] .. ":", zbf.Controller.GetStatValue(Controller, "defense"), zclib.colors[ "blue02" ])
		AddField(zbf.language[ "Neuro" ] .. ":", zbf.Controller.GetStatValue(Controller, "neuro"), zbf.colors[ "orange02" ])

		stats_pnl:InvalidateChildren(true)
		stats_pnl:SizeToChildren(false, true)
	end

	RebuildStats()

	// This handels the multi selection of devices
	local SelectedDevices = {}
	local function UpdateConnection()
		net.Start("zbf_Controller_ConnectDevices")
		net.WriteEntity(Controller)
		net.WriteUInt(table.Count(SelectedDevices), 16)

		for k, v in pairs(SelectedDevices) do
			net.WriteEntity(k)
			net.WriteBool(Controller ~= k:GetController())
		end

		net.SendToServer()
		zclib.vgui.PlaySound("UI/buttonclick.wav")
		SelectedDevices = {}

		// If we are still on this page then rebuild it
		timer.Simple(0.25, function()
			if IsValid(BotList) then
				RebuildStats()
			end
		end)
	end

	local pnl = zclib.vgui.Panel(BotList, "[ " .. zbf.language[ "Bots" ] .. " ]")
	pnl:SetSize(300 * zclib.wM, 300 * zclib.hM)
	pnl:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	pnl:Dock(FILL)

	local connect_btn = zclib.vgui.ImageButton(260 * zclib.wM, 10 * zclib.hM, 30 * zclib.wM, 30 * zclib.hM, pnl, zclib.Materials.Get("link"), function()
		SelectedDevices = {}

		// Get all devices that are not connected yet to "a" controller
		for k, v in pairs(zbf.Controller.GetNearDevices(Controller)) do
			if not IsValid(v) then continue end
			if IsValid(v:GetController()) then continue end
			SelectedDevices[ v ] = true
		end

		UpdateConnection()
	end, false)
	connect_btn.NoneHover_IconColor = zclib.colors[ "ui02" ]
	connect_btn.IconColor = zclib.colors[ "green01" ]
	connect_btn:SetTooltip(zbf.language[ "link_tooltip" ])

	local list, scroll = zclib.vgui.List(pnl)
	scroll:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 10 * zclib.hM)
	list:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	list:SetSpaceY(5 * zclib.hM)
	list:SetSpaceX(5 * zclib.wM)


	local DeviceList = {}
	local ClearList = {}

	// Get all the devices which are close by
	for k, v in pairs(zbf.Controller.GetNearDevices(Controller)) do
		if not IsValid(v) then continue end
		DeviceList[v] = true
		table.insert(ClearList,v)
	end

	// Lets also add any bot thats not yet in the list but also connected to this Controller
	for k, v in pairs(zbf.Controller.GetConnectedDevices(Controller)) do
		if not IsValid(v) then continue end
		if DeviceList[v] then continue end
		DeviceList[v] = true
		table.insert(ClearList,v)
	end

	local FirstSelectedState
	for k,v in pairs(ClearList) do
		AddBotItem({
			Controller = Controller,
			list = list,
			ent = v,
			JobID = JobID,
			PnlSize = 40,
			IsSelected = function() return SelectedDevices[ v ] end,
			OnError = function() SelectedDevices[ v ] = nil end,
			OnClick = function()
				// Nobody can connected / reconnect bots which are highjacked
				if zbf.Bot.IsHighjacked(v) then return end

				// Make sure we only can select the bots with the same state as the first selected
				if FirstSelectedState == nil then
					FirstSelectedState = IsValid(v:GetController())
				end

				if FirstSelectedState then
					if IsValid(v:GetController()) and SelectedDevices[ v ] == nil then
						SelectedDevices[ v ] = true
						zclib.vgui.PlaySound("buttons/blip1.wav")
					end
				else
					if not IsValid(v:GetController()) and SelectedDevices[ v ] == nil then
						SelectedDevices[ v ] = true
						zclib.vgui.PlaySound("buttons/blip1.wav")
					end
				end
			end,
		})
	end

	local LastMouse
	pnl.Think = function(s)
		local curMouse = input.IsMouseDown(MOUSE_LEFT)

		if curMouse == false and curMouse ~= LastMouse and table.Count(SelectedDevices) > 0 then
			UpdateConnection()
			FirstSelectedState = nil
		end

		LastMouse = curMouse
	end
end

/*
	Creates the Job Selection on the ContentPanel
*/
function zbf.Controller.JobSelection(main)

	local HasJobs = true

	local JobSelection = vgui.Create("DPanel", ContentPanel)
	JobSelection:Dock(FILL)
	JobSelection:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	JobSelection.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui01" ])
		draw.SimpleText("[ " .. zbf.language[ "Task Selection" ] .. " ]", zclib.GetFont("zclib_font_medium"), 10 * zclib.wM, 5 * zclib.hM, zclib.colors[ "orange01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		if not HasJobs then
			draw.SimpleText("[ " .. zbf.language[ "NO JOBS AVAILABLE" ] .. " ]", zclib.GetFont("zclib_font_big"), w / 2, h / 2, zclib.colors[ "white_a15" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	local JobList
	local JobInfo

	local function RebuildList()
		if IsValid(JobList) then JobList:Remove() end
		JobList = vgui.Create("DPanel", JobSelection)
		JobList:SetSize(300 * zclib.wM, 30 * zclib.hM)
		JobList:Dock(LEFT)
		JobList:DockMargin(10 * zclib.wM, 50 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
		JobList.Paint = function(s, w, h) end

		local alist, ascroll = zclib.vgui.List(JobList)
		alist:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		alist:SetSpaceY(6 * zclib.hM)
		ascroll:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		ascroll:Dock(FILL)
		ascroll.Paint = function(s, w, h) end

		if IsValid(JobInfo) then JobInfo:Remove() end
		JobInfo = vgui.Create("DPanel", JobSelection)
		JobInfo:Dock(FILL)
		JobInfo:DockMargin(0 * zclib.wM, 50 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
		JobInfo.Paint = function(s, w, h) end

		local content
		local SelectedJob
		local AcceptButton

		/*
			Gets called when job is being selected
		*/
		local function SelectJob(aparent, job_id)

			SelectedJob = job_id

			if IsValid(content) then content:Remove() end
			if IsValid(AcceptButton) then AcceptButton:Remove() end

			// Rebuild Botlist
			zbf.Controller.BotList(job_id)

			local JobData = zbf.Jobs.GetData(job_id)
			if JobData == nil then
				content = vgui.Create("DPanel", aparent)
				content:Dock(FILL)
				content:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
				content:DockPadding(0, 40 * zclib.hM, 0, 0)
				content.Paint = function(s, w, h)
					draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])
				end
				return
			end

			local CryptoIcon
			if zbf.Jobs.IsCryptoJob(job_id) then CryptoIcon = zbf.Currency.GetIcon(JobData.crypto_id) end

			local JobTypeColor = zbf.Jobs.GetJobTypeColor(JobData.type)

			content = vgui.Create("DPanel", aparent)
			content:Dock(FILL)
			content:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			content:DockPadding(0, 40 * zclib.hM, 0, 0)
			content.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])

				if JobData.img then
					BMASKS.BeginMask("zclib_gradient_topdown")
					surface.SetDrawColor(color_white)
					surface.SetMaterial(JobData.img)
					surface.DrawTexturedRect(0, 0, w, h)
					if CryptoIcon then
						local hover = (25 * math.sin(CurTime() * 2)) * zclib.hM
						surface.SetDrawColor(color_white)
						surface.SetMaterial(CryptoIcon)
						surface.DrawTexturedRectRotated(w / 2, (h / 1.7) + hover, w * 0.7, w * 0.7,math.sin(CurTime()) * 10)
						zclib.util.DrawBlur(s,1,3)
					end
					BMASKS.EndMask("zclib_gradient_topdown", w / 2, h / 2, w, h, 150, 180)
				end

				draw.SimpleText(JobData.name, zclib.GetFont("zclib_font_medium"), 10 * zclib.wM, 10 * zclib.hM, JobTypeColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end

			local desc = vgui.Create("DLabel", content)
			desc:SetTall(100 * zclib.hM)
			desc:Dock(TOP)
			desc:DockMargin(10 * zclib.wM, 5 * zclib.hM, 10 * zclib.wM, 0 * zclib.hM)
			desc:SetWrap(true)
			desc:SetContentAlignment(7)
			desc:SetText(zbf.Jobs.GetDesc(job_id))
			desc:SetTextColor(zclib.colors[ "text01" ])
			desc:SetFont(zclib.GetFont("zclib_font_mediumsmoll_thin"))

			local stats = vgui.Create("DPanel", content)
			stats:SetTall(100 * zclib.hM)
			stats:Dock(BOTTOM)
			stats:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			stats.Paint = function(s, w, h)
				draw.RoundedBox(0, 0, 0, w, h, zclib.colors[ "black_a100" ])
				zclib.util.DrawBlur(s, 1, 50)
			end

			local function AddField(name, val, color, font, height,flashred)
				local pnl = vgui.Create("DPanel", stats)
				pnl:SetSize(280 * zclib.wM, height * zclib.hM)
				pnl:Dock(TOP)
				pnl:DockMargin(0, 0 * zclib.hM, 0, 0)
				pnl.Paint = function(s, w, h)
					draw.RoundedBox(0, 0, 0, w, 2, zclib.colors[ "black_a100" ])
					if flashred then
						local redCol = Color(zclib.colors[ "red01" ].r,zclib.colors[ "red01" ].g,zclib.colors[ "red01" ].b,255 * math.abs(math.sin(CurTime() * 3)))
						draw.SimpleText(name, zclib.GetFont("zclib_font_mediumsmall_blur"), 10 * zclib.wM, h / 2, redCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					end
					draw.SimpleText(name, font, 10 * zclib.wM, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(val, font, w - 10 * zclib.wM, h / 2, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				end
			end

			// Show how many ticks are requiered
			AddField(zbf.language[ "Requiered Ticks" ] .. ":", JobData.ticks, zclib.colors[ "text01" ], zclib.GetFont("zclib_font_mediumsmall"), 50)

			/*
			// Display the difficulty according to the jobs error amount
			local diffi = zbf.Jobs.GetDifficulty(job_id)
			AddField(zbf.language[ "Difficulty" ] .. ":", diffi, zclib.util.LerpColor(diffi, zclib.colors[ "green01" ], zclib.colors[ "red01" ]), zclib.GetFont("zclib_font_mediumsmall"), 50)
			*/

			// If it has a cooldown afterwards then show that info
			if JobData.cooldown then
				AddField(zbf.language[ "Cooldown" ] .. ":", JobData.cooldown, zbf.colors[ "text01" ], zclib.GetFont("zclib_font_mediumsmall"), 50)
			end

			// If the JobType is crypto then lets display the crypto value
			if zbf.Jobs.IsCryptoJob(job_id) then
				AddField(zbf.language[ "Current Price" ] .. ":", zclib.Money.Display(zbf.Currency.Format(JobData.crypto_id,zbf.Currency.GetValue(JobData.crypto_id))), zclib.colors[ "green01" ], zclib.GetFont("zclib_font_mediumsmall"), 50)
			end

			// Display the requiered BotNet neuro level in order to do this job
			if JobData.neuro_reg then
				AddField(zbf.language[ "Requiered Neuro Level" ] .. ":", JobData.neuro_reg, zbf.colors[ "orange02" ], zclib.GetFont("zclib_font_mediumsmall"), 50,not zbf.Controller.HasNeuroRequierement(Controller, job_id))
			end

			local c_type, c_amount = zbf.Jobs.GetPayment(job_id, LocalPlayer(),Controller)
			if c_type and c_amount then
				if c_type == ZBF_CURRENCY_MONEY then
					AddField(zbf.language[ "Payment" ] .. ":", zclib.Money.Display(c_amount), zclib.colors[ "green01" ], zclib.GetFont("zclib_font_mediumsmall"), 50)
				else
					AddField(zbf.language[ "Payment" ] .. ":", c_amount .. " " .. zbf.Currency.GetShort(c_type) .. " / " .. zclib.Money.Display(math.Round(zbf.Currency.GetValue(c_type) * c_amount)), zclib.colors[ "green01" ], zclib.GetFont("zclib_font_mediumsmall"), 50)
				end
			end

			// Battle System
			/*
			AttackPoints = Your Attack Strength - Targets Defense Strength

			Ping Attack:		In this attack the BotNet with the higher value wins 	(AttackPoints > 0)
			Steal Attack:		Display the max amount of money you can steal 			(AttackPoints x 10$)
			Cripple Attack:		Display how many bots can be rebooted 					(AttackPoints / 25)
			Crash Attack:		Display how many bots can be crashed 					(AttackPoints / 25)
			*/

			// Display how much money can be stolen
			if job_id == ZBF_JOB_BOTNET_STEAL then
				local money = zbf.Controller.GetAttackValue_Money(Controller)
				AddField(zbf.language[ "Max Steal Amount" ] .. ":", zclib.Money.Display(money), zclib.colors[ "green01" ], zclib.GetFont("zclib_font_mediumsmall"), 50,money <= 0)
			end

			if zbf.Jobs.IsTargetingBots(job_id) then
				local ImpactedBots = zbf.Controller.GetAttackValue_Bots(Controller)
				AddField(zbf.language[ "Impacted Bots" ] .. ":", ImpactedBots, zclib.colors[ "red01" ], zclib.GetFont("zclib_font_mediumsmall"), 50, ImpactedBots <= 0)

				if job_id == ZBF_JOB_BOTNET_CRASH then
					local TotalAttackDamage = zbf.Controller.GetAttackValue_Health(Controller)
					AddField(zbf.language[ "Max Attack Damage" ] .. ":", TotalAttackDamage .. " " .. zbf.language[ "DMG" ], zclib.colors[ "red01" ], zclib.GetFont("zclib_font_mediumsmall"), 50, TotalAttackDamage <= 0)
				end

				if job_id == ZBF_JOB_BOTNET_HIGHJACK then
					local TotalHighjackTime = zbf.Controller.GetAttackValue_Highjack(Controller)
					AddField(zbf.language[ "Max Control Time" ] .. ":", TotalHighjackTime .. zbf.language[ "short_second" ], zclib.colors[ "text01" ], zclib.GetFont("zclib_font_mediumsmall"), 50, TotalHighjackTime <= 0)
				end
			end

			// Display how much the target will be protected against damage
			if job_id == ZBF_JOB_NEURO_SHIELD then
				AddField(zbf.language[ "Reduced Damage" ] .. ":", (100 * zbf.Controller.GetNeuroStrength(Controller)) .. "%", zclib.colors[ "orange01" ], zclib.GetFont("zclib_font_mediumsmall"), 50)
			end


			stats:InvalidateChildren(true)
			stats:SizeToChildren(false, true)

			local b_name = zbf.language[ "Start Task" ]
			local b_color = zclib.colors[ "green01" ]
			if JobData.type == ZBF_JOBTYPE_BOTNET then
				b_name = zbf.language[ "Select IP" ]
			elseif JobData.type == ZBF_JOBTYPE_NEURO then
				b_name = zbf.language[ "Select Player" ]
				if not zbf.Controller.HasNeuroRequierement(Controller, job_id) then
					b_color = zclib.colors[ "ui02_grey" ]
				end
			end

			if zbf.Controller.HasCooldown(Controller, job_id , LocalPlayer()) then
				b_color = zclib.colors[ "ui02_grey" ]
			end

			AcceptButton = zbf.vgui.Button(JobInfo, b_name, zclib.GetFont("zclib_font_big"), b_color, function()
				// If the selected job currently has a cooldown then stop
				if zbf.Controller.HasCooldown(Controller, job_id , LocalPlayer()) then
					local cooldown = math.Round(Controller.Cooldowns[ job_id ] - CurTime())
					zclib.Notify(LocalPlayer(), zbf.language[ "Cooldown" ] .. " " .. cooldown .. zbf.language[ "short_second" ], 1)

					return
				end

				if JobData.type == ZBF_JOBTYPE_NEURO then
					// Check if this controller / BotNet has a high enough Neuro Level
					if not zbf.Controller.HasNeuroRequierement(Controller, job_id) then
						zclib.Notify(LocalPlayer(), zbf.language[ "NeuroLevelTooLow" ], 1)

						return
					end

					// Select Target Player
					zbf.vgui.PlayerSelection(false, function(ply)
						zbf.Controller.StartJob(Controller, SelectedJob, ply:UserID())
					end, function()
						zbf.Controller.Main()
					end,function(pl,w,h)
						// Only show this to bad neuro jobs
						if zbf.Jobs.IsBadNeuroJob(job_id) then
							// Draw the % chance
							local per = 100 * zbf.Controller.Neuro_GetAttackValue(LocalPlayer(),pl)
							draw.RoundedBox(5,w * 0.55,0, w * 0.45, 23 * zclib.hM, zclib.colors[ "black_a200" ])
							draw.SimpleText(per .. "%", zclib.GetFont("zclib_font_small"),w - (5 * zclib.wM),3 * zclib.hM, zbf.GetPercentageColor(per), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
						end
					end,function(pl)
						return zbf.Controller.Neuro_CanTarget(LocalPlayer(),pl)
					end)
					return
				end

				if JobData.type == ZBF_JOBTYPE_BOTNET then

					// Check if our attack level is high enough to even impact a single bot!
					if zbf.Jobs.IsTargetingBots(job_id) and zbf.Controller.GetAttackValue_Bots(Controller) <= 0 then
						zclib.Notify(LocalPlayer(), zbf.language[ "AttackLevelTooLow" ], 1)
						return
					end

					if job_id == ZBF_JOB_BOTNET_STEAL and zbf.Controller.GetAttackValue_Money(Controller) <= 0 then
						zclib.Notify(LocalPlayer(), zbf.language[ "AttackLevelTooLow" ], 1)
						return
					end

					// Select Target BotNet
					zbf.Controller.IPMap(zbf.language[ "Select IP" ], function(BotNetIP)
						zbf.Controller.StartJob(Controller,SelectedJob,BotNetIP)
						Controller.TargetIP = BotNetIP
					end)

					return
				end

				// SelectedJob
				zbf.Controller.StartJob(Controller,SelectedJob,0)
			end)
			AcceptButton:SetTall(60 * zclib.hM)
			AcceptButton:Dock(BOTTOM)
			AcceptButton:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		end

		/*
			Adds a new job to the selection menu
		*/
		local function AddJob(id)

			// Lets just hide any job that currently has a cooldown
			if zbf.Controller.HasCooldown(Controller, id, LocalPlayer()) then return end

			local dat = zbf.config.Jobs[id]
			if dat == nil then return end

			// If its a crypto job and its value has not yet being loaded from coinbase then stop
			if dat.crypto_id and zbf.Currency.GetValue(dat.crypto_id) <= 0 then return end

			// This will display a repeat icon, but only if its not a crypto mining job, Those will repeat no matter what and i rather replace that icon with a Favourites button
			local CanRepeat = zbf.Jobs.CanRepeat(id) and dat.type ~= ZBF_JOBTYPE_CRYPTO

			local OfferEnd = 0
			local OfferTime = zbf.Jobs.GetExpireTime(id)
			if Controller.JobOffers and Controller.JobOffers[ id ] then
				OfferEnd = Controller.JobOffers[ id ]
			end

			local function FormatTime(remain)
				local time = string.FormattedTime(remain)

				local m = math.Round(time.m)
				if m < 10 then
					m = "0" .. m
				end

				local s = math.Round(time.s)
				if s < 10 then
					s = "0" .. s
				end
				return m .. " : " .. s
			end

			local itm = vgui.Create("DButton")
			itm:SetSize(280 * zclib.wM, 30 * zclib.hM)
			itm:SetText("")
			local name_font = zclib.util.FontSwitch(dat.name, itm:GetWide() - 90 * zclib.wM, zclib.GetFont("zclib_font_small"), zclib.GetFont("zclib_font_tiny"))
			local JobTypeColor = zbf.Jobs.GetIconColor(id)
			itm.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, Either(id == SelectedJob, zclib.colors[ "ui_highlight" ], zclib.colors[ "black_a100" ]))

				if OfferTime and OfferEnd > 0 then
					local remain = math.Clamp(OfferEnd - CurTime(), 0, 999999999999999999999)

					// Display the countdown
					draw.SimpleText(FormatTime(remain), zclib.GetFont("zclib_font_tiny"), w - 10 * zclib.wM, h / 2, remain < 30 and zclib.colors[ "red01" ] or zclib.colors[ "text01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					// Times up, remove yourself
					if remain <= 0 then
						s:Remove()
						if SelectedJob == id then
							SelectJob(JobInfo, -1)
						end
					end
				end

				local IsLocked = dat.type == ZBF_JOBTYPE_NEURO and not zbf.Controller.HasNeuroRequierement(Controller, id)
				local IconSize = h * zbf.Jobs.GetIconSize(id)

				surface.SetDrawColor(IsLocked and zclib.colors[ "white_a15" ] or JobTypeColor)
				surface.SetMaterial(zbf.Jobs.GetIcon(id))
				surface.DrawTexturedRectRotated(IconSize * 0.7, h / 2, IconSize, IconSize, 0)

				if CanRepeat then
					surface.SetDrawColor(IsLocked and zclib.colors[ "white_a15" ] or zclib.colors[ "green01" ])
					surface.SetMaterial(zclib.Materials.Get("repeat"))
					surface.DrawTexturedRectRotated(w - h * 0.5, h / 2, h * 0.8, h * 0.8, 0)
				end

				draw.SimpleText(dat.name, name_font, 40 * zclib.wM, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				if IsLocked then draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a100" ]) end
			end
			itm.DoClick = function(s)
				zclib.vgui.PlaySound("UI/buttonclick.wav")
				SelectJob(JobInfo, id)
			end

			// Lets add a favourite button
			if dat.type == ZBF_JOBTYPE_CRYPTO then

				local IsFav = zbf.Currency.IsFav(dat.crypto_id)

				local fav = vgui.Create("DButton",itm)
				fav:SetSize(30 * zclib.wM, 30 * zclib.hM)
				fav:Dock(RIGHT)
				fav:SetText("")
				fav.Paint = function(s, w, h)
					surface.SetDrawColor(IsFav and zclib.colors[ "yellow01" ] or zclib.colors[ "ui02_grey" ])
					surface.SetMaterial(zclib.Materials.Get("star01"))
					surface.DrawTexturedRect(w * 0.1, h * 0.1, w * 0.8, h * 0.8)

					if s:IsHovered() then
						surface.SetDrawColor(zclib.colors[ "white_a100" ])
						surface.SetMaterial(zclib.Materials.Get("star01"))
						surface.DrawTexturedRect(w * 0.1, h * 0.1, w * 0.8, h * 0.8)
					end
				end
				fav.DoClick = function(s)
					zclib.vgui.PlaySound("UI/buttonclick.wav")

					if IsFav then
						zbf.Currency.RemoveFav(dat.crypto_id)
					else
						zbf.Currency.AddFav(dat.crypto_id)
					end

					// Rebuild job page
					RebuildList()
				end
			end

			alist:Add(itm)

			if SelectedJob == nil then
				SelectJob(JobInfo, id)
			end
		end

		/*
			Adds a seperation panel in between the jobs
		*/
		local function AddSep(title,color)
			local col_a = Color(color.r,color.g,color.b,25)

			local itm = vgui.Create("DPanel")
			itm:SetSize(280 * zclib.wM, 30 * zclib.hM)
			itm.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a150" ])
				if title then
					surface.SetDrawColor(color)
					surface.SetMaterial(zclib.Materials.Get("linear_gradient_a"))
					surface.DrawTexturedRectRotated(w / 2, h / 2, w, h,0)

					draw.SimpleText(title, zclib.GetFont("zclib_font_mediumsmall_blur"), 10 * zclib.wM, h / 2, col_a, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(title, zclib.GetFont("zclib_font_mediumsmall"), 10 * zclib.wM, h / 2, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
			end
			alist:Add(itm)
		end

		// Here we display all the job offers
		if table.Count(Controller.JobOffers) > 0 then
			AddSep(zbf.language[ "Contracts" ],zclib.colors[ "orange01" ])
			for k,v in pairs(Controller.JobOffers) do
				// We should not even have any that we cant do since the same check is run on SERVER where we get them assigned, but just for good measure lets check again
				if not zbf.Jobs.CanDo(k,LocalPlayer()) then continue end
				AddJob(k)
			end
		end

		// Here we display all the unlocked jobs
		if table.Count(zbf.Controller.GetUnlockedJobs(LocalPlayer())) > 0 then
			AddSep(zbf.language[ "Completed" ],zclib.colors[ "orange01" ])
			for k,v in pairs(zbf.Controller.GetUnlockedJobs(LocalPlayer())) do AddJob(k) end
		end

		// Here we display all the other jobs
		local LastType
		for k, v in pairs(zbf.config.Jobs) do
			if v == nil then continue end

			// We did all the available job offers above so lets skip them here
			if zbf.Jobs.IsContract(k) then continue end

			// Is the player allowed todo this job?
			if not zbf.Jobs.CanDo(k,LocalPlayer()) then continue end

			// The type of jobs have changed, lets add a seperator
			if LastType == nil or LastType ~= v.type then

				// Before we add the default Crypto list we want to add our Favourites
				if v.type == ZBF_JOBTYPE_CRYPTO and table.Count(zbf.Currency.Favourites) > 0 then
					AddSep("Favourites",zclib.colors["yellow01"])
					for a,b in pairs(zbf.config.Jobs) do
						if not zbf.Jobs.CanDo(a,LocalPlayer()) then continue end
						if b and b.type == ZBF_JOBTYPE_CRYPTO and zbf.Currency.IsFav(b.crypto_id) then
							AddJob(a)
						end
					end
				end

				// Now add the job category
				AddSep(zbf.Jobs.GetJobTypeName(v.type),zbf.Jobs.GetJobTypeColor(v.type))
			end
			LastType = v.type

			// Now if the next job is a crypto currency and a favourite then stop since we added them before
			if v and v.type == ZBF_JOBTYPE_CRYPTO and zbf.Currency.IsFav(v.crypto_id) then continue end

			AddJob(k)
		end

		HasJobs = #alist:GetChildren() > 0
	end

	RebuildList()
end

/*
	Creates the Job Progress Window
*/
LocalPlayer().zbf_Job_Mute = false
LocalPlayer().zbf_Job_Effects = false
function zbf.Controller.JobConfiguration()
	Controller.ConnectedDevices = zbf.Controller.GetConnectedDevices(Controller)
	local JobID = Controller:GetJobID()
	local JobData = zbf.config.Jobs[ JobID ]
	local JobType = JobData.type
	local JobTypeData = zbf.Jobs.GetJobTypeData(JobType)
	local job_col = zbf.Jobs.GetJobTypeColor(JobType)

	local c_type, c_amount = zbf.Jobs.GetPayment(JobID, LocalPlayer(),Controller)

	local main = vgui.Create("DPanel", ContentPanel)
	main:Dock(FILL)
	main:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	main.Paint = function(s, w, h) end

	local t_title = ""
	if JobType == ZBF_JOBTYPE_BOTNET or JobType == ZBF_JOBTYPE_NEURO then
		t_title = JobData.name .. " ► " .. Controller:GetTargetName()
	else
		if c_type and c_amount then
			if c_type == ZBF_CURRENCY_MONEY then
				t_title = zclib.Money.Display(c_amount)
			else

				t_title = "x" .. c_amount .. " " .. zbf.Currency.GetShort(c_type) .. " / " .. zclib.Money.Display(math.Round(zbf.Currency.GetValue(c_type) * c_amount))
			end
			t_title = "► " .. t_title
		end
	end

	local top = vgui.Create("DPanel", main)
	top:SetSize(300 * zclib.wM, 50 * zclib.hM)
	top:Dock(TOP)
	top.Paint = function(s, w, h) draw.SimpleText(t_title, zclib.GetFont("zclib_font_medium"), 60 * zclib.wM, 25 * zclib.hM, job_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end

	local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
		zbf.Controller.StartJob(Controller,0,0)
		zbf.Controller.Main()
	end, false)
	back_btn:Dock(LEFT)
	back_btn:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	back_btn.IconColor = zclib.colors[ "red01" ]

	// Add mute button and remember state
	local volume_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, LocalPlayer().zbf_Job_Mute and zclib.Materials.Get("mute") or zclib.Materials.Get("volume"), function(s)
		LocalPlayer().zbf_Job_Mute = not LocalPlayer().zbf_Job_Mute
		s.IconImage = LocalPlayer().zbf_Job_Mute and zclib.Materials.Get("mute") or zclib.Materials.Get("volume")
	end, false)
	volume_btn:Dock(RIGHT)
	volume_btn:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	volume_btn.IconColor = zclib.colors[ "orange01" ]
	volume_btn:SetTooltip(zbf.language[ "mutesound_tooltip" ])

	// Add mute button and remember state
	local effect_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("star01"), function(s)
		LocalPlayer().zbf_Job_Effects = not LocalPlayer().zbf_Job_Effects
		s.IconImage = LocalPlayer().zbf_Job_Effects and zclib.Materials.Get("zbf_noeffect") or zclib.Materials.Get("zbf_effect")
	end, false)
	effect_btn:Dock(RIGHT)
	effect_btn:DockMargin(0 * zclib.wM, 0 * zclib.hM, 10 * zclib.wM, 0 * zclib.hM)
	effect_btn.IconImage = LocalPlayer().zbf_Job_Effects and zclib.Materials.Get("zbf_noeffect") or zclib.Materials.Get("zbf_effect")
	effect_btn:SetTooltip(zbf.language[ "muteeffect_tooltip" ])

	// Add button to show the background image in full
	local DescriptionPanel
	local ShowBackgroundImage = false
	local bg_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("image"), function(s)
		ShowBackgroundImage = not ShowBackgroundImage
		s.NoneHover_IconColor = ShowBackgroundImage and zclib.colors["text01"] or zclib.colors["ui01"]
		if DescriptionPanel then
			DescriptionPanel:SetVisible(not ShowBackgroundImage)
		end
	end, false)
	bg_btn:Dock(RIGHT)
	bg_btn:DockMargin(0 * zclib.wM, 0 * zclib.hM, 10 * zclib.wM, 0 * zclib.hM)
	bg_btn.NoneHover_IconColor = ShowBackgroundImage and zclib.colors["text01"] or zclib.colors["ui01"]
	bg_btn:SetTooltip(zbf.language[ "showbgimage_tooltip" ])


	local bsize = 5 * zclib.wM
	local progress = vgui.Create("DPanel", main)
	progress:Dock(FILL)
	progress:DockMargin(0 * zclib.wM, 5 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

	progress.GetCircleRadius = function(s,w,h) return h - 200 * zclib.wM end

	progress.GetCenter = function(s,w,h)
		return w / 2, h / 1.9
	end

	progress.GetDevicePos = function(s, w, h, id)
		local center_x, center_y = s:GetCenter(w,h)
		local circle_size = s:GetCircleRadius(w,h)
		local rad = circle_size / 2
		local dCount = table.Count(Controller.ConnectedDevices)
		local ang = math.rad(id / dCount * 360)
		local x = math.cos(ang) * rad
		local y = math.sin(ang) * rad
		x = center_x + x - bsize / 2
		y = center_y + y - bsize / 2

		return x, y
	end

	// Get the current Progress of the job
	progress.SmoothProgress = Controller:GetJobProgress()
	local tick_objs = {}

	/*
		This will handle which audio to play per tick according to the JobType
	*/
	local SequenceInterval = JobTypeData.snd_seq_interval
	local SequenceCount = JobTypeData.snd_seq_count
	local AudioSequence = {}
	for i = 1, SequenceCount do AudioSequence[ i ] = string.Replace(JobTypeData.snd_seq, "$KEY", i) end

	local ActiveBeat = 1
	local NextBeat = 0
	local VGUIEffect = zbf.Jobs.GetVGUIEffect(JobType)

	local function PlayBeat(s, w, h)
		if not LocalPlayer().zbf_Job_Mute then
			zclib.vgui.PlaySound(AudioSequence[ ActiveBeat ])
			//zclib.vgui.PlaySound("zbf/pop0" .. math.random(5) .. ".wav")
		end

		// Causes the JobType Icon to pulse in beat
		progress.SmoothAlpha = 125

		ActiveBeat = ActiveBeat + 1
		if ActiveBeat > SequenceCount then
			ActiveBeat = 1
		end
	end

	// This will increase per tick and defines how many beats we are allowed to play
	local BeatGauge = zbf.Controller.GetTicksPerSecond(Controller)
	local LastPlay = 0
	local ShouldPlay = BeatGauge > 10
	local snd_complete = "zbf_jobtype_" .. JobType .. "_seq_complete"

	local function BeatLogic(s, w, h)
		zclib.util.LoopedSound(LocalPlayer(), snd_complete, ShouldPlay)
		if CurTime() < NextBeat then return end
		NextBeat = CurTime() + SequenceInterval
		if BeatGauge <= 0 then return end

		// If the Beat took longer then the sequence interval + 0.05 then this means we are out of synch
		local IsDesynch = BeatGauge < 3
		if ActiveBeat >= SequenceCount and CurTime() >= LastPlay then
			ShouldPlay = not IsDesynch
			LastPlay = CurTime() + 0.25
		end

		BeatGauge = math.Clamp(BeatGauge - 1, 0, 15)
		PlayBeat(s, w, h)
	end

	local function OnTick(s, w, h)
		BeatGauge = math.Clamp(BeatGauge + 1, 0, 15)

		if not LocalPlayer().zbf_Job_Effects then
			if ShouldPlay then
				// NOTE This refraction effect doesent look that good, idk, i just disabled it for now
				//zclib.vgui.PlayEffectAtPanel("zbf_jobtype_complete_vgui", s, 0, 15 * zclib.hM)
			end

			// BUG The effect dont spread correctly in the 64x Branch
			zclib.vgui.PlayEffectAtPanel(VGUIEffect, s, 0, 15 * zclib.hM)
		end
	end

	progress.OnRemove = function() LocalPlayer():StopSound(snd_complete) end

	local c_icon
	local c_icon_color = zbf.Jobs.GetIconColor(JobID)
	if zbf.Jobs.IsCryptoJob(JobID) then
		c_icon = zbf.Currency.GetIcon(c_type) or ""
	else
		c_icon = zbf.Jobs.GetIcon(JobID) or ""
	end

	local JobTypeColor = zbf.Jobs.GetJobTypeColor(JobData.type)

	progress.Paint = function(s, w, h)

		if ShowBackgroundImage and JobData and JobData.img then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(JobData.img)
			surface.DrawTexturedRect(0, 0, w, h)
			return
		end

		draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui01" ])
		BeatLogic(s, w, h)

		local center_x, center_y = s:GetCenter(w,h)
		local circle_size = s:GetCircleRadius(w,h)
		local fract = 1 / JobData.ticks * progress.SmoothProgress

		if JobData and JobData.img then
			BMASKS.BeginMask("zclib_gradient_topdown")
			surface.SetDrawColor(color_white)
			surface.SetMaterial(JobData.img)
			surface.DrawTexturedRect(0, 0, w, h)
			BMASKS.EndMask("zclib_gradient_topdown", w / 2, h / 2, w, h, 100, 180)

			// Lets draw the job icon
			if zbf.Jobs.IsCryptoJob(JobID) then
				BMASKS.BeginMask("radial_shadow")
				local mSize = circle_size * 1.1
				surface.SetDrawColor(c_icon_color)
				surface.SetMaterial(c_icon)
				surface.DrawTexturedRectRotated(center_x, center_y, circle_size,circle_size,CurTime() * 15)
				BMASKS.EndMask("radial_shadow",center_x - (mSize / 2), center_y - (mSize / 2), mSize,mSize, 255, 0)
			else
				if JobType ~= ZBF_JOBTYPE_GENERIC then

					s.SmoothJumping = Lerp(FrameTime(),s.SmoothJumping or 0,ShouldPlay and 15 * math.sin(CurTime() * 5) or 0)
					s.SmoothScaling = Lerp(FrameTime(),s.SmoothScaling or 1,ShouldPlay and 0.8 + math.abs(math.sin(CurTime() * 10)) * 0.2 or 1)
					s.SmoothAlpha = Lerp(FrameTime() * 5,s.SmoothAlpha or 255,0)

					local PulseColor = Color(c_icon_color.r,c_icon_color.g,c_icon_color.b,50 + s.SmoothAlpha)

					surface.SetDrawColor(PulseColor)
					surface.SetMaterial(c_icon)
					surface.DrawTexturedRectRotated(center_x, center_y, circle_size * s.SmoothScaling,circle_size * s.SmoothScaling,s.SmoothJumping)
				end
			end
			zclib.util.DrawBlur(s,1,5)
		end

		draw.SimpleText(JobData.name, zclib.GetFont("zclib_font_medium"), 10 * zclib.wM, 5 * zclib.hM, JobTypeColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		//////////////
		// Lets make a hard reset every 10 seconds or so
		if progress.HardReset == nil or CurTime() > progress.HardReset then
			progress.SmoothProgress = Controller:GetJobProgress()
			progress.HardReset = CurTime() + 10
		end

		local C_TicksPerSecond = zbf.Controller.GetTicksPerSecond(Controller)
		local Increase = C_TicksPerSecond * FrameTime()
		progress.SmoothProgress = math.Clamp(progress.SmoothProgress + Increase,0,JobData.ticks)

		//////////////
		if progress.SmoothProgress >= JobData.ticks and not JobData.cooldown then

			// Create money effect when we get payed
			if c_type then zclib.vgui.PlayEffectAtPanel("Sell", s, w * math.Rand(-0.25, 0.25), h * math.Rand(-0.25, 0.25)) end

			progress.SmoothProgress = 0
		end

		// Draw the progress bar of the job
		zbf.vgui.ProgressBar(w * 0.9, h * 0.05,  w * 0.05, h * 0.9, fract, zclib.colors["green01"], zclib.colors["text01"])
		draw.SimpleText(math.Round(progress.SmoothProgress) .. " / " .. JobData.ticks, zclib.GetFont("zclib_font_small"), w / 2, h - 44 * zclib.hM, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		Controller.ConnectedDevices = zbf.Controller.GetConnectedDevices(Controller)

		if Controller.ConnectedDevices then
			for k, v in pairs(Controller.ConnectedDevices) do
				if not IsValid(v) then continue end
				local x, y = s:GetDevicePos(w, h, k)

				// Draw the white line to the center
				surface.SetDrawColor(zclib.colors[ "white_a5" ])
				surface.DrawLine(x + bsize / 2, y + bsize / 2, center_x, center_y)

				// Draw a colored dot for the state of the bot
				surface.SetDrawColor(zbf.Bot.GetStateColor(v, JobID))
				surface.DrawRect(x, y, bsize, bsize)
				if zbf.Bot.IsWorking(v) == false then continue end
				local ticks = zbf.Bot.GetTicksPerSecond(v)

				if ticks < 1 then
					local c_move = LerpVector(v.progress, Vector(x, y, 0), Vector(center_x, center_y, 0))
					surface.SetDrawColor(job_col)
					surface.DrawRect(c_move.x, c_move.y, bsize, bsize)

					if v.LastProgress and v.progress < v.LastProgress then
						OnTick(s, w, h)
					end

					v.LastProgress = v.progress
				else
					if v.NextTick == nil or CurTime() >= v.NextTick then
						local time = 1 / ticks

						for i = 1, ticks do
							local start = CurTime() + time * (i - 1)

							table.insert(tick_objs, {
								t_start = start,
								dur = 1,
								id = k
							})
						end

						v.NextTick = CurTime() + 1
					end
				end
			end

			for k, v in pairs(tick_objs) do
				local x, y = s:GetDevicePos(w, h, v.id)
				local c_fract = math.Clamp(CurTime() - v.t_start, 0, v.dur)
				local c_move = LerpVector(1 / v.dur * c_fract, Vector(x, y, 0), Vector(center_x, center_y, 0))
				local left = c_move.x
				local forward = c_move.y
				surface.SetDrawColor(job_col)
				surface.DrawRect(left, forward, bsize, bsize)

				if CurTime() >= v.t_start + v.dur then
					tick_objs[ k ] = nil
					OnTick(s, w, h)
				end
			end
		end
	end

	DescriptionPanel = vgui.Create("DLabel", progress)
	DescriptionPanel:SetTall(100 * zclib.hM)
	DescriptionPanel:Dock(TOP)
	DescriptionPanel:DockMargin(10 * zclib.wM, 40 * zclib.hM, 10 * zclib.wM, 0 * zclib.hM)
	DescriptionPanel:SetWrap(true)
	DescriptionPanel:SetContentAlignment(7)
	DescriptionPanel:SetText(zbf.Jobs.GetDesc(JobID))
	DescriptionPanel:SetTextColor(zclib.colors[ "text01" ])
	DescriptionPanel:SetFont(zclib.GetFont("zclib_font_mediumsmoll_thin"))
end

/*
	Creates a info window about the selected field
*/
local FieldInfo
local function DisplayDetail(BotNetIP,window,parentwindow,OnSelect)

	// Do we know which controller entity this field is assigned to
	local CacheData = Controller.IPCache[ BotNetIP ]

	local function AddField(name, val, color, font, height)
		local pnl = vgui.Create("DPanel", window)
		pnl:SetSize(280 * zclib.wM, height * zclib.hM)
		pnl:Dock(TOP)
		pnl.Paint = function(s, w, h)
			draw.RoundedBox(0, 0, 0, w, h, zclib.colors[ "black_a50" ])
			zclib.util.DrawOutlinedBox(0, 0, w, h, 2, zclib.colors[ "black_a50" ])
			draw.SimpleText(name, font, 10 * zclib.wM, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(val, font, w - 10 * zclib.wM, h / 2, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
	end

	local avatar = vgui.Create("DPanel", window)
	avatar:SetSize(250 * zclib.wM, 250 * zclib.wM)
	avatar:Dock(TOP)
	avatar:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	avatar.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, zclib.colors[ "black_a50" ])
		zclib.util.DrawOutlinedBox(0, 0, w, h, 2, zclib.colors[ "black_a50" ])

		if CacheData then
			draw.SimpleText("[" .. zbf.language[ "EMPTY" ] .. "]", zclib.GetFont("zclib_font_large"), w / 2, h / 2, zclib.colors[ "white_a5" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("?", zclib.GetFont("zclib_font_giant"), w / 2, h / 2, zclib.colors[ "white_a5" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if s.m_Material then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(s.m_Material)
			surface.DrawTexturedRect(0, 0, w, h)
		end
	end

	AddField(zbf.language[ "IP" ] .. ":", BotNetIP, zclib.colors[ "text01" ], zclib.GetFont("zclib_font_mediumsmall"), 40)

	if CacheData == nil then return end

	// When was this field last updated from this controller
	local LastUpdate = CacheData.LastUpdate or 0
	LastUpdate = zclib.util.FormatTime(CurTime() - LastUpdate)
	AddField(zbf.language[ "Last Ping" ] .. ":", LastUpdate, zclib.colors[ "text01" ], zclib.GetFont("zclib_font_smoll"), 26)

	// Foreign Connections inside the BotNet
	local FC = CacheData.ForeignConnections or 0
	AddField(zbf.language[ "Foreign Connections" ] .. ":", FC, zclib.colors[ "red01" ], zclib.GetFont("zclib_font_small"), 26)

	local ctrl = CacheData.ControllerEntity
	if not IsValid(ctrl) then return end
	local job = CacheData.ControllerEntity:GetJobID()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	if job > 0 then
		local jtype = zbf.Jobs.GetType(job)
		AddField(zbf.language[ "JobType" ] .. ":",zbf.Jobs.GetJobTypeName(jtype), zbf.Jobs.GetJobTypeColor(jtype), zclib.GetFont("zclib_font_small"), 26)
	else
		AddField(zbf.language[ "Current State" ] .. ":",zbf.language[ "Idle" ], zclib.colors[ "text01" ], zclib.GetFont("zclib_font_small"), 26)
	end
	//AddField(zbf.language[ "Current State" ] .. ":",job > 0 and zbf.language[ "Working" ] or zbf.language[ "Idle" ], zclib.colors[ "text01" ], zclib.GetFont("zclib_font_small"), 26)

	local InfoPanel
	InfoPanel = vgui.Create("DPanel", parentwindow)
	InfoPanel:SetSize(400 * zclib.wM, 590 * zclib.hM)
	InfoPanel:SetPos(290 * zclib.wM,0 * zclib.hM)
	InfoPanel:DockPadding(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	InfoPanel:Dock(NODOCK)
	InfoPanel:DockMargin(0,0,0,0)
	InfoPanel.Paint = function(s, w, h) draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui02" ]) end

	/*
		A simple function to delete and rebuild its content
	*/
	local InfoContent
	local function RebuildInfoPanel(OnBuild)
		if IsValid(InfoContent) then InfoContent:Remove() end
		InfoContent = vgui.Create("DPanel", InfoPanel)
		InfoContent:Dock(FILL)
		InfoContent.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])
		end

		pcall(OnBuild,InfoContent)
	end

	/*
		Creates a list with all the connected bots on the network
	*/
	local function BuildBotList(pnl)
		local ConnectedBots = zbf.Controller.GetConnectedDevices(ctrl)

		local botList = zclib.vgui.Panel(pnl, "")
		botList:Dock(FILL)
		botList:DockMargin(0,0,0,0)
		botList.BG_color = zclib.colors[ "black_a50" ]
		botList.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui02" ])
			draw.SimpleText(zbf.language[ "Bots" ] .. ":", zclib.GetFont("zclib_font_medium"), 10 * zclib.wM, 5 * zclib.hM, zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			if table.Count(ConnectedBots) <= 0 then
				draw.SimpleText("[" .. zbf.language[ "EMPTY" ] .. "]", zclib.GetFont("zclib_font_large"), w / 2, h / 2, zclib.colors[ "white_a5" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		local list, scroll = zclib.vgui.List(botList)
		scroll:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 10 * zclib.hM)
		list:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		list:SetSpaceY(5 * zclib.hM)
		list:SetSpaceX(5 * zclib.wM)

		// Get all the devices which are close by
		local JobID = ctrl:GetJobID()
		//local PnlSize = 48
		for k, v in pairs(ConnectedBots) do
			if not IsValid(v) then continue end


			AddBotItem({
				Controller = ctrl,
				list = list,
				ent = v,
				JobID = JobID,
				PnlSize = 48,
				IsSelected = function() return false end,
				OnError = function() end,
				OnClick = function() end,
			})
		end
	end

	/*
		Creates a list with all the currencies inside the BotNet
	*/
	local function BuildCurrencyPortfolio(pnl)

		// Display all currencies in the controller
		local currencyList = zclib.vgui.Panel(pnl,"")
		currencyList:Dock(FILL)
		currencyList:DockMargin(0,0,0,0)
		currencyList:DockPadding(0, 50 * zclib.hM, 0, 10 * zclib.hM)
		currencyList.Paint = function(ss, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui02" ])
			draw.SimpleText(zbf.language["Local Wallet"] .. ":", zclib.GetFont("zclib_font_medium"), 10 * zclib.wM, 5 * zclib.hM, zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			if ctrl.zbf_Wallet and table.Count(ctrl.zbf_Wallet) <= 0 then
				draw.SimpleText("[" .. zbf.language[ "EMPTY" ] .. "]", zclib.GetFont("zclib_font_large"), w / 2, h / 2, zclib.colors[ "white_a5" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		local list, scroll = zclib.vgui.List(currencyList)
		scroll:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		list:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		list:SetSpaceY(10 * zclib.hM)
		list:SetSpaceX(10 * zclib.wM)

		// Display all the currencys that are currently stored inside the controller
		if ctrl.zbf_Wallet == nil then ctrl.zbf_Wallet = {} end
		for k, v in pairs(zbf.Currency.List) do

			local CurrencyValue = zbf.Currency.GetValue(k)
			local CurrencyAmount = ctrl.zbf_Wallet[k] or 0

			if CurrencyAmount <= 0 then continue end

			local MoneyAmount = math.Round(CurrencyAmount * CurrencyValue)

			local c_name = zbf.Currency.GetName(k)

			local itm = list:Add("DPanel")
			itm:SetSize(365 * zclib.wM, 60 * zclib.hM)
			itm:SetText("")
			itm.Paint = function(sel, w, h)
				draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui_highlight" ])

				if sel.crypto_icon then
					if isstring(sel.crypto_icon) then
						draw.SimpleText(sel.crypto_icon, zclib.GetFont("zclib_font_big"), h / 2, h / 2, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						surface.SetDrawColor(color_white)
						surface.SetMaterial(sel.crypto_icon)
						surface.DrawTexturedRect(h * 0.15,h * 0.15,h * 0.7,h * 0.7)
					end
				else
					draw.RoundedBox(5, 0, 0, h, h, zclib.colors[ "blue02" ])
				end

				draw.SimpleText(c_name, zclib.GetFont("zclib_font_mediumsmall_thin"), h + (10 * zclib.wM), 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw.SimpleText(v.short, zclib.GetFont("zclib_font_small_thin"), h + (10 * zclib.wM), h - 5, zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

				draw.SimpleText(zclib.Money.Display(MoneyAmount), zclib.GetFont("zclib_font_mediumsmall_thin"), w - (10 * zclib.wM), 5, zclib.colors[ "green01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
				draw.SimpleText(CurrencyAmount .. " " .. v.short, zclib.GetFont("zclib_font_small_thin"),w - (10 * zclib.wM), h - 5, zclib.colors["text01"], TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			end
			itm.crypto_icon = zbf.Currency.GetIcon(k)
		end
	end

	local owner = zclib.Player.GetOwner(ctrl)
	if IsValid(owner) then
		// Load the players steam avatar
		zclib.Avatar.GetMaterial(owner:SteamID64(), function(mat)
			if not IsValid(avatar) then return end
			avatar.m_Material = mat
		end)

		// Name of the BotNet Owner
		AddField(zbf.language[ "Owner" ] .. ":", owner:Nick() or "nil", zclib.colors[ "blue02" ], zclib.GetFont("zclib_font_small"), 26)

		AddField(zbf.language[ "TickPerSecond" ] .. ":", zbf.Controller.GetStatValue(ctrl, "tps"), zclib.colors[ "text01" ], zclib.GetFont("zclib_font_small"), 26)
		AddField(zbf.language[ "Attack" ] .. ":", zbf.Controller.GetStatValue(ctrl, "attack"), zclib.colors[ "red01" ], zclib.GetFont("zclib_font_small"), 26)
		AddField(zbf.language[ "Defense" ] .. ":", zbf.Controller.GetStatValue(ctrl, "defense"), zclib.colors[ "blue02" ], zclib.GetFont("zclib_font_small"), 26)
		AddField(zbf.language[ "Neuro" ] .. ":", zbf.Controller.GetStatValue(ctrl, "neuro"), zbf.colors[ "orange02" ], zclib.GetFont("zclib_font_small"), 26)
	end

	if IsValid(owner) then

		// Show connected Bots in the BotNet
		local ShowConnectedBots = zbf.vgui.Button(window, zbf.language[ "Bots" ], zclib.GetFont("zclib_font_medium"), zclib.colors[ "blue02" ], function(s)

			// Rebuild info panel with all connected bots
			RebuildInfoPanel(function(pnl) BuildBotList(pnl) end)
		end)
		ShowConnectedBots:SetSize(200 * zclib.wM, 40 * zclib.hM)
		ShowConnectedBots:Dock(TOP)
		ShowConnectedBots:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		ShowConnectedBots:DoClick()

		// Show Amount of currency inside the BotNet
		local ShowCurrency = zbf.vgui.Button(window, zbf.language["Local Wallet"], zclib.GetFont("zclib_font_medium"), zclib.colors[ "blue02" ], function(s)

			// Rebuild info panel with currencies
			RebuildInfoPanel(function(pnl) BuildCurrencyPortfolio(pnl) end)
		end)
		ShowCurrency:SetSize(200 * zclib.wM, 40 * zclib.hM)
		ShowCurrency:Dock(TOP)
		ShowCurrency:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

		local LiveFeed = zbf.vgui.Button(window, zbf.language[ "LiveFeed" ], zclib.GetFont("zclib_font_medium"), zclib.colors[ "blue02" ], function()
			if IsValid(FieldInfo) then FieldInfo:Remove() end
			local str = string.Replace(zbf.language["OwnerS"],"$PLAYENAME",owner:Nick())
			zbf.Controller.LiveFeed(str .. " " .. zbf.language[ "LiveFeed" ], ctrl, BotNetIP, OnSelect)
		end)
		LiveFeed:SetSize(200 * zclib.wM, 40 * zclib.hM)
		LiveFeed:Dock(TOP)
		LiveFeed:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	end

	return InfoPanel
end
local function DisplayFieldInfo(BotNetIP, OnSelect)
	if IsValid(FieldInfo) then FieldInfo:Remove() end

	local main = vgui.Create("DButton")
	main:MakePopup()
	main:SetText("")
	main:SetSize(zclib_main_panel:GetWide(), zclib_main_panel:GetTall())
	main:Center()
	main.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a200" ])

		if input.IsKeyDown(KEY_ESCAPE) and IsValid(s) then
			s:Remove()
		end
	end
	main.DoClick = function()
		main:Remove()
	end

	FieldInfo = main

	local parentwindow = vgui.Create("DPanel", main)
	parentwindow:SetSize(650 * zclib.wM, 600 * zclib.hM)
	parentwindow:Center()
	parentwindow.Paint = function(s, w, h)
		//draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui02" ])
	end

	local window = vgui.Create("DPanel", parentwindow)
	window:SetSize(280 * zclib.wM, 600 * zclib.hM)
	window:DockPadding(10 * zclib.wM, 0 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
	window.Paint = function(s, w, h) draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui02" ]) end

	// Display all the info about this field
	local InfoPanel = DisplayDetail(BotNetIP,window,parentwindow,OnSelect)

	// If we got a OnSelect function then lets add a select button for the ip field
	if OnSelect then
		local SelectButton = zbf.vgui.Button(window, zbf.language[ "Select" ], zclib.GetFont("zclib_font_medium"), zclib.colors[ "green01" ], function()
			pcall(OnSelect, BotNetIP)
			main:Remove()
		end)
		SelectButton:SetSize(200 * zclib.wM, 40 * zclib.hM)
		SelectButton:Dock(TOP)
		SelectButton:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	end

	//window:InvalidateParent(true)
	window:InvalidateChildren(true)
	window:SizeToChildren(true, true)

	if IsValid(InfoPanel) then InfoPanel:SetTall(window:GetTall()) end

	//parentwindow:InvalidateParent(true)
	parentwindow:InvalidateChildren(true)
	parentwindow:SizeToChildren(true, true)

	parentwindow:Center()

	local xPos,yPos = zclib_main_panel:GetPos()
	main:SetPos(xPos,yPos)
end

/*
	Creates a map with every possible IP and shows which are already scanned
*/
function zbf.Controller.IPMap(Title, OnSelect, AutoSelectIP, ShowRefreshButton)
	zclib.vgui.Page("       " .. Title, function(main, top)
		main:SetSize(1000 * zclib.wM, 1000 * zclib.hM)

		// This will be used by zbf_Controller_IPCache_Update to rebuild the minimap if something changed
		main.RebuildMap = function()
			zbf.Controller.IPMap(Title, OnSelect, AutoSelectIP, ShowRefreshButton)
		end

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
			zbf.Controller.Main()
		end, false)
		back_btn:Dock(LEFT)
		back_btn:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		back_btn.IconColor = zclib.colors[ "orange01" ]

		zbf.vgui.AddTopSepeartor(top)

		// This will store are the existing fields
		local Fields = {}

		if ShowRefreshButton then
			local RefreshIP = zbf.vgui.Button(top, zbf.language[ "Refresh IP" ], zclib.GetFont("zclib_font_medium"), zclib.colors[ "blue02" ], function(s)

				// Check IP Change cooldown
				if Controller.NextIPRefresh and Controller.NextIPRefresh > CurTime() then
					local cooldown = math.Round(Controller.NextIPRefresh - CurTime())
					zclib.Notify(LocalPlayer(), zbf.language[ "Next IP Refresh" ] .. " " .. cooldown .. zbf.language[ "short_second" ], 1)
					return
				end

				// Create some effect
				local FieldData = Fields[Controller.BotNetIP]
				if FieldData and FieldData.m_X and FieldData.m_Y and FieldData.m_W and FieldData.m_H then
					local pX, pY = ContentPanel:GetPos()
					local cX, cY = ContentPanel:GetParent():LocalToScreen(pX + FieldData.m_X + (FieldData.m_W / 2), pY + FieldData.m_Y + (FieldData.m_H / 2))
					zclib.vgui.PlayEffect("Magic", cX, cY)
				end

				Controller.NextIPRefresh = CurTime() + zbf.config.Controller.ip_refresh
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

				s:Lock(CurTime() + zbf.config.Controller.ip_refresh,zbf.config.Controller.ip_refresh)

				// Request new IP
				net.Start("zbf_Controller_RefreshIP")
				net.WriteEntity(Controller)
				net.SendToServer()
			end)

			if Controller.NextIPRefresh and Controller.NextIPRefresh > CurTime() then
				RefreshIP:Lock(Controller.NextIPRefresh,zbf.config.Controller.ip_refresh)
			else
				RefreshIP:Unlock()
			end

			//RefreshIP:SetSize(200 * zclib.wM, 50 * zclib.hM)
			RefreshIP:Dock(RIGHT)
			RefreshIP:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		end

		ContentPanel = vgui.Create("DPanel", main)
		ContentPanel:SetSize(1000 * zclib.wM, 950 * zclib.hM)
		ContentPanel:Dock(FILL)
		ContentPanel:DockMargin(50 * zclib.wM, 0 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)

		// Handels the mouse zoom
		local MouseOffsetX,MouseOffsetY = 0,0

		// In order to figure out how many rows we will have we need to use our IPMax in a cubing function
		local function cubeRoot(x) return x ^ (1 / 2) end
		local IPMax = zbf.config.Controller.ip_size
		local rowCount = math.Round(cubeRoot(IPMax))

		// Check if our controller is currently doing a BotNet attack, if so lets get the TargetIP
		local TargetID = -1
		local JobData
		if zbf.Jobs.IsBotNetJob(Controller:GetJobID()) then
			JobData = zbf.Jobs.GetData(Controller:GetJobID())
			TargetID = tonumber(Controller:GetTargetName())
		end

		ContentPanel.Paint = function(s, w, h)

			if not IsValid(Controller) then main:Remove() end

			surface.SetMaterial(zclib.Materials.Get("grid"))
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(0,0,w,h)

			local mx, my = input.GetCursorPos()
			local lx,ly = s:ScreenToLocal(mx,my)
			MouseOffsetX = lx
			MouseOffsetY = ly

			local CurrentField = Fields[ Controller.BotNetIP ]

			// Draw the connection lines for IPs you dont own
			for k, v in pairs(Fields) do
				if not IsValid(Controller) then continue end
				if IsValid(Controller) and Controller.IPCache[ v.m_IP ] and not v.m_Owned then
					local bgColor
					if v.m_Material or zbf.config.Controller.ip_ping_fadeout <= 0 then
						bgColor = zclib.colors[ "ui_highlight" ]
					else
						bgColor = zclib.util.LerpColor(v.m_Age, zclib.colors[ "ui_highlight" ], zclib.colors[ "ui00" ])
					end

					// Go from CurrentField X to NextField X
					surface.SetDrawColor(bgColor)
					surface.DrawLine(CurrentField.m_X + CurrentField.m_W / 2, CurrentField.m_Y + CurrentField.m_H / 2, v.m_X + v.m_W / 2, CurrentField.m_Y + CurrentField.m_H / 2)

					// Go from CurrentField Y to NextField Y
					surface.SetDrawColor(bgColor)
					surface.DrawLine(v.m_X + v.m_W / 2, CurrentField.m_Y + CurrentField.m_H / 2, v.m_X + v.m_W / 2, v.m_Y + v.m_H / 2)
				end
			end

			// Draw the connection lines for IP you own
			for k, v in pairs(Fields) do
				if not IsValid(Controller) then continue end
				if IsValid(Controller) and Controller.IPCache[ v.m_IP ] and v.m_Owned then
				    // Go from CurrentField X to NextField X
					surface.SetDrawColor(zclib.colors[ "blue02" ])
					surface.DrawLine(CurrentField.m_X + CurrentField.m_W / 2, CurrentField.m_Y + CurrentField.m_H / 2, v.m_X + v.m_W / 2, CurrentField.m_Y + CurrentField.m_H / 2)

				    // Go from CurrentField Y to NextField Y
					surface.SetDrawColor(zclib.colors[ "blue02" ])
					surface.DrawLine(v.m_X + v.m_W / 2, CurrentField.m_Y + CurrentField.m_H / 2, v.m_X + v.m_W / 2, v.m_Y + v.m_H / 2)
				end
			end

			// Draw a point moving alone the lines from the Controller To the Tarted IP if we currently performing at BotNet Attack
			local TargetField = Fields[ TargetID ]
			if TargetField and CurrentField then

				// Draw the lines from the Controller to the Target
				surface.SetDrawColor(zclib.colors[ "text01" ])
				surface.DrawLine(CurrentField.m_X + CurrentField.m_W / 2, CurrentField.m_Y + CurrentField.m_H / 2, TargetField.m_X + TargetField.m_W / 2, CurrentField.m_Y + CurrentField.m_H / 2)

				surface.SetDrawColor(zclib.colors[ "text01" ])
				surface.DrawLine(TargetField.m_X + TargetField.m_W / 2, CurrentField.m_Y + CurrentField.m_H / 2, TargetField.m_X + TargetField.m_W / 2, TargetField.m_Y + TargetField.m_H / 2)

				// The progress of the Attack
				local fract = 1 / JobData.ticks * Controller:GetJobProgress()


				// First get the total distance Between StartX / EndX and  StartY / EndY
				local TotalDistance = 0

				local distX = math.abs(CurrentField.m_X - TargetField.m_X)
				TotalDistance = TotalDistance + distX

				local distY = math.abs(CurrentField.m_Y - TargetField.m_Y)
				TotalDistance = TotalDistance + distY


				// This will be the faction of the whole distance thats traveled on X
				local LineX_fract_length = (1 / TotalDistance) * distX
				local LineX_fract = (1 / LineX_fract_length) * fract

				// This will be the faction of the whole distance thats traveled on Y
				local LineY_fract_length = (1 / TotalDistance) * distY
				local LineY_fract = (1 / LineY_fract_length) * (fract - LineX_fract_length)

				// Now lets Calculate the vector we are goin to move on
				local movePos

				// If our current fraction is less then LineX faction then that means we still need to travel it
				if fract < LineX_fract_length then
					movePos = LerpVector(LineX_fract,Vector(CurrentField.m_X,CurrentField.m_Y,0),Vector(TargetField.m_X,CurrentField.m_Y,0))
				else
					// Other whise start traveling on Y
					movePos = LerpVector(LineY_fract,Vector(TargetField.m_X,CurrentField.m_Y,0),Vector(TargetField.m_X,TargetField.m_Y,0))
				end

				surface.SetDrawColor(zclib.colors[ "black_a200" ])
				surface.SetMaterial(zclib.Materials.Get("radial_shadow"))
				surface.DrawTexturedRectRotated(movePos.x + 18 * zclib.wM, movePos.y + 15 * zclib.hM, 100 * zclib.wM, 100 * zclib.hM, 0)

				surface.SetDrawColor(zclib.colors[ "blue02" ])
				surface.SetMaterial(zclib.Materials.Get("robot"))
				surface.DrawTexturedRectRotated(movePos.x + 18 * zclib.wM, movePos.y + 15 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, 0)
			end

			// Draw the BotNets you got in your IPCache
			for k,v in pairs(Fields) do
				if not IsValid(Controller) then continue end

				if Controller.IPCache[ v.m_IP ] then
					local bgColor
					if v.m_Material or zbf.config.Controller.ip_ping_fadeout <= 0 then
						bgColor = zclib.colors[ "ui_highlight" ]
					else
						bgColor = zclib.util.LerpColor(v.m_Age, zclib.colors[ "ui_highlight" ], zclib.colors[ "ui00" ])
					end
					draw.RoundedBox(0, v.m_X, v.m_Y, v.m_W, v.m_H, bgColor)
				end

				if v.m_IP == Controller.BotNetIP then
					draw.RoundedBox(0, v.m_X, v.m_Y, v.m_W, v.m_H, zclib.colors[ "blue02" ])
				end

				if v.m_Material then
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(v.m_Material)
					surface.DrawTexturedRect(v.m_X + v.m_W * 0.05, v.m_Y + v.m_H * 0.05, v.m_W * 0.9, v.m_H * 0.9)
				end

				if not IsValid(FieldInfo) and MouseOffsetX > v.m_X and MouseOffsetX < (v.m_X + v.m_W) and MouseOffsetY > v.m_Y and MouseOffsetY < (v.m_Y + v.m_H) then
					draw.RoundedBox(0, v.m_X, v.m_Y, v.m_W, v.m_H, zclib.colors[ "white_a15" ])
					if input.IsMouseDown(MOUSE_LEFT) and not IsValid(FieldInfo) then
						DisplayFieldInfo(v.m_IP, OnSelect)
					end
				end
			end

			// Draw any hints this controller has
			if Controller.IPHints then
				for ip,time in pairs(Controller.IPHints) do
					local dat = Fields[ip]
					if not dat then continue end
					zclib.util.DrawOutlinedBox(dat.m_X, dat.m_Y, dat.m_W, dat.m_H, 2, zclib.colors[ "green01" ])
					draw.SimpleText("?", zclib.GetFont("zclib_font_medium"), dat.m_X + (dat.m_W / 2), dat.m_Y + (dat.m_H / 2), zclib.colors[ "green01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end

		local fW
		local fH
		local fX, fY = 0 , 0
		local count = 1
		local function AddIPField(ip)

			fW = ContentPanel:GetWide() / rowCount
			fH = (ContentPanel:GetTall() - 30 * zclib.hM) / rowCount

			Fields[ip] = {}
			Fields[ip].m_IP = ip

			Fields[ip].m_X = fX
			Fields[ip].m_Y = fY
			Fields[ip].m_W = fW
			Fields[ip].m_H = fH
			Fields[ip].m_Age = 0

			fX = fX + fW
			if count >= rowCount then
				count = 0
				fX = 0
				fY = fY + fH
			end
			count = count + 1

			// Calculate a value using the Last Update time, so the highlight color starts to fade if its older then 10 minutes
			local CacheData = Controller.IPCache[ ip ]
			if CacheData == nil then return end

			// 10 minutes after the last update we want for the field too look like its un-scanned again
			if CacheData and CacheData.LastUpdate then
				local bgFract = 1
				local diff = CurTime() - CacheData.LastUpdate
				bgFract = (1 / zbf.config.Controller.ip_ping_fadeout) * diff
				bgFract = math.Clamp(bgFract, 0, 1)
				Fields[ip].m_Age = bgFract
			end

			if CacheData and IsValid(CacheData.ControllerEntity) then
				local owner = zclib.Player.GetOwner(CacheData.ControllerEntity)
				if IsValid(owner) then
					Fields[ip].m_Owned = LocalPlayer() == owner
					zclib.Avatar.GetMaterial(owner:SteamID64(), function(mat)
						Fields[ip].m_Material = mat
					end)
				end
			end
		end

		timer.Simple(0.1, function()
			if IsValid(ContentPanel) then
				for i = 1, IPMax do
					AddIPField(i)
				end
			end
		end)

		local InfoPanel = vgui.Create("DPanel", main)
		InfoPanel:SetSize(900 * zclib.wM, 50 * zclib.hM)
		InfoPanel:Dock(BOTTOM)
		InfoPanel:DockMargin(50 * zclib.wM, 0 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
		InfoPanel.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 5, w, h - 5, zclib.colors[ "black_a200" ])

			// Dont show the IP Info if we currenty inspecting the IPField active
			if IsValid(FieldInfo) then return end
			local IP = "?"
			for k,v in pairs(Fields) do
				if MouseOffsetX > v.m_X and MouseOffsetX < (v.m_X + v.m_W) and MouseOffsetY > v.m_Y and MouseOffsetY < (v.m_Y + v.m_H) then
					IP = v.m_IP
					break
				end
			end
			draw.SimpleText(zbf.language[ "IP" ] .. ": " .. IP, zclib.GetFont("zclib_font_medium"),w / 2,h / 1.8, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		InfoPanel.OnRemove = function() if IsValid(FieldInfo) then FieldInfo:Remove() end end

		if AutoSelectIP then
			timer.Simple(0.1, function()
				DisplayFieldInfo(AutoSelectIP)
			end)
		end
	end)
end

/*
	Display a bunch of diffrent Views from the specified Controller
*/
local drag_spd = 1
local scroll_spd = 0.2
local viewmult = 0.5
function zbf.Controller.LiveFeed(Title, Target, BotNetIP, OnSelect)
	zclib.vgui.Page(Title, function(main, top)
		main:SetSize(1200 * zclib.wM, 800 * zclib.hM)

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		zbf.vgui.AddTopSepeartor(top)

		local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
			zbf.Controller.IPMap(zbf.language["BotNet Map"], OnSelect, nil, true)

			DisplayFieldInfo(BotNetIP, OnSelect)
		end, false)
		back_btn:Dock(RIGHT)
		back_btn:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		back_btn.IconColor = zclib.colors[ "red01" ]

		local ViewScreen = vgui.Create("DPanel", main)
		ViewScreen:Dock(FILL)
		ViewScreen:DockMargin(50 * zclib.wM, 5 * zclib.hM, 50 * zclib.wM, 10 * zclib.hM)
		ViewScreen:SetKeyboardInputEnabled(false)
		ViewScreen.MousePosX = 0
		ViewScreen.MousePosY = 0
		ViewScreen.OffsetVector = Vector(0, 0, 0)
		ViewScreen.LockedOnPlayer = true
		ViewScreen.Think = function(self)

			if not IsValid(Controller) then main:Remove() end

			if not self:IsHovered() then return end
			local mx, my = input.GetCursorPos()
			local tb = self:GetTable()

			if input.IsMouseDown(MOUSE_LEFT) then
				if not tb.IsDraggingView then
					tb.IsDraggingView = true
				else
					local nx, ny = tb.MousePosX - mx, tb.MousePosY - my
					tb.OffsetVector.x = tb.OffsetVector.x - ny * drag_spd
					tb.OffsetVector.y = tb.OffsetVector.y - nx * drag_spd
				end
			else
				tb.IsDraggingView = false
			end

			tb.MousePosX, tb.MousePosY = mx, my
		end

		// Scrolling in and out
		ViewScreen.OnMouseWheeled = function(self, scroll) viewmult = math.Clamp(viewmult - scroll * scroll_spd, 0.1, 1) end

		/*
			Performs some scissoring action to make sure we dont draw outside the window
		*/
		local function DrawOnArea(OnDraw)
			local w, h = ViewScreen:GetWide(), ViewScreen:GetTall()
			local x, y = ViewScreen:GetPos()
			x, y = main:LocalToScreen(x, y)
			render.SetScissorRect(x, y, x + w, y + h, true)
			pcall(OnDraw, w, h, x, y)
			render.SetScissorRect(0, 0, 0, 0, false)
		end

		// Painting the view
		ViewScreen.Paint = function(self, w, h)
			if not IsValid(Target) then return end
			LocalPlayer().zbf_LiveFeed = CurTime()
			local ViewPos = Target:LocalToWorld(Vector(0, 0, 100))
			local ViewAngle = Target:LocalToWorldAngles(Angle(-self.OffsetVector.x, self.OffsetVector.y, 0))
			local x, y = self:GetPos()
			x, y = main:LocalToScreen(x, y)
			render.SetShadowsDisabled(true)
			render.RenderView({
				origin = ViewPos,
				angles = ViewAngle,
				x = x,
				y = y,
				w = w,
				h = h,
				drawviewmodel = false,
				drawhud = false,
				drawmonitors = false,
				bloomtone = false,
				fov = 20 + 100 * viewmult,
				znear = 1,
				znearviewmodel = 1,
				zfar = 30000,
				zfarviewmodel = 30000
			})
			render.SetShadowsDisabled(false)

			DrawOnArea(function()
				zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 10, zclib.colors[ "ui00" ])
				draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])

				surface.SetDrawColor(color_white)
				surface.SetMaterial(zclib.Materials.Get("feedoverlay"))
				surface.DrawTexturedRect(0, 0, w, h)

				surface.SetDrawColor(zclib.colors[ "black_a100" ])
				surface.SetMaterial(zclib.Materials.Get("scanlines"))
				surface.DrawTexturedRect(0, 0, w, h)

				local time = string.FormattedTime(CurTime())

				local hour = math.Round(time.h)
				if hour < 10 then hour = "0" .. hour end

				local m = math.Round(time.m)
				if m < 10 then m = "0" .. m end

				local s = math.Round(time.s)
				if s < 10 then s = "0" .. s end

				local ms = math.Round(time.ms)
				if ms < 10 then ms = "0" .. ms end

				draw.SimpleText(hour .. " : " .. m .. " : " .. s .. " :", zclib.GetFont("zclib_font_big"), w / 2 - 25 * zclib.wM, h * 0.05, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(ms, zclib.GetFont("zclib_font_medium"), w / 2 + 100 * zclib.wM, h * 0.055, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if math.sin(CurTime() * 4) > 0 then draw.RoundedBox(50, 75 * zclib.wM, 50 * zclib.hM, 26 * zclib.wM, 26 * zclib.hM, color_red) end
			end)
		end


		/*
			I like to think this bottom part actully does what its made for but idk, results dont seem repetitive enough in order to get to any conclusion
		*/

		// Forces any bot to rebuild his material
		local nearEnts = ents.FindInSphere(Target:GetPos(), 500)
		for k, v in pairs(nearEnts) do
			if not IsValid(v) then continue end
			if v:GetClass() ~= "zbf_bot" then continue end
			v.UpdatedPaint = nil
		end

		local skip = {
			[ "viewmodel" ] = true,
			[ "manipulate_bone" ] = true,
			[ "physgun_beam" ] = true,
			[ "gmod_hands" ] = true
		}

		zclib.Hook.Remove("PostDrawOpaqueRenderables", "zbf_livefeed")
		zclib.Hook.Add("PostDrawOpaqueRenderables", "zbf_livefeed", function()
			if not IsValid(ViewScreen) then
				zclib.Hook.Remove("PostDrawOpaqueRenderables", "zbf_livefeed")
				return
			end

			if not IsValid(Target) then
				zclib.Hook.Remove("PostDrawOpaqueRenderables", "zbf_livefeed")
				return
			end

			for k, v in pairs(ents.FindInSphere(Target:GetPos(), 500)) do
				if not IsValid(v) then continue end
				if not v.DrawModel then continue end
				if skip[ v:GetClass() ] then continue end
				v:DrawModel()
			end
		end)
	end)
	// TODO Figure out how to render the LocalPlayers WorldModel
end

/*
	Creates a selection to choose which bot we want to buy
*/
function zbf.Controller.BotSelection()
	zclib.vgui.Page("       " .. zbf.language[ "Bot Shop" ], function(main, top)
		main:SetSize(1200 * zclib.wM, 800 * zclib.hM)

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)

		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
			zbf.Controller.Main()
		end, false)
		back_btn:Dock(LEFT)
		back_btn:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		back_btn.IconColor = zclib.colors[ "orange01" ]

		zbf.vgui.AddTopSepeartor(top)

		local SelectedBot
		local BotInfo = vgui.Create("DPanel", main)
		BotInfo:SetSize(250 * zclib.wM, 500 * zclib.hM)
		BotInfo:Dock(RIGHT)
		BotInfo:DockMargin(0 * zclib.wM, 5 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
		BotInfo.Paint = function(s, w, h)
			if not IsValid(Controller) then main:Remove() end
		end
		local InfoContent

		local function SelectBot(id)
			if IsValid(InfoContent) then InfoContent:Remove() end

			SelectedBot = id

			local BotData = zbf.Bot.GetData(id)
			InfoContent = vgui.Create("DPanel", BotInfo)
			InfoContent:Dock(FILL)
			InfoContent.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, w, zclib.colors[ "black_a100" ])
				surface.SetDrawColor(zclib.colors[ "black_a100" ])
				surface.SetMaterial(zclib.Materials.Get("linear_gradient"))
				surface.DrawTexturedRectRotated(w / 2, w / 2, w, w, -90)
			end

			local imgpnl = vgui.Create("DImage", InfoContent)
			imgpnl:SetSize(250 * zclib.wM, 250 * zclib.hM)
			imgpnl:Dock(TOP)
			local img = zclib.Snapshoter.Get({
				class = "zbf_bot",
				model = BotData.mdl,
				BotID = BotData.uniqueid
			}, imgpnl)
			imgpnl:SetImage(img and img or "materials/zerochain/zerolib/ui/icon_loading.png")

			local stats_pnl = vgui.Create("DPanel", InfoContent)
			stats_pnl:SetSize(250 * zclib.wM, 500 * zclib.hM)
			stats_pnl:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			stats_pnl:Dock(TOP)
			stats_pnl.Paint = function(s, w, h) end

			local function AddField(name, val, color)
				local pnl = vgui.Create("DPanel", stats_pnl)
				pnl:SetSize(250 * zclib.wM, 30 * zclib.hM)
				pnl:Dock(TOP)
				pnl:DockMargin(0, 0, 0, 4 * zclib.hM)
				pnl.Paint = function(s, w, h)
					draw.RoundedBox(0, 0, 0, w, h, zclib.colors[ "black_a50" ])
					zclib.util.DrawOutlinedBox(0, 0, w, h, 2, zclib.colors[ "black_a50" ])
					draw.SimpleText(name, zclib.GetFont("zclib_font_small"), 10 * zclib.wM, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(val, zclib.GetFont("zclib_font_small"), w - 10 * zclib.wM, h / 2, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				end
			end
			AddField(zbf.language[ "ID" ] .. ":", BotData.uniqueid or 0, zclib.colors[ "text01" ])
			AddField(zbf.language[ "Name" ] .. ":", BotData.name, zclib.colors[ "text01" ])
			AddField(zbf.language[ "Price" ] .. ":", zclib.Money.Display(BotData.price), zclib.colors[ "green01" ])
			AddField(zbf.language[ "Health" ] .. ":", BotData.health, zclib.colors[ "text01" ])
			AddField(zbf.language[ "TickPerSecond" ] .. ":", BotData.tps, zclib.colors[ "text01" ])
			AddField(zbf.language[ "Attack" ] .. ":", BotData.attack or 0, zclib.colors[ "red01" ])
			AddField(zbf.language[ "Defense" ] .. ":", BotData.defense or 0, zclib.colors[ "blue02" ])
			AddField(zbf.language[ "Neuro" ] .. ":", BotData.neuro or 0, zclib.colors[ "orange02" ])
			stats_pnl:InvalidateChildren(true)
			stats_pnl:SizeToChildren(false, true)

			local btn = zbf.vgui.Button(InfoContent, zbf.language[ "Purchase" ], zclib.GetFont("zclib_font_big"), zclib.colors[ "green01" ], function()
				zbf.Controller.OnBotSelect(SelectedBot)
				main:Close()
			end)

			btn:SetTall(50 * zclib.hM)
			btn:Dock(TOP)
			btn:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		end

		local Machines_content = vgui.Create("DPanel", main)
		Machines_content:SetSize(1000 * zclib.wM, 1000 * zclib.hM)
		Machines_content:Dock(FILL)
		Machines_content:DockMargin(50 * zclib.wM, 5 * zclib.hM, 10 * zclib.wM, 0 * zclib.hM)

		Machines_content.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])
			draw.RoundedBox(5, w - 15 * zclib.wM, 0, 15 * zclib.wM, h, zclib.colors[ "black_a50" ])
		end

		local list, scroll = zclib.vgui.List(Machines_content)
		scroll:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		list:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		list:SetSpaceY(10 * zclib.hM)
		list:SetSpaceX(10 * zclib.wM)

		for k, v in pairs(zbf.config.Bots) do

			// Dont show bots restricted by job
			if not zbf.Bot.CanBuy_JobRestriction(LocalPlayer(),k) then continue end

			zbf.vgui.BotPanel(list, 154, k, v, function() return SelectedBot == k end, function(id)
				SelectBot(id)
			end, not zbf.Bot.CanBuy(LocalPlayer(), k), true)
			if SelectedBot == nil then SelectedBot = k end
		end

		// Dont select Bot1, select the first valid bot
		SelectBot(SelectedBot)
	end)
end

/*
	Starts the pointer system and allows the player to specifiey the Target for the Bot Purchase function
*/
function zbf.Controller.OnBotSelect(BotID)
	zclib.PointerSystem.Start(Controller, function()
		// OnInit
		zclib.PointerSystem.Data.MainColor = zclib.colors[ "green01" ]
		zclib.PointerSystem.Data.ActionName = zbf.language[ "Purchase" ]
		zclib.PointerSystem.Data.CancelName = zbf.language[ "Cancel" ]
	end, function()
		// OnLeftClick
		// Send net message to server and let him figure out if the target we are looking at can be upgraded / free to spawn a bot
		net.Start("zbf_Controller_Purchase")
		net.WriteEntity(Controller)
		net.WriteUInt(BotID, 8)
		net.SendToServer()
	end, function()
		//zclib.PointerSystem.Stop()
		// Catch the Target
		if IsValid(zclib.PointerSystem.Data.HitEntity) and (zclib.PointerSystem.Data.HitEntity:GetClass() == "zbf_bot" or zclib.PointerSystem.Data.HitEntity:GetClass() == "zbf_rack") then
			zclib.PointerSystem.Data.Target = zclib.PointerSystem.Data.HitEntity
		else
			zclib.PointerSystem.Data.Target = nil
		end

		if zclib.util.InDistance(zclib.PointerSystem.Data.Pos, Controller:GetPos(), 500) then
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
	end, nil, function()
		// ReOpen BotSelection
		zbf.Controller.BotSelection()
	end)
end

/*
	Starts the pointer system and allows the player to specifiey which bot should be sold
*/
function zbf.Controller.SellBot()
	zclib.PointerSystem.Start(Controller, function()
		// OnInit
		zclib.PointerSystem.Data.MainColor = zbf.colors[ "orange02" ]
		zclib.PointerSystem.Data.ActionName = zbf.language[ "Sell" ]
		zclib.PointerSystem.Data.CancelName = zbf.language[ "Cancel" ]
	end, function()
		if zclib.PointerSystem.Data == nil then return end
		if not IsValid(zclib.PointerSystem.Data.HitEntity) then return end
		// OnLeftClick
		// Send net message to server and let him figure out if the target we are looking at can be upgraded / free to spawn a bot
		net.Start("zbf_Controller_Sell")
		net.WriteEntity(zclib.PointerSystem.Data.HitEntity)
		net.SendToServer()
	end, function()
		//zclib.PointerSystem.Stop()
		// Catch the Target
		if IsValid(zclib.PointerSystem.Data.HitEntity) and zclib.PointerSystem.Data.HitEntity:GetClass() == "zbf_bot" then
			zclib.PointerSystem.Data.Target = zclib.PointerSystem.Data.HitEntity
		else
			zclib.PointerSystem.Data.Target = nil
		end

		if zclib.util.InDistance(zclib.PointerSystem.Data.Pos, LocalPlayer():GetPos(), 500) and IsValid(zclib.PointerSystem.Data.HitEntity) and zclib.PointerSystem.Data.HitEntity:GetClass() == "zbf_bot" then
			zclib.PointerSystem.Data.MainColor = zbf.colors[ "orange02" ]
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
	end, nil, function()
		// ReOpen BotSelection
		zbf.Controller.Main()
	end)
end

/*
	Starts the pointer system and allows the player to specifiey which robot should be repaired
*/
function zbf.Controller.RepairBot()

	zclib.PointerSystem.Start(Controller, function()
		// OnInit
		zclib.PointerSystem.Data.MainColor = zclib.colors[ "green01" ]
		zclib.PointerSystem.Data.ActionName = zbf.language[ "Repair" ] .. " -" .. zclib.Money.Display(zbf.config.WearSystem.repair_cost)
		zclib.PointerSystem.Data.CancelName = zbf.language[ "Cancel" ]
	end, function()
		// OnLeftClick
		if not IsValid(zclib.PointerSystem.Data.Target) then return end
		// Send net message to server and let him figure out if the target we are looking at can be upgraded / free to spawn a bot
		net.Start("zbf_Controller_Repair")
		net.WriteEntity(zclib.PointerSystem.Data.Target)
		net.SendToServer()
	end, function()

		local RepairCost

		// Catch the Target
		if IsValid(zclib.PointerSystem.Data.HitEntity) and zclib.PointerSystem.Data.HitEntity:GetClass() == "zbf_bot" then
			zclib.PointerSystem.Data.Target = zclib.PointerSystem.Data.HitEntity

			RepairCost = zbf.config.WearSystem.repair_cost * zbf.Bot.GetRepairCost(zclib.PointerSystem.Data.HitEntity:GetBotID())
		else
			RepairCost = zbf.config.WearSystem.repair_cost
			zclib.PointerSystem.Data.Target = nil
		end

		zclib.PointerSystem.Data.ActionName = zbf.language[ "Repair" ] .. " -" .. zclib.Money.Display(RepairCost)

		if zclib.util.InDistance(zclib.PointerSystem.Data.Pos, Controller:GetPos(), 500) then
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
	end, nil, function()
		// ReOpen BotSelection
		zbf.Controller.Main()
	end)
end


/*
	Here we display all the diffrent currencys which are currently inside the controller
*/
function zbf.Controller.CurrencyPortfolio()
	zclib.vgui.Page("       " .. zbf.language["Local Wallet"], function(main, top)
		main:SetSize(1200 * zclib.wM, 800 * zclib.hM)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		main.WalletSize = zclib.Money.Display(zbf.Controller.GetWalletSize(Controller, zclib.Player.GetOwner(Controller)))
		main.WalletValue = zclib.Money.Display(zbf.Wallet.GetMoneyValue(Controller))

		local oldPaint = main.Paint
		main.Paint = function(s,w,h)

			if not IsValid(Controller) then main:Remove() end

			oldPaint(s,w,h)
			draw.SimpleText(main.WalletValue .. " / " .. main.WalletSize, zclib.GetFont("zclib_font_big"), w - (85 * zclib.wM), 50 * zclib.hM, zclib.colors[ "yellow01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end


		main.CurrencyPortfolio = true

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
			zbf.Controller.Main()
		end, false)
		back_btn:Dock(LEFT)
		back_btn:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		back_btn.IconColor = zclib.colors[ "orange01" ]

		zbf.vgui.AddTopSepeartor(top)

		zbf.Controller.CurrencyPortfolio_Rebuild(main)
	end)
end

function zbf.Controller.CurrencyPortfolio_Rebuild(window)
	if Controller.zbf_Wallet == nil then Controller.zbf_Wallet = {} end

	window.WalletSize = zclib.Money.Display(zbf.Controller.GetWalletSize(Controller, zclib.Player.GetOwner(Controller)))
	window.WalletValue = zclib.Money.Display(zbf.Wallet.GetMoneyValue(Controller))


	zbf.vgui.CurrencyList(window, Controller.zbf_Wallet, true, function(itm,id,IsEmpty)
		if IsEmpty then return end

		if zbf.Currency.IsMoney(id) then
			zbf.vgui.TextButton(itm, zbf.language[ "Payout" ], zclib.GetFont("zclib_font_small"), zclib.colors[ "green01" ], function()
				zbf.vgui.CurrencyAmountSelector(id, Controller.zbf_Wallet[1], function(val)
					net.Start("zbf_Wallet_PayoutMoney")
					net.WriteEntity(Controller)
					net.WriteDouble(val)
					net.SendToServer()
				end)
			end)
		end


		zbf.vgui.TextButton(itm, zbf.language[ "Transfer To Vault >" ], zclib.GetFont("zclib_font_small"), zclib.colors[ "blue02" ], function()
			net.Start("zbf_Wallet_SendToVault")
			net.WriteEntity(Controller)
			net.WriteUInt(id,8)
			net.SendToServer()
		end)
	end)
end

/*
	If we got the currency portfolio open then rebuild it
*/
zclib.Hook.Add("zbf_Wallet_OnCurrencyUpdated", "zbf_Wallet_OnCurrencyUpdated_controller", function(ent, wallet)
	if IsValid(Controller) and Controller == ent and IsValid(zclib_main_panel) and zclib_main_panel.CurrencyPortfolio then
		zbf.Controller.CurrencyPortfolio_Rebuild(zclib_main_panel)
	end
end)


/*
	Called after the job got successfully started
*/
net.Receive("zbf_Controller_StartJob", function(len)
	zclib.Debug_Net("zbf_Controller_StartJob", len)
	if IsValid(zclib_main_panel) then zbf.Controller.Main() end
end)

/*
	Called after the job got finished, this is only called for jobs that are not of type Repeat
*/
local function LootCheck(ent)
	if ent.zbf_LastWallet == nil then ent.zbf_LastWallet = {} end
	local Found_id,Found_amount
	for k, v in pairs(ent.zbf_Wallet) do
		local val = math.Clamp(v - (ent.zbf_LastWallet[ k ] or 0), 0, 99999999999999999)

		if val > 0 then
			Found_id = k
			Found_amount = val
			break
		end
	end

	if Found_id and Found_amount and IsValid(FieldInfo) then

		local window = FieldInfo:GetChild(0)
		if IsValid(window) then

			if Found_amount > 100 then Found_amount = math.Round(Found_amount) end
			local info = "+" .. zbf.Currency.Format(Found_id,Found_amount)
			local CryptoIcon = zbf.Currency.GetIcon(Found_id)
			local CryptoShort = zbf.Currency.GetShort(Found_id)

			local NextEffect = CurTime() + 1
			local EffectsList = {"firework_red","firework_green","firework_blue","firework_yellow"}

			local InfoPanel = vgui.Create("DPanel", FieldInfo)

			local xPos,yPos = window:GetPos()

			InfoPanel:SetPos(xPos, yPos + window:GetTall() + 10 * zclib.hM)

			InfoPanel:SetSize(window:GetWide(), 100 * zclib.hM)
			InfoPanel:DockPadding(10 * zclib.wM, 0 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
			InfoPanel.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui02" ])

				surface.SetDrawColor(color_white)
				surface.SetMaterial(CryptoIcon)
				surface.DrawTexturedRectRotated(h / 2, h / 2, h * 0.8, h * 0.8,0)

				draw.SimpleText(zbf.language[ "Loot" ], zclib.GetFont("zclib_font_medium"),h * 1.8,h * 0.1, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)


				draw.SimpleText(info, zclib.GetFont("zclib_font_medium"),h * 1.8,h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(CryptoShort, zclib.GetFont("zclib_font_medium"),h * 1.8,h * 0.9, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

				if CurTime() > NextEffect then
					zclib.vgui.PlayEffectAtPanel(EffectsList[ math.random(#EffectsList) ], s, math.Rand(-200, 200), math.Rand(-25, 25),true)
					NextEffect = CurTime() + math.Rand(0.15,2)
				end
			end
		end
	end
end
net.Receive("zbf_Controller_FinishJob", function(len)
	zclib.Debug_Net("zbf_Controller_FinishJob", len)
	local ent = net.ReadEntity()

	if IsValid(Controller) and Controller == ent and IsValid(zclib_main_panel) then

		local JobID = Controller:GetJobID()
		local JobData = zbf.config.Jobs[ JobID ]
		if JobData then
			if JobData.type == ZBF_JOBTYPE_BOTNET then

				zbf.Controller.IPMap(zbf.language["BotNet Map"], nil, Controller.TargetIP)

				// If the job was a PING attack then diplsay the change in wallet currency
				if JobID == ZBF_JOB_BOTNET_PING then
					timer.Simple(0.3,function() if IsValid(ent) then LootCheck(ent) end end)
				end
			else
				timer.Simple(0.1, function() if IsValid(Controller) then zbf.Controller.Main() end end)
			end
		else
			zbf.Controller.Main()
		end
	end
end)
