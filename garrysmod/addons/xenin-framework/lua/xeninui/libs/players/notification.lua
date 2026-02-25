local function __laux_concat_0(...)
  local arr = {
  ...
  }
  local result = {}
  for _, obj in ipairs(arr) do
    for i = 1, #obj do
      result[#result + 1] = obj[i]
    end
    for k, v in pairs(obj) do
      if type(k) == "number" and k > #obj then result[k] = v
      elseif type(k) ~= "number" then
        result[k] = v
      end
    end
  end
  return result
end
local Types
do
  local _class_0
  local _base_0 = {
    __name = "Types",
    _getId = function(self, scriptId, typeId)
      return scriptId .. "_" .. typeId
    end,
    set = function(self, scriptId, typeId, data)
      self.cache[self:_getId(scriptId, typeId)] = data
    end,
    get = function(self, scriptId, typeId)
      return self.cache[self:_getId(scriptId, typeId)]
    end,
    getAll = function(self)
      return self.cache
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
  Types = _class_0
end
local Builder
do
  local _class_0
  local _base_0 = {
    __name = "Builder",
    setSteamID64 = function(self, sid64)
      self.sid64 = sid64

      return self
    end,
    setPlayer = function(self, ply)
      self:setSteamID64(ply:SteamID64())

      return self
    end,
    setScript = function(self, scriptId)
      self.scriptId = scriptId

      return self
    end,
    setType = function(self, typeId)
      self.type = typeId

      return self
    end,
    setContent = function(self, content)
      self.content = content

      return self
    end,
    setData = function(self, data)
      self.data = data

      return self
    end,
    send = function(self)
      self.parent:addNotification(__laux_concat_0(self))

      return self
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, parent)
      self.parent = parent
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
  Builder = _class_0
end
do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Notification",
    builder = function(self)
      return Builder(self)
    end,
    addType = function(self, scriptId, id, data)
      if data == nil then data = {}
      end
      self.types:set(scriptId, id, data)
    end,
    getType = function(self, scriptId, id)
      return self.types:get(scriptId, id)
    end,
    addNotification = function(self, notification)
      if SERVER then
        local db = XeninUI.Players.Database
        db:insertNotification(notification.sid64, notification.scriptId, notification.type, notification.content, notification.data)

        local ply = player.GetBySteamID64(notification.sid64)
        XeninUI.Players.Network:sendNotification(ply, notification)
      else
        error("missing impl")
      end
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.types = Types()
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
  XeninUI.Notification = _class_0()
end
