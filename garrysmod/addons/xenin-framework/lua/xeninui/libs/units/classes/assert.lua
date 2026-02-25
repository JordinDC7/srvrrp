do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Units.Assert",
    isType = function(self, name, errMsg)
      local valType = type(self.val)
      assert(valType == name, errMsg or "Expected \"" .. tostring(self.val) .. "\"\" type to be \"" .. tostring(name) .. "\", but it is type \"" .. tostring(valType) .. "\"")

      return self
    end,
    isTrue = function(self, errMsg)
      self:isType("boolean")
      assert(self.val == true, errMsg or "Boolean is not true")

      return self
    end,
    isFalse = function(self, errMsg)
      self:isType("boolean")
      assert(!self.val, errMsg or "Boolean is not false")

      return self
    end,
    isNil = function(self, errMsg)
      assert(self.val == nil, errMsg or "Excepted nil, got \"" .. tostring(self.val) .. "\" of type \"" .. tostring(type(self.val)) .. "\"")

      return self
    end,
    isNotNil = function(self, errMsg)
      assert(self.val != nil, errMsg or "Expected not nil, but got nil")

      return self
    end,
    isNull = function(self, errMsg)
      assert(self.val == NULL, errMsg or "Expected NULL, but got \"" .. tostring(type(self.val)) .. "\"")

      return self
    end,
    isNotNull = function(self, errMsg)
      assert(self.val != NULL, errMsg or "Expected not NULL, but got NULL\"")

      return self
    end,
    isPlayer = function(self)
      assert(IsValid(self.val), "Player entity is not valid")
      assert(self.val:IsPlayer(), "This entity is not a player")

      return self
    end,
    shouldEqual = function(self, compare, errMsg)
      assert(self.val == compare, errMsg or "Expected \"" .. tostring(self.val) .. "\" of type \"" .. tostring(type(self.val)) .. "\" to equal \"" .. tostring(compare) .. "\" of type \"" .. tostring(type(compare)) .. "\", it does not")

      return self
    end,
    shouldNotEqual = function(self, compare, errMsg)
      assert(self.val != compare, errMsg or "Expected \"" .. tostring(self.val) .. "\" of type \"" .. tostring(type(self.val)) .. "\" to not equal \"" .. tostring(compare) .. "\" of type \"" .. tostring(type(compare)) .. "\", it does")

      return self
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, val, args)
      self.val = val
      self.args = args
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
  XeninUI.Units.Assert = _class_0
end
