/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Bot = zbf.Bot or {}
zbf.Bot.List = zbf.Bot.List or {}

function zbf.Bot.Initialize(Bot)
	Bot.m_BeingLookedAt = zclib.Entity.GetLookTarget() == Bot
	Bot.m_Controller = Bot:GetController()
	Bot.m_IsWorking = false
	Bot:DestroyShadow()
	timer.Simple(0.2, function()
		if IsValid(Bot) then
			Bot.m_Initialized = true
		end
	end)
end

local Effect_vec = Vector(-5, 0, 0)
local Effect_ang = Angle(90, 0, 0)
function zbf.Bot.OnThink(Bot)
	if not Bot then return end
	if not Bot:IsValid() then return end

	if zbf.Bot.List[Bot] == nil then
		zbf.Bot.List[Bot] = true
	end

	if not zbf.Bot.IsLoaded(Bot) then return end

	Bot.m_BeingLookedAt = zclib.Entity.GetLookTarget() == Bot
	Bot.m_Controller = Bot:GetController()
	Bot.m_IsWorking = zbf.Bot.IsWorking(Bot)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	if Bot.m_IsWorking and IsValid(Bot.m_Controller) then
		local JobData = zbf.Jobs.GetData(Bot.m_Controller:GetJobID())
		if JobData == nil then return end

		Bot.progress = (Bot.progress or 0) + (zbf.Bot.GetTicksPerSecond(Bot) * FrameTime())
		if Bot.progress > 1 then
			Bot.progress = 0

			local effect = zbf.Jobs.GetWorldEffect(JobData.type)
			if zclib.Convar.GetBool("zbf_cl_bot_effects") and Bot and Bot:IsValid() and effect then
				zclib.Effect.ParticleEffect(effect, Bot:LocalToWorld(Effect_vec), Bot:LocalToWorldAngles(Effect_ang), Bot)
			end
		end

		if zclib.util.InDistance(LocalPlayer():GetPos(), Bot:GetPos(), 200) then
			local rotation_speed = 2160 * zbf.Bot.GetSpeed(Bot)
			for i = 1, 6 do
				local bone = Bot:LookupBone("fan0" .. i)

				if bone then
					Bot:ManipulateBoneAngles(bone, Angle(0, CurTime() * rotation_speed, 0))
				end
			end
		end
	end
end

function zbf.Bot.OnRemove(Bot)
	Bot:StopSound("zbf_fan")
	Bot:StopSound("zbf_neuro_loop")
	zbf.Bot.List[Bot] = nil
end

/*

    This will handle the fan sound of the bots

*/
// This function will not only loop the fan sound but also change its pitch according to the speed
function zbf.Bot.FanSound(Bot, shouldplay)
	if shouldplay and not IsValid(zclib_main_panel) and zclib.util.InDistance(LocalPlayer():GetPos(), Bot:GetPos(), 100) then
		if Bot.FanSound == nil then
			Bot.FanSound = CreateSound(Bot, zbf.Bot.IsNeuroBot(Bot) and "zbf_neuro_loop" or "zbf_fan")
		end

		if Bot.FanSound:IsPlaying() == false then
			if zbf.Bot.IsNeuroBot(Bot) then
				Bot.FanSound:PlayEx(zclib.Convar.Get("zclib_cl_sfx_volume"), 100)
			else
				Bot.FanSound:PlayEx(zclib.Convar.Get("zclib_cl_sfx_volume"), Lerp(zbf.Bot.GetSpeed(Bot), 90, 135))
			end
			Bot.LastVolume = zclib.Convar.Get("zclib_cl_sfx_volume")
		else
			if Bot.LastVolume ~= zclib.Convar.Get("zclib_cl_sfx_volume") then
				Bot.LastVolume = zclib.Convar.Get("zclib_cl_sfx_volume")
				Bot.FanSound:ChangeVolume(Bot.LastVolume, 0)
			end
		end
	else
		if Bot.FanSound ~= nil and Bot.FanSound:IsPlaying() == true then
			Bot.FanSound:ChangeVolume(0, 0)
			Bot.FanSound:Stop()
			Bot.FanSound = nil
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

local ActiveFanSounds = 0
zclib.Timer.Remove("zbf_bot_fan_soundhandler")
zclib.Timer.Create("zbf_bot_fan_soundhandler", 0.3, 0, function()
	ActiveFanSounds = 0

	for ent, _ in pairs(zbf.Bot.List) do
		if not IsValid(ent) then continue end

		if ActiveFanSounds < 15 and ent.m_IsWorking then
			zbf.Bot.FanSound(ent, true)
			ActiveFanSounds = ActiveFanSounds + 1
		else
			zbf.Bot.FanSound(ent, false)
		end
	end
end)

