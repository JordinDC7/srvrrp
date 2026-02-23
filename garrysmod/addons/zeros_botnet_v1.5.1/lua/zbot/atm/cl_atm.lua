/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.ATM = zbf.ATM or {}
zbf.ATM.List = zbf.ATM.List or {}

/*

	The Crypto ATM can be used to Buy / Sell / Send crypto and also gives the player access to this crypto vault

*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

local vec = Vector(-10, 0, 59)
local ang = Angle(180, 90, -90)
function zbf.ATM.OnDraw(ATM)
	if not zclib.Convar.GetBool("zclib_cl_drawui") then return end
	if zclib.util.InDistance(ATM:GetPos(), LocalPlayer():GetPos(), 400) == false then return end

	if ATM.NextChange == nil or CurTime() > ATM.NextChange then
		ATM.CryptoID = (ATM.CryptoID or math.random(2, #zbf.Currency.List - 1)) + 1
		if ATM.CryptoID > #zbf.Currency.List then ATM.CryptoID = 2 end

		ATM.CryptoName = zbf.Currency.GetName(ATM.CryptoID)

		if zclib.util.GetTextSize(ATM.CryptoName or "",zclib.GetFont("zclib_world_font_large")) > 430 then
			if zclib.util.GetTextSize(ATM.CryptoName or "",zclib.GetFont("zclib_world_font_medium")) > 430 then
				ATM.CryptoFont = zclib.GetFont("zclib_world_font_mediumsmall")
			else
				ATM.CryptoFont = zclib.GetFont("zclib_world_font_medium")
			end
		else
			ATM.CryptoFont = zclib.GetFont("zclib_world_font_large")
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		ATM.CryptoIcon = zbf.Currency.GetIcon(ATM.CryptoID)

		local value = zbf.Currency.GetValue(ATM.CryptoID)
		value = zbf.Currency.Format(ATM.CryptoID,value)
		value = zclib.Money.Display(value)
		ATM.CryptoValue = value
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		local CryptoPerf_txt, CryptoPerf_Color = zbf.Currency.GetNicePerformance(ATM.CryptoID)
		ATM.CryptoPerf_txt = CryptoPerf_txt
		ATM.CryptoPerf_Color = CryptoPerf_Color

		ATM.NextChange = CurTime() + 3
	end

	// Dont draw the interface when the LiveFeed is open since it fucks up the 3D2D anyway
	if LocalPlayer().zbf_LiveFeed and LocalPlayer().zbf_LiveFeed > (CurTime() - 1) then return end

	local w, h = 440, 280
	cam.Start3D2D(ATM:LocalToWorld(vec), ATM:LocalToWorldAngles(ang), 0.05)
		draw.RoundedBox(5, -w / 2, -h / 2, w, h, zclib.colors["ui00"])

		if ATM.CryptoIcon then
			if zbf.config.Disable2d3dMask then
				for i = 1,12 do zclib.util.DrawCircleAdv(0 , 0 * zclib.hM, 30 * (CurTime() * 0.15) + (30 * i), 4, 15, w / 1.8,  zclib.colors["white_a2"]) end
				local hover = 25 * math.sin(CurTime() * 2)
				surface.SetDrawColor(zclib.colors["white_a50"])
				surface.SetMaterial(ATM.CryptoIcon)
				surface.DrawTexturedRectRotated(0, hover, 200, 200,math.sin(CurTime()) * 10)
			else
				local scW,scH = 850,540
				BMASKS.BeginMask("zclib_gradient_topdown_border")
				for i = 1,12 do zclib.util.DrawCircleAdv(0 , 0 * zclib.hM, 30 * (CurTime() * 0.15) + (30 * i), 4, 15, w / 1.65,  zclib.colors["ui_highlight"]) end
				local hover = 25 * math.sin(CurTime() * 2)
				surface.SetDrawColor(color_white)
				surface.SetMaterial(ATM.CryptoIcon)
				surface.DrawTexturedRectRotated(0, hover, 200, 200,math.sin(CurTime()) * 10)
				BMASKS.EndMask("zclib_gradient_topdown_border", -scW / 2, -scH / 2, scW, scH, 150, 0)
			end
		end

		//local dafont = zclib.util.FontSwitch(ATM.CryptoName or "",430,zclib.GetFont("zclib_world_font_large"),zclib.GetFont("zclib_world_font_medium"))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		draw.SimpleText(ATM.CryptoName or "", ATM.CryptoFont or zclib.GetFont("zclib_world_font_large"), 0,  0,color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		draw.SimpleText(ATM.CryptoValue or "", zclib.GetFont("zclib_world_font_medium"), 0,  35, zclib.colors["text01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(ATM.CryptoPerf_txt or "", zclib.GetFont("zclib_world_font_mediumsmall"), 0,  90, ATM.CryptoPerf_Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	cam.End3D2D()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
