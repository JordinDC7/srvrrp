/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

ENT.Type                    = "anim"
ENT.Base                    = "base_anim"
ENT.AutomaticFrameAdvance   = false
ENT.PrintName               = "Joint"
ENT.Author                  = "ZeroChain"
ENT.Category                = "Zeros GrowOP 2"
ENT.Spawnable               = false
ENT.AdminSpawnable          = false
ENT.Model                   = "models/zerochain/props_growop2/zgo2_joint.mdl"
ENT.RenderGroup             = RENDERGROUP_OPAQUE


function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "WeedID")
    self:NetworkVar("Int", 2, "WeedTHC")
    self:NetworkVar("Int", 3, "WeedAmount")
    self:NetworkVar("Bool", 0, "IsBurning")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- b37a8fb28504eb62d58d3884879faeab205c3ee35b0aaa5ae62e13952d407275
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c5b22d0c464981a2a2cb55407ea8523b955c581541c9aaa45b7d50e2253186c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d95ede022471e32e4a4b21a5ceaeb1f2c170bb22540bb623b92f31411b4103f1

    if (SERVER) then
        self:SetWeedID(-1)
        self:SetWeedTHC(-1)
        self:SetWeedAmount(0)
        self:SetIsBurning(false)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 256faf0bb74efb046ebcf0963ed53c37af5e1a016331265ffe11ff7e2eac93a2
