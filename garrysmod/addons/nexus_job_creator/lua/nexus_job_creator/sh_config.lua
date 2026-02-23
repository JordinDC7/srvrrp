function Nexus.JobCreator:GetPhrase(str, ply)
    if CLIENT then
        local text = Nexus:GetPhrase(str, "Nexus_JobCreator")
        return text
    else
        if IsValid(ply) then
            return Nexus:GetPhrase(str, "Nexus_JobCreator", ply)
        else
            return Nexus:GetRawPhrase(str, "Nexus_JobCreator", Nexus:GetDefaultLanguage())            
        end
    end
end