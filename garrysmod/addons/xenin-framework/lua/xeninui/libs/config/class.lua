local Config
do
  local _class_0
  local _base_0 = {
    __name = "Config",
    load = function(self)
      if SERVER then
        self:loadServer()
      else
        self:loadClient()
      end
    end,
    loadServer = function(self)
      hook.Add("XeninDB.Connected", "Xenin.Config", function()
        self:loadConfig()
      end)

      local db = file.Read("xenin/mysql.txt")
      MsgC(XeninUI.Theme.Red, "[Xenin Framework] ", color_white, "Using " .. (db and "MySQL" or "SQLite") .. " connection\n")
      if db then
        local tbl = util.JSONToTable(db)
        XeninDB.initialize(tbl)
        self.serverId = tbl.serverId or 1
      else
        XeninDB.initialize({
          EnableMySQL = false,
          Host = "ip",
          Username = "root",
          Password = "password",
          Database_name = "gmod_server",
          Database_port = 3306,
          MultiStatements = false
        })
      end
    end,
    loadConfig = function(self)
      XeninUI.ORM.DB = XeninUI.ORM.ORM("xeninui/server/migrations/")


      timer.Simple(3, function()
        self.db = XeninUI.ORM.DB
        self.builder = XeninUI.ORM.Builder
        local id = self.serverId or 1

        self.db:orm("xenin_framework_settings"):select():where("server_id", "=", self.builder.raw(tostring(id) .. " or NULL")):run():next(function(result)
          for i, v in ipairs(result or {}) do
            local val = v.json and util.JSONToTable(v.value) or v.value

            self:register(v.id, val)
          end

          self.loaded = true

          hook.Run("Xenin.ConfigLoaded")
        end)
      end)
    end,
    loadClient = function(self, selector)
      if selector == nil then selector = "scripts"
      end
      net.Start("Xenin.RequestConfig")
      net.WriteString(selector)
      net.SendToServer()
    end,
    getIndex = function(self, selector)
      local tbl = self.config
      local split = string.Explode(".", selector)

      for i, v in ipairs(split) do
        if (v == "") then continue end
        if (!tbl[v]) then return end

        tbl = tbl[v]
      end

      return tbl
    end,
    save = function(self, scriptId, tbl)
      if tbl == nil then tbl = {}
      end
      if CLIENT then
        tbl = von.serialize(tbl)
        local len = tbl:len()

        net.Start("Xenin.Config")
        net.WriteString(scriptId)
        net.WriteUInt(len, 32)
        net.WriteData(tbl, len)
        net.SendToServer()
      else
        local tbl = XeninUI.Config:get("scripts")[scriptId]
        if (!tbl) then return end

        local id = self.serverId or 1

        for i, v in pairs(tbl) do
          local json = istable(v)
          local val = json and util.TableToJSON(v) or v

          self.db:orm("xenin_framework_settings"):upsert({
            id = tostring(scriptId) .. "." .. tostring(i),
            value = val,
            json = json,
            server_id = id
          }, {
          "id" }):run()
        end
      end
    end,
    get = function(self, selector, default)
      return self:getIndex(selector) or default
    end,
    set = function(self, selector, key, value)
      local tbl = self:getIndex(selector)
      tbl[key] = value

      return self
    end,
    __type = function(self)
      return "XeninUI.Config"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.config = {}
      self:load()
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
  Config = _class_0
end

XeninUI.Config = Config()
XeninUI.Config:set("", "scripts", {})
