-- One shared file just cus it makes this all easier to find/edit

if(SERVER) then
    util.AddNetworkString("ultimatepartysystem.radio.clientupdate")
    util.AddNetworkString("ultimatepartysystem.radio.serverupdate")

    hook.Add("PlayerCanHearPlayersVoice", "ultimatepartysystem.core.radio", function(listener, talker)
        -- thats a lot of validation damn
        if(!UltimatePartySystem.Settings.GetValue("radioEnable")) then return end
        if(!listener:UPSIsInParty()) then return end
        if(!talker:UPSIsInParty()) then return end
        if(talker:UPSGetPartyID() != listener:UPSGetPartyID()) then return end
        if(!UltimatePartySystem.Radios[talker:SteamID64()]) then return end
        if(!UltimatePartySystem.Radios[listener:SteamID64()]) then return end

        return true
    end)

    net.Receive("ultimatepartysystem.radio.clientupdate", function(len, ply)
        if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end
        if(!UltimatePartySystem.Settings.GetValue("radioEnable")) then return end

        UltimatePartySystem.Radios[ply:SteamID64()] = net.ReadBool()

        local party = ply:UPSGetPartyTable()
        for k,v in pairs(party.players) do
            net.Start("ultimatepartysystem.radio.serverupdate")
            net.WriteEntity(ply)
            net.WriteBool(UltimatePartySystem.Radios[ply:SteamID64()])
            net.Send(v)
        end
    end)
end

if(CLIENT) then
    -- UPS.Radios[LocalPlayer():SteamID64()] = false

    concommand.Add("ups_radio_toggle", function()
        if(!UltimatePartySystem.Settings.GetValue("radioEnable")) then return end
        UltimatePartySystem.Radios[LocalPlayer():SteamID64()] = !UltimatePartySystem.Radios[LocalPlayer():SteamID64()]

        net.Start("ultimatepartysystem.radio.clientupdate")
        net.WriteBool(UltimatePartySystem.Radios[LocalPlayer():SteamID64()])
        net.SendToServer()
    end, function() end, "Toggles your party's radio.")

    net.Receive("ultimatepartysystem.radio.serverupdate", function()
        if(!UltimatePartySystem.Settings.GetValue("radioEnable")) then return end
        UltimatePartySystem.Radios[net.ReadEntity():SteamID64()] = net.ReadBool()
    end)
end