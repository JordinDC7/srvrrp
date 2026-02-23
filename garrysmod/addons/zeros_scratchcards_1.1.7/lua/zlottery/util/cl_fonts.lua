if SERVER then return end

zlt = zlt or {}
zlt.Font = zlt.Font or {}

function zlt.Font.Rebuild()
	for k, v in pairs(zlt.config.Fonts) do
		zclib.FontData["zlt_ticket_title0" .. k] = {
			font = v,
			extended = true,
			size = ScreenScale(17),
			weight = ScreenScale(500),
			antialias = true
		}

		zclib.FontData["zlt_ticket_title0" .. k .. "_big"] = {
			font = v,
			extended = true,
			size = ScreenScale(60),
			weight = ScreenScale(500),
			antialias = true
		}
	end
end
zlt.Font.Rebuild()

zclib.FontData["zlt_ticket_price"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(50),
	weight = ScreenScale(100),
	antialias = true
}

zclib.FontData["zlt_ticket_desc"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(26),
	weight = ScreenScale(100),
	antialias = true
}

zclib.FontData["zlt_ticket_desc_small"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(15),
	weight = ScreenScale(100),
	antialias = true
}

zclib.FontData["zlt_ticket_desc_tiny"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(10),
	weight = ScreenScale(100),
	antialias = true
}
