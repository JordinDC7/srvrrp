/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_clickfarm/zcf_usb.mdl")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
    zclib.Player.SetOwner(ent, ply)
	for k,v in pairs(zbf.Wallet.ConvertToID(tbl.data)) do zbf.Wallet.SetCurrency(ent,k,v) end
end)

function ITEM:GetData(ent)
	return zbf.Wallet.ConvertToShort(ent.zbf_Wallet or {})
end

function ITEM:GetName(item)
	return "Hardware Wallet"
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

ITEM:SetDescription(function(self, tbl)
    local desc = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	for k,v in pairs(zbf.Wallet.ConvertToID(tbl.data)) do
		//table.insert(desc,zbf.Currency.GetName(k) .. " " .. math.Round(v,zbf.Currency.GetPrecision(k)))
		table.insert(desc,math.Round(v,zbf.Currency.GetPrecision(k)) .. " " .. zbf.Currency.GetShort(k))
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

    return desc
end)

function ITEM:GetDisplayName(item)
    return self:GetName(item)
end

function ITEM:GetCameraModifiers(tbl)
    return {
        FOV = 30,
        X = 0,
        Y = 0,
        Z = 50,
        Angles = Angle(0, 45, 0),
        Pos = Vector(0, 0, 0)
    }
end

ITEM:Register("zbf_usb")
