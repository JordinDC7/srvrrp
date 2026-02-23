-- Revised: 76561223073791539

FERMA = FERMA or {}
FERMA.CORE = FERMA.CORE or {}

local blur = Material( "pp/blurscreen" )

function FERMA.CORE.Fermafy( style, parent )
    local FT = {}
    
    FT.FWidth = style["width"] or 100
    FT.FHeight = style["height"] or 100

    FT.FPosX = style["x"] or 0
    FT.FPosY = style["y"] or 0

    FT.FLeft = style["left"] or 0
    FT.FRight = style["right"] or 0
    FT.FTop = style["top"] or 0
    FT.FBottom = style["bottom"] or 0

    FT.FMargin = style["margin"] or { 0 }
    FT.FMarginLeft = style["margin-left"] or nil
    FT.FMarginTop = style["margin-top"] or nil
    FT.FMarginRight = style["margin-right"] or nil
    FT.FMarginBottom = style["margin-bottom"] or nil

    FT.FBefore = style["before"] or nil
    FT.FBeforeX = 0
    FT.FBeforeWidth = 0
    FT.FBeforeMarginLeft = 0

    FT.FAfter = style["after"] or nil
    FT.FAfterX = 0
    FT.FAfterWidth = 0
    FT.FAfterMarginRight = 0

    FT.FAbove = style["above"] or nil
    FT.FAboveY = 0
    FT.FAboveHeight = 0
    FT.FAboveMarginTop = 0

    FT.FBelow = style["below"] or nil
    FT.FBelowY = 0
    FT.FBelowHeight = 0
    FT.FBelowMarginBottom = 0

    FT.FZIndex = style["z-index"] or nil
    FT.FAlpha = style["opacity"] or nil
    FT.FFloat = style["float"] or nil

    FT.FPopup = style["popup"] or false
    FT.FCenter = style["center"] or false
    FT.FParent = parent or nil

    if( type( FT.FWidth ) == "string"  ) then
        if( string.match( FT.FWidth, "%%" ) == "%" ) then
            FT.FWidth = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FWidth, "%", "" ) )
        elseif( string.match( FT.FWidth, "vw" ) == "vw" ) then
            FT.FWidth = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FWidth, "vw", "" ) )
        elseif( string.match( FT.FWidth, "vh" ) == "vh" ) then
            FT.FWidth = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FWidth, "vh", "" ) )
        end
    end

    if( type( FT.FHeight ) == "string"  ) then
        if( string.match( FT.FHeight, "%%" ) == "%" ) then
            FT.FHeight = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FHeight, "%", "" ) )
        elseif( string.match( FT.FHeight, "vw" ) == "vw" ) then
            FT.FHeight = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FHeight, "vw", "" ) )
        elseif( string.match( FT.FHeight, "vh" ) == "vh" ) then
            FT.FHeight = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FHeight, "vh", "" ) )
        end
    end

    if( type( FT.FMarginLeft ) == "string"  ) then
        if( string.match( FT.FMarginLeft, "%%" ) == "%" ) then
            FT.FMarginLeft = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginLeft, "%", "" ) )
        elseif( string.match( FT.FMarginLeft, "vw" ) == "vw" ) then
            FT.FMarginLeft = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMarginLeft, "vw", "" ) )
        elseif( string.match( FT.FMarginLeft, "vh" ) == "vh" ) then
            FT.FMarginLeft = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginLeft, "vh", "" ) )
        end
    end

    if( type( FT.FMarginTop ) == "string"  ) then
        if( string.match( FT.FMarginTop, "%%" ) == "%" ) then
            FT.FMarginTop = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginTop, "%", "" ) )
        elseif( string.match( FT.FMarginTop, "vw" ) == "vw" ) then
            FT.FMarginTop = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMarginTop, "vw", "" ) )
        elseif( string.match( FT.FMarginTop, "vh" ) == "vh" ) then
            FT.FMarginTop = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginTop, "vh", "" ) )
        end
    end

    if( type( FT.FMarginRight ) == "string"  ) then
        if( string.match( FT.FMarginRight, "%%" ) == "%" ) then
            FT.FMarginRight = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginRight, "%", "" ) )
        elseif( string.match( FT.FMarginRight, "vw" ) == "vw" ) then
            FT.FMarginRight = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMarginRight, "vw", "" ) )
        elseif( string.match( FT.FMarginRight, "vh" ) == "vh" ) then
            FT.FMarginRight = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginRight, "vh", "" ) )
        end
    end

    if( type( FT.FMarginBottom ) == "string"  ) then
        if( string.match( FT.FMarginBottom, "%%" ) == "%" ) then
            FT.FMarginBottom = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginBottom, "%", "" ) )
        elseif( string.match( FT.FMarginBottom, "vw" ) == "vw" ) then
            FT.FMarginBottom = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMarginBottom, "vw", "" ) )
        elseif( string.match( FT.FMarginBottom, "vh" ) == "vh" ) then
            FT.FMarginBottom = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginBottom, "vh", "" ) )
        end
    end

    if( type( FT.FMargin[1] ) == "string"  ) then
        if( string.match( FT.FMargin[1], "%%" ) == "%" ) then
            FT.FMargin[1] = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMargin[1], "%", "" ) )
        elseif( string.match( FT.FMargin[1], "vw" ) == "vw" ) then
            FT.FMargin[1] = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMargin[1], "vw", "" ) )
        elseif( string.match( FT.FMargin[1], "vh" ) == "vh" ) then
            FT.FMargin[1] = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMargin[1], "vh", "" ) )
        end
    end

    if( type( FT.FMargin[2] ) == "string"  ) then
        if( string.match( FT.FMargin[2], "%%" ) == "%" ) then
            FT.FMargin[2] = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMargin[2], "%", "" ) )
        elseif( string.match( FT.FMargin[2], "vw" ) == "vw" ) then
            FT.FMargin[2] = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMargin[2], "vw", "" ) )
        elseif( string.match( FT.FMargin[2], "vh" ) == "vh" ) then
            FT.FMargin[2] = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMargin[2], "vh", "" ) )
        end
    end

    if( type( FT.FMargin[3] ) == "string"  ) then
        if( string.match( FT.FMargin[3], "%%" ) == "%" ) then
            FT.FMargin[3] = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMargin[3], "%", "" ) )
        elseif( string.match( FT.FMargin[3], "vw" ) == "vw" ) then
            FT.FMargin[3] = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMargin[3], "vw", "" ) )
        elseif( string.match( FT.FMargin[3], "vh" ) == "vh" ) then
            FT.FMargin[3] = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMargin[3], "vh", "" ) )
        end
    end

    if( type( FT.FMargin[4] ) == "string"  ) then
        if( string.match( FT.FMargin[4], "%%" ) == "%" ) then
            FT.FMargin[4] = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMargin[4], "%", "" ) )
        elseif( string.match( FT.FMargin[4], "vw" ) == "vw" ) then
            FT.FMargin[4] = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMargin[4], "vw", "" ) )
        elseif( string.match( FT.FMargin[4], "vh" ) == "vh" ) then
            FT.FMargin[4] = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMargin[4], "vh", "" ) )
        end
    end

    if( type( FT.FMarginLeft ) == "string"  ) then
        if( string.match( FT.FMarginLeft, "%%" ) == "%" ) then
            FT.FMarginLeft = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMarginLeft, "%", "" ) )
        elseif( string.match( FT.FMarginLeft, "vw" ) == "vw" ) then
            FT.FMarginLeft = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMarginLeft, "vw", "" ) )
        elseif( string.match( FT.FMarginLeft, "vh" ) == "vh" ) then
            FT.FMarginLeft = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginLeft, "vh", "" ) )
        end
    end

    if( type( FT.FMarginTop ) == "string"  ) then
        if( string.match( FT.FMarginTop, "%%" ) == "%" ) then
            FT.FMarginTop = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginTop, "%", "" ) )
        elseif( string.match( FT.FMarginTop, "vw" ) == "vw" ) then
            FT.FMarginTop = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMarginTop, "vw", "" ) )
        elseif( string.match( FT.FMarginTop, "vh" ) == "vh" ) then
            FT.FMarginTop = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginTop, "vh", "" ) )
        end
    end

    if( type( FT.FMarginRight ) == "string"  ) then
        if( string.match( FT.FMarginRight, "%%" ) == "%" ) then
            FT.FMarginRight = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMarginRight, "%", "" ) )
        elseif( string.match( FT.FMarginRight, "vw" ) == "vw" ) then
            FT.FMarginRight = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMarginRight, "vw", "" ) )
        elseif( string.match( FT.FMarginRight, "vh" ) == "vh" ) then
            FT.FMarginRight = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginRight, "vh", "" ) )
        end
    end

    if( type( FT.FMarginBottom ) == "string"  ) then
        if( string.match( FT.FMarginBottom, "%%" ) == "%" ) then
            FT.FMarginBottom = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginBottom, "%", "" ) )
        elseif( string.match( FT.FMarginBottom, "vw" ) == "vw" ) then
            FT.FMarginBottom = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FMarginBottom, "vw", "" ) )
        elseif( string.match( FT.FMarginBottom, "vh" ) == "vh" ) then
            FT.FMarginBottom = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FMarginBottom, "vh", "" ) )
        end
    end

    if( type( FT.FLeft ) == "string"  ) then
        if( string.match( FT.FLeft, "%%" ) == "%" ) then
            FT.FLeft = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FLeft, "%", "" ) )
        elseif( string.match( FT.FLeft, "vw" ) == "vw" ) then
            FT.FLeft = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FLeft, "vw", "" ) )
        elseif( string.match( FT.FLeft, "vh" ) == "vh" ) then
            FT.FLeft = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FLeft, "vh", "" ) )
        end
    end

    if( type( FT.FTop ) == "string"  ) then
        if( string.match( FT.FTop, "%%" ) == "%" ) then
            FT.FTop = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FTop, "%", "" ) )
        elseif( string.match( FT.FTop, "vw" ) == "vw" ) then
            FT.FTop = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FTop, "vw", "" ) )
        elseif( string.match( FT.FTop, "vh" ) == "vh" ) then
            FT.FTop = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FTop, "vh", "" ) )
        end
    end

    if( type( FT.FRight ) == "string"  ) then
        if( string.match( FT.FRight, "%%" ) == "%" ) then
            FT.FRight = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FRight, "%", "" ) )
        elseif( string.match( FT.FRight, "vw" ) == "vw" ) then
            FT.FRight = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FRight, "vw", "" ) )
        elseif( string.match( FT.FRight, "vh" ) == "vh" ) then
            FT.FRight = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FRight, "vh", "" ) )
        end
    end

    if( type( FT.FBottom ) == "string"  ) then
        if( string.match( FT.FBottom, "%%" ) == "%" ) then
            FT.FBottom = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FBottom, "%", "" ) )
        elseif( string.match( FT.FBottom, "vw" ) == "vw" ) then
            FT.FBottom = FT.FParent:GetWide() / 100 * tonumber( string.Replace( FT.FBottom, "vw", "" ) )
        elseif( string.match( FT.FBottom, "vh" ) == "vh" ) then
            FT.FBottom = FT.FParent:GetTall() / 100 * tonumber( string.Replace( FT.FBottom, "vh", "" ) )
        end
    end

    -- 76561223073791539

    if( FT.FMarginLeft ~= nil ) then
        FT.FMargin[1] = FT.FMarginLeft
    end

    if( FT.FMarginTop ~= nil ) then
        FT.FMargin[2] = FT.FMarginTop
    end

    if( FT.FMarginRight ~= nil ) then
        FT.FMargin[3] = FT.FMarginRight
    end

    if( FT.FMarginBottom ~= nil ) then
        FT.FMargin[4] = FT.FMarginBottom
    end

    if( FT.FMargin ~= nil ) then
        if( FT.FMargin[4] ~= nil ) then
            FT.FMargin[1] = FT.FMargin[1]
            FT.FMargin[2] = FT.FMargin[2]
            FT.FMargin[3] = FT.FMargin[3]
            FT.FMargin[4] = FT.FMargin[4]
        elseif( FT.FMargin[3] ~= nil ) then
            FT.FMargin[1] = FT.FMargin[1]
            FT.FMargin[2] = FT.FMargin[2]
            FT.FMargin[3] = FT.FMargin[3]
            FT.FMargin[4] = 0
        elseif( FT.FMargin[2] ~= nil ) then
            FT.FMargin[1] = FT.FMargin[1]
            FT.FMargin[2] = FT.FMargin[2]
            FT.FMargin[3] = FT.FMargin[1]
            FT.FMargin[4] = FT.FMargin[2]
        elseif( FT.FMargin[1] ~= nil ) then
            FT.FMargin[1] = FT.FMargin[1]
            FT.FMargin[2] = FT.FMargin[1]
            FT.FMargin[3] = FT.FMargin[1]
            FT.FMargin[4] = FT.FMargin[1]
        else
            FT.FMargin = { 0, 0, 0, 0 }
        end
    end

    if( FT.FBefore ~= nil ) then
        FT.FBeforeX, FT.FBeforeY = FT.FBefore:GetPos()
        FT.FBeforeMarginLeft = FT.FBefore.FT.FMargin[1]
    elseif( FT.FAfter ~= nil ) then
        FT.FAfterX, FT.FAfterY = FT.FAfter:GetPos()
        FT.FAfterWidth = FT.FAfter:GetWide()
        FT.FAfterMarginRight = FT.FAfter.FT.FMargin[3]
    end

    if( FT.FAbove ~= nil ) then
        FT.FAboveX, FT.FAboveY = FT.FAbove:GetPos()
        FT.FAboveMarginTop = FT.FAbove.FT.FMargin[2]
    elseif( FT.FBelow ~= nil ) then
        FT.FBelowX, FT.FBelowY = FT.FBelow:GetPos()
        FT.FBelowHeight = FT.FBelow:GetTall()
        FT.FBelowMarginBottom = FT.FBelow.FT.FMargin[4]
    end

    FT.FWidth = FT.FWidth - FT.FMargin[1] - FT.FMargin[3]
    FT.FHeight = FT.FHeight - FT.FMargin[2] - FT.FMargin[4]

    if( FT.FFloat == "right" ) then
        FT.FPosX = FT.FParent:GetWide() - FT.FPosX - FT.FMargin[3] - FT.FWidth + FT.FLeft - FT.FRight
        FT.FPosY = FT.FPosY + FT.FMargin[2] + FT.FTop - FT.FBottom
    else
        FT.FPosX = FT.FPosX + FT.FMargin[1] + FT.FLeft - FT.FRight
        FT.FPosY = FT.FPosY + FT.FMargin[2] + FT.FTop - FT.FBottom
    end

    if( FT.FBefore ~= nil ) then
        FT.FPosX = FT.FBeforeX - FT.FWidth - FT.FMargin[3] - FT.FBeforeMarginLeft + FT.FLeft - FT.FRight
    elseif( FT.FAfter ~= nil ) then
        FT.FPosX = FT.FAfterX + FT.FAfterWidth + FT.FAfterMarginRight + FT.FMargin[1] + FT.FLeft - FT.FRight
    end
    
    if( FT.FAbove ~= nil ) then
        FT.FPosY = FT.FAboveY - FT.FHeight - FT.FMargin[4] - FT.FAboveMarginTop + FT.FTop - FT.FBottom
    elseif ( FT.FBelow ~= nil ) then
        FT.FPosY = FT.FBelowY + FT.FBelowHeight + FT.FBelowMarginBottom + FT.FMargin[2] + FT.FTop - FT.FBottom
    end

    if( FT.FCenter == true ) then
        FT.FPosX = ( ScrW() / 2 ) - ( FT.FWidth / 2 )
        FT.FPosY = ( ScrH() / 2 ) - ( FT.FHeight / 2)
    end

    /* */

    FT.FBorder = style["border"] or nil
    FT.FBorderColor = style["border-color"] or Color( 0, 0, 0 )
    FT.FBackground = style["background-color"] or Color( 0, 0, 0, 150 )
    FT.FVisibility = style["visibility"] or nil
    FT.FBlur = style["blur"] or nil

    FT.FBorderLeft = style["border-left"] or nil
    FT.FBorderTop = style["border-top"] or nil
    FT.FBorderRight = style["border-right"] or nil
    FT.FBorderBottom = style["border-bottom"] or nil

    if( FT.FBorder ~= nil ) then
        if( FT.FBorder[4] ~= nil ) then
            FT.FBorder[1] = FT.FBorder[1]
            FT.FBorder[2] = FT.FBorder[2]
            FT.FBorder[3] = FT.FBorder[3]
            FT.FBorder[4] = FT.FBorder[4]
        elseif( FT.FBorder[3] ~= nil ) then
            FT.FBorder[1] = FT.FBorder[1]
            FT.FBorder[2] = FT.FBorder[2]
            FT.FBorder[3] = FT.FBorder[3]
            FT.FBorder[4] = 0
        elseif( FT.FBorder[2] ~= nil ) then
            FT.FBorder[1] = FT.FBorder[1]
            FT.FBorder[2] = FT.FBorder[2]
            FT.FBorder[3] = FT.FBorder[1]
            FT.FBorder[4] = FT.FBorder[2]
        elseif( FT.FBorder[1] ~= nil ) then
            FT.FBorder[1] = FT.FBorder[1]
            FT.FBorder[2] = FT.FBorder[1]
            FT.FBorder[3] = FT.FBorder[1]
            FT.FBorder[4] = FT.FBorder[1]
        else
            FT.FBorder = { 0, 0, 0, 0 }
        end
    else
        FT.FBorder = { 0, 0, 0, 0 }
    end

    if( FT.FBorderLeft ~= nil ) then
        FT.FBorder[1] = FT.FBorderLeft
    end

    if( FT.FBorderTop ~= nil ) then
        FT.FBorder[2] = FT.FBorderTop
    end

    if( FT.FBorderRight ~= nil ) then
        FT.FBorder[3] = FT.FBorderRight
    end

    if( FT.FBorderBottom ~= nil ) then
        FT.FBorder[4] = FT.FBorderBottom
    end

    return FT
