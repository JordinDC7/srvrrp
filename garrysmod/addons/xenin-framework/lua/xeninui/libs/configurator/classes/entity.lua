local function __laux_concat_0(...)
  local arr = {
  ...
  }
  local result = {}
  for _, obj in ipairs(arr) do
    for i = 1, #obj do
      result[#result + 1] = obj[i]
    end
    for k, v in pairs(obj) do
      if type(k) == "number" and k > #obj then result[k] = v
      elseif type(k) ~= "number" then
        result[k] = v
      end
    end
  end
  return result
end
do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Configurator.Entity",
    setDatabaseEntity = function(self, databaseEntity)
      self.databaseEntity = databaseEntity
      return self
    end,
    getDatabaseEntity = function(self)
      return self.databaseEntity
    end,
    getColumns = function(self)
      return self.columns
    end,
    getColumn = function(self, id)
      for i, v in ipairs(self.columns) do
        if (v.id != id) then continue end

        return v, i
      end
    end,
    addColumn = function(self, id, data)
      table.insert(self.columns, __laux_concat_0({
      id = id
      }, data))

      local name = id:sub(1, 1):upper() .. id:sub(2)
      self["set" .. tostring(name)] = function(self, val, deserialize)
        if deserialize then
          if (data.csv and isstring(val)) then
            val = string.Explode(",", val)
          elseif (isstring(val) and (data.type == "list" or data.json)) then
            val = util.JSONToTable(val)
          end
        end

        self[id] = val

        return self
      end
      self["set" .. tostring(id)] = function(self, ...)
        self["set" .. tostring(name)](self, ...)end
      self["get" .. tostring(name)] = function(self, serialize)
        if serialize then
          if (data.csv and istable(self[id])) then
            return table.concat(self[id], ",")
          elseif istable(self[id]) then
            return util.TableToJSON(self[id])
          end
        end

        return self[id]
      end
      self["get" .. tostring(id)] = function(self, ...)
        return self["get" .. tostring(name)](self, ...)end
    end,
    getSQLTableName = function(self)
      local str = self:getDatabaseEntity():lower()
      str = str:Replace(".", "_")

      return "xenin_configurator_entity_" .. str
    end,
    createSQLTable = function(self)
      local tableName = self:getSQLTableName()
      XeninUI.ORM.Table(XeninDB, tableName, function(tbl)
        for i, v in ipairs(self:getColumns()) do
          assert(v ~= nil, "cannot destructure nil value")
          local type, length, primary, null, default = v.type, v.length, v.primary, v.null, v.default
          local dataType = type == "list" and "text" or type
          local col = tbl[dataType](tbl, v.id)
          if primary then col:primary()end
          if length then col:length(length)end
          if null then col:nullable()end
          if default then
            local notExpressions = {
              integer = true,
              string = true
            }

            local isExpression = !notExpressions[type]
            col:default(default, isExpression)
          end
        end
      end, function()
        self:seed()
      end)
    end,
    seedData = function(self) end,
    seed = function(self)
      local data = self:seedData()
      if (!data) then return end
      local name = self:getSQLTableName()

      for i, v in ipairs(data) do
        XeninUI.Configurator.ORM:seed(name, v.version, v.code())
      end
    end,
    onNetworkSend = function(self)

      local cols = self:getColumns()
      local size = #cols
      local tbl = {}
      for i, v in ipairs(cols) do
        assert(v ~= nil, "cannot destructure nil value")
        local id = v.id
        local val = self["get" .. tostring(id)](self, true)
        if (!val) then continue end
        if (isstring(val) and val == "") then continue end

        tbl[id] = val
      end

      local size = table.Count(tbl)
      net.WriteUInt(size, 12)
      for i, v in pairs(tbl) do
        net.WriteString(i)
        XeninUI.Configurator.Network:write(v)
      end
    end,
    onNetworkReceive = function(self)
      local cols = self:getColumns()
      local size = net.ReadUInt(12)
      for i = 1, size do
        local id = net.ReadString()
        local val = XeninUI.Configurator.Network:read()

        self["set" .. tostring(id)](self, val, true)
      end
    end,
    onSave = function(self) end,
    onDelete = function(self) end,
    onLoad = function(self) end,
    validateColumn = function(self, id, input)
      local col = self:getColumn(id)
      if (!col) then return end

      if (!col.validate) then return true, "No validation"end

      return col.validate(input)
    end,
    shouldAllowNetwork = function(self, ply)
      return true end,
    save = function(self, admin)
      self:onSave()

      if (!admin) then return end

      if CLIENT then
        XeninUI.Configurator.Network:sendSaveEntity(self)

        return
      end

      XeninUI.Configurator.ORM:saveEntity(self)

      self:network()
    end,
    network = function(self, target)
      if (!target) then
        target = {}
        for i, v in ipairs(player.GetAll()) do
          if (!self:shouldAllowNetwork(v)) then continue end

          table.insert(target, v)
        end

        if (table.IsEmpty(target)) then return end
      end

      XeninUI.Configurator.Network:sendEntity(target, self)
    end,
    createNewEntity = function(self)
      if CLIENT then
        XeninUI.Configurator.Network:sendCreateEntity(self)

        return
      end

      XeninUI.Configurator.ORM:createEntity(self)
    end,
    delete = function(self, admin)
      self:onDelete()

      if (!admin) then return end

      if CLIENT then
        XeninUI.Configurator.Network:sendDeleteEntity(self)

        return
      end

      XeninUI.Configurator.ORM:deleteEntity(self)
    end,
    isDatabaseEntity = function(self)
      return true end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.columns = {}
    end,
    __base = _base_0,
    register = function(name, entity)
      local __laux_type = (istable(entity) and entity.__type and entity:__type()) or type(entity)
      assert(__laux_type == "XeninUI.Configurator.Entity", "Expected parameter `entity` to be type `XeninUI.Configurator.Entity` instead of `" .. __laux_type .. "`")
      XeninUI.Configurator.Entities:register(name, entity)
    end
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  XeninUI.Configurator.Entity = _class_0
end
