-- [MEGA UPDATE PATCH] Unified UX hub, onboarding, and safety/performance helpers.

if SERVER then
  util.AddNetworkString("srvrrp_mega_update_open_hub")
  util.AddNetworkString("srvrrp_mega_update_tip")

  local function openHub(ply)
    if not IsValid(ply) then return end
    net.Start("srvrrp_mega_update_open_hub")
    net.Send(ply)
  end

  hook.Add("PlayerSay", "srvrrp_mega_update_chat_commands", function(ply, text)
    local msg = string.Trim(string.lower(text or ""))
    if msg == "!hub" or msg == "/hub" or msg == "!menu" or msg == "/menu" then
      openHub(ply)
      return ""
    end

    if msg == "!systems" or msg == "/systems" then
      ply:ChatPrint("[Server] Systems: F4 (jobs/shop), inventory, gangs, unboxing, casino, grow op, botnet, scratchcards, party.")
      ply:ChatPrint("[Server] Use /hub for the quick launcher.")
      return ""
    end
  end)

  hook.Add("PlayerInitialSpawn", "srvrrp_mega_update_intro_tip", function(ply)
    timer.Simple(8, function()
      if not IsValid(ply) then return end
      net.Start("srvrrp_mega_update_tip")
      net.WriteString("Use /hub for the new quick-access launcher and system tips.")
      net.Send(ply)
    end)
  end)

  -- [MEGA UPDATE PATCH] Admin-safety gates for known risky tools.
  local trustedRanks = {
    superadmin = true,
    admin = true,
    moderator = true
  }

  local function isTrusted(ply)
    if not IsValid(ply) then return false end
    return trustedRanks[string.lower(ply:GetUserGroup() or "")] == true
  end

  local blockedTools = {
    ["advdupe2"] = true,
    ["stacker"] = true,
    ["stacker_improved"] = true,
    ["keypad_cracker"] = true
  }

  hook.Add("CanTool", "srvrrp_mega_update_tool_safety", function(ply, tr, tool)
    if not blockedTools[string.lower(tool or "")] then return end
    if isTrusted(ply) then return end

    if DarkRP and DarkRP.notify then
      DarkRP.notify(ply, 1, 4, "This tool is restricted to staff for safety.")
    else
      ply:ChatPrint("[Server] This tool is restricted to staff for safety.")
    end

    return false
  end)

  concommand.Add("srvrrp_open_hub", function(ply)
    if not IsValid(ply) then return end
    openHub(ply)
  end)

  return
end

local accent = Color(94, 178, 255)
local bg = Color(18, 22, 29, 245)
local panel = Color(32, 38, 48, 255)
local panelHover = Color(42, 52, 67, 255)
local txt = Color(232, 236, 242)
local subTxt = Color(170, 176, 186)

surface.CreateFont("SRVRRP.Mega.Title", {
  font = "Roboto",
  size = 30,
  weight = 700,
  antialias = true,
  extended = true
})

surface.CreateFont("SRVRRP.Mega.Subtitle", {
  font = "Roboto",
  size = 18,
  weight = 500,
  antialias = true,
  extended = true
})

surface.CreateFont("SRVRRP.Mega.Button", {
  font = "Roboto",
  size = 19,
  weight = 600,
  antialias = true,
  extended = true
})

local function runCommand(kind, value)
  if kind == "console" then
    LocalPlayer():ConCommand(value)
    return
  end

  if kind == "say" then
    LocalPlayer():ConCommand("say " .. value)
  end
end

local actions = {
  { name = "Inventory", desc = "Open Xenin Inventory", kind = "console", value = "inventory" },
  { name = "F4 Menu", desc = "Open jobs, shipments, and entities", kind = "console", value = "say /f4" },
  { name = "Gangs", desc = "Open Bricks Gangs panel", kind = "console", value = "gang" },
  { name = "Unboxing", desc = "Open cases and rewards", kind = "console", value = "unboxing" },
  { name = "Party", desc = "Open Ultimate Party System", kind = "say", value = "/party" },
  { name = "Systems Help", desc = "Show quick system guide in chat", kind = "say", value = "/systems" }
}

