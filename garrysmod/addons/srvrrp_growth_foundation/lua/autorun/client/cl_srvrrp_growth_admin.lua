if SERVER then return end
if not SRVRRP_GROWTH then return end

local function formatInt(value)
    return string.Comma(math.floor(tonumber(value) or 0))
end

local function updatePanel(frame, report)
    if not IsValid(frame) then return end
    if not istable(report) then return end

    frame.summary:SetText(string.format(
        "Avg Tick: %.2fms | Avg Ents: %.2f | Threshold: %.2f | Generated: %s",
        tonumber(report.summary and report.summary.avgTickMs) or 0,
        tonumber(report.summary and report.summary.avgEntityCount) or 0,
        tonumber(report.summary and report.summary.threshold) or 0,
        os.date("%Y-%m-%d %H:%M:%S", tonumber(report.generatedAt) or os.time())
    ))

    frame.list:Clear()
    for _, row in ipairs(report.topNets or {}) do
        frame.list:AddLine(
            tostring(row.name or "unknown"),
            formatInt(row.inboundCount),
            formatInt(row.inboundBytes),
            formatInt(row.outboundCount),
            formatInt(row.outboundBytes),
            formatInt(row.blocked)
        )
    end
end

function SRVRRP_GROWTH:OpenObservatoryPanel()
    if IsValid(self.AdminObsFrame) then
        self.AdminObsFrame:MakePopup()
        return
    end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("SRVRRP Observatory")
    frame:SetSize(900, 560)
    frame:Center()
    frame:MakePopup()

    local summary = vgui.Create("DLabel", frame)
    summary:Dock(TOP)
    summary:SetTall(32)
    summary:DockMargin(8, 8, 8, 4)
    summary:SetText("Waiting for observatory snapshot...")
    frame.summary = summary

    local btn = vgui.Create("DButton", frame)
    btn:Dock(TOP)
    btn:SetTall(28)
    btn:DockMargin(8, 0, 8, 8)
    btn:SetText("Refresh")
    btn.DoClick = function()
        net.Start("srvrrp_obs_admin_request")
        net.SendToServer()
    end

    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:DockMargin(8, 0, 8, 8)
    list:AddColumn("Message")
    list:AddColumn("In Count")
    list:AddColumn("In Bytes")
    list:AddColumn("Out Count")
    list:AddColumn("Out Bytes")
    list:AddColumn("Blocked")
    frame.list = list

    self.AdminObsFrame = frame

    net.Start("srvrrp_obs_admin_request")
    net.SendToServer()
end

net.Receive("srvrrp_obs_admin_snapshot", function()
    local raw = net.ReadString()
    local decoded = util.JSONToTable(raw or "")
    if not istable(decoded) then return end
    updatePanel(SRVRRP_GROWTH.AdminObsFrame, decoded)
end)
