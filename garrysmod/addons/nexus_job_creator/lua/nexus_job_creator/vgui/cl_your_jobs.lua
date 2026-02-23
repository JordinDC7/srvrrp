local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin()

    self.HScrollbar = self:Add("Nexus:V2:HorizontalScrollPanel")
    self.HScrollbar:Dock(FILL)
    local old = self.HScrollbar:GetCanvas().PerformLayout
    self.HScrollbar:GetCanvas().PerformLayout = function(s, w, h)
        old(s, w, h)

        for _, v in ipairs(self.HScrollbar:GetCanvas():GetChildren()) do
            v:SetSize(h*.5, h)
        end
    end

    local ourJobs = {}
    for id, v in pairs(Nexus.JobCreator.ActiveJobs) do
        if v.Owner ~= LocalPlayer():SteamID64() then continue end
        table.insert(ourJobs, v)
    end
    
    for i = 1, (math.max(Nexus:GetValue("nexus-jobcreator-max-ownedJobs"), #ourJobs)) do
        local jobPanel = self.HScrollbar:Add("Nexus:JobCreator:JobPanel")
        jobPanel:Dock(LEFT)
        jobPanel:DockMargin(0, 0, self.margin, 0)
        jobPanel:SetID(ourJobs[i] and ourJobs[i].id or false)
    end
end

function PANEL:Paint(w, h)
end
vgui.Register("Nexus:JobCreator:YourJobs", PANEL, "EditablePanel")