/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Jobs = zbf.Jobs or {}

game.AddParticles("particles/zbf_jobtype.pcf")
PrecacheParticleSystem("zbf_jobtype_complete_vgui")


if CLIENT then
	zclib.vgui.AddEffect("zbf_jobtype_complete_vgui","zbf_jobtype_complete_vgui")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

zbf.Jobs.Types = {}
local function AddJobType(data)
	// Precache
	PrecacheParticleSystem(data.effect_world)
	PrecacheParticleSystem(data.effect_vgui)

	// Adds the pop effect to the VGUI Effect list
	if CLIENT then
		zclib.vgui.AddEffect("zbf_jobtype_neuro_vgui","zbf_jobtype_neuro_vgui")
		zclib.vgui.AddEffect(data.effect_vgui,data.effect_vgui)
	end

	return table.insert(zbf.Jobs.Types,data)
end

// A generic computing job which pays money
ZBF_JOBTYPE_GENERIC = AddJobType({
    name = zbf.language[ "JobType_Generic" ],
    icon = Material("materials/zerochain/zbot/zbf_special_icon.png", "smooth"),
    color = Color(235, 200, 102),

	// What effect should be played in world space at the bot when a tick is received
	effect_world = "zbf_jobtype_generic_world",

	// What effect should be played on the controller vgui when a tick is received using zcLib VGUI Effect system > zclib.vgui.PlayEffectAtPanel
	// NOTE This is not the name of the particle system but rather the id the effect got registred with > zclib.vgui.AddEffect
	effect_vgui = "zbf_jobtype_generic_vgui",

	// How many sound seq files
	snd_seq_count = 64,

	// The interval for each sound in the sequence
	snd_seq_interval = 0.124,

	// Where are the seq files
	snd_seq = "zbf/jobtype/generic/generic_seq$KEY.wav",

	// If we the sequence can be played in full at the correct speed then we play this one in the background
	snd_complete = "zbf/jobtype/generic/generic_complete.wav",
})

// A hacking job which targets and impacts another BotNet owned by another player on the server
ZBF_JOBTYPE_BOTNET = AddJobType({
	name = zbf.language[ "JobType_BotNet" ],
	icon = Material("materials/zerochain/zbot/zbf_bot_icon.png", "smooth"),
	color = Color(86, 114, 194),
	effect_world = "zbf_jobtype_botnet_world",
	effect_vgui = "zbf_jobtype_botnet_vgui",
	snd_seq_count = 64,
	snd_seq_interval = 0.124,
	snd_seq = "zbf/jobtype/generic/generic_seq$KEY.wav",
	snd_complete = "zbf/jobtype/botnet/botnet_complete.wav"
})

// A hacking job which targets players
ZBF_JOBTYPE_NEURO = AddJobType({
	name = zbf.language[ "JobType_Neuro" ],
	icon = Material("materials/zerochain/zbot/zbf_brain_icon.png", "smooth"),
	color = Color(243, 116, 53),
	effect_world = "zbf_jobtype_neuro_world",
	effect_vgui = "zbf_jobtype_neuro_vgui",
	snd_seq_count = 64,
	snd_seq_interval = 0.124,
	snd_seq = "zbf/jobtype/generic/generic_seq$KEY.wav",
	snd_complete = "zbf/jobtype/neuro/neuro_complete.wav"
})

// A crypto computing job which pays crypto money
ZBF_JOBTYPE_CRYPTO = AddJobType({
	name = zbf.language[ "JobType_Crypto" ],
	effect_world = "zbf_jobtype_crypto_world",
	effect_vgui = "zbf_jobtype_crypto_vgui",
	snd_seq_count = 64,
	snd_seq_interval = 0.124,
	snd_seq = "zbf/jobtype/generic/generic_seq$KEY.wav",
	snd_complete = "zbf/jobtype/generic/generic_complete.wav",
})

// A scam computing job which scams people
ZBF_JOBTYPE_SCAM = AddJobType({
	name = zbf.language[ "JobType_Scams" ],
	icon = Material("materials/zerochain/zbot/zbf_scam_icon.png", "smooth"),
	color = Color(194, 86, 86),
	effect_world = "zbf_jobtype_scam_world",
	effect_vgui = "zbf_jobtype_scam_vgui",
	snd_seq_count = 64,
	snd_seq_interval = 0.124,
	snd_seq = "zbf/jobtype/generic/generic_seq$KEY.wav",
	snd_complete = "zbf/jobtype/neuro/neuro_complete.wav",
})

function zbf.Jobs.GetJobTypeData(id)
	return zbf.Jobs.Types[id]
end

function zbf.Jobs.GetJobTypeColor(id)
	local dat = zbf.Jobs.GetJobTypeData(id)

	return dat.color or color_white
