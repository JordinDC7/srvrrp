local playerMeta = FindMetaTable("Player")
function playerMeta:GetUnboxingMarketplaceSlots()
	if( SERVER ) then
		return self.BRS_UNBOXING_MARKETPLACESLOTS or {}
	elseif( CLIENT ) then
		if( self == LocalPlayer() ) then
			return BRS_UNBOXING_MARKETPLACESLOTS or {}
		else
			return self.BRS_UNBOXING_MARKETPLACESLOTS or {}
		end
	end
end