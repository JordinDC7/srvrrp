local PANEL = {}

function PANEL:Init()
    self:SetTextColor(color_white)
    self:SetFont("ultimatepartysystem.scaled.7")

    self.DropButton.Paint = function(s, w, h)
        local triangle = {
        	{x = 0, y = (h * 0.3)},
            {x = w * 0.8, y = (h * 0.3)},
        	{x = (w * 0.8) / 2, y = (h * 0.7)},
        }

        surface.SetDrawColor(255, 255, 255)
    	draw.NoTexture()
    	surface.DrawPoly(triangle)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.SlightGray)
end

vgui.Register("ultimatepartysystem.combobox", PANEL, "DComboBox")