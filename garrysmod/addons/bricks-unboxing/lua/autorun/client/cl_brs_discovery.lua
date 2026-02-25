--[[
    ONE-TIME DISCOVERY TOOL
    Run brs_discover in client console with the unboxing menu INVENTORY tab open
    Dumps every property on every panel so we know how to hook in
]]--
if not CLIENT then return end

concommand.Add("brs_discover", function()
    print("\n\n========== BRS DEEP PANEL DISCOVERY ==========")

    local function DumpPanel(panel, depth, maxDepth)
        if not IsValid(panel) then return end
        if depth > maxDepth then return end

        local indent = string.rep("  ", depth)
        local cls = panel:GetClassName()
        local w, h = panel:GetSize()
        local tbl = panel:GetTable()

        -- Count non-function properties
        local props = {}
        for k, v in pairs(tbl) do
            if not isfunction(v) then
                props[k] = v
            end
        end

        -- Always print panels with interesting class names or sufficient size at low depth
        local isInteresting = string.find(cls, "ricks") or string.find(cls, "nboxing") or string.find(cls, "lot") or string.find(cls, "nventory")
        local hasProps = table.Count(props) > 4

        if isInteresting or (hasProps and depth <= 4) or (depth <= 2 and w > 100) then
            print(indent .. cls .. " [" .. math.floor(w) .. "x" .. math.floor(h) .. "] props=" .. table.Count(props))

            for k, v in SortedPairs(props) do
                -- Skip boring defaults
                if k == "Hovered" or k == "m_bDraggable" or k == "m_bSizable" or k == "m_bScreenClamp"
                   or k == "m_iMinWidth" or k == "m_iMinHeight" or k == "m_bIsMenuComponent"
                   or k == "m_bDeleteOnClose" or k == "m_bPaintBackground" or k == "Depressed" then
                    continue
                end

                local valStr
                if istable(v) then
                    -- Dump table contents (first 10 keys)
                    local entries = {}
                    local n = 0
                    for k2, v2 in pairs(v) do
                        n = n + 1
                        if n <= 10 then
                            local vs = tostring(v2)
                            if istable(v2) then
                                -- Go one level deeper for nested tables
                                local inner = {}
                                local m = 0
                                for k3, v3 in pairs(v2) do
                                    m = m + 1
                                    if m <= 6 then
                                        table.insert(inner, tostring(k3) .. "=" .. string.sub(tostring(v3), 1, 25))
                                    end
                                end
                                vs = "TABLE{" .. table.concat(inner, ", ") .. "}"
                            else
                                vs = string.sub(vs, 1, 40)
                            end
                            table.insert(entries, tostring(k2) .. "=" .. vs)
                        end
                    end
                    valStr = "TABLE(" .. n .. ") {" .. table.concat(entries, ", ") .. "}"
                elseif IsValid(v) then
                    valStr = "PANEL<" .. v:GetClassName() .. ">"
                elseif ispanel(v) then
                    valStr = "PANEL(invalid)"
                else
                    valStr = string.sub(tostring(v), 1, 60)
                end

                print(indent .. "  ." .. tostring(k) .. " = " .. valStr)
            end
        end

        for _, child in ipairs(panel:GetChildren()) do
            DumpPanel(child, depth + 1, maxDepth)
        end
    end

    local found = 0
    for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
        if IsValid(panel) and panel:IsVisible() then
            local w, h = panel:GetSize()
            if w > 400 and h > 250 then
                found = found + 1
                print("\n--- TOP LEVEL #" .. found .. ": " .. panel:GetClassName() .. " [" .. math.floor(w) .. "x" .. math.floor(h) .. "] ---")
                DumpPanel(panel, 0, 6)
            end
        end
    end

    if found == 0 then
        print("NO LARGE PANELS FOUND - Is the unboxing menu open?")
    end

    print("========== END DISCOVERY ==========\n")
end)

print("[BRS] Discovery tool loaded - type brs_discover in console with menu open")
