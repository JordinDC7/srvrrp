local currency = {}
currency.Format = function(amount)
    return string.Comma(amount).." tokens"
end

currency.CanAfford = function(ply, amount)
    return mTokens.CanPlayerAfford(ply, amount)
end

currency.AddMoney = function(ply, amount)
    mTokens.AddPlayerTokens(ply, amount)
end

currency.GetTotalMoney = function(ply)
    if SERVER then
        return mTokens.GetPlayerTokens(ply)
    else
        return mTokens.PlayerTokens
    end
end

Nexus.JobCreator.Currencies["MTokens"] = currency