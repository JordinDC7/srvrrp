BRICKS_SERVER.TEMP.UnboxingTrades = BRICKS_SERVER.TEMP.UnboxingTrades or {}

local playerMeta = FindMetaTable("Player")
function playerMeta:ChangeUnboxingTradeStatus( type, partnerSteamID64, partnerIsSender, newValue )
    net.Start( (type == "Accept" and "BRS.Net.AcceptUnboxingActiveTradeReturn") or "BRS.Net.ConfirmUnboxingActiveTradeReturn" )
        net.WriteString( partnerSteamID64 )
        net.WriteBool( partnerIsSender )
        net.WriteBool( false )
        net.WriteBool( newValue )
    net.Send( self )

	local partnerPly = player.GetBySteamID64( partnerSteamID64 )
    net.Start( (type == "Accept" and "BRS.Net.AcceptUnboxingActiveTradeReturn") or "BRS.Net.ConfirmUnboxingActiveTradeReturn" )
        net.WriteString( self:SteamID64() )
        net.WriteBool( not partnerIsSender )
        net.WriteBool( true )
        net.WriteBool( newValue )
    net.Send( partnerPly )
end

util.AddNetworkString( "BRS.Net.ClearUnboxingActiveTradeStatus" )
function playerMeta:ClearUnboxingTradeStatus( partnerSteamID64, partnerIsSender )
	local tradeTable = self:GetUnboxingTradeTable( partnerSteamID64, partnerIsSender )

	if( not tradeTable ) then return end

	tradeTable.SenderConfirmed = false
	tradeTable.ReceiverConfirmed = false
	tradeTable.SenderAccepted = false
	tradeTable.ReceiverAccepted = false
	
    net.Start( "BRS.Net.ClearUnboxingActiveTradeStatus" )
        net.WriteString( partnerSteamID64 )
        net.WriteBool( partnerIsSender )
    net.Send( self )

	local partnerPly = player.GetBySteamID64( partnerSteamID64 )
    net.Start( "BRS.Net.ClearUnboxingActiveTradeStatus" )
        net.WriteString( self:SteamID64() )
        net.WriteBool( not partnerIsSender )
    net.Send( partnerPly )
end

