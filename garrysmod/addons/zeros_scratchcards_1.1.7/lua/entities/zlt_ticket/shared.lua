ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_lottery/ticket.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Ticket"
ENT.Category = "Zeros Scratchcards"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("String", 1, "TicketID")
    self:NetworkVar("Int", 2, "PrizeID")

    if (SERVER) then
        self:SetTicketID(1)
        self:SetPrizeID(1)
    end
end

function ENT:CanProperty(ply)
    return ply:IsSuperAdmin()
end

function ENT:CanTool(ply, tab, str)
    return ply:IsSuperAdmin()
end

function ENT:CanDrive(ply)
    return ply:IsSuperAdmin()
end
