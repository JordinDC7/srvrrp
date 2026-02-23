/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

local ITEM = BRICKS_SERVER.Func.CreateItemType("zbf_usb")

ITEM.GetItemData = function(ent)
    if (not IsValid(ent)) then return end
    local itemData = {"zbf_usb", "models/zerochain/props_clickfarm/zcf_usb.mdl",zbf.Wallet.ConvertToShort(ent.zbf_Wallet or {})}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

    return itemData, 1
end

ITEM.OnSpawn = function(ply, pos, itemData, itemAmount)
	local wallet = itemData[3]
    local ent = ents.Create("zbf_usb")
    if not IsValid(ent) then return end
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
    zclib.Player.SetOwner(ent, ply)
	for k,v in pairs(zbf.Wallet.ConvertToID(wallet)) do zbf.Wallet.SetCurrency(ent,k,v) end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

ITEM.GetInfo = function(itemData)
    return {"Hardware Wallet", "Stores crypto currencies.", ""}
end


ITEM.ModelDisplay = function(Panel, itemtable)
    if (not Panel.Entity or not IsValid(Panel.Entity)) then return end
    local mn, mx = Panel.Entity:GetRenderBounds()
    local size = 0
    size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
    size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
    size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
    Panel:SetFOV(20)
    Panel:SetCamPos(Vector(size, size * 3, size * 2))
    Panel:SetLookAt((mn + mx) * 0.5)
    Panel.Entity:SetAngles(Angle(0, -45, 0))
end


ITEM.CanCombine = function(itemData1, itemData2) return false end
ITEM:Register()

if BRICKS_SERVER and BRICKS_SERVER.CONFIG and BRICKS_SERVER.CONFIG.INVENTORY and BRICKS_SERVER.CONFIG.INVENTORY.Whitelist then
    BRICKS_SERVER.CONFIG.INVENTORY.Whitelist["zbf_usb"] = {false, true}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d
