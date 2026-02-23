do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.ORM.Column",
    type = function(self, type)
      local isMySQL = self.isMySQL

      if (type == "int" and !isMySQL) then
        return "integer"
      end

      return type
    end,
    default = function(self, num, surround)
      self._default = {
        surround = surround,
        value = isbool(num) and tonumber(num) or num
      }

      return self
    end,
    decimals = function(self, num)
      self._decimals = num

      return self
    end,
    length = function(self, num)
      self._length = num

      return self
    end,
    primary = function(self)
      self._primary = true

      return self
    end,
    nullable = function(self)
      self._nullable = true

      return self
    end,
    increments = function(self)
      self._increments = true

      return self
    end,
    unsigned = function(self)
      self._unsigned = true

      return self
    end,
    onUpdate = function(self, str)
      self._onUpdate = str

      return self
    end,
    incrementOnUpdate = function(self, amt)
      if amt == nil then amt = 1
      end
      self:onUpdate(self._name .. " + " .. amt)
    end,
    buildString = function(self)
      local isMySQL = self.isMySQL
      local type = self._type:upper()
      local unsigned = self._unsigned and "UNSIGNED"
      local str = "`" .. tostring(self._name) .. "` "
      if (unsigned and !isMySQL) then str = str .. tostring(unsigned) .. " "
      end
      str = str .. type

      if self._length then
        local decimals = self._decimals and ", " .. tostring(self._decimals) or ""
        str = str .. "(" .. tostring(self._length) .. tostring(decimals) .. ")"
      end
      if (unsigned and isMySQL) then str = str .. " " .. tostring(unsigned)
      end
      if self._primary then str = str .. " PRIMARY KEY"
      end
      if self._increments then str = str .. (self.isMySQL and " AUTO_INCREMENT" or " AUTOINCREMENT")
      end
      if (!self._nullable) then str = str .. " NOT NULL"
      end
      if self._default then local __lauxi0 = self._default
        assert(__lauxi0 ~= nil, "cannot destructure nil value")
        local value, surround = __lauxi0.value, __lauxi0.surround
        if (value == "NULL" and (type == "TIMESTAMP" or type == "DATETIME")) then str = str .. (" " .. (surround and "(" or "") .. value .. (surround and "(" or ""))
        else
          str = str .. (" DEFAULT " .. (surround and "(" or "") .. value .. (surround and ")" or ""))
        end
      end
      if self._onUpdate then str = str .. ("\n  ON UPDATE " .. self._onUpdate)
      end

      return str
    end,
    __type = function(self)
      return "XeninUI.ORM.Column"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name, type, isMySQL)
      if isMySQL == nil then isMySQL = false
      end
      self.isMySQL = isMySQL
      self._name = name
      self._type = self:type(type)
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
  XeninUI.ORM.Column = _class_0
end
