/*
    Addon id: 64058314-9b3d-4ee7-a98b-bcfc9a58ef8b
    Version: v1.5.1 (stable)
*/

if SERVER then return end
zbf = zbf or {}
zbf.Bot = zbf.Bot or {}
zbf.Bot.Editor = zbf.Bot.Editor or {}

concommand.Add("zbf_bot_editor", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zbf.Bot.Editor.MainMenu()
    end
end)

// Stores the bot data we are currently working on
local BotData

// If we edit a existing config then this is the id we overwrite after saving
local OverwriteID

/*
    Updates the provided models lua material
*/
local function UpdateModel(Bot_ent)

	// Get the normal map of the material we wanna replace
    local mats = Bot_ent:GetMaterials()
	local mat_overwrite_path = mats[math.Clamp(BotData.material.id + 1, 0, table.Count(mats) - 1)]
    local params = util.KeyValuesToTable( file.Read( "materials/" .. mat_overwrite_path .. ".vmt", "GAME" ) ) or {}

	local s_diff_map = BotData.material.diff
    local s_nrm_map = BotData.material.nrm

	if params["$basetexture"] then s_diff_map = params["$basetexture"] end
    if s_nrm_map == nil and params["$bumpmap"] then s_nrm_map = params["$bumpmap"] end
    if s_nrm_map == nil and params["$normalmap"] then s_nrm_map = params["$normalmap"] end

    BotData.material.diff = s_diff_map or "zerochain/props_clickfarm/bot/zcf_bot_mat01_diff"
	BotData.material.nrm = s_nrm_map or "zerochain/props_clickfarm/bot/zcf_bot_mat01_nrm"

    // Builds / updates the material
    zbf.Bot.GetMaterial("zbf_bot_paint_mat_editor",BotData)

    // Reset all materials
    Bot_ent:SetSubMaterial()

    Bot_ent:SetSubMaterial(BotData.material.id, "!" .. "zbf_bot_paint_mat_editor")
end

/*
    Creates a generic CategoryBox
*/
local function CategoryBox(list,name,content)

    local cat_itm = list:Add( name )
    cat_itm:SetTall( 100 )
    cat_itm:SetHeaderHeight(30 * zclib.hM)
    cat_itm.Header:SetTextColor(zclib.colors["orange01"])
    cat_itm.Header:SetFont(zclib.GetFont("zclib_font_mediumsmall"))
    cat_itm:SetExpanded(false)
    cat_itm.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"])
    end

    local container = vgui.Create("DPanel", list)
    container.Paint = function(s, w, h) end
    container:DockPadding(0, 0 * zclib.hM, 0, 10 * zclib.hM)
    list:AddItem(container)

    pcall(content,container,cat_itm)

    // Add DPanelList to our Collapsible Category
    cat_itm:SetContents( container )

    container:InvalidateLayout(true)
    container:SizeToChildren(false,true)
end

/*
    Creates a titled ColorMixer
*/
local function ColorMixer(parent,default,title,alpha,OnChange)
    local pnl = zclib.vgui.Panel(parent, title)
    pnl:SetSize(245 * zclib.wM, 120 * zclib.hM)
    pnl:Dock(TOP)
    pnl:DockMargin(10 * zclib.wM,0 * zclib.hM,10 * zclib.wM,10 * zclib.hM)
    pnl:DockPadding(0, -10 * zclib.hM, 0, 10 * zclib.hM)

    pnl.Title_font = zclib.GetFont("zclib_font_small")
    pnl.Title_color = zclib.colors["text01"]
    pnl.BG_color = zclib.colors["black_a50"]

    local paint_color = zclib.vgui.Colormixer(pnl,default,function(col)
    end,function(col)
        pcall(OnChange,col)
    end)

    paint_color:Dock(FILL)
    paint_color:SetWangs(false)
    paint_color:SetAlphaBar(alpha)
end

/*
    Creates a ComboBox to select a Image Processing Blendmode
*/
local function BlendMode(parent,default,OnChange)
    local pnl = zclib.vgui.Panel(parent, zbf.language[ "BlendMode" ])
    pnl:SetSize(245 * zclib.wM, 70 * zclib.hM)
    pnl:Dock(TOP)
    pnl:DockMargin(10 * zclib.wM,0 * zclib.hM,10 * zclib.wM,10 * zclib.hM)
    pnl:DockPadding(0, 10 * zclib.hM, 0, 10 * zclib.hM)

    pnl.Title_font = zclib.GetFont("zclib_font_small")
    pnl.Title_color = zclib.colors["text01"]
    pnl.BG_color = zclib.colors["black_a50"]

    local blendmode_DComboBox = zclib.vgui.ComboBox(pnl,zbf.Bot.BlendModes[default].name,function(index, value,apnl)
        pcall(OnChange,index, value,apnl)
    end)
    blendmode_DComboBox:SetTall(30 * zclib.hM)
    blendmode_DComboBox:SetSortItems( false )
    blendmode_DComboBox:DockMargin(10 * zclib.wM,20 * zclib.hM,10 * zclib.wM,10 * zclib.hM)
    blendmode_DComboBox:Dock(TOP)

    for i,v in pairs(zbf.Bot.BlendModes) do blendmode_DComboBox:AddChoice(v.name, i) end
end

