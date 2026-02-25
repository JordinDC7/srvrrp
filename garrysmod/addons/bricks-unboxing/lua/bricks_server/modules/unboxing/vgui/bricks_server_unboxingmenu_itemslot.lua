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
                local topX, topY = surface.GetTextSize( finalText )

                local boxW, boxH = topX+15, topY+5

                if( w != boxW ) then
                    self2:SetWide( boxW )
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

    self.panelInfo = vgui.Create( "DPanel", self )
    self.panelInfo:Dock( FILL )

    if( configItemTable ) then
        local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( configItemTable.Rarity )

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
        local rarityX, rarityY = surface.GetTextSize( configItemTable.Rarity or "" )
    
        local infoH = (nameY+rarityY)-4-4

        self.panelInfo.Paint = function( self2, w, h )
            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x != toScreenX or y != toScreenY ) then
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

            local textY = h-10-25

            draw.SimpleText( configItemTable.Name or "NIL", nameFont, w/2, textY+2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            
            draw.SimpleText( (configItemTable.Rarity or ""), rarityFont, w/2, textY-2, BRICKS_SERVER.Func.GetRarityColor( rarityInfo ), TEXT_ALIGN_CENTER, 0 )
        end
        
        local rarityBox = vgui.Create( "bricks_server_raritybox", self.panelInfo )
        rarityBox:SetSize( self:GetWide(), 10 )
        rarityBox:SetPos( 0, self:GetTall()-rarityBox:GetTall() )
        rarityBox:SetRarityName( configItemTable.Rarity or "" )
        rarityBox:SetCornerRadius( 8 )
        rarityBox:SetRoundedBoxDimensions( false, -10, false, 20 )

        self.itemDisplay = vgui.Create( "bricks_server_unboxing_itemdisplay", self.panelInfo )
        self.itemDisplay:SetPos( 0, 0 )
        self.itemDisplay:SetSize( self:GetWide(), self:GetTall()-(infoH+(25-(rarityY-2))+10) )
        self.itemDisplay:SetItemData( (isItem and "ITEM") or (isCase and "CASE") or (isKey and "KEY") or "", configItemTable )
        self.itemDisplay:SetIconSizeAdjust( 0.75 )

        self.topBar = vgui.Create( "DPanel", self.panelInfo )
        self.topBar:SetPos( 5, 5 )
        self.topBar:SetWide( self:GetWide()-10 )
        self.topBar.Paint = function( self2, w, h ) end

        if( amount > 1 ) then
            self:AddTopInfo( string.Comma( amount ) .. "X" )
        end

        if( isItem ) then
            local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type]

            if( devConfigTable and devConfigTable.TagName ) then
                self:AddTopInfo( devConfigTable.TagName, devConfigTable.TagColor, devConfigTable.TagTextColor, true )
            end
        end
    else
        self.panelInfo.Paint = function( self2, w, h )
            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x != toScreenX or y != toScreenY ) then
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