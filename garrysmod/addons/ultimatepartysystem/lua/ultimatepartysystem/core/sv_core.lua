util.AddNetworkString("ultimatepartysystem.core.message")
util.AddNetworkString("ultimatepartysystem.core.openui")
util.AddNetworkString("ultimatepartysystem.core.updatepartycache")
util.AddNetworkString("ultimatepartysystem.core.requestpartycache")
-- Creating/Modifying Party
util.AddNetworkString("ultimatepartysystem.core.createparty")
-- General Party Management
util.AddNetworkString("ultimatepartysystem.core.joinparty")
util.AddNetworkString("ultimatepartysystem.core.leaveparty")
util.AddNetworkString("ultimatepartysystem.core.updateparty")
util.AddNetworkString("ultimatepartysystem.core.deleteparty")
util.AddNetworkString("ultimatepartysystem.core.kickplayer")
util.AddNetworkString("ultimatepartysystem.core.partychat")
-- Invites
util.AddNetworkString("ultimatepartysystem.core.inviteplayer")
util.AddNetworkString("ultimatepartysystem.core.invited")
util.AddNetworkString("ultimatepartysystem.core.acceptinvite")
util.AddNetworkString("ultimatepartysystem.core.inviteremoved")
-- Markers
util.AddNetworkString("ultimatepartysystem.core.requestmarkerupdate")
util.AddNetworkString("ultimatepartysystem.core.setmarker")

-- can you tell im bored of commenting this file yet?
function UltimatePartySystem.Core.Message(ply, msg)
    net.Start("ultimatepartysystem.core.message")
    net.WriteString(msg)
    net.Send(ply)
end
function UltimatePartySystem.Core.HandleNetCooldown(ply)
    if(UltimatePartySystem.NetCooldowns[ply:SteamID64()]) then
        if(UltimatePartySystem.NetCooldowns[ply:SteamID64()] > CurTime()) then
            UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("netCooldown"))
            return false
        end
    end

    if(!ply:SteamID64()) then return true end -- Not really sure how else to handle this. This can happen on a client joining so idfk
    UltimatePartySystem.NetCooldowns[ply:SteamID64()] = CurTime() + 0.25
    return true
end

