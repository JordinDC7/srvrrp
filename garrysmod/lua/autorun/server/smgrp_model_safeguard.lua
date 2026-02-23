if not SERVER then return end

local cvar = CreateConVar(
    "smgrp_model_safeguard_enable",
    "1",
    FCVAR_ARCHIVE,
    "Replace known broken playermodels with a stable fallback model."
)

local fallbackModel = "models/player/kleiner.mdl"
local blockedModelFragments = {
    "models/captainbigbutt/vocaloid/miku_classic/",
    "models/humans/tyler_the_created/"
}

local function shouldReplaceModel(modelPath)
    if not isstring(modelPath) then return false end

    local normalized = string.lower(modelPath)
    for i = 1, #blockedModelFragments do
        if string.find(normalized, blockedModelFragments[i], 1, true) then
            return true
        end
    end

    return false
end

local function enforceSafeModel(ply)
    if not cvar:GetBool() then return end
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local currentModel = ply:GetModel()
    if not shouldReplaceModel(currentModel) then return end

    ply:SetModel(fallbackModel)

    if DarkRP and DarkRP.notify then
        DarkRP.notify(
            ply,
            1,
            6,
            "Your selected model is currently disabled because its materials are broken on clients."
        )
    end

    print(string.format(
        "[SmG RP] Replaced blocked model '%s' on %s <%s>",
        tostring(currentModel),
        ply:Nick(),
        ply:SteamID()
    ))
end

hook.Add("PlayerSpawn", "SmGRP_ModelSafeguard_PlayerSpawn", function(ply)
    timer.Simple(0, function()
        enforceSafeModel(ply)
    end)
end)
