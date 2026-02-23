local Scripts
do
  local _class_0
  local _base_0 = {
    __name = "Scripts",
    checkScriptVersions = function(self, tbl)
      local scripts = self:getAll()
      local needUpdate = {}

      for i, v in pairs(scripts) do
        if (!v.versionCheck) then continue end

        local tblVersion = tbl[v.id]
        local version = tonumber(v.version)
        if (!isnumber(version)) then continue end
        if (!isnumber(tblVersion)) then continue end

        if (tblVersion and version < tblVersion) then
          needUpdate[v.id] = {
            name = v.name,
            version = tblVersion,
            currentVersion = v.version
          }
        end
      end

      local msgs = {}
      for i, v in pairs(needUpdate) do
        table.insert(msgs, {
          XeninUI.Theme.Accent,
          "[Xenin " .. tostring(v.name) .. "] ",
          Color(255, 255, 255),
          "Please update to ",
          XeninUI.Theme.Green,
          "version " .. tostring(v.version),
          Color(255, 255, 255),
          " you are on ",
          XeninUI.Theme.Red,
          "version " .. tostring(v.currentVersion)
        })
      end
      local targets = {}
      for i, v in ipairs(player.GetAll()) do
        if (XeninUI.Permissions:canAccessFramework(v) or XeninUI.Permissions:isAdmin(v)) then
          table.insert(targets, v)
        end
      end

      XeninUI.ScriptsNetwork:sendUpdateMessage(targets, msgs)

      for i, v in ipairs(msgs) do
        table.insert(v, "\n")

        MsgC(unpack(v))
      end
    end,
    register = function(self, id, name, version, author, tbl)
      if tbl == nil then tbl = {}
      end
      local script = {
        id = id,
        name = name,
        author = author,
        version = version
      }

      table.Merge(script, tbl)

      self.scripts[id] = script
    end,
    setAll = function(self, tbl)
      self.scripts = tbl
    end,
    get = function(self, id)
      return self.scripts[id]
    end,
    getAll = function(self)
      return self.scripts
    end,
    getByName = function(self, name)
      for i, v in pairs(self.scripts) do
        if (v.name != name) then continue end

        return name
      end
    end,
    __type = function(self)
      return "XeninUI.Scripts"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.scripts = {}
      if (CLIENT) then return end

      timer.Create("Xenin.Framework.Version", 600, 0, function()
        http.Fetch("https://gitlab.com/sleeppyy/xenin-version-tracker/-/raw/master/versions.json", function(body, size, headers, code)
          if (code >= 400) then return end
          if (size == 0) then return end
          local tbl = util.JSONToTable(body)
          if (!tbl) then return end

          self:checkScriptVersions(tbl)
        end)
      end)
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
  Scripts = _class_0
end

XeninUI.Scripts = Scripts()
