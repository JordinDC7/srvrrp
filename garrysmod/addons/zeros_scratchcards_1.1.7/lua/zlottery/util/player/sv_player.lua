if CLIENT then return end

zclib.Hook.Add("zclib_PlayerJoined", "zlt_PlayerJoined", function(ply)

    // Send main config
    zlt.Machine.SendConfig(ply)

    // Send ticket config
    zlt.Ticket.SendConfig(ply)

    timer.Simple(3,function()
        // Send machine definitions for each entity
        for k,v in ipairs(ents.FindByClass("zlt_machine")) do
            if IsValid(v) then
                zlt.Machine.SendData(v,ply)
            end
        end
    end)
end)