util.AddNetworkString( "BRS.Net.CompleteUnboxingActiveTrade" )
function playerMeta:CompleteUnboxingTrade( partnerSteamID64, partnerIsSender )
	local tradeTable = self:GetUnboxingTradeTable( partnerSteamID64, partnerIsSender )

	if( not tradeTable ) then return end

	local senderSteamID64 = (partnerIsSender and partnerSteamID64) or self:SteamID64()
	local receiverSteamID64 = (not partnerIsSender and partnerSteamID64) or self:SteamID64()

	local senderPly, receiverPly = player.GetBySteamID64( senderSteamID64 ), player.GetBySteamID64( receiverSteamID64 )

	if( not IsValid( senderPly ) or not IsValid( receiverPly ) ) then
		return false, BRICKS_SERVER.Func.L( "unboxingInvalidPlayer" )
	end

	-- Checking
	if( table.Count( tradeTable.SenderItems ) > 0 ) then
		local senderInventory = senderPly:GetUnboxingInventory()
		for k, v in pairs( tradeTable.SenderItems ) do
			if( (senderInventory[k] or 0) < v ) then
				return false, BRICKS_SERVER.Func.L( "unboxingSenderNoItems" )
			end
		end
	end

	if( table.Count( tradeTable.ReceiverItems ) > 0 ) then
		local receiverInventory = receiverPly:GetUnboxingInventory()
		for k, v in pairs( tradeTable.ReceiverItems ) do
			if( (receiverInventory[k] or 0) < v ) then
				return false, BRICKS_SERVER.Func.L( "unboxingReceiverNoItems" )
			end
		end
	end

	if( table.Count( tradeTable.SenderCurrencies ) > 0 ) then
		for k, v in pairs( tradeTable.SenderCurrencies ) do
			local devConfigTable = BRICKS_SERVER.DEVCONFIG.Currencies[k]

			if( not devConfigTable ) then return false, BRICKS_SERVER.Func.L( "unboxingSenderCurrencyBad" ) end

			if( devConfigTable.getFunction( senderPly ) < v ) then return false, BRICKS_SERVER.Func.L( "unboxingSenderNoCurrency" ) end
		end
	end

	if( table.Count( tradeTable.ReceiverCurrencies ) > 0 ) then
		for k, v in pairs( tradeTable.ReceiverCurrencies ) do
			local devConfigTable = BRICKS_SERVER.DEVCONFIG.Currencies[k]

			if( not devConfigTable ) then return false, BRICKS_SERVER.Func.L( "unboxingReceiverCurrencyBad" ) end

			if( devConfigTable.getFunction( receiverPly ) < v ) then return false, BRICKS_SERVER.Func.L( "unboxingReceiverNoCurrency" ) end
		end
	end

	-- Adding/Removing
	if( table.Count( tradeTable.SenderItems ) > 0 ) then
		senderPly:RemoveUnboxingInventoryItem( BRICKS_SERVER.UNBOXING.Func.UnpackItemsTable( tradeTable.SenderItems ) )
		receiverPly:AddUnboxingInventoryItem( BRICKS_SERVER.UNBOXING.Func.UnpackItemsTable( tradeTable.SenderItems ) )
	end

	if( table.Count( tradeTable.ReceiverItems ) > 0 ) then
		receiverPly:RemoveUnboxingInventoryItem( BRICKS_SERVER.UNBOXING.Func.UnpackItemsTable( tradeTable.ReceiverItems ) )
		senderPly:AddUnboxingInventoryItem( BRICKS_SERVER.UNBOXING.Func.UnpackItemsTable( tradeTable.ReceiverItems ) )
	end

	if( table.Count( tradeTable.SenderCurrencies ) > 0 ) then
		for k, v in pairs( tradeTable.SenderCurrencies ) do
			local devConfigTable = BRICKS_SERVER.DEVCONFIG.Currencies[k]

			devConfigTable.addFunction( senderPly, -v )
			devConfigTable.addFunction( receiverPly, v )
		end
	end

	if( table.Count( tradeTable.ReceiverCurrencies ) > 0 ) then
		for k, v in pairs( tradeTable.ReceiverCurrencies ) do
			local devConfigTable = BRICKS_SERVER.DEVCONFIG.Currencies[k]

			devConfigTable.addFunction( receiverPly, -v )
			devConfigTable.addFunction( senderPly, v )
		end
	end

	net.Start( "BRS.Net.CompleteUnboxingActiveTrade" )
		net.WriteString( receiverSteamID64 )
		net.WriteBool( false )
	net.Send( senderPly )

	net.Start( "BRS.Net.CompleteUnboxingActiveTrade" )
		net.WriteString( senderSteamID64 )
		net.WriteBool( true )
	net.Send( receiverPly )

	if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] ) then
        BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] = nil
    end

	return true
end

util.AddNetworkString( "BRS.Net.SendUnboxingTrade" )
util.AddNetworkString( "BRS.Net.SendUnboxingTradeReturn" )
net.Receive( "BRS.Net.SendUnboxingTrade", function( len, ply )
	local receiverSteamID64 = net.ReadString()

	if( not receiverSteamID64 ) then return end

    local receiverPly = player.GetBySteamID64( receiverSteamID64 )
    if( receiverPly == ply ) then return end

    if( CurTime() < (ply.BRS_TRADECOOLDOWN or 0) ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingTradeCooldown" ), math.ceil( (ply.BRS_TRADECOOLDOWN or 0)-CurTime() ) )
        return 
    end

	local tradeCooldown = tonumber( ((BRICKS_SERVER.UNBOXING.LUACFG.TopTier or {}).TradeCooldownSeconds) ) or 5
	ply.BRS_TRADECOOLDOWN = CurTime()+math.max( tradeCooldown, 5 )

    if( not IsValid( receiverPly ) ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingPlyNotOnline" ) )
        return
    end

    if( ply:HasSentUnboxingTrade() ) then
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingOneTradeInvite" ) )
        return
    end

    if( BRICKS_SERVER.TEMP.UnboxingTrades[ply:SteamID64()] and BRICKS_SERVER.TEMP.UnboxingTrades[ply:SteamID64()][receiverSteamID64] ) then return end

    if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][ply:SteamID64()] ) then
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingAlreadySentInvite" ) )
        return
    end

    if( not BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] ) then
        BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] = {}
    end

    BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][ply:SteamID64()] = {}

    BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingTradeInviteSent" ) )
    BRICKS_SERVER.Func.SendChatNotification( receiverPly, Color( 26, 188, 156 ), BRICKS_SERVER.Func.L( "unboxingChatTag" ), Color( 255, 255, 255 ), BRICKS_SERVER.Func.L( "unboxingInviteReceived", ply:Nick() ) )

    net.Start( "BRS.Net.SendUnboxingTradeReturn" )
        net.WriteString( ply:SteamID64() )
        net.WriteBool( true )
    net.Send( receiverPly )

    net.Start( "BRS.Net.SendUnboxingTradeReturn" )
        net.WriteString( receiverSteamID64 )
        net.WriteBool( false )
    net.Send( ply )
