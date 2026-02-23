if GAS and GAS.Logging then
    local withdraw = GAS.Logging:MODULE()

    withdraw.Category = "sPrinter"
    withdraw.Name = slib.getLang("sprinter", sPrinter.config["language"], "wthdrew")
    withdraw.Colour = sPrinter.config["logging_col"]

    withdraw:Setup(function()
        withdraw:Hook("sP:Withdrawn", "sP:bLogSupport", function(ply, ent)
            if !IsValid(ply) then return end
            withdraw:Log(slib.getLang("sprinter", sPrinter.config["language"], "log_withdrew"), GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatEntity(ent))
        end)
    end)

    GAS.Logging:AddModule(withdraw)


    local upgraded = GAS.Logging:MODULE()

    upgraded.Category = "sPrinter"
    upgraded.Name = slib.getLang("sprinter", sPrinter.config["language"], "upgrded")
    upgraded.Colour = sPrinter.config["logging_col"]

    upgraded:Setup(function()
        upgraded:Hook("sP:Upgraded", "sP:bLogSupport", function(ply, ent)
            if !IsValid(ply) then return end
            upgraded:Log(slib.getLang("sprinter", sPrinter.config["language"], "log_upgraded"), GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatEntity(ent))
        end)
    end)

    GAS.Logging:AddModule(upgraded)
end

if mLogs then
    mLogs.addCategory(
        "sPrinter",
        "sprinter",
        sPrinter.config["logging_col"],
        function()
            return true
        end
    )

    local withdraw = slib.getLang("sprinter", sPrinter.config["language"], "log_withdrew")
    withdraw = string.Replace(withdraw, "{1}", "ply")
    withdraw = string.Replace(withdraw, "{2}", "ent")

    local upgraded = slib.getLang("sprinter", sPrinter.config["language"], "log_upgraded")
    upgraded = string.Replace(upgraded, "{1}", "ply")
    upgraded = string.Replace(upgraded, "{2}", "ent")

    mLogs.addCategoryDefinitions("sprinter", {
        wthdraw = function(data) return mLogs.doLogReplace(withdraw, data) end,
        upgrded = function(data) return mLogs.doLogReplace(upgraded, data) end
    })

    local category = "sprinter"

    mLogs.addLogger(slib.getLang("sprinter", sPrinter.config["language"], "wthdrew"), "wthdraw", category)
    mLogs.addHook("sP:Withdrawn", category, function(ply, ent)
        if !IsValid(ply) then return end
        mLogs.log("wthdraw", category, {ply=mLogs.logger.getPlayerData(ply),ent=mLogs.logger.getEntityData(ent)})
    end)

    mLogs.addLogger(slib.getLang("sprinter", sPrinter.config["language"], "upgrded"), "upgrded", category)
    mLogs.addHook("sP:Upgraded", category, function(ply, ent)
        if !IsValid(ply) then return end
        mLogs.log("upgrded", category, {ply=mLogs.logger.getPlayerData(ply),ent=mLogs.logger.getEntityData(ent)})
    end)
end