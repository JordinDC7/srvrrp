/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.config = zbf.config or {}
zbf.language = zbf.language or {}

///////////////////////// Zero´s BotNet ////////////////////////////////////

// Developed by ZeroChain:
// http://steamcommunity.com/id/zerochain/
// https://www.gmodstore.com/users/view/76561198013322242
// https://www.artstation.com/zerochain

/////////////////////////////////////////////////////////////////////////////


///////////////////////// zclib Config //////////////////////////////////////
/*
	This config can be used to overwrite the main config of zeros libary
*/

// The Currency
zclib.config.Currency = "$"

// Should the Currency symbol be in front or after the money value?
zclib.config.CurrencyInvert = true

// These Ranks are admins
// If xAdmin, sAdmin or SAM is installed then this table can be ignored
zclib.config.AdminRanks = {
	[ "superadmin" ] = true
}

//zclib.config.CleanUp.SkipOnTeamChange[TEAM_STAFF] = true
/////////////////////////////////////////////////////////////////////////////


/*
	What language should we display en , ru , es , de , fr , cn
*/
zbf.config.SelectedLanguage = "en"

/*
	This automaticly blacklists the entities from the pocket swep
*/
if GAMEMODE and GAMEMODE.Config and GAMEMODE.Config.PocketBlacklist then
	GAMEMODE.Config.PocketBlacklist[ "zbf_bot" ] = true
	GAMEMODE.Config.PocketBlacklist[ "zbf_rack" ] = true
	GAMEMODE.Config.PocketBlacklist[ "zbf_controller" ] = true
	GAMEMODE.Config.PocketBlacklist[ "zbf_usb" ] = true
	GAMEMODE.Config.PocketBlacklist[ "zbf_atm" ] = true
end

/*
	How much damage it takes to destroy the object, -1 disables it
*/
zbf.config.Damageable = {
	["zbf_rack"] = 550,
	["zbf_controller"] = 500,
	["zbf_usb"] = 100,
}

/*
	Should the Bots,racks,controller and usb be damaged by water?
*/
zbf.config.Waterdamage = true

/*
	2d3d UIs with masks cause a visual bug in which the image will be rendered in front of certain entities
	Setting this to true will fix the issues but the image wont look as good
*/
zbf.config.Disable2d3dMask = false

/*
	This defines the size of the render target aka the resolution of the custom lua material
*/
zbf.config.RenderTargetSize = 512

/*
	If enabled this system will damage / wear down bots health over a certain amount of produced ticks
	NOTE Bots with more health obviously will wear down much slower
*/
zbf.config.WearSystem = {
	enabled = true,

	// After how many seconds of use will damage occur on the bot?
	// Lets say every 15 minutes
	uses = 900,

	// How much damage should be applied?
	dmg = 1,

	// How much does it cost to repair the bot
	// NOTE This can be modified by the repair cost multipliactor inside the bot editor
	repair_cost = 100,

	// How much health do we get per repair?
	repair_health = 5,
}

/*
	Bots will increase their level overtime, the longer they work and stay alive the higher their level will be
*/
zbf.config.LevelSystem = {
	// Should this system be enabled?
	enabled = true,

	// How many levels can a bot level up?
	max_level = 10,

	// How much better will the bot be once he is max_level?
	// This multiplicator will apply to TPS, Attack, Defense, Neuro
	max_performance = 1, // + 100%

	// How long does a bot have to work in order to be at max level?
	time_max_level = 10800, // 3 Hours
}

