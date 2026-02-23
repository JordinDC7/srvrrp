local margin, accent_col, successcolor, main_col, shade_5, shade_10, shade_20, shade_min10, text_col, text_colmin40, white, failcolor = 8, slib.getTheme("accentcolor"), slib.getTheme("successcolor"), slib.getTheme("maincolor"), slib.getTheme("maincolor", 5), slib.getTheme("maincolor", 10), slib.getTheme("maincolor", 20), slib.getTheme("maincolor", -10), slib.getTheme("textcolor"), slib.getTheme("textcolor", -40), Color(255,255,255), slib.getTheme("failcolor")
local money, income, withdraw, eject, repair_ico = Material("sprinter/money.png", "smooth"), Material("sprinter/income.png", "smooth"), Material("sprinter/withdraw.png", "smooth"), Material("sprinter/eject.png", "smooth"), Material("sprinter/repair.png", "smooth")
local back_ico, charge_ico, logs_ico, upgrades_ico, settings_ico, power_ico, manage_ico, auth_ico, lock_ico, fingerprint_ico, hack_ico, upgradeall_ico = Material("sprinter/back.png", "smooth"), Material("sprinter/energy.png", "smooth"), Material("sprinter/log.png", "smooth"), Material("sprinter/upgrade.png", "smooth"), Material("sprinter/settings.png", "smooth"), Material("sprinter/power.png", "smooth"), Material("sprinter/manage.png", "smooth"), Material("sprinter/user.png", "smooth"), Material("sprinter/lock.png", "smooth"), Material("sprinter/fingerprint.png", "smooth"), Material("sprinter/hacking.png", "smooth"), Material("sprinter/upgrade-all.png", "smooth")
local console_ico, minigame_bg, minigame_base, minigame_dot = Material("sprinter/console.png", "smooth"), Material("sprinter/minigame-bg.png", "smooth"), Material("sprinter/minigame-base.png", "smooth"), Material("sprinter/minigame-dot.png", "smooth")
local popup_menu_bg, dot_col, green_bg = Color(shade_min10.r, shade_min10.g, shade_min10.b, 250), Color(white.r, white.g, white.b, 100), Color(10, 119, 0)

