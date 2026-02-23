local margin, accent_col, successcolor, main_col, shade_10, shade_min10, text_col, text_colmin40, white = 8, slib.getTheme("accentcolor"), slib.getTheme("successcolor"), slib.getTheme("maincolor"), slib.getTheme("maincolor", 10), slib.getTheme("maincolor", -10), slib.getTheme("textcolor"), slib.getTheme("textcolor", -40), Color(255,255,255)
local cursor, money, income, temperature, clockspeed, withdraw, eject, repair_ico = Material("sprinter/cursor.png", "smooth"), Material("sprinter/money.png", "smooth"), Material("sprinter/income.png", "smooth"), Material("sprinter/temperature.png", "smooth"), Material("sprinter/chip.png", "smooth"), Material("sprinter/withdraw.png", "smooth"), Material("sprinter/eject.png", "smooth"), Material("sprinter/repair.png", "smooth")
local stats = {}

local function addSplitterFrame(parent)
    local frame = vgui.Create("EditablePanel", parent)
    frame:Dock(TOP)
    frame:SetTall(80)
    frame:DockPadding(0,0,0,margin)

    frame.ResizeChilds = function()
        for k,v in pairs(stats[frame]) do
            k.Resize()
        end
    end

    frame.OnSizeChanged = function(width)
        frame.ResizeChilds()
    end

    return frame
end

