local PANEL = {}

function PANEL:Init()
    
end

function PANEL:AddTopInfo( textOrMat, color, textColor, left )
    if( not IsValid( self.topBar ) ) then return end

    local text = textOrMat
    local isMaterial
    if( type( textOrMat ) == "IMaterial" ) then
        isMaterial = true
        text = ""
    end

    surface.SetFont( "BRS_UW_Font10B" )
    local topX, topY = surface.GetTextSize( isfunction( text ) and text() or text )
    
    local boxW, boxH = topX+8, topY+4

    self.topBar:SetTall( math.max( self.topBar:GetTall(), boxH ) )

    local infoEntry = vgui.Create( "DPanel", self.topBar )
    infoEntry:Dock( not left and RIGHT or LEFT )
    infoEntry:DockMargin( not left and 3 or 0, 0, left and 3 or 0, 0 )
    infoEntry:SetWide( isMaterial and boxH or boxW )
    infoEntry.Paint = function( self2, w, h ) 
        draw.RoundedBox( 4, 0, 0, w, h, (istable( color or "" ) and color) or BRICKS_SERVER.Func.GetTheme( (self.themeNum or 2)-1, self.themeNum == 1 and 125 ) )

        if( not isMaterial ) then
            if( not isfunction( text ) ) then
                draw.SimpleText( text, "BRS_UW_Font10B", w/2, (h/2), textColor or BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            else
                local finalText = text()
                surface.SetFont( "BRS_UW_Font10B" )
                local topX2 = surface.GetTextSize( finalText )
                local boxW2 = topX2+8
                if( w ~= boxW2 ) then
                    self2:SetWide( boxW2 )
                end
                draw.SimpleText( finalText, "BRS_UW_Font10B", w/2, (h/2), textColor or BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        else
            surface.SetDrawColor( textColor or BRICKS_SERVER.Func.GetTheme( 6, 75 ) )
            surface.SetMaterial( textOrMat )
            local iconSize = 12
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
    end
end

function PANEL:FillPanel( data, amount, actions )
    self:Clear()
    
    local globalKey, configItemTable, itemKey, isItem, isCase, isKey
    if( data ) then
        if( not istable( data ) ) then
            globalKey = data
            configItemTable, itemKey, isItem, isCase, isKey = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( globalKey )
        else
            globalKey = data[1]
            configItemTable = data[2]
            if isstring(globalKey) then
                isItem = string.StartWith( globalKey, "ITEM_" )
                isCase = string.StartWith( globalKey, "CASE_" )
                isKey = string.StartWith( globalKey, "KEY_" )
            end
        end
    end

    local x, y, w, h = 0, 0, self:GetSize()
    local alpha = 0

    -- ====== UNIQUE WEAPON DETECTION ======
    local isUniqueWeapon = false
    local uwData = nil
    if globalKey and BRS_UW and BRS_UW.IsUniqueWeapon and BRS_UW.IsUniqueWeapon(globalKey) then
        isUniqueWeapon = true
        uwData = BRS_UW.GetWeaponData(globalKey)
    end

    self.panelInfo = vgui.Create( "DPanel", self )
    self.panelInfo:Dock( FILL )

    if( configItemTable ) then
        local displayRarity = configItemTable.Rarity
        if uwData and uwData.rarity then
            displayRarity = uwData.rarity
        end

        local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( displayRarity )

        -- Use smaller fonts for weapon name
        local textFonts = { 
            { "BRICKS_SERVER_Font22", "BRICKS_SERVER_Font18" }, 
            { "BRICKS_SERVER_Font21", "BRICKS_SERVER_Font17" }, 
            { "BRICKS_SERVER_Font20", "BRICKS_SERVER_Font17" }
        }
        
        local function CheckNameSize( fontNum )
            surface.SetFont( textFonts[fontNum][1] )
            local textX, textY = surface.GetTextSize( configItemTable.Name or "NIL" )
            if( textX > self:GetWide()-20 and textFonts[fontNum+1] ) then
                return CheckNameSize( fontNum+1 )
            end
            return textX, textY, fontNum
        end
    
        local nameX, nameY, fontNum = CheckNameSize( 1 )
        local nameFont, rarityFont = textFonts[fontNum][1], textFonts[fontNum][2]
    
        surface.SetFont( rarityFont )
        local rarityX, rarityY = surface.GetTextSize( displayRarity or "" )
    
        local infoH = (nameY+rarityY)-6
        -- Stat area: quality row + 4 stat bars (spacious layout)
        local statAreaH = isUniqueWeapon and 48 or 0

        self.panelInfo.Paint = function( self2, w, h )
            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x ~= toScreenX or y ~= toScreenY ) then
                x, y = toScreenX, toScreenY
            end

            -- Base background
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( self.themeNum or 2 ) )

            -- ====== RARITY BORDER (2px colored border like MUTINY) ======
            if isUniqueWeapon and uwData and BRS_UW.GetBorderColor then
                local borderColor = BRS_UW.GetBorderColor(uwData.rarity)
                local bT = 2
                surface.SetDrawColor(borderColor)
                -- Top
                surface.DrawRect(bT, 0, w - bT*2, bT)
                -- Bottom  
                surface.DrawRect(bT, h - bT, w - bT*2, bT)
                -- Left
                surface.DrawRect(0, 0, bT, h)
                -- Right
                surface.DrawRect(w - bT, 0, bT, h)
            end

            -- Hover effect
            if( IsValid( self.button ) ) then
                if( not self.button:IsDown() and self.button:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 75 )
                else
                    alpha = math.Clamp( alpha-10, 0, 75 )
                end
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( (self.themeNum or 2)+1, alpha ) )
                BRICKS_SERVER.Func.DrawClickCircle( self.button, w, h, BRICKS_SERVER.Func.GetTheme( (self.themeNum or 2)+1 ), 8 )
            end

            -- ====== NAME + RARITY TEXT ======
            local nameY_pos = h - 8 - statAreaH - 10
            
            -- Weapon name
            draw.SimpleText( configItemTable.Name or "NIL", nameFont, w/2, nameY_pos, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            
            -- Rarity text (small, right under name)
            local rarityDrawColor = BRICKS_SERVER.Func.GetRarityColor( rarityInfo )
            if isUniqueWeapon and uwData and BRS_UW.GetRarityColor then
                rarityDrawColor = BRS_UW.GetRarityColor(uwData.rarity)
            end
            draw.SimpleText( (displayRarity or ""), rarityFont, w/2, nameY_pos + 1, rarityDrawColor, TEXT_ALIGN_CENTER, 0 )

            -- ====== UNIQUE WEAPON: QUALITY + STATS OVERLAY ======
            if isUniqueWeapon and uwData and uwData.stats and BRS_UW.Stats then
                local bottomY = h - 8
                local statsX = 6
                local statsW = w - 12

                -- Quality badge (small, bottom-left) 
                local qualityInfo = BRS_UW.GetQualityInfo and BRS_UW.GetQualityInfo(uwData.quality or "Junk")
                if qualityInfo then
                    draw.RoundedBox(3, statsX, bottomY - 46, 44, 13, ColorAlpha(qualityInfo.color, 160))
                    draw.SimpleText(uwData.quality or "Junk", "BRS_UW_Font8", statsX + 22, bottomY - 39, Color(255,255,255,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                -- Avg boost (small, bottom-right)
                local avgBoost = uwData.avgBoost or 0
                local avgCol = avgBoost >= 50 and Color(80,255,120) or (avgBoost >= 25 and Color(255,200,40) or Color(180,180,180))
                draw.SimpleText("Avg +" .. string.format("%.1f", avgBoost) .. "%", "BRS_UW_Font8", w - 6, bottomY - 39, avgCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                -- 4 stat bars with comfortable spacing
                local barStartY = bottomY - 30
                local barH = 4
                local barSpacing = 3
                local labelW = 26
                local barW = statsW - labelW - 6

                for i, statDef in ipairs(BRS_UW.Stats) do
                    local val = uwData.stats[statDef.key] or 0
                    local barY = barStartY + (i - 1) * (barH + barSpacing)
                    
                    -- Colored label
                    draw.SimpleText(statDef.shortName, "BRS_UW_Font8", statsX + labelW, barY + 1, statDef.color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    
                    -- Bar bg
                    local barX = statsX + labelW + 3
                    draw.RoundedBox(1, barX, barY, barW, barH, Color(15,15,15,220))
                    
                    -- Bar fill
                    local fillW = math.Clamp(val / 100, 0, 1) * barW
                    if fillW > 1 then
                        draw.RoundedBox(1, barX, barY, fillW, barH, ColorAlpha(statDef.color, 200))
                    end
                end
            end
        end
        
        -- Rarity color strip at very bottom
        local rarityBox = vgui.Create( "bricks_server_raritybox", self.panelInfo )
        rarityBox:SetSize( self:GetWide(), 8 )
        rarityBox:SetPos( 0, self:GetTall()-rarityBox:GetTall() )
        rarityBox:SetRarityName( displayRarity or "" )
        rarityBox:SetCornerRadius( 8 )
        rarityBox:SetRoundedBoxDimensions( false, -10, false, 20 )

        -- Item model display (takes up most of card)
        local displayH = self:GetTall() - infoH - 10 - statAreaH
        self.itemDisplay = vgui.Create( "bricks_server_unboxing_itemdisplay", self.panelInfo )
        self.itemDisplay:SetPos( 0, 0 )
        self.itemDisplay:SetSize( self:GetWide(), displayH )
        self.itemDisplay:SetItemData( (isItem and "ITEM") or (isCase and "CASE") or (isKey and "KEY") or "", configItemTable )
        self.itemDisplay:SetIconSizeAdjust( 0.75 )

        -- Top info bar (for Equipped tag, amount, etc - NOT rarity)
        self.topBar = vgui.Create( "DPanel", self.panelInfo )
        self.topBar:SetPos( 4, 4 )
        self.topBar:SetWide( self:GetWide()-8 )
        self.topBar.Paint = function( self2, w2, h2 ) end

        -- Amount badge
        if( amount and amount > 1 ) then
            self:AddTopInfo( string.Comma( amount ) .. "X" )
        end

        -- Permanent tag (only for non-unique, keep it subtle)
        if( isItem and not isUniqueWeapon ) then
            local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type]
            if( devConfigTable and devConfigTable.TagName ) then
                self:AddTopInfo( devConfigTable.TagName, devConfigTable.TagColor, devConfigTable.TagTextColor, true )
            end
        end

        -- For unique weapons: small rarity tag in top-right (like MUTINY's "Glitched" text)
        if isUniqueWeapon and uwData then
            local rCol = BRS_UW.GetRarityColor and BRS_UW.GetRarityColor(uwData.rarity) or Color(200,200,200)
            self:AddTopInfo(uwData.rarity, ColorAlpha(rCol, 180), Color(255,255,255))
        end
    else
        -- Deleted/missing item
        self.panelInfo.Paint = function( self2, w, h )
            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x ~= toScreenX or y ~= toScreenY ) then
                x, y = toScreenX, toScreenY
            end
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( self.themeNum or 2 ) )
            if( IsValid( self.button ) ) then
                if( not self.button:IsDown() and self.button:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 75 )
                else
                    alpha = math.Clamp( alpha-10, 0, 75 )
                end
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( (self.themeNum or 2)+1, alpha ) )
                BRICKS_SERVER.Func.DrawClickCircle( self.button, w, h, BRICKS_SERVER.Func.GetTheme( (self.themeNum or 2)+1 ), 8 )
            end
            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingDeletedItem" ), "BRICKS_SERVER_Font23", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    if( actions ) then
        self.button = vgui.Create( "DButton", self.panelInfo )
        self.button:Dock( FILL )
        self.button:SetText( "" )
        self.button.Paint = function( self2, w, h ) end
        self.button.DoClick = function( self2 )
            if( (istable( actions ) and #actions <= 0) ) then return end
            if( IsValid( self2.popupPanel ) ) then 
                self2.popupPanel:Remove()
                return 
            end
            if( istable( actions ) ) then
                self2.popupPanel = vgui.Create( "bricks_server_popupdmenu" )
                for k, v in pairs( actions or {} ) do
                    self2.popupPanel:AddOption( isfunction( v[1] ) and v[1]() or v[1], v[2] )
                end
                self2.popupPanel:Open( self2, x+w+5, (y+(h/2))-(self2.popupPanel:GetTall()/2) )
            else
                actions( x, y, w, h )
            end
        end
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_itemslot", PANEL, "DPanel" )
