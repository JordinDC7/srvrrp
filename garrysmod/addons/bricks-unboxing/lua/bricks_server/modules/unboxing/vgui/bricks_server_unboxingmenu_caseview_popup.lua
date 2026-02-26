local PANEL = {}

function PANEL:Init()

end

function PANEL:CreatePopout()
    self.panelWide, self.panelTall = self:GetSize()
    self.popoutWide, self.popoutTall = self.panelWide*0.9, self.panelTall*0.9

    self.popoutPanel = BRICKS_SERVER.Func.CreatePopoutPanel( self, self.panelWide, self.panelTall, self.popoutWide, self.popoutTall )
    self.popoutPanel.Paint = function( self2, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end
    self.popoutPanel.OnRemove = function()
        self:Remove()
    end

    self.leftPanel = vgui.Create( "DPanel", self.popoutPanel )
    self.leftPanel:Dock( LEFT )
    self.leftPanel:SetWide( self.popoutWide*0.25 )
    self.leftPanel.Paint = function( self2, w, h ) 
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), true, false, true, false )
    end

    local infoHeader = vgui.Create( "DPanel", self.leftPanel )
    infoHeader:Dock( TOP )
    infoHeader:SetTall( 60 )
    infoHeader.Paint = function( self2, w, h )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), true, false, false, false )
        draw.SimpleText( "CASE DETAILS", "BRICKS_SERVER_Font21", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    self.mainPanel = vgui.Create( "DPanel", self.popoutPanel )
    self.mainPanel:Dock( FILL )
    self.mainPanel.Paint = function( self2, w, h ) end

    self.closeButton = vgui.Create( "DButton", self.mainPanel )
    self.closeButton:Dock( BOTTOM )
    self.closeButton:SetTall( 40 )
    self.closeButton:SetText( "" )
    self.closeButton:DockMargin( 25, 0, 25, 25 )
    local changeAlpha = 0
    self.closeButton.Paint = function( self2, w, h )
        if( not self2:IsDown() and self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
        end
        
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )

        surface.SetAlphaMultiplier( changeAlpha/255 )
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ), 8 )
        
        draw.SimpleText( BRICKS_SERVER.Func.L( "close" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    self.closeButton.DoClick = self.popoutPanel.ClosePopout

    self.topPanel = vgui.Create( "DPanel", self.mainPanel )
    self.topPanel:Dock( TOP )
    self.topPanel:SetTall( self.popoutTall*0.3 )
    self.topPanel.Paint = function( self2, w, h ) 
        draw.RoundedBoxEx( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), self.leftPanel:GetWide() <= 0, true, false, false )
    end

    local gridWide = self.popoutWide-self.leftPanel:GetWide()-50
    local slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 150 ) )
    local spacing = 10
    self.slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    local itemsScroll = vgui.Create( "bricks_server_scrollpanel", self.mainPanel )
    itemsScroll:Dock( FILL )
    itemsScroll:DockMargin( 25, 25, 25, 25 )
    itemsScroll.Paint = function( self, w, h ) end 

    self.itemsGrid = vgui.Create( "DIconLayout", itemsScroll )
    self.itemsGrid:Dock( FILL )
    self.itemsGrid:SetSpaceY( spacing )
    self.itemsGrid:SetSpaceX( spacing )
end

