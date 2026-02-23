Nexus.JobCreator.Databases[Nexus:GetValue("nexus-jobcreator-selecteddatabase")]:Initialize()

function Nexus.JobCreator:Query(str, callback)
    callback = callback or function() end
    Nexus.JobCreator.Databases[Nexus:GetValue("nexus-jobcreator-selecteddatabase")]:Query(str, callback)
end

function Nexus.JobCreator:GetLastID(callback)
    callback = callback or function() end
    Nexus.JobCreator.Databases[Nexus:GetValue("nexus-jobcreator-selecteddatabase")]:GetLastID(callback)
end