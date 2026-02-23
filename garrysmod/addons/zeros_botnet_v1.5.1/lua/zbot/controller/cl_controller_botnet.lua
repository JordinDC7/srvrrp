/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Controller = zbf.Controller or {}

/*
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2d758f4c397a244637d464ba034d8f901161afcac9b1cc1013a7e00e770c265e
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 82f8890a7cf2ce669fa8ca3efd33c093292b7b1cbbcbb6ebcdbdfdd991817a2a

    The IP System can be used to target other players networks and attack them

*/

/*
Updates the player about which IP Fields are scanned on the specified controller
*/
net.Receive("zbf_Controller_IPCache_Update", function(len)
	zclib.Debug_Net("zbf_Controller_IPCache_Update", len)
	local ctrl = net.ReadEntity()
	ctrl.BotNetIP = net.ReadUInt(15)
	ctrl.TargetIP = net.ReadUInt(15)

	ctrl.IPCache = {}
	local count = net.ReadUInt(15)
	for i = 1, count do
		local ip = net.ReadUInt(15)
		local contrll = net.ReadEntity()
		local ForeignConnections = net.ReadUInt(8)
		local LastUpdate = net.ReadUInt(32)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

		ctrl.IPCache[ ip ] = {
			ControllerEntity = contrll,
			ForeignConnections = ForeignConnections,
			LastUpdate = LastUpdate,
		}
	end

	// If the player has the IP Map open while this net message comes in lets update it
	// BUG For some reason the RefreshIP Button not getting rebuild in that progress
	if IsValid(zclib_main_panel) and zclib_main_panel.RebuildMap then
		zclib_main_panel:RebuildMap()
	end
end)

/*
Called after the IP got successfully changed
*/
net.Receive("zbf_Controller_RefreshIP", function(len)
	zclib.Debug_Net("zbf_Controller_RefreshIP", len)
	zbf.Controller.IPMap(zbf.language["BotNet Map"], nil, nil, true)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4fcbab3dc2aea90e138de2f251f32d28bb62fa5ce4ee5ed8ee4a1176efd8f401