local function addStatToParent(ent, parent, icon, title, amount, prefix, suffix, identifier, lerpmultiplier)
    stats[parent] = stats[parent] or {}

    local stat = vgui.Create("EditablePanel", parent)
    stat:Dock(LEFT)
    stat:SetWide(50)
    stat.val = ""
    if table.Count(stats[parent]) < 1 then
        stat:DockMargin(0,0,margin,0)
    end

    stat.updateNum = function()
        stat.val = isfunction(amount) and amount() or amount
        stat.title = isfunction(title) and title() or title

        if isnumber(stat.val) then
            stat.val = slib.lerpNum(stat.title..tostring(icon)..identifier, stat.val, lerpmultiplier or 1)
            stat.val = string.Comma(stat.val)
        end
    end

    stat.Paint = function(s,w,h)
        if ent:drawingOverlay() then return end
        surface.SetDrawColor(shade_min10)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(shade_10)
        surface.DrawRect(0,0,h,h)

        surface.SetDrawColor(accent_col)
        surface.SetMaterial(icon)
        local iconsize = h * .7
        surface.DrawTexturedRect( h * .5 - iconsize * .5, h * .5 - iconsize * .5, iconsize, iconsize )

        local workarea = w - h
        s.updateNum()
        
        draw.SimpleText((prefix and prefix or "")..s.val..(suffix and suffix or ""), slib.createFont("NasalizationRg-Regular", 38, nil, true), h + margin, margin * .5, text_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(s.title, slib.createFont("NasalizationRg-Regular", 26, nil, true), h + margin, h - margin * .5, text_colmin40, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    stat.Resize = function()
        stat:SetWide(parent:GetWide() / math.Clamp(table.Count(stats[parent]), 1, 99) - (margin / table.Count(stats[parent])))
    end

    stats[parent][stat] = true

    parent.ResizeChilds()
end

sPrinter.drawSideScreen = function(ent, opacity)
    if !IsValid(ent.sideScreen) then
        ent.sideScreen = vgui.Create("EditablePanel")
        ent.sideScreen:SetSize(630, 263)
        ent.sideScreen:DockPadding(margin,margin + 45,margin,margin)
        ent.sideScreen:SetPaintedManually(true)

        local hookName = "sP:DisableScreen_"..ent:EntIndex()
        hook.Add("sP:MouseEnabled", hookName, function(enabled)
            if !IsValid(ent) or !IsValid(ent.sideScreen) then hook.Remove("sP:MouseEnabled", hookName) return end

            ent.sideScreen:SetMouseInputEnabled(!enabled)
        end)

        ent.sideScreen.Paint = function(s,w,h)
            surface.SetDrawColor(main_col)
            surface.DrawRect(0,0,w,h)
        end

        ent.sideScreen.PaintOver = function(s,w,h)
            if ent:GetLocked() then
                sPrinter.DrawLocked(w,h)
            end


            sPrinter.DrawCursor(w, h, ent, 20)
        end

        sPrinter.addTopbar(ent.sideScreen, ent)

        local mainstats = addSplitterFrame(ent.sideScreen)
        addStatToParent(ent, mainstats, money, function() return "/"..string.Comma(ent:GetMaxStorage()) end, function() return ent:GetWithdrawAmount() end, sPrinter.config["currency"], nil,tostring(function() end))
        addStatToParent(ent, mainstats, income, slib.getLang("sprinter", sPrinter.config["language"], "income"), function() local clockspeed = ent:GetUpgrade("overclocking") return (ent.data.baseincome * (clockspeed + ent.data.clockspeed)) * 6 end, "+", nil, tostring(function() end))

        local miscstats = addSplitterFrame(ent.sideScreen)
        addStatToParent(ent, miscstats, clockspeed, slib.getLang("sprinter", sPrinter.config["language"], "clockspeed"), function() local clockspeed = ent:GetUpgrade("overclocking") return ent.data.clockspeed + clockspeed end, nil, " Ghz", tostring(function() end))
        addStatToParent(ent, miscstats, temperature, slib.getLang("sprinter", sPrinter.config["language"], "temperature"), function() return ent:GetTemperature() end, nil, "°", tostring(function() end), .1)

        local buttons = vgui.Create("EditablePanel", ent.sideScreen)
        buttons:Dock(FILL)

        sPrinter.addButton(buttons, ent, slib.getLang("sprinter", sPrinter.config["language"], "withdraw"), function() net.Start("sP:Networking") net.WriteEntity(ent) net.WriteUInt(1,3) net.WriteUInt(1,2) net.SendToServer() end, withdraw, RIGHT)
        sPrinter.addButton(buttons, ent, slib.getLang("sprinter", sPrinter.config["language"], "eject"), function() net.Start("sP:Networking") net.WriteEntity(ent) net.WriteUInt(1,3) net.WriteUInt(2,2) net.SendToServer() end, eject, RIGHT, margin, function() return IsValid(ent:GetRack()) end)
        
        local condition = vgui.Create("EditablePanel", buttons)
        condition:Dock(FILL)
        condition:DockMargin(0,0,margin,0)

        condition.Paint = function(s,w,h)
            if ent:drawingOverlay() then return end

            surface.SetDrawColor(shade_10)
            surface.DrawRect(0, 0, w, h)
            
            local statusbarx, statusbary, statusbarw, statusbarh = margin + (h * .8) + margin, h * .10, w - ((h * .8) + margin) - margin - 3, 20

            surface.SetDrawColor(main_col)
            surface.DrawRect(statusbarx, statusbary, statusbarw, statusbarh)

            surface.SetDrawColor(successcolor)
            surface.DrawRect(statusbarx, statusbary, statusbarw * (ent:Health() / 100), statusbarh)

            draw.SimpleText(math.Round(ent:Health()).."%", slib.createFont("NasalizationRg-Regular", 22, nil, true), statusbarx + 3, statusbary + statusbarh * .5, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            draw.SimpleText(slib.getLang("sprinter", sPrinter.config["language"], "condition"), slib.createFont("NasalizationRg-Regular", 17, nil, true), margin + (h * .8) + margin, h * .3 + 12, text_colmin40, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local repair = vgui.Create("SButton", condition)
        repair.Paint = function(s,w,h)
            if ent:drawingOverlay() then return end
            if s.Hovered and !sPrinter.ShouldDraw(ent) then s.Hovered = false end
            surface.SetDrawColor(slib.lerpColor(s, s.Hovered and accent_col or white))
            surface.SetMaterial(repair_ico)
            local iconsize = h * .8
            surface.DrawTexturedRect(margin, h * .5 - iconsize * .5, iconsize, iconsize)
        end

        repair.DoClick = function()
            surface.PlaySound("buttons/button15.wav")
            
            sPrinter.MakePopup(ent, ent.sideScreen, slib.getLang("sprinter", sPrinter.config["language"], "this-will-cost", sPrinter.config["currency"]..string.Comma(ent.data.repairprice)), function()
                net.Start("sP:Networking")
                net.WriteEntity(ent)
                net.WriteUInt(2,3)
                net.WriteUInt(2,2)
                net.SendToServer()
            end)
        end

        condition.OnSizeChanged = function(s,w,h)
            repair:SetSize(h,h)
        end

        return
    else
        ent.sideScreen:SetAlpha(opacity)
    end

    local pos = ent:LocalToWorld(Vector(-22.83, -0.080310, 3.837402))
	local ang = ent:LocalToWorldAngles(Angle(0,0,90))

	vgui.Start3D2DS( pos, ang, .03 )
        ent.sideScreen:SPaint3D2D(ent)
    vgui.End3D2DS()
end