local currency = {}
currency.Format = function(amount)
    return BRICKSCREDITSTORE.FormatCredits(amount, true)
end

currency.CanAfford = function(ply, amount)
    return ply:GetBRCS_Credits() >= amount
end

currency.AddMoney = function(ply, amount)
    ply:AddBRCS_Credits(amount)
end

currency.GetTotalMoney = function(ply)
    return ply:GetBRCS_Credits()
end

Nexus.JobCreator.Currencies["bricks credit store"] = currency