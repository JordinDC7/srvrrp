--[[

Author: tochnonement
Email: tochnonement@gmail.com

14/08/2024

--]]

local L = function( ... ) return onyx.lang:Get( ... ) end

local COLOR_PRIMARY = onyx:Config( 'colors.primary' )
local COLOR_SECONDARY = onyx:Config( 'colors.secondary' )
local COLOR_BG = onyx.LerpColor( .1, COLOR_PRIMARY, color_black )

function onyx.hud.OpenSettings()
    local padding = onyx.ScaleTall( 15 )
    local conPadding = onyx.ScaleTall( 10 )

    RunConsoleCommand( 'cl_onyx_hud_show_help', 0 )
    
    local frame = vgui.Create( 'onyx.Frame' )
    frame:SetSize( ScrW() * .5, ScrH() * .65 )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( 'ONYX HUD' )

    local content = frame:Add( 'Panel' )
    content:DockPadding( padding, padding, padding, padding )
    content:Dock( FILL )

    local navbar = content:Add( 'onyx.Navbar' )
    navbar:SetTall( onyx.ScaleTall( 30 ) )
    navbar:Dock( TOP )
    navbar.Paint = function(panel, w, h)
        draw.RoundedBoxEx( 8, 0, 0, w, h, COLOR_SECONDARY, true, true )
    end

    local container = content:Add( 'Panel' )
    container:Dock( FILL )
    container:DockPadding( conPadding, conPadding, conPadding, conPadding )
    container.Paint = function( panel, w, h )
        draw.RoundedBoxEx( 8, 0, 0, w, h, COLOR_SECONDARY, false, false, true, true )
        draw.RoundedBoxEx( 8, 1, 1, w - 2, h - 2, COLOR_BG, false, false, true, true )
    end

    navbar:SetContainer( container )

    CAMI.PlayerHasAccess( LocalPlayer(), 'onyx_hud_edit', function( bHasAccess )
        if ( IsValid( frame ) ) then
            local tabsAmount = bHasAccess and 2 or 1
            local tabWidth = ( frame:GetWide() - padding * 2 ) / tabsAmount

            navbar:AddTab({
                name = L( 'settings_u' ),
                class = 'onyx.hud.ClientSettings',
                material = Material( 'onyx_hud/settings_u.png', 'smooth' ),
            }):SetWide( tabWidth )
        
            if ( bHasAccess ) then
                navbar:AddTab({
                    name = L( 'configuration_u' ),
                    material = Material( 'onyx_hud/configuration_u.png', 'smooth' ),
                    class = 'onyx.Configuration',
                    onBuild = function( panel )
                        panel:LoadAddonSettings( 'hud' )
                        panel:OpenCategories()
                    end
                }):SetWide( tabWidth )
            end

            navbar:ChooseTab( 1 )
            navbar:SetVisible( bHasAccess )
        end
    end )

    return frame
end

concommand.Add( 'onyx_hud', function() onyx.hud.OpenSettings() end )