util.AddNetworkString("Xenin.Config")
util.AddNetworkString("Xenin.RequestConfig")

net.Receive("Xenin.Config", function(len, ply)
  if (!XeninUI.Permissions:isDeveloper(ply)) then return end

  local scriptId = net.ReadString()
  local len = net.ReadUInt(32)
  local tbl = von.deserialize(net.ReadData(len))

  XeninUI.Config:set("scripts", scriptId, tbl)
  XeninUI.Config:save(scriptId)
end)

net.Receive("Xenin.RequestConfig", function(len, ply)
  local selector = net.ReadString()
  local data = von.serialize(XeninUI.Config:get(selector, {}))
  local len = data:len()

  net.Start("Xenin.RequestConfig")
  net.WriteString(selector)
  net.WriteUInt(len, 32)
  net.WriteData(data, len)
  net.Send(ply)
end)

print("hi")
