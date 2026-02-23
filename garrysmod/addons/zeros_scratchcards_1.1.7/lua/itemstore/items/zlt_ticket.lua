ITEM.Name = "Lottery Ticket"
ITEM.Description = "A lottery ticket."
ITEM.Model = "models/zerochain/props_lottery/ticket.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()
	local name = "Unkown"
	local TicketID = self:GetData("TicketID")
	local ListID = zlt.Ticket.GetID(TicketID)
	if ListID and zlt.config.Tickets[ListID] then
		name = zlt.config.Tickets[ListID].title_val
	end

	return self:GetData("Name", name)
end

// Only merge the same ingredient item ids
function ITEM:CanMerge( item )
	return false
end

// Only pickup if the student owns this item, NO STEALING!
function ITEM:CanPickup(ply, ent)
	return zclib.Player.IsOwner(ply, ent)
end

// We save the uniqueid to be save should the ingredients config order or item count change
function ITEM:SaveData(ent)
	self:SetData("TicketID", ent:GetTicketID())
	self:SetData("PrizeID", ent:GetPrizeID())
end

// Get the list id using the uniqueid and set it in the entity
function ITEM:LoadData(ent)
	local ticketID = self:GetData("TicketID")
	local prizeID = self:GetData("PrizeID")
	if ticketID and prizeID and zlt.Ticket.DoesExist(ticketID,prizeID) then
		ent:SetTicketID(ticketID)
		ent:SetPrizeID(prizeID)
	else
		SafeRemoveEntity(ent)
	end
end

function ITEM:Drop(ply,con,slot,ent)
	zclib.Player.SetOwner(ent, ply)
end


function ITEM:Use( pl )

	if SERVER then
		zlt.Ticket.InventoryUse(pl,self:GetData("TicketID"),self:GetData("PrizeID"))
	end

	return self:TakeOne()
end
