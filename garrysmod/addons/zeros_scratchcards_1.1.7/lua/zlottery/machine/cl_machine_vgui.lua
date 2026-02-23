if SERVER then return end

//// UTILITY
local function ImageGallery(OnImageSelected)

    if IsValid(zlt_Machine_panel.OptionPanel) then zlt_Machine_panel.OptionPanel:Remove() end

    local main = vgui.Create( "DPanel", zlt_Machine_panel )
    zlt_Machine_panel.Main_pnl:MoveToFront()
    main:SetSize(600 * zclib.wM, 800 * zclib.hM)
    local mainX,mainY = zlt_Machine_panel.Main_pnl:GetPos()
    main:SetPos(mainX ,mainY)
    main:MoveTo(mainX - 610 * zclib.wM,mainY,0.25,0,1,function() end)

    local title_font = zclib.GetFont("zclib_font_big")
    local txtW = zclib.util.GetTextSize(zlt.language["Cached Images"],title_font)
    if txtW >= (480 * zclib.wM) then
        title_font = zclib.GetFont("zclib_font_medium")
    end

    main.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])
        draw.RoundedBox(10, 50 * zclib.wM,70 * zclib.hM, w, 5 * zclib.hM, zclib.colors["ui01"])
        draw.SimpleText(zlt.language["Cached Images"], title_font, 50 * zclib.wM,15 * zclib.hM,zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    zlt_Machine_panel.OptionPanel = main


    local function GoBack()
        main:Remove()
        if zlt_Machine_panel.edit_buttons and IsValid(zlt_Machine_panel.edit_buttons[zlt_Machine_panel.SelectedOption]) then zlt_Machine_panel.edit_buttons[zlt_Machine_panel.SelectedOption]:DoClick() end
    end

    local close_btn = zclib.vgui.ImageButton(540 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,main,zclib.Materials.Get("back"),function()
        GoBack()
    end,false)
    close_btn.IconColor = zclib.colors["red01"]


    local scroll = vgui.Create( "DScrollPanel", main )
    scroll:SetSize(500 * zclib.wM, 675 * zclib.hM)
    scroll:SetPos(50 * zclib.wM, 90 * zclib.hM)
    scroll.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui00"])
    end

    local sbar = scroll:GetVBar()
    sbar:SetHideButtons( true )
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h) draw.RoundedBox(w, 0, 0, w, h, zclib.colors["text01"]) end

    local list = vgui.Create( "DIconLayout", scroll )
    list:Dock( FILL )
    list:SetSpaceY( 10 )
    list:SetSpaceX( 10 )
    list:DockMargin(10 * zclib.wM,0 * zclib.hM,10 * zclib.wM,0 * zclib.hM)
    list.Paint = function(s, w, h) end

    local itmSize = 500 / 4
    itmSize = itmSize - 20
    for imgurid,img_mat in pairs(zclib.Imgur.CachedMaterials) do
        if img_mat == nil then continue end
        if imgurid == nil then continue end
        local b = vgui.Create("DButton",list)
        list:Add(b)
        b:SetText("")
        b:SetSize(itmSize * zclib.wM, itmSize * zclib.hM )
        b.DoClick = function()
            OnImageSelected(imgurid)
            GoBack()
        end
        b.mat = img_mat
        b.Paint = function(s, w, h)
            if s.mat then
                surface.SetDrawColor(color_white)
                surface.SetMaterial(s.mat)
                surface.DrawTexturedRect(0,0,w,h)
            end
        end
    end
end

