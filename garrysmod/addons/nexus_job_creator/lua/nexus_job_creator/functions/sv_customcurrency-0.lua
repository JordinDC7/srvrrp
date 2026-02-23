util.AddNetworkString("Nexus:JobCreator:NetworkCredits")
util.AddNetworkString("Nexus:JobCreator:NetworkCredits")
hook.Add("Nexus:FullyLoaded", "Nexus:JobCreator:LoadCredits", function(ply)
    Nexus.JobCreator:Query("SELECT amount FROM nexus_jobcreator_credits WHERE steamid64 = "..sql.SQLStr(ply:SteamID64())..";", function(data)
        if not IsValid(ply) then return end

        local amount = 0
        if #(data or {}) == 0 then
            Nexus.JobCreator:Query("INSERT INTO nexus_jobcreator_credits (steamid64, amount) VALUES("..sql.SQLStr(ply:SteamID64())..", "..amount..");")
        else
            amount = tonumber(data[1].amount)
        end

        net.Start("Nexus:JobCreator:NetworkCredits")
        net.WriteUInt(amount, 32)
        net.Send(ply)

        ply.JobCredits = ply.JobCredits or 0
        ply.JobCredits = amount
    end)
end)

function Nexus.JobCreator:AddCredits(ply, amount)
    ply.JobCredits = ply.JobCredits or 0
    ply.JobCredits = ply.JobCredits + amount

    net.Start("Nexus:JobCreator:NetworkCredits")
    net.WriteUInt(ply.JobCredits, 32)
    net.Send(ply)

    Nexus.JobCreator:Query("UPDATE nexus_jobcreator_credits SET amount = "..ply.JobCredits.." WHERE steamid64 = "..sql.SQLStr(ply:SteamID64())..";")
end

concommand.Add("job_creator_add_money", function(ply, cmd, args)
    if IsValid(ply) then Nexus.JobCreator:Notification(ply, "Use Server Console", 3) return end

    local steamid64 = args[1]
    if not steamid64 then Nexus.JobCreator:Notification(ply, "ERROR", 3) return end

    local amount = tonumber(args[2])
    if not amount then Nexus.JobCreator:Notification(ply, "ERROR", 3) return end

    local activePlayer = player.GetBySteamID64(steamid64)
    if activePlayer then
        Nexus.JobCreator:AddCredits(activePlayer, amount)
        Nexus.JobCreator:Notification(activePlayer, "Success", 3)
        return
    end

    Nexus.JobCreator:Query("SELECT amount FROM nexus_jobcreator_credits WHERE steamid64 = "..sql.SQLStr(steamid64)..";", function(data)
        local baseAmount = 0
        if #(data or {}) == 0 then
            Nexus.JobCreator:Query("INSERT INTO nexus_jobcreator_credits (steamid64, amount) VALUES("..sql.SQLStr(steamid64)..", "..amount..");")
        else
            baseAmount = tonumber(data[1].amount)
        end
        baseAmount = baseAmount + amount

        Nexus.JobCreator:Query("UPDATE nexus_jobcreator_credits SET amount = "..baseAmount.." WHERE steamid64 = "..sql.SQLStr(steamid64)..";")
    end)
end)