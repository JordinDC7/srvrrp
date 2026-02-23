concommand.Add( "bricks_server_import_mgangs2", function( ply, cmd, args )
	if( IsValid( ply ) and not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	if( not mg2 ) then
		print( "MGangs not found!" )
		return
	end

	local dType = zlib.data:GetConnection("mg2.Main")

	dType:Query( "SELECT * FROM mg2_gangs", function(data)
		for k, v in pairs( data or {} ) do
			local gangTable = {
				Name = v.name,
				Icon = v.icon_url,
				Owner = v.leader_steamid,
				Members = { [v.leader_steamid] = { v.leader_name, 1 } },
				Roles = { 
					{ BRICKS_SERVER.Func.L( "gangOwner" ), Color( 231, 76, 60 ), {} },
					{ BRICKS_SERVER.Func.L( "gangOfficer" ), Color( 52, 152, 219 ), {} },
					{ BRICKS_SERVER.Func.L( "gangMember" ), Color( 189, 195, 199 ), {} }
				}
			}
	
			BRICKS_SERVER.Func.InsertGangDB( v.id, gangTable.Name, gangTable.Icon, gangTable.Owner, gangTable.Members, gangTable.Roles, function()
				BRICKS_SERVER.Func.UpdateGangDB( v.id, "level", v.level or 0 )
				BRICKS_SERVER.Func.UpdateGangDB( v.id, "experience", BRICKS_SERVER.Func.GetGangExpToLevel( 0, v.level or 0 ) )
				BRICKS_SERVER.Func.UpdateGangDB( v.id, "money", v.balance or 0 )
			end )
		end

		dType:Query( "SELECT * FROM mg2_users", function(data)
			local newGangMembers = {}
			for k, v in pairs( data or {} ) do
				newGangMembers[v.gang_id] = newGangMembers[v.gang_id] or {}
				newGangMembers[v.gang_id][v.steamid] = { v.name, math.min( v.group, 3 ) }
			end
		
			for k, v in pairs( newGangMembers ) do
				BRICKS_SERVER.Func.UpdateGangDB( k, "members", util.TableToJSON( v ) )
			end
		end)
	end)
end )