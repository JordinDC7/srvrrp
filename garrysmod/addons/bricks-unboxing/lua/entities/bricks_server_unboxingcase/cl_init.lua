include("shared.lua")

function ENT:Initialize()

end

local loadingIcon = Material( "materials/bricks_server/loading.png" )
function ENT:Draw()
	self:DrawModel()

	if( LocalPlayer():GetPos():DistToSqr( self:GetPos() ) >= BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then return end

	local configItemTable = BRICKS_SERVER.CONFIG.UNBOXING.Cases[self:GetCaseKey()]

	local iconMat
	if( configItemTable and configItemTable.ModelIcon and not iconMat ) then
        BRICKS_SERVER.Func.GetImage( configItemTable.ModelIcon, function( mat ) iconMat = mat end )
	end

	local selfAngles = self:GetAngles()

	selfAngles:RotateAroundAxis( selfAngles:Forward(), 90 )
	selfAngles:RotateAroundAxis( selfAngles:Right(), 270 )

	local w, h = 100, 100
	local x, y =  -(w/2), 0
	cam.Start3D2D( self:GetPos()+(selfAngles:Up()*9.78)-(selfAngles:Right()*13), selfAngles, 0.1 )
		if( configItemTable and configItemTable.ModelIcon ) then
			if( iconMat ) then
				local iconSize = w
				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
				surface.SetMaterial( iconMat )
				surface.DrawTexturedRect( x+(w/2)-(iconSize/2), y+(h/2)-(iconSize/2), iconSize, iconSize )
			else
				local iconSize = 32
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( loadingIcon )
				surface.DrawTexturedRectRotated( x+(w/2), y+(h/2), iconSize, iconSize, -(CurTime() % 360 * 250) )
			end
		end
	cam.End3D2D()
end

function ENT:Think()
	if( self:GetCaseSet() and CurTime() >= (self:GetCaseAnimTime() or 0) ) then
		local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( self:GetWinningItemKey() )
	
		if( not configItemTable ) then return end

		if( not IsValid( self.winningItemEnt ) and configItemTable.Model ) then
			self.winningItemEnt = ClientsideModel( configItemTable.Model )
			
			if( IsValid( self.winningItemEnt ) ) then
				if( string.StartWith( self:GetWinningItemKey(), "ITEM_" ) ) then
					local devConfigTable = BRICKS_SERVER.DEVCONFIG.UnboxingItemTypes[configItemTable.Type or ""]
					if( devConfigTable and devConfigTable.ModelDisplay ) then devConfigTable.ModelDisplay( self.winningItemEnt, configItemTable.ReqInfo ) end
				end

				if( not BRICKS_SERVER.CONFIG.UNBOXING["Disable Item Halos"] and configItemTable.Rarity ) then
					if( not BRICKS_SERVER.TEMP.UnboxRewardEnts[configItemTable.Rarity] ) then
						BRICKS_SERVER.TEMP.UnboxRewardEnts[configItemTable.Rarity] = {}
					end

					table.insert( BRICKS_SERVER.TEMP.UnboxRewardEnts[configItemTable.Rarity], self.winningItemEnt )
				end
			end
		end

		if( IsValid( self.winningItemEnt ) ) then
			local itemAnimPercent = math.Clamp( (CurTime()-self:GetCaseAnimTime())/self.WinningItemDuration, 0, 1 )
			self.winningItemEnt:SetPos( self:GetPos()+self:GetUp()*(10+(20*itemAnimPercent)) )
			self.winningItemEnt:SetAngles( self:GetAngles()+Angle( 0, 90, 0 ) )
		end
	end
end

function ENT:OnRemove()
	if( IsValid( self.winningItemEnt ) ) then
		self.winningItemEnt:Remove()
	end
end

local whiteVector = Vector( 1, 1, 1 )
matproxy.Add({
    name = "CaseColor", 
    init = function( self, mat, values )
    	self.ResultTo = values.resultvar
    end,
	bind = function( self, mat, ent )
		local caseColor = IsValid( ent ) and ent:GetNWVector( "CaseColor", whiteVector ) or whiteVector
		mat:SetVector( self.ResultTo, caseColor )
   end 
})

matproxy.Add({
    name = "KeyColor", 
    init = function( self, mat, values )
    	self.ResultTo = values.resultvar
    end,
	bind = function( self, mat, ent )
		local keyColor = IsValid( ent ) and ent:GetNWVector( "KeyColor", whiteVector ) or whiteVector
		mat:SetVector( self.ResultTo, keyColor )
   end 
})

local originalMat = Material( "materials/sterling/brickwall_lootbox_logo" )
matproxy.Add({
    name = "CaseLogo", 
    init = function( self, mat, values )
    	self.ResultTo = values.resultvar
    end,
	bind = function( self, mat, ent )
		if( ent.CaseLogo ) then
			mat:SetTexture( self.ResultTo, ent.CaseLogo:GetTexture( "$basetexture" ) )
		else
			mat:SetTexture( self.ResultTo, originalMat:GetTexture( "$basetexture" ) )
		end
   end 
})