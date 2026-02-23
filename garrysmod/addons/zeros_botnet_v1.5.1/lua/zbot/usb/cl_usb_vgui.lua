/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.USB = zbf.USB or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

local USBEntity

net.Receive("zbf_USB_Open", function(len)
	zclib.Debug_Net("zbf_USB_Open", len)

	USBEntity = net.ReadEntity()

	zbf.USB.Open()
end)

/*
	Here we display all the diffrent currencys which are currently inside the usb
*/
function zbf.USB.Open()
	if USBEntity.zbf_Wallet == nil then USBEntity.zbf_Wallet = {} end
	if table.Count(USBEntity.zbf_Wallet or {}) <= 0 then
		if IsValid(zclib_main_panel) then zclib_main_panel:Close() end
		return
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	local owner = zclib.Player.GetOwner(USBEntity)
	local ownerName = ""
	if owner then ownerName = string.Replace(zbf.language["OwnerS"],"$PLAYENAME",zclib.Player.GetName(owner)) end

	zclib.vgui.Page(ownerName .. zbf.language[ "HardwareWallet" ], function(main, top)
		main:SetSize(1200 * zclib.wM, 800 * zclib.hM)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		local oldPaint = main.Paint
		main.Paint = function(s,w,h)
			if not IsValid(USBEntity) then main:Remove() end
			oldPaint(s,w,h)
		end

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			main:Close()
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors[ "red01" ]

		zbf.vgui.AddTopSepeartor(top)

		zbf.USB.Rebuild(main)
	end)
end

function zbf.USB.Rebuild(window)
	zbf.vgui.CurrencyList(window, USBEntity.zbf_Wallet, true, function(itm,id,IsEmpty)
		if IsEmpty then return end

		zbf.vgui.TextButton(itm, zbf.language[ "Transfer To Vault >" ], zclib.GetFont("zclib_font_small"), zclib.colors[ "blue02" ], function()
			net.Start("zbf_Wallet_SendToVault")
			net.WriteEntity(USBEntity)
			net.WriteUInt(id,8)
			net.SendToServer()
		end)
	end)
end

zclib.Hook.Add("zbf_Wallet_OnCurrencyUpdated", "zbf_Wallet_OnCurrencyUpdated_usb", function(ent, wallet)
	if IsValid(USBEntity) and USBEntity == ent and IsValid(zclib_main_panel) then
		if table.Count(zbf.Wallet.Get(USBEntity)) <= 0 then
			zclib_main_panel:Remove()
		else
			zbf.USB.Rebuild(zclib_main_panel)
		end
	end
end)
