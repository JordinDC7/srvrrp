local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(999)
ITEM:SetModel("models/Items/item_item_crate.mdl")

ITEM:AddUse(function(self, ply, tbl)
	if( CLIENT ) then return true end

	if( BRICKS_SERVER and BRICKS_SERVER.UNBOXING and BRICKS_SERVER.UNBOXING.Func and BRICKS_SERVER.UNBOXING.Func.OpenMenu ) then
		BRICKS_SERVER.UNBOXING.Func.OpenMenu( ply )
	end
end, function(self, ply, slot)
	return true
end)

ITEM:SetDescription(function(self, tbl)
	local itemType = ((tbl.data or {}).Type or "Item")
	local amount = tonumber( tbl.amount or 0 ) or 0

	return {
		itemType,
		"Mirrored from unboxing inventory",
		"Amount: " .. tostring( amount )
	}
end)

function ITEM:GetName(item)
	if( istable( item ) and istable( item.data ) and isstring( item.data.Name ) and item.data.Name != "" ) then
		return item.data.Name
	end

	return "Unboxing Item"
end

function ITEM:GetModel(item)
	if( istable( item ) and istable( item.data ) and isstring( item.data.Model ) and item.data.Model != "" ) then
		return item.data.Model
	end

	return self.Model
end

ITEM:Register("brs_unboxing_item")
