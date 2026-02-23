local MODULE = GAS.Logging:MODULE()
MODULE.Category = "UPS"
MODULE.Name = "Player Activity"
MODULE.Colour = Color(37, 199, 116)

MODULE:Setup(function()
    -- Joining
    MODULE:Hook("ultimatepartysystem.core.joinparty", "join", function(ply, ownerID, partyInfo)
        if(partyInfo.private) then
            MODULE:Log("{1} joined the private party {2}.", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(partyInfo.name))
            return
        end

        MODULE:Log("{1} joined the party {2}.", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(partyInfo.name))
    end)

    -- Leaving
    MODULE:Hook("ultimatepartysystem.core.leaveparty", "leave", function(ply, ownerID, partyInfo)
        if(partyInfo.private) then
            MODULE:Log("{1} left the private party {2}.", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(partyInfo.name))
            return
        end

        MODULE:Log("{1} left the party {2}.", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(partyInfo.name))
    end)
    MODULE:Hook("ultimatepartysystem.core.playerkicked", "kicked", function(kicked, ply, partyInfo)
        if(partyInfo.private) then
            MODULE:Log("{1} was kicked from the private party {2} by {3}.", GAS.Logging:FormatPlayer(kicked), GAS.Logging:Highlight(partyInfo.name), GAS.Logging:FormatPlayer(ply))
            return
        end

        MODULE:Log("{1} was kicked from the party {2} by {3}.", GAS.Logging:FormatPlayer(kicked), GAS.Logging:Highlight(partyInfo.name), GAS.Logging:FormatPlayer(ply))
    end)
end)

GAS.Logging:AddModule(MODULE)