/*
    Creates a ComboBox to select a NormalMap
*/
local function NormapMaps(parent,default,OnChange)
    local pnl = zclib.vgui.Panel(parent, zbf.language[ "NormalMap" ])
    pnl:SetSize(245 * zclib.wM, 70 * zclib.hM)
    pnl:Dock(TOP)
    pnl:DockMargin(10 * zclib.wM,0 * zclib.hM,10 * zclib.wM,10 * zclib.hM)
    pnl:DockPadding(0, 10 * zclib.hM, 0, 10 * zclib.hM)

    pnl.Title_font = zclib.GetFont("zclib_font_small")
    pnl.Title_color = zclib.colors["text01"]
    pnl.BG_color = zclib.colors["black_a50"]

	// Find which id corresponds with this normapmap path
	local id = 1
	for k,v in pairs(zbf.Bot.NormalMaps) do
		if v and v.path == default then
			id = k
			break
		end
	end

    local nrm_DComboBox = zclib.vgui.ComboBox(pnl,zbf.Bot.NormalMaps[id].name,function(index, value,apnl)
        pcall(OnChange,index, value,apnl)
    end)
    nrm_DComboBox:SetTall(30 * zclib.hM)
    nrm_DComboBox:SetSortItems( false )
    nrm_DComboBox:DockMargin(10 * zclib.wM,20 * zclib.hM,10 * zclib.wM,10 * zclib.hM)
    nrm_DComboBox:Dock(TOP)

    for i,v in pairs(zbf.Bot.NormalMaps) do nrm_DComboBox:AddChoice(v.name, v.path) end
end

