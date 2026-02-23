-- Translation by Livaco 
-- https://www.gmodstore.com/users/Livaco
UltimatePartySystem.Languages["en"] = {
    netCooldown = "You are sending too many requests to the server. Please wait a few seconds.", -- Message to a user who is trying to spam net messages like a bad boi.

    --
    -- Chat Messages
    --
    openingWindow = "Opening party window...", -- Message when the user is opening the Party Window.
    noPermission = "You do not have permission to access this.", -- No permission.
    configUpdate = "The config has been updated.", -- Config updated.
    configReset = "The config has been reset successfully.", -- Config reset.

    partyCreationAlreadyOwned = "You already own a party.", -- User trying to make a party while already owning one.
    partyCreationNameTooLong = "Your name is too long, must not be longer than %s characters.", -- Party name is too long. %s is the amount of characters.
    partyCreationTooManySlots = "Your party cannot have more than %s slots.", -- Party tried to have too many slots. %s is the amount of slots.
    partyCreationTooLittleSlots = "Your party cannot have less than 2 slots.", -- Party tried to have less than 2 slots.
    partyCreationCannotAfford = "You cannot afford the %s fee to create this party.", -- Can't afford to make a party. %s is the fee for making a party.
    partyCreationSuccessfull = "Your party '%s' has been created.", -- Party created. %s is the name of the party.

    partyInviteOof = "You do not own a party.", -- Player tries to invite a player to a party when they don't own one.
    partyInviteAlreadyIn = "%s is already in a party.", -- Player invited to party when they are already in a party. %s is the player name.
    partyInviteDone = "%s invited %s to the party.", -- Player invites another player to a lobby. %s is the invitee, followed by the invited.
    partyInvited = "%s invited you to '%s'. Accept this invite in the Party UI.", -- Player invited to party. %s is the invitee, followed by the party name.
    partyInviteTimeout = "%s's invite has timed out.", -- Party invite timed out. %s is the inviter.
    partyInviteTimeoutOwner = "Your party invite to %s has timed out.", -- Owner informed Party invite timed out. %s is the invited.

    partyJoinAlreadyIn = "You are already in a party.", -- Player tries to join a party while already being in one.
    partyJoinDoesNotExist = "That party does not exist.", -- Player tries to join a party that doesn't exist.
    partyJoinIsFull = "That party is full.", -- Party is full.
    partyJoinSuccess = "You have joined party '%s'.", -- Player joined a party. %s is the party name.

    partyLeaveSuccess = "You have left party '%s'.", -- Player leaving a party. %s is the party name.
    partyLeaveFromKicked = "You have been kicked from party '%s'.", -- Player being kicked from a party. %s is the party name.

    partyLeaveDisbanded = "The party '%s' has been disbanded, so you have been removed.", -- Party has been deleted. %s is the party name.

    partyOwnerPlayerJoin = "%s has joined your party.", -- Player joined a party. %s is the party name.
    partyOwnerPlayerLeave = "'%s' has left your party.", -- Player leaving a party. %s is the users name.
    partyOwnerPlayerDisconnect = "%s disconnected and has left your party.", -- Player disconnected forcing them out the party. %s is the player name.
    partyOwnerPlayerKicked = "%s has been kicked.", -- Player kicked from the party. %s is the name.
    partyOwnerPartyDisband = "Your party '%s' has been disbanded.", -- Party disbanded. %s is the party name.

    partyOwnerEditOof = "You do not own a party.", -- Player tries to change party without owning it.
    partyOwnerEditNotEnoughSlotsForPlayers = "Your slot count cannot be lower than the amount of players in your party.", -- Player tries to change party slots to be lower than the player count.
    partyOwnerEditSuccess = "Your party has been updated.", -- Player updates their party's settings successfully.

    partyOwnerDeleteOof = "You do not own a party.", -- Player tries to delete a party without owning it.

    partyOwnerKickNotFound = "Could not find that player.", -- Player tries to kick a nonexistent player from their party.
    partyOwnerKickOof = "You do not own a party.", -- Player tries to kick a player from their party without owning one.

    partyChatPrefix = "[Party Chat] %s >>", -- Party Chat prefix. %s is the player's name.


    --
    -- VGUI
    --
    primaryWindowTitle = "PARTY SYSTEM", -- Main Window title. All caps for a s t e t i c s.
    primaryWindowViewPartiesTab = "View Parties", -- View Parties button.
    primaryWindowCreatePartyTab = "Create Party", -- Create Party button.
    primaryWindowViewPartyTab = "View Party", -- View Party button.
    primaryWindowSettingsTab = "Settings", -- Settings button.

    viewPartyOwnedBy = "Owned By %s", -- Party owned by text. %s is the user's name.
    viewPartyInside = "You are already in a party.", -- Text is user is viewing a party they're in.
    viewPartySlots = "%s/%s Slots Taken", -- Party slots text. %s is the players in the party, followed by the total slots.
    viewPartyJoin = "JOIN PARTY", -- Join Party text.
    viewPartyAcceptInvite = "ACCEPT INVITE", -- Accept Invite text.
    viewPartyLeave = "LEAVE", -- Leave button.
    thereIsNoPartyTakeOffYourClothes = "There is no parties right now.", -- No partys.

    createPartyName = "What would you like to name your Party?", -- Name of a new party field.
    createPartyPrivate = "Private Party?", -- Private party field.
    createPartySlots = "Number of Slots", -- Slots field.
    createPartyOwners = "Add Owners", -- Other Owners header.
    createPartySubmit = "CREATE PARTY", -- Create Party button.
    createPartySubmitCostly = "CREATE PARTY (COSTS %s)", -- Create Party button if there is a cost too. %s it the formatted cost.

    viewPartyEditHeader = "EDIT PARTY", -- Edit Party header when viewing your own party.
    viewPartyEditPrivate = "Private Party?", -- Edit Party private party header.
    viewPartyEditSlots = "Number of Slots", -- Edit Party slots header.
    viewPartyEditSaveButton = "SAVE SETTINGS", -- Save party settings button.
    viewPartyEditDeleteButton = "DELETE PARTY", -- Delete party button.
    viewPartyPlayerListHeader = "PLAYER LIST", -- Player List.
    viewPartyPlayerListOwner = "(Owner)", -- Owner on the Player List.
    viewPartyPlayerListInvite = "INVITE PLAYERS", -- Invite Players button.

    deletePartyTitle = "Delete Party?", -- Title for the delete party vgui.
    deletePartyButton = "Confirm", -- Confirm Button for the delete party vgui.

    invitePlayerTitle = "Invite a Player to your Party", -- Invite a player vgui title.
    invitePlayerMessage = "Select a player to invite.", -- Message inside the VGUI.
    invitePlayerButton = "Send Invitation", -- Message inside the VGUI.

    configWindowTitle = "ULTIMATE PARTY SYSTEM CONFIG", -- Config Window title
    configResetHeader = "Are you sure you want to reset the entire confg?", -- Config Reset Header
    configResetSubHeader = "This cannot be undone.", -- Config Reset Sub-Header
    configResetConfirmButton = "I'm a big boy and know what I'm doing. Reset it.", -- Config Reset Button

    cancelButton = "CANCEL", -- Cancel button.


    --
    -- Config Localisation
    --
    -- Fuck off if you think for a SECOND im commenting all this fucking shit. Figure it out youself. I'm writing these localisation vars at 2:20am on a school night, gimme a fuckin break.

    -- General
    configPrefixName = "Prefix",
    configPrefixDescription = "The prefix for all chat messages.",

    configPrefixColorName = "Prefix Color",
    configPrefixColorDescription = "The color of the prefix.",

    configMessageColorName = "Message Color",
    configMessageColorDescription = "The color of the rest of a message.",

    configThemeColorName = "Theme Color",
    configThemeColorDescription = "The theme color of every UI.",

    configMoneyFormatName = "Money Format",
    configMoneyFormatDescription = "How money is formatted. %s is the amount of money with commas.",

    -- User Interface
    configChatCommandName = "Chat Command",
    configChatCommandDescription = "The command for opening the UI.",

    configHideCommandName = "Hide Chat Command",
    configHideCommandDescription = "If the chat command should be hidden from chat when used.",

    configUIMessageName = "Show UI Opening Message",
    configHideCommandDescription = "If the addon should send a chat message when the UI is opened.",

    -- Parties
    configMaxNameLengthName = "Maximum Party Name Length",
    configMaxNameLengthDescription = "The maximum length a Party Name can have.",

    configAllowPrivatePartiesName = "Allow Private Parties",
    configAllowPrivatePartiesDescription = "If users can make private parties.",

    configMaxSlotsName = "Maximum Slots",
    configMaxSlotsDescription = "The maximum slots a party can have.",

    configDefaultSlotsName = "Default Slots",
    configDefaultSlotsDescription = "The default amount of slots a party has.",

    configPartyCreationCostName = "Party Creation Price",
    configPartyCreationCostDescription = "How much creating a party costs. Set this to zero for no cost.",

    -- Misc
    configRadioEnabledName = "Radio Enabled",
    configRadioEnabledDescription = "Enables the Radio feature.",

    configMarkerEnabledName = "Markers Enabled",
    configMarkerEnabledDescription = "Enables the Marker feature.",

    configInviteTimeoutName = "Party Invite Timeout",
    configInviteTimeoutDescription = "How much time should pass before a party invite is timed out in seconds.",

    configEnableFriendlyFireName = "Enable Friendly Fire",
    configEnableFriendlyFireDescription = "If the addon should enable friendly fire for two people in the same party.",

    configEnablePartyChatName = "Enable Party Chat",
    configEnablePartyChatDescription = "If the addon should enable the party chat feature.",

    configPartyChatCommandName = "Party Chat Command",
    configPartyChatCommandDescription = "The command for sending to Party Chat.",

    -- Client Based Settings
    clientConfigDrawHUDName = "Draw HUD",
    clientConfigDrawHUDDescription = "Draw the Party HUD.",

    clientConfigHUDXName = "HUD X Offset",
    clientConfigHUDXDescription = "The X position offset for the HUD.",

    clientConfigHUDYName = "HUD Y Offset",
    clientConfigHUDYDescription = "The Y position offset for the HUD.",

    clientConfigHUDOpacityName = "HUD Opacity",
    clientConfigHUDOpacityDescription = "The opacity of the HUD.",

    clientConfigDrawMarkersName = "Draw Markers",
    clientConfigDrawMarkersDescription = "If the addon should draw markers.",

    clientConfigDisplayPartyChatName = "Display Party Chat",
    clientConfigDisplayPartyChatDescription = "If the addon should display party chat messages.",
}