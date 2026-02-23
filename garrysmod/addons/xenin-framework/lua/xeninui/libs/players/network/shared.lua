do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Players.NetworkHelper",
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self) end,
    __base = _base_0,
    sendNotification = function(notification)
      assert(notification ~= nil, "cannot destructure nil value")
      local scriptId, type, content, createdAt, readAt, data, id = notification.scriptId, notification.type, notification.content, notification.createdAt, notification.readAt, notification.data, notification.id

      net.WriteString(scriptId)
      net.WriteString(type)
      net.WriteString(content)
      net.WriteString(createdAt)
      net.WriteBool(istable(data))
      if istable(data) then
        net.WriteTable(data)
      end
      net.WriteBool(readAt != nil)
      if readAt then
        net.WriteString(readAt)
      end
      net.WriteBool(id != nil)
      if id then
        net.WriteUInt(id, 32)
      end
    end,
    receiveNotification = function()
      local notification = {
        scriptId = net.ReadString(),
        type = net.ReadString(),
        content = net.ReadString(),
        createdAt = net.ReadString()
      }
      local hasData = net.ReadBool()
      if hasData then
        notification.data = net.ReadTable()
      end
      local hasRead = net.ReadBool()
      if hasRead then
        notification.readAt = net.ReadString()
      end
      local hasId = net.ReadBool()
      if hasId then
        notification.id = net.ReadUInt(32)
      end

      return notification
    end
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  XeninUI.Players.NetworkHelper = _class_0
end
