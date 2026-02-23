sPrinter = sPrinter or {}

local margin, main_col, accent_col, successcolor, failcolor, shade_10, shade_min10, text_col, white, orange, invisible = 8, slib.getTheme("maincolor"), slib.getTheme("accentcolor"), slib.getTheme("successcolor"), slib.getTheme("failcolor"), slib.getTheme("maincolor", 10), slib.getTheme("maincolor", -10), slib.getTheme("textcolor"), Color(255,255,255), Color(189, 75, 0), Color(0,0,0,0)
local cursor, power_ico, charge_ico, plus_ico, upgrades_ico, lock_ico = Material("sprinter/cursor.png", "smooth"), Material("sprinter/power.png", "smooth"), Material("sprinter/energy.png", "smooth"), Material("sprinter/plus.png", "smooth"), Material("sprinter/upgrade.png", "smooth"), Material("sprinter/lock.png", "smooth")
local stats = {}

function sPrinter.addTopbar(parent, ent)
    local drawBattery = isfunction(ent.GetBattery)
    local topbar = vgui.Create("EditablePanel", parent)
    topbar:SetSize(parent:GetWide(), 45)
    topbar.Paint = function(s,w,h)
        if ent:drawingOverlay("topbar") then return end
        surface.SetDrawColor(shade_min10)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText(ent.name or topbar.title, slib.createFont("NasalizationRg-Regular", 35, nil, true), margin, h * .5, text_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if drawBattery then
            local batteryw, batteryh = 75, 26
            local batteryx, batteryy = (w - batteryw - margin) - 70, (h * .5 - (batteryh * .5))
            local percent = ent:GetBattery()
            local percentcolor = successcolor

            if percent < .5 then
                percentcolor = orange
                if percent < .15 then
                    percentcolor = failcolor
                end
            end

            surface.SetDrawColor(percentcolor)
            surface.DrawRect(batteryx + (batteryw * (1 - percent)), batteryy, batteryw * percent, batteryh)

            surface.SetDrawColor(white)
            surface.DrawOutlinedRect(batteryx, batteryy, batteryw, batteryh)

            surface.DrawRect(batteryx - 2, h * .5 - (12 * .5), 2, 12)

            draw.SimpleText(math.Round(percent * 100).."%", slib.createFont("NasalizationRg-Regular", 28, nil, true), batteryx + (batteryw * .5), batteryy + (batteryh * .5), white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if drawBattery then
        local power = vgui.Create("SButton", topbar)
        :Dock(RIGHT)
        :SetWide(25)
        :DockMargin(0, 7, 20, 7)

        power.DoClick = function()
            if !sPrinter.ShouldDraw(ent) then return end
            net.Start("sP:Networking")
            net.WriteEntity(ent)
            net.WriteUInt(1,3)
            net.WriteUInt(3,2)
            net.SendToServer()
        end

        power.Paint = function(s,w,h)
            if ent:drawingOverlay() then return end
            surface.SetDrawColor(slib.lerpColor(s, ent:GetPower() and successcolor or failcolor))
            surface.SetMaterial(power_ico)
            local iconsize = h
            surface.DrawTexturedRect(margin, h * .5 - iconsize * .5, iconsize, iconsize)
        end

        local charge = vgui.Create("SButton", topbar)
        :Dock(RIGHT)
        :SetWide(25)
        :DockMargin(0, 7, 10, 7)

        charge.DoClick = function()
            if !sPrinter.ShouldDraw(ent) then return end
            surface.PlaySound("buttons/button15.wav")
            
            sPrinter.MakePopup(ent, parent, slib.getLang("sprinter", sPrinter.config["language"], "this-will-cost", sPrinter.config["currency"]..string.Comma(ent:GetRechargePrice())), function()
                net.Start("sP:Networking")
                net.WriteEntity(ent)
                net.WriteUInt(2,3)
                net.WriteUInt(1,2)
                net.SendToServer()
            end)
        end

        charge.Paint = function(s,w,h)
            if ent:drawingOverlay() then return end
            if s.Hovered and !sPrinter.ShouldDraw(ent) then s.Hovered = false end
            surface.SetDrawColor(slib.lerpColor(s, s.Hovered and accent_col or white))
            surface.SetMaterial(charge_ico)
            local iconsize = h
            surface.DrawTexturedRect(margin, h * .5 - iconsize * .5, iconsize, iconsize)
        end
    end

    return topbar
end

local ico_size = 64
sPrinter.DrawLocked = function(w, h)
    surface.SetDrawColor(main_col)
    surface.DrawRect(0,0,w,h)

    surface.SetDrawColor(successcolor)
    surface.SetMaterial(lock_ico)
    surface.DrawTexturedRect(w * .5 - ico_size * .5, h * .5 - ico_size * .5 - 25, ico_size, ico_size)

    draw.SimpleText(slib.getLang("sprinter", sPrinter.config["language"], "locked"), slib.createFont("NasalizationRg-Regular", 56, nil, true), w * .5, h * .5 + 25, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

local ShouldDraw = {}
local lastDistUpdate = {}

function sPrinter.ShouldDraw(ent)
    if !IsValid(ent) then return end
    if !lastDistUpdate[ent] or (CurTime() - lastDistUpdate[ent]) > .5 then 
        local plypos = LocalPlayer():GetPos()
        local entpos = ent:GetPos()
        entpos.z = plypos.z

        ShouldDraw[ent] = plypos:DistToSqr(entpos) <= sPrinter.config["maxdistance"]
        lastDistUpdate[ent] = CurTime()
    end

    return ShouldDraw[ent]
end

local isDrawingCursor = CurTime()

function sPrinter.DrawCursor(w, h, ent, limit)
    if !sPrinter.ShouldDraw(ent) then return end
    local x, y = gui.MouseX(), gui.MouseY()
    if (x > w + 10 or x < -30) or (y > h + 10 or y < -30) or (x <= 0 and y <= 0) then return end
    surface.SetDrawColor(white)
    surface.SetMaterial(cursor)
    surface.DrawTexturedRect(math.Clamp(x, 0, w - limit), math.Clamp(y, 0, h - limit), 20, 20)
    isDrawingCursor = CurTime()
end

function sPrinter.MakePopup(ent, parent, question, func)
    local madeTime = SysTime()

    ent.stopHover = true

    local cover = vgui.Create("SButton", parent)
    cover:SetSize(parent:GetWide(), parent:GetTall())
    cover.OnRemove = function()
        ent.stopHover = nil
    end

    cover.Paint = function(s, w, h)
        surface.SetDrawColor(shade_min10.r, shade_min10.g, shade_min10.b, 250)
        surface.DrawRect(0, 0, w, h)
    end

    cover.DoClick = function() cover:Remove() end
    
    local popup = vgui.Create("SFrame", cover)
    :SetSize(parent:GetWide() * .6, 130)
    :setTitle(slib.getLang("sprinter", sPrinter.config["language"], "are-you-sure"))
    :addCloseButton()
    :Center()

    popup:SetDraggable(false)

    popup.OnRemove = function()
        if !IsValid(cover) then return end
        cover:Remove()
    end

    popup.PaintOver = function(s,w,h)
        draw.SimpleText(question, slib.createFont("NasalizationRg-Regular", 26, nil, true), w * .5, h * .5, text_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local agree = vgui.Create("SButton", popup)
    agree.bg = shade_10
    agree:setTitle(slib.getLang("sprinter", sPrinter.config["language"], "agree"))
    agree:SetSize(popup:GetWide() * .5 - 7, 25)
    agree:SetPos(popup:GetWide() - agree:GetWide() - 5, popup:GetTall() - 30)

    agree.DoClick = function()
        surface.PlaySound("buttons/button15.wav")
        cover.dontClick = true
        func()
    end

    local deny = vgui.Create("SButton", popup)
    deny.bg = shade_10
    deny:setTitle(slib.getLang("sprinter", sPrinter.config["language"], "deny"))
    deny:SetSize(popup:GetWide() * .5 - 7, 25)
    deny:SetPos(5, popup:GetTall() - 30)

    deny.DoClick = function()
        surface.PlaySound("buttons/button14.wav")
    end

    return popup
end

function sPrinter.addButton(parent, ent, title, func, icon, dock, gap, check, onlyicon)
    surface.SetFont(slib.createFont("NasalizationRg-Regular", 24, nil, true))
    local originalfunc = title
    if isfunction(title) then title = title() end
    local w = select(1, surface.GetTextSize(title))

    local button = vgui.Create("SButton", parent)
    :SetWide(w + margin * 2)

    if dock then
        button:Dock(dock)
    end

    button.resetText = function()
        title = originalfunc()
    end

    if gap then
        button:DockMargin(0,0,gap,0)
    end

    button.DoClick = function()
        if !sPrinter.ShouldDraw(ent) or ent:drawingOverlay() then return end
        if isfunction(check) and !check() then return end
        surface.PlaySound("buttons/button15.wav")
        func()
    end

    button.randid = tostring(function() end)

    button.Paint = function(s,w,h)
        if !IsValid(ent) or ent:drawingOverlay() then return end
        if s.disabled ~= nil then s.Hovered = s.disabled end
        if isfunction(check) and !check() then return end
        if ent.stopHover or !sPrinter.ShouldDraw(ent) and s.Hovered then s.Hovered = false end
        local wantedColor = onlyicon and invisible or s.Hovered and invisible or text_col
        local wantedIconColor = s.Hovered and accent_col or onlyicon and white or invisible
        surface.SetDrawColor(s.forcebg and s.forcebg or shade_10)
        surface.DrawRect(0, 0, w, h)

        local iconcol = slib.lerpColor(s.randid, s.inverted and wantedColor or wantedIconColor)
        local textcol = slib.lerpColor(s, s.inverted and wantedIconColor or wantedColor)

        surface.SetDrawColor(iconcol.a > 60 and iconcol or invisible)
        surface.SetMaterial(icon)
        local iconsize = (s.usewidth and w or h) * .7
        iconsize = s.iconsize or iconsize
        surface.DrawTexturedRect(w * .5 - iconsize * .5, h * .5 - iconsize * .5, iconsize, iconsize)

        draw.SimpleText(title, slib.createFont("NasalizationRg-Regular", s.fontsize and s.fontsize or 24, nil, true), w * .5, h * .5, textcol.a > 60 and textcol or invisible, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    return button
end

local function fullUpgradePrice(ent, upg_int)
    local cur_stage = ent.data.upgrades[upg_int].stage
    local sum = 0

    for i = cur_stage + 1, ent.data.upgrades[upg_int].max do
        sum = sum + ent:GetUpgradePrice(upg_int, i)
    end

    return sum
end 

function sPrinter.addUpgrades(ent, parent)
    for k,v in ipairs(ent.data.upgrades) do
        ent.data.upgrades[k].stage = ent.data.upgrades[k].stage or 0
        local name = slib.getLang("sprinter", sPrinter.config["language"], v.upgrade)

        local upg_bttn, upg_all_bttn

        local upgrade = vgui.Create("EditablePanel", parent)
        upgrade:Dock(TOP)
        upgrade:DockMargin(0,0,0,margin)
        upgrade:SetTall(60)

        upgrade.Paint = function(s,w,h)
            if !ent or !ent.data then return end
            if !ent.data.upgrades then upgrade:Remove() return end
            surface.SetDrawColor(shade_10)
            surface.DrawRect(0, 0, w, h)

            local iconsize = h * .7
            surface.SetDrawColor(white)
            surface.SetMaterial(v.icon)
            surface.DrawTexturedRect(h * .5 - iconsize * .5, h * .5 - iconsize * .5, iconsize, iconsize)

            local stage = ent.data.upgrades[k].stage
            local upgradewidth = math.Round((w - h - 110 - 30) / ent.data.upgrades[k].max)
            if ent.data.upgrades and ent.data.upgrades[k] and ent.data.upgrades[k].max then
                for i=1,ent.data.upgrades[k].max do
                    surface.SetDrawColor(i <= stage and accent_col or main_col)
                    surface.DrawRect(h + ((upgradewidth + 1) * (i - 1)), 7, (upgradewidth - 1) - ent.data.upgrades[k].max, 7)
                end
            end

            draw.SimpleText(name.."["..stage.."/"..ent.data.upgrades[k].max.."]", slib.createFont("NasalizationRg-Regular", 29, nil, true), h, h - 10, text_colmin40, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            local price = (stage >= ent.data.upgrades[k].max) and "Max" or upg_bttn.Hovered and ent:GetUpgradePrice(k, stage + 1) or upg_all_bttn.Hovered and fullUpgradePrice(ent, k) or "N/A"
            local isnum = isnumber(price)
            price = isnum and sPrinter.config["currency"]..string.Comma(price) or price
            draw.SimpleText(price, slib.createFont("NasalizationRg-Regular", 24, nil, true), w - 56, h * .5, !isnum and text_col or successcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local w = parent:GetWide()

        local buttonDock = vgui.Create("EditablePanel", upgrade)
        buttonDock:Dock(RIGHT)
        buttonDock:DockMargin(0,0,108,0)
        buttonDock:DockPadding(0,1,0,1)
        buttonDock:SetWide(28)

        upg_bttn = sPrinter.addButton(buttonDock, ent, "", function()
            net.Start("sP:Networking")
            net.WriteEntity(ent)
            net.WriteUInt(3, 3)
            net.WriteUInt(k, 3)
            net.WriteBool(false)
            net.SendToServer()
        end, plus_ico, TOP, nil, nil, true)
        upg_bttn:SetTall(28)
        upg_bttn:DockMargin(0,0,0,1)
        upg_bttn.forcebg = main_col

        upg_all_bttn = sPrinter.addButton(buttonDock, ent, "", function()
            net.Start("sP:Networking")
            net.WriteEntity(ent)
            net.WriteUInt(3, 3)
            net.WriteUInt(k, 3)
            net.WriteBool(true)
            net.SendToServer()
        end, upgrades_ico, TOP, nil, nil, true)
        upg_all_bttn:SetTall(28)
        upg_all_bttn:DockMargin(0,1,0,0)
        upg_all_bttn.forcebg = main_col
    end
end

local settingUpdate = {}

local UpdatedSetting = function(ent, setting)
    for panel, v in pairs(settingUpdate) do
        if !IsValid(panel) then continue end
        if setting == v.action and v.ent == ent then
            panel.enabled = ent.settings[setting]
        end
    end
end

local settings = {
    ["notify-low-hp"] = {action = 1, icon = Material("sprinter/low-hp-notify.png", "smooth")},
    ["notify-withdraw"] = {action = 2, icon = Material("sprinter/steal.png", "smooth")},
    ["notify-low-battery"] = {action = 3, icon = Material("sprinter/low-battery.png", "smooth")},
    ["notify-on-damage"] = {action = 4, icon = Material("sprinter/on-damage-notify.png", "smooth")}
}

function sPrinter.addSettings(ent, parent)
    ent.settings = ent.settings or {}
    for name, v in pairs(settings) do
        local setting = vgui.Create("SStatement", parent)
        setting:SetTall(55)
        setting:DockMargin(0,0,0,margin)
        setting.font = slib.createFont("NasalizationRg-Regular", 32, nil, true)
        local name = slib.getLang("sprinter", sPrinter.config["language"], name)
        setting.Paint = function(s,w,h)
            surface.SetDrawColor(shade_10)
            surface.DrawRect(0, 0, w, h)

            local iconsize = h * .7
            surface.SetDrawColor(white)
            surface.SetMaterial(v.icon)
            surface.DrawTexturedRect(h * .5 - iconsize * .5, h * .5 - iconsize * .5, iconsize, iconsize)

            draw.SimpleText(name, s.font, h, h * .5, text_colmin40, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local _, element = setting:addStatement(name, ent.settings[v.action])
        element:DockMargin(5,5,5,5)
        element:SetWide(45)
        settingUpdate[element] = {action = v.action, ent = ent}

        element.onValueChange = function(newval)
            net.Start("sP:Networking")
            net.WriteEntity(ent)
            net.WriteUInt(2,3)
            net.WriteUInt(3,2)
            net.WriteUInt(v.action, 3)
            net.WriteBool(newval)
            net.SendToServer()
        end
    end
end

local actionNames = {
    [1] = "withdrawn-money",
    [2] = "received-damage",
    [3] = "upgraded-printer",
    [4] = "turned-on",
    [5] = "turned-off"
}

local function addLogEntry(parent, ent, setting)
    if !IsValid(parent) then return end
    local data = ent.logs[setting]
    local entry = vgui.Create("EditablePanel", parent)
    entry:Dock(TOP)
    entry:DockMargin(0,0,0,margin)
    entry:SetZPos(-setting)
    entry:SetTall(40)

    entry.Paint = function(s,w,h)
        surface.SetDrawColor(shade_10)
        surface.DrawRect(0, 0, w, h)

        local iconsize = h * .7
        
        surface.SetDrawColor(white)
        surface.SetMaterial(plus_ico)
        surface.DrawTexturedRect(h * .5 - iconsize * .5, h * .5 - iconsize * .5, iconsize, iconsize)

        draw.SimpleText("["..os.date( "%H:%M" , data.time ).."] "..slib.getLang("sprinter", sPrinter.config["language"], actionNames[data.action]), slib.createFont("NasalizationRg-Regular", 29, nil, true), h, h * .5, text_colmin40, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

local logsEntryCanvas = {}

function sPrinter.addLogEntries(ent, parent)
    if ent.logs then
        for k,v in pairs(ent.logs) do
            addLogEntry(parent, ent, k)
        end
    end

    logsEntryCanvas[parent] = ent
end

sPrinter.requestData = function(ent)
    if ent.Requested then return end
    net.Start("sP:Networking")
    net.WriteEntity(ent)
    net.SendToServer()
    ent.Requested = true
end

sPrinter.fadeByDistance = function(ent)
    if !IsValid(ent) then return end
    local distance = ent:GetPos():DistToSqr(LocalPlayer():GetPos())
    local wantedopacity = distance > sPrinter.config["maxdrawdistance"] and 0 or 255

    return slib.lerpNum(ent, wantedopacity, 2, RealFrameTime())
end

sPrinter.drawLogo = function(ent, id)
    local logo = slib.ImgurGetMaterial(id)
    if !logo then return end

    local class = ent:GetClass()
    local data = sPrinter.config["logo"][class] or sPrinter.config["logo"][ent.Base]
    local pos = ent:LocalToWorld(data.pos)
	local ang = ent:LocalToWorldAngles(data.ang)
    local size = data.size

	vgui.Start3D2DS( pos, ang, .03 )
        surface.SetDrawColor(white)
        surface.SetMaterial(logo)
        surface.DrawTexturedRect(-(size.w * .5),-(size.h * .5),size.w,size.h)
	vgui.End3D2DS()
end

net.Receive("sP:Networking", function(len)
    local ent = net.ReadEntity()
    local action = net.ReadUInt(2)
    if !IsValid(ent) then return end

    if action == 0 then
        local upgrade = net.ReadUInt(3)
        local stage = net.ReadUInt(4)

        ent.data.upgrades[upgrade].stage = stage
    elseif action == 1 then
        local setting = net.ReadUInt(3)
        local status = net.ReadBool()
        ent.settings[setting] = status

        hook.Run("sP:SettingsNetworked", ent, setting)
    elseif action == 2 then
        local chunk = net.ReadUInt(32)
        local data = net.ReadData(chunk)

        data = util.Decompress(data)
        data = util.JSONToTable(data)

        if istable(ent.logs) then
            local setting = #ent.logs + 1
            ent.logs[setting] = data

            hook.Run("sP:LogsNetworked", ent, setting)
        end
    elseif action == 3 then
        local bool = net.ReadBool()
        local sid64 = LocalPlayer():SteamID64()
        ent.authorized[sid64] = bool or nil
    end
end)

local lastMouseStatus, nextThink = nil, 0

hook.Add("Think", "sP:ToggleScreenMode", function(enabled)
    if nextThink > CurTime() then return end
    
    local prev = lastMouseStatus

    lastMouseStatus = gui.MouseX() != 0 or gui.MouseY() != 0

    if prev != lastMouseStatus then
        hook.Run("sP:MouseEnabled", lastMouseStatus)
    end

    nextThink = CurTime() + .5
end)

hook.Add("HUDShouldDraw", "noCrosshairOnScreen", function(n)
    if n == "CHudCrosshair" and (CurTime() - (isDrawingCursor or 0) < .1) then return false end
end)

hook.Add("sP:SettingsNetworked", "sP:UpdateSettings", UpdatedSetting)

hook.Add("sP:LogsNetworked", "sP:AddLogsCanvas", function(ent, setting)
    for canvas,v in pairs(logsEntryCanvas) do
        if v ~= ent then continue end
        addLogEntry(canvas, ent, setting)
    end
end) --- Add log entries!    ​​  ​0      0