end )

util.AddNetworkString( "BRS.Net.CancelUnboxingTrade" )
util.AddNetworkString( "BRS.Net.CancelUnboxingTradeReturn" )
net.Receive( "BRS.Net.CancelUnboxingTrade", function( len, ply )
	local receiverSteamID64 = net.ReadString()

	if( not receiverSteamID64 ) then return end

    local receiverPly = player.GetBySteamID64( receiverSteamID64 )

    if( not IsValid( receiverPly ) ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingPlyNotOnline" ) )
        return
    end

    if( not BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] or not BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][ply:SteamID64()] or BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][ply:SteamID64()].Active ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoActiveInvite" ) )
        return
    end

    BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][ply:SteamID64()] = nil

    BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingTradeInviteCancelled" ) )
    BRICKS_SERVER.Func.SendChatNotification( receiverPly, Color( 26, 188, 156 ), BRICKS_SERVER.Func.L( "unboxingChatTag" ), Color( 255, 255, 255 ), BRICKS_SERVER.Func.L( "unboxingCancelledInvite", ply:Nick() ) )

    net.Start( "BRS.Net.CancelUnboxingTradeReturn" )
        net.WriteString( ply:SteamID64() )
        net.WriteBool( true )
    net.Send( receiverPly )

    net.Start( "BRS.Net.CancelUnboxingTradeReturn" )
        net.WriteString( receiverSteamID64 )
        net.WriteBool( false )
    net.Send( ply )
end )

hook.Add( "PlayerDisconnected", "BricksServerHooks_PlayerDisconnected_Trading", function( ply )
    local sPlayerSteamID64 = ply:SteamID64()

    local sFoundReceiver, sFoundSender
    for sTradeReceiver, tTrades in pairs( BRICKS_SERVER.TEMP.UnboxingTrades ) do
        if( sTradeReceiver == sPlayerSteamID64 and table.Count( tTrades ) > 0 ) then
            sFoundReceiver = sTradeReceiver
            sFoundSender = table.GetKeys( tTrades )[1]
            break
        end

        for sTradeSender, _ in pairs( tTrades ) do
            if( sTradeSender == sPlayerSteamID64 ) then
                sFoundReceiver = sTradeReceiver
                sFoundSender = sTradeSender
                break
            end
        end
    end

    if( not sFoundReceiver or not sFoundSender ) then return end

    BRICKS_SERVER.TEMP.UnboxingTrades[sFoundReceiver][sFoundSender] = nil

    local bIsSender = sFoundSender == sPlayerSteamID64
    local pOtherPly = player.GetBySteamID64( bIsSender and sFoundReceiver or sFoundSender )

    if( not IsValid( pOtherPly ) ) then 
        BRICKS_SERVER.Func.SendNotification( pOtherPly, 1, 5, BRICKS_SERVER.Func.L( "unboxingPlyNotOnline" ) )

        net.Start( "BRS.Net.CancelUnboxingTradeReturn" )
            net.WriteString( pOtherPly:SteamID64() )
            net.WriteBool( not bIsSender )
        net.Send( pOtherPly )
    end
end )

