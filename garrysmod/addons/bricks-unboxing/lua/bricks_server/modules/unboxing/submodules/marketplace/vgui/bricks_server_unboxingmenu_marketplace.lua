local PANEL = {}

function PANEL:Init()
    self.animTime = 0.2
end

function PANEL:FillPanel()
    self.panelTall = ScrH()*0.65-40

    self.topBar = vgui.Create( "DPanel", self )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 60 )
    self.topBar.Paint = function( self, w, h ) 
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.DrawRect( 0, 0, w, h )
    end 

    self.searchBar = vgui.Create( "bricks_server_searchbar", self.topBar )
    self.searchBar:Dock( LEFT )
    self.searchBar:DockMargin( 25, 10, 10, 10 )
    self.searchBar:SetWide( ScrW()*0.2 )
    self.searchBar:SetBackColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BRICKS_SERVER.Func.GetTheme( 0 ) )

    self.pages = {}
    self.pageButtonBack = vgui.Create( "DPanel", self.topBar )
    self.pageButtonBack:Dock( RIGHT )
    self.pageButtonBack:DockMargin( 0, 10, 25, 10 )
    self.pageButtonBack:SetWide( 0 )
    self.pageButtonBack.Paint = function( self, w, h ) end 

    self.auctions = vgui.Create( "DPanel", self )
    self.auctions:SetSize( self.panelWide, self.panelTall-self.topBar:GetTall() )
    self.auctions.Paint = function( self, w, h ) end 
    self:CreatePage( BRICKS_SERVER.Func.L( "unboxingAuctions" ), "Auctions", self.auctions, function() self:OpenAuctions() end )

    self.myAuctions = vgui.Create( "DPanel", self )
    self.myAuctions:SetSize( self.panelWide, self.panelTall-self.topBar:GetTall() )
    self.myAuctions.Paint = function( self, w, h ) end 
    self:CreatePage( BRICKS_SERVER.Func.L( "unboxingMyAuctions" ), "MyAuctions", self.myAuctions, function() self:OpenMyAuctions() end )

    self.myBids = vgui.Create( "DPanel", self )
    self.myBids:SetSize( self.panelWide, self.panelTall-self.topBar:GetTall() )
    self.myBids.Paint = function( self, w, h ) end 
    self:CreatePage( BRICKS_SERVER.Func.L( "unboxingMyBids" ), "MyBids", self.myBids, function() self:OpenMyBids() end )

    self:OpenPage( 1, true )

    hook.Add( "BRS.Hooks.UnboxingMenuOpened", self, function( self, keysTable, totalCount, page )
        if( self.activePage == "Auctions" ) then
            self:OpenAuctions()
        elseif( self.activePage == "MyAuctions" ) then
            self:OpenMyAuctions()
        elseif( self.activePage == "MyBids" ) then
            self:OpenMyBids()
        end
    end )

    hook.Add( "BRS.Hooks.FillUnboxingMarketslots", self, function()
        if( self.activePage == "MyAuctions" ) then
            self:RefreshMyAuctions()
        end
    end )

    hook.Add( "BRS.Hooks.FillUnboxingMarket", self, function( self, keysTable, totalCount, page )
        if( self.activePage == "Auctions" ) then
            self:RefreshAuctions( keysTable, totalCount, page )
        end
    end )

    hook.Add( "BRS.Hooks.UpdateUnboxingMarketData", self, function()
        if( self.activePage == "Auctions" ) then
            self:RefreshAuctions( self.auctions.keysTable, self.auctions.totalCount, self.auctions.page )
        elseif( self.activePage == "MyAuctions" ) then
            self:RefreshMyAuctions()
        elseif( self.activePage == "MyBids" ) then
            self:RefreshMyBids()
        end
    end )
end

