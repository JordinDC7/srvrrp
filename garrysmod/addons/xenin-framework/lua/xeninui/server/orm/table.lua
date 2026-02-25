do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.ORM.Table",
    isMySQL = function(self)
      return self.conn.isMySQL()
    end,
    column = function(self, name, type)
      local col = XeninUI.ORM.Column(name, type, self:isMySQL())
      table.insert(self.columns, col)

      return col
    end,
    constraint = function(self, name)
      local constraint = XeninUI.ORM.Constraint(name, self:isMySQL())
      table.insert(self.constraints, constraint)

      return constraint
    end,
    integer = function(self, name)
      return self:column(name, "int")
    end,
    increments = function(self, name)
      local col = self:integer(name):increments():primary()

      if self:isMySQL() then
        col:unsigned()
      end

      return col
    end,
    string = function(self, name, length)
      local col = self:column(name, "varchar")
      if length then
        col:length(length)
      end

      return col
    end,
    json = function(self, name)
      return self:column(name, "json")
    end,
    boolean = function(self, name)
      return self:column(name, "boolean")
    end,
    char = function(self, name, length)
      return self:column(name, "char"):length(length)
    end,
    date = function(self, name)
      return self:column(name, "date")
    end,
    dateTime = function(self, name)
      return self:column(name, "datetime")
    end,
    decimal = function(self, name)
      return self:column(name, "decimal")
    end,
    double = function(self, name)
      return self:column(name, "double")
    end,
    float = function(self, name)
      return self:column(name, "float")
    end,
    longText = function(self, name)
      return self:column(name, "longtext")
    end,
    smallInteger = function(self, name)
      return self:column(name, "smallint")
    end,
    tinyInteger = function(self, name)
      return self:column(name, "tinyint")
    end,
    text = function(self, name)
      return self:column(name, "text")
    end,
    time = function(self, name)
      return self:column(name, "time")
    end,
    timestamp = function(self, name)
      return self:column(name, "timestamp")
    end,
    timestamps = function(self)
      self:timestamp("created_at")
      self:timestamp("updated_at")
    end,
    steamid = function(self, name)
      return self:string(name, 24)
    end,
    steamid64 = function(self, name)
      return self:char(name, 21)
    end,
    create = function(self, name)
      local columns = XeninUI:Map(self.columns, function(x)
        return x:buildString()end)
      local constraints = XeninUI:Map(self.constraints, function(x)
        return x:build()end)
      local query = [[
      CREATE TABLE IF NOT EXISTS :name: (
        :content:
      )
    ]]
      query = query:Replace(":name:", name)
      local contents = {}
      for i, v in ipairs(columns) do
        table.insert(contents, v)
      end
      for i, v in ipairs(constraints) do
        table.insert(contents, v)
      end
      query = query:Replace(":content:", table.concat(contents, ",\n        "))

      local tblName = ""
      local split = string.Explode("_", name)
      local splitSize = #split
      for i, v in ipairs(split) do
        local isLast = splitSize == i

        tblName = tblName .. (v:sub(1, 1):upper() .. v:sub(2) .. (isLast and "" or "."))
      end

      if XeninUI.Debug then
        print(query)
      end

      return XeninUI:InvokeSQL(self.conn, query, tblName .. ".Create", function() end, function(err)
        print("Failed to create table " .. tblName)
        print("Query:")
        print(query)
      end)
    end,
    __type = function(self)
      return "XeninUI.ORM.Table"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, conn, name, func, afterFunc)
      if func == nil then func = function() end
      end
      if afterFunc == nil then afterFunc = function() end
      end
      self.constraints = {}
      self.columns = {}
      self.conn = conn
      self.debugName = debugName

      func(self)

      self:create(name):next(function(result)
        afterFunc()
      end)
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
  XeninUI.ORM.Table = _class_0
end
