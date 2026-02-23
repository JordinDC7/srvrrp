/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Sign = zbf.Sign or {}

/*

	The Crypto Sign displays the selected currencies history data

*/
function zbf.Sign.Initialize(Sign)
	Sign:SetModel(Sign.Model)
	Sign:PhysicsInit(SOLID_VPHYSICS)
	Sign:SetSolid(SOLID_VPHYSICS)
	Sign:SetMoveType(MOVETYPE_VPHYSICS)
	Sign:SetUseType(SIMPLE_USE)
	//Sign:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phy = Sign:GetPhysicsObject()
	if IsValid(phy) then
		phy:Wake()
		phy:EnableMotion(false)
	end
end

/*
	Open interface to let the user select which currencie he wants
*/
function zbf.Sign.OnUse(Sign,ply)
	zbf.Sign.Open(Sign,ply)
end

util.AddNetworkString("zbf_Sign_Open")
function zbf.Sign.Open(Sign,ply)
	if not zclib.Player.IsAdmin(ply) then return end
	net.Start("zbf_Sign_Open")
	net.WriteEntity(Sign)
	net.Send(ply)
end

/*
	Called from the client to change the displayed currency
*/
util.AddNetworkString("zbf_Sign_Set")
net.Receive("zbf_Sign_Set", function(len, ply)
	zclib.Debug_Net("zbf_Sign_Set", len)
	//if zclib.Player.Timeout(nil, ply) then return end

	if not zclib.Player.IsAdmin(ply) then return end

	local c_type = net.ReadUInt(32)
	local Sign = net.ReadEntity()

	//print("zbf_Sign_Set "..tostring(c_type).." "..tostring(Sign))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	if not IsValid(Sign) then return end
	if c_type == nil then return end

	Sign:SetCurrencyID(c_type or 0)
end)

util.AddNetworkString("zbf_Sign_Scale")
net.Receive("zbf_Sign_Scale", function(len, ply)
	zclib.Debug_Net("zbf_Sign_Scale", len)
	if zclib.Player.Timeout(nil, ply) then return end

	if not zclib.Player.IsAdmin(ply) then return end

	local scale = net.ReadFloat()
	local Sign = net.ReadEntity()
	if not IsValid(Sign) then return end
	if scale == nil then return end
	Sign:SetUIScale(scale)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

/*
	Saves the Signs to the Map and loads it after restart / cleanup
*/
file.CreateDir("zbf")
zclib.STM.Setup("zbf_infosign", "zbf/" .. string.lower(game.GetMap()) .. "_Signs.txt", function()
	local data = {}

	for k, v in ipairs(ents.FindByClass("zbf_infosign")) do
		if IsValid(v) then

			local c_data = zbf.Currency.Get(v:GetCurrencyID())
			if not c_data then continue end

			table.insert(data, {
				pos = v:GetPos(),
				ang = v:GetAngles(),
				currency_short = c_data.short,
				scale = v:GetUIScale()
			})
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	return data
end, function(data)
	for k, v in pairs(data) do
		local ent = ents.Create("zbf_infosign")
		if not IsValid(ent) then continue end
		ent:SetPos(v.pos)
		ent:SetAngles(v.ang)
		ent:Spawn()
		ent:Activate()
		ent:SetCurrencyID(zbf.Currency.GetID(v.currency_short) or 0)
		ent:SetUIScale(v.scale)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

	zbf.Print("Finished loading Signs!")
end, function()
	for k, v in pairs(ents.FindByClass("zbf_infosign")) do
		if IsValid(v) then
			v:Remove()
		end
	end
end)

concommand.Add("zbf_infosign_save", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		zclib.STM.Save("zbf_infosign")
		zclib.Notify(ply, "Signs saved for " .. string.lower(game.GetMap()) .. "!", 0)
	end
end)

concommand.Add("zbf_infosign_remove", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		zclib.STM.Remove("zbf_infosign")
		zclib.Notify(ply, "Removed all Signs!", 0)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
