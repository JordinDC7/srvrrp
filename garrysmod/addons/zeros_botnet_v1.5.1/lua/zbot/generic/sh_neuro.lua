/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Neuro = zbf.Neuro or {}

/*
	Tells us if the player is protected
*/
function zbf.Neuro.IsProtected(ply)
	return ply:GetNWInt("zbf_neuro_shield_time",0) > CurTime()
end

if SERVER then
	/*
		Make the player faster for a certain amount of time
	*/
	function zbf.Neuro.MakeFaster(ply,duration)
		ply.zbf_Neuro_Boost_Finish = CurTime() + duration
		ply:SetJumpPower(500)
		local identifier = "zbf_controller_neuro_boost_" .. ply:SteamID64()
		zclib.Hook.Add("Move", identifier, function(pl, mv, usrcmd)
			if pl == ply then
				local speed = mv:GetMaxSpeed() * 1.5
				mv:SetMaxSpeed(speed)
				mv:SetMaxClientSpeed(speed)

				if CurTime() >= ply.zbf_Neuro_Boost_Finish then
					ply:SetJumpPower(200)
					zclib.Hook.Remove("Move",identifier)
				end
			end
		end)
	end

	/*
		Make the player slower for a certain amount of time
	*/
	function zbf.Neuro.MakeSlower(ply,duration)
		ply.zbf_Neuro_Cribble_Finish = CurTime() + duration
		ply:SetJumpPower(100)
		local identifier = "zbf_controller_neuro_cribble_" .. ply:SteamID64()
		zclib.Hook.Add("Move", identifier, function(pl, mv, usrcmd)
			if pl == ply then
				local speed = mv:GetMaxSpeed() * 0.5
				mv:SetMaxSpeed(speed)
				mv:SetMaxClientSpeed(speed)

				if CurTime() >= ply.zbf_Neuro_Cribble_Finish then
					ply:SetJumpPower(200)
					zclib.Hook.Remove("Move",identifier)
				end
			end
		end)
	end

	/*
		Protect the player against damage for a certain amount of time
	*/
	function zbf.Neuro.Protect(ply,duration,strength)
		ply:SetNWInt( "zbf_neuro_shield_time", CurTime() + duration )
		ply:SetNWFloat( "zbf_neuro_shield_strength", strength )
	end

	/*
		Reduces the players health overtime and impacts his vision
	*/
	util.AddNetworkString("zbf.Neuro.Aneurysm")
	function zbf.Neuro.Aneurysm(ply,duration)

		net.Start("zbf.Neuro.Aneurysm")
		net.WriteUInt(duration, 20)
		net.Send(ply)

		local timerid = "zbf_Neuro_Aneurysm_" .. ply:SteamID64()
		zclib.Timer.Remove(timerid)
		zclib.Timer.Create(timerid, 1, duration, function()
			if not IsValid(ply) then
				zclib.Timer.Remove(timerid)
				return
			end
			if not ply:Alive() then
				zclib.Timer.Remove(timerid)
				return
			end
			ply:SetHealth(ply:Health() - 1)
		end)
	end
	zclib.Hook.Add("PlayerDeath", "zbf.Neuro.Aneurysm", function(victim, attacker)
		if IsValid(victim) then
			zclib.Timer.Remove("zbf_Neuro_Aneurysm_" .. victim:SteamID64())
		end
	end)

	function zbf.Neuro.GrowthHormones(ply,duration)

		local prevHealth = ply:GetMaxHealth()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		ply:SetMaxHealth(zbf.config.Neuro.Growth_health)
		ply:SetHealth(zbf.config.Neuro.Growth_health)
		ply:SetModelScale(1.25,0.1)

		local HookID = "zbf.Neuro.GrowthHormones" .. ply:SteamID64()
		local timerid = "zbf_Neuro_GrowthHormones_" .. ply:SteamID64()

		local function ResetEffect()
			zclib.Timer.Remove(timerid)
			ply:SetMaxHealth(prevHealth)
			ply:SetHealth(prevHealth)
			ply:SetModelScale(1,0.1)
			zclib.Hook.Remove("PlayerDeath",HookID)
		end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

		zclib.Timer.Remove(timerid)
		zclib.Timer.Create(timerid, duration, 1, function()
			if not IsValid(ply) then
				zclib.Timer.Remove(timerid)
				return
			end
			ResetEffect()
		end)

		zclib.Hook.Add("PlayerDeath", HookID, function(victim, attacker)
			if IsValid(victim) and victim == ply then
				ResetEffect()
			end
		end)
	end

	/*
		Prevent the player getting any damage if he is protected
	*/
	zclib.Hook.Add("EntityTakeDamage", "zbf_neuro_shield", function(ply, dmg)
		if IsValid(ply) and ply:IsPlayer() and ply:Alive() and zbf.Neuro.IsProtected(ply) then
			local shield_strength = ply:GetNWFloat("zbf_neuro_shield_strength",0)
			dmg:ScaleDamage( 1 - shield_strength )
			local pos = dmg:GetDamagePosition() or ply:GetPos()

			// Creates a spark / reflection effect
			zclib.NetEvent.Create("zbf_neuro_shield_reflect", {pos})
		end
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

	zclib.Hook.Add( "PlayerShouldTakeDamage", "zbf_neuro_shield", function( ply, attacker )
		if IsValid(ply) and ply:IsPlayer() and ply:Alive() and zbf.Neuro.IsProtected(ply) then
			local shield_strength = ply:GetNWFloat("zbf_neuro_shield_strength",0)
			if shield_strength >=1 then
				return false
			end
		end
	end )

	zclib.Hook.Add( "OnDamagedByExplosion", "zbf_neuro_shield", function( ply, dmg )
		if IsValid(ply) and ply:IsPlayer() and ply:Alive() and zbf.Neuro.IsProtected(ply) then
			local shield_strength = ply:GetNWFloat("zbf_neuro_shield_strength",0)
			if shield_strength >=1 then
				return true
			end
		end
	end )

	zclib.Hook.Add("ScalePlayerDamage", "zbf_neuro_shield", function(ply,hit, dmg)
		if IsValid(ply) and ply:IsPlayer() and ply:Alive() and zbf.Neuro.IsProtected(ply) then

			local pos = dmg:GetDamagePosition() or ply:GetPos()

			// Creates a spark / reflection effect
			zclib.NetEvent.Create("zbf_neuro_shield_reflect", {pos})

			local shield_strength = ply:GetNWFloat("zbf_neuro_shield_strength",0)
			if shield_strength >= 1 then
				return true
			else
				dmg:ScaleDamage(1 - shield_strength)
			end
		end
	end)

	/*
		Reset the neuro movement vars on death
	*/
	zclib.Hook.Add("PlayerDeath", "zbf_neuro_shield", function(victim, attacker)
		if IsValid(victim) then
			victim.zbf_Neuro_Cribble_Finish = 0
			victim.zbf_Neuro_Boost_Finish = 0
			victim:SetNWInt("zbf_neuro_shield_time",0)
			victim:SetNWFloat("zbf_neuro_shield_strength",0)
		end
	end)
else

	/*
		Same damage hook we call on the server will also be called on client to prevent any effects
	*/
	zclib.Hook.Add("ScalePlayerDamage", "zbf_neuro_shield", function(ply,hit, dmg)
		if IsValid(ply) and ply:IsPlayer() and ply:Alive() and zbf.Neuro.IsProtected(ply) then
			local shield_strength = ply:GetNWFloat("zbf_neuro_shield_strength",0)
			if shield_strength >= 1 then
				return true
			end
		end
	end)


	/*
		Here we draw the protection shield
	*/

	local function CreateShield(ply)
		local plyMDL = ply:GetModel()
		zclib.CacheModel(plyMDL)
	    local cs = zclib.ClientModel.AddProp()
	    if IsValid(cs) then

	        cs:SetModel(plyMDL)
	        cs:DrawShadow(false)
	        cs:DestroyShadow()
	        cs:Spawn()
			cs:SetLOD( 0 )

			ply:CallOnRemove("zbf_remove_cs_shield_on_entity_deletion", function(ent)
				zclib.ClientModel.Remove(cs)
			end)

			local CallBackID = cs:AddCallback("BuildBonePositions", function(shield, numbones)

				local shield_time = ply:GetNWInt("zbf_neuro_shield_time",0)
				local diff = shield_time - CurTime()
				local fact = (1 / zbf.config.Neuro.Shield_duration) * diff


				// Depending on the protection strength we change the Size of the shield
				local shield_strength = ply:GetNWFloat("zbf_neuro_shield_strength",0)
				local size = Lerp(shield_strength,1.05,1.5)

				// Scale the size according to time left, so it shrinks
				size = Lerp(fact,1.05,size)

		        for i = 0, numbones - 1 do
		            local mat = shield:GetBoneMatrix(i)
		            if not mat then continue end

					local bone = ply:GetBoneName(i)
					if bone == "__INVALIDBONE__" then continue end
					local vec, ang = ply:GetBonePosition(i)
					if vec == ply:GetPos() then
						local mtx = ply:GetBoneMatrix(i)
						if mtx then
							vec = mtx:GetTranslation()
						end
					end

					mat:SetAngles(ang)
					mat:SetTranslation(vec)
					mat:SetScale(Vector(size,size,size))

		            shield:SetBoneMatrix(i, mat)
		        end
		    end)

		    cs:CallOnRemove("zbf_remove_cs_shield_BuildBonePositions_Callback_" .. math.random(99999999), function(shield)
		        shield:RemoveCallback("BuildBonePositions", CallBackID)
		    end)

	        return cs
	    end
	end

	local function RemoveShield(ply)
		if IsValid(ply.zbf_Shield) then
		   zclib.ClientModel.Remove(ply.zbf_Shield)
		   ply.zbf_Shield = nil
		end
	end

	local function DrawShield(ply)

		if not ply:Alive() then
			RemoveShield(ply)
			return
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		local shield_time = ply:GetNWInt("zbf_neuro_shield_time",0)

		if CurTime() > shield_time then
			RemoveShield(ply)
			return
		end

	    if zclib.util.InDistance(LocalPlayer():GetPos(), ply:GetPos(), 500) == false then
			RemoveShield(ply)
	        return
	    end

		if not IsValid(ply.zbf_Shield) then
			ply.zbf_Shield = CreateShield(ply)
			return
		end

		local diff = shield_time - CurTime()
		local fact = (1 / zbf.config.Neuro.Shield_duration) * diff
		fact = fact + 0.1

		// Depending on the protection strength we change the color
		local shield_strength = ply:GetNWFloat("zbf_neuro_shield_strength",0)
		if shield_strength < 0.5 then
			render.SetColorModulation(0, 0, fact * 0.1)
		else
			render.SetColorModulation(0, 0, fact * 0.8)
		end
		render.MaterialOverride(zclib.Materials.Get("highlight"))
		ply.zbf_Shield:DrawModel()
		render.MaterialOverride()
		render.SetColorModulation(1, 1, 1)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

	// Draw protect shield
	zclib.Hook.Remove("PostPlayerDraw", "zbf.Neuro.Protect")
	zclib.Hook.Add("PostPlayerDraw", "zbf.Neuro.Protect", function(ply) if IsValid(ply) then DrawShield(ply) end end)

	net.Receive("zbf.Neuro.Aneurysm", function(len)
	    zclib.Debug_Net("zbf.Neuro.Aneurysm", len)
	    local duration = net.ReadUInt(20)
	    if not duration then return end
		zbf.Neuro.Aneurysm(LocalPlayer(),duration)
	end)

	function zbf.Neuro.Aneurysm(ply,duration)
		local FinishTime = CurTime() + duration
		zclib.Hook.Remove("RenderScreenspaceEffects", "zbf.Neuro.Protect")
		zclib.Hook.Add("RenderScreenspaceEffects", "zbf.Neuro.Protect", function()
			if not IsValid(ply) then
				zclib.Hook.Remove("RenderScreenspaceEffects", "zbf.Neuro.Protect")
				return
			end

			if not ply:Alive() then
				zclib.Hook.Remove("RenderScreenspaceEffects", "zbf.Neuro.Protect")
				return
			end

			if CurTime() >= FinishTime then
				zclib.Hook.Remove("RenderScreenspaceEffects", "zbf.Neuro.Protect")
				return
			end

			local strength = math.abs(math.sin(CurTime() * 1))
			local strength01 = math.abs(math.sin(CurTime() * 15))

			DrawBloom(0, 0.5, 8 * strength01, 8 * strength01, 1, 1, 1, 1, 1)
			DrawMotionBlur(0.05 * strength, 2 * strength, 0)
			DrawToyTown(1, (ScrH() / 2) * strength)

			local tab = {}
			tab["$pp_colour_colour"] = 1
			tab["$pp_colour_contrast"] = 1 + 0.5 * strength
			tab["$pp_colour_brightness"] = 0
			tab["$pp_colour_addr"] = 0
			tab["$pp_colour_addg"] = 0
			tab["$pp_colour_addb"] = 0
			tab["$pp_colour_mulg"] = 0
			tab["$pp_colour_mulr"] = 0
			tab["$pp_colour_mulb"] = 0
			DrawColorModify(tab)

			DrawMaterialOverlay("effects/water_warp01", -0.025 * strength01)
		end)
	end
end
