include('shared.lua')
local refreshPanel = true
local backMat = Material( "bricks_server/back.png" )
local cursorMat = Material( "bricks_server/cursor.png" )
function ENT:CreateVGUI()
	if( IsValid( self.printerVGUI )  ) then
		self.printerVGUI:Remove()
	end

	if( not IsValid( self.printerVGUI )  ) then
		local outerMargin, innerSpacing = 15*0.8, 10*0.8
		
		self.printerVGUI = vgui.Create( "DPanel" )
		self.printerVGUI:SetPos( 0, 0 )
		self.printerVGUI:SetSize( BRICKS_SERVER.DEVCONFIG.GangPrinterW, BRICKS_SERVER.DEVCONFIG.GangPrinterH )
		local cursorX, cursorY = 0, 0
		self.printerVGUI.Paint = function( self2, w, h )
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
			surface.DrawRect( 0, 0, w, h )

			if( IsValid( self.printerVGUI.Cursor ) ) then
				local lerpPercent = RealFrameTime()*10
				cursorX = Lerp( lerpPercent, cursorX, gui.MouseX()+1 )
				cursorY = Lerp( lerpPercent, cursorY, gui.MouseY()+1 )

				self.printerVGUI.Cursor:SetPos( cursorX, cursorY )
			end
		end
		self.printerVGUI.CreateCursor = function( self2 )
			if( IsValid( self.printerVGUI.Cursor ) ) then
				self.printerVGUI.Cursor:Remove()
			end

			self.printerVGUI.Cursor = vgui.Create( "DPanel", self.printerVGUI )
			self.printerVGUI.Cursor:SetSize( 16*0.8, 16*0.8 )
			self.printerVGUI.Cursor.Paint = function( self2, w, h )
				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
				surface.SetMaterial( cursorMat )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
		end

		local topPanel = vgui.Create( "DPanel", self.printerVGUI )
		topPanel:Dock( TOP )
		topPanel:DockMargin( outerMargin, outerMargin, outerMargin, 0 )
		topPanel:SetTall( 88*0.8 )
		topPanel.Paint = function( self2, w, h ) end

		local gangTable = (BRICKS_SERVER_GANGS or {})[self:GetGangID()]
		local printerConfigTable = BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[self:GetPrinterID()] or {}

		local gangPanel = vgui.Create( "DPanel", topPanel )
		gangPanel:Dock( LEFT )
		gangPanel:SetWide( (self.printerVGUI:GetWide()-(2*outerMargin)-innerSpacing)/2 )
		local greyTextCol = Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 25 )
		local iconMat
		BRICKS_SERVER.Func.GetImage( (gangTable or {}).Icon or "question.png", function( mat ) 
			iconMat = mat 
		end )
		gangPanel.Paint = function( self2, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

			local iconBackSize, iconBackSpacing, iconSize = h-22, 11, ((gangTable or {}).Icon and h-22-10) or 32
			draw.RoundedBox( 8, iconBackSpacing, iconBackSpacing, iconBackSize, iconBackSize, BRICKS_SERVER.Func.GetTheme( 2 ) )

			draw.SimpleText( ((gangTable or {}).Name or "Unknown"), "BRICKS_SERVER_NoSC_Font33", iconBackSpacing+iconBackSize+20, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( (printerConfigTable.Name or "Printer 0"), "BRICKS_SERVER_NoSC_Font24", iconBackSpacing+iconBackSize+20, h/2-2, greyTextCol, 0, 0 )

			if( iconMat ) then
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( iconMat )
				surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
			end
		end

		local healthPercents = {
			{ 0.75, Color( 182, 209, 42 ) },
			{ 0.50, Color( 209, 131, 42 ) },
			{ 0.25, Color( 209, 87, 42 ) },
			{ 0.10, Color( 209, 42, 42 ) }
		}

		local healthPanel = vgui.Create( "DPanel", topPanel )
		healthPanel:Dock( FILL )
		healthPanel:DockMargin( innerSpacing, 0, 0, 0 )
		healthPanel.Paint = function( self2, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

			draw.SimpleText( "HEALTH", "BRICKS_SERVER_NoSC_Font24", 23*0.8, 15*0.8, Color( 255, 255, 255, 25 ), 0, 0 )

			local barH, barSideMargin = 13*0.8, 23*0.8
			draw.RoundedBox( barH/2, barSideMargin, 45*0.8, w-(2*barSideMargin), barH, BRICKS_SERVER.Func.GetTheme( 3 ) )

			local healthPercent = math.Clamp( self:Health()/self:GetTotalHealth(), 0, 1 )

			local healthColor = Color( 70, 200, 112 )
			for k, v in ipairs( healthPercents ) do
				if( healthPercent <= v[1] ) then
					healthColor = v[2]
				else
					break
				end
			end

			draw.RoundedBox( 8, barSideMargin, 45*0.8, (w-(2*barSideMargin))*healthPercent, barH, healthColor )
		end

		-- Progress Bars
		local ProgressBars = {}
		table.insert( ProgressBars, { "MONEY", function() 
			return DarkRP.formatMoney( self:GetHolding() or 0 )
		end, function()
			return 1
		end, true } )

		table.insert( ProgressBars, { "INCOME", function() 
			return DarkRP.formatMoney( self:GetPrintAmount() ) .. " / " .. self:GetPrintTime() .. "s"
		end, function()
			if( self:GetPrintTime() <= 0 ) then return 1 end

			return (self:GetNextPrint() > 0 and 1-((self:GetNextPrint()-CurTime())/self:GetPrintTime())) or 1
		end } )

		table.insert( ProgressBars, { "TEMPERATURE", function() 
			return self:GetTemperature() .. "°C"
		end, function()
			return 1
		end, true } )

		local radius, arcWidth, mainArcWidth = 80*0.8, 2, 6
		local spacing = ((self.printerVGUI:GetWide()-(2*outerMargin))-(#ProgressBars*radius*2))/(#ProgressBars+1)

		local statisticsPanel = vgui.Create( "DPanel", self.printerVGUI )
		statisticsPanel:Dock( TOP )
		statisticsPanel:DockMargin( outerMargin, innerSpacing, outerMargin, 0 )
		statisticsPanel:SetTall( (radius+spacing)*2 )
		statisticsPanel.Paint = function( self2, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		end

		for k, v in ipairs( ProgressBars ) do
			local progressPanel = vgui.Create( "DPanel", statisticsPanel )
			progressPanel:Dock( LEFT )
			progressPanel:DockMargin( spacing, 0, 0, 0 )
			progressPanel:SetWide( radius*2 )
			local cachedArc, oldValue, cachedArcBack
			progressPanel.Paint = function( self2, w, h )
				BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2-(mainArcWidth/2)+(arcWidth/2), BRICKS_SERVER.Func.GetTheme( 2 ) )
				BRICKS_SERVER.Func.DrawCircle( w/2, h/2, (w/2-(mainArcWidth/2)+(arcWidth/2))-arcWidth, BRICKS_SERVER.Func.GetTheme( 0 ) )

				if( not v[4] and 360*v[3]() < 360 ) then
					local newValue = v[3]()
					if( newValue != oldValue ) then
						cachedArc = BRICKS_SERVER.Func.PrecachedArc( w/2, h/2, w/2, mainArcWidth, 90-(360*v[3]()), 90 )
						oldValue = newValue
					end
					
					BRICKS_SERVER.Func.DrawCachedArc( cachedArc, BRICKS_SERVER.Func.GetTheme( 5 ) )
				else
					BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2, BRICKS_SERVER.Func.GetTheme( 5 ) )
					BRICKS_SERVER.Func.DrawCircle( w/2, h/2, (w/2)-mainArcWidth, BRICKS_SERVER.Func.GetTheme( 0 ) )
				end
				
				draw.SimpleText( v[2](), "BRICKS_SERVER_NoSC_Font24", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( v[1], "BRICKS_SERVER_NoSC_Font24", w/2, h/2+radius+15, Color( 255, 255, 255, 25 ), TEXT_ALIGN_CENTER, 0 )
			end
		end

		local graphPanel = vgui.Create( "DPanel", self.printerVGUI )
		graphPanel:Dock( TOP )
		graphPanel:DockMargin( outerMargin, innerSpacing, outerMargin, 0 )
		graphPanel:SetTall( 333*0.8 )
		graphPanel.Paint = function( self2, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

			draw.SimpleText( "INCOME", "BRICKS_SERVER_NoSC_Font24", 23, 21, Color( 255, 255, 255, 25 ), 0, 0 )
		end

		local income, lineDistance
		function self.printerVGUI.RefreshIncomeGraph()
			income = self.IncomeTrackTable or {}
			lineDistance = 30

			for k, v in ipairs( income ) do
				surface.SetFont( "BRICKS_SERVER_NoSC_Font17" )
				local displayValue = math.ceil( (v >= 100 and v/1000) or v )
				local textX, textY = surface.GetTextSize( ((v >= 100 and displayValue .. "k") or displayValue) )
				local newLineDistance = textX+20
	
				if( newLineDistance > lineDistance ) then
					lineDistance = newLineDistance
				end
			end
		end
		self.printerVGUI.RefreshIncomeGraph()

		local lineCount, circleRadius = 11, 4
		local graphLinesPanel = vgui.Create( "DPanel", graphPanel )
		graphLinesPanel:Dock( FILL )
		graphLinesPanel:DockMargin( 25, 65, 25, 0 )
		graphLinesPanel.Paint = function( self2, w, h )
			local sortedIncome = table.Copy( income )
			table.sort( sortedIncome, function(a, b) return a < b end )
			local lowestValue = sortedIncome[1] or 0
			local highestValue = sortedIncome[#sortedIncome] or 0

			local lineDifference = (highestValue-lowestValue)/(lineCount-1)
			local lowerBound = lowestValue
			local upperBound = highestValue

			for i = 1, lineCount do
				local lineValue = lowerBound+((i-1)*lineDifference)
				
				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
				surface.DrawRect( lineDistance, (i-1)*(h/lineCount), w-lineDistance, 1 )

				local displayValue = math.ceil( (lineValue >= 100 and lineValue/1000) or lineValue )
				draw.SimpleText( ((lineValue >= 100 and displayValue .. "k") or displayValue), "BRICKS_SERVER_NoSC_Font17", lineDistance/2, h-(i*(h/lineCount))-1, BRICKS_SERVER.Func.GetTheme( 5 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end

			local lineTotalH = h-(h/lineCount)
			local previousCircleX, previousCircleY
			for k, v in ipairs( income ) do
				local circleX, circleY = lineDistance+(((w-lineDistance)/(self.IncomeTrackAmount-1))*(k-1)), lineTotalH-(((v-lowerBound)/(upperBound-lowerBound))*lineTotalH)

				draw.NoTexture()
				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
				BRICKS_SERVER.Func.DrawCircle( circleX, circleY, circleRadius, 45 )	
					
				if( previousCircleX and previousCircleY ) then
					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
					surface.DrawLine( previousCircleX, previousCircleY, circleX, circleY )
				end

				previousCircleX, previousCircleY = circleX, circleY
			end

			for k, v in ipairs( income ) do
				local circleX, circleY = lineDistance+(((w-lineDistance)/(self.IncomeTrackAmount-1))*(k-1)), lineTotalH-(((v-lowerBound)/(upperBound-lowerBound))*lineTotalH)

				draw.NoTexture()
				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
				BRICKS_SERVER.Func.DrawCircle( circleX, circleY, circleRadius-2, 45 )	
			end
		end

		local bottomPanel = vgui.Create( "DPanel", self.printerVGUI )
		bottomPanel:Dock( FILL )
		bottomPanel.Paint = function( self2, w, h ) end

		local bottomLeftPanel = vgui.Create( "DPanel", bottomPanel )
		bottomLeftPanel:Dock( LEFT )
		bottomLeftPanel:DockMargin( outerMargin, innerSpacing, 0, outerMargin )
		bottomLeftPanel:SetWide( (self.printerVGUI:GetWide()-(2*outerMargin)-innerSpacing)/2 )
		bottomLeftPanel.Paint = function( self2, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

			draw.SimpleText( "HISTORY", "BRICKS_SERVER_NoSC_Font24", 23, 21, Color( 255, 255, 255, 25 ), 0, 0 )
		end

		local bottomRightPanel = vgui.Create( "DPanel", bottomPanel )
		bottomRightPanel:Dock( RIGHT )
		bottomRightPanel:DockMargin( 0, innerSpacing, outerMargin, outerMargin )
		bottomRightPanel:SetWide( (self.printerVGUI:GetWide()-(2*outerMargin)-innerSpacing)/2 )
		bottomRightPanel.Paint = function( self2, w, h ) end

		local buttonBack = vgui.Create( "DPanel", bottomRightPanel )
		buttonBack:Dock( TOP )
		buttonBack:SetTall( 46*0.8 )
		buttonBack.Paint = function( self2, w, h ) end

		local toggleButton = vgui.Create( "DButton", buttonBack )
		toggleButton:Dock( RIGHT )
		toggleButton:DockMargin( innerSpacing, 0, 0, 0 )
		toggleButton:SetWide( 150*0.8 )
		toggleButton:SetText( "" )
		toggleButton.Paint = function( self2, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

			local buttonColor = Color( 70, 200, 112 )
			local poly = {
				{ x = w/2-10, y = h },
				{ x = w/2-10, y = 0 },
				{ x = w/2+10, y = 0 }
			}

			if( self:GetStatus() ) then
				draw.RoundedBoxEx( 8, 0, 0, w/2-10, h, buttonColor, true, false, true, false )
			else
				buttonColor = Color( 218, 51, 56 )
				draw.RoundedBoxEx( 8, w/2+10, 0, w/2-10, h, buttonColor, false, true, false, true )

				poly = {
					{ x = w/2-10, y = h },
					{ x = w/2+10, y = 0 },
					{ x = w/2+10, y = h }
				}
			end

			surface.SetDrawColor( buttonColor )
			draw.NoTexture()
			surface.DrawPoly( poly )

			draw.SimpleText( "ON", "BRICKS_SERVER_NoSC_Font20", w/4, h/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "OFF", "BRICKS_SERVER_NoSC_Font20", w/4*3, h/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		toggleButton.DoClick = function()
			net.Start( "BRS.Net.GangPrinterToggle" )
				net.WriteEntity( self )
			net.SendToServer()
		end

		local withdrawButton = vgui.Create( "DButton", buttonBack )
		withdrawButton:Dock( FILL )
		withdrawButton:SetText( "" )
		withdrawButton.Paint = function( self2, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, Color( 218, 51, 56 ) )

			draw.SimpleText( "WITHDRAW MONEY", "BRICKS_SERVER_NoSC_Font20", w/2, h/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		withdrawButton.DoClick = function()
			net.Start( "BRS.Net.GangPrinterWithdraw" )
				net.WriteEntity( self )
			net.SendToServer()
		end

		local menuPanel = vgui.Create( "DPanel", bottomRightPanel )
		menuPanel:Dock( FILL )
		menuPanel:DockMargin( 0, innerSpacing, 0, 0 )
		menuPanel:DockPadding( 0, 21+40, 0, 0 )
		menuPanel.Paint = function( self2, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )

			draw.SimpleText( "MENU", "BRICKS_SERVER_NoSC_Font24", 23, 21, Color( 255, 255, 255, 25 ), 0, 0 )
		end

		local pages = {
			{
				Name = "UPGRADES",
				Icon = Material( "bricks_server/printer_upgrade.png" ),
				Element = "bricks_server_gangprinter_upgrades"
			}
		}

		for k, v in ipairs( pages ) do
			surface.SetFont( "BRICKS_SERVER_NoSC_Font20" )
			local textX, textY = surface.GetTextSize( v.Name )

			local button = vgui.Create( "DButton", menuPanel )
			button:Dock( TOP )
			button:DockMargin( 20, 0, 20, 12 )
			button:SetTall( 40*0.8 )
			button:SetText( "" )
			local Alpha = 0
			button.Paint = function( self2, w, h ) 
				if( self2.Hovered ) then
					Alpha = math.Clamp( Alpha+10, 0, 255 )
				else
					Alpha = math.Clamp( Alpha-10, 0, 255 )
				end
			
				draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

				surface.SetAlphaMultiplier( Alpha/255 )
				draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
				surface.SetAlphaMultiplier( 1 )

				local iconSize = 16
				surface.SetDrawColor( 255, 255, 255, 50 )
				surface.SetMaterial( v.Icon )
				surface.DrawTexturedRect( (w/2)-(textX/2)-5-iconSize, (h/2)-(iconSize/2), iconSize, iconSize )

				draw.SimpleText( v.Name, "BRICKS_SERVER_NoSC_Font20", w/2, h/2, Color( 255, 255, 255, 50 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
			button.DoClick = function()
				if( IsValid( self.printerVGUI.printerPage ) ) then
					self.printerVGUI.printerPage:Remove()
				end

				surface.SetFont( "BRICKS_SERVER_NoSC_Font40" )
				local textX, textY = surface.GetTextSize( v.Name )

				self.printerVGUI.printerPage = vgui.Create( "DPanel", self.printerVGUI )
				self.printerVGUI.printerPage:SetSize( self.printerVGUI:GetWide(), self.printerVGUI:GetTall() )
				self.printerVGUI.printerPage:SetPos( 0, 0 )
				self.printerVGUI.printerPage.Paint = function( self2, w, h )
					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
					surface.DrawRect( 0, 0, w, h )

					draw.RoundedBox( 8, 12, 12, 75+textX+36, 75, BRICKS_SERVER.Func.GetTheme( 0 ) )
		
					draw.SimpleText( v.Name, "BRICKS_SERVER_NoSC_Font40", 24+51+25, 12+(75/2)-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
				end

				local backButton = vgui.Create( "DButton", self.printerVGUI.printerPage )
				backButton:SetSize( 51, 51 )
				backButton:SetPos( 24, 24 )
				backButton:SetText( "" )
				local Alpha = 0
				backButton.Paint = function( self2, w, h ) 
					if( self2.Hovered ) then
						Alpha = math.Clamp( Alpha+10, 0, 255 )
					else
						Alpha = math.Clamp( Alpha-10, 0, 255 )
					end
				
					draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
	
					surface.SetAlphaMultiplier( Alpha/255 )
					draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
					surface.SetAlphaMultiplier( 1 )
	
					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
					surface.SetMaterial( backMat )
					local iconSize = 24
					surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
				end
				backButton.DoClick = function()
					self.printerVGUI.printerPage:Remove()
				end

				local pageContent = vgui.Create( v.Element, self.printerVGUI.printerPage )
				pageContent:Dock( FILL )
				pageContent:DockMargin( 0, 12+75, 0, 0 )
				pageContent:FillPanel( self )

				self.printerVGUI.CreateCursor()
			end
		end

		self.printerVGUI.CreateCursor()
	end
end

function ENT:OnRemove()
	if( IsValid( self.printerVGUI ) ) then
		self.printerVGUI:Remove()
	end
end

function ENT:Draw()
	self:DrawModel()

	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	if( Distance >= BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then return end

	if( not IsValid( self.printerVGUI ) or refreshPanel ) then
		self:CreateVGUI()
		refreshPanel = false
	end

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	//TOP PANEL
	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), 270)
	Ang:RotateAroundAxis(Ang:Forward(), -5.6)

	vgui.Start3D2D( Pos+(Ang:Up() * 30.55)-(Ang:Forward()*11.35)-(Ang:Right()*45.03), Ang, 0.03/0.8 )
		self.printerVGUI:Paint3D2D()
	vgui.End3D2D()

	if( not self:HasRequestTimer() ) then
		self:CreateRequestTimer()
	end
end

function ENT:HasRequestTimer()
	return timer.Exists( tostring( self ) .. "_GangPrinterRequestTimer" )
end

function ENT:CreateRequestTimer()
	net.Start( "BRS.Net.GangPrinterIncomeTrackRequest" )
		net.WriteEntity( self )
	net.SendToServer()

	local timerID = tostring( self ) .. "_GangPrinterRequestTimer"
	timer.Create( timerID, (BRICKS_SERVER.CONFIG.GANGPRINTERS["Income Update Time"] or 10), 0, function()
		if( not IsValid( self ) or not IsValid( LocalPlayer() ) or LocalPlayer():GetPos():DistToSqr( self:GetPos() ) >= BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then 
			timer.Remove( timerID )
			return 
		end

		net.Start( "BRS.Net.GangPrinterIncomeTrackRequest" )
			net.WriteEntity( self )
		net.SendToServer()
	end )
end

net.Receive( "BRS.Net.GangPrinterIncomeTrackSend", function()
	local printerEntity = net.ReadEntity()

	if( not IsValid( printerEntity ) ) then return end

	printerEntity.IncomeTrackTable = net.ReadTable() or {}

	if( IsValid( printerEntity.printerVGUI  ) and printerEntity.printerVGUI.RefreshIncomeGraph ) then
		printerEntity.printerVGUI.RefreshIncomeGraph()
	end
end )