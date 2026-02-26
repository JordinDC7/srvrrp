-- ============================================================
-- DarkRP Custom Categories
-- ============================================================

DarkRP.createCategory{
    name = "Ammo",
    categorises = "entities",
    startExpanded = true,
    color = Color(255, 200, 60, 255),
    canSee = function(ply) return true end,
    sortOrder = 1,
}
