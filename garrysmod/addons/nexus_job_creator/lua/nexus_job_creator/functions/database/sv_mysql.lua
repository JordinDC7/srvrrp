local MODULE = {}
local queue = {}
function MODULE:Initialize(callback)
    callback = callback or function() end

    require("mysqloo")
    assert(mysqloo, "MySQLoo is not installed")

    local info = Nexus:GetValue("nexus-jobcreator-mysqlDetails")
    local query = mysqloo.connect(info.Host, info.Username, info.Password, info.Database, info.Port)
    query.onConnected = function(db)
        Nexus.JobCreator.MySQLDatabase = db

        print("[ Nexus ][ Job Creator ] Connected MySQL DB")
        Nexus.JobCreator:Query([[CREATE TABLE IF NOT EXISTS nexus_jobcreator_jobs (
            id INTEGER PRIMARY KEY AUTO_INCREMENT,
            owner TEXT not null,
            name TEXT not null,
            description TEXT,
            color TEXT not null,
            extraHealth INTEGER not null,
            extraArmor INTEGER not null,
            extraSalary INTEGER not null,
            gunLicense BOOLEAN not null,
            models TEXT not null,
            guns TEXT not null,

            verified BOOLEAN not null,
            disabled BOOLEAN not null
        );]], function() print("[ Nexus ][ Job Creator ] Job Creator database 1 created") end)

        Nexus.JobCreator:Query([[CREATE TABLE IF NOT EXISTS nexus_jobcreator_friends (
            id INTEGER PRIMARY KEY AUTO_INCREMENT,
            jobID INTEGER not null,
            steamid64 TEXT not null
        );]], function() print("[ Nexus ][ Job Creator ] Job Creator database 2 created") end)

        Nexus.JobCreator:Query([[CREATE TABLE IF NOT EXISTS nexus_jobcreator_credits (
            id INTEGER PRIMARY KEY AUTO_INCREMENT,
            amount INTEGER not null,
            steamid64 TEXT not null
        );]], function() print("[ Nexus ][ Job Creator ] Job Creator database 3 created") end)

        for _, v in ipairs(queue) do
            MODULE:Query(v[1], v[2])
        end

        timer.Remove("Nexus:JobCreator:MySQL")
    end

    query.onConnectionFailed = function(db, err)
        timer.Create("Nexus:JobCreator:MySQL", 1, 0, function()
            print("[ Nexus ][ Job Creator ] Please restart your server MySQL details are wrong")
            print(err)
        end)
    end

    query:connect()
end

function MODULE:Query(str, callback)
    callback = callback or function() end
    if not Nexus.JobCreator.MySQLDatabase then
        table.Add(query, {{str, callback}})
        return
    end

    local query = Nexus.JobCreator.MySQLDatabase:query(str)

    query.onSuccess = function(s, data)
        callback(data)
    end

	query.onError = function(tr, err)
        print(str)
        print("[ Nexus ][ Job Creator ] "..err)
    end

	query:start()
end

function MODULE:GetLastID(callback)
    callback = callback or function() end

    MODULE:Query("SELECT LAST_INSERT_ID() AS id", function(data)
        callback(data and data[1].id or false)
    end)
end

Nexus.JobCreator.Databases["mysql"] = MODULE