-- ============================================================
-- SmG RP - Custom Item Slot Card
-- Dark tactical design with clean stat display
-- ============================================================
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

    local font = "SMGRP_Bold10"
    surface.SetFont( font )
    local topX, topY = surface.GetTextSize( isfunction( text ) and text() or text )
    
    local boxW, boxH = topX + 10, topY + 4

    self.topBar:SetTall( math.max( self.topBar:GetTall(), boxH ) )

    local infoEntry = vgui.Create( "DPanel", self.topBar )
    infoEntry:Dock( not left and RIGHT or LEFT )
    infoEntry:DockMargin( not left and 3 or 0, 0, left and 3 or 0, 0 )
    infoEntry:SetWide( isMaterial and boxH or boxW )
    infoEntry.Paint = function( self2, w, h )
        local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors
        local bgCol = (istable( color or "" ) and color) or (C and C.bg_darkest or Color(12,12,18))
        draw.RoundedBox( 3, 0, 0, w, h, ColorAlpha(bgCol, 200) )

        if( not isMaterial ) then
            if( not isfunction( text ) ) then
                draw.SimpleText( text, font, w/2, h/2, textColor or (C and C.text_secondary or Color(140,144,160)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            else
                local finalText = text()
                surface.SetFont( font )
                local topX2 = surface.GetTextSize( finalText )
                local boxW2 = topX2 + 10
                if( w ~= boxW2 ) then self2:SetWide( boxW2 ) end
                draw.SimpleText( finalText, font, w/2, h/2, textColor or (C and C.text_secondary or Color(140,144,160)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        else
            surface.SetDrawColor( textColor or Color(140,144,160) )
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

        -- Font selection for weapon name
        local textFonts = { 
            { "SMGRP_Bold14", "SMGRP_Body12" }, 
            { "SMGRP_Bold13", "SMGRP_Body12" }, 
            { "SMGRP_Bold12", "SMGRP_Tiny9" }
        }
        
        local function CheckNameSize( fontNum )
            surface.SetFont( textFonts[fontNum][1] )
            local textX, textY = surface.GetTextSize( configItemTable.Name or "NIL" )
            if( textX > self:GetWide()-16 and textFonts[fontNum+1] ) then
                return CheckNameSize( fontNum+1 )
            end
            return textX, textY, fontNum
        end
    
        local nameX, nameY, fontNum = CheckNameSize( 1 )
        local nameFont, rarityFont = textFonts[fontNum][1], textFonts[fontNum][2]
    
        surface.SetFont( rarityFont )
        local rarityX, rarityY = surface.GetTextSize( displayRarity or "" )
    
        local infoH = (nameY + rarityY) - 4
        local statAreaH = isUniqueWeapon and 52 or 0

        -- Get rarity color once
        local rarityColor = (SMGRP and SMGRP.UI and SMGRP.UI.GetRarityColor) and SMGRP.UI.GetRarityColor(displayRarity or "Common") or Color(160,165,175)

        self.panelInfo.Paint = function( self2, w, h )
            local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x ~= toScreenX or y ~= toScreenY ) then
                x, y = toScreenX, toScreenY
            end

            -- ====== CARD BACKGROUND ======
            draw.RoundedBox( 6, 0, 0, w, h, C.bg_mid or Color(26,27,35) )

            -- Subtle 1px border
            surface.SetDrawColor(C.border or Color(50,52,65))
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            -- ====== RARITY BOTTOM STRIP ======
            local stripH = 3
            local stripCol = rarityColor

            if isUniqueWeapon and uwData then
                if uwData.rarity == "Glitched" and SMGRP.UI.GetGlitchedColor then
                    stripCol = SMGRP.UI.GetGlitchedColor()
                elseif uwData.rarity == "Mythical" and SMGRP.UI.GetMythicalColor then
                    stripCol = SMGRP.UI.GetMythicalColor()
                end
            end

            draw.RoundedBoxEx(4, 0, h - stripH, w, stripH, stripCol, false, false, true, true)

            -- Left accent bar for unique weapons
            if isUniqueWeapon then
                surface.SetDrawColor(ColorAlpha(stripCol, 100))
                surface.DrawRect(0, 8, 2, h - 16)
            end

            -- ====== HOVER ======
            if( IsValid( self.button ) ) then
                if( not self.button:IsDown() and self.button:IsHovered() ) then
                    alpha = math.Clamp( alpha + 12, 0, 45 )
                else
                    alpha = math.Clamp( alpha - 8, 0, 45 )
                end
                if alpha > 0 then
                    draw.RoundedBox( 6, 0, 0, w, h, Color(255, 255, 255, alpha) )
                end
            end

            -- ====== NAME + RARITY ======
            local textBaseY = h - 8 - statAreaH

            draw.SimpleText( configItemTable.Name or "NIL", nameFont, w/2, textBaseY - rarityY + 2, C.text_primary or Color(220,222,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            draw.SimpleText( displayRarity or "", rarityFont, w/2, textBaseY - rarityY + 4, ColorAlpha(stripCol, 200), TEXT_ALIGN_CENTER, 0 )

            -- ====== UNIQUE WEAPON STATS ======
            if isUniqueWeapon and uwData and uwData.stats and BRS_UW and BRS_UW.Stats then
                local bottomY = h - stripH - 5
                local sX = 8
                local sW = w - 16

                -- Quality pill (bottom-left)
                local qualityInfo = BRS_UW.GetQualityInfo and BRS_UW.GetQualityInfo(uwData.quality or "Junk")
                if qualityInfo then
                    surface.SetFont("SMGRP_Bold10")
                    local qTW = surface.GetTextSize(uwData.quality or "Junk")
                    local pW, pH = qTW + 10, 14
                    local pY = bottomY - 38

                    draw.RoundedBox(3, sX, pY, pW, pH, ColorAlpha(qualityInfo.color, 140))
                    draw.SimpleText(uwData.quality or "Junk", "SMGRP_Bold10", sX + pW/2, pY + pH/2, Color(255,255,255,220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                -- Avg boost (bottom-right)
                local avg = uwData.avgBoost or 0
                local avgCol = avg >= 50 and (C.green or Color(60,200,120)) or (avg >= 25 and (C.amber or Color(255,185,50)) or (C.text_muted or Color(90,94,110)))
                draw.SimpleText("+" .. string.format("%.1f", avg) .. "%", "SMGRP_Bold10", w - 8, bottomY - 38 + 7, avgCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                -- 4 stat bars
                local barY0 = bottomY - 22
                local barH = 4
                local barGap = 3
                local lblW = 28
                local bX = sX + lblW + 4
                local bW = sW - lblW - 4

                for i, statDef in ipairs(BRS_UW.Stats) do
                    local val = uwData.stats[statDef.key] or 0
                    local bY = barY0 + (i - 1) * (barH + barGap)
                    
                    draw.SimpleText(statDef.shortName, "SMGRP_Bold10", sX + lblW, bY + barH/2, statDef.color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    
                    if SMGRP and SMGRP.UI and SMGRP.UI.DrawStatBar then
                        SMGRP.UI.DrawStatBar(bX, bY, bW, barH, val / 100, statDef.color)
                    else
                        draw.RoundedBox(2, bX, bY, bW, barH, Color(10,10,15,200))
                        local fillW = math.Clamp(val / 100, 0, 1) * bW
                        if fillW > 1 then
                            draw.RoundedBox(2, bX, bY, fillW, barH, ColorAlpha(statDef.color, 200))
                        end
                    end
                end
            end
        end
        
        -- Bricks rarity strip (hidden under our custom one, needed for case opening anim)
        local rarityBox = vgui.Create( "bricks_server_raritybox", self.panelInfo )
        rarityBox:SetSize( self:GetWide(), 3 )
        rarityBox:SetPos( 0, self:GetTall() - 3 )
        rarityBox:SetRarityName( displayRarity or "" )
        rarityBox:SetCornerRadius( 6 )
        rarityBox:SetRoundedBoxDimensions( false, -10, false, 20 )

        -- Item model display
        local displayH = self:GetTall() - infoH - 8 - statAreaH
        self.itemDisplay = vgui.Create( "bricks_server_unboxing_itemdisplay", self.panelInfo )
        self.itemDisplay:SetPos( 0, 0 )
        self.itemDisplay:SetSize( self:GetWide(), displayH )
        self.itemDisplay:SetItemData( (isItem and "ITEM") or (isCase and "CASE") or (isKey and "KEY") or "", configItemTable )
        self.itemDisplay:SetIconSizeAdjust( 0.75 )

        -- Top info bar
        self.topBar = vgui.Create( "DPanel", self.panelInfo )
        self.topBar:SetPos( 5, 5 )
        self.topBar:SetWide( self:GetWide() - 10 )
        self.topBar.Paint = function() end

        -- Amount badge
        if( amount and amount > 1 ) then
            self:AddTopInfo( string.Comma( amount ) .. "x" )
        end

        -- Permanent tag (non-unique only)
        if( isItem and not isUniqueWeapon ) then
            local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type]
            if( devConfigTable and devConfigTable.TagName ) then
                self:AddTopInfo( devConfigTable.TagName, devConfigTable.TagColor, devConfigTable.TagTextColor, true )
            end
        end

        -- Rarity tag for unique weapons
        if isUniqueWeapon and uwData then
            local rCol = SMGRP.UI.GetRarityColor(uwData.rarity)
            self:AddTopInfo(uwData.rarity, ColorAlpha(rCol, 160), Color(255,255,255))
        end
    else
        -- Missing/deleted item
        self.panelInfo.Paint = function( self2, w, h )
            local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x ~= toScreenX or y ~= toScreenY ) then x, y = toScreenX, toScreenY end
            draw.RoundedBox( 6, 0, 0, w, h, C.bg_mid or Color(26,27,35) )
            surface.SetDrawColor(C.border or Color(50,52,65))
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            if( IsValid( self.button ) ) then
                if( not self.button:IsDown() and self.button:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 45 )
                else
                    alpha = math.Clamp( alpha-10, 0, 45 )
                end
                if alpha > 0 then
                    draw.RoundedBox( 6, 0, 0, w, h, Color(255,255,255, alpha) )
                end
            end
            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingDeletedItem" ), "SMGRP_Body14", w/2, h/2, C.text_muted or Color(90,94,110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    if( actions ) then
        self.button = vgui.Create( "DButton", self.panelInfo )
        self.button:Dock( FILL )
        self.button:SetText( "" )
        self.button.Paint = function() end
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
