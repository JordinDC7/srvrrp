local MODULE = GAS.Logging:MODULE()
MODULE.Category = "UPS"
MODULE.Name = "Party Management"
MODULE.Colour = Color(37, 199, 116)

MODULE:Setup(function()
    -- Creation
    MODULE:Hook("ultimatepartysystem.core.partycreated", "create", function(owner, name, private, slots)
        if(private) then
            MODULE:Log("{1} created a new private party called {2} with {3} slots.", GAS.Logging:FormatPlayer(owner), GAS.Logging:Highlight(name), GAS.Logging:Highlight(slots))
            return
        end

        MODULE:Log("{1} created a new public party called {2} with {3} slots.", GAS.Logging:FormatPlayer(owner), GAS.Logging:Highlight(name), GAS.Logging:Highlight(slots))
    end)

    -- Deletion
    MODULE:Hook("ultimatepartysystem.core.partyremoved", "removed", function(owner, name)
        MODULE:Log("{1} removed their party called {2}.", GAS.Logging:FormatPlayer(owner), GAS.Logging:Highlight(name))
    end)
end)

GAS.Logging:AddModule(MODULE)