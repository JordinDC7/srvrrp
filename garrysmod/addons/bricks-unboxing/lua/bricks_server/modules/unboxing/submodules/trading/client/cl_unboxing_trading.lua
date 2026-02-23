BRICKS_SERVER.TEMP.UnboxingTrades = BRICKS_SERVER.TEMP.UnboxingTrades or {}

net.Receive( "BRS.Net.SendUnboxingTradeReturn", function()
    local plySteamID64 = net.ReadString()
    local plyIsSender = net.ReadBool()

    local localPlayerSteamID64 = LocalPlayer():SteamID64()
    if( plyIsSender ) then
        if( not BRICKS_SERVER.TEMP.UnboxingTrades[localPlayerSteamID64] ) then
            BRICKS_SERVER.TEMP.UnboxingTrades[localPlayerSteamID64] = {}
        end

        BRICKS_SERVER.TEMP.UnboxingTrades[localPlayerSteamID64][plySteamID64] = {}
    else
        if( not BRICKS_SERVER.TEMP.UnboxingTrades[plySteamID64] ) then
            BRICKS_SERVER.TEMP.UnboxingTrades[plySteamID64] = {}
        end

        BRICKS_SERVER.TEMP.UnboxingTrades[plySteamID64][localPlayerSteamID64] = {}
    end

    hook.Run( "BRS.Hooks.RefreshUnboxingTrades" )
end )

net.Receive( "BRS.Net.CancelUnboxingTradeReturn", function()
    local plySteamID64 = net.ReadString()
    local plyIsSender = net.ReadBool()

    local localPlayerSteamID64 = LocalPlayer():SteamID64()
    if( plyIsSender ) then
        if( BRICKS_SERVER.TEMP.UnboxingTrades[localPlayerSteamID64] ) then
            BRICKS_SERVER.TEMP.UnboxingTrades[localPlayerSteamID64][plySteamID64] = nil
        end
    else
        if( BRICKS_SERVER.TEMP.UnboxingTrades[plySteamID64] ) then
            BRICKS_SERVER.TEMP.UnboxingTrades[plySteamID64][localPlayerSteamID64] = nil
        end
    end

    hook.Run( "BRS.Hooks.RefreshUnboxingTrades" )
end )

net.Receive( "BRS.Net.AcceptUnboxingTradeReturn", function()
    local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()

    local newTradeTable = {
        Active = true,
        ReceiverItems = {},
        SenderItems = {},
        ReceiverCurrencies = {},
        SenderCurrencies = {},
        ChatTable = {}
    }

    local senderSteamID64 = (partnerIsSender and partnerSteamID64) or LocalPlayer():SteamID64()
    local receiverSteamID64 = (partnerIsSender and LocalPlayer():SteamID64()) or partnerSteamID64

    if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] ) then
        BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] = newTradeTable
    end

    BRICKS_SERVER.UNBOXING.Func.OpenMenu()

    hook.Run( "BRS.Hooks.OpenUnboxingTradePage" )
    
    hook.Run( "BRS.Hooks.OpenUnboxingTrade", partnerSteamID64, partnerIsSender )
end )

net.Receive( "BRS.Net.CancelUnboxingActiveTradeReturn", function()
    local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()

    local senderSteamID64 = (partnerIsSender and partnerSteamID64) or LocalPlayer():SteamID64()
    local receiverSteamID64 = (partnerIsSender and LocalPlayer():SteamID64()) or partnerSteamID64

    if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] ) then
        BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] = nil
    end

    hook.Run( "BRS.Hooks.CancelUnboxingTrade" )
end )

