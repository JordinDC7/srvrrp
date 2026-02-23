FERMA = FERMA or {}
FCheckBox = {}

function FCheckBox:Style( style )
    
    /* Defaults */
    self.FT = FERMA.CORE.Fermafy( style, self:GetParent() )
    FERMA.CORE.FermaDefaults( self )
    /* */

    /* Panel Specific Styling */
    self.FT.FCVar = style["cvar"] or nil

    if( self.FT.FCVar ~= nil ) then
        self:SetValue( cvars.Bool( self.FT.FCVar ) )
        self:SetConVar( self.FT.FCVar )
    end
    /* */

end

derma.DefineControl( "FCheckBox", "Better DCheckBox", FCheckBox, "DCheckBox" )