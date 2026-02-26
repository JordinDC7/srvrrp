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
    local PICKUP_RADIUS = 64  -- units, roughly player width

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

        self._nextPickupCheck = 0
    end

    function ENT:GiveAmmoTo(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return false end
        if self._used then return false end
        self._used = true

        local weapons = ply:GetWeapons()
        local count = 0
        local givenTypes = {}

        for _, wep in ipairs(weapons) do
            if not IsValid(wep) then continue end

            -- Fill magazine
            local clipMax = wep:GetMaxClip1()
            if clipMax > 0 then
                wep:SetClip1(clipMax)
            end

            -- Give reserve ammo (false = show HUD pickup popup)
            local ammoType = wep:GetPrimaryAmmoType()
            if ammoType >= 0 then
                local ammoName = game.GetAmmoName(ammoType)
                if ammoName and not givenTypes[ammoName] then
                    ply:GiveAmmo(AMMO_PER_BUY, ammoName, false)
                    givenTypes[ammoName] = true
                    count = count + 1
                end
            end

            -- Secondary ammo too
            local clipMax2 = wep:GetMaxClip2()
            if clipMax2 > 0 then
                wep:SetClip2(clipMax2)
            end
            local ammoType2 = wep:GetSecondaryAmmoType()
            if ammoType2 >= 0 then
                local ammoName2 = game.GetAmmoName(ammoType2)
                if ammoName2 and not givenTypes[ammoName2] then
                    ply:GiveAmmo(AMMO_PER_BUY, ammoName2, false)
                    givenTypes[ammoName2] = true
                end
            end
        end

        if count > 0 then
            if BRICKS_SERVER and BRICKS_SERVER.Func and BRICKS_SERVER.Func.SendNotification then
                BRICKS_SERVER.Func.SendNotification(ply, 1, 4, "+" .. AMMO_PER_BUY .. " rounds - all magazines refilled!")
            else
                ply:ChatPrint("+" .. AMMO_PER_BUY .. " rounds - all magazines refilled!")
            end
        else
            ply:ChatPrint("No weapons to give ammo to!")
        end

        self:Remove()
        return true
    end

    -- Press E to pick up
    function ENT:Use(activator, caller)
        self:GiveAmmoTo(activator)
    end

    -- Proximity auto-pickup (most reliable method for DarkRP)
    function ENT:Think()
        if self._used then return end

        local ct = CurTime()
        if ct < self._nextPickupCheck then return end
        self._nextPickupCheck = ct + 0.15  -- check ~7x/sec

        local pos = self:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() and ply:GetPos():DistToSqr(pos) < PICKUP_RADIUS * PICKUP_RADIUS then
                if self:GiveAmmoTo(ply) then return end
            end
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
            draw.SimpleTextOutlined("Walk over or press E", "DermaDefault", 0, 30, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        cam.End3D2D()
    end
end
