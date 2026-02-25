local Driver
do
  local _class_0
  local _base_0 = {
    __name = "Driver",
    __type = function(self)
      return "XeninUI.ORM.Driver"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self) end,
    __base = _base_0,
    NAME = "name",
    UNSIGNED = "unsigned",
    TYPE = "type",
    LENGTH = "length",
    PRIMARY = "primary",
    FOREIGN = "foreign",
    INCREMENTS = "increments",
    NULLABLE = "nullable",
    ONUPDATE = "onUpdate",
    autoIncrement = function()
      return " AUTO_INCREMENT"
    end
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  Driver = _class_0
end

XeninUI.ORM.Driver = Driver
