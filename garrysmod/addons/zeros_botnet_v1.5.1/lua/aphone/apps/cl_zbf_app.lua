/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

local APP = {}
APP.name = "Crypto Point"
APP.color = Color(255, 255, 255)
APP.icon = "zerochain/zbot/zbf_mcphone_app_icon.png"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

function APP:Open(main, main_x, main_y)
	function main:Paint(w, h)
		draw.RoundedBox(1, 0, 0, w, h, zclib.colors[ "ui01" ])
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	local but = vgui.Create("DButton", main)
	but:Dock(FILL)
	but:SetText("")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	function but:Paint(w, h)
		surface.SetDrawColor(self:IsHovered() and zbf.colors[ "orange02" ] or zclib.colors[ "white_a100" ])
		surface.SetMaterial(zclib.Materials.Get("zbf_cryptopoint"))
		surface.DrawTexturedRectRotated(w / 2, h / 2, w, w, 0)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	function but:DoClick()
		zbf.ATM.MainMenu()
	end

	main:aphone_RemoveCursor()
end
function APP:Open2D(main, main_x, main_y)
    self:Open(main, main_x, main_y, true)
end
aphone.RegisterApp(APP)
