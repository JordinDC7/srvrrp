/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.vgui = zbf.vgui or {}

/*
	Creates a progress bar
*/
function zbf.vgui.ProgressBar(w, h, x, y, fract, color01, color02)
	local barW = w
	barW = math.Clamp(barW * fract, 0, barW)
	draw.RoundedBox(0, x + 4, y + 4, math.Clamp(barW - 8, 0, w), h - 8, color01)
	zclib.util.DrawOutlinedBox(x, y, w, h, 2, color02)
end

/*
	Creates a simple text button
*/
function zbf.vgui.Button(parent, text, font, color, OnClick)
	local btn = vgui.Create("DButton", parent)
	btn:SetTall(30 * zclib.hM)
	btn:Dock(TOP)
	btn:DockMargin(10 * zclib.wM, 10 * zclib.hM, 10 * zclib.wM, 0 * zclib.hM)
	btn.MainColor = color
	btn.HighlightColor = Color(color.r * 1.5, color.g * 1.5, color.b * 1.5)
	btn.IsLocked = false

	function btn:Lock(UnlockTime,Duration)
		btn.MainColor = zclib.colors[ "ui02_grey" ]
		btn:SetTextColor(zclib.colors[ "ui02_grey" ])
		btn.IsLocked = true
		btn.UnlockTime = UnlockTime
		btn.Duration = Duration
	end

	function btn:Unlock()
		btn.MainColor = color
		btn.IsLocked = false
		btn:SetTextColor(color)
		btn.UnlockTime = nil
		btn.Duration = nil
	end

	function btn:SetSelected(state)
		btn.m_IsSelected = state
		if btn.m_IsSelected then
			btn:SetTextColor(btn.HighlightColor)
		else
			btn:SetTextColor(btn.MainColor)
		end
	end

	btn:SetText(text)
	btn:SetFont(font)
	btn:SetTextColor(btn.IsLocked and zclib.colors[ "ui02_grey" ] or color)
	btn:SizeToContentsX(30 * zclib.wM)

	btn.Paint = function(s, w, h)
		zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2,s.m_IsSelected and s.HighlightColor or s.MainColor)

		if s.UnlockTime and s.Duration then
			if CurTime() > s.UnlockTime then s:Unlock() end

			if s.UnlockTime and s.Duration then
				local diff = math.Clamp(s.UnlockTime - CurTime(), 0, s.Duration)
				draw.RoundedBox(0, 0, 0, w / s.Duration * diff, h, zclib.colors[ "black_a50" ])
			end
		end

		if not s.UnlockTime and s:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, zclib.colors[ "white_a15" ])
		end
	end

	btn.DoClick = function(s)
		zclib.vgui.PlaySound("UI/buttonclick.wav")
		pcall(OnClick, s)
	end

	return btn
end

