/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

ENT.Type                    = "anim"
ENT.Base                    = "base_anim"
ENT.AutomaticFrameAdvance   = true
ENT.PrintName               = "Mixer"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros GrowOP 2"
ENT.Spawnable               = true
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_growop2/zgo2_mixer.mdl"
ENT.RenderGroup             = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "HasBowl")
    self:NetworkVar("Bool", 1, "HasDough")

    self:NetworkVar("Int", 0, "WeedID")
    self:NetworkVar("Int", 1, "WeedAmount")
    self:NetworkVar("Int", 2, "WeedTHC")

    // 0 = idle, 1 = open , 2 = close , 3 = run
    self:NetworkVar("Int", 3, "WorkState")

	self:NetworkVar("Int", 4, "EdibleID")

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c98d49b320af02372d954ba403147b52446efe45185e82d35620a577545ff88

    if (SERVER) then
		self:SetEdibleID(0)

        self:SetWorkState(0)
        self:SetHasBowl(true)
        self:SetHasDough(false)

        self:SetWeedID(-1)
        self:SetWeedAmount(0)
        self:SetWeedTHC(0)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c98d49b320af02372d954ba403147b52446efe45185e82d35620a577545ff88
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

function ENT:OnRemoveButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

    if lp.x > -12 and lp.x < 4 and lp.y < 12 and lp.y > 11 and lp.z > 9 and lp.z < 20 then
        return true
    else
        return false
    end
end
