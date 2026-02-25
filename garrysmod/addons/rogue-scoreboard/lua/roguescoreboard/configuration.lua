RogueScoreboard.Configuration = {}

local Configuration = RogueScoreboard.Configuration


// T I P S 
--[[ 

1. I would suggest making your job colors more vibrant to suit the scoreboard better, for instance i used Color( 0,255,80 ) for my citizen job color. This can be done in your darkrpmodifications folder.

2. Configuration.UndercoverNames is random names for incognito / undercover mode, i would suggest adding your own to suit your server requirements & for more variety.

3. If the scoreboard does not show up, try disabling Fadmin. ( Have had no known issues with this but it is here incase )

4. Dont be a leaker, support the lads who do the hard work for you, we have to put up with the cost of living and bills too.

]]


// M A I N   C O N F I G U R A T I O N S

-- Server title
Configuration.ServerTitle           = "R O G U E   S C O R E B O A R D"

-- Are you using DarkRP?
Configuration.DarkRP                = true
-- Sort the menu by categories?
Configuration.SortByCategories      = false

-- Type your admin prefix. Currently supports: "ulx", "serverguard", "xadmin2", "xadmin", "fadmin", "sam" 
Configuration.AdministrationMod     = "ulx"

-- Allow ALL ranks to view players money and props. If false fill table below.
Configuration.InformationViewAll    = true
Configuration.InformationView       = { "Moderator", "admin", "superadmin", "Owner" }

-- Show the online count at the bottom of the scoreboard?
Configuration.ShowOnlineCount       = true

-- Information bar is the information above the scorebord with, ( NAME, JOB, K, D )
Configuration.InformationBar        = true
-- Does the bar have a background?
Configuration.InformationBackground = false

-- Show players name?
Configuration.ShowName              = true
-- Show players team?
Configuration.ShowTeam              = true
-- Show players rank?
Configuration.ShowRank              = true

-- Show players steamname rather than ingame Nick?
Configuration.SteamName             = false

// R E P O R T  S Y S T E M ( N E W  )

-- Set to false if you do not want the report system
Configuration.ReportEnabled         = true

-- Are you using a report addon that uses a chat prefix? example SH Report uses /report
Configuration.UsingReportAddon      = false
Configuration.ReportAddonPrefix     = "/report" -- This can be /r or anything your report system requires the prefix to be to open the menu

// If you are not using a report addon this section of the report system is for you
-- URL for your report button, Set to false if you are not using a website for report button, this will send messages to admins ingame instead
Configuration.UsingReportSite       = false
Configuration.ReportURL             = "www.google.com"


-- Report button admin message if you are not using a report addon
Configuration.ReportPrefix          = "@"
Configuration.ReportedText          = "I would like to report"



// T H E M E

Configuration.MainBackground        = Color( 19,20,21,246 )
Configuration.PanelBackground       = Color( 24,25,26,210 )
Configuration.ServerTitleColor      = Color( 255,255,255 )

Configuration.NameHover             = Color( 0,190,255 )
Configuration.Friends               = Color( 0,170,255 )
Configuration.Muted                 = Color( 255,190,0 )
Configuration.ClearProps            = Color( 255,190,0 )
Configuration.ClearPropsHover       = Color( 255,70,0 )
Configuration.ReportColor           = Color( 255,190,0 )
Configuration.ReportHoverColor      = Color( 255,70,0 )
Configuration.IconsDarkColor        = Color( 121,122,123 )

Configuration.PingFull              = Color( 0,255,0 )
Configuration.Ping3                 = Color( 250,255,0 )
Configuration.Ping2                 = Color( 255,155,0 )
Configuration.PingCritical          = Color( 255,100,0 )

Configuration.UndercoverIcon        = Color( 121,122,123 )
Configuration.IsUndercoverIcon      = Color( 0,160,255 )


// L A N G U A G E

-- Information bar
Configuration.NameText              = "NAME" 
Configuration.JobText               = "JOB" 
Configuration.KillsText             = "K" 
Configuration.DeathsText            = "D"

-- Button text
Configuration.ClearPropText         = "CLEAR PROPS"
Configuration.MuteText              = "MUTE"
Configuration.UnMuteText            = "UN-MUTE"
Configuration.ReportText            = "REPORT"

-- Command text
Configuration.TargetSelfCheck       = "You cannot target yourself.."
Configuration.CommandCopy           = "COPY STEAM ID & STEAM 64"
Configuration.CommandGoto           = "GOTO"
Configuration.CommandBring          = "BRING"
Configuration.CommandSpectate       = "SPECTATE"
Configuration.CommandBringFreeze    = "BRING & FREEZE"

