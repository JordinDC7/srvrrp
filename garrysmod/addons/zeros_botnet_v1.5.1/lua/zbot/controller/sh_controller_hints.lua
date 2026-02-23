/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*

    The Hint System displays hints on the minimap, pretty simple
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

/*
	Just in case they dont update their config
*/
function zbf.Controller.GetHintLifetime()
	local lifetime = 120
	if zbf.config.Controller.ip_hints and zbf.config.Controller.ip_hints.lifetime then
		lifetime = zbf.config.Controller.ip_hints.lifetime
	end
	return lifetime
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

if SERVER then
	function zbf.Controller.AddHints(Controller)

		// Find a IP which is not known to this controller and add it as a hint to the IP Map + 2 False hints
		local FoundIP
		for ip,ent in pairs(zbf.Controller.IPs) do
			// If we already know about this IP then skip
			if Controller.IPCache[ip] then continue end

			if not IsValid(ent) then continue end

			FoundIP = ip
			break
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

		if FoundIP then
			if Controller.IPHints == nil then Controller.IPHints = {} end

			local function AddHint(ip)
				Controller.IPHints[ ip ] = math.Round(CurTime())
			end

			AddHint(FoundIP)
			for i = 1, zbf.config.Controller.ip_hints.fake do
				AddHint(math.random(zbf.config.Controller.ip_size))
			end
		end
	end

	concommand.Add("zbf.Controller.AddHints", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()
			if tr and IsValid(tr.Entity) and tr.Entity:GetClass() == "zbf_controller" then
				zbf.Controller.AddHints(tr.Entity)
			end
		end
	end)

	util.AddNetworkString("zbf_Controller_UpdateHints")
	function zbf.Controller.UpdateHints(Controller,ply)
		if Controller.IPHints == nil then Controller.IPHints = {} end

		// Clean up any hints which time has run out
		local clean = {}
		for ip,time in pairs(Controller.IPHints) do
			if not time then continue end
			if Controller.IPCache[ip] then continue end
			if CurTime() < (time + zbf.Controller.GetHintLifetime()) then
				clean[ip] = time
			end
		end
		Controller.IPHints = clean

		// Update the player about which IP hints the controller has
		net.Start("zbf_Controller_UpdateHints")
		net.WriteEntity(Controller)
		net.WriteUInt(table.Count(Controller.IPHints),20)
		for ip,time in pairs(Controller.IPHints) do
			net.WriteUInt(ip,32)
			net.WriteUInt(time,32)
		end
		net.Send(ply)
	end
else
	net.Receive("zbf_Controller_UpdateHints", function(len,ply)
	    zclib.Debug_Net("zbf_Controller_UpdateHints", len)
	    local Controller = net.ReadEntity()
	    if not IsValid(Controller) then return end

		Controller.IPHints = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

		local count = net.ReadUInt(20)
		for i = 1, count do
			Controller.IPHints[ net.ReadUInt(32) ] = net.ReadUInt(32)
		end
	end)
end
