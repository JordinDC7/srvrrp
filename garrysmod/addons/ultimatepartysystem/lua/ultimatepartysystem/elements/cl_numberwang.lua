local PANEL = {}

function PANEL:Init()
    self:SetTextColor(color_black)
    self:SetFont("ultimatepartysystem.scaled.7")
    self:SetNumeric(true)

    self.min = nil
    self.max = nil
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, color_white)
    self:DrawTextEntryText(color_black, color_black, color_black)
end

function PANEL:SetMin(min)
    self.min = min
end
function PANEL:SetMax(max)
    self.max = max
end

function PANEL:GetValue()
    return self:GetInt()
end

function PANEL:OnChange()
    if(self:GetText() == nil) then return end
    if(string.Trim(self:GetText()) == "") then return end
    if(string.Trim(self:GetText()) == "-") then return end
    if(self:GetInt() == nil) then return end

    if(self.min) then
        if(self.min > self:GetInt()) then
            self:SetText(self.min)
            self:KillFocus()
            return
        end
    end
    if(self.max) then
        if(self.max < self:GetInt()) then
            self:SetText(self.max)
            self:KillFocus()
            return
        end
    end
end
function PANEL:OnLoseFocus()
    if(string.Trim(self:GetText()) != "") then return end
    self:SetText(self.min)
end

vgui.Register("ultimatepartysystem.numberwang", PANEL, "DTextEntry")