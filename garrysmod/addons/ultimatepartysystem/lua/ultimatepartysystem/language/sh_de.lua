-- Translation by Deltaa 
-- https://www.gmodstore.com/users/76561198297420399
UltimatePartySystem.Languages["de"] = {
    netCooldown = "Du sendest zu viele Anfragen an den Server, bitte warte einen Moment!", -- Message to a user who is trying to spam net messages like a bad boi.

    --
    -- Chat Messages
    --
    openingWindow = "Öffne Partyfenster...", -- Message when the user is opening the Party Window.
    noPermission = "Dir fehlen die notwendigen Zugriffsrechte!", -- No permission.
    configUpdate = "Die Config wurde erfolgreich aktualisiert.", -- Config updated.
    configReset = "Die Config wurde erfolgreich zurückgesetzt.", -- Config reset.

    partyCreationAlreadyOwned = "Du besitzt bereits eine Party.", -- User trying to make a party while already owning one.
    partyCreationNameTooLong = "Dein Name ist zu lang, dieser darf nicht länger als %s Buchstaben sein.", -- Party name is too long. %s is the amount of characters.
    partyCreationTooManySlots = "Deine Party kann nicht mehr als %s Slots haben.", -- Party tried to have too many slots. %s is the amount of slots.
    partyCreationTooLittleSlots = "Deine Party kann nicht weniger als 2 Slots haben.", -- Party tried to have less than 2 slots.
    partyCreationCannotAfford = "Du kannst dir die %s Erstellungsgebühr für deine Party nicht leisten.", -- Can't afford to make a party. %s is the fee for making a party.
    partyCreationSuccessfull = "Deine Party '%s' wurde erfolgreich erstellt.", -- Party created. %s is the name of the party.

    partyInviteOof = "Du besitzt keine Party.", -- Player tries to invite a player to a party when they don't own one.
    partyInviteAlreadyIn = "%s ist bereits Mitglied einer Party.", -- Player invited to party when they are already in a party. %s is the player name.
    partyInviteDone = "%s hat %s in die Party eingeladen.", -- Player invites another player to a lobby. %s is the invitee, followed by the invited.
    partyInvited = "%s hat dich in die Party '%s' eingeladen. Akzeptiere die Anfrage im Partymenü.", -- Player invited to party. %s is the invitee, followed by the party name.
    partyInviteTimeout = "%s's Einladung ist ausgelaufen.", -- Party invite timed out. %s is the inviter.
    partyInviteTimeoutOwner = "Deine Partyeinladung an %s ist ausgelaufen.", -- Owner informed Party invite timed out. %s is the invited.

    partyJoinAlreadyIn = "Du bist bereits Mitglied einer Party.", -- Player tries to join a party while already being in one.
    partyJoinDoesNotExist = "Die Party existiert nicht.", -- Player tries to join a party that doesn't exist.
    partyJoinIsFull = "Diese Party ist voll.", -- Party is full.
    partyJoinSuccess = "Du bist der Party '%s' beigetreten.", -- Player joined a party. %s is the party name.

    partyLeaveSuccess = "Du hast die Party '%s' verlassen.", -- Player leaving a party. %s is the party name.
    partyLeaveFromKicked = "Du wurdest aus der Party '%s' geworfen.", -- Player being kicked from a party. %s is the party name.

    partyLeaveDisbanded = "Die Party '%s' wurde aufgelöst, dadurch wurdest du aus dieser entfernt.", -- Party has been deleted. %s is the party name.

    partyOwnerPlayerJoin = "%s ist deiner Party beigetreten.", -- Player joined a party. %s is the party name.
    partyOwnerPlayerLeave = "'%s' hat deine Party verlassen.", -- Player leaving a party. %s is the users name.
    partyOwnerPlayerDisconnect = "%s hat den Server verlassen und ist damit der Party ausgetreten.", -- Player disconnected forcing them out the party. %s is the player name.
    partyOwnerPlayerKicked = "%s wurde aus der Party gekickt.", -- Player kicked from the party. %s is the name.
    partyOwnerPartyDisband = "Deine Party '%s' wurde aufgelöst.", -- Party disbanded. %s is the party name.

    partyOwnerEditOof = "Du besitzt keine Party.", -- Player tries to change party without owning it.
    partyOwnerEditNotEnoughSlotsForPlayers = "Deine Slotanzahl kann nicht niedriger sein, als die Anzahl der Spieler in deiner Party.", -- Player tries to change party slots to be lower than the player count.
    partyOwnerEditSuccess = "Deine Party hat sich aktualisiert.", -- Player updates their party's settings successfully.

    partyOwnerDeleteOof = "Du besitzt keine Party.", -- Player tries to delete a party without owning it.

    partyOwnerKickNotFound = "Der Spieler konnte nicht gefunden werden.", -- Player tries to kick a nonexistent player from their party.
    partyOwnerKickOof = "Du besitzt diese Party nicht.", -- Player tries to kick a player from their party without owning one.

    partyChatPrefix = "[Party Chat] %s >>", -- Party Chat prefix. %s is the player's name.

    
    --
    -- VGUI
    --
    primaryWindowTitle = "PARTY SYSTEM", -- Main Window title. All caps for a s t e t i c s.
    primaryWindowViewPartiesTab = "Partys ansehen", -- View Parties button.
    primaryWindowCreatePartyTab = "Party erstellen", -- Create Party button.
    primaryWindowViewPartyTab = "Party ansehen", -- View Party button.
    primaryWindowSettingsTab = "Einstellungen", -- Settings button.

    viewPartyOwnedBy = "Gehört %s", -- Party owned by text. %s is the user's name.
    viewPartyInside = "Du bist bereits in einer Party.", -- Text is user is viewing a party they're in.
    viewPartySlots = "%s/%s Slots besetzt", -- Party slots text. %s is the players in the party, followed by the total slots.
    viewPartyJoin = "BEITRETEN", -- Join Party text.
    viewPartyAcceptInvite = "EINLADUNG AKZEPTIEREN", -- Accept Invite text.
    viewPartyLeave = "VERLASSEN", -- Leave button.
    thereIsNoPartyTakeOffYourClothes = "Aktuell gibt es keine Partys.", -- No partys.

    createPartyName = "Was soll der Party-Name sein?", -- Name of a new party field.
    createPartyPrivate = "Private Party?", -- Private party field.
    createPartySlots = "Anzahl an Slots", -- Slots field.
    createPartyOwners = "Besitzer hinzufügen", -- Other Owners header.
    createPartySubmit = "PARTY ERSTELLEN", -- Create Party button.
    createPartySubmitCostly = "ERSTELLE PARTY (KOSTET %s)", -- Create Party button if there is a cost too. %s it the formatted cost.

    viewPartyEditHeader = "BEARBEITE PARTY", -- Edit Party header when viewing your own party.
    viewPartyEditPrivate = "Private Party?", -- Edit Party private party header.
    viewPartyEditSlots = "Anzahl an Slots", -- Edit Party slots header.
    viewPartyEditSaveButton = "Speichere Einstellungen", -- Save party settings button.
    viewPartyEditDeleteButton = "LÖSCHE PARTY", -- Delete party button.
    viewPartyPlayerListHeader = "SPIELERLISTE", -- Player List.
    viewPartyPlayerListOwner = "(Besitzer)", -- Owner on the Player List.
    viewPartyPlayerListInvite = "SPIELER EINLADEN", -- Invite Players button.

    deletePartyTitle = "Lösche Party?", -- Title for the delete party vgui.
    deletePartyButton = "Bestätigen", -- Confirm Button for the delete party vgui.

    invitePlayerTitle = "Lade einen Spieler in deine Party ein.", -- Invite a player vgui title.
    invitePlayerMessage = "Wähle einen Spieler den du einladen möchtest.", -- Message inside the VGUI.
    invitePlayerButton = "Einladung senden", -- Message inside the VGUI.

    configWindowTitle = "ULTIMATE PARTY SYSTEM CONFIG", -- Config Window title
    configResetHeader = "Möchtest du wirklich die GESAMTE CONFIG zurücksetzen?", -- Config Reset Header
    configResetSubHeader = "Dies kann nicht wiederhergestellt werden!", -- Config Reset Sub-Header
    configResetConfirmButton = "Ich bestätige die Zurücksetzung", -- Config Reset Button

    cancelButton = "ABBRUCH", -- Cancel button.


    --
    -- Config Localisation
    --
    -- Fuck off if you think for a SECOND im commenting all this fucking shit. Figure it out youself. I'm writing these localisation vars at 2:20am on a school night, gimme a fuckin break.

    -- General
    configPrefixName = "Prefix",
    configPrefixDescription = "Der Prefix aller Chatnachrichten.",

    configPrefixColorName = "Prefix Color",
    configPrefixColorDescription = "Die Farbe des Prefix",

    configMessageColorName = "Nachrichtenfarbe",
    configMessageColorDescription = "Der Farbe des Rests einer Nachricht.",

    configThemeColorName = "Theme Color",
    configThemeColorDescription = "Die Themecolor von jedem UI.",

    configMoneyFormatName = "Geldformat",
    configMoneyFormatDescription = "Wie das Geld formattiert ist. %s ist der Geldbetrag mit Kommas.",

    -- User Interface
    configChatCommandName = "Chatbefehl",
    configChatCommandDescription = "Der Befehl um das Menü zu öffnen.",

    configHideCommandName = "Verstecke Chatbefehl",
    configHideCommandDescription = "Ob der Chatbefehl versteckt werden soll, wenn er benutzt wurde.",

    configUIMessageName = "UI-Eröffnungsnachricht anzeigen",
    configHideCommandDescription = "Ob das Addon beim Öffnen des Menüs eine Chat-Nachricht senden soll.",

    -- Parties
    configMaxNameLengthName = "Maximaler Partyname",
    configMaxNameLengthDescription = "Die maximale Länge des Partynamens.",

    configAllowPrivatePartiesName = "Erlaube private Partys",
    configAllowPrivatePartiesDescription = "Ob Spieler private Partys erstellen können.",

    configMaxSlotsName = "Maximale Slots",
    configMaxSlotsDescription = "Das Maximum an Partyslots.",

    configDefaultSlotsName = "Standard Slots",
    configDefaultSlotsDescription = "Die standardmäßige Anzahl an Slots für eine Party",

    configPartyCreationCostName = "Preis für eine Party",
    configPartyCreationCostDescription = "Wie viel soll eine Party kosten? 0 heißt es ist kostenlos.",

    configDisableFriendlyFireName = "Deaktiviere Teambeschuss",
    configDisableFriendlyFireDescription = "Ob das Addon den Teambeschuss von 2 Spielern in der selben Party deaktivieren soll.",

    -- Misc
    configRadioEnabledName = "Funk aktiviert",
    configRadioEnabledDescription = "Aktiviere das Funk Feature",

    configMarkerEnabledName = "Markierungen aktiviert",
    configMarkerEnabledDescription = "Aktiviere das Markierungsfeature.",

    configInviteTimeoutName = "Partyeinladung - Auslaufen",
    configInviteTimeoutDescription = "Wie viel Zeit soll vergehen, bevor eine Partyeinladung ausläuft?",

    configEnablePartyChatName = "Aktiviere Partychat",
    configEnablePartyChatDescription = "Ob das Addon den Partychat aktivieren soll",

    configPartyChatCommandName = "Partychat-Befehl",
    configPartyChatCommandDescription = "Der Befehl um eine Nachricht den Partychat zu senden.",

    -- Client Based Settings
    clientConfigDrawHUDName = "Zeichne HUD",
    clientConfigDrawHUDDescription = "Zeichne das Party-HUD.",

    clientConfigHUDXName = "HUD X Versatz",
    clientConfigHUDXDescription = "Der X-Positionsversatz für das HUD.",

    clientConfigHUDYName = "HUD Y Versatz",
    clientConfigHUDYDescription = "Der Y-Positionsversatz für das HUD.",

    clientConfigHUDOpacityName = "HUD Deckkraft",
    clientConfigHUDOpacityDescription = "Die Deckkraft für das HUD",

    clientConfigDrawMarkersName = "Zeichne Markierungen",
    clientConfigDrawMarkersDescription = "Ob das Addon Markierungen zeichnen soll",

    clientConfigDisplayPartyChatName = "Zeige Partychat Nachrichten",
    clientConfigDisplayPartyChatDescription = "Ob das Addon Partychat Nachrichten anzeigen soll.",
}