function zbf.vgui.TextButton(parent, text, font, color, OnClick)
	local btn = vgui.Create("DButton", parent)
	btn:SetTall(30 * zclib.hM)
	btn:Dock(RIGHT)
	btn:DockMargin(10 * zclib.wM, 10 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)

	btn:SetText(text)
	btn:SetFont(font)
	btn:SetTextColor(btn.IsLocked and zclib.colors[ "ui02_grey" ] or color)
	btn:SizeToContentsX(30 * zclib.wM)
	btn:SetText("")

	btn.Paint = function(s, w, h)
		zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2,s:IsHovered() and color or zclib.colors["black_a100"])
		draw.SimpleText(text, font, w / 2,h / 2, s:IsHovered() and color or zclib.colors["black_a100"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	btn.DoClick = function(s)
		zclib.vgui.PlaySound("UI/buttonclick.wav")
		pcall(OnClick, s)
	end

	return btn
end

/*
	Displays a Bot and its state according to its connected controllers
*/
function zbf.vgui.BotPanel(list, PnlSize, BotID, BotData, IsSelected, OnClick, IsLocked, SimpleMode)
	local pnlHeight = SimpleMode and PnlSize or PnlSize + 50
	local itm = vgui.Create("DPanel")
	itm:SetSize(PnlSize * zclib.wM, pnlHeight * zclib.hM)

	itm.Paint = function(s, w, h)
		//draw.RoundedBox(5, 0, 0, w, h, IsSelected() and zclib.colors[ "ui_highlight" ] or zclib.colors[ "ui00" ])
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui00" ])
		if IsSelected() then
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "white_a5" ])
		end

		surface.SetDrawColor(zclib.colors[ "black_a100" ])
		surface.SetMaterial(zclib.Materials.Get("linear_gradient"))
		surface.DrawTexturedRectRotated(w / 2, h / 2 + 50 * zclib.hM, w, h, -90)
	end

	list:Add(itm)
	local imgpnl = vgui.Create("DImage", itm)
	imgpnl:SetSize(PnlSize * zclib.wM, PnlSize * zclib.hM)

	local img = zclib.Snapshoter.Get({
		class = "zbf_bot",
		model = BotData.mdl,
		BotID = BotData.uniqueid
	}, imgpnl)

	imgpnl:SetImage(img and img or "materials/zerochain/zerolib/ui/icon_loading.png")
	imgpnl:Dock(TOP)

	if not SimpleMode then
		local tps = vgui.Create("DPanel", itm)
		tps:SetSize(100 * zclib.wM, 30 * zclib.hM)

		tps.Paint = function(s, w, h)
			draw.RoundedBox(0, 20 * zclib.wM, 0, w - 40 * zclib.wM, 3 * zclib.hM, zclib.colors[ "black_a200" ])
			draw.SimpleText(BotData.tps .. " / s", zclib.GetFont("zclib_font_small"), w / 2, h / 2 + 1 * zclib.hM, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		tps:Dock(BOTTOM)
		local stats = vgui.Create("DPanel", itm)
		stats:SetSize(100 * zclib.wM, 50 * zclib.hM)
		stats.Paint = function(s, w, h) end //draw.RoundedBox(5, 0, 0, w,h, zclib.colors["black_a200"])
		stats:Dock(BOTTOM)

		local function DrawField(dock, icon, val, color)
			local field = vgui.Create("DPanel", stats)
			field:SetSize(50 * zclib.wM, 50 * zclib.hM)

			field.Paint = function(s, w, h)
				draw.SimpleText(val, zclib.GetFont("zclib_font_small"), w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				surface.SetDrawColor(zclib.colors[ "white_a5" ])
				surface.SetMaterial(icon)
				surface.DrawTexturedRectRotated(w / 2, h / 2, h / 1.2, h / 1.2, 0)
			end

			field:Dock(dock)
		end

		DrawField(LEFT, zclib.Materials.Get("attack"), BotData.attack or 0, zclib.colors[ "red01" ])
		DrawField(FILL, zclib.Materials.Get("defense"), BotData.defense or 0, zclib.colors[ "blue02" ])
		DrawField(RIGHT, zclib.Materials.Get("neuro"), BotData.neuro or 0, zbf.colors[ "orange02" ])
	end

	if not IsLocked then
		local name_font = zclib.util.FontSwitch(BotData.name, itm:GetWide() - 10 * zclib.wM, zclib.GetFont("zclib_font_mediumsmall"), zclib.GetFont("zclib_font_small"))
		name_font = zclib.util.FontSwitch(BotData.name, itm:GetWide() - 10 * zclib.wM, name_font, zclib.GetFont("zclib_font_tiny"))
		local lbl = vgui.Create("DLabel", imgpnl)
		lbl:SetSize(500, 30 * zclib.hM)
		lbl:Dock(TOP)
		lbl:DockMargin(5, 3, 5, 2)
		lbl:SetFont(name_font)
		lbl:SetTextColor(zclib.colors[ "text01" ])
		lbl:SetText(BotData.name)
		lbl:SetContentAlignment(7)
		lbl:SetWrap(true)
		lbl:SetAutoStretchVertical(true)
	end

	local btnpnl = vgui.Create("DButton", itm)
	btnpnl:SetTall(itm:GetTall())
	btnpnl:SetWide(itm:GetWide())
	btnpnl:SetText("")

	btnpnl.Paint = function(s, w, h)
		if not IsLocked then
			if SimpleMode then
				draw.SimpleText(zclib.Money.Display(BotData.price), zclib.GetFont("zclib_font_small"), w - 5 * zclib.wM, h - 2 * zclib.hM, zclib.colors[ "green01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			else
				draw.SimpleText(zclib.Money.Display(BotData.price), zclib.GetFont("zclib_font_small"), 5 * zclib.wM, 27 * zclib.hM, zclib.colors[ "green01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
		end

		if not IsLocked and s:IsHovered() then
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "white_a5" ])
		end

		if IsLocked then
			zclib.util.DrawBlur(s, 1, 5)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a200" ])
			local size = w * 0.7
			surface.SetDrawColor(zclib.colors[ "white_a50" ])
			surface.SetMaterial(zclib.Materials.Get("icon_locked"))
			surface.DrawTexturedRectRotated(w / 2, h / 2, size, size, 0)
		end
	end

	btnpnl.DoClick = function(s)
		if IsLocked then return end
		zclib.vgui.PlaySound("UI/buttonclick.wav")
		pcall(OnClick, BotID)
	end

	local restriction

	if BotData.ranks and table.Count(BotData.ranks) > 0 then
		restriction = zbf.language[ "Ranks" ] .. ": " .. zclib.table.ToString(BotData.ranks)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	if BotData.jobs and table.Count(BotData.jobs) > 0 then
		if restriction then
			restriction = restriction .. "\n"
		end

		restriction = (restriction or "") .. zbf.language[ "Jobs" ] .. ": " .. zclib.table.ToString(BotData.jobs)
	end

	if restriction then
		btnpnl:SetTooltip(restriction)
	end
end

/*
	Adds a simple seperator panel
*/
function zbf.vgui.AddTopSepeartor(top)
	local seperator = zclib.vgui.AddSeperator(top)
	seperator:SetSize(5 * zclib.wM, 50 * zclib.hM)
	seperator:Dock(RIGHT)
	seperator:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
end

/*
	Creates a nummeric slider
*/
function zbf.vgui.NumSlider(parent, default, title, OnChange, Min, Max, Decimal)
	local DermaNumSlider = vgui.Create("DNumSlider", parent)
	DermaNumSlider:SetPos(50, 50)
	DermaNumSlider:SetSize(300, 30 * zclib.hM)
	DermaNumSlider:SetMin(Min)
	DermaNumSlider:SetMax(Max)
	DermaNumSlider:SetDecimals(Decimal)
	DermaNumSlider:SetValue(default)
	DermaNumSlider:DockPadding(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

	DermaNumSlider.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, zclib.colors[ "black_a50" ])
	end

	DermaNumSlider:DockMargin(10 * zclib.wM, 0 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
	DermaNumSlider:Dock(TOP)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	DermaNumSlider.OnValueChanged = function(self, value)
		pcall(OnChange, value)
	end

	DermaNumSlider.Label:SetFont(zclib.GetFont("zclib_font_small"))
	DermaNumSlider.Label:SetTextColor(zclib.colors[ "text01" ])
	DermaNumSlider:SetText(title)

	DermaNumSlider.PerformLayout = function(self)
		self.Label:SetWide(self:GetWide() / 3)
	end

	DermaNumSlider.TextArea:SetDrawLanguageID(false)

	DermaNumSlider.TextArea.Paint = function(s, w, h)
		if s:GetText() == "" and not s:IsEditing() then
			draw.SimpleText(emptytext, zclib.GetFont("zclib_font_small"), 5 * zclib.wM, h / 2, zclib.colors[ "white_a15" ], 0, 1)
		end

		s:DrawTextEntryText(color_white, zclib.colors[ "textentry" ], color_white)
	end

	DermaNumSlider.TextArea.PerformLayout = function(s, width, height)
		s:SetFontInternal(zclib.GetFont("zclib_font_small"))
	end

	return DermaNumSlider
end

/*
    Creates a quick confirmation window
*/
function zbf.vgui.ConfirmationWindow(Question, OnAccept, OnDecline)
	local main = vgui.Create("DPanel")
	main:MakePopup()
	main:SetSize(zclib_main_panel:GetWide(), zclib_main_panel:GetTall())

	local xPos,yPos = zclib_main_panel:GetPos()
	main:SetPos(xPos,yPos)

	main.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a200"])

		if input.IsKeyDown(KEY_ESCAPE) and IsValid(s) then
			s:Remove()
		end
	end

	local window = vgui.Create("DPanel", main)
	window:SetSize(500 * zclib.wM, 200 * zclib.hM)
	window:Center()
	window.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])
		draw.SimpleText(Question, zclib.GetFont("zclib_font_big"), w / 2, 30 * zclib.hM, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	local yes = zbf.vgui.Button(window, zbf.language[ "Yes" ], zclib.GetFont("zclib_font_mediumsmall"), zclib.colors["green01"], function()
		pcall(OnAccept)
		main:Remove()
	end)
	yes:Dock(NODOCK)
	yes:SetPos(50 * zclib.wM, 120 * zclib.hM)
	yes:SetSize(160 * zclib.wM, 50 * zclib.hM)

	local No = zbf.vgui.Button(window, zbf.language[ "No" ], zclib.GetFont("zclib_font_mediumsmall"), zclib.colors["red01"], function()
		if OnDecline then
			pcall(OnDecline)
		end

		main:Remove()
	end)
	No:Dock(NODOCK)
	No:SetPos(290 * zclib.wM, 120 * zclib.hM)
	No:SetSize(160 * zclib.wM, 50 * zclib.hM)
end

/*
    Creates a button with a image
*/
function zbf.vgui.ImageButton(parent, image, color, OnClick,IsLocked,tooltip)
    local btn = zclib.vgui.ImageButton(0, 0, 50 * zclib.wM, 50 * zclib.hM, parent, image, function(s)
        pcall(OnClick,s)
    end,function()
        return IsLocked()
    end)
    btn:Dock(RIGHT)
    btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
    btn.IconColor = color
    btn:SetTooltip(tooltip)
    return btn
end

/*
    Creates a TextEntry with a Button to open a list of cached Imgur images
*/
local OptionPanel
local function ImageGallery(OnImageSelected,txt)

    if IsValid(OptionPanel) then OptionPanel:Remove() end

    local main = vgui.Create( "DPanel" )
    main:MakePopup()
    main:SetSize(zclib_main_panel:GetWide(),zclib_main_panel:GetTall())
    main:Center()

    local title_font = zclib.GetFont("zclib_font_big")
    local txtW = zclib.util.GetTextSize("Cached Images",title_font)
    if txtW >= (480 * zclib.wM) then
        title_font = zclib.GetFont("zclib_font_medium")
    end

    main.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])
        draw.RoundedBox(10, 50 * zclib.wM,70 * zclib.hM, w, 5 * zclib.hM, zclib.colors["ui01"])
        draw.SimpleText(zbf.language[ "Cached Images" ], title_font, 50 * zclib.wM,15 * zclib.hM,zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    OptionPanel = main

    local back_btn = zclib.vgui.ImageButton(zclib_main_panel:GetWide() - 60 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,main,zclib.Materials.Get("back"),function()
        main:Close()
    end,false)
    back_btn.IconColor = zclib.colors["red01"]

    local list,scroll = zclib.vgui.List(main)
    scroll:DockMargin(50 * zclib.wM,90 * zclib.hM,50 * zclib.wM,10 * zclib.hM)
    list:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
    list:SetSpaceY( 10 * zclib.hM)
    list:SetSpaceX( 10 * zclib.wM)
    scroll.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, zclib.colors["black_a50"])
    end

    local itmSize = (zclib_main_panel:GetWide() - 100 * zclib.wM) / 6
    itmSize = itmSize - 28 * zclib.wM
    for imgurid,img_mat in pairs(zclib.Imgur.CachedMaterials) do
        if img_mat == nil then continue end
        if imgurid == nil then continue end
        local b = vgui.Create("DButton",list)
        list:Add(b)
        b:SetText("")
        b:SetSize(itmSize * zclib.wM, itmSize * zclib.hM )
        b.DoClick = function()
            OnImageSelected(imgurid,txt)
            main:Remove()
        end
        b.mat = img_mat
        b.Paint = function(s, w, h)
            if s.mat then
                surface.SetDrawColor(color_white)
                surface.SetMaterial(s.mat)
                surface.DrawTexturedRect(0,0,w,h)
            end
        end
    end
end
function zbf.vgui.ImgurEntry(parent,default,OnImageSelected)
    local txt = zclib.vgui.TextEntry(parent,default,OnImageSelected,false)
    txt:Dock(TOP)
    txt:DockMargin(10 * zclib.wM,0 * zclib.hM,10 * zclib.wM,10 * zclib.hM)
    txt.bg_color = zclib.colors["black_a50"]

    local gallery_btn = zbf.vgui.ImageButton(txt, zclib.Materials.Get("clipboard"), zclib.colors["blue01"], function()
        ImageGallery(OnImageSelected,txt)
    end,function() return false end,zbf.language[ "CachedImages_tooltip" ])
    gallery_btn.IconColor = zclib.colors["blue01"]
    gallery_btn.NoneHover_IconColor = zclib.colors["text01"]
    gallery_btn:Dock(RIGHT)
    gallery_btn:DockMargin(10 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)

    return txt
end

/*
	Creates a interface that lets you select a piece or all of the provided c_amount
*/
local OptionWindow
function zbf.vgui.CurrencyAmountSelector(c_type, c_amount, OnConfirm, OnDecline,Default,AllowEmpty)
	if IsValid(OptionWindow) then
		OptionWindow:Remove()
	end

	local AmountSlider
	local AmountTextArea
	OptionWindow = vgui.Create("EditablePanel")
	OptionWindow:MakePopup()
	OptionWindow:SetText("")
	OptionWindow:SetSize(zclib_main_panel:GetWide(), zclib_main_panel:GetTall())

	local xPos, yPos = zclib_main_panel:GetPos()
	OptionWindow:SetPos(xPos, yPos)

	OptionWindow.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a200" ])

		if input.IsKeyDown(KEY_ESCAPE) and IsValid(s) then
			s:Remove()
		end

		if s:IsHovered() and IsValid(AmountSlider) and not AmountSlider:IsEditing() and IsValid(AmountTextArea) and not AmountTextArea:IsEditing() then
			s:SetCursor("hand")

			if input.IsMouseDown(MOUSE_LEFT) then
				if s.LeftClicked == nil then
					s.LeftClicked = true
					s:DoClick()
				end
			else
				s.LeftClicked = nil
			end
		end
	end
	OptionWindow.DoClick = function() OptionWindow:Remove() end

	local short = zbf.Currency.GetShort(c_type)
	local CurrencyValue = zbf.Currency.GetValue(c_type)
	local decimal = zbf.Currency.GetPrecision(c_type)

	local parentwindow = vgui.Create("DPanel", OptionWindow)
	parentwindow:SetSize(600 * zclib.wM, 300 * zclib.hM)
	parentwindow:Center()
	parentwindow.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui02" ])

		if IsValid(AmountSlider) then
			local amount = AmountSlider:GetValue()
			local MoneyAmount = math.Round(amount * CurrencyValue)
			local txt = zbf.Currency.Format(c_type,amount) .. " " .. short .. " / " .. zclib.Money.Display(MoneyAmount)
			draw.SimpleText(txt, zclib.GetFont("zclib_font_medium"), w / 2, 30 * zclib.hM, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end

	local selectedAmount = 0

	AmountSlider = zbf.vgui.NumSlider(parentwindow, selectedAmount, short .. ":", function(val)
		selectedAmount = val
		if not AmountTextArea:IsEditing() then AmountTextArea:SetText(math.Round(selectedAmount * CurrencyValue)) end
	end, 0, c_amount, decimal)
	AmountSlider:Dock(TOP)
	AmountSlider:SetTall(40)
	AmountSlider:DockMargin(20 * zclib.wM, 90 * zclib.hM, 20 * zclib.wM, 0 * zclib.hM)
	AmountSlider.PerformLayout = function(self) self.Label:SetWide(self:GetWide() / 8) end
	AmountSlider:DockPadding(10 * zclib.wM, 0 * zclib.hM, 10 * zclib.wM, 0 * zclib.hM)
	AmountSlider.TextArea:SetNumeric(true)
	AmountSlider.TextArea.PerformLayout = function(s, width, height)
		s:SetWide(56 * zclib.wM)
		s:SetFontInternal(zclib.GetFont("zclib_font_small"))
	end

	// Sets the money amount of the text entry to this default value
	if Default then
		AmountSlider:SetValue(Default)
	end

	local MainTextArea = vgui.Create("DPanel", parentwindow)
	MainTextArea:Dock(TOP)
	MainTextArea:SetTall(40)
	MainTextArea:DockMargin(20 * zclib.wM, 20 * zclib.hM, 20 * zclib.wM, 0 * zclib.hM)
	MainTextArea.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])
		draw.SimpleText(zbf.language[ "Money" ] .. ":", zclib.GetFont("zclib_font_small"), 5 * zclib.wM, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	AmountTextArea = vgui.Create("DTextEntry", MainTextArea)
	AmountTextArea:Dock(FILL)
	AmountTextArea:DockMargin(80 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	AmountTextArea:SetPaintBackground(false)
	AmountTextArea:SetNumeric(true)
	AmountTextArea:SetDrawLanguageID(false)

	AmountTextArea.Paint = function(s, w, h)
		if s:GetText() == "" and not s:IsEditing() then
			draw.SimpleText(zclib.Money.Display(0), zclib.GetFont("zclib_font_medium"), 5 * zclib.wM, h / 2, zclib.colors[ "white_a15" ], 0, 1)
		end

		s:DrawTextEntryText(color_white, zclib.colors[ "textentry" ], color_white)
	end

	AmountTextArea.PerformLayout = function(s, width, height)
		s:SetFontInternal(zclib.GetFont("zclib_font_medium"))
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	AmountTextArea.OnChange = function()
		local val = AmountTextArea:GetValue()
		if val == nil then return end
		val = tonumber(val, 10)
		if val == nil then return end
		val = math.Round(val)
		selectedAmount = math.Round(val / CurrencyValue, decimal)

		if not AmountSlider:IsEditing() then
			AmountSlider:SetValue(val / CurrencyValue)
		end
	end

	// Sets the money amount of the text entry to this default value
	if Default then
		AmountTextArea:SetValue(zbf.Currency.GetValue(c_type,Default))
	end

	local yes = zbf.vgui.Button(parentwindow, zbf.language[ "Confirm" ], zclib.GetFont("zclib_font_mediumsmall"), zclib.colors[ "green01" ], function()
		if not AllowEmpty and selectedAmount <= 0 then return end

		// You cant payout more then what you got
		if selectedAmount > c_amount then return end


		pcall(OnConfirm, selectedAmount)
		OptionWindow:Remove()
	end)

	yes:Dock(LEFT)
	yes:SetWide(200)
	yes:DockMargin(20 * zclib.wM, 20 * zclib.hM, 0 * zclib.wM, 20 * zclib.hM)

	local No = zbf.vgui.Button(parentwindow, zbf.language[ "Cancel" ], zclib.GetFont("zclib_font_mediumsmall"), zclib.colors[ "red01" ], function()
		if OnDecline then
			pcall(OnDecline)
		end

		OptionWindow:Remove()
	end)

	No:Dock(RIGHT)
	No:SetWide(200)
	No:DockMargin(10 * zclib.wM, 20 * zclib.hM, 20 * zclib.wM, 20 * zclib.hM)
end

/*
	Creates a window that lets the player select how much of the provided currecnys he wants sell / drop / move etc
*/
function zbf.vgui.CurrencySelector(CurrencyList, OnConfirm, OnAbort,Confirm_Name,Confirm_ToolTip)
	zclib.vgui.Page("       " .. zbf.language[ "Choose Currencys" ], function(main, top)
		main:SetSize(1200 * zclib.wM, 800 * zclib.hM)

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
			pcall(OnAbort)
		end, false)
		back_btn:Dock(LEFT)
		back_btn:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		back_btn.IconColor = zclib.colors[ "orange01" ]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		zbf.vgui.AddTopSepeartor(top)

		local SelectedCurrencys = {}
		local ConfirmButton = zbf.vgui.Button(top, Confirm_Name, zclib.GetFont("zclib_font_medium"), zclib.colors[ "green01" ], function()
			if table.Count(SelectedCurrencys) <= 0 then
				return
			end
			pcall(OnConfirm, SelectedCurrencys)
		end)

		ConfirmButton:SetTall(50)
		ConfirmButton:Dock(RIGHT)
		ConfirmButton:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		if Confirm_ToolTip then ConfirmButton:SetTooltip(Confirm_ToolTip) end

		local content

		local function RebuildLists()
			if IsValid(content) then
				content:Remove()
			end

			content = vgui.Create("DPanel", main)
			content:SetSize(1100 * zclib.wM, 1000 * zclib.hM)
			content:Dock(FILL)
			content:DockMargin(50 * zclib.wM, 0 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
			content.Paint = function(s, w, h) end

			local function AddList(dock, Populate)
				local pnl = vgui.Create("DPanel", content)
				pnl:SetSize(540 * zclib.wM, 1000 * zclib.hM)
				pnl:Dock(dock)

				//pnl:DockMargin(50 * zclib.wM, 0 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
				pnl.Paint = function(s, w, h)
					draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])
				end

				local list, scroll = zclib.vgui.List(pnl)
				scroll:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
				list:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
				list:SetSpaceY(10 * zclib.hM)
				list:SetSpaceX(10 * zclib.wM)
				pcall(Populate, list)
			end

			local function AddCurrencyButton(list, k, CurrencyAmount, OnClick)
				if CurrencyAmount <= 0 then return end

				local CurrencyData = zbf.Currency.Get(k)
				local CurrencyValue = zbf.Currency.GetValue(k)
				local MoneyAmount = math.Round(CurrencyAmount * CurrencyValue)
				MoneyAmount = zclib.Money.Display(MoneyAmount)

				local CurrencyAmountNice = zbf.Currency.Format(k,CurrencyAmount) .. " " .. CurrencyData.short

				local itm = list:Add("DButton")
				itm:SetSize(510 * zclib.wM, 60 * zclib.hM)
				itm:SetText("")
				itm.Paint = function(s, w, h)
					draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui_highlight" ])

					if s.crypto_icon then
						if isstring(s.crypto_icon) then
							draw.SimpleText(s.crypto_icon, zclib.GetFont("zclib_font_big"), h / 2, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						else
							surface.SetDrawColor(color_white)
							surface.SetMaterial(s.crypto_icon)
							surface.DrawTexturedRect(h * 0.15, h * 0.15, h * 0.7, h * 0.7)
						end
					else
						draw.RoundedBox(5, 0, 0, h, h, zclib.colors[ "blue02" ])
					end

					draw.SimpleText(CurrencyData.name, zclib.GetFont("zclib_font_mediumsmall_thin"), h + 10 * zclib.wM, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					draw.SimpleText(CurrencyData.short, zclib.GetFont("zclib_font_small_thin"), h + 10 * zclib.wM, h - 5, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(MoneyAmount, zclib.GetFont("zclib_font_mediumsmall_thin"), w - 10 * zclib.wM, 5, zclib.colors[ "green01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
					draw.SimpleText(CurrencyAmountNice, zclib.GetFont("zclib_font_small_thin"), w - 10 * zclib.wM, h - 5, zclib.colors[ "text01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
				end
				itm.DoClick = function() pcall(OnClick, k, CurrencyAmount) end

				itm.crypto_icon = zbf.Currency.GetIcon(k)
			end

			// First lets display all the currencys we currently have in our wallet minus the one we already got select
			AddList(LEFT, function(list)
				for k, v in pairs(zbf.Currency.List) do
					// Remove the amount thats allready selected
					local remain = math.Clamp((CurrencyList[ k ] or 0) - (SelectedCurrencys[ k ] or 0), 0, 99999999999999999)
					if remain <= 0 then continue end

					// Add a currency button with the full amount we have in our vault and which opens a amount selection window when clicked on it
					AddCurrencyButton(list, k, remain, function(id, CurrencyAmount)
						// Open selection window with the specified CurrencyAmount
						zbf.vgui.CurrencyAmountSelector(id, CurrencyAmount, function(val)
							//Add currency to droplist
							SelectedCurrencys[ id ] = val
							// Rebuild lists
							RebuildLists()
						end)
					end)
				end
			end)

			// Now lets display all the currencys we allready have select
			AddList(RIGHT, function(list)
				for k, v in pairs(SelectedCurrencys) do
					// Add a currency button with the selected amount which can be removed when clicked on it
					AddCurrencyButton(list, k, v, function(id, CurrencyAmount)
						// Remove currency from droplist
						SelectedCurrencys[ id ] = nil
						// Rebuild lists
						RebuildLists()
					end)
				end
			end)
		end

		RebuildLists()
	end)
end

/*
	Creates a list of the players currency
*/
function zbf.vgui.CurrencyList(window, PlayerWallet, HideEmpty, OnRowCreated,CanDisplay,DisplayEarnings)
	if IsValid(window.CurrencyList) then window.CurrencyList:Remove() end

	local content = vgui.Create("DPanel", window)
	content:SetSize(1000 * zclib.wM, 1000 * zclib.hM)
	content:Dock(FILL)
	content:DockMargin(50 * zclib.wM, 0 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
	content.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 40 * zclib.hM, w, h, zclib.colors[ "black_a50" ])
		draw.RoundedBox(5, w - 15 * zclib.wM, 40 * zclib.hM, 15 * zclib.wM, h, zclib.colors[ "black_a50" ])
		draw.RoundedBox(5, 0, 0, w, 30 * zclib.hM, zclib.colors[ "black_a50" ])
	end
	window.CurrencyList = content

	content.PaintOver = function(s,w,h)
		surface.SetDrawColor(zclib.colors[ "black_a200" ])
		surface.SetMaterial(zclib.Materials.Get("linear_gradient"))
		surface.DrawTexturedRectRotated(w / 2,h * 0.91,h * 0.2,w,-90)
	end

	local CryptoList

	local SearchName

	local SortByName = false
	local SortByBalance = true
	local SortByPrice = false
	local SortByPerf = false
	local SortByEarn = false

	local SortInvert = false

	local function RebuildList()
		if not IsValid(content) then return end
		if IsValid(CryptoList) then CryptoList:Remove() end

		local list, scroll = zclib.vgui.List(content)
		scroll:DockMargin(10 * zclib.wM, 40 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		list:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		list:SetSpaceY(10 * zclib.hM)
		list:SetSpaceX(10 * zclib.wM)
		CryptoList = scroll

		// Sort Alphabetically
		local t_list = table.Copy(zbf.Currency.List)
		for k,v in pairs(t_list) do v.id = k end

		// Remove any currency from the list you already have
		for k,v in pairs(t_list) do
			if PlayerWallet[k] then
				v.am = PlayerWallet[k]
			else
				v.am = 0
			end
		end

		// Lets add the earnings diffrence
		for k,v in pairs(t_list) do
			v.earnings = zbf.MoneyTrack.GetDifference(LocalPlayer(),v.id)
		end

		// Sort By Name
		if SortByName then
			if SortInvert then
				table.sort(t_list,function(a, b) return a.name < b.name end)
			else
				table.sort(t_list,function(a, b) return a.name > b.name end)
			end
		end

		// Sort by balance
		if SortByBalance then
			if SortInvert then
				table.sort(t_list,function(a, b) return (zbf.Currency.GetValue(a.id) * a.am) < (zbf.Currency.GetValue(b.id) * b.am) end)
			else
				table.sort(t_list,function(a, b) return (zbf.Currency.GetValue(a.id) * a.am) > (zbf.Currency.GetValue(b.id) * b.am) end)
			end
		end

		// Sort by price
		if SortByPrice then
			if SortInvert then
				table.sort(t_list,function(a, b) return zbf.Currency.GetValue(a.id) < zbf.Currency.GetValue(b.id) end)
			else
				table.sort(t_list,function(a, b) return zbf.Currency.GetValue(a.id) > zbf.Currency.GetValue(b.id) end)
			end
		end

		// Sort by performance
		if SortByPerf then
			if SortInvert then
				table.sort(t_list,function(a, b) return zbf.Currency.GetPerformance(a.id) < zbf.Currency.GetPerformance(b.id) end)
			else
				table.sort(t_list,function(a, b) return zbf.Currency.GetPerformance(a.id) > zbf.Currency.GetPerformance(b.id) end)
			end
		end

		// Sort by earnings
		if SortByEarn then
			if SortInvert then
				table.sort(t_list,function(a, b) return a.earnings < b.earnings end)
			else
				table.sort(t_list,function(a, b) return a.earnings > b.earnings end)
			end
		end

		for k, v in pairs(t_list) do
			local CurrencyValue = zbf.Currency.GetValue(v.id)
			local CurrencyAmount = PlayerWallet[ v.id ] or 0
			local IsEmpty = CurrencyAmount <= 0
			local MoneyAmount = math.Round(CurrencyAmount * CurrencyValue)
			MoneyAmount = zclib.Money.Display(MoneyAmount)

			if CanDisplay and CanDisplay(v.id) == false then continue end

			if HideEmpty and IsEmpty then continue end

			CurrencyValue = zbf.Currency.Format(v.id,CurrencyValue)
			CurrencyValue = zclib.Money.Display(CurrencyValue)

			local CryptoName = zbf.Currency.GetName(v.id)

			// If we search for a specific crypto then skip anything that doesent fit
			if SearchName and string.find( string.lower(CryptoName), string.lower(SearchName) ) == nil then continue end

			// Cacluates the current performance of that coin
			local CryptoPerf_txt,CryptoPerf_Color = zbf.Currency.GetNicePerformance(v.id)

			local c_name = zbf.Currency.GetName(v.id)

			CurrencyAmount = zbf.Currency.Format(v.id,CurrencyAmount)

			content:InvalidateLayout(true)
			content:InvalidateParent(true)
			local itm_w = content:GetWide() - 32 * zclib.wM//1070 * zclib.wM

			local itm = list:Add("DPanel")
			itm:SetSize(itm_w, 60 * zclib.hM)
			itm:SetText("")
			/*
			itm.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, IsEmpty and zclib.colors[ "ui02" ] or zclib.colors[ "ui_highlight" ])

				if s.crypto_icon then
					if isstring(s.crypto_icon) then
						draw.SimpleText(s.crypto_icon, zclib.GetFont("zclib_font_big"), h / 2, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						surface.SetDrawColor(color_white)
						surface.SetMaterial(s.crypto_icon)
						surface.DrawTexturedRect(h * 0.15, h * 0.15, h * 0.7, h * 0.7)
					end
				else
					draw.RoundedBox(5, 0, 0, h, h, zclib.colors[ "blue02" ])
				end

				draw.SimpleText(c_name, zclib.GetFont("zclib_font_mediumsmall_thin"), h + 10 * zclib.wM, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw.SimpleText(v.short, zclib.GetFont("zclib_font_small_thin"), h + 10 * zclib.wM, h - 5, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				draw.SimpleText(MoneyAmount, zclib.GetFont("zclib_font_mediumsmall_thin"), h + 300 * zclib.wM, 5,IsEmpty and zclib.colors[ "black_a150" ] or zclib.colors[ "green01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw.SimpleText(CurrencyAmount .. " " .. v.short, zclib.GetFont("zclib_font_small_thin"), h + 300 * zclib.wM, h - 5, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

				draw.SimpleText(CurrencyValue, zclib.GetFont("zclib_font_mediumsmall_thin"), h + 530 * zclib.wM, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText(CryptoPerf_txt, zclib.GetFont("zclib_font_mediumsmall_thin"), h + 710 * zclib.wM,  h / 2, CryptoPerf_Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			*/

			local Earnings = v.earnings
			local EarningColor = zclib.colors[ "text01" ]

			local FinalEarnings = zclib.Money.Display(math.abs(Earnings))

			if Earnings > 0 then
				EarningColor = zclib.colors[ "green01" ]
				FinalEarnings = "+" .. FinalEarnings
			elseif Earnings < 0 then
				EarningColor = zclib.colors[ "red01" ]
				FinalEarnings = "-" .. FinalEarnings
			end

			itm.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, IsEmpty and zclib.colors[ "ui02" ] or zclib.colors[ "ui_highlight" ])

				if s.crypto_icon then
					if isstring(s.crypto_icon) then
						draw.SimpleText(s.crypto_icon, zclib.GetFont("zclib_font_big"), h / 2, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						surface.SetDrawColor(color_white)
						surface.SetMaterial(s.crypto_icon)
						surface.DrawTexturedRect(h * 0.15, h * 0.15, h * 0.7, h * 0.7)
					end
				else
					draw.RoundedBox(5, 0, 0, h, h, zclib.colors[ "blue02" ])
				end

				draw.SimpleText(c_name, zclib.GetFont("zclib_font_mediumsmall_thin"), h + 10 * zclib.wM, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw.SimpleText(v.short, zclib.GetFont("zclib_font_small_thin"), h + 10 * zclib.wM, h - 5, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				draw.SimpleText(MoneyAmount, zclib.GetFont("zclib_font_mediumsmall_thin"), h + 300 * zclib.wM, 5,IsEmpty and zclib.colors[ "black_a150" ] or zclib.colors[ "green01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw.SimpleText(CurrencyAmount .. " " .. v.short, zclib.GetFont("zclib_font_small_thin"), h + 300 * zclib.wM, h - 5, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

				draw.SimpleText(CurrencyValue, zclib.GetFont("zclib_font_mediumsmall_thin"), h + 530 * zclib.wM, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText(CryptoPerf_txt, zclib.GetFont("zclib_font_mediumsmall_thin"), h + 680 * zclib.wM,  h / 2, CryptoPerf_Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				if DisplayEarnings then
					draw.SimpleText(FinalEarnings, zclib.GetFont("zclib_font_mediumsmall_thin"), h + 880 * zclib.wM,  h / 2, EarningColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
			end

			pcall(OnRowCreated,itm,v.id,IsEmpty)

			itm.crypto_icon = zbf.Currency.GetIcon(v.id)
		end
	end

	RebuildList()

	local searchbox = zclib.vgui.TextEntry(content, zbf.language[ "Search" ],function(val)
		SearchName = val
		// Setup delay timer to only refresh 1-2 seconds after typing
		local timerid = "zbf_crypto_type_delay"
		zclib.Timer.Remove(timerid)
		zclib.Timer.Create(timerid,1,1,function() RebuildList() end)
	end)
	searchbox:SetSize(160 * zclib.wM,20 * zclib.hM )
	searchbox:SetPos(150 * zclib.wM,5 * zclib.hM)

	local function AddArrowButton(x,txt,OnClick,IsSelected,tooltip)
		local btn = vgui.Create("DButton", content)
		btn:SetSize(200 * zclib.wM,30 * zclib.hM )
		btn:SetPos(x * zclib.wM,0 * zclib.hM)
		btn:SetText(txt)
		btn:SetFont(zclib.GetFont("zclib_font_mediumsmall_thin"))
		btn.Paint = function(s, w, h)
			//draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])

			if IsSelected() then
				draw.SimpleText(txt .. (SortInvert and "▼" or "▲"), zclib.GetFont("zclib_font_mediumsmall_thin"), 0, h / 2, s:IsHovered() and zbf.colors[ "orange03" ] or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(txt, zclib.GetFont("zclib_font_mediumsmall_thin"), 0, h / 2, s:IsHovered() and zbf.colors[ "orange03" ] or zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
		btn.DoClick = function(s)
			zclib.vgui.PlaySound("UI/buttonclick.wav")
			pcall(OnClick)
		end
		btn:SetTooltip(tooltip)
		btn:SizeToContentsX(50)
		btn:SetText("")
	end

	// Sort by name
	AddArrowButton(10,zbf.language[ "Name" ],function()

		SortInvert = not SortInvert

		SortByName = true
		SortByBalance = false
		SortByPrice = false
		SortByPerf = false
		SortByEarn = false
		RebuildList()
	end,function() return SortByName end,zbf.language[ "SortByName" ])
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	// Sot by balance
	AddArrowButton(370,zbf.language[ "Balance" ],function()

		SortInvert = not SortInvert

		SortByName = false
		SortByBalance = true
		SortByPrice = false
		SortByPerf = false
		SortByEarn = false
		RebuildList()
	end,function() return SortByBalance end,zbf.language[ "SortByBalance" ])

	// Sort by price
	AddArrowButton(600,zbf.language[ "Price" ],function()

		SortInvert = not SortInvert

		SortByName = false
		SortByBalance = false
		SortByPrice = true
		SortByPerf = false
		SortByEarn = false
		RebuildList()
	end,function() return SortByPrice end,zbf.language[ "SortByPrice" ])

	// Sort by performance
	AddArrowButton(750,zbf.language[ "Performance" ],function()

		SortInvert = not SortInvert

		SortByName = false
		SortByBalance = false
		SortByPrice = false
		SortByPerf = true
		SortByEarn = false
		RebuildList()
	end,function() return SortByPerf end,zbf.language[ "SortByPerformance" ])

	if DisplayEarnings then
		// Sort by earnings
		AddArrowButton(950,zbf.language[ "Earnings" ],function()

			SortInvert = not SortInvert

			SortByName = false
			SortByBalance = false
			SortByPrice = false
			SortByPerf = false
			SortByEarn = true
			RebuildList()
		end,function() return SortByEarn end,zbf.language[ "SortByEarnings" ])
	end
end

/*
	Creates a selection to choose which player we want
*/
local bot_mat = Material("materials/zerochain/zbot/zbf_bot_icon.png", "smooth")
function zbf.vgui.PlayerSelection(HideSelf,OnSelect,OnBack,PostDraw,CanSelect)
	local title
	if OnBack then
		title = "       " .. zbf.language[ "Select Player" ]
	else
		title = zbf.language[ "Select Player" ]
	end

	zclib.vgui.Page(title, function(main, top)
		main:SetSize(1200 * zclib.wM, 800 * zclib.hM)

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		if OnBack then
			local back_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("back"), function()
				pcall(OnBack)
			end, false)
			back_btn:Dock(LEFT)
			back_btn:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			back_btn.IconColor = zclib.colors[ "orange01" ]
		end

		zbf.vgui.AddTopSepeartor(top)

		local content = vgui.Create("DPanel", main)
		content:SetSize(1000 * zclib.wM, 1000 * zclib.hM)
		content:Dock(FILL)
		content:DockMargin(50 * zclib.wM, 5 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
		content.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])
			draw.RoundedBox(5, w - 15 * zclib.wM, 0, 15 * zclib.wM, h, zclib.colors[ "black_a50" ])
		end

		local list, scroll = zclib.vgui.List(content)
		scroll:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		list:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		list:SetSpaceY(10 * zclib.hM)
		list:SetSpaceX(10 * zclib.wM)

		local PnlSize = 111

		for k, v in pairs(player.GetAll()) do
			if not IsValid(v) then continue end

			// Hide ourself
			if HideSelf and v == LocalPlayer() then continue end

			// Hide the player from the list for any other reason
			if CanSelect and not CanSelect(v) then continue end

			local itm = vgui.Create("DButton")
			itm:SetSize(PnlSize * zclib.wM, PnlSize * zclib.hM)
			local nick = v:Nick()
			itm:SetText("")
			itm.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "ui00" ])

				if s.m_Material then
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(s.m_Material)
					surface.DrawTexturedRect(w * 0.1, h * 0.1, w * 0.8, h * 0.8)
				end

				if nick then
					draw.RoundedBox(5, 0, h - (26 * zclib.hM), w, 26 * zclib.hM, zclib.colors[ "black_a200" ])
					draw.SimpleText(nick, zclib.GetFont("zclib_font_smoll"),w / 2,h - (5 * zclib.hM), zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
				end

				if PostDraw then
					pcall(PostDraw,v,w,h)
				end

				if s:IsHovered() then
					draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "white_a15" ])
				end
			end

			list:Add(itm)

			if v:IsBot() then
				itm.m_Material = bot_mat
			else
				zclib.Avatar.GetMaterial(v:SteamID64(), function(mat)
					if not IsValid(itm) then return end
					itm.m_Material = mat
				end)
			end

			itm.DoClick = function(s)
				pcall(OnSelect, v)
				main:Close()
				zclib.vgui.PlaySound("UI/buttonclick.wav")
			end
		end
	end)
end
