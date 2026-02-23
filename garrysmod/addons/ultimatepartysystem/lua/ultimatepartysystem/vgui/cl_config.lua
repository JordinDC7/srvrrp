function UltimatePartySystem.UI.Config()
    if(!UltimatePartySystem.Config.ConfigGroups[LocalPlayer():GetUserGroup()] && !UltimatePartySystem.Config.ConfigGroups[ply:SteamID()]) then return end

    local updatedValues = {}

    local frame = vgui.Create("ultimatepartysystem.frame")
    frame:SetSize(ScrW() * 0.6, ScrH() * 0.6)
    frame:Center()
    frame:MakePopup()
    frame:SetTopBarTitle(UltimatePartySystem.Core.GetLanguage("configWindowTitle"))
    frame:SetTopBarHeight(frame:GetTall() * 0.067)
    frame.closeButton.DoClick = function()
        -- Save
        net.Start("ultimatepartysystem.settings.saveconfig")
        net.WriteTable(updatedValues)
        net.SendToServer()

        frame:Remove()
        UltimatePartySystem.UI.OpenMainWindow()
    end

    local sideScroll = vgui.Create("ultimatepartysystem.sideselect", frame)
    sideScroll:Dock(LEFT)
    sideScroll:SetWide(frame:GetWide() * 0.2)

    local mainScroll = vgui.Create("ultimatepartysystem.scrollpanel", frame)
    mainScroll:Dock(FILL)

    for k,v in pairs(UltimatePartySystem.ConfigDisplay) do
        sideScroll:AddTab(k, function()
            mainScroll:Clear()

            for x,y in ipairs(v) do
                local panel = vgui.Create("DPanel", mainScroll)
                panel:Dock(TOP)
                panel:DockMargin(0, 0, 0, 5)

                if(y.type == "string") then
                    panel:SetHeight(frame:GetTall() * 0.15)
                    panel.Paint = function(s, w, h)
                        draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                        draw.SimpleText(y.name, "ultimatepartysystem.scaled.10", 10, 10, color_white)
                        draw.SimpleText(y.description, "ultimatepartysystem.scaled.7", 10, h * 0.375, color_white)
                    end

                    local txt = vgui.Create("ultimatepartysystem.textentry", panel)
                    txt:Dock(BOTTOM)
                    txt:SetTall(panel:GetTall() * 0.25)
                    txt:DockMargin(10, 10, 10, 10)
                    txt:SetText(UltimatePartySystem.Settings.GetValue(y.key))
                    txt.OnChange = function()
                        updatedValues[y.key] = txt:GetValue()
                    end

                    continue
                end
                if(y.type == "number") then
                    panel:SetHeight(frame:GetTall() * 0.15)
                    panel.Paint = function(s, w, h)
                        draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                        draw.SimpleText(y.name, "ultimatepartysystem.scaled.10", 10, 10, color_white)
                        draw.SimpleText(y.description, "ultimatepartysystem.scaled.7", 10, h * 0.375, color_white)
                    end

                    local txt = vgui.Create("ultimatepartysystem.numberwang", panel)
                    txt:Dock(BOTTOM)
                    txt:SetTall(panel:GetTall() * 0.25)
                    txt:DockMargin(10, 10, 10, 10)
                    txt:SetMin(0)
                    txt:SetText(UltimatePartySystem.Settings.GetValue(y.key))
                    txt:SetNumeric(true)
                    txt.OnChange = function()
                        if(string.Trim(txt:GetText()) == "") then return end
                        if(string.Trim(txt:GetText()) == "-") then return end
                        if(txt:GetText() == nil) then return end

                        updatedValues[y.key] = txt:GetInt()
                    end

                    continue
                end
                if(y.type == "color") then
                    panel:SetHeight(frame:GetTall() * 0.25)
                    panel.Paint = function(s, w, h)
                        draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                        draw.SimpleText(y.name, "ultimatepartysystem.scaled.10", 10, 10, color_white)
                        draw.SimpleText(y.description, "ultimatepartysystem.scaled.7", 10, h * 0.225, color_white)
                    end

                    local pal = vgui.Create("DColorMixer", panel)
                    pal:Dock(BOTTOM)
                    pal:SetTall(panel:GetTall() * 0.55)
                    pal:DockMargin(10, 10, 10, 10)
                    pal:SetColor(UltimatePartySystem.Settings.GetValue(y.key))
                    pal:SetPalette(false)
                    pal.ValueChanged = function() -- I know this returns a table already but it's not in the color metatable. GetColor() is faster than converting it back into a color value. https://wiki.facepunch.com/gmod/DColorMixer:ValueChanged
                        updatedValues[y.key] = pal:GetColor()
                    end

                    continue
                end
                if(y.type == "boolean") then
                    panel:SetHeight(frame:GetTall() * 0.15)
                    panel.Paint = function(s, w, h)
                        draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                        draw.SimpleText(y.name, "ultimatepartysystem.scaled.10", 10, 10, color_white)
                        draw.SimpleText(y.description, "ultimatepartysystem.scaled.7", 10, h * 0.375, color_white)
                    end

                    local switch = vgui.Create("ultimatepartysystem.switch", panel)
                    switch:SetColor(UltimatePartySystem.Settings.GetValue("themeColor"))
                    switch:SetPos(10, panel:GetTall() * 0.65)
                    switch:SetSize(mainScroll:GetWide() * 0.06, panel:GetTall() * 0.25)
                    switch:SetValue(UltimatePartySystem.Settings.GetValue(y.key))
                    switch.OnToggle = function(v)
                        updatedValues[y.key] = v
                    end

                    continue
                end
            end
        end)
    end

    sideScroll:AddTab("Reset Config", function()
        mainScroll:Clear()

        local p = vgui.Create("DPanel", mainScroll)
        p:Dock(TOP)
        p:SetHeight(mainScroll:GetTall())
        p.Paint = function(s, w, h)
            draw.SimpleText(UltimatePartySystem.Core.GetLanguage("configResetHeader"), "ultimatepartysystem.scaled.bold.10", w / 2, h * 0.4, color_white, 1, 1)
            draw.SimpleText(UltimatePartySystem.Core.GetLanguage("configResetSubHeader"), "ultimatepartysystem.scaled.bold.8", w / 2, h * 0.45, UltimatePartySystem.Cache.Colors.LightRed, 1, 1)
        end

        local yes = vgui.Create("ultimatepartysystem.button", p)
        p.PerformLayout = function()
            yes:SetPos(p:GetWide() * 0.25, p:GetTall() * 0.5)
            yes:SetSize(p:GetWide() * 0.5, p:GetTall() * 0.075)
            yes:SetColor(UltimatePartySystem.Cache.Colors.LightRed)
            yes:SetLabel(UltimatePartySystem.Core.GetLanguage("configResetConfirmButton"))
            yes:SetFont("ultimatepartysystem.scaled.bold.8")

            yes.DoClick = function()
                -- you heard the man/woman/other. it's 2020 man, keep up.

                net.Start("ultimatepartysystem.settings.purgeconfig")
                net.SendToServer()

                frame:Remove()
            end
        end
    end)

    sideScroll:SetSelected(1)
end