local function openPrinterOption(ent, slot, page)
    ent.stopHover = true

    if IsValid(ent.rackScreen.main) then
        ent.rackScreen.main:SetVisible(false)
    end

    local printer = slot and ent:hasPrinter(slot)
    if slot and !IsValid(printer) then return end

    local oldtitle = ent.rackScreen.topbar.title
    ent.rackScreen.topbar.title = printer and printer.name or page
    local width, height = ent.rackScreen:GetWide(), ent.rackScreen:GetTall() - 45
    local frame = vgui.Create("EditablePanel", ent.rackScreen)
    frame:SetPos(0, 45)
    frame:SetSize(width, height)

    frame.OnRemove = function()
        if IsValid(ent) then
            if ent.rackScreen and IsValid(ent.rackScreen.main) then
                ent.rackScreen.main:SetVisible(true)
            end
            ent.stopHover = nil
        end
    end

    frame.Paint = function(s,w,h)
        if slot and !IsValid(ent:hasPrinter(slot)) then frame:Remove() end
        surface.SetDrawColor(main_col)
        surface.DrawRect(0, 0, w, h)
    end

    local topbar = vgui.Create("EditablePanel", frame)
    topbar:SetSize(width, 40)
    topbar.Paint = function(s,w,h)
        surface.SetDrawColor(shade_10)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(shade_20)
        surface.DrawRect(0,h - 1,w,1)

        draw.SimpleText(slot and page or "", slib.createFont("NasalizationRg-Regular", 32, nil, true), w * .5, h * .5, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local back = vgui.Create("SButton", topbar)
    back:SetPos(5,0)
    back:SetSize(40,40)
    back.triggered = false
    back.Paint = function(s,w,h)
        if slot and !IsValid(ent:hasPrinter(slot)) then s.DoClick(true) end
        if s.Hovered and !sPrinter.ShouldDraw(ent) then s.Hovered = false end
        surface.SetDrawColor(slib.lerpColor(s, ent.page == slib.getLang("sprinter", sPrinter.config["language"], "main") and transparent or (s.Hovered and accent_col or white)))
        surface.SetMaterial(back_ico)
        local iconsize = h * .8
        surface.DrawTexturedRect(w * .5 - iconsize * .5, h * .5 - iconsize * .5, iconsize, iconsize)
    end

    back.DoClick = function(nosound)
        if ent.page == slib.getLang("sprinter", sPrinter.config["language"], "main") or back.triggered then return end
        if !nosound then surface.PlaySound("buttons/button15.wav") end
        frame:Remove()
        ent.rackScreen.topbar.title = oldtitle
        ent.overlayDrawn = nil
        back.triggered = true
    end

    local canvas = vgui.Create("SScrollPanel", frame)
    canvas:SetPos(0, 40)
    canvas:SetSize(width, height - 40)
    canvas:GetCanvas():DockPadding(margin,margin,margin,margin)
    canvas.PaintOver = function(s,w,h)
        if #canvas:GetCanvas():GetChildren() < 1 then
            draw.SimpleText(slib.getLang("sprinter", sPrinter.config["language"], "nothing-to-show"), slib.createFont("NasalizationRg-Regular", 32, nil, true), w * .5, h * .5, text_colmin40, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local scrollbar = canvas:GetVBar()

    local scrollbarw, scrollbarh = scrollbar:GetWide(), canvas:GetTall()

    local upButtn = vgui.Create("SButton", scrollbar)
    upButtn:SetSize(scrollbarw, scrollbarh * .5)
    upButtn.Paint = function(s)
        if input.IsKeyDown(KEY_E) and s.Hovered and (!s.lastClick or (CurTime() - s.lastClick > .2)) then
            s.lastClick = CurTime()
            s.DoClick()
        end
    end

    upButtn.DoClick = function()
        local curScroll = scrollbar:GetScroll()
        scrollbar:SetScroll(curScroll - (40 + margin))
    end

    local downButtn = vgui.Create("SButton", scrollbar)
    downButtn:SetSize(scrollbarw, scrollbarh * .5)
    downButtn:SetPos(0, scrollbarh * .5)
    downButtn.Paint = function(s)
        if input.IsKeyDown(KEY_E) and s.Hovered and (!s.lastClick or (CurTime() - s.lastClick > .2)) then
            s.lastClick = CurTime()
            s.DoClick()
        end
    end

    downButtn.DoClick = function()
        local curScroll = scrollbar:GetScroll()
        scrollbar:SetScroll(curScroll + (40 + margin))
    end

    if page == "Logs" then 
        if !printer.addedLogs then
            printer.addedLogs = true
            net.Start("sP:Networking")
            net.WriteEntity(printer)
            net.WriteUInt(4,3)
            net.WriteUInt(2,2)
            net.SendToServer()
        end

        sPrinter.addLogEntries(printer, canvas)
    elseif page == "Settings" then
        sPrinter.addSettings(printer, canvas)
    elseif page == "Upgrades" then
        sPrinter.addUpgrades(printer, canvas)
    elseif page == slib.getLang("sprinter", sPrinter.config["language"], "authorization") then
        for k,v in ipairs(player.GetAll()) do
            if v == LocalPlayer() or v:IsBot() then continue end
            local ply = vgui.Create("SStatement", canvas)
            ply:SetTall(55)
            ply:DockMargin(0,0,0,margin)
            ply.font = slib.createFont("NasalizationRg-Regular", 32, nil, true)
            ply.Paint = function(s,w,h)
                if !IsValid(v) then s:Remove() return end
                surface.SetDrawColor(shade_10)
                surface.DrawRect(0, 0, w, h)
    
                draw.SimpleText(v:Nick(), s.font, 3, h * .5, text_colmin40, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            local sid64 = v:SteamID64()

            local _, element = ply:addStatement(name, ent.authorized[sid64] or false)
            element:DockMargin(5,5,5,5)
            element:SetWide(45)
    
            element.onValueChange = function(newval)
                net.Start("sP:Networking")
                net.WriteEntity(ent)
                net.WriteUInt(5,3)
                net.WriteUInt(1,2)
                net.WriteUInt(v:EntIndex(), 17)
                net.WriteBool(newval)
                net.SendToServer()

                ent.authorized[sid64] = newval or nil
            end
        end
    end

    ent.overlayDrawn = true

    topbar:MoveToFront()

    return printer
end

local handleWordGeneration = {}

local function getRandomHackWord(ent)
    local v, k = table.Random(sPrinter.config["hack_words"])
    handleWordGeneration[ent] = handleWordGeneration[ent] or {}
    
    if (handleWordGeneration[ent].cd or 0) < CurTime() then
        handleWordGeneration[ent].word = k

        handleWordGeneration[ent].cd = CurTime() + .1
    end

    return handleWordGeneration[ent].word
end

local ico_size = 148
local hack_size = 280

sPrinter.drawRackScreen = function(ent, opacity)
    local owner = ent:Getowning_ent()
    if !IsValid(ent.rackScreen) then
        ent.authorized = ent.authorized or {}
        
        ent.rackScreen = vgui.Create("EditablePanel")
        ent.rackScreen:SetSize(540, 598)
        ent.rackScreen:DockPadding(0,45,0,0)
        ent.rackScreen:SetPaintedManually(true)

        local hookName = "sP:DisableScreen_"..ent:EntIndex()
        hook.Add("sP:MouseEnabled", hookName, function(enabled)
            if !IsValid(ent) or !IsValid(ent.rackScreen) then hook.Remove("sP:MouseEnabled", hookName) return end

            ent.rackScreen:SetMouseInputEnabled(!enabled)
        end)

        ent.rackScreen.Paint = function(s,w,h)
            if s:IsMouseInputEnabled() == sPrinter.isMouseEnabled then s:SetMouseInputEnabled(!sPrinter.isMouseEnabled) end
            
            surface.SetDrawColor(main_col)
            surface.DrawRect(0,0,w,h)
        end

        ent.rackScreen.offset = 0
        ent.rackScreen.dotrotation = math.random(0,360)
        ent.rackScreen.hackRotation = ent.rackScreen.dotrotation + 10 
        ent.rackScreen.hackRotation = ent.rackScreen.hackRotation > 360 and ent.rackScreen.hackRotation - 360 or ent.rackScreen.hackRotation
        ent.rackScreen.hackCount = 0
        ent.rackScreen.hackDirection = true

        local animDown = true
        local console_size = 24

        ent.rackScreen.PaintOver = function(s,w,h)
            if ent:GetLocked() then
                local fps = math.Round(1/FrameTime())
                local lply = LocalPlayer()
                local canOpen = owner == lply or ent.authorized[lply:SteamID64()]

                if s:IsHovered() then
                    if input.IsKeyDown(KEY_E) then
                        if !s.clicked then
                            s.clicked = true
                            if !canOpen and !s.crackScreen then
                                s.crackScreen = true
                                ent.rackScreen.dotrotation = math.random(0,360)
                                ent.rackScreen.hackRotation = ent.rackScreen.dotrotation + 10 
                                ent.rackScreen.hackRotation = ent.rackScreen.hackRotation > 360 and ent.rackScreen.hackRotation - 360 or ent.rackScreen.hackRotation
                                
                                ent:HackHandler(false)
                            return end

                            if s.crackScreen then
                                local result = math.abs(s.hackRotation - s.dotrotation)
                                
                                if result <= 10 then
                                    surface.PlaySound("buttons/button14.wav")
                                    s.dotrotation = math.random(0,360)
                                    s.hackRotation = s.dotrotation + math.random(10,20) 
                                    s.hackRotation = s.hackRotation > 360 and s.hackRotation - 360 or s.hackRotation

                                    s.hackCount = s.hackCount + 1
                                    
                                    if s.hackCount >= 3 then
                                        s.hackedSuccess = true
                                    end

                                    if math.random(0,100) > 50 then
                                        s.hackDirection = !s.hackDirection
                                    end
                                else
                                    surface.PlaySound("buttons/blip1.wav")
                                    s.hackfailed = CurTime() + 1

                                    timer.Simple(1, function()
                                        if !IsValid(s) then return end
                                        s.crackScreen = nil
                                        s.hackCount = 0
                                    end)
                                end
                            else
                                s.attemptedUnlock = true
                            end
                        end
                    elseif s.clicked then
                        if s.hackedSuccess then
                            ent:HackHandler(true)
                            s.hackedSuccess = nil
                        end

                        if s.attemptedUnlock then
                            ent:AttemptUnlock()
                        end

                        s.clicked = nil
                    end
                end

                surface.SetDrawColor(main_col)
                surface.DrawRect(0, 0, w, h)
                
                local increment = 15 / fps
                s.offset = s.offset + (animDown and increment or -increment)
                if math.abs(s.offset) >= 8 then
                    animDown = !animDown
                end

                if !s.crackScreen then
                    surface.SetDrawColor(canOpen and white or successcolor)
                    surface.SetMaterial(canOpen and fingerprint_ico or hack_ico)
                    surface.DrawTexturedRect(w * .5 - ico_size * .5, h * .5 - ico_size * .5 - 65, ico_size, ico_size)

                    draw.SimpleText(canOpen and slib.getLang("sprinter", sPrinter.config["language"], "use_unlock") or slib.getLang("sprinter", sPrinter.config["language"], "use_hack"), slib.createFont("NasalizationRg-Regular", 38, nil, true), w *.5, h * .5 + 65 + s.offset, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    surface.SetDrawColor(shade_min10)
                    surface.DrawRect(0, 0, w, 35)

                    surface.SetDrawColor(white)
                    surface.SetMaterial(console_ico)
                    surface.DrawTexturedRect(8, 6, console_size, console_size)

                    draw.SimpleText(getRandomHackWord(ent)..".exe", slib.createFont("NasalizationRg-Regular", 20, nil, true), 36, 18, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                    local centerh = (h - 35) * .5 + 35

                    surface.SetDrawColor(green_bg)
                    surface.SetMaterial(minigame_bg)
                    surface.DrawTexturedRect(0, 35, w, h - 35)

                    surface.SetDrawColor(white)
                    surface.SetMaterial(minigame_base)
                    surface.DrawTexturedRectRotated(w * .5, centerh, hack_size, hack_size, 0)

                    local increment = sPrinter.config["hack_speed"]

                    local curtime, elapsed = CurTime(), 0
                    if s.lastPaintOver and s.lastPaintOver >= curtime then increment = 0 else elapsed = s.lastPaintOver and curtime - s.lastPaintOver or 0 s.lastPaintOver = curtime + (1 / 60) end

                    if elapsed > 0 then
                        increment = increment + (elapsed / (1 / 60) * sPrinter.config["hack_speed"])
                    end

                    s.hackRotation = s.hackRotation + increment
                    s.hackRotation = s.hackRotation >= 360 and 0 or s.hackRotation

                    local isFailed = s.hackfailed and s.hackfailed > curtime

                    surface.SetDrawColor(isFailed and failcolor or green_bg)
                    surface.SetMaterial(minigame_dot)
                    surface.DrawTexturedRectRotated(w * .5, centerh, hack_size, hack_size, s.hackDirection and s.dotrotation or -s.dotrotation)

                    surface.SetDrawColor(dot_col)
                    surface.SetMaterial(minigame_dot)
                    surface.DrawTexturedRectRotated(w * .5, centerh, hack_size, hack_size, s.hackDirection and s.hackRotation or -s.hackRotation)

                    draw.SimpleText(s.hackCount.."/3", slib.createFont("NasalizationRg-Regular", 60, nil, true), w * .5, centerh, isFailed and failcolor or green_bg, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            else
                s.crackScreen = nil
                s.hackCount = 0
            end

            sPrinter.DrawCursor(w, h, ent, 5)
        end

        ent.rackScreen.topbar = sPrinter.addTopbar(ent.rackScreen, ent)
        ent.rackScreen.topbar.title = slib.getLang("sprinter", sPrinter.config["language"], "rack")
        ent.rackScreen.topbar.PaintOver = function(s,w,h)
            if ent:drawingOverlay() or sPrinter.config["rack"]["godmode"] then return end

            local wide, height = 130, 20

            surface.SetDrawColor(main_col)
            surface.DrawRect(w - wide - h - (h * .8), h * .5 - height * .5, wide, height)

            surface.SetDrawColor(successcolor)
            surface.DrawRect(w - wide - h - (h * .8), h * .5 - height * .5, wide * (ent:Health() / 100), height)

            draw.SimpleText(math.Round(ent:Health()).."%", slib.createFont("NasalizationRg-Regular", 22, nil, true), w - wide - h - (h * .8) + 3, h * .5, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        ent.rackScreen.main = vgui.Create("EditablePanel", ent.rackScreen)
        ent.rackScreen.main:Dock(FILL)

        local bttnsize = ent.rackScreen.topbar:GetTall()

        local power_all = vgui.Create("SButton", ent.rackScreen.topbar)
        power_all:SetSize(bttnsize, bttnsize)
        power_all:SetPos(ent.rackScreen.topbar:GetWide() - bttnsize, 0)
        power_all.Paint = function(s,w,h)
            if ent:drawingOverlay() then return end
            if s.Hovered and !sPrinter.ShouldDraw(ent) then s.Hovered = false end
            surface.SetDrawColor(slib.lerpColor(s, ent:GetPower() and failcolor or successcolor))
            surface.SetMaterial(power_ico)
            local iconsize = h * .6
            surface.DrawTexturedRect(margin, h * .5 - iconsize * .5, iconsize, iconsize)
        end

        power_all.DoClick = function()
            surface.PlaySound("buttons/button15.wav")
            net.Start("sP:Networking")
            net.WriteEntity(ent)
            net.WriteUInt(1,3)
            net.WriteUInt(3,2)
            net.SendToServer()
        end
        
        local manage = vgui.Create("SButton", ent.rackScreen.topbar)
        manage:SetSize(bttnsize, bttnsize)
        manage:SetPos(ent.rackScreen.topbar:GetWide() - bttnsize * 1.8, 0)
        manage.Paint = function(s,w,h)
            if ent:drawingOverlay() then return end
            if s.Hovered and !sPrinter.ShouldDraw(ent) then s.Hovered = false end
            surface.SetDrawColor(slib.lerpColor(s, s.Hovered and accent_col or white))
            surface.SetMaterial(manage_ico)
            local iconsize = h * .6
            surface.DrawTexturedRect(margin, h * .5 - iconsize * .5, iconsize, iconsize)
        end

        manage.DoClick = function()
            surface.PlaySound("buttons/button15.wav")

            local canRepair = !sPrinter.config["rack"]["godmode"] and ent:Health() < 100
            local buttonCount = !canRepair and 2 or 3

            local canUpgradeAll = ent:GetUpgradeAllPrice() > 0
            if canUpgradeAll then
                buttonCount = buttonCount + 1
            end

            local buttonW = 145
            local popup_menu = vgui.Create("SFrame", ent.rackScreen)
            popup_menu:SetSize(((buttonW + margin) * buttonCount) + margin, 85 + (margin * 2) + popup_menu.topbarheight)
            :Center()
            :SetBG(true, false, popup_menu_bg)
            :addCloseButton()
            :setTitle(slib.getLang("sprinter", sPrinter.config["language"], "management"))
            :SetDraggable(false)
            
            if canRepair then
                local rep_price = sPrinter.config["currency"]..string.Comma(sPrinter.config["rack_repair_price"])
                local repair = sPrinter.addButton(popup_menu.frame, ent, function() return ent:Health() >= 100 and slib.getLang("sprinter", sPrinter.config["language"], "full_hp") or rep_price end, function()
                    if ent:Health() >= 100 then return end
                    
                    net.Start("sP:Networking")
                    net.WriteEntity(ent)
                    net.WriteUInt(2,3)
                    net.WriteUInt(2,2)
                    net.WriteBool(false)
                    net.SendToServer()

                    popup_menu:Remove()
                end, repair_ico)
                repair:SetWide(buttonW)
                repair:Dock(LEFT)
                repair:DockMargin(margin,margin,0,margin)
                repair.inverted = true

                repair.PaintOver = function(s)
                    if s.nextUpdate and CurTime() < s.nextUpdate then return end
                    s.nextUpdate = CurTime() + 1
        
                    s.resetText()
                end
            end

            local auth = sPrinter.addButton(popup_menu.frame, ent, slib.getLang("sprinter", sPrinter.config["language"], "authorize"), function()
                if ent:Getowning_ent() ~= LocalPlayer() then
                    slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "insufficient-permissions"))
                return end

                openPrinterOption(ent, nil, slib.getLang("sprinter", sPrinter.config["language"], "authorization"))
                popup_menu:Remove()
            end, auth_ico)
            auth:SetWide(buttonW)
            auth:Dock(LEFT)
            auth:DockMargin(margin,margin,0,margin)
            auth.inverted = true

            local lock = sPrinter.addButton(popup_menu.frame, ent, slib.getLang("sprinter", sPrinter.config["language"], "lock"), function()
                if ent:Getowning_ent() ~= LocalPlayer() and !ent.authorized[LocalPlayer():SteamID64()] then
                    slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "insufficient-permissions"))
                return end

                net.Start("sP:Networking")
                net.WriteEntity(ent)
                net.WriteUInt(5,3)
                net.WriteUInt(0,2)
                net.WriteBool(true)
                net.SendToServer()

                popup_menu:Remove()
            end, lock_ico)
            lock:SetWide(buttonW)
            lock:Dock(LEFT)
            lock:DockMargin(margin,margin,0,margin)
            lock.inverted = true

            if !canUpgradeAll then return end

            local upgrade_all = sPrinter.addButton(popup_menu.frame, ent, slib.getLang("sprinter", sPrinter.config["language"], "upgrade_all"), function()
                if ent:Getowning_ent() ~= LocalPlayer() and !ent.authorized[LocalPlayer():SteamID64()] then
                    slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "insufficient-permissions"))
                return end
                
                local price = ent:GetUpgradeAllPrice()

                if price <= 0 then
                    slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "already_upgraded"))
                return end

                sPrinter.MakePopup(ent, ent.rackScreen, slib.getLang("sprinter", sPrinter.config["language"], "this-will-cost", sPrinter.config["currency"]..string.Comma(price)), function()
                    net.Start("sP:Networking")
                    net.WriteEntity(ent)
                    net.WriteUInt(5,3)
                    net.WriteUInt(3,2)
                    net.SendToServer()
                end)

                popup_menu:Remove()
            end, upgradeall_ico)
            upgrade_all:SetWide(buttonW)
            upgrade_all:Dock(LEFT)
            upgrade_all:DockMargin(margin,margin,0,margin)
            upgrade_all.inverted = true

            local childs = popup_menu.frame:GetChildren()

            local function moveButtonsToRow(row, childs)
                local childIndex = row.i
                if row.i == 2 then childIndex = 3 end -- Just to target the childs of the frame

                childs[childIndex]:SetParent(row)
                childs[childIndex + 1]:SetParent(row)

                childs[childIndex]:DockMargin(margin, margin * (row.i == 2 and .5 or 1), 0, margin * (row.i == 2 and 1 or .5))
                childs[childIndex + 1]:DockMargin(margin, margin * (row.i == 2 and .5 or 1), 0, margin * (row.i == 2 and 1 or .5))

            end

            if #childs > 3 then
                for i = 1, 2, 1 do
                    local row = vgui.Create("EditablePanel", popup_menu.frame)
                    row:Dock(TOP)
                    row.i = i
                    row:SetTall(85 + margin)

                    moveButtonsToRow(row, childs)
                end

                popup_menu:SetSize(((buttonW + margin) * 2) + margin, (85 * 2) + (margin * 2) + popup_menu.topbarheight)
                :Center()
            end
        end

        local last = true
        local iteration = 0
        local made = 0
        for i= 1, 8 do
            local gap = margin
            local parentWide = ent.rackScreen:GetWide()
            local width, height = (parentWide / 2) - (gap * 1.5), 105
            local slot = vgui.Create("SButton", ent.rackScreen.main)
            local x, y = last and gap or parentWide - width - gap, gap + iteration * (height + gap)
            slot:setTitle(i)
            slot:SetSize(width, height)
            slot:SetPos(x, y)
            slot.Paint = function(s,w,h)
                if ent:drawingOverlay() then return end
                surface.SetDrawColor(shade_10)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(shade_5)
                surface.DrawRect(0, 0, w, margin + 20 + margin)

                local printer = ent:hasPrinter(i)
                draw.SimpleText(IsValid(printer) and printer.name or slib.getLang("sprinter", sPrinter.config["language"], "empty"), slib.createFont("NasalizationRg-Regular", 20, nil, true), margin, margin, IsValid(printer) and text_col or text_colmin40, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText("#"..i, slib.createFont("NasalizationRg-Regular", 20, nil, true), w - margin, margin, text_colmin40, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end

            slot.PaintOver = function(s,w,h)
                if ent:drawingOverlay() then return end
                local printer = ent:hasPrinter(i)
                if IsValid(printer) then return end
                local field = h - (margin + 20 + margin)
                surface.SetDrawColor(shade_10)
                surface.DrawRect(0, margin + 20 + margin, w, field)

                draw.SimpleText(slib.getLang("sprinter", sPrinter.config["language"], "nothing-to-show"), slib.createFont("NasalizationRg-Regular", 20, nil, true), w * .5, margin + 20 + margin + (field * .5), text_colmin40, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            local wide = width / 3

            local logs = sPrinter.addButton(slot, ent, "", function()
                local printer = openPrinterOption(ent, i, "Logs")

                if printer and !printer.addedLogs then
                    printer.addedLogs = true
                    net.Start("sP:Networking")
                    net.WriteEntity(printer)
                    net.WriteUInt(4,3)
                    net.WriteUInt(2,2)
                    net.SendToServer()
                end
            end, logs_ico, LEFT, margin, function() return IsValid(ent:hasPrinter(i)) end, true)
            logs:DockMargin(0, 20 + margin + margin, 0, 0)
            logs:SetWide(wide)
            logs.iconsize = wide * .5
    
            local upgrades = sPrinter.addButton(slot, ent, "", function() openPrinterOption(ent, i, "Upgrades") end, upgrades_ico, LEFT, margin, function() return IsValid(ent:hasPrinter(i)) end, true)
            upgrades:DockMargin(0, 20 + margin + margin, 0, 0)
            upgrades:SetWide(wide)
            upgrades.iconsize = wide * .45
            upgrades.PaintOver = function(s,w,h)
                if ent:drawingOverlay() then return end
                
                surface.SetDrawColor(shade_5)
                surface.DrawRect(0,0,2,h)
                surface.DrawRect(w - 2,0,2,h)
            end
    
            local settings = sPrinter.addButton(slot, ent, "", function()
                local printer = openPrinterOption(ent, i, "Settings")

                if printer and !printer.addedSettings then
                    printer.addedSettings = true
                    net.Start("sP:Networking")
                    net.WriteEntity(printer)
                    net.WriteUInt(4,3)
                    net.WriteUInt(1,2)
                    net.SendToServer()
                end
            end, settings_ico, LEFT, margin, function() return IsValid(ent:hasPrinter(i)) end, true)
            settings:DockMargin(0, 20 + margin + margin, 0, 0)
            settings:SetWide(wide)
            settings.iconsize = wide * .45

            made = made + 1
            last = !last
            iteration = made >= 2 and iteration + 1 or iteration

            made = made >= 2 and 0 or made
        end
        
        local manageButtons = vgui.Create("EditablePanel", ent.rackScreen.main)
        manageButtons:Dock(BOTTOM)
        manageButtons:DockMargin(margin,0,margin,margin)
        manageButtons:DockPadding(margin,margin + 32,margin,margin)
        manageButtons:SetTall(61 + 32 - margin)
        manageButtons.Paint = function(s,w,h)
            if ent:drawingOverlay() then return end

            surface.SetDrawColor(shade_5)
            surface.DrawRect(0,0,w,h)

            draw.SimpleText(slib.getLang("sprinter", sPrinter.config["language"], "recharge"), slib.createFont("NasalizationRg-Regular", 22, nil, true), (w * .15) + (margin * 2.5), 20, text_colmin40, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(slib.getLang("sprinter", sPrinter.config["language"], "repair"), slib.createFont("NasalizationRg-Regular", 22, nil, true), (w * .5), 20, text_colmin40, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(slib.getLang("sprinter", sPrinter.config["language"], "withdraw"), slib.createFont("NasalizationRg-Regular", 22, nil, true), (w * .85) - (margin * 2.5), 20, text_colmin40, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local recharge = sPrinter.addButton(manageButtons, ent, function()
            local money = 0

            for i = 1,8 do
                local printer = ent:hasPrinter(i)
                
                if !IsValid(printer) or printer:GetBattery() >= (sPrinter.config["rack"]["min_recharge"] or 0.8) then continue end
                
                money = money + printer:GetRechargePrice()
            end

            return money > 0 and (sPrinter.config["currency"]..string.Comma(money)) or "N/A"
        end, 
        function()
            net.Start("sP:Networking")
            net.WriteEntity(ent)
            net.WriteUInt(2,3)
            net.WriteUInt(1,2)
            net.SendToServer()
        end, charge_ico, LEFT, margin)
        recharge:DockMargin(0, 0, margin * .5, 0)

        recharge.PaintOver = function(s)
            if s.nextUpdate and CurTime() < s.nextUpdate then return end
            s.nextUpdate = CurTime() + 1

            s.resetText()
        end

        local repair = sPrinter.addButton(manageButtons, ent, function()
            local money = 0
            
            for i = 1,8 do
                local printer = ent:hasPrinter(i)
                if !IsValid(printer) or printer:Health() >= 100 then continue end
                money = money + printer.data.repairprice
            end

            return money > 0 and (sPrinter.config["currency"]..string.Comma(money)) or "N/A"
        end, 
        function()
            net.Start("sP:Networking")
            net.WriteEntity(ent)
            net.WriteUInt(2,3)
            net.WriteUInt(2,2)
            net.WriteBool(true)
            net.SendToServer()
        end, repair_ico, FILL, margin)
        repair:DockMargin(margin * .5, 0, margin * .5, 0)

        repair.PaintOver = function(s)
            if s.nextUpdate and CurTime() < s.nextUpdate then return end
            s.nextUpdate = CurTime() + 1

            s.resetText()
        end

        local withdraw = sPrinter.addButton(manageButtons, ent, function() 
            local money = 0

            for i = 1,8 do
                local printer = ent:hasPrinter(i)
                if !IsValid(printer) then continue end
                money = money + printer:GetWithdrawAmount()
            end

            return money > 0 and (sPrinter.config["currency"]..string.Comma(money)) or "N/A"
        end,
        function()
            net.Start("sP:Networking")
            net.WriteEntity(ent)
            net.WriteUInt(1,3)
            net.WriteUInt(1,2)
            net.SendToServer()
        end, withdraw, RIGHT, margin)
        withdraw:DockMargin(margin * .5, 0, 0, 0)

        withdraw.PaintOver = function(s)
            if s.nextUpdate and CurTime() < s.nextUpdate then return end
            s.nextUpdate = CurTime() + 1

            s.resetText()
        end

        manageButtons.OnSizeChanged = function(s, w, h)
            local size = w / 3 - (margin * 2 / 3) + 1.5

            recharge:SetWide(size)
            repair:SetWide(size)
            withdraw:SetWide(size)
        end

        return
    else
        ent.rackScreen:SetAlpha(opacity)
    end

    local pos = ent:LocalToWorld(Vector(-5.25 - 5.65, -6.5, 42.52 + 32.9))
	local ang = ent:LocalToWorldAngles(Angle(0,0,80))

	vgui.Start3D2DS( pos, ang, .03 )
        ent.rackScreen:SPaint3D2D(ent)
    vgui.End3D2DS()
end

--- DONT REMOVE INT:76561199109663699