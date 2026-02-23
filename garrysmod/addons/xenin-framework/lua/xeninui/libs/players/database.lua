local ORM
do
  local _class_0
  local _parent_0 = XeninUI.ORM.ORM
  local _base_0 = {
    __name = "ORM",
    __base = XeninUI.ORM.ORM.__base,
    insertPlayer = function(self, sid64)
      return self:orm("xenin_framework_players"):insert({
        id = sid64,
        created_at = self.b.raw("CURRENT_TIMESTAMP")
      }):ignore():run()
    end,
    insertPlayerJoin = function(self, sid64)
      return self:orm("xenin_framework_players_history"):insert({
        player_id = sid64,
        joined_at = self.b.raw("CURRENT_TIMESTAMP")
      }):ignore():run()
    end,
    insertPlayerLeave = function(self, sid64)
      return self:orm("xenin_framework_players_history"):update({
      left_at = self.b.raw("CURRENT_TIMESTAMP")
      }):where("player_id", "=", sid64):where("left_at", "", self.b.isNull()):run()
    end,
    deleteInactivePlayerJoins = function(self, sid64)
      return self:orm("xenin_framework_players_history"):delete():where("player_id", "=", sid64):where("left_at", "", self.b.isNull()):run()
    end,
    getPlayerPlayTime = function(self, sid64)
      local mySQL = self:isMySQL()
      local str = [[
      SELECT
        (
            SELECT IFNULL(SUM(:playTime:), 0)
            FROM xenin_framework_players_history
            WHERE left_at IS NOT NULL
              AND player_id = ':steamid64:'
        ) AS playTime,
        (
            SELECT IFNULL(SUM(:currentPlayTime:), 0)
            FROM xenin_framework_players_history
            WHERE left_at IS NULL
              AND player_id = ':steamid64:'
        ) AS currentPlayTime
    ]]
      str = str:Replace(":steamid64:", sid64)
      str = str:Replace(":playTime:", mySQL and "TIMEDIFF(left_at, joined_at)" or "strftime('%s', left_at) - strftime('%s', joined_at)")
      str = str:Replace(":currentPlayTime:", mySQL and "TIMEDIFF(CURRENT_TIMESTAMP, joined_at)" or "strftime('%s', CURRENT_TIMESTAMP) - strftime('%s', joined_at)")

      return self:rawQuery(str):next(function(results)
        if (!results) then return {}end
        if (!results[1]) then return {}end

        return results[1]
      end)
    end,
    insertNotification = function(self, sid64, scriptId, type, content, data)
      return self:orm("xenin_framework_notifications", true):insert({
        target_id = sid64,
        script_id = scriptId,
        type = type,
        content = content,
        data = data and util.TableToJSON(data)
      }):run():next(function(results)

        return results[2]
      end)
    end,
    markNotificationRead = function(self, sid64, id)
      return self:orm("xenin_framework_notifications"):update({
      read_at = self.b.raw("CURRENT_TIMESTAMP")
      }):where("id", "=", id):where("target_id", "=", sid64):where("read_at", "", self.b.isNull()):run()
    end,
    getAmountOfUnreadNotifications = function(self, sid64)
      return self:orm("xenin_framework_notifications"):select(self.b.raw("COUNT(*) AS amount")):where("target_id", "=", sid64):where("read_at", "", self.b.isNull()):getOne():next(function(result)
        return result.amount == "NULL" and 0 or result.amount
      end)
    end,
    getNotification = function(self, id)
      return self:orm("xenin_framework_notifications"):select("id", "script_id", "type", "content", "data", self.b.alias(self.b.timestamp("created_at"), "created_at"), self.b.alias(self.b.timestamp("read_at"), "read_at")):where("id", "=", id):run():next(function(results)
        local tbl = {}

        for i, v in ipairs(results) do
          local entry = {
            id = v.id,
            type = v.type,
            scriptId = v.script_id,
            content = v.content,
            createdAt = v.created_at
          }
          if (v.data != "NULL") then
            entry.data = util.JSONToTable(v.data)
          end
          if (v.read_at != "NULL") then
            entry.readAt = v.read_at
          end

          table.insert(tbl, entry)
        end

        return tbl
      end)
    end,
    getNotifications = function(self, sid64, limit, offset)
      if limit == nil then limit = 10
      end
      if offset == nil then offset = 0
      end
      return self:orm("xenin_framework_notifications"):select("id", "type", "script_id", "content", "data", self.b.alias(self.b.timestamp("created_at"), "created_at"), self.b.alias(self.b.timestamp("read_at"), "read_at")):where("target_id", "=", sid64):orderBy("id", self.b.DESC):limit(limit):offset(offset):run():next(function(results)
        local tbl = {}

        for i, v in ipairs(results) do
          local entry = {
            id = v.id,
            type = v.type,
            scriptId = v.script_id,
            content = v.content,
            createdAt = v.created_at
          }
          if (v.data != "NULL") then
            entry.data = util.JSONToTable(v.data)
          end
          if (v.read_at != "NULL") then
            entry.readAt = v.read_at
          end

          table.insert(tbl, entry)
        end

        return tbl
      end)
    end,
    __type = function(self)
      return "Xenin.Notification.Database"end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self)
      ORM.__parent.__init(self, "xeninui/libs/players/migrations/")
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
  ORM = _class_0
end

local function Load()
  XeninUI.Players.Database = ORM()
end

if ((XeninUI.Configurator and XeninUI.Configurator.ORM) and XeninUI.Configurator.ORM.LoadedInsideHook) then
  Load()
else
  hook.Add("Xenin.Configurator.InitialisedDatabase", "Xenin.Players.Database", function()
    Load()
  end)
end
