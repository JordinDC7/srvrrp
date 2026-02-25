do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Units.Spec",
    getName = function(self)
      return self.name end,
    getFunc = function(self)
      return self.func end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name, func)
      self.name = name
      self.func = func
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
  XeninUI.Units.Spec = _class_0
end