-- chat command
hook.Add("PlayerSay", "ultimatepartysystem.core.playersay", function(ply, text, team)
    if(string.lower(string.sub(text, 1, #UltimatePartySystem.Settings.GetValue("chatCommand"))) != UltimatePartySystem.Settings.GetValue("chatCommand")) then return end

    net.Start("ultimatepartysystem.core.openui")
    net.Send(ply)

    if(UltimatePartySystem.Settings.GetValue("uiMessage")) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("openingWindow"))
    end

    if(UltimatePartySystem.Settings.GetValue("hideChatCommand")) then
        return ""
    end
end)

-- user wants to make a party huh?
net.Receive("ultimatepartysystem.core.createparty", function(len, ply)
    if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

    if(UltimatePartySystem.Parties[ply:SteamID64()]) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyCreationAlreadyOwned"))
        return
    end

    local name = net.ReadString()
    if(#name > UltimatePartySystem.Settings.GetValue("maxNameLength")) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyCreationNameTooLong", UltimatePartySystem.Settings.GetValue("maxNameLength")))
        return
    end

    local priv = false
    if(UltimatePartySystem.Settings.GetValue("allowPrivateParties")) then
        priv = net.ReadBool()
    end
    local slots = net.ReadInt(9)

    if(slots < 2) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyCreationTooLittleSlots"))
        return
    end
    if(slots > UltimatePartySystem.Settings.GetValue("maxSlots")) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyCreationTooManySlots", UltimatePartySystem.Settings.GetValue("maxSlots")))
        return
    end

    if(UltimatePartySystem.Settings.GetValue("partyCreationCost") > 0) then
        if(!ply:canAfford(UltimatePartySystem.Settings.GetValue("partyCreationCost"))) then
            UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyCreationCannotAfford", UltimatePartySystem.Core.FormatMoney(UltimatePartySystem.Settings.GetValue("partyCreationCost"))))
            return
        end

        ply:addMoney(UltimatePartySystem.Settings.GetValue("partyCreationCost") * -1)
    end

    UltimatePartySystem.Core.CreateParty(ply, name, priv, slots)
    UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyCreationSuccessfull", name))
end)

-- create/remove partys
function UltimatePartySystem.Core.CreateParty(owner, name, private, slots)
    local steamid = owner:SteamID64()

    UltimatePartySystem.Parties[steamid] = {
        name = name,
        private = private,
        slots = slots,
        players = {
            [steamid] = owner
        }
    }

    UltimatePartySystem.Core.UpdateClientPartyCache()

    hook.Run("ultimatepartysystem.core.partycreated", owner, name, private, slots)
end
function UltimatePartySystem.Core.RemoveParty(owner)
    for k,v in pairs(UltimatePartySystem.Parties[owner:SteamID64()].players) do
        if(UltimatePartySystem.Settings.GetValue("markerEnable")) then
            net.Start("ultimatepartysystem.core.setmarker")
            net.WriteTable({})
            net.WriteBool(false)
            net.WriteBool(true)
            net.Send(v)
        end

        if(k == owner:SteamID64()) then continue end -- They gets a message anyway.
        UltimatePartySystem.Core.Message(v, UltimatePartySystem.Core.GetLanguage("partyLeaveDisbanded", UltimatePartySystem.Parties[owner:SteamID64()].name))
    end
    UltimatePartySystem.Core.Message(owner, UltimatePartySystem.Core.GetLanguage("partyOwnerPartyDisband", UltimatePartySystem.Parties[owner:SteamID64()].name))

    local name = UltimatePartySystem.Parties[owner:SteamID64()].name -- For the hook

    UltimatePartySystem.Parties[owner:SteamID64()] = nil
    UltimatePartySystem.Core.UpdateClientPartyCache()

    hook.Run("ultimatepartysystem.core.partyremoved", owner, name)
end

-- Client Party Cache
-- I need to do all of this to prevent private parties that aren't related to the client being sent, being a potential security vunerability.
function UltimatePartySystem.Core.UpdateClientPartyCache()
    for k,v in pairs(player.GetAll()) do
        local toSend = {}
        for x,y in pairs(UltimatePartySystem.Parties) do
            if(y.private && x != v:SteamID64()) then
                if(!y.players[v:SteamID64()]) then continue end 
            end
            
            toSend[x] = y
        end

        net.Start("ultimatepartysystem.core.updatepartycache")
        net.WriteTable(toSend)
        net.Send(v)
    end
end

-- Remove the party and player on disconnect
hook.Add("PlayerDisconnected", "ultimatepartysystem.core.playerdisconnect", function(ply)
    -- According to the Wiki, ply:SteamID64() can return nil here. This apparently still needs to be validated, but if it does turn out to be true than i'll swap table indexes to be numberical and just use table.HasValue or something. Really shit solution but fuck it I guess.
    -- https://wiki.facepunch.com/gmod/GM:PlayerDisconnected https://upload.livaco.dev/u/25gxqbEm03.png

    if(ply:UPSOwnsParty()) then
        UltimatePartySystem.Core.RemoveParty(ply)
        return
    end
    if(ply:UPSIsInParty()) then
        local partyOwner = ply:UPSGetPartyID()
        local party = ply:UPSGetPartyTable()
        party.players[ply:SteamID64()] = nil

        local owner = player.GetBySteamID64(partyOwner)
        UltimatePartySystem.Core.Message(owner, UltimatePartySystem.Core.GetLanguage("partyOwnerPlayerDisconnect", ply:Name()))

        UltimatePartySystem.Core.UpdateClientPartyCache()
    end
end)

-- iNvites
net.Receive("ultimatepartysystem.core.inviteplayer", function(len, ply)
    if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

    if(!ply:UPSOwnsParty()) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyInviteOof"))
        return
    end

    local invited = player.GetBySteamID64(net.ReadString())
    if(!invited) then return end
    if(invited == ply) then return end

    if(invited:UPSIsInParty()) then
        UltimatePartySystem.Core.Message(invited, UltimatePartySystem.Core.GetLanguage("partyInviteAlreadyIn", invited:GetName()))
        return
    end

    UltimatePartySystem.Invites[#UltimatePartySystem.Invites + 1] = {
        invitee = ply,
        invited = invited,
        timeout = CurTime() + UltimatePartySystem.Settings.GetValue("inviteTimeOut")
    }

    net.Start("ultimatepartysystem.core.invited")
    net.WriteString(ply:SteamID64())
    net.WriteTable(ply:UPSGetPartyTable())
    net.Send(invited)
    UltimatePartySystem.Core.Message(invited, UltimatePartySystem.Core.GetLanguage("partyInvited", ply:GetName(), ply:UPSGetPartyTable().name))

    for k,v in pairs(ply:UPSGetPartyTable().players) do
        UltimatePartySystem.Core.Message(v, UltimatePartySystem.Core.GetLanguage("partyInviteDone", ply:GetName(), invited:GetName()))
    end
end)
net.Receive("ultimatepartysystem.core.inviteremoved", function(len, ply)
    if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

    local owner = player.GetBySteamID64(net.ReadString())
    if(!owner) then return end

    for k,v in pairs(UltimatePartySystem.Invites) do
        if(v.invited != ply) then continue end
        if(v.invitee != owner) then continue end

        UltimatePartySystem.Core.Message(owner, UltimatePartySystem.Core.GetLanguage("partyInviteTimeoutOwner", v.invited:GetName()))
        UltimatePartySystem.Invites[k] = nil
        break
    end
end)

-- Joining stuff
function UltimatePartySystem.Core.JoinParty(ply, ownerSID)
    if(ply:UPSIsInParty()) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyJoinAlreadyIn"))
        return
    end

    local owner = net.ReadString()
    local party = UltimatePartySystem.Parties[ownerSID]
    if(!party) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyJoinDoesNotExist"))
        return
    end
    if(!party.players[ownerSID]) then
        -- uhhhhhhh yeah this should be impossible but im adding a check anyway since the addon will cause a hissy fit later if this isn't checked
        UltimatePartySystem.Parties[ownerSID] = nil

        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyJoinDoesNotExist"))
        return
    end

    if(#party.players >= party.slots) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyJoinIsFull"))
        return
    end

    party.players[ply:SteamID64()] = ply

    UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyJoinSuccess", party.name))
    UltimatePartySystem.Core.Message(party.players[ownerSID], UltimatePartySystem.Core.GetLanguage("partyOwnerPlayerJoin", ply:Name()))

    UltimatePartySystem.Core.UpdateClientPartyCache()

    hook.Run("ultimatepartysystem.core.joinparty", ply, ownerSID, party)
end

-- Accepting invites (joining)
net.Receive("ultimatepartysystem.core.acceptinvite", function(len, ply)
    if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

    local ownerSID = net.ReadString()
    -- whoops
    -- ownerSID = "76561199117690551"
    UltimatePartySystem.Core.JoinParty(ply, ownerSID)

    local owner = player.GetBySteamID64(ownerSID)
    if(!owner) then return end
    for k,v in pairs(UltimatePartySystem.Invites) do
        if(v.invited != ply) then continue end
        if(v.invitee != owner) then continue end

        UltimatePartySystem.Invites[k] = nil
        break
    end
end)

-- Joining
net.Receive("ultimatepartysystem.core.joinparty", function(len, ply)
    if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

    UltimatePartySystem.Core.JoinParty(ply, net.ReadString())
end)

-- Leaving
net.Receive("ultimatepartysystem.core.leaveparty", function(len, ply)
    if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

    if(!ply:UPSIsInParty()) then return end
    if(ply:UPSOwnsParty()) then return end

    local owner = ply:UPSGetPartyID()
    local party = UltimatePartySystem.Parties[owner]
    party.players[ply:SteamID64()] = nil

    UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyLeaveSuccess", party.name))
    UltimatePartySystem.Core.Message(party.players[owner], UltimatePartySystem.Core.GetLanguage("partyOwnerPlayerLeave", ply:Name()))

    hook.Run("ultimatepartysystem.core.leaveparty", ply, owner, party)

    if(!UltimatePartySystem.Settings.GetValue("markerEnable")) then return end
    for k,v in pairs(party.players) do
        net.Start("ultimatepartysystem.core.setmarker")
        net.WriteTable({
            ply = ply
        })
        net.WriteBool(false)
        net.WriteBool(false)
        net.Send(v)
    end

    net.Start("ultimatepartysystem.core.setmarker")
    net.WriteTable({})
    net.WriteBool(false)
    net.WriteBool(true)
    net.Send(ply)

    UltimatePartySystem.Core.UpdateClientPartyCache()
end)

-- Updating partys
net.Receive("ultimatepartysystem.core.updateparty", function(len, ply)
    if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

    if(!ply:UPSOwnsParty()) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyOwnerEditOof"))
        return
    end

    local tbl = ply:UPSGetPartyTable() -- We can assume it's the players own party since it's kinda impossible to see the settings otherwise.

    local newName = net.ReadString()
    if(#newName > UltimatePartySystem.Settings.GetValue("maxNameLength")) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyCreationNameTooLong", UltimatePartySystem.Settings.GetValue("maxNameLength")))
        return
    end

    local private = false
    if(UltimatePartySystem.Settings.GetValue("allowPrivateParties")) then
        private = net.ReadBool()
    end
    local slots = net.ReadInt(9)
    if(slots < 2) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyCreationTooLittleSlots"))
        return
    end
    if(slots > UltimatePartySystem.Settings.GetValue("maxSlots")) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyCreationTooManySlots", UltimatePartySystem.Settings.GetValue("maxSlots")))
        return
    end
    if(slots < table.Count(tbl.players)) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyOwnerEditNotEnoughSlotsForPlayers"))
        return
    end

    tbl.name = newName
    tbl.private = private
    tbl.slots = slots
    UltimatePartySystem.Core.UpdateClientPartyCache()

    UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyOwnerEditSuccess"))
end)

-- Deleting party
net.Receive("ultimatepartysystem.core.deleteparty", function(len, ply)
    if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

    if(!ply:UPSOwnsParty()) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyOwnerDeleteOof"))
        return
    end

    UltimatePartySystem.Core.RemoveParty(ply)
end)

-- Markers. I relay them through serverside because I don't want clients just directly messaging other clients giving each other markers.
net.Receive("ultimatepartysystem.core.requestmarkerupdate", function(len, ply)
    if(!UltimatePartySystem.Settings.GetValue("markerEnable")) then return end
    if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

    if(!ply:UPSIsInParty()) then return end

    local tbl = net.ReadTable()
    local state = net.ReadBool()
    for k,v in pairs(ply:UPSGetPartyTable().players) do
        if(v == ply) then continue end

        net.Start("ultimatepartysystem.core.setmarker")
        net.WriteTable(tbl)
        net.WriteBool(state)
        net.Send(v)
    end
end)

-- Kicking players.
net.Receive("ultimatepartysystem.core.kickplayer", function(len, ply)
    if(!UltimatePartySystem.Core.HandleNetCooldown(ply)) then return end

    if(!ply:UPSOwnsParty()) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyOwnerKickOof"))
        return
    end

    local kicked = player.GetBySteamID64(net.ReadString())
    if(!kicked) then
        UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyOwnerKickNotFound"))
        return
    end

    if(!kicked:UPSIsInParty()) then return end
    if(kicked:UPSOwnsParty()) then return end

    local owner = ply:UPSGetPartyID()
    local party = UltimatePartySystem.Parties[owner]
    party.players[kicked:SteamID64()] = nil

    UltimatePartySystem.Core.Message(ply, UltimatePartySystem.Core.GetLanguage("partyOwnerPlayerKicked", kicked:Name()))
    UltimatePartySystem.Core.Message(kicked, UltimatePartySystem.Core.GetLanguage("partyLeaveFromKicked", party.name))

    hook.Run("ultimatepartysystem.core.playerkicked", kicked, ply, party)

    if(!UltimatePartySystem.Settings.GetValue("markerEnable")) then return end
    for k,v in pairs(party.players) do
        net.Start("ultimatepartysystem.core.setmarker")
        net.WriteTable({
            ply = kicked
        })
        net.WriteBool(false)
        net.Send(v)
    end
    UltimatePartySystem.Core.UpdateClientPartyCache()
end)

net.Receive("ultimatepartysystem.core.requestpartycache", function(len, ply)
    local toSend = {}
    for x,y in pairs(UltimatePartySystem.Parties) do
        if(y.private && x != ply:SteamID64()) then continue end

        toSend[x] = y
    end

    net.Start("ultimatepartysystem.core.updatepartycache")
    net.WriteTable(toSend)
    net.Send(ply)
end)

-- Friendly Fire
hook.Add("PlayerShouldTakeDamage", "ultimatepartysystem.core.friendlyfire", function(victim, attacker)
    if(UltimatePartySystem.Settings.GetValue("enableFriendlyFire")) then return end
    if(!victim) then return end
    if(!attacker) then return end
    if(attacker == Entity(0)) then return end
    if(!attacker:IsPlayer()) then return end 
    if(!victim:IsPlayer()) then return end 
    if(!victim:UPSIsInParty()) then return end
    if(!attacker:UPSIsInParty()) then return end
    if(attacker == victim) then return end 

    return victim:UPSGetPartyID() != attacker:UPSGetPartyID()
end)

-- Party Chat
hook.Add("PlayerSay", "ultimatepartysystem.core.partychathook", function(ply, text, team)
    if(!UltimatePartySystem.Settings.GetValue("enablePartyChat")) then return end
    if(!ply:UPSIsInParty()) then return end
    if(string.lower(string.sub(text, 1, #UltimatePartySystem.Settings.GetValue("partyChatCommand"))) != UltimatePartySystem.Settings.GetValue("partyChatCommand")) then return end

    local msg = string.sub(text, #UltimatePartySystem.Settings.GetValue("partyChatCommand") + 1)

    for k,v in pairs(ply:UPSGetPartyTable().players) do
        -- UltimatePartySystem.Core.Message(v, UltimatePartySystem.Core.GetLanguage("partyChatPrefix", ply:Name()) .. msg)
        net.Start("ultimatepartysystem.core.partychat")
        net.WriteString(UltimatePartySystem.Core.GetLanguage("partyChatPrefix", ply:Name()) .. msg)
        net.Send(v)
    end

    return ""
end)