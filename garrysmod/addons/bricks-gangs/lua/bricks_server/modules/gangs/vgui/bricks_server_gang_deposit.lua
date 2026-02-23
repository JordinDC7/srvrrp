local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:Center()
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( false )
    self:ShowCloseButton( false )

    self.mainPanel = vgui.Create( "bricks_server_dframepanel", self )
    self.mainPanel:SetHeader( BRICKS_SERVER.Func.L( "gangDepositMenu" ) )
    self.mainPanel:SetSize( ScrW()*0.5, ScrH()*0.5 )
    self.mainPanel:Center()
    self.mainPanel.onCloseFunc = function()
		self:Remove()
	end

    local spacing = 5

    function self.RefreshPanel()
        if( IsValid( self.sheet ) ) then
            self.sheet:Remove()
        end

        if( IsValid( self.cover ) ) then
            self.cover:Remove()
        end

        self.sheet = vgui.Create( "bricks_server_colsheet_top", self.mainPanel )
        self.sheet:Dock( FILL )
        self.sheet.pageClickFunc = function( page )
            self.page = page
        end

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) and table.Count( LocalPlayer():BRS():GetInventory() ) > 0 ) then
            local inventoryTable = LocalPlayer():BRS():GetInventory()

            local inventoryScroll = vgui.Create( "bricks_server_scrollpanel", self.sheet )
            inventoryScroll:Dock( FILL )
            inventoryScroll:DockMargin( 10, 10, 10, 10 )
            inventoryScroll.Paint = function( self, w, h ) end 
            self.sheet:AddSheet( BRICKS_SERVER.Func.L( "inventory" ), inventoryScroll, ((self.page or "") == BRICKS_SERVER.Func.L( "inventory" )) )

            local inventoryGrid = vgui.Create( "DIconLayout", inventoryScroll )
            inventoryGrid:Dock( FILL )
            inventoryGrid:SetSpaceY( spacing )
            inventoryGrid:SetSpaceX( spacing )

            self:FillItems( inventoryTable, inventoryGrid, function( key, val )
                local itemInfo = {}
                if( BRICKS_SERVER.Func.GetInvTypeCFG( ((val or {})[2] or {})[1] or "" ).GetInfo ) then
                    itemInfo = BRICKS_SERVER.Func.GetInvTypeCFG( ((val or {})[2] or {})[1] or "" ).GetInfo( val[2] )
                else
                    itemInfo = BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs.GetInfo( val[2] )
                end
    
                BRICKS_SERVER.Func.Query( BRICKS_SERVER.Func.L( "gangDepositInventoryQuery", itemInfo[1] ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function() 
                    net.Start( "BRS.Net.GangDepositInventory" )
                        net.WriteUInt( key, 10 )
                    net.SendToServer()
                end )
            end, function( key, val ) return not inventoryTable[key] end )
        end

        local playerInventory = {}

        for k, v in pairs( LocalPlayer():GetWeapons() ) do
            if( GAMEMODE.Config.DisallowDrop[v:GetClass()] or (v:GetModel() or "") == "" ) then continue end

            table.insert( playerInventory, { 1, { "spawned_weapon", v:GetModel(), v:GetClass() } } )
        end

        if( table.Count( playerInventory ) > 0 ) then
            local playerScroll = vgui.Create( "bricks_server_scrollpanel", self.sheet )
            playerScroll:Dock( FILL )
            playerScroll:DockMargin( 10, 10, 10, 10 )
            playerScroll.Paint = function( self, w, h ) end 
            self.sheet:AddSheet( BRICKS_SERVER.Func.L( "player" ), playerScroll, ((self.page or "") == BRICKS_SERVER.Func.L( "player" )) )

            local playerGrid = vgui.Create( "DIconLayout", playerScroll )
            playerGrid:Dock( FILL )
            playerGrid:SetSpaceY( spacing )
            playerGrid:SetSpaceX( spacing )

            self:FillItems( playerInventory, playerGrid, function( key, val )
                local itemInfo = {}
                if( BRICKS_SERVER.Func.GetInvTypeCFG( ((val or {})[2] or {})[1] or "" ).GetInfo ) then
                    itemInfo = BRICKS_SERVER.Func.GetInvTypeCFG( ((val or {})[2] or {})[1] or "" ).GetInfo( val[2] )
                else
                    itemInfo = BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs.GetInfo( val[2] )
                end

                BRICKS_SERVER.Func.Query( BRICKS_SERVER.Func.L( "gangDepositPlayerQuery", itemInfo[1] ), BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "confirm" ), BRICKS_SERVER.Func.L( "cancel" ), function() 
                    net.Start( "BRS.Net.GangDepositLoadout" )
                        net.WriteString( val[2][3] )
                    net.SendToServer()
                end )
            end, function( key, val ) return not LocalPlayer():HasWeapon( val[2][3] ) end )
        end

        if( #self.sheet.Items <= 0 ) then
            self.sheet:Remove()

            self.cover = vgui.Create( "DPanel", self.mainPanel )
            self.cover:Dock( FILL )
            self.cover.Paint = function( self2, w, h )
                draw.SimpleText( BRICKS_SERVER.Func.L( "gangNoDepositItems" ), "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end
    end
    self.RefreshPanel()
end

local gradient = Material( "vgui/gradient_up" ) 
function PANEL:FillItems( items, grid, depositFunc, refreshFunc )
    local spacing = 5
    local gridWide = self.mainPanel:GetWide()-20
    local wantedSlotSize = 125
    local slotsWide = math.floor( gridWide/wantedSlotSize )
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    for k, v in pairs( items ) do
        local slotBack = grid:Add( "DPanel" )
        slotBack:SetSize( slotSize, slotSize )
        local x, y, w, h = 0, 0, slotSize, slotSize
        local itemModel
        local changeAlpha = 0
        local itemInfo = {}
        if( BRICKS_SERVER.Func.GetInvTypeCFG( ((v or {})[2] or {})[1] or "" ).GetInfo ) then
            itemInfo = BRICKS_SERVER.Func.GetInvTypeCFG( ((v or {})[2] or {})[1] or "" ).GetInfo( v[2] )
        else
            itemInfo = BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs.GetInfo( v[2] )
        end
        
        local tooltipInfo = {}
        tooltipInfo[1] = { itemInfo[1], false, "BRICKS_SERVER_Font23B" }
        local rarityInfo
        if( itemInfo[3] ) then
            rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemInfo[3] )
            tooltipInfo[2] = { itemInfo[3], function() return BRICKS_SERVER.Func.GetRarityColor( rarityInfo ) end, "BRICKS_SERVER_Font17" }
        end
        table.insert( tooltipInfo, itemInfo[2] )
        if( #itemInfo > 3 ) then
            for i = 4, #itemInfo do
                table.insert( tooltipInfo, itemInfo[i] )
            end
        end

        slotBack.Paint = function( self2, w, h )
            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x != toScreenX or y != toScreenY ) then
                x, y = toScreenX, toScreenY
                itemModel:SetBRSToolTip( x, y, w, h, tooltipInfo )
            end

            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            
            if( itemModel:IsDown() ) then
                changeAlpha = 0
            elseif( itemModel:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 50 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 50 )
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
            surface.SetAlphaMultiplier( 1 )

            if( (v[1] or 1) > 1 ) then
                draw.SimpleText( "x" .. (v[1] or 1), "BRICKS_SERVER_Font20B", w-12, h-7, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
            end
        end
        slotBack.Think = function()
            if( refreshFunc ) then
                local refresh = refreshFunc( k, v )

                if( refresh ) then
                    self.RefreshPanel()
                end
            end
        end

        if( rarityInfo ) then
            local rarityBox = vgui.Create( "bricks_server_raritybox", slotBack )
            rarityBox:SetSize( slotBack:GetWide(), 5 )
            rarityBox:SetPos( 0, slotBack:GetTall()-rarityBox:GetTall() )
            rarityBox:SetRarityName( rarityInfo[1] )
            rarityBox:SetCornerRadius( 8 )
            rarityBox:SetRoundedBoxDimensions( false, -15, false, 20 )
        end

        itemModel = vgui.Create( "DModelPanel" , slotBack )
        itemModel:Dock( FILL )
        itemModel:SetModel( ((v or {})[2] or {})[2] or "models/error.mdl" )
        itemModel:SetFOV( 50 )
        function itemModel:LayoutEntity( Entity ) return end

        if( BRICKS_SERVER.Func.GetInvTypeCFG( ((v or {})[2] or {})[1] or "" ).ModelDisplay ) then
            BRICKS_SERVER.Func.GetInvTypeCFG( ((v or {})[2] or {})[1] or "" ).ModelDisplay( itemModel, v[2] )
        else
            BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs.ModelDisplay( itemModel, v[2] )
        end

        itemModel.DoClick = function()
            depositFunc( k, v )
        end
    end
end

function PANEL:Paint( w, h )
    BRICKS_SERVER.Func.DrawBlur( self, 4, 4 )
end

vgui.Register( "bricks_server_gang_deposit", PANEL, "DFrame" )