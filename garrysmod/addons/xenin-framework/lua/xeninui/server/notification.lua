util.AddNetworkString("XeninUI.Notification")

function XeninUI:Notify(ply, str, icon, duration, progressColor, textColor, markup)
  net.Start("XeninUI.Notification")
  net.WriteTable({
    str = str,
    icon = icon,
    dur = duration,
    progressCol = progressColor,
    textCol = textColor,
    markup = markup
  })
  net.Send(ply)
end
