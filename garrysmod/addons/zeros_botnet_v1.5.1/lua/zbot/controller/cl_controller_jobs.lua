/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Controller = zbf.Controller or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

/*
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

	This system handles which job cooldowns / offers
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

function zbf.Controller.StartJob(Controller,JobID,TargetID)
	net.Start("zbf_Controller_StartJob")
	net.WriteEntity(Controller)
	net.WriteUInt(JobID, 8)
	net.WriteUInt(TargetID, 16)
	net.SendToServer()
end

/*
	Updates the player about which cooldowns this controller currently has
*/
net.Receive("zbf_Controller_UpdateCooldowns", function(len)
	zclib.Debug_Net("zbf_Controller_UpdateCooldowns", len)
	local ctrl = net.ReadEntity()
	if not IsValid(ctrl) then return end
	ctrl.Cooldowns = {}
	local count = net.ReadUInt(15)

	for i = 1, count do
		local job_id = net.ReadUInt(8)
		local end_time = net.ReadUInt(32)
		ctrl.Cooldowns[ job_id ] = end_time
	end
end)

/*
	Updates the current job offers this controller has
*/
net.Receive("zbf_Controller_UpdateJobOffers", function(len)
	zclib.Debug_Net("zbf_Controller_UpdateJobOffers", len)
	local ctrl = net.ReadEntity()
	if not IsValid(ctrl) then return end
	ctrl.JobOffers = {}
	local count = net.ReadUInt(15)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

	for i = 1, count do
		local job_id = net.ReadUInt(8)
		local offer_time = net.ReadUInt(32)
		ctrl.JobOffers[ job_id ] = offer_time
	end
end)

/*
	Updates which jobs are already unlocked
*/
net.Receive("zbf_Controller_UpdateUnlockedJobs", function(len)
	zclib.Debug_Net("zbf_Controller_UpdateUnlockedJobs", len)
	LocalPlayer().zbf_UnlockedJobs = {}
	local count = net.ReadUInt(15)
	for i = 1, count do
		LocalPlayer().zbf_UnlockedJobs[ net.ReadUInt(8) ] = true
	end
end)