local function TitledTextEntry(parent,height,font,name,default,hasrefreshbutton,OnChange,OnRefresh,OnImageSelected)
    local m = vgui.Create("DPanel", parent)
    m:SetSize(600 * zclib.wM, height * zclib.hM)
    m:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
    m:Dock(TOP)
    m.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, 190 * zclib.wM, h, zclib.colors["ui01"])
        draw.SimpleText(name, zclib.GetFont("zclib_font_medium"), 10 * zclib.wM,h / 2,zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    // This is only really used for imgur image urls
    if OnImageSelected then
        // Adds button to open image gallery for cached imgur images

        local close_btn = zclib.vgui.ImageButton(0 * zclib.wM,0 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,m,zclib.Materials.Get("icon_loading"),function()
            ImageGallery(OnImageSelected)
        end,false)
        close_btn.IconColor = zclib.colors["blue01"]
        close_btn:Dock(RIGHT)
        close_btn:DockMargin(10 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
    end

    local txt = zclib.vgui.TextEntry(m,default,OnChange,hasrefreshbutton,OnRefresh)
    txt:Dock(FILL)
    txt:DockMargin(150 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
    txt.font = font
    txt.main = m
    return txt
end

local function TitledSlider(parent,text,start_val,onChange,height,OnValueChangeStop)
    local p = vgui.Create("DButton", parent)
    p.locked = false
    p.slideValue = start_val
    p.displayValue = math.Round(p.slideValue * 100)
    p:SetAutoDelete(true)
    p:SetText("")
    p.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui01"])

        draw.SimpleText(text, zclib.GetFont("zclib_font_medium"),10 * zclib.wM, h / 2, zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.SimpleText(s.displayValue, zclib.GetFont("zclib_font_medium"),w - 5 * zclib.wM, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        local AreaW = w * 0.45
        local AreaX = w * 0.42
        draw.RoundedBox(4, AreaX, h * 0.5, AreaW, 2 * zclib.hM, color_black)

        local boxHeight = h * 0.5
        local boxPosX = AreaW * s.slideValue
        draw.RoundedBox(4, (AreaX - (boxHeight / 2)) + boxPosX, boxHeight / 2, boxHeight, boxHeight, zclib.colors["text01"])

        if p.locked == true then
            draw.RoundedBox(4, 0, 0, w, h, zclib.colors["black_a100"])
        end

        if s:IsDown() then
            s.StartedDrag = true
            local x,_ = s:CursorPos()
            local min = AreaX
            local max = min + AreaW

            x = math.Clamp(x, min, max)

            local val = (1 / AreaW) * (x - min)

            s.slideValue = math.Round(val,2)

            if s.slideValue ~= s.LastValue then
                s.LastValue = s.slideValue

                if s.locked == true then return end
                pcall(onChange,s.slideValue,s)
            end
        else
            if s.StartedDrag == true then
                s.StartedDrag = nil
                pcall(OnValueChangeStop,s.slideValue,s)
            end
        end
    end
    p:SetSize(200 * zclib.wM,(height or 50) * zclib.hM )
    p:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
    p:Dock(TOP)
    return p
end

local function TitledCheckbox(parent,text,start_val,onclick)
    local p = vgui.Create("DButton", parent)
    p:SetSize(200 * zclib.wM,50 * zclib.hM )
    p.locked = false
    p.state = start_val
    p.slideValue = 0
    p.font = zclib.GetFont("zclib_font_medium")
    p:SetAutoDelete(true)
    p:SetText("")
    p.Paint = function(s, w, h)

        local BoxWidth = w * 0.2
        local BoxHeight = h * 0.5
        local BoxPosY = h * 0.25
        local BoxPosX = w * 0.78

        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui01"])
        draw.SimpleText(text, s.font, 10 * zclib.wM, h / 2, zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.RoundedBox(4, BoxPosX, BoxPosY, BoxWidth, BoxHeight, zclib.colors["black_a100"])

        if s.state then
            s.slideValue = Lerp(5 * FrameTime(), s.slideValue, 1)
        else
            s.slideValue = Lerp(5 * FrameTime(), s.slideValue, 0)
        end

        local col = zclib.util.LerpColor(s.slideValue, zclib.colors["red01"], zclib.colors["green01"])
        draw.RoundedBox(4, BoxPosX + (BoxWidth - BoxHeight) * s.slideValue, BoxPosY, BoxHeight, BoxHeight, col)

        if p.locked == true then
            draw.RoundedBox(4, BoxPosX, BoxPosY, BoxWidth, BoxHeight, zclib.colors["black_a100"])
        end
    end
    p:SetSize(600 * zclib.wM, 50 * zclib.hM)
    p:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
    p:Dock(TOP)
    p.DoClick = function(s)
        if p.locked == true then return end
        zclib.vgui.PlaySound("UI/buttonclick.wav")
        s.state = not s.state
        pcall(onclick,s.state)
    end

    timer.Simple(0,function()
        if not IsValid(p) then return end
        if zclib.util.GetTextSize(text,zclib.GetFont("zclib_font_medium")) >= (p:GetWide() - 100 * zclib.wM) then
            p.font = zclib.GetFont("zclib_font_mediumsmall")
        end
    end)


    return p
end

local function AddSeperator(parent)
    local seperator = vgui.Create("DPanel", parent)
    seperator:SetSize(600 * zclib.wM, 5 * zclib.hM)
    seperator:Dock(TOP)
    seperator:DockMargin(50 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
    seperator.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui01"])
    end
end

local function TitledComboBox(parent,data,default,OnSelect)

    local t_name = ""
    local t_col = zclib.colors["orange01"]

    if isstring(data) then
        t_name = data
    elseif istable(data) then
        t_name = data.name
        t_col = data.color
    end

    local m = vgui.Create("DPanel", parent)
    m:SetSize(600 * zclib.wM, 50 * zclib.hM)
    m:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
    m:Dock(TOP)
    m.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui01"])
        draw.SimpleText(t_name, zclib.GetFont("zclib_font_medium"), 10 * zclib.wM,h / 2,t_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local DComboBox = vgui.Create( "DComboBox", m )
    DComboBox:SetSize(200 * zclib.wM, 50 * zclib.hM)
    DComboBox:DockMargin(240 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
    DComboBox:Dock(FILL)
    if default then DComboBox:SetValue(default) end
    DComboBox:SetColor(zclib.colors["text01"] )
    DComboBox.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, zclib.colors["ui01"]) end
    DComboBox.OnSelect = function( s, index, value ,data_val) pcall(OnSelect,index,value,DComboBox,data_val) end

    DComboBox.main = m

    return DComboBox
end

local function ConfirmationWindow(parent,question,OnAccept,OnDecline)
    local bg_pnl = vgui.Create("DPanel", parent)
    bg_pnl:Dock(FILL)
    bg_pnl.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, zclib.colors["black_a200"])
    end
    bg_pnl.Think = function()
        if input.IsKeyDown(KEY_ESCAPE) then
            bg_pnl:Remove()
        end
    end
    bg_pnl:InvalidateLayout(true)
    bg_pnl:InvalidateParent(true)

    local Main_pnl = vgui.Create("DPanel", bg_pnl)
    Main_pnl:SetSize(400 * zclib.wM, 200 * zclib.hM)
    Main_pnl:Center()
    Main_pnl.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])
        draw.SimpleText(question, zclib.GetFont("zclib_font_big"), w / 2, h * 0.3, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local close_btn = zclib.vgui.ImageButton(250 * zclib.wM,110 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,Main_pnl,zclib.Materials.Get("close"),function()
        bg_pnl:Remove()
        pcall(OnDecline)
    end,false)
    close_btn.IconColor = zclib.colors["red01"]

    local accept_btn = zclib.vgui.ImageButton(100 * zclib.wM,110 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,Main_pnl,zclib.Materials.Get("accept"),function()
        bg_pnl:Remove()
        pcall(OnAccept)
    end,false)
    accept_btn.IconColor = zclib.colors["green01"]
end

local function TicketPreview(parent,data)

    local ticket_preview = vgui.Create("DPanel", parent)
    ticket_preview:SetSize(500 * zclib.wM, 250 * zclib.wM)
    ticket_preview.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, s.color)

        if s.bg_urlMAT then
            surface.SetDrawColor(s.bg_col)
            surface.SetMaterial(s.bg_urlMAT)
            surface.DrawTexturedRectRotated(w * s.bg_x,h * s.bg_y,w * 2 *  s.bg_scale_w,h * 2 * s.bg_scale_h,360 * s.bg_rot)
        end

        if s.symbol_urlMAT then
            surface.SetDrawColor(s.symbol_col)
            surface.SetMaterial(s.symbol_urlMAT)
            surface.DrawTexturedRectRotated(w * s.symbol_x,h * s.symbol_y,w * 2 *  s.symbol_scale_w,h * 2 * s.symbol_scale_h,360 * s.symbol_rot)
        end

        local pW = zclib.util.GetTextSize(s.price,zclib.GetFont("zclib_font_medium"))
        local bW = 40 * zclib.wM + pW
        draw.RoundedBox(10, w - (bW - 10 * zclib.wM),10 * zclib.hM, bW, 30 * zclib.hM, s.price_bg_col)
        draw.SimpleText(s.price, zclib.GetFont("zclib_font_medium"),w - 20 * zclib.wM,25 * zclib.hM,s.price_col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        if s.scratch_urlMAT then
            local x , y = 2 * s.scratch_x , 2 * s.scratch_y
            local u0, v0 = 0 * s.scratch_scale + x,0 * s.scratch_scale + y
            local u1, v1 = 1 * s.scratch_scale + x,1 * s.scratch_scale + y
            surface.SetDrawColor(s.scratch_col or color_white)
            surface.SetMaterial(s.scratch_urlMAT)
            surface.DrawTexturedRectUV(w * 0.515, h * 0.225, w * 0.44, h * 0.635, u0, v0, u1, v1)
        end

        if s.logo_urlMAT then
            surface.SetDrawColor(s.logo_col)
            surface.SetMaterial(s.logo_urlMAT)
            surface.DrawTexturedRectRotated(w * s.logo_x,h * s.logo_y,w * s.logo_scale_w,h * s.logo_scale_h,360 * s.logo_rot)
        end

        if s.scratch_outline_type then
            surface.SetDrawColor(s.scratch_outline_col)
            surface.SetMaterial(zclib.Materials.Get(s.scratch_outline_type))
            surface.DrawTexturedRect(w * 0.51,h * 0.205, w * 0.452,h * 0.675)
        end

        draw.DrawText(s.title_val, zclib.GetFont(s.title_font), w * s.title_x, h * s.title_y, s.title_color, s.title_aligncenter)
        draw.DrawText(s.desc_val, zclib.GetFont("zclib_font_small"), w * s.desc_x, h * s.desc_y, s.desc_color, s.desc_aligncenter)

        //zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 5, zclib.colors["black_a100"])

        draw.WordBox( 2, 5 * zclib.wM, 5 * zclib.hM, data.uniqueid or "",zclib.GetFont("zclib_font_small"), zclib.colors["black_a200"], color_white )

        if s.rubbfield then
            surface.SetDrawColor(s.scratch_bg_col or color_white)
            surface.SetMaterial(s.rubbfield)
            surface.DrawTexturedRectRotated(290 * zclib.wM, 90 * zclib.hM,50 * zclib.wM, 50 * zclib.hM, 0)
        end
    end

    for k,v in pairs(zlt.Ticket.Structure) do
        if k == "price" then
            ticket_preview[k] = zclib.Money.Display(data[k] or v)
        else
            ticket_preview[k] = data[k] or v
        end
    end


    if data.scratch_url then
        zclib.Imgur.GetMaterial(tostring(data.scratch_url), function(result)
            if result and IsValid(ticket_preview) then
                ticket_preview.scratch_urlMAT = result
            end
        end)
    end

    if data.logo_url then
        zclib.Imgur.GetMaterial(tostring(data.logo_url), function(result)
            if result and IsValid(ticket_preview) then
                ticket_preview.logo_urlMAT = result
            end
        end)
    end

    if data.bg_url then
        zclib.Imgur.GetMaterial(tostring(data.bg_url), function(result)
            if result and IsValid(ticket_preview) then
                ticket_preview.bg_urlMAT = result
            end
        end)
    end

    if data.symbol_url then
        zclib.Imgur.GetMaterial(tostring(data.symbol_url), function(result)
            if result and IsValid(ticket_preview) then
                ticket_preview.symbol_urlMAT = result
            end
        end)
    end


    return ticket_preview
end

local function TitledMultiText(parent,font,name,default,OnChange)
    local m = vgui.Create("DPanel", parent)
    m:SetSize(600 * zclib.wM, 330 * zclib.hM)
    m:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
    m:Dock(TOP)
    local txtW = zclib.util.GetTextSize(name,zclib.GetFont("zclib_font_medium"))
    m.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, txtW + 15 * zclib.wM, 40 * zclib.hM, zclib.colors["ui01"])
        draw.SimpleText(name, zclib.GetFont("zclib_font_medium"), 5 * zclib.wM,2 * zclib.hM,zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local p = vgui.Create("DTextEntry", m)
    p:Dock(FILL)
    p:DockMargin(0 * zclib.wM, 35 * zclib.hM, 0 * zclib.wM, 10 * zclib.hM)
    p:SetPaintBackground(false)
    p:SetUpdateOnType(true)
    p:SetMultiline(true)
    p:SetDrawLanguageID(false)
    p.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, zclib.colors["ui01"])

        if s:GetText() == "" and not s:IsEditing() then
            draw.SimpleText(default, font, 5 * zclib.wM, 5 * zclib.hM, zclib.colors["white_a15"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        s:DrawTextEntryText(color_white, zclib.colors["textentry"], color_white)
    end

    p.main = m

    p.OnValueChange = function(s, val)
        pcall(OnChange, val)
    end

    function p:PerformLayout()
    end

    function p:PerformLayout(width, height)
        self:SetFontInternal(font)
    end

    return p
end

local function TitledColormixer(parent,name,default,OnChange,OnValueChangeStop)
    local m = vgui.Create("DPanel", parent)
    m:SetSize(600 * zclib.wM, 125 * zclib.hM)
    m:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
    m:DockPadding(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,10 * zclib.hM)
    m:Dock(TOP)
    m.font =  zclib.GetFont("zclib_font_medium")
    m.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui01"])
        draw.SimpleText(name, s.font, 10 * zclib.wM,20 * zclib.hM,zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    // TODO Its stupid but InvalidateParent doesent want to work
    timer.Simple(0,function()
        if not IsValid(m) then return end
        local txtW = zclib.util.GetTextSize(name,zclib.GetFont("zclib_font_medium"))
        if txtW > m:GetWide() then
            m.font = zclib.GetFont("zclib_font_mediumsmall")
        end
    end)


    local colmix = vgui.Create("DColorMixer", m)
    colmix:SetSize(240 * zclib.wM, 100 * zclib.hM)
    colmix:DockMargin(10 * zclib.wM,40 * zclib.hM,10 * zclib.wM,0 * zclib.hM)
    colmix:Dock(FILL)
    colmix:SetPalette(false)
    colmix:SetAlphaBar(false)
    colmix:SetWangs(true)
    colmix:SetColor(default or color_white)
    colmix.ValueChanged = function(s,col)
        pcall(OnChange,col)

        zclib.Timer.Remove("zlt_colormixer_delay")
        zclib.Timer.Create("zlt_colormixer_delay",0.1,1,function()
            pcall(OnValueChangeStop,col)
        end)
    end
    m.colmix = colmix


    return m
end

local function SetupPage(parent,title,content,IsFrame,DontCenter,TitleWidth)
    if IsValid(parent.Main_pnl) then parent.Main_pnl:Remove() end

    local Main_pnl
    if IsFrame then
         Main_pnl = vgui.Create("DFrame", parent)
         Main_pnl:ShowCloseButton(false)
         Main_pnl:SetTitle("")
         Main_pnl:SetDraggable(false)
         Main_pnl:SetSizable(false)
         Main_pnl:DockPadding(0, 15 * zclib.hM, 0, 0)
    else
         Main_pnl = vgui.Create("DPanel", parent)
    end

    Main_pnl:SetSize(600 * zclib.wM, 800 * zclib.hM)
    Main_pnl:Center()
    Main_pnl.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])
        if IsFrame then
            surface.SetMaterial(zclib.Materials.Get("grib_horizontal"))
            surface.SetDrawColor(zclib.colors["white_a5"])
            surface.DrawTexturedRectUV(0, 0, w, 20 * zclib.hM, 0, 0, w / (20 * zclib.hM), (20 * zclib.hM) / (20 * zclib.hM))
        end
    end
    parent.Main_pnl = Main_pnl

    if IsValid(parent.Title_pnl) then parent.Title_pnl:Remove() end


    local title_font = zclib.GetFont("zclib_font_big")
    if TitleWidth then
        local txtW = zclib.util.GetTextSize(title,title_font)
        if txtW >= (TitleWidth * zclib.wM) then
            title_font = zclib.GetFont("zclib_font_mediumsmall")
        end
    end

    local top_pnl = vgui.Create("DPanel", parent.Main_pnl)
    top_pnl:SetSize(600 * zclib.wM, 80 * zclib.hM)
    top_pnl:Dock( TOP )
    top_pnl:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
    top_pnl.Paint = function(s, w, h)
        draw.RoundedBox(10, 50 * zclib.wM, h - 8 * zclib.hM, w, 5 * zclib.hM, zclib.colors["ui01"])
        draw.SimpleText(title, title_font, 50 * zclib.wM,35 * zclib.hM,zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    parent.Title_pnl = top_pnl

    pcall(content,Main_pnl,top_pnl)
end



//////////////

local MachineVGUI = {}
net.Receive("zlt_Machine_Open", function(len)
    zclib.Debug_Net("zlt_Machine_Open", len)
    LocalPlayer().zlt_Machine = net.ReadEntity()

    if IsValid(zlt_Machine_panel) then
        zlt_Machine_panel:Remove()
    end

    zlt_Machine_panel = vgui.Create("ZLT_MACHINE")
end)

function MachineVGUI:Init()
    self:SetSize(ScrW(),ScrH())
    self:Center()
    self:MakePopup()
    self:ShowCloseButton(false)
    self:SetTitle("")
    self:SetDraggable(false)
    self:SetSizable(false)
    self:DockPadding(0,0,0,0)

    self:MainMenu()
end

function MachineVGUI:Paint(w, h)
    if input.IsKeyDown(KEY_ESCAPE) then
        self:Close()
    end
end

function MachineVGUI:Close()
    if IsValid(zlt_Machine_panel) then
        zlt_Machine_panel:Remove()
    end

    LocalPlayer().zlt_Machine = nil
end



function MachineVGUI:MainMenu()

    if IsValid(self.OptionPanel) then self.OptionPanel:Remove() end

    SetupPage(self,zlt.language["Configuration"],function(main,top)

        main:SetDraggable(true)

        local close_btn = zclib.vgui.ImageButton(540 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("close"),function()
            self:Close()
        end,false)
        close_btn.IconColor = zclib.colors["red01"]

        local machine_button = zclib.vgui.TextButton(0, 0, 50,50, main, {
            Text01 = zlt.language["Edit Machine"],
        }, function()
            self:EditMachine(main:GetPos())
        end, false)
        machine_button:Dock(TOP)
        machine_button:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,10 * zclib.hM)

        AddSeperator(main)

        local main_button = zclib.vgui.TextButton(0, 0, 50,50, main, {
            Text01 = zlt.language["Main Config"],
        }, function()
            self:MainConfig(main:GetPos())
        end, false)
        main_button:Dock(TOP)
        main_button:DockMargin(50 * zclib.wM,20 * zclib.hM,50 * zclib.wM,0 * zclib.hM)

        local tickets_button = zclib.vgui.TextButton(0, 0, 50,50, main, {
            Text01 = zlt.language["Ticket Config"],
        }, function()
            self:TicketConfig()
        end, false)
        tickets_button:Dock(TOP)
        tickets_button:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,10 * zclib.hM)

        AddSeperator(main)

        local save_button = zclib.vgui.TextButton(0, 0, 50,50, main, {
            Text01 = zlt.language["Save Machines"],
        }, function()
            LocalPlayer():ConCommand("zlt_Machine_save")
        end, false)
        save_button:Dock(TOP)
        save_button:DockMargin(50 * zclib.wM,20 * zclib.hM,50 * zclib.wM,0 * zclib.hM)

        local remove_button = zclib.vgui.TextButton(0, 0, 50,50, main, {
            Text01 = zlt.language["Remove Machines"],
        }, function()
            LocalPlayer():ConCommand("zlt_Machine_remove")
            self:Close()
        end, false)
        remove_button:Dock(TOP)
        remove_button:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
    end,true)
end

function MachineVGUI:EditMachine(x,y)
    SetupPage(self,zlt.language["Edit Machine"],function(main,top)

        main:SetDraggable(true)
        main:SetPos(x,y)

        local ent = LocalPlayer().zlt_Machine
        local e_index = ent:EntIndex()
        local function SendNetVar(key, val)
            local dat = {
                key = key,
                val = val
            }

            local e_String = util.TableToJSON(dat)
            local e_Compressed = util.Compress(e_String)
            net.Start("zlt_Machine_NWVar_Update")
            net.WriteEntity(ent)
            net.WriteUInt(#e_Compressed, 16)
            net.WriteData(e_Compressed, #e_Compressed)
            net.SendToServer()
        end

        local m = vgui.Create("DPanel", main)
        m:SetSize(600 * zclib.wM, 150 * zclib.hM)
        m:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
        m:Dock(TOP)
        m.Paint = function(s, w, h) end

        // Color mixer for machine paint
        local col_main = zlt.Machine.GetData(e_index, "Paint")
        col_main = zclib.util.VectorToColor(col_main)
        local paint_color = TitledColormixer(m,zlt.language["Paint Color:"],col_main,function(col)
        end,function(col)
            SendNetVar("Paint", zclib.util.ColorToVector(col))
        end)
        paint_color:SetSize(245 * zclib.wM, 200 * zclib.hM)
        paint_color:DockMargin(0 * zclib.wM,0 * zclib.hM,10 * zclib.wM,0 * zclib.hM)
        paint_color:Dock(LEFT)

        // Color mixer for light color
        local col_light = zlt.Machine.GetData(e_index, "Light")
        col_light = zclib.util.VectorToColor(col_light)
        local light_color = TitledColormixer(m,zlt.language["Light Color:"],col_light,function(col)
        end,function(col)
            SendNetVar("Light", zclib.util.ColorToVector(col))
        end)
        light_color:SetSize(245 * zclib.wM, 200 * zclib.hM)
        light_color:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
        light_color:Dock(RIGHT)

        AddSeperator(main)

        main.LogoUrlTextEntry = TitledTextEntry(main,50,zclib.GetFont("zclib_font_medium"),zlt.language["Imgur ID:"],zlt.Machine.GetData(e_index, "Logo"),true,function(val)
        end,function(val)
            SendNetVar("Logo", val)
        end,function(val)
            main.LogoUrlTextEntry:SetValue(val)
            SendNetVar("Logo", val)
        end)

        TitledSlider(main, zlt.language["ScaleW:"], zlt.Machine.GetData(e_index, "LogoScaleW"), function(val,s)
            s.displayValue = math.Round(s.slideValue * 100)
        end, 40, function(val)
            SendNetVar("LogoScaleW", val)
        end)

        TitledSlider(main, zlt.language["ScaleH:"], zlt.Machine.GetData(e_index, "LogoScaleH"), function(val,s)
            s.displayValue = math.Round(s.slideValue * 100)
        end, 40, function(val)
            SendNetVar("LogoScaleH", val)
        end)

        TitledSlider(main, zlt.language["PosX:"],zlt.Machine.GetData(e_index, "LogoPosX"), function(val,s)
            s.displayValue = math.Round(s.slideValue * 100)
        end, 40, function(val)
            SendNetVar("LogoPosX", val)
        end)

        TitledSlider(main, zlt.language["PosY:"],zlt.Machine.GetData(e_index, "LogoPosY"), function(val,s)
            s.displayValue = math.Round(s.slideValue * 100)
        end, 40, function(val)
            SendNetVar("LogoPosY", val)
        end)

        AddSeperator(main)

        // 4 Slots with combo box to assign ticket ids
        local function AddSlot(id)
            local default = zlt.Machine.GetData(e_index, "Slot0" .. id)
            local ListID = zlt.Ticket.GetID(default)

            if ListID == nil or default == -1 then
                default = zlt.language["NONE"]
            else
                default = string.Replace(zlt.config.Tickets[ListID].title_val,"\n"," ") .. " [" .. zlt.config.Tickets[ListID].uniqueid .. "]"
            end

            local DComboBox = TitledComboBox(main,zlt.language["Slot"] .. id .. ":",default,function(index, value,pnl)
                local data = pnl:GetOptionData( index )
                SendNetVar("Slot0" .. id, data)
            end)
            DComboBox:AddChoice( zlt.language["NONE"],-1 )
            DComboBox:SetSortItems( false )
            for k,v in pairs(zlt.config.Tickets) do
                DComboBox:AddChoice(string.Replace(v.title_val, "\n", " ") .. " [" .. v.uniqueid .. "]", v.uniqueid)
            end
        end
        AddSlot(1)
        AddSlot(2)
        AddSlot(3)
        AddSlot(4)

        // Close
        local close_btn = zclib.vgui.ImageButton(540 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("back"),function()
            self:MainMenu()
        end,false)
        close_btn.IconColor = zclib.colors["orange01"]
    end,true)
end

function MachineVGUI:MainConfig(x,y)
    SetupPage(self,zlt.language["Main Config"],function(main,top)

        main:SetDraggable(true)
        main:SetPos(x,y)

        local ConfigData = {}

        // Store Config data inside local table
        ConfigData.Debug = zclib.config.Debug
        ConfigData.Currency = zclib.config.Currency
        ConfigData.CurrencyInvert = zclib.config.CurrencyInvert
        ConfigData.SelectedLanguage = zlt.config.SelectedLanguage
        ConfigData.AdminRanks = table.Copy(zclib.config.AdminRanks)
        ConfigData.Fonts = table.Copy(zlt.config.Fonts)
        ConfigData.AutoPickup = zlt.config.AutoPickup
        ConfigData.InstantUse = zlt.config.InstantUse

        local debug_pnl = TitledCheckbox(main,zlt.language["debug_title"],ConfigData.Debug,function()
            ConfigData.Debug = not ConfigData.Debug
        end)
        debug_pnl:SetTooltip(zlt.language["debug_desc"])

        local currency_pnl = TitledTextEntry(main,50, zclib.GetFont("zclib_font_medium"),zlt.language["currency_title"], ConfigData.Currency, false,function(val)
            ConfigData.Currency = val
        end,function() end)
        if ConfigData.Currency then currency_pnl:SetValue(ConfigData.Currency) end
        currency_pnl:SetTooltip(zlt.language["currency_desc"])
        currency_pnl:DockMargin(395 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
        currency_pnl.main.Paint = function(s, w, h)
            draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui01"])
            draw.SimpleText(zlt.language["currency_title"], zclib.GetFont("zclib_font_medium"), 10 * zclib.wM,h / 2,zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local currencyinv_pnl = TitledCheckbox(main,zlt.language["currencyinv_title"],ConfigData.CurrencyInvert,function()
            ConfigData.CurrencyInvert = not ConfigData.CurrencyInvert
        end)
        currencyinv_pnl:SetTooltip(zlt.language["currencyinv_desc"])


        local DComboBox = TitledComboBox(main,zlt.language["lang_title"],ConfigData.SelectedLanguage,function(index, value,pnl)
            local data = pnl:GetOptionData( index )
            ConfigData.SelectedLanguage = data
        end)
        DComboBox:AddChoice( "English","en" )
        DComboBox:AddChoice( "German","de" )
        DComboBox:AddChoice( "French","fr" )
        DComboBox:AddChoice( "Turkish","tr" )
        DComboBox:AddChoice( "Spanish","es" )
        DComboBox:AddChoice( "Polish","pl" )
        DComboBox:AddChoice( "Russian","ru" )
        DComboBox:AddChoice( "Chinese","cn" )
        DComboBox:SetTooltip(zlt.language["lang_desc"])
        DComboBox:DockMargin(395 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)

        local pickup_pnl = TitledCheckbox(main, zlt.language["invauto_title"], ConfigData.AutoPickup, function()
            ConfigData.AutoPickup = not ConfigData.AutoPickup
        end)
        pickup_pnl:SetTooltip(zlt.language["invauto_desc"])


        if ConfigData.InstantUse == nil then ConfigData.InstantUse = false end
        local instaUse_pnl = TitledCheckbox(main, zlt.language["instaUse_title"], ConfigData.InstantUse, function()
            ConfigData.InstantUse = not ConfigData.InstantUse
        end)
        instaUse_pnl:SetTooltip(zlt.language["instaUse_desc"])

        local admin_ranks_pnl = TitledMultiText(main, zclib.GetFont("zclib_font_medium"), zlt.language["admrnk_title"], zlt.language["rank_sep"], function(val)
            if val and val ~= "" and val ~= "\n" then
                ConfigData.AdminRanks = {}
                local perms = string.Split(val, "\n")

                for k, v in pairs(perms) do
                    if v == nil or v == "" then continue end
                    ConfigData.AdminRanks[v] = true
                end
            else
                ConfigData.AdminRanks = {}
            end
        end)
        admin_ranks_pnl.main:SetTall(150 * zclib.hM)
        if ConfigData.AdminRanks then
            local __string = ""

            for k, v in pairs(ConfigData.AdminRanks) do
                if k == nil or k == "" then continue end
                __string = __string .. tostring(k) .. "\n"
            end

            admin_ranks_pnl:SetValue(__string)
        end
        admin_ranks_pnl.main:SetTooltip(zlt.language["admrnk_desc"])


        local fonts_pnl = TitledMultiText(main, zclib.GetFont("zclib_font_medium"), zlt.language["font_title"], zlt.language["font_sep"], function(val)
            if val and val ~= "" and val ~= "\n" then
                ConfigData.Fonts = {}
                local perms = string.Split(val, "\n")
                for k, v in pairs(perms) do
                    if v == nil or v == "" then continue end
                    table.insert(ConfigData.Fonts,v)
                end
            else
                ConfigData.Fonts = {}
            end
        end)
        fonts_pnl.main:SetTall(170 * zclib.hM)
        fonts_pnl.main:DockMargin(50 * zclib.wM,0 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
        if ConfigData.Fonts then
            local __string = ""

            for k, v in pairs(ConfigData.Fonts) do
                if v == nil or v == "" then continue end
                __string = __string .. tostring(v) .. "\n"
            end

            fonts_pnl:SetValue(__string)
        end
        fonts_pnl.main:SetTooltip(zlt.language["font_desc"])


        // Close
        local close_btn = zclib.vgui.ImageButton(540 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("back"),function()
            self:MainMenu()
        end,false)
        close_btn.IconColor = zclib.colors["orange01"]

        // Save Button
        local save_btn = zclib.vgui.ImageButton(480 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("save"),function()
            // Send config to server
            zlt.Machine.UpdateConfig(ConfigData)

            // Close menu
            self:Close()
            //self:MainMenu()
        end,false)
        save_btn.IconColor = zclib.colors["green01"]
    end,true)
end



local SelectedTicket
function MachineVGUI:TicketConfig()
    zclib.vgui.PlaySound("zlt/ui_slide.wav")

    if IsValid(self.OptionPanel) then self.OptionPanel:Remove() end
    if IsValid(self.PrizePanel) then self.PrizePanel:Remove() end

    SetupPage(self,zlt.language["Ticket Config"],function(main,top)

        main:SetDraggable(true)

        // Close
        local close_btn = zclib.vgui.ImageButton(540 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("back"),function()
            self:MainMenu()
        end,false)
        close_btn.IconColor = zclib.colors["orange01"]

        // Edit
        local edit_btn = zclib.vgui.ImageButton(480 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("edit"),function()
            if SelectedTicket == nil or zlt.config.Tickets[SelectedTicket] == nil then return end
            self:TicketEditor(SelectedTicket)
        end,function()
            return SelectedTicket == nil or zlt.config.Tickets[SelectedTicket] == nil
        end)
        edit_btn.IconColor = zclib.colors["orange01"]
        edit_btn:SetTooltip(zlt.language["Edit Ticket"])

        // Remove
        local remove_btn = zclib.vgui.ImageButton(420 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("delete"),function()
            if SelectedTicket == nil or zlt.config.Tickets[SelectedTicket] == nil then return end
            self:RemoveTicket(SelectedTicket)
        end,function()
            return SelectedTicket == nil or zlt.config.Tickets[SelectedTicket] == nil
        end)
        remove_btn.IconColor = zclib.colors["red01"]
        remove_btn:SetTooltip(zlt.language["Delete Ticket"])

        // Duplicate
        local dupl_btn = zclib.vgui.ImageButton(360 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("duplicate"),function()
            if SelectedTicket == nil or zlt.config.Tickets[SelectedTicket] == nil then return end
            self:DuplicateTicket(SelectedTicket)
        end,function()
            return SelectedTicket == nil or zlt.config.Tickets[SelectedTicket] == nil
        end)
        dupl_btn.IconColor = zclib.colors["blue01"]
        dupl_btn:SetTooltip(zlt.language["Duplicate Ticket"])

        // Add
        local add_btn = zclib.vgui.ImageButton(300 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("plus"),function()
            self:TicketEditor(-1)
        end,false)
        add_btn.IconColor = zclib.colors["green01"]
        add_btn:SetTooltip(zlt.language["New Ticket"])

        // Show all the diffrent lottery tickets the player can buy
        self:TicketList()
    end,true,false,230)
end

function MachineVGUI:TicketList()
    ////////// CREATE LIST
    if IsValid(self.Main_pnl.Content) then self.Main_pnl.Content:Remove() end
    local Main = vgui.Create("DPanel", self.Main_pnl)
    Main:SetAutoDelete(true)
    Main:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
    Main:Dock( FILL )
    Main.Paint = function(s, w, h) end
    self.Main_pnl.Content = Main

    local scroll = vgui.Create( "DScrollPanel", Main )
    scroll:Dock( FILL )
    scroll:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,20 * zclib.hM)
    scroll.Paint = function(s, w, h) draw.RoundedBox(10, 0, 0, w, h, zclib.colors["ui00"]) end
    Main.scroll = scroll
    local sbar = scroll:GetVBar()
    sbar:SetHideButtons( true )
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h) draw.RoundedBox(w, 0, 0, w, h, zclib.colors["text01"]) end

    local list = vgui.Create( "DIconLayout", scroll )
    list:Dock( FILL )
    list:SetSpaceY( 10 )
    list:SetSpaceX( 0 )
    list:DockMargin(11 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
    list.Paint = function(s, w, h) end
    Main.list = list
    Main:InvalidateLayout(true)
    Main:InvalidateParent(true)
    scroll:InvalidateLayout(true)
    scroll:InvalidateParent(true)

    // POPULATE LIST
    local itmW = Main.scroll:GetWide() - 40 * zclib.wM
    for id, data in pairs(zlt.config.Tickets) do

        local ticket_preview = TicketPreview(Main,data)
        ticket_preview:SetSize(itmW, itmW / 2)
        Main.list:Add(ticket_preview)

        local btn = vgui.Create("DButton", ticket_preview)
        btn:Dock(FILL)
        btn:SetAutoDelete(true)
        btn:SetText("")
        btn.Paint = function(s, w, h)

            if SelectedTicket == id then


                //draw.RoundedBox(0, 0, h - 5 * zclib.hM, w, 5 * zclib.hM, color_white)
                zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 4, color_white)
            end


            if s:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, zclib.colors["white_a15"])
            end
        end
        btn.DoClick = function(s)
            zclib.vgui.PlaySound("UI/buttonclick.wav")
            SelectedTicket = id
        end
    end

    local shadow_bttm = vgui.Create("DPanel", Main)
    shadow_bttm:Dock( FILL )
    shadow_bttm:DockMargin(60 * zclib.wM,580 * zclib.hM,79 * zclib.wM,20 * zclib.hM)
    shadow_bttm.Paint = function(s, w, h)
        surface.SetDrawColor(color_black)
        surface.SetMaterial(zclib.Materials.Get("bottomshadow"))
        surface.DrawTexturedRectRotated(w / 2,(h / 2) + 5 * zclib.hM, w,h,0)
    end

    local shadow_top = vgui.Create("DPanel", Main)
    shadow_top:Dock( FILL )
    shadow_top:DockMargin(60 * zclib.wM,10 * zclib.hM,79 * zclib.wM,580 * zclib.hM)
    shadow_top.Paint = function(s, w, h)
        surface.SetDrawColor(color_black)
        surface.SetMaterial(zclib.Materials.Get("bottomshadow"))
        surface.DrawTexturedRectRotated(w / 2,(h / 2) - 5 * zclib.hM, w,h,180)
    end
end


local TicketData
function MachineVGUI:TicketEditor(id)
    zclib.vgui.PlaySound("zlt/ui_slide.wav")


    SetupPage(self,zlt.language["Details"],function(main,top)
        // back
        local close_btn = zclib.vgui.ImageButton(540 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("back"),function()
            self:TicketConfig()
        end,false)
        close_btn.IconColor = zclib.colors["red01"]

        TicketData = {}
        if zlt.config.Tickets[id] and istable(zlt.config.Tickets[id]) then
            TicketData = table.Copy(zlt.config.Tickets[id])
        else
            TicketData = table.Copy(zlt.Ticket.Structure)
            TicketData.symbol_url = "ZQmqdyX"
            TicketData.prizelist = {
                [1] = {
                    type = 1,
                	chance = 50,
                    final_chance = 50,
                },
                [2] = {
                    type = 2,
                	money = 10,
                	chance = 50,
                    final_chance = 50,
                },
            }
        end

        // Design Editor
        self:DesignEditor(main)

        AddSeperator(main)

        // Ticket Preview
        local ticket_preview = TicketPreview(main,TicketData)
        ticket_preview:SetSize(500 * zclib.wM, 250 * zclib.wM)
        ticket_preview:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
        ticket_preview:Dock( TOP )
        ticket_preview.rubbfield = zclib.Materials.Get("rubbfield04")
        self.Preview = ticket_preview

        // Prize List
        self:PrizeWindow()

        // Save Button
        local save_btn = zclib.vgui.ImageButton(480 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,top,zclib.Materials.Get("save"),function()
            if id == -1 then
                // Create ticket
                self:CreateTicket()
            else
                // Update ticket
                self:UpdateTicket(SelectedTicket)
            end
        end,false)
        save_btn.IconColor = zclib.colors["green01"]
    end)
end

function MachineVGUI:RemoveTicket(id)
    if id == nil or zlt.config.Tickets[id] == nil then return end

    ConfirmationWindow(self,zlt.language["Delete this ticket?"],function()
        table.remove(zlt.config.Tickets,id)
        self:UpdateServer()
        self:TicketConfig()
    end,function()
        // DO nuthin
    end)
end

function MachineVGUI:DuplicateTicket(id)
    if id == nil or zlt.config.Tickets[id] == nil then return end

    ConfirmationWindow(self,zlt.language["Duplicate this ticket?"],function()

        local data = table.Copy(zlt.config.Tickets[id])
        data.uniqueid = zclib.util.GenerateUniqueID("xxxxxxxxxx")
        table.insert(zlt.config.Tickets,data)

        self:UpdateServer()
        self:TicketConfig()
    end,function()
        // DO nuthin
    end)
end

function MachineVGUI:UpdateTicket(id)
    zlt.config.Tickets[id] = TicketData
    self:UpdateServer()
    self:TicketConfig()
end

function MachineVGUI:CreateTicket()
    TicketData.uniqueid = zclib.util.GenerateUniqueID("xxxxxxxxxx")
    table.insert(zlt.config.Tickets,TicketData)
    self:UpdateServer()
    self:TicketConfig()
end

function MachineVGUI:UpdateServer()
    // Send net msg to server
    zlt.Ticket.UpdateConfig(zlt.config.Tickets)
    TicketData = nil
end

function MachineVGUI:DesignEditor(main_parent)

    local OptionFields = {
        ["textentry"] = function(data,parent)
            local pnl = TitledTextEntry(parent, data.Height, zclib.GetFont("zclib_font_medium"), data.ValueType,data.empty or data.ValueType, data.showrefreshbutton, data.onchange, data.onrefresh,data.onimageselected)
            pnl:SetMultiline( data.SetMultiline )
            pnl:SetNumeric(data.SetNumeric)
            if data.default and TicketData[data.default] then pnl:SetValue(TicketData[data.default]) end
        end,
        ["multitext"] = function(data,parent)
            local pnl = TitledMultiText(parent, zclib.GetFont("zclib_font_medium"), data.ValueType,data.empty or data.ValueType, data.onchange)

            if data.default and TicketData[data.default] then
                local __string = ""

                for k, v in pairs(TicketData[data.default]) do
                    __string = __string .. tostring(v) .. "\n"
                end

                pnl:SetValue(__string)
            end

            //if data.default and TicketData[data.default] then pnl:SetValue(TicketData[data.default]) end
        end,
        ["colormixer"] = function(data,parent)

            local colmix = TitledColormixer(parent,data.ValueType,TicketData[data.default] or zlt.Ticket.Structure[data.default],function(col)
                pcall(data.onchange,col)
            end,function() end)
            colmix.colmix:SetAlphaBar(data.SetAlphaBar)
            if data.Height then colmix:SetSize(600 * zclib.wM, (data.Height or 125) * zclib.hM) end
        end,
        ["combobox"] = function(data,parent)
            local DComboBox = TitledComboBox(parent,data.ValueType,TicketData[data.default] or zlt.Ticket.Structure[data.default],function(index, value) pcall(data.onchange,value) end)
            for k,v in pairs(data.choices) do DComboBox:AddChoice( v ) end
        end,
        ["slider"] = function(data,parent)
            TitledSlider(parent,data.ValueType,TicketData[data.default] or zlt.Ticket.Structure[data.default],data.onchange,data.Height or 40)
        end,
        ["seperator"] = function(data,parent)
            AddSeperator(parent)
        end,
        ["checkbox"] = function(data,parent)
            TitledCheckbox(parent,data.ValueType,TicketData[data.default] or zlt.Ticket.Structure[data.default],data.onchange)
        end
    }

    local OptionsList = {}
    local function AddOption(data) table.insert(OptionsList,data) end

    local OptionTypes = {
        ["text_default"] = function(name,var)
            return {type = "textentry",ValueType = name,Height = 50,SetMultiline = false,SetNumeric = false,default = var,onchange = function(val)
                self.Preview[var] = val
                TicketData[var] = val
            end,showrefreshbutton = false,onrefresh = function() end}
        end,
        ["text_multi"] = function(name,var)
            return {type = "textentry",ValueType = name,Height = 100,SetMultiline = true,SetNumeric = false,default = var,onchange = function(val)
                self.Preview[var] = val
                TicketData[var] = val
            end,showrefreshbutton = false,onrefresh = function() end}
        end,
        ["text_url"] = function(name,var)
            return {type = "textentry",ValueType = name,Height = 50,SetMultiline = false,SetNumeric = false,default = var,onchange = function()
            end,showrefreshbutton = true,onrefresh = function(val)

                zclib.Imgur.GetMaterial(tostring(val), function(result)
                    if not IsValid(self) then return end
                    if not IsValid(self.Preview) then return end
                    self.Preview[var .. "MAT"] = result
                end)
                self.Preview[var] = val
                TicketData[var] = val
            end,onimageselected = function(imgid)

                zclib.Imgur.GetMaterial(tostring(imgid), function(result)
                    if not IsValid(self) then return end
                    if not IsValid(self.Preview) then return end
                    self.Preview[var .. "MAT"] = result
                end)
                self.Preview[var] = imgid
                TicketData[var] = imgid
            end}
        end,
        ["text_price"] = function(name,var)
            return {type = "textentry",ValueType = name,Height = 50,SetMultiline = false,SetNumeric = true,default = var,onchange = function(val)
                self.Preview[var] = zclib.Money.Display(tonumber(val))
                TicketData[var] = tonumber(val)
            end,showrefreshbutton = false,onrefresh = function() end}
        end,
        ["text_perms"] = function(name,var,empty)
            return {type = "multitext",ValueType = name,default = var,empty = empty,onchange = function(val)
                if val and val ~= "" and val ~= "\n" then
                    local perms = string.Split(val, "\n")
                    self.Preview[var] = perms or {}
                    TicketData[var] = perms or {}
                else
                    self.Preview[var] = {}
                    TicketData[var] = {}
                end
            end}
        end,
        ["color_default"] = function(name,var,height)
            return {type = "colormixer",ValueType = name,Height = height,SetAlphaBar = false,default = var,onchange = function(col)
                self.Preview[var] = col
                TicketData[var] = col
            end}
        end,
        ["color_alpha"] = function(name,var,height)
            return {type = "colormixer",ValueType = name,Height = height,SetAlphaBar = true,default = var,onchange = function(col)
                self.Preview[var] = col
                TicketData[var] = col
            end}
        end,
        ["combo_font"] = function(name,var,choices)
            return {type = "combobox",ValueType = name,choices = choices,default = var,onchange = function(font)
                self.Preview[var] = font
                TicketData[var] = font
            end}
        end,
        ["slider_pos"] = function(name,var)
            return {type = "slider",ValueType = name,default = var,onchange = function(val,pnl)
                self.Preview[var] = val
                TicketData[var] = val
                pnl.displayValue = math.Round(val * 100)
            end}
        end,
        ["slider_aligment"] = function(name,var)
            return {type = "slider",ValueType = zlt.language["Alignment:"],default = var,onchange = function(val,pnl)
                if val < 0.3 then
                    self.Preview[var] = TEXT_ALIGN_LEFT
                    TicketData[var] = TEXT_ALIGN_LEFT

                    pnl.displayValue = "L"
                elseif val < 0.6 then
                    self.Preview[var] = TEXT_ALIGN_CENTER
                    TicketData[var] = TEXT_ALIGN_CENTER

                    pnl.displayValue = "C"
                else
                    self.Preview[var] = TEXT_ALIGN_RIGHT
                    TicketData[var] = TEXT_ALIGN_RIGHT

                    pnl.displayValue = "R"
                end
            end}
        end,
    }
    local function AddOptionType(type,name,var,empty) return OptionTypes[type](name,var,empty) end

    // Title
    local fontList = {}
    for k,v in pairs(zlt.config.Fonts) do table.insert(fontList, "zlt_ticket_title0" .. k) end
    AddOption({
        name = zlt.language["Title"],
        fields = {
            [1] = AddOptionType("text_multi",zlt.language["Text:"],"title_val"),
            [2] = AddOptionType("combo_font",zlt.language["Font:"],"title_font",fontList),
            [3] = AddOptionType("color_alpha",zlt.language["Text Color:"],"title_color"),
            [4] = AddOptionType("slider_pos",zlt.language["PosX:"],"title_x"),
            [5] = AddOptionType("slider_pos",zlt.language["PosY:"],"title_y"),
            [6] = AddOptionType("slider_aligment",zlt.language["Alignment:"],"title_aligncenter"),
        }
    })

    // Background
    AddOption({
        name = zlt.language["Background"],
        fields = {
            [1] = AddOptionType("color_default",zlt.language["Background Color:"],"color"),
            [2] = {type = "seperator"},
            [3] = AddOptionType("text_url",zlt.language["Imgur ID:"],"bg_url"),
            [4] = AddOptionType("color_alpha",zlt.language["Image Color:"],"bg_col"),
            [5] = AddOptionType("slider_pos",zlt.language["PosX:"],"bg_x"),
            [6] = AddOptionType("slider_pos",zlt.language["PosY:"],"bg_y"),
            [7] = AddOptionType("slider_pos",zlt.language["Rotation:"],"bg_rot"),
            [8] = AddOptionType("slider_pos",zlt.language["ScaleW:"],"bg_scale_w"),
            [9] = AddOptionType("slider_pos",zlt.language["ScaleH:"],"bg_scale_h"),
        }
    })

    // Extra Symbol
    AddOption({
        name = zlt.language["Symbol"],
        fields = {
            [1] = AddOptionType("text_url",zlt.language["Imgur ID:"],"symbol_url"),
            [2] = AddOptionType("color_alpha",zlt.language["Image Color:"],"symbol_col"),
            [3] = AddOptionType("slider_pos",zlt.language["PosX:"],"symbol_x"),
            [4] = AddOptionType("slider_pos",zlt.language["PosY:"],"symbol_y"),
            [5] = AddOptionType("slider_pos",zlt.language["Rotation:"],"symbol_rot"),
            [6] = AddOptionType("slider_pos",zlt.language["ScaleW:"],"symbol_scale_w"),
            [7] = AddOptionType("slider_pos",zlt.language["ScaleH:"],"symbol_scale_h"),
        }
    })

    // Description
    AddOption({
        name = zlt.language["Description"],
        fields = {
            [1] = AddOptionType("text_default", zlt.language["Text:"], "desc_val"),
            [2] = AddOptionType("color_alpha", zlt.language["Text Color:"], "desc_color"),
            [3] = AddOptionType("slider_pos", zlt.language["PosX:"], "desc_x"),
            [4] = AddOptionType("slider_pos", zlt.language["PosY:"], "desc_y"),
            [5] = AddOptionType("slider_aligment", zlt.language["Alignment:"], "desc_aligncenter")
        }
    })

    // Scratch field
    AddOption({
        name = zlt.language["Scratch Field"],
        fields = {
            [1] = AddOptionType("text_url",zlt.language["Imgur ID:"],"scratch_url"),
            [2] = AddOptionType("color_default",zlt.language["Image Color:"],"scratch_col"),
            [3] = AddOptionType("slider_pos",zlt.language["PosX:"],"scratch_x"),
            [4] = AddOptionType("slider_pos",zlt.language["PosY:"],"scratch_y"),
            [5] = AddOptionType("slider_pos",zlt.language["Scale:"],"scratch_scale"),
            [6] = {type = "seperator"},
            [7] = AddOptionType("combo_font",zlt.language["Outline Type:"],"scratch_outline_type",{"border01","border02","border03","border04","border05"}),
            [8] = AddOptionType("color_alpha",zlt.language["Outline Color:"],"scratch_outline_col"),
            [9] = {type = "seperator"},
            [10] = AddOptionType("color_default",zlt.language["Background Color:"],"scratch_bg_col",125),
        }
    })

    // Logo
    AddOption({
        name = zlt.language["Logo"],
        fields = {
            [1] = AddOptionType("text_url",zlt.language["Imgur ID:"],"logo_url"),
            [2] = AddOptionType("color_alpha",zlt.language["Image Color:"],"logo_col"),
            [3] = AddOptionType("slider_pos",zlt.language["PosX:"],"logo_x"),
            [4] = AddOptionType("slider_pos",zlt.language["PosY:"],"logo_y"),
            [5] = AddOptionType("slider_pos",zlt.language["Rotation:"],"logo_rot"),
            [6] = AddOptionType("slider_pos",zlt.language["ScaleW:"],"logo_scale_w"),
            [7] = AddOptionType("slider_pos",zlt.language["ScaleH:"],"logo_scale_h"),
        }
    })

    // Price
    AddOption({
        name = zlt.language["Price"],
        fields = {
            [1] = AddOptionType("text_price",zlt.language["Price"] .. ":","price"),
            [2] = AddOptionType("color_default",zlt.language["Text Color:"],"price_col"),
            [3] = AddOptionType("color_alpha",zlt.language["Background Color:"],"price_bg_col"),
        }
    })

    // Restriction
    AddOption({
        name = zlt.language["Restriction"],
        fields = {
            [1] = AddOptionType("text_perms",zlt.language["Ranks"],"ranks",zlt.language["rank_sep"]),
            [2] = {type = "seperator"},
            [3] = AddOptionType("text_perms",zlt.language["Jobs"],"jobs",zlt.language["jobs_sep"]),
        }
    })

    // Add the Edit Buttons
    local mainX,mainY = self.Main_pnl:GetPos()
    self.edit_buttons = {}
    for optionid,optionData in pairs(OptionsList) do

        local btn = zclib.vgui.TextButton(0,0,600,45,main_parent,{Text01 = optionData.name},function()

            if IsValid(self.OptionPanel) then self.OptionPanel:Remove() end

            local OptionPanel = vgui.Create("DPanel", self)
            self.Main_pnl:MoveToFront()
            OptionPanel:SetSize(600 * zclib.wM, 800 * zclib.hM)
            OptionPanel:SetPos(mainX ,mainY)
            OptionPanel:MoveTo(mainX - 610 * zclib.wM,mainY,0.25,0,1,function() end)
            OptionPanel:DockPadding(0,80 * zclib.hM,0,0)
            OptionPanel.Paint = function(s, w, h)
                draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])
                draw.RoundedBox(10, 50 * zclib.wM,70 * zclib.hM, w, 5 * zclib.hM, zclib.colors["ui01"])
                draw.SimpleText(optionData.name, zclib.GetFont("zclib_font_big"), 50 * zclib.wM,15 * zclib.hM,zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
            self.OptionPanel = OptionPanel

            self.SelectedOption = optionid

            for _,field_data in ipairs(optionData.fields) do
                OptionFields[field_data.type](field_data,OptionPanel)
            end
        end,false,function()
            return self.SelectedOption == optionid
        end,"zlt/ui_slide.wav")
        btn:DockMargin(50 * zclib.wM,8 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
        btn:Dock(TOP)
        table.insert(self.edit_buttons,btn)
    end
    if IsValid(self.edit_buttons[1]) then self.edit_buttons[1]:DoClick() end
end




local SelectedPrizeID
function MachineVGUI:PrizeWindow()

    local mainX,mainY = self.Main_pnl:GetPos()

    if IsValid(self.PrizePanel) then self.PrizePanel:Remove() end
    local PrizePanel = vgui.Create("DPanel", self)
    self.Main_pnl:MoveToFront()
    PrizePanel:SetSize(600 * zclib.wM, 800 * zclib.hM)
    PrizePanel:SetPos(mainX ,mainY)
    PrizePanel:MoveTo(mainX + 610 * zclib.wM,mainY,0.25,0,1,function() end)
    PrizePanel.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])
        draw.RoundedBox(10, 50 * zclib.wM,70 * zclib.hM, w, 5 * zclib.hM, zclib.colors["ui01"])
        draw.SimpleText(zlt.language["Prize Pool"], zclib.GetFont("zclib_font_big"), 50 * zclib.wM,15 * zclib.hM,zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(zlt.language["Prize Type"], zclib.GetFont("zclib_font_medium"), 60 * zclib.wM,80 * zclib.hM,zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(zlt.language["Chance"], zclib.GetFont("zclib_font_medium"), w - 60 * zclib.wM,80 * zclib.hM,zclib.colors["text01"], TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end
    self.PrizePanel = PrizePanel


    // Edit
    local edit_btn = zclib.vgui.ImageButton(540 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,PrizePanel,zclib.Materials.Get("edit"),function()
        if SelectedPrizeID == nil or TicketData.prizelist[SelectedPrizeID] == nil then return end
        self:PrizeEditor(SelectedPrizeID)
    end,function()
        return SelectedPrizeID == nil or TicketData.prizelist[SelectedPrizeID] == nil
    end)
    edit_btn.IconColor = zclib.colors["orange01"]


    // Remove
    local remove_btn = zclib.vgui.ImageButton(480 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,PrizePanel,zclib.Materials.Get("delete"),function()
        if SelectedPrizeID == nil or TicketData.prizelist[SelectedPrizeID] == nil then return end
        ConfirmationWindow(PrizePanel,zlt.language["Delete this prize?"],function()
            TicketData.prizelist[SelectedPrizeID] = nil
            self:PrizeWindow()
        end,function()
        end)
    end,function()
        return SelectedPrizeID == nil or TicketData.prizelist[SelectedPrizeID] == nil
    end)
    remove_btn.IconColor = zclib.colors["red01"]


    // Add
    local add_btn = zclib.vgui.ImageButton(420 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,PrizePanel,zclib.Materials.Get("plus"),function()
        self:PrizeEditor(-1)
    end,false)
    add_btn.IconColor = zclib.colors["green01"]


    local PrizeList_pnl = vgui.Create( "DPanel", PrizePanel )
    PrizeList_pnl:Dock( FILL )
    PrizeList_pnl:DockMargin(50 * zclib.wM,115 * zclib.hM,50 * zclib.wM,35 * zclib.hM)
    PrizeList_pnl.Paint = function(s, w, h) end

    local scroll = vgui.Create( "DScrollPanel", PrizeList_pnl )
    scroll:Dock( FILL )
    scroll.Paint = function(s, w, h) draw.RoundedBox(10, 0, 0, w, h, zclib.colors["ui00"]) end
    local sbar = scroll:GetVBar()
    sbar:SetHideButtons( true )
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h) draw.RoundedBox(w, 0, 0, w, h, zclib.colors["text01"]) end

    local list = vgui.Create( "DIconLayout", scroll )
    list:Dock( FILL )
    list:SetSpaceY( 10 * zclib.hM)
    list:SetSpaceX( 0 )
    list:DockMargin(10 * zclib.wM,10 * zclib.hM,10 * zclib.wM,0 * zclib.hM)
    list.Paint = function(s, w, h) end

    PrizeList_pnl:InvalidateLayout(true)
    PrizeList_pnl:InvalidateParent(true)

    scroll:InvalidateLayout(true)
    scroll:InvalidateParent(true)

    local PrizeConfig = TicketData.prizelist or {}
    if PrizeConfig and table.IsEmpty(PrizeConfig) == false then

        local itemW = PrizeList_pnl:GetWide()
        if table.Count(PrizeConfig) >= 10 then
            itemW = itemW - 40 * zclib.hM
        else
            itemW = itemW - 20 * zclib.hM
        end

        for PrizeID, PrizeData in pairs(PrizeConfig) do

            local PrizeTypeData = zlt.Ticket.PrizeTypes[PrizeData.type]
            local PrizeValue = PrizeTypeData.display_value(PrizeData)
            local PrizeName = PrizeData.name or PrizeValue or ""

            local font = zclib.GetFont("zclib_font_medium")
            local txtW = zclib.util.GetTextSize(PrizeName or "",font)

            if txtW > 220 * zclib.wM then
                font = zclib.GetFont("zclib_font_tiny")
            elseif txtW > 150 * zclib.wM then
                font = zclib.GetFont("zclib_font_small")
            end

            local prizetype_txt_w = zclib.util.GetTextSize(PrizeTypeData.name,zclib.GetFont("zclib_font_medium"))
            local prizetype_font = zclib.GetFont("zclib_font_medium")
            if prizetype_txt_w > 100 * zclib.wM then
                prizetype_font = zclib.GetFont("zclib_font_small")
            end

            //local btn = vgui.Create("DButton", PrizeList_pnl)

            local btn = list:Add("DButton")
            btn:SetSize(itemW, 50 * zclib.hM)
            btn:SetAutoDelete(true)
            btn:SetText("")
            btn.Paint = function(s, w, h)
                draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui01"])
                draw.RoundedBox(0, 160 * zclib.wM, 0, 5 * zclib.wM, h, zclib.colors["ui02"])
                draw.SimpleText(PrizeTypeData.name,prizetype_font, 10 * zclib.wM, h / 2, zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                draw.RoundedBox(0, itemW - 66 * zclib.wM, 0, 5 * zclib.wM, h, zclib.colors["ui02"])

                if PrizeName then draw.SimpleText(PrizeName, font, 310 * zclib.wM, h / 2, zclib.colors["green01"], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER) end
                draw.RoundedBox(0, itemW - 165 * zclib.wM, 0, 5 * zclib.wM, h, zclib.colors["ui02"])
                draw.SimpleText((PrizeData.final_chance or 0) .. "%", zclib.GetFont("zclib_font_medium"), w - 70 * zclib.wM, h / 2, zclib.colors["orange01"], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                if SelectedPrizeID == PrizeID then zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2, color_white) end
                if s:IsHovered() then
                    zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2, zclib.colors["white_a15"])
                end
            end
            btn.DoClick = function(s)
                zclib.vgui.PlaySound("UI/buttonclick.wav")
                SelectedPrizeID = PrizeID
            end

            local txt = zclib.vgui.TextEntry(btn,PrizeData.chance,function(val)

                PrizeData.chance = math.Clamp(tonumber(val),0.01,500)

                zlt.Ticket.CalculatePreciseChance(PrizeConfig)
            end,false,function() end)
            txt:SetNumeric(true)
            txt:Dock(FILL)
            txt:DockMargin(itemW - 60 * zclib.wM,5 * zclib.hM,5 * zclib.wM,5 * zclib.hM)
            txt.font = zclib.GetFont("zclib_font_medium")
            if PrizeData.chance then txt:SetValue(PrizeData.chance) end
        end

        zlt.Ticket.CalculatePreciseChance(PrizeConfig)
    end
end

function MachineVGUI:PrizeEditor(PrizeID)
    local PrizeData = {
        type = 2,
        chance = 10,
        final_chance = 10
    }

    if TicketData.prizelist[PrizeID] then
        PrizeData = TicketData.prizelist[PrizeID]
    end

    local mainX,mainY = self.Main_pnl:GetPos()
    if IsValid(self.PrizePanel) then self.PrizePanel:Remove() end
    local PrizePanel = vgui.Create("DPanel", self)
    PrizePanel:SetSize(600 * zclib.wM, 800 * zclib.hM)
    PrizePanel:SetPos(mainX + 610 * zclib.wM ,mainY)
    PrizePanel.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])
        draw.RoundedBox(10, 50 * zclib.wM,70 * zclib.hM, w, 5 * zclib.hM, zclib.colors["ui01"])
        draw.SimpleText(zlt.language["Prize Editor"], zclib.GetFont("zclib_font_big"), 50 * zclib.wM,15 * zclib.hM,zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    self.PrizePanel = PrizePanel



    local back_btn = zclib.vgui.ImageButton(540 * zclib.wM,10 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,PrizePanel,zclib.Materials.Get("save"),function()
        if PrizeID == -1 then
            // Create ticket
            self:CreatePrize(PrizeData)
        else
            // Update ticket
            self:UpdatePrize(PrizeID,PrizeData)
        end
    end,false)
    back_btn.IconColor = zclib.colors["green01"]


    local InputFields = {
        ["text_numeric"] = function(parent,name,default,onchange)
            local pnl = TitledTextEntry(parent,40, zclib.GetFont("zclib_font_medium"), name .. ": ", name, false,function(val)
                pcall(onchange,tonumber(val))
            end,function() end)
            pnl:SetNumeric(true)
            if default then pnl:SetValue(default) end
            return pnl
        end,
        ["text_default"] = function(parent,name,default,onchange)
            local pnl = TitledTextEntry(parent,40, zclib.GetFont("zclib_font_medium"), name .. ": ", name, false,onchange,function() end)
            if default then pnl:SetValue(default) end
            return pnl
        end,
        ["text_lua"] = function(parent,name,default,onchange,emptytext)
            local pnl = TitledMultiText(parent,zclib.GetFont("zclib_font_medium"),"Lua Editor",emptytext,function(val)
                pcall(onchange,val)
            end)
            pnl.main:SetTall(200 * zclib.hM)
            if default then pnl:SetValue(default) end
            pnl.main:Dock(FILL)
            return pnl
        end,
        ["seperator"] = function(parent)
            AddSeperator(parent)
        end,
        ["icon_editor"] = function(parent,name,default,onchange)

            local data = {
                icon_url = nil,
                icon_color = nil,
                icon_stencil = nil,
            }

            local main = vgui.Create("DPanel", parent)
            main:SetSize(600 * zclib.wM, 260 * zclib.hM)
            main:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
            main:Dock(TOP)
            main.Paint = function(s, w, h)
                //draw.RoundedBox(5,  0, 50 * zclib.hM, w - 60 * zclib.wM,50 * zclib.hM, zclib.colors["ui01"])
                //draw.SimpleText(name .. ":", zclib.GetFont("zclib_font_medium"), 10 * zclib.wM, 75 * zclib.hM, zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            main.SetImgurIcon = function(s,val)
                data.icon_url = val
                zclib.Imgur.GetMaterial(tostring(data.icon_url), function(result)
                    if result and IsValid(main) then
                        main.mat = result
                    end
                end)
                if IsValid(main) and IsValid(main.txtpnl) then
                    main.txtpnl:SetValue(data.icon_url)
                end
                if data.icon_color == nil then data.icon_color = color_white end
                pcall(onchange,data)
            end

            if default and default.icon_url then
                data.icon_url = default.icon_url
                zclib.Imgur.GetMaterial(tostring(data.icon_url), function(result)
                    if result and IsValid(main) then
                        main.mat = result
                    end
                end)
            end
            if default and default.icon_color then data.icon_color = default.icon_color end
            if default and default.icon_stencil then data.icon_stencil = default.icon_stencil end

            local checkbox = TitledCheckbox(main,"Stencil:",data.icon_stencil or false,function(val)
                data.icon_stencil = val
                pcall(onchange,data)
            end)
            checkbox:SetSize(600 * zclib.wM,40 * zclib.hM )
            checkbox:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,10 * zclib.hM)

            local m = vgui.Create("DPanel", main)
            m:SetSize(600 * zclib.wM, 50 * zclib.hM)
            m:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
            m:Dock(TOP)
            m.Paint = function(s, w, h)
                draw.RoundedBox(5,  0, 0 * zclib.hM, w - 60 * zclib.wM,50 * zclib.hM, zclib.colors["ui01"])
                draw.SimpleText(name .. ":", zclib.GetFont("zclib_font_medium"), 10 * zclib.wM, 25 * zclib.hM, zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            local gallery_btn = zclib.vgui.ImageButton(0 * zclib.wM,0 * zclib.hM,50 * zclib.wM, 50 * zclib.hM,m,zclib.Materials.Get("icon_loading"),function()
                ImageGallery(function(val)
                    main:SetImgurIcon(val)
                end)
            end,false)
            gallery_btn.IconColor = zclib.colors["blue01"]
            gallery_btn:Dock(RIGHT)
            gallery_btn:DockMargin(10 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)

            local txt = zclib.vgui.TextEntry(m,"Imgur ID",function()
            end,true,function(val)
                main:SetImgurIcon(val)
            end)
            txt:Dock(FILL)
            txt:DockMargin(150 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
            main.txtpnl = txt
            txt.font = zclib.GetFont("zclib_font_medium")
            if data.icon_url then txt:SetValue(data.icon_url) end

            local colmix = vgui.Create("DColorMixer", main)
            colmix:SetSize(240 * zclib.wM, 120 * zclib.hM)
            colmix:DockMargin(0 * zclib.wM,10 * zclib.hM,10 * zclib.wM,0 * zclib.hM)
            colmix:Dock(LEFT)
            colmix:SetPalette(false)
            colmix:SetAlphaBar(false)
            colmix:SetWangs(false)
            colmix:SetColor(data.icon_color or color_white)
            colmix.ValueChanged = function(s,col)
                data.icon_color = col
                zclib.Timer.Remove("zlt_colormixer_delay")
                zclib.Timer.Create("zlt_colormixer_delay",0.1,1,function()
                    data.icon_color = col
                    pcall(onchange,data)
                end)
            end

            local preview_pnl = vgui.Create("DPanel", main)
            preview_pnl:SetSize(240 * zclib.wM, 50 * zclib.hM)
            preview_pnl:DockMargin(10 * zclib.wM,10 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
            preview_pnl:Dock(LEFT)
            preview_pnl.Paint = function(s, w, h)
                draw.RoundedBox(5,  0, 0, w,h, zclib.colors["ui01"])

                /*
                TODO Integrate icon scaling
                surface.SetDrawColor(color_white)
                surface.SetMaterial(data.scratch_img)
                local x , y = 2 * data.scratch_x , 2 * data.scratch_y
                local u0, v0 = 0 * data.scratch_scale + x,0 * data.scratch_scale + y
                local u1, v1 = 1 * data.scratch_scale + x,1 * data.scratch_scale + y
                surface.DrawTexturedRectUV(w * 0.518, h * 0.221, w * 0.435, h * 0.63, u0, v0, u1, v1)
                */

                if main.mat then

                    if data.icon_stencil == true then

                        BMASKS.BeginMask("zclib_Circle")
                            surface.SetDrawColor(data.icon_color or color_white)
                            surface.SetMaterial(main.mat)
                            surface.DrawTexturedRectRotated(w / 2, h / 2, h, h, 0)
                        BMASKS.EndMask("zclib_Circle",(w - h) / 2, 0, h, h)
                    else
                        surface.SetDrawColor(data.icon_color or color_white)
                        surface.SetMaterial(main.mat)
                        surface.DrawTexturedRectRotated(w / 2, h / 2, h, h, 0)
                    end
                end
            end

            return main
        end,
        ["ezs_editor"] = function(parent,name,default,onchange)

            local data = {
                ezs_skinid = nil,
                ezs_weaponclass = nil,
            }

            local main = vgui.Create("DPanel", parent)
            main:SetSize(600 * zclib.wM, 320 * zclib.hM)
            main:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
            main:Dock(TOP)
            main.Paint = function(s, w, h)
            end

            if default then
                if default.ezs_skinid then
                    data.ezs_skinid = default.ezs_skinid
                end

                if default.ezs_weaponclass then
                    data.ezs_weaponclass = default.ezs_weaponclass
                end
            end

            local m = vgui.Create("DPanel", main)
            m:SetSize(600 * zclib.wM, 240 * zclib.hM)
            m:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
            m:Dock(TOP)
            m.Paint = function(s, w, h)
            end

            local function SelectSkin(skinid)
                local skin = SH_EASYSKINS.GetSkin(skinid)
        		if skin == nil then return end

                data.ezs_skinid = skinid
                data.ezs_weaponclass = nil

                main.SkinComboBox:SetValue(skin.dispName)

        		local skinpath =  skin.material.path
        		if skinpath == nil then return end

        		local image = CL_EASYSKINS.VMTToUnlitGeneric(skinpath)
        		if image == nil then return end

                main.preview_pnl:SetMaterial(image)

                // Rebuild weaponclass combobox

                if IsValid(main.WeabonClassBox_main) then main.WeabonClassBox_main:Remove() end
                local function SelectWeaponClass(class)

                    data.ezs_weaponclass = class

                    if IsValid(main.preview_weaponclass_pnl) then


						if class == "Random" then
							main.WeabonClassBox:SetValue("Random")
							return
						end

                        local weapon = weapons.Get(class)
                        if weapon == nil then
                            weapon = SH_EASYSKINS.NONLINKEDMODELS[class]
                        end
                        if weapon and weapon.WorldModel then

                            main.WeabonClassBox:SetValue(class)

                            main.preview_weaponclass_pnl:SetVisible(true)
                            main.preview_weaponclass_pnl:SetModel(weapon.WorldModel)

                            SH_EASYSKINS.ApplySkinToModel(main.preview_weaponclass_pnl.Entity, skinpath)
                        end
                    end

                    // Send data to ticket
                    pcall(onchange,data)
                end
                local WeabonClassBox = TitledComboBox(m,{name = zlt.language["Weapon:"],color = zclib.colors["orange01"]},"Skin",function(index, value,pnl)
                    SelectWeaponClass(value)
                end)
                WeabonClassBox.main:SetTall(100 * zclib.hM)
                WeabonClassBox.main:DockMargin(0 * zclib.wM,10 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
                WeabonClassBox:DockMargin(160 * zclib.wM,0 * zclib.hM,10 * zclib.wM,0 * zclib.hM)
                WeabonClassBox.main.Paint = function(s, w, h)
                    draw.RoundedBox(5, 0, 0, 150 * zclib.wM, h, zclib.colors["ui01"])
                    draw.SimpleText(zlt.language["Weapon:"], zclib.GetFont("zclib_font_medium"), 10 * zclib.wM,h / 2,zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                main.WeabonClassBox = WeabonClassBox
                main.WeabonClassBox_main = WeabonClassBox.main

				WeabonClassBox:AddChoice( "Random" )

                local weaponclass_List = skin.weaponTbl
                for i = 1, #weaponclass_List do
                    if weaponclass_List[i] then
                        WeabonClassBox:AddChoice( weaponclass_List[i] )
                    end
                end

				local _default = data.ezs_weaponclass or "Random"
                local preview_pnl = zclib.vgui.ModelPanel({model = "models/props_borealis/bluebarrel001.mdl"})
                preview_pnl:SetParent(WeabonClassBox.main)
                preview_pnl:SetSize(100 * zclib.wM, 100 * zclib.hM)
                preview_pnl:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
                preview_pnl:Dock(RIGHT)
                preview_pnl.PreDrawModel = function(s,ent)
                    cam.Start2D()
                        draw.RoundedBox(5, 0, 0, 100 * zclib.wM, 100 * zclib.hM, zclib.colors["ui01"])
                    cam.End2D()
                end
				preview_pnl.PostDrawModel = function(s,ent)
					if _default ~= "Random" then return end
					cam.Start2D()
					draw.RoundedBox(5, 0, 0, 100 * zclib.wM, 100 * zclib.hM, zclib.colors["ui01"])
					draw.SimpleText("?", zclib.GetFont("zclib_font_giant"), 50 * zclib.wM, 50 * zclib.hM,zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					cam.End2D()
				end
                main.preview_weaponclass_pnl = preview_pnl

                SelectWeaponClass(_default)//weaponclass_List[1])
            end

            ////////// SKIN FIELD
            local DComboBox = TitledComboBox(m,{name = zlt.language["Skin:"],color = zclib.colors["orange01"]},"Skin",function(index, value,pnl)
                local dat = pnl:GetOptionData( index )
                SelectSkin(dat)
            end)
            DComboBox.main:SetTall(100 * zclib.hM)
            DComboBox.main:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
            DComboBox:DockMargin(160 * zclib.wM,0 * zclib.hM,10 * zclib.wM,0 * zclib.hM)
            DComboBox.main.Paint = function(s, w, h)
                draw.RoundedBox(5, 0, 0, 150 * zclib.wM, h, zclib.colors["ui01"])
                draw.SimpleText(zlt.language["Skin:"], zclib.GetFont("zclib_font_medium"), 10 * zclib.wM,h / 2,zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            local skinList = SH_EASYSKINS.GetSkins()
            for i = 1, #skinList do
                if skinList[i] and skinList[i].id then
                    DComboBox:AddChoice( skinList[i].dispName , skinList[i].id )
                end
            end
            main.SkinComboBox = DComboBox

            local preview_pnl = vgui.Create("DImage", DComboBox.main )
            preview_pnl:SetSize(100 * zclib.wM, 100 * zclib.hM)
            preview_pnl:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
            preview_pnl:Dock(RIGHT)
            main.preview_pnl = preview_pnl
            if data.ezs_skinid then
                SelectSkin(data.ezs_skinid)
            else
                SelectSkin(1)
            end
            /////////////

            return main
        end,
        ["darkrp_shipments"] = function(parent,name,default,onchange)

            local data = {
                shipID = 1,
                shipAmount = 10,
            }

            if default then
                if default.shipID then
                    data.shipID = default.shipID

                    data.shipAmount = CustomShipments[data.shipID].amount
                end

                if default.shipAmount then
                    data.shipAmount = default.shipAmount
                end
            end

            local DComboBox = TitledComboBox(parent,{name = name,color = zclib.colors["orange01"]},(CustomShipments[data.shipID] and CustomShipments[data.shipID].name) or "Shipment",function(index, value,pnl)
                local dat = pnl:GetOptionData( index )
                pnl:SetValue(CustomShipments[dat].name)
                data.shipID = dat

                // Set the default value for the text entry bellow
                data.shipAmount = CustomShipments[dat].amount or 10
                pnl.AmountInput:SetValue(data.shipAmount)

                pcall(onchange,data)
            end)
            DComboBox.main:SetTall(40 * zclib.hM)
            for i,v in ipairs(CustomShipments) do DComboBox:AddChoice( v.name , i ) end


            local pnl = TitledTextEntry(parent,40, zclib.GetFont("zclib_font_medium"), zlt.language["Amount"] .. ": ", data.shipAmount, false,function(val)
                data.shipAmount = tonumber(val)
                pcall(onchange,data)
            end,function() end)
            pnl:SetNumeric(true)
            DComboBox.AmountInput = pnl
            if data.shipAmount then pnl:SetValue(data.shipAmount) end

            return DComboBox
        end,
        ["xenin_ds"] = function(parent,name,default,onchange)

            local DComboBox = TitledComboBox(parent,{name = name,color = zclib.colors["orange01"]},default or "Deathscreens",function(index, value,pnl)
                local dat = pnl:GetOptionData( index )
                pnl:SetValue(XeninDS.Config.cards[dat].name)
                pcall(onchange,dat)
            end)
            DComboBox.main:SetTall(40 * zclib.hM)
            for k,v in pairs(XeninDS.Config.cards) do DComboBox:AddChoice( v.name , k ) end

            return DComboBox
        end,
    }


    // Write function for value fields rebuilds
    local function RebuildInputFields(PrizeTypeID)
        // Rebuild value field / fields
        if IsValid(self.InputField) then self.InputField:Remove() end

        local PrizeTypeData = zlt.Ticket.PrizeTypes[PrizeTypeID]

        if PrizeTypeData.inputfields then
            local InputField = vgui.Create("DPanel", PrizePanel)
            InputField:SetSize(600 * zclib.wM, 620 * zclib.hM)
            InputField:Dock( TOP )
            InputField:DockMargin(0 * zclib.wM,0 * zclib.hM,0 * zclib.wM,10 * zclib.hM)
            InputField.Paint = function(s, w, h)
                draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])
            end
            self.InputField = InputField

            InputField.Elements = {}

            // Create input fields for diffrent prize vars
            for k,v in ipairs(PrizeTypeData.inputfields) do
                local pnl = InputFields[v.type](InputField,v.title,PrizeData[v.var],function(val)
                    if val == "" or val == " " then
                        val = nil
                    end
                    PrizeData[v.var] = val

                    // Should we search if the received input is inside one of our lists, if so select the corresponding imgur id for the icon
                    if v.AutoSearchForImgurID and val and IsValid(InputField.Elements["icon"]) then
                        // Uses the input we received (weaponclass) and check if its inside our list of connected imgur ids
                        if zlt.InputToImgur[val] then
                            InputField.Elements["icon"]:SetImgurIcon(zlt.InputToImgur[val])
                        end
                    else
                        // Do nothing
                    end

                end,v.emptytext)


                // Registers the created pnl for later reference
                if IsValid(pnl) then InputField.Elements[v.var] = pnl end
            end
        end
    end
    local DComboBox = TitledComboBox(PrizePanel,{name = zlt.language["Prize Type"] .. ":",color = zclib.colors["blue01"]},zlt.Ticket.PrizeTypes[PrizeData.type].name,function(index, value,pnl,data_val)
        PrizeData = {
            type = data_val,
            chance = 10
        }
        RebuildInputFields(data_val)
    end)
    DComboBox:SetSortItems( false )
    DComboBox.main:DockMargin(50 * zclib.wM,90 * zclib.hM,50 * zclib.wM,0 * zclib.hM)
    for k,v in ipairs(zlt.Ticket.PrizeTypes) do

        // Make sure you only display prizetypes which are installed
        if v.installed == nil or v.installed == false then continue end

        DComboBox:AddChoice( v.name , k )
    end

    AddSeperator(PrizePanel)

    RebuildInputFields(PrizeData.type)
end

function MachineVGUI:UpdatePrize(PrizeID,PrizeData)
    TicketData.prizelist[PrizeID] = table.Copy(PrizeData)
    self:PrizeWindow()
end

function MachineVGUI:CreatePrize(PrizeData)
    table.insert(TicketData.prizelist,PrizeData)
    self:PrizeWindow()
end

vgui.Register("ZLT_MACHINE", MachineVGUI, "DFrame")
