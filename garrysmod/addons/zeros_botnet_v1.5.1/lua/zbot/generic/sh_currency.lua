/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Currency = zbf.Currency or {}
zbf.Currency.List = zbf.Currency.List or {}
zbf.Currency.ShortToList = zbf.Currency.ShortToList or {}

/*

	Here we register all the diffrent kind of currencys

*/

local ConvertType = "USD"

// If the money gets displayed in euro then we use the EUR ConvertType
if zclib.config.Currency == "€" then ConvertType = "EUR" end

// Returns for how many decimal places we should round
function zbf.Currency.GetPrecision(id)
	return zbf.Currency.IsMoney(id) and 0 or 8
end

// Builds the coinbase URL to fetch a crypto spot price
function zbf.Currency.FettchURL(short) return "https://api.coinbase.com/v2/prices/" .. short .. "-" .. ConvertType .. "/spot" end

// Returns the currency value , one day ago
function zbf.Currency.FettchHistoricURL(short) return "https://api.coinbase.com/v2/prices/" .. short .. "-" .. ConvertType .. "/historic?period=hour" end

/*
	Add a new Currency
*/
function zbf.Currency.Add(data)

	/*
		data = {
			name = "Bitcoin",
			short = "BTC",
		}
	*/

	local id = table.insert(zbf.Currency.List, data)

	// Here we add the short as key and list id as value so we can use this to convert between those two later
	zbf.Currency.ShortToList[data.short] = id

	// If its id 1 then its DarkRP money in which case we dont want to register it
	if zbf.Currency.IsMoney(id) then return id end

	// This is the url from which we will get our price
	local coinbase_url = zbf.Currency.FettchURL(data.short)

	// This is the url which sends us the value changes for the last few hours
	local historic_url = zbf.Currency.FettchHistoricURL(data.short)

	// Create the icon
	zbf.Currency.List[id].icon = Material("materials/zerochain/zbot/crypto/" .. string.lower(data.short) .. ".png", "noclamp smooth")

	// Add the coinbase registration here so it updates the currencies value every so often
	zbf.Coinbase.Reg(coinbase_url,historic_url,function(val)

		// Returns the current value

		local newVal = math.Round(val,zbf.Currency.GetPrecision(id))
		zbf.Currency.List[id].value = newVal
	end,function(HistoricValue)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

		// Returns the historic value, 1 hour ago

		// Lets compare the Historic value (1 hour ago) to the current value and calculate its performance
		zbf.Currency.List[id].perf = (1 / HistoricValue) * zbf.Currency.List[id].value - 1
	end,data.short)

	return id
end

/*
	Get the Currency Data
*/
function zbf.Currency.Get(id)
	return zbf.Currency.List[id]
end

/*
	Get the money value of that currency
*/
function zbf.Currency.GetValue(id,amount)
	local dat = zbf.Currency.Get(id)
	if dat == nil or dat.value == nil then return 0 end
	local val = dat.value

	if amount then
		val = val * amount
	end

	return val
end

/*
	Formats the currency value to a nice decimal string
*/
function zbf.Currency.Format(id,amount)
	local decimal = zbf.Currency.IsMoney(id) and 0 or 6

	if amount < 0.05 then decimal = 3 end
	if amount < 0.005 then decimal = 4 end
	if amount < 0.0005 then decimal = 5 end
	if amount < 0.00005 then decimal = 6 end
	//if amount < 0.000025 then decimal = 6 end

	if amount == 0 then decimal = 0 end

	local val = math.Round(amount, decimal)

	if amount > 0 and amount < 0.0001 then
		val = string.format( "%f" , val )
	end

	return val
end

/*
	Is money
*/
function zbf.Currency.IsMoney(id)
	return id == 1
end

/*
	Get the current performance
*/
function zbf.Currency.GetPerformance(id)
	local dat = zbf.Currency.Get(id)
	if dat == nil or dat.perf == nil then return 0 end
	return dat.perf
end

/*
	Get the current performance as a string and with color
*/
function zbf.Currency.GetNicePerformance(id)
	local CryptoPerf = math.Round(zbf.Currency.GetPerformance(id) * 100,2)
	if CryptoPerf > 0 then
		return "+" .. CryptoPerf .. "%", zclib.colors[ "green01" ]
	elseif CryptoPerf == 0 then
		return "--%", zclib.colors[ "text01" ]
	else
		return CryptoPerf .. "%", zclib.colors[ "red01" ]
	end
end

/*
	Get the short definition
*/
function zbf.Currency.GetShort(id)
	local dat = zbf.Currency.Get(id)
	if dat == nil or dat.value == nil then return "???" end
	return dat.short
