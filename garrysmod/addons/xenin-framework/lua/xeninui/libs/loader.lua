XENINUI_SERVER = 1
XENINUI_CLIENT = 2
XENINUI_SHARED = 3

do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Loader",
    setName = function(self, name)
      self.name = name
      return self
    end,
    setAcronym = function(self, acronym)
      self.acronym = acronym
      return self
    end,
    setDirectory = function(self, directory)
      self.directory = directory
      return self
    end,
    setColor = function(self, color)
      self.color = color
      return self
    end,
    getName = function(self)
      return self.name
    end,
    getAcronym = function(self)
      return self.acronym
    end,
    getDirectory = function(self)
      return self.directory
    end,
    getColor = function(self)
      return self.color
    end,
    loadMessage = function(self, path, realm, col)
      if col == nil then col = self:getColor()
      end
      local __laux_type = (istable(path) and path.__type and path:__type()) or type(path)
      assert(__laux_type == "string", "Expected parameter `path` to be type `string` instead of `" .. __laux_type .. "`")
      if (XeninUI.DisableLoadMessages) then return end

      local name = self:getName()

      MsgC(self:getColor(), "[" .. tostring(name), col, " - " .. tostring(realm) .. "] ", color_white, "Loaded ", Color(0, 255, 0), tostring(path) .. "\n")
    end,
    loadFile = function(self, path, realm, func)
      local __laux_type = (istable(path) and path.__type and path:__type()) or type(path)
      assert(__laux_type == "string", "Expected parameter `path` to be type `string` instead of `" .. __laux_type .. "`")
      local __laux_type = (istable(realm) and realm.__type and realm:__type()) or type(realm)
      assert(__laux_type == "number", "Expected parameter `realm` to be type `number` instead of `" .. __laux_type .. "`")
      if (!string.EndsWith(path, ".lua")) then path = path .. ".lua"
      end

      local fullPath = self:getDirectory() .. "/" .. path
      if self.loadedFiles[path] then
        if (!self.suppressDuplicates and !XeninUI.DisableLoadMessages) then
          local name = self:getName()
          MsgC(XeninUI.Theme.Red, "[" .. tostring(name) .. "]", color_white, " " .. tostring(fullPath) .. " has already been loaded. Skipping\n")
        end

        return
      end

      local tbl = self.realms[realm]
      self:loadMessage(string.StripExtension(fullPath), tbl.name, tbl.color)
      func = func or tbl.func
      func(self, fullPath)

      self.loadedFiles[path] = true

      return self
    end,
    loadFileOrIgnore = function(self, ...)
      pcall(self:loadFile(...))

      return self
    end,
    load = function(self, dir, realm, recursive, options)
      if recursive == nil then recursive = false
      end
      if options == nil then options = {}
      end
      local __laux_type = (istable(dir) and dir.__type and dir:__type()) or type(dir)
      assert(__laux_type == "string", "Expected parameter `dir` to be type `string` instead of `" .. __laux_type .. "`")
      local __laux_type = (istable(realm) and realm.__type and realm:__type()) or type(realm)
      assert(__laux_type == "number" or __laux_type == "table", "Expected parameter `realm` to be type `number|table` instead of `" .. __laux_type .. "`")
      local __laux_type = (istable(recursive) and recursive.__type and recursive:__type()) or type(recursive)
      assert(__laux_type == "boolean", "Expected parameter `recursive` to be type `boolean` instead of `" .. __laux_type .. "`")
      local ignoreFiles = options.ignoreFiles or {}
      local overwriteRealm = options.overwriteRealm or {}
      local path = self:getDirectory()
      if (!string.EndsWith(path, "/")) then path = path .. "/"
      end
      if (!string.EndsWith(dir, "/")) then dir = dir .. "/"
      end

      local realmTbl = isnumber(realm) and self.realms[realm]
      local files, folders = file.Find(path .. dir .. "*", "LUA")
      for i, file in ipairs(files) do
        local name = string.StripExtension(file)
        if (ignoreFiles[name]) then continue end

        local fileRealm = realm
        local func = (realmTbl and realmTbl.func)
        local color = (realmTbl and realmTbl.color)
        local realmName = (realmTbl and realmTbl.name)
        if (istable(realm) or overwriteRealm[name]) then
          local realm = overwriteRealm[name] or realm[name]
          if realm then
            local tbl = self.realms[realm]
            func = tbl.func
            color = tbl.color
            realmName = tbl.name
            fileRealm = realm
          end
        end

        local filePath = dir .. file
        self:loadFile(filePath, fileRealm, func)
      end

      if recursive then
        for i, folder in ipairs(folders) do
          self:load(dir .. folder, realm, recursive, options)
        end
      end

      return self
    end,
    done = function(self)
      local time = math.Round(SysTime() - self.start, 4)
      local files = table.Count(self.loadedFiles)

      MsgC(self:getColor(), "[" .. self:getName() .. "]", color_white, " Finished loading " .. tostring(files) .. " files in " .. tostring(time) .. "s\n")
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, suppressDuplicates)
      self.realms = {
        [1] = {
          color = XeninUI.Theme.Blue,
          name = "SV",
          func = function(self, path)
            if (CLIENT) then return end

            return include(path)
          end
        },
        [2] = {
          color = XeninUI.Theme.Orange,
          name = "CL",
          func = function(self, path)
            if CLIENT then
              return include(path)
            end

            AddCSLuaFile(path)
          end
        },
        [3] = {
          color = XeninUI.Theme.Purple,
          name = "SH",
          func = function(self, path)
            self.realms[XENINUI_CLIENT].func(self, path)
            return self.realms[XENINUI_SERVER].func(self, path)
          end
        }
      }
      self.suppressDuplicates = suppressDuplicates or !XeninUI.Debug
      self.start = SysTime()
      self.loadedFiles = {}
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
  XeninUI.Loader = _class_0
end
