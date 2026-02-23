function UltimatePartySystem.Core.Message(msg)
    chat.AddText(UltimatePartySystem.Settings.GetValue("prefixColor"), UltimatePartySystem.Settings.GetValue("prefix"), " ", UltimatePartySystem.Settings.GetValue("messageColor"), msg)
end
net.Receive("UltimatePartySystem.core.message", function()
    UltimatePartySystem.Core.Message(net.ReadString())
end)

-- fonts
local boldFonts = {7, 8, 9, 10, 11}
local regularFonts = {7, 8, 9, 10}
for k,v in pairs(boldFonts) do
    surface.CreateFont("ultimatepartysystem.scaled.bold." .. v, {
        font = "Roboto",
        size = ScreenScale(v),
        weight = 650,
        antialasing = true,
        extended = true
    })
end
for k,v in pairs(regularFonts) do
    surface.CreateFont("ultimatepartysystem.scaled." .. v, {
        font = "Roboto",
        size = ScreenScale(v),
        antialasing = true,
        extended = true
    })
end

-- Cache
UltimatePartySystem.Cache.Colors = {}
UltimatePartySystem.Cache.Colors.SlightGray = Color(35, 35, 35)
UltimatePartySystem.Cache.Colors.SlightlyDarkerGray = Color(20, 20, 20)
UltimatePartySystem.Cache.Colors.SlightlyIDKDarkerGray = Color(22, 22, 22)
UltimatePartySystem.Cache.Colors.SlightlyLighterDarkerGray = Color(25, 25, 25)
UltimatePartySystem.Cache.Colors.LightSlightlyLighterDarkerGray = Color(26, 26, 26)
UltimatePartySystem.Cache.Colors.FiftyShadesOfGray = Color(28, 28, 28)
UltimatePartySystem.Cache.Colors.AnotherFuckingGray = Color(35, 35, 35)
UltimatePartySystem.Cache.Colors.LightRed = Color(255, 50, 50)
UltimatePartySystem.Cache.Colors.Gray = Color(50, 50, 50)
UltimatePartySystem.Cache.Colors.LightGray = Color(175, 175, 175)
UltimatePartySystem.Cache.Colors.ImRunningOutOfFunnyVarNames = Color(200, 200, 200)

UltimatePartySystem.Cache.Materials = {}
UltimatePartySystem.Cache.Materials.Cross = Material("livaco/ultimatepartysystem/cross.png")
UltimatePartySystem.Cache.Materials.CircleyBoi = Material("livaco/ultimatepartysystem/circley_boi.png")
UltimatePartySystem.Cache.Materials.Wrench = Material("livaco/ultimatepartysystem/wrench.png")
UltimatePartySystem.Cache.Materials.GroupIcon = Material("livaco/ultimatepartysystem/group.png")
UltimatePartySystem.Cache.Materials.Microphone = Material("livaco/ultimatepartysystem/microphone.png")
UltimatePartySystem.Cache.Materials.MutedMicrophone = Material("livaco/ultimatepartysystem/muted_microphone.png")
UltimatePartySystem.Cache.Materials.Arrow = Material("livaco/ultimatepartysystem/arrow.png")

net.Receive("ultimatepartysystem.core.updatepartycache", function()
    UltimatePartySystem.Parties = net.ReadTable()
end)
hook.Add("InitPostEntity", "ultimatepartysystem.core.initcache", function()
    net.Start("ultimatepartysystem.core.requestpartycache")
    net.SendToServer()
end)

-- Party Invites
net.Receive("ultimatepartysystem.core.invited", function()
    local id = net.ReadString()
    local partyInfo = net.ReadTable()

    UltimatePartySystem.Invites[id] = {
        party = partyInfo,
        timeout = CurTime() + UltimatePartySystem.Settings.GetValue("inviteTimeOut")
    }
end)
-- [MEGA UPDATE PATCH] Keep invite timeout loop cheap/safe and avoid nil name errors.
timer.Create("ultimatepartysystem.core.invitetimeout", 1, 0, function()
    for k,v in pairs(UltimatePartySystem.Invites) do
        if(v.timeout > CurTime()) then continue end

        UltimatePartySystem.Invites[k] = nil
        net.Start("ultimatepartysystem.core.inviteremoved")
        net.WriteString(k)
        net.SendToServer()

        local ownerPly = player.GetBySteamID64(k)
        local ownerName = IsValid(ownerPly) and ownerPly:Name() or "Party Owner"
        UltimatePartySystem.Core.Message(UltimatePartySystem.Core.GetLanguage("partyInviteTimeout", ownerName))
    end
end)

-- A few other helper funcs
function UltimatePartySystem.Core.DrawCircle(x, y, radius, quality)
    local cir = {}
    for i=1,quality do
        local rad = math.rad(i * 360) / quality
        cir[i] = {x = x + math.cos(rad) * radius, y = y + math.sin(rad) * radius}
    end

    draw.NoTexture()
    surface.DrawPoly(cir)
end

-- Party Chat
net.Receive("ultimatepartysystem.core.partychat", function()
    if(!UltimatePartySystem.ClientSettings.GetValue("displayPartyChat")) then return end
    UltimatePartySystem.Core.Message(net.ReadString())
end)