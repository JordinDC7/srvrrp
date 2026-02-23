local alreadySetKeysPrinters = {
    ["bodycolor"] = true,
    ["price"] = true,
    ["customCheck"] = true,
    ["failmsg"] = true,
    ["max"] = true,
    ["allowed"] = true
}

local customKeysRack = {
    ["bodycolor"] = true,
    ["godmode"] = true,
    ["water_affect"] = true
}

sPrinter.loadDarkRPContent = function()
    for k, v in ipairs(sPrinter.config["drp_categories"] or {}) do
        DarkRP.createCategory{ 
            name = v.name,
            categorises = "entities",
            startExpanded = true,
            color = v.color,
            canSee = v.canSee or function(ply) return false end,
            sortOrder = v.sortOrder
        }
    end

    if !sPrinter.config["rack"]["disabled"] then
        local rack_ent = {
            ent = "sprinter_rack",
            model = "models/stromic/rack.mdl",
            max = sPrinter.config["rack"]["max"] or 1,
            category = sPrinter.config["rack"]["category"] or (sPrinter.config["drp_categories"] and sPrinter.config["drp_categories"][1] and sPrinter.config["drp_categories"][1].name) or "Printers",
            cmd = "buy_spprinter_rack",
        }

        for k,v in pairs(sPrinter.config["rack"]) do
            if customKeysRack[k] then continue end

            rack_ent[k] = v
        end

        DarkRP.createEntity(slib.getLang("sprinter", sPrinter.config["language"], "rack"), rack_ent)
    end

    for name, data in SortedPairsByMemberValue(sPrinter.config.printers, "sortorder") do
        local ENT = {}
        
        ENT.Base = "sprinter_base"
        ENT.Category = "sPrinter"
        ENT.PrintName = name
        ENT.Author = "Stromic"
        ENT.Spawnable = true
        ENT.name = name
        ENT.data = data
        
        local classstring = string.lower(string.gsub(name, " ", "_"))
        local classname = "sprinter_"..classstring
        scripted_ents.Register( ENT, classname)

        if SERVER then
            function ENT:PostInit()
                if data.bodycolor then
                    self:SetColor(data.bodycolor)
                end
            end
        end

        local entData = {
            ent = classname,
            model = "models/stromic/money_printer.mdl",
            price = data.price,
            category = data.category or (sPrinter.config["drp_categories"] and sPrinter.config["drp_categories"][1] and sPrinter.config["drp_categories"][1].name) or "Printers",
            customCheck = data.customCheck and data.customCheck or data.usergroup and function(ply) return CLIENT or data.usergroup[ply:GetUserGroup()] end or nil,
            CustomCheckFailMsg = data.failmsg and data.failmsg or nil,
            max = data.max or 1,
            allowed = data.allowed and data.allowed or nil,
            cmd = "buy_sp"..classstring
        }

        for k,v in pairs(data) do
            if alreadySetKeysPrinters[k] then continue end

            entData[k] = v
        end

        DarkRP.createEntity(name, entData)
    end
end

local SWEP = {Primary = {}, Secondary = {}}

if CLIENT then
    SWEP.PrintName = slib.getLang("sprinter", sPrinter.config["language"], "swep-name")
    SWEP.Slot = 4
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = true
    SWEP.Instructions = slib.getLang("sprinter", sPrinter.config["language"], "swep-instructions")   
end

SWEP.Author = "Stromic"
SWEP.Category = "sPrinter"
SWEP.WorldModel	= ""

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.PrimaryAttack = function() end
SWEP.SecondaryAttack = function() end

SWEP.PreDrawViewModel = function() return true end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

if SERVER then
    local items = {}

    local function unholsterPrinter(swep, printer, key)
        local posBase = IsValid(swep.Owner) and swep.Owner or swep

        if posBase:IsPlayer() then
            local trace = {}
            trace.start = posBase:EyePos()
            trace.endpos = trace.start + posBase:GetAimVector() * 85
            trace.filter = posBase

            local tr = util.TraceLine(trace)

            posBase = tr.HitPos
        else
            local posBase = posBase:GetPos()
            posBase.z = posBase.z + (20 * key)
        end

        printer:SetCollisionGroup(0)
        printer:SetNoDraw(false)
        printer:SetPos(posBase)

        local phys = printer:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(true)
            phys:Wake()
        end

        items[swep][key] = nil
    end

    function SWEP:PrimaryAttack()
        self:SetNextPrimaryFire(CurTime() + 0.5)
        local owner = self.Owner

        if !IsValid(owner) then return end

        items[self] = items[self] or {}
        
        local printerCount = 0

        for k,v in ipairs(items[self]) do
            if !IsValid(v) then continue end
            printerCount = printerCount + 1
        end
        
        local max = isnumber(sPrinter.config["max_printer_bag"]) and sPrinter.config["max_printer_bag"] or sPrinter.config["max_printer_bag"][owner:GetUserGroup()] or sPrinter.config["max_printer_bag"]["default"]

        if printerCount >= max then
            slib.notify(sPrinter.config["prefix"]..slib.getLang("sprinter", sPrinter.config["language"], "full-printer-bag"), owner)
        return end

        local trace = owner:GetEyeTrace()
        local ent = trace.Entity

        if !IsValid(ent) or ent:GetPos():DistToSqr(owner:GetPos()) > 10000 or ent.Base ~= "sprinter_base" then return end
        if IsValid(ent:GetRack()) then ent:Eject() end

        items[self][#items[self] + 1] = ent

        ent:SetCollisionGroup(10)
        ent:SetNoDraw(true)
        ent:SetPos(Vector(0,0,999))
        ent:Power(false)

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end

    function SWEP:SecondaryAttack()
        self:SetNextSecondaryFire(CurTime() + 0.5)

        if !items[self] or table.IsEmpty(items[self]) then return end

        for i = table.Count(items[self]), 0, -1 do
            local printer = items[self][i]
            if !IsValid(printer) then continue end
            unholsterPrinter(self, printer, i)
            break
        end
    end

    function SWEP:OnRemove()
        if !items[self] or table.IsEmpty(items[self]) then return end
        for i = 1, table.Count(items[self]) do
            local printer = items[self][i]
            if !IsValid(printer) then continue end
            unholsterPrinter(self, printer, i)
        end
    end
end
    
weapons.Register( SWEP, "sprinter_bag" )