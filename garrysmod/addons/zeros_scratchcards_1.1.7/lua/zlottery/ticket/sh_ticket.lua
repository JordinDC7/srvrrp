zlt = zlt or {}
zlt.Ticket = zlt.Ticket or {}
zlt.config = zlt.config or {}

// Creates a default ticket structure with var names and default value
zlt.Ticket.Structure = {
    ["color"] = Color(166, 39, 39),

    ["title_val"] = "SUPER\nCASH",
    ["title_color"] = Color(227, 154, 58),
    ["title_font"] = "zlt_ticket_title01",
    ["title_y"] = 0.24,
    ["title_x"] = 0.25,
    ["title_aligncenter"] = TEXT_ALIGN_CENTER,

    ["desc_val"] = "",
    ["desc_color"] = Color(0,0,0,255),
    ["desc_y"] = 0.90,
    ["desc_x"] = 0.98,
    ["desc_aligncenter"] = TEXT_ALIGN_RIGHT,

    ["price"] = 10,
    ["price_col"] = Color(255,255,255,255),
    ["price_bg_col"] = zclib.colors["black_a100"],

    ["scratch_url"] = "3CchPAs",
    ["scratch_col"] = Color(255,255,255,255),
    ["scratch_scale"] = 1,
    ["scratch_x"] = 0,
    ["scratch_y"] = 0,
    ["scratch_outline_col"] = Color(227, 154, 58),
    ["scratch_outline_type"] = "border01",
    ["scratch_bg_col"] = Color(255,255,255,255),

    ["bg_url"] = "",
    ["bg_x"] = 0.5,
    ["bg_y"] = 0.5,
    ["bg_scale_w"] = 0.5,
    ["bg_scale_h"] = 0.5,
    ["bg_rot"] = 0,
    ["bg_col"] = Color(255,255,255,255),

    ["symbol_url"] = "",
    ["symbol_x"] = 0.28,
    ["symbol_y"] = 0.4,
    ["symbol_scale_w"] = 0.39,
    ["symbol_scale_h"] = 0.44,
    ["symbol_rot"] = 0,
    ["symbol_col"] = Color(0,0,0,100),

    ["logo_url"] = "idt25DI",
    ["logo_x"] = 0.07,
    ["logo_y"] = 0.87,
    ["logo_scale_w"] = 0.1,
    ["logo_scale_h"] = 0.2,
    ["logo_rot"] = 0,
    ["logo_col"] = Color(255,255,255,255),
}

zlt.config.Ticket_ListID = {}
function zlt.Ticket.RebuildListIDs()
    zclib.Debug("zlt.Ticket.RebuildListIDs")
    zlt.config.Ticket_ListID = {}
    for k,v in pairs(zlt.config.Tickets) do
        if v == nil then continue end
        local uniqueid = v.uniqueid or zclib.util.GenerateUniqueID("xxxxxxxxxx")
        if v.uniqueid == nil then v.uniqueid = uniqueid end
        zlt.config.Ticket_ListID[uniqueid] = k
    end
    //zclib.Debug(zlt.config.Ticket_ListID)
end

