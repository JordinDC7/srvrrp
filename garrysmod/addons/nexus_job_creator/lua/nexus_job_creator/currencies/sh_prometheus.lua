local currency = {}

-- Resolve a player's premium balance from Prometheus (supports common API variants).
local function getPrometheusBalance(ply)
    if not IsValid(ply) then return 0 end

    if Prometheus and isfunction(Prometheus.GetPlayerCurrency) then
        local amount = Prometheus:GetPlayerCurrency(ply) or 0
        return math.max(tonumber(amount) or 0, 0)
    end

    if Prometheus and isfunction(Prometheus.GetPlayerCredits) then
        local amount = Prometheus:GetPlayerCredits(ply) or 0
        return math.max(tonumber(amount) or 0, 0)
    end

    if isfunction(ply.GetPrometheusCredits) then
        local amount = ply:GetPrometheusCredits() or 0
        return math.max(tonumber(amount) or 0, 0)
    end

    if isfunction(ply.Prometheus_GetCredits) then
        local amount = ply:Prometheus_GetCredits() or 0
        return math.max(tonumber(amount) or 0, 0)
    end

    return 0
end

-- Apply a balance change using Prometheus API (supports common API variants).
local function addPrometheusBalance(ply, amount)
    if not IsValid(ply) then return false end

    if Prometheus and isfunction(Prometheus.AddPlayerCurrency) then
        Prometheus:AddPlayerCurrency(ply, amount)
        return true
    end

    if Prometheus and isfunction(Prometheus.AddPlayerCredits) then
        Prometheus:AddPlayerCredits(ply, amount)
        return true
    end

    if isfunction(ply.AddPrometheusCredits) then
        ply:AddPrometheusCredits(amount)
        return true
    end

    if isfunction(ply.Prometheus_AddCredits) then
        ply:Prometheus_AddCredits(amount)
        return true
    end

    return false
end

currency.Format = function(amount)
    return string.Comma(math.max(math.Round(tonumber(amount) or 0), 0)) .. " crypto"
end

currency.CanAfford = function(ply, amount)
    return getPrometheusBalance(ply) >= math.max(math.Round(tonumber(amount) or 0), 0)
end

currency.AddMoney = function(ply, amount)
    local safeAmount = math.Round(tonumber(amount) or 0)
    local success = addPrometheusBalance(ply, safeAmount)

    if not success and SERVER then
        if Nexus and isfunction(Nexus.Debug) then
            Nexus:Debug("[Nexus Job Creator] Missing Prometheus currency API binding for AddMoney.")
        else
            print("[Nexus Job Creator] Missing Prometheus currency API binding for AddMoney.")
        end
    end

    return success
end

currency.GetTotalMoney = function(ply)
    local amount = getPrometheusBalance(ply)

    if amount <= 0 and SERVER and IsValid(ply) then
        if Nexus and isfunction(Nexus.Debug) then
            Nexus:Debug("[Nexus Job Creator] Prometheus returned no balance for " .. ply:SteamID64())
        else
            print("[Nexus Job Creator] Prometheus returned no balance for " .. ply:SteamID64())
        end
    end

    return amount
end

Nexus.JobCreator.Currencies["Prometheus"] = currency
