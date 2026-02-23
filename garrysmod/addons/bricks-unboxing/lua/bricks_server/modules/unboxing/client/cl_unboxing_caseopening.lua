local weaponsSwitch = { "keys", "weapon_physcannon", "weapon_physgun" }
function BRICKS_SERVER.UNBOXING.Func.StartPlacingCase( caseKey )
    local caseTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[caseKey]

    if( not caseTable ) then return end

    local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingCaseModels[caseTable.Model]

    if( not devConfigTable ) then return end

    local ply = LocalPlayer()

    if( not ply:Alive() ) then 
        BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "unboxingPlyDead" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red ) 
        return
    end

    local canOpen, message = ply:UnboxingCanOpenCase( caseKey )
    if( not canOpen ) then
        BRICKS_SERVER.Func.CreateTopNotification( message, 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
        return
    end

    for k, v in ipairs( weaponsSwitch ) do
        local wepEnt = ply:GetWeapon( v )
        if( IsValid( wepEnt ) ) then
            input.SelectWeapon( wepEnt )
            break
        end
    end

    if( IsValid( BRICKS_SERVER.TEMP.CaseModel ) ) then
        BRICKS_SERVER.TEMP.CaseModel:Remove()
    end

    BRICKS_SERVER.TEMP.CaseModel = ClientsideModel( devConfigTable.Model, RENDERGROUP_TRANSLUCENT )
    BRICKS_SERVER.TEMP.CaseModel:SetColor( Color( 255, 255, 255, 175 ) )
    BRICKS_SERVER.TEMP.CaseModel:SetRenderMode( RENDERMODE_TRANSALPHA )
    BRICKS_SERVER.TEMP.CaseModel:SetPos( ply:GetPos()+ply:GetForward()*20 )

    BRICKS_SERVER.TEMP.CaseKey = caseKey
    BRICKS_SERVER.TEMP.CaseCooldown = 0
    
    if( IsValid( BRICKS_SERVER_UNBOXINGMENU ) ) then
        BRICKS_SERVER_UNBOXINGMENU:SetVisible( false )
    end
end

hook.Add( "Think", "BricksServerHooks_Think_CaseOpening", function()
    if( not IsValid( BRICKS_SERVER.TEMP.CaseModel ) ) then return end
    
    local ply = LocalPlayer()

    if( not ply:Alive() ) then
        BRICKS_SERVER.TEMP.CaseModel:Remove()
        return
    end

    BRICKS_SERVER.TEMP.CaseModel:SetPos( ply:GetEyeTrace().HitPos )

    local canPlace = true
    if( ply:GetPos():DistToSqr( BRICKS_SERVER.TEMP.CaseModel:GetPos() ) > 10000 ) then
        canPlace = false
    end

    if( canPlace ) then
        BRICKS_SERVER.TEMP.CaseModel:SetColor( Color( 255, 255, 255, 175 ) )
    else
        BRICKS_SERVER.TEMP.CaseModel:SetColor( Color( 255, 100, 100, 175 ) )
    end
end )

hook.Add( "KeyPress", "BricksServerHooks_KeyPress_CaseOpening", function( ply, key )
    if( not IsValid( BRICKS_SERVER.TEMP.CaseModel ) ) then return end
    
    if( key == IN_ATTACK ) then
        if( CurTime() < (BRICKS_SERVER.TEMP.CaseCooldown or 0) ) then return end

        BRICKS_SERVER.TEMP.CaseCooldown = CurTime()+0.3

        net.Start( "BRS.Net.PlaceUnboxingCase" )
            net.WriteUInt( BRICKS_SERVER.TEMP.CaseKey, 16 )
        net.SendToServer()
    elseif( key == IN_ATTACK2 ) then
        BRICKS_SERVER.TEMP.CaseModel:Remove()
    end
end )

hook.Add( "HUDPaint", "BricksServerHooks_HUDPaint_CaseOpening", function()
    if( not IsValid( BRICKS_SERVER.TEMP.CaseModel ) or not BRICKS_SERVER.TEMP.CaseKey ) then return end
    
    local caseTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[BRICKS_SERVER.TEMP.CaseKey]

    if( not caseTable ) then return end

    local amount = LocalPlayer():GetUnboxingInventory()["CASE_" .. BRICKS_SERVER.TEMP.CaseKey] or 0

    if( amount < 1 ) then
        BRICKS_SERVER.TEMP.CaseModel:Remove()
        return
    end

    local text = amount .. "X " .. caseTable.Name
    surface.SetFont( "BRICKS_SERVER_Font30" )
    local textX, textY = surface.GetTextSize( text )
    local boxHeaderH, controlH = textY+15, 35
    local boxW, boxH = textX+30, boxHeaderH+(controlH*2)+10
    local boxX, boxY = math.floor( (ScrW()/2)-(boxW/2) ), ScrH()-25-boxH

    BRICKS_SERVER.BSHADOWS.BeginShadow()
    draw.RoundedBox( 8, boxX, boxY, boxW, boxH, BRICKS_SERVER.Func.GetTheme( 3 ) )
    BRICKS_SERVER.BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )

    draw.RoundedBoxEx( 8, boxX, boxY, boxW, boxHeaderH, BRICKS_SERVER.Func.GetTheme( 2 ), true, true, false, false )
    draw.SimpleText( text, "BRICKS_SERVER_Font30", boxX+(boxW/2), boxY+(boxHeaderH/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingPlaceCase" ), "BRICKS_SERVER_Font23", boxX+(boxW/2), boxY+boxHeaderH+5+(controlH/2)+2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingPlaceCaseCancel" ), "BRICKS_SERVER_Font23", boxX+(boxW/2), boxY+boxHeaderH+5+controlH+(controlH/2)-2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end )

BRICKS_SERVER.TEMP.UnboxRewardEnts = BRICKS_SERVER.TEMP.UnboxRewardEnts or {}
hook.Add( "PreDrawHalos", "BricksServerHooks_PreDrawHalos_CaseOpening", function()
    if( BRICKS_SERVER.CONFIG.UNBOXING["Disable Item Halos"] ) then return end

    for k, v in pairs( BRICKS_SERVER.TEMP.UnboxRewardEnts ) do
        local rarityInfo, rarityKey = BRICKS_SERVER.Func.GetRarityInfo( k )
        local rarityColor = BRICKS_SERVER.Func.GetRarityColor( rarityInfo )
        
        if( not rarityColor ) then continue end

        for key, val in pairs( v ) do
            if( not IsValid( val ) ) then 
                table.remove( BRICKS_SERVER.TEMP.UnboxRewardEnts[k], key )
            end
        end

        if( #BRICKS_SERVER.TEMP.UnboxRewardEnts[k] < 1 ) then
            BRICKS_SERVER.TEMP.UnboxRewardEnts[k] = nil
            continue
        end

        halo.Add( v, rarityColor, 0, 0, 20 )
    end
end )