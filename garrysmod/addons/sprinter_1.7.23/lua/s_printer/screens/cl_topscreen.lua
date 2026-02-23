local margin, accent_col, successcolor, failcolor, main_col, shade_10, shade_20, shade_min10, text_col, text_colmin40, white, orange, transparent = 8, slib.getTheme("accentcolor"), slib.getTheme("successcolor"), slib.getTheme("failcolor"), slib.getTheme("maincolor"), slib.getTheme("maincolor", 10), slib.getTheme("maincolor", 20), slib.getTheme("maincolor", -10), slib.getTheme("textcolor"), slib.getTheme("textcolor", -40), Color(255,255,255), Color(189, 75, 0), Color(0,0,0,0)

local pages = {}

local function setActivePage(parent, page)
    for pnl, name in pairs(pages[parent]) do
        if !IsValid(pnl) then pages[parent][pnl] = nil continue end
        pnl:SetVisible(page == name)
    end

    parent.page = page
end

local function createPage(ent, parent, name, topbar, disabled)
    local page = vgui.Create("EditablePanel", parent)
    page:Dock(FILL)
    page:DockPadding(margin,margin,margin,margin)

    pages[ent] = pages[ent] or {}
    pages[ent][page] = name

    return page
end

local back_ico, logs_ico, upgrades_ico, settings_ico = Material("sprinter/back.png", "smooth"), Material("sprinter/log.png", "smooth"), Material("sprinter/upgrade.png", "smooth"), Material("sprinter/settings.png", "smooth")

local function getScrollpage(parent, func)
    local w, h = 630, 271
    local scroller = vgui.Create("SScrollPanel", parent)
    scroller:SetSize(w, h)
    scroller:GetCanvas():DockPadding(margin,margin,margin,margin)

    func(scroller)

    local scroller_scrollbar = scroller:GetVBar()

    local upButtn = vgui.Create("SButton", scroller_scrollbar)
    upButtn:SetSize(scroller_scrollbar:GetWide(), h * .5)
    upButtn.Paint = function(s)
        if input.IsKeyDown(KEY_E) and s.Hovered and (!s.lastClick or (CurTime() - s.lastClick > .2)) then
            s.lastClick = CurTime()
            s.DoClick()
        end
    end

    upButtn.DoClick = function(num)
        local curScroll = scroller_scrollbar:GetScroll()
        scroller_scrollbar:SetScroll(curScroll - (40 + margin))
    end

    local downButtn = vgui.Create("SButton", scroller_scrollbar)
    downButtn:SetSize(scroller_scrollbar:GetWide(), h * .5)
    downButtn:SetPos(0, h * .5)
    downButtn.Paint = function(s)
        if input.IsKeyDown(KEY_E) and s.Hovered and (!s.lastClick or (CurTime() - s.lastClick > .2)) then
            s.lastClick = CurTime()
            s.DoClick()
        end
    end

    downButtn.DoClick = function(num)
        local curScroll = scroller_scrollbar:GetScroll()
        scroller_scrollbar:SetScroll(curScroll + (40 + margin))
    end

    return scroller
end