function PANEL:FillPanel( caseKey, buttonFunc, inventoryView )
    self.itemsGrid:Clear()

    local caseTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey]
    if( not caseTable ) then return end

    self.buttonFunc = buttonFunc
    self.inventoryView = inventoryView

    local buttonText = not self.inventoryView and BRICKS_SERVER.Func.L( "unboxingAddToCart" ) or BRICKS_SERVER.Func.L( "unboxingUnlock" )
    surface.SetFont( "BRICKS_SERVER_Font21" )
    local textX, textY = surface.GetTextSize( buttonText )
    local totalContentW = 16+5+textX

    local bottomButton = vgui.Create( "DButton", self.leftPanel )
    bottomButton:Dock( BOTTOM )
    bottomButton:DockMargin( 12, 0, 12, 12 )
    bottomButton:SetTall( 44 )
    bottomButton:SetText( "" )
    local alpha = 0
    local bottomButtonMat = self.inventoryView and Material( "bricks_server/unboxing_unlock_16.png" ) or Material( "bricks_server/unboxing_cart_16.png" ) 
    bottomButton.Paint = function( self2, w, h )
        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
        -- Base: accent colored button
        local baseCol = self.inventoryView and (C.accent or Color(0, 212, 170)) or (C.accent or Color(0, 212, 170))
        local hoverCol = self.inventoryView and (C.accent_hover or Color(0, 235, 190)) or (C.accent_hover or Color(0, 235, 190))
        
        draw.RoundedBox( 6, 0, 0, w, h, baseCol )

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBox( 6, 0, 0, w, h, hoverCol )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, hoverCol, 6 )

        surface.SetDrawColor( Color(255,255,255) )
        surface.SetMaterial( bottomButtonMat )
        local iconSize = 16
        surface.DrawTexturedRect( (w/2)-(totalContentW/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( buttonText, "BRICKS_SERVER_Font21", (w/2)-(totalContentW/2)+iconSize+5, h/2-1, Color(255,255,255), 0, TEXT_ALIGN_CENTER )
    end
    bottomButton.DoClick = function()
        if( not self.inventoryView ) then
            self.buttonFunc()
        else
            local canOpen, message = LocalPlayer():UnboxingCanOpenCase( caseKey )
            if( not canOpen ) then
                BRICKS_SERVER.Func.CreateTopNotification( message, 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                return
            end

            self:UnlockCase( caseKey )
        end
    end

    if( table.Count( caseTable.Keys or {} ) > 0 ) then
        -- Keys are no longer required - section removed
    end

    -- ====== CASE STATS: Rarity breakdown ======
    local caseItems = caseTable.Items or {}
    local totalChanceInfo = 0
    local rarityBuckets = {}
    for k, v in pairs( caseItems ) do
        totalChanceInfo = totalChanceInfo + v[1]

        -- Resolve item config directly (same approach as FillCaseItems)
        local configItem
        if( string.StartWith( k, "ITEM_" ) ) then
            local actualKey = tonumber( string.Replace( k, "ITEM_", "" ) )
            configItem = BRICKS_SERVER.CONFIG.UNBOXING.Items[actualKey]
        elseif( string.StartWith( k, "CASE_" ) ) then
            local actualKey = tonumber( string.Replace( k, "CASE_", "" ) )
            configItem = BRICKS_SERVER.CONFIG.UNBOXING.Cases[actualKey]
        elseif( string.StartWith( k, "KEY_" ) ) then
            local actualKey = tonumber( string.Replace( k, "KEY_", "" ) )
            configItem = BRICKS_SERVER.CONFIG.UNBOXING.Keys[actualKey]
        end

        if configItem then
            local rar = configItem.Rarity or "Common"
            rarityBuckets[rar] = (rarityBuckets[rar] or 0) + v[1]
        end
    end

    local statsPanel = vgui.Create( "DPanel", self.leftPanel )
    statsPanel:Dock( TOP )
    statsPanel:DockMargin( 12, 12, 12, 0 )
    
    -- Sort rarities by drop chance (highest first)
    local sortedRarities = {}
    for rar, chance in pairs( rarityBuckets ) do
        table.insert(sortedRarities, { rar, chance })
    end
    table.sort(sortedRarities, function(a, b) return a[2] > b[2] end)

    local entryH = 30
    local headerH = 36
    local statsH = #sortedRarities * entryH + headerH + 8
    statsPanel:SetTall( statsH )
    statsPanel:DockPadding( 10, headerH, 10, 4 )
    statsPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 6, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.SimpleText( "DROP RATES", "BRICKS_SERVER_Font20", w/2, 18, BRICKS_SERVER.Func.GetTheme( 6, 120 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        surface.SetDrawColor(BRICKS_SERVER.Func.GetTheme( 3 ))
        surface.DrawRect(10, headerH - 2, w - 20, 1)
    end

    for i, entry in ipairs( sortedRarities ) do
        local rar, chance = entry[1], entry[2]
        local pct = totalChanceInfo > 0 and (chance / totalChanceInfo * 100) or 0
        local oneInX = pct > 0 and math.Round(100 / pct) or 0
        local rarInfo = BRICKS_SERVER.Func.GetRarityInfo( rar )
        local rarCol = BRICKS_SERVER.Func.GetRarityColor( rarInfo ) or Color(160,165,175)

        local row = vgui.Create( "DPanel", statsPanel )
        row:Dock( TOP )
        row:SetTall( entryH )
        row.Paint = function( self2, w, h )
            -- Rarity dot
            draw.RoundedBox( 4, 2, h/2 - 4, 8, 8, rarCol )
            -- Rarity name
            draw.SimpleText( rar, "BRICKS_SERVER_Font17", 16, h/2, rarCol, 0, TEXT_ALIGN_CENTER )
            -- 1 in X odds
            local oddsStr = oneInX > 1 and ("1 in " .. oneInX) or "—"
            draw.SimpleText( oddsStr, "BRICKS_SERVER_Font17", w - 50, h/2, BRICKS_SERVER.Func.GetTheme( 6, 100 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
            -- Percentage
            draw.SimpleText( string.format("%.1f%%", pct), "BRICKS_SERVER_Font17", w - 2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 160 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end
    end

    -- Item count
    local countPanel = vgui.Create( "DPanel", self.leftPanel )
    countPanel:Dock( TOP )
    countPanel:DockMargin( 12, 8, 12, 0 )
    countPanel:SetTall( 40 )
    local itemCount = table.Count( caseItems )
    countPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 6, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.SimpleText( itemCount .. " POSSIBLE DROPS", "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 100 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( caseTable.Rarity )

    self.caseName = vgui.Create( "DPanel", self.topPanel )
    self.caseName:Dock( BOTTOM )
    self.caseName:DockMargin( 0, 0, 0, 10 )
    self.caseName:SetTall( 60 )
    self.caseName.Paint = function( self2, w, h ) 
        draw.SimpleText( caseTable.Name, "BRICKS_SERVER_Font23", w/2, (h/2)+2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        
        draw.SimpleText( (caseTable.Rarity or ""), "BRICKS_SERVER_Font20", w/2, (h/2)-2, BRICKS_SERVER.Func.GetRarityColor( rarityInfo ), TEXT_ALIGN_CENTER, 0 )
    end

    self.caseModel = vgui.Create( "bricks_server_unboxing_itemdisplay", self.topPanel )
    self.caseModel:SetSize( self.topPanel:GetTall()-10, self.topPanel:GetTall()-10-self.caseName:GetTall() )
    self.caseModel:SetPos( ((self.popoutWide-self.leftPanel:GetWide())/2)-(self.caseModel:GetWide()/2), 0 )
    self.caseModel:SetItemData( "CASE", caseTable )
    self.caseModel:SetIconSizeAdjust( 0.8 )

    self.rarityBox = vgui.Create( "bricks_server_raritybox", self.topPanel )
    self.rarityBox:SetSize( self.popoutWide, 10 )
    self.rarityBox:SetPos( 0, self.topPanel:GetTall()-self.rarityBox:GetTall() )
    self.rarityBox:SetRarityName( caseTable.Rarity or "" )
    self.rarityBox:SetCornerRadius( 0 )

    self:FillCaseItems( caseKey )
end

function PANEL:FillCaseItems( caseKey )
    self.itemsGrid:Clear()

    local caseTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey]
    if( not caseTable ) then return end

    local caseItems = caseTable.Items
    if( not caseItems ) then return end

    local items, hiddenItem = {}
    for k, v in pairs( caseItems ) do
        if( v[2] ) then 
            hiddenItem = true
            continue 
        end

        local configItemTable, actualKey

        if( string.StartWith( k, "ITEM_" ) ) then
            actualKey = tonumber( string.Replace( k, "ITEM_", "" ) )
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[actualKey]
        elseif( string.StartWith( k, "CASE_" ) ) then
            actualKey = tonumber( string.Replace( k, "CASE_", "" ) )
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[actualKey]
        elseif( string.StartWith( k, "KEY_" ) ) then
            actualKey = tonumber( string.Replace( k, "KEY_", "" ) )
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Keys[actualKey]
        end

        items[k] = table.Copy( configItemTable )
    end

    if( hiddenItem ) then
        local slotBack = self.itemsGrid:Add( "DPanel" )
        slotBack:SetSize( self.slotSize, self.slotSize*1.2 )
        local mysteryMat = Material( "bricks_server/unboxing_mystery.png" )
        slotBack.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
    
            local iconSize = 64
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
            surface.SetMaterial( mysteryMat )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingMystery" ), "BRICKS_SERVER_Font30B", w/2, (h/2)+(iconSize/2)+10, textColor or BRICKS_SERVER.Func.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
        end
    end

    local sortedItems = {}
    for k, v in pairs( items ) do
        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( v.Rarity or "" )
        
        table.insert( sortedItems, { rarityKey, k } )
    end

    table.SortByMember( sortedItems, 1, false )

    for k, v in pairs( sortedItems ) do
        local slotBack = self.itemsGrid:Add( "bricks_server_unboxingmenu_itemslot" )
        slotBack:SetSize( self.slotSize, self.slotSize*1.2 )
        slotBack:FillPanel( v[2], 1 )
        slotBack.themeNum = 1
    end
end

function PANEL:UnlockCase( caseKey )
    local caseTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey]
    if( not caseTable ) then return end

    local caseItems = caseTable.Items
    if( not caseItems ) then return end

    local gridWide = self.popoutWide-50-20
    local slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 150 ) )
    local spacing = 10
    self.slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    self.rollSlotSize = 150

    self:FillCaseItems( caseKey )

    self.caseName:AlphaTo( 0, 0.2, 0, function() self.caseName:Remove() end )
    self.caseModel:AlphaTo( 0, 0.2, 0, function() self.caseModel:Remove() end )

    self.leftPanel:SizeTo( 0, self.popoutTall, 0.2 )
    self.leftPanel.OnSizeChanged = function( self2, w, h )
        if( IsValid( self.caseModel ) ) then
            self.caseModel:SetPos( ((self.popoutWide-w)/2)-(self.caseModel:GetWide()/2), 0 )
        end
    end

    local newTopH = (self.rollSlotSize*1.2)+10+50
    self.topPanel:SizeTo( self.popoutWide, newTopH, 0.2, 0, -1, function()
        self.rarityBox:SetPos( 0, self.topPanel:GetTall()-self.rarityBox:GetTall() )
    end )

    self.topPanel.OnSizeChanged = function()
        self.rarityBox:SetPos( 0, self.topPanel:GetTall()-self.rarityBox:GetTall() )
    end

    local items, totalChance = {}, 0
    for k, v in pairs( caseItems ) do
        local configItemTable, actualKey

        if( string.StartWith( k, "ITEM_" ) ) then
            actualKey = tonumber( string.Replace( k, "ITEM_", "" ) )
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Items[actualKey]
        elseif( string.StartWith( k, "CASE_" ) ) then
            actualKey = tonumber( string.Replace( k, "CASE_", "" ) )
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[actualKey]
        elseif( string.StartWith( k, "KEY_" ) ) then
            actualKey = tonumber( string.Replace( k, "KEY_", "" ) )
            configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Keys[actualKey]
        end

        if( not configItemTable ) then continue end

        items[k] = table.Copy( configItemTable )
        items[k].Chance = v[1]
        items[k].Hidden = v[2]

        totalChance = totalChance+v[1]
    end

    local totalItems = 100

    local function GenerateRandomItem()
        local winningChance, currentChance = math.Rand( 0, 100 ), 0
        local winningItemKey
        for k, v in pairs( items ) do
            local actualChance = (v.Chance/totalChance)*100

            if( winningChance > currentChance and winningChance <= currentChance+actualChance ) then
                winningItemKey = k
                break
            end
    
            currentChance = currentChance+actualChance
        end

        return winningItemKey
    end

    local slotSpacing = 5
    local panelWide = self.popoutWide

    local rollBack = vgui.Create( "DPanel", self.topPanel )
    rollBack:SetSize( (totalItems*(self.rollSlotSize+slotSpacing))-slotSpacing, self.rollSlotSize*1.2 )
    rollBack:SetPos( 25, ((newTopH-10)/2)-(rollBack:GetTall()/2) )
    rollBack.Paint = function( self2, w, h ) end
    local previousSoundX = 0
    local soundCooldown = 0
    rollBack.Think = function()
        local xPos, yPos = rollBack:GetPos()

        if( xPos < previousSoundX-(self.rollSlotSize+slotSpacing) and CurTime() >= soundCooldown ) then
            surface.PlaySound( "bricks_server/ui_unboxing_scroll.wav" )
            previousSoundX = xPos
            soundCooldown = CurTime()+0.25
        end
    end

    local pinBack = vgui.Create( "DPanel", self.topPanel )
    pinBack:SetSize( 3, newTopH-10 )
    pinBack:SetPos( ((panelWide-50)/2)-(pinBack:GetWide()/2), 0 )
    pinBack.Paint = function( self2, w, h )
        BRICKS_SERVER.BSHADOWS.BeginShadow()
        local x, y = self2:LocalToScreen( 0, 0 )
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
        surface.DrawRect( x, y, w, h )
        BRICKS_SERVER.BSHADOWS.EndShadow( 3, 2, 2, 255, 0, 0, false )
    end

    local mysteryMat = Material( "bricks_server/unboxing_mystery.png" )

    local finalItemSlotKey = math.random( math.floor( totalItems*0.7 ), math.floor( totalItems*0.8 ) )
    local createdSlots = {}
    for i = 1, totalItems do
        local randomKey = GenerateRandomItem()
        if( items[randomKey] and items[randomKey].Hidden and i != finalItemSlotKey ) then
            local slotBack = rollBack:Add( "DPanel" )
            slotBack:SetSize( self.rollSlotSize, self.rollSlotSize*1.2 )
            slotBack:Dock( LEFT )
            slotBack:DockMargin( 0, 0, slotSpacing, 0 )
            slotBack.Paint = function( self2, w, h )
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        
                local iconSize = 64
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                surface.SetMaterial( mysteryMat )
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    
                draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingMystery" ), "BRICKS_SERVER_Font30B", w/2, (h/2)+(iconSize/2)+10, textColor or BRICKS_SERVER.Func.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
            end
        else
            local slotBack = rollBack:Add( "bricks_server_unboxingmenu_itemslot" )
            slotBack:SetSize( self.rollSlotSize, self.rollSlotSize*1.2 )
            slotBack:Dock( LEFT )
            slotBack:DockMargin( 0, 0, slotSpacing, 0 )

            if( i != finalItemSlotKey ) then
                slotBack:FillPanel( randomKey, 1, {} )
            end

            createdSlots[i] = slotBack
        end
    end

    function self.StartOpen( self2, globalKey )
        local keySlot = createdSlots[finalItemSlotKey]

        if( not IsValid( keySlot ) ) then return end

        keySlot:FillPanel( globalKey, 1, {} )

        local keySlotX, keySlotY = keySlot:GetPos()
        local currentX, currentY = rollBack:GetPos()
        local startTime = CurTime()
        rollBack:MoveTo( -keySlotX+((panelWide-50)/2)-(self.rollSlotSize/2)+math.random( -(self.rollSlotSize-15)/2, (self.rollSlotSize-15)/2 ), currentY, BRICKS_SERVER.CONFIG.UNBOXING["Case UI Open Time"], 0, 0.25, function()
            self.popoutPanel.ClosePopout()
        end )

        surface.PlaySound( "bricks_server/ui_unboxing_open.wav" )
    end

    rollBack:SetAlpha( 0 )
    rollBack:AlphaTo( 255, 0.2, 0, function()
        net.Start( "BRS.Net.UnboxCase" )
            net.WriteUInt( caseKey, 16 )
        net.SendToServer()
    end )

    hook.Add( "BRS.Hooks.UnboxingOpenCase", self, function( self, globalKey )
        self:StartOpen( globalKey )
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_caseview_popup", PANEL, "DPanel" )