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

    surface.SetFont( "BRICKS_SERVER_Font20B" )
    local topX, topY = surface.GetTextSize( isfunction( text ) and text() or text )
    
    local boxW, boxH = topX+15, topY+5

    self.topBar:SetTall( math.max( self.topBar:GetTall(), boxH ) )

    local infoEntry = vgui.Create( "DPanel", self.topBar )
    infoEntry:Dock( not left and RIGHT or LEFT )
    infoEntry:DockMargin( not left and 5 or 0, 0, left and 5 or 0, 0 )
    infoEntry:SetWide( isMaterial and boxH or boxW )
    infoEntry.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, (istable( color or "" ) and color) or BRICKS_SERVER.Func.GetTheme( (self.themeNum or 2)-1, self.themeNum == 1 and 125 ) )

        if( not isMaterial ) then
            if( not isfunction( text ) ) then
                draw.SimpleText( text, "BRICKS_SERVER_Font20B", w/2, (h/2)-1, textColor or BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            else
                local finalText = text()
                surface.SetFont( "BRICKS_SERVER_Font20B" )
                local topX2, topY2 = surface.GetTextSize( finalText )
                local boxW2 = topX2+15
                if( w ~= boxW2 ) then
                    self2:SetWide( boxW2 )
                end
                draw.SimpleText( finalText, "BRICKS_SERVER_Font20B", w/2, (h/2)-1, textColor or BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        else
            surface.SetDrawColor( textColor or BRICKS_SERVER.Func.GetTheme( 6, 75 ) )
            surface.SetMaterial( textOrMat )
            local iconSize = 16
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
            configItemTable, itemKey, isItem, isCase, isKey = data[2], false, string.StartWith( globalKey, "ITEM_" ), string.StartWith( globalKey, "CASE_" ), string.StartWith( globalKey, "KEY_" )
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
        -- Use unique weapon rarity if available
        local displayRarity = configItemTable.Rarity
        if uwData and uwData.rarity then
            displayRarity = uwData.rarity
        end

        local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( displayRarity )

        local textFonts = { 
            { "BRICKS_SERVER_Font23", "BRICKS_SERVER_Font20" }, 
            { "BRICKS_SERVER_Font22", "BRICKS_SERVER_Font19" }, 
            { "BRICKS_SERVER_Font21", "BRICKS_SERVER_Font18" }, 
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
    
        local infoH = (nameY+rarityY)-4-4
        local statAreaH = isUniqueWeapon and 42 or 0

        self.panelInfo.Paint = function( self2, w, h )
            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x ~= toScreenX or y ~= toScreenY ) then
                x, y = toScreenX, toScreenY
            end

            -- Base background
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( self.themeNum or 2 ) )

            -- ====== UNIQUE WEAPON RARITY BORDER ======
            if isUniqueWeapon and uwData and BRS_UW.GetBorderColor then
                local borderColor = BRS_UW.GetBorderColor(uwData.rarity)
                local bT = 2
                -- Top
                surface.SetDrawColor(borderColor)
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

            -- Weapon name
            local nameY_pos = h - 10 - 25 - statAreaH
            draw.SimpleText( configItemTable.Name or "NIL", nameFont, w/2, nameY_pos+2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            
            -- Rarity text with custom color for unique weapons
            local rarityDrawColor = BRICKS_SERVER.Func.GetRarityColor( rarityInfo )
            if isUniqueWeapon and uwData and BRS_UW.GetRarityColor then
                rarityDrawColor = BRS_UW.GetRarityColor(uwData.rarity)
            end
            draw.SimpleText( (displayRarity or ""), rarityFont, w/2, nameY_pos-2, rarityDrawColor, TEXT_ALIGN_CENTER, 0 )

            -- ====== STAT BARS & QUALITY FOR UNIQUE WEAPONS ======
            if isUniqueWeapon and uwData and uwData.stats and BRS_UW.Stats then
                local statsY = h - 10 - statAreaH + 2
                local statsX = 6
                local statsW = w - 12

                -- Quality badge (bottom-left)
                local qualityInfo = BRS_UW.GetQualityInfo and BRS_UW.GetQualityInfo(uwData.quality or "Junk")
                if qualityInfo then
                    draw.RoundedBox(4, statsX, statsY - 1, 52, 14, ColorAlpha(qualityInfo.color, 160))
                    draw.SimpleText(uwData.quality or "Junk", "BRS_UW_Font8", statsX + 26, statsY + 6, Color(255,255,255,220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                -- Avg boost (bottom-right)
                local avgBoost = uwData.avgBoost or 0
                local avgCol = avgBoost >= 50 and Color(80,255,120) or (avgBoost >= 25 and Color(255,200,40) or Color(200,200,200))
                draw.SimpleText("Avg +" .. string.format("%.0f", avgBoost) .. "%", "BRS_UW_Font8", w - 6, statsY + 6, avgCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                -- 5 mini stat bars
                local barStartY = statsY + 16
                local barH = 3
                local barSpacing = 2
                local labelW = 24
                local barW = statsW - labelW - 4

                for i, statDef in ipairs(BRS_UW.Stats) do
                    local val = uwData.stats[statDef.key] or 0
                    local barY = barStartY + (i - 1) * (barH + barSpacing)
                    
                    -- Label
                    draw.SimpleText(statDef.shortName, "BRS_UW_Font8", statsX + labelW - 2, barY + 1, statDef.color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    
                    -- Bar bg
                    local barX = statsX + labelW + 2
                    draw.RoundedBox(1, barX, barY, barW, barH, Color(20,20,20,200))
                    
                    -- Bar fill
                    local fillW = math.Clamp(val / 100, 0, 1) * barW
                    if fillW > 1 then
                        draw.RoundedBox(1, barX, barY, fillW, barH, ColorAlpha(statDef.color, 220))
                    end
                end
            end
        end
        
        -- Rarity color bar at bottom
        local rarityBox = vgui.Create( "bricks_server_raritybox", self.panelInfo )
        rarityBox:SetSize( self:GetWide(), 10 )
        rarityBox:SetPos( 0, self:GetTall()-rarityBox:GetTall() )
        rarityBox:SetRarityName( displayRarity or "" )
        rarityBox:SetCornerRadius( 8 )
        rarityBox:SetRoundedBoxDimensions( false, -10, false, 20 )

        -- Item model display
        local displayH = self:GetTall()-(infoH+(25-(rarityY-2))+10) - statAreaH
        self.itemDisplay = vgui.Create( "bricks_server_unboxing_itemdisplay", self.panelInfo )
        self.itemDisplay:SetPos( 0, 0 )
        self.itemDisplay:SetSize( self:GetWide(), displayH )
        self.itemDisplay:SetItemData( (isItem and "ITEM") or (isCase and "CASE") or (isKey and "KEY") or "", configItemTable )
        self.itemDisplay:SetIconSizeAdjust( 0.75 )

        -- Top info bar
        self.topBar = vgui.Create( "DPanel", self.panelInfo )
        self.topBar:SetPos( 5, 5 )
        self.topBar:SetWide( self:GetWide()-10 )
        self.topBar.Paint = function( self2, w2, h2 ) end

        if( amount and amount > 1 ) then
            self:AddTopInfo( string.Comma( amount ) .. "X" )
        end

        if( isItem ) then
            local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type]
            if( devConfigTable and devConfigTable.TagName ) then
                self:AddTopInfo( devConfigTable.TagName, devConfigTable.TagColor, devConfigTable.TagTextColor, true )
            end
        end

        -- Rarity tag badge for unique weapons (top-right)
        if isUniqueWeapon and uwData then
            local rCol = BRS_UW.GetRarityColor and BRS_UW.GetRarityColor(uwData.rarity) or Color(200,200,200)
            self:AddTopInfo(uwData.rarity, rCol, Color(255,255,255))
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
