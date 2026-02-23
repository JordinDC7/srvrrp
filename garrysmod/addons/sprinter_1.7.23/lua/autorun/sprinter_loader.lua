hook.Add("DarkRPFinishedLoading", "sP:Loading", function()
    if slib and slib.loadFolder then slib.loadFolder("s_printer/", true, {{"s_printer/", "sh_sprinter_config.lua"}}, {{"s_printer/", "sh_sprinter.lua"}, {"s_printer/integration/", "sv_logging.lua"}}) end
    hook.Add("slib:loadedUtils", "sP:Initialize", function() slib.loadFolder("s_printer/", true, {{"s_printer/", "sh_sprinter_config.lua"}}, {{"s_printer/", "sh_sprinter.lua"}, {"s_printer/integration/", "sv_logging.lua"}}) end)
end)