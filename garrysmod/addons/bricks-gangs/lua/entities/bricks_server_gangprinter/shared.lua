
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Gang Printer"
ENT.Category		= "Brick's Gangs"
ENT.Author			= "Brickwall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true
ENT.IncomeTrackAmount = 10

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Holding" )

	if( SERVER ) then
		self:NetworkVarNotify( "Holding", function( entity, name, old, new )
			if( #entity.IncomeTrackTable >= entity.IncomeTrackAmount ) then
				table.remove( entity.IncomeTrackTable, 1 )
			end

			table.insert( entity.IncomeTrackTable, new )
		end )
	end

	self:NetworkVar( "Int", 1, "HoldingEXP" )
	self:NetworkVar( "Int", 2, "Temperature" )
	self:NetworkVar( "Int", 3, "NextPrint" )

	self:NetworkVar( "Int", 4, "GangID" )
	self:NetworkVar( "Int", 5, "PrinterID" )
	self:NetworkVar( "Int", 6, "Servers" )

	self:NetworkVar( "Bool", 0, "Status" )
	self:NetworkVar( "Bool", 1, "Overheated" )
end

function ENT:GetPrintAmount()
	local printerConfigTable = BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[self:GetPrinterID()]

	if( not printerConfigTable ) then return 100 end

	local printAmount = 0
	for i = 1, self:GetServers() do
		local amountUpgradeTier = ((BRICKS_SERVER.CONFIG.GANGPRINTERS.ServerUpgrades["Amount"] or {}).Tiers or {})[self:GetNW2Int( "AmountServer" .. i, 0 )] or {}
		local multiplier = 1+((amountUpgradeTier.ReqInfo or {})[1] or 0)/100

		printAmount = printAmount+((printerConfigTable.ServerAmount or 0)*multiplier)
	end

	return printAmount
end

function ENT:GetTargetTemp()
	local printerConfigTable = BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[self:GetPrinterID()]

	if( not printerConfigTable ) then return 0 end

	local targetTemp = 0
	for i = 1, self:GetServers() do
		local amountUpgradeTier = ((BRICKS_SERVER.CONFIG.GANGPRINTERS.ServerUpgrades["Cooling"] or {}).Tiers or {})[self:GetNW2Int( "CoolingServer" .. i, 0 )] or {}
		local multiplier = 1-((amountUpgradeTier.ReqInfo or {})[1] or 0)/100

		targetTemp = targetTemp+((printerConfigTable.ServerHeat or 0)*multiplier)
	end

	return targetTemp
end

function ENT:GetPrintTime()
	local printerConfigTable = BRICKS_SERVER.CONFIG.GANGPRINTERS.Printers[self:GetPrinterID()]

	if( not printerConfigTable ) then return 1 end

	local printTime = 0
	for i = 1, self:GetServers() do
		local amountUpgradeTier = ((BRICKS_SERVER.CONFIG.GANGPRINTERS.ServerUpgrades["Speed"] or {}).Tiers or {})[self:GetNW2Int( "SpeedServer" .. i, 0 )] or {}
		local multiplier = math.Clamp( (1-((i-1)*BRICKS_SERVER.DEVCONFIG.GangPrinterServerTime))-((amountUpgradeTier.ReqInfo or {})[1] or 0)/100, 0, 1 )

		printTime = printTime+((printerConfigTable.ServerTime or 0)*multiplier)
	end

	return printTime
end

function ENT:GetTotalHealth()
	local health = BRICKS_SERVER.CONFIG.GANGPRINTERS["Base Printer Health"]

	local healthTier = BRICKS_SERVER.CONFIG.GANGPRINTERS.Upgrades["Health"].Tiers[self:GetNW2Int( "HealthUpgrade", 0 )]
	if( healthTier ) then
		health = health*(1+(healthTier.ReqInfo[1]/100))
	end

	return health
end