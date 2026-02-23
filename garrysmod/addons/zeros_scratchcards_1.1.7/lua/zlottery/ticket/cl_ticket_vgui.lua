if SERVER then return end

local function OpenInterface(uniqueid,prizeid,reg_id)
    if IsValid(zlt_Ticket_panel) then zlt_Ticket_panel:Remove() end
    if zlt.Ticket.DoesExist(uniqueid,prizeid) == false then return end

    // Close the XeninInventory if its open
    if XeninInventory and IsValid(XeninInventory.Frame) then XeninInventory.Frame:Remove() end

    // Close the Itemstore inventory
    if itemstore then
        for k,v in pairs(vgui.GetWorldPanel():GetChildren()) do
            if IsValid(v) and v:GetName() == "ItemStoreContainerWindow" then
                v:Close()
                break
            end
        end
    end

    local TicketID = zlt.Ticket.GetID(uniqueid)

    zlt_Ticket_panel = vgui.Create("ZLT_TICKET")
    zlt_Ticket_panel.TicketID = TicketID
    zlt_Ticket_panel.PrizeID = prizeid
    zlt_Ticket_panel.RegID = reg_id
end

// Called from the ticket entity
net.Receive("zlt_Ticket_Open", function(len)
    zclib.Debug_Net("zlt_Ticket_Open", len)
    LocalPlayer().zlt_Ticket = net.ReadEntity()
    if not IsValid(LocalPlayer().zlt_Ticket) then return end

    local uniqueid = LocalPlayer().zlt_Ticket:GetTicketID()
    local prizeid = LocalPlayer().zlt_Ticket:GetPrizeID()

    OpenInterface(uniqueid,prizeid)
end)

// Informs the player that his ticket got registered, Only called by the entity
net.Receive("zlt_Ticket_RegisterUse", function(len)
    zclib.Debug_Net("zlt_Ticket_RegisterUse", len)

    local reg_uniqueid = net.ReadString()

    if reg_uniqueid and IsValid(zlt_Ticket_panel) then
        zlt_Ticket_panel.RegID = reg_uniqueid
    end
end)


// Called from a players inventory
net.Receive("zlt_Ticket_InventorytUse", function(len)
    zclib.Debug_Net("zlt_Ticket_InventorytUse", len)

    local uniqueid = net.ReadString()
    local prizeid = net.ReadUInt(10)
    local reg_uniqueid = net.ReadString()

    OpenInterface(uniqueid,prizeid,reg_uniqueid)
end)

// Called from a players inventory
net.Receive("zlt_Ticket_InstantUse", function(len)
    zclib.Debug_Net("zlt_Ticket_InstantUse", len)

    local uniqueid = net.ReadString()
    local prizeid = net.ReadUInt(10)
    local reg_uniqueid = net.ReadString()

    OpenInterface(uniqueid,prizeid,reg_uniqueid)
end)




// Called from server to force close the interface, if the player dies
net.Receive("zlt_Ticket_Close", function(len)
    zclib.Debug_Net("zlt_Ticket_Close", len)

	if IsValid(zlt_Ticket_panel) then
		zlt_Ticket_panel:Close()
	end
end)




local VGUIItem = {}
function VGUIItem:Init()
    self:SetSize(ScrW(),ScrH())
    self:Center()
    self:MakePopup()
    self:ShowCloseButton(false)
    self:SetTitle("")
    self:SetDraggable(false)
    self:SetSizable(false)
    self:DockPadding(0,0,0,0)

    zclib.vgui.PlaySound("zlt/ui_slide.wav")

    self.ScratchedFields = 0
	self.ScratchedWinFields = 0
    self.RarityColor = "86, 182, 194"

    timer.Simple(0, function()
        if IsValid(self) then
            self:SetupTicket3D()
        end
    end)
end