end

/*
	Get the icon of that currency
*/
function zbf.Currency.GetIcon(id)

	if zbf.Currency.IsMoney(id) then
		return zclib.config.Currency
	end

	local dat = zbf.Currency.Get(id)
	if dat == nil or dat.icon == nil then return end
	return dat.icon
end

/*
	Get the name
*/
function zbf.Currency.GetName(id)
	local dat = zbf.Currency.Get(id)
	if dat == nil or dat.name == nil then return "???" end

	return dat.name
end

/*
	Get the List ID from the SHORT
*/
function zbf.Currency.GetID(short)
	return zbf.Currency.ShortToList[short]
end

/*
	Is the player allowed to buy this currency?
*/
function zbf.Currency.CanPurchase(id,ply)
	local result = hook.Run("zbf_Crypto_CanBuy",ply,zbf.Currency.GetShort(id))
	if result ~= nil then return result end
	return true
end

/*
	Is the player allowed to buy this currency?
*/
function zbf.Currency.CanSell(id,ply)
	local result = hook.Run("zbf_Crypto_CanSell",ply,zbf.Currency.GetShort(id))
	if result ~= nil then return result end
	return true
end

/*
	Is the player allowed to send this currency?
*/
function zbf.Currency.CanSend(id,ply)
	local result = hook.Run("zbf_Crypto_CanSend",ply,zbf.Currency.GetShort(id))
	if result ~= nil then return result end
	return true
end


if CLIENT then

	zbf.Currency.Favourites = {}

	/*
		Add the specified ID as favourite
	*/
	function zbf.Currency.AddFav(id)
		local short = zbf.Currency.GetShort(id)
		if short == nil then return end
		zbf.Currency.Favourites[short] = true
		zbf.Currency.SaveFav()
	end

	/*
		Removes the specified ID as favourite
	*/
	function zbf.Currency.RemoveFav(id)
		local short = zbf.Currency.GetShort(id)
		if short == nil then return end
		zbf.Currency.Favourites[short] = nil
		zbf.Currency.SaveFav()
	end

	/*
		Check if the specified crypto id is our favourite
	*/
	function zbf.Currency.IsFav(id)
		local short = zbf.Currency.GetShort(id)
		if short == nil then return false end
		return zbf.Currency.Favourites[short] ~= nil
	end

	/*
		Saves the specified ID as favourite
	*/
	file.CreateDir("zbf")
	function zbf.Currency.SaveFav()
		file.Write("zbf/crypto_fav.txt", util.TableToJSON(zbf.Currency.Favourites))
	end

	/*
		Load the specified ID as favourite
	*/
	function zbf.Currency.LoadFav()
		local data = file.Read("zbf/crypto_fav.txt", "DATA")
		if data == nil then return end
		data = util.JSONToTable(data)
		if data == nil then return end

		zbf.Currency.Favourites = data
	end
end

// We already did the setup, stapth!
if table.Count(zbf.Currency.List) > 0 then return end

ZBF_CURRENCY_MONEY = zbf.Currency.Add({
	name = "Money",
	short = ConvertType,
	value = 1,
})

// NOTE The short value is also used to find the image of the crypto currency

// Every motherfucking crypto currency from coinbase :I

ZBF_CURRENCY_BTC = zbf.Currency.Add({
	name = "Bitcoin",
	short = "BTC",
})

zbf.Currency.Add({
	name = "Wrapped Bitcoin",
	short = "WBTC",
})

zbf.Currency.Add({
	name = "Litecoin",
	short = "LTC",
})

zbf.Currency.Add({
	name = "Bitcoin Cash",
	short = "BCH",
})

zbf.Currency.Add({
	name = "Ethereum",
	short = "ETH",
})

zbf.Currency.Add({
	name = "Dogecoin",
	short = "DOGE",
})

zbf.Currency.Add({
	name = "SHIBA INU",
	short = "SHIB",
})

zbf.Currency.Add({
	name = "Chainlink",
	short = "LINK",
})

zbf.Currency.Add({
	name = "Dai",
	short = "DAI",
})

zbf.Currency.Add({
	name = "Tether",
	short = "USDT",
})

zbf.Currency.Add({
	name = "Cardano",
	short = "ADA",
})

zbf.Currency.Add({
	name = "Solana",
	short = "SOL",
})

zbf.Currency.Add({
	name = "Avalanche",
	short = "AVAX",
})

zbf.Currency.Add({
	name = "Polkadot",
	short = "DOT",
})
/*
zbf.Currency.Add({
	name = "TerraUSD",
	short = "UST",
})
*/

