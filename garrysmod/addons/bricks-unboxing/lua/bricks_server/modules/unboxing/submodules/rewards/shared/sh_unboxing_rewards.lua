local playerMeta = FindMetaTable("Player")
function playerMeta:GetUnboxingRewardsClaimed()
	if( SERVER ) then
		return self.BRS_UNBOXING_REWARDSCLAIMED or {}
	elseif( CLIENT ) then
		if( self == LocalPlayer() ) then
			return BRS_UNBOXING_REWARDSCLAIMED or {}
		else
			return self.BRS_UNBOXING_REWARDSCLAIMED or {}
		end
	end
end

function playerMeta:GetUnboxingRewardsTodayClaimed()
    local claimedTable = self:GetUnboxingRewardsClaimed()
    
    local dataTable = os.date( "*t" )

    if( claimedTable[dataTable.year] and claimedTable[dataTable.year][dataTable.month] and claimedTable[dataTable.year][dataTable.month][dataTable.day] ) then
        return true
    end

    return false
end