local PANEL = {}

local matTick = Material("xenin/tick.png", "smooth")

function PANEL:Init()
	self:SetText("")

	self.State = false
	self.AnimationController = 0
	self.Color = XeninUI.Theme.Accent
	self.Background = XeninUI.Theme.Primary
	self.Font = "XeninUI.CheckboxV2"
end

XeninUI:CreateFont("XeninUI.CheckboxV2", 18)

function PANEL:Paint(w, h)
	XeninUI:MaskInverse(function()
		surface.SetDrawColor(color_white)
		local x = h * math.Clamp((self.AnimationController - 0.5) * 2, 0, 1)
		surface.DrawRect(h - x, 0, h, h)
	end, function()
		XeninUI:DrawRoundedBoxEx(6, 0, 0, h, h * 0.5, self.Color, true, true, false, false)
	end)
	XeninUI:MaskInverse(function()
		surface.SetDrawColor(color_white)
		local width = h * math.Clamp(self.AnimationController * 2, 0, 1)
		surface.DrawRect(0, 0, width, h)
	end, function()
		XeninUI:DrawRoundedBoxEx(6, 0, h * 0.5, h, h * 0.5, self.Color, false, false, true, true)
	end)
	XeninUI:DrawRoundedBox(4, 2, 2, h - 4, h - 4, self.Background)

	XeninUI:MaskInverse(function()
		surface.SetDrawColor(color_white)
		local x = h * math.Clamp((self.AnimationController - 1) * 2, 0, 1)
		surface.DrawRect(x, 0, h, h)
	end, function()
		surface.SetMaterial(matTick)
		surface.SetDrawColor(self.Color)
		surface.DrawTexturedRect(0, 0, h, h)
	end)

	if self.Text then
		local x = h + 5
		XeninUI:DrawShadowText(self.Text, self.Font, x, h / 2 - 1, self.TextColor or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, 125)
	end
end

function PANEL:SizeToContentsX()
	surface.SetFont(self.Font)
	local tw = surface.GetTextSize(self.Text)

	self:SetWide(self:GetTall() + 5 + tw)
end

function PANEL:SetState(state, instant)
	self.State = state

	if state then
		if instant then
			self:EndAnimations()
			self.AnimationController = 1.5
		else
			self:Lerp("AnimationController", 1.5, 0.4)
		end
	else
		self:EndAnimations()
		self.AnimationController = 0
	end
end

function PANEL:OnStateChanged() end

function PANEL:Toggle()
	self:SetState(!self.State)
	self:OnStateChanged(self.State)
end

vgui.Register("XeninUI.CheckboxV2", PANEL, "DButton")
