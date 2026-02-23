hook.Add("sP:WithdrawOverride", "sP:CrapHeadATMIntegration", function(ply, printer, amount)
    if CH_ATM and CH_ATM.Config.WithdrawToBankFromPrinter then
        -- Add money to bank account
        CH_ATM.AddMoneyToBankAccount( ply, amount )
        
        -- Notify player
        CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The money has been sent to your bank account." ) )
        
        -- bLogs support
        hook.Run( "CH_ATM_bLogs_ReceiveMoney", amount, ply, "Withdraw from money printer" )

        return true
    end
end)