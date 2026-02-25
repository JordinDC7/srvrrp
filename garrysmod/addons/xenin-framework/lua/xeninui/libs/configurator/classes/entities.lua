local Entities
do
  local _class_0
  local _base_0 = {
    __name = "Entities",
    getEntities = function(self)
      return self.entities
    end,
    register = function(self, name, entity)
      self.entities[name] = entity
    end,
    get = function(self, name)
      return self.entities[name]
    end,
    create = function(self, name)
      return self:get(name)()
    end,
    createSQLTable = function(self, entity)
      local inst = entity()
      local name = inst:getDatabaseEntity()
      XeninUI.Configurator:PrintMessage("Creating SQL table for entity " .. tostring(name))
      inst:createSQLTable()
    end,
    __type = function(self)
      return "XeninUI.Configurator.Entities"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.entities = {}
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
  Entities = _class_0
end
XeninUI.Configurator.Entities = XeninUI.Configurator.Entities || Entities()

hook.Add("Xenin.Configurator.InitialisedDatabase", "XeninUI.Configurator.Entities", function()
  local ents = XeninUI.Configurator.Entities
  for i, v in pairs(ents:getEntities()) do
    ents:createSQLTable(v)
  end
end)
