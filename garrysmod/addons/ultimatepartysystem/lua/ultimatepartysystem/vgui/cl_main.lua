function UltimatePartySystem.UI.OpenMainWindow()
    local frame = vgui.Create("ultimatepartysystem.frame")
    frame:SetSize(ScrH() * 0.55, ScrH() * 0.7) -- I use ScrH() on both the width and height so it scales properly between aspect ratios. If I didn't it would begin stretching and look all skinny and weird.
    frame:Center()
    frame:MakePopup()
    frame:RemoveCloseButton()
    frame:SetTopBarTitle(UltimatePartySystem.Core.GetLanguage("primaryWindowTitle"))
    frame:SetTopBarHeight(frame:GetTall() * 0.055)

    if(UltimatePartySystem.Config.ConfigGroups[LocalPlayer():GetUserGroup()] || UltimatePartySystem.Config.ConfigGroups[LocalPlayer():SteamID()]) then -- I check this serverside too so don't shit yourself
        local btn = vgui.Create("DButton", frame.topPanel)
        btn:Dock(RIGHT)
        btn:SetSize(frame.topPanel:GetTall(), frame.topPanel:GetTall())
        btn:SetText("")
        btn.Paint = function(s, w, h)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(UltimatePartySystem.Cache.Materials.Wrench)
            surface.DrawTexturedRect((h / 3) / 2, (h / 3) / 2, h / 1.5, h / 1.5)
        end
        btn.DoClick = function()
            frame:Remove()
            UltimatePartySystem.UI.Config()
        end
    end

    local cancel = vgui.Create("ultimatepartysystem.button", frame)
    cancel:SetLabel(UltimatePartySystem.Core.GetLanguage("cancelButton"))
    cancel:SetColor(UltimatePartySystem.Cache.Colors.LightRed)
    cancel:Dock(BOTTOM)
    cancel:SetHeight(frame:GetTall() * 0.07)
    cancel:SetMaterial(UltimatePartySystem.Cache.Materials.Cross, 2.5, 2)
    cancel.DoClick = function()
        frame:Remove()
    end

    local top = vgui.Create("ultimatepartysystem.tabselect", frame)
    top:Dock(TOP)
    top:SetHeight(frame:GetTall() * 0.06)

    local scroll = vgui.Create("ultimatepartysystem.scrollpanel", frame)
    scroll:Dock(FILL)

    top:AddTab(UltimatePartySystem.Core.GetLanguage("primaryWindowViewPartiesTab"), function()
        scroll:Clear()
        local theresNoParties = true

        -- Invites first
        for k,v in pairs(UltimatePartySystem.Invites) do
            theresNoParties = false

            local ownerName = player.GetBySteamID64(k):Name()
            if(!ownerName) then continue end

            local panel = vgui.Create("DPanel", scroll)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 5)
            panel:SetHeight(frame:GetTall() * 0.15)
            panel.Paint = function(s, w, h)
                draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                if(v.timeout < CurTime()) then
                    panel:Remove()
                    return
                end
                draw.SimpleText(v.party.name .. " (" .. math.floor(v.timeout - CurTime()) .. "s)", "ultimatepartysystem.scaled.bold.9", 11, 10, color_white)
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartyOwnedBy", ownerName), "ultimatepartysystem.scaled.7", 10, h * 0.325, color_white)

                -- Slots
                -- I'm using table.Count since I index steamid64's
                draw.RoundedBox(0, 10, h * 0.65, w - 20, h * 0.265, UltimatePartySystem.Cache.Colors.SlightlyDarkerGray)
                draw.RoundedBox(0, 10, h * 0.65, (w - 20) * (table.Count(v.party.players) / v.party.slots), h * 0.265, UltimatePartySystem.Settings.GetValue("themeColor"))
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartySlots", table.Count(v.party.players), v.party.slots), "ultimatepartysystem.scaled.7", w / 2, h * 0.77, color_white, 1, 1)
            end

            local join = vgui.Create("ultimatepartysystem.button", panel)
            join:SetLabel(UltimatePartySystem.Core.GetLanguage("viewPartyAcceptInvite"))
            join:SetFont("ultimatepartysystem.scaled.bold.7")
            panel.PerformLayout = function()
                join:SetPos(panel:GetWide() * 0.7, panel:GetTall() * 0.16)
                join:SetSize(panel:GetWide() - (panel:GetWide() * 0.7) - 10, panel:GetTall() * 0.3)
            end
            join.DoClick = function()
                frame:Remove()

                net.Start("ultimatepartysystem.core.acceptinvite")
                net.WriteString(k)
                net.SendToServer()

                UltimatePartySystem.Invites[k] = nil
            end
        end

        local delayedParties = {} -- These are parties that don't have any available slots and are displayed AFTER the parties that do have slots.
        for k,v in pairs(UltimatePartySystem.Parties) do
            if(k == LocalPlayer():SteamID64()) then continue end
            if(#v.players >= v.slots) then
                delayedParties[k] = v
                continue
            end

            local ownerName = player.GetBySteamID64(k):Name()
            if(!ownerName) then continue end

            theresNoParties = false

            local panel = vgui.Create("DPanel", scroll)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 5)
            panel:SetHeight(frame:GetTall() * 0.15)
            panel.Paint = function(s, w, h)
                draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                draw.SimpleText(v.name, "ultimatepartysystem.scaled.bold.9", 11, 10, color_white)
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartyOwnedBy", ownerName), "ultimatepartysystem.scaled.7", 10, h * 0.325, color_white)

                if(LocalPlayer():UPSIsInParty()) then
                    draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartyInside"), "ultimatepartysystem.scaled.7", w - 10, h * 0.325, UltimatePartySystem.Cache.Colors.ImRunningOutOfFunnyVarNames, 2, 0)
                end

                -- Slots
                -- I'm using table.Count since I index steamid64's
                draw.RoundedBox(0, 10, h * 0.65, w - 20, h * 0.265, UltimatePartySystem.Cache.Colors.SlightlyDarkerGray)
                draw.RoundedBox(0, 10, h * 0.65, (w - 20) * (table.Count(v.players) / v.slots), h * 0.265, UltimatePartySystem.Settings.GetValue("themeColor"))
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartySlots", table.Count(v.players), v.slots), "ultimatepartysystem.scaled.7", w / 2, h * 0.77, color_white, 1, 1)
            end

            if(!LocalPlayer():UPSIsInParty()) then
                local join = vgui.Create("ultimatepartysystem.button", panel)
                join:SetLabel(UltimatePartySystem.Core.GetLanguage("viewPartyJoin"))
                join:SetFont("ultimatepartysystem.scaled.bold.7")
                panel.PerformLayout = function()
                    join:SetPos(panel:GetWide() * 0.7, panel:GetTall() * 0.16)
                    join:SetSize(panel:GetWide() - (panel:GetWide() * 0.7) - 10, panel:GetTall() * 0.3)
                end
                join.DoClick = function()
                    frame:Remove()

                    net.Start("ultimatepartysystem.core.joinparty")
                    net.WriteString(k)
                    net.SendToServer()
                end
            end
        end

        -- Now do the delayed parties.
        for k,v in pairs(delayedParties) do
            if(k == LocalPlayer():SteamID64()) then continue end

            local ownerName = player.GetBySteamID64(k):Name()
            if(!ownerName) then continue end

            theresNoParties = false

            local panel = vgui.Create("DPanel", scroll)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 5)
            panel:SetHeight(frame:GetTall() * 0.15)
            panel.Paint = function(s, w, h)
                draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                draw.SimpleText(v.name, "ultimatepartysystem.scaled.bold.9", 11, 10, color_white)
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartyOwnedBy", ownerName), "ultimatepartysystem.scaled.7", 10, h * 0.325, UltimatePartySystem.Cache.Colors.ImRunningOutOfFunnyVarNames)

                -- Slots
                draw.RoundedBox(0, 10, h * 0.65, w - 20, h * 0.265, UltimatePartySystem.Cache.Colors.SlightlyDarkerGray)
                draw.RoundedBox(0, 10, h * 0.65, w - 20, h * 0.265, UltimatePartySystem.Settings.GetValue("themeColor"))
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartySlots", table.Count(v.players), table.Count(v.slots)), "ultimatepartysystem.scaled.7", w / 2, h * 0.77, color_white, 1, 1)
            end
        end

        if(theresNoParties) then
            local display = vgui.Create("DPanel", scroll)
            display:Dock(TOP)
            display:SetHeight(frame:GetTall() * 0.8)
            display.Paint = function(s, w, h)
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("thereIsNoPartyTakeOffYourClothes"), "ultimatepartysystem.scaled.10", w / 2, h / 2, color_white, 1, 1)
            end
        end
    end)
    if(LocalPlayer():UPSIsInParty()) then
        top:AddTab(UltimatePartySystem.Core.GetLanguage("primaryWindowViewPartyTab"), function()
            scroll:Clear()

            local party = LocalPlayer():UPSGetPartyTable()
            if(!party) then return end
            local owner = player.GetBySteamID64(LocalPlayer():UPSGetPartyID())

            local top = vgui.Create("DPanel", scroll)
            top:Dock(TOP)
            top:SetHeight(scroll:GetTall() * 0.175)
            top.Paint = function(s, w, h)
                draw.SimpleText(party.name, "ultimatepartysystem.scaled.bold.10", 11, 10, color_white, 0, 0)
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartyOwnedBy", owner:Name()), "ultimatepartysystem.scaled.7", 10, h * 0.325, UltimatePartySystem.Cache.Colors.ImRunningOutOfFunnyVarNames, 0, 0)

                -- Slots
                draw.RoundedBox(0, 10, h * 0.65, w - 20, h * 0.265, UltimatePartySystem.Cache.Colors.FiftyShadesOfGray)
                draw.RoundedBox(0, 10, h * 0.65, (w - 20) * (table.Count(party.players) / party.slots), h * 0.265, UltimatePartySystem.Settings.GetValue("themeColor"))
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartySlots", table.Count(party.players), party.slots), "ultimatepartysystem.scaled.7", w / 2, h * 0.77, color_white, 1, 1)
            end

            if(owner != LocalPlayer()) then
                local leave = vgui.Create("ultimatepartysystem.button", top)
                leave:SetPos(frame:GetWide() * 0.7825, 15)
                leave:SetSize(frame:GetWide() * 0.2, top:GetTall() * 0.35)
                leave:SetLabel(UltimatePartySystem.Core.GetLanguage("viewPartyLeave"))
                leave:SetFont("ultimatepartysystem.scaled.bold.8")
                leave:SetColor(UltimatePartySystem.Cache.Colors.LightRed)
                leave.DoClick = function()
                    frame:Remove()

                    net.Start("ultimatepartysystem.core.leaveparty")
                    net.SendToServer()
                end
            end

            local playerListHeight = scroll:GetTall() * 0.825
            if(owner == LocalPlayer()) then
                local ownerSettings = vgui.Create("DPanel", scroll)
                ownerSettings:Dock(TOP)
                ownerSettings:SetHeight(scroll:GetTall() * 0.3)
                ownerSettings.Paint = function(s, w, h)
                    draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartyEditHeader"), "ultimatepartysystem.scaled.bold.9", 10, 5, color_white, 0, 0)

                    if(UltimatePartySystem.Settings.GetValue("allowPrivateParties")) then
                        draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartyEditPrivate"), "ultimatepartysystem.scaled.8", 10, h * 0.4, color_white, 0, 0)
                        draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartyEditSlots"), "ultimatepartysystem.scaled.8", w * 0.3, h * 0.4, color_white, 0, 0)
                    else
                        draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartyEditSlots"), "ultimatepartysystem.scaled.8", 10, h * 0.4, color_white, 0, 0)
                    end
                end

                -- Name, Private, Slots
                local name = vgui.Create("ultimatepartysystem.textentry", ownerSettings)
                name:SetPos(10, ownerSettings:GetTall() * 0.2)
                name:SetSize(frame:GetWide() - 20, ownerSettings:GetTall() * 0.15)
                name:SetMaxCharacters(UltimatePartySystem.Settings.GetValue("maxNameLength"))
                name:SetValue(party.name)

                local private = nil
                if(UltimatePartySystem.Settings.GetValue("allowPrivateParties")) then
                    private = vgui.Create("ultimatepartysystem.switch", ownerSettings)
                    private:SetColor(UltimatePartySystem.Settings.GetValue("themeColor"))
                    private:SetPos(10, ownerSettings:GetTall() * 0.55)
                    private:SetSize(frame:GetWide() * 0.1, ownerSettings:GetTall() * 0.15)
                    private:SetValue(party.private)
                end

                local slots = vgui.Create("ultimatepartysystem.numberwang", ownerSettings)
                slots:SetMin(2)
                slots:SetMax(UltimatePartySystem.Settings.GetValue("maxSlots"))
                slots:SetValue(party.slots)
                slots:SetPos(frame:GetWide() * 0.3, ownerSettings:GetTall() * 0.55)
                slots:SetSize(frame:GetWide() * 0.684, ownerSettings:GetTall() * 0.15)
                if(!UltimatePartySystem.Settings.GetValue("allowPrivateParties")) then
                    slots:SetPos(10, ownerSettings:GetTall() * 0.55)
                    slots:SetSize(frame:GetWide() - 20, ownerSettings:GetTall() * 0.15)
                end

                local save = vgui.Create("ultimatepartysystem.button", ownerSettings)
                save:SetPos(10, ownerSettings:GetTall() * 0.775)
                save:SetSize((frame:GetWide() - 30) / 2, ownerSettings:GetTall() * 0.225)
                save:SetLabel(UltimatePartySystem.Core.GetLanguage("viewPartyEditSaveButton"))
                save.DoClick = function()
                    frame:Remove()

                    net.Start("ultimatepartysystem.core.updateparty")
                    net.WriteString(name:GetValue())
                    if(UltimatePartySystem.Settings.GetValue("allowPrivateParties")) then
                        net.WriteBool(private:GetValue())
                    end
                    net.WriteInt(slots:GetValue(), 9)
                    net.SendToServer()
                end

                local delete = vgui.Create("ultimatepartysystem.button", ownerSettings)
                delete:SetPos((frame:GetWide() / 2) + 6, ownerSettings:GetTall() * 0.775)
                delete:SetSize((frame:GetWide() - 30) / 2, ownerSettings:GetTall() * 0.225)
                delete:SetLabel(UltimatePartySystem.Core.GetLanguage("viewPartyEditDeleteButton"))
                delete:SetColor(UltimatePartySystem.Cache.Colors.LightRed)
                delete.DoClick = function()
                    frame:Remove()

                    UltimatePartySystem.UI.DeletePartyConfirmation()
                end

                playerListHeight = scroll:GetTall() * 0.525
            end

            local playerList = vgui.Create("DPanel", scroll)
            playerList:Dock(TOP)
            playerList:SetHeight(playerListHeight)
            playerList.Paint = function(s, w, h)
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("viewPartyPlayerListHeader"), "ultimatepartysystem.scaled.bold.9", 10, 10, color_white, 0, 0)
            end

            if(owner == LocalPlayer()) then
                local invite = vgui.Create("ultimatepartysystem.button", playerList)
                invite:SetPos(frame:GetWide() * 0.7085, 10)
                invite:SetSize(frame:GetWide() * 0.275, 20)
                invite:SetLabel(UltimatePartySystem.Core.GetLanguage("viewPartyPlayerListInvite"))
                invite:SetFont("ultimatepartysystem.scaled.bold.7")
                invite.DoClick = function()
                    frame:Remove()

                    UltimatePartySystem.UI.InviteMenu()
                end
            end

            local scrolliBoi = vgui.Create("ultimatepartysystem.scrollpanel", playerList)
            scrolliBoi:Dock(FILL)
            scrolliBoi:DockMargin(10, playerList:GetTall() * 0.135, 10, 10)
            if(owner != LocalPlayer()) then
                scrolliBoi:DockMargin(10, playerList:GetTall() * 0.1, 10, 10)
            end
            scrolliBoi.Paint = function(s, w, h)
                draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.FiftyShadesOfGray)
            end

            for k,v in pairs(party.players) do
                local plyPan = vgui.Create("DPanel", scrolliBoi)
                plyPan:Dock(TOP)
                plyPan:SetTall(frame:GetTall() * 0.1)
                plyPan:DockMargin(0, 0, 0, 5)
                plyPan.Paint = function(s, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.AnotherFuckingGray)

                    local name = v:Name()
                    if(v == owner) then
                        name = name .. " " .. UltimatePartySystem.Core.GetLanguage("viewPartyPlayerListOwner")
                    end
                    draw.SimpleText(name, "ultimatepartysystem.scaled.9", h + (w * 0.01), h / 2, color_white, 0, 1)
                end

                local avi = vgui.Create("AvatarImage", plyPan)
                avi:SetSize(plyPan:GetTall() - 10, plyPan:GetTall() - 10)
                avi:Dock(LEFT)
                avi:DockMargin(5, 5, 5, 5)
                avi:SetPlayer(v, 128)

                if(owner != LocalPlayer()) then continue end
                if(v == owner) then continue end

                local kick = vgui.Create("DButton", plyPan)
                kick:Dock(RIGHT)
                kick:SetSize(plyPan:GetTall() - 10, plyPan:GetTall() - 10)
                kick:DockMargin(5, 5, 5, 5)
                kick:SetText("")
                kick.Paint = function(s, w, h)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(UltimatePartySystem.Cache.Materials.Cross)
                    surface.DrawTexturedRect(w / 3, h / 3, w / 3, h / 3)
                end
                kick.DoClick = function()
                    frame:Remove()

                    net.Start("ultimatepartysystem.core.kickplayer")
                    net.WriteString(v:SteamID64())
                    net.SendToServer()
                end
            end
        end)
    else
        top:AddTab(UltimatePartySystem.Core.GetLanguage("primaryWindowCreatePartyTab"), function()
            scroll:Clear()

            local namePanel = vgui.Create("DPanel", scroll)
            namePanel:Dock(TOP)
            namePanel:SetHeight(scroll:GetTall() * 0.11)
            namePanel.Paint = function(s, w, h)
                draw.SimpleText(UltimatePartySystem.Core.GetLanguage("createPartyName"), "ultimatepartysystem.scaled.8", 10, 8, color_white)
            end
            local name = vgui.Create("ultimatepartysystem.textentry", namePanel)
            name:Dock(BOTTOM)
            name:SetTall(namePanel:GetTall() * 0.375)
            name:DockMargin(10, 15, 10, 5)
            name:SetMaxCharacters(UltimatePartySystem.Settings.GetValue("maxNameLength"))
            name:SetValue(LocalPlayer():Name() .. "'s cool party!")

            local privacyPanel = vgui.Create("DPanel", scroll)
            privacyPanel:Dock(TOP)
            privacyPanel:SetHeight(scroll:GetTall() * 0.1)
            privacyPanel.Paint = function(s, w, h)
                if(UltimatePartySystem.Settings.GetValue("allowPrivateParties")) then
                    draw.SimpleText(UltimatePartySystem.Core.GetLanguage("createPartyPrivate"), "ultimatepartysystem.scaled.8", 10, 5, color_white)
                    draw.SimpleText(UltimatePartySystem.Core.GetLanguage("createPartySlots"), "ultimatepartysystem.scaled.8", w * 0.25 - 1, 5, color_white)
                else
                    draw.SimpleText(UltimatePartySystem.Core.GetLanguage("createPartySlots"), "ultimatepartysystem.scaled.8", 10 - 1, 5, color_white)
                end
            end

            local slots = vgui.Create("ultimatepartysystem.numberwang", privacyPanel)
            slots:SetMin(2)
            slots:SetMax(UltimatePartySystem.Settings.GetValue("maxSlots"))
            slots:SetValue(UltimatePartySystem.Settings.GetValue("defaultSlots"))
            local private = nil
            if(UltimatePartySystem.Settings.GetValue("allowPrivateParties")) then
                private = vgui.Create("ultimatepartysystem.switch", privacyPanel)
                private:SetColor(UltimatePartySystem.Settings.GetValue("themeColor"))
                private:SetPos(10, privacyPanel:GetTall() * 0.525)
                private:SetSize(scroll:GetWide() * 0.09, privacyPanel:GetTall() * 0.45)
                private:SetValue(false)

                slots:SetPos(scroll:GetWide() * 0.25, privacyPanel:GetTall() * 0.55)
                slots:SetSize(scroll:GetWide() * 0.735, privacyPanel:GetTall() * 0.375)
            else
                slots:SetPos(10, privacyPanel:GetTall() * 0.55)
                slots:SetSize(scroll:GetWide() - 20, privacyPanel:GetTall() * 0.375)
            end


            -- I wrap the button in a panel for padding reasons
            local submitPanel = vgui.Create("DPanel", scroll)
            submitPanel:Dock(TOP)
            submitPanel:DockMargin(0, 10, 0, 0)
            submitPanel:SetHeight(scroll:GetTall() * 0.09)
            submitPanel.Paint = function() end

            local submit = vgui.Create("ultimatepartysystem.button", submitPanel)
            submitPanel.PerformLayout = function()
                submit:Dock(FILL)
                submit:DockMargin(10, 5, 10, 6)
            end
            submit:SetLabel(UltimatePartySystem.Core.GetLanguage("createPartySubmit"))
            if(UltimatePartySystem.Settings.GetValue("partyCreationCost") > 0) then
                submit:SetLabel(UltimatePartySystem.Core.GetLanguage("createPartySubmitCostly", UltimatePartySystem.Core.FormatMoney(UltimatePartySystem.Settings.GetValue("partyCreationCost"))))
            end
            submit.DoClick = function()
                net.Start("ultimatepartysystem.core.createparty")
                net.WriteString(name:GetValue()) -- Name of the party
                if(UltimatePartySystem.Settings.GetValue("allowPrivateParties")) then
                    net.WriteBool(private:GetValue()) -- If it's private
                end
                net.WriteInt(slots:GetInt(), 9) -- Slots it has. 9 bit since I doubt people are going to have over 255 players in a single party.
                net.SendToServer()

                frame:Remove()
            end
        end)
    end
    top:AddTab(UltimatePartySystem.Core.GetLanguage("primaryWindowSettingsTab"), function()
        scroll:Clear()

        for k,v in ipairs(UltimatePartySystem.ClientSettings.ConfigDisplay) do
            local panel = vgui.Create("DPanel", scroll)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 5)

            if(v.type == "string") then
                panel:SetHeight(frame:GetTall() * 0.15)
                panel.Paint = function(s, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                    draw.SimpleText(v.name, "ultimatepartysystem.scaled.10", 9, 10, color_white)
                    draw.SimpleText(v.description, "ultimatepartysystem.scaled.7", 10, h * 0.375, color_white)
                end

                local txt = vgui.Create("ultimatepartysystem.textentry", panel)
                txt:Dock(BOTTOM)
                txt:SetTall(panel:GetTall() * 0.25)
                txt:DockMargin(10, 10, 10, 10)
                txt:SetText(UltimatePartySystem.ClientSettings.GetValue(v.key))
                txt.OnChange = function()
                    UltimatePartySystem.ClientSettings.SetValue(v.key, txt:GetValue())
                end

                continue
            end
            if(v.type == "number") then
                panel:SetHeight(frame:GetTall() * 0.13)
                panel.Paint = function(s, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                    draw.SimpleText(v.name, "ultimatepartysystem.scaled.10", 9, 10, color_white)
                    draw.SimpleText(v.description, "ultimatepartysystem.scaled.7", 10, h * 0.375, color_white)
                end

                local txt = vgui.Create("ultimatepartysystem.numberwang", panel)
                txt:Dock(BOTTOM)
                txt:SetTall(panel:GetTall() * 0.25)
                txt:DockMargin(10, 10, 10, 10)
                txt:SetMin(0)
                txt:SetText(UltimatePartySystem.ClientSettings.GetValue(v.key))
                txt:SetNumeric(true)
                txt.OnChange = function()
                    -- I have to do a ton of validation because of this shit fucking min/max stuff :/
                    if(txt:GetText() == nil) then return end
                    if(string.Trim(txt:GetText()) == "") then return end
                    if(string.Trim(txt:GetText()) == "-") then return end
                    if(string.find(txt:GetText(), "-", 2) != nil) then return end
                    if(txt:GetInt() == nil) then return end

                    UltimatePartySystem.ClientSettings.SetValue(v.key, txt:GetInt())
                end

                continue
            end
            if(v.type == "color") then
                panel:SetHeight(frame:GetTall() * 0.25)
                panel.Paint = function(s, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                    draw.SimpleText(v.name, "ultimatepartysystem.scaled.10", 9, 10, color_white)
                    draw.SimpleText(v.description, "ultimatepartysystem.scaled.7", 10, h * 0.225, color_white)
                end

                local pal = vgui.Create("DColorMixer", panel)
                pal:Dock(BOTTOM)
                pal:SetTall(panel:GetTall() * 0.55)
                pal:DockMargin(10, 10, 10, 10)
                pal:SetColor(UltimatePartySystem.ClientSettings.GetValue(v.key))
                pal:SetPalette(false)
                pal.ValueChanged = function() -- I know this returns a table already but it's not in the color metatable. GetColor() is faster than converting it back into a color value. https://wiki.facepunch.com/gmod/DColorMixer:ValueChanged
                    UltimatePartySystem.ClientSettings.SetValue(v.key, pal:GetColor())
                end

                continue
            end
            if(v.type == "boolean") then
                panel:SetHeight(frame:GetTall() * 0.13)
                panel.Paint = function(s, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray)

                    draw.SimpleText(v.name, "ultimatepartysystem.scaled.10", 9, 10, color_white)
                    draw.SimpleText(v.description, "ultimatepartysystem.scaled.7", 10, h * 0.375, color_white)
                end

                local switch = vgui.Create("ultimatepartysystem.switch", panel)
                switch:SetColor(UltimatePartySystem.Settings.GetValue("themeColor"))
                switch:SetPos(10, panel:GetTall() * 0.65)
                switch:SetSize(scroll:GetWide() * 0.095, panel:GetTall() * 0.26)
                switch:SetValue(UltimatePartySystem.ClientSettings.GetValue(v.key))
                switch.OnToggle = function(value)
                    UltimatePartySystem.ClientSettings.SetValue(v.key, value)
                end

                continue
            end
        end
    end)
    top:SetSelected(1)
end

net.Receive("ultimatepartysystem.core.openui", function()
    UltimatePartySystem.UI.OpenMainWindow()
end)


-- Delete Party confirmation
function UltimatePartySystem.UI.DeletePartyConfirmation()
    local frame = vgui.Create("ultimatepartysystem.frame")
    frame:SetSize(ScrW() * 0.4, ScrH() * 0.15)
    frame:Center()
    frame:MakePopup()
    frame:SetTopBarTitle(UltimatePartySystem.Core.GetLanguage("deletePartyTitle"))
    frame:SetTopBarHeight(frame:GetTall() * 0.25)

    local master = vgui.Create("DPanel", frame)
    master:Dock(FILL)
    master.Paint = function(s, w, h)
        draw.SimpleText("Are you sure you want to delete your party?", "ultimatepartysystem.scaled.9", w / 2, h * 0.175, color_white, 1, 0)
    end

    local yes = vgui.Create("ultimatepartysystem.button", master)
    yes:Dock(BOTTOM)
    yes:DockMargin(10, 10, 10, 11)
    yes:SetTall(frame:GetTall() * 0.25)
    yes:SetLabel(UltimatePartySystem.Core.GetLanguage("deletePartyButton"))
    yes.DoClick = function()
        frame:Remove()

        net.Start("ultimatepartysystem.core.deleteparty")
        net.SendToServer()
    end
end

-- Invite Player
function UltimatePartySystem.UI.InviteMenu()
    local frame = vgui.Create("ultimatepartysystem.frame")
    frame:SetSize(ScrW() * 0.4, ScrH() * 0.2)
    frame:Center()
    frame:MakePopup()
    frame:SetTopBarTitle(UltimatePartySystem.Core.GetLanguage("invitePlayerTitle"))
    frame:SetTopBarHeight(frame:GetTall() * 0.18)

    local master = vgui.Create("DPanel", frame)
    master:Dock(FILL)
    master.Paint = function(s, w, h)
        draw.SimpleText(UltimatePartySystem.Core.GetLanguage("invitePlayerMessage"), "ultimatepartysystem.scaled.9", w / 2, h * 0.15, color_white, 1, 0)
    end

    local mmmyes = vgui.Create("ultimatepartysystem.combobox", master)
    for k,v in pairs(player.GetAll()) do
        if(v == LocalPlayer()) then continue end
        mmmyes:AddChoice(v:Name(), v:SteamID64())
    end
    master.PerformLayout = function()
        mmmyes:SetPos(master:GetWide() * 0.3, master:GetTall() * 0.35)
        mmmyes:SetSize(master:GetWide() * 0.4, master:GetTall() * 0.15)
    end

    local dewit = vgui.Create("ultimatepartysystem.button", master)
    dewit:Dock(BOTTOM)
    dewit:DockMargin(10, 10, 10, 11)
    dewit:SetTall(frame:GetTall() * 0.175)
    dewit:SetLabel(UltimatePartySystem.Core.GetLanguage("invitePlayerButton"))
    dewit.DoClick = function()
        frame:Remove()

        net.Start("ultimatepartysystem.core.inviteplayer")
        local _,sid = mmmyes:GetSelected()
        net.WriteString(sid)
        net.SendToServer()
    end
end