end

function zbf.Jobs.GetWorldEffect(id)
	local dat = zbf.Jobs.GetJobTypeData(id)
	return dat.effect_world or "zbf_jobtype_generic_world"
end

function zbf.Jobs.GetVGUIEffect(id)
	local dat = zbf.Jobs.GetJobTypeData(id)
	return dat.effect_vgui or "zbf_jobtype_generic_vgui"
end

function zbf.Jobs.GetJobTypeName(id)
	local dat = zbf.Jobs.GetJobTypeData(id)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	return dat.name or color_white
end


/*
	Returns the data of the job
*/
function zbf.Jobs.GetData(id)
	return zbf.config.Jobs[id]
end

/*
	Returns the type of the job
*/
function zbf.Jobs.GetType(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData == nil then return end
	return JobData.type
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

/*
	Returns which error and time should be used now
*/
function zbf.Jobs.GetNextError(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData and JobData.error and JobData.error.types then
		return table.Random(JobData.error.types)
	else
		return ZBF_ERRORTYPE_REBOOT , 30
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

/*
	Returns the name of the job
*/
function zbf.Jobs.GetName(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData == nil or JobData.name == nil then return end
	return JobData.name
end

/*
	Returns the desc of the job
*/
function zbf.Jobs.GetDesc(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData == nil or JobData.desc == nil then return end

	local str = JobData.desc
	if JobData.type == ZBF_JOBTYPE_NEURO then
		str = string.Replace(str,"$BoostValue",JobData.boost_val)
	end

	return str
end

/*
	Returns the JobTypes icon or a custom one if defined
*/
function zbf.Jobs.GetIcon(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData.icon then return JobData.icon end
	local JobTypeData = zbf.Jobs.GetJobTypeData(JobData.type)
	return JobTypeData.icon or ""
end

/*
	Returns the JobTypes icon to be used in the background
*/
function zbf.Jobs.GetBackgroundIcon(id)
	local JobData = zbf.Jobs.GetData(id)

	// We dont want to show the icon for GENERIC jobs
	if JobData.type == ZBF_JOBTYPE_GENERIC then return end

	if zbf.Jobs.IsCryptoJob(job_id) then
		return zbf.Currency.GetIcon(JobData.crypto_id)
	end

	local JobTypeData = zbf.Jobs.GetJobTypeData(JobData.type)
	return JobTypeData.icon
end

/*
	Returns the JobTypes icon color or a custom one if defined
*/
function zbf.Jobs.GetIconColor(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData.icon_color then return JobData.icon_color end
	return zbf.Jobs.GetJobTypeColor(JobData.type)
end

/*
	Returns the JobTypes icon size or a custom one if defined
*/
function zbf.Jobs.GetIconSize(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData.icon_size then return JobData.icon_size end
	return 1
end

/*
	Returns if the job can be executed in a loop
*/
function zbf.Jobs.CanRepeat(id)
	local JobData = zbf.Jobs.GetData(id)

	return JobData.cooldown == nil
end

/*
	Tells us if the job is targeting players brains
*/
function zbf.Jobs.IsNeuroJob(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData == nil then return false end
	return JobData.type == ZBF_JOBTYPE_NEURO
end

/*
	Tells us if the job is targeting players brains
*/
function zbf.Jobs.IsBadNeuroJob(id)
	if id == ZBF_JOB_NEURO_CRIPPLE then return true end
	if id == ZBF_JOB_NEURO_OVERHEAT then return true end
	if id == ZBF_JOB_NEURO_ANEURYSM then return true end
	return false
end


/*
	Tells us if the job is targeting players brains
*/
function zbf.Jobs.IsCryptoJob(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData == nil then return false end
	return JobData.type == ZBF_JOBTYPE_CRYPTO
end

/*
	Tells us if the job is targeting BotNets
*/
function zbf.Jobs.IsBotNetJob(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData == nil then return false end
	return JobData.type == ZBF_JOBTYPE_BOTNET
end

/*
	Tells us if the job is targeting bots
*/
function zbf.Jobs.IsTargetingBots(id)
	return id == ZBF_JOB_BOTNET_REBOOT or id == ZBF_JOB_BOTNET_CRASH or id == ZBF_JOB_BOTNET_HIGHJACK
end

/*
	Returns how long till the job offer expires
*/
function zbf.Jobs.GetExpireTime(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData == nil then return false end
	return JobData.expire
end

/*
	Returns true if the job has a expire time
*/
function zbf.Jobs.IsContract(id)
	local JobData = zbf.Jobs.GetData(id)
	if JobData == nil then return false end
	return JobData.expire ~= nil
end

/*
	Returns which and how much currency the player gets for the specified job
*/
function zbf.Jobs.GetPayment(id, ply, Controller, TargetIP)
	local JobData = zbf.Jobs.GetData(id)

	if JobData and JobData.GetPayment then
		local c_type, c_amount = JobData.GetPayment(ply, Controller, TargetIP)
		local overwrite_type, overwrite_amount = hook.Run("zbf_Modify_JobPayment", ply, Controller, id, c_type, c_amount)

		if overwrite_type then
			c_type = overwrite_type
		end

		if overwrite_amount then
			c_amount = overwrite_amount
		end

		if c_amount > 10 then
			c_amount = math.Round(c_amount)
		else
			c_amount = math.Round(c_amount, zbf.Currency.GetPrecision(c_type))
		end

		return c_type, c_amount
	end
end

/*
	Check if the player is allowed todo this job
*/
function zbf.Jobs.CanDo(id,ply)
	if not IsValid(ply) then return false end

	local overwrite = hook.Run("zbf_Job_Block",ply,id)
	if overwrite ~= nil then return false end

	local JobData = zbf.Jobs.GetData(id)

	if JobData and JobData.jobs and not zclib.Player.JobCheck(ply, JobData.jobs) then return false end

	if JobData and JobData.ranks and not zclib.Player.RankCheck(ply,JobData.ranks) then return false end

	if JobData and JobData.crypto_id then
		local result = hook.Run("zbf_Crypto_CanMine",ply,zbf.Currency.GetShort(JobData.crypto_id))
		if result ~= nil then return result end
	end

	return true
end

/*
	Calculate the CrashAmount for each job
*/
local MaxCrashAmount = 0
function zbf.Jobs.GetCrashAmount(id)
	local JobData = zbf.Jobs.GetData(id)

	// We will only count errors which crash the bot as reboot errors are not dangerous
	local CrashAmount = 0

	if JobData.error then

		// How often on average will a error occure on this job
		local interval = 0
		if isnumber(JobData.error.interval) then
			interval = JobData.error.interval
		else
			local diff = JobData.error.interval.max - JobData.error.interval.min
			interval = JobData.error.interval.min + (diff / 2)
		end

		// The amount of errors that will occure on the duration of the job
		local ErrorCalls = JobData.ticks / interval

		local CrashTypeCount = 0

		for e_time,e_data in pairs(JobData.error.types) do
			if isnumber(e_data) then
				// Ok its a simple crash error
				if e_data == ZBF_ERRORTYPE_CRASH then

					CrashTypeCount = CrashTypeCount + 1

					// The default danger amount of this error
					local crash_val = 1

					// Lets check how long the player has time to fix the error
					// The difficulty of the error gets calculated by how long the player has time to fix it, 10 seconds would be easy
					local fix_mul = math.Clamp(2 - (1 / 10) * e_time,0.1,1)

					crash_val = crash_val + fix_mul

					CrashAmount = CrashAmount + crash_val
				end
			else
				// [Time/Duration] = {ErrorType,ImpactedBotCount,ExtraValue},

				// Ok its a simple crash error
				if e_data[1] == ZBF_ERRORTYPE_CRASH then

					CrashTypeCount = CrashTypeCount + 1

					// The default danger amount of this error
					local crash_val = 1

					// Lets check how long the player has time to fix the error
					// The difficulty of the error gets calculated by how long the player has time to fix it, 10 seconds would be easy
					local fix_mul = math.Clamp(2 - (1 / 10) * e_time,0.1,1)
					crash_val = crash_val + fix_mul
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

					// Any damage value larger then 25 is extremly dangerous
					local dmg_mul = (1 / 10) * e_data[3]
					crash_val = crash_val + dmg_mul

					// The amount of impacted bos is also a multiplicator
					crash_val = crash_val * e_data[2]

					CrashAmount = CrashAmount + crash_val
				end
			end
		end

		ErrorCalls = (ErrorCalls / table.Count(JobData.error.types)) * CrashTypeCount

		CrashAmount = CrashAmount * ErrorCalls
	end

	// Lets keep track on the highest value for later
	if CrashAmount > MaxCrashAmount then
		MaxCrashAmount = CrashAmount
	end

	return CrashAmount
end

// Lets go through all the jobs and calculate for each the difficulty value
timer.Simple(1,function()
	for k,v in pairs(zbf.config.Jobs) do
		local CrashAmount = zbf.Jobs.GetCrashAmount(k)
		v.CrashAmount = CrashAmount
	end
end)

/*
	Returns a number between 0-1 depending on how many errors the job will cause
*/
function zbf.Jobs.GetDifficulty(id)
	local JobData = zbf.Jobs.GetData(id)
	// 0 == Easy
	// 1 == Very Hard
	return math.Round((1 / MaxCrashAmount) * JobData.CrashAmount,4)
end
