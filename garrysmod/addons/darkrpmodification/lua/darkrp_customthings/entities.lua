-- ============================================================
-- DarkRP Custom Entities
-- These show up in the F4 menu under the Entities tab
-- ============================================================

DarkRP.createEntity("Universal Ammo (100 rounds)", {
    ent = "brs_universal_ammo",
    model = "models/items/ammocrate_smg1.mdl",
    price = 100,
    max = 10,
    cmd = "buyammo",
    category = "Other",
})
