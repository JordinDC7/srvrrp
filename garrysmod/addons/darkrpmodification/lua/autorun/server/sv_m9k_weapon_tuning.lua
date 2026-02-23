if not SERVER then return end

local cvEnabled = CreateConVar("srvrrp_m9k_tuning_enabled", "1", FCVAR_ARCHIVE, "Enable server-side M9K weapon tuning.")
local cvDamageMult = CreateConVar("srvrrp_m9k_damage_mult", "1.08", FCVAR_ARCHIVE, "Damage multiplier applied to M9K weapons.")
local cvSpreadMult = CreateConVar("srvrrp_m9k_spread_mult", "0.82", FCVAR_ARCHIVE, "Spread multiplier applied to M9K weapons (lower is more accurate).")
local cvRecoilMult = CreateConVar("srvrrp_m9k_recoil_mult", "0.9", FCVAR_ARCHIVE, "Recoil multiplier applied to M9K weapons.")
-- Disabled by default: some M9K shotguns (notably SPAS-12 variants) can misbehave when
-- their bullet source is forcibly overridden server-side.
local cvMuzzleBullets = CreateConVar("srvrrp_m9k_muzzle_bullets", "0", FCVAR_ARCHIVE, "Fire M9K bullets from the weapon muzzle toward the crosshair.")

local function isM9KWeapon(wep)
    if not IsValid(wep) and type(wep) ~= "table" then return false end

    local class = wep.GetClass and wep:GetClass() or wep.ClassName
    if not isstring(class) then return false end

    if string.StartWith(string.lower(class), "m9k_") then
        return true
    end

    local base = wep.Base
    return isstring(base) and string.find(string.lower(base), "bobs_gun_base", 1, true) ~= nil
end

local function scalePrimaryValue(primary, key, multiplier, minValue)
    if not istable(primary) then return end

    local originalKey = "_srvrrp_original_" .. key
    local current = primary[key]

    if primary[originalKey] == nil and isnumber(current) then
        primary[originalKey] = current
    end

    local original = primary[originalKey]
    if not isnumber(original) then return end

    local updated = original * multiplier
    if minValue ~= nil then
        updated = math.max(minValue, updated)
    end

    primary[key] = updated
end

local function applyM9KTuningToSWEP(swep)
    if not cvEnabled:GetBool() or not isM9KWeapon(swep) then return end
    if not istable(swep.Primary) then return end

    scalePrimaryValue(swep.Primary, "Damage", cvDamageMult:GetFloat(), 1)
    scalePrimaryValue(swep.Primary, "Cone", cvSpreadMult:GetFloat(), 0)
    scalePrimaryValue(swep.Primary, "Spread", cvSpreadMult:GetFloat(), 0)
    scalePrimaryValue(swep.Primary, "KickUp", cvRecoilMult:GetFloat(), 0)
    scalePrimaryValue(swep.Primary, "KickDown", cvRecoilMult:GetFloat(), 0)
    scalePrimaryValue(swep.Primary, "KickHorizontal", cvRecoilMult:GetFloat(), 0)
    scalePrimaryValue(swep.Primary, "StaticRecoilFactor", cvRecoilMult:GetFloat(), 0)
    scalePrimaryValue(swep.Primary, "IronAccuracy", cvSpreadMult:GetFloat(), 0)
end

local function applyM9KTuning()
    for _, swep in ipairs(weapons.GetList()) do
        applyM9KTuningToSWEP(swep)
    end
end

hook.Add("InitPostEntity", "SrvRRP.M9K.ApplyTuning", function()
    timer.Simple(0, applyM9KTuning)
end)

hook.Add("OnReloaded", "SrvRRP.M9K.ApplyTuning.Reloaded", applyM9KTuning)

cvars.AddChangeCallback("srvrrp_m9k_tuning_enabled", function()
    timer.Simple(0, applyM9KTuning)
end, "SrvRRP.M9K.EnabledChanged")

cvars.AddChangeCallback("srvrrp_m9k_damage_mult", function()
    timer.Simple(0, applyM9KTuning)
end, "SrvRRP.M9K.DamageChanged")

cvars.AddChangeCallback("srvrrp_m9k_spread_mult", function()
    timer.Simple(0, applyM9KTuning)
end, "SrvRRP.M9K.SpreadChanged")

cvars.AddChangeCallback("srvrrp_m9k_recoil_mult", function()
    timer.Simple(0, applyM9KTuning)
end, "SrvRRP.M9K.RecoilChanged")

hook.Add("EntityFireBullets", "SrvRRP.M9K.MuzzleBulletSource", function(entity, data)
    if not cvEnabled:GetBool() or not cvMuzzleBullets:GetBool() then return end
    if not IsValid(entity) or not entity:IsPlayer() then return end
    if not istable(data) then return end

    local weapon = entity:GetActiveWeapon()
    if not IsValid(weapon) or not isM9KWeapon(weapon) then return end

    local attachmentId = weapon:LookupAttachment("muzzle") or 0
    if attachmentId <= 0 then
        attachmentId = 1
    end

    local attachment = weapon:GetAttachment(attachmentId)
    if not attachment or not attachment.Pos then return end

    local targetTrace = entity:GetEyeTraceNoCursor()
    if not targetTrace or not targetTrace.HitPos then return end

    local src = attachment.Pos
    if not isvector(src) then return end

    local direction = (targetTrace.HitPos - src)
    if direction:LengthSqr() <= 0.01 then return end

    data.Src = src
    data.Dir = direction:GetNormalized()
end)

hook.Add("EntityTakeDamage", "SrvRRP.M9K.ZeroDamageFallback", function(target, dmgInfo)
    if not cvEnabled:GetBool() then return end
    if not IsValid(target) then return end
    if not IsValid(dmgInfo) or dmgInfo:GetDamage() > 0 then return end
    if not dmgInfo:IsDamageType(DMG_BULLET) then return end

    local attacker = dmgInfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then return end

    local weapon = attacker:GetActiveWeapon()
    if not IsValid(weapon) or not isM9KWeapon(weapon) then return end

    local primary = weapon.Primary
    local fallbackDamage = istable(primary) and (primary.Damage or primary._srvrrp_original_Damage) or nil
    if not isnumber(fallbackDamage) then
        fallbackDamage = 1
    end

    dmgInfo:SetDamage(math.max(1, fallbackDamage))
end)
