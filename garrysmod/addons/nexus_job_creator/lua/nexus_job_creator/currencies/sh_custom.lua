local currency = {}
currency.Format = function(amount)
    return "₵"..string.Comma(amount)
end

currency.CanAfford = function(ply, amount)
    return amount <= Nexus.JobCreator:GetCredits(ply)
end

currency.AddMoney = function(ply, amount)
    Nexus.JobCreator:AddCredits(ply, amount)
end

currency.GetTotalMoney = function(ply)
    return Nexus.JobCreator:GetCredits(ply)
end

Nexus.JobCreator.Currencies["Custom"] = currency