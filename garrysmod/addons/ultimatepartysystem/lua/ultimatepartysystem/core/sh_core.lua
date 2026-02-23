function UltimatePartySystem.Core.GetLanguageUnformatted(key)
    if(!UltimatePartySystem.Languages[UltimatePartySystem.Config.Language][key]) then
        return "Error loading text with key '" .. key .. "'. Double check the language file and try again."
    end

    return UltimatePartySystem.Languages[UltimatePartySystem.Config.Language][key]
end

function UltimatePartySystem.Core.FormatMoney(amount)
    return string.format(UltimatePartySystem.Settings.GetValue("moneyFormat"), string.Comma(amount))
end