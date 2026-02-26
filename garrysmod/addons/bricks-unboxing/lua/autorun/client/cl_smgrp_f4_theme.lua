-- ============================================================
-- SmG RP - Xenin F4 Menu Theme Override
-- Overrides XeninUI.Theme to match our dark tactical UI
-- Runs after Xenin framework loads
-- ============================================================
if not CLIENT then return end

local function ApplyF4Theme()
    if not XeninUI or not XeninUI.Theme then return end

    -- Override XeninUI core theme colors
    XeninUI.Theme.Primary    = Color(26, 27, 35)     -- bg_mid
    XeninUI.Theme.Navbar     = Color(18, 18, 26)     -- bg_dark
    XeninUI.Theme.Background = Color(14, 15, 20)     -- darker than bg_darkest
    XeninUI.Theme.Accent     = Color(0, 212, 170)    -- teal accent
    XeninUI.Theme.Red        = Color(220, 60, 60)    -- our red
    XeninUI.Theme.Green      = Color(60, 200, 120)   -- our green
    XeninUI.Theme.Blue       = Color(70, 140, 255)   -- our blue
    XeninUI.Theme.Yellow     = Color(255, 185, 50)   -- our amber
    XeninUI.Theme.Purple     = Color(155, 70, 255)   -- our epic purple
    XeninUI.Theme.Orange     = Color(255, 150, 40)   -- warm orange
    XeninUI.Theme.OrangeRed  = Color(255, 100, 60)
    XeninUI.Theme.LightYellow = Color(200, 200, 30)
    XeninUI.Theme.GreenDark  = Color(40, 150, 90)

    -- Override F4Menu config colors if available
    if F4Menu and F4Menu.Config then
        F4Menu.Config.Colors = {
            Top = Color(22, 23, 30),
            Sidebar = Color(18, 18, 26),
            Background = Color(14, 15, 20),
        }
        F4Menu.Config.CategoriesBackgroundFullyColored = false

        -- Ensure title is correct
        if F4Menu.Config.Title ~= "SmG RP" then
            F4Menu.Config.Title = "SmG RP"
        end
    end

    print("[SmG RP] F4 Menu theme override applied")
end

-- Apply after Xenin loads (multiple fallbacks)
hook.Add("InitPostEntity", "SMGRP_F4Theme", function()
    timer.Simple(0.5, ApplyF4Theme)
end)

-- Also apply on HUDPaint once (catches late loads)
local _applied = false
hook.Add("HUDPaint", "SMGRP_F4ThemeOnce", function()
    if _applied then
        hook.Remove("HUDPaint", "SMGRP_F4ThemeOnce")
        return
    end
    if XeninUI and XeninUI.Theme then
        ApplyF4Theme()
        _applied = true
        hook.Remove("HUDPaint", "SMGRP_F4ThemeOnce")
    end
end)

-- Override the F4 row Paint to use our dark style
hook.Add("InitPostEntity", "SMGRP_F4RowOverride", function()
    timer.Simple(1, function()
        -- Pre-allocated colors for row paint (zero allocs per frame)
        local _rowBg       = Color(22, 23, 30)
        local _rowBgHover  = Color(34, 36, 46)
        local _rowAccent   = Color(0, 212, 170, 120)
        local _rowName     = Color(220, 222, 230)
        local _rowPrice    = Color(0, 180, 150)
        local _rowSalary   = Color(0, 180, 150, 200)
        local _rowArcBg    = Color(14, 15, 20)
        local _rowArcFg    = Color(0, 212, 170)
        local _rowDot      = Color(0, 212, 170)

        -- ====== ITEM ROWS (entities, weapons, ammo, etc) ======
        local rowMeta = vgui.GetControlTable("F4Menu.Items.Row")
        if rowMeta then
            rowMeta.Paint = function(self2, w, h)
                local hovered = self2:IsHovered()
                XeninUI:DrawRoundedBox(6, 0, 0, w, h, hovered and _rowBgHover or _rowBg)

                if hovered then
                    surface.SetDrawColor(_rowAccent)
                    surface.DrawRect(0, 4, 2, h - 8)
                end

                local x = IsValid(self2.ModelPanel) and (self2.ModelPanel.x + self2.ModelPanel:GetWide() + self2.ModelPanel.x) or 16

                XeninUI:DrawShadowText(self2.Name, "F4Menu.Jobs.Row.Name", x, h / 2, _rowName, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, 150)
                XeninUI:DrawShadowText(self2.PriceStr, "F4Menu.Jobs.Row.Salary", x, h / 2, _rowPrice, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 150)

                local limit = self2.Limit
                if limit then
                    local frac, str = 0, ""
                    if (limit == 0) then
                        str = "∞"
                    else
                        local amount = LocalPlayer():getCustomEntity(self2.Data)
                        frac = math.Clamp(amount / limit, 0, 1)
                        str = amount .. "/" .. limit
                    end

                    local size = h / 2 - 10
                    XeninUI:MaskInverse(function()
                        XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, 360, size * 0.8, _rowArcFg, 90)
                    end, function()
                        XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, 360, size, _rowArcBg, 90)
                    end)
                    XeninUI:MaskInverse(function()
                        XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, 360, size * 0.8, _rowArcFg, 90)
                    end, function()
                        XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, frac * 360, size, _rowArcFg, 90)
                    end)
                    XeninUI:DrawShadowText(str, "F4Menu.Jobs.Row.Limit", w - 16 - size / 2 - 8, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, 125)
                end
            end
        end

        -- ====== JOB ROWS ======
        local jobRowMeta = vgui.GetControlTable("F4Menu.Jobs.Row")
        if jobRowMeta and jobRowMeta.Paint then
            local origJobPaint = jobRowMeta.Paint
            jobRowMeta.Paint = function(self2, w, h)
                XeninUI:DrawRoundedBox(6, 0, 0, w, h, self2:IsHovered() and _rowBgHover or _rowBg)

                local x = IsValid(self2.ModelPanel) and (self2.ModelPanel.x + self2.ModelPanel:GetWide() + self2.ModelPanel.x) or 16

                if self2.Name then
                    XeninUI:DrawShadowText(self2.Name, "F4Menu.Jobs.Row.Name", x, h / 2, _rowName, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, 150)
                end
                if self2.Salary then
                    XeninUI:DrawShadowText(DarkRP.formatMoney(self2.Salary), "F4Menu.Jobs.Row.Salary", x, h / 2, _rowSalary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 150)
                end

                -- Team indicator dot for current team
                if self2.Data and team.GetName(LocalPlayer():Team()) == team.GetName(self2.Data.team) then
                    draw.RoundedBox(4, w - 24, h / 2 - 4, 8, 8, _rowDot)
                end
            end
        end

        print("[SmG RP] F4 row paint overrides applied")
    end)
end)