/*
	The controller is the heart of the BotNet
*/
zbf.config.Controller = {

	// Defines how much money a BotNet can hold depending on the Owners rank
	// So player have to check on their controller once in a while and dont afk mine
	// This really just applys to looping jobs and doesent impact any other form of moving money to the controller (StealAttack)
	// NOTE If you need something more dynamic, look at sh_zbf_hooks.lua > zbf_Controller_GetWalletSize
	wallet_size = {
		["default"]  = 25000,
		["VIP"]  = 90000,
		["superadmin"]  = 180000,
	},

	// How many bots can the player purchase?
	// NOTE If you need something more dynamic, look at sh_zbf_hooks.lua > zbf_Controller_GetBotLimit
	BotLimit = {
		["default"] = 20,
		["VIP"] = 40,
		["manager"] = 40,
		["superadmin"] = 60,
	},

	// Defines how many ip adresses are possible (Ye its better if you dont touch that)
	ip_size = 600,

	// How often is the player allow to change his IP per controller
	// Lets say every 10 minutes
	ip_refresh = 600,

	// If set to true then the IP Cache on the controller will be reset once the controller refreshes its IP
	// You may want this set to true, so that refreshing your IP actully causes the loss of valuable connections you made with other BotNets / IPs
	ip_resetcache_onrefresh = false,

	// The time it takes for the pinged IP field to become invalid again and fade out.
	// All this really does is prevent the scanned IP fields to stay up to date and the time is only used to visualy fade the IP field on the map.
	// NOTE Settings this to -1 will disable pinged IP fields to fade out and will stay up to date (Unless the controller who pinged refreshes his IP)
	ip_ping_fadeout = 600,

	// Should we show potential botnet hints on the IP Map after performing a Ping.
	// This will show the player a potential IP which is connected to a BotNet (If any are found)
	// NOTE From the shown hints, 1 of them will be legit and the others will be fake / random
	ip_hints = {
		enabled = true,

		// How long will the IP hints be visible on the minimap?
		lifetime = 120,

		// How many fake hints should be added?
		fake = 2,
	},

	// When finishing a Ping attack on a empty IP Field the player can sometimes find loot
	ip_loot = {
		// How high is the chance of finding loot
		chance = 10, // %

		// How much money / crypto can the player find
		// NOTE The money will be giving to the player in form of random crypto currencies
		max_money = 3500,
		min_money = 600,
	},

	// Defines how often the player can be offered a new job to compute
	// NOTE This only applys to jobs which got the "expire" parameter set
	-- [MEGA UPDATE PATCH] Lower burst throughput to reduce AFK-style income spikes.
	job_offer_interval = 160,

	// Defines how many job offers the player can have availble at the same time
		job_offer_limit = 4,

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	// How much money does the player get back when selling his bots?
	// NOTE Setting this to 0 will disable the Bot Sell function
	sell_refund = 0.6, // 60%

	// If set to true then the players wont be able to buy the bots from the controller bot shop
	disable_shop = false,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	// If set to true then the players wont be able to repair the bots from the controller
	disable_repair = false,
}

/*
	Some config options for the BotNet Attacks
*/
zbf.config.BotNet = {
	// Should the attackers IP be revealed to the victim after the attack?
	RevealAttacker = true
}

/*
	Those Neuro Config options are connected to the Neuro jobs and are just here for easier access
*/
zbf.config.Neuro = {

	// It doesent really matter what values you use, its just about the player with the largest number has the highest chance of attack success and defense success
	AttackSuccess = {
		["default"] = 100,
		["user"] = 100,
		["VIP"] = 250,
		["admin"] = 500,
		["superadmin"] = 1000,
	},

	// Should a crash wave should be send to the attacker if the neuro attack on the target player failed?
	// NOTE The impacted bot count depends on the defense strength of the target.
	CrashOnAttackFail = true,

	// For how long will the players movement speed will be increased per neuro boost attack
	Boost_duration = 60,

	// How much health will the player gain per neuro vitality attack
	Vitality_amount = 15,

	// For how long will the player be protected against damage or other neuro attacks per neuro shield attack
	Shield_duration = 60,

	// For how long will the players movement speed will be decreased per neuro cripple attack
	Cripple_duration = 60,

	// For how long will the player be on fire per neuro cripple attack
	Overheat_duration = 10,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	// For how long will the players health and vision be impacted
	Aneurysm_duration = 30,

	// For how long will the players health and size be boosted
	Growth_duration = 60,
	Growth_health = 200,
}

/*
	Anything Crypto / Coinbase releated
*/
zbf.config.Crypto = {

	// How often should we fetch the current crypto prices from coinbase
	interval = 1200,

	// We got arround 200 crypto currencies so lets not send 160 http requests to coinbase at once (Atleast i think thats the best way to handle it :I)
	http_delay = 0.05,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

	// This will be the default money mining amount a player will get, its directly connected to the mining jobs created at the bottom of sh_zbf_job_config_legal.lua
	// In short, every 1000 ticks the player will get 100$ in the crypto currency he is mining. How fast he produces those ticks depends on his setup.
	MoneyPerCycle = 700,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	// This command will opens the players currency inventory which gets saved on the server
	// NOTE Removing this will disable the chat command
	// NOTE There is also !adminvault which allows admins to inspect other players vault
	ChatCommand = "!vault",

	// How much money in crypto assets is the player allowed to own?
	Limit = 50000000
}

/*
	The Vault allows the player to save his crypto on the server
*/
zbf.config.Vault = {
	// How often should we auto save everyones crypto on the server?
	// NOTE -1 Disables it
	AutoSave = 300,

	// Any savefile which has not been modified in 2 months will be removed
	LifeTime = 5356800
}

/*
	The Crypto ATM allows the player to Buy / Sell / Send Crypto Currencies
*/
zbf.config.ATM = {
	// Defines how much crypto currency in $ the player can purchase per transaction
	PurchaseLimit = 10000000
}

/*
	The USB / Hardware wallet is used to place down Crypto Currencies on the map
*/
zbf.config.USB = {
	// How many usb wallet entitys can the player spawn / drop?
	SpawnLimit = {
		["default"] = 3,
		["VIP"] = 6,
		["superadmin"] = 15,
	},
}