Configuration.CommandKick           = "KICK"
Configuration.CommandKickReason     = "You have been kicked"

Configuration.CommandBan            = "BAN"
Configuration.CommandBanReason      = "You have received a 2 Hour ban"

Configuration.PropText              = "PROPS"

-- Incognito text
Configuration.ActivateIncog         = "UNDERCOVER"
Configuration.DeactivateIncog       = "DEACTIVATE"

-- Player count text
Configuration.CurrentPlayersText    = "Current Players"



// C U S T O M  T A G S

-- Customized tags use players steamID
-- Configuration.CustomUserTag["STEAM_X:X:XXXXXXX"]      = { Tag = "TAG NAME", TagColor = Color( R,G,B ) }

Configuration.CustomUserTag = {}
Configuration.CustomUserTag["STEAM_0:0:29761241"]       = { Tag = "THE MAN, THE MYTH, THE LEGEND", TagColor = Color( 121,122,123 ) }




// R A N K   S E L E C T I O N 

-- Rank Display Table
-- Configuration.RankDisplay["rank"]         = { DisplayName = "Display name you want to see", TagName = "This is the tag name that will show if the player does not have a custom tag", DisplayColor = Color( R,G,B ), TagColor = Color( R,G,B ) }

Configuration.RankDisplay = {}
Configuration.RankDisplay["user"]           = { DisplayName = "", TagName = "USER", DisplayColor = Color( 255,255,255 ), TagColor = Color( 121,122,123 ) }
Configuration.RankDisplay["TMod"]           = { DisplayName = "Trial Mod", TagName = "TRIAL MODERATOR", DisplayColor = Color( 255,255,255 ), TagColor = Color( 121,122,123 ) }
Configuration.RankDisplay["admin"]          = { DisplayName = "Administrator", TagName = "ADMINISTRATOR", DisplayColor = Color( 255,255,255 ), TagColor = Color( 121,122,123 ) }  
Configuration.RankDisplay["superadmin"]     = { DisplayName = "Super Admin", TagName = "SUPPORT STAFF", DisplayColor = Color( 255,155,0 ), TagColor = Color( 121,122,123 ) }
Configuration.RankDisplay["developer"]      = { DisplayName = "Developer", TagName = "DEVELOPER", DisplayColor = Color( 255,155,0 ), TagColor = Color( 121,122,123 ) }
Configuration.RankDisplay["Owner"]          = { DisplayName = "Owner", TagName = "OWNER", DisplayColor = Color( 255,255,255 ), TagColor = Color( 121,122,123 ) }



// C O M M A N D  C O N F I G U R A T I O N

-- Who has access to remove players props, this uses FPP system
Configuration.PropAccess            = { "admin", "superadmin", "Owner" }

-- Who can see the administrative buttons
Configuration.MenuAccess            = { "Moderator", "admin", "superadmin", "Owner" }

-- Allow precise control for commands, if true then set the tables below to what ranks have access otherwise Configuration.MenuAccess determines allowed ranks.
Configuration.SeperateAccess        = false

-- If seperate access is true, configure below.
-- Who has access to goto
Configuration.AllowedGoto           = { "Moderator", "admin", "superadmin", "Owner" }
-- Who has access to bring
Configuration.AllowedBring          = { "Moderator", "admin", "superadmin", "Owner" }
-- Who has access to spectate
Configuration.AllowedSpectate       = { "Moderator", "admin", "superadmin", "Owner" }
-- Who has access to freeze
Configuration.AllowedFreeze         = { "Moderator", "admin", "superadmin", "Owner" }
-- Who has access to kick
Configuration.AllowedKick           = { "Moderator", "admin", "superadmin", "Owner" }
-- Who has access to ban
Configuration.AllowedBan            = { "Moderator", "admin", "superadmin", "Owner" }

-- Ban time
Configuration.CommandBanTime        = 120



// U N D E R  C O V E R  M O D E

-- Who has access to go incognito?
Configuration.IncognitoAccess       = { "admin", "superadmin", "Owner" }
-- Who can see who is incognito mode?
Configuration.IncognitoVision       = { "admin", "superadmin", "Owner" }
-- Use the custom icon for profile picture, if false will use players original profile picture
Configuration.UseCustomIcon         = true

-- Lowest money selected
Configuration.LowestMoney           = 12732
-- Highest money selected
Configuration.HighestMoney          = 67324

-- Lowest kills selected
Configuration.LowestKills           = 0
-- Highest kills selected
Configuration.HighestKills          = 2

-- Lowest deaths selected
Configuration.LowestDeaths          = 0
-- Highest deaths selected
Configuration.HighestDeaths         = 2

