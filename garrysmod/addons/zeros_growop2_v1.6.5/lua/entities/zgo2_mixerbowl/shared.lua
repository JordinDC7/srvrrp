/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

ENT.Type                    = "anim"
ENT.Base                    = "base_anim"
ENT.AutomaticFrameAdvance   = true
ENT.PrintName               = "Mixer Bowl"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros GrowOP 2"
ENT.Spawnable               = false
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_growop2/zgo2_mixerbowl.mdl"
ENT.RenderGroup             = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()

	self:NetworkVar("Int", 4, "EdibleID")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2

    self:NetworkVar("Int", 0, "WeedID")
    self:NetworkVar("Int", 1, "WeedAmount")
    self:NetworkVar("Int", 2, "WeedTHC")

    if (SERVER) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275

		self:SetEdibleID(0)
        self:SetWeedID(0)

        self:SetWeedAmount(0)
        self:SetWeedTHC(0)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c98d49b320af02372d954ba403147b52446efe45185e82d35620a577545ff88
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d95ede022471e32e4a4b21a5ceaeb1f2c170bb22540bb623b92f31411b4103f1

function ENT:OnRemoveButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -12 and lp.x < 4 and lp.y < 12 and lp.y > 11 and lp.z > 9 and lp.z < 20 then
        return true
    else
        return false
    end
end
