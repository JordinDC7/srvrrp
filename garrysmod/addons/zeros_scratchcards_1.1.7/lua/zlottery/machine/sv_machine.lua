if CLIENT then return end
zlt = zlt or {}
zlt.Machine = zlt.Machine or {}


function zlt.Machine.Initialize(Machine)
    zlt.Machine.SetupData(Machine:EntIndex())
end

util.AddNetworkString("zlt_Machine_Open")
function zlt.Machine.OnUse(Machine, ply)

    local button = Machine:OnButton(ply)
    if button then

        zclib.NetEvent.Create("machine_button0" .. button, {[1] = Machine})

        Machine:EmitSound("zlt_button")

        local slotid = zlt.Machine.GetData(Machine:EntIndex(), "Slot0" .. button)
        local TicketID = zlt.Ticket.GetID(slotid)
        if TicketID then
            zlt.Machine.BuyTicket(Machine, ply, TicketID,button)
        end
    else
        if zclib.Player.IsAdmin(ply) and Machine:OnEditButton(ply) then
            net.Start("zlt_Machine_Open")
            net.WriteEntity(Machine)
            net.Send(ply)

            Machine:EmitSound("zlt_button")
        end
    end
end

function zlt.Machine.OnRemove(Machine)
    zlt.Machine.RemoveData(Machine:EntIndex())
end


function zlt.Machine.SpawnLimit(ply)
    local count = 0
    for k,v in pairs(zclib.EntityTracker.GetList()) do
        if IsValid(v) and v:GetClass() == "zlt_ticket" and zclib.Player.IsOwner(ply, v) then
            count = count + 1
        end
    end
    if count >= zlt.config.TicketLimit then
        return true
    else
        return false
    end
end

function zlt.Machine.BuyTicket(Machine,ply,TicketID,SlotID)
    local TicketData = zlt.config.Tickets[TicketID]
    if TicketData == nil then
        return
    end

    // Check if the ticket spawn limit is reached
    if zlt.Machine.SpawnLimit(ply) then
        zclib.Notify(ply, zlt.language["Spawnlimit"], 1)
        return
    end

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

    // Perform certain checks to see if the player has enough money
    if zlt.Money.Has(ply,TicketData.price) == false then
        zclib.Notify(ply, zlt.language["NotEnoughMoney"], 1)
        return
    else
        zlt.Money.Take(ply, TicketData.price)
    end

    // Run prize check and assign the price ID
    local PrizeID = zlt.Ticket.GetPrize(TicketID)

    // If enabled then the ticket will be instantly used by the player who purchased it
    if zlt.config.InstantUse then
        zlt.Ticket.InstantUse(ply,TicketData.uniqueid,PrizeID)
        return
    end

    local ent = ents.Create("zlt_ticket")
    if not IsValid(ent) then return end
    ent:SetPos(Machine:LocalToWorld(Vector(17,-18 + 7 * SlotID,34)))
    ent:SetAngles(Machine:LocalToWorldAngles(Angle(0,90,0)))
    ent:Spawn()
    ent:Activate()
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end

    timer.Simple(0.1,function()
        if IsValid(ent) then
            phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:EnableMotion(true)
            end
        end
    end)

    zclib.Player.SetOwner(ent, ply)

    ent:SetTicketID(TicketData.uniqueid)

    ent:SetPrizeID(PrizeID)

    zclib.NetEvent.Create("machine_door", {[1] = Machine})

    //zclib.Sound.EmitFromEntity("cash", ply)

    Machine:EmitSound("zlt_ticket_output")

    // If some inventory is installed then add it to his inventory
    if zlt.config.AutoPickup == true and zclib.Inventory.Pickup(ply,ent,"zlt_ticket") == true then
        local name = string.Replace(TicketData.title_val,"\n"," ")
        local str = string.Replace(zlt.language["InvAutoPickup_ticket"],"$TicketName",name)
        zclib.Notify(ply, str, 0)
    end
end