-- List of names randomly selected for incognito
Configuration.UndercoverNames       = { 

"Trembled", "ROcky", "Stan8", "Danny 42", "Deeep", "Venomz", "Harrryyy", "Dimitri", "Corbs912", "Shapey Boi", "NewbS", "Statix", "Dreamin", "TrumpY", "Stackd",
"Clappedd", "Shenzi", "Fatal", "Turbo12", "ExDee Hehe", "Never Get Dis", "BrokenKid1", "Dollars Plz", "SkippY", "EndeRRs", "Jimma 28", "Garry Newman", "Assa55inz", "SumBowdy Come Get ER"

}



// A D M I N I S T R A T I O N  P R E F I X

// Below is administration prefix for commands, do not edit below unless you know what to do

//////////////////////////////////////////////////////////////////////////

// U L X

Configuration.Administration = {}
Configuration.Administration["ulx"] = {}
Configuration.Administration["ulx"].goto = function(cmdPly)
    RunConsoleCommand("ulx", "goto", cmdPly:Nick())
end

Configuration.Administration["ulx"].bring = function(cmdPly)
    RunConsoleCommand("ulx", "bring", cmdPly:Nick())
end

Configuration.Administration["ulx"].freeze = function(cmdPly)
    RunConsoleCommand("ulx", "bring", cmdPly:Nick())
    RunConsoleCommand("ulx", "freeze", cmdPly:Nick())
end

Configuration.Administration["ulx"].unfreeze = function(cmdPly)
    RunConsoleCommand("ulx", "unfreeze", cmdPly:Nick())
end

Configuration.Administration["ulx"].send = function(cmdPly)
    RunConsoleCommand("ulx", "return", cmdPly:Nick())
end

Configuration.Administration["ulx"].spectate = function(cmdPly)
    RunConsoleCommand("ulx", "spectate", cmdPly:Nick())
end

Configuration.Administration["ulx"].ban = function(cmdPly, time, reason)
    RunConsoleCommand("ulx", "ban", cmdPly:Nick(), time, reason)
end

Configuration.Administration["ulx"].kick = function(cmdPly, reason)
    RunConsoleCommand("ulx", "kick", cmdPly:Nick(), reason)
end

// S A M  A D M I N

Configuration.Administration["sam"] = {}
Configuration.Administration["sam"].goto = function(cmdPly)
    RunConsoleCommand("sam", "goto", cmdPly:Nick())
end

Configuration.Administration["sam"].bring = function(cmdPly)
    RunConsoleCommand("sam", "bring", cmdPly:Nick())
end

Configuration.Administration["sam"].freeze = function(cmdPly)
    RunConsoleCommand("sam", "bring", cmdPly:Nick())
    RunConsoleCommand("sam", "freeze", cmdPly:Nick())
end

Configuration.Administration["sam"].unfreeze = function(cmdPly)
    RunConsoleCommand("sam", "unfreeze", cmdPly:Nick())
end

Configuration.Administration["sam"].send = function(cmdPly)
    RunConsoleCommand("sam", "return", cmdPly:Nick())
end

Configuration.Administration["sam"].spectate = function(cmdPly)
    RunConsoleCommand("sam", "spectate", cmdPly:Nick())
end

Configuration.Administration["sam"].ban = function(cmdPly, time, reason)
    RunConsoleCommand("sam", "ban", cmdPly:Nick(), time, reason)
end

Configuration.Administration["sam"].kick = function(cmdPly, reason)
    RunConsoleCommand("sam", "kick", cmdPly:Nick(), reason)
end

// F  A D M I N

Configuration.Administration["fadmin"] = {}
Configuration.Administration["fadmin"].goto = function(cmdPly)
    RunConsoleCommand("fadmin", "goto", cmdPly:Nick())
end

Configuration.Administration["fadmin"].bring = function(cmdPly)
    RunConsoleCommand("fadmin", "bring", cmdPly:Nick())
end

Configuration.Administration["fadmin"].freeze = function(cmdPly)
    RunConsoleCommand("fadmin", "bring", cmdPly:Nick())
    RunConsoleCommand("fadmin", "freeze", cmdPly:Nick())
end

Configuration.Administration["fadmin"].unfreeze = function(cmdPly)
    RunConsoleCommand("fadmin", "unfreeze", cmdPly:Nick())
end

Configuration.Administration["fadmin"].send = function(cmdPly)
    RunConsoleCommand("fadmin", "return", cmdPly:Nick())
end

Configuration.Administration["fadmin"].spectate = function(cmdPly)
    RunConsoleCommand("fadmin", "spectate", cmdPly:Nick())
end

