do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Units.Result",
    setError = function(self, err)
      self.returnVal = err end,
    setSuccess = function(self, bool)
      self.success = bool end,
    getReturn = function(self)
      return self.returnVal end,
    isSuccess = function(self)
      return self.success end,
    getMessagePrint = function(self)
      local prefix = self.success and "+" or "-"
      local color = self.success and XeninUI.Theme.Green or XeninUI.Theme.Red
      local str = tostring(prefix) .. " " .. tostring(self.name)
      if (!self.success) then str = str .. " ** FAILED **"
        if isstring(self.returnVal) then

          local errMsg = self.returnVal:Split("stack traceback")
          errMsg = errMsg[1]:sub(1, #errMsg[1] - 1)
          str = str .. "\nError was: " .. tostring(errMsg)
        end
      end

      return {
        color,
        str
      }
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name, success, returnVal)
      self.isResult = true

      self.name = name
      self.success = success
      self.returnVal = returnVal
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
  XeninUI.Units.Result = _class_0
end
