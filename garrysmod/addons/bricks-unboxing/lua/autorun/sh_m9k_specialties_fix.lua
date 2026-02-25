--[[
    M9K Specialties Fix
    Patches the language.Add error in m9k_mad_c4/shared.lua:171
    "[M9K Specialties] language.Add expects string as second argument!"
    
    This is a known bug in the original M9K Specialties addon.
    We wrap language.Add to silently handle nil second arguments.
]]--

local origLanguageAdd = language.Add
language.Add = function(key, val)
    if key == nil then return end
    if val == nil then val = tostring(key) end
    return origLanguageAdd(key, val)
end

print("[BRS] M9K Specialties language.Add fix loaded")
