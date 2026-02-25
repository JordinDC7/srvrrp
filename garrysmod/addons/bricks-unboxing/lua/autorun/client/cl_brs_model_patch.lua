-- ============================================================
-- AUTO-POPULATE WEAPON MODELS FOR BRICKS UNBOXING ITEMS
-- Fixes ERROR models when items are created via config files
-- instead of through the admin UI
-- ============================================================

if ( SERVER ) then return end

local function PatchWeaponModels()
    if ( not BRICKS_SERVER or not BRICKS_SERVER.CONFIG or not BRICKS_SERVER.CONFIG.UNBOXING ) then
        return false
    end

    local items = BRICKS_SERVER.CONFIG.UNBOXING.Items
    if ( not items ) then return false end

    local patched = 0
    local failed = 0

    for id, itemTable in pairs( items ) do
        if ( itemTable.Type == "PermWeapon" or itemTable.Type == "Weapon" ) then
            if ( not itemTable.Model or itemTable.Model == "" or itemTable.Model == "error.mdl" ) then
                local weaponClass = itemTable.ReqInfo and itemTable.ReqInfo[1]
                if ( weaponClass ) then
                    -- Try weapons.Get first
                    local wepTable = weapons.Get( weaponClass )
                    if ( wepTable and wepTable.WorldModel and wepTable.WorldModel ~= "" ) then
                        itemTable.Model = wepTable.WorldModel
                        itemTable.Icon = nil
                        patched = patched + 1
                    else
                        -- Fallback: try weapons.GetStored
                        local storedWep = weapons.GetStored( weaponClass )
                        if ( storedWep and storedWep.WorldModel and storedWep.WorldModel ~= "" ) then
                            itemTable.Model = storedWep.WorldModel
                            itemTable.Icon = nil
                            patched = patched + 1
                        else
                            failed = failed + 1
                        end
                    end
                end
            end
        end
    end

    if ( patched > 0 ) then
        print( "[BRS ModelPatch] Patched " .. patched .. " weapon models" .. ( failed > 0 and ( ", " .. failed .. " failed" ) or "" ) )
    end

    return patched > 0 or failed == 0
end

-- Try multiple times since weapons table and bricks config load at different times
local attempts = 0
local maxAttempts = 30

timer.Create( "BRS_PatchWeaponModels", 1, maxAttempts, function()
    attempts = attempts + 1

    if ( PatchWeaponModels() ) then
        timer.Remove( "BRS_PatchWeaponModels" )
        print( "[BRS ModelPatch] Complete after " .. attempts .. " attempt(s)" )
        return
    end

    if ( attempts >= maxAttempts ) then
        print( "[BRS ModelPatch] Gave up after " .. maxAttempts .. " attempts - BRICKS_SERVER config may not be loaded" )
    end
end )

-- Also run on InitPostEntity as a backup trigger
hook.Add( "InitPostEntity", "BRS_PatchWeaponModels", function()
    timer.Simple( 3, function()
        PatchWeaponModels()
    end )
end )
