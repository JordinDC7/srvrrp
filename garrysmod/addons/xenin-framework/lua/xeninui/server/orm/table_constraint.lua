do
  local _class_0
  local _base_0 = {
    __name = "ForeignKey",
    references = function(self, name)
      self._references = name

      return self
    end,
    columns = function(self, ...)
      self.targetColumns = {
      ... }

      return self
    end,
    cascade = function(self)
      self._cascade = true

      return self
    end,
    setNull = function(self)
      self._setNull = true

      return self
    end,
    buildSQL = function(self)
      local tableKeys = table.concat(self.tableColumns, ", ")
      local targetKeys = table.concat(self.targetColumns, ", ")
      local target = self._references

      local str = "FOREIGN KEY (" .. tostring(tableKeys) .. ") REFERENCES " .. tostring(target) .. "(" .. tostring(targetKeys) .. ")"
      if self._cascade then str = str .. "\n          ON DELETE CASCADE"
      elseif self._setNull then
        str = str .. "\n          ON DELETE SET NULL"
      end

      return str
    end,
    build = function(self)
      self.parent:build()
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, parent, ...)
      self.parent = parent
      self.tableColumns = {
      ... }
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
  ForeignKey = _class_0
end
do
  local _class_0
  local _base_0 = {
    __name = "Unique",
    buildSQL = function(self)
      local keys = table.concat(self.columns, ", ")

      return "UNIQUE (" .. tostring(keys) .. ")"
    end,
    build = function(self)
      self.parent:build()
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, parent, ...)
      self.parent = parent
      self.columns = {
      ... }
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
  Unique = _class_0
end
do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.ORM.Constraint",
    primary = function(self, ...)
      self._primary = {
      ... }
    end,
    foreign = function(self, ...)
      self._foreign = ForeignKey(self, ...)

      return self._foreign
    end,
    unique = function(self, ...)
      self._unique = Unique(self, ...)

      return self._unique
    end,
    buildSQL = function(self)
      local str = ""

      if self._primary then
        local keys = table.concat(self._primary, ", ")
        str = "PRIMARY KEY (" .. tostring(keys) .. ")"
      elseif self._foreign then
        str = self._foreign:buildSQL()
      elseif self._unique then
        str = self._unique:buildSQL()
      end

      return str
    end,
    build = function(self)
      return self:buildSQL()
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name, isMySQL)
      if isMySQL == nil then isMySQL = false
      end
      self.isMySQL = isMySQL
      self.name = name
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
  XeninUI.ORM.Constraint = _class_0
end
