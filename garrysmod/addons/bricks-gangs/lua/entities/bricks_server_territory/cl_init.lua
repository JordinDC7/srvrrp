include('shared.lua')

function ENT:Initialize()
	self.flagMaterial = CreateMaterial( "brs_flag_material_entid" .. self:EntIndex(), "UnlitGeneric", {} )
	self.flagRenderTarget = GetRenderTarget( "brs_flag_rendertarget_entid" .. self:EntIndex(), 1004, 704, false )

	self.flagMaterial:SetTexture( "$basetexture", self.flagRenderTarget )
end

local iconMat
local iconRequested = false
function ENT:Draw()
	self:DrawModel()

    local position = self:GetPos()
    local angles = self:GetAngles()

	angles:RotateAroundAxis( angles:Forward(), 90)

	angles.y = LocalPlayer():EyeAngles().y - 90

	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	local w, h = 200, 50
	local x, y = 25, 0

	local territoryKey = self:GetTerritoryKey()
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )

	if( not territoryTable ) then return end
	
	local territoryConfig = BRICKS_SERVER.CONFIG.GANGS.Territories[territoryKey] or {}
	local territoryGangTable = (BRICKS_SERVER_GANGS or {})[(territoryTable or {}).GangID or 0] or {}

	if( Distance < BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then
		surface.SetAlphaMultiplier( math.Clamp( 1-(Distance/BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"]), 0, 1 ) )
		cam.Start3D2D( self:GetPos()+self:GetUp()*55, angles, 0.1 )
			draw.RoundedBox( 5, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

			local capturePercent = (territoryTable.Claimed and 1) or 0

			if( IsValid( self:GetCaptor() ) ) then
				if( (self:GetCaptureEndTime() or 0) > 0 ) then
					capturePercent = math.Clamp( (BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]-(self:GetCaptureEndTime()-CurTime()))/BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"], 0, 1 )
				else
					capturePercent = math.Clamp( 1-((BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]-(self:GetUnCaptureEndTime()-CurTime()))/BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]), 0, 1 )
				end
			end

			local border = 5
			draw.RoundedBox( 5, x+border, y+border, (w-2*border)*capturePercent, h-(2*border), territoryConfig.Color or BRICKS_SERVER.Func.GetTheme( 5 ) )
		cam.End3D2D()

		local bottomW, bottomH, iconSize = 240, 310, 64
		local bottomX, bottomY = -(bottomW/2), 0

		local function drawBottomInfo()
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
			surface.DrawRect( bottomX, bottomY, bottomW, bottomH )
			draw.SimpleText( territoryConfig.Name, "BRICKS_SERVER_Font40", bottomX+bottomW/2, 65, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( BRICKS_SERVER.Func.L( "gangTerritoryUpper" ), "BRICKS_SERVER_Font25", bottomX+bottomW/2, 65, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )

			if( territoryTable.Claimed ) then
				draw.SimpleText( BRICKS_SERVER.Func.L( "gangCaptured" ), "BRICKS_SERVER_Font20", bottomX+bottomW/2, bottomY+(bottomH/2)-(iconSize/2)+25-5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

				if( territoryTable.IconMat ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( territoryTable.IconMat )
					surface.DrawTexturedRect( bottomX+(bottomW/2)-(iconSize/2), bottomY+(bottomH/2)-(iconSize/2)+25, iconSize, iconSize )
				else
					BRICKS_SERVER.Func.RequestTerritoryIconMat( territoryKey )
				end

				draw.SimpleText( (territoryGangTable.Name or BRICKS_SERVER.Func.L( "nil" )), "BRICKS_SERVER_Font25", bottomX+bottomW/2, bottomY+(bottomH/2)+(iconSize/2)+25+5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
			end
		end

		local angles = self:GetAngles()
		angles:RotateAroundAxis( angles:Forward(), 90)

		cam.Start3D2D( self:GetPos()+self:GetUp()*17.4+self:GetRight()*12.8, angles, 0.05 )
			drawBottomInfo()
		cam.End3D2D()

		angles:RotateAroundAxis( angles:Right(), 90)

		cam.Start3D2D( self:GetPos()+self:GetUp()*17.4-self:GetForward()*12.8, angles, 0.05 )
			drawBottomInfo()
		cam.End3D2D()
		
		angles:RotateAroundAxis( angles:Right(), 90)

		cam.Start3D2D( self:GetPos()+self:GetUp()*17.4-self:GetRight()*12.8, angles, 0.05 )
			drawBottomInfo()
		cam.End3D2D()

		angles:RotateAroundAxis( angles:Right(), 90)

		cam.Start3D2D( self:GetPos()+self:GetUp()*17.4+self:GetForward()*12.8, angles, 0.05 )
			drawBottomInfo()
		cam.End3D2D()
		surface.SetAlphaMultiplier( 1 )

		-- Draw flag color and logo
		local w, h, iconSize = 1004, 704, 400
		render.PushRenderTarget( self.flagRenderTarget )
			render.Clear( 0, 0, 0, 0, true, true ) 
			cam.Start2D()
				surface.SetDrawColor( territoryConfig.Color or BRICKS_SERVER.Func.GetTheme( 5 ) )
				surface.DrawRect( 0, 0, w, h )

				if( territoryTable.Claimed ) then
					if( territoryTable.IconMat ) then
						surface.SetDrawColor( 255, 255, 255, 255 )
						surface.SetMaterial( territoryTable.IconMat )
						surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
					else
						BRICKS_SERVER.Func.RequestTerritoryIconMat( territoryKey )
					end
				end
			cam.End2D()
		render.PopRenderTarget()
		
		self:SetSubMaterial( 2, "!brs_flag_material_entid" .. self:EntIndex() )
	end
end