Configuration.Administration["fadmin"].ban = function(cmdPly, time, reason)
    RunConsoleCommand("fadmin", "ban", cmdPly:Nick(), time, reason)
end

Configuration.Administration["fadmin"].kick = function(cmdPly, reason)
    RunConsoleCommand("fadmin", "kick", cmdPly:Nick(), reason)
end

// S E R V E R  G U A R D

Configuration.Administration["serverguard"] = {}
Configuration.Administration["serverguard"].goto = function(cmdPly)
    RunConsoleCommand("sg", "goto", cmdPly:Nick())
end

Configuration.Administration["serverguard"].bring = function(cmdPly)
    RunConsoleCommand("sg", "bring", cmdPly:Nick())
end

Configuration.Administration["serverguard"].freeze = function(cmdPly)
    RunConsoleCommand("sg", "bring", cmdPly:Nick())
    RunConsoleCommand("sg", "freeze", cmdPly:Nick())
end

Configuration.Administration["serverguard"].unfreeze = function(cmdPly)
    RunConsoleCommand("sg", "unfreeze", cmdPly:Nick())
end

Configuration.Administration["serverguard"].send = function(cmdPly)
    RunConsoleCommand("sg", "return", cmdPly:Nick())
end

Configuration.Administration["serverguard"].spectate = function(cmdPly)
    RunConsoleCommand("sg", "spectate", cmdPly:Nick())
end

Configuration.Administration["serverguard"].ban = function(cmdPly, time, reason)
    RunConsoleCommand("sg", "ban", cmdPly:Nick(), time, reason)
end

Configuration.Administration["serverguard"].kick = function(cmdPly, reason)
    RunConsoleCommand("sg", "kick", cmdPly:Nick(), reason)
end

// X  A D M I N  2

Configuration.Administration["xadmin2"] = {}
Configuration.Administration["xadmin2"].goto = function(cmdPly)
    RunConsoleCommand("xadmin", "goto", cmdPly:Nick())
end

Configuration.Administration["xadmin2"].bring = function(cmdPly)
    RunConsoleCommand("xadmin", "bring", cmdPly:Nick())
end

Configuration.Administration["xadmin2"].freeze = function(cmdPly)
    RunConsoleCommand("xadmin", "bring", cmdPly:Nick())
    RunConsoleCommand("xadmin", "freeze", cmdPly:Nick())
end

Configuration.Administration["xadmin2"].unfreeze = function(cmdPly)
    RunConsoleCommand("xadmin", "unfreeze", cmdPly:Nick())
end

Configuration.Administration["xadmin2"].send = function(cmdPly)
    RunConsoleCommand("xadmin", "return", cmdPly:Nick())
end

Configuration.Administration["xadmin2"].spectate = function(cmdPly)
    RunConsoleCommand("xadmin", "spectate", cmdPly:Nick())
end

Configuration.Administration["xadmin2"].ban = function(cmdPly, time, reason)
    RunConsoleCommand("xadmin", "ban", cmdPly:Nick(), time, reason)
end

Configuration.Administration["xadmin2"].kick = function(cmdPly, reason)
    RunConsoleCommand("xadmin", "kick", cmdPly:Nick(), reason)
end

// X  A D M I N  1

Configuration.Administration["xadmin"] = {}
Configuration.Administration["xadmin"].goto = function(cmdPly)
    RunConsoleCommand("xadmin_goto", "goto", cmdPly:Nick())
end

Configuration.Administration["xadmin"].bring = function(cmdPly)
    RunConsoleCommand("xadmin_bring", "bring", cmdPly:Nick())
end

Configuration.Administration["xadmin"].freeze = function(cmdPly)
    RunConsoleCommand("xadmin_bring", "bring", cmdPly:Nick())
    RunConsoleCommand("xadmin_freeze", "freeze", cmdPly:Nick())
end

Configuration.Administration["xadmin"].unfreeze = function(cmdPly)
    RunConsoleCommand("xadmin_unfreeze", "unfreeze", cmdPly:Nick())
end

Configuration.Administration["xadmin"].send = function(cmdPly)
    RunConsoleCommand("xadmin_return", "return", cmdPly:Nick())
end

Configuration.Administration["xadmin"].spectate = function(cmdPly)
    RunConsoleCommand("xadmin_spectate", "spectate", cmdPly:Nick())
end

Configuration.Administration["xadmin"].ban = function(cmdPly, time, reason)
    RunConsoleCommand("xadmin_ban", "ban", cmdPly:Nick(), time, reason)
end

Configuration.Administration["xadmin"].kick = function(cmdPly, reason)
    RunConsoleCommand("xadmin_kick", "kick", cmdPly:Nick(), reason)
end