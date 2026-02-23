local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_lottery/ticket.mdl")

ITEM:AddAction("Use", 1, function(self, ply, ent, tbl)
    if CLIENT then return true end

	local data = tbl.data
	zlt.Ticket.InventoryUse(ply,data.TicketID,data.PrizeID)

end, function() return true end)

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data

	local ticketID = data.TicketID
	local prizeID = data.PrizeID
	if ticketID and prizeID and zlt.Ticket.DoesExist(ticketID,prizeID) then

		ent:SetTicketID(ticketID)
		ent:SetPrizeID(prizeID)
		zclib.Player.SetOwner(ent, ply)
	else
		SafeRemoveEntity(ent)
	end
end)

ITEM:SetDescription(function(self, tbl)

	local ticketID = zlt.Ticket.GetID(tbl.data.TicketID)
	local desc = ""
	if zlt.config.Tickets[ticketID] and zlt.config.Tickets[ticketID].desc_val then
		desc = zlt.config.Tickets[ticketID].desc_val
	end

	return {
		desc,
	}
end)

function ITEM:GetData(ent)
	return {
		TicketID = ent:GetTicketID(),
		PrizeID = ent:GetPrizeID(),
	}
end

function ITEM:GetDisplayName(item)
	return self:GetName(item)
end

function ITEM:GetName(item)
	local name = "Unkown"

	local ent = isentity(item)
	local ticketID
	if ent then
		ticketID = zlt.Ticket.GetID(item:GetTicketID())
	else
		ticketID = zlt.Ticket.GetID(item.data.TicketID)
	end
	if ticketID and zlt.config.Tickets[ticketID] and zlt.config.Tickets[ticketID].title_val then
		name = string.Replace(zlt.config.Tickets[ticketID].title_val,"\n"," ")
	end

	return name
end

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 25,
		X = 0,
		Y = -22,
		Z = 25,
		Angles = Angle(0, -160, 0),
		Pos = Vector(0, 0, 0)
	}
end

function ITEM:GetClientsideModel(tbl, mdlPanel)
	if tbl.data.TicketID then

		local ticketID = zlt.Ticket.GetID(tbl.data.TicketID)
		if ticketID and zlt.config.Tickets[ticketID] then
			zlt.Ticket.UpdateMaterial(mdlPanel.Entity,ticketID)
		end
	end
end

ITEM:Register("zlt_ticket")
