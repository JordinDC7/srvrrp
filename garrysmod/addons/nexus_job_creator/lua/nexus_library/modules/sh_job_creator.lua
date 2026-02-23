Nexus.JobCreator = Nexus.JobCreator or {}

Nexus:AddLanguages("Nexus_JobCreator", "en", {
    ["Your Jobs"] = "Your Jobs",
    ["Shared Jobs"] = "Shared Jobs",
    ["Back"] = "< Back",
    ["Total Cost"] = "Total Cost:",
    ["Name"] = "Name",
    ["Minimum Chars"] = "minimum %s characters needed",
    ["Maximum Chars"] = "%s too many characters",
    ["Description"] = "Description",
    ["Job Color"] = "Job Color",
    ["Extra Health"] = "Extra Health",
    ["Extra Armor"] = "Extra Armor",
    ["Gun License"] = "Gun License",
    ["Extra Salary"] = "Extra Salary",
    ["Add Model"] = "Add Model",
    ["Steamworkshop Model"] = "Steamworkshop Playermodel URL",
    ["Import Model"] = "Import Model",
    ["Local Model"] = "Local Model",
    ["Import"] = "Import",
    ["Invalid ID"] = "Invalid ID",
    ["Model Download Error"] = "Model Download Error",
    ["Local Models"] = "Local Models",
    ["Price"] = "Price",
    ["Model Path"] = "Model Path",
    ["Category"] = "Category",
    ["Name"] = "Name",
    ["Yes"] = "Yes",
    ["No"] = "No",
    ["Guns"] = "Guns",
    ["Class"] = "Class",
    ["Damage"] = "DAMAGE",
    ["Firerate"] = "FIRERATE",
    ["Clipsize"] = "CLIPSIZE",
    ["Models"] = "Models",
    ["Total"] = "Total",
    ["Purchase"] = "Purchase",
    ["Add"] = "Add",
    ["Add Player"] = "Add a steamid64 to your job",
    ["Already On Job"] = "steamid64 already on the job!",
    ["Players"] = "Players",
    ["Invalid %"] = "Invalid %s",
    ["Not Afford"] = "You cannot afford this",
    ["Too many players"] = "Too many players added to the job",
    ["Player cant join"] = "%s cannot join the job",
    ["Created too many jobs"] = "You have created too many jobs",
    ["Failed Title"] = "Failed to fetch title",
    ["Edit"] = "Edit",
    ["Old Total"] = "Old Total",
    ["New Total"] = "New Total",
    ["Final Total"] = "Final Total",
    ["Refund of"] = "refund of",
    ["Delete"] = "Delete",
    ["Delete&Refund"] = "Delete & Refund %s",
    ["Not Owner"] = "You are not the owner of this job",
    ["Edited Job"] = "Edited Job for",
    ["Success"] = "Success",
    ["Leave Job"] = "Leave Job",
    ["Bad Name"] = "A job already has this name",
    ["Processing"] = "We are still processing your previous request please wait...",
    ["Validate"] = "Validate",
    ["Failed Validation"] = "Failed Validation",
    ["Incorrect Usergroup"] = "Incorrect Usergroup",
    ["Cannot validate"] = "Cannot validate the steamworkshop addon has been updated",
    ["Kicking Note"] = "*note validating or editing a job will kick online members off the job",
    ["Search"] = "Search...",
    ["On Cooldown"] = "You are on cooldown (%s)s",
    ["Disabled"] = "Disabled",
    ["Job Disabled"] = "Failed ( Job Disabled )",
    ["This is a Custom Job"] = "This is a custom job!",
    ["Enable"] = "Enable",
    ["Disable"] = "Disable",
    ["Maximum MB"] = "The maximum allowed size for an imported model is %s",
    ["$/MB"] = "%s / MB",
    ["Maximum Size MB"] = "max MB of %s",
    ["Your Balance"] = "Your Balance",

    [":MySQL Details"] = "MySQL Details",
    [":Cooldown"] = "Cooldown in seconds between job edits",

    [":Max MB"] = "Maximum MB a imported model could be",
    [":Max Players"] = "Maximum additional players on one job",
    [":Maximum Jobs"] = "Maximum jobs one person can own",
    [":Maximum Shared Jobs"] = "Maximum shared jobs a player can have",
    [":Maximum Name"] = "Maximum length of a jobs name",
    [":Maximum Description"] = "Maximum length of a jobs description",
    [":Maximum Health"] = "Maximum extra health a job can have",
    [":Maximum Armor"] = "Maximum extra armor a job can have",
    [":Maximum Salary"] = "Maximum salary a job can have",

    [":Base Cost"] = "Base cost of the job",
    [":Owned Job Multiplier"] = "Extra % cost per already owned custom job",
    [":Price Health"] = "Price per unit of health",
    [":Price Armor"] = "Price per unit of armor",
    [":Price Salary"] = "Price per unit of salary",
    [":Price GunLicense"] = "Price for a gun license",
    [":Price MB"] = "Price per MB of an imported model",
    [":Extra Player"] = "Price to add an additional player",
    [":Selected Currency"] = "Selected currency",
    [":Selected Database"] = "Selected database",
    [":Use LocalModels"] = "Can players use local models from a list below",
    [":Use WorkshopModels"] = "Can players import models from the workshop",
    [":Can Edit"] = "Can players edit their custom job",
    [":Can Refund Edit"] = "If the players edit their job to be worse should they get compensated",
    [":Can Refund Delete"] = "Can players refund their custom job",
    [":Refund %"] = "The % refund if players can refund their job (0-100)",
    [":NPC Model"] = "NPC Model",
    [":Admins"] = "Admin ranks who can edit/disable/validate players jobs",
})

