local PANEL = {}

function PANEL:Init()
    self:DockMargin( 10, 10, 10, 10 )
end

function PANEL:FillPanel( gangTable )
    function self.RefreshPanel()
        self:Clear()

        for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Territories or {} ) do
            local territoryTable = (BRS_GANG_TERRITORIES or {})[k] or {}
            local claimed = territoryTable.Claimed

            local itemBack = vgui.Create( "DPanel", self )
            itemBack:Dock( TOP )
            itemBack:DockMargin( 0, 0, 0, 5 )
            itemBack:SetTall( 140 )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            end

            local topBar = vgui.Create( "DPanel", itemBack )
            topBar:Dock( TOP )
            topBar:SetTall( 40 )
            surface.SetFont( "BRICKS_SERVER_Font20" )
            local nameX, nameY = surface.GetTextSize( v.Name )
            topBar.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                BRICKS_SERVER.Func.DrawPartialRoundedBox( 5, 0, 0, 3, h, (v.Color or BRICKS_SERVER.Func.GetTheme( 5 )), 10, h )
            
                draw.SimpleText( v.Name, "BRICKS_SERVER_Font20", 15, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )

                local text = (claimed and BRICKS_SERVER.Func.L( "gangClaimed" )) or BRICKS_SERVER.Func.L( "gangUnclaimed" )

                surface.SetFont( "BRICKS_SERVER_Font20" )
                local textX, textY = surface.GetTextSize( text )
                local boxW, boxH = textX+10, textY+3

                draw.RoundedBox( 5, 15+nameX+10, (h/2)-(boxH/2), boxW, boxH, (claimed and BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                draw.SimpleText( text, "BRICKS_SERVER_Font20", 15+nameX+10+(boxW/2), h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                if( claimed ) then
                    local timeSince = math.max( 0, math.floor( os.time()-(territoryTable.ClaimedAt or 0) ) )

                    draw.SimpleText( BRICKS_SERVER.Func.L( "gangClaimedAgo", BRICKS_SERVER.Func.FormatWordTime( timeSince ) ), "BRICKS_SERVER_Font20", w-10, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                end
            end

            local rewardsBackTall = itemBack:GetTall()-topBar:GetTall()

            local rewardsBack = vgui.Create( "DPanel", itemBack )
            rewardsBack:Dock( RIGHT )
            rewardsBack:DockMargin( 0, 0, 15, 0 )
            rewardsBack:SetWide( 150 )
            local noticeBack
            rewardsBack.Paint = function( self2, w, h ) 
                if( v.Rewards and table.Count( v.Rewards ) > 0 ) then
                    if( not IsValid( noticeBack ) ) then return end

                    local noticeX, noticeY = noticeBack:GetPos()
                    local noticeW, noticeH = noticeBack:GetSize()

                    draw.SimpleText( BRICKS_SERVER.Func.L( "gangRewards" ), "BRICKS_SERVER_Font23", w/2, noticeY-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

                    draw.SimpleText( BRICKS_SERVER.Func.L( "gangRewardsEvery", BRICKS_SERVER.Func.FormatWordTime( v.RewardTime ) ), "BRICKS_SERVER_Font17", w/2, noticeY+noticeH+5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                else
                    draw.SimpleText( BRICKS_SERVER.Func.L( "gangRewards" ), "BRICKS_SERVER_Font23", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
                    draw.SimpleText( BRICKS_SERVER.Func.L( "none" ), "BRICKS_SERVER_Font17", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                end
            end

            noticeBack = vgui.Create( "DPanel", rewardsBack )
            noticeBack:SetSize( 0, 35 )
            noticeBack:SetPos( (rewardsBack:GetWide()/2)-(noticeBack:GetWide()/2), (rewardsBackTall/2)-(noticeBack:GetTall()/2) )
            noticeBack.Paint = function( self2, w, h ) end

            local itemNotices = {}

            for key, val in pairs( v.Rewards or {} ) do
                local devConfig = BRICKS_SERVER.DEVCONFIG.GangRewards[key]

                if( not devConfig ) then continue end

                table.insert( itemNotices, { devConfig.FormatDescription( val ), devConfig.Color } )
            end

            for k, v in pairs( itemNotices ) do
                surface.SetFont( "BRICKS_SERVER_Font23" )
                local textX, textY = surface.GetTextSize( v[1] )
                local boxW, boxH = textX+10, textY

                local itemInfoNotice = vgui.Create( "DPanel", noticeBack )
                itemInfoNotice:Dock( LEFT )
                itemInfoNotice:DockMargin( 0, 0, 5, 0 )
                itemInfoNotice:SetWide( boxW )
                itemInfoNotice.Paint = function( self2, w, h ) 
                    draw.RoundedBox( 5, 0, 0, w, h, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                    draw.SimpleText( v[1], "BRICKS_SERVER_Font23", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                if( noticeBack:GetWide() <= 5 ) then
                    noticeBack:SetSize( noticeBack:GetWide()+boxW, boxH )
                else
                    noticeBack:SetSize( noticeBack:GetWide()+5+boxW, boxH )
                end

                if( noticeBack:GetWide() > rewardsBack:GetWide() ) then
                    rewardsBack:SetWide( noticeBack:GetWide() )
                end

                noticeBack:SetPos( (rewardsBack:GetWide()/2)-(noticeBack:GetWide()/2), (rewardsBackTall/2)-(noticeBack:GetTall()/2) )
            end

            local claimedGangTable = {}
            if( claimed ) then
                if( BRICKS_SERVER_GANGS[territoryTable.GangID or 0] ) then
                    claimedGangTable = BRICKS_SERVER_GANGS[territoryTable.GangID or 0]
                else
                    BRICKS_SERVER.Func.RequestTerritoryGangs()
                end
            end

            local avatarBack = vgui.Create( "DPanel", itemBack )
            avatarBack:Dock( FILL )
            avatarBack:DockMargin( 15, 15, 15, 15 )
            local avatarBackSize = 70
            local avatarSize = (claimedGangTable.Icon and avatarBackSize*0.6) or 32
            avatarBack.Paint = function( self2, w, h )
                local textStartPos = avatarBackSize+15

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.NoTexture()
                BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )
        
                draw.SimpleText( (claimedGangTable.Name or BRICKS_SERVER.Func.L( "gangNone" )), "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
        
                draw.SimpleText( BRICKS_SERVER.Func.L( "gangID", (claimedGangTable.GangID or 0) ), "BRICKS_SERVER_Font17", textStartPos, h/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            local gangIcon = vgui.Create( "bricks_server_gangicon", avatarBack )
            gangIcon:SetSize( avatarSize, avatarSize )
            gangIcon:SetPos( (avatarBackSize-avatarSize)/2, (avatarBackSize-avatarSize)/2 )
            gangIcon:SetIconURL( claimedGangTable.Icon or "bricks_server/question.png" )
        end
    end
    self.RefreshPanel()

    hook.Add( "BRS.Hooks.RefreshGangTerritories", self, function()
        if( IsValid( self ) ) then
            self.RefreshPanel()
        else
            hook.Remove( "BRS.Hooks.RefreshGangTerritories", self )
        end
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_territories", PANEL, "bricks_server_scrollpanel" )