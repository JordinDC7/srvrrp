local PANEL = {}

local IMAGE_LOAD_TIMEOUT = 6

function PANEL:Init()
    self.iconSizeAdjust = 1
end

local loadingIcon = Material( "bricks_server/loading.png", "smooth" )
local fallbackIcon = Material( "icon16/picture.png", "smooth" )

if( loadingIcon and loadingIcon.IsError and loadingIcon:IsError() ) then
    loadingIcon = Material( "icon16/arrow_refresh.png", "smooth" )
end

local function BRS_UNBOXING_GetWeaponModelFromClass( weaponClass )
    if( not isstring( weaponClass ) or weaponClass == "" ) then return nil end

    local weaponData = weapons.GetStored( weaponClass )
    if( not istable( weaponData ) ) then return nil end

    local possibleModels = {
        weaponData.WorldModel,
        weaponData.ViewModel,
        weaponData.WM,
        weaponData.VM,
        weaponData.Model
    }

    for _, mdl in ipairs( possibleModels ) do
        if( isstring( mdl ) and mdl ~= "" and util.IsValidModel( mdl ) ) then
            return mdl
        end
    end

    return nil
end

local function BRS_UNBOXING_DrawFallbackIcon( w, h, text )
    draw.RoundedBox( 6, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2, 215 ) )
    surface.SetDrawColor( 255, 255, 255, 220 )
    surface.SetMaterial( fallbackIcon )

    local iconSize = math.min( math.max( h * 0.35, 16 ), 48 )
    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2)-8, iconSize, iconSize )

    if( h > 40 ) then
        draw.SimpleText( text, "BRICKS_SERVER_Font18", w/2, (h/2)+(iconSize/2), BRICKS_SERVER.Func.GetTheme( 6, 180 ), TEXT_ALIGN_CENTER, 0 )
    end
end

local function BRS_UNBOXING_TryGetMaterial( iconPath )
    if( not isstring( iconPath ) ) then return nil end

    local cleanPath = string.Trim( iconPath )
    if( cleanPath == "" ) then return nil end

    local candidates = {
        cleanPath,
        string.gsub( cleanPath, "^materials/", "" ),
        string.StripExtension( cleanPath ),
        string.StripExtension( string.gsub( cleanPath, "^materials/", "" ) )
    }

    for _, candidate in ipairs( candidates ) do
        if( isstring( candidate ) and candidate ~= "" ) then
            local mat = Material( candidate, "smooth" )
            if( mat and (not mat.IsError or not mat:IsError()) ) then
                return mat
            end
        end
    end

    return nil
end

local function BRS_UNBOXING_LoadIconMaterial( iconPath, callback )
    local localMat = BRS_UNBOXING_TryGetMaterial( iconPath )
    if( localMat ) then
        callback( localMat )
        return
    end

    if( not isfunction( BRICKS_SERVER.Func.GetImage ) ) then
        callback( nil )
        return
    end

    BRICKS_SERVER.Func.GetImage( iconPath, function( mat )
        if( ismaterial( mat ) and (not mat.IsError or not mat:IsError()) ) then
            callback( mat )
            return
        end

        callback( nil )
    end )
end

local function BRS_UNBOXING_ResolveItemModel( itemType, itemTable )
    local itemModel = itemTable.Model

    if( itemType == "CASE" ) then
        itemModel = (BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels[itemTable.Model] or {}).Model
    elseif( itemType == "KEY" ) then
        itemModel = (BRICKS_SERVER.DEVCONFIG.UnboxingKeyModels[itemTable.Model] or BRICKS_SERVER.DEVCONFIG.UnboxingKeyModels[1]).Model
    end

    if( (not isstring( itemModel ) or itemModel == "" or not util.IsValidModel( itemModel )) and itemType == "ITEM" ) then
        itemModel = BRS_UNBOXING_GetWeaponModelFromClass( (itemTable.ReqInfo or {})[1] ) or itemModel
    end

    if( isstring( itemModel ) and itemModel ~= "" and util.IsValidModel( itemModel ) ) then
        return itemModel
    end

    -- Some workshop/content-pack models don't report as valid at UI build time even though
    -- they still render correctly in a DModelPanel once requested by path.
    if( isstring( itemModel ) and itemModel ~= "" and string.EndsWith( string.lower( itemModel ), ".mdl" ) ) then
        return itemModel
    end

    return nil
end

function PANEL:SetItemData( type, itemTable, iconAdjust )
    self:Clear()

    local resolvedModel = BRS_UNBOXING_ResolveItemModel( type, itemTable )
    local iconPath = isstring( itemTable.Icon ) and string.Trim( itemTable.Icon ) or ""
    local shouldUseIcon = iconPath ~= "" and (type != "ITEM" or not resolvedModel)
    
    if( shouldUseIcon ) then
        local iconMat
        local iconRequestedAt = CurTime()
        local iconLoadFailed = false

        BRS_UNBOXING_LoadIconMaterial( iconPath, function( mat )
            if( not IsValid( self ) ) then return end

            if( ismaterial( mat ) ) then
                iconMat = mat
            else
                iconLoadFailed = true
            end
        end )
        
        self.itemModel = vgui.Create( "DPanel", self )
        self.itemModel:Dock( FILL )
        self.itemModel.Paint = function( self2, w, h )
            if( iconMat ) then
                surface.SetDrawColor( itemTable.Color or BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( iconMat )
                local iconSize = h*self.iconSizeAdjust
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            elseif( iconLoadFailed or (CurTime()-iconRequestedAt) > IMAGE_LOAD_TIMEOUT ) then
                BRS_UNBOXING_DrawFallbackIcon( w, h, "NO IMAGE" )
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
        if( not resolvedModel ) then
            self.itemModel = vgui.Create( "DPanel", self )
            self.itemModel:Dock( FILL )
            self.itemModel.Paint = function( self2, w, h )
                BRS_UNBOXING_DrawFallbackIcon( w, h, BRICKS_SERVER.Func.L( "unknown" ) )
            end

            return
        end

        self.itemModel = vgui.Create( "DModelPanel", self )
        self.itemModel:Dock( FILL )
        self.itemModel:SetModel( resolvedModel or "error.mdl" )
        self.itemModel:SetCursor( "none" )
        self.itemModel:SetPaintBackground( false )
        function self.itemModel:LayoutEntity( Entity ) return end
        function self.itemModel:PreDrawModel( Entity )
            render.ClearDepth()
        end
        function self.itemModel:Paint( w, h )
            draw.RoundedBox( 0, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2, 215 ) )
            self:DrawModel()
        end
    
        local itemModelEnt = self.itemModel.Entity
        if( itemModelEnt and IsValid( itemModelEnt ) ) then
            local mn, mx = itemModelEnt:GetRenderBounds()
            local size = 0
            size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
            size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
            size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
    
            self.itemModel:SetFOV( tonumber( itemTable.FOV ) or 50 )
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
    self.iconSizeAdjust = tonumber( iconSizeAdjust ) or 1
end

function PANEL:Paint()
    
end

vgui.Register( "bricks_server_unboxing_itemdisplay", PANEL, "DPanel" )
