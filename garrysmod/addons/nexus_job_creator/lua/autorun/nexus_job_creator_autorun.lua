local function load()
    if not Nexus then return end

    Nexus.JobCreator = Nexus.JobCreator or {}
    Nexus.JobCreator.Currencies = Nexus.JobCreator.Currencies or {}
    Nexus.JobCreator.Databases = Nexus.JobCreator.Databases or {}

    Nexus:LoadDirectory("nexus_job_creator", {
        "nexus_job_creator/functions/database/sv_sql.lua",
        "nexus_job_creator/functions/database/sv_mysql.lua",
        "nexus_job_creator/functions/database/sv_database.lua",
    })

    hook.Run("Nexus:JobCreator:Finished")
end
load()

hook.Add("Nexus:Loaded", "Nexus:JobCreator:Loaded", function()
    load()
end)