/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

sound.Add({
	name = "zbf_fix",
	channel = CHAN_STATIC,
	volume = 1,
	level = 55,
	pitch = {100, 100},
	sound = {"buttons/button24.wav"}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

sound.Add({
	name = "zbf_reboot",
	channel = CHAN_STATIC,
	volume = 1,
	level = 55,
	pitch = {100, 100},
	sound = {
		"zbf/reboot.wav"
	}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

sound.Add({
	name = "zbf_shield",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = {100, 100},
	sound = {
		"zbf/shield.wav"
	}
})

sound.Add({
	name = "zbf_speed_down",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = {100, 100},
	sound = {
		"zbf/speed_down.wav"
	}
})
sound.Add({
	name = "zbf_speed_up",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = {100, 100},
	sound = {
		"zbf/speed_up.wav"
	}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

sound.Add({
	name = "zbf_crash",
	channel = CHAN_STATIC,
	volume = 1,
	level = 55,
	pitch = {100, 100},
	sound = {
		"zbf/crash.wav"
	}
})

sound.Add({
	name = "zbf_mine",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 35,
	pitch = {95, 102},
	sound = {"zbf/tick01.wav"}
})

sound.Add({
	name = "zbf_neuro",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 30,
	pitch = {95, 102},
	sound = {
		"zbf/pop01.wav",
		"zbf/pop02.wav",
		"zbf/pop03.wav",
		"zbf/pop04.wav",
		"zbf/pop05.wav",
	}
})


sound.Add({
	name = "zbf_fan",
	channel = CHAN_STATIC,
	volume = 0.6,
	level = 40,
	pitch = {100, 100},
	sound = {"zbf/fan_loop.wav"}
})

sound.Add({
	name = "zbf_neuro_loop",
	channel = CHAN_STATIC,
	volume = 0.7,
	level = 35,
	pitch = {100, 100},
	sound = {"zbf/neuro_loop01.wav"}
})

sound.Add({
	name = "zbf_bot_explode",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = {100, 100},
	sound = {
		//"npc/scanner/scanner_explode_crash2.wav"
		"npc/scanner/scanner_pain2.wav"
	}
})

sound.Add({
	name = "zbf_health_boost",
	channel = CHAN_STATIC,
	volume = 1,
	level = 45,
	pitch = {100, 100},
	sound = {
		"items/medshot4.wav"
	}
})
sound.Add({
	name = "zbf_bot_damage",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = {100, 100},
	sound = {
		"weapons/stunstick/spark1.wav",
		"weapons/stunstick/spark2.wav",
		"weapons/stunstick/spark3.wav"
	}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

zclib.Sound.List["zbf_neuro_shield_reflect"] = {
	paths = {
		"weapons/fx/nearmiss/bulletLtoR03.wav",
		"weapons/fx/nearmiss/bulletLtoR04.wav",
		"weapons/fx/nearmiss/bulletLtoR05.wav",
		"weapons/fx/nearmiss/bulletLtoR06.wav",
	},
	lvl = 65,
	pitchMin = 100,
	pitchMax = 100
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

/*
	Create the sounds for the job types since they need to be looped
*/
for k, v in pairs(zbf.Jobs.Types) do
	sound.Add({
		name = "zbf_jobtype_" .. k .. "_seq_complete",
		channel = CHAN_STATIC,
		volume = 1,
		level = 65,
		pitch = {100, 100},
		sound = {v.snd_complete}
	})
end
