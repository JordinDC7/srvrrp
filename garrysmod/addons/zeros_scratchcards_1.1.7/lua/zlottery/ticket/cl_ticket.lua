if SERVER then return end
zlt = zlt or {}
zlt.Ticket = zlt.Ticket or {}

zlt.ScreenW = ScrW()
zlt.ScreenH = ScrH()
zclib.Hook.Add("OnScreenSizeChanged", "zlt_ticket_VarUpdater", function()
    zlt.ScreenW = ScrW()
    zlt.ScreenH = ScrH()
end)


function zlt.Ticket.Initialize(Ticket)
    timer.Simple(0.5, function()
        if not IsValid(Ticket) then return end
        Ticket.RebuildMaterial = true
    end)
end

function zlt.Ticket.Draw(Ticket)
    if zclib.util.InDistance(Ticket:GetPos(), LocalPlayer():GetPos(), 500) then
        if Ticket.RebuildMaterial then
            local TicketID = zlt.Ticket.GetID(Ticket:GetTicketID())
            if TicketID then zlt.Ticket.UpdateMaterial(Ticket,TicketID) end
            Ticket.RebuildMaterial = false
        end

        local curDraw = CurTime()
        if Ticket.LastDraw == nil then Ticket.LastDraw = CurTime() end
        if Ticket.LastDraw < (curDraw - 1) then
            Ticket.RebuildMaterial = true
        end
        Ticket.LastDraw = curDraw
    else
        Ticket.RebuildMaterial = true
    end
end

// Create a ticket material
zlt.Ticket.Materials = zlt.Ticket.Materials or {}
function zlt.Ticket.GetMaterial(matID)
    zclib.Debug("zlt.Ticket.GetMaterial")

    // If the material already got created then just return it here
    if zlt.Ticket.Materials[matID] then
        return zlt.Ticket.Materials[matID]
    end

    local m_material = CreateMaterial(matID, "VertexLitGeneric", {
        ["$basetexture"] = "zerochain/props_lottery/ticket/zlt_ticket_diff",
        ["$halflambert"] = 1,
        ["$model"] = 1,
        //["$selfillum"] = 1,
        //["$selfillummaskscale"] = 0.5,

        ["$bumpmap"] = "zerochain/props_lottery/ticket/zlt_ticket_nrm",
        ["$normalmapalphaenvmapmask"] = 1,

        ["$envmap"] = "env_cubemap",
        ["$envmaptint"] = Vector(1,1,1),
        ["$envmapfresnel"] = 1,

        ["$phong"] = 1,
        ["$phongexponent"] = 1,
        ["$phongboost"] = 1,
        ["$phongfresnelranges"] = Vector(1, 1, 1),
        ["$phongtint"] = Vector(1, 1, 1),

        ["$rimlight"] = 1,
        ["$rimlightexponent"] = 5,
        ["$rimlightboost"] = 1,
    })
    m_material:SetInt("$halflambert", 1)
    m_material:SetInt("$model", 1)
    m_material:SetTexture("$bumpmap", "zerochain/props_lottery/ticket/zlt_ticket_nrm")
    m_material:SetInt("$normalmapalphaenvmapmask", 1)

    m_material:SetVector("$envmaptint", Vector(0.05,0.05,0.05))
    m_material:SetFloat("$envmapfresnel", 0.05)

    m_material:SetInt("$phong", 1)
    m_material:SetFloat("$phongexponent", 35)
    m_material:SetFloat("$phongboost", 1)
    m_material:SetVector("$phongfresnelranges", Vector(1, 1, 1))
    m_material:SetVector("$phongtint", Vector(1,1,1))

    m_material:SetInt("$rimlight", 1)
    m_material:SetFloat("$rimlightexponent", 2)
    m_material:SetFloat("$rimlightboost", 1)

    //m_material:SetInt("$selfillum", 1)
    //m_material:SetFloat("$selfillummaskscale", 0.5)


    // $model + $envmapmode + $normalmapalphaenvmapmask + $opaquetexture + $softwareskin + $halflambert + //$selfillum
    m_material:SetInt("$flags", 2048 + 33554432 + 4194304 + 16777216 + 8388608 /*+ 64*/)

    //m_material:Recompute()

    zlt.Ticket.Materials[matID] = m_material

    return m_material
end

