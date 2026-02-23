sPrinter = sPrinter or {}
sPrinter.config = sPrinter.config or {}

// _                           ___                   
// | |       _                 / __)                  
// | |____ _| |_ _____  ____ _| |__ _____  ____ _____ 
// | |  _ (_   _) ___ |/ ___|_   __|____ |/ ___) ___ |
// | | | | || |_| ____| |     | |  / ___ ( (___| ____|
// |_|_| |_| \__)_____)_|     |_|  \_____|\____)_____)
//
// This is used if you want to override the currency, for example PS1 points etc.

sPrinter.config.addMoney = function(ply, money)
    return ply:addMoney(money)
end

sPrinter.config.canAfford = function(ply, money)
    return ply:canAfford(money)
end