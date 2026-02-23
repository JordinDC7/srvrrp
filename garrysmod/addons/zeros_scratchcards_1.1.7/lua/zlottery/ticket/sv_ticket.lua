if CLIENT then return end
zlt = zlt or {}
zlt.Ticket = zlt.Ticket or {}


function zlt.Ticket.Initialize(Ticket)
    zclib.EntityTracker.Add(Ticket)
end

function zlt.Ticket.OnRemove(Ticket)
    zclib.EntityTracker.Remove(Ticket)
end

// This will keep track on who is currently allowed to retrieve a prize
zlt.Ticket.UseList = zlt.Ticket.UseList or {}

/*
    zlt.Ticket.UseList = {
        [ply:SteamID()] = {
            ["UNIQUEID"] = {TicketID,PrizeID},
            ["UNIQUEID"] = {TicketID,PrizeID},
            ["UNIQUEID"] = {TicketID,PrizeID},
        }
    }
*/

// Called from CLIENT inside the Ticket Interface once the first scratch occurs and a Ticket entity exists
util.AddNetworkString("zlt_Ticket_RegisterUse")
net.Receive("zlt_Ticket_RegisterUse", function(len,ply)
    zclib.Debug_Net("zlt_Ticket_RegisterUse", len)

    if zclib.Player.Timeout(nil,ply) == true then return end

    local ticket = net.ReadEntity()
    if not IsValid(ticket) then return end
    if ticket:GetClass() ~= "zlt_ticket" then return end
    if zclib.util.InDistance(ticket:GetPos(), ply:GetPos(), 1000) == false then return end
    if ticket.Used == true then return end

    local u_ticketid = ticket:GetTicketID()
    local u_prizeid = ticket:GetPrizeID()

    if zlt.Ticket.DoesExist(u_ticketid,u_prizeid) == false then return end

    ticket:SetSolid(SOLID_NONE)
    ticket.Used = true

    // We delay the registration a bit so they cant cheat the system
    timer.Simple(0.1,function()
        if u_ticketid and u_prizeid and IsValid(ticket) and IsValid(ply) then

            // Remove ticket!
            SafeRemoveEntity(ticket)

            // Register ticket use
            local uniqueid = zlt.Ticket.RegisterUse(ply,u_ticketid,u_prizeid)

            // Informs the player about his ticket
            net.Start("zlt_Ticket_RegisterUse")
            net.WriteString(uniqueid)
            net.Send(ply)
        end
    end)
end)

// Tells the server that this user is wanting to use a scratch card
function zlt.Ticket.RegisterUse(ply,TicketID,PrizeID)
    local ply_id = ply:SteamID64()
    if zlt.Ticket.UseList[ply_id] == nil then zlt.Ticket.UseList[ply_id] = {} end

    local uniqueid = zclib.util.GenerateUniqueID("xxxxxxxxxx")
    zlt.Ticket.UseList[ply_id][uniqueid] = {
        TicketID = TicketID,
        PrizeID = PrizeID
    }

    return uniqueid
end

function zlt.Ticket.RemoveUse(ply,UniqueID)
    local ply_id = ply:SteamID64()
    if zlt.Ticket.UseList[ply_id] == nil then zlt.Ticket.UseList[ply_id] = {} end
    zlt.Ticket.UseList[ply_id][UniqueID] = nil
end

// Called from the Inventory to instantly use the ticket and register
util.AddNetworkString("zlt_Ticket_InventorytUse")
function zlt.Ticket.InventoryUse(ply,TicketID,PrizeID)
    if zlt.Ticket.DoesExist(TicketID,PrizeID) == false then
        // Tells the player that his ticket does not work anymore because it either got removed or the prize id he would have gotten does not exist anymore.
        zclib.Notify(ply, "The Ticket / Prize ID you would have gotten does not exist anymore on this server.", 1)
        return
    end

    local uniqueid = zlt.Ticket.RegisterUse(ply,TicketID,PrizeID)

    net.Start("zlt_Ticket_InventorytUse")
    net.WriteString(TicketID)
    net.WriteUInt(PrizeID,10)
    net.WriteString(uniqueid)
    net.Send(ply)