net.Receive( "BRS.Net.UnboxingActiveTradeAddItemReturn", function()
    local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()
    local partnerMadeChange = net.ReadBool()
    local globalKey = net.ReadString()
    local itemAmount = net.ReadUInt( 16 )

    local senderSteamID64 = (partnerIsSender and partnerSteamID64) or LocalPlayer():SteamID64()
    local receiverSteamID64 = (partnerIsSender and LocalPlayer():SteamID64()) or partnerSteamID64

    if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] ) then
        local oldAmount = 0
        if( (partnerIsSender and partnerMadeChange) or (not partnerIsSender and not partnerMadeChange) ) then
            oldAmount = BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].SenderItems[globalKey] or 0
            BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].SenderItems[globalKey] = (itemAmount > 0 and itemAmount) or nil
        else
            oldAmount = BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ReceiverItems[globalKey] or 0
            BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ReceiverItems[globalKey] = (itemAmount > 0 and itemAmount) or nil
        end

        hook.Run( "BRS.Hooks.UpdateUnboxingTradeItems", partnerMadeChange )

        local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
        local message

        local changeAmount = itemAmount-oldAmount
        if( changeAmount > 0 ) then
            message = BRICKS_SERVER.Func.L( "unboxingAddedXToTrade", changeAmount, configItemTable.Name )
        else
            message = BRICKS_SERVER.Func.L( "unboxingRemovedXTrade", math.abs( changeAmount ), configItemTable.Name )
        end
    
        local messageKey = table.insert( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ChatTable, { BRICKS_SERVER.Func.UTCTime(), message, (partnerMadeChange and partnerSteamID64) or LocalPlayer():SteamID64(), true } )
        hook.Run( "BRS.Hooks.AddUnboxingChatMessage", messageKey )
    end
end )

net.Receive( "BRS.Net.UnboxingActiveTradeAddCurrencyReturn", function()
    local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()
    local partnerMadeChange = net.ReadBool()
    local currencyKey = net.ReadString()
    local currencyAmount = net.ReadUInt( 32 )

    local senderSteamID64 = (partnerIsSender and partnerSteamID64) or LocalPlayer():SteamID64()
    local receiverSteamID64 = (partnerIsSender and LocalPlayer():SteamID64()) or partnerSteamID64

    if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] ) then
        local oldAmount = 0
        if( (partnerIsSender and partnerMadeChange) or (not partnerIsSender and not partnerMadeChange) ) then
            oldAmount = BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].SenderCurrencies[currencyKey] or 0
            BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].SenderCurrencies[currencyKey] = (currencyAmount > 0 and currencyAmount) or nil
        else
            oldAmount = BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ReceiverCurrencies[currencyKey] or 0
            BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ReceiverCurrencies[currencyKey] = (currencyAmount > 0 and currencyAmount) or nil
        end

        hook.Run( "BRS.Hooks.UpdateUnboxingTradeCurrencies", partnerMadeChange )

        local devConfigTable = BRICKS_SERVER.DEVCONFIG.Currencies[currencyKey]
        local message

        local changeAmount = currencyAmount-oldAmount
        if( changeAmount > 0 ) then
            message = BRICKS_SERVER.Func.L( "unboxingAddedTradeCurrency", devConfigTable.formatFunction( changeAmount ) )
        else
            message = BRICKS_SERVER.Func.L( "unboxingRemovedTradeCurrency", devConfigTable.formatFunction( math.abs( changeAmount ) ) )
        end
    
        local messageKey = table.insert( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ChatTable, { BRICKS_SERVER.Func.UTCTime(), message, (partnerMadeChange and partnerSteamID64) or LocalPlayer():SteamID64(), true } )
        hook.Run( "BRS.Hooks.AddUnboxingChatMessage", messageKey )
    end
end )

net.Receive( "BRS.Net.UnboxingActiveTradeSendChatReturn", function()
    local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()
    local partnerMadeChange = net.ReadBool()
    local message = net.ReadString()

    local senderSteamID64 = (partnerIsSender and partnerSteamID64) or LocalPlayer():SteamID64()
    local receiverSteamID64 = (partnerIsSender and LocalPlayer():SteamID64()) or partnerSteamID64

    if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] ) then
        local messageKey = table.insert( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ChatTable, { BRICKS_SERVER.Func.UTCTime(), message, (partnerMadeChange and partnerSteamID64) or LocalPlayer():SteamID64() } )
        hook.Run( "BRS.Hooks.AddUnboxingChatMessage", messageKey )
    end
