local Network
do
  local _class_0
  local _parent_0 = XeninUI.Network
  local _base_0 = {
    __name = "Network",
    __base = XeninUI.Network.__base,
    sendEntity = function(self, target, entity)
      self:send("Entity", target, function(self)
        net.WriteString(entity:getDatabaseEntity())
        entity:onNetworkSend()
      end)
    end,
    sendEntities = function(self, target, entities)
      for i, v in pairs(entities) do
        self:sendEntity(target, v)
      end
    end,
    sendSettings = function(self, target, script, settings)
      local __laux_type = (istable(target) and target.__type and target:__type()) or type(target)
      assert(__laux_type == "Player", "Expected parameter `target` to be type `Player` instead of `" .. __laux_type .. "`")
      local __laux_type = (istable(script) and script.__type and script:__type()) or type(script)
      assert(__laux_type == "string", "Expected parameter `script` to be type `string` instead of `" .. __laux_type .. "`")
      local __laux_type = (istable(settings) and settings.__type and settings:__type()) or type(settings)
      assert(__laux_type == "table", "Expected parameter `settings` to be type `table` instead of `" .. __laux_type .. "`")
      self:send("Settings", target, function(self)
        net.WriteString(script)
        net.WriteUInt(table.Count(settings), 12)
        for i, v in pairs(settings) do
          net.WriteString(i)
          self:write(v)
        end
      end)
    end,
    sendGetEntities = function(self, target, entities)
      local size = #entities
      self:send("GetEntities", target, function(self)
        net.WriteUInt(size, 16)
        for i, v in ipairs(entities) do
          net.WriteString(v:getDatabaseEntity())
          v:onNetworkSend()
        end
      end)
    end,
    receiveSaveSettings = function(self, ply)
      if (!XeninUI.Permissions:canAccessFramework(ply)) then return end

      local script = net.ReadString()
      local size = net.ReadUInt(12)
      local settings = {}
      for i = 1, size do
        local id = net.ReadString()
        local val = self:read()

        table.insert(settings, {
          id = id,
          val = val
        })
      end

      local controller = XeninUI.Configurator:FindControllerByScriptName(script)
      for i, v in ipairs(settings) do
        controller:set(v.id, v.val)
        controller:saveSetting(v.id, v.val)
      end
    end,
    receiveSaveSetting = function(self, ply)
      if (!XeninUI.Permissions:canAccessFramework(ply)) then return end

      local script = net.ReadString()
      local id = net:ReadString()
      local val = self:read()
      local controller = XeninUI.Configurator:FindControllerByScriptName(script)
      controller:set(id, val)
      controller:saveSetting(id, val)
    end,
    receiveGetEntities = function(self, ply)
      if (!XeninUI.Permissions:canAccessFramework(ply)) then return end

      local entity = net.ReadString()
      local limit = net.ReadUInt(16)
      local offset = net.ReadUInt(16)
      local search = net.ReadString()
      if (search == "") then search = nil end
      local ent = XeninUI.Configurator.Entities:create(entity)
      local tbl = {}
      if search then
        for i, v in ipairs(ent:getColumns()) do
          if v.primary then
            tbl[v.id] = search
          end
        end
      end

      XeninUI.Configurator.ORM:findEntities(ent, tbl):next(function(results)
        if (!IsValid(ply)) then return end
        results = results || {}

        local tbl = {}

        for _, ent in ipairs(results) do
          local inst = XeninUI.Configurator.Entities:create(entity)
          for i, v in pairs(ent) do
            inst["set" .. tostring(i)](inst, v)
          end
          table.insert(tbl, inst)
        end

        self:sendGetEntities(ply, tbl)
      end)
    end,
    receiveSaveEntity = function(self, ply)
      if (!XeninUI.Permissions:canAccessFramework(ply)) then return end

      local entity = net.ReadString()
      local ent = XeninUI.Configurator.Entities:create(entity)
      ent:onNetworkReceive()
      ent:save(true)
    end,
    receiveDeleteEntity = function(self, ply)
      if (!XeninUI.Permissions:canAccessFramework(ply)) then return end

      local entity = net.ReadString()
      local ent = XeninUI.Configurator.Entities:create(entity)
      ent:onNetworkReceive()
      ent:delete(true)
    end,
    receiveCreateEntity = function(self, ply)
      if (!XeninUI.Permissions:canAccessFramework(ply)) then return end

      local entity = net.ReadString()
      local ent = XeninUI.Configurator.Entities:create(entity)
      ent:onNetworkReceive()

      XeninUI.Configurator.ORM:createEntity(ent):next(function(result)
        if (!IsValid(ply)) then return end
        if (ent.setId and (result and result[2])) then
          ent:setId(result[2])
        end

        self:send("CreateEntity", ply, function(self)
          net.WriteString(entity)
          ent:onNetworkSend()
        end)
      end)
    end,
    __type = function(self)
      return "XeninUI.Configurator.Network"end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self)
      Network.__parent.__init(self)

      self:setPrefix("XeninUI.Configuator.")
      self:prepare({
        "Settings",
        "SaveSettings",
        "SaveSetting",
        "GetSettings",
        "Entity",
        "SaveEntity",
        "GetEntities",
        "CreateEntity",
        "DeleteEntity"
      })

      self:receiver("SaveSettings", self.receiveSaveSettings)
      self:receiver("GetEntities", self.receiveGetEntities)
      self:receiver("SaveEntity", self.receiveSaveEntity)
      self:receiver("CreateEntity", self.receiveCreateEntity)
      self:receiver("DeleteEntity", self.receiveDeleteEntity)
      self:receiver("SaveSetting", self.receiveSaveSetting)
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
  Network = _class_0
end

XeninUI.Configurator.Network = Network()
