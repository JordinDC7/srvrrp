/*
    Addon id: 64edeaec-8955-454a-aac4-1d19d72ee4af
    Version: v1.6.5 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function ENT:Initialize()
	zgo2.Dryline.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c98d49b320af02372d954ba403147b52446efe45185e82d35620a577545ff88

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	zgo2.Dryline.OnThink(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

function ENT:OnRemove()
	zgo2.Dryline.OnRemove(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d95ede022471e32e4a4b21a5ceaeb1f2c170bb22540bb623b92f31411b4103f1
