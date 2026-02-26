-- ============================================================
-- SmG RP - Custom Item Slot Card (PERFORMANCE OPTIMIZED)
-- ============================================================
local PANEL = {}

-- ============================================================
-- PRE-ALLOCATED COLORS (zero allocs inside Paint)
-- ============================================================
local _gold      = Color(255, 215, 60)
local _goldBdr   = Color(180, 140, 20, 220)
local _goldTxt   = Color(255, 245, 200)
local _statBg    = Color(10, 10, 15, 200)
local _whiteA220 = Color(255, 255, 255, 220)
local _dc        = Color(0, 0, 0, 0) -- reusable scratch color

-- Ascended: clean premium identity colors
local _ascBorderCol = Color(255, 215, 60, 90)   -- subtle gold border
local _ascCorner    = Color(255, 215, 60, 180)   -- corner diamond
local _ascInnerLine = Color(255, 215, 60, 40)    -- faint inner line

-- ============================================================
-- PARTICLE SYSTEM (swap-remove, pre-alloc colors, capped)
-- ============================================================
local cardParticles = {}
local MAX_PARTICLES = 6

-- Glitched: cyber teal falling chars
local _pcolGlitch = {}
for i = 1, 6 do _pcolGlitch[i] = Color(0, 160 + i * 16, 130 + i * 12) end
-- Mythical: ethereal icy blue light motes
local _pcolMyth = {}
for i = 1, 5 do _pcolMyth[i] = Color(150 + i * 10, 200 + i * 6, 255) end