zbf.Currency.Add({
	name = "Polygon",
	short = "MATIC",
})

zbf.Currency.Add({
	name = "Crypto.com Coin",
	short = "CRO",
})

zbf.Currency.Add({
	name = "Cosmos",
	short = "ATOM",
})

zbf.Currency.Add({
	name = "Uniswap",
	short = "UNI",
})

zbf.Currency.Add({
	name = "Algorand",
	short = "ALGO",
})

zbf.Currency.Add({
	name = "Decentraland",
	short = "MANA",
})

zbf.Currency.Add({
	name = "Stellar Lumens",
	short = "XLM",
})

zbf.Currency.Add({
	name = "Ethereum Classic",
	short = "ETC",
})

zbf.Currency.Add({
	name = "Internet Computer",
	short = "ICP",
})

zbf.Currency.Add({
	name = "Filecoin",
	short = "FIL",
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

zbf.Currency.Add({
	name = "Axie Infinity",
	short = "AXS",
})

zbf.Currency.Add({
	name = "Tezos",
	short = "XTZ",
})

zbf.Currency.Add({
	name = "EOS",
	short = "EOS",
})

zbf.Currency.Add({
	name = "Zcash",
	short = "ZEC",
})

zbf.Currency.Add({
	name = "Maker",
	short = "MKR",
})

zbf.Currency.Add({
	name = "Aave",
	short = "AAVE",
})

zbf.Currency.Add({
	name = "The Graph",
	short = "GRT",
})

zbf.Currency.Add({
	name = "Gala",
	short = "GALA",
})

zbf.Currency.Add({
	name = "Stacks",
	short = "STX",
})

zbf.Currency.Add({
	name = "Quant",
	short = "QNT",
})

zbf.Currency.Add({
	name = "Celo",
	short = "CGLD",
})

zbf.Currency.Add({
	name = "Enjin Coin",
	short = "ENJ",
})

zbf.Currency.Add({
	name = "Chiliz",
	short = "CHZ",
})

zbf.Currency.Add({
	name = "Amp",
	short = "AMP",
})

zbf.Currency.Add({
	name = "Dash",
	short = "DASH",
})

zbf.Currency.Add({
	name = "Basic Attention Token",
	short = "BAT",
})

zbf.Currency.Add({
	name = "Curve DAO Token",
	short = "CRV",
})

zbf.Currency.Add({
	name = "Loopring",
	short = "LRC",
})

zbf.Currency.Add({
	name = "Paxos Standard",
	short = "PAX",
})

zbf.Currency.Add({
	name = "yearn.finance",
	short = "YFI",
})

zbf.Currency.Add({
	name = "Compound",
	short = "COMP",
})

zbf.Currency.Add({
	name = "IoTeX (ERC-20)",
	short = "IOTX",
})

zbf.Currency.Add({
	name = "Ankr",
	short = "ANKR",
})

zbf.Currency.Add({
	name = "Render",
	short = "RNDR",
})

zbf.Currency.Add({
	name = "Bancor Network Token",
	short = "BNT",
})

zbf.Currency.Add({
	name = "1inch",
	short = "1INCH",
})

zbf.Currency.Add({
	name = "OMG Network",
	short = "OMG",
})

zbf.Currency.Add({
	name = "Synthetix Network Token",
	short = "SNX",
})

zbf.Currency.Add({
	name = "Livepeer",
	short = "LPT",
})

zbf.Currency.Add({
	name = "UMA",
	short = "UMA",
})

zbf.Currency.Add({
	name = "Golem",
	short = "GLM",
})

zbf.Currency.Add({
	name = "Horizen",
	short = "ZEN",
})

zbf.Currency.Add({
	name = "Rally",
	short = "RLY",
})

zbf.Currency.Add({
	name = "Voyager Token",
	short = "VGX",
})

zbf.Currency.Add({
	name = "0x",
	short = "ZRX",
})

zbf.Currency.Add({
	name = "Keep Network",
	short = "KEEP",
})

zbf.Currency.Add({
	name = "Ren",
	short = "REN",
})

zbf.Currency.Add({
	name = "SKALE",
	short = "SKL",
})

zbf.Currency.Add({
	name = "SushiSwap",
	short = "SUSHI",
})

zbf.Currency.Add({
	name = "Storj",
	short = "STORJ",
})

zbf.Currency.Add({
	name = "Polymath",
	short = "POLY",
})

zbf.Currency.Add({
	name = "Immutable",
	short = "IMX",
})

zbf.Currency.Add({
	name = "Braintrust",
	short = "BTRST",
})

zbf.Currency.Add({
	name = "NuCypher",
	short = "NU",
})

zbf.Currency.Add({
	name = "Spell Token",
	short = "SPELL",
})

zbf.Currency.Add({
	name = "Perpetual Protocol",
	short = "PERP",
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

zbf.Currency.Add({
	name = "Ethereum Name Service",
	short = "ENS",
})

zbf.Currency.Add({
	name = "SuperFarm",
	short = "SUPER",
})

zbf.Currency.Add({
	name = "Fetch.ai",
	short = "FET",
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

zbf.Currency.Add({
	name = "Powerledger",
	short = "POWR",
})

zbf.Currency.Add({
	name = "Tribe",
	short = "TRIBE",
})

zbf.Currency.Add({
	name = "PlayDapp",
	short = "PLA",
})

zbf.Currency.Add({
	name = "XYO",
	short = "XYO",
})

zbf.Currency.Add({
	name = "COTI",
	short = "COTI",
})

zbf.Currency.Add({
	name = "Status",
	short = "SNT",
})

zbf.Currency.Add({
	name = "Function X",
	short = "FX",
})

zbf.Currency.Add({
	name = "Request",
	short = "REQ",
})

zbf.Currency.Add({
	name = "API3",
	short = "API3",
})

zbf.Currency.Add({
	name = "Rari Governance Token",
	short = "RGT",
})

zbf.Currency.Add({
	name = "Decentralized Social",
	short = "DESO",
})

zbf.Currency.Add({
	name = "MyNeighborAlice",
	short = "ALICE",
})

zbf.Currency.Add({
	name = "Civic",
	short = "CVC",
})

zbf.Currency.Add({
	name = "Alchemy Pay",
	short = "ACH",
})

zbf.Currency.Add({
	name = "Numeraire",
	short = "NMR",
})

zbf.Currency.Add({
	name = "Cartesi",
	short = "CTSI",
})

zbf.Currency.Add({
	name = "OriginTrail",
	short = "TRAC",
})

zbf.Currency.Add({
	name = "Orchid",
	short = "OXT",
})

zbf.Currency.Add({
	name = "Mirror Protocol",
	short = "MIR",
})

zbf.Currency.Add({
	name = "Augur",
	short = "REP",
})

zbf.Currency.Add({
	name = "BICONOMY (BICO)",
	short = "BICO",
})

zbf.Currency.Add({
	name = "iExec RLC",
	short = "RLC",
})

zbf.Currency.Add({
	name = "Orion Protocol",
	short = "ORN",
})

zbf.Currency.Add({
	name = "NKN",
	short = "NKN",
})

zbf.Currency.Add({
	name = "Alchemix",
	short = "ALCX",
})

zbf.Currency.Add({
	name = "Enzyme",
	short = "MLN",
})

zbf.Currency.Add({
	name = "Origin Token",
	short = "OGN",
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

zbf.Currency.Add({
	name = "Polkastarter",
	short = "POLS",
})

zbf.Currency.Add({
	name = "AIOZ Network",
	short = "AIOZ",
})

zbf.Currency.Add({
	name = "Maple",
	short = "MPL",
})

zbf.Currency.Add({
	name = "TrueFi",
	short = "TRU",
})

zbf.Currency.Add({
	name = "Badger DAO",
	short = "BADGER",
})

zbf.Currency.Add({
	name = "IDEX",
	short = "IDEX",
})

zbf.Currency.Add({
	name = "ARPA Chain",
	short = "ARPA",
})

zbf.Currency.Add({
	name = "Gitcoin",
	short = "GTC",
})

zbf.Currency.Add({
	name = "Clover Finance",
	short = "CLV",
})

zbf.Currency.Add({
	name = "Aergo",
	short = "AERGO",
})

zbf.Currency.Add({
	name = "Balancer",
	short = "BAL",
})

zbf.Currency.Add({
	name = "Rai Reflex Index",
	short = "RAI",
})

zbf.Currency.Add({
	name = "Loom Network",
	short = "LOOM",
})

zbf.Currency.Add({
	name = "Jasmy",
	short = "JASMY",
})

zbf.Currency.Add({
	name = "Bonfida",
	short = "FIDA",
})

zbf.Currency.Add({
	name = "Ampleforth Governance Token",
	short = "FORTH",
})

zbf.Currency.Add({
	name = "DFI.Money",
	short = "YFII",
})

zbf.Currency.Add({
	name = "Shapeshift FOX Token",
	short = "FOX",
})

zbf.Currency.Add({
	name = "Circuits of Value",
	short = "COVAL",
})

zbf.Currency.Add({
	name = "Adventure Gold",
	short = "AGLD",
})

zbf.Currency.Add({
	name = "Ethernity Chain",
	short = "ERN",
})

zbf.Currency.Add({
	name = "LCX",
	short = "LCX",
})

zbf.Currency.Add({
	name = "PolySwarm",
	short = "NCT",
})

zbf.Currency.Add({
	name = "DIA",
	short = "DIA",
})

zbf.Currency.Add({
	name = "Harvest Finance",
	short = "FARM",
})

zbf.Currency.Add({
	name = "DerivaDAO",
	short = "DDX",
})

zbf.Currency.Add({
	name = "Assemble Protocol",
	short = "ASM",
})

zbf.Currency.Add({
	name = "QuickSwap",
	short = "QUICK",
})

zbf.Currency.Add({
	name = "Ribbon Finance",
	short = "RBN",
})

zbf.Currency.Add({
	name = "Bluzelle",
	short = "BLZ",
})

zbf.Currency.Add({
	name = "Rarible",
	short = "RARI",
})

zbf.Currency.Add({
	name = "Highstreet",
	short = "HIGH",
})

zbf.Currency.Add({
	name = "Liquity",
	short = "LQTY",
})

zbf.Currency.Add({
	name = "BarnBridge",
	short = "BOND",
})

zbf.Currency.Add({
	name = "Tellor",
	short = "TRB",
})

zbf.Currency.Add({
	name = "district0x",
	short = "DNT",
})

zbf.Currency.Add({
	name = "Measurable Data Token",
	short = "MDT",
})

zbf.Currency.Add({
	name = "SHPING",
	short = "SHPING",
})

zbf.Currency.Add({
	name = "Unifi Protocol DAO",
	short = "UNFI",
})

zbf.Currency.Add({
	name = "Bounce Token",
	short = "AUCTION",
})

zbf.Currency.Add({
	name = "SUKU",
	short = "SUKU",
})

zbf.Currency.Add({
	name = "Gods Unchained",
	short = "GODS",
})

zbf.Currency.Add({
	name = "Kryll",
	short = "KRL",
})

zbf.Currency.Add({
	name = "GYEN",
	short = "GYEN",
})

zbf.Currency.Add({
	name = "Cryptex Finance",
	short = "CTX",
})

zbf.Currency.Add({
	name = "Inverse Finance",
	short = "INV",
})

zbf.Currency.Add({
	name = "Pawtocol",
	short = "UPI",
})

zbf.Currency.Add({
	name = "Goldfinch Protocol",
	short = "GFI",
})

zbf.Currency.Add({
	name = "Aventus",
	short = "AVT",
})

zbf.Currency.Add({
	name = "Pluton",
	short = "PLU",
})
/*
zbf.Currency.Add({
	name = "Wrapped LUNA Token",
	short = "WLUNA",
})
*/

zbf.Currency.Add({
	name = "Synapse",
	short = "SYN",
})

zbf.Currency.Add({
	name = "Orca",
	short = "ORCA",
})

zbf.Currency.Add({
	name = "Wrapped Centrifuge",
	short = "WCFG",
})

zbf.Currency.Add({
	name = "Moss Carbon Credit",
	short = "MCO2",
})

zbf.Currency.Add({
	name = "Kyber Network",
	short = "KNC",
})

zbf.Currency.Add({
	name = "ApeCoin",
	short = "APE",
})

zbf.Currency.Add({
	name = "Mask Network",
	short = "MASK",
})

zbf.Currency.Add({
	name = "Radicle",
	short = "RAD",
})

zbf.Currency.Add({
	name = "Mina",
	short = "MINA",
})

zbf.Currency.Add({
	name = "Binance USD",
	short = "BUSD",
})

zbf.Currency.Add({
	name = "Oasis Network",
	short = "ROSE",
})

zbf.Currency.Add({
	name = "STEPN",
	short = "GMT",
})

zbf.Currency.Add({
	name = "Green Satoshi Token",
	short = "GST",
})

zbf.Currency.Add({
	name = "Project Galaxy",
	short = "GAL",
})

zbf.Currency.Add({
	name = "Flow",
	short = "FLOW",
})

zbf.Currency.Add({
	name = "The Sandbox",
	short = "SAND",
})


zbf.Currency.Add({
	name = "TE-FOOD",
	short = "TONE",
})

zbf.Currency.Add({
	name = "SuperRare",
	short = "RARE",
})

zbf.Currency.Add({
	name = "Stargate Finance",
	short = "STG",
})

zbf.Currency.Add({
	name = "League of Kingdoms Arena",
	short = "LOKA",
})

zbf.Currency.Add({
	name = "Gemini Dollar",
	short = "GUSD",
})
