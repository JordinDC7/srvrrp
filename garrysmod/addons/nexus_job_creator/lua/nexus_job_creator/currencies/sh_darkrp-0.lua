local currency = {}
currency.Format = function(amount)
    return DarkRP.formatMoney(amount)
end

currency.CanAfford = function(ply, amount)
    return ply:canAfford(amount)
end

currency.AddMoney = function(ply, amount)
    ply:addMoney(amount)
end

currency.GetTotalMoney = function(ply)
    return ply:getDarkRPVar("money")
end

Nexus.JobCreator.Currencies["darkrp"] = currency