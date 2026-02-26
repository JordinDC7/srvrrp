-- ============================================================
-- SmG RP - Custom Item Slot Card
-- Rarity-driven visuals with premium effects for rare+ items
-- ============================================================
local PANEL = {}

-- ============================================================
-- PARTICLE SYSTEM for Glitched/Mythical cards
-- ============================================================
local cardParticles = {}

local function SpawnParticle(panelID, w, h, rarity, isAscended)
    cardParticles[panelID] = cardParticles[panelID] or {}
    local particles = cardParticles[panelID]
    if #particles > 16 then return end

    if isAscended then
        -- Golden rising star particles
        local startX = math.Rand(4, w - 4)
        table.insert(particles, {
            x = startX,
            y = h - math.Rand(0, 10),
            vx = math.Rand(-6, 6),
            vy = math.Rand(-50, -90),
            size = math.Rand(1.5, 3),
            life = 0,
            maxLife = math.Rand(0.8, 1.6),
            color = Color(255, math.random(200, 255), math.random(60, 140)),
            ascended = true,
            spin = math.Rand(-4, 4),
        })
        return
    end

    if rarity == "Glitched" then
        table.insert(particles, {
            x = math.Rand(4, w - 4),
            y = math.Rand(4, h - 4),
            size = math.Rand(1.5, 3.5),
            life = 0,
            maxLife = math.Rand(0.4, 1.0),
            color = HSVToColor(math.random(0, 360), 0.6, 1),
        })
    elseif rarity == "Mythical" then
        table.insert(particles, {
            x = math.Rand(8, w - 8),
            y = h - math.Rand(5, 15),
            vx = math.Rand(-8, 8),
            vy = math.Rand(-40, -80),
            size = math.Rand(1.5, 3),
            life = 0,
            maxLife = math.Rand(0.6, 1.2),
            color = Color(255, math.random(80, 200), 0),
        })
    end
end