/*

    This handels the drawing of the 2d3d Screen

*/
local offset_near = Vector(0.9,0,0)
local ang_offset = Angle(0,90,90)
local scale = 0.05
function zbf.Bot.OnDraw(Bot)
	Bot:DrawModel()
	if not Bot.m_Initialized then return end
	if not zclib.Convar.GetBool("zclib_cl_drawui") then return end
	if not zclib.util.InDistance(LocalPlayer():GetPos(), Bot:GetPos(), 300) then return end

	if not zbf.Bot.IsLoaded(Bot) then return end

	// Update everything if it wasnt drawn for a long period
	local curDraw = CurTime()
	if Bot.LastDraw == nil then
		Bot.LastDraw = curDraw
	end
	if Bot.LastDraw < (curDraw - 0.25) then
		Bot.UpdatedPaint = nil
	end
	Bot.LastDraw = curDraw

	if Bot:GetBotID() ~= Bot.LastID then
		Bot.LastID = Bot:GetBotID()
		Bot.UpdatedPaint = nil
		Bot:InvalidateBoneCache()

		for i = 1, Bot:GetBoneCount() do
			Bot:ManipulateBoneAngles(i, angle_zero)
		end
	end

	// Dont draw the interface when the LiveFeed is open since it fucks up the 3D2D anyway
	if LocalPlayer().zbf_LiveFeed and LocalPlayer().zbf_LiveFeed > (CurTime() - 1) then return end

	cam.Start3D2D(Bot:LocalToWorld(offset_near), Bot:LocalToWorldAngles(ang_offset), scale) zbf.Bot.DrawInfo(Bot, 0, 0) cam.End3D2D()

	if IsValid(Bot.m_Controller) then
		zbf.Bot.DrawConnection(Bot)
	end
end

