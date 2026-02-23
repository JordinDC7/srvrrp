local PANEL = {}

function PANEL:Init()
    self.color = UltimatePartySystem.Settings.GetValue("themeColor")
    self.lightColor = Color(self.color.r + 25, self.color.g + 25, self.color.b + 25) -- this is probably bad (for the gradient btw)

    self.lerp = 0
    self.hoverColor = Color(self.color.r + 50, self.color.g + 50, self.color.b + 50)

    self.material = nil
    self.matSize = 2.5
    self.matPadding = 5

    self.label = "um"
    self.font = "ultimatepartysystem.scaled.bold.10"
    self:SetText("")
end

function PANEL:Paint(w, h)
    if(self:IsHovered()) then
        self.lerp = Lerp(RealFrameTime() * 2, self.lerp, 150)
    else
        self.lerp = Lerp(RealFrameTime() * 2, self.lerp, 0)
    end

    draw.RoundedBox(0, 0, 0, w, h, self.color)

    surface.SetDrawColor(self.hoverColor.r, self.hoverColor.g, self.hoverColor.b, self.lerp)
    surface.SetMaterial(UltimatePartySystem.Cache.Materials.CircleyBoi)
    local x,y = self:CursorPos()
    surface.DrawTexturedRect(x - (w / 2), y - (w / 2), w, w)

    if(self.material) then
        -- this could probably be better...
        surface.SetFont(self.font)
        local txtWidth = surface.GetTextSize(self.label)

        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(self.material)
        surface.DrawTexturedRect((w / 2) - (txtWidth / 2) - self.matPadding, (h / 2) - ((h / self.matSize) / 2), h / self.matSize, h / self.matSize)

        draw.SimpleText(self.label, self.font, w / 2 + (h / 2) + self.matPadding, h / 2, color_white, 1, 1)

        return
    end

    draw.SimpleText(self.label, self.font, w / 2, h / 2, color_white, 1, 1)
end

function PANEL:SetColor(clr)
    self.color = clr
    self.lightColor = Color(clr.r + 25, clr.g + 25, clr.b + 25)
    self.hoverColor = Color(clr.r + 50, clr.g + 50, clr.b + 50)
end
function PANEL:SetLabel(lbl)
    self.label = lbl
end
function PANEL:SetFont(fnt)
    self.font = fnt
end
function PANEL:SetMaterial(mat, size, padding)
    self.material = mat
    self.matSize = size
    self.matPadding = padding
end

vgui.Register("ultimatepartysystem.button", PANEL, "DButton")