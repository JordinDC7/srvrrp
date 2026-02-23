SRVRRP_GROWTH = SRVRRP_GROWTH or {}

SRVRRP_GROWTH.Version = "0.1.0"

SRVRRP_GROWTH.Config = SRVRRP_GROWTH.Config or {
    FeatureFlags = {
        observatory_enabled = true,
        net_budget_enforcement = true,
        telemetry_console_reports = true
    },
    NetBudgets = {
        -- per-player, per-minute inbound message caps
        -- set to nil / remove to disable budget for a message
        ["XeninF4:Networking"] = 120,
        ["BricksServerNet"] = 180,
        ["zclib_NET"] = 240,
        ["BRS.Net.Commands"] = 120
    },
    ReportInterval = 60,
    SlowTickMsThreshold = 30,
    MaxHistoryFrames = 300
}

function SRVRRP_GROWTH:IsEnabled(flagName)
    if not self.Config or not self.Config.FeatureFlags then return false end

    local value = self.Config.FeatureFlags[flagName]
    return value == true
end

function SRVRRP_GROWTH:SetFeatureFlag(flagName, enabled)
    if not self.Config or not self.Config.FeatureFlags then return false end
    if self.Config.FeatureFlags[flagName] == nil then return false end

    self.Config.FeatureFlags[flagName] = enabled == true
    return true
end
