hook.Add("HUDPaint", "ultimatepartysystem.marks.drawmarks", function()
    if(!UltimatePartySystem.Settings.GetValue("markerEnable")) then return end
    if(!LocalPlayer():UPSIsInParty()) then return end
    if(!UltimatePartySystem.ClientSettings.GetValue("drawMarkers")) then return end

    for k,v in pairs(UltimatePartySystem.Markers) do
        local pos = v.pos:ToScreen()

        -- draw.RoundedBox(0, pos.x, pos.y, 50, 50, Color(255, 0, 0))
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(UltimatePartySystem.Cache.Materials.Arrow)
        surface.DrawTexturedRect(pos.x - 17.5, pos.y - 20, 35, 35)

        local dist = LocalPlayer():GetShootPos():DistToSqr(v.pos)
        draw.SimpleText(math.floor(dist / 25000) .. "m", "ultimatepartysystem.scaled.bold.10", pos.x, pos.y - 55, color_white, 1, 0) -- Divided by 25000 to move this down to a reasonable value. It should be (roughly) a meter now.
        draw.SimpleText(v.ply:Name(), "ultimatepartysystem.scaled.7", pos.x, pos.y - 34, color_white, 1, 0)
    end
end)

concommand.Add("ups_marker_create", function()
    if(!UltimatePartySystem.Settings.GetValue("markerEnable")) then return end
    if(!LocalPlayer():UPSIsInParty()) then return end

    local pos = LocalPlayer():GetEyeTrace().HitPos

    local new = {
        pos = pos,
        ply = LocalPlayer()
    }
    UltimatePartySystem.Markers[LocalPlayer():SteamID64()] = new

    net.Start("ultimatepartysystem.core.requestmarkerupdate")
    net.WriteTable(new)
    net.WriteBool(true)
    net.SendToServer()
end, function() end, "Creates a new marker where you are looking.")
concommand.Add("ups_marker_clear", function()
    if(!UltimatePartySystem.Settings.GetValue("markerEnable")) then return end
    if(!LocalPlayer():UPSIsInParty()) then return end
    if(!UltimatePartySystem.Markers[LocalPlayer():SteamID64()]) then return end

    net.Start("ultimatepartysystem.core.requestmarkerupdate")
    net.WriteTable(UltimatePartySystem.Markers[LocalPlayer():SteamID64()])
    net.WriteBool(false)
    net.SendToServer()

    UltimatePartySystem.Markers[LocalPlayer():SteamID64()] = nil
end, function() end, "Creates a new marker where you are looking.")

net.Receive("ultimatepartysystem.core.setmarker", function()
    if(!UltimatePartySystem.Settings.GetValue("markerEnable")) then return end
    if(!LocalPlayer():UPSIsInParty()) then return end

    local info = net.ReadTable()
    local state = net.ReadBool()
    if(!state) then
        local all = net.ReadBool() -- just wipe the table
        if(all) then
            UltimatePartySystem.Markers = {}
            return
        end
    end

    -- True = Creating / Updating, False = Removing
    if(state) then
        UltimatePartySystem.Markers[info.ply:SteamID64()] = info
    else
        UltimatePartySystem.Markers[info.ply:SteamID64()] = nil
    end
end)