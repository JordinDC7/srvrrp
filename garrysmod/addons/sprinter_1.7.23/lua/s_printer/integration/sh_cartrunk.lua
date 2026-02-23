hook.Add("PostGamemodeLoaded", "sP:CarTrunkIntegration", function()
    if CarTrunk and CarTrunk.Config then
        CarTrunk.Config.SpecificEntities["sprinter_rack"] = {
            isBlacklisted = true,
        }
    end
end)