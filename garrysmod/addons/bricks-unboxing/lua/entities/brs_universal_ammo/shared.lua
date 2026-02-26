AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Universal Ammo (100 rounds)"
ENT.Category = "SmG RP"
ENT.Author = "SmG RP"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
end

if SERVER then
    local AMMO_PER_BUY = 100

    function ENT:Initialize()
        self:SetModel("models/items/ammocrate_smg1.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetTrigger(true) -- enable Touch()

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end

    function ENT:GiveAmmoTo(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if self._used then return end
        self._used = true

        local weapons = ply:GetWeapons()
        local count = 0

        for _, wep in ipairs(weapons) do
            if not IsValid(wep) then continue end

            local clipMax = wep:GetMaxClip1()
            if clipMax > 0 then
                wep:SetClip1(clipMax)
            end

            local ammoType = wep:GetPrimaryAmmoType()
            if ammoType >= 0 then
                ply:GiveAmmo(AMMO_PER_BUY, ammoType, true)
                count = count + 1
            end

            local clipMax2 = wep:GetMaxClip2()
            if clipMax2 > 0 then
                wep:SetClip2(clipMax2)
            end
            local ammoType2 = wep:GetSecondaryAmmoType()
            if ammoType2 >= 0 then
                ply:GiveAmmo(AMMO_PER_BUY, ammoType2, true)
            end
        end

        if BRICKS_SERVER and BRICKS_SERVER.Func and BRICKS_SERVER.Func.SendNotification then
            BRICKS_SERVER.Func.SendNotification(ply, 1, 4, "+" .. AMMO_PER_BUY .. " rounds added to " .. count .. " weapons!")
        else
            ply:ChatPrint("+" .. AMMO_PER_BUY .. " rounds added to " .. count .. " weapons!")
        end

        self:Remove()
    end

    function ENT:Use(activator, caller)
        self:GiveAmmoTo(activator)
    end

    function ENT:Touch(ent)
        if IsValid(ent) and ent:IsPlayer() then
            self:GiveAmmoTo(ent)
        end
    end

    function ENT:StartTouch(ent)
        if IsValid(ent) and ent:IsPlayer() then
            self:GiveAmmoTo(ent)
        end
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local pos = self:GetPos() + Vector(0, 0, 20)
        local ang = (LocalPlayer():EyePos() - pos):Angle()
        ang:RotateAroundAxis(ang:Right(), -90)
        ang:RotateAroundAxis(ang:Up(), 180)

        cam.Start3D2D(pos, ang, 0.08)
            draw.SimpleTextOutlined("AMMO (100 rounds)", "DermaLarge", 0, 0, Color(255, 220, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
            draw.SimpleTextOutlined("Press E to use", "DermaDefault", 0, 30, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        cam.End3D2D()
    end
end
