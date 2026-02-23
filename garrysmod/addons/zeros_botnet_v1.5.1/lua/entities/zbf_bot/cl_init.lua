/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e

function ENT:Initialize()
    zbf.Bot.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function ENT:Draw()
    zbf.Bot.OnDraw(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

function ENT:OnRemove()
    zbf.Bot.OnRemove(self)
end

function ENT:Think()
    zbf.Bot.OnThink(self)
    self:SetNextClientThink(CurTime())
    return true
end