local function UpdateAndDrawParticles(panelID, dt)
    local particles = cardParticles[panelID]
    if not particles then return end

    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life + dt

        if p.life >= p.maxLife then
            table.remove(particles, i)
        else
            local frac = p.life / p.maxLife
            local a = frac < 0.3 and (frac / 0.3) or (1 - ((frac - 0.3) / 0.7))
            a = math.Clamp(a, 0, 1) * 255

            if p.vx then
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
            end

            local col = ColorAlpha(p.color, a)

            if p.ascended then
                -- Draw 4-point star cross
                local sz = p.size * (1 + frac * 0.5)
                local armLen = sz * 2.5
                local armW = sz * 0.6
                -- Vertical arm
                draw.RoundedBox(0, p.x - armW/2, p.y - armLen, armW, armLen * 2, col)
                -- Horizontal arm
                draw.RoundedBox(0, p.x - armLen, p.y - armW/2, armLen * 2, armW, col)
                -- Bright center
                draw.RoundedBox(sz, p.x - sz, p.y - sz, sz * 2, sz * 2, ColorAlpha(Color(255,255,220), a * 0.9))
                -- Outer glow
                local glowSz = sz * 3
                draw.RoundedBox(glowSz, p.x - glowSz, p.y - glowSz, glowSz * 2, glowSz * 2, ColorAlpha(p.color, a * 0.15))
            else
                local sz = p.size * (1 + frac * 0.3)
                draw.RoundedBox(sz, p.x - sz/2, p.y - sz/2, sz, sz, col)
                draw.RoundedBox(sz * 2, p.x - sz, p.y - sz, sz * 2, sz * 2, ColorAlpha(col, a * 0.3))
            end
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

            -- ====== OUTER GLOW (Legendary/Glitched/Mythical) ======
            if isHighTier then
                local pulse = math.sin(ct * 2.5) * 0.4 + 0.6
                local glowA = isGlitched and (20 * pulse) or (isMythical and (25 * pulse) or (15 * pulse))
                draw.RoundedBox(8, -2, -2, w + 4, h + 4, ColorAlpha(borderCol, glowA))
                if isGlitched or isMythical then
                    draw.RoundedBox(10, -4, -4, w + 8, h + 8, ColorAlpha(borderCol, glowA * 0.4))
                end
            end

            -- ====== CARD BACKGROUND ======
            draw.RoundedBox( 6, 0, 0, w, h, C.bg_mid or Color(26,27,35) )

            -- ====== RARITY TOP GRADIENT ======
            if isUniqueWeapon then
                local gradA = isHighTier and 18 or (isEpic and 12 or 8)
                for i = 0, 40 do
                    local a = math.max(0, gradA - i * (gradA / 40))
                    surface.SetDrawColor(ColorAlpha(borderCol, a))
                    surface.DrawRect(1, 1 + i, w - 2, 1)
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

            -- ====== HOLOGRAPHIC SHIMMER (Glitched) ======
            if isGlitched then
                local shimmerW = w * 0.5
                local shimmerX = ((ct * 1.2 + shimmerPhase) % 3.0) / 3.0
                local sx = Lerp(shimmerX, -shimmerW, w + shimmerW)

                local toSX, toSY = self2:LocalToScreen(0, 0)
                render.SetScissorRect(toSX, toSY, toSX + w, toSY + h, true)

                for i = 0, math.floor(shimmerW), 2 do
                    local frac = i / shimmerW
                    local intensity = math.exp(-((frac - 0.5) * 3) ^ 2)
                    local hue = (ct * 80 + frac * 120) % 360
                    local shimCol = HSVToColor(hue, 0.3, 1)
                    surface.SetDrawColor(ColorAlpha(shimCol, intensity * 22))
                    for row = 0, h - 1, 3 do
                        local dx = sx + i + row * 0.4
                        if dx >= 0 and dx < w then
                            surface.DrawRect(dx, row, 2, 3)
                        end
                    end
                end

                render.SetScissorRect(0, 0, 0, 0, false)

                if math.random() < 0.15 then
                    SpawnParticle(panelID, w, h, "Glitched")
                end
            end

            -- ====== FIRE RADIANCE (Mythical) ======
            if isMythical then
                local fireHeight = math.floor(h * 0.6)
                for i = 0, fireHeight do
                    local frac = i / fireHeight
                    local baseA = (1 - frac) * 22
                    local flicker = math.sin(ct * 3 + i * 0.15) * 0.3 + 0.7
                    local waveA = math.sin(ct * 5 + i * 0.3) * 0.15 + 0.85
                    local a = math.max(0, baseA * flicker * waveA)
                    local g = math.floor(60 + frac * 140)
                    surface.SetDrawColor(255, g, 0, a)
                    surface.DrawRect(1, h - 1 - i, w - 2, 1)
                end

                local heatPulse = math.sin(ct * 4) * 0.3 + 0.7
                surface.SetDrawColor(255, 80, 0, 6 * heatPulse)
                surface.DrawRect(1, 1, w - 2, h - 2)

                if math.random() < 0.12 then
                    SpawnParticle(panelID, w, h, "Mythical")
                end
            end

            -- ====== DRAW PARTICLES ======
            if isGlitched or isMythical or isAscended then
                UpdateAndDrawParticles(panelID, dt)
            end

            -- ====== ASCENDED QUALITY EFFECTS (subtle golden aura) ======
            if isAscended then
                local ascT = ct * 1.8
                local breathe = math.sin(ascT) * 0.3 + 0.7

                -- Outer golden glow (subtle)
                local goldCol = Color(255, 215, 60)
                local outerA = 14 * breathe
                draw.RoundedBox(10, -4, -4, w + 8, h + 8, ColorAlpha(goldCol, outerA * 0.3))
                draw.RoundedBox(8, -2, -2, w + 4, h + 4, ColorAlpha(goldCol, outerA))

                -- Golden border overlay (thin, pulsing)
                local bA = 80 + 50 * breathe
                local gold = ColorAlpha(goldCol, bA)
                draw.RoundedBoxEx(6, 0, 0, w, 2, gold, true, true, false, false)
                draw.RoundedBoxEx(6, 0, h - 2, w, 2, gold, false, false, true, true)
                surface.SetDrawColor(gold)
                surface.DrawRect(0, 2, 1, h - 4)
                surface.DrawRect(w - 1, 2, 1, h - 4)

                -- Corner light rays (4 corners, rotating)
                local toSX, toSY = self2:LocalToScreen(0, 0)
                render.SetScissorRect(toSX, toSY, toSX + w, toSY + h, true)

                local corners = {{2, 2}, {w - 2, 2}, {2, h - 2}, {w - 2, h - 2}}
                for ci, corner in ipairs(corners) do
                    local cx, cy = corner[1], corner[2]
                    local rayLen = 20 + 6 * math.sin(ascT * 1.5 + ci * 1.57)
                    local rayA = (25 + 15 * breathe)
                    for r = 0, 3 do
                        local angle = ascT * 0.8 + ci * 1.57 + r * 1.57
                        local ex = cx + math.cos(angle) * rayLen
                        local ey = cy + math.sin(angle) * rayLen
                        for step = 0, 1, 0.1 do
                            local px = Lerp(step, cx, ex)
                            local py = Lerp(step, cy, ey)
                            local stepA = rayA * (1 - step)
                            surface.SetDrawColor(255, 220, 80, stepA)
                            surface.DrawRect(px - 1, py - 1, 2, 2)
                        end
                    end
                end

                -- Sweeping golden shimmer (slow diagonal)
                local shimmerW = w * 0.5
                local shimmerCycle = ((ascT * 0.35) % 4.0) / 4.0
                local sx = Lerp(shimmerCycle, -shimmerW, w + shimmerW)

                for i = 0, math.floor(shimmerW), 2 do
                    local frac = i / shimmerW
                    local intensity = math.exp(-((frac - 0.5) * 3) ^ 2)
                    local shimA = intensity * 12 * breathe
                    surface.SetDrawColor(255, 230, 120, shimA)
                    for row = 0, h - 1, 3 do
                        local dx = sx + i + row * 0.5
                        if dx >= 0 and dx < w then
                            surface.DrawRect(dx, row, 2, 3)
                        end
                    end
                end

                render.SetScissorRect(0, 0, 0, 0, false)

                -- Spawn golden star particles
                if math.random() < 0.14 then
                    SpawnParticle(panelID, w, h, nil, true)
                end
            end

            -- ====== HOVER EFFECT (rarity-colored) ======
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
                        if alpha > 20 then
                            local edgeA = (alpha / 60) * 40
                            draw.RoundedBoxEx(6, 0, 0, w, 2, ColorAlpha(borderCol, edgeA), true, true, false, false)
                            draw.RoundedBoxEx(6, 0, h - 2, w, 2, ColorAlpha(borderCol, edgeA), false, false, true, true)
                        end
                    else
                        draw.RoundedBox( 6, 0, 0, w, h, Color(255, 255, 255, alpha * 0.5) )
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
            draw.SimpleText( displayRarity or "", rarityFont, w/2, textBaseY - rarityY + 4, ColorAlpha(borderCol, 200), TEXT_ALIGN_CENTER, 0 )

            -- ====== UNIQUE WEAPON STATS ======
            if isUniqueWeapon and uwData and uwData.stats and BRS_UW and BRS_UW.Stats then
                local bottomY = h - stripH - 6
                local sX = 8
                local sW = w - 16

                -- ====== STAT BARS (bottom section) ======
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
                    if SMGRP and SMGRP.UI and SMGRP.UI.DrawStatBar then
                        SMGRP.UI.DrawStatBar(bX, bY, bW, barH, math.min(val / 100, 1), statDef.color)
                    else
                        draw.RoundedBox(2, bX, bY, bW, barH, Color(10,10,15,200))
                        local fillW = math.Clamp(val / 100, 0, 1) * bW
                        if fillW > 1 then
                            draw.RoundedBox(2, bX, bY, fillW, barH, ColorAlpha(statDef.color, 200))
                        end
                    end
                    -- Golden overflow glow for stats above 100%
                    if val > 100 and isAscended then
                        local overflowPulse = math.sin(ct * 3 + i) * 0.3 + 0.7
                        draw.RoundedBox(2, bX, bY, bW, barH, ColorAlpha(Color(255, 215, 60), 40 * overflowPulse))
                        draw.RoundedBox(2, bX, bY - 1, bW, barH + 2, ColorAlpha(Color(255, 215, 60), 15 * overflowPulse))
                        -- Show actual value past the bar
                        draw.SimpleText(string.format("%.0f%%", val), "SMGRP_Bold10", bX + bW + 2, bY + barH/2, Color(255, 220, 80, 200 * overflowPulse), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
                        -- Ascended badge: golden pulsing with glow
                        local badgePulse = math.sin(ct * 2.5) * 0.3 + 0.7
                        draw.RoundedBox(3, sX - 1, qualityRowY - 1, pW + 2, pH + 2, ColorAlpha(Color(255, 215, 60), 60 * badgePulse))
                        draw.RoundedBox(3, sX, qualityRowY, pW, pH, Color(180, 140, 20, 220))
                        draw.SimpleText(uwData.quality, "SMGRP_Bold10", sX + pW/2, qualityRowY + pH/2, Color(255, 245, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    else
                        draw.RoundedBox(3, sX, qualityRowY, pW, pH, ColorAlpha(qualityInfo.color, 140))
                        draw.SimpleText(uwData.quality or "Junk", "SMGRP_Bold10", sX + pW/2, qualityRowY + pH/2, Color(255,255,255,220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end

                local avg = uwData.avgBoost or 0
                local avgCol
                if avg >= 100 then
                    -- Golden pulsing for 100%+
                    local gp = math.sin(ct * 3) * 0.2 + 0.8
                    avgCol = ColorAlpha(Color(255, 220, 60), 255 * gp)
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
            self:AddTopInfo(uwData.rarity, ColorAlpha(rCol, 160), Color(255,255,255))
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
