-- player meta stuff
local PLAYER = FindMetaTable("Player")

function PLAYER:UPSOwnsParty()
    return (UltimatePartySystem.Parties[self:SteamID64()] != nil) -- much better
end

function PLAYER:UPSIsInParty()
    -- Unsure if this function would be a problem for a performance or not. My other solution is to have a table that stores user's steamid64's as keys and party owner steamids in the value but that seems unnessasary. If this is a problem lemme know mr curator man and I'll swap it over.
    for k,v in pairs(UltimatePartySystem.Parties) do
        if(v.players[self:SteamID64()]) then return true end
    end

    return self:UPSOwnsParty()
end

function PLAYER:UPSGetPartyID()
    if(!self:UPSIsInParty()) then return end

    if(self:UPSOwnsParty()) then
        return self:SteamID64()
    end

    for k,v in pairs(UltimatePartySystem.Parties) do
        if(!v.players[self:SteamID64()]) then continue end
        return k
    end

    return
end
function PLAYER:UPSGetPartyTable()
    if(!self:UPSIsInParty()) then return end

    if(self:UPSOwnsParty()) then
        return UltimatePartySystem.Parties[self:SteamID64()]
    end

    for k,v in pairs(UltimatePartySystem.Parties) do
        if(!v.players[self:SteamID64()]) then continue end
        return v
    end

    return
end