function PANEL:CreatePage( name, key, panel, onClick )
    panel:SetPos( self.panelWide, self.topBar:GetTall() )

    local pageNum = table.insert( self.pages, { key, panel, onClick } )

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local textX, textY = surface.GetTextSize( name )

    local pageButton = vgui.Create( "DButton", self.pageButtonBack )
    pageButton:Dock( LEFT )
    pageButton:SetWide( textX+25 )
    pageButton:SetText( "" )
    local alpha = 0
    pageButton.Paint = function( self2, w, h )
        local buttonColor, buttonDownColor = BRICKS_SERVER.Func.GetTheme( 1 ), BRICKS_SERVER.Func.GetTheme( 0 )
        if( self.activePage == key ) then
            buttonColor, buttonDownColor = BRICKS_SERVER.Func.GetTheme( 5 ), BRICKS_SERVER.Func.GetTheme( 4 )
        end

        local roundLeft, roundRight = pageNum == 1, pageNum == #self.pages

        draw.RoundedBoxEx( 8, 0, 0, w, h, buttonColor, roundLeft, roundRight, roundLeft, roundRight )

        if( not self2:IsDown() and self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        surface.SetAlphaMultiplier( alpha/255 )
        draw.RoundedBoxEx( 8, 0, 0, w, h, buttonDownColor, roundLeft, roundRight, roundLeft, roundRight )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, buttonDownColor, 8 )

        draw.SimpleText( name, "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    pageButton.DoClick = function()
        self:OpenPage( pageNum )
    end

    self.pageButtonBack:SetWide( self.pageButtonBack:GetWide()+pageButton:GetWide() )
end

function PANEL:OpenPage( num, noAnim )
    local pageKey, pagePanel, pageOnClick = self.pages[num][1], self.pages[num][2], self.pages[num][3]

    if( self.activePage == pageKey ) then return end

    if( IsValid( self.auctions.popout ) ) then
        self.auctions.popout:Remove()
    end

    if( IsValid( self.activePanel ) ) then
        local newX = self.panelWide

        local nextPanelX = pagePanel:GetPos()
        if( nextPanelX >= self.panelWide ) then
            newX = -self.panelWide
        end

        self.activePanel:MoveTo( newX, self.topBar:GetTall(), self.animTime )
    end

    self.activePanel = pagePanel
    self.activePage = pageKey

    pagePanel:MoveTo( 0, self.topBar:GetTall(), noAnim and 0 or self.animTime )

    pageOnClick()
end

function PANEL:CreateAuctionSlot( parent, width, height, marketKey, marketItemTable )
    local slot = parent:Add( "bricks_server_unboxingmenu_itemslot" )
    slot:SetSize( width, height )
    slot:FillPanel( marketItemTable.ItemGlobalKey, (marketItemTable.ItemAmount or 1), function( x, y, w, h )
        if( IsValid( slot.popoutPanel ) ) then 
            slot.popoutPanel:Remove()
            return 
        end

        local actions = {}
        if( BRICKS_SERVER.Func.UTCTime() < marketItemTable.StartTime+marketItemTable.Duration and marketItemTable.OwnerSteamID64 != LocalPlayer():SteamID64() ) then
            local minBid = math.floor( marketItemTable.CurrentBid*BRICKS_SERVER.CONFIG.UNBOXING["Auctions Minimum Bid Increase"] )
            table.insert( actions, { "Place Bid", function()
                BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "unboxingAuction" ), BRICKS_SERVER.Func.L( "unboxingAuctionBidQuery" ), minBid, function( text ) 
                    local amount = tonumber( text )

                    if( amount < minBid ) then
                        BRICKS_SERVER.Func.Message( BRICKS_SERVER.Func.L( "unboxingAuctionCantBidLess", BRICKS_SERVER.UNBOXING.Func.FormatCurrency( minBid ) ), BRICKS_SERVER.Func.L( "unboxing" ), BRICKS_SERVER.Func.L( "confirm" ) )
                        return
                    end
    
                    net.Start( "BRS.Net.BidUnboxingAuction" )
                        net.WriteUInt( marketKey, 8 )
                        net.WriteUInt( amount, 32 )
                    net.SendToServer()
                end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), true )
            end } )
        end

        if( BRICKS_SERVER.Func.UTCTime() >= marketItemTable.StartTime+marketItemTable.Duration ) then
            table.insert( actions, { BRICKS_SERVER.Func.L( "unboxingCollectAuction" ), function()
                net.Start( "BRS.Net.CollectUnboxingAuction" )
                    net.WriteUInt( marketKey, 8 )
                net.SendToServer()
            end } )
        elseif( marketItemTable.OwnerSteamID64 == LocalPlayer():SteamID64() ) then
            table.insert( actions, { BRICKS_SERVER.Func.L( "unboxingCancelAuction" ), function()
                net.Start( "BRS.Net.CancelUnboxingAuction" )
                    net.WriteUInt( marketKey, 8 )
                net.SendToServer()
            end } )
        end

        slot.popoutPanel = vgui.Create( "bricks_server_unboxingmenu_marketplace_view" )
        slot.popoutPanel:SetPos( (x or 0)+(w or 0)+5, y or 0 )
        slot.popoutPanel:FillPanel( marketItemTable.ItemGlobalKey, (marketItemTable.ItemAmount or 1), actions, marketItemTable )
        slot.popoutPanel.Think = function( self3 )
            if( not self3:HasFocus() ) then
                if( not self3.removeTime ) then
                    self3.removeTime = CurTime()+0.1
                end
            elseif( self3.removeTime ) then
                self3.removeTime = nil
            end

            if( not IsValid( slot ) or (self3.removeTime and CurTime() >= self3.removeTime) ) then
                self3:Remove()
            end
        end
    end )
    slot:AddTopInfo( BRICKS_SERVER.UNBOXING.Func.FormatCurrency( marketItemTable.CurrentBid or 0 ) )
    slot:AddTopInfo( function() 
        if( marketItemTable.Duration > 0 ) then
            local timeLeft = math.max( 0, (marketItemTable.StartTime+marketItemTable.Duration)-BRICKS_SERVER.Func.UTCTime() )
            return timeLeft > 0 and BRICKS_SERVER.Func.FormatTime( timeLeft ) or BRICKS_SERVER.Func.L( "unboxingAuctionEnded" )
        else
            return BRICKS_SERVER.Func.L( "unboxingAuctionCancelled" )
        end
    end )
