-- defo wasn't ripped from advanced printers nope. no sir. absolutely not. noooo.
local PANEL = {}

function PANEL:Init()
    self:SetText("")

    self.color = color_white
    self.bgColor = UltimatePartySystem.Cache.Colors.LightGray
    self.fade = true

    self.value = false
    self.locked = false

    self.lerp = self:GetTall() / 2

    self.lerpCR = self.color.r
    self.lerpCG = self.color.g
    self.lerpCB = self.color.b

    self.lerpBR = self.bgColor.r
    self.lerpBG = self.bgColor.g
    self.lerpBB = self.bgColor.b

    self:SetSize(40, 20)
end

function PANEL:SetColor(clr)
    self.color = clr
    self.lerpCR = self.color.r
    self.lerpCG = self.color.g
    self.lerpCB = self.color.b

    self.bgColor = Color(clr.r - 50, clr.g - 50, clr.b - 50)
    self.lerpBR = self.bgColor.r
    self.lerpBG = self.bgColor.g
    self.lerpBB = self.bgColor.b
end
function PANEL:SetBGColor(clr)
    self.bgColor = clr
    self.lerpBR = self.bgColor.r
    self.lerpBG = self.bgColor.g
    self.lerpBB = self.bgColor.b
end
function PANEL:SetFade(fde)
    self.fade = fade
end
function PANEL:SetValue(value)
    self.value = value
end
function PANEL:GetValue(value)
    return self.value
end
function PANEL:Toggle()
    if(self.locked) then return end
    self.value = !self.value

    self.OnToggle(self.value)
end

function PANEL:OnToggle(value)
end

function PANEL:SetLocked(lock)
    self.locked = lock
end

function PANEL:DoClick()
    self:Toggle()
end

function PANEL:Paint(w, h)
    if(self.value) then
        self.lerp = Lerp(RealFrameTime() * 5, self.lerp, w - (h / 2))
        if(self.fade) then
            self.lerpCR = Lerp(RealFrameTime() * 5, self.lerpCR, self.color.r)
            self.lerpCG = Lerp(RealFrameTime() * 5, self.lerpCG, self.color.g)
            self.lerpCB = Lerp(RealFrameTime() * 5, self.lerpCB, self.color.b)

            self.lerpBR = Lerp(RealFrameTime() * 5, self.lerpBR, self.bgColor.r)
            self.lerpBG = Lerp(RealFrameTime() * 5, self.lerpBG, self.bgColor.g)
            self.lerpBB = Lerp(RealFrameTime() * 5, self.lerpBB, self.bgColor.b)
        end
    else
        self.lerp = Lerp(RealFrameTime() * 5, self.lerp, h / 2)
        if(self.fade) then
            self.lerpCR = Lerp(RealFrameTime() * 5, self.lerpCR, 200)
            self.lerpCG = Lerp(RealFrameTime() * 5, self.lerpCG, 200)
            self.lerpCB = Lerp(RealFrameTime() * 5, self.lerpCB, 200)

            self.lerpBR = Lerp(RealFrameTime() * 5, self.lerpBR, 50)
            self.lerpBG = Lerp(RealFrameTime() * 5, self.lerpBG, 50)
            self.lerpBB = Lerp(RealFrameTime() * 5, self.lerpBB, 50)
        end
    end

    draw.RoundedBox((h - 5) / 2, 2, 2, w - 4, h - 4, Color(self.lerpBR, self.lerpBG, self.lerpBB))

    surface.SetDrawColor(self.lerpCR, self.lerpCG, self.lerpCB)
    UltimatePartySystem.Core.DrawCircle(self.lerp, h / 2, h / 2, 15)
end

vgui.Register("ultimatepartysystem.switch", PANEL, "DButton")