local tips = {
  "Grow Op and BotNet are high-value loops: active monitoring is better than AFK farming.",
  "Use inventory sorting + search to keep item management fast during raids.",
  "Gangs + parties stack well for coordinated farming and territory pressure.",
  "Casino and scratchcards are best used as burst-risk spending, not primary income.",
}

local function createHub()
  if IsValid(SRVRRP_MegaHub) then
    SRVRRP_MegaHub:Remove()
  end

  local w, h = math.min(ScrW() - 80, 980), math.min(ScrH() - 80, 650)
  local frame = vgui.Create("DFrame")
  SRVRRP_MegaHub = frame
  frame:SetSize(w, h)
  frame:Center()
  frame:MakePopup()
  frame:SetTitle("")
  frame:ShowCloseButton(false)
  frame.Paint = function(_, fw, fh)
    draw.RoundedBox(12, 0, 0, fw, fh, bg)
    draw.RoundedBoxEx(12, 0, 0, fw, 82, panel, true, true, false, false)
    draw.SimpleText("SRVRRP Control Center", "SRVRRP.Mega.Title", 24, 18, txt)
    draw.SimpleText("Unified access to core systems and progression loops", "SRVRRP.Mega.Subtitle", 24, 54, subTxt)
  end

  local close = frame:Add("DButton")
  close:SetText("✕")
  close:SetFont("SRVRRP.Mega.Subtitle")
  close:SetTextColor(txt)
  close:SetSize(36, 36)
  close:SetPos(w - 44, 10)
  close.Paint = function(s, bw, bh)
    draw.RoundedBox(8, 0, 0, bw, bh, s:IsHovered() and panelHover or panel)
  end
  close.DoClick = function() frame:Remove() end

  local list = frame:Add("DScrollPanel")
  list:SetPos(16, 94)
  list:SetSize(w - 32, h - 194)

  for _, info in ipairs(actions) do
    local b = list:Add("DButton")
    b:Dock(TOP)
    b:DockMargin(0, 0, 0, 8)
    b:SetTall(66)
    b:SetText("")
    b.Paint = function(s, bw, bh)
      draw.RoundedBox(10, 0, 0, bw, bh, s:IsHovered() and panelHover or panel)
      draw.RoundedBox(8, 0, 0, 6, bh, accent)
      draw.SimpleText(info.name, "SRVRRP.Mega.Button", 18, 20, txt)
      draw.SimpleText(info.desc, "SRVRRP.Mega.Subtitle", 18, 44, subTxt)
    end
    b.DoClick = function()
      runCommand(info.kind, info.value)
      surface.PlaySound("buttons/button15.wav")
    end
  end

  local footer = frame:Add("DPanel")
  footer:SetPos(16, h - 90)
  footer:SetSize(w - 32, 74)
  footer.Paint = function(_, fw, fh)
    draw.RoundedBox(10, 0, 0, fw, fh, panel)
    local idx = math.floor(CurTime() / 8) % #tips + 1
    draw.SimpleText("TIP", "SRVRRP.Mega.Button", 12, 10, accent)
    draw.SimpleText(tips[idx], "SRVRRP.Mega.Subtitle", 12, 42, subTxt)
  end
end

net.Receive("srvrrp_mega_update_open_hub", createHub)
net.Receive("srvrrp_mega_update_tip", function()
  notification.AddLegacy(net.ReadString(), NOTIFY_HINT, 7)
  surface.PlaySound("buttons/button14.wav")
end)

concommand.Add("srvrrp_hub", createHub)

hook.Add("PlayerButtonDown", "srvrrp_mega_update_f6_shortcut", function(_, button)
  if button ~= KEY_F6 then return end
  if gui.IsGameUIVisible() then return end
  createHub()
end)
