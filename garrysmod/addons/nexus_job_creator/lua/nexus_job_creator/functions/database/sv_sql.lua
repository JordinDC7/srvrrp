local MODULE = {}
function MODULE:Initialize(callback)
    callback = callback or function() end

    sql.Query([[create table if not exists nexus_jobcreator_jobs (
        id integer not null primary key autoincrement,
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
        disabled BOOLEAN not null,
        unique (id)
    )]])

    sql.Query([[create table if not exists nexus_jobcreator_friends (
        id integer not null primary key autoincrement,
        jobID INTEGER not null,
        steamid64 TEXT not null,
        unique (id)
    )]])

    sql.Query([[create table if not exists nexus_jobcreator_credits (
        id integer not null primary key autoincrement,
        amount INTEGER not null,
        steamid64 TEXT not null,
        unique (id)
    )]])
end

function MODULE:Query(str, callback)
    callback = callback or function() end
    local data = sql.Query(str)
    callback(data)
end

function MODULE:GetLastID(callback)
    local data = sql.QueryValue("SELECT last_insert_rowid();")
    callback(data)
end

Nexus.JobCreator.Databases["sql"] = MODULE