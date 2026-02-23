local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( gangTable )
    local topPanel = vgui.Create( "DPanel", self )
    topPanel:Dock( TOP )
    topPanel:DockMargin( 10, 10, 10, 0 )
    topPanel:SetTall( 80 )
    topPanel.Paint = function( self2, w, h ) 
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        draw.SimpleText( BRICKS_SERVER.Func.L( "gangStorageUpper" ), "BRICKS_SERVER_Font17", 15, 5, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )
    end

    if( LocalPlayer():GangHasPermission( "DepositItem" ) ) then
        local storageDeposit = vgui.Create( "DButton", topPanel )
        storageDeposit:Dock( RIGHT )
        storageDeposit:DockMargin( 0, 10, 10, 10 )
        storageDeposit:SetWide( topPanel:GetTall()-20 )
        storageDeposit:SetText( "" )
        local Alpha = 0
        local depositMat = Material( "bricks_server/deposit.png" )
        storageDeposit.Paint = function( self2, w, h )
            if( self2:IsDown() ) then
                Alpha = 0
            elseif( self2:IsHovered() ) then
                Alpha = math.Clamp( Alpha+5, 0, 75 )
            else
                Alpha = math.Clamp( Alpha-5, 0, 75 )
            end
        
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( Alpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            surface.SetAlphaMultiplier( 1 )
        
            surface.SetDrawColor( 255, 255, 255, 20+(235*(Alpha/75)) )
            surface.SetMaterial( depositMat )
            local iconSize = 32
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        storageDeposit.DoClick = function()
            if( not IsValid( BRICKS_SERVER_GANGDEPOSIT ) ) then
                BRICKS_SERVER_GANGDEPOSIT = vgui.Create( "bricks_server_gang_deposit" )
            end
        end
    end

    local storageProgress = vgui.Create( "DPanel", topPanel )
    storageProgress:Dock( BOTTOM )
    if( LocalPlayer():GangHasPermission( "DepositItem" ) ) then
        storageProgress:DockMargin( 10, 10, 5, 10 )
    else
        storageProgress:DockMargin( 10, 10, 10, 10 )
    end
    storageProgress:SetTall( 40 )
    storageProgress.Paint = function( self2, w, h ) 
        local storageCount, maxStorage = table.Count( gangTable.Storage or {} ), BRICKS_SERVER.Func.GangGetUpgradeInfo( LocalPlayer():GetGangID(), "StorageSlots" )[1]

        local decimal = math.Clamp( storageCount/maxStorage, 0, 1 )

        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.RoundedBox( 5, 0, 0, w*decimal, h, BRICKS_SERVER.Func.GetTheme( 5 ) )

        draw.SimpleText( BRICKS_SERVER.Func.L( "gangStorageProgress", storageCount, maxStorage ), "BRICKS_SERVER_Font20", 15, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        
        draw.SimpleText( math.Round( decimal*100, 2 ) .. "%", "BRICKS_SERVER_Font20", w-15, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end

    local storageScroll = vgui.Create( "bricks_server_scrollpanel", self )
    storageScroll:Dock( FILL )
    storageScroll:DockMargin( 10, 10, 10, 10 )
    storageScroll.Paint = function( self, w, h ) end 

    local spacing = 5
    local storageGrid = vgui.Create( "DIconLayout", storageScroll )
    storageGrid:Dock( TOP )
    storageGrid:SetSpaceY( spacing )
    storageGrid:SetSpaceX( spacing )

    local gridWide = self.panelWide-20
    local slotSize = 125
    local slotsWide = math.floor( gridWide/slotSize )
    local actualSlotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    function self.RefreshPanel()
        storageGrid:Clear()

        local maxStorage = BRICKS_SERVER.Func.GangGetUpgradeInfo( LocalPlayer():GetGangID(), "StorageSlots" )[1]
        local slotsTall = math.ceil( maxStorage/slotsWide )
        storageGrid:SetTall( (slotsTall*actualSlotSize)+((slotsTall-1)*spacing) )

        for i = 1, maxStorage do
            local slotBack = storageGrid:Add( "DPanel" )
            slotBack:SetSize( actualSlotSize, actualSlotSize )
            slotBack.Paint = function( self2, w, h )
                surface.SetAlphaMultiplier( 75/255 )
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                surface.SetAlphaMultiplier( 1 )
            end

            if( gangTable.Storage and gangTable.Storage[i] ) then
                local v = gangTable.Storage[i]

                local x, y, w, h = 0, 0, actualSlotSize, actualSlotSize
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
                        self2.itemModel:SetBRSToolTip( x, y, w, h, tooltipInfo )
                    end

                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                    
                    if( self2.itemModel:IsDown() ) then
                        changeAlpha = 0
                    elseif( self2.itemModel:IsHovered() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 50 )
                    else
                        changeAlpha = math.Clamp( changeAlpha-10, 0, 50 )
                    end

                    surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
                    surface.SetAlphaMultiplier( 1 )

                    if( (v[1] or 1) > 1 ) then
                        draw.SimpleText( "x" .. (v[1] or 1), "BRICKS_SERVER_Font20B", w-12, h-7, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
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

                slotBack.itemModel = vgui.Create( "DModelPanel" , slotBack )
                slotBack.itemModel:Dock( FILL )
                slotBack.itemModel:SetModel( ((v or {})[2] or {})[2] or "models/error.mdl" )
                slotBack.itemModel:SetFOV( 50 )
                function slotBack.itemModel:LayoutEntity( Entity ) return end

                if( BRICKS_SERVER.Func.GetInvTypeCFG( ((v or {})[2] or {})[1] or "" ).ModelDisplay ) then
                    BRICKS_SERVER.Func.GetInvTypeCFG( ((v or {})[2] or {})[1] or "" ).ModelDisplay( slotBack.itemModel, v[2] )
                else
                    BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs.ModelDisplay( slotBack.itemModel, v[2] )
                end

                if( LocalPlayer():GangHasPermission( "WithdrawItem" ) ) then
                    local actions = {
                        [BRICKS_SERVER.Func.L( "drop" )] = function() 
                            net.Start( "BRS.Net.GangStorageDrop" )
                            net.WriteUInt( 1, 8 )
                                net.WriteUInt( i, 10 )
                            net.SendToServer()
                        end
                    }
            
                    if( BRICKS_SERVER.Func.GetInvTypeCFG( v[2][1] or "" ).OnUse ) then
                        actions[BRICKS_SERVER.Func.L( "use" )] = function() 
                            net.Start( "BRS.Net.GangStorageUse" )
                                net.WriteUInt( i, 10 )
                            net.SendToServer()
                        end
                    end
            
                    if( BRICKS_SERVER.Func.GetInvTypeCFG( v[2][1] or "" ).CanDropMultiple and (v[1] or 1) > 1 ) then
                        actions[BRICKS_SERVER.Func.L( "dropAll" )] = function() 
                            net.Start( "BRS.Net.GangStorageDrop" )
                                net.WriteUInt( (v[1] or 1), 8 )
                                net.WriteUInt( i, 10 )
                            net.SendToServer()
                        end
                    end
            
                    slotBack.itemModel.DoClick = function()
                        slotBack.itemModel.Menu = vgui.Create( "bricks_server_popupdmenu" )
                        for k, v in pairs( actions ) do
                            slotBack.itemModel.Menu:AddOption( k, v )
                        end
                        slotBack.itemModel.Menu:Open( slotBack.itemModel, x+w-5, y+(h/2)-(slotBack.itemModel.Menu:GetTall()/2) )
                    end
                end
            end
        end
    end
    self.RefreshPanel()

    hook.Add( "BRS.Hooks.RefreshGang", self, function( self, valuesChanged )
        if( IsValid( self ) ) then
            if( valuesChanged and (valuesChanged["Storage"] or valuesChanged["Upgrades"]) ) then
                self.RefreshPanel()
            end
        else
            hook.Remove( "BRS.Hooks.RefreshGang", self )
        end
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_storage", PANEL, "DPanel" )