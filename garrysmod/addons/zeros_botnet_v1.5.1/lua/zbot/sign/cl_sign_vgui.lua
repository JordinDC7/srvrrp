/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Sign = zbf.Sign or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

local SelectedSign
net.Receive("zbf_Sign_Open", function(len)
	zclib.Debug_Net("zbf_Sign_Open", len)
	SelectedSign = net.ReadEntity()
	if not IsValid(SelectedSign) then return end
	zbf.Sign.MainMenu()
end)

function zbf.Sign.MainMenu()
	zclib.vgui.Page(zbf.language[ "Info Sign" ], function(main, top)
		main:SetSize(1200 * zclib.wM, 800 * zclib.hM)
		top:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		zbf.vgui.AddTopSepeartor(top)

		local slider = zbf.vgui.NumSlider(top, SelectedSign:GetUIScale(), zbf.language[ "Scale" ], function(val)

			if not IsValid(SelectedSign) then return end

			SelectedSign.NewUIScale = val

			zclib.Timer.Remove("zbf_sign_scaler")
			zclib.Timer.Create("zbf_sign_scaler",0.5, 0, function()
				net.Start("zbf_Sign_Scale")
				net.WriteFloat(val)
				net.WriteEntity(SelectedSign)
				net.SendToServer()
			end)
		end, 0.01, 2, 2)
		slider:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		slider:Dock(RIGHT)

		local SaveAll = zbf.vgui.Button(top, zbf.language[ "Save" ], zclib.GetFont("zclib_font_medium"), zbf.colors[ "orange03" ], function(s)
			LocalPlayer():ConCommand("zbf_infosign_save")
		end)
		SaveAll:Dock(RIGHT)
		SaveAll:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		zbf.vgui.CurrencyList(main, {}, false, function(itm,id,IsEmpty)

			itm.PaintOver = function(s,w,h)
				if id == SelectedSign:GetCurrencyID() then
					zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2,zbf.colors[ "orange03" ])
				end
			end

			zbf.vgui.TextButton(itm, zbf.language[ "Select" ], zclib.GetFont("zclib_font_small"), zbf.colors[ "orange03" ], function()

				net.Start("zbf_Sign_Set")
				net.WriteUInt(id,32)
				net.WriteEntity(SelectedSign)
				net.SendToServer()
			end)
		end,function(id)
			return id ~= 1
		end)
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