end

// Called from the interface to redeem a previoulsy registred ticket
util.AddNetworkString("zlt_Ticket_RedeemPrize")
net.Receive("zlt_Ticket_RedeemPrize", function(len,ply)
    zclib.Debug_Net("zlt_Ticket_RedeemPrize", len)

    if zclib.Player.Timeout(nil,ply) == true then return end

    local regid = net.ReadString()

    local ply_id = ply:SteamID64()
    if zlt.Ticket.UseList[ply_id] == nil then zlt.Ticket.UseList[ply_id] = {} end
    local regData = zlt.Ticket.UseList[ply_id][regid]
    if regData == nil then return end
    if regData.TicketID == nil then return end
    if regData.PrizeID == nil then return end

    // Copy data to temp table and remove the ticket from the list
    regData = table.Copy(zlt.Ticket.UseList[ply_id][regid])

    zlt.Ticket.RemoveUse(ply,regid)

    if zlt.Ticket.DoesExist(regData.TicketID,regData.PrizeID) == false then return end
    local TicketData , PrizeData = zlt.Ticket.GetData(regData.TicketID,regData.PrizeID)

    // Perform certain checks to see if the player is allowed to buy this ticket
    if TicketData.ranks and table.IsEmpty(TicketData.ranks) == false and zclib.Player.RankCheck(ply,zclib.table.invert(TicketData.ranks)) == false then
        zclib.Notify(ply, zlt.language["RankCheck"], 1)
        zclib.Notify(ply, zclib.table.ToString(zclib.table.invert(TicketData.ranks)), 1)
        return
    end

    if TicketData.jobs and table.IsEmpty(TicketData.jobs) == false and zclib.table.invert(TicketData.jobs)[zclib.Player.GetJobName(ply)] == nil then
        zclib.Notify(ply, zlt.language["JobCheck"], 1)
        zclib.Notify(ply, zclib.table.ToString(zclib.table.invert(TicketData.jobs)), 1)
        return
    end

    zlt.Ticket.PrizeTypes[PrizeData.type].func(ply,PrizeData)
end)

// Gets used to remove / abort a registered prize
    // Usally gets called if a player closes the ticket without finishing all the scratch fields
util.AddNetworkString("zlt_Ticket_KillPrize")
net.Receive("zlt_Ticket_KillPrize", function(len,ply)
    zclib.Debug_Net("zlt_Ticket_KillPrize", len)
    if zclib.Player.Timeout(nil,ply) == true then return end

    local regid = net.ReadString()

    zlt.Ticket.RemoveUse(ply,regid)
end)

// Called from the entity to open the ticket interface
util.AddNetworkString("zlt_Ticket_Open")
function zlt.Ticket.EntityUse(Ticket, ply)
    //if zclib.Player.IsOwner(ply, Ticket) == false then return end

    if zlt.Ticket.DoesExist(Ticket:GetTicketID(), Ticket:GetPrizeID()) == false then
        SafeRemoveEntity(Ticket)

        return
    end

    net.Start("zlt_Ticket_Open")
    net.WriteEntity(Ticket)
    net.Send(ply)
end

util.AddNetworkString("zlt_Ticket_Close")
zclib.Hook.Add("PlayerDeath", "zlt_ticket", function(victim)
    net.Start("zlt_Ticket_Close")
    net.Send(victim)
end)






// Called from the entity to open the ticket interface
util.AddNetworkString("zlt_Ticket_InstantUse")
function zlt.Ticket.InstantUse(ply,TicketID,PrizeID)

    if zlt.Ticket.DoesExist(TicketID, PrizeID) == false then
        return
    end

    local uniqueid = zlt.Ticket.RegisterUse(ply,TicketID,PrizeID)
    if uniqueid == nil then return end

    net.Start("zlt_Ticket_InstantUse")
    net.WriteString(TicketID)
    net.WriteUInt(PrizeID,10)
    net.WriteString(uniqueid)
    net.Send(ply)
end
