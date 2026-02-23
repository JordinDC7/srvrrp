if SERVER and not __invokephysgunscript__ then
    ErrorNoHalt("Physgun Utils not detected. This addon will only run on Physgun servers. If you think this is a error, please contact support.")
    return
end

XeninInventory = XeninInventory || {}

local function Load()
  XeninUI.Loader():setName("Xenin Inventory"):setAcronym("XeninInv"):setDirectory("inventory"):setColor(XeninUI.Theme.Blue):loadFile("classes/database", XENINUI_SERVER):load("classes", XENINUI_SHARED, true):load("entities", XENINUI_SHARED):loadFile("essentials/helper", XENINUI_SHARED):loadFile("essentials/player", XENINUI_SERVER):loadFile("essentials/languages", XENINUI_SHARED):load("essentials", XENINUI_CLIENT):load("languages", XENINUI_SHARED):load("configuration", XENINUI_SHARED, true):load("importer", XENINUI_SHARED, true):loadFile("networking/inventory_server", XENINUI_SERVER):loadFile("networking/inventory_client", XENINUI_CLIENT):load("ui", XENINUI_CLIENT, true):done()

  XeninInventory.FinishedLoading = true
end

if XeninUI then
  Load()
else
  hook.Add("XeninUI.Loaded", "XeninInventory", Load)
end

if SERVER then
  resource.AddFile("resource/fonts/Montserrat-Bold.ttf")
  resource.AddFile("resource/fonts/Montserrat-Regular.ttf")

  resource.AddWorkshop("1900562881")
  resource.AddWorkshop("1902931848")
end
