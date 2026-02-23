/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.USB = zbf.USB or {}
zbf.USB.List = zbf.USB.List or {}

/*
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

	The hardware USB can be used to store currencys inside a physical object in the world

*/
function zbf.USB.Initialize(USB)
	USB:SetModel("models/zerochain/props_clickfarm/zcf_usb.mdl")
	USB:PhysicsInit(SOLID_VPHYSICS)
	USB:SetSolid(SOLID_VPHYSICS)
	USB:SetMoveType(MOVETYPE_VPHYSICS)
	USB:SetUseType(SIMPLE_USE)
	USB:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	local phy = USB:GetPhysicsObject()
	if IsValid(phy) then
		phy:Wake()
		phy:EnableMotion(true)
	end

	zclib.EntityTracker.Add(USB)

	table.insert(zbf.USB.List,USB)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	USB:PrecacheGibs()

	if zbf.config.Damageable["zbf_usb"] >  0 then
		USB:SetHealth(zbf.config.Damageable["zbf_usb"])
		USB:SetMaxHealth(zbf.config.Damageable["zbf_usb"])
	end

	zbf.Wallet.Setup(USB)
end

/*
	Open interface to let the user select which currencie he wants
*/
function zbf.USB.OnUse(USB,ply)

	zbf.Wallet.UpdateCurrency(USB,ply)

	timer.Simple(0.05, function()
		if not IsValid(ply) then return end
		if not IsValid(USB) then return end
		zbf.USB.Open(USB,ply)
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

/*
	Opens a interface to show all currencys the player currently has stored away
*/
util.AddNetworkString("zbf_USB_Open")
function zbf.USB.Open(USB,ply)
	net.Start("zbf_USB_Open")
	net.WriteEntity(USB)
	net.Send(ply)
end

zclib.Hook.Add("zbf_Wallet_OnCurrencyUpdated", "zbf_Wallet_OnCurrencyUpdated_usb", function(ent, wallet)
	if IsValid(ent) and ent:GetClass() == "zbf_usb" and table.Count(zbf.Wallet.Get(ent)) <= 0 then
		SafeRemoveEntity(ent)
	end
end)

function zbf.USB.OnTakeDamage(USB, dmginfo)
	if zbf.config.Damageable["zbf_usb"] <= 0 then return end
	zclib.Debug("zbf.USB.OnTakeDamage")
	if not IsValid(USB) then return end

	if (not USB.m_bApplyingDamage) then
		USB.m_bApplyingDamage = true
		USB:TakeDamageInfo(dmginfo)
		zbf.USB.Damage(USB, dmginfo:GetDamage())
		USB.m_bApplyingDamage = false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

function zbf.USB.Damage(USB, dmg)
	USB:SetHealth(math.Clamp(USB:Health() - (dmg or 5), 0, USB:GetMaxHealth()))

	zclib.NetEvent.Create("zbf_bot_damage", {USB})

	if USB:Health() <= 0 then
		zbf.USB.Destroy(USB)
	end
end

function zbf.USB.Destroy(USB)
	if USB.Destroyed then return end
	USB.Destroyed = true
	zclib.Entity.SafeRemove(USB)
	zclib.NetEvent.Create("zbf_Controller_destroy", {USB})
end
