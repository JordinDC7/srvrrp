/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Bot = zbf.Bot or {}

/*
	In order to simulate a blend mode we change the color src and dest
	BlendModes:
		Additive:[srcBlend = BLEND_SRC_ALPHA, destBlend = BLEND_ONE, blendFunc = BLENDFUNC_ADD]
		Multiply:[srcBlend = BLEND_DST_COLOR, destBlend = BLEND_ZERO, blendFunc = BLENDFUNC_ADD]
*/
zbf.Bot.BlendModes = {
	[0] = {
		name = zbf.language["Normal"]
	},
	[1] = {
		name = zbf.language["Additive"],
		srcBlend = BLEND_SRC_ALPHA,
		destBlend = BLEND_ONE,
		blendFunc = BLENDFUNC_ADD,
		srcBlendAlpha = BLEND_ONE,
		destBlendAlpha = BLEND_ZERO,
		blendFuncAlpha = BLENDFUNC_ADD
	},
	[2] = {
		name = zbf.language["Multiply"],
		srcBlend = BLEND_DST_COLOR,//BLEND_DST_COLOR
		destBlend = BLEND_ONE_MINUS_SRC_ALPHA, // BLEND_ZERO
		blendFunc = BLENDFUNC_ADD,
		srcBlendAlpha = BLEND_ONE,
		destBlendAlpha = BLEND_ZERO,
		blendFuncAlpha = BLENDFUNC_ADD
	}
}

/*

	You might ask why am I using a "draw HUD" hook here
	instead of using ENT:Draw from the screen entity itself.

	The answer is: HDR does not affect stuff drawn on this hook.
	In some occasions it was very hard to see the screen on dark/bright rooms...

	Of course, this means I had to keep track of
	all bots in existence, but hey, it works.

*/
zclib.Hook.Remove("PreDrawHUD", "zbf_bot_drawpaint")
zclib.Hook.Add("PreDrawHUD", "zbf_bot_drawpaint", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    cam.Start3D()
        for ent,_ in pairs(zbf.Bot.List) do
            if not IsValid(ent) then continue end

			if not ent.m_Initialized then continue end

            // If we cant see the bot then skip
            if zclib.util.IsInsideViewCone(ent:GetPos(),EyePos(),EyeAngles(),2000,2000) == false then
                continue
            end

            if ent.UpdatedPaint == nil then zbf.Bot.UpdatePaint(ent,ent:GetBotID()) end
        end
    cam.End3D()
end)

/*

    This system creates the custom bot lua material

*/
function zbf.Bot.UpdatePaint(Bot)
	local dat = zbf.config.Bots[Bot:GetBotID()]
	if dat == nil then return end
	local matID = "zbf_bot_paint_mat_" .. dat.uniqueid

	// Builds / Updates / Caches the material
	zbf.Bot.GetMaterial(matID, dat)

	Bot:SetSubMaterial()

	Bot:SetSubMaterial(dat.material.id, "!" .. matID)

	Bot.UpdatedPaint = true
end

local CachedMaterials = {}
function zbf.Bot.GetCachedMaterial(MatID,BotID)
	if CachedMaterials[ MatID ] then
		return CachedMaterials[ MatID ]
	else
		return zbf.Bot.GetMaterial(MatID, zbf.Bot.GetData(BotID))
	end
end

function zbf.Bot.DrawImgur(BotData, ImgurMat, w, h)
	local x, y = BotData.material.imgur_x, BotData.material.imgur_y
	local u0, v0 = 0 * BotData.material.imgur_scale + x, 0 * BotData.material.imgur_scale + y
	local u1, v1 = 1 * BotData.material.imgur_scale + x, 1 * BotData.material.imgur_scale + y
	surface.SetDrawColor(BotData.material.imgur_color)
	surface.SetMaterial(ImgurMat)
	surface.DrawTexturedRectUV(0, 0, w, h, u0, v0, u1, v1)
end

