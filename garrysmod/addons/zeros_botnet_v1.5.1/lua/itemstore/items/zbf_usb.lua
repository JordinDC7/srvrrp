/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

ITEM.Name = "Hardware Wallet"
ITEM.Description = "Stores crypto currencies."
ITEM.Model = "models/zerochain/props_clickfarm/zcf_usb.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:SaveData(ent)
	self:SetData("Wallet", zbf.Wallet.ConvertToShort(ent.zbf_Wallet or {}))
end

function ITEM:LoadData(ent)
	for k,v in pairs(zbf.Wallet.ConvertToID(self:GetData("Wallet"))) do zbf.Wallet.SetCurrency(ent,k,v) end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

function ITEM:CanMerge(item)
	return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

function ITEM:Drop(ply, con, slot, ent)
	zclib.Player.SetOwner(ent, ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d
