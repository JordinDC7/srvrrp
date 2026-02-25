local playerMeta = FindMetaTable("Player")
function playerMeta:HasActiveUnboxingTrade()
    for k, v in pairs( BRICKS_SERVER.TEMP.UnboxingTrades ) do
		if( k == self:SteamID64() ) then
			for key, val in pairs( v ) do
				if( val.Active ) then
					return true, key, true
				end
			end
		elseif( v[self:SteamID64()] and v[self:SteamID64()].Active ) then
			return true, k, false
		end
	end
	
	return false
end

function playerMeta:HasSentUnboxingTrade()
    for k, v in pairs( BRICKS_SERVER.TEMP.UnboxingTrades ) do
		if( v[self:SteamID64()] ) then
			return true
		end
	end
	
	return false
end

function playerMeta:GetUnboxingTradeTable( partnerSteamID64, partnerIsSender )
	local selfSteamID64 = self:SteamID64()
	if( partnerIsSender ) then
		if( BRICKS_SERVER.TEMP.UnboxingTrades[selfSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[selfSteamID64][partnerSteamID64] ) then
			return BRICKS_SERVER.TEMP.UnboxingTrades[selfSteamID64][partnerSteamID64]
		end
	else
		if( BRICKS_SERVER.TEMP.UnboxingTrades[partnerSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[partnerSteamID64][selfSteamID64] ) then
			return BRICKS_SERVER.TEMP.UnboxingTrades[partnerSteamID64][selfSteamID64]
		end
	end

	return false
end

function playerMeta:GetUnboxingTradeHasContents( partnerSteamID64, partnerIsSender )
	local tradeTable = self:GetUnboxingTradeTable( partnerSteamID64, partnerIsSender )

	if( table.Count( tradeTable.SenderItems ) > 0 or table.Count( tradeTable.ReceiverItems ) > 0 or table.Count( tradeTable.SenderCurrencies ) > 0 or table.Count( tradeTable.ReceiverCurrencies ) > 0 ) then
		return true
	end

	return false
end