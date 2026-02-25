--[[
    DIAGNOSTIC VERSION - Testing if file loads + panel detection
]]--
if not CLIENT then return end

print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("[BRS UW] CLIENT FILE IS LOADING!")
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

-- Try to hook panels repeatedly and report what happens
local attempts = 0
timer.Create("BRS_UW_DIAG", 2, 0, function()
    attempts = attempts + 1

    local SLOT = vgui.GetControlTable("bricks_server_unboxingmenu_itemslot")
    local INV = vgui.GetControlTable("bricks_server_unboxingmenu_inventory")

    if attempts <= 30 or (attempts % 30 == 0) then
        print("[BRS UW DIAG] Attempt " .. attempts .. 
            " | itemslot=" .. tostring(SLOT ~= nil) .. 
            " | inventory=" .. tostring(INV ~= nil) ..
            " | BRICKS_SERVER=" .. tostring(BRICKS_SERVER ~= nil))
    end

    if SLOT then
        print("[BRS UW DIAG] FOUND ITEMSLOT at attempt " .. attempts .. "!")
        print("[BRS UW DIAG] FillPanel exists: " .. tostring(SLOT.FillPanel ~= nil))
        print("[BRS UW DIAG] Paint exists: " .. tostring(SLOT.Paint ~= nil))
        print("[BRS UW DIAG] PaintOver exists: " .. tostring(SLOT.PaintOver ~= nil))

        -- List all methods on the panel
        local methods = {}
        for k, v in pairs(SLOT) do
            if isfunction(v) then table.insert(methods, k) end
        end
        table.sort(methods)
        print("[BRS UW DIAG] Methods: " .. table.concat(methods, ", "))

        timer.Remove("BRS_UW_DIAG")
    end
end)

concommand.Add("brs_diag", function()
    print("=== BRS DIAGNOSTIC ===")
    print("Attempts so far: " .. attempts)
    print("BRICKS_SERVER: " .. tostring(BRICKS_SERVER ~= nil))
    if BRICKS_SERVER then
        print("  .UNBOXING: " .. tostring(BRICKS_SERVER.UNBOXING ~= nil))
        if BRICKS_SERVER.UNBOXING then
            print("  .Func: " .. tostring(BRICKS_SERVER.UNBOXING.Func ~= nil))
            if BRICKS_SERVER.UNBOXING.Func then
                print("  .GetItemFromGlobalKey: " .. tostring(BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey ~= nil))
            end
        end
        print("  .CONFIG: " .. tostring(BRICKS_SERVER.CONFIG ~= nil))
        if BRICKS_SERVER.CONFIG then
            print("  .CONFIG.UNBOXING: " .. tostring(BRICKS_SERVER.CONFIG.UNBOXING ~= nil))
        end
    end

    local SLOT = vgui.GetControlTable("bricks_server_unboxingmenu_itemslot")
    print("itemslot panel: " .. tostring(SLOT ~= nil))

    -- Also check how many registered bricks panels there are
    local bricksPanels = {}
    if vgui and vgui.GetControlTable then
        -- We can't enumerate all panels, but try common names
        local names = {
            "bricks_server_unboxingmenu_itemslot",
            "bricks_server_unboxingmenu_inventory",
            "bricks_server_unboxingmenu",
            "bricks_server_unboxingmenu_home",
            "bricks_server_unboxingmenu_store",
            "bricks_server_raritybox",
            "bricks_server_unboxing_itemdisplay",
        }
        for _, n in ipairs(names) do
            local exists = vgui.GetControlTable(n) ~= nil
            print("  " .. n .. ": " .. tostring(exists))
        end
    end
    print("======================")
end)
