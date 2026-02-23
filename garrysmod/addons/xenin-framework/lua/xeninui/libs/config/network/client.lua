net.Receive("Xenin.RequestConfig", function(len, ply)
  local selector = net.ReadString()
  local len = net.ReadUInt(32)
  local tbl = von.deserialize(net.ReadData(len))

  XeninUI.Config:set(selector, tbl)
end)
