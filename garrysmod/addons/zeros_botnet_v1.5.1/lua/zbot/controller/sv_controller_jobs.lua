/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if CLIENT then return end
zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*

	This system handles which jobs the controller is doing and which ones he is suggested
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

*/

/*
	Updates the client about which job has currently a cooldown in the controller
*/
util.AddNetworkString("zbf_Controller_UpdateCooldowns")
function zbf.Controller.UpdateCooldowns(Controller, ply)
	zclib.Debug("zbf.Controller.UpdateCooldowns")

	Controller.Cooldowns = Controller.Cooldowns or {}

	/*
		Controller.Cooldowns[JobID] = EndTime
	*/

	// If any of the cooldowns is over then remove them
	for k, v in pairs(Controller.Cooldowns) do
		if CurTime() > v then
			Controller.Cooldowns[ k ] = nil
		end
	end

	//if table.Count(Controller.Cooldowns) <= 0 then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

	net.Start("zbf_Controller_UpdateCooldowns")
	net.WriteEntity(Controller)
	net.WriteUInt(table.Count(Controller.Cooldowns), 15)

	for job_id, end_time in pairs(Controller.Cooldowns) do
		net.WriteUInt(job_id, 8)
		net.WriteUInt(end_time, 32)
	end

	net.Send(ply)
end

/*
	Updates the client about which joboffers are currently possible for the controller
*/
util.AddNetworkString("zbf_Controller_UpdateJobOffers")
function zbf.Controller.UpdateJobOffers(Controller,ply)
	zclib.Debug("zbf.Controller.UpdateJobOffers")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	Controller.JobOffers = Controller.JobOffers or {}

	/*
		Controller.JobOffers[JobID] = CurTime
	*/

	// Remove any job offer which time runs out
	for k, v in pairs(Controller.JobOffers) do
		if CurTime() > v then
			Controller.JobOffers[ k ] = nil
		end

		// This should never be needed but just to make sure lets remove any job which already got unlocked
		if ply.zbf_UnlockedJobs and ply.zbf_UnlockedJobs[k] then
			Controller.JobOffers[ k ] = nil
		end
	end

	// Check if we can give the player another job
	if Controller.NextJobOffer == nil or CurTime() > Controller.NextJobOffer and table.Count(Controller.JobOffers) < zbf.config.Controller.job_offer_limit then
		local nextOffer = zbf.Controller.GetNextOffer(Controller,ply)
		if nextOffer then
			Controller.JobOffers[nextOffer] = CurTime() + zbf.Jobs.GetExpireTime(nextOffer)
		end
		Controller.NextJobOffer = CurTime() + zbf.config.Controller.job_offer_interval
	end

	//if table.Count(Controller.JobOffers) <= 0 then return end

	net.Start("zbf_Controller_UpdateJobOffers")
	net.WriteEntity(Controller)
	net.WriteUInt(table.Count(Controller.JobOffers), 15)

	for job_id, offer_time in pairs(Controller.JobOffers) do
		net.WriteUInt(job_id, 8)
		net.WriteUInt(offer_time, 32)
	end

	net.Send(ply)
end

/*
	Updates the client about which jobs he already has unlocked
*/
util.AddNetworkString("zbf_Controller_UpdateUnlockedJobs")
function zbf.Controller.UpdateUnlockedJobs(ply)
	zclib.Debug("zbf.Controller.UpdateUnlockedJobs")

	if ply.zbf_UnlockedJobs == nil then ply.zbf_UnlockedJobs = {} end

	net.Start("zbf_Controller_UpdateUnlockedJobs")
	net.WriteUInt(table.Count(ply.zbf_UnlockedJobs), 15)
	for job_id, _ in pairs(ply.zbf_UnlockedJobs) do
		net.WriteUInt(job_id, 8)
	end
	net.Send(ply)
end


