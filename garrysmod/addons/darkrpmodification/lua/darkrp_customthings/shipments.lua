-- ============================================================
-- DarkRP Custom Shipments / Ammo
-- separate = false → appears in Ammo tab
-- ============================================================

DarkRP.createShipment("Universal Ammo (100 rounds)", {
    model = "models/items/ammocrate_smg1.mdl",
    entity = "brs_universal_ammo",
    price = 100,
    amount = 1,
    separate = false,
    noShip = true,
    ammoType = "pistol",
    amtGiven = 1,
    category = "Other",
})
