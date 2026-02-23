-- [MEGA UPDATE PATCH] Unified UX hub, onboarding, and safety/performance helpers.

if SERVER then
  util.AddNetworkString("srvrrp_mega_update_open_hub")
  util.AddNetworkString("srvrrp_mega_update_tip")
  util.AddNetworkString("srvrrp_mega_update_daily_brief")

  local commandCooldowns = {}
  local spawnTipPool = {
    "Pro tip: Use /hub to quickly jump into inventory, gangs, and party systems.",
    "Money loop: Group with party + gang members for safer high-value runs.",
    "Reminder: /systems prints a full list of core progression systems in chat.",
    "Need support? Use @ in chat to contact staff and explain your issue clearly."
  }

  local dailyBriefPool = {
    "Focus objective: stack legal income first, then scale into risky systems once geared.",
    "Territory pressure works best when your gang rotates players between money and defense.",
    "Convert spare profits into utility items before gambling-heavy spending.",
    "Use downtime between raids to sort inventory and prep quick-access loadouts."
  }

  local function canUseCommand(ply, key, cd)
    if not IsValid(ply) then return false end
    commandCooldowns[ply] = commandCooldowns[ply] or {}

    local now = CurTime()
    local nextUse = commandCooldowns[ply][key] or 0
    if nextUse > now then
      local remaining = math.ceil(nextUse - now)
      ply:ChatPrint("[Server] Command cooldown: " .. remaining .. "s")
      return false
    end

    commandCooldowns[ply][key] = now + cd
    return true
  end

  local function openHub(ply)
    if not IsValid(ply) then return end
    net.Start("srvrrp_mega_update_open_hub")
    net.Send(ply)
  end

  local function sendDailyBrief(ply)
    if not IsValid(ply) then return end
    local idx = ((os.date("%j") or 1) % #dailyBriefPool) + 1
    net.Start("srvrrp_mega_update_daily_brief")
    net.WriteString(dailyBriefPool[idx])
    net.Send(ply)
  end

  hook.Add("PlayerDisconnected", "srvrrp_mega_update_cleanup_cooldowns", function(ply)
    commandCooldowns[ply] = nil
  end)

  hook.Add("PlayerSay", "srvrrp_mega_update_chat_commands", function(ply, text)
    local msg = string.Trim(string.lower(text or ""))
    if msg == "!hub" or msg == "/hub" or msg == "!menu" or msg == "/menu" then
      if not canUseCommand(ply, "hub", 2) then return "" end
      openHub(ply)
      return ""
    end

    if msg == "!systems" or msg == "/systems" then
      ply:ChatPrint("[Server] Systems: F4 (jobs/shop), inventory, gangs, unboxing, casino, grow op, botnet, scratchcards, party.")
      ply:ChatPrint("[Server] Use /hub for the quick launcher.")
      return ""
    end

    if msg == "!brief" or msg == "/brief" then
      if not canUseCommand(ply, "brief", 6) then return "" end
      sendDailyBrief(ply)
      return ""
    end

    if msg == "!staff" or msg == "/staff" then
      if not canUseCommand(ply, "staff", 4) then return "" end
      local staffOnline = 0
      for _, target in ipairs(player.GetAll()) do
        if IsValid(target) and (target:IsAdmin() or target:IsSuperAdmin()) then
          staffOnline = staffOnline + 1
        end
      end

      ply:ChatPrint("[Server] Staff online: " .. staffOnline)
      return ""
    end

    if msg == "!boosts" or msg == "/boosts" then
      if not canUseCommand(ply, "boosts", 6) then return "" end
      ply:ChatPrint("[Boost Guide] Pair party + gang for safer runs and objective stacking.")
      ply:ChatPrint("[Boost Guide] Reinvest early income into utility and defense, not pure luck systems.")
      ply:ChatPrint("[Boost Guide] Use /brief for today's strategy pulse.")
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

    timer.Simple(16, function()
      if not IsValid(ply) then return end
      local tipIdx = math.random(#spawnTipPool)
      net.Start("srvrrp_mega_update_tip")
      net.WriteString(spawnTipPool[tipIdx])
      net.Send(ply)
    end)

    timer.Simple(24, function()
      sendDailyBrief(ply)
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
    ["keypad_cracker"] = true,
    ["material"] = true,
    ["paint"] = true
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
  { name = "Systems Help", desc = "Show quick system guide in chat", kind = "say", value = "/systems" },
  { name = "Daily Brief", desc = "Receive today's strategy pulse", kind = "say", value = "/brief" },
  { name = "Staff Online", desc = "Check active staff count", kind = "say", value = "/staff" },
  { name = "Boost Guide", desc = "Print progression optimization tips", kind = "say", value = "/boosts" }
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

  local search = frame:Add("DTextEntry")
  search:SetPos(16, 94)
  search:SetSize(w - 32, 34)
  search:SetPlaceholderText("Search actions (inventory, gangs, party, brief, staff...)")
  search:SetUpdateOnType(true)

  list:SetPos(16, 136)
  list:SetSize(w - 32, h - 236)

  local buttons = {}

  local function refreshFilter()
    local needle = string.Trim(string.lower(search:GetValue() or ""))
    for _, entry in ipairs(buttons) do
      local hay = string.lower(entry.info.name .. " " .. entry.info.desc)
      local visible = needle == "" or string.find(hay, needle, 1, true) ~= nil
      entry.btn:SetVisible(visible)
      entry.btn:SetTall(visible and 66 or 0)
      entry.btn:SetDockMargin(0, 0, 0, visible and 8 or 0)
    end

    list:InvalidateLayout(true)
  end

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

    buttons[#buttons + 1] = {
      btn = b,
      info = info
    }
  end

  search.OnValueChange = refreshFilter
  refreshFilter()

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

net.Receive("srvrrp_mega_update_daily_brief", function()
  notification.AddLegacy("[Daily Brief] " .. net.ReadString(), NOTIFY_GENERIC, 8)
  surface.PlaySound("buttons/button17.wav")
end)

concommand.Add("srvrrp_hub", createHub)

hook.Add("PlayerButtonDown", "srvrrp_mega_update_f6_shortcut", function(_, button)
  if button ~= KEY_F6 then return end
  if gui.IsGameUIVisible() then return end
  createHub()
end)
