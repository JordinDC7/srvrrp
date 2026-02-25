XeninUI:CreateFont("XeninUI.Frame.Title", 28)

local PANEL = {}

function PANEL:Init()
	self.top = vgui.Create("Panel", self)
	self.top:Dock(TOP)
	self.top.Paint = function(pnl, w, h)
		draw.RoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Primary, true, true, false, false)
	end

	if XeninUI.Branding then
		local isMat = type(XeninUI.Branding) == "IMaterial"

		self.branding = vgui.Create("Panel", self.top)
		self.branding:Dock(LEFT)
		if (!isMat) then
			XeninUI:DownloadIcon(self.branding, XeninUI.Branding)
		end
		self.branding.Paint = function(pnl, w, h)
			if isMat then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(XeninUI.Branding)
				surface.DrawTexturedRect(4, 4, w - 8, h - 8)
			else
				XeninUI:DrawIcon(4, 4, w - 8, h - 8, pnl)
			end
		end
	end

	self.title = vgui.Create("DLabel", self.top)
	self.title:Dock(LEFT)
	self.title:DockMargin(IsValid(self.branding) and 0 or 10, 0, 0, 0)
	self.title:SetFont("XeninUI.Frame.Title")
	self.title:SetTextColor(color_white)

	self.closeBtn = vgui.Create("DButton", self.top)
	self.closeBtn:Dock(RIGHT)
	self.closeBtn:SetText("")
	self.closeBtn.CloseButton = Color(195, 195, 195)
	self.closeBtn.Alpha = 0
	self.closeBtn.DoClick = function(pnl)
		self:Remove()
	end
	self.closeBtn.Paint = function(pnl, w, h)
		draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(XeninUI.Theme.Red, pnl.Alpha))

		surface.SetDrawColor(pnl.CloseButton)
		surface.SetMaterial(XeninUI.Materials.CloseButton)
		surface.DrawTexturedRect(12, 12, w - 24, h - 24)
	end
	self.closeBtn.OnCursorEntered = function(pnl)
		pnl:Lerp("Alpha", 255)
		pnl:LerpColor("CloseButton", Color(255, 255, 255))
	end
	self.closeBtn.OnCursorExited = function(pnl)
		pnl:Lerp("Alpha", 0)
		pnl:LerpColor("CloseButton", Color(195, 195, 195))
	end
end

function PANEL:SetTitle(str)
	self.title:SetText(str)
	self.title:SizeToContents()
end

function PANEL:PerformLayout(w, h)
	self.top:SetTall(40)

	if IsValid(self.branding) then
		self.branding:SetWide(self.top:GetTall())
	end

	self.closeBtn:SetWide(self.top:GetTall())
end

function PANEL:Paint(w, h)
	local x, y = self:LocalToScreen()

	BSHADOWS.BeginShadow()
	draw.RoundedBox(6, x, y, w, h, XeninUI.Theme.Background)
	BSHADOWS.EndShadow(1, 2, 2, 255, 0, 0)
end

function PANEL:ShowCloseButton(show)
	self.closeBtn:SetVisible(show)
end

vgui.Register("XeninUI.Frame", PANEL, "EditablePanel")

concommand.Add("xeninui", function()
	local frame = vgui.Create("XeninUI.Frame")
	frame:SetSize(960, 720)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Party")
end)
