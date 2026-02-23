local ScriptsNetwork
do
  local _class_0
  local _parent_0 = XeninUI.Network
  local _base_0 = {
    __name = "ScriptsNetwork",
    __base = XeninUI.Network.__base,
    receiveScripts = function(self, ply)
      local scripts = self:decompress()
      XeninUI.Scripts:setAll(scripts)

      hook.Run("Xenin.Framework.ReceivedScripts", scripts)
    end,
    receiveUpdateScripts = function(self, ply)
      local tbl = self:decompress()
      for i, v in ipairs(tbl) do
        chat.AddText(unpack(v))
      end
    end,
    requestScripts = function(self)
      if self.SentScriptsRequest then
        hook.Run("Xenin.Framework.ReceivedScripts", XeninUI.Scripts:getAll())

        return
      end

      self.SentScriptsRequest = true

      self:sendRequestScripts()
    end,
    sendRequestScripts = function(self)
      self:send("Xenin.Framework.Scripts", function(self) end)
    end,
    __type = function(self)
      return "XeninUI.ScriptsNetwork"end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self)
      ScriptsNetwork.__parent.__init(self)

      self:receiver("Xenin.Framework.Scripts", self.receiveScripts)
      self:receiver("Xenin.Framework.UpdateScriptsMessage", self.receiveUpdateScripts)
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
