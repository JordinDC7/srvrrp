local PANEL = {}

function PANEL:Init()
    self.margin = 0
end

function PANEL:FillPanel()
    self.panelWide = self.panelWide or self:GetWide(); self.panelTall = self.panelTall or self:GetTall()

    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )
    end 

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local textX, textY = surface.GetTextSize( "Create Case" )
    local totalContentW = 16+5+textX

    local createNewButton = vgui.Create( "DButton", self.topBar )
    createNewButton:Dock( RIGHT )
    createNewButton:DockMargin( 10, 10, 25, 10 )
    createNewButton:SetWide( totalContentW+27 )
    createNewButton:SetText( "" )
    local alpha = 0
    local addMat = Material( "bricks_server/add_16.png" )
    createNewButton.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ) )
        surface.SetMaterial( addMat )
        local iconSize = 16
        surface.DrawTexturedRect( 12, (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( "Create Case", "BRICKS_SERVER_Font20", 12+iconSize+5, h/2, BRICKS_SERVER.Func.GetTheme( 6, 20+(235*(alpha/255)) ), 0, TEXT_ALIGN_CENTER )
    end
    createNewButton.DoClick = function()
        BS_ConfigCopyTable.UNBOXING.Cases[BRICKS_SERVER.Func.ConfigGenerateUnboxingID( "CASE" )] = {
            Name = "New Case",
            Model = 1,
            Rarity = BS_ConfigCopyTable.GENERAL.Rarities[#BS_ConfigCopyTable.GENERAL.Rarities][1],
            Items = {}
        }
        BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
        self:Refresh()

        BRICKS_SERVER.Func.CreateTopNotification( "New case successfully created!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
    end

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( ScrW()*0.2 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
    self.searchBar.OnChange = function()
        self:Refresh()
    end

    self.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.Paint = function( self, w, h ) end 

    local gridWide = self.panelWide-50-10-10
    self.slotsWide = math.floor( gridWide/BRICKS_SERVER.Func.ScreenScale( 200 ) )
    self.spacing = 10
    self.slotWide = (gridWide-((self.slotsWide-1)*self.spacing))/self.slotsWide

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( self.spacing )
    self.grid:SetSpaceX( self.spacing )

    self:Refresh()
end

function PANEL:Refresh()
    self.grid:Clear()

    for k, v in pairs( BS_ConfigCopyTable.UNBOXING.Cases or {} ) do
        if( self.searchBar:GetValue() != "" and not string.find( string.lower( v.Name ), string.lower( self.searchBar:GetValue() ) ) ) then
            continue
        end

        local slotBack = self.grid:Add( "bricks_server_unboxingmenu_itemslot" )
        slotBack:SetSize( self.slotWide, self.slotWide*1.2 )
        slotBack:FillPanel( { "CASE_" .. k, v }, 1, function()
            self.popoutPanel = vgui.Create( "bricks_server_config_unboxing_cases_popup", self )
            self.popoutPanel:SetPos( 0, 0 )
            self.popoutPanel:SetSize( self.panelWide or self:GetWide(), self.panelTall or self:GetTall() )
            self.popoutPanel:SetItemTable( k, v, function( valueChanged, newItemTable )
                if( valueChanged ) then
                    BS_ConfigCopyTable.UNBOXING.Cases[k] = newItemTable
                    BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )
        
                    if( IsValid( self ) ) then
                        self:Refresh() 
                    end
        
                    BRICKS_SERVER.Func.CreateTopNotification( "Case successfully edited!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
                end
            end, function() 
                BRICKS_SERVER.Func.ConfigRemoveUnboxingItem( "CASE", k )
                self:Refresh()
                BRICKS_SERVER.Func.CreateTopNotification( "Case successfully removed!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
            end, function() 
                BS_ConfigCopyTable.UNBOXING.Cases[BRICKS_SERVER.Func.ConfigGenerateUnboxingID( "CASE" )] = v
                BRICKS_SERVER.Func.ConfigChange( "UNBOXING" )

                self:Refresh()
                BRICKS_SERVER.Func.CreateTopNotification( "Case successfully duplicated!", 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
            end )
        end )
    end
end


function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_unboxing_cases", PANEL, "DPanel" )