Nexus.Builder:Start()
    :SetName("Nexus Job Creator")

    :AddMultiTextEntry({
        id = "nexus-jobcreator-mysqlDetails",
        dontNetwork = true,

        label = {":MySQL Details", "Nexus_JobCreator"},
        entries = {
            {id = "Host", default = "", placeholder = "Host", isNumeric = false},
            {id = "Port", default = 3306, placeholder = "Port", isNumeric = true},
            {id = "Username", default = "", placeholder = "Username", isNumeric = false},
            {id = "Password", default = "", placeholder = "Password", isNumeric = false},
            {id = "Database", default = "", placeholder = "Database", isNumeric = false},
        },

        onChange = function(value)
            Nexus.JobCreator.Databases[Nexus:GetValue("nexus-jobcreator-selecteddatabase")]:Initialize()
        end,
    })

    :AddButtons({
        id = "nexus-jobcreator-selecteddatabase",
        defaultValue = "sql",
        showSelected = true,
        label = {":Selected Database", "Nexus_JobCreator"},

        buttons = {
            {text = "sql", value = "sql"},
            {text = "MySQL", value = "mysql"},
        },
        onChange = function(value)
            Nexus.JobCreator.Databases[value]:Initialize()
        end,
    })

    :AddKeyTable({
        id = "nexus-jobcreator-admins",
        dontNetwork = false,
        defaultValue = {
            ["superadmin"] = true,
        },

        label = {":Admins", "Nexus_JobCreator"},

        placeholder = "Usergroup",
        isNumeric = false,

        onChange = function(value) end,
    })

    :AddButtons({
        id = "nexus-jobcreator-canEdit",
        defaultValue = "Yes",
        showSelected = true,
        label = {":Can Edit", "Nexus_JobCreator"},

        buttons = function() return {
            {text = Nexus.JobCreator:GetPhrase("Yes"), value = "Yes"},
            {text = Nexus.JobCreator:GetPhrase("No"), value = "No"},
        } end,
        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-cooldown",
        defaultValue = 10,

        label = {":Cooldown", "Nexus_JobCreator"},
        placeholder = "10",
        isNumeric = false,

        onChange = function(value) end,
    })

    :AddButtons({
        id = "nexus-jobcreator-canRefund",
        defaultValue = "Yes",
        showSelected = true,
        label = {":Can Refund Edit", "Nexus_JobCreator"},

        buttons = function() return {
            {text = Nexus.JobCreator:GetPhrase("Yes"), value = "Yes"},
            {text = Nexus.JobCreator:GetPhrase("No"), value = "No"},
        } end,
        onChange = function(value) end,
    })

    :AddButtons({
        id = "nexus-jobcreator-canRefundDelete",
        defaultValue = "Yes",
        showSelected = true,
        label = {":Can Refund Delete", "Nexus_JobCreator"},

        buttons = function() return {
            {text = Nexus.JobCreator:GetPhrase("Yes"), value = "Yes"},
            {text = Nexus.JobCreator:GetPhrase("No"), value = "No"},
        } end,
        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-refund%",
        defaultValue = 70,

        label = {":Refund %", "Nexus_JobCreator"},
        placeholder = "70",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-npcModel",
        defaultValue = "models/gman_high.mdl",

        label = {":NPC Model", "Nexus_JobCreator"},
        placeholder = "models/gman_high.mdl",
        isNumeric = false,

        onChange = function(value) end,
    })

    :AddButtons({
        id = "nexus-jobcreator-selectedcurrency",
        defaultValue = "Prometheus",
        showSelected = true,
        label = {":Selected Currency", "Nexus_JobCreator"},

        buttons = function()
            local data = {}
            for id, _ in pairs(Nexus.JobCreator.Currencies) do
                table.Add(data, {{text = id, value = id}})
            end

            return data
        end,
        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-max-players",
        defaultValue = 2,

        label = {":Max Players", "Nexus_JobCreator"},
        placeholder = "2",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-max-ownedJobs",
        defaultValue = 3,

        label = {":Maximum Jobs", "Nexus_JobCreator"},
        placeholder = "3",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-max-sharedjobs",
        defaultValue = 3,

        label = {":Maximum Shared Jobs", "Nexus_JobCreator"},
        placeholder = "3",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-max-nameLength",
        defaultValue = 25,

        label = {":Maximum Name", "Nexus_JobCreator"},
        placeholder = "25",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-max-descriptionLength",
        defaultValue = 150,

        label = {":Maximum Description", "Nexus_JobCreator"},
        placeholder = "150",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-price-baseCost",
        defaultValue = 1000,

        label = {":Base Cost", "Nexus_JobCreator"},
        placeholder = "1000",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-price-ownedJobMultiplier",
        defaultValue = 15,

        label = {":Owned Job Multiplier", "Nexus_JobCreator"},
        placeholder = "15",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-max-health",
        defaultValue = 150,

        label = {":Maximum Health", "Nexus_JobCreator"},
        placeholder = "150",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-price-health",
        defaultValue = 10,

        label = {":Price Health", "Nexus_JobCreator"},
        placeholder = "10",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-price-armor",
        defaultValue = 10,

        label = {":Price Armor", "Nexus_JobCreator"},
        placeholder = "10",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-max-armor",
        defaultValue = 150,

        label = {":Maximum Armor", "Nexus_JobCreator"},
        placeholder = "150",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-price-Salary",
        defaultValue = 10,

        label = {":Price Salary", "Nexus_JobCreator"},
        placeholder = "10",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-max-salary",
        defaultValue = 350,

        label = {":Maximum Salary", "Nexus_JobCreator"},
        placeholder = "350",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-price-GunLicense",
        defaultValue = 10,

        label = {":Price GunLicense", "Nexus_JobCreator"},
        placeholder = "10",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTable({
        id = "nexus-jobcreator-price-guns",
        defaultValue = {},

        label = { "Guns", "Nexus_JobCreator" },

        values = function() return {
            {id = "Category", type = "TextEntry", placeholder = Nexus.JobCreator:GetPhrase("Category"), isNumeric = false},
            {id = "Name", type = "TextEntry", placeholder = Nexus.JobCreator:GetPhrase("Name"), isNumeric = false},
            {id = "Class", type = "TextEntry", placeholder = Nexus.JobCreator:GetPhrase("Class"), isNumeric = false},
            {id = "Price", type = "TextEntry", placeholder = Nexus.JobCreator:GetPhrase("Price"), isNumeric = true},
        } end,

        onChange = function(value) end,
    })

    
    :AddButtons({
        id = "nexus-jobcreator-useLocalModels",
        defaultValue = 1,    
        showSelected = true,

        label = {":Use LocalModels", "Nexus_JobCreator"},
        buttons = function() return {
            {text = Nexus.JobCreator:GetPhrase("Yes"), value = 1},
            {text = Nexus.JobCreator:GetPhrase("No"), value = 0},
        } end,

        onChange = function(value) end,
    })

    :AddTable({
        id = "nexus-jobcreator-price-localModels",
        defaultValue = {},

        label = { "Local Models", "Nexus_JobCreator" },

        values = function() return {
            {id = "Category", type = "TextEntry", placeholder = Nexus.JobCreator:GetPhrase("Category"), isNumeric = false},
            {id = "Name", type = "TextEntry", placeholder = Nexus.JobCreator:GetPhrase("Name"), isNumeric = false},
            {id = "Model", type = "TextEntry", placeholder = Nexus.JobCreator:GetPhrase("Model Path"), isNumeric = false},
            {id = "Price", type = "TextEntry", placeholder = Nexus.JobCreator:GetPhrase("Price"), isNumeric = true},
        } end,

        onChange = function(value) end,
    })

    :AddButtons({
        id = "nexus-jobcreator-useWorkshopModels",
        defaultValue = 1,
        showSelected = true,

        label = {":Use WorkshopModels", "Nexus_JobCreator"},
        buttons = function() return {
            {text = Nexus.JobCreator:GetPhrase("Yes"), value = 1},
            {text = Nexus.JobCreator:GetPhrase("No"), value = 0},
        } end,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-price-perMB",
        defaultValue = 10,

        label = {":Price MB", "Nexus_JobCreator"},
        placeholder = "10",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-maxMB",
        defaultValue = 50,

        label = {":Max MB", "Nexus_JobCreator"},
        placeholder = "50",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-jobcreator-price-player",
        defaultValue = 100,

        label = {":Extra Player", "Nexus_JobCreator"},
        placeholder = "100",
        isNumeric = true,

        onChange = function(value) end,
    })
:End()
