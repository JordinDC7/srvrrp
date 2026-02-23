FERMA = FERMA or {}
FTitleBar = {}

function FTitleBar:Style( style )

    /* Defaults */
    self.FT = FERMA.CORE.Fermafy( style, self:GetParent() )
    FERMA.CORE.FermaDefaults( self )
    /* */

    /* Panel Specific Styling */
    self.FT.FTitle = style["content"] or ""
    self.FT.FColor = style["color"] or Color( 255, 255, 255 )
    self.FT.FFont = style["font-family"] or "Default"

    self.Label = vgui.Create( "FLabel", self )
    self.Label:Style
    {
        ["width"] = "100%",
        ["height"] = "100%",
        ["content"] = "   " .. self.FT.FTitle,
        ["color"] = self.FT.FColor,
        ["font-family"] = self.FT.FFont,
        ["text-align"] = 4,
        ["visibility"] = "hidden"
    }

    self.Button = vgui.Create( "FButton", self )
    self.Button:Style
    {
        ["float"] = "right",
        ["width"] = "90vh",
        ["height"] = "100%",
        ["font-family"] = "Default",
        ["content"] = "X",
        ["visibility"] = "hidden"
    }

    function self.Button.DoClick()
        self:GetParent():Remove()
    end
    /* */

end

function FTitleBar:Paint( w, h )

    /* Defaults */
    FERMA.CORE.PaintFermafy( w, h, self.FT )
    -- 76561223073791539
    /* */

end

derma.DefineControl( "FTitleBar", "A title bar for closable windows.", FTitleBar, "DPanel" )