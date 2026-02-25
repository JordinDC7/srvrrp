local blur = Material("pp/blurscreen")
function XeninUI:DrawBlur(panel, amount)
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 3 do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

if CLIENT then
	CreateClientConVar("xenin_hud_blur", 0)
end

function XeninUI:DrawBlurHUD(x, y, w, h, amt)
	local X, Y = 0, 0

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)

	for i = 1, amt or 5 do
		blur:SetFloat("$blur", (i / 3) * 5)
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(x, y, x + w, y + h, true)
		surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

function XeninUI:FormatTime(seconds, format)
	if (!seconds) then seconds = 0 end
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds / 60) % 60)
	seconds = math.floor(seconds % 60)

	return string.format(format, hours, minutes, seconds)
end





local mat_white = Material("vgui/white")

function draw.SimpleLinearGradient(x, y, w, h, startColor, endColor, horizontal)
	draw.LinearGradient(x, y, w, h, {
		{
			offset = 0,
			color = startColor
		},
		{
			offset = 1,
			color = endColor
		}
	}, horizontal)
end





function draw.LinearGradient(x, y, w, h, stops, horizontal)
	if #stops == 0 then
		return
	elseif #stops == 1 then
		surface.SetDrawColor(stops[1].color)
		surface.DrawRect(x, y, w, h)
		return
	end

	table.SortByMember(stops, "offset", true)

	render.SetMaterial(mat_white)
	mesh.Begin(MATERIAL_QUADS, #stops - 1)
	for i = 1, #stops - 1 do
		local offset1 = math.Clamp(stops[i].offset, 0, 1)
		local offset2 = math.Clamp(stops[i + 1].offset, 0, 1)
		if offset1 == offset2 then continue end

		local deltaX1, deltaY1, deltaX2, deltaY2

		local color1 = stops[i].color
		local color2 = stops[i + 1].color

		local r1, g1, b1, a1 = color1.r, color1.g, color1.b, color1.a
		local r2, g2, b2, a2
		local r3, g3, b3, a3 = color2.r, color2.g, color2.b, color2.a
		local r4, g4, b4, a4

		if horizontal then
			r2, g2, b2, a2 = r3, g3, b3, a3
			r4, g4, b4, a4 = r1, g1, b1, a1
			deltaX1 = offset1 * w
			deltaY1 = 0
			deltaX2 = offset2 * w
			deltaY2 = h
		else
			r2, g2, b2, a2 = r1, g1, b1, a1
			r4, g4, b4, a4 = r3, g3, b3, a3
			deltaX1 = 0
			deltaY1 = offset1 * h
			deltaX2 = w
			deltaY2 = offset2 * h
		end

		mesh.Color(r1, g1, b1, a1)
		mesh.Position(Vector(x + deltaX1, y + deltaY1))
		mesh.AdvanceVertex()

		mesh.Color(r2, g2, b2, a2)
		mesh.Position(Vector(x + deltaX2, y + deltaY1))
		mesh.AdvanceVertex()

		mesh.Color(r3, g3, b3, a3)
		mesh.Position(Vector(x + deltaX2, y + deltaY2))
		mesh.AdvanceVertex()

		mesh.Color(r4, g4, b4, a4)
		mesh.Position(Vector(x + deltaX1, y + deltaY2))
		mesh.AdvanceVertex()
	end
	mesh.End()
end

function XeninUI:DrawRotatedTexture(x, y, w, h, angle, cx, cy)
	cx, cy = cx or w / 2, cy or w / 2
	if (cx == w / 2 and cy == w / 2) then
		surface.DrawTexturedRectRotated(x, y, w, h, angle)
	else
		local vec = Vector(w / 2 - cx, cy - h / 2, 0)
		vec:Rotate(Angle(180, angle, -180))
		surface.DrawTexturedRectRotated(x - vec.x, y + vec.y, w, h, angle)
	end
end

function XeninUI:FormatMoney(number, decimals)
	decimals = decimals or 2

	if (number >= 1000000000) then
		return DarkRP.formatMoney(math.Round(number / 1000000000, 2)) .. " bil"
	elseif (number >= 1000000) then
		return DarkRP.formatMoney(math.Round(number / 1000000, 2)) .. " mil"
	elseif (number > 10000) then
		return DarkRP.formatMoney(math.Round(number / 1000, 2)) .. "k"
	end

	return DarkRP.formatMoney(number)
end

function XeninUI:DateToString(date)
	if !date then return "now"end


	local dif = os.ServerTime() - date

	if dif < 60 then
		return "a moment ago"
	elseif dif < (60 * 60) then
		local mins = math.Round(dif / 60, 0)
		local str = mins .. " minute" .. (mins == 1 and "" or "s") .. " ago"

		return str
	elseif dif < (60 * 60) * 24 then
		return os.date("%H:%M", date)
	else
		return os.date("%d/%m/%Y", date)
	end

	return "?"
end

if !XeninUI.__AddedPanelFunctions then
	local PNL = FindMetaTable("Panel")
	local Old_Remove = Old_Remove or PNL.Remove

	function PNL:Remove()
		for k, v in pairs(self.hooks or {}) do
			hook.Remove(v.name, k)
		end

		for k, v in pairs(self.timers or {}) do
			timer.Remove(k)
		end

		Old_Remove(self)
	end

	function PNL:AddHook(name, identifier, func)
		identifier = identifier .. " - " .. CurTime()

		self.hooks = self.hooks or {}
		self.hooks[identifier] = {
			name = name,
			func = function(...)
				if IsValid(self) then
					return func(self, ...)
				end
			end
		}

		hook.Add(name, identifier, self.hooks[identifier].func)
	end

	function PNL:GetHooks()
		return self.hooks or {}
	end

	function PNL:AddTimer(identifier, delay, rep, func)
		self.timers = self.timers or {}
		self.timers[identifier] = true

		timer.Create(identifier, delay, rep, function(...)
			if IsValid(self) then
				func(self, ...)
			end
		end)
	end

	function PNL:GetTimers()
		return self.timers or {}
	end

	function PNL:LerpAlpha(alpha, time, callback)
		callback = callback or function() end

		self.Alpha = self.Alpha or 0

		local oldThink = self.Think
		self.Think = function(pnl)
			if oldThink then oldThink(pnl)end


			self:SetAlpha(pnl.Alpha >= 250 and 255 or pnl.Alpha)
		end
		self:Lerp("Alpha", alpha, time, function()
			self.Think = oldThink
			callback(self)
		end)
	end

	XeninUI.__AddedPanelFunctions = true
end

local matLoading = Material("xenin/loading.png", "smooth")
function XeninUI:DrawLoadingCircle(x, y, size, col)
	surface.SetMaterial(matLoading)
	surface.SetDrawColor(col or ColorAlpha(XeninUI.Theme.Accent, 100))
	XeninUI:DrawRotatedTexture(x, y, size, size, ((ct or CurTime()) % 360) * -100)
end

local function toLines(text, font, mWidth)
	surface.SetFont(font)

	local buffer = {}
	local nLines = {}

	for word in string.gmatch(text, "%S+") do
		local w, h = surface.GetTextSize(table.concat(buffer, " ") .. " " .. word)
		if w > mWidth then
			table.insert(nLines, table.concat(buffer, " "))
			buffer = {}
		end
		table.insert(buffer, word)
	end

	if #buffer > 0 then
		table.insert(nLines, table.concat(buffer, " "))
	end

	return nLines
end

local function drawMultiLine(text, font, mWidth, spacing, x, y, color, alignX, alignY, sAmt, sAlpha)
	local mLines = toLines(text, font, mWidth)
	local amt = #mLines - 1
	for i, line in pairs(mLines) do
		if (sAmt and sAlpha) then
			XeninUI:DrawShadowText(line, font, x, y + (i - 1) * spacing - amt * spacing / 2, color, alignX, alignY, sAmt, sAlpha)
		else
			draw.SimpleText(line, font, x, y + (i - 1) * spacing - amt * spacing / (alignY == TEXT_ALIGN_CENTER and 2 or 1), color, alignX, alignY)
		end
	end

	return amt * spacing
end

XeninUI.DrawMultiLine = drawMultiLine

local matCredit = Material("xenin/credit_small.png", "smooth")
function XeninUI:DrawCreditsText(text, font, x, y, col, xAlign, yAlign, textY, iconColor, spacing)
	textY = textY or 1
	iconColor = iconColor or color_white
	spacing = spacing or 4

	surface.SetFont(font)
	local tw, th = surface.GetTextSize(text)
	local size = th
	if (xAlign == TEXT_ALIGN_LEFT) then
		surface.SetMaterial(matCredit)
		surface.SetDrawColor(iconColor)
		surface.DrawTexturedRect(x, y, size, size)

		draw.SimpleText(text, font, x + size + spacing, y + textY, col, xAlign, yAlign)
	elseif (xAlign == TEXT_ALIGN_CENTER) then
		x = x + size / 2 + 2

		surface.SetMaterial(matCredit)
		surface.SetDrawColor(iconColor)
		surface.DrawTexturedRect(x - tw / 2 - size - spacing, y, size, size)

		draw.SimpleText(text, font, x, y + textY, col, xAlign, yAlign)
	elseif (xAlign == TEXT_ALIGN_RIGHT) then
		x = x + size / 2 + 2

		surface.SetMaterial(matCredit)
		surface.SetDrawColor(iconColor)
		surface.DrawTexturedRect(x - tw - size - spacing, y, size, size)

		draw.SimpleText(text, font, x, y + textY, col, xAlign, yAlign)
	end
end


function XeninUI:DrawArc(x, y, ang, p, rad, color, seg)
	seg = seg or 80
	ang = (-ang) + 180
	local circle = {}

	table.insert(circle, {
		x = x,
		y = y
	})
	for i = 0, seg do
		local a = math.rad((i / seg) * -p + ang)
		table.insert(circle, {
			x = x + math.sin(a) * rad,
			y = y + math.cos(a) * rad
		})
	end

	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(circle)
end

function XeninUI:CalculateArc(x, y, ang, p, rad, seg)
	seg = seg or 80
	ang = (-ang) + 180
	local circle = {}

	table.insert(circle, {
		x = x,
		y = y
	})
	for i = 0, seg do
		local a = math.rad((i / seg) * -p + ang)
		table.insert(circle, {
			x = x + math.sin(a) * rad,
			y = y + math.cos(a) * rad
		})
	end

	return circle
end

function XeninUI:DrawCachedArc(circle, color)
	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(circle)
end


function XeninUI:DrawRoundedBoxEx(radius, x, y, w, h, col, tl, tr, bl, br)

	x = math.floor(x)
	y = math.floor(y)
	w = math.floor(w)
	h = math.floor(h)
	radius = math.Clamp(math.floor(radius), 0, math.min(h / 2, w / 2))

	if (radius == 0) then
		surface.SetDrawColor(col)
		surface.DrawRect(x, y, w, h)

		return
	end


	surface.SetDrawColor(col)
	surface.DrawRect(x + radius, y, w - radius * 2, radius)
	surface.DrawRect(x, y + radius, w, h - radius * 2)
	surface.DrawRect(x + radius, y + h - radius, w - radius * 2, radius)


	if tl then
		XeninUI:DrawArc(x + radius, y + radius, 270, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x, y, radius, radius)
	end

	if tr then
		XeninUI:DrawArc(x + w - radius, y + radius, 0, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x + w - radius, y, radius, radius)
	end

	if bl then
		XeninUI:DrawArc(x + radius, y + h - radius, 180, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x, y + h - radius, radius, radius)
	end

	if br then
		XeninUI:DrawArc(x + w - radius, y + h - radius, 90, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x + w - radius, y + h - radius, radius, radius)
	end
end

function XeninUI:DrawRoundedBox(radius, x, y, w, h, col)
	XeninUI:DrawRoundedBoxEx(radius, x, y, w, h, col, true, true, true, true)
end





function XeninUI:MaskInverse(maskFn, drawFn, pixel)
	pixel = pixel or 1

	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(pixel)

	maskFn()

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(pixel - 1)

	drawFn()

	render.SetStencilEnable(false)
	render.ClearStencil()
end

function XeninUI:Mask(maskFn, drawFn, pixel)
	pixel = pixel or 1

	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(pixel)

	maskFn()

	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(pixel)

	drawFn()

	render.SetStencilEnable(false)
	render.ClearStencil()
end

XeninUI:CreateFont("XeninUI.NPC.Overhead", 160)
function XeninUI:DrawNPCOverhead(npc, tbl)
	local alpha = tbl.alpha or 255
	local text = tbl.text or npc.PrintName or "NO NAME"
	local icon = tbl.icon
	local hover = tbl.sin
	local xOffset = tbl.xOffset or 0
	local textOffset = tbl.textOffset or 0
	local col = tbl.color or XeninUI.Theme.Accent
	col = ColorAlpha(col, alpha)

	local str = text
	surface.SetFont("XeninUI.NPC.Overhead")
	local width = surface.GetTextSize(str)
	width = width + 40
	if icon then
		width = width + (64 * 3)
	else
		width = width + 64
	end

	local center = 900 / 2
	local x = -width / 2 - 30 + (xOffset or 0)
	local y = 220
	local sin = math.sin(CurTime() * 2)
	if hover then
		y = math.Round(y + (sin * 30))
	end
	local h = 64 * 3

	local isLookingAt
	if (alpha > 0.5) then
		isLookingAt = LocalPlayer():GetEyeTrace().Entity == npc
	end
	npc.overheadAlpha = npc.overheadAlpha or 0
	if isLookingAt then
		npc.overheadAlpha = math.Clamp(npc.overheadAlpha + (FrameTime() * 3), 0, 1)
	else
		npc.overheadAlpha = math.Clamp(npc.overheadAlpha - (FrameTime() * 3), 0, 1)
	end

	local darkerColor = Color(col.r * 0.5, col.g * 0.5, col.b * 0.5)
	XeninUI:DrawRoundedBox(64, x, y, width, h, ColorAlpha(darkerColor, npc.overheadAlpha * 255))
	XeninUI:DrawRoundedBox(64, x + 8, y + 8, width - 16, h - 16, ColorAlpha(col, npc.overheadAlpha * 255))



	local textX = !icon and (width / 2) or h
	XeninUI:DrawShadowText(str, "XeninUI.NPC.Overhead", x + textX + textOffset, h / 2 + y - 10, Color(225, 225, 225, alpha), icon and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, 125)

	if icon then
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetMaterial(icon)
		local margin = tbl.icon_margin or tbl.iconMargin or 30
		surface.DrawTexturedRect(x + margin, y + margin, h - (margin * 2), h - (margin * 2))
	end





end

function XeninUI:DrawShadowText(text, font, x, y, col, xAlign, yAlign, amt, shadow)
	for i = 1, amt do
		draw.SimpleText(text, font, x + i, y + i, Color(0, 0, 0, i * (shadow or 50)), xAlign, yAlign)
	end

	draw.SimpleText(text, font, x, y, col, xAlign, yAlign)
end

function XeninUI:DrawOutlinedText(str, font, x, y, col, xAlign, yAlign, outlineCol, thickness)
	thickness = thickness or 1

	for i = 1, thickness do
		draw.SimpleText(str, font, x - thickness, y - thickness, outlineCol or color_black, xAlign, yAlign)
		draw.SimpleText(str, font, x - thickness, y + thickness, outlineCol or color_black, xAlign, yAlign)
		draw.SimpleText(str, font, x + thickness, y - thickness, outlineCol or color_black, xAlign, yAlign)
		draw.SimpleText(str, font, x + thickness, y + thickness, outlineCol or color_black, xAlign, yAlign)
	end

	draw.SimpleText(str, font, x, y, col, xAlign, yAlign)
end

function XeninUI:DrawHollowArc(cx, cy, radius, thickness, startang, endang, roughness, color)
	surface.SetDrawColor(color)

	local arc = self:CacheHollowArc(cx, cy, radius, thickness, startang, endang, roughness)

	for i, vertex in pairs(arc) do
		surface.DrawPoly(vertex)
	end
end

function XeninUI:CacheHollowArc(cx, cy, radius, thickness, startang, endang, roughness)
	local triarc = {}



	local roughness = math.max(roughness or 1, 1)
	local step = roughness


	local startang, endang = startang or 0, endang or 0

	if startang > endang then
		step = math.abs(step) * -1
	end


	local inner = {}
	local r = radius - thickness
	for deg = startang, endang, step do
		local rad = math.rad(deg)

		local ox, oy = cx + (math.cos(rad) * r), cy + (-math.sin(rad) * r)
		table.insert(inner, {
			x = ox,
			y = oy,
			u = (ox - cx) / radius + .5,
			v = (oy - cy) / radius + .5
		})
	end


	local outer = {}
	for deg = startang, endang, step do
		local rad = math.rad(deg)

		local ox, oy = cx + (math.cos(rad) * radius), cy + (-math.sin(rad) * radius)
		table.insert(outer, {
			x = ox,
			y = oy,
			u = (ox - cx) / radius + .5,
			v = (oy - cy) / radius + .5
		})
	end


	for tri = 1, #inner * 2 do
		local p1, p2, p3
		p1 = outer[math.floor(tri / 2) + 1]
		p3 = inner[math.floor((tri + 1) / 2) + 1]
		if tri % 2 == 0 then
			p2 = outer[math.floor((tri + 1) / 2)]
		else
			p2 = inner[math.floor((tri + 1) / 2)]
		end

		table.insert(triarc, {
			p1,
			p2,
			p3
		})
	end


	return triarc
end


function XeninUI:DualText(title, subtitle, x, y, w, h)
	x = x or 0
	y = y or 0

	surface.SetFont(title[2])
	local tW, tH = surface.GetTextSize(title[1])

	surface.SetFont(subtitle[2])
	local sW, sH = surface.GetTextSize(subtitle[1])

	XeninUI:DrawShadowText(title[1], title[2], x, y + (h / 2 - sH / 2), title[3], title[4], TEXT_ALIGN_CENTER, title[5], title[6])
	XeninUI:DrawShadowText(subtitle[1], subtitle[2], x, y + (h / 2 + tH / 2), subtitle[3], subtitle[4], TEXT_ALIGN_CENTER, subtitle[5], subtitle[6])
end

function XeninUI:DrawIconRotated(x, y, w, h, rotation, pnl, col, loadCol)
	col = col or color_white
	loadCol = loadCol or XeninUI.Theme.Accent

	if (pnl.Icon and type(pnl.Icon) == "IMaterial") then
		surface.SetMaterial(pnl.Icon)
		surface.SetDrawColor(col)
		XeninUI:DrawRotatedTexture(x, y, w, h, rotation)
	elseif (pnl.Icon != nil) then
		XeninUI:DrawLoadingCircle(h, h, h, loadCol)
	end
end
