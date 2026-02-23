local Controller
do
  local _class_0
  local _base_0 = {
    __name = "Controller",
    onPlayerInitialSpawn = function(self, ply)
      local db = XeninUI.Players.Database
      db:begin()
      self:playTimeJoin(ply)
      db:commit():next(function()
        if (!IsValid(ply)) then return end

        hook.Run("Xenin.PlayerInitialSpawn", ply)
      end)
    end,
    onPlayerDisconnect = function(self, ply)
      self:playTimeDisconnect(ply)
    end,
    playTimeJoin = function(self, ply)
      local sid64 = ply:SteamID64()
      local db = XeninUI.Players.Database
      db:insertPlayer(sid64)
      db:deleteInactivePlayerJoins(sid64)
      db:insertPlayerJoin(sid64)
      db:getPlayerPlayTime(sid64):next(function(result)
        if (!IsValid(ply)) then return end

        ply.xeninPlaytime = result
      end)
    end,
    getAmountOfUnreadNotifications = function(self, ply)
      return XeninUI.Players.Database:getAmountOfUnreadNotifications(ply:SteamID64())
    end,
    getNotifications = function(self, ply)
      return XeninUI.Players.Database:getNotifications(ply:SteamID64())
    end,
    addNotificationSid64 = function(self, sid64, notification)
      assert(notification ~= nil, "cannot destructure nil value")
      local scriptId, type, content, data = notification.scriptId, notification.type, notification.content, notification.data
      local db = XeninUI.Players.Database

      return db:insertNotification(sid64, scriptId, type, content, data):next(function(id)
        return db:getNotification(id)
      end)
    end,
    markNotificationsRead = function(self, sid64, ids)
      local db = XeninUI.Players.Database
      db:begin()
      for i, v in ipairs(ids) do
        db:markNotificationRead(sid64, v)
      end
      return db:commit()
    end,
    addNotification = function(self, ply, notification)
      return self:addNotificationSid64(ply:SteamID64(), notification):next(function(result)
        return result
      end)
    end,
    playTimeDisconnect = function(self, ply)
      XeninUI.Players.Database:insertPlayerLeave(ply:SteamID64())
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self) end,
    __base = _base_0
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  Controller = _class_0
end

XeninUI.Players.Controller = Controller()

if SERVER then
  hook.Add("PlayerInitialSpawn", "XeninUI.Players", function(ply)
    XeninUI.Players.Controller:onPlayerInitialSpawn(ply)
  end)

  hook.Add("PlayerDisconnected", "XeninUI.Players", function(ply)
    XeninUI.Players.Controller:onPlayerDisconnect(ply)
  end)
end