local function SpawnParticle(panelID, w, h, rarity)
    cardParticles[panelID] = cardParticles[panelID] or {}
    local ps = cardParticles[panelID]
    if #ps >= MAX_PARTICLES then return end
    if rarity == "Glitched" then
        -- Matrix: characters fall from top
        ps[#ps + 1] = { x = math.Rand(6,w-6), y = -math.Rand(2,10), vy = math.Rand(30,70), size = math.Rand(2,4), life = 0, maxLife = math.Rand(0.6,1.4), color = _pcolGlitch[math.random(6)] }
    elseif rarity == "Mythical" then
        -- Angelic: light motes drift upward from bottom
        ps[#ps + 1] = { x = math.Rand(6,w-6), y = h - math.Rand(0,8), vx = math.Rand(-3,3), vy = math.Rand(-30,-60), size = math.Rand(1.5,3), life = 0, maxLife = math.Rand(0.8,1.5), color = _pcolMyth[math.random(5)] }
    end
end

local function UpdateAndDrawParticles(panelID, dt)
    local ps = cardParticles[panelID]
    if not ps then return end
    local n = #ps
    for i = n, 1, -1 do
        local p = ps[i]
        p.life = p.life + dt
        if p.life >= p.maxLife then
            ps[i] = ps[n]; ps[n] = nil; n = n - 1
        else
            local frac = p.life / p.maxLife
            local a = (frac < 0.2) and (frac / 0.2 * 200) or ((1 - (frac - 0.2) / 0.8) * 200)
            if p.vx then p.x = p.x + p.vx * dt end
            if p.vy then p.y = p.y + p.vy * dt end
            _dc.r, _dc.g, _dc.b, _dc.a = p.color.r, p.color.g, p.color.b, a
            surface.SetDrawColor(_dc)
            surface.DrawRect(p.x - p.size/2, p.y - p.size/2, p.size, p.size)
        end
    end
end

-- ============================================================
-- PANEL METHODS
-- ============================================================
function PANEL:Init()
end

function PANEL:OnRemove()
    if self._particleID then
        cardParticles[self._particleID] = nil
    end
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

    local isUniqueWeapon = false
    local uwData = nil
    if globalKey and BRS_UW and BRS_UW.IsUniqueWeapon and BRS_UW.IsUniqueWeapon(globalKey) then
        isUniqueWeapon = true
        uwData = BRS_UW.GetWeaponData(globalKey)
    end

    self._particleID = tostring(self) .. "_" .. tostring(globalKey or "")

    self.panelInfo = vgui.Create( "DPanel", self )
    self.panelInfo:Dock( FILL )

    if( configItemTable ) then
        local displayRarity = configItemTable.Rarity
        if uwData and uwData.rarity then
            displayRarity = uwData.rarity
        end

        local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( displayRarity )

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
        local statAreaH = isUniqueWeapon and 74 or 0

        local rarityColor = (SMGRP and SMGRP.UI and SMGRP.UI.GetRarityColor) and SMGRP.UI.GetRarityColor(displayRarity or "Common") or Color(160,165,175)

        local isGlitched = displayRarity == "Glitched"
        local isMythical = displayRarity == "Mythical"
        local isLegendary = displayRarity == "Legendary"
        local isEpic = displayRarity == "Epic"
        local isHighTier = isGlitched or isMythical or isLegendary
        local hasBorder = isUniqueWeapon and (isHighTier or isEpic or displayRarity == "Rare")
        local isAscended = isUniqueWeapon and uwData and uwData.quality == "Ascended"

        local shimmerPhase = math.Rand(0, 100)
        local panelID = self._particleID

        self.panelInfo.Paint = function( self2, w, h )
            local C = SMGRP and SMGRP.UI and SMGRP.UI.Colors or {}
            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x ~= toScreenX or y ~= toScreenY ) then
                x, y = toScreenX, toScreenY
            end

            local dt = FrameTime()
            local ct = CurTime()

            local borderCol = rarityColor
            if isUniqueWeapon and BRS_UW and BRS_UW.GetBorderColor then
                borderCol = BRS_UW.GetBorderColor(displayRarity) or rarityColor
            end

            -- ====== OUTER GLOW (high tier, skip for Ascended) ======
            if isHighTier and not isAscended then
                local pulse = math.sin(ct * 2) * 0.3 + 0.7
                local glowA = isMythical and (22 * pulse) or (isGlitched and (10 * pulse) or (8 * pulse))
                draw.RoundedBox(8, -2, -2, w + 4, h + 4, ColorAlpha(borderCol, glowA))
            end

            -- ====== CARD BACKGROUND ======
            draw.RoundedBox( 6, 0, 0, w, h, C.bg_mid or Color(26,27,35) )

            -- ====== RARITY TOP GRADIENT ======
            if isUniqueWeapon then
                local gradA = isMythical and 18 or (isHighTier and 12 or (isEpic and 8 or 5))
                for i = 0, 4 do
                    _dc.r, _dc.g, _dc.b, _dc.a = borderCol.r, borderCol.g, borderCol.b, gradA * (1 - i/5)
                    surface.SetDrawColor(_dc)
                    surface.DrawRect(1, 1 + i*8, w - 2, 8)
                end
            end

            -- ====== ANIMATED BORDER ======
            if hasBorder then
                local bT = (isGlitched or isMythical) and 2 or 1
                draw.RoundedBoxEx(6, 0, 0, w, bT, borderCol, true, true, false, false)
                draw.RoundedBoxEx(6, 0, h - bT, w, bT, borderCol, false, false, true, true)
                surface.SetDrawColor(borderCol)
                surface.DrawRect(0, bT, bT, h - bT * 2)
                surface.DrawRect(w - bT, bT, bT, h - bT * 2)
            else
                surface.SetDrawColor(C.border or Color(50,52,65))
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end

            -- ====== CYBER DIGITAL RAIN (Glitched) ======
            if isGlitched then
                local toSX, toSY = self2:LocalToScreen(0, 0)
                render.SetScissorRect(toSX, toSY, toSX + w, toSY + h, true)
                local cols = 6
                local charH = 4
                local spacing = (w - 8) / cols
                for col = 0, cols - 1 do
                    local seed = shimmerPhase + col * 7.3
                    local speed = 25 + math.sin(seed) * 10
                    local colX = 4 + col * spacing
                    for ch = 0, 3 do
                        local baseY = ((ct * speed + ch * (h / 3) + seed * 20) % (h + 20)) - 10
                        local brightness = (ch == 0) and 1 or (0.3 + math.sin(ct * 3 + col + ch) * 0.2)
                        local g = math.floor(200 * brightness + 55)
                        local b = math.floor(g * 0.75)
                        _dc.r, _dc.g, _dc.b, _dc.a = 0, g, b, (ch == 0) and 18 or 10
                        surface.SetDrawColor(_dc)
                        surface.DrawRect(colX, baseY, 2, charH)
                    end
                end
                render.SetScissorRect(0, 0, 0, 0, false)
                if math.random() < 0.06 then SpawnParticle(panelID, w, h, "Glitched") end
            end

            -- ====== HEAVENLY RADIANCE (Mythical) - icy blue light from top ======
            if isMythical then
                local lightH = h * 0.55
                local bandH = lightH / 6
                for i = 0, 5 do
                    local frac = i / 6
                    local baseA = (1 - frac) * 25
                    local breathe = math.sin(ct * 1.5 + i * 0.5) * 0.2 + 0.8
                    _dc.r, _dc.g, _dc.b, _dc.a = 160, 210, 255, baseA * breathe
                    surface.SetDrawColor(_dc)
                    surface.DrawRect(1, 1 + i * bandH, w - 2, bandH)
                end

                -- Center light pillar
                local colW = w * 0.35
                local colX = (w - colW) / 2
                local colA = 10 + math.sin(ct * 2) * 5
                _dc.r, _dc.g, _dc.b, _dc.a = 180, 225, 255, colA
                surface.SetDrawColor(_dc)
                surface.DrawRect(colX, 1, colW, h - 2)

                if math.random() < 0.07 then SpawnParticle(panelID, w, h, "Mythical") end
            end

            -- ====== DRAW PARTICLES (Glitched + Mythical only) ======
            if isGlitched or isMythical then
                UpdateAndDrawParticles(panelID, dt)
            end

            -- ====== ASCENDED IDENTITY (clean premium - no particles/glow) ======
            if isAscended then
                -- Thin gold inner border (1px, subtle breathing)
                local ascA = 45 + math.sin(ct * 1.5) * 12
                _dc.r, _dc.g, _dc.b, _dc.a = 255, 215, 60, ascA
                surface.SetDrawColor(_dc)
                surface.DrawOutlinedRect(2, 2, w - 4, h - 4, 1)

                -- Small diamond markers in 4 corners
                _dc.a = 130
                surface.SetDrawColor(_dc)
                surface.DrawRect(4, 4, 3, 3)
                surface.DrawRect(w - 7, 4, 3, 3)
                surface.DrawRect(4, h - 7, 3, 3)
                surface.DrawRect(w - 7, h - 7, 3, 3)
            end

            -- ====== HOVER EFFECT ======
            if( IsValid( self.button ) ) then
                local isHovered = not self.button:IsDown() and self.button:IsHovered()
                if isHovered then
                    alpha = math.Clamp( alpha + 12, 0, 60 )
                else
                    alpha = math.Clamp( alpha - 8, 0, 60 )
                end
                if alpha > 0 then
                    if isUniqueWeapon then
                        draw.RoundedBox( 6, 0, 0, w, h, ColorAlpha(borderCol, alpha * 0.7) )
                    else
                        _dc.r, _dc.g, _dc.b, _dc.a = 255, 255, 255, alpha * 0.5
                        draw.RoundedBox( 6, 0, 0, w, h, _dc )
                    end
                end
            end

            -- ====== RARITY BOTTOM STRIP ======
            local stripH = isHighTier and 4 or 3
            draw.RoundedBoxEx(4, 0, h - stripH, w, stripH, borderCol, false, false, true, true)

            if isUniqueWeapon then
                surface.SetDrawColor(ColorAlpha(borderCol, 100))
                surface.DrawRect(0, 8, 2, h - 16)
            end

            -- ====== NAME + RARITY ======
            local textBaseY = h - 8 - statAreaH
            draw.SimpleText( configItemTable.Name or "NIL", nameFont, w/2, textBaseY - rarityY + 2, C.text_primary or Color(220,222,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

            -- Glitched rarity label: matrix flicker effect
            if isGlitched then
                local flkG = 200 + math.sin(ct * 12) * 55 + math.sin(ct * 31) * 30
                local flkB = flkG * 0.75
                local flkA = 180 + math.sin(ct * 7) * 40
                _dc.r, _dc.g, _dc.b, _dc.a = 0, math.floor(math.Clamp(flkG, 140, 255)), math.floor(math.Clamp(flkB, 100, 200)), math.floor(math.Clamp(flkA, 140, 255))
                draw.SimpleText( displayRarity or "", rarityFont, w/2, textBaseY - rarityY + 4, _dc, TEXT_ALIGN_CENTER, 0 )
            elseif isMythical then
                -- Ethereal: icy blue text with gentle breathing
                local mythA = 210 + math.sin(ct * 1.8) * 40
                _dc.r, _dc.g, _dc.b, _dc.a = 175, 215, 255, math.floor(mythA)
                draw.SimpleText( displayRarity or "", rarityFont, w/2, textBaseY - rarityY + 4, _dc, TEXT_ALIGN_CENTER, 0 )
            else
                draw.SimpleText( displayRarity or "", rarityFont, w/2, textBaseY - rarityY + 4, rarityColor, TEXT_ALIGN_CENTER, 0 )
            end

            -- ====== UNIQUE WEAPON STATS ======
            if isUniqueWeapon and uwData and uwData.stats and BRS_UW and BRS_UW.Stats then
                local bottomY = h - stripH - 6
                local sX = 8
                local sW = w - 16
                local barH = 4
                local barGap = 3
                local lblW = 32
                local bX = sX + lblW + 4
                local bW = sW - lblW - 4
                local totalBarsH = #BRS_UW.Stats * (barH + barGap) - barGap
                local barY0 = bottomY - totalBarsH

                for i, statDef in ipairs(BRS_UW.Stats) do
                    local val = uwData.stats[statDef.key] or 0
                    local bY = barY0 + (i - 1) * (barH + barGap)
                    draw.SimpleText(statDef.shortName, "SMGRP_Bold10", sX + lblW, bY + barH/2, statDef.color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    draw.RoundedBox(2, bX, bY, bW, barH, _statBg)
                    local fillW = math.min(val / 100, 1) * bW
                    if fillW > 1 then
                        draw.RoundedBox(2, bX, bY, fillW, barH, statDef.color)
                    end
                    if val > 100 and isAscended then
                        local pulse = math.sin(ct * 3 + i) * 0.3 + 0.7
                        _dc.r, _dc.g, _dc.b, _dc.a = 255, 215, 60, 40 * pulse
                        draw.RoundedBox(2, bX, bY, bW, barH, _dc)
                    end
                end

                -- ====== QUALITY BADGE + AVG BOOST (above bars with gap) ======
                local qualityRowY = barY0 - 20
                local qualityInfo = BRS_UW.GetQualityInfo and BRS_UW.GetQualityInfo(uwData.quality or "Junk")
                if qualityInfo then
                    surface.SetFont("SMGRP_Bold10")
                    local qTW = surface.GetTextSize(uwData.quality or "Junk")
                    local pW, pH = qTW + 12, 16

                    if isAscended then
                        local badgePulse = math.sin(ct * 2.5) * 0.3 + 0.7
                        _dc.r, _dc.g, _dc.b, _dc.a = 255, 215, 60, 60 * badgePulse
                        draw.RoundedBox(3, sX - 1, qualityRowY - 1, pW + 2, pH + 2, _dc)
                        draw.RoundedBox(3, sX, qualityRowY, pW, pH, _goldBdr)
                        draw.SimpleText(uwData.quality, "SMGRP_Bold10", sX + pW/2, qualityRowY + pH/2, _goldTxt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    else
                        local qc = qualityInfo.color
                        _dc.r, _dc.g, _dc.b, _dc.a = qc.r, qc.g, qc.b, 140
                        draw.RoundedBox(3, sX, qualityRowY, pW, pH, _dc)
                        draw.SimpleText(uwData.quality or "Junk", "SMGRP_Bold10", sX + pW/2, qualityRowY + pH/2, _whiteA220, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end

                local avg = uwData.avgBoost or 0
                local avgCol
                if avg >= 100 then
                    local gp = math.sin(ct * 3) * 0.2 + 0.8
                    _dc.r, _dc.g, _dc.b, _dc.a = 255, 220, 60, 255 * gp
                    avgCol = _dc
                elseif avg >= 50 then
                    avgCol = C.green or Color(60,200,120)
                elseif avg >= 25 then
                    avgCol = C.amber or Color(255,185,50)
                else
                    avgCol = C.text_muted or Color(90,94,110)
                end
                draw.SimpleText("+" .. string.format("%.1f", avg) .. "%", "SMGRP_Bold10", w - 8, qualityRowY + 8, avgCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
        
        local rarityBox = vgui.Create( "bricks_server_raritybox", self.panelInfo )
        rarityBox:SetSize( self:GetWide(), 3 )
        rarityBox:SetPos( 0, self:GetTall() - 3 )
        rarityBox:SetRarityName( displayRarity or "" )
        rarityBox:SetCornerRadius( 6 )
        rarityBox:SetRoundedBoxDimensions( false, -10, false, 20 )

        local displayH = self:GetTall() - infoH - 8 - statAreaH
        self.itemDisplay = vgui.Create( "bricks_server_unboxing_itemdisplay", self.panelInfo )
        self.itemDisplay:SetPos( 0, 0 )
        self.itemDisplay:SetSize( self:GetWide(), displayH )
        self.itemDisplay:SetItemData( (isItem and "ITEM") or (isCase and "CASE") or (isKey and "KEY") or "", configItemTable )
        self.itemDisplay:SetIconSizeAdjust( 0.75 )

        self.topBar = vgui.Create( "DPanel", self.panelInfo )
        self.topBar:SetPos( 5, 5 )
        self.topBar:SetWide( self:GetWide() - 10 )
        self.topBar.Paint = function() end

        if( amount and amount > 1 ) then
            self:AddTopInfo( string.Comma( amount ) .. "x" )
        end

        if( isItem and not isUniqueWeapon ) then
            local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type]
            if( devConfigTable and devConfigTable.TagName ) then
                self:AddTopInfo( devConfigTable.TagName, devConfigTable.TagColor, devConfigTable.TagTextColor, true )
            end
        end

        if isUniqueWeapon and uwData then
            local rCol = SMGRP.UI.GetRarityColor(uwData.rarity)
            if isGlitched then
                -- Matrix-style: dark pill with green text
                self:AddTopInfo(uwData.rarity, Color(5, 20, 18, 200), Color(0, 255, 200))
            elseif isMythical then
                -- Heavenly: icy blue pill with dark text
                self:AddTopInfo(uwData.rarity, Color(170, 215, 255, 210), Color(20, 40, 70))
            else
                self:AddTopInfo(uwData.rarity, Color(rCol.r, rCol.g, rCol.b, 160), Color(255,255,255))
            end
        end
    else
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
