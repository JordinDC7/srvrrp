-- Translation by Goran
-- https://www.gmodstore.com/users/Goran
UltimatePartySystem.Languages["es"] = {
    netCooldown = "Estás enviándole demasiadas solicitudes al servidor. Espera unos segundos.", -- Message to a user who is trying to spam net messages like a bad boi.

    --
    -- Chat Messages
    --
    openingWindow = "Abriendo ventana de escuadrones...", -- Message when the user is opening the Party Window.
    noPermission = "No tienes permiso para acceder a esto.", -- No permission.
    configUpdate = "La configuración fue actualizada.", -- Config updated.
    configReset = "La configuración ha sido restaurada.", -- Config reset.

    partyCreationAlreadyOwned = "Ya eres propietario de un escuadrón.", -- User trying to make a party while already owning one.
    partyCreationNameTooLong = "Tu nombre es demasiado largo, no puede tener más de %s caracteres.", -- Party name is too long. %s is the amount of characters.
    partyCreationTooManySlots = "Tu escuadrón no puede contar con más de %s espacios.", -- Party tried to have too many slots. %s is the amount of slots.
    partyCreationTooLittleSlots = "Tu escuadrón no puede contar con menos de 2 espacios.", -- Party tried to have less than 2 slots.
    partyCreationCannotAfford = "No puedes pagar la cuota de %s para crear este escuadrón.", -- Can't afford to make a party. %s is the fee for making a party.
    partyCreationSuccessfull = "Tu escuadrón '%s' ha sido creado.", -- Party created. %s is the name of the party.

    partyInviteOof = "No eres propietario de ningún escuadrón.", -- Player tries to invite a player to a party when they don't own one.
    partyInviteAlreadyIn = "%s ya forma parte de un escuadrón.", -- Player invited to party when they are already in a party. %s is the player name.
    partyInviteDone = "%s ha invitado a %s a un escuadrón.", -- Player invites another player to a lobby. %s is the invitee, followed by the invited.
    partyInvited = "%s te ha invitado a '%s'. Acepta esta invitación en la IU de escuadrones.", -- Player invited to party. %s is the invitee, followed by the party name.
    partyInviteTimeout = "La invitación de %s ha caducado.", -- Party invite timed out. %s is the inviter.
    partyInviteTimeoutOwner = "La invitación enviada a %s ha caducado.", -- Owner informed Party invite timed out. %s is the invited.

    partyJoinAlreadyIn = "Ya formas parte de un escuadrón.", -- Player tries to join a party while already being in one.
    partyJoinDoesNotExist = "Ese escuadrón no existe.", -- Player tries to join a party that doesn't exist.
    partyJoinIsFull = "El escuadrón está lleno.", -- Party is full.
    partyJoinSuccess = "Te has unido al escuadrón '%s'.", -- Player joined a party. %s is the party name.

    partyLeaveSuccess = "Has abandonado el escuadrón '%s'.", -- Player leaving a party. %s is the party name.
    partyLeaveFromKicked = "Has sido expulsado del escuadrón '%s'.", -- Player being kicked from a party. %s is the party name.

    partyLeaveDisbanded = "El escuadrón '%s' fue disuelto, por lo que has sido removido de él.", -- Party has been deleted. %s is the party name.

    partyOwnerPlayerJoin = "%s se ha unido a tu escuadrón.", -- Player joined a party. %s is the party name.
    partyOwnerPlayerLeave = "'%s' ha abandonado tu escuadrón.", -- Player leaving a party. %s is the users name.
    partyOwnerPlayerDisconnect = "%s se ha desconectado y ha abandonado tu escuadrón.", -- Player disconnected forcing them out the party. %s is the player name.
    partyOwnerPlayerKicked = "%s fue expulsado.", -- Player kicked from the party. %s is the name.
    partyOwnerPartyDisband = "Tu escuadrón '%s' ha sido disuelto.", -- Party disbanded. %s is the party name.

    partyOwnerEditOof = "No eres propietario de ningún escuadrón.", -- Player tries to change party without owning it.
    partyOwnerEditNotEnoughSlotsForPlayers = "La cantidad de espacios no puede ser menor a la cantidad de jugadores del escuadrón.", -- Player tries to change party slots to be lower than the player count.
    partyOwnerEditSuccess = "Tu escuadrón fue actualizado.", -- Player updates their party's settings successfully.

    partyOwnerDeleteOof = "No eres propietario de ningún escuadrón.", -- Player tries to delete a party without owning it.

    partyOwnerKickNotFound = "Jugador no encontrado.", -- Player tries to kick a nonexistent player from their party.
    partyOwnerKickOof = "No eres propietario de ningún escuadrón.", -- Player tries to kick a player from their party without owning one.

    partyChatPrefix = "[Escuadrón] %s >>", -- Party Chat prefix. %s is the player's name.


    --
    -- VGUI
    --
    primaryWindowTitle = "SISTEMA DE ESCUADRONES", -- Main Window title. All caps for a s t e t i c s.
    primaryWindowViewPartiesTab = "Ver Escuadrones", -- View Parties button.
    primaryWindowCreatePartyTab = "Crear Escuadrón", -- Create Party button.
    primaryWindowViewPartyTab = "Ver Escuadrón", -- View Party button.
    primaryWindowSettingsTab = "Ajustes", -- Settings button.

    viewPartyOwnedBy = "Propietario: %s", -- Party owned by text. %s is the user's name.
    viewPartyInside = "Ya formas parte de un escuadrón.", -- Text is user is viewing a party they're in.
    viewPartySlots = "%s/%s Espacios Ocupados", -- Party slots text. %s is the players in the party, followed by the total slots.
    viewPartyJoin = "UNIRSE AL ESCUADRÓN", -- Join Party text.
    viewPartyAcceptInvite = "ACEPTAR INVITACIÓN", -- Accept Invite text.
    viewPartyLeave = "ABANDONAR", -- Leave button.
    thereIsNoPartyTakeOffYourClothes = "No hay escuadrones formados aún.", -- No partys.

    createPartyName = "¿Cuál será el nombre de tu Escuadrón?", -- Name of a new party field.
    createPartyPrivate = "¿Será privado?", -- Private party field.
    createPartySlots = "Espacios", -- Slots field.
    createPartyOwners = "Añadir Propietarios", -- Other Owners header.
    createPartySubmit = "CREAR ESCUADRÓN", -- Create Party button.
    createPartySubmitCostly = "CREAR UN ESCUADRÓN (CUESTA %s)", -- Create Party button if there is a cost too. %s it the formatted cost.

    viewPartyEditHeader = "EDITAR ESCUADRÓN", -- Edit Party header when viewing your own party.
    viewPartyEditPrivate = "¿Será privado?", -- Edit Party private party header.
    viewPartyEditSlots = "Espacios", -- Edit Party slots header.
    viewPartyEditSaveButton = "GUARDAR AJUSTES", -- Save party settings button.
    viewPartyEditDeleteButton = "ELIMINAR ESCUADRÓN", -- Delete party button.
    viewPartyPlayerListHeader = "LISTA DE JUGADORES", -- Player List.
    viewPartyPlayerListOwner = "(Propietario)", -- Owner on the Player List.
    viewPartyPlayerListInvite = "INVITAR JUGADORES", -- Invite Players button.

    deletePartyTitle = "¿Eliminar Escuadrón?", -- Title for the delete party vgui.
    deletePartyButton = "Confirmar", -- Confirm Button for the delete party vgui.

    invitePlayerTitle = "Invita a un Jugador a tu escuadrón", -- Invite a player vgui title.
    invitePlayerMessage = "Selecciona a un jugador para invitarlo.", -- Message inside the VGUI.
    invitePlayerButton = "Enviar Invitación", -- Message inside the VGUI.

    configWindowTitle = "CONFIGURACIÓN DE ULTIMATE PARTY SYSTEM", -- Config Window title
    configResetHeader = "¿Deseas restaurar toda la configuración?", -- Config Reset Header
    configResetSubHeader = "Esto no puede ser deshecho.", -- Config Reset Sub-Header
    configResetConfirmButton = "Soy un chico independiente, sé lo que hago. Házlo.", -- Config Reset Button

    cancelButton = "CANCELAR", -- Cancel button.


    --
    -- Config Localisation
    --

    -- General
    configPrefixName = "Prefijo",
    configPrefixDescription = "Prefijo para todos los mensajes de chat.",

    configPrefixColorName = "Color del Prefijo",
    configPrefixColorDescription = "El color del prefijo.",

    configMessageColorName = "Color del Mensaje",
    configMessageColorDescription = "Color del resto del mensaje.",

    configThemeColorName = "Color del Tema",
    configThemeColorDescription = "Color del Tema para todas las IU.",

    configMoneyFormatName = "Formato de Dinero",
    configMoneyFormatDescription = "Qué formato utilizará el dinero. %s es la cantidad de dinero con comas.",

    -- User Interface
    configChatCommandName = "Comando de Chat",
    configChatCommandDescription = "El comando para abrir la IU.",

    configHideCommandName = "Ocultar Comando del Chat",
    configHideCommandDescription = "¿Debería ocultarse el comando del chat al ser ejecutado?.",

    configUIMessageName = "Mostrar Mensaje al Abrir IU",
    configHideCommandDescription = "¿Debería enviarse un mensaje por chat al jugador cuando se abre la IU?.",

    -- Parties
    configMaxNameLengthName = "Tope del Nombre del Escuadrón",
    configMaxNameLengthDescription = "La cantidad máxima de caracteres que el Nombre de un Escuadrón puede tener.",

    configAllowPrivatePartiesName = "Habilitar Escuadrones Privados",
    configAllowPrivatePartiesDescription = "Habilita la posibilidad de crear Escuadrones Privados.",

    configMaxSlotsName = "Espacios Máximos",
    configMaxSlotsDescription = "La cantidad máxima de Espacios que un Escuadrón puede tener.",

    configDefaultSlotsName = "Espacios por Defecto",
    configDefaultSlotsDescription = "La cantidad de espacios por defecto que tiene un Escuadrón.",

    configPartyCreationCostName = "Precio de Creación de Escuadrón",
    configPartyCreationCostDescription = "Cuánto cuesta crear un Escuadrón. Establece este valor en cero para que sea gratis.",

    -- Misc
    configRadioEnabledName = "Radio Habilitada",
    configRadioEnabledDescription = "Habilita la Radio.",

    configMarkerEnabledName = "Marcadores Habilitados",
    configMarkerEnabledDescription = "Habilita los Marcadores.",

    configInviteTimeoutName = "Expiración de Invitación",
    configInviteTimeoutDescription = "El tiempo en segundos que debe transcurrir para que una invitación expire.",

    configEnableFriendlyFireName = "Habilitar Fuego Amigo",
    configEnableFriendlyFireDescription = "Permitir que los miembros de un mismo Escuadrón puedan dañarse entre ellos.",

    configEnablePartyChatName = "Habilitar Chat",
    configEnablePartyChatDescription = "Habilita el chat entre miembros de un mismo Escuadrón.",

    configPartyChatCommandName = "Comando del Chat del Escuadrón",
    configPartyChatCommandDescription = "El comando para enviar un mensaje por el chat del Escuadrón.",

    -- Client Based Settings
    clientConfigDrawHUDName = "Dibujar HUD",
    clientConfigDrawHUDDescription = "Dibujar el HUD del Escuadrón.",

    clientConfigHUDXName = "Desajuste del HUD en X",
    clientConfigHUDXDescription = "El valor del desajuste en X del HUD.",

    clientConfigHUDYName = "Desajuste del HUD en Y",
    clientConfigHUDYDescription = "El valor del desajuste en Y del HUD.",

    clientConfigHUDOpacityName = "Opacidad del HUD",
    clientConfigHUDOpacityDescription = "La opacidad HUD.",

    clientConfigDrawMarkersName = "Dibujar Marcadores",
    clientConfigDrawMarkersDescription = "Si el addon debería dibujar los marcadores.",

    clientConfigDisplayPartyChatName = "Mostrar mensajes de chat",
    clientConfigDisplayPartyChatDescription = "Habilita la visualización de los mensajes de chat.",
}