end

function FERMA.CORE.PaintFermafy( w, h, panel )
    if( panel.FVisibility ~= "hidden" ) then
        FERMA.CORE.DrawBox 
        {
            ["x"] = 0,
            ["y"] = 0,
            ["width"] = w,
            ["height"] = h,
            ["color"] = panel.FBackground
        }

        if( panel.FBlur ~= nil ) then
            FERMA.CORE.DrawBlurBox
            { 
                ["x"] = panel.FPosX,
                ["y"] = panel.FPosY,
                ["strength"] = panel.FBlur
            }
        end

        if( panel.FBorder[1] ~= nil && panel.FBorder[1] ~= 0 ) then
            FERMA.CORE.DrawVerticalLine 
            {
                ["x"] = 0,
                ["y"] = 0,
                ["length"]  = h,
                ["thickness"] = panel.FBorder[1],
                ["color"] = panel.FBorderColor
            }
        end

        if( panel.FBorder[2] ~= nil && panel.FBorder[2] ~= 0 ) then
            FERMA.CORE.DrawHorizontalLine 
            {
                ["x"] = 0,
                ["y"] = 0,
                ["length"] = w,
                ["thickness"] = panel.FBorder[2],
                ["color"] = panel.FBorderColor
            }
        end

        if( panel.FBorder[3] ~= nil && panel.FBorder[3] ~= 0 ) then
            FERMA.CORE.DrawVerticalLine 
            {
                ["x"] = w - panel.FBorder[3],
                ["y"] = 0,
                ["length"]  = h,
                ["thickness"] = panel.FBorder[3],
                ["color"] = panel.FBorderColor
            }
        end

        if( panel.FBorder[4] ~= nil && panel.FBorder[4] ~= 0 ) then
            FERMA.CORE.DrawHorizontalLine 
            {
                ["x"] = 0,
                ["y"] = h - panel.FBorder[4],
                ["length"] = w,
                ["thickness"] = panel.FBorder[4],
                ["color"] = panel.FBorderColor
            }
        end
    end
