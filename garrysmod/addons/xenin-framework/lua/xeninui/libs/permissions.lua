local Permissions
do
  local _class_0
  local _base_0 = {
    __name = "Permissions",
    canAccessFramework = function(self, ply)
      local dev = self:isXeninDeveloper(ply)
      if (dev and tonumber(GetConVar("xenin_easy_permissions")) == 1) then
        return true
      end

      return self:isSuperAdmin(ply)
    end,
    isAdmin = function(self, ply, level)
      if level == nil then level = 1
      end
      return ply:IsAdmin()
    end,
    isSuperAdmin = function(self, ply)
      return ply:IsSuperAdmin()
    end,
    isXeninDeveloper = function(self, ply)
      return self.xeninDevelopers[ply:SteamID64()]
    end,
    __type = function(self)
      return "XeninUI.Permissions"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.xeninDevelopers = {
        ["76561198202328247"] = "sleeppyy",
        ["76561198058042338"] = "Hoofy"
      }
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
  Permissions = _class_0
end

XeninUI.Permissions = Permissions()

CreateConVar("xenin_easy_permissions", 1)