function zbf.Bot.DrawLogo(BotData, LogoMat, w, h)

	local x, y = BotData.material.logo_x, BotData.material.logo_y
	local img_w, img_h = w * BotData.material.logo_scale, h * BotData.material.logo_scale

	x = (w * x) - (img_w / 2)
	y = (h * y) - (img_h / 2)

	surface.SetDrawColor(BotData.material.logo_color)
	surface.SetMaterial(LogoMat)
	surface.DrawTexturedRectRotated((img_w / 2) + x, (img_h / 2) + y, img_w,img_h, BotData.material.logo_rotation or 0)
end

function zbf.Bot.DrawBaseTexture(BotData, w, h)
	local BaseTexMat = zbf.Bot.GetBasetexture(BotData)
	if not BaseTexMat then return end


	local x, y = 0,0
	local u0, v0 = 0 + x, 0 + y
	local u1, v1 = 1 + x, 1 + y

	// Draw the basetexture
	surface.SetDrawColor(BotData.material.color)

	//surface.SetTexture( surface.GetTextureID( BotData.material.diff ) )

	surface.SetMaterial(BaseTexMat)
	surface.DrawTexturedRectUV(0, 0, w, h, u0, v0, u1, v1)
end

function zbf.Bot.DrawColorMask(BotData, w, h)
	local MaskMat = zbf.Bot.GetMaskTexture(BotData)
	if not MaskMat then return end

	local x, y = 0,0
	local u0, v0 = 0 + x, 0 + y
	local u1, v1 = 1 + x, 1 + y

	// Draw the parts of the texture that should be colored
	surface.SetDrawColor(BotData.material.color)
	surface.SetMaterial(MaskMat)
	surface.DrawTexturedRectUV(0, 0, w, h, u0, v0, u1, v1)
end

function zbf.Bot.DrawEmissive(BotData, EmissveMat, w, h)
	local x, y = BotData.material.em_x, BotData.material.em_y
	local u0, v0 = 0 * BotData.material.em_scale + x, 0 * BotData.material.em_scale + y
	local u1, v1 = 1 * BotData.material.em_scale + x, 1 * BotData.material.em_scale + y
	surface.SetDrawColor(BotData.material.em_color)
	surface.SetMaterial(EmissveMat)
	surface.DrawTexturedRectUV(0, 0, w, h, u0, v0, u1, v1)
end




/*
	Draws the diffuse map of our material
*/
function zbf.Bot.DrawMaterial(w,h,BotData,ImgurMat,LogoMat)

	// Draw diff basetexture
	zbf.Bot.DrawBaseTexture(BotData, w, h)

	// Draw color mask
	//zbf.Bot.DrawColorMask(BotData,w,h)

	// Draw default imgur image
	if ImgurMat then
		if BotData.material.imgur_blendmode == 0 then
			// Dont blend
			zbf.Bot.DrawImgur(BotData,ImgurMat, w, h)
		else

			// Blend according to mode
			local bm = zbf.Bot.BlendModes[BotData.material.imgur_blendmode]
			render.OverrideBlend(true, bm.srcBlend, bm.destBlend, bm.blendFunc, bm.srcBlendAlpha, bm.destBlendAlpha, bm.blendFuncAlpha)
				zbf.Bot.DrawImgur(BotData,ImgurMat, w, h)
			render.OverrideBlend( false )
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

	// Draw logo imgur image
	if LogoMat then
		if BotData.material.logo_blendmode == 0 then
			// Dont blend
			zbf.Bot.DrawLogo(BotData, LogoMat, w, h)
		else
			// Blend according to mode
			local bm = zbf.Bot.BlendModes[BotData.material.logo_blendmode]
			render.OverrideBlend(true, bm.srcBlend, bm.destBlend, bm.blendFunc, bm.srcBlendAlpha, bm.destBlendAlpha, bm.blendFuncAlpha)
				zbf.Bot.DrawLogo(BotData, LogoMat, w, h)
			render.OverrideBlend( false )
		end
	end