sPrinter.drawTopScreen = function(ent, opacity)
    if IsValid(ent:GetRack()) and sPrinter.config["disable_topscreen_in_rack"] then if IsValid(ent.topScreen) then ent.topScreen:Remove() end return end
    
    if !IsValid(ent.topScreen) then
        ent.topScreen = vgui.Create("EditablePanel")
        ent.topScreen:SetSize(630, 356)
        ent.topScreen:DockPadding(0, 45, 0, 0)
        ent.topScreen:SetPaintedManually(true)

        ent.topScreen.Paint = function(s,w,h)
            if s:IsMouseInputEnabled() == sPrinter.isMouseEnabled then s:SetMouseInputEnabled(!sPrinter.isMouseEnabled) end
            
            surface.SetDrawColor(main_col)
            surface.DrawRect(0,0,w,h)
        end

        ent.topScreen.PaintOver = function(s,w,h)
            if ent:GetLocked() then
                sPrinter.DrawLocked(w,h)
            end

            sPrinter.DrawCursor(w, h, ent, 5)
        end

        local hookName = "sP:DisableScreen_"..ent:EntIndex()
        hook.Add("sP:MouseEnabled", hookName, function(enabled)
            if !IsValid(ent) or !IsValid(ent.topScreen) then hook.Remove("sP:MouseEnabled", hookName) return end

            ent.topScreen:SetMouseInputEnabled(!enabled)
        end)

        sPrinter.addTopbar(ent.topScreen, ent)

        local topbar = vgui.Create("EditablePanel", ent.topScreen)
        topbar:SetPos(0, 45)
        topbar:SetSize(ent.topScreen:GetWide(), 40)
        topbar.Paint = function(s,w,h)
            surface.SetDrawColor(shade_10)
            surface.DrawRect(0,0,w,h)

            surface.SetDrawColor(shade_20)
            surface.DrawRect(0,h - 1,w,1)

            draw.SimpleText(ent.page or "", slib.createFont("NasalizationRg-Regular", 32, nil, true), w * .5, h * .5, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local back = vgui.Create("SButton", topbar)
        back:SetPos(5,0)
        back:SetSize(40,40)
        back.Paint = function(s,w,h)
            if s.Hovered and !sPrinter.ShouldDraw(ent) then s.Hovered = false end
            surface.SetDrawColor(slib.lerpColor(s, ent.page == slib.getLang("sprinter", sPrinter.config["language"], "main") and transparent or (s.Hovered and accent_col or white)))
            surface.SetMaterial(back_ico)
            local iconsize = h * .8
            surface.DrawTexturedRect(w * .5 - iconsize * .5, h * .5 - iconsize * .5, iconsize, iconsize)
        end

        back.DoClick = function()
            if ent.page == slib.getLang("sprinter", sPrinter.config["language"], "main") then return end
            surface.PlaySound("buttons/button15.wav")
            setActivePage(ent, slib.getLang("sprinter", sPrinter.config["language"], "main"))
        end

        local canvas = vgui.Create("EditablePanel", ent.topScreen)
        canvas:SetSize(ent.topScreen:GetWide(), ent.topScreen:GetTall() - 85)
        canvas:SetPos(0,85)

        local mainpage = createPage(ent, canvas, slib.getLang("sprinter", sPrinter.config["language"], "main"), true, true)
        mainpage:DockPadding(0,0,0,0)

        local logs_bttn = sPrinter.addButton(mainpage, ent, slib.getLang("sprinter", sPrinter.config["language"], "logs"), function()
            setActivePage(ent, slib.getLang("sprinter", sPrinter.config["language"], "logs"))
            
            if !ent.addedLogs then
                ent.addedLogs = true
                net.Start("sP:Networking")
                net.WriteEntity(ent)
                net.WriteUInt(4,3)
                net.WriteUInt(2,2)
                net.SendToServer()
            end
        end, logs_ico, LEFT)
        logs_bttn.usewidth = true
        logs_bttn.fontsize = 32
        logs_bttn:DockMargin(margin,margin,0,margin)
        logs_bttn:SetWide((ent.topScreen:GetWide() - (margin * 4)) / 3)

        local upgrades_bttn = sPrinter.addButton(mainpage, ent, slib.getLang("sprinter", sPrinter.config["language"], "upgrades"), function() setActivePage(ent, slib.getLang("sprinter", sPrinter.config["language"], "upgrades")) end, upgrades_ico, LEFT)
        upgrades_bttn.usewidth = true
        upgrades_bttn.fontsize = 32
        upgrades_bttn:DockMargin(margin,margin,0,margin)
        upgrades_bttn:SetWide((ent.topScreen:GetWide() - (margin * 4)) / 3)

        local settings_bttn = sPrinter.addButton(mainpage, ent, slib.getLang("sprinter", sPrinter.config["language"], "settings"), function()
            setActivePage(ent, slib.getLang("sprinter", sPrinter.config["language"], "settings"))

            if !ent.addedSettings then
                ent.addedSettings = true
                net.Start("sP:Networking")
                net.WriteEntity(ent)
                net.WriteUInt(4,3)
                net.WriteUInt(1,2)
                net.SendToServer()
            end
        end, settings_ico, LEFT)
        settings_bttn.usewidth = true
        settings_bttn.fontsize = 32
        settings_bttn:DockMargin(margin,margin,0,margin)
        settings_bttn:SetWide((ent.topScreen:GetWide() - (margin * 4)) / 3)

        local logspage = createPage(ent, canvas, slib.getLang("sprinter", sPrinter.config["language"], "logs"), true)
        logspage:DockPadding(0,0,0,0)

        local logs_scroller = getScrollpage(logspage, function(scroller) sPrinter.addLogEntries(ent, scroller) end)


        local upgradespage = createPage(ent, canvas, slib.getLang("sprinter", sPrinter.config["language"], "upgrades"), true)
        upgradespage:DockPadding(0,0,0,0)
        
        local upgrades_scroller = getScrollpage(upgradespage, function(scroller) sPrinter.addUpgrades(ent, scroller) end)

        local settingspage = createPage(ent, canvas, slib.getLang("sprinter", sPrinter.config["language"], "settings"), true)
            
        sPrinter.addSettings(ent, settingspage)

        setActivePage(ent, slib.getLang("sprinter", sPrinter.config["language"], "main"))
        topbar:MoveToFront()
        
        return
    else
        ent.topScreen:SetAlpha(opacity)
    end

    local pos = ent:LocalToWorld(Vector(-22.85, 11.1, 4.6))
    local ang = ent:LocalToWorldAngles(Angle(0,0,0))

    vgui.Start3D2DS( pos, ang, .03 )
        ent.topScreen:SPaint3D2D(ent)
    vgui.End3D2DS()
end