function VGUIItem:SetupTicket3D()
    local Main = zclib.vgui.ModelPanel({model = "models/zerochain/props_lottery/ticket.mdl"})
    Main:SetParent(self)
    Main:Dock(FILL)
    Main:SetDirectionalLight(BOX_TOP, color_black)
    Main:SetDirectionalLight(BOX_FRONT,color_black)
    Main:SetDirectionalLight(BOX_LEFT, color_black)
    Main:SetDirectionalLight(BOX_BACK, color_black)
    Main:SetAmbientLight(color_black)
    Main:SetDirectionalLight(BOX_RIGHT, Color(255,255,255))
    Main:SetFOV(7.5)
    Main.LayoutEntity = function(s)
        Main.Entity:SetAngles(Angle(5 - 10 * math.sin(CurTime() * 1),-90 + 10 * math.sin(CurTime() * 0.8),  0))
    end
    Main:SetCamPos(Vector(0,100,15))
    Main.PreDrawModel = function(s,ent)
        cam.Start2D()
            surface.SetDrawColor(color_black)
            surface.SetMaterial(zclib.Materials.Get("radial_shadow"))
            surface.DrawTexturedRect(0, 0, s:GetWide(), s:GetTall())
        cam.End2D()
    end


    // Create ticketmaterial
    local i_matid = "zlt_ticket_3dview"
    local m_material =  zlt.Ticket.GetMaterial(i_matid)
    self.TicketMaterial = m_material
    self.TicketMaterial:SetTexture("$envmap", "zerochain/props_lottery/ticket/zlt_ticket_env01")
    self.TicketMaterial:SetVector("$envmaptint", Vector(0.5,0.5,0.5))
    self.TicketMaterial:SetFloat("$envmapfresnel", 0.5)


    local cX,cY = input.GetCursorPos()

    local function ConvertW(val) return (val / 1600) * zlt.ScreenW end
    local function ConvertH(val) return (val / 900) * zlt.ScreenH end


    local TicketData = zlt.config.Tickets[self.TicketID]
    local prizedata = TicketData.prizelist[self.PrizeID]

    self.PrizeValue = zlt.Ticket.GetPrizeDisplayValue(self.TicketID,self.PrizeID)
    self.PrizeType = zlt.Ticket.PrizeTypes[prizedata.type].name
    self.PrizeName = zlt.Ticket.GetPrizeName(self.TicketID,self.PrizeID)
    self.DidWin = zlt.Ticket.DidWin(self.TicketID,self.PrizeID)
    self.RarityColor = zlt.Ticket.GetRarityColor(self.TicketID,self.PrizeID)

    local List = zlt.Ticket.GenerateFieldList(self.TicketID,self.PrizeID)

    local ScratchFields = {}
    local fw, fh = (ConvertW(700) / 3) * 0.95, (ConvertH(567) / 3) * 0.95
    local nX, nY = ConvertW(950), ConvertH(310)
    local ThreeStack = 0
    for i = 1, 9 do
        ThreeStack = ThreeStack + 1
        local font = zclib.GetFont("zlt_ticket_desc")
        if string.len(List[i].val) >= 5 then
            font = zclib.GetFont("zlt_ticket_desc_small")
        end
        ScratchFields[i] = {
            x = nX + (ConvertW(700) / 3) * 0.05,
            y = nY,
            scratched = false,
            scratchlevel = 1,


            p_icon_img = List[i].p_icon_img,
            p_icon_color = List[i].p_icon_color,
            p_icon_stencil = List[i].p_icon_stencil,
            val = List[i].val,
            IsWinner = List[i].IsWinner,

            font = font,
            color = color_black,
			scratch_bg_col = TicketData.scratch_bg_col or color_white
        }

        if ThreeStack >= 3 then
            nX = ConvertW(950)
            nY = nY + fh
            ThreeStack = 0
            continue
        end

        nX = nX + fw
    end

    local LastPos
    Main.Emitters = {}
    Main.PostDrawModel = function(s,ent)
        // Render all scratch effects we got and remove the finished ones
        for k,v in pairs(Main.Emitters) do
            if v and v:IsValid() then
                v:Render()

                if v:IsFinished() then
                    v:StopEmission(false, true)
                end
            end
        end

        if Main.UpdateRenderTarget then

            if input.IsMouseDown(MOUSE_LEFT) then
                cX, cY = input.GetCursorPos()

                cX = (zlt.ScreenW / ConvertW(850)) * (cX - ConvertW(370))
                cX = math.Clamp(cX,0,zlt.ScreenW)

                cY = (zlt.ScreenH / ConvertH(430)) * (cY -  ConvertH(235))
                cY = math.Clamp(cY,0,zlt.ScreenH)
            end

            // Calculates Cursor pos to world pos
            /////////////////////////////////
            if input.IsMouseDown(MOUSE_LEFT) then
                local mX, mY = input.GetCursorPos()

                local min,max = ent:GetRenderBounds()
                local ent_w = math.abs(min.y) + math.abs(max.y)
                local ent_h =  math.abs(min.z) +  math.abs(max.z)
                local wX = (ent_w / zlt.ScreenW) * mX
                local wY = (ent_h / zlt.ScreenH) * mY

                wX = (-wX + 3.7) * 1.85
                wX = math.Clamp(wX,-3.3,3.3)

                wY = (-wY + 2) * 1.85
                wY = math.Clamp(wY,-1.3,1.3)

                self.CursorLocalPos = Vector(-0.7,wX,wY)
            end
            if self.CursorLocalPos then self.CursorWorldPos = Main.Entity:LocalToWorld(self.CursorLocalPos) end
            /////////////////////////////////

            // If we dont validate .DrawModel before calling it then the game crashes!
            if input.IsMouseDown(MOUSE_LEFT) and self.CursorWorldPos and IsValid(self.Coin) and self.Coin.DrawModel then
                local swenk = 25 * math.sin(CurTime() * 10)
                local ang = Main.Entity:LocalToWorldAngles(Angle(0, swenk, 0))
                self.Coin:SetAngles(ang)
                self.Coin:SetPos(self.CursorWorldPos)
                self.Coin:DrawModel()
            end


            // Updates the material every frame
            zlt.Ticket.ReplaceMaterial(ent,m_material,i_matid,self.TicketID,"zlt_ticket_rendertarget",function()

                // Calculate cursor speed
                local Speed = 0
                local CurPos = Vector(cX,cY,0)
                if LastPos then
                    Speed = math.Round(LastPos:Distance(CurPos) / FrameTime(),2)
                end
                LastPos = CurPos

                // Draw the scratch fields
                local aW, aH = fw * 0.3, fh * 0.3
                for k,v in pairs(ScratchFields) do

                    if v.scratchlevel > 0 and v.scratch_mat then
                        surface.SetDrawColor(v.scratch_bg_col)
                        surface.SetMaterial(zclib.Materials.Get(v.scratch_mat))
                        surface.DrawTexturedRectRotated(v.x, v.y, fw, fh, 0)
                    end

                    if Speed > 1000 and v.scratched == false and cX > v.x - aW and cX < v.x + aW and cY > v.y - aH and cY < v.y + aH then

                        zclib.vgui.PlaySound("zlt/scratch0" .. math.random(5) .. ".wav")

                        self:OnScratch()

                        ////////////////////
                        local emitter = CreateParticleSystem(ent,"zlt_scratch_explo01",PATTACH_WORLDORIGIN, 0, self.CursorWorldPos)
                        if IsValid(emitter) then
                            emitter:StartEmission(false)
                            emitter:SetShouldDraw(false)
                            table.insert(Main.Emitters,emitter)
                        end
                        ////////////////////

                        if v.scratchlevel >= 2 then
                            v.scratched = true

                            self.ScratchedFields = self.ScratchedFields + 1

                            if self.ScratchedFields >= 9 then
                                self:OnScratchCompleted()
                            end

                            if math.random(10) > 5 then
                                v.scratch_mat = "rubbfield04"
                            else
                                v.scratch_mat = "rubbfield03"
                            end
                        else
                            v.scratchlevel = v.scratchlevel + 1
                            v.scratch_mat = "rubbfield0" .. v.scratchlevel
                        end

                        v.scratchlevel = v.scratchlevel + 1
                    end

                    if v.scratched == false then continue end

                    // If we scratched all fields then highlight the winings or show a lost screen
                    if self.ScratchedFields >= 9 and v.IsWinner == true then

                        local mrot = zclib.util.SnapValue(15, 15 * math.sin(CurTime() * 16))

                        surface.SetDrawColor(color_black)
                        surface.SetMaterial(zclib.Materials.Get("explosion"))
                        surface.DrawTexturedRectRotated(v.x, v.y, fw, fh, mrot)

                        surface.SetDrawColor(zclib.colors["red01"])
                        surface.SetMaterial(zclib.Materials.Get("explosion"))
                        surface.DrawTexturedRectRotated(v.x, v.y, fw * 0.9, fh * 0.9, mrot)

                        surface.SetDrawColor(zclib.colors["orange01"])
                        surface.SetMaterial(zclib.Materials.Get("explosion"))
                        surface.DrawTexturedRectRotated(v.x, v.y, fw * 0.7, fh * 0.7, zclib.util.SnapValue(30, 30 * math.sin(CurTime() * 16)))
                    end

                    if v.p_icon_img then
                        if v.p_icon_stencil then
                            BMASKS.BeginMask("zclib_Circle")
                                surface.SetDrawColor(v.p_icon_color or v.color)
                                surface.SetMaterial(v.p_icon_img)
                                surface.DrawTexturedRectRotated(v.x, v.y, fw * 0.6, fh * 0.6, 0)
                            BMASKS.EndMask("zclib_Circle", v.x - fw * 0.31, v.y - fh * 0.31, fw * 0.62, fh * 0.62)
                        else
                            surface.SetDrawColor(v.p_icon_color or v.color)
                            surface.SetMaterial(v.p_icon_img)
                            surface.DrawTexturedRectRotated(v.x, v.y, fw * 0.6, fh * 0.6, 0)
                        end
                    else
                        draw.SimpleText(v.val, v.font, v.x, v.y, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            end,0)
        end
    end

    // Create coin model
    self.Coin = zclib.ClientModel.Add("models/zerochain/props_lottery/coin.mdl", RENDERGROUP_OPAQUE)
    self.Coin:SetModelScale(0.1)

    Main.OnRemove = function()
        for k,v in pairs(Main.Emitters) do
            if v then
                v:StopEmission(false, true)
            end
        end
    end
    timer.Simple(0,function() if IsValid(Main) then Main.UpdateRenderTarget = true end end)
end

function VGUIItem:OnScratch()
    if not IsValid(LocalPlayer().zlt_Ticket) then return end
    if self.FirstScratchOccured == true then return end
    self.FirstScratchOccured = true

    // Tells the server to remove the ticket entity and register its use
    net.Start("zlt_Ticket_RegisterUse")
    net.WriteEntity(LocalPlayer().zlt_Ticket)
    net.SendToServer()
end

// Called once the last field got scratched
function VGUIItem:OnScratchCompleted()
    if self.DidWin then
        LocalPlayer():EmitSound("zlt_win")
    else
        LocalPlayer():EmitSound("zlt_loose")
    end
end

function VGUIItem:Close()

    if IsValid(self.Coin) then
        zclib.ClientModel.Remove(self.Coin)
    end

    if self.RegID then
        if self.ScratchedFields >= 9 then
            net.Start("zlt_Ticket_RedeemPrize")
            net.WriteString(self.RegID)
            net.SendToServer()
        else
            net.Start("zlt_Ticket_KillPrize")
            net.WriteString(self.RegID)
            net.SendToServer()
        end
    end

    self.RegID = nil
    LocalPlayer().zlt_Ticket = nil
    self:Remove()
end


local function DrawButton(h,w,text,ishovered)
    if ishovered then
        draw.DrawText(text, zclib.GetFont("zclib_font_huge"), w / 2,h * 0.86, color_white, TEXT_ALIGN_CENTER)
        zclib.util.DrawOutlinedBox(w * 0.4, h * 0.85, w * 0.2, h * 0.1, 5, color_white)
    else
        draw.DrawText(text, zclib.GetFont("zclib_font_huge"), w / 2,h * 0.86, zclib.colors["white_a100"], TEXT_ALIGN_CENTER)
        zclib.util.DrawOutlinedBox(w * 0.4, h * 0.85, w * 0.2, h * 0.1, 5, zclib.colors["white_a100"])
    end
end

local MouseDown = input.IsMouseDown(MOUSE_LEFT)
function VGUIItem:Paint(w, h)

    if input.IsKeyDown(KEY_ESCAPE) then
        self:Close()
    end


    surface.SetDrawColor(color_white)
    surface.SetMaterial(zclib.Materials.Get("blur"))
    for i = 1, 15 do
        zclib.Materials.Get("blur"):SetFloat("$blur", (i / 15) * 1)
        zclib.Materials.Get("blur"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(0 * -1, 0 * -1, ScrW(), ScrH())
    end

    // Show if he lost
    if self.ScratchedFields >= 9 then

        surface.SetDrawColor(color_black)
        surface.SetMaterial(zclib.Materials.Get("radial_shadow"))
        surface.DrawTexturedRectRotated(w / 2, h * 0.12, w, h * 0.4, 0)

        if self.DidWin then
            if self.ParsedResult == nil then
                local text = string.Replace(zlt.language["YouWon"], "$PrizeName", "<colour=" .. self.RarityColor .. ",255>" .. (self.PrizeName or (self.PrizeValue .. " [" .. self.PrizeType .. "]")) .. "</colour>" .. "<colour=255, 255, 255,255>")
                self.ParsedResult = markup.Parse("<font=" .. zclib.GetFont("zclib_font_huge") .. ">" .. text .. "</colour>!</font>")
            else
                self.ParsedResult:Draw(w / 2, h * (0.12 + (0.01 * math.sin(CurTime() * 2))),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
        else
            draw.DrawText(zlt.language["NoWin"], zclib.GetFont("zclib_font_huge"), w / 2, h * (0.12 + (0.01 * math.sin(CurTime() * 2))), color_white, TEXT_ALIGN_CENTER)
        end
    end

    local _,mY = input.GetCursorPos()
    local IsHovered = mY > h * 0.8
    if IsValid(LocalPlayer().zlt_Ticket) and self.ScratchedFields <= 0 then
        DrawButton(h,w,zlt.language["Close"],IsHovered)
        if IsHovered and MouseDown ~= input.IsMouseDown(MOUSE_LEFT) and MouseDown == true then
            self:Close()
        end
        MouseDown = input.IsMouseDown(MOUSE_LEFT)
    else
        if self.ScratchedFields >= 9 then
            DrawButton(h,w,zlt.language["Close"],IsHovered)
            if IsHovered and MouseDown ~= input.IsMouseDown(MOUSE_LEFT) and MouseDown == true then
                self:Close()
            end
            MouseDown = input.IsMouseDown(MOUSE_LEFT)
        end
    end
end

vgui.Register("ZLT_TICKET", VGUIItem, "DFrame")
