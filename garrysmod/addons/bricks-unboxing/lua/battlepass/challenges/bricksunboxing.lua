local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName( "Cases unboxed" )
CHALLENGE:SetIcon( "battlepass/challenges/ammo.png" )
CHALLENGE:SetProgressDesc( "Unbox :goal more crates" )
CHALLENGE:SetFinishedDesc( "Unboxed:goal crates" )
CHALLENGE:SetID( "bricksunboxing" )
CHALLENGE:AddHook( "BRS_CaseUnboxed", function(self, ply, _ply, amount)
    if( IsValid( _ply ) and ply == _ply ) then
        self:AddProgress(amount or 1)
        self:NetworkProgress()
    end
end )
BATTLEPASS:RegisterChallenge(CHALLENGE)