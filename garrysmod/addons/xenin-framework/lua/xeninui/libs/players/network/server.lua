local NetworkServer
do
  local _class_0
  local _parent_0 = XeninUI.Network
  local _base_0 = {
    __name = "NetworkServer",
    __base = XeninUI.Network.__base,
    receiveNotifications = function(self, ply)
      XeninUI.Players.Controller:getNotifications(ply):next(function(notifications)
        self:send("notifications", ply, function(self)
          local amt = #notifications
          net.WriteUInt(amt, 8)
          for i = 1, amt do
            XeninUI.Players.NetworkHelper.sendNotification(notifications[i])
          end
        end)
      end)
    end,
    receiveReadNotifications = function(self, ply)
      local sid64 = ply:SteamID64()
      local amt = net.ReadUInt(8)
      local ids = {}
      for i = 1, amt do
        ids[#ids + 1] = net.ReadUInt(32)
      end

      XeninUI.Players.Controller:markNotificationsRead(sid64, ids):next(function()
        self:send("readNotifications", ply, function(self)
          net.WriteBool(true)
        end)
      end, function(err)
        self:send("readNotifications", ply, function(self)
          net.WriteBool(false)
        end)
      end)
    end,
    sendNotification = function(self, ply, notification)
      self:send("notification", ply, function(self)
        XeninUI.Players.NetworkHelper.sendNotification(notification)
      end)
    end,
    sendNotifications = function(self, ply, notifications)
      self:send("notifications", ply, function(self)
        local amt = #notifications
        net.WriteUInt(amt, 8)
        for i = 1, amt do
          XeninUI.Players.NetworkHelper.sendNotification(notifications[i])
        end
      end)
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self, ...)
      NetworkServer.__parent.__init(self, ...)

      self:setPrefix("Xenin.Players.")

      self:prepare({
        "notification",
        "notifications",
        "readNotifications"
      })

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
  NetworkServer = _class_0
end

XeninUI.Players.Network = NetworkServer()
