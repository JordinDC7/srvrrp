-- The in-game HUD for parties.
-- I don't cache any of the colors in here as the player can change the HUD's opacity.
hook.Add("HUDPaint", "ultimatepartysystem.hud.hudpaint", function()
    if(!UltimatePartySystem.ClientSettings.GetValue("drawHUD")) then return end
    if(!LocalPlayer():UPSIsInParty()) then return end


    local party = LocalPlayer():UPSGetPartyTable()

    local baseX = UltimatePartySystem.ClientSettings.GetValue("hudOffsetX")
    local baseY = UltimatePartySystem.ClientSettings.GetValue("hudOffsetY")

    local baseW = ScrW() * 0.1
    local baseH = ScrH() * 0.05

    -- Get all the text sizes into a table and set the maximum length to baseW so it scales. This could be better probably but for now it'll do
    local textSizes = {}
    surface.SetFont("ultimatepartysystem.scaled.bold.10")
    textSizes[#textSizes + 1] = surface.GetTextSize(party.name) + 16 + (ScrH() * 0.03) -- I add this because of the icon.
    -- Take account for players too.
    local players = {}
    surface.SetFont("ultimatepartysystem.scaled.bold.8")
    for k,v in pairs(party.players) do
        if(!v) then continue end
        if(!IsValid(v)) then continue end

        textSizes[#textSizes + 1] = surface.GetTextSize(v:Name()) + (ScrH() * 0.02) + 17
        baseH = baseH + (ScrH() * 0.02) + 1 -- height
    end

    for k,v in pairs(textSizes) do
        if(baseW > v) then continue end
        baseW = v + 10
    end

    -- The actual HUD
    draw.RoundedBox(0, baseX, baseY, baseW, baseH, Color(20, 20, 20, UltimatePartySystem.ClientSettings.GetValue("hudOpaque")))

    -- Title bar
    draw.RoundedBox(0, baseX, baseY, baseW, ScrH() * 0.04, Color(35, 35, 35, UltimatePartySystem.ClientSettings.GetValue("hudOpaque")))

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(UltimatePartySystem.Cache.Materials.GroupIcon)
    surface.DrawTexturedRect((baseX + 5) + (ScrH() * 0.005), (baseY) + (ScrH() * 0.005), ScrH() * 0.03, ScrH() * 0.03)

    draw.SimpleText(party.name, "ultimatepartysystem.scaled.bold.10", baseX + (ScrH() * 0.04) + 5, baseY + (ScrH() * 0.04) / 2, color_white, 0, 1)


    -- Players
    local plyH = baseY + (ScrH() * 0.04) + 15
    for k,v in pairs(party.players) do
        if(!v) then continue end
        if(!IsValid(v)) then continue end

        surface.SetDrawColor(255, 255, 255, 255)
        local mat = UltimatePartySystem.Cache.Materials.Microphone
        if(!UltimatePartySystem.Radios[v:SteamID64()]) then
            mat = UltimatePartySystem.Cache.Materials.MutedMicrophone
        end
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(baseX + 8, (plyH - (ScrH() * 0.02)) + 11, ScrH() * 0.02, ScrH() * 0.02)

        draw.SimpleText(v:Name(), "ultimatepartysystem.scaled.bold.8", baseX + (ScrH() * 0.025) + 10, plyH, color_white, 0, 1)
        plyH = plyH + (ScrH() * 0.02)
    end
end)