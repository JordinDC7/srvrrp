local Driver = XeninUI.ORM.Driver

local MySQL
do
  local _class_0
  local _parent_0 = Driver
  local _base_0 = {
    __name = "MySQL",
    __base = Driver.__base,
    __type = function(self)
      return "XeninUI.ORM.MySQL"end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self) end,
    __base = _base_0,
    __parent = _parent_0,
    queryOrder = {
      Driver.NAME,
      Driver.TYPE,
      Driver.LENGTH,
      Driver.UNSIGNED,
      Driver.PRIMARY,
      Driver.FOREIGN,
      Driver.INCREMENTS,
      Driver.NULLABLE,
      Driver.ONUPDATE
    }
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
  MySQL = _class_0
end

XeninUI.ORM.MySQL = MySQL
