do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Network",
    setPrefix = function(self, prefix)
      self.prefix = prefix
      return self
    end,
    getPrefix = function(self)
      return self.prefix
    end,
    prepare = function(self, str)
      if istable(str) then
        for i, v in ipairs(str) do
          util.AddNetworkString(self:getPrefix() .. v)
        end
      else
        util.AddNetworkString(self:getPrefix() .. str)
      end
    end,
    receiver = function(self, name, func)
      if func == nil then func = function() end
      end
      net.Receive(self:getPrefix() .. name, function(len, ply)
        func(self, ply or LocalPlayer(), len)
      end)
    end,
    send = function(self, name, target, func)
      net.Start(self:getPrefix() .. name)

      if CLIENT then
        target(self)

        net.SendToServer()
      else
        func(self)

        net.Send(target)
      end
    end,
    compress = function(self, data)
      local tbl = false
      if istable(data) then
        data = util.TableToJSON(data)
        tbl = true
      end

      data = util.Compress(data)
      local len = data:len()

      net.WriteUInt(len, 32)
      net.WriteBool(tbl)
      net.WriteData(data, len)
    end,
    decompress = function(self)
      local len = net.ReadUInt(32)
      local tbl = net.ReadBool()
      local data = net.ReadData(len)
      data = util.Decompress(data)

      if tbl then
        data = util.JSONToTable(data)
      end

      return data
    end,
    getNetworkType = function(self, input)
      if isnumber(input) then
        local int, frac = math.modf(input)
        if (frac != 0) then
          return self.FLOAT
        end

        return self.INTEGER
      elseif (isbool(input) or input == nil) then
        return self.BOOL
      elseif isstring(input) then
        return self.STRING
      elseif istable(input) then
        return self.TABLE
      end
    end,
    writeType = function(self, input)
      local type = self:getNetworkType(input)
      net.WriteUInt(type, self.DYNAMIC_DATA_SIZE)

      return type
    end,
    readType = function(self, input)
      return net.ReadUInt(self.DYNAMIC_DATA_SIZE)end,
    write = function(self, input, ...)
      local type = self:writeType(input)
      self:writeFromType(type, input, ...)

      return type
    end,
    read = function(self, ...)
      local type = self:readType()
      return self:readFromType(type, ...)
    end,
    writeFromType = function(self, type, input, ...)
      self.writeTypes[type](input, ...)end,
    readFromType = function(self, type, ...)
      return self.readTypes[type](...)end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.TABLE = 4
      self.STRING = 3
      self.BOOL = 2
      self.INTEGER = 1
      self.FLOAT = 0
      self.DYNAMIC_DATA_SIZE = 3
      self:setPrefix("")

      self.writeTypes = {
        [self.FLOAT] = function(i)
          net.WriteFloat(i)end,
        [self.INTEGER] = function(i)
          net.WriteInt(i, 16)end,
        [self.BOOL] = function(i)
          net.WriteBool(i)end,
        [self.STRING] = function(i)
          net.WriteString(i)end,

        [self.TABLE] = function(i)
          net.WriteTable(i)end
      }
      self.readTypes = {
        [self.FLOAT] = function()
          return math.Round(net.ReadFloat(), 5)end,
        [self.INTEGER] = function()
          return net.ReadInt(16)end,
        [self.BOOL] = function()
          return net.ReadBool()end,
        [self.STRING] = function()
          return net.ReadString()end,
        [self.TABLE] = function()
          return net.ReadTable()end
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
  XeninUI.Network = _class_0
end
