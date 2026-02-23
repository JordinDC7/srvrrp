/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

ENT.Type                    = "anim"
ENT.Base                    = "base_anim"
ENT.AutomaticFrameAdvance   = false
ENT.PrintName               = "Generator"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros GrowOP 2"
ENT.Spawnable               = true
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_growop2/zgo2_generator.mdl"
ENT.RenderGroup             = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c5b22d0c464981a2a2cb55407ea8523b955c581541c9aaa45b7d50e2253186c

// How much fuel can it hold
ENT.Capacity = 2000

// How much power does it produce per second
ENT.PowerRate = 3


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Fuel")
	self:NetworkVar("Int", 1, "Power")
	self:NetworkVar("Bool", 1, "TurnedOn")

	self:NetworkVar("Int", 2, "GeneratorID")

	if SERVER then
		self:SetGeneratorID(1)
		self:SetFuel(0)
		self:SetPower(0)
		self:SetTurnedOn(false)
	end
end

function ENT:CanProperty(ply)
    return ply:IsSuperAdmin()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c98d49b320af02372d954ba403147b52446efe45185e82d35620a577545ff88

function ENT:CanTool(ply, tab, str)
    return ply:IsSuperAdmin()
end

function ENT:CanDrive(ply)
    return false
end

local lsw_vec = Vector(7.5,0,-10)
function ENT:OnSwitch(ply)
    local trace = ply:GetEyeTrace()

	local dat = zgo2.Generator.GetData(self:GetGeneratorID())
	if not dat then return end

	local pos = dat.UIPos.vec + lsw_vec
	//debugoverlay.Sphere(self:LocalToWorld(pos),1,0.1,Color( 0, 255, 0 ),true)
    if zclib.util.InDistance(self:LocalToWorld(pos), trace.HitPos, 6) then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

local lsw_vec01 = Vector(-7.5,0,-10)
function ENT:OnConnect(ply)
    local trace = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

	local dat = zgo2.Generator.GetData(self:GetGeneratorID())
	if not dat then return end

	local pos = dat.UIPos.vec + lsw_vec01
	//debugoverlay.Sphere(self:LocalToWorld(pos),1,0.1,Color( 0, 255, 0 ),true)

    if zclib.util.InDistance(self:LocalToWorld(pos), trace.HitPos, 6) then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2
