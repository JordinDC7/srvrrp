do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Configurator.Cache",
    get = function(self, id)
      return self.cache[id]
    end,
    set = function(self, id, val)
      self.cache[id] = val
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.cache = {}
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
  XeninUI.Configurator.Cache = _class_0
end
