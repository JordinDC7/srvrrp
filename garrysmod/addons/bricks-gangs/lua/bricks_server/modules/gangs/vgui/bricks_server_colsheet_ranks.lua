
local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

function PANEL:Init()
	self.Navigation = vgui.Create( "bricks_server_scrollpanel", self )
	self.Navigation:Dock( LEFT )
	self.Navigation:SetWidth( 200 )
	self.Navigation.Paint = function( self2, w, h )
		surface.SetAlphaMultiplier( 200/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
		surface.SetAlphaMultiplier( 1 )
	end

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}
end

function PANEL:UseButtonOnlyStyle()
	self.ButtonOnly = true
end

function PANEL:AddSheet( label, panel, color )

	if ( !IsValid( panel ) ) then return end

	local Sheet = {}
	Sheet.Button = vgui.Create( "DButton", self.Navigation )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( TOP )
	Sheet.Button:DockMargin( 5, 0, 5, 0 )
	Sheet.Button:SetText( "" )
	Sheet.Button:SetTall( 30 )
	local changeAlpha = 0
	Sheet.Button.Paint = function( self2, w, h )
		local backColor = (isfunction( color ) and color()) or color

		if( self2:IsDown() or self2.m_bSelected ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 50 )
		elseif( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 10 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 50 )
		end

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, backColor or BRICKS_SERVER.Func.GetTheme( 4 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( ((isfunction( label ) and label()) or label), "BRICKS_SERVER_Font20", 10, h/2, (backColor or BRICKS_SERVER.Func.GetTheme( 5 )), 0, TEXT_ALIGN_CENTER )
	end

	Sheet.Button.DoClick = function( self2 )
		if( not Sheet.Button.m_bSelected ) then
			changeAlpha = 0
		end

		self:SetActiveButton( Sheet.Button )
	end

	Sheet.Button.label = ((isfunction( label ) and label()) or label)

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetVisible( false )

	if ( self.ButtonOnly ) then
		Sheet.Button:SizeToContents()
	end

	table.insert( self.Items, Sheet )

	if ( !IsValid( self.ActiveButton ) ) then
		self:SetActiveButton( Sheet.Button )
	end
	
	return Sheet
end

function PANEL:Think()
	for k, v in pairs( self.Items ) do
		if( v.Think ) then
			v.Think()
		end
	end
end

function PANEL:SetActiveButton( active )
	if ( self.ActiveButton == active ) then return end

	if ( self.ActiveButton && self.ActiveButton.Target ) then
		local targetPanel = self.ActiveButton.Target
		targetPanel:SetVisible( false )
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
	active:SetSelected( true )
	active:SetToggle( true )

	if( active.onLoad ) then
		active.onLoad()
	end

	self.Content:InvalidateLayout()
end

function PANEL:SetActiveSheet( sheetLabel )
	if( not sheetLabel ) then return end

	for k, v in pairs( self.Items ) do
		if( v.Button and v.Button.label and v.Button.label == sheetLabel ) then
			self:SetActiveButton( v.Button )
			break
		end
	end
end

function PANEL:ClearSheets()
	self.Items = {}
	self.Navigation:Clear()
	self.Content:Clear()
end

derma.DefineControl( "bricks_server_colsheet_ranks", "", PANEL, "Panel" )
