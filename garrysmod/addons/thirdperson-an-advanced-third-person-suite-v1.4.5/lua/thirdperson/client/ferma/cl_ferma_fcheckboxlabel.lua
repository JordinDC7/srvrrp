FERMA = FERMA or {}
FCheckBoxLabel = {}

function FCheckBoxLabel:Style( style )
    
    /* Defaults */
    self.FT = FERMA.CORE.Fermafy( style, self:GetParent() )
    FERMA.CORE.FermaDefaults( self )
    /* */

    /* Panel Specific Styling */
    self.FT.FFont = style["font-family"] or nil
    self.FT.FContent = style["content"] or nil
    self.FT.FCVar = style["cvar"] or nil

    if( self.FT.FCVar ~= nil ) then
        self:SetValue( cvars.Bool( self.FT.FCVar ) )
        self:SetConVar( self.FT.FCVar )
    end

    if( self.FT.FContent ~= nil ) then
        self.Label:SetText( self.FT.FContent )
    end

    if( self.FT.FFont ~= nil ) then
        self.Label:SetFont( self.FT.FFont )
    end
    /* */

end

function FCheckBoxLabel:PerformLayout()
  local x = self.m_iIndent || 0

  self.Button:SetSize( 15, 15 )
  self.Button:SetPos( x, math.floor( ( self:GetTall() - self.Button:GetTall() ) / 2 ) )

  self.Label:SizeToContents()
  self.Label:SetPos( x + self.Button:GetWide() + 9, 2 )
end

derma.DefineControl( "FCheckBoxLabel", "Better DCheckBoxLabel", FCheckBoxLabel, "DCheckBoxLabel" )
-- 76561223073791539