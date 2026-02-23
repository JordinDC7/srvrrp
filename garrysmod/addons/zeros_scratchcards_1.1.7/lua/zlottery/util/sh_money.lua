zlt = zlt or {}
zlt.Money = zlt.Money or {}

if SERVER then
    function zlt.Money.Give(ply, amount)
        local result = zlt.config.MoneyOverwrite.give(ply, amount)

        if result == nil then
            zclib.Money.Give(ply, amount)
        end
    end

    function zlt.Money.Take(ply, amount)
        local result = zlt.config.MoneyOverwrite.take(ply, amount)

        if result == nil then
            zclib.Money.Take(ply, amount)
        end
    end
end

function zlt.Money.Has(ply, amount)
    local result = zlt.config.MoneyOverwrite.has(ply, amount)

    if result == nil then
        result = zclib.Money.Has(ply, amount)
    end

    return result
end
