local ScriptsNetwork
do
  local _class_0
  local _parent_0 = XeninUI.Network
  local _base_0 = {
    __name = "ScriptsNetwork",
    __base = XeninUI.Network.__base,
    receiveScriptsRequest = function(self, ply)
      if (!XeninUI.Permissions:canAccessFramework(ply)) then return end

      self:sendScripts(ply, XeninUI.Scripts:getAll())
    end,
    sendUpdateMessage = function(self, ply, tbl)
      self:send("Xenin.Framework.UpdateScriptsMessage", ply, function(self)
        self:compress(tbl)
      end)
    end,
    sendScripts = function(self, ply, scripts)
      self:send("Xenin.Framework.Scripts", ply, function(self)
        self:compress(scripts)
      end)
    end,
    __type = function(self)
      return "XeninUI.ScriptsNetwork"end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self)
      ScriptsNetwork.__parent.__init(self)

      self:prepare({
        "Xenin.Framework.Scripts",
        "Xenin.Framework.UpdateScriptsMessage"
      })

      self:receiver("Xenin.Framework.Scripts", self.receiveScriptsRequest)
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
  ScriptsNetwork = _class_0
end

XeninUI.ScriptsNetwork = ScriptsNetwork()