function zlt.Machine.UpdateSlotBodygroup(Machine,bg_id,slot_val)
    if slot_val == -1 or zlt.Ticket.GetID(slot_val) == nil or zlt.config.Tickets[zlt.Ticket.GetID(slot_val)] == nil then
        Machine:SetBodygroup(bg_id,0)
        Machine:EmitSound("zlt_remove_cards")
    else
        Machine:SetBodygroup(bg_id,1)
        Machine:EmitSound("zlt_add_cards")
    end
end

util.AddNetworkString("zlt_Machine_NWVar_Update")
net.Receive("zlt_Machine_NWVar_Update", function(len,ply)
    zclib.Debug_Net("zlt_Machine_NWVar_Update", len)

    if zclib.Player.Timeout(nil,ply) == true then return end
    if zclib.Player.IsAdmin(ply) == false then return end

    local Machine = net.ReadEntity()
    if not IsValid(Machine) then return end
    if Machine:GetClass() ~= "zlt_machine" then return end
    if zclib.util.InDistance(Machine:GetPos(), ply:GetPos(), 2000) == false then return end

    local dataLength = net.ReadUInt(16)
    local dataDecompressed = util.Decompress(net.ReadData(dataLength))
    local data = util.JSONToTable(dataDecompressed)

    // Update the data
    zlt.Machine.SetData(Machine:EntIndex(), data.key, data.val)

    // Call for a bodygroup update if the key that got changed was a slot
    if data.key == "Slot01" then
        zlt.Machine.UpdateSlotBodygroup(Machine,0,data.val)
    elseif data.key == "Slot02" then
        zlt.Machine.UpdateSlotBodygroup(Machine,1,data.val)
    elseif data.key == "Slot03" then
        zlt.Machine.UpdateSlotBodygroup(Machine,2,data.val)
    elseif data.key == "Slot04" then
        zlt.Machine.UpdateSlotBodygroup(Machine,3,data.val)
    end

    // Lets send the clients the updated data
    zlt.Machine.SendDataToAll(Machine)
end)



file.CreateDir("zlt")
file.CreateDir("zlt/machines")
zclib.STM.Setup("zlt_machines", "zlt/machines/" .. string.lower(game.GetMap()) .. ".txt", function()
    local data = {}

    for k, v in ipairs(ents.GetAll()) do
        if IsValid(v) and v:GetClass() == "zlt_machine" then
            table.insert(data, {
                class = v:GetClass(),
                pos = v:GetPos(),
                ang = v:GetAngles(),
                mdata = zlt.Machine.GetAllData(v:EntIndex())
            })
        end
    end

    return data
end, function(data)
    for k, v in ipairs(data) do
        if v == nil then continue end
        local ent = ents.Create("zlt_machine")
        if not IsValid(ent) then return end
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()
        local e_index = ent:EntIndex()
        zlt.Machine.SetAllData(e_index, v.mdata)
        zlt.Machine.UpdateSlotBodygroup(ent, 0, zlt.Machine.GetData(e_index, "Slot01"))
        zlt.Machine.UpdateSlotBodygroup(ent, 1, zlt.Machine.GetData(e_index, "Slot02"))
        zlt.Machine.UpdateSlotBodygroup(ent, 2, zlt.Machine.GetData(e_index, "Slot03"))
        zlt.Machine.UpdateSlotBodygroup(ent, 3, zlt.Machine.GetData(e_index, "Slot04"))

        timer.Simple(1, function()
            if IsValid(ent) then
                zlt.Machine.SendDataToAll(ent)
            end
        end)
    end

    zlt.Print("Finished loading Ticket machines!")
end, function()
    for k, v in ipairs(ents.GetAll()) do
        if IsValid(v) and v:GetClass() == "zlt_machine" then
            v:Remove()
        end
    end
end)

concommand.Add("zlt_Machine_save", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zclib.STM.Save("zlt_machines")
        zclib.Notify(ply, "Ticket machines have been saved for " .. game.GetMap(), 0)
    end
end)

concommand.Add("zlt_Machine_remove", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zclib.STM.Remove("zlt_machines")
        zclib.Notify(ply, "All Ticket machines have been removed for " .. game.GetMap(), 0)
    end
end)
