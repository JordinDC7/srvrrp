-- Translation by Sunshio
-- https://www.gmodstore.com/users/Sunshio
UltimatePartySystem.Languages["fr"] = {
    netCooldown = "Vous envoyez trop de requetes au serveur. Merci d'attendre quelques secondes.", -- Message to a user who is trying to spam net messages like a bad boi.

    --
    -- Chat Messages
    --
    openingWindow = "Ouverture de la fenetre des parties...", -- Message when the user is opening the Party Window.
    noPermission = "Vous n'avez pas les permissions pour effectuer cette action.", -- No permission.
    configUpdate = "La configuration a été mise à jour.", -- Config updated.
    configReset = "La configuration a été réinitialisée avec succès.", -- Config reset.

    partyCreationAlreadyOwned = "Vous gérez déjà une partie.", -- User trying to make a party while already owning one.
    partyCreationNameTooLong = "Le nom de la partie est trop long, il ne doit pas etre supérieur à %s caractères.", -- Party name is too long. %s is the amount of characters.
    partyCreationTooManySlots = "La partie ne peut pas avoir plus de %s slots.", -- Party tried to have too many slots. %s is the amount of slots.
    partyCreationTooLittleSlots = "La partie ne peut pas avoir moins de 2 slots.", -- Party tried to have less than 2 slots.
    partyCreationCannotAfford = "Vous ne pouvez pas vous permettre de payer %s de frais pour créer cette partie.", -- Can't afford to make a party. %s is the fee for making a party.
    partyCreationSuccessfull = "La partie '%s' a été créée.", -- Party created. %s is the name of the party.

    partyInviteOof = "Vous ne possédez pas cette partie.", -- Player tries to invite a player to a party when they don't own one.
    partyInviteAlreadyIn = "%s est déjà dans la partie.", -- Player invited to party when they are already in a party. %s is the player name.
    partyInviteDone = "%s a été invité %s dans la partie.", -- Player invites another player to a lobby. %s is the invitee, followed by the invited.
    partyInvited = "%s vous a invité dans '%s'. Acceptez cette invitation dans l'UI des parties.", -- Player invited to party. %s is the invitee, followed by the party name.
    partyInviteTimeout = "L'invitation de %s a expiré.", -- Party invite timed out. %s is the inviter.
    partyInviteTimeoutOwner = "Votre invitation pour %s a expiré.", -- Owner informed Party invite timed out. %s is the invited.

    partyJoinAlreadyIn = "Vous faites déjà partie d'une partie.", -- Player tries to join a party while already being in one.
    partyJoinDoesNotExist = "Cette partie n'existe pas.", -- Player tries to join a party that doesn't exist.
    partyJoinIsFull = "Cette partie est compléte.", -- Party is full.
    partyJoinSuccess = "Vous avez rejoint la partie '%s'.", -- Player joined a party. %s is the party name.

    partyLeaveSuccess = "Vous avez quitté la partie '%s'.", -- Player leaving a party. %s is the party name.
    partyLeaveFromKicked = "Vous avez été expulsé de la partie '%s'.", -- Player being kicked from a party. %s is the party name.

    partyLeaveDisbanded = "La partie '%s' a été dissoute, vous avez donc été retiré de celle-ci.", -- Party has been deleted. %s is the party name.

    partyOwnerPlayerJoin = "%s a rejoint la partie.", -- Player joined a party. %s is the party name.
    partyOwnerPlayerLeave = "'%s' a quitté la partie.", -- Player leaving a party. %s is the users name.
    partyOwnerPlayerDisconnect = "%s vient de déconnecter et de quitter la partie.", -- Player disconnected forcing them out the party. %s is the player name.
    partyOwnerPlayerKicked = "%s a été expulsé .", -- Player kicked from the party. %s is the name.
    partyOwnerPartyDisband = "La partie '%s' a été dissoute.", -- Party disbanded. %s is the party name.

    partyOwnerEditOof = "Vous ne gérez pas cette partie.", -- Player tries to change party without owning it.
    partyOwnerEditNotEnoughSlotsForPlayers = "Le nombre de slot ne peut pas être plus bas que le nombre nombre de joueurs dans la partie.", -- Player tries to change party slots to be lower than the player count.
    partyOwnerEditSuccess = "La partie a été mise à jour.", -- Player updates their party's settings successfully.

    partyOwnerDeleteOof = "Vous ne gérez pas cette partie.", -- Player tries to delete a party without owning it.

    partyOwnerKickNotFound = "Impossible de trouver ce joueur.", -- Player tries to kick a nonexistent player from their party.
    partyOwnerKickOof = "Vous ne gérez pas cette partie.", -- Player tries to kick a player from their party without owning one.

    partyChatPrefix = "[Discussion de groupe] %s >>", -- Party Chat prefix. %s is the player's name.

    --
    -- VGUI
    --
    primaryWindowTitle = "GESTIONNAIRE DE PARTIES", -- Main Window title. All caps for a s t e t i c s.
    primaryWindowViewPartiesTab = "Voir les parties", -- View Parties button.
    primaryWindowCreatePartyTab = "Créer une partie", -- Create Party button.
    primaryWindowViewPartyTab = "Voir la partie", -- View Party button.
    primaryWindowSettingsTab = "Paramètres", -- Settings button.

    viewPartyOwnedBy = "Possédée par %s", -- Party owned by text. %s is the user's name.
    viewPartyInside = "Vous etes déjà dans une partie.", -- Text is user is viewing a party they're in.
    viewPartySlots = "%s/%s Slots occupés", -- Party slots text. %s is the players in the party, followed by the total slots.
    viewPartyJoin = "REJOINDRE LA PARTIE", -- Join Party text.
    viewPartyAcceptInvite = "ACCEPTER L'INVITATION", -- Accept Invite text.
    viewPartyLeave = "QUITTER", -- Leave button.
    thereIsNoPartyTakeOffYourClothes = "Il n'y a pas de parties en cours.", -- No partys.

    createPartyName = "Comment voulez-vous nommer votre partie ?", -- Name of a new party field.
    createPartyPrivate = "Partie privée ?", -- Private party field.
    createPartySlots = "Nombre de Slots", -- Slots field.
    createPartyOwners = "Ajouter des propriétaires", -- Other Owners header.
    createPartySubmit = "CREER UNE PARTIE", -- Create Party button.
    createPartySubmitCostly = "CREER UNE PARTIE (COUTE %s)", -- Create Party button if there is a cost too. %s it the formatted cost.

    viewPartyEditHeader = "MODIFIER LA PARTIE", -- Edit Party header when viewing your own party.
    viewPartyEditPrivate = "Partie Privée ?", -- Edit Party private party header.
    viewPartyEditSlots = "Nombre de Slots", -- Edit Party slots header.
    viewPartyEditSaveButton = "SAUVEGARDER", -- Save party settings button.
    viewPartyEditDeleteButton = "SUPPRIMER LA PARTIE", -- Delete party button.
    viewPartyPlayerListHeader = "LISTE DES JOUEURS", -- Player List.
    viewPartyPlayerListOwner = "(Propriétaire)", -- Owner on the Player List.
    viewPartyPlayerListInvite = "INVITER DES AMIS", -- Invite Players button.

    deletePartyTitle = "Supprimer la partie ?", -- Title for the delete party vgui.
    deletePartyButton = "Confirmer", -- Confirm Button for the delete party vgui.

    invitePlayerTitle = "Inviter un joueur dans la partie", -- Invite a player vgui title.
    invitePlayerMessage = "Sélectioner un joueur à inviter.", -- Message inside the VGUI.
    invitePlayerButton = "Envoyer une invitation", -- Message inside the VGUI.

    configWindowTitle = "ULTIMATE PARTY SYSTEM CONFIG", -- Config Window title
    configResetHeader = "Etes vous sur de vouloir réinitialiser toute la configuration ?", -- Config Reset Header
    configResetSubHeader = "Vous ne pouvez pas revenir en arriere.", -- Config Reset Sub-Header
    configResetConfirmButton = "Je suis ne suis pas un idiot. Réinitialise le !", -- Config Reset Button

    cancelButton = "ANNULER", -- Cancel button.


    --
    -- Config Localisation
    --
    -- Fuck off if you think for a SECOND im commenting all this fucking shit. Figure it out youself. I'm writing these localisation vars at 2:20am on a school night, gimme a fuckin break.

    -- General
    configPrefixName = "Prefixe",
    configPrefixDescription = "Le prefixe pour tous les messages du tchat.",

    configPrefixColorName = "Couleur de prefixe",
    configPrefixColorDescription = "La couleur du prefixe.",

    configMessageColorName = "Couleur du message",
    configMessageColorDescription = "La couleur du restant du message.",

    configThemeColorName = "Couleur de thème",
    configThemeColorDescription = "La couleur du thème de chaque UI.",

    configMoneyFormatName = "Format monetaire",
    configMoneyFormatDescription = "Comment l argent est formaté. %s est le montant d argent avec des virgules.",

    -- User Interface
    configChatCommandName = "Commande du chat",
    configChatCommandDescription = "La commande pour ouvrir l'UI.",

    configHideCommandName = "Masquer la commande du tchat",
    configHideCommandDescription = "Si la commande du tchat doit être cacher à l'utilisation.",

    configUIMessageName = "Afficher le message d'ouverture de l'UI",
    configHideCommandDescription = "Si l'addon doit affiche un message à l'ouverture de l'UI.",

    -- Parties
    configMaxNameLengthName = "Taille maximale du nom de la partie",
    configMaxNameLengthDescription = "La taille maximale que peut avoir le nom de la partie.",

    configAllowPrivatePartiesName = "Autoriser les parties privées",
    configAllowPrivatePartiesDescription = "Si le joueur peut créer des parties.",

    configMaxSlotsName = "Slots Maximum",
    configMaxSlotsDescription = "Le nombre maximum de slots que peut avoir une partie.",

    configDefaultSlotsName = "Slots par défaut",
    configDefaultSlotsDescription = "Le nombre de slots par défault que la partie a.",

    configPartyCreationCostName = "Prix pour la création de parties",
    configPartyCreationCostDescription = "Combien coute la création d'une partie. Mettez le à zero si cela est gratuit.",

    configDisableFriendlyFireName = "Désactiver le tir allié",
    configDisableFriendlyFireDescription = "Si l'addon doit désactiver le tir allié entre deux personnes dans la partie.",

    clientConfigDisplayPartyChatName = "Afficher le tchat",
    clientConfigDisplayPartyChatDescription = "Si l'addon doit afficher les messages dans le tchat de la partie.",

    configEnableFriendlyFireName = "Activer le tir allié",
    configEnableFriendlyFireDescription = "Si l'addon doit activer le tir allié entre deux personnes dans la même partie.",


    configEnablePartyChatName = "Activer le tchat de la partie",
    configEnablePartyChatDescription = "Si l'addon doit activer la fonctionnalité de tchat.",

    configPartyChatCommandName = "Commande du tchat de la partie",
    configPartyChatCommandDescription = "La commande d'envoi de la partie dans le tchat.",

    -- Misc
    configRadioEnabledName = "Radio Activée",
    configRadioEnabledDescription = "Active la fonctionnalité Radio.",

    configMarkerEnabledName = "Marqueurs Activés",
    configMarkerEnabledDescription = "Active la fonctionnalité des Marqueurs.",

    configInviteTimeoutName = "Délai d'invitation pour une partie",
    configInviteTimeoutDescription = "Combien de temps doit-il s'écouler avant qu'une invitation à une partuie ne soit expirée en secondes.",

    -- Client Based Settings
    clientConfigDrawHUDName = "Afficher le HUD",
    clientConfigDrawHUDDescription = "Afficher le HUD de la partie.",

    clientConfigHUDXName = "Décalage de l'axe X du HUD",
    clientConfigHUDXDescription = "La position X du décalage de l'HUD.",

    clientConfigHUDYName = "Décalage de l'axe Y du HUD",
    clientConfigHUDYDescription = "La position Y du décalage de l'HUD.",

    clientConfigHUDOpacityName = "OPACITE DU HUD",
    clientConfigHUDOpacityDescription = "L'opacité du HUD.",

    clientConfigDrawMarkersName = "Afficher les marqueurs",
    clientConfigDrawMarkersDescription = "Si l'addon doit afficher les marqueurs.",
}