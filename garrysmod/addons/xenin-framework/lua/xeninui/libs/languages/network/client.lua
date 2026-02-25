local LanguagesNetwork
do
  local _class_0
  local _parent_0 = XeninUI.Network
  local _base_0 = {
    __name = "LanguagesNetwork",
    __base = XeninUI.Network.__base,
    receiveLanguage = function(self, ply)
      local addonId = net.ReadString()
      local lang = net.ReadString()
      local data = self:decompress()

      XeninUI.LanguageAddons[addonId]:SetLocalLanguage(lang, data)
    end,
    sendRequestLanguage = function(self, addonId, lang)
      self:send("XeninUI.Language", function(self)
        net.WriteString(addonId)
        net.WriteString(lang)
      end)
    end,
    __type = function(self)
      return "XeninUI.LanguagesNetwork"end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__index)
  _class_0 = setmetatable({
    __init = function(self)
      LanguagesNetwork.__parent.__init(self)

      self:receiver("XeninUI.Language", self.receiveLanguage)
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
  LanguagesNetwork = _class_0
end

XeninUI.LanguagesNetwork = LanguagesNetwork()
