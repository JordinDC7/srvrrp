-- This file just does small configuration stuff such as Language and default keybinds. The rest of the config is in-game so yeah.

-- The language the addon uses. This can be: en, de, fr, tr, es
UltimatePartySystem.Config.Language = "en"

-- If to auto resource.AddWorkshop the content. (FastDL)
UltimatePartySystem.Config.FastDL = true

-- Users that can modify the in-game config. This can be usergroups or steamids.
UltimatePartySystem.Config.ConfigGroups = {}
UltimatePartySystem.Config.ConfigGroups['superadmin'] = true
UltimatePartySystem.Config.ConfigGroups['STEAM_0:1:80376292'] = true -- Remove this unless you trust me with your config lol


-- Keybinds:
-- Due to Garry's Mod blocking lua code to set binds on players, all players will have to set these bindings themselves. It's up to you how you choose to inform them on how to do it, but here's a basic guide for you to give to your players.
-- Go into your Garry's Mod options. Under the Keyboard tab, click "Advanced" at the bottom and check the box that says "enable developer console". After doing that, click okay, apply, and close the options button. Pressing the Tilta key (` - underneath ESC usually) you will open the console. Here, you can type in the following commands. Be sure to change <key> to the desired key you want.

-- bind "<key>" "ups_radio_toggle"             < Toggle Radio
-- bind "<key>" "ups_marker_create"            < Create a new Marker
-- bind "<key>" "ups_marker_clear"             < Clear a player's marker.


-- okay go in-game now