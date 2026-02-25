do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.ORM.Helpers",
    __type = function(self)
      return "XeninUI.ORM.Helpers"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self) end,
    __base = _base_0,
    ASC = "ASC",
    DESC = "DESC",
    UPSERT = true,
    NULL = {
    raw = "NULL"
    },
    raw = function(str)
      return {
      raw = str
      }
    end,
    fixArgument = function(arg)
      if (!istable(arg)) then
        return XeninUI.ORM.Helpers.construct(arg)
      end

      return arg
    end,
    construct = function(arg)
      return {
        mysql = arg,
        sqlite = arg
      }
    end,
    duplicate = function(arg)
      return {
        left = arg,
        right = arg
      }
    end,
    days = function(amt)
      local days = (60 * 60 * 24) * amt

      return {
        mysql = {
          left = days,
          right = "INTERVAL " .. tostring(amt) .. " DAYS"
        },
        sqlite = XeninUI.ORM.Helpers.duplicate(days)
      }
    end,
    timeSubtract = function(current, subtract)
      current = XeninUI.ORM.Helpers.fixArgument(current)
      subtract = XeninUI.ORM.Helpers.fixArgument(subtract)

      return {
        mysql = tostring(current.mysql.left) .. " - " .. tostring(subtract.mysql.right),
        sqlite = tostring(current.sqlite.left) .. " - " .. tostring(subtract.sqlite.right)
      }
    end,
    nowDateTime = function()
      return {
      raw = "now()"
      }
    end,
    now = function()
      return {
        mysql = XeninUI.ORM.Helpers.duplicate("UNIX_TIMESTAMP(now())"),
        sqlite = XeninUI.ORM.Helpers.duplicate("strftime('%s', 'now')")
      }
    end,
    timestamp = function(row)
      return {
        mysql = "UNIX_TIMESTAMP(" .. row .. ")",
        sqlite = "strftime('%s', " .. row .. ")"
      }
    end,
    unixEpochToTimestamp = function(epoch)
      return {
        mysql = "FROM_UNIXTIME(" .. tostring(epoch) .. ")",
        sqlite = "DATETIME(" .. tostring(epoch) .. ", 'unixepoch')"
      }
    end,
    cast = function(field, alias, length, typeMySQL, typeSQLite)
      if typeSQLite == nil then typeSQLite = typeMySQL
      end
      local lengthStr = ""
      if length then
        lengthStr = "(" .. tostring(length) .. ")"
      end

      local str = "CAST(" .. tostring(field) .. " AS " .. tostring(typeMySQL) .. tostring(lengthStr) .. ") AS " .. tostring(alias)

      return XeninUI.ORM.Helpers.construct(str)
    end,
    castChar = function(field, alias, length)
      return XeninUI.ORM.Helpers.cast(field, alias, length, "CHAR", "CHAR")
    end,
    alias = function(field, alias)
      local mysql = istable(field) and field.mysql or field
      local sqlite = istable(field) and field.sqlite or field

      return {
        mysql = tostring(mysql) .. " AS " .. tostring(alias),
        sqlite = tostring(sqlite) .. " AS " .. tostring(alias)
      }
    end,
    count = function(fields, alias)
      local str = "COUNT(" .. tostring(fields) .. ")"
      if alias then str = str .. "AS " .. tostring(alias)
      else
        return XeninUI.ORM.Helpers.raw(str)
      end

      return XeninUI.ORM.Helpers.construct(str)
    end,
    max = function(fields, alias)
      local str = "MAX(" .. tostring(fields) .. ")"
      if alias then str = str .. "AS " .. tostring(alias)
      else
        return XeninUI.ORM.Helpers.raw(str)
      end

      return XeninUI.ORM.Helpers.construct(str)
    end,
    between = function(low, high)
      return XeninUI.ORM.Helpers.construct("BETWEEN " .. tostring(low) .. " AND " .. tostring(high))
    end,
    isNull = function()
      return XeninUI.ORM.Helpers.construct("IS NULL")
    end,
    sid64 = function(ply)
      if (!IsValid(ply)) then return end

      return XeninUI.ORM.Helpers.raw(ply:SteamID64())
    end,
    inArray = function(array, forceString)
      local str = ""
      local length = #array
      for i, v in ipairs(array) do
        local isNumber = tonumber(v)
        if (isNumber and !forceString) then str = str .. v
        else
          local escape = v:Replace("\"", "\\")
          str = str .. "\"" .. tostring(escape) .. "\""
        end

        if (i != length) then str = str .. ", "
        end
      end

      return XeninUI.ORM.Helpers.raw("IN (" .. tostring(str) .. ")")
    end,
    upsertDifference = function(tbl)
      return {
        raw = true,
        upsertDifference = true,
        data = tbl
      }
    end
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  XeninUI.ORM.Helpers = _class_0
end
do
  local _class_0
  local _parent_0 = XeninUI.ORM.Helpers
  local _base_0 = {
    __name = "XeninUI.ORM.Builder",
    __base = XeninUI.ORM.Helpers.__base,
    construct = function(self, tbl)
      if (!istable(tbl)) then return tbl end
      if tbl.raw then return tbl end

      if self:isMySQL() then
        return XeninUI.ORM.Builder.raw(tbl.mysql)
      else
        return XeninUI.ORM.Builder.raw(tbl.sqlite)
      end
    end,
    getTableName = function(self)
      if istable(self.aliasTblName) then
        return self.aliasTblName[1]
      elseif isstring(self.aliasTblName) then
        return self.aliasTblName
      end

      return self.tblName
    end,
    unpackString = function(self, str)
      if istable(str) then return str end

      local split = string.Explode(" ", str)
      if (#split <= 1) then return str end

      return split
    end,
    getEnclosedTableName = function(self)
      return self:encloseValue(self:unpackString(self.aliasTblName or self.tblName))
    end,
    encloseValue = function(self, str)
      if (type(str) == "string") then
        return "`" .. tostring(str) .. "`"
      elseif (type(str) == "table") then
        local output = ""
        for i, v in ipairs(str) do
          local upperStr = v:upper()
          local isKeyword = self.keywords[upperStr]

          if isKeyword then output = output .. " " .. tostring(v) .. " "
          else
            output = output .. "`" .. tostring(v) .. "`"
          end
        end

        return output
      elseif (type(str) == "boolean") then
        return str and 1 or 0
      end

      return str
    end,
    escape = function(self, str)
      if isbool(str) then
        str = str and 1 or 0
      end

      return self.conn.SQLStr(str)
    end,
    select = function(self, ...)
      self.type = self.operations.SELECT
      self.columns = {}

      for i, v in ipairs({
      ... }) do
        if istable(v) then
          if v.raw then
            table.insert(self.columns, v.raw)
          elseif v.mysql then
            local str = self:isMySQL() and "mysql" or "sqlite"

            table.insert(self.columns, v[str])
          end
        else
          local split = string.Explode(".", v)
          local enclosed = XeninUI:Map(split, function(x)
            return self:encloseValue(self:unpackString(x))
          end)

          table.insert(self.columns, string.Implode(".", enclosed))
        end
      end

      return self
    end,
    indent = function(self, num)
      if num == nil then num = 1
      end
      local output = ""
      for i = 1, num do
        output = output .. "  "
      end

      return output
    end,
    getColumns = function(self, indentAmt)
      if indentAmt == nil then indentAmt = 1
      end
      if (!self.columns or #self.columns == 0) then return "*"end

      local output = "\n" .. self:indent(indentAmt)
      output = output .. string.Implode(",\n" .. self:indent(indentAmt), self.columns)

      return output
    end,
    getJoins = function(self)
      if (!self.joins) then return ""end

      local output = "\n"
      local size = #self.joins
      for i, v in ipairs(self.joins) do
        local leftSplit = string.Explode(".", v.leftCol)
        local leftEnclosed = XeninUI:Map(leftSplit, function(x)
          return self:encloseValue(self:unpackString(x))
        end)
        local rightSplit = string.Explode(".", v.rightCol)
        local rightEnclosed = XeninUI:Map(rightSplit, function(x)
          return self:encloseValue(self:unpackString(x))
        end)

        output = output .. (tostring(v.joinType) .. " " .. self:encloseValue(self:unpackString(v.tbl)) .. " ON " .. string.Implode(".", leftEnclosed) .. " " .. tostring(v.operator) .. " " .. string.Implode(".", rightEnclosed) .. (i == size and "" or "\n"))
      end

      return output
    end,
    orderBy = function(self, str, order)
      self.orders = self.orders or {}

      table.insert(self.orders, {
        str = str,
        order = order
      })

      return self
    end,
    getOrders = function(self)
      if (!self.orders) then return ""end

      local output = "ORDER BY"
      local size = #self.orders
      for i, v in ipairs(self.orders) do
        local value = istable(v.str) and v.str.raw or self:encloseValue(v.str)
        output = output .. ("\n" .. self:indent(1) .. value .. (v.order and " " .. tostring(v.order) or "") .. (i == size and "" or ","))
      end

      return output
    end,
    join = function(self, tbl, leftCol, operator, rightCol, joinType)
      if joinType == nil then joinType = "INNER JOIN"
      end
      self.joins = self.joins or {}

      table.insert(self.joins, {
        joinType = joinType,
        tbl = tbl,
        leftCol = leftCol,
        operator = operator,
        rightCol = rightCol
      })

      return self
    end,
    leftJoin = function(self, tbl, leftCol, operator, rightCol)
      return self:join(tbl, leftCol, operator, rightCol, "LEFT JOIN")
    end,
    rightJoin = function(self, tbl, leftCol, operator, rightCol)
      return self:join(tbl, leftCol, operator, rightCol, "RIGHT JOIN")
    end,
    fullJoin = function(self, tbl, leftCol, operator, rightCol)
      return self:join(tbl, leftCol, operator, rightCol, "JOIN")
    end,
    getWheres = function(self)
      if (!self.wheres) then return ""end

      local output = "\nWHERE\n"
      local size = #self.wheres
      for i, v in ipairs(self.wheres) do
        local rightCol = v.rightCol
        if istable(rightCol) then
          if (!rightCol.raw) then
            rightCol = self:construct(rightCol)
          end

          rightCol = rightCol.raw
        else
          rightCol = self:escape(rightCol)
        end

        local leftCol = v.leftCol
        if istable(leftCol) then
          if leftCol.raw then
            leftCol = leftCol.value
          else
            leftCol = self:escape(leftCol.value)
          end
        else
          local split = string.Explode(".", leftCol)
          local columns = XeninUI:Map(split, function(x)
            return self:encloseValue(self:unpackString(x))
          end)
          leftCol = string.Implode(".", columns)
        end

        output = output .. (self:indent(1) .. leftCol .. " " .. tostring(v.operator) .. " " .. rightCol .. (i == size and "" or " AND") .. "\n")
      end

      return output
    end,
    where = function(self, leftCol, operator, rightCol)
      self.wheres = self.wheres or {}

      table.insert(self.wheres, {
        leftCol = leftCol,
        operator = operator,
        rightCol = rightCol
      })

      return self
    end,
    union = function(self, obj)
      self.unions = self.unions or {}

      table.insert(self.unions, obj)

      return self
    end,
    getUnions = function(self) end,
    groupBy = function(self, name)
      self._groupBy = name

      return self
    end,
    getGroupBy = function(self)
      if (!self._groupBy) then return ""end

      return "GROUP BY " .. self:encloseValue(self._groupBy) .. "\n"
    end,
    rawSQL = function(self, sql)
      self._rawSQL = sql

      return self
    end,
    limit = function(self, num)
      self.limitSet = num

      return self
    end,
    getLimit = function(self)
      if (!self.limitSet) then return ""end

      return "\nLIMIT " .. self.limitSet
    end,
    offset = function(self, num)
      self.offsetSet = num

      return self
    end,
    getOffset = function(self)
      if (!self.offsetSet) then return ""end

      return "\nOFFSET " .. self.offsetSet
    end,
    debugName = function(self, name)
      self.debugName = name

      return self
    end,
    run = function(self, debug)
      if debug == nil then debug = self.debugName or "No Debug Name"
      end
      local query = self:toRaw()
      if (XeninUI.Debug == "extended") then
        print(query)
      end

      return XeninUI:InvokeSQL(self.conn, query, isstring(debug) and debug or self.tblName .. ".operation:" .. (self.type or "RAW"), nil, nil, self.returnId, self.transaction)
    end,
    printSQL = function(self)
      local sql = self:toRaw()
      local lines = sql:Split("\n")
      local length = #lines
      for i, v in ipairs(lines) do
        if (v == "") then continue end

        print(v)
      end

      return self
    end,
    getOne = function(self)
      self:limit(1)
      local p = XeninUI.Promises.new()

      self:run():next(function(results)
        if (!istable(results)) then return p:resolve()end
        if (!results[1]) then return p:resolve()end

        p:resolve(results[1])
      end, function(err)
        p:reject(err)
      end)

      return p
    end,
    ignore = function(self)
      self._ignore = true

      return self
    end,
    insert = function(self, input, upsert, keys)
      if keys == nil then keys = {}
      end
      self.type = self.operations.INSERT
      self.isUpsert = upsert
      self.insertColumns = {}
      self.keysMap = {}
      for i, v in ipairs(keys) do
        self.keysMap[v] = true
      end


      local seq = table.IsSequential(input)
      if (!seq) then
        input = {
        input }
      end

      for insertId, insert in ipairs(input) do
        local temp = {}

        for i, v in pairs(insert) do
          if istable(v) then
            if (v.upsertDifference and upsert) then
              local tbl = v.data
              for i, v in pairs(tbl) do
                if v.raw then
                  tbl[i] = v.raw
                else
                  tbl[i] = self:escape(v)
                end
              end

              temp[i] = tbl
            elseif v.raw then
              temp[i] = v.raw
            elseif (v.mysql or v.sqlite) then
              local conn = self:isMySQL() and "mysql" or "sqlite"
              temp[i] = v[conn]
            elseif (v.left or v.right) then
              temp[i] = v.right
            else
              Error("Unable to insert " .. tostring(i) .. " - " .. tostring(v))
            end
          else
            temp[i] = self:escape(v)
          end
        end

        table.insert(self.insertColumns, temp)
      end


      return self
    end,
    upsert = function(self, input, keys)
      if self:isMySQL() then
        return self:insert(input, XeninUI.ORM.Builder.UPSERT, keys)
      else
        self:insert(input, true)
        self.replaceColumns = {}
        self.replaceKeys = {}

        local map = {}
        if (!keys) then
          ErrorNoHaltWithStack("[Xenin Framework - ORM] Trying to use QueryBuilder::upsert without specifying keys. This technically might work, but this WILL cause issues with SQLite")
        end

        for i, v in ipairs(keys or {}) do
          map[v] = true

          local split = string.Explode(".", v)
          local enclosed = XeninUI:Map(split, function(x)
            return self:encloseValue(self:unpackString(x))
          end)

          table.insert(self.replaceKeys, table.concat(enclosed, "."))
        end

        for i, v in pairs(input) do
          if (map[i]) then continue end

          if (istable(v) and v.raw) then
            if v.upsertDifference then
              local tbl = v.data
              for i, v in pairs(tbl) do
                if (!istable(v)) then
                  tbl[i] = v
                elseif v.update then
                  tbl[i] = v.update
                elseif v.raw then
                  tbl[i] = v.raw
                else
                  tbl[i] = self:escape(v)
                end
              end

              self.replaceColumns[i] = tbl
            else
              self.replaceColumns[i] = v.raw
            end
          else
            self.replaceColumns[i] = self:escape(v)
          end
        end

        return self
      end
    end,
    getOnConflict = function(self)
      if (!self.replaceColumns) then return ""end

      local output = ""

      local size = table.Count(self.replaceColumns) - 1

      if (size + 1 == 0) then
        return ""
      end
      local noLoops = 0
      for i, v in pairs(self.replaceColumns) do
        local isLast = noLoops == size
        local str = v
        if istable(v) then
          if v.update then
            str = v.update
          elseif v.raw then
            str = v.raw
          else
            local conn = self:isMySQL() and "mysql" or "sqlite"
            str = v[conn]
          end
        end
        output = output .. ("\n" .. self:indent(2) .. i .. " = " .. tostring(str) .. (isLast and "" or ", "))
        noLoops = noLoops + 1
      end

      local keys = table.concat(self.replaceKeys, ", ")

      return "\nON CONFLICT(" .. keys .. ") DO\n" .. self:indent(1) .. "UPDATE SET" .. output
    end,
    update = function(self, input)
      self.type = self.operations.UPDATE
      self.updateColumns = {}

      for i, v in pairs(input) do
        if istable(v) then
          self.updateColumns[i] = v.raw or v
        else
          self.updateColumns[i] = self:escape(v)
        end
      end

      return self
    end,
    delete = function(self)
      self.type = self.operations.DELETE

      return self
    end,
    toRaw = function(self)
      if self._rawSQL then
        return self._rawSQL
      end

      local ops = self.operations

      if (self.type == ops.SELECT) then
        return "SELECT " .. self:getColumns() .. "\nFROM " .. self:getEnclosedTableName() .. self:getJoins() .. self:getWheres() .. self:getGroupBy() .. self:getOrders() .. self:getLimit() .. self:getOffset()
      elseif (self.type == ops.INSERT) then
        return self:getInsert() .. self:getEnclosedTableName() .. " (" .. self:getInsertColumns() .. ")\n" .. "VALUES " .. self:getValues() .. self:getUpsert() .. self:getOnConflict()
      elseif (self.type == ops.UPDATE) then
        return "UPDATE " .. self:getEnclosedTableName() .. "\n" .. self:indent(1) .. "SET " .. self:getUpdateStatements() .. self:getWheres() .. self:getOffset() .. self:getLimit()
      elseif (self.type == ops.DELETE) then
        return "DELETE FROM " .. self:getEnclosedTableName() .. self:getWheres() .. self:getLimit()
      end
    end,
    getValues = function(self)
      if (!self.insertColumns or table.IsEmpty(self.insertColumns)) then return ""end
      if (!self.insertColumns[1]) then return ""end

      local output = ""

      local inserts = #self.insertColumns
      local size = table.Count(self.insertColumns[1]) - 1
      for insertId, insert in ipairs(self.insertColumns) do
        local noLoops = 0
        local insertStr = ""
        for i, v in pairs(insert) do
          local isLast = noLoops == size
          local isTable = istable(v)
          local str = v
          if istable(v) then
            if v.insert then
              str = v.insert
            elseif v.raw then
              str = v.raw
            else
              local conn = self:isMySQL() and "mysql" or "sqlite"
              str = v[conn]
            end
          end
          insertStr = insertStr .. (str .. (isLast and "" or ", "))
          noLoops = noLoops + 1
        end
        insertStr = "(" .. tostring(insertStr) .. ")"
        if (insertId != inserts) then insertStr = insertStr .. ", "
        end

        output = output .. insertStr
      end

      return output
    end,
    getInsert = function(self)
      local str = "INSERT"

      if self:isMySQL() then str = str .. " IGNORE INTO "
      else
        str = str .. " OR IGNORE INTO "
      end

      return str
    end,
    getInsertColumns = function(self)
      if (!self.insertColumns or table.IsEmpty(self.insertColumns)) then return ""end

      local tbl = self.insertColumns[1]
      if (!tbl) then return end

      local output = ""
      local size = table.Count(tbl) - 1
      local noLoops = 0
      for i, v in pairs(tbl) do
        local isLast = noLoops == size
        output = output .. (i .. (isLast and "" or ", "))
        noLoops = noLoops + 1
      end

      return output
    end,
    getUpdateStatements = function(self)
      if (!self.updateColumns or table.IsEmpty(self.updateColumns)) then return ""end

      local size = table.Count(self.updateColumns) - 1
      local output = {}
      for i, v in pairs(self.updateColumns) do
        local str = v
        if istable(v) then
          if v.update then
            str = v.update
          elseif v.raw then
            str = v.raw
          else
            local conn = self:isMySQL() and "mysql" or "sqlite"
            str = v[conn]
          end
        end
        table.insert(output, "\n" .. self:indent(2) .. i .. " = " .. tostring(str))
      end

      return table.concat(output, ", ")
    end,
    isMySQL = function(self)
      return self.conn.isMySQL()
    end,
    getUpsert = function(self)
      if (!self.isUpsert) then return ""end
      if (!self:isMySQL()) then return ""end

      local maps = self.keysMap

      if (table.Count(maps) == table.Count(self.insertColumns[1])) then
        maps = {}
      end
      local output = {}
      for i, v in pairs(self.insertColumns[1]) do
        if (maps[i]) then continue end

        local str = v
        if istable(v) then
          if v.update then
            str = v.update
          elseif v.raw then
            str = v.raw
          else
            local conn = self:isMySQL() and "mysql" or "sqlite"
            str = v[conn]
          end
        end
        table.insert(output, "\n" .. self:indent(2) .. i .. " = " .. tostring(str))
      end

      return "\nON DUPLICATE KEY\n" .. self:indent(1) .. "UPDATE" .. table.concat(output, ", ")
    end,
    __type = function(self)
      return "XeninUI.ORM.Builder"end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self, tblName, conn, returnId, transaction)
      if conn == nil then conn = XeninDB
      end
      self.keywords = {
      AS = 1
      }
      self.operations = {
        SELECT = 1,
        INSERT = 2,
        UPDATE = 3,
        DELETE = 4
      }
      XeninUI.ORM.Builder.__parent.__init(self)

      self.tblName = tblName
      self.returnId = returnId
      self.transaction = transaction
      local split = string.Explode(" ", tblName)
      self.aliasTblName = split
      self.conn = conn
    end,
    __base = _base_0,
    __parent = _parent_0
  }, {
    __index = function(cls, parent)
      local val = rawget(_base_0, parent)
      if val == nil then local _parent = rawget(cls, "__parent")
        if _parent then return _parent[parent]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  if _parent_0.__inherited then _parent_0.__inherited(_parent_0, _class_0)
  end
  XeninUI.ORM.Builder = _class_0
end
