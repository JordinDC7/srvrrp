zlt = zlt or {}
zlt.config = zlt.config or {}

/////////////////////////////////////////////////////////////////////////////

// Bought by 76561198013322242
// Version 1.1.5

/////////////////////////// Zero´s Scratchcards //////////////////////////////

// Developed by ZeroChain:
// http://steamcommunity.com/id/zerochain/
// https://www.gmodstore.com/users/view/76561198013322242
// https://www.artstation.com/zerochain

/////////////////////////////////////////////////////////////////////////////

// What language should we display en
zlt.config.SelectedLanguage = "en"

// Here you can add font types
zlt.config.Fonts = {
	"Gecko Lunch",
	"Budmo Jiggler",
	"Gunplay"
}

// Should the ticket be AutoPicked up on purchase?
// Currently only works for Itemstore and Xenin Inventory
zlt.config.AutoPickup = false

// If enabled then the ticket will be instantly used by the player who purchased it
zlt.config.InstantUse = false

// How many tickets is the player allowed to spawn?
zlt.config.TicketLimit = 7

// zclib.config.ImageServices["folder"] = "https://AdresseToImage/"
/*
	Examble:
		Addresse to a imagefile: > https://imgpile.com/images/nnHvi2.jpg
		ImageService would be that > zclib.config.ImageServices["imgpile"] = "https://imgpile.com/images/"
		ImageID would be that > nnHvi2

		flickr Setup would look like that
		zclib.config.ImageServices["imgpile"] = "https://imgpile.com/images/"
		zclib.config.ActiveImageService = "imgpile"
*/

// Which image side should we use? imgur or imgpile
zclib.config.ActiveImageService = "imgur"



// This automaticly blacklists the entities from the pocket swep
if GM and GM.Config and GM.Config.PocketBlacklist then
	GM.Config.PocketBlacklist["zlt_ticket"] = true
	GM.Config.PocketBlacklist["zlt_machine"] = true
end

zlt.config.RarityColors = {
	[70] = "86, 182, 194", // Blue01
	[60] = "77, 105, 205", // Blue02
	[50] = "137, 71, 255", // Violett
	[40] = "212, 43, 230", // Pink
	[30] = "235, 75, 75", // Red
	[20] = "202, 171, 5", // Gold
	[10] = "136, 106, 8", // Immortal
}

// This can be used to overwrite the money functions, Return nil to use the zclib internal money functions, which are currently for Sandbox, darkrp, nutscript and basewars
zlt.config.MoneyOverwrite = {
	give = function(ply,amount)

		if engine.ActiveGamemode() == "underdone" then
			ply:AddItem("money", amount)
			return true
		end

		return nil
	end,
	take = function(ply,amount)

		if engine.ActiveGamemode() == "underdone" then
			ply:RemoveItem("money", amount)
			return true
		end

		return nil
	end,
	has = function(ply,amount)

		if engine.ActiveGamemode() == "underdone" then
			return ply:HasItem("money", amount)
		end

		return nil
	end,
}