/*
	Returns when the next error will occur according to the specific job
*/
function zbf.Controller.GetNextError(JobID)
	local jobdata = zbf.config.Jobs[ JobID ]
	local time = math.random(40, 60)

	if jobdata and jobdata.error and jobdata.error.interval then
		if isnumber(jobdata.error.interval) then
			time = jobdata.error.interval
		elseif istable(jobdata.error) then
			time = math.random(jobdata.error.interval.min, jobdata.error.interval.max)
		end
	end

	return CurTime() + time
end

/*
	Causes a bunch of connected bots to error out
*/
function zbf.Controller.MassError(Controller,BotCount, e_type, e_time, e_val)
	// Get some random bot and cause a error
	local Bots = {}
	for i = 1, BotCount do
		local device = zbf.Controller.GetRandomWorkingBot(Controller)
		if IsValid(device) then
			table.insert(Bots,device)
		end
	end
	zbf.Bot.MassError(Bots, e_type, e_time, e_val)
end


/*
	Gets called from the interface to start a new computing job
*/
util.AddNetworkString("zbf_Controller_StartJob")
net.Receive("zbf_Controller_StartJob", function(len, ply)
	zclib.Debug_Net("zbf_Controller_StartJob", len)
	if zclib.Player.Timeout(nil, ply) then return end
	local controller = net.ReadEntity()
	local jobid = net.ReadUInt(8)
	local targetIP = net.ReadUInt(16)
	if jobid == nil then return end
	if not IsValid(controller) then return end
	if not IsValid(ply) then return end
	if zclib.util.InDistance(ply:GetPos(), controller:GetPos(), 500) == false then return end

	if not zclib.Player.IsOwner(ply, controller) then
		zclib.Notify(ply,zbf.language[ "Youdontown" ], 1)
		return
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	zbf.Controller.StartJob(controller, jobid, targetIP, ply)

	timer.Simple(0.1, function()
		net.Start("zbf_Controller_StartJob")
		net.Send(ply)
	end)
end)

function zbf.Controller.StartJob(Controller, JobID, TargetIP, ply)

	// Is the player even allowed todo this job?
	if not zbf.Jobs.CanDo(JobID,ply) then return end

	// Has this job offer already expired?
	if zbf.Jobs.IsContract(JobID) and Controller.JobOffers[JobID] and CurTime() > Controller.JobOffers[JobID] then return end

	// Does the controller is still in cooldown for this type of jobid?
	if zbf.Controller.HasCooldown(Controller, JobID, ply) then return end

	// Check if this controller / BotNet has a high enough Neuro Level
	if not zbf.Controller.HasNeuroRequierement(Controller, JobID) then return end

	// If its a job offer then remove it from the controllers list
	if zbf.Jobs.IsContract(JobID) and Controller.JobOffers[JobID] then
		Controller.JobOffers[JobID] = nil
		zbf.Controller.UpdateJobOffers(Controller,ply)
	end

	local jobData = zbf.config.Jobs[ JobID ]

	Controller:SetJobID(JobID)
	Controller:SetJobProgress(0)
	Controller.TargetIP = TargetIP

	local target = Player(TargetIP)
	if IsValid(target) then
		Controller:SetTargetName(tostring(target:Nick()))
	else
		Controller:SetTargetName(TargetIP)
	end

	local timerid = "zbf_controller_timer_" .. Controller:EntIndex()
	zclib.Timer.Remove(timerid)

	if jobData == nil then return end

	zclib.Debug("zbf.Controller.StartJob " .. jobData.name)
	local nextError = zbf.Controller.GetNextError(JobID)

	zclib.Timer.Create(timerid, 1, 0, function()
		if not IsValid(Controller) then
			zclib.Timer.Remove(timerid)

			return
		end

		if CurTime() >= nextError then
			nextError = zbf.Controller.GetNextError(JobID)

			// Depending on Job the reboot time might take a bit longer
			local e_data, e_time = zbf.Jobs.GetNextError(JobID)
			local e_type
			local e_val
			local BotCount = 1
			if istable(e_data) then
				e_type = e_data[1]
				BotCount = e_data[2]
				e_val = e_data[3]
			else
				e_type = e_data
			end

			// Get some random bot and cause a error
			zbf.Controller.MassError(Controller, BotCount, e_type, e_time, e_val)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

		for _, v in pairs(zbf.Controller.GetConnectedDevices(Controller)) do
			if not IsValid(v) then continue end
			if zbf.Bot.IsWorking(v) == false then continue end

			// If one of the bots is too far away and he is not highjacked then disconnect him
			if not zclib.util.InDistance(Controller:GetPos(), v:GetPos(), 500) and not zbf.Bot.IsHighjacked(v) then
				zbf.Bot.SetController(v, NULL)
				continue
			end

			// Wears down the bot a bit
			zbf.Bot.Wear(v)

			// Increase the XP if the level system is enabled
			zbf.Bot.AddXP(v)

			Controller:SetJobProgress(Controller:GetJobProgress() + zbf.Bot.GetTicksPerSecond(v))

			if Controller:GetJobProgress() >= jobData.ticks and zbf.Controller.FinishJob(Controller, JobID, TargetIP, ply) then break end
		end
	end)