end

/*
	Creates / Caches the base diffuse map as lua material and also its color mask png
*/
local CachedJPGTextures = {}
function zbf.Bot.GetBasetexture(BotData)
	local diff = BotData.material.diff
	// BUG This wont work if there doesent exist a jpg version of the diffuse texture for the model
	if CachedJPGTextures[diff] == nil then
		CachedJPGTextures[diff] = Material(diff .. ".jpg","ignorez smooth")
	end
	return CachedJPGTextures[diff]
end

local CachedMaskTextures = {}
function zbf.Bot.GetMaskTexture(BotData)
	local diff = BotData.material.diff
	if CachedMaskTextures[diff] == nil then
		CachedMaskTextures[diff] = Material(diff .. ".jpg","ignorez smooth")
	end

	return CachedMaskTextures[diff]
end

function zbf.Bot.PushTexture(r,g,b,a,MatID,OnPush)
	local rt_target = GetRenderTargetEx(MatID, zbf.config.RenderTargetSize, zbf.config.RenderTargetSize,RT_SIZE_NO_CHANGE,MATERIAL_RT_DEPTH_SHARED,bit.bor(2, 256,512,8192,32768,67108864),0,IMAGE_FORMAT_BGRA8888)

	//local rt_target = GetRenderTarget(MatID, zbf.config.RenderTargetSize or 512, zbf.config.RenderTargetSize or 512, false)
	local mat = Matrix()
	render.SuppressEngineLighting(true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	render.PushRenderTarget(rt_target)

		render.ClearDepth()
		render.Clear(r, g, b, a, true, true)

		render.OverrideAlphaWriteEnable(true, true)

			cam.Start2D()

				cam.PushModelMatrix(mat)

					render.PushFilterMag( TEXFILTER.ANISOTROPIC )
					render.PushFilterMin( TEXFILTER.ANISOTROPIC )
						pcall(OnPush)
					render.PopFilterMag()
					render.PopFilterMin()

				cam.PopModelMatrix()

			cam.End2D()

		render.OverrideAlphaWriteEnable(false)

	render.PopRenderTarget()

	render.SuppressEngineLighting(false)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	return rt_target
end

/*
	Creates / Caches / Updates the final lua material
*/
function zbf.Bot.GetMaterial(MatID, BotData)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	local m_material

	// Verify Data integrity
	BotData = zbf.Bot.VerifyData(BotData)

	local v_color = zclib.util.ColorToVector(BotData.material.color)

	local v_spec_color = zclib.util.ColorToVector(BotData.material.spec_color)
	v_spec_color = Vector(v_spec_color.r * BotData.material.reflection, v_spec_color.g * BotData.material.reflection, v_spec_color.b * BotData.material.reflection)

	local em_color = zclib.util.ColorToVector(BotData.material.em_color or color_black)

	local diff = BotData.material.diff // SkinData.diff
	local nrm = BotData.material.nrm // SkinData.nrm

	if CachedMaterials[MatID] == nil then
		zbf.Print("Cached "..tostring(MatID))
		CachedMaterials[MatID] = CreateMaterial(MatID, "VertexLitGeneric", {
			["$color2"] = v_color,
			["$basetexture"] = diff,
			["$halflambert"] = 1,
			["$model"] = 1,

			["$bumpmap"] = nrm,
			["$normalmapalphaenvmapmask"] = 1,

			["$envmap"] = "env_cubemap",
			["$envmaptint"] = v_spec_color,
			["$envmapfresnel"] = BotData.material.fresnel,
			["$fresnelreflection"] = BotData.material.fresnel,
			["$envmapfresnelminmaxexp"] = Vector(1 * BotData.material.fresnel, 4 * BotData.material.fresnel, 6 * BotData.material.fresnel),

			["$phong"] = 1,
			["$phongexponent"] = 1,
			["$phongboost"] = BotData.material.fresnel,
			["$phongfresnelranges"] = Vector(1 * BotData.material.fresnel, 4 * BotData.material.fresnel, 6 * BotData.material.fresnel),
			["$phongtint"] = v_spec_color,

			["$rimlight"] = 1,
			["$rimlightexponent"] = 5,
			["$rimlightboost"] = 1,

			["$emissiveBlendEnabled"] = 1,
			["$emissiveBlendTexture"] = "zerochain/props_clickfarm/bot/null",
			["$emissiveBlendBaseTexture"] = "zerochain/props_clickfarm/bot/null", // Change this to emissive map
			["$emissiveBlendFlowTexture"] = "zerochain/props_clickfarm/bot/null",
			["$emissiveBlendTint"] = em_color,
			["$emissiveBlendStrength"] = BotData.material.em_strength,
		})
	end
	m_material = CachedMaterials[MatID]

    m_material:SetVector("$color2", v_color)

	m_material:SetTexture("$basetexture", diff)
	m_material:SetInt("$halflambert", 1)
	m_material:SetInt("$model", 1)

	m_material:SetTexture("$bumpmap", nrm)
	m_material:SetInt("$normalmapalphaenvmapmask", 1)

	m_material:SetVector("$envmaptint", v_spec_color)
	m_material:SetFloat("$envmapfresnel", BotData.material.fresnel)
	m_material:SetFloat("$fresnelreflection", BotData.material.fresnel)
	m_material:SetVector("$envmapfresnelminmaxexp", Vector(1 * BotData.material.fresnel, 4 * BotData.material.fresnel, 6 * BotData.material.fresnel))

	m_material:SetInt("$phong", 1)
	m_material:SetFloat("$phongexponent", 2)
	m_material:SetFloat("$phongboost", BotData.material.fresnel)
	m_material:SetVector("$phongfresnelranges", Vector(1 * BotData.material.fresnel, 4 * BotData.material.fresnel, 6 * BotData.material.fresnel))
	m_material:SetVector("$phongtint", v_spec_color)

	m_material:SetInt("$rimlight", 1)
	m_material:SetFloat("$rimlightexponent", 1)
	m_material:SetFloat("$rimlightboost", 0.1)

	// $model + $normalmapalphaenvmapmask + $opaquetexture + //$vertexalpha
	m_material:SetInt("$flags", 2048 + 4194304 + 16777216 /*+ 32*/)

	///////////////////////////////
	local ImgurMat
	if BotData.material.imgur_url then
		zclib.Imgur.GetMaterial(tostring(BotData.material.imgur_url), function(result)
			if result then
				ImgurMat = result
			end
		end)
	end

	local LogoMat
	if BotData.material.logo_url then
		zclib.Imgur.GetMaterial(tostring(BotData.material.logo_url), function(result)
			if result then
				LogoMat = result
			end
		end)
	end

	local base_target = zbf.Bot.PushTexture(255,255,255,255,MatID,function()
		// 224293224
		zbf.Bot.DrawMaterial(ScrW(),ScrH(),BotData,ImgurMat,LogoMat)
	end)
	m_material:SetTexture("$basetexture", base_target)
	///////////////////////////////
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690


	///////////////////////////////
	m_material:SetVector("$emissiveBlendTint", em_color)
	m_material:SetFloat("$emissiveBlendStrength", BotData.material.em_strength)

	local EmissveMat
	if BotData.material.em_url then
		zclib.Imgur.GetMaterial(tostring(BotData.material.em_url), function(result)
			if result then
				EmissveMat = result
			end
		end)
	end

	if EmissveMat then
		local em_target = zbf.Bot.PushTexture(0,0,0,255,MatID .. "_em",function()
			zbf.Bot.DrawEmissive(BotData, EmissveMat, ScrW(),ScrH())
		end)
		m_material:SetTexture("$emissiveBlendBaseTexture", em_target)
	end
	///////////////////////////////

	// Refresh the material
	m_material:Recompute()

	return m_material
end
