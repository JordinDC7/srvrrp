local NetworkClient
do
  local _class_0
  local _parent_0 = XeninUI.Network
  local _base_0 = {
    __name = "NetworkClient",
    __base = XeninUI.Network.__base,
    receiveNotification = function(self, ply)
      local noti = XeninUI.Players.NetworkHelper.receiveNotification()

      local str = noti.content:Split("\n")[1]
      local len = math.max(4, #str * 0.065)
      XeninUI:Notify(str, NOTIFY_HINT, len)
    end,
    receiveNotifications = function(self, ply)
      local amt = net.ReadUInt(8)
      local tbl = {}
      for i = 1, amt do
        table.insert(tbl, XeninUI.Players.NetworkHelper.receiveNotification())
      end

      hook.Run("XeninUI.Players.GotNotifications", tbl)
    end,
    sendReceiveNotifications = function(self)
      self:send("notifications", function(self) end)
    end,
    sendReadNotifications = function(self, ids)
      self:send("readNotifications", function(self)
        net.WriteUInt(#ids, 8)
        for i = 1, #ids do
          net.WriteUInt(ids[i], 32)
        end
      end)
    end,
    receiveReadNotifications = function(self, ply) end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self, ...)
      NetworkClient.__parent.__init(self, ...)

      self:setPrefix("Xenin.Players.")

      self:receiver("notification", self.receiveNotification)
      self:receiver("notifications", self.receiveNotifications)
      self:receiver("readNotifications", self.receiveReadNotifications)
    end,
    __base = _base_0,
    __parent = _parent_0
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
  NetworkClient = _class_0
end

XeninUI.Players.Network = NetworkClient()
