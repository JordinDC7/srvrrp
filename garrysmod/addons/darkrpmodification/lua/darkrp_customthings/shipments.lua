-- ============================================================
-- DarkRP Custom Ammo Types
-- DarkRP.createAmmoType → appears in the AMMO tab
-- DarkRP.createShipment separate=false → Shipments tab (WRONG)
-- ============================================================

DarkRP.createAmmoType("universal_ammo", {
    name = "Universal Ammo (100 rounds)",
    model = "models/items/ammocrate_smg1.mdl",
    price = 100,
    ammoType = "pistol",
    amountGiven = 1,
    category = "Other",
})
