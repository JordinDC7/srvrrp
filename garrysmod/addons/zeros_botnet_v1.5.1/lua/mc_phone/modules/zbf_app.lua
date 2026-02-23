/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/


local module_id = #McPhone.Modules + 1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

McPhone.Modules[module_id] = {}

McPhone.Modules[module_id].name = "Crypto Point"

McPhone.Modules[module_id].icon = "zerochain/zbot/zbf_mcphone_app_icon.png"

McPhone.Modules[module_id].openMenu = function()

	if !McPhone.UI or !McPhone.UI.Menu then return end

	local m_list
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

	function m_list()
		McPhone.UI.Menu:Clear()
		McPhone.UI.Menu:SetPos( 20, 140 )
		McPhone.UI.Menu:SetSize( 270, 256 )
		McPhone.UI.Menu.List = true
		McPhone.UI.Menu:EnableHorizontal( true )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		local frame = vgui.Create( "DPanel" )
		frame:SetSize( 256, 256 )
		frame:SetDisabled( true )
		frame.Paint = function(self, w, h)
			draw.RoundedBox(1, 0, 0, w, h, zclib.colors["ui01"])

			surface.SetDrawColor(zclib.colors[ "white_a100" ])
			surface.SetMaterial(zclib.Materials.Get("zbf_cryptopoint"))
			surface.DrawTexturedRectRotated(w / 2, h / 2, 256, 256, 0)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

		timer.Simple(0, function() frame:SetDisabled( false ) end)

		McPhone.UI.Menu:AddItem(frame)
		McPhone.UI.Buttons.Left = {nil,nil,nil}
		McPhone.UI.Buttons.Middle = {"mc_phone/icons/buttons/id4.png",McPhone.MainColors["green"], function()
			zbf.ATM.MainMenu()
		end}
		McPhone.UI.Buttons.Right = {"mc_phone/icons/buttons/id15.png",McPhone.MainColors["red"], nil}
	end
	m_list()
end