util.AddNetworkString( "BRS.Net.AcceptUnboxingTrade" )
util.AddNetworkString( "BRS.Net.AcceptUnboxingTradeReturn" )
net.Receive( "BRS.Net.AcceptUnboxingTrade", function( len, ply )
	local senderSteamID64 = net.ReadString()

	if( not senderSteamID64 ) then return end

    local senderPly = player.GetBySteamID64( senderSteamID64 )

    if( not IsValid( senderPly ) ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingPlyNotOnline" ) )
        return
    end

    if( not BRICKS_SERVER.TEMP.UnboxingTrades[ply:SteamID64()] or not BRICKS_SERVER.TEMP.UnboxingTrades[ply:SteamID64()][senderSteamID64] ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoInviteFromPly" ) )
        return
    end

    if( ply:HasActiveUnboxingTrade() ) then
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingAlreadyActiveTrade" ) )
        return
    end

    BRICKS_SERVER.TEMP.UnboxingTrades[ply:SteamID64()][senderSteamID64] = {
        Active = true,
        ReceiverItems = {},
        SenderItems = {},
        ReceiverCurrencies = {},
        SenderCurrencies = {}
    }

    BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingTradeInviteAccepted" ) )

    net.Start( "BRS.Net.AcceptUnboxingTradeReturn" )
        net.WriteString( senderSteamID64 )
        net.WriteBool( true )
    net.Send( ply )

    net.Start( "BRS.Net.AcceptUnboxingTradeReturn" )
        net.WriteString( ply:SteamID64() )
        net.WriteBool( false )
    net.Send( senderPly )
end )

util.AddNetworkString( "BRS.Net.CancelUnboxingActiveTrade" )
util.AddNetworkString( "BRS.Net.CancelUnboxingActiveTradeReturn" )
net.Receive( "BRS.Net.CancelUnboxingActiveTrade", function( len, ply )
	local partnerSteamID64 = net.ReadString()
	local partnerIsSender = net.ReadBool()

	if( not partnerSteamID64 ) then return end

    local hasActiveTrade = false
    if( partnerIsSender ) then
        if( BRICKS_SERVER.TEMP.UnboxingTrades[ply:SteamID64()] and BRICKS_SERVER.TEMP.UnboxingTrades[ply:SteamID64()][partnerSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[ply:SteamID64()][partnerSteamID64].Active ) then
            BRICKS_SERVER.TEMP.UnboxingTrades[ply:SteamID64()][partnerSteamID64] = nil
            hasActiveTrade = true
        end
    else
        if( BRICKS_SERVER.TEMP.UnboxingTrades[partnerSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[partnerSteamID64][ply:SteamID64()] and BRICKS_SERVER.TEMP.UnboxingTrades[partnerSteamID64][ply:SteamID64()].Active ) then
            BRICKS_SERVER.TEMP.UnboxingTrades[partnerSteamID64][ply:SteamID64()] = nil
            hasActiveTrade = true
        end
    end

    if( not hasActiveTrade ) then
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoActiveTradeWithPly" ) )
        return
    end

    BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingTradeCancelled" ) )

    net.Start( "BRS.Net.CancelUnboxingActiveTradeReturn" )
        net.WriteString( partnerSteamID64 )
        net.WriteBool( partnerIsSender )
    net.Send( ply )

    local partnerPly = player.GetBySteamID64( partnerSteamID64 )
    if( IsValid( partnerPly ) ) then 
        BRICKS_SERVER.Func.SendNotification( partnerPly, 1, 5, BRICKS_SERVER.Func.L( "unboxingTradeCancelledPartner" ) )

        net.Start( "BRS.Net.CancelUnboxingActiveTradeReturn" )
            net.WriteString( ply:SteamID64() )
            net.WriteBool( not partnerIsSender )
        net.Send( partnerPly )
    end
end )

util.AddNetworkString( "BRS.Net.UnboxingActiveTradeAddItem" )
util.AddNetworkString( "BRS.Net.UnboxingActiveTradeAddItemReturn" )
net.Receive( "BRS.Net.UnboxingActiveTradeAddItem", function( len, ply )
	local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()
    local globalKey = net.ReadString()
    local itemAmount = net.ReadUInt( 16 )

    if( not partnerSteamID64 or not globalKey or not itemAmount ) then return end
    
    local partnerPly = player.GetBySteamID64( partnerSteamID64 )
    if( not IsValid( partnerPly ) ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingPlyNotOnline" ) )
        return
    end

    local tradeTable = ply:GetUnboxingTradeTable( partnerSteamID64, partnerIsSender )

    if( not tradeTable ) then
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoActiveTradeWithPly" ) )
        return
    end

    local plyInventory = ply:GetUnboxingInventory()
    if( not plyInventory[globalKey] ) then return end

    local newAmount = math.Clamp( itemAmount, 0, (plyInventory[globalKey] or 0) )
    if( partnerIsSender ) then
        tradeTable.ReceiverItems[globalKey] = (newAmount > 0 and newAmount) or nil
    else
        tradeTable.SenderItems[globalKey] = (newAmount > 0 and newAmount) or nil
    end

    BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingTradeItemAdded" ) )

    net.Start( "BRS.Net.UnboxingActiveTradeAddItemReturn" )
        net.WriteString( partnerSteamID64 )
        net.WriteBool( partnerIsSender )
        net.WriteBool( false )
        net.WriteString( globalKey )
        net.WriteUInt( newAmount, 16 )
    net.Send( ply )

    net.Start( "BRS.Net.UnboxingActiveTradeAddItemReturn" )
        net.WriteString( ply:SteamID64() )
        net.WriteBool( not partnerIsSender )
        net.WriteBool( true )
        net.WriteString( globalKey )
        net.WriteUInt( newAmount, 16 )
    net.Send( partnerPly )

    ply:ClearUnboxingTradeStatus( partnerSteamID64, partnerIsSender )
end )

util.AddNetworkString( "BRS.Net.UnboxingActiveTradeAddCurrency" )
util.AddNetworkString( "BRS.Net.UnboxingActiveTradeAddCurrencyReturn" )
net.Receive( "BRS.Net.UnboxingActiveTradeAddCurrency", function( len, ply )
	local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()
    local currencyKey = net.ReadString()
    local currencyAmount = net.ReadUInt( 32 )

    if( not partnerSteamID64 or not currencyKey or not currencyAmount or not BRICKS_SERVER.DEVCONFIG.Currencies[currencyKey] ) then return end

    local partnerPly = player.GetBySteamID64( partnerSteamID64 )
    if( not IsValid( partnerPly ) ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingPlyNotOnline" ) )
        return
    end

    local tradeTable = ply:GetUnboxingTradeTable( partnerSteamID64, partnerIsSender )

    if( not tradeTable ) then
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoActiveTradeWithPly" ) )
        return
    end

    local currencyTable = BRICKS_SERVER.DEVCONFIG.Currencies[currencyKey]

    local newCurrencyAmount = math.Clamp( currencyAmount, 0, (currencyTable.getFunction( ply ) or 0) )

    if( newCurrencyAmount <= 0 and ((partnerIsSender and not tradeTable.ReceiverCurrencies[currencyKey]) or (not partnerIsSender and not tradeTable.SenderCurrencies[currencyKey])) ) then return end

    if( partnerIsSender ) then
        tradeTable.ReceiverCurrencies[currencyKey] = (newCurrencyAmount > 0 and newCurrencyAmount) or nil
    else
        tradeTable.SenderCurrencies[currencyKey] = (newCurrencyAmount > 0 and newCurrencyAmount) or nil
    end

    BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingTradeCurrencyAdded" ) )

    net.Start( "BRS.Net.UnboxingActiveTradeAddCurrencyReturn" )
        net.WriteString( partnerSteamID64 )
        net.WriteBool( partnerIsSender )
        net.WriteBool( false )
        net.WriteString( currencyKey )
        net.WriteUInt( newCurrencyAmount, 32 )
    net.Send( ply )

    net.Start( "BRS.Net.UnboxingActiveTradeAddCurrencyReturn" )
        net.WriteString( ply:SteamID64() )
        net.WriteBool( not partnerIsSender )
        net.WriteBool( true )
        net.WriteString( currencyKey )
        net.WriteUInt( newCurrencyAmount, 32 )
    net.Send( partnerPly )

    ply:ClearUnboxingTradeStatus( partnerSteamID64, partnerIsSender )
end )

util.AddNetworkString( "BRS.Net.UnboxingActiveTradeSendChat" )
util.AddNetworkString( "BRS.Net.UnboxingActiveTradeSendChatReturn" )
net.Receive( "BRS.Net.UnboxingActiveTradeSendChat", function( len, ply )
	local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()
    local message = net.ReadString()

    if( not partnerSteamID64 or not message ) then return end
    
    local partnerPly = player.GetBySteamID64( partnerSteamID64 )
    if( not IsValid( partnerPly ) ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingPlyNotOnline" ) )
        return
    end

    local tradeTable = ply:GetUnboxingTradeTable( partnerSteamID64, partnerIsSender )

    if( not tradeTable ) then
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoActiveTradeWithPly" ) )
        return
    end

    net.Start( "BRS.Net.UnboxingActiveTradeSendChatReturn" )
        net.WriteString( partnerSteamID64 )
        net.WriteBool( partnerIsSender )
        net.WriteBool( false )
        net.WriteString( message )
    net.Send( ply )

    net.Start( "BRS.Net.UnboxingActiveTradeSendChatReturn" )
        net.WriteString( ply:SteamID64() )
        net.WriteBool( not partnerIsSender )
        net.WriteBool( true )
        net.WriteString( message )
    net.Send( partnerPly )
end )

util.AddNetworkString( "BRS.Net.AcceptUnboxingActiveTrade" )
util.AddNetworkString( "BRS.Net.AcceptUnboxingActiveTradeReturn" )
net.Receive( "BRS.Net.AcceptUnboxingActiveTrade", function( len, ply )
	local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()

    if( not partnerSteamID64 ) then return end
    
    local partnerPly = player.GetBySteamID64( partnerSteamID64 )
    if( not IsValid( partnerPly ) ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingPlyNotOnline" ) )
        return
    end

    local tradeTable = ply:GetUnboxingTradeTable( partnerSteamID64, partnerIsSender )

    if( not tradeTable ) then
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoActiveTradeWithPly" ) )
        return
    end

    if( not ply:GetUnboxingTradeHasContents( partnerSteamID64, partnerIsSender ) ) then return end

    if( partnerIsSender ) then
        if( tradeTable.ReceiverAccepted ) then return end

        tradeTable.ReceiverAccepted = true
    else
        if( tradeTable.SenderAccepted ) then return end

        tradeTable.SenderAccepted = true
    end

    ply:ChangeUnboxingTradeStatus( "Accept", partnerSteamID64, partnerIsSender, true )
end )

util.AddNetworkString( "BRS.Net.ConfirmUnboxingActiveTrade" )
util.AddNetworkString( "BRS.Net.ConfirmUnboxingActiveTradeReturn" )
net.Receive( "BRS.Net.ConfirmUnboxingActiveTrade", function( len, ply )
	local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()

    if( not partnerSteamID64 ) then return end
    
    local partnerPly = player.GetBySteamID64( partnerSteamID64 )
    if( not IsValid( partnerPly ) ) then 
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingPlyNotOnline" ) )
        return
    end

    local tradeTable = ply:GetUnboxingTradeTable( partnerSteamID64, partnerIsSender )

    if( not tradeTable ) then
        BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "unboxingNoActiveTradeWithPly" ) )
        return
    end

    if( not tradeTable.SenderAccepted or not tradeTable.ReceiverAccepted ) then return end

    if( not ply:GetUnboxingTradeHasContents( partnerSteamID64, partnerIsSender ) ) then return end

    if( partnerIsSender ) then
        if( tradeTable.ReceiverConfirmed ) then return end

        tradeTable.ReceiverConfirmed = true
    else
        if( tradeTable.SenderConfirmed ) then return end

        tradeTable.SenderConfirmed = true
    end

    ply:ChangeUnboxingTradeStatus( "Confirm", partnerSteamID64, partnerIsSender, true )

    if( tradeTable.SenderConfirmed and tradeTable.ReceiverConfirmed ) then
        local success, errorMsg = ply:CompleteUnboxingTrade( partnerSteamID64, partnerIsSender )

        if( success ) then
            BRICKS_SERVER.Func.SendTopNotification( ply, BRICKS_SERVER.Func.L( "unboxingTradeCompleted" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
            BRICKS_SERVER.Func.SendTopNotification( partnerPly, BRICKS_SERVER.Func.L( "unboxingTradeCompleted" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )

            ply:UpdateUnboxingStat( "trades", 1, true )
            partnerPly:UpdateUnboxingStat( "trades", 1, true )
        else
            BRICKS_SERVER.Func.SendTopNotification( ply, (errorMsg or BRICKS_SERVER.Func.L( "unboxingTradeError" )), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
            BRICKS_SERVER.Func.SendTopNotification( partnerPly, (errorMsg or BRICKS_SERVER.Func.L( "unboxingTradeError" )), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
        end
    end
end )