// Compose the ticket design
function zlt.Ticket.ComposeDesign(TicketID)
    zclib.Debug("zlt.Ticket.ComposeDesign")
    local TicketData = zlt.config.Tickets[TicketID]
    if TicketData == nil then return end

    local data = {}
    for k,v in pairs(zlt.Ticket.Structure) do
        if k == "price" then
            data[k] = zclib.Money.Display(TicketData[k] or v)
        else
            data[k] = TicketData[k] or v
        end
    end

    if data.scratch_url then
        zclib.Imgur.GetMaterial(tostring(data.scratch_url), function(result)
            if result then
                data.scratch_img = result
            end
        end)
    end

    if data.bg_url then
        zclib.Imgur.GetMaterial(tostring(data.bg_url), function(result)
            if result then
                data.bg_img = result
            end
        end)
    end

    if data.symbol_url then
        zclib.Imgur.GetMaterial(tostring(data.symbol_url), function(result)
            if result then
                data.symbol_img = result
            end
        end)
    end

    if data.logo_url then
        zclib.Imgur.GetMaterial(tostring(data.logo_url), function(result)
            if result then
                data.logo_img = result
            end
        end)
    end

    local w,h = zlt.ScreenW,zlt.ScreenH

    draw.RoundedBox(0, 0, 0, w, h, data.color)

    if data.bg_img then
        surface.SetDrawColor(data.bg_col)
        surface.SetMaterial(data.bg_img)
        surface.DrawTexturedRectRotated(w * data.bg_x, h * data.bg_y, w * 2 * data.bg_scale_w, h * 2 * data.bg_scale_h, 360 * data.bg_rot)
    end

    if data.symbol_img then
        surface.SetDrawColor(data.symbol_col)
        surface.SetMaterial(data.symbol_img)
        surface.DrawTexturedRectRotated(w * data.symbol_x, h * data.symbol_y, w * 2 * data.symbol_scale_w, h * 2 * data.symbol_scale_h, 360 * data.symbol_rot)
    end

    local pW = zclib.util.GetTextSize(data.price,zclib.GetFont("zlt_ticket_price"))
    local bW = 80 + pW
    draw.RoundedBox(20, w - (bW - 30 ),55 , bW, 120 , data.price_bg_col)
    draw.SimpleText(data.price, zclib.GetFont("zlt_ticket_price"),w - 30 ,115,data.price_col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    if data.scratch_img then
        surface.SetDrawColor(color_white)
        surface.SetMaterial(data.scratch_img)

        local x , y = 2 * data.scratch_x , 2 * data.scratch_y
        local u0, v0 = 0 * data.scratch_scale + x,0 * data.scratch_scale + y
        local u1, v1 = 1 * data.scratch_scale + x,1 * data.scratch_scale + y
        surface.DrawTexturedRectUV(w * 0.518, h * 0.221, w * 0.435, h * 0.63, u0, v0, u1, v1)
    end


    if data.logo_img then
        surface.SetDrawColor(data.logo_col)
        surface.SetMaterial(data.logo_img)
        surface.DrawTexturedRectRotated(w * data.logo_x,h * data.logo_y,w * data.logo_scale_w,h * data.logo_scale_h,360 * data.logo_rot)
    end


    if data.scratch_outline_type then
        surface.SetDrawColor(data.scratch_outline_col)
        surface.SetMaterial(zclib.Materials.Get(data.scratch_outline_type))
        surface.DrawTexturedRect(w * 0.511,h * 0.2, w * 0.45,h * 0.67)
    end


    draw.DrawText(data.title_val, zclib.GetFont(data.title_font .. "_big"), w * data.title_x, h * data.title_y, data.title_color, data.title_aligncenter)
    draw.DrawText(data.desc_val, zclib.GetFont("zlt_ticket_desc"), w * data.desc_x, h * data.desc_y, data.desc_color, data.desc_aligncenter)

    surface.SetDrawColor(color_white)
    surface.SetMaterial(zclib.Materials.Get("ticket_border"))
    surface.DrawTexturedRect(0,0,w,h)
end

// Shove that design in the materials basetexture
function zlt.Ticket.ReplaceMaterial(ent,material,i_matid,TicketID,rt_name,AppendDraw,mat_index)
    zclib.Debug("zlt.Ticket.ReplaceMaterial " .. tostring(ent))
    local sw,sh = 2048 / zlt.ScreenW,2048 / zlt.ScreenH

    local rt_target = GetRenderTarget(rt_name, 2048, 2048, false)

    local mat = Matrix()
    mat:SetScale( Vector(sw,sh,1) )
    render.SuppressEngineLighting(true)
    render.PushRenderTarget(rt_target)
        render.Clear(255,255,255, 255, true, true)
        render.OverrideAlphaWriteEnable(true, true)
        cam.Start2D()
            cam.PushModelMatrix(mat)
                zlt.Ticket.ComposeDesign(TicketID)
                if AppendDraw then pcall(AppendDraw) end
            cam.PopModelMatrix()
        cam.End2D()
    render.PopRenderTarget()
    render.SuppressEngineLighting(false)

    material:SetTexture("$basetexture", rt_target)
    ent:SetSubMaterial(mat_index,"!" .. i_matid)
end

// Updates the ticket material on the entity
function zlt.Ticket.UpdateMaterial(Ticket,TicketID)
    zclib.Debug("zlt.Ticket.UpdateMaterial")

    local TicketData = zlt.config.Tickets[TicketID]
    if TicketData == nil then return end

    local i_matid = "zlt_ticket_material_" .. TicketData.uniqueid
    local m_material =  zlt.Ticket.GetMaterial(i_matid)

    zlt.Ticket.ReplaceMaterial(Ticket,m_material,i_matid,TicketID,"zlt_ticket_rendertarget_" .. TicketData.uniqueid,function() end,0)
end

// Generate a scratchfield list
local DummyValues = {
    [1] = 5,
    [2] = 10,
    [3] = 15,
    [4] = 25,
    [5] = 200,
    [6] = 2000,
    [7] = 20000,
    [8] = 150000,
}

// Lets make it so that the None Wining list is dynamicly generated from the existing price pool , minues the wining price and any duplicates we may find in the dummy list

function zlt.Ticket.GenerateFieldList(TicketID,PrizeID)
    local List = {}

    /*
        Get the prizelist from TicketData
        Subtract the wining id if one exist
        Check if we get enough items in that list (We need a certain amount 4 (* 2) unique prizes + 1)
            If there are not enough pizes in the scratchcard then just use the dummy values
        Our list needs atleat 5 unique prizes
    */

    local TicketData = zlt.config.Tickets[TicketID]
    local PrizeData = TicketData.prizelist[PrizeID]

    local temp = table.Copy(DummyValues)

    // Remove money value from list if its inside
    if PrizeData.money then
        for k,v in pairs(temp) do
            if v == PrizeData.money then
                temp[k] = nil
                break
            end
        end
    end

    local function AddField(prizeid,IsWinner)
        // If we dont have a prize id then lets use the dummy values
        if prizeid == -1 then

            local tval,key = table.Random(temp)

            table.insert(List, {
                val = zclib.Money.Display(tval), // Can be a string or a icon
                IsWinner = false,
            })

            // Remove from temp list
            temp[key] = nil

            return
        end

        // If the prizeid is invalid then use one of the dummy values
        local PrizeValue = zlt.Ticket.GetPrizeDisplayValue(TicketID,prizeid)
        local PrizeIcon,PrizeIcon_color,PrizeIcon_stencil = zlt.Ticket.GetPrizeIcon(TicketID,prizeid)

        table.insert(List, {
            val = PrizeValue, // Can be a string or a icon
            p_icon_img = PrizeIcon,
            p_icon_color = PrizeIcon_color,
            p_icon_stencil = PrizeIcon_stencil,
            IsWinner = IsWinner,
        })
    end

    // Get the list of possible prices
    local t_prizelist = table.Copy(TicketData.prizelist)

    // Lets remove the wining id
    t_prizelist[PrizeID] = nil

    // Remove any prize value with the prize type 1
    for k, v in pairs(t_prizelist) do
        if v and v.type == 1 then
            t_prizelist[k] = nil
        end
    end

    local function AddDummyPrize(double)
        // If we dont have enough prizes in the scratchcard then lets use some money dummy values instead aka -1
        if table.Count(t_prizelist) <= 0 then
            if double then
                AddField(-1, false)
                AddField(-1, false)
            else
                AddField(-1, false)
            end
            return
        end

        local _, id = table.Random(t_prizelist)
        if double then
            AddField(id, false)
            AddField(id, false)
        else
            AddField(id, false)
        end

        // Remove from temp list
        t_prizelist[id] = nil
    end

    if zlt.Ticket.DidWin(TicketID,PrizeID) then
        // Add the wining fields
        for i = 1, 3 do
            AddField(PrizeID,true)
        end

        // Add dummy fields
        for i = 1, 3 do
            AddDummyPrize(true)
        end
    else
        // Add dummy fields
        for i = 1, 4 do
            AddDummyPrize(true)
        end

        AddDummyPrize()
    end

    List = zclib.table.randomize(List)

    return List
end
