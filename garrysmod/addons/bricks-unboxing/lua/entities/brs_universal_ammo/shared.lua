AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Universal Ammo (100 rounds)"
ENT.Category = "SmG RP"
ENT.Author = "SmG RP"
ENT.Spawnable = false
ENT.AdminSpawnable = false

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

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end

    function ENT:Use(activator, caller)
        if not IsValid(activator) or not activator:IsPlayer() then return end

        local weapons = activator:GetWeapons()
        local count = 0

        for _, wep in ipairs(weapons) do
            if not IsValid(wep) then continue end

            -- Fill clip
            local clipMax = wep:GetMaxClip1()
            if clipMax > 0 then
                wep:SetClip1(clipMax)
            end

            -- Add 100 reserve rounds
            local ammoType = wep:GetPrimaryAmmoType()
            if ammoType >= 0 then
                activator:GiveAmmo(AMMO_PER_BUY, ammoType, true)
                count = count + 1
            end

            -- Secondary
            local clipMax2 = wep:GetMaxClip2()
            if clipMax2 > 0 then
                wep:SetClip2(clipMax2)
            end
            local ammoType2 = wep:GetSecondaryAmmoType()
            if ammoType2 >= 0 then
                activator:GiveAmmo(AMMO_PER_BUY, ammoType2, true)
            end
        end

        if BRICKS_SERVER and BRICKS_SERVER.Func and BRICKS_SERVER.Func.SendNotification then
            BRICKS_SERVER.Func.SendNotification(activator, 1, 4, "+" .. AMMO_PER_BUY .. " rounds added to " .. count .. " weapons!")
        else
            activator:ChatPrint("+" .. AMMO_PER_BUY .. " rounds added to " .. count .. " weapons!")
        end

        self:Remove()
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
