FERMA = FERMA or {}
FLabel = {}

function FLabel:Style( style )

    /* Defaults */
    self.FT = FERMA.CORE.Fermafy( style, self:GetParent() )
    FERMA.CORE.FermaDefaults( self )
    /* */

    /* Panel Specific Styling */
    self.FT.FContent = style["content"] or ""
    self.FT.FFont = style["font-family"] or "Default"
    self.FT.FTextAlign = style["text-align"] or 5
    self.FT.FColor = style["color"] or Color( 255, 255, 255 )

    self:SetText( self.FT.FContent )
    self:SetFont( self.FT.FFont )
    self:SetColor( self.FT.FColor )
    self:SetContentAlignment( self.FT.FTextAlign )
    /* */

end

function FLabel:Paint( w, h )
    
    /* Defaults */
    FERMA.CORE.PaintFermafy( w, h, self.FT )
    -- 76561223073791539
    /* */

end

derma.DefineControl( "FLabel", "Better DLabel", FLabel, "DLabel" )