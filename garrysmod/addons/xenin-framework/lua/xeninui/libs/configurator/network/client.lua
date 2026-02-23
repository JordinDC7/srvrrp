local Network
do
  local _class_0
  local _parent_0 = XeninUI.Network
  local _base_0 = {
    __name = "Network",
    __base = XeninUI.Network.__base,
    receiveSettings = function(self, ply)
      local script = net.ReadString()
      local size = net.ReadUInt(12)
      XeninUI.Configurator:PrintMessage("Received settings for the addon '" .. tostring(script) .. "', size: " .. tostring(size))
      local controller = XeninUI.Configurator:FindControllerByScriptName(script)
      for i = 1, size do
        local id = net.ReadString()
        local val = self:read()

        controller:set(id, val)
      end
    end,
    sendSaveSettings = function(self, script, tbl)
      local __laux_type = (istable(script) and script.__type and script:__type()) or type(script)
      assert(__laux_type == "string", "Expected parameter `script` to be type `string` instead of `" .. __laux_type .. "`")
      local __laux_type = (istable(tbl) and tbl.__type and tbl:__type()) or type(tbl)
      assert(__laux_type == "table", "Expected parameter `tbl` to be type `table` instead of `" .. __laux_type .. "`")
      self:send("SaveSettings", function(self)
        local size = table.Count(tbl)
        net.WriteString(script)
        net.WriteUInt(size, 12)
        for i, v in pairs(tbl) do
          net.WriteString(i)
          self:write(v)
        end
      end)
    end,
    sendSaveSetting = function(self, script, id, val)
      local __laux_type = (istable(script) and script.__type and script:__type()) or type(script)
      assert(__laux_type == "string", "Expected parameter `script` to be type `string` instead of `" .. __laux_type .. "`")
      local __laux_type = (istable(id) and id.__type and id:__type()) or type(id)
      assert(__laux_type == "string", "Expected parameter `id` to be type `string` instead of `" .. __laux_type .. "`")
      self:send("SaveSetting", function(self)
        net.WriteString(script)
        net.WriteString(id)
        self:write(val)
      end)
    end,
    sendGetEntities = function(self, entity, limit, offset, search)
      if limit == nil then limit = 10
      end
      if offset == nil then offset = 0
      end
      if search == nil then search = ""
      end
      local __laux_type = (istable(entity) and entity.__type and entity:__type()) or type(entity)
      assert(__laux_type == "XeninUI.Configurator.Entity", "Expected parameter `entity` to be type `XeninUI.Configurator.Entity` instead of `" .. __laux_type .. "`")
      local ent = entity:getDatabaseEntity()

      self:send("GetEntities", function(self)
        net.WriteString(ent)
        net.WriteUInt(limit, 16)
        net.WriteUInt(offset, 16)
        net.WriteString(search)
      end)
    end,
    sendSaveEntity = function(self, entity)
      self:send("SaveEntity", function(self)
        net.WriteString(entity:getDatabaseEntity())
        entity:onNetworkSend()
      end)
    end,
    sendCreateEntity = function(self, entity)
      self:send("CreateEntity", function(self)
        net.WriteString(entity:getDatabaseEntity())
        entity:onNetworkSend()
      end)
    end,
    sendDeleteEntity = function(self, entity)
      self:send("DeleteEntity", function(self)
        net.WriteString(entity:getDatabaseEntity())
        entity:onNetworkSend()
      end)
    end,
    receiveCreateEntity = function(self, entity)
      local entity = net.ReadString()
      local ent = XeninUI.Configurator.Entities:create(entity)
      ent:onNetworkReceive()
      ent:save()

      hook.Run("XeninUI.Configurator.CreatedEntity", ent)
    end,
    receiveEntity = function(self, ply)
      local entity = net.ReadString()
      local ent = XeninUI.Configurator.Entities:create(entity)
      ent:onNetworkReceive()
      ent:save()
    end,
    receiveGetEntities = function(self, ply)
      local size = net.ReadUInt(16)
      local tbl = {}
      for i = 1, size do
        local entity = net.ReadString()
        local ent = XeninUI.Configurator.Entities:create(entity)
        ent:onNetworkReceive()

        table.insert(tbl, ent)
      end

      hook.Run("XeninUI.Configurator.GetEntities", tbl)
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

      self:receiver("Settings", self.receiveSettings)
      self:receiver("Entity", self.receiveEntity)
      self:receiver("GetEntities", self.receiveGetEntities)
      self:receiver("CreateEntity", self.receiveCreateEntity)
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