end

/*
	Gets called once a computing job finishes
*/
util.AddNetworkString("zbf_Controller_FinishJob")
function zbf.Controller.FinishJob(Controller, JobID, TargetIP, ply)
	local jobData = zbf.config.Jobs[ JobID ]

	// Check if this controller / BotNet has a high enough Neuro Level
	if not zbf.Controller.HasNeuroRequierement(Controller, JobID) then return end

	// Transfer the money
	if jobData.GetPayment then
		local c_type, c_amount = zbf.Jobs.GetPayment(JobID, ply, Controller, TargetIP)

		local WalletSize = zbf.Controller.GetWalletSize(Controller, zclib.Player.GetOwner(Controller))
		local WalletValue = zbf.Wallet.GetMoneyValue(Controller)

		// If we got less money then the limit allows then we can add more
		if WalletValue < WalletSize then zbf.Wallet.AddCurrency(Controller,c_type,c_amount) end
	end

	// Reset the progress
	Controller:SetJobProgress(0)

	// If we got a finish function to call then do that
	if jobData.OnFinish then

		// A custom hook to prevent the jobs finish function to execute
		local block = hook.Run("zbf_Job_BlockFinish",Controller,JobID)
		if not block then
			jobData.OnFinish(Controller, ply, TargetIP)
		end
	end

	// If the job has a cooldown then tell the Controller when he can perform this job again
	if jobData.cooldown then
		Controller.Cooldowns = Controller.Cooldowns or {}
		Controller.Cooldowns[ JobID ] = CurTime() + jobData.cooldown
		// Update all players close by
		local filter = RecipientFilter()
		filter:AddPVS(Controller:GetPos())
		zbf.Controller.UpdateCooldowns(Controller, filter)
	end

	// If the job is a unlockable job then write in the player entity that he unlocked this job, so it can be easly accesed again once completed
	if jobData.unlockable then
		if ply.zbf_UnlockedJobs == nil then ply.zbf_UnlockedJobs = {} end
		ply.zbf_UnlockedJobs[JobID] = true

		// Update the player about which jobs he already has unlocked
		zbf.Controller.UpdateUnlockedJobs(ply)
	end

	// If its not a repeating job then stop
	if zbf.Jobs.CanRepeat(JobID) == false then
		Controller:SetJobID(-1)
		Controller.TargetIP = 0

		// Send Update to any player who has the interface of that controller open
		net.Start("zbf_Controller_FinishJob")
		net.WriteEntity(Controller)
		net.Broadcast()
		zclib.Timer.Remove("zbf_controller_timer_" .. Controller:EntIndex())

		return true
	end
end