end )

net.Receive( "BRS.Net.AcceptUnboxingActiveTradeReturn", function()
    local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()
    local partnerMadeChange = net.ReadBool()
    local newValue = net.ReadBool()

    local senderSteamID64 = (partnerIsSender and partnerSteamID64) or LocalPlayer():SteamID64()
    local receiverSteamID64 = (partnerIsSender and LocalPlayer():SteamID64()) or partnerSteamID64

    if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] ) then
        if( (partnerIsSender and partnerMadeChange) or (not partnerIsSender and not partnerMadeChange) ) then
            BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].SenderAccepted = newValue
        else
            BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ReceiverAccepted = newValue
        end

        hook.Run( "BRS.Hooks.UpdateUnboxingTradeStatus" )

        local messageKey = table.insert( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ChatTable, { BRICKS_SERVER.Func.UTCTime(), BRICKS_SERVER.Func.L( "unboxingAcceptedTrade" ), (partnerMadeChange and partnerSteamID64) or LocalPlayer():SteamID64(), true } )
        hook.Run( "BRS.Hooks.AddUnboxingChatMessage", messageKey )
    end
end )

net.Receive( "BRS.Net.ConfirmUnboxingActiveTradeReturn", function()
    local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()
    local partnerMadeChange = net.ReadBool()
    local newValue = net.ReadBool()

    local senderSteamID64 = (partnerIsSender and partnerSteamID64) or LocalPlayer():SteamID64()
    local receiverSteamID64 = (partnerIsSender and LocalPlayer():SteamID64()) or partnerSteamID64

    if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] ) then
        if( (partnerIsSender and partnerMadeChange) or (not partnerIsSender and not partnerMadeChange) ) then
            BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].SenderConfirmed = newValue
        else
            BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ReceiverConfirmed = newValue
        end

        hook.Run( "BRS.Hooks.UpdateUnboxingTradeStatus" )

        local messageKey = table.insert( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ChatTable, { BRICKS_SERVER.Func.UTCTime(), BRICKS_SERVER.Func.L( "unboxingConfirmedTrade" ), (partnerMadeChange and partnerSteamID64) or LocalPlayer():SteamID64(), true } )
        hook.Run( "BRS.Hooks.AddUnboxingChatMessage", messageKey )
    end
end )

net.Receive( "BRS.Net.ClearUnboxingActiveTradeStatus", function()
    local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()

    local senderSteamID64 = (partnerIsSender and partnerSteamID64) or LocalPlayer():SteamID64()
    local receiverSteamID64 = (partnerIsSender and LocalPlayer():SteamID64()) or partnerSteamID64

    if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] ) then
        BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].SenderConfirmed = false
        BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ReceiverConfirmed = false
        BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].SenderAccepted = false
        BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64].ReceiverAccepted = false

        hook.Run( "BRS.Hooks.UpdateUnboxingTradeStatus" )
    end
end )

net.Receive( "BRS.Net.CompleteUnboxingActiveTrade", function()
    local partnerSteamID64 = net.ReadString()
    local partnerIsSender = net.ReadBool()

    local tradeTable = LocalPlayer():GetUnboxingTradeTable( partnerSteamID64, partnerIsSender )

    if( not tradeTable ) then return end

    local senderSteamID64 = (partnerIsSender and partnerSteamID64) or LocalPlayer():SteamID64()
    local receiverSteamID64 = (partnerIsSender and LocalPlayer():SteamID64()) or partnerSteamID64

    if( BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64] and BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] ) then
        BRICKS_SERVER.TEMP.UnboxingTrades[receiverSteamID64][senderSteamID64] = nil
    end

    hook.Run( "BRS.Hooks.CompleteUnboxingTrade", partnerSteamID64, partnerIsSender, tradeTable.SenderItems, tradeTable.ReceiverItems, tradeTable.SenderCurrencies, tradeTable.ReceiverCurrencies )
end )