end

function FERMA.CORE.FermaDefaults( panel )
    panel:SetSize( panel.FT.FWidth, panel.FT.FHeight )
    panel:SetPos( panel.FT.FPosX, panel.FT.FPosY )

    if( panel.FT.FZIndex ~= nil ) then
        panel:SetZPos( panel.FT.FZIndex )
    end

    if( panel.FT.FAlpha ~= nil ) then
        panel:SetAlpha( panel.FT.FAlpha )
    end
    
    if( panel.FT.FPopup == true ) then
        panel:MakePopup()
    end
end

function FERMA.CORE.DrawBlurBox( style )
  surface.SetDrawColor( 255, 255, 255 )
  surface.SetMaterial( blur )

  for i = 1, 3 do
    blur:SetFloat( "$blur", ( i / 3 ) * ( style["strength"] or 6 ) )
    blur:Recompute()
    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect( style["x"] * -1, style["y"] * -1, ScrW(), ScrH() )
  end
end

function FERMA.CORE.DrawVerticalLine( style )
  surface.SetDrawColor( style["color"] )
  surface.DrawRect( style["x"], style["y"], style["thickness"], style["length"] )
end

function FERMA.CORE.DrawHorizontalLine( style )
  surface.SetDrawColor( style["color"] )
  surface.DrawRect( style["x"], style["y"], style["length"], style["thickness"] )
