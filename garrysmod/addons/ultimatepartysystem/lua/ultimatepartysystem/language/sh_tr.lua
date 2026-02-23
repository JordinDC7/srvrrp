-- Translation by Wolflix
-- https://www.gmodstore.com/users/76561198089913075
UltimatePartySystem.Languages["tr"] = {
    netCooldown = "Sunucuya çok fazla talep gönderiyorsun. Lütfen biraz bekle.", -- Message to a user who is trying to spam net messages like a bad boi.

    --
    -- Chat Messages
    --
    openingWindow = "Parti penceresi açılıyor...", -- Message when the user is opening the Party Window.
    noPermission = "Buna ulaşmak için belirli bir yetkiye sahip değilsin.", -- No permission.
    configUpdate = "Config güncellendi.", -- Config updated.
    configReset = "Config sıfırlandı.", -- Config reset.

    partyCreationAlreadyOwned = "Zaten bir partiye sahipsin.", -- User trying to make a party while already owning one.
    partyCreationNameTooLong = "İsmin çok uzun, %s karakterden uzun bir isim koyamazsın.", -- Party name is too long. %s is the amount of characters.
    partyCreationTooManySlots = "Partin çok fazla yuvaya sahip %s yuvadan fazla yuvaya sahip olamazsın.", -- Party tried to have too many slots. %s is the amount of slots.
    partyCreationTooLittleSlots = "Partin 2'den az yuvaya sahip olamaz.", -- Party tried to have less than 2 slots.
    partyCreationCannotAfford = "%s ücretini karşılayamadığından parti açamıyorsun.", -- Can't afford to make a party. %s is the fee for making a party.
    partyCreationSuccessfull = "Partin '%s' oluşturuldu.", -- Party created. %s is the name of the party.

    partyInviteOof = "Bir partiye sahip değilsin.", -- Player tries to invite a player to a party when they don't own one.
    partyInviteAlreadyIn = "%s zaten bir partiye üye.", -- Player invited to party when they are already in a party. %s is the player name.
    partyInviteDone = "%s %s'yı partiye davet etti.", -- Player invites another player to a lobby. %s is the invitee, followed by the invited.
    partyInvited = "%s seni '%s''ya davet etti. Parti arayüzünden kabul edebilirsin.", -- Player invited to party. %s is the invitee, followed by the party name.
    partyInviteTimeout = "%s'nın davet süresi bitti.", -- Party invite timed out. %s is the inviter.
    partyInviteTimeoutOwner = "%s'ya gönderilen davetin süresi bitti.", -- Owner informed Party invite timed out. %s is the invited.

    partyJoinAlreadyIn = "Zaten bir partidesin.", -- Player tries to join a party while already being in one.
    partyJoinDoesNotExist = "Böyle bir parti bulunmamakta.", -- Player tries to join a party that doesn't exist.
    partyJoinIsFull = "Bu parti tamamen dolu.", -- Party is full.
    partyJoinSuccess = "'%s' partisine katıldın.", -- Player joined a party. %s is the party name.

    partyLeaveSuccess = "'%s' partisinden ayrıldın.", -- Player leaving a party. %s is the party name.
    partyLeaveFromKicked = "'%s' partisinden atıldın.", -- Player being kicked from a party. %s is the party name.

    partyLeaveDisbanded = "'%s' partisi dağıtıldı, bu yüzden partiden çıkartıldın.", -- Party has been deleted. %s is the party name.

    partyOwnerPlayerJoin = "%s partine katıldı.", -- Player joined a party. %s is the party name.
    partyOwnerPlayerLeave = "'%s' partinden ayrıldı.", -- Player leaving a party. %s is the users name.
    partyOwnerPlayerDisconnect = "%s oyundan çıktı ve partinden ayrıldı.", -- Player disconnected forcing them out the party. %s is the player name.
    partyOwnerPlayerKicked = "%s partiden atıldı.", -- Player kicked from the party. %s is the name.
    partyOwnerPartyDisband = "Partin '%s' dağıtıldı.", -- Party disbanded. %s is the party name.

    partyOwnerEditOof = "Herhangi bir partiye sahip değilsin.", -- Player tries to change party without owning it.
    partyOwnerEditNotEnoughSlotsForPlayers = "Partinin yuva sayısı üye sayısından az olamaz.", -- Player tries to change party slots to be lower than the player count.
    partyOwnerEditSuccess = "Partin güncellendi.", -- Player updates their party's settings successfully.

    partyOwnerDeleteOof = "Bir partiye sahip değilsin.", -- Player tries to delete a party without owning it.

    partyOwnerKickNotFound = "Oyuncu bulunamadı.", -- Player tries to kick a nonexistent player from their party.
    partyOwnerKickOof = "Bu partinin kurucususu değilsin.", -- Player tries to kick a player from their party without owning one.

    partyChatPrefix = "[Parti Sohbeti] %s >>", -- Party Chat prefix. %s is the player's name.


    --
    -- VGUI
    --
    primaryWindowTitle = "PARTİ SİSTEMİ", -- Main Window title. All caps for a s t e t i c s.
    primaryWindowViewPartiesTab = "Partileri Görüntüle", -- View Parties button.
    primaryWindowCreatePartyTab = "Parti Yarat", -- Create Party button.
    primaryWindowViewPartyTab = "Partiyi Görüntüle", -- View Party button.
    primaryWindowSettingsTab = "Ayarlar", -- Settings button.

    viewPartyOwnedBy = "%s'ya ait", -- Party owned by text. %s is the user's name.
    viewPartyInside = "Zaten bir partidesin.", -- Text is user is viewing a party they're in.
    viewPartySlots = "%s/%s Yuva Dolu", -- Party slots text. %s is the players in the party, followed by the total slots.
    viewPartyJoin = "PARTİYE KATIL", -- Join Party text.
    viewPartyAcceptInvite = "DAVETİ KABUL ET", -- Accept Invite text.
    viewPartyLeave = "AYRIL", -- Leave button.
    thereIsNoPartyTakeOffYourClothes = "Mevcut parti bulunmamakta.", -- No partys.

    createPartyName = "Partinin ismi ne olsun istersin?", -- Name of a new party field.
    createPartyPrivate = "Özel Parti?", -- Private party field.
    createPartySlots = "Yuva Sayısı", -- Slots field.
    createPartyOwners = "Sahip Ekle", -- Other Owners header.
    createPartySubmit = "PARTİ OLUŞTUR", -- Create Party button.
    createPartySubmitCostly = "PARTİ OLUŞTUR (ÜCRET: %s)", -- Create Party button if there is a cost too. %s it the formatted cost.

    viewPartyEditHeader = "PARTİ DÜZENLE", -- Edit Party header when viewing your own party.
    viewPartyEditPrivate = "Özel Parti?", -- Edit Party private party header.
    viewPartyEditSlots = "Yuva Sayısı", -- Edit Party slots header.
    viewPartyEditSaveButton = "AYARLARI KAYDET", -- Save party settings button.
    viewPartyEditDeleteButton = "PARTİYİ SİL", -- Delete party button.
    viewPartyPlayerListHeader = "OYUNCU LİSTESİ", -- Player List.
    viewPartyPlayerListOwner = "(Sahip)", -- Owner on the Player List.
    viewPartyPlayerListInvite = "OYUNCU DAVET ET", -- Invite Players button.

    deletePartyTitle = "Partiyi Sil?", -- Title for the delete party vgui.
    deletePartyButton = "Onayla", -- Confirm Button for the delete party vgui.

    invitePlayerTitle = "Partine bir oyuncuyu davet et", -- Invite a player vgui title.
    invitePlayerMessage = "Davet etmek istediğin oyuncuyu seç.", -- Message inside the VGUI.
    invitePlayerButton = "Davet Gönder", -- Message inside the VGUI.

    configWindowTitle = "ULTIMATE PARTY SYSTEM CONFIG", -- Config Window title
    configResetHeader = "Bütün configi sıfırlamak istediğine emin misin?", -- Config Reset Header
    configResetSubHeader = "Bu işlem geri alınamaz.", -- Config Reset Sub-Header
    configResetConfirmButton = "Ne yaptığını bilen bir adamım ben. Sıfırla.", -- Config Reset Button

    cancelButton = "İPTAL", -- Cancel button.


    --
    -- Config Localisation
    --
    -- Fuck off if you think for a SECOND im commenting all this fucking shit. Figure it out youself. I'm writing these localisation vars at 2:20am on a school night, gimme a fuckin break.

    -- General
    configPrefixName = "Ön Ek",
    configPrefixDescription = "Bütün sohbet mesajları için ön ek.",

    configPrefixColorName = "Ön Ek Rengi",
    configPrefixColorDescription = "Ön ek rengi.",

    configMessageColorName = "Mesaj Rengi",
    configMessageColorDescription = "Mesajın geri kalanının rengi.",

    configThemeColorName = "Tema Rengi",
    configThemeColorDescription = "Bütün arayüzün tema rengi.",

    configMoneyFormatName = "Para Formatı",
    configMoneyFormatDescription = "Paranın formatını ayarlar. %s paranın virgülle beraber miktarı.",

    -- User Interface
    configChatCommandName = "Sohbet Komutu",
    configChatCommandDescription = "Arayüzü açmak için girilecek komut.",

    configHideCommandName = "Sohbet Komutunu Gizle",
    configHideCommandDescription = "Sohbetten komutu gizler.",

    configUIMessageName = "Arayüz Açılma Mesajını Göster",
    configHideCommandDescription = "Arayüz açıldığında eklentinin sohbetten mesaj göndermesini sağlar.",

    -- Parties
    configMaxNameLengthName = "Maksimum Parti İsmi Uzunluğu",
    configMaxNameLengthDescription = "Partinin sahip olabilceği maksimum isim uzunluğu.",

    configAllowPrivatePartiesName = "Özel Partilere İzin Ver",
    configAllowPrivatePartiesDescription = "Oyuncuların kendine özel parti açma ayarı.",

    configMaxSlotsName = "Maksimum Yuva Sayısı",
    configMaxSlotsDescription = "Partinin sahip olabilceği maksimum yuva.",

    configDefaultSlotsName = "Varsayılan Yuva Sayısı",
    configDefaultSlotsDescription = "Partinin varsayılan yuva sayısı.",

    configPartyCreationCostName = "Parti Oluşturma Ücreti",
    configPartyCreationCostDescription = "Parti oluşturmanın ücretini belirler. Ücretsiz yapmak için 0 olarak ayarlayın.",

    -- Misc
    configRadioEnabledName = "Radyo Aktif",
    configRadioEnabledDescription = "Radyoyu aktif eder.",

    configMarkerEnabledName = "İşaretleme Aktif",
    configMarkerEnabledDescription = "İşaretlemeyi aktif eder.",

    configInviteTimeoutName = "Parti Daveti Zaman Aşım Süresi",
    configInviteTimeoutDescription = "Saniye biriminde parti davetinin zaman aşım süresi.",

    configEnableFriendlyFireName = "Dost Ateşi Aktif",
    configEnableFriendlyFireDescription = "Eklentinin aynı partideki kişilerin birbirine hasar verip vermemesi.",

    configEnablePartyChatName = "Parti Sohbeti Aktif",
    configEnablePartyChatDescription = "Eklenti parti sohbeti muhabbetini aktif edip etmemesi.",

    configPartyChatCommandName = "Party Sohbet Komutu",
    configPartyChatCommandDescription = "Parti sohbetine yazmak için olan komut.",

    -- Client Based Settings
    clientConfigDrawHUDName = "HUD'u Çiz",
    clientConfigDrawHUDDescription = "Partinin HUD'unu Çiz.",

    clientConfigHUDXName = "HUD'un X Pozisyonu",
    clientConfigHUDXDescription = "HUD'un X eksenindeki pozisyonu.",

    clientConfigHUDYName = "HUD'un Y Pozisyonu'",
    clientConfigHUDYDescription = "HUD'un Y eksenindeki pozisyonu.",

    clientConfigHUDOpacityName = "HUD Opaklığı",
    clientConfigHUDOpacityDescription = "HUD'un opaklığı.",

    clientConfigDrawMarkersName = "İşaretleri Çiz",
    clientConfigDrawMarkersDescription = "Eklentinin işaretlere izin verip vermemesi.",

    clientConfigDisplayPartyChatName = "Parti Sohbetini Göster",
    clientConfigDisplayPartyChatDescription = "Parti sohbetinin gösterilip gösterilmemesi.",
}