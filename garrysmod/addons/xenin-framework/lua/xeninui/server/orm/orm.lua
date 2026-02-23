do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.ORM.ORM",
    tableWrapper = function(self)
      return function(...)
        XeninUI.ORM.Table(self.connection, ...)
      end
    end,
    createMigrationTable = function(self, callback)
      if callback == nil then callback = function() end
      end
      local run = 0
      local function done()
        run = run + 1

        if (run == 2) then
          callback()
        end
      end

      XeninUI.ORM.Table(self.connection, "xenin_framework_migrations", function(tbl)
        tbl:string("id"):length(191):primary()
        tbl:date("last_updated"):nullable()
        tbl:integer("times_updated"):default(0)
      end, done)
      XeninUI.ORM.Table(self.connection, "xenin_framework_seeds", function(tbl)
        tbl:string("id"):length(191):primary()
        tbl:integer("version")
      end, done)
    end,
    getConnection = function(self)
      return self.connection
    end,
    isMySQL = function(self)
      return self:getConnection().isMySQL()
    end,
    getConnectionTypeAsString = function(self)
      return self:isMySQL() and "[MySQL]" or "[SQLite]"
    end,
    begin = function(self)
      local connStr = self:getConnectionTypeAsString()
      if XeninUI.Debug then
        MsgC(Color(201, 176, 15), connStr, XeninUI.Theme.Green, " Starting transaction\n")
      end
      self.connection.begin()
      self.transaction = true
    end,
    rawQuery = function(self, sql)
      return self:orm("RAW_QUERY"):rawSQL(sql):run()
    end,
    commit = function(self)
      local p = XeninUI.Promises.new()

      self.connection.commit(function()
        p:resolve()
      end)

      self.transaction = false
      local connStr = self:getConnectionTypeAsString()
      if XeninUI.Debug then
        MsgC(Color(201, 176, 15), connStr, XeninUI.Theme.Green, " Commiting transaction\n")
      end

      return p
    end,
    strToDate = function(self, date)

      if (!self:isMySQL()) then return date end

      local year = date:sub(1, 2)
      local month = date:sub(3, 4)
      local day = date:sub(5, 6)
      local str = "STR_TO_DATE('" .. tostring(year) .. "-" .. tostring(month) .. "-" .. tostring(day) .. "', '%Y-%m-%d')"

      return self.b.raw(str)
    end,
    handleMigration = function(self, file, tablePath)
      local conn = self.connection
      local split = string.Explode("_", file)
      local date = split[1]
      table.remove(split, 1)
      local tableName = table.concat(split, "_")
      tableName = tableName:sub(1, #tableName - 4)

      self:orm("xenin_framework_migrations"):select():where("last_updated", ">=", self:strToDate(date)):where("id", "=", tableName):getOne():next(function(result)
        if (!result) then
          include(tablePath .. file)(self:tableWrapper())

          self:orm("xenin_framework_migrations"):upsert({
            last_updated = date,
            id = tableName,
            times_updated = self.b.upsertDifference({
              insert = self.b.raw(0),
              update = self.b.raw("times_updated + 1")
            })
          }, {
          "id" }):run()

        end
      end, function(err)
        Error(err)
      end)
    end,
    orm = function(self, tableName, returnId)
      return self.b(tableName, self.connection, returnId, self.transaction)
    end,
    __type = function(self)
      return "XeninUI.ORM.ORM"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, tablePath, connection)
      if connection == nil then connection = XeninDB
      end
      self.b = XeninUI.ORM.Builder
      self.connection = connection
      self:createMigrationTable(function()
        local files = file.Find(tostring(tablePath) .. "*.lua", "LUA")
        for i, file in ipairs(files) do
          self:handleMigration(file, tablePath)
        end
      end, function(err)
        Error(err)
      end)

      return self
    end,
    __base = _base_0
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  XeninUI.ORM.ORM = _class_0
end
