
zclib.NetEvent.AddDefinition("machine_button01", {
	[1] = {
		type = "entity"
	},
}, function(received)
	zlt.Machine.PressButton(received[1], 1)
end)


zclib.NetEvent.AddDefinition("machine_button02", {
	[1] = {
		type = "entity"
	},
}, function(received)
	zlt.Machine.PressButton(received[1], 2)
end)


zclib.NetEvent.AddDefinition("machine_button03", {
	[1] = {
		type = "entity"
	},
}, function(received)
	zlt.Machine.PressButton(received[1], 3)
end)


zclib.NetEvent.AddDefinition("machine_button04", {
	[1] = {
		type = "entity"
	},
}, function(received)
	zlt.Machine.PressButton(received[1], 4)
end)


zclib.NetEvent.AddDefinition("machine_door", {
	[1] = {
		type = "entity"
	},
}, function(received)
	zclib.Animation.Play(received[1], "door", 1)
end)
