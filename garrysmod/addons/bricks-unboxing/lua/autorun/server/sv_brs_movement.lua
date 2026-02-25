-- ============================================================
-- Movement Speed Enforcement
-- Ensures players always get proper speed, even if DarkRP
-- config doesn't load or gets overridden
-- ============================================================

local WALK_SPEED = 250
local RUN_SPEED = 500

hook.Add("PlayerSpawn", "BRS_EnforceMovementSpeed", function(ply)
    timer.Simple(0.1, function()
        if not IsValid(ply) then return end
        
        -- Only override if speed is at DarkRP's sluggish defaults
        if ply:GetWalkSpeed() < WALK_SPEED then
            ply:SetWalkSpeed(WALK_SPEED)
        end
        if ply:GetRunSpeed() < RUN_SPEED then
            ply:SetRunSpeed(RUN_SPEED)
        end
    end)
end)

-- Also enforce on initial spawn
hook.Add("PlayerInitialSpawn", "BRS_EnforceMovementSpeedInit", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        if ply:GetWalkSpeed() < WALK_SPEED then
            ply:SetWalkSpeed(WALK_SPEED)
        end
        if ply:GetRunSpeed() < RUN_SPEED then
            ply:SetRunSpeed(RUN_SPEED)
        end
    end)
end)

print("[BRS] Movement speed enforcement loaded - Walk: " .. WALK_SPEED .. " Run: " .. RUN_SPEED)
