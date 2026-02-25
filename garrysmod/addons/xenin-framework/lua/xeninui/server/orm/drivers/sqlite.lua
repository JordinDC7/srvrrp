local Driver = XeninUI.ORM.Driver

local SQLite
do
  local _class_0
  local _parent_0 = Driver
  local _base_0 = {
    __name = "SQLite",
    __base = Driver.__base,
    __type = function(self)
      return "XeninUI.ORM.SQLite"end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self) end,
    __base = _base_0,
    __parent = _parent_0,
    queryOrder = {
      Driver.NAME,
      Driver.UNSIGNED,
      Driver.TYPE,
      Driver.LENGTH,
      Driver.PRIMARY,
      Driver.FOREIGN,
      Driver.INCREMENTS,
      Driver.NULLABLE,
      Driver.ONUPDATE
    },
    type = function(type)
      if (type == "int") then
        return "integer"
      end

      return type
    end,
    autoIncrement = function()
      return " AUTOINCREMENT"
    end
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
  SQLite = _class_0
end

XeninUI.ORM.SQLite = SQLite
