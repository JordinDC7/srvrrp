if SERVER then return end
zlt = zlt or {}
zlt.Machine = zlt.Machine or {}

function zlt.Machine.Initialize(Machine)
    zlt.Machine.SetupData(Machine:EntIndex())
end

local ButtonOffset = Vector(0,0,0.3)
function zlt.Machine.Draw(Machine)
    if zclib.util.InDistance(Machine:GetPos(), LocalPlayer():GetPos(), 1000) then

        // Draw Edit Button
        if zclib.Player.IsAdmin(LocalPlayer()) then
            cam.Start3D2D(Machine:LocalToWorld(Vector(3,22,88)), Machine:LocalToWorldAngles(Angle(0,90,90)), 0.03)

                if Machine:OnEditButton(LocalPlayer()) then
                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(zclib.Materials.Get("edit"))
                    surface.DrawTexturedRectRotated(0,0,300,300,CurTime() * 50)

                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(zclib.Materials.Get("icon_box01"))
                    surface.DrawTexturedRectRotated(0,0,300,300,0)
                else
                    surface.SetDrawColor(zclib.colors["white_a15"])
                    surface.SetMaterial(zclib.Materials.Get("edit"))
                    surface.DrawTexturedRectRotated(0,0,300,300,0)

                    surface.SetDrawColor(zclib.colors["white_a15"])
                    surface.SetMaterial(zclib.Materials.Get("icon_box01"))
                    surface.DrawTexturedRectRotated(0,0,300,300,0)
                end
            cam.End3D2D()
        end

        zlt.Machine.UpdateSlot(Machine,1)
        zlt.Machine.UpdateSlot(Machine,2)
        zlt.Machine.UpdateSlot(Machine,3)
        zlt.Machine.UpdateSlot(Machine,4)


        // Update everything if it wasnt drawn for a long period
        local curDraw = CurTime()
        if Machine.LastDraw == nil then Machine.LastDraw = CurTime() end

		if zclib.util.IsInsideViewCone(Machine:GetPos(),EyePos(),EyeAngles(),2000,2000) then
	        if Machine.LastDraw < (curDraw - 0.25) then
	            Machine.Slots[1] = nil
	            Machine.Slots[2] = nil
	            Machine.Slots[3] = nil
	            Machine.Slots[4] = nil
	            Machine.LastPaintColor = nil
	            Machine.LastLightColor = nil
	        end

        	Machine.LastDraw = curDraw
		end

        local e_index = Machine:EntIndex()

        // Get Logo material
        //local logo_data = Machine:GetLogo()
        local logo_data = zlt.Machine.GetData(e_index, "Logo")
        if Machine.logo_data ~= logo_data then
            Machine.logo_data = logo_data
            Machine.Logo_img = nil
            zclib.Imgur.GetMaterial(tostring(logo_data), function(result)
                if result then
                    Machine.Logo_img = result
                end
            end)
        end

        // Draw logo
        if Machine.Logo_img then

            cam.Start3D2D(Machine:LocalToWorld(Vector(7.7,0,80)), Machine:LocalToWorldAngles(Angle(0,90,90)), 0.2)
                surface.SetDrawColor(color_white)
                surface.SetMaterial(Machine.Logo_img)
                surface.DrawTexturedRectRotated(100 * zlt.Machine.GetData(e_index, "LogoPosX") - 50,100 * zlt.Machine.GetData(e_index, "LogoPosY") - 50,100 * zlt.Machine.GetData(e_index, "LogoScaleW"),100 * zlt.Machine.GetData(e_index, "LogoScaleH"),0)
            cam.End3D2D()
        end

        // Draw buttons
        local buttonSize = 12
        for k, v in ipairs(Machine.ButtonList) do
            local bone = Machine:LookupBone("button0" .. k .. "_jnt")

            if bone == nil then continue end
            local b_pos,b_ang = Machine:GetBonePosition( bone )

            if b_pos == Machine:GetPos() then
            	b_pos = Machine:GetBoneMatrix(bone):GetTranslation()
            end

            if b_pos == nil then continue end
            if b_ang == nil then continue end

            cam.Start3D2D(b_pos + ButtonOffset, b_ang, 0.1)
                if Machine:OnButton(LocalPlayer()) == k then
                    surface.SetDrawColor(zclib.colors["red01"])
                    surface.SetMaterial(zclib.Materials.Get("square_glow"))
                    surface.DrawTexturedRectRotated(0,0,buttonSize,buttonSize,0)

                    surface.SetDrawColor(zclib.colors["white_a15"])
                    surface.SetMaterial(zclib.Materials.Get("radial_shadow"))
                    surface.DrawTexturedRectRotated(0,0,buttonSize,buttonSize,0)
                end
            cam.End3D2D()
        end

        // Update Main paint color
        local vec_paint_color = zlt.Machine.GetData(e_index, "Paint")
        if Machine.LastPaintColor ~= vec_paint_color then
            Machine.LastPaintColor = vec_paint_color
            zlt.Machine.UpdatePaint(Machine,vec_paint_color)
        end

        // Update light color
        local vec_light_color = zlt.Machine.GetData(e_index, "Light")
        if Machine.LastLightColor ~= vec_light_color then
            Machine.LastLightColor = vec_light_color
            zlt.Machine.UpdateLight(Machine,vec_light_color)
        end

        zlt.Machine.DrawLight(Machine)
    else
        if Machine.Slots then
            Machine.Slots[1] = nil
            Machine.Slots[2] = nil
            Machine.Slots[3] = nil
            Machine.Slots[4] = nil
        end
        if Machine.LastPaintColor then
            Machine.LastPaintColor = nil
        end
        if Machine.LastLightColor then
            Machine.LastLightColor = nil
        end
    end
