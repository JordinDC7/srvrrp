/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

net.Receive("zbf_Controller_ConnectDevices", function(len)
    zclib.Debug_Net("zbf_Controller_ConnectDevices", len)

    local Controller = net.ReadEntity()
    if not IsValid(Controller) then return end

    // Inform the controller that his connected devices list changed
    Controller.DevicesUpdated = true
    Controller.TicksPerSecond =  zbf.Controller.GetTicksPerSecond(Controller)
    Controller.ConnectedDevices = zbf.Controller.GetConnectedDevices(Controller)
end)

local vec = Vector(12.6, 0, 51.4)
local ang = Angle(0, 90, 85)
function zbf.Controller.OnDraw(Controller)
    Controller:DrawModel()
    if not zclib.Convar.GetBool("zclib_cl_drawui") then return end
    if zclib.util.InDistance(Controller:GetPos(), LocalPlayer():GetPos(), 300) == false then return end

	// Dont draw the interface when the LiveFeed is open since it fucks up the 3D2D anyway
	if LocalPlayer().zbf_LiveFeed and LocalPlayer().zbf_LiveFeed > (CurTime() - 1) then return end

	// Is the controller currently disabled?
	if zbf.Controller.IsDisabled(Controller) then return end

	local w, h = 270, 180
	cam.Start3D2D(Controller:LocalToWorld(vec), Controller:LocalToWorldAngles(ang), 0.05)
		draw.RoundedBox(5, -w / 2, -h / 2, w, h, zclib.colors["ui00"])
		local JobID = Controller:GetJobID()
		local JobData = zbf.config.Jobs[JobID]
		if JobData then

			local c_type, c_amount = zbf.Jobs.GetPayment(JobID, LocalPlayer(),Controller)
			local c_icon = zbf.Currency.GetIcon(c_type) or ""
			local c_icon_color = zbf.Jobs.GetIconColor(JobID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

			local fract = (1 / JobData.ticks) * (Controller:GetJobProgress() or 0)
			zbf.vgui.ProgressBar(w * 0.8, h * 0.2, -w * 0.4, h * 0.17, fract, zclib.colors["green01"], zclib.colors["text01"])

			if zbf.Jobs.IsCryptoJob(JobID) then
				draw.SimpleText("▼", zclib.GetFont("zclib_font_medium"), 0, -70, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

				surface.SetDrawColor(c_icon_color)
				surface.SetMaterial(c_icon)
				surface.DrawTexturedRectRotated(0,-15, 70,70,math.sin(CurTime()) * 25)

				if c_amount then
					if zbf.Currency.IsMoney(c_type) then
						draw.SimpleText("+" .. zclib.Money.Display(c_amount), zclib.GetFont("zclib_font_medium"), 0, 48, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						draw.SimpleText("+" .. c_amount .. " " .. zbf.Currency.GetShort(c_type), zclib.GetFont("zclib_font_medium"), 0, 48, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				end
			else
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

				if JobData.type ~= ZBF_JOBTYPE_GENERIC then
					// Draw the job types icon in the backgroun
					local j_icon = zbf.Jobs.GetIcon(JobID)
					local bgSize = h
					surface.SetDrawColor(Color(c_icon_color.r,c_icon_color.g,c_icon_color.b,25 + 25 * math.abs(math.sin(CurTime() * 3))))
					surface.SetMaterial(j_icon)
					surface.DrawTexturedRectRotated(0,0, bgSize,bgSize,0)
				else
					// Draw the job image in the background
					if JobData.img then
						local scW,scH = 530,350

						if zbf.config.Disable2d3dMask then
							surface.SetDrawColor(zclib.colors["white_a100"])
							surface.SetMaterial(JobData.img)
							surface.DrawTexturedRectUV( -270 / 2, -185 / 2,270, 180, 0, 0, 1, 1 )
						else
							BMASKS.BeginMask("zclib_gradient_topdown_border")
							surface.SetDrawColor(color_white)
							surface.SetMaterial(JobData.img)
							surface.DrawTexturedRect(-270 / 2, -270 / 2, 270, 270)
							BMASKS.EndMask("zclib_gradient_topdown_border", -scW / 2, -scH / 2, scW, scH, 255, 0)
						end
					end
				end

				if c_amount then
					draw.SimpleText("+" .. zclib.Money.Display(c_amount), zclib.GetFont("zclib_font_medium"), 0, 48, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end


				local t_font = zclib.util.FontSwitch(JobData.name,270,zclib.GetFont("zclib_font_medium"),zclib.GetFont("zclib_font_small"))
				draw.SimpleTextOutlined(JobData.name, t_font, 0, -60, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,2, color_black)
				draw.SimpleText("▼", zclib.GetFont("zclib_font_medium"), 0, -35, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if JobData.type == ZBF_JOBTYPE_BOTNET or JobData.type == ZBF_JOBTYPE_NEURO then
					draw.SimpleText(Controller:GetTargetName(), zclib.GetFont("zclib_font_medium"), 0, 0, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				else
					if isstring(c_icon) then
						draw.SimpleText(c_icon, zclib.GetFont("zclib_font_large"), 0, 2, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						surface.SetDrawColor(color_white)
						surface.SetMaterial(c_icon)
						surface.DrawTexturedRectRotated(0,0, 40,40,0)
					end
				end
			end
		else
			draw.SimpleText(zbf.language["READY"], zclib.GetFont("zclib_font_large"), 0,  50, zclib.colors["orange01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			surface.SetDrawColor(zclib.colors["orange01"])
			surface.SetMaterial(zclib.Materials.Get("robot"))
			surface.DrawTexturedRectRotated(0,  -30, 160, 160, 0)
		end
	cam.End3D2D()

	zbf.Controller.DrawConnection(Controller)
end

local CachedColors = {}
local function FadeColor(alpha)
	if CachedColors[alpha] then return CachedColors[alpha] end
	CachedColors[alpha] = Color(121, 121, 195, alpha)
	return CachedColors[alpha]
end

local fade_speed = 3
function zbf.Controller.DrawConnection(Controller)
	if not zclib.Convar.GetBool("zbf_cl_bot_connection") then return end

    // If the connected devices changed then rebuild the LineData
    if Controller.DevicesUpdated then
        Controller.DevicesUpdated = nil
        Controller.LineData = nil
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

    if zclib.Entity.GetLookTarget() == Controller then
        Controller.LineAlpha = Lerp(FrameTime() * fade_speed, Controller.LineAlpha or 0, 1)
    else
        Controller.LineAlpha = Lerp(FrameTime() * fade_speed, Controller.LineAlpha or 0, 0)
    end
    Controller.LineAlpha = math.Clamp(math.Round(Controller.LineAlpha,4),0,1)

    if Controller.LineAlpha > 0.01 then
        Controller.LineColor = FadeColor(math.Round(255 * Controller.LineAlpha))
        if Controller.LineData then
            cam.Start3D()
                for k, v in pairs(Controller.LineData) do
                    zbf.Controller.DrawLine(Controller,v.p_start,v.p_end)
                end
        	cam.End3D()
        else
            Controller.LineData = {}
            for k, v in pairs(zbf.Controller.GetConnectedDevices(Controller)) do
                if not IsValid(v) then continue end
				//if IsValid(v:GetParent()) then continue end
                zbf.Controller.BuildLine(Controller,v)
            end
        end
    else
        Controller.LineData = nil
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

local laser_mat = Material("sprites/physbeam")
local laser_thick = 5
function zbf.Controller.DrawLine(Controller,posA,posB)

    render.SetMaterial(laser_mat)
    render.StartBeam(2)
       local dist = posA:DistToSqr(posB)
       dist = dist / 2

       local tex = math.floor(dist / 50)

        render.AddBeam(posA, laser_thick, tex * 1, Controller.LineColor)
        render.AddBeam(posB, laser_thick, tex * 2, Controller.LineColor)
    render.EndBeam()

    render.SetMaterial(zclib.Materials.Get("glow01"))
    render.DrawSprite(posB, laser_thick, laser_thick, Controller.LineColor)
end

function zbf.Controller.BuildLine(Controller,device)
    local dPos = device:GetPos()
    local cPos = Controller:GetPos()

    // Go Z from device to controller
    table.insert(Controller.LineData,{
        p_start = dPos,
        p_end = Vector(dPos.x,dPos.y,cPos.z),
    })

    // Go X from device to controller
    table.insert(Controller.LineData,{
        p_start = Vector(dPos.x,dPos.y,cPos.z),
        p_end = Vector(cPos.x,dPos.y,cPos.z),
    })

    // Go Y from device to controller
    table.insert(Controller.LineData,{
        p_start = Vector(cPos.x,dPos.y,cPos.z),
        p_end = Vector(cPos.x,cPos.y,cPos.z)
    })
end
