local ORM
do
  local _class_0
  local _parent_0 = XeninUI.ORM.ORM
  local _base_0 = {
    __name = "ORM",
    __base = XeninUI.ORM.ORM.__base,
    getScriptSettings = function(self, script)
      return self:orm("xenin_configurator_settings"):select("id", "value", "json"):where("script_id", "=", script):run()
    end,
    saveSetting = function(self, script, id, val)
      local isJSON
      local entity
      if istable(val) then
        isJSON = true
        val = util.TableToJSON(val)
      end

      return self:orm("xenin_configurator_settings"):upsert({
        id = id,
        script_id = script,
        value = val,
        json = isJSON or self.b.NULL
      }, {
        "id",
        "script_id"
      }):run()
    end,
    getSetting = function(self, script, id)
      return self:orm("xenin_configurator_settings"):select():where("script_id", "=", script):where("id", "=", id):run()
    end,
    saveEntity = function(self, entity)
      local tableName = entity:getSQLTableName()
      local columns = entity:getColumns()
      local upsertTbl = {}
      for i, v in ipairs(columns) do
        local name = string.Trim(v.id:sub(1, 1):upper() .. v.id:sub(2))
        local val = entity["get" .. tostring(name)](entity, true)
        if (val == nil) then
          val = self.b.NULL
        end
        if v.onSave then
          val = v:onSave(val)
        end

        upsertTbl[v.id] = val
      end

      return self:orm(tableName):upsert(upsertTbl, {
      "id" }):run()
    end,
    createEntity = function(self, entity)
      local tableName = entity:getSQLTableName()
      local columns = entity:getColumns()
      local tbl = {}
      for i, v in ipairs(columns) do
        if (v.type == "increments") then continue end

        local val = entity["get" .. tostring(v.id)](entity, true)
        if (val == nil or val == "NULL") then
          val = isfunction(v.defaultValue) and v:defaultValue() or v.defaultValue
        end
        if (val == nil or val == "NULL") then
          val = self.b.NULL
        end

        tbl[v.id] = val
      end

      return self:orm(tableName, true):insert(tbl):run()
    end,
    deleteEntity = function(self, entity)
      local tableName = entity:getSQLTableName()
      local columns = entity:getColumns()
      local whereTbl = {}
      for i, v in ipairs(columns) do
        if (!v.primary) then continue end

        local name = string.Trim(v.id:sub(1, 1):upper() .. v.id:sub(2))
        whereTbl[v.id] = entity["get" .. tostring(name)](entity, true)
      end

      local b = self:orm(tableName):delete()
      for i, v in pairs(whereTbl) do
        b:where(i, "=", v)
      end

      return b:run()
    end,
    findEntities = function(self, entity, params)
      if params == nil then params = {}
      end
      local tableName = entity:getSQLTableName()
      local b = self:orm(tableName):select()

      for i, v in pairs(params) do
        b:where(i, "LIKE ", "%" .. tostring(v) .. "%")
      end

      return b:run()
    end,
    seed = function(self, name, version, code)
      local sqlStr = istable(code) and code.sql or code

      return self:orm("xenin_framework_seeds"):select("version"):where("id", "=", name):getOne():next(function(result)
        if result then
          return XeninUI.Promises.new():resolve()
        end

        return XeninUI:InvokeSQL(XeninDB, sqlStr, "XeninUI.Seeding." .. name):next(function()
          if istable(code) then
            code.postSeed()
          end

          return self:orm("xenin_framework_seeds"):insert({
            id = name,
            version = version
          }):run()
        end, function(err)
          Error("Failed to create " .. name .. " seed")
        end)
      end, function(err)
        Error("Failed to create " .. name .. " seed")
      end)
    end,
    __type = function(self)
      return "XeninUI.Configurator.ORM"end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self)
      ORM.__parent.__init(self, "xeninui/libs/configurator/migrations/")
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
  ORM = _class_0
end

hook.Add("Xenin.ConfigLoaded", "XeninUI.Configurator", function()
  XeninUI.Configurator:PrintMessage("Initialising database instance")
  XeninUI.Configurator.ORM = ORM()

  timer.Simple(3, function()
    XeninUI.Configurator.ORM.LoadedInsideHook = true
    XeninUI.Configurator:PrintMessage("Initialised database instance successfully")

    hook.Run("Xenin.Configurator.InitialisedDatabase")
  end)
end)

XeninUI.Configurator.ORM = ORM()
