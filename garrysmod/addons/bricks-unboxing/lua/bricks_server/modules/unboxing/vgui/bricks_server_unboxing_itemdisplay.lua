local PANEL = {}

function PANEL:Init()
    self.iconSizeAdjust = 1
end

local loadingIcon = Material( "materials/bricks_server/loading.png" )
function PANEL:SetItemData( type, itemTable, iconAdjust )
    self:Clear()
    
    if( itemTable.Icon ) then
        local iconMat
        BRICKS_SERVER.Func.GetImage( itemTable.Icon, function( mat ) iconMat = mat end )
        
        self.itemModel = vgui.Create( "DPanel", self )
        self.itemModel:Dock( FILL )
        self.itemModel.Paint = function( self2, w, h )
            if( iconMat ) then
                surface.SetDrawColor( itemTable.Color or BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( iconMat )
                local iconSize = h*self.iconSizeAdjust
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            else
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( loadingIcon )
                local size = math.min( 32, h )
                surface.DrawTexturedRectRotated( w/2, h/2, size, size, -(CurTime() % 360 * 250) )
            
                if( h > 32 ) then
                    draw.SimpleText( BRICKS_SERVER.Func.L( "loading" ), "BRICKS_SERVER_Font20", w/2, h/2+(size/2)+5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                end
            end
        end
    else
        local itemModel = itemTable.Model
        if( type == "CASE" ) then
            itemModel = (BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels[itemTable.Model] or {}).Model
        elseif( type == "KEY" ) then
            itemModel = (BRICKS_SERVER.DEVCONFIG.UnboxingKeyModels[itemTable.Model] or BRICKS_SERVER.DEVCONFIG.UnboxingKeyModels[1]).Model
        end

        self.itemModel = vgui.Create( "DModelPanel", self )
        self.itemModel:Dock( FILL )
        self.itemModel:SetModel( itemModel or "error.mdl" )
        self.itemModel:SetCursor( "none" )
        function self.itemModel:LayoutEntity( Entity ) return end
        function self.itemModel:PreDrawModel( Entity )
            render.ClearDepth()
        end
    
        local itemModelEnt = self.itemModel.Entity
        if( itemModelEnt and IsValid( itemModelEnt ) ) then
            local mn, mx = itemModelEnt:GetRenderBounds()
            local size = 0
            size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
            size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
            size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
    
            self.itemModel:SetFOV( (itemModelTable or {}).FOV or 50 )
            self.itemModel:SetCamPos( Vector( size, size, size ) )
            self.itemModel:SetLookAt( (mn + mx) * 0.5 )

            if( type == "ITEM" ) then
                local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[itemTable.Type or ""]
                if( devConfigTable and devConfigTable.ModelDisplay ) then devConfigTable.ModelDisplay( self.itemModel, itemTable.ReqInfo ) end
            elseif( type == "CASE" ) then
                if( itemTable.ModelIcon ) then
                    BRICKS_SERVER.Func.GetImage( itemTable.ModelIcon, function( mat )
                        itemModelEnt:SetBodygroup( 2, 1 )
                        self.itemModel.Entity.CaseLogo = mat
                    end )
                end

                if( itemTable.Color and istable( itemTable.Color ) ) then
                    self.itemModel.Entity:SetNWVector( "CaseColor", Color( itemTable.Color.r, itemTable.Color.g, itemTable.Color.b ):ToVector() )
                end
            elseif( type == "KEY" and itemTable.Color ) then
                self.itemModel:SetColor( itemTable.Color )
            end
        end
    end
end

function PANEL:SetIconSizeAdjust( iconSizeAdjust )
    self.iconSizeAdjust = 0.75
end

function PANEL:Paint()
    
end

vgui.Register( "bricks_server_unboxing_itemdisplay", PANEL, "DPanel" )