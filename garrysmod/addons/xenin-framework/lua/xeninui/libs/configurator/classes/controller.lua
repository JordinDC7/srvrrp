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
XeninUI.Configurator.Controllers = XeninUI.Configurator.Controllers || {}

function XeninUI.Configurator:GetControllers()
  return self.Controllers
end

function XeninUI.Configurator:FindControllerByScriptName(script)
  return self:GetControllers()[script]
end

do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Configurator.Controller",
    setTitle = function(self, title)
      self.title = title
      return self
    end,
    getSettings = function(self)
      return self.settings
    end,
    getTabs = function(self)
      return self.tabs
    end,
    getScript = function(self)
      return self.script
    end,
    getTitle = function(self)
      return self.title
    end,
    IsValid = function(self)
      return XeninUI.Configurator:FindControllerByScriptName(self.script) == self
    end,
    addSettingTab = function(self, name)
      table.insert(self.settingTab, {
        name = name,
        subtabs = {}
      })
    end,
    getSettingTabs = function(self)
      return self.settingTab
    end,
    addSetting = function(self, id, category, subCategory, name, desc, value, type, data, sortOrder)
      if data == nil then data = {}
      end
      self.settings[id] = {
        id = id,
        category = category,
        subCategory = subCategory,
        name = name,
        desc = desc,
        value = value,
        defaultValue = value,
        type = type,
        data = data,
        sortOrder = sortOrder or table.Count(self.settings) + 1
      }

      self.cache:set(id, value)
    end,
    addTab = function(self, name, icon, color, panel, settings)
      if settings == nil then settings = {}
      end
      table.insert(self.tabs, __laux_concat_0({
        name = name,
        icon = icon,
        color = color or color_white,
        panel = panel or "DPanel"
      }, settings))
    end,
    addSettingsTab = function(self, name, icon, color, settings)
      if settings == nil then settings = {}
      end
      local panel = "Xenin.Configurator.Admin.Panel"
      settings.settingsTab = true

      self:addTab(name, icon, color, panel, settings)
    end,
    addEntityTab = function(self, name, icon, color, entity, settings)
      if settings == nil then settings = {}
      end
      local panel = settings.panelOverride or "Xenin.Configurator.Admin.Entity"
      if (settings.isGrid and !settings.panelOverride) then
        panel = "Xenin.Configurator.Admin.EntityGrid"
      end
      if (settings.isList and !settings.panelOverride) then
        panel = "Xenin.Configurator.Admin.EntityList"
      end

      table.Merge(settings, {
        __entity = entity,
        script = self:getScript(),
        name = name
      })
      self:addTab(name, icon, color, panel, settings)
    end,
    getSettingsKV = function(self)
      local tbl = {}
      for i, v in pairs(self:getSettings()) do
        tbl[v.id] = self.cache:get(v.id)
      end

      return tbl
    end,
    getSortedSettings = function(self)
      local tbl = {}
      for i, v in pairs(self:getSettings()) do
        table.insert(tbl, v)
      end
      table.sort(tbl, function(a, b)
        return a.sortOrder < b.sortOrder end)

      return tbl
    end,
    getSettingsByCategory = function(self)
      local tbl = {}
      for i, v in pairs(self:getSettings()) do
        tbl[v.category] = tbl[v.category] || {}

        table.insert(tbl[v.category], v)
      end
      for i, v in pairs(tbl) do
        table.sort(v, function(a, b)
          return a.sortOrder < b.sortOrder end)
      end

      return tbl
    end,
    get = function(self, key, default)
      local val = self.cache:get(key)
      if (val != nil) then
        return val
      end

      return default
    end,
    onSettingChanged = function(self, key, value) end,
    set = function(self, key, value)
      self.cache:set(key, value)
      self.settings[key].value = value

      self:onSettingChanged(key, value)
    end,
    saveSetting = function(self, id, val)
      if CLIENT then
        XeninUI.Configurator.Network:sendSaveSetting(self:getScript(), id, val)
      else
        return XeninUI.Configurator.ORM:saveSetting(self:getScript(), id, val)
      end
    end,
    load = function(self)
      local p = XeninUI.Promises.new()

      if self.hasLoadedSettings then
        return p:resolve()
      end

      XeninUI.Configurator.ORM:getScriptSettings(self:getScript()):next(function(results)
        if results == nil then results = {}
        end
        for i, v in ipairs(results) do
          assert(v ~= nil, "cannot destructure nil value")
          local id, value, json = v.id, v.value, v.json
          if (json and json != "NULL") then
            value = util.JSONToTable(value)
          end

          self.cache:set(id, value)
        end

        self.hasLoadedSettings = true
        p:resolve()
      end, function(err)
        p:reject(err)
      end)

      return p
    end,
    networkSettings = function(self, target)
      if (CLIENT) then return end

      local isAdmin = XeninUI.Permissions:canAccessFramework(target)
      local tbl = {}
      for i, v in pairs(self:getSettings()) do
        local setting = self.settings[v.id]
        if (setting.data.secret and !isAdmin) then continue end

        tbl[v.id] = self.cache:get(v.id)
      end

      XeninUI.Configurator.Network:sendSettings(target, self:getScript(), tbl)
    end,
    loadEntities = function(self, ent)
      local p = XeninUI.Promises.new()
      local id = ent:getDatabaseEntity()
      if self.loadedEntities[id] then
        return p:resolve()
      end

      XeninUI.Configurator.ORM:findEntities(ent):next(function(results)
        results = results || {}

        local tbl = {}

        for _, entData in ipairs(results) do
          local inst = XeninUI.Configurator.Entities:create(id)
          for i, v in pairs(entData) do
            local val = v
            local col = inst:getColumn(i)
            if col.onLoad then
              val = col:onLoad(v)
            end

            inst["set" .. tostring(i)](inst, val)
          end
          inst:save()
          inst:onLoad()
        end

        self.loadedEntities[id] = true
        p:resolve()
      end)

      return p
    end,
    networkEntities = function(self, target)
      if (CLIENT) then return end

      local ents = XeninUI.Configurator.Entities:getEntities()
      local type = self:__type()
      local id = (string.Explode(".", type) and string.Explode(".", type)[1])
      local length = #id
      for entId, ent in pairs(ents) do
        local str = entId:sub(1, length)
        if (str != id) then continue end

        if (!ent.getAllEntities) then
          Error(tostring(entId) .. " has no way of getting all instances of said entity. Please implement a static getAllEntities function\n")
        end

        self:loadEntities(ent()):next(function(result)
          local allEnts = ent.getAllEntities()

          XeninUI.Configurator.Network:sendEntities(target, allEnts)
        end)
      end
    end,
    addSearch = function(self, id, tabFunc, matchFunc, clickFunc)
      if clickFunc == nil then clickFunc = function() end
      end
      table.insert(self.search, {
        id = id,
        matchFunc = matchFunc,
        tabFunc = tabFunc,
        clickFunc = clickFunc
      })
    end,
    getSearch = function(self, text)
      text = text:lower()

      local function findTab(func)
        for i, v in pairs(self.tabs) do
          if (!func(v, i)) then continue end

          return v, i
        end
      end

      local tbl = {}
      for i, v in ipairs(self.search) do

        local tab = findTab(v.tabFunc)
        if (!tab) then continue end

        local results = v:matchFunc(text, tab)
        tbl = __laux_concat_0(tbl, results)

        if (#tbl >= 4) then break end
      end

      return {
        tbl[1],
        tbl[2],
        tbl[3],
        tbl[4]
      }
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, script)
      self.search = {}
      self.loadedEntities = {}
      self.tabs = {}
      self.settingTab = {}
      self.settings = {}
      self.hasLoadedSettings = false
      self.cache = XeninUI.Configurator.Cache()
      self.script = script:lower()

      XeninUI.Configurator.Controllers[self.script] = self

      hook.Add("PlayerInitialSpawn", "XeninUI.Configurator.Scripts." .. tostring(script), function(ply)
        timer.Simple(3, function()
          self:load():next(function()
            if (!IsValid(ply)) then return end

            self:networkSettings(ply)
            self:networkEntities(ply)
          end)
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
  XeninUI.Configurator.Controller = _class_0
end
