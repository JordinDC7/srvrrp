/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*
	Returns all the jobs the player can currently do
*/
function zbf.Controller.GetAvailableJobs(ply)
	local jobs = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

	for k, v in pairs(zbf.config.Jobs) do
		if v == nil then continue end
		if zclib.Player.JobCheck(ply, v.jobs) == false then continue end
		jobs[ k ] = v
	end

	return jobs
end

/*
	Returns a list of all available Job offers for this controller
*/
function zbf.Controller.GetAvailableOffers(Controller,ply)
	local jobs = {}

	for k,v in pairs(zbf.Controller.GetAvailableJobs(ply)) do
		if v and zbf.Jobs.IsContract(k) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

			// If for some reason the player is not allowed todo this job then skip
			if not zbf.Jobs.CanDo(k,ply) then continue end

			// If this job offer does already exist in our offers then dont add it
			if Controller.JobOffers and Controller.JobOffers[k] then continue end

			// If this job is already unlocked then stop
			if ply.zbf_UnlockedJobs and ply.zbf_UnlockedJobs[k] then continue end

			jobs[k] = v
		end
	end

	return jobs
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401

/*
	Returns a random possible job offer
*/
function zbf.Controller.GetNextOffer(Controller,ply)
	local jobs = zbf.Controller.GetAvailableOffers(Controller,ply)
	if jobs == nil or table.Count(jobs) <= 0 then return end
	local _ , JobID = table.Random(jobs)
	return JobID
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

/*
	Returns if the controller has currently a cooldown for the specified JobID
*/
function zbf.Controller.HasCooldown(Controller, JobID, ply)
	// Unlocked jobs dont have a cooldown anymore
	if ply.zbf_UnlockedJobs[JobID] then return false end

	if Controller.Cooldowns and Controller.Cooldowns[JobID] then
		return math.Clamp(Controller.Cooldowns[JobID] - CurTime(), 0, 999999999999999999999) > 0
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c


/*
	Returns a list of all available Unlocked Jobs
*/
function zbf.Controller.GetUnlockedJobs(ply)
	local jobs = {}

	if ply.zbf_UnlockedJobs == nil then ply.zbf_UnlockedJobs = {} end
	for k,v in pairs(ply.zbf_UnlockedJobs) do
		if k == nil or v == nil then continue end

		// If for some reason the player is not allowed todo this job then skip
		if not zbf.Jobs.CanDo(k,ply) then continue end

		jobs[k] = v
	end

	return jobs
end

/*
	Tells us if this specific job id already got unlocked by the player
*/
function zbf.Controller.IsUnlocked(ply, JobID)
	if ply.zbf_UnlockedJobs == nil then ply.zbf_UnlockedJobs = {} end
	return ply.zbf_UnlockedJobs[JobID] ~= nil
end
