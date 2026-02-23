local LanguagesNetwork
do
  local _class_0
  local _parent_0 = XeninUI.Network
  local _base_0 = {
    __name = "LanguagesNetwork",
    __base = XeninUI.Network.__base,
    receiveRequestLanguage = function(self, ply)
      local addonId = net.ReadString()
      if (!isstring(addonId)) then return end
      local inst = XeninUI.LanguageAddons[addonId]
      if (!istable(inst)) then return end
      local lang = net.ReadString()
      if (!isstring(lang)) then return end

      local function resolve(data)
        self:sendLanguage(ply, addonId, lang, data)
      end

      inst:Download(lang):next(resolve, function(err)
        resolve({
        phrases = {} })
      end)
    end,
    sendLanguage = function(self, ply, addonId, lang, tbl)
      self:send("XeninUI.Language", ply, function(self)
        net.WriteString(addonId)
        net.WriteString(lang)
        self:compress(tbl)
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

      self:prepare("XeninUI.Language")

      self:receiver("XeninUI.Language", self.receiveRequestLanguage)
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
