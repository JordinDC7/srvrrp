/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Rack = zbf.Rack or {}
zbf.Rack.List = zbf.Rack.List or {}

function zbf.Rack.Initialize(Rack)
	zclib.Debug("zbf.Rack.Initialize")

	Rack:PrecacheGibs()

	if zbf.config.Damageable["zbf_rack"] >  0 then
		Rack:SetHealth(zbf.config.Damageable["zbf_rack"])
		Rack:SetMaxHealth(zbf.config.Damageable["zbf_rack"])
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

	table.insert(zbf.Rack.List,Rack)

	zbf.Rack.SetupSpots(Rack)
end

function zbf.Rack.SetupSpots(Rack)
    zclib.Debug("zbf.Rack.SetupSpots")
    Rack.Spots = {}

    local count = 0
    local side,up,front = 0,0,0

    local w,h = 12.5,17.5
    local wSize = w * 6

    for i = 1,20 do
        if count >= 5 then
            count = 0
            up = up + h
            side = 0
            front = front - 1.6
        end
        side = side + w

        local aPos = Vector(11.1 + front,side - (wSize / 2),up + 16.5)
        Rack.Spots[i] = {
            ent = nil,
            pos = aPos
        }
        //debugoverlay.Sphere( Rack:LocalToWorld(aPos), 1,4,Color( 255, 255, 255 ), false )
        count = count + 1
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

/*
	This function is obsolete since we automaticly connect now the Bots when buying them
	For now i just keep it since some admins might wanna set it so up that they players buy the bots from the F4 menu
*/
function zbf.Rack.OnTouch(Rack, other)
	if not IsValid(Rack) then return end
	if not IsValid(other) then return end
	if other:GetClass() ~= "zbf_bot" then return end
	if zclib.util.CollisionCooldown(other) then return end
	if other.SkipCollision then return end
	if not zclib.Player.SharedOwner(Rack,other) then return end
	zbf.Rack.AddBot(Rack, other)
end

function zbf.Rack.AddBot(Rack, bot)
	local key = zbf.Rack.GetFreeSpot(Rack)
	if key == nil then return end
	zbf.Rack.AddBotAtID(Rack, bot, key)
end

function zbf.Rack.AddBotAtID(Rack, bot, key)
	if not IsValid(Rack) then return end
	if not IsValid(bot) then return end
	if not key then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	bot.PhysgunDisabled = true
	bot.SkipCollision = true

	if Rack.Spots == nil then Rack.Spots = {} end
	if Rack.Spots[ key ] == nil then Rack.Spots[ key ] = {} end
	Rack.Spots[ key ].ent = bot

	timer.Simple(0.1, function()
		if not IsValid(Rack) then return end
		if not IsValid(bot) then return end
		DropEntityIfHeld(bot)
		bot:SetPos(Rack:LocalToWorld(Rack.Spots[ key ].pos))
		bot:SetAngles(Rack:LocalToWorldAngles(Angle(-5, 0, 0)))
		bot:SetParent(Rack)
		bot.RackID = key
		bot:SetMoveType(MOVETYPE_NONE)
		bot:PhysicsDestroy()
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

function zbf.Rack.GetFreeSpot(Rack)
	local key

	for k, v in ipairs(Rack.Spots) do
		if v and not IsValid(v.ent) then
			key = k
			break
		end
	end

	return key
end

function zbf.Rack.HasBots(Rack)
	local key

	for k, v in ipairs(Rack.Spots) do
		if v and IsValid(v.ent) then
			key = k
			break
		end
	end

	return key
end

function zbf.Rack.Destroy(Rack)
	if Rack.Destroyed then return end
	Rack.Destroyed = true
	zclib.Entity.SafeRemove(Rack)
	zclib.NetEvent.Create("zbf_rack_destroy", {Rack})
end

function zbf.Rack.Damage(Rack, dmg)
	if zbf.config.Damageable["zbf_rack"] <= 0 then return end
	Rack:SetHealth(math.Clamp(Rack:Health() - (dmg or 5), 0, Rack:GetMaxHealth()))

	if Rack:Health() <= 0 then
		zbf.Rack.Destroy(Rack)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

function zbf.Rack.OnTakeDamage(Rack, dmginfo)
	zclib.Debug("zbf.Rack.OnTakeDamage")
	if not IsValid(Rack) then return end

	if zbf.Rack.HasBots(Rack) then return end

	if (not Rack.m_bApplyingDamage) then
		Rack.m_bApplyingDamage = true
		Rack:TakeDamageInfo(dmginfo)
		zbf.Rack.Damage(Rack, dmginfo:GetDamage())
		Rack.m_bApplyingDamage = false
	end
end