if CLIENT then

    // Called from interface after config change
    function zlt.Ticket.UpdateConfig(config)
        local e_String = util.TableToJSON(config)
        local e_Compressed = util.Compress(e_String)
        net.Start("zlt_Ticket_Config_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.SendToServer()
    end

    // Called from SERVER after config UPDATE
    net.Receive("zlt_Ticket_Config_Update", function(len)
        zclib.Debug_Net("zlt_Ticket_Config_Update", len)

        local dataLength = net.ReadUInt(16)
        local dataDecompressed = util.Decompress(net.ReadData(dataLength))
        local config = util.JSONToTable(dataDecompressed)

        zlt.config.Tickets = table.Copy(config)

        zlt.Ticket.RebuildListIDs()

        // Causes all the machines to rebuild their preview ticket material
        for k,v in pairs(ents.FindByClass("zlt_machine")) do
            if IsValid(v) and v.Slots then
                v.Slots[1] = nil
                v.Slots[2] = nil
                v.Slots[3] = nil
                v.Slots[4] = nil
            end
        end

        // Run through all the tickets and download the used images
        for _,data in pairs(zlt.config.Tickets) do
            zclib.Imgur.GetMaterial(data.scratch_url, function(result) end)
            zclib.Imgur.GetMaterial(data.bg_url, function(result) end)
            zclib.Imgur.GetMaterial(data.symbol_url, function(result) end)
            zclib.Imgur.GetMaterial(data.logo_url, function(result) end)

            // Also preload the custom icons used in the prizelist
            for _,prizedata in pairs(data.prizelist) do
                if prizedata and prizedata.icon and prizedata.icon.icon_url then
                    zclib.Imgur.GetMaterial(prizedata.icon.icon_url, function(result) end)
                end
            end
        end
    end)
    zlt.Ticket.RebuildListIDs()
else


    // Loads the Ticket Configs once the SERVER finished loading
    timer.Simple(1,function()
        if file.Exists("zlt/config.txt", "DATA") then
            local config = file.Read("zlt/config.txt","DATA")
            if config then
                config = util.JSONToTable(config)
                zlt.config.Tickets = {}
                for k,v in pairs(config) do
                    if v == nil then continue end
                    table.insert(zlt.config.Tickets,v)
                end

                zlt.Print("Ticket Config loaded!")
                zlt.Ticket.UpdateConfig(zlt.config.Tickets)
            end
        end

        zlt.Ticket.RebuildListIDs()
    end)

    // Saves the ticket config
    util.AddNetworkString("zlt_Ticket_Config_Update")
    net.Receive("zlt_Ticket_Config_Update", function(len,ply)
        zclib.Debug_Net("zlt_Ticket_Config_Update", len)

        if zclib.Player.Timeout(nil,ply) == true then return end
        if zclib.Player.IsAdmin(ply) == false then return end

        local dataLength = net.ReadUInt(16)
        local dataDecompressed = util.Decompress(net.ReadData(dataLength))
        local config = util.JSONToTable(dataDecompressed)

        zlt.config.Tickets = table.Copy(config) or {}

        // Save to file
        if not file.Exists("zlt", "DATA") then file.CreateDir("zlt") end
        file.Write("zlt/config.txt", util.TableToJSON(config,true))

        zlt.Ticket.RebuildListIDs()

        // Inform CLIENTS
        zlt.Ticket.UpdateConfig(zlt.config.Tickets)


        // Update all machines bodygroup
        for k,v in ipairs(ents.FindByClass("zlt_machine")) do
            if IsValid(v) then
                local e_index = v:EntIndex()
                zlt.Machine.UpdateSlotBodygroup(v, 0, zlt.Machine.GetData(e_index, "Slot01"))
                zlt.Machine.UpdateSlotBodygroup(v, 1, zlt.Machine.GetData(e_index, "Slot02"))
                zlt.Machine.UpdateSlotBodygroup(v, 2, zlt.Machine.GetData(e_index, "Slot03"))
                zlt.Machine.UpdateSlotBodygroup(v, 3, zlt.Machine.GetData(e_index, "Slot04"))
            end
        end
    end)

    // Informs all CLIENTS about the config change, This is usally only needed if the config gets changed mid game without a restart
    function zlt.Ticket.UpdateConfig(config)
        local e_String = util.TableToJSON(config)
        local e_Compressed = util.Compress(e_String)
        net.Start("zlt_Ticket_Config_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.Broadcast()
    end

    function zlt.Ticket.SendConfig(ply)
        zclib.Debug("zlt.Ticket.SendConfig " .. tostring(ply))
        local e_String = util.TableToJSON(zlt.config.Tickets)
        local e_Compressed = util.Compress(e_String)
        net.Start("zlt_Ticket_Config_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.Send(ply)
    end
end



math.randomseed(os.time())
math.random()
math.random()

// Returns the table index
function zlt.Ticket.GetID(uniqueid)
    // If the provided id is actully the list id then return it
    if zlt.config.Tickets[uniqueid] then return uniqueid end
    return zlt.config.Ticket_ListID[uniqueid]
end

function zlt.Ticket.GetData(uniqueid,u_prizeid)
    local ticketID = zlt.Ticket.GetID(uniqueid)
    if ticketID == nil then return end
    local TicketData = zlt.config.Tickets[ticketID]
    local PrizeData
    if u_prizeid then
        PrizeData = TicketData.prizelist[u_prizeid]
    end
    return TicketData , PrizeData
end

function zlt.Ticket.DoesExist(uniqueid,u_prizeid)
    local ticketID = zlt.Ticket.GetID(uniqueid)

    if ticketID == nil then return false end
    local ticketData = zlt.config.Tickets[ticketID]

    if ticketData == nil then return false end

    if u_prizeid and ticketData.prizelist[u_prizeid] == nil then return false end

    return true
end


local function roundChance(what, precision)
    return math.floor(what * math.pow(10, precision) + 0.5) / math.pow(10, precision)
end
function zlt.Ticket.CalculatePreciseChance(PrizeList)
    local totalChance = 0

    for k, v in pairs(PrizeList) do
        totalChance = totalChance + v.chance
    end

    for k, v in pairs(PrizeList) do
        local chance = roundChance((100 / totalChance) * PrizeList[k].chance, 2)
        PrizeList[k].final_chance = chance
    end
end

// Returns a PrizeID from the tickets prize list according to their drop chance
function zlt.Ticket.GetPrize(TicketID)

    // Get prizelist from ticket data
    if zlt.config.Tickets[TicketID] == nil then return end
    local TicketData = zlt.config.Tickets[TicketID]

    //Loop over items and create the chances
    local totalChance = 0
    for _ ,PrizeData in pairs(TicketData.prizelist) do
        totalChance = totalChance + (PrizeData.final_chance or PrizeData.chance)
    end

    local num = math.Rand(0.01 , totalChance)
    local prevCheck = 0
    local PrizeID = nil

    for id ,PrizeData in pairs(TicketData.prizelist) do
        local _chance = PrizeData.final_chance or PrizeData.chance
        if num >= prevCheck and num <= (prevCheck + _chance) then
            PrizeID = id
        end
        prevCheck = prevCheck + _chance
    end

    return PrizeID
end

if SERVER then
    concommand.Add("zlt_debug_ticket", function(ply, cmd, args)
        if zclib.Player.IsAdmin(ply) then
            local TickedID = tonumber(args[1]) or 1
            local TicketData = zlt.config.Tickets[TickedID]

            local count = 10000
            local WinList = {}
            print(" ")
            print("///////////////////////////")
            print(TicketData.title_val, "Used Tickets: " .. count)

            for i = 1, count do
                local prize = zlt.Ticket.GetPrize(TickedID)
                local prizeData = TicketData.prizelist[prize]

                if prizeData then
                    local prizetype = zlt.Ticket.PrizeTypes[prizeData.type]
                    local winData = prizetype.name .. " " .. prizetype.display_value(prizeData)
                    WinList[winData] = (WinList[winData] or 0) + 1
                end
            end

            print(" ")
            print("PrizeItem:          DrawCount:")

            for k, v in pairs(WinList) do
                print("  " .. k .. string.rep(" ", 20 - k:len()) .. v .. "x")
            end

            print("///////////////////////////")
            print(" ")
        end
    end)
end

function zlt.Ticket.GetPrizeDisplayValue(TicketID, PrizeID)
    local TicketData = zlt.config.Tickets[TicketID]
    if TicketData == nil then return 0 end
    local prizedata = TicketData.prizelist[PrizeID]
    if prizedata == nil then return 0 end
    local prizeType = zlt.Ticket.PrizeTypes[prizedata.type]

    return prizeType.display_value(prizedata)
end

function zlt.Ticket.GetPrizeName(TicketID,PrizeID)
    local TicketData = zlt.config.Tickets[TicketID]
    if TicketData == nil then return 0 end

    local prizedata = TicketData.prizelist[PrizeID]
    if prizedata == nil then return 0 end

    return prizedata.name
end

function zlt.Ticket.DidWin(TicketID,PrizeID)
    local TicketData = zlt.config.Tickets[TicketID]
    if TicketData == nil then return false end

    local prizedata = TicketData.prizelist[PrizeID]
    if prizedata == nil then return false end

    return prizedata.type > 1
end

function zlt.Ticket.GetPrizeIcon(TicketID,PrizeID)
    local TicketData = zlt.config.Tickets[TicketID]
    if TicketData == nil then return end

    local prizedata = TicketData.prizelist[PrizeID]
    if prizedata == nil then return end

    local prizeType = zlt.Ticket.PrizeTypes[prizedata.type]

    local icon_mat = prizeType.icon
    local icon_color

    if prizeType.icon_overwrite then
        local icon_overwrite = prizeType.icon_overwrite(prizedata)
        if icon_overwrite and icon_overwrite ~= false then
            icon_mat = icon_overwrite
            icon_color = color_white
        end
    end

    // Overwrite Icon if admin defined custom url
    if prizedata.icon and prizedata.icon.icon_url then
        zclib.Imgur.GetMaterial(tostring(prizedata.icon.icon_url), function(result)
            if result then
                icon_mat = result
            end
        end)

        icon_color = prizedata.icon.icon_color
    end

    local icon_stencil = false
    if prizedata.icon and prizedata.icon.icon_stencil then
        icon_stencil = prizedata.icon.icon_stencil
    end


    return icon_mat , icon_color , icon_stencil
end

// Returns the cost of the ticket
function zlt.Ticket.GetPrice(uniqueid)
    if zlt.Ticket.DoesExist(uniqueid) == false then return end
    local TicketID = zlt.Ticket.GetID(uniqueid)
    local TicketData = zlt.config.Tickets[TicketID]
    if TicketData and TicketData.price then
        return TicketData.price,zclib.Money.Display(TicketData.price)
    end
end

function zlt.Ticket.GetRarityColor(TicketID,PrizeID)
    local TicketData = zlt.config.Tickets[TicketID]
    if TicketData == nil then return end

    // Find the largest %
    local max = 1
    for k, v in pairs(TicketData.prizelist) do
        local chan = v.final_chance or v.chance
        if chan > max then
            max = chan
        end
    end

    local prizedata = TicketData.prizelist[PrizeID]
    if prizedata == nil then return end


    local _chance = (100 / max) * (prizedata.final_chance or prizedata.chance)


    //local _chance = prizedata.final_chance or prizedata.chance

    // BUG This does not correct scale, as the final_chance is not the correct value
    // TODO This should actully work now, so lets just chill

    local raritycolor = "86, 182, 194"
    local mindiff = 100
    for chanc,col in pairs(zlt.config.RarityColors) do
        local diff = math.abs(chanc - _chance)
        if diff < mindiff then
            mindiff = diff
            raritycolor = col
        end
    end
    return raritycolor
end