end

function PANEL:CreateLoadingPopout()
    if( IsValid( self.auctions.popout ) ) then
        self.auctions.popout:Remove()
    end

    local popoutClose = vgui.Create( "DPanel", self.auctions )
    popoutClose:SetSize( self.panelWide, self.panelTall-self.topBar:GetTall() )
    popoutClose:SetAlpha( 0 )
    popoutClose:AlphaTo( 255, 0.2 )
    popoutClose.Paint = function( self2, w, h )
        surface.SetDrawColor( 0, 0, 0, 150 )
        surface.DrawRect( 0, 0, w, h )
        BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
    end

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local loadingX, loadingY = surface.GetTextSize( BRICKS_SERVER.Func.L( "loading" ) )

    local popoutWide, popoutTall = self.panelWide*0.65, math.max( (self.panelTall-self.topBar:GetTall())*0.25, 25+32+5+loadingY+25+40+25 )

    self.auctions.popout = vgui.Create( "DPanel", self.auctions )
    self.auctions.popout:SetSize( 0, 0 )
    self.auctions.popout:SizeTo( popoutWide, popoutTall, 0.2 )
    self.auctions.popout.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    end
    self.auctions.popout.OnSizeChanged = function( self2 )
        self2:SetPos( (self.panelWide/2)-(self2:GetWide()/2), ((self.panelTall-self.topBar:GetTall())/2)-(self2:GetTall()/2) )
    end
    self.auctions.popout.ClosePopout = function()
        if( IsValid( self.auctions.popout ) ) then
            self.auctions.popout:SizeTo( 0, 0, 0.2, 0, -1, function()
                if( IsValid( self.auctions.popout ) ) then
                    self.auctions.popout:Remove()
                end
            end )
        end

        popoutClose:AlphaTo( 0, 0.2, 0, function()
            if( IsValid( popoutClose ) ) then
                popoutClose:Remove()
            end
        end )
    end

    local actionButton = vgui.Create( "DButton", self.auctions.popout )
    actionButton:Dock( BOTTOM )
    actionButton:SetTall( 40 )
    actionButton:SetText( "" )
    actionButton:DockMargin( 25, 0, 25, 25 )
    local changeAlpha = 0
    actionButton.Paint = function( self2, w, h )
        if( not self2:IsDown() and self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
        end
        
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )

        surface.SetAlphaMultiplier( changeAlpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        surface.SetAlphaMultiplier( 1 )

        BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        
        draw.SimpleText( BRICKS_SERVER.Func.L( "cancel" ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    actionButton.DoClick = self.auctions.popout.ClosePopout

    local loadingPanel = vgui.Create( "DPanel", self.auctions.popout )
    loadingPanel:Dock( FILL )
    loadingPanel:DockMargin( 25, 25, 25, 25 )
    local loadingIcon = Material( "materials/bricks_server/loading.png" )
    loadingPanel.Paint = function( self2, w, h )
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( loadingIcon )
        local size = 32
        surface.DrawTexturedRectRotated( w/2, h/2, size, size, -(CurTime() % 360 * 250) )
    
        draw.SimpleText( BRICKS_SERVER.Func.L( "loading" ), "BRICKS_SERVER_Font20", w/2, h/2+(size/2)+5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
    end
end

function PANEL:OpenAuctions()
    self.auctions:Clear()

    local function requestMarketData( searchString, filter, page )
        self:CreateLoadingPopout()

        local hasRequested, errorMsg, waitTime = BRICKS_SERVER.UNBOXING.Func.RequestMarketData( searchString, filter, page )

        if( not hasRequested ) then
            timer.Create( "BRS_UNBOXING_MARKETDATA_WAIT_" .. tostring( self ), (waitTime or 3), 1, function()
                local hasRequested2, errorMsg2, waitTime2 = BRICKS_SERVER.UNBOXING.Func.RequestMarketData( searchString, filter, page )
                if( not hasRequested2 ) then
                    BRICKS_SERVER.Func.Message( errorMsg, BRICKS_SERVER.Func.L( "unboxing" ), BRICKS_SERVER.Func.L( "confirm" ) )
                end
            end )
        end
    end

    self.searchBar.OnEnter = function()
        requestMarketData( self.searchBar:GetValue(), "none", 1 )
    end

    self.auctions.bottomBar = vgui.Create( "DPanel", self.auctions )
    self.auctions.bottomBar:Dock( BOTTOM )
    self.auctions.bottomBar:DockMargin( 25, 0, 25, 25 )
    self.auctions.bottomBar:SetTall( 40 )
    self.auctions.bottomBar.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingAuctionResults", (self2.results or 0), (self2.totalCount or 0) ), "BRICKS_SERVER_Font17", 10, h/2, BRICKS_SERVER.Func.GetTheme( 6, 75 ), 0, TEXT_ALIGN_CENTER )
    end 
    self.auctions.bottomBar.RefreshNav = function( results, totalCount, activePage )
        self.auctions.bottomBar:Clear()

        self.auctions.bottomBar.results = results
        self.auctions.bottomBar.totalCount = totalCount

        local totalPages = math.ceil( totalCount/BRICKS_SERVER.CONFIG.UNBOXING["Auctions Per Page"] )
        for i = 1, totalPages do
            local pageNum = (totalPages-i)+1

            local pageButton = vgui.Create( "DButton", self.auctions.bottomBar )
            pageButton:Dock( RIGHT )
            pageButton:DockMargin( 5, 0, 0, 0 )
            pageButton:SetWide( 30 )
            pageButton:SetText( "" )
            local alpha = 0
            pageButton.Paint = function( self2, w, h )
                local buttonColor, buttonDownColor = BRICKS_SERVER.Func.GetTheme( 3, 100 ), BRICKS_SERVER.Func.GetTheme( 3 )
                if( activePage == pageNum ) then
                    buttonColor, buttonDownColor = BRICKS_SERVER.Func.GetTheme( 5 ), BRICKS_SERVER.Func.GetTheme( 4 )
                end

                draw.RoundedBoxEx( 8, 0, 0, w, h, buttonColor, false, pageNum == totalPages, false, pageNum == totalPages )
        
                if( not self2:IsDown() and self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 255 )
                else
                    alpha = math.Clamp( alpha-10, 0, 255 )
                end
        
                surface.SetAlphaMultiplier( alpha/255 )
                draw.RoundedBoxEx( 8, 0, 0, w, h, buttonDownColor, false, pageNum == totalPages, false, pageNum == totalPages )
                surface.SetAlphaMultiplier( 1 )
        
                BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, buttonDownColor, 8 )
        
                draw.SimpleText( pageNum, "BRICKS_SERVER_Font21", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            pageButton.DoClick = function()
                if( activePage == pageNum ) then return end

                requestMarketData( self.searchBar:GetValue(), "none", pageNum )
            end
        end
    end

    self.auctions.spacing = 10
    local gridWide = self.panelWide-50-10-self.auctions.spacing
    self.auctions.slotsWide = 4
    self.auctions.slotWide = (gridWide-((self.auctions.slotsWide-1)*self.auctions.spacing))/self.auctions.slotsWide
    self.auctions.slotTall = 75

    self.auctions.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.auctions )
    self.auctions.scrollPanel:Dock( FILL )
    self.auctions.scrollPanel:DockMargin( 25, 25, 25, 10 )
    self.auctions.scrollPanel.Paint = function( self, w, h ) end 

    self.auctions.grid = vgui.Create( "DIconLayout", self.auctions.scrollPanel )
    self.auctions.grid:Dock( TOP )
    self.auctions.grid:SetSpaceY( self.auctions.spacing )
    self.auctions.grid:SetSpaceX( self.auctions.spacing )

    requestMarketData( self.searchBar:GetValue(), "none", 1 )
end

function PANEL:RefreshAuctions( keysTable, totalCount, page )
    self.auctions.grid:Clear()

    self.auctions.bottomBar.RefreshNav( #keysTable, totalCount, page )
    self.auctions.keysTable = keysTable
    self.auctions.totalCount = totalCount
    self.auctions.page = page

    if( #keysTable > 0 ) then
        for k, v in pairs( keysTable ) do
            local marketItemTable = BRICKS_SERVER.TEMP.UnboxingMarketplace[v]

            if( not marketItemTable ) then continue end

            self:CreateAuctionSlot( self.auctions.grid, self.auctions.slotWide, self.auctions.slotWide*1.2, v, marketItemTable )
        end

        self.auctions.scrollPanel.Paint = function( self, w, h ) end 
    else
        surface.SetFont( "BRICKS_SERVER_Font25" )
        local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingMarketNoAuctions" ) )
        textX, textY = textX+30, textY+20

        self.auctions.scrollPanel.Paint = function( self, w, h ) 
            draw.RoundedBox( 5, (w/2)-(textX/2), (h/2)-(textY/2), textX, textY, BRICKS_SERVER.Func.GetTheme( 3 ) )

            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingMarketNoAuctions" ), "BRICKS_SERVER_Font23", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end 
    end

    if( IsValid( self.auctions.popout ) ) then
        self.auctions.popout.ClosePopout()
    end
end

function PANEL:OpenMyAuctions()
    self.myAuctions:Clear()

    self.searchBar.OnEnter = function()

    end

    self.myAuctions.spacing = 10
    local gridWide = self.panelWide-50-10-self.myAuctions.spacing
    self.myAuctions.slotsWide = 4
    self.myAuctions.slotWide = (gridWide-((self.myAuctions.slotsWide-1)*self.myAuctions.spacing))/self.myAuctions.slotsWide

    self.myAuctions.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.myAuctions )
    self.myAuctions.scrollPanel:Dock( FILL )
    self.myAuctions.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.myAuctions.scrollPanel.Paint = function( self, w, h ) end 

    self.myAuctions.grid = vgui.Create( "DIconLayout", self.myAuctions.scrollPanel )
    self.myAuctions.grid:Dock( TOP )
    self.myAuctions.grid:SetSpaceY( self.myAuctions.spacing )
    self.myAuctions.grid:SetSpaceX( self.myAuctions.spacing )

    BRICKS_SERVER.UNBOXING.Func.RequestSlotMarketData()

    self:RefreshMyAuctions()
end

function PANEL:RefreshMyAuctions()
    self.myAuctions.grid:Clear()

    for k, v in pairs( BRICKS_SERVER.CONFIG.UNBOXING.Marketplace.Slots ) do
        local marketSlotTable = LocalPlayer():GetUnboxingMarketplaceSlots()[k]
        if( marketSlotTable and marketSlotTable[1] ) then
            local marketItemTable = BRICKS_SERVER.TEMP.UnboxingMarketplace[marketSlotTable[1]]

            if( not marketItemTable ) then continue end

            self:CreateAuctionSlot( self.myAuctions.grid, self.myAuctions.slotWide, self.myAuctions.slotWide*1.2, marketSlotTable[1], marketItemTable )
        else
            local iconMat = Material( "bricks_server/unboxing_lock.png" )
            if( marketSlotTable ) then
                iconMat = Material( "bricks_server/unboxing_add.png" )
            end

            local unlockMat = Material( "bricks_server/unboxing_unlock.png" )

            local slot = self.myAuctions.grid:Add( "DPanel" )
            slot:SetSize( self.myAuctions.slotWide, self.myAuctions.slotWide*1.2 )
            local alpha = 0
            slot.Paint = function( self2, w, h )
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        
                if( IsValid( self2.button ) ) then
                    if( not self2.button:IsDown() and self2.button:IsHovered() ) then
                        alpha = math.Clamp( alpha+10, 0, 75 )
                    else
                        alpha = math.Clamp( alpha-10, 0, 75 )
                    end
        
                    draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3, alpha ) )
        
                    BRICKS_SERVER.Func.DrawClickCircle( self2.button, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), 8 )
                end
        
                local iconSize = 128
                
                if( iconMat ) then
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, (marketSlotTable and 255) or 255-((alpha/75)*255) ) )
                    surface.SetMaterial( iconMat )
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end

                if( not marketSlotTable ) then
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, (alpha/75)*255 ) )
                    surface.SetMaterial( unlockMat )
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end

                draw.SimpleText( string.upper( BRICKS_SERVER.Func.L( (marketSlotTable and "unboxingAddItem") or "unboxingUnlock" ) ), "BRICKS_SERVER_Font30B", w/2, (h/2)+(iconSize/2)+10, textColor or BRICKS_SERVER.Func.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
            end
            slot.addTopInfo = function( text, color, textColor )
                surface.SetFont( "BRICKS_SERVER_Font20B" )
                local topX, topY = surface.GetTextSize( text )
                
                local boxW, boxH = topX+15, topY+5

                slot.topBar:SetTall( math.max( slot.topBar:GetTall(), boxH ) )

                local infoEntry = vgui.Create( "DPanel", slot.topBar )
                infoEntry:Dock( RIGHT )
                infoEntry:DockMargin( 5, 0, 0, 0 )
                infoEntry:SetWide( boxW )
                infoEntry.Paint = function( self2, w, h ) 
                    draw.RoundedBox( 8, 0, 0, w, h, color or BRICKS_SERVER.Func.GetTheme( 1 ) )
                    draw.SimpleText( text, "BRICKS_SERVER_Font20B", w/2, (h/2)-1, textColor or BRICKS_SERVER.Func.GetTheme( 6, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
            end

            slot.topBar = vgui.Create( "DPanel", slot )
            slot.topBar:SetPos( 5, 5 )
            slot.topBar:SetWide( slot:GetWide()-10 )
            slot.topBar.Paint = function( self2, w, h ) end

            slot.addTopInfo( BRICKS_SERVER.Func.L( "unboxingAuctionSlot", k ) )
            
            if( not marketSlotTable ) then
                if( v.Price ) then
                    slot.addTopInfo( BRICKS_SERVER.UNBOXING.Func.FormatCurrency( v.Price ) )
                end

                if( v.Group ) then
                    local groupTable = {}
                    for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                        if( val[1] == v.Group ) then
                            groupTable = val
                            break
                        end
                    end

                    slot.addTopInfo( v.Group, groupTable[3], BRICKS_SERVER.Func.GetTheme( 6 ) )
                end
            end

            slot.button = vgui.Create( "DButton", slot )
            slot.button:Dock( FILL )
            slot.button:SetText( "" )
            slot.button.Paint = function( self2, w, h ) end
            slot.button.DoClick = function( self2 )
                if( not marketSlotTable ) then
                    local text, confirm = BRICKS_SERVER.Func.L( "unboxingUnlockSlot" ), BRICKS_SERVER.Func.L( "unboxingUnlock" )
                    if( v.Price ) then
                        text, confirm = BRICKS_SERVER.Func.L( "unboxingPurchaseSlot", BRICKS_SERVER.UNBOXING.Func.FormatCurrency( v.Price ) ), BRICKS_SERVER.Func.L( "unboxingPurchase" )
                    end

                    BRICKS_SERVER.Func.CreatePopoutQuery( text, self, self.panelWide, self.panelTall, confirm, BRICKS_SERVER.Func.L( "cancel" ), function()
                        if( v.Price and not BRICKS_SERVER.UNBOXING.Func.CanAffordCurrency( LocalPlayer(), v.Price ) ) then
                            BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "unboxingCantAfford" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                            return
                        end

                        if( v.Group and not BRICKS_SERVER.Func.IsInGroup( LocalPlayer(), v.Group ) ) then
                            BRICKS_SERVER.Func.CreateTopNotification( BRICKS_SERVER.Func.L( "unboxingNotGroup" ), 3, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                            return
                        end

                        net.Start( "BRS.Net.UnlockUnboxingMarketplaceSlot" )
                            net.WriteUInt( k, 8 )
                        net.SendToServer()
                    end )
                else
                    self2.popoutPanel = vgui.Create( "bricks_server_unboxingmenu_marketplace_additem", self )
                    self2.popoutPanel:SetPos( 0, 0 )
                    self2.popoutPanel:SetSize( self.panelWide, self.panelTall )
                    self2.popoutPanel.slot = k
                    self2.popoutPanel:CreatePopout()
                end
            end
        end
    end
end

function PANEL:OpenMyBids()
    self.myBids:Clear()

    self.searchBar.OnEnter = function()

    end

    self.myBids.spacing = 10
    local gridWide = self.panelWide-50-10-self.myBids.spacing
    self.myBids.slotsWide = 4
    self.myBids.slotWide = (gridWide-((self.myBids.slotsWide-1)*self.myBids.spacing))/self.myBids.slotsWide

    self.myBids.scrollPanel = vgui.Create( "bricks_server_scrollpanel_bar", self.myBids )
    self.myBids.scrollPanel:Dock( FILL )
    self.myBids.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.myBids.scrollPanel.Paint = function( self, w, h ) end 

    self.myBids.grid = vgui.Create( "DIconLayout", self.myBids.scrollPanel )
    self.myBids.grid:Dock( TOP )
    self.myBids.grid:SetSpaceY( self.myBids.spacing )
    self.myBids.grid:SetSpaceX( self.myBids.spacing )

    BRICKS_SERVER.UNBOXING.Func.RequestBidMarketData()

    self:RefreshMyBids()
end

function PANEL:RefreshMyBids()
    self.myBids.grid:Clear()

    local myBidsCount = 0
    for k, v in pairs( BRICKS_SERVER.TEMP.UnboxingMarketplace ) do
        if( not v.Bidders or not v.Bidders[LocalPlayer():SteamID()] or v.Bidders[LocalPlayer():SteamID()][2] ) then continue end

        myBidsCount = myBidsCount+1

        self:CreateAuctionSlot( self.myBids.grid, self.myBids.slotWide, self.myBids.slotWide*1.2, k, v )
    end

    if( myBidsCount <= 0 ) then
        surface.SetFont( "BRICKS_SERVER_Font25" )
        local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "unboxingMarketNoAuctions" ) )
        textX, textY = textX+30, textY+20

        self.myBids.scrollPanel.Paint = function( self, w, h ) 
            draw.RoundedBox( 5, (w/2)-(textX/2), (h/2)-(textY/2), textX, textY, BRICKS_SERVER.Func.GetTheme( 3 ) )

            draw.SimpleText( BRICKS_SERVER.Func.L( "unboxingMarketNoAuctions" ), "BRICKS_SERVER_Font23", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    else
        self.myBids.scrollPanel.Paint = function( self, w, h ) end
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_unboxingmenu_marketplace", PANEL, "DPanel" )