function zbf.Bot.DrawError(Bot, w, h, x, y)
	local ErrorType = Bot:GetErrorType()
	local ErrorData = zbf.Bot.GetErrorData(ErrorType)
	draw.RoundedBox(0, -w / 2 + x, -h / 2 + y, w, h, ErrorData.color)

	if ErrorData.fixable then
		local txt = Bot.m_BeingLookedAt and zbf.language["[FIX]"] or ErrorData.name
		draw.SimpleText(txt, zclib.util.FontSwitch(txt,160,zclib.GetFont("zclib_world_font_mediumsmall"),zclib.GetFont("zclib_world_font_tiny")), x, y + 20, zclib.colors["black_a200"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(ErrorData.name,zclib.util.FontSwitch(ErrorData.name,160,zclib.GetFont("zclib_world_font_mediumsmall"),zclib.GetFont("zclib_world_font_tiny")), x, y + 20, zclib.colors["black_a200"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if ErrorData.fixable and Bot.m_BeingLookedAt then
		local rot = 15 * math.sin(CurTime() * 6)
		rot = zclib.util.SnapValue(15, rot)
		surface.SetDrawColor(zclib.colors["black_a200"])
		surface.SetMaterial(zclib.Materials.Get("repair"))
		surface.DrawTexturedRectRotated(x, y - 45, 100, 100, rot)
	else
		ErrorData.OnDraw(Bot, w, h, x, y)
	end

	// Draw the loading bar of the error
	local fract = (1 / Bot:GetErrorTime()) * (CurTime() - Bot:GetErrorStart())
	fract = math.Clamp(fract,0,1)
	if ErrorType == ZBF_ERRORTYPE_CRASH then fract = 1 - fract end
	zbf.vgui.ProgressBar(w * 0.8, h * 0.1, -w * 0.4, h * 0.3, fract,zclib.colors["black_a200"],zclib.colors["black_a200"])

	surface.SetDrawColor(zclib.colors["black_a100"])
	surface.SetMaterial(zclib.Materials.Get("scanlines"))
	surface.DrawTexturedRectRotated(x, y, w, h, 0)
end

function zbf.Bot.DrawInfo(Bot, x, y)
	local w, h = 6.5 / scale, 10 / scale
	draw.RoundedBox(0, -w / 2 + x, -h / 2 + y, w, h, zclib.colors["ui00"])

	// Draw error screen
	if zbf.Bot.HasError(Bot) then
		zbf.Bot.DrawError(Bot, w, h, x, y)
		return
	end

	if IsValid(Bot.m_Controller) then

		local JobID = Bot.m_Controller:GetJobID()
		if JobID > 0 and not zbf.Bot.IsCompatible(Bot, JobID) then
			zbf.Bot.Draw_NotCompatible(Bot, x, y)
			return
		end

		if Bot.m_IsWorking then
			zbf.Bot.Draw_Working(Bot, x, y)
		else
			zbf.Bot.Draw_Ready(Bot, x, y)
		end
	else
		zbf.Bot.Draw_NoController(Bot, x, y)
	end

	// Draw the health
	if not zclib.Convar.GetBool("zbf_cl_bot_simplescreen") then
		zbf.vgui.ProgressBar(100, 20, -50, 60, (1 / Bot:GetMaxHealth()) * Bot:Health(), zclib.colors["text01"], zclib.colors["text01"])
	end


	if zbf.config.LevelSystem.enabled then
		zbf.Bot.Draw_Level(Bot, 48, -82)
	end

	surface.SetDrawColor(zclib.colors["black_a100"])
	surface.SetMaterial(zclib.Materials.Get("scanlines"))
	surface.DrawTexturedRectRotated(x, y, w, h, 0)
end

local CachedColor = {}
local function GetCachedBangColor(val)
	val = math.Round(val)
	if CachedColor[val] then return CachedColor[val] end
	CachedColor[val] = Color(255,255,255,val)
	return CachedColor[val]
end
local CryptoBGColor = Color(80, 80, 90)
function zbf.Bot.Draw_Working(Bot, x, y)

	if zclib.Convar.GetBool("zbf_cl_bot_simplescreen") then
		surface.SetDrawColor(zclib.colors["green01"])
		surface.SetMaterial(zclib.Materials.Get("robot"))
		surface.DrawTexturedRectRotated(x, y - 40, 100, 100, 0)

		zbf.vgui.ProgressBar(100, 20, -50, 40, Bot.progress or 0, zclib.colors["green01"], zclib.colors["text01"])
		return
	end

	local JobID = Bot.m_Controller:GetJobID()

	if zbf.Jobs.IsCryptoJob(JobID) then

		surface.SetDrawColor(CryptoBGColor)
		surface.SetMaterial(zclib.Materials.Get("item_bg"))
		surface.DrawTexturedRectRotated(0, 0, 130 , 200 , 0)

		local c_type = zbf.Jobs.GetPayment(JobID, LocalPlayer(),Controller)
		local c_icon = zbf.Currency.GetIcon(c_type)
		local c_icon_color = zbf.Jobs.GetIconColor(JobID)

		surface.SetDrawColor(c_icon_color)
		surface.SetMaterial(c_icon)
		surface.DrawTexturedRectRotated(-20,-15, 60,60,math.sin(CurTime()) * 25)

		local speed = zbf.Bot.GetSpeed(Bot)
		local rot = 45 * math.sin(CurTime() * 40 * speed)
		rot = zclib.util.SnapValue(45, rot) + 25

		if rot >= 70 then
			Bot.BangSize = Lerp(FrameTime() * 10,Bot.BangSize or 90,90)
			Bot.BangAlpha = Lerp(FrameTime() * 10,Bot.BangAlpha or 100,0)

			surface.SetDrawColor(GetCachedBangColor(Bot.BangAlpha))
			surface.SetMaterial(zclib.Materials.Get("bang"))
			surface.DrawTexturedRectRotated(-15,-30, Bot.BangSize,Bot.BangSize,math.sin(CurTime()) * 90)

			if not IsValid(zclib_main_panel) and Bot.PlayTickSound == nil then
				Bot:EmitSound("zbf_mine")

				// At this speed the bang animation doesent work anymore since its so fast, so lets just set the size to large
				if speed > 0.8 then
					Bot.BangSize = 90
					Bot.BangAlpha = 255
				else
					Bot.BangSize = 0
					Bot.BangAlpha = 255
				end
				Bot.PlayTickSound = true
			end
		else
			Bot.PlayTickSound = nil
		end

		surface.SetDrawColor(zclib.colors["text01"])
		surface.SetMaterial(zclib.Materials.Get("mine"))
		surface.DrawTexturedRectRotated(20, -45, 100 , 100 ,rot)
	else
		local JobData = zbf.Jobs.GetData(JobID)
		if JobData and JobData.img then
			local bounce = math.sin(CurTime() * 2)
			local rot = 15 * bounce
			local scl = Lerp(math.abs(bounce), 1, 1.25)

			if zbf.config.Disable2d3dMask then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(JobData.img)
				surface.DrawTexturedRectUV( -130/2, -100, 130, 115, 0, 0, 1, 1 )
				//surface.DrawTexturedRectRotated(0, -35, 130, 130, 0)
			else
				BMASKS.BeginMask("zclib_gradient_topdown_border")
				surface.SetDrawColor(color_white)
				surface.SetMaterial(JobData.img)
				surface.DrawTexturedRectRotated(0, -40, 130 * scl, 130 * scl, rot)
				BMASKS.EndMask("zclib_gradient_topdown_border", -127, -161, 254, 254, 255, 0)
			end
		end
	end


	// Make a pop sound for neuro calculation
	if not IsValid(zclib_main_panel) and zbf.Jobs.IsNeuroJob(JobID) and Bot.progress >= 0.9 and (Bot.PlayPopSound == nil or CurTime() > Bot.PlayPopSound) then
		Bot:EmitSound("zbf_neuro")
		Bot.PlayPopSound = CurTime() + 0.1
	end

	zbf.vgui.ProgressBar(100, 20, -50, 30, Bot.progress or 0, zclib.colors["green01"], zclib.colors["text01"])
end

function zbf.Bot.Draw_Ready(Bot, x, y)
	draw.SimpleText(zbf.language["READY"], zclib.GetFont("zclib_world_font_small"), x, y + 20, zclib.colors["orange01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	surface.SetDrawColor(zclib.colors["orange01"])
	surface.SetMaterial(zclib.Materials.Get("robot"))
	surface.DrawTexturedRectRotated(x, y - 45, 100, 100, 0)
end

function zbf.Bot.Draw_NoController(Bot, x, y)
	draw.SimpleText(zbf.language["MISSING"], zclib.GetFont("zclib_world_font_small"), x, y + 20, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(zbf.language["CONTROLLER"], zclib.GetFont("zclib_world_font_tiny"), x, y + 45, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	surface.SetDrawColor(zclib.colors["text01"])
	surface.SetMaterial(zclib.Materials.Get("robot"))
	surface.DrawTexturedRectRotated(x, y - 45, 100, 100, 0)
end

function zbf.Bot.Draw_NotCompatible(Bot, x, y)
	draw.SimpleText(zbf.language["NOT"], zclib.GetFont("zclib_world_font_small"), x, y + 20, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(zbf.language["COMPATIBLE"], zclib.GetFont("zclib_world_font_tiny"), x, y + 45, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	surface.SetDrawColor(zclib.colors["text01"])
	surface.SetMaterial(zclib.Materials.Get("close"))
	surface.DrawTexturedRectRotated(x, y - 45, 100, 100, 0)
end

local LevelColors = {
	[1] = Color(255,255,255),
	[2] = Color(101,150,226),
	[3] = Color(77,105,205),
	[4] = Color(137,71,255),
	[5] = Color(212,43,230),
	[6] = Color(235,75,75),
	[7] = Color(202,171,5),
	[8] = Color(136,106,8),
}
zbf.Bot.SortedLevelColors = nil

function zbf.Bot.GetLevelColor(Bot)
	if zbf.Bot.SortedLevelColors == nil then
		zbf.Bot.SortedLevelColors = {}
		for i=1,zbf.config.LevelSystem.max_level do
			local step = math.Clamp((8 / zbf.config.LevelSystem.max_level) * i,1,8)
			zbf.Bot.SortedLevelColors[(8 / zbf.config.LevelSystem.max_level) * i] = LevelColors[math.floor(step)]
		end
	end
	return zbf.Bot.SortedLevelColors[(8 / zbf.config.LevelSystem.max_level) * Bot:GetLevel()] or color_white
end

function zbf.Bot.Draw_Level(Bot, x, y)
	local currentLevel = Bot:GetLevel()
	if Bot.LastLevel ~= currentLevel then
		if Bot.LastLevel and currentLevel > Bot.LastLevel then
			local pos = Bot:GetPos()
			pos = pos:ToScreen()
			zclib.Sound.EmitFromPosition(Bot:GetPos(),"upgrade")
			zclib.Effect.ParticleEffect("zbf_level_up", Bot:LocalToWorld(Vector(10, 0, 0)), Bot:GetAngles())
		end
		Bot.LastLevel = currentLevel
	end


	surface.SetDrawColor(zbf.Bot.GetLevelColor(Bot))
	surface.SetMaterial(zclib.Materials.Get("star01"))
	surface.DrawTexturedRectRotated(x, y, 36, 36, 0)

	draw.SimpleText(currentLevel, zclib.GetFont("zclib_world_font_tiny"), x, y + 2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

zclib.Snapshoter.SetPath("zbf_bot",function(ItemData)
	if ItemData.BotID then
		return "zbf/bot_" .. ItemData.BotID
	elseif ItemData.extraData and ItemData.extraData.BotID then

		// This is for zeros vendingmachine, fucking gay
		return "zbf/bot_" .. ItemData.extraData.BotID
	end
end)

zclib.Hook.Add("zclib_RenderProductImage", "zclib_RenderProductImage_ZerosBotNet", function(cEnt, ItemData)
	if ItemData.class == "zbf_bot" and ItemData then
		if ItemData.BotID then
			local data = zbf.Bot.GetData(ItemData.BotID)
			if data then
				// 224293224
				cEnt:SetSubMaterial(data.material.id, "!zbf_bot_paint_mat_" .. ItemData.BotID)
			end
		elseif ItemData.extraData and ItemData.extraData.BotID then
			// This is for zeros vendingmachine, fucking gay
			local data = zbf.Bot.GetData(ItemData.extraData.BotID)
			if data then
				cEnt:SetSubMaterial(data.material.id, "!zbf_bot_paint_mat_" .. ItemData.extraData.BotID)
			end
		end
	end
end)





/*
	Everything bellow is not used anymore, probably could be removed
*/

local CachedColors = {}
local function FadeColor(alpha)
	if CachedColors[alpha] then return CachedColors[alpha] end
	CachedColors[alpha] = Color(121, 121, 195, alpha)
	return CachedColors[alpha]
end

local fade_speed = 3
function zbf.Bot.DrawConnection(Bot)

	if not zclib.Convar.GetBool("zbf_cl_bot_connection") then return end

    // If the connected devices changed then rebuild the LineData
    if Bot.DevicesUpdated then
        Bot.DevicesUpdated = nil
        Bot.LineData = nil
    end

    if zclib.Entity.GetLookTarget() == Bot then
        Bot.LineAlpha = Lerp(FrameTime() * fade_speed, Bot.LineAlpha or 0, 1)
    else
        Bot.LineAlpha = Lerp(FrameTime() * fade_speed, Bot.LineAlpha or 0, 0)
    end
    Bot.LineAlpha = math.Clamp(math.Round(Bot.LineAlpha,4),0,1)

    if Bot.LineAlpha > 0.01 then
        Bot.LineColor = FadeColor(math.Round(255 * Bot.LineAlpha))
        if Bot.LineData then
            cam.Start3D()
                for k, v in pairs(Bot.LineData) do
                    zbf.Bot.DrawLine(Bot,v.p_start,v.p_end)
                end
        	cam.End3D()
        else
            Bot.LineData = {}
            zbf.Bot.BuildLine(Bot,Bot.m_Controller)
        end
    else
        Bot.LineData = nil
    end
end

local laser_mat = Material("sprites/physbeam")
local laser_thick = 10
function zbf.Bot.DrawLine(Bot,posA,posB)

    render.SetMaterial(laser_mat)
    render.StartBeam(2)
       local dist = posA:DistToSqr(posB)
       dist = dist / 2

       local tex = math.floor(dist / 50)

        render.AddBeam(posA, laser_thick, tex * 1, Bot.LineColor)
        render.AddBeam(posB, laser_thick, tex * 2, Bot.LineColor)
    render.EndBeam()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

    render.SetMaterial(zclib.Materials.Get("glow01"))
    render.DrawSprite(posB, laser_thick, laser_thick, Bot.LineColor)
end

function zbf.Bot.BuildLine(Bot,controller)
    local dPos = Bot:GetPos()
    local cPos = controller:GetPos()

    // Go Z from device to controller
    table.insert(Bot.LineData,{
        p_start = dPos,
        p_end = Vector(dPos.x,dPos.y,cPos.z),
    })
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

    // Go X from device to controller
    table.insert(Bot.LineData,{
        p_start = Vector(dPos.x,dPos.y,cPos.z),
        p_end = Vector(cPos.x,dPos.y,cPos.z),
    })

    // Go Y from device to controller
    table.insert(Bot.LineData,{
        p_start = Vector(cPos.x,dPos.y,cPos.z),
        p_end = Vector(cPos.x,cPos.y,cPos.z)
    })
end