end

function FERMA.CORE.DrawLine( style )
  surface.SetDrawColor( style["color"] )
  surface.DrawLine( style["x"], style["y"], style["end-x"], style["end-y"] )
end

function FERMA.CORE.DrawBox( style )
  surface.SetDrawColor( style["color"] )
  surface.DrawRect( style["x"], style["y"], style["width"], style["height"] )
end

function FERMA.CORE.CreateFont( path, name, setfont, setweight, fonttable )
    local i = 1
    while i <= 40 do
        surface.CreateFont( name .. i, { 
            font = setfont,
            size = ScreenScale(i),
            weight = setweight,
            blursize = fonttable.blur or nil,
            scanlines = fonttable.scanlines or nil,
            antialias = fonttable.antialias or true,
            underline = fonttable.underline or nil,
            italic = fonttable.italic or nil,
            strikeout = fonttable.strikeout or nil,
            symbol = fonttable.symbol or nil,
            rotary = fonttable.rotary or nil,
            shadow = fonttable.shadow or nil,
            additive = fonttable.additive or nil,
            outline = fonttable.outline or nil,
            extended = fonttable.extended or nil
        } )
        surface.CreateFont( name .. "Unscaled" .. i, { 
            font = setfont,
            size = i,
            weight = setweight,
            blursize = fonttable.blur or nil,
            scanlines = fonttable.scanlines or nil,
            antialias = fonttable.antialias or true,
            underline = fonttable.underline or nil,
            italic = fonttable.italic or nil,
            strikeout = fonttable.strikeout or nil,
            symbol = fonttable.symbol or nil,
            rotary = fonttable.rotary or nil,
            shadow = fonttable.shadow or nil,
            additive = fonttable.additive or nil,
            outline = fonttable.outline or nil,
            extended = fonttable.extended or nil
        } )
        i = i + 1
    end
end 