FERMA = FERMA or {}
FPointMapper = {}

function FPointMapper:Style( style )

    /* Defaults */
    self.FT = FERMA.CORE.Fermafy( style, self:GetParent() )
    FERMA.CORE.FermaDefaults( self )
    /* */

    /* Panel Specific Styling */
    self.FT.FKnob = style["knob"]

    self:SetLockX( nil )
    self:SetLockY( nil )

    self.Knob:NoClipping( false )
    self.m_fSlideX = self.FT.FKnob[1]
    self.m_fSlideY = self.FT.FKnob[2]
    /* */
end

function FPointMapper:Paint( w, h )

    /* Defaults */
    FERMA.CORE.PaintFermafy( w, h, self.FT )
    /* */

    /* Panel Specific Painting */
    FERMA.CORE.DrawHorizontalLine
    {
        ["color"] = Color( 0, 0, 0, 150 ),
        ["x"] = 0,
        ["y"] = h / 2 - 1,
        ["length"] = w,
        ["thickness"] = 2
    }

    FERMA.CORE.DrawVerticalLine
    {
        ["color"] = Color( 0, 0, 0, 150 ),
        ["x"] = w / 2 - 1,
        ["y"] = 0,
        ["length"] = h,
        ["thickness"] = 2
    }
    /* */
    
end

function FPointMapper:ConvertX( ValPosX, NewMinX, NewMaxX, OldMinX, OldMaxX )
    if( ValPosX == "knob" ) then
        local KnobX, KnobY = self.Knob:GetPos()
        X = ( KnobX + ( self.Knob:GetWide() / 2 ) ) * ( NewMaxX - NewMinX ) / ( OldMaxX - OldMinX ) + NewMinX
    else
        X = ( ValPosX - OldMinX ) * ( NewMaxX - NewMinX ) / ( OldMaxX - OldMinX ) + NewMinX
    end    

    return X
end

function FPointMapper:ConvertY(ValPosY, NewMinY, NewMaxY, OldMinY, OldMaxY )
    if( ValPosY == "knob" ) then
        local KnobX, KnobY = self.Knob:GetPos()
        Y = ( KnobY + ( self.Knob:GetTall() / 2 ) ) * ( NewMaxY - NewMinY ) / ( OldMaxY - OldMinY ) + NewMinY
    else
        Y = ( ValPosY - OldMinY ) * ( NewMaxY - NewMinY ) / ( OldMaxY - OldMinY ) + NewMinY
    end    

    return Y
end

derma.DefineControl( "FPointMapper", "X and Y user editable mapper.", FPointMapper, "DSlider" )