end

function zlt.Machine.UpdateSlot(Machine,id)
    if Machine.Slots == nil then Machine.Slots = {} end

    local slot_data = zlt.Machine.GetData(Machine:EntIndex(), "Slot0" .. id)


    local _,prettyprice = zlt.Ticket.GetPrice(slot_data)
    local TicketID = zlt.Ticket.GetID(slot_data)
    cam.Start3D2D(Machine:LocalToWorld(Vector(7.75,-16.2 + 6.4 * id,50.6)), Machine:LocalToWorldAngles(Angle(0,90,90)), 0.03)
        draw.RoundedBox(0, -85, -30, 170, 60, color_black)
        if prettyprice == nil then
            draw.SimpleText(zlt.language["EMPTY"], zclib.GetFont("zlt_ticket_desc_small"), 0, 0, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            local txt = prettyprice
            if zclib.util.GetTextSize(txt,zclib.GetFont("zlt_ticket_desc_small")) > 170 then
                draw.SimpleText(txt, zclib.GetFont("zlt_ticket_desc_tiny"), 0, 0, color_green, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(txt, zclib.GetFont("zlt_ticket_desc_small"), 0, 0, color_green, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    cam.End3D2D()

    if Machine.Slots[id] ~= slot_data then
        Machine.Slots[id] = slot_data

        // Update ticket material
        if TicketID == nil then
            Machine:SetSubMaterial(6 + id, nil)
        else

            local s_matid = "zlt_ticket_material_" .. slot_data
            local rt_name = "zlt_machine_" .. Machine:EntIndex() .. "_ticket_rendertarget_" .. id
            local m_material = zlt.Ticket.GetMaterial(s_matid)
            zlt.Ticket.ReplaceMaterial(Machine, m_material, s_matid, TicketID, rt_name, function() end, 6 + id)
        end
    end
end

function zlt.Machine.UpdatePaint(Machine,vec_paint_color)

    local matID = "zlt_machine_paint_mat_" .. Machine:EntIndex()
    local m_material = CreateMaterial(matID, "VertexLitGeneric", {
        ["$color2"] = Vector(1,1,1),
        ["$basetexture"] = "zerochain/props_lottery/machine/zlt_machine_paint_diff",
        ["$halflambert"] = 1,
        ["$model"] = 1,

        ["$bumpmap"] = "zerochain/props_lottery/machine/zlt_machine_paint_nrm",
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

    m_material:SetVector("$color2", vec_paint_color)

    m_material:SetInt("$halflambert", 1)
    m_material:SetInt("$model", 1)
    m_material:SetTexture("$bumpmap", "zerochain/props_lottery/machine/zlt_machine_paint_nrm")
    m_material:SetInt("$normalmapalphaenvmapmask", 1)

    m_material:SetVector("$envmaptint", vec_paint_color)
    m_material:SetFloat("$envmapfresnel", 0.1)

    m_material:SetInt("$phong", 1)
    m_material:SetFloat("$phongexponent", 2)
    m_material:SetFloat("$phongboost",2)
    m_material:SetVector("$phongfresnelranges", Vector(1, 4, 6))
    m_material:SetVector("$phongtint", vec_paint_color)

    m_material:SetInt("$rimlight", 1)
    m_material:SetFloat("$rimlightexponent", 25)
    m_material:SetFloat("$rimlightboost", 0.1)


    // $model + $envmapmode + $normalmapalphaenvmapmask + $opaquetexture + $softwareskin + $halflambert
    m_material:SetInt("$flags", 2048 + 33554432 + 4194304 + 16777216 + 8388608)

    //m_material:Recompute()

    Machine:SetSubMaterial(5, "!" .. matID)
end

function zlt.Machine.UpdateLight(Machine, vec_light_color)
    local matID = "zlt_machine_light_mat_" .. Machine:EntIndex()

    local m_material = CreateMaterial(matID, "MonitorScreen", {
        ["$color2"] = Vector(1, 1, 1),
        ["$basetexture"] = "zerochain/props_lottery/machine/zlt_machine_lights",
        ["$model"] = 1,
        ["$alphatest"] = 1,
        ["$additive"] = 1,
        ["$offset"] = 0,
        Proxies = {
            AnimatedTexture = {
                animatedTextureVar = "$basetexture",
                animatedTextureFrameNumVar = "$frame",
                animatedTextureFrameRate = 10
            }
        }
    })

    m_material:SetVector("$color2", vec_light_color)
    m_material:SetInt("$halflambert", 1)
    m_material:SetInt("$model", 1)
    m_material:SetInt("$alphatest", 1)
    m_material:SetInt("$additive", 1)
    m_material:SetInt("$offset", 0)

    // $model + $envmapmode + $additive
    m_material:SetInt("$flags", 2048 + 128)

    //m_material:Recompute()

    Machine:SetSubMaterial(3, "!" .. matID)

    local light_color = zclib.util.VectorToColor(vec_light_color)
    local h,s,v = ColorToHSV(light_color)
    Machine.LightColor = HSVToColor(h,0.2,v)
end

function zlt.Machine.DrawLight(Machine)
    local dlight01 = DynamicLight(Machine:EntIndex())
    local pos = Machine:LocalToWorld(Vector(40, 0, 80))
    //debugoverlay.Sphere(pos, 5, 0.1, Color( 255, 255, 255 ),true )
    if (dlight01) then
        if Machine.LightColor == nil then
            Machine.LightColor = color_white
        end

        dlight01.pos = pos
        dlight01.r = Machine.LightColor.r
        dlight01.g = Machine.LightColor.g
        dlight01.b = Machine.LightColor.b
        dlight01.brightness = 1
        dlight01.Decay = 1000
        dlight01.Size = 256
        dlight01.DieTime = CurTime() + 1
    end
end

function zlt.Machine.AnimateButton(Machine, id)
    if Machine.PosePosition == nil then
        Machine.PosePosition = {}
    end
    if (Machine.PosePosition[id] or 0) <= 0 then return end
    Machine.PosePosition[id] = math.Round(Lerp(FrameTime() * 2, Machine.PosePosition[id] or 0, 0),5)
    Machine:SetPoseParameter("button0" .. id, Machine.PosePosition[id])
    Machine:InvalidateBoneCache()
end

function zlt.Machine.PressButton(Machine, id)
    if Machine.PosePosition == nil then
        Machine.PosePosition = {}
    end

    Machine.PosePosition[id] = 1
end

function zlt.Machine.Think(Machine)
    // Animate buttons
    zlt.Machine.AnimateButton(Machine, 1)
    zlt.Machine.AnimateButton(Machine, 2)
    zlt.Machine.AnimateButton(Machine, 3)
    zlt.Machine.AnimateButton(Machine, 4)
end

function zlt.Machine.OnRemove(Machine)
    zlt.Machine.RemoveData(Machine:EntIndex())
end