/*
	Creates a TextBox Entry
*/
local function TextEntry(parent, title, default, OnChange)

    local pnl = vgui.Create("DPanel", parent)
    pnl:SetTall(30 * zclib.hM)
    pnl:Dock(TOP)
    pnl:DockMargin(10 * zclib.wM, 0 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
    pnl:DockPadding(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
    pnl.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"])
    end

    local lbl = vgui.Create("DLabel", pnl)
    lbl:Dock(LEFT)
    lbl:SetMouseInputEnabled(true)
    lbl:SetFont(zclib.GetFont("zclib_font_small"))
    lbl:SetTextColor(zclib.colors["text01"])
    lbl:SetText(title)

    local entry = zclib.vgui.TextEntry(pnl, default, OnChange, false)
    entry:Dock(FILL)
    entry.font = zclib.GetFont("zclib_font_small")
    entry.bg_color = zclib.colors["black_a50"]
    entry:SetValue(default)

    pnl.PerformLayout = function(self)
        lbl:SetWide(self:GetWide() / 3)
    end
end

/*
    Opens the Bot selection menu
*/
function zbf.Bot.Editor.MainMenu()
    zclib.vgui.Page(zbf.language["Bot Selection"], function(main, top)
        main:SetSize(1200 * zclib.wM, 1000 * zclib.hM)

        zbf.vgui.ImageButton(top, zclib.Materials.Get("close"), zclib.colors["red01"], function()
            main:Close()
        end,function() return false end,zbf.language["Close"])

        local seperator = zclib.vgui.AddSeperator(top)
        seperator:SetSize(5 * zclib.wM, 50 * zclib.hM)
        seperator:Dock(RIGHT)
        seperator:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

        local SelectedID = -1

        local function InvalidBot() return not zbf.Bot.GetData(SelectedID) end

        // Only admins can edit the skins
        if zclib.Player.IsAdmin(LocalPlayer()) then

            zbf.vgui.ImageButton(top, zclib.Materials.Get("delete"), zclib.colors["red01"], function()
                if SelectedID and zbf.Bot.GetData(SelectedID) then

                    zbf.vgui.ConfirmationWindow(zbf.language["confirm_delete"],function()
                        zbf.config.Bots[SelectedID] = nil
                        SelectedID = nil
                        zbf.Bot.Editor.UpdateServer()
                        zbf.Bot.Editor.Wait()
                    end)
                end
            end, function() return InvalidBot() end, zbf.language["Delete"])

            zbf.vgui.ImageButton(top, zclib.Materials.Get("edit"), zclib.colors["orange01"], function()
                if SelectedID and zbf.Bot.GetData(SelectedID) then

					local FoundBotData = zbf.Bot.GetData(SelectedID)
					BotData = table.Copy(FoundBotData)
					BotData = zbf.Bot.VerifyData(BotData)

					OverwriteID = SelectedID

                    zbf.Bot.Editor.Start()
                end
            end,function() return InvalidBot() end,zbf.language["Edit"])

            zbf.vgui.ImageButton(top, zclib.Materials.Get("duplicate"), zclib.colors["blue02"], function()
                if SelectedID and zbf.Bot.GetData(SelectedID) then

                    zbf.vgui.ConfirmationWindow(zbf.language["confirm_duplicate"],function()
                        local m_botdata = table.Copy(zbf.Bot.GetData(SelectedID))
                        m_botdata.uniqueid = zclib.util.GenerateUniqueID("xxxxxxxxxx")

						m_botdata.name = m_botdata.name .. " Copy"

                        table.insert(zbf.config.Bots,m_botdata)

                        zbf.Bot.Editor.UpdateServer()

                        // NOTE We need to build the material before the snapshoter is gonna use it in the next frame to render the thumbnail
                        // Its something about the Imgur material not being present in the current frame
                        zbf.Bot.GetMaterial("zbf_bot_paint_mat_" .. m_botdata.uniqueid,m_botdata)

                        zbf.Bot.Editor.Wait()
                    end)
                end
            end,function() return InvalidBot() end,zbf.language["Duplicate"])

			zbf.vgui.ImageButton(top, zclib.Materials.Get("clipboard"), zclib.colors[ "blue02" ], function()
				if SelectedID and zbf.Bot.GetData(SelectedID) then
					zbf.Bot.CopyToClipboard(SelectedID)
				end
			end, function() return InvalidBot() end, zbf.language[ "ClipboardTooltip" ])

            zbf.vgui.ImageButton(top, zclib.Materials.Get("plus"), zclib.colors["green01"], function()

				BotData = {}
				BotData.uniqueid = zclib.util.GenerateUniqueID("xxxxxxxxxx")
		        BotData = zbf.Bot.VerifyData(BotData)
				OverwriteID = nil

                zbf.Bot.Editor.Start()
            end,function() return false end,zbf.language["Create"])

            local seperator = zclib.vgui.AddSeperator(top)
            seperator:SetSize(5 * zclib.wM, 50 * zclib.hM)
            seperator:Dock(RIGHT)
            seperator:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
        end

        local Machines_content = vgui.Create("DPanel", main)
        Machines_content:SetSize(1000 * zclib.wM, 1000 * zclib.hM)
        Machines_content:Dock(FILL)
        Machines_content:DockMargin(50 * zclib.wM, 5 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
        Machines_content.Paint = function(s, w, h)
            draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"])
            draw.RoundedBox(5, w - 15 * zclib.wM, 0, 15 * zclib.wM, h, zclib.colors["black_a50"])
        end

        local list,scroll = zclib.vgui.List(Machines_content)
        scroll:DockMargin(10 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
        list:DockMargin(0 * zclib.wM,10 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
        list:SetSpaceY( 10 * zclib.hM)
        list:SetSpaceX( 10 * zclib.wM)

		for k, v in pairs(zbf.config.Bots) do
			zbf.vgui.BotPanel(list, 207, k, v, function() return SelectedID == k end, function(id)
				SelectedID = id
			end,false)
		end
    end)
end

/*
    Opens the Bot editor
*/
local WindowMode = true
function zbf.Bot.Editor.Start()
    zclib.vgui.Page(zbf.language["Bot Editor"], function(main, top)

		if WindowMode then
			main:SetSize(1200 * zclib.wM, 1000 * zclib.hM)
			main:SetDraggable(true)
		else
			main:SetSize(ScrW(), ScrH())
			main:SetDraggable(false)
		end
		main:Center()


        zbf.vgui.ImageButton(top, zclib.Materials.Get("close"), zclib.colors["red01"], function()
            main:Close()
        end,function() return false end,zbf.language["Close"])

		local windowButton = zbf.vgui.ImageButton(top, zclib.Materials.Get("fullscreen"), zclib.colors[ "orange01" ], function(s)
			WindowMode = not WindowMode

			if WindowMode then
				main:SetSize(1200 * zclib.wM, 1000 * zclib.hM)
				main:SetDraggable(true)
			else
				main:SetSize(ScrW(), ScrH())
				main:SetDraggable(false)
			end

			main:Center()
			s.IconImage = WindowMode and zclib.Materials.Get("fullscreen") or zclib.Materials.Get("minimize")

		end, function() return false end)
		windowButton.IconImage = WindowMode and zclib.Materials.Get("fullscreen") or zclib.Materials.Get("minimize")


        local seperator = zclib.vgui.AddSeperator(top)
        seperator:SetSize(5 * zclib.wM, 50 * zclib.hM)
        seperator:Dock(RIGHT)
        seperator:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663690

        zbf.vgui.ImageButton(top, zclib.Materials.Get("back"), zclib.colors["orange01"], function()
            zbf.Bot.Editor.MainMenu()
        end,function() return false end, zbf.language["Back"])

        zbf.vgui.ImageButton(top, zclib.Materials.Get("save"), zclib.colors["green01"], function()

            if OverwriteID then
                // Overwrite existing one
                //BotData.uniqueid = zclib.util.GenerateUniqueID("xxxxxxxxxx")
                zbf.config.Bots[OverwriteID] = table.Copy(BotData)

				// Send out net Message to all Clients to remove this file so it gets rebuild
				zclib.Snapshoter.Delete("zbf/bot_" .. BotData.uniqueid,true)
            else
                // Create new
                table.insert(zbf.config.Bots,BotData)
            end

            zbf.Bot.Editor.UpdateServer()

            // NOTE We need to build the material before the snapshoter is gonna use it in the next frame to render the thumbnail
            // Its something about the Imgur material not being present in the current frame
            zbf.Bot.GetMaterial("zbf_bot_paint_mat_" .. BotData.uniqueid,BotData)

            zbf.Bot.Editor.Wait()
        end,function() return false end, zbf.language["Save"])


        local PageContent = vgui.Create("DPanel", main)
        PageContent:SetSize(1000 * zclib.wM, 800 * zclib.hM)
        PageContent:Dock(FILL)
        PageContent:DockMargin(50 * zclib.wM, 5 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
        PageContent.Paint = function(s, w, h)
            draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"])
        end

		local mdl = zclib.vgui.DAdjustableModelPanel({model = BotData.mdl})
		mdl:SetParent(PageContent)
		mdl:Dock(FILL)
		mdl:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		mdl:SetDirectionalLight(BOX_TOP, color_white)
		mdl:SetDirectionalLight(BOX_FRONT, color_white)
		mdl:SetDirectionalLight(BOX_BACK, color_white)
		mdl:SetDirectionalLight(BOX_LEFT, color_black)
		mdl:SetDirectionalLight(BOX_RIGHT, color_white)

		mdl:OnMousePressed( MOUSE_LEFT ) timer.Simple(0,function() if IsValid(mdl) then mdl:OnMouseReleased( MOUSE_LEFT ) end end)

		local function SimpleTextBox(txt, color, font, x, y)
			local txtWidth, txtHeight = zclib.util.GetTextSize(txt, font)
			txtWidth = txtWidth + 20 * zclib.wM
			txtHeight = txtHeight + 5 * zclib.hM
			draw.RoundedBox(5, x - 10 * zclib.wM, y, txtWidth, txtHeight, zclib.colors["black_a100"])
			draw.SimpleText(txt, font, x, y + 3 * zclib.hM, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end

		function mdl:PreDrawModel(ent)
			cam.Start2D()
				surface.SetDrawColor(zclib.colors["text01"])
				surface.SetMaterial(zclib.Materials.Get("item_bg"))
				surface.DrawTexturedRect(0, 0, mdl:GetWide(), mdl:GetTall())

				draw.SimpleText(zbf.language["[TOUCH]"], zclib.GetFont("zclib_font_giant"), mdl:GetWide() / 2, mdl:GetTall() / 2, zclib.colors["black_a50"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End2D()
		end

		function mdl:PostDrawModel(ent)
			cam.Start2D()
				local name = BotData.name
				if name then
					SimpleTextBox(name, zclib.colors["orange01"], zclib.GetFont("zclib_font_big"), 7 * zclib.wM, 10 * zclib.hM)
				end

				local price = BotData.price
				if price then
					SimpleTextBox(zclib.Money.Display(price), zclib.colors["green01"], zclib.GetFont("zclib_font_big"), 7 * zclib.wM, 70 * zclib.hM)
				end
			cam.End2D()
		end

		// Display the job restriction
		if BotData.jobs then
			local lbl = vgui.Create("DLabel", mdl)
			lbl:SetSize(500,100)
		    lbl:Dock(BOTTOM)
			lbl:DockMargin(10,5,0,5)
		    lbl:SetFont(zclib.GetFont("zclib_font_mediumsmall"))
		    lbl:SetTextColor(zclib.colors["blue02"])
		    lbl:SetText(zbf.language["Jobs"] .. ": " .. zclib.table.ToString(BotData.jobs))
			lbl:SetContentAlignment(7)
			lbl:SetWrap(true)
			lbl:SetAutoStretchVertical(true)
		end

		// Display the ranks restriction
		if BotData.ranks then
			local lbl = vgui.Create("DLabel", mdl)
			lbl:SetSize(500,100)
		    lbl:Dock(BOTTOM)
			lbl:DockMargin(10,5,0,5)
		    lbl:SetFont(zclib.GetFont("zclib_font_mediumsmall"))
		    lbl:SetTextColor(zclib.colors["orange01"])
		    lbl:SetText(zbf.language["Ranks"] .. ": " .. zclib.table.ToString(BotData.ranks))
			lbl:SetContentAlignment(7)
			lbl:SetWrap(true)
			lbl:SetAutoStretchVertical(true)
		end

        local OptionsPnl = vgui.Create("DPanel", PageContent)
        OptionsPnl:SetSize(410 * zclib.wM, 800 * zclib.hM)
        OptionsPnl:Dock(LEFT)
        OptionsPnl:DockPadding(10 * zclib.wM, 10 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
        OptionsPnl:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
        OptionsPnl.Paint = function(s, w, h) draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"]) end

        local cat_list = vgui.Create("DCategoryList", OptionsPnl)
        cat_list:SetSize(300 * zclib.wM, 200 * zclib.hM)
        cat_list:DockPadding(0, 0 * zclib.hM, 0, 0 * zclib.hM)
        cat_list:Dock(FILL)
        cat_list.Paint = function(s, w, h) end
        local sbar = cat_list:GetVBar()
    	sbar:SetHideButtons(true)
    	function sbar:Paint(w, h) draw.RoundedBox(5, w * 0.1, 0, w * 0.8, h, zclib.colors["black_a50"]) end
    	function sbar.btnUp:Paint(w, h) end
    	function sbar.btnDown:Paint(w, h) end
        function sbar.btnGrip:Paint(w, h) draw.RoundedBox(5, w * 0.1, 0, w * 0.8, h, zclib.colors["text01"]) end


        local ImgurMat
        local LogoMat
        local EmissveMat

        local LastFrame = CurTime()

		CategoryBox(cat_list,zbf.language["Basic"],function(parent)

			TextEntry(parent, zbf.language["Name"] .. ":", BotData.name, function(val)
				BotData.name = val
			end)

			zbf.vgui.NumSlider(parent,BotData.price,zbf.language["Price"] .. ":",function(val)
				BotData.price = math.Round(val)
			end,1,500000000,0)

			zbf.vgui.Button(parent,zbf.language["Rank Restriction"],zclib.GetFont("zclib_font_mediumsmall"), zclib.colors["orange01"], function()
				zbf.Bot.Editor.List(zbf.language["Rank Restriction"],"ranks",zclib.colors["orange01"])
			end)

			zbf.vgui.Button(parent,zbf.language["Job Restriction"],zclib.GetFont("zclib_font_mediumsmall"), zclib.colors["blue02"], function()
				zbf.Bot.Editor.List(zbf.language["Job Restriction"],"jobs",zclib.colors["blue02"])
			end)
		end)

		CategoryBox(cat_list,zbf.language["Stats"],function(parent)

			zbf.vgui.NumSlider(parent,BotData.health,zbf.language["Health"] .. ":",function(val)
				BotData.health = math.Round(val)
			end,0,500,0)

			local TicksPerSecond = zbf.vgui.NumSlider(parent,BotData.tps,zbf.language["TPS"] .. ":",function(val)
				BotData.tps = math.Round(val,1)
			end,0.1,5,1)
			TicksPerSecond:SetTooltip(zbf.language["TPS_tooltip"])

			zbf.vgui.NumSlider(parent,BotData.attack,zbf.language["Attack"] .. ":",function(val)
				BotData.attack = math.Round(val)
			end,0,100,0)

			zbf.vgui.NumSlider(parent,BotData.defense,zbf.language["Defense"] .. ":",function(val)
				BotData.defense = math.Round(val)
			end,0,100,0)

			zbf.vgui.NumSlider(parent,BotData.neuro,zbf.language["Neuro"] .. ":",function(val)
				BotData.neuro = math.Round(val)
			end,0,100,0)

			zbf.vgui.NumSlider(parent,BotData.repaircost,zbf.language[ "Repair" ] .. ":",function(val)
				BotData.repaircost = math.Round(val)
			end,0.1,10,2)
		end)

		CategoryBox(cat_list, zbf.language["Appearance"], function(parent)
			local matid_slider

			// Select which model
			local mdl_DComboBox = zclib.vgui.ComboBox(parent, zbf.language["Model"], function(index, value, pnl)
				local ModelData = pnl:GetOptionData(index)
				BotData.material.id = ModelData.id
				BotData.mdl = ModelData.mdl
				mdl:SetModel(BotData.mdl)
				// Update the slider since the new model could have more materials
				matid_slider:SetMax(table.Count(mdl.Entity:GetMaterials()) - 1)

				BotData.material.diff = nil
				BotData.material.nrm = nil
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 413ccb693c9bf4d2a0c62d7c658860ea4939ede03231165aacdc44ca05b2388d

				UpdateModel(mdl.Entity)
			end)

			mdl_DComboBox:SetTall(40 * zclib.hM)
			mdl_DComboBox:SetSortItems(false)
			mdl_DComboBox:DockMargin(10 * zclib.wM, 0 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
			mdl_DComboBox:Dock(TOP)

			for k, v in ipairs(zbf.Bot.Models) do
				mdl_DComboBox:AddChoice("Model0" .. k, v)
			end

			matid_slider = zbf.vgui.NumSlider(parent, BotData.material.id, zbf.language["MaterialID"] .. ":", function(val)
				BotData.material.id = math.Round(val)
				UpdateModel(mdl.Entity)
			end, 0, table.Count(mdl.Entity:GetMaterials()) - 1, 0)

			// Normalmaps
			NormapMaps(parent, BotData.material.nrm, function(index, value, pnl)
				local val = pnl:GetOptionData(index)
				BotData.material.nrm = val
				UpdateModel(mdl.Entity)
			end)

			// Base color
			ColorMixer(parent, BotData.material.color, zbf.language["Base Color"], false, function(col)
				BotData.material.color = Color(col.r, col.g, col.b, 255)
				UpdateModel(mdl.Entity)
			end)

			// Reflection color
			ColorMixer(parent, BotData.material.spec_color, zbf.language["Reflection Color"], false, function(col)
				BotData.material.spec_color = Color(col.r, col.g, col.b, 255)
				UpdateModel(mdl.Entity)
			end)

			zbf.vgui.NumSlider(parent, BotData.material.fresnel, zbf.language["Fresnel"], function(val)
				BotData.material.fresnel = val
				UpdateModel(mdl.Entity)
			end, 0, 15, 1)

			zbf.vgui.NumSlider(parent, BotData.material.reflection, zbf.language["Reflection"], function(val)
				BotData.material.reflection = val
				UpdateModel(mdl.Entity)
			end, 0, 15, 1)
		end)

        CategoryBox(cat_list,zbf.language["Imgur"],function(parent)

            // Imgur color
            ColorMixer(parent,BotData.material.imgur_color,zbf.language["Image Color"],true,function(col)
                BotData.material.imgur_color = Color(col.r,col.g,col.b,col.a)
                UpdateModel(mdl.Entity)
            end)

            // Blendmode
            BlendMode(parent, BotData.material.imgur_blendmode or 0, function(index, value, pnl)
                local val = pnl:GetOptionData(index)
                BotData.material.imgur_blendmode = val
                UpdateModel(mdl.Entity)
            end)

            local Entry = zbf.vgui.ImgurEntry(parent,zbf.language["ImgurID"],function(val,txt)
                BotData.material.imgur_url = val
                ImgurMat = nil
                zclib.Imgur.GetMaterial(tostring(BotData.material.imgur_url), function(result)
                    if result then
                        ImgurMat = result
                    else
                        BotData.material.imgur_url = nil
                    end

                    UpdateModel(mdl.Entity)
                end)

                if LastFrame ~= CurTime() then
                    txt:SetValue(BotData.material.imgur_url)
                    LastFrame = CurTime()
                end
            end)
            if BotData.material.imgur_url then
                Entry:SetValue(BotData.material.imgur_url)
            end

            zbf.vgui.NumSlider(parent,BotData.material.imgur_x,zbf.language["PositionX"],function(val)
                BotData.material.imgur_x = val
                UpdateModel(mdl.Entity)
            end,0,1,2)

            zbf.vgui.NumSlider(parent,BotData.material.imgur_y,zbf.language["PositionY"],function(val)
                BotData.material.imgur_y = val
                UpdateModel(mdl.Entity)
            end,0,1,2)

            zbf.vgui.NumSlider(parent,BotData.material.imgur_scale,zbf.language["Scale"],function(val)
                BotData.material.imgur_scale = val
                UpdateModel(mdl.Entity)
            end,0.1,15,2)

            if BotData and BotData.material.imgur_url then
                zclib.Imgur.GetMaterial(tostring(BotData.material.imgur_url), function(result)
                    if result then
                        ImgurMat = result
                        UpdateModel(mdl.Entity)
                    end
                end)
            end
        end)

        CategoryBox(cat_list,zbf.language["Logo"],function(parent)

            // Imgur color
            ColorMixer(parent,BotData.material.logo_color,zbf.language["Image Color"],true,function(col)
                BotData.material.logo_color = Color(col.r,col.g,col.b,col.a)
                UpdateModel(mdl.Entity)
            end)

            // Blendmode
            BlendMode(parent, BotData.material.logo_blendmode or 0, function(index, value, pnl)
                local val = pnl:GetOptionData(index)
                BotData.material.logo_blendmode = val
                UpdateModel(mdl.Entity)
            end)

            local Entry = zbf.vgui.ImgurEntry(parent,zbf.language["ImgurID"],function(val,txt)
                BotData.material.logo_url = val
                LogoMat = nil
                zclib.Imgur.GetMaterial(tostring(BotData.material.logo_url), function(result)
                    if result then
                        LogoMat = result
                    else
                        BotData.material.logo_url = nil
                    end

                    UpdateModel(mdl.Entity)
                end)

                if LastFrame ~= CurTime() then
                    txt:SetValue(BotData.material.logo_url)
                    LastFrame = CurTime()
                end
            end)
            if BotData.material.logo_url then Entry:SetValue(BotData.material.logo_url) end

            zbf.vgui.NumSlider(parent,BotData.material.logo_x or 0.5,zbf.language["PositionX"],function(val)
                BotData.material.logo_x = val
                UpdateModel(mdl.Entity)
            end,0,1,2)

            zbf.vgui.NumSlider(parent,BotData.material.logo_y or 0.5,zbf.language["PositionY"],function(val)
                BotData.material.logo_y = val
                UpdateModel(mdl.Entity)
            end,0,1,2)

            zbf.vgui.NumSlider(parent,BotData.material.logo_scale or 1,zbf.language["Scale"],function(val)
                BotData.material.logo_scale = val
                UpdateModel(mdl.Entity)
            end,0.05,1,2)

            zbf.vgui.NumSlider(parent,BotData.material.logo_rotation or 0,zbf.language["Rotation"],function(val)
                BotData.material.logo_rotation = val
                UpdateModel(mdl.Entity)
            end,0,360,0)

            if BotData and BotData.material.logo_url then
                zclib.Imgur.GetMaterial(tostring(BotData.material.logo_url), function(result)
                    if result then
                        LogoMat = result
                        UpdateModel(mdl.Entity)
                    end
                end)
            end
        end)

        CategoryBox(cat_list,zbf.language["Emissive"],function(parent)

            zbf.vgui.NumSlider(parent,BotData.material.em_strength,zbf.language["Strength"],function(val)
                BotData.material.em_strength = val
                UpdateModel(mdl.Entity)
            end,0,1,2)

            // Imgur color
            ColorMixer(parent,BotData.material.em_color,zbf.language["Emissive Color"],false,function(col)
                BotData.material.em_color = Color(col.r,col.g,col.b,255)
                UpdateModel(mdl.Entity)
            end)

            local Entry = zbf.vgui.ImgurEntry(parent,zbf.language["ImgurID"],function(val,txt)
                BotData.material.em_url = val
                EmissveMat = nil
                zclib.Imgur.GetMaterial(tostring(BotData.material.em_url), function(result)
                    if result then
                        EmissveMat = result
                    else
                        BotData.material.em_url = nil
                    end

                    UpdateModel(mdl.Entity)
                end)

                if LastFrame ~= CurTime() then
                    txt:SetValue(BotData.material.em_url)
                    LastFrame = CurTime()
                end
            end)
            if BotData.material.em_url then
                Entry:SetValue(BotData.material.em_url)
            end

            zbf.vgui.NumSlider(parent,BotData.material.em_x,zbf.language["PositionX"],function(val)
                BotData.material.em_x = val
                UpdateModel(mdl.Entity)
            end,0,1,2)

            zbf.vgui.NumSlider(parent,BotData.material.em_y,zbf.language["PositionY"],function(val)
                BotData.material.em_y = val
                UpdateModel(mdl.Entity)
            end,0,1,2)

            zbf.vgui.NumSlider(parent,BotData.material.em_scale,zbf.language["Scale"],function(val)
                BotData.material.em_scale = val
                UpdateModel(mdl.Entity)
            end,0.1,15,2)

            if BotData and BotData.material.em_url then
                zclib.Imgur.GetMaterial(tostring(BotData.material.em_url), function(result)
                    if result then
                        EmissveMat = result
                        UpdateModel(mdl.Entity)
                    end
                end)
            end
        end)

        local ImgurImagePreview = vgui.Create("DButton", OptionsPnl)
        ImgurImagePreview:SetText("")
        ImgurImagePreview:SetSize(350 * zclib.wM, 350 * zclib.hM)
        ImgurImagePreview:Dock(BOTTOM)
        ImgurImagePreview:DockMargin(0 * zclib.wM,10 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
        ImgurImagePreview.ToggledOpen = true
        ImgurImagePreview.Paint = function(s, w, h)
            draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"])
            if ImgurImagePreview.ToggledOpen then

                zbf.Bot.DrawMaterial(w,h,BotData,ImgurMat,LogoMat)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

            	if EmissveMat then
                    local lastMul = surface.GetAlphaMultiplier()
                    surface.SetAlphaMultiplier(BotData.material.em_strength)
                    local bm = zbf.Bot.BlendModes[1]
        			render.OverrideBlend(true, bm.srcBlend, bm.destBlend, bm.blendFunc, bm.srcBlendAlpha, bm.destBlendAlpha, bm.blendFuncAlpha)
        				zbf.Bot.DrawEmissive(BotData, EmissveMat,w,h)
        			render.OverrideBlend( false )
                    surface.SetAlphaMultiplier(lastMul)
            	end

                if s:IsHovered() then
                    draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a200"])
                    draw.SimpleText(zbf.language["Close"], zclib.GetFont("zclib_font_big"), w / 2, h / 2, zclib.colors["orange01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            else
                draw.SimpleText(zbf.language["2D Preview"], zclib.GetFont("zclib_font_mediumsmall"), w / 2, h / 2, zclib.colors["orange01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        ImgurImagePreview.DoClick = function()
            if ImgurImagePreview.Animating then return end
            //surface.PlaySound("zerolib/upgrade.wav")
            zclib.vgui.PlayEffectAtPanel("Magic",ImgurImagePreview,0,0)

            ImgurImagePreview.Animating = true

            ImgurImagePreview:SizeTo(ImgurImagePreview:GetWide(), (not ImgurImagePreview.ToggledOpen) and 350 * zclib.hM or 30 * zclib.hM, 0.15, 0, -1, function()
                ImgurImagePreview.ToggledOpen = not ImgurImagePreview.ToggledOpen
                ImgurImagePreview.Animating = false
            end)
        end

        UpdateModel(mdl.Entity)
    end)
end

/*
    Creates a page which display a loading symbol
*/
function zbf.Bot.Editor.Wait()
    zclib.vgui.Page(zbf.language["Bot Editor"], function(main, top)
        main:SetSize(1200 * zclib.wM, 1000 * zclib.hM)

        local ImgurImagePreview = vgui.Create("DPanel", main)
        ImgurImagePreview:Dock(FILL)
        ImgurImagePreview:DockMargin(50 * zclib.wM,10 * zclib.hM,50 * zclib.wM,10 * zclib.hM)
        ImgurImagePreview.Paint = function(s, w, h)
            draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"])

            surface.SetDrawColor(zclib.colors["text01"])
            surface.SetMaterial(zclib.Materials.Get("icon_loading"))
            surface.DrawTexturedRectRotated(w / 2, h / 2, 300 * zclib.wM,300 * zclib.hM, zclib.util.SnapValue(36, CurTime() * -700))
        end

        timer.Simple(0.25,function()
            zbf.Bot.Editor.MainMenu()
        end)
    end)
end

/*
    Tell zcLib Data system to send net msg to SERVER
*/
function zbf.Bot.Editor.UpdateServer()
    // Send net msg to server
    zclib.Data.UpdateConfig("zbf_bot_config")
end

/*
	Lets us edit a list of jobs
*/
function zbf.Bot.Editor.List(title,key,color)
	zclib.vgui.Page("       " .. title, function(main, top)

		if WindowMode then
			main:SetSize(1200 * zclib.wM, 1000 * zclib.hM)
			main:SetDraggable(true)
		else
			main:SetSize(ScrW(), ScrH())
			main:SetDraggable(false)
		end
		main:Center()

		local suggestions = {}
		for _, v in pairs(zbf.config.Bots) do
			if v and v[key] then
				for itm, _ in pairs(v[key]) do
					suggestions[itm] = true
				end
			end
		end

		// Get all the jobs from ExtraTeams and add their name too
		if key == "jobs" then
			for _, v in pairs(team.GetAllTeams()) do
				if v and v.Name then
					suggestions[v.Name] = true
				end
			end
		end

		local back = zbf.vgui.ImageButton(top, zclib.Materials.Get("back"), zclib.colors["orange01"], function()
			zbf.Bot.Editor.Start()
		end, function() return false end, zbf.language["Back"])
		back:Dock(LEFT)
		back:DockMargin(40 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

		local parent = vgui.Create("DPanel", main)
		parent:SetSize(1000 * zclib.wM, 1000 * zclib.hM)
		parent:Dock(FILL)
		parent:DockMargin(50 * zclib.wM, 5 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
		parent.Paint = function(s, w, h) end

		local content
		local function RebuildList()
			if IsValid(content) then content:Remove() end
			content = vgui.Create("DPanel", parent)
			content:Dock(FILL)
			content.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a50"])
				draw.RoundedBox(5, w - 15 * zclib.wM, 0, 15 * zclib.wM, h, zclib.colors["black_a50"])
			end

			local list, scroll = zclib.vgui.List(content)
			scroll:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			list:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			list:SetSpaceY(10 * zclib.hM)
			list:SetSpaceX(10 * zclib.wM)

			local function AddButton(txt,rcolor, OnClick)
				local btnpnl = zbf.vgui.Button(scroll, txt, zclib.GetFont("zclib_font_medium"), rcolor, function()
					pcall(OnClick, txt)
				end)
				btnpnl:Dock(NODOCK)
				btnpnl:SetSize(100 * zclib.wM, 50 * zclib.hM)
				btnpnl:SizeToContentsX(10)
				list:Add(btnpnl)
			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199109663699

			if BotData[key] == nil then BotData[key] = {} end
			for k, v in pairs(BotData[key]) do
				AddButton(k,color, function(val)
					BotData[key][val] = nil
					RebuildList()
				end)
			end

			for k,v in pairs(suggestions) do
				if BotData[key][k] == nil then

					// Adds the suggestion and rebuilds the list
					AddButton(k,zclib.colors["ui02_grey"], function(val)
						BotData[key][val] = true
						RebuildList()
					end)
				end
			end
		end
		RebuildList()

		if key == "ranks" then
			local txt = zclib.vgui.TextEntry(top, "", function(val) end, false)
			txt:Dock(RIGHT)
			txt:SetWide(300)
			txt:DockMargin(10 * zclib.wM, 0 * zclib.hM, 40 * zclib.wM, 0 * zclib.hM)
			txt.bg_color = zclib.colors["black_a50"]
			txt.font = zclib.GetFont("zclib_font_medium")

			zbf.vgui.ImageButton(top, zclib.Materials.Get("plus"), zclib.colors["green01"], function()
				local val = txt:GetValue()

				if val and val ~= "" and val ~= " " then
					if BotData[key] == nil then BotData[key] = {} end
					BotData[key][val] = true
					RebuildList()
					txt:SetValue("")
				end
			end, function() return false end, zbf.language["Add Item"])
		end
	end)
end



local function BuildClipboard(id)
    local dat = zbf.Bot.GetData(id)
    if dat == nil then return end

    local text = [[AddBot({
    uniqueid = "]] .. tostring(dat.uniqueid) .. [[",
    name = "]] .. dat.name .. [[",
    mdl = "]] .. dat.mdl .. [[",
    health = ]] .. dat.health .. [[,
    price = ]] .. dat.price .. [[,
	tps = ]] .. dat.tps .. [[,
	attack = ]] .. dat.attack .. [[,
	defense = ]] .. dat.defense .. [[,
	neuro = ]] .. dat.neuro .. [[,

]]

text = text .. [[
    ranks = {
]]

    for k, v in pairs(dat.ranks) do
        text = text .. [[       ["]] .. k .. [["] = true,
]]
    end

text = text .. [[
	},

]]

text = text .. [[

	jobs = {
]]
	for k, v in pairs(dat.jobs) do
		text = text .. [[       ["]] .. k .. [["] = true,
]]
	end
text = text .. [[
	},
]]

text = text .. [[

	material = {
		]]
	for k, v in pairs(dat.material) do
		if v == nil or k == nil then continue end
		if istable(v) then
			text = text .. k .. [[ = Color( ]] .. math.Round(v.r) .. [[ , ]] .. math.Round(v.g) .. [[ , ]] .. math.Round(v.b) .. [[ , ]] .. math.Round(v.a or 255) .. [[ ),
		]]
		elseif isstring(v) then
			text = text .. k .. [[ = "]] .. v .. [[",
		]]
		else
			text = text .. k .. [[ = ]] .. v .. [[,
		]]
		end
	end
	text = text .. [[

	},
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 388a1c86da0b2b3b143103007c189551b38773c41275ecf21fd90ac6b5e0a95c

]]

text = text .. [[
})]]
	text = string.Replace(text,[[\]],[[/]])

	return text
end

function zbf.Bot.CopyToClipboard(id)
	local dat = zbf.Bot.GetData(id)
	if dat == nil then return end
	SetClipboardText(BuildClipboard(id))
	zclib.vgui.Notify(zbf.language[ "ClipboardNotify" ], NOTIFY_GENERIC)
end
