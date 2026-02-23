local PANEL = {}

function PANEL:Init()
    self:SetTextColor(color_black)
    self:SetFont("ultimatepartysystem.scaled.7")

    self.maxChars = -1
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, color_white)
    self:DrawTextEntryText(color_black, color_black, color_black)
end

function PANEL:SetMaxCharacters(x)
    self.maxChars = x
end

function PANEL:OnChange()
    if(self.maxChars < 0) then return end
    if(#self:GetText() <= self.maxChars) then return end
    self:SetText(string.sub(self:GetText(), 0, self.maxChars))
    self:KillFocus()
end

vgui.Register("ultimatepartysystem.textentry